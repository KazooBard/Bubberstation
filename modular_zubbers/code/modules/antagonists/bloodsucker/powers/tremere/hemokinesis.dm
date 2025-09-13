/datum/action/cooldown/bloodsucker/hemokinesis
	name = "Hemokinesis"
	desc = "Conjure your vampiric powers into your hand, bending the blood of all living beings."
	active_background_icon_state = "tremere_power_on"
	base_background_icon_state = "tremere_power_off"
	button_icon = 'modular_zubbers/icons/mob/actions/tremere_bloodsucker.dmi'
	background_icon = 'modular_zubbers/icons/mob/actions/tremere_bloodsucker.dmi'

	level_current = 1

	power_flags = BP_CONTINUOUS_EFFECT
	check_flags = BP_CANT_USE_IN_TORPOR|BP_CANT_USE_IN_FRENZY
	purchase_flags = TREMERE_CAN_BUY
	cooldown_time = 0 SECONDS
	bloodcost = 0
	constant_bloodcost = 0
	var/our_hand_item
	var/turning_off

/datum/action/cooldown/bloodsucker/hemokinesis/get_power_explanation_extended()
	. = list()
	. += "Manifest blood weapon allows you to create powerful tools out of your own blood."
	. += "Your arsenal of blood weapons expands as you upgrade this ability. All of them apply stacks of Hemocatalysis"
	. += "You can manifest and hold up to 1 weapon at a time."
	. += "All weapons apply Hemokinesis."
	. += "The Dagger flies back into your hand after a succesful throwing hit."
	. += "The Javelin has more reach than the daggers do, absorbing blood as it flies to boost it's damage on hit."
	. += "The Zweihander deals potent damage, it's attacks cleave - striking adjacent targets for half the damage."

/datum/action/cooldown/bloodsucker/hemokinesis/ActivatePower() //Me when I reuse code and pass it off as efficiency
	var/mob/living/carbon/human/caster = owner
	if(!our_hand_item)
		turning_off = FALSE
		var/turf/current_position = get_turf(caster)
		var/obj/item/melee/tremere_hand/given_hand = new(current_position)
		our_hand_item = given_hand
		if(caster.put_in_hands(given_hand))
			to_chat(caster, span_cult_italic("You channel your arcane power into your hand..."))
		else
			to_chat(caster, span_cult_italic("You need a free hand to cast spells!"))
	return TRUE

/datum/action/cooldown/bloodsucker/hemokinesis/DeactivatePower(deactivate_flags)
	if(our_hand_item)
		new /obj/effect/temp_visual/cult/sparks(get_turf(src))
		qdel(our_hand_item)
		to_chat(owner, span_cult_italic("You decide to spare the mortals and conceal your magicks..."))
		turning_off = FALSE
		our_hand_item = null
	return ..()

/datum/action/cooldown/bloodsucker/hemokinesis/process(seconds_per_tick)
	// Checks that we can keep using this.
	. = ..()
	if(!.)
		return
	if(!active)
		return
	if(!our_hand_item)
		DeactivatePower()
		return


/// THE HAND, LORD HAVE MERCY ON MY SOUL THIS WILL BE A TON OF CODE ///

/obj/item/melee/tremere_hand
	name = "\improper hemokinetic grasp"
	desc = "A monstrous aura, spreading like veins from around the hand."
	icon = 'icons/obj/weapons/hand.dmi'
	lefthand_file = 'icons/mob/inhands/items/touchspell_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/touchspell_righthand.dmi'
	icon_state = "disintegrate"
	inhand_icon_state = "disintegrate"
	item_flags = NEEDS_PERMIT | ABSTRACT | DROPDEL
	w_class = WEIGHT_CLASS_HUGE
	throwforce = 0
	throw_range = 0
	throw_speed = 0
	var/datum/action/innate/cult/blood_spell/source
	var/target_one
	var/target_two

/obj/item/melee/tremere_hand/Initialize(mapload, spell)
	gender_reveal(
			outline_color = COLOR_CULT_RED,
			ray_color = null,
			do_float = FALSE,
			do_layer = FALSE,
		)
	. = ..()

/obj/item/melee/tremere_hand/Destroy()
	return ..()

