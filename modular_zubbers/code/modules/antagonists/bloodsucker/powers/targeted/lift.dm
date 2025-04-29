/datum/action/cooldown/bloodsucker/targeted/lift
	name = "Herculean Might"
	desc = "Rip a machine or structure out from whatever it's attached to, to be used as a weapon or projectile."
	button_icon_state = "power_lunge"
	check_flags = AB_CHECK_CONSCIOUS|AB_CHECK_INCAPACITATED|AB_CHECK_LYING|AB_CHECK_PHASED|AB_CHECK_LYING
	bloodcost = 10
	cooldown_time = 10 SECONDS
	power_activates_immediately = FALSE
	var/stam_penalty_initial = 25
	var/assigned_max_hits = 2
	var/static/list/valid_lift_targets = typecacheof(list(
	/obj/structure/closet,
	/obj/structure/table,
	/obj/structure/chair,
	/obj/structure/flora/rock/style_2,
	/obj/structure/flora/rock/style_3,
	/obj/structure/flora/rock/style_4,
	/obj/structure/dresser,
	/obj/structure/toilet,
	/obj/structure/bookcase,
	/obj/structure/reagent_dispensers,
	/obj/structure/mecha_wreckage,
	/obj/structure/flippedtable,
	/obj/structure/reagent_anvil,
	/obj/structure/reagent_forge,
	/obj/structure/reagent_crafting_bench,
	/obj/structure/weightmachine,
	))

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
	. = ..()
	if(!.)
		return FALSE
	if(istype(target_atom) && (is_type_in_typecache(target_atom, valid_lift_targets)))
		return TRUE
	return FALSE

/datum/action/cooldown/bloodsucker/targeted/lift/FireTargetedPower(atom/target, params)
	. = ..()
	var/mob/living/lifter = owner
	var/obj/structure/our_target = target
	if(get_dist(lifter, target) <=1)
		START_PROCESSING(SSprocessing, src)
		lifter.face_atom(target)
		if(our_target.anchored)
			playsound(target, 'sound/machines/airlock/airlock_alien_prying.ogg', 40, TRUE, -1)
			our_target.structure_try_pickup(lifter, ignore_anchors = TRUE, stam_penalty_initial = src.stam_penalty_initial, assigned_max_hits = src.assigned_max_hits)
			lifter.balloon_alert(lifter, "you tense up, prying it up from the floor!")
		else
			our_target.structure_try_pickup(lifter, ignore_anchors = TRUE, stam_penalty_initial = src.stam_penalty_initial, assigned_max_hits = src.assigned_max_hits)
			lifter.balloon_alert(lifter, "you effortlessly lift it up!")
		var/base_x = lifter.base_pixel_x
		var/base_y = lifter.base_pixel_y
		animate(lifter, pixel_x = base_x, pixel_y = base_y, time = 1, loop = 1)
		for(var/i in 1 to 25)
			var/x_offset = base_x + rand(-3, 3)
			var/y_offset = base_y + rand(-3, 3)
			animate(pixel_x = x_offset, pixel_y = y_offset, time = 1)
			return TRUE
	else
		lifter.balloon_alert(lifter, "You can't reach that far!")
		//animate them shake

/datum/action/cooldown/bloodsucker/targeted/lift/upgraded
	name = "Herculean Might But I made It better And I Have No Good Names Yet Bear WIth Me"
	stam_penalty_initial = 14
	assigned_max_hits = 3
