/datum/bb_gear/printgun
	name = "3D Printed Gun Disk"
	desc = "Contains a disk containing designs to make subpar, but accessible guns, which are more useful for execution than combat..."
	spawn_path = /obj/item/disk/design_disk/liberator

/datum/bb_gear/gymnastics
	name = "Combat-Gymnastics Routines for Duos"
	desc = "A two-use, classical manual containing the techniques necessary for unhindered piggyback-riding, carrying, instant aggressive grabs on your partner and proper technique to avoid slowing down when dragging others."
	spawn_path = /obj/item/book/granter/martial/gymnastics

/datum/bb_gear/overwatch
	name = "Overwatch/Agent Kit"
	desc = "A box containing an old-fashioned hacking laptop, coming with all the tools an up and coming agent would need to remotely open doors for and watch over their partner with."
	spawn_path = /obj/item/storage/box/syndie_kit/overwatch

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
	icon_state = "cqcmanual"
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
		name = "useless book"
		desc = "It's illegible."
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
	if(old_grab_state == GRAB_PASSIVE && locate(/datum/martial_art/gymnastics) in defender.martial_arts && attacker.combat_mode)
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

// OVERWATCH KIT

/obj/item/storage/box/syndie_kit/overwatch
	name = "Overwatch/Agent Kit"

/obj/item/hacktop
	name = "Conspicuous Laptop"
	desc = "Nothing good can come out of this laptop's use, surely..."
	icon = 'icons/obj/devices/modular_laptop.dmi'
	icon_state = "laptop"
	var/other_pair
	var/mode = 0

/obj/item/hacktop/attack_self(mob/user, modifiers)
	. = ..()
	if(!other_pair)
		balloon_alert(user, "no doorbug linked!")
		return
	if(!other_pair.last_checked_airlock)
		balloon_alert(user, "no airlock linked through doorbug!")
		return
	var/obj/machinery/door/airlock/target_airlock = other_pair.last_checked_airlock
	var/dist_between = get_dist(get_turf(other_pair), get_turf(src))
	var/to_move_till_usable = 10 - dist_between
	if(dist_between < 9)
		balloon_alert(user, "the doorbug's signal is causing interference, move away from it! ([to_move_till_usable] more)")
	if(mode == 0) //open airlocks
		if(do_after(user, 4 SECONDS, target = src))
			if(target_airlock.density)
				target_airlock.open()
				continue
			target_airlock.close(force_crush = TRUE)

	if(mode == 1) //bolt airlocks
		if(do_after(user, 1 SECONDS, target = src))
			if(target_airlock.locked)
				target_airlock.secure_open
				continue
			target_airlock.secure_close()

	if(mode == 2) //shock airlocks
		if(do_after(user, 2 SECONDS, target = src))
			if(wires.is_cut(WIRE_SHOCK))
				to_chat(user, span_warning("Can't un-electrify the airlock - The electrification wire is cut."))
			else if(isElectrified())
				set_electrified(MACHINE_NOT_ELECTRIFIED)
			else if(!isElectrified())
				set_electrified(MACHINE_ELECTRIFIED_PERMANENT)

/obj/item/hacktop/attackby(obj/item/attacking_item, mob/user, list/modifiers, list/attack_modifiers)
	. = ..()
	if(istype(attacking_item, /obj/item/doorbug))
		var/obj/item/doorbug/our_doorbug = attacking_item
		our_doorbug.other_pair = src
		src.other_pair = our_doorbug
		balloon_alert(user, "linked!")


/obj/item/hacktop/attack_self_secondary(mob/user, modifiers)
	. = ..()
	mode++
	if(mode > 2)
		mode = 0
	var/mode_to_text
	switch(mode)
		if(0)
			mode_to_text = "opening/closing"
		if(1)
			mode_to_text = "force opening/bolting shut"
		if(2)
			mode_to_text = "electrifying/de-electrifying"

	balloon_alert(user, "set to [mode_to_text]")

/obj/item/doorbug
	name = "Conspicuous Tool"
	desc = "A suspicious widget, cobbled together from various materials. How odd..."
	icon =
	icon_state =
	var/other_pair
	var/last_checked_airlock

/obj/item/doorbug/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	. = ..()
	if(istype(interacting_with, /obj/machinery/door/airlock))
		var/obj/machinery/door/airlock/our_airlock = interacting_with
		last_checked_airlock = our_airlock

/obj/item/storage/box/syndie_kit/overwatch/PopulateContents()
	new	/obj/item/computer_disk/syndicate(src)
	var/obj/item/hacktop/a = new(src)
	var/obj/item/doorbug/b = new(src)

	A.other_pair = B
	B.other_pair = A

