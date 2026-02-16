/datum/bb_gear/printgun
	name = "3D Printed Gun Disk"
	desc = "Contains a disk containing designs to make subpar, but accessible guns, which are more useful for execution than combat..."
	spawn_path = /obj/item/disk/design_disk/liberator

/datum/bb_gear/gymnastics
	name = "Combat-Gymnastics Routines for Duos"
	desc = "A two-use, classical manual containing the techniques necessary for unhindered piggyback-riding, carrying, instant aggressive grabs on your partner and proper technique to avoid slowing down when dragging others."
	spawn_path = /obj/item/book/granter/martial/gymnastics


// GYMNASTICS GRANTER

/obj/item/book/granter/martial/gymnastics
	martial = /datum/martial_art/gymnastics
	name = "Gymnastics Routines for Duos"
	martial_name = "gymnastics"
	desc = "A two-use, classical manual containing techniques used by the Terrence-Manuel brothers, studied under legendary clown-acrobats E. Shirtface and Juggles The Clown. \
		Due to the second-hand account, the legendary acrobatic techniques allowing juggling people aren't found in this tome, but it has a fraction of their power, including details on unhindered piggybacking, \
		quickly tossing your partner, acrobatic pickups and the lifting technique to move freely when grabbing others!"

	greet = span_sciradio("You've learned advanced gymnastical routines, allowing you to quickly carry your partner as well as grab them twice as fast any non-proffessional would!")
	icon = 'icons/obj/scrolls.dmi'
	icon_state = "sleepingcarp"
	worn_icon_state = "scroll"
	remarks = list(
		"Hold hands... Leg on knee.. And up I go, this looks managable...",
		"Huh, it sure would suck to have a person at me...",
		"The Terrence-Manuel brothers sure knew how to fight as one, maybe if I get on someone's shoulders...",
		"To think first-generation clowns could juggle entire people... How... Terrifying.",
		"Have I been lifting with my back all this time?... Is that why it takes so long to drag prone people around?..."
	)
	uses = 2

/obj/item/book/granter/martial/gymnastics/on_reading_finished(mob/living/carbon/user)
	. = ..()
	update_appearance()

/obj/item/book/granter/martial/gymnastics/update_appearance(updates)
	. = ..()
	if(uses <= 0)
		name = "empty scroll"
		desc = "It's completely blank."
		icon_state = "blankscroll"
	else
		name = initial(name)
		desc = initial(desc)
		icon_state = initial(icon_state)

// GYMNASTICS "MARTIAL ART"

/datum/martial_art/gymnastics
	name = "Gymnastics"
	id = MARTIALART_GYMNASTICS
	display_combos = TRUE
	grab_state_modifier = 1
	/// List of traits applied to users of this martial art.
	var/list/gymnastics_traits = list(TRAIT_QUICKER_CARRY)

/datum/martial_art/gymnastics/activate_style(mob/living/new_holder)
	. = ..()
	new_holder.add_traits(gymnastics_traits, GYMNASTICS_TRAIT)
	new_holder.add_movespeed_mod_immunities("gymnastics", /datum/movespeed_modifier/grab_slowdown)
	new_holder.mind.adjust_experience(/datum/skill/athletics, (2500))

/datum/martial_art/gymnastics/deactivate_style(mob/living/remove_from)
	remove_from.remove_traits(gymnastics_traits, GYMNASTICS_TRAIT)
	remove_from.remove_movespeed_mod_immunities("gymnastics", /datum/movespeed_modifier/grab_slowdown)
	// new_holder.mind.remove_experience(/datum/skill/athletics, (-2500))
	return ..()

/datum/martial_art/gymnastics/grab_act(mob/living/attacker, mob/living/defender)
	if(attacker == defender)
		return

	var/old_grab_state = attacker.grab_state
	defender.grabbedby(attacker, TRUE)
	if(old_grab_state == GRAB_PASSIVE && locate(/datum/martial_art/gymnastics) in defender.martial_arts)
		attacker.setGrabState(GRAB_AGGRESSIVE) //Instant aggressive grab if it's another gymnast
		log_combat(attacker, defender, "grabbed", addition="aggressively")
		defender.visible_message(
			span_warning("[attacker] aggressively grabs [defender]!"),
			span_userdanger("You're expertly grabbed by your fellow gymnast, [attacker]!"),
			span_hear("You hear sounds of aggressive fondling!"),
			COMBAT_MESSAGE_RANGE,
			attacker,
		)
		to_chat(attacker, span_danger("You expertly grab your fellow gymnast, [defender]!"))


/mob/living/setGrabState(newstate)
	. = ..()
	switch(grab_state)
		if(GRAB_PASSIVE)
			remove_movespeed_modifier(MOVESPEED_ID_MOB_GRAB_STATE)
		if(GRAB_AGGRESSIVE)
			add_movespeed_modifier(/datum/movespeed_modifier/grab_slowdown/aggressive)
		if(GRAB_NECK)
			add_movespeed_modifier(/datum/movespeed_modifier/grab_slowdown/neck)
		if(GRAB_KILL)
			add_movespeed_modifier(/datum/movespeed_modifier/grab_slowdown/kill)