/obj/item/melee/tremere_hand/ranged_interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	get_target(interacting_with, user, modifiers)
	return ITEM_INTERACT_BLOCKING

/obj/item/melee/tremere_hand/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(HAS_TRAIT(interacting_with, TRAIT_COMBAT_MODE_SKIP_INTERACTION))
		return NONE
	return ranged_interact_with_atom(interacting_with, user, modifiers)

/obj/item/melee/tremere_hand/proc/get_target(interacting_with, mob/living/user, modifiers) // This stores our target in target_one or target_two if there is a target_one already
	var/mob/living/ourtarget = user
	if(IS_DEAD_OR_INCAP(ourtarget))
		return
	if(!target_one)
		target_one = interacting_with
		return
	if(!target_two)
		target_two = interacting_with
		pick_spell(ourtarget)
		wipe_targets(ourtarget)

/obj/item/melee/tremere_hand/proc/wipe_targets(user)
	to_chat(user, "Targets wiped!")
	target_one = null
	target_two = null
	return

// Zoo wee mama, so here we go. The way this works is the user clicks on 2 things and a spell comes out, depending
// on what they've clicked. We handle the case where you click on objs/tiles etc which is always blood bolt
// and then we handle the mobs separately since it gets confusing.


/obj/item/melee/tremere_hand/proc/pick_spell(user)
	if(ismob(target_one))
		handle_mob_targets(user)
		return
	if(isturf(target_one) || isobj(target_one))
		blood_bolt(target_one, target_two, user)
		return

/// Helper proc
/obj/item/melee/tremere_hand/proc/handle_mob_targets(user)
	if(target_one == user) // Only spill blood starts with user, it's your setup tool.
		spill_blood(target_two, user)
		return

	if(isturf(target_two) || isobj(target_two))
		fling(target_one, target_two, user) // Throw someone
		return

	if(ismob(target_two))
		if(target_two == user)
			drain_life(target_one, user) // From them to me, so stealing life logically
			return
		if(target_one == target_two)
			boil_blood(target_one, user) // The same person twice, nuke them
			return
		else //Two different people...
			blood_bond(target_one, target_two, user) // ... so we tie them together

// ...existing code...
/obj/item/melee/tremere_hand/attack_self(mob/user, modifiers)
	. = ..()

// It's either this or making 8 unaccessible abilities triggered from an item

/obj/item/melee/tremere_hand/proc/charge_blood(mob/living/user, bloodcost)
	var/datum/antagonist/bloodsucker/bloodsuckerdatum = IS_BLOODSUCKER(user)
	if(!HAS_TRAIT(user, TRAIT_NOBLOOD) && bloodsuckerdatum.GetBloodVolume() < bloodcost)
		return
	if(bloodsuckerdatum.frenzied)
		return
// Not frenzied, has enough blood to actually pay, time to pay it up.
	if(HAS_TRAIT(user, TRAIT_NOBLOOD) && !bloodsuckerdatum)
		user.adjustBruteLoss(bloodcost * 0.1)
	else
		bloodsuckerdatum.AdjustBloodVolume(-bloodcost)
	return

///////////////////
//  BLOOD BOLT  //
/////////////////

/obj/projectile/blood_bolt
	name = "\improper Blood_bolt"
	range = 15
	pass_flags = PASSTABLE | PASSGLASS | PASSGRILLE | PASSCLOSEDTURF | PASSMACHINE | PASSSTRUCTURE | PASSDOORS | PASSMOB

/obj/projectile/blood_bolt/reduce_range()
	..()
	var/turf/T = get_turf(src)
	if(is_type_on_turf(T, /obj/effect/decal/cleanable/blood/tremere))
		new /obj/effect/temp_visual/bubblegum_hands/leftsmack(T)
		for(var/mob/living/L in T)
			to_chat(L, span_userdanger("Claws lunge at you from the puddle of blood!"))
			var/limb_to_hit = L.get_bodypart(L.get_random_valid_zone(even_weights = TRUE))
			L.apply_damage(15, BRUTE, limb_to_hit, L.run_armor_check(limb_to_hit, MELEE, null, null, armour_penetration), wound_bonus = CANT_WOUND)

