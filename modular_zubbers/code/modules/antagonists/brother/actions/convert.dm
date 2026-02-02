/datum/action/bb/convert
	name = "Blood Bond"
	desc = "Use once on a target to check if they're valid for conversion, use a second time to convert."
	button_icon_state = "weapons"
	check_flags = AB_CHECK_CONSCIOUS
	click_to_activate = TRUE
	var/lastchecked
	var/used = 0
	var/power_in_use = FALSE

/datum/action/bb/convert/IsAvailable(feedback)
	. = ..()
	if(!.)
		return
	if(length(team.members) < 2)
		return TRUE
	else
		return FALSE

/datum/action/bb/convert/Trigger(trigger_flags)
	. = ..()
	if(!.)
		return

/datum/action/bb/convert/PreActivate(atom/target)
	if(!target)
		return ..()
	// CANCEL RANGED TARGET check
	if(used == 1 || !IsAvailable)
		return FALSE
	used = 0
	return TRUE

/datum/action/bb/convert/set_click_ability(mob/on_who)
	// activate runs before
	if(!PreActivate())
		return
	if(prefire_message)
		to_chat(owner, span_announce("[Who do you want to check?]"))

/datum/action/bb/convert/unset_click_ability(mob/on_who, refund_cooldown)
	. = ..()
	if(active) //todo refactor active into is_action_active()
		DeactivatePower()


/datum/action/bb/convert/DeactivatePower(deactivate_flags)
	. = ..()
	if(!.)
		return
	// sometimes things will call DeactivatePower, but not unset_click_ability, so we have to unset the click interception here.
	if(owner.click_intercept == src) // TODO test if this is no longer needed
		owner.click_intercept = null

/datum/action/bb/convert/InterceptClickOn(mob/living/clicker, params, atom/target)
	. = ..()
	if(!.)
		return FALSE
	var/list/modifiers = params2list(params)
	SEND_SIGNAL(src, COMSIG_FIRE_TARGETED_POWER, target)
	return convert_this_fucker(target, modifiers)


/datum/action/bb/convert/convert_this_fucker(atom/target, params)
	var/valid_target = FALSE
	var/mob/living/user = owner
	var/mob/living/carbon/convertee = target_ref?.resolve()

	if(convertee.stat == DEAD || issilicon(convertee) || isdrone(convertee))
		return

	if(convertee.stat != CONSCIOUS)
		to_chat(source, span_warning("[convertee.p_They()] must be conscious before you can convert [convertee.p_them()]!"))
		return

	if(lastchecked == convertee)
		//alert
		if(valid_target == TRUE)
			weflashedem(owner, convertee)
	else
		lastchecked = convertee




/datum/action/bb/convert/proc/weflashedem(mob/living/source, mob/living/flashed)
#ifdef TESTING
	if (isnull(flashed.mind))
		flashed.mind_initialize()
#else
	if (isnull(flashed.mind) || !GET_CLIENT(flashed))
		flashed.balloon_alert(source, "[flashed.p_their()] mind is vacant!")
		return
#endif

	for(var/datum/objective/brother_objective as anything in source.mind.get_all_objectives())
		// If the objective has a target, are we flashing them?
		if(flashed == brother_objective.target?.current)
			flashed.balloon_alert(source, "that's your target!")
			return

	if (flashed.mind.has_antag_datum(/datum/antagonist/brother))
		flashed.balloon_alert(source, "[flashed.p_theyre()] loyal to someone else!")
		return

	if (HAS_TRAIT(flashed, TRAIT_UNCONVERTABLE))
		flashed.balloon_alert(source, "[flashed.p_they()] resist!")
		return

	if (!team.add_brother(flashed, key_name(source))) // Shouldn't happen given the former, more specific checks but just in case
		flashed.balloon_alert(source, "failed!")
		return

	source.log_message("converted [key_name(flashed)] to blood brother", LOG_ATTACK)
	flashed.log_message("was converted by [key_name(source)] to blood brother", LOG_ATTACK)
	log_game("[key_name(flashed)] was made into a blood brother by [key_name(source)]", list(
		"converted" = flashed,
		"converted by" = source,
	))
	flashed.mind.add_memory( \
		/datum/memory/recruited_by_blood_brother, \
		protagonist = flashed, \
		antagonist = owner.current, \
	)
	flashed.balloon_alert(source, "converted")
