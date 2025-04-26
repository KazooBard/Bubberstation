/datum/action/cooldown/bloodsucker/targeted/lift
	name = "Predatory Lunge"
	desc = "Spring at your target to grapple them without warning, or tear the dead's heart out. Attacks from concealment or the rear may even knock them down if strong enough."
	button_icon_state = "power_lunge"
	check_flags = AB_CHECK_CONSCIOUS|AB_CHECK_INCAPACITATED|AB_CHECK_LYING|AB_CHECK_PHASED|AB_CHECK_LYING
	purchase_flags = BRUJAH_CAN_BUY
	bloodcost = 10
	cooldown_time = 10 SECONDS
	power_activates_immediately = FALSE
	unset_after_click = FALSE

/datum/action/cooldown/bloodsucker/targeted/lift/get_power_explanation_extended()
	. = list()
	. += "Click any player to start spinning wildly and, after a short delay, dash at them."
	. += "When lunging at someone, you will grab them, immediately starting off at aggressive."
	. += "Riot gear and Monster Hunters are protected and will only be passively grabbed."
	. += "You cannot use the Power if you are already grabbing someone, or are being grabbed."
	. += "If you grab from behind, or while using cloak of darkness, you will knock the target down."

/datum/action/cooldown/bloodsucker/targeted/lift/CheckValidTarget(atom/target_atom)
	. = ..()
	if(!.)
		return FALSE
	return isstructure(target_atom)

/datum/action/cooldown/bloodsucker/targeted/lift/CheckCanTarget(atom/target_atom)
	// DEFAULT CHECKS (Distance)
	. = ..()
	if(!.) // Disable range notice for Brawn.
		return FALSE
	else if(istype(target_atom, /obj/structure/closet))
		return TRUE
	return FALSE

/datum/action/cooldown/bloodsucker/targeted/lift/FireTargetedPower(atom/target, params)
	. = ..()
	var/mob/living/lifter = owner
	var/obj/structure/our_target = target
	if(get_dist(lifter, target) <=1)
		START_PROCESSING(SSprocessing, src)
		lifter.balloon_alert(lifter, "straining!")
		//animate them shake
		var/base_x = lifter.base_pixel_x
		var/base_y = lifter.base_pixel_y
		animate(lifter, pixel_x = base_x, pixel_y = base_y, time = 1, loop = -1)
		for(var/i in 1 to 25)
			var/x_offset = base_x + rand(-3, 3)
			var/y_offset = base_y + rand(-3, 3)
			animate(pixel_x = x_offset, pixel_y = y_offset, time = 1)
		lifter.face_atom(target)
		our_target.structure_try_pickup(owner)
		return TRUE