/obj/item/melee/tremere_hand/proc/blood_bolt(target_one, target_two, user)
	var/obj/projectile/our_projectile
	if(!target_one || !target_two)
		return

	our_projectile = new /obj/projectile/blood_bolt(target_one)
	our_projectile.aim_projectile(target_two, target_one, null)
	our_projectile.firer = user
	our_projectile.fire()
	charge_blood(user, 30)

///////////////////
//  DRAIN LIFE  //
/////////////////
/obj/item/melee/tremere_hand/proc/drain_life(target_one, target_two, user)


/obj/effect/ebeam/blood_drain
	name = "draining beam"

/datum/status_effect/life_drain
	id = "drain_beam"
	tick_interval = 0.2 SECONDS
	duration = 30 SECONDS
	status_type = STATUS_EFFECT_REPLACE
	alert_type = null
	/// Stores the current beam target
	var/mob/living/current_target
	/// Checks the time of the last check
	var/last_check = 0
	/// The delay of when the beam gets checked
	var/check_delay = 10 //Check los as often as possible, max resolution is SSobj tick though
	/// The maximum range of the beam
	var/max_range = 8
	/// Wether the beam is active or not
	var/active = FALSE
	/// The storage for the beam
	var/datum/beam/current_beam = null

/datum/status_effect/life_drain/on_creation(mob/living/new_owner, mob/living/current_target)
	src.current_target = current_target
	start_beam(current_target, new_owner)
	return ..()

/datum/status_effect/life_drain/be_replaced()
	if(active)
		QDEL_NULL(current_beam)
		active = FALSE
	return ..()

/datum/status_effect/life_drain/tick(seconds_between_ticks)
	if(!current_target)
		lose_target()
		return

	if(world.time <= last_check+check_delay)
		return

	last_check = world.time

	if(!los_check(owner, current_target))
		QDEL_NULL(current_beam)//this will give the target lost message
		return

	if(current_target)
		on_beam_tick(current_target)

/**
 * Proc that always is called when we want to end the beam and makes sure things are cleaned up, see beam_died()
 */
/datum/status_effect/life_drain/proc/lose_target()
	if(active)
		QDEL_NULL(current_beam)
		active = FALSE
	if(current_target)
		on_beam_release(current_target)
	current_target = null

/**
 * Proc that is only called when the beam fails due to something, so not when manually ended.
 * manual disconnection = lose_target, so it can silently end
 * automatic disconnection = beam_died, so we can give a warning message first
 */
/datum/status_effect/life_drain/proc/beam_died()
	SIGNAL_HANDLER
	to_chat(owner, span_warning("You lose control of the beam!"))
	lose_target()
	duration = 0

/// Used for starting the beam when a target has been acquired
/datum/status_effect/life_drain/proc/start_beam(atom/target, mob/living/user)

	if(current_target)
		lose_target()
	if(!isliving(target))
		return

	current_target = target
	active = TRUE
	current_beam = user.Beam(current_target, icon_state="cosmic_beam", time = 30 SECONDS, maxdistance = max_range, beam_type = /obj/effect/ebeam/life_drain)
	RegisterSignal(current_beam, COMSIG_QDELETING, PROC_REF(beam_died))

	SSblackbox.record_feedback("tally", "gun_fired", 1, type)

/// What to process when the beam is connected to a target
/datum/status_effect/life_drain/proc/on_beam_tick(mob/living/target, mob/living/user)
	if(target.adjustFireLoss(3, updating_health = FALSE))
		target.updatehealth()
	if(IS_BLOODSUCKER(user))
		if(user.adjustFireLoss(-3, updating_health = FALSE))
			user.updatehealth()


/// What to remove when the beam disconnects from a target
/datum/status_effect/life_drain/proc/on_beam_release(mob/living/target)


/obj/item/melee/tremere_hand/proc/boil_blood(target_one, target_two, user)
/obj/item/melee/tremere_hand/proc/spill_blood(target_one, target_two, user)
/obj/item/melee/tremere_hand/proc/drain_life(target_one, target_two, user)
/obj/item/melee/tremere_hand/proc/blood_bond(target_one, target_two, user)
/obj/item/melee/tremere_hand/proc/fling(target_one, target_two, user)
