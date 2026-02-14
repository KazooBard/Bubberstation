/datum/action/innate/bb
	background_icon = 'modular_zubbers/icons/mob/actions/brother/backgrounds.dmi'
	background_icon_state = "bg_syndie"
	button_icon = 'modular_zubbers/icons/mob/actions/brother/actions_bb.dmi'
	check_flags = AB_CHECK_CONSCIOUS
	var/datum/antagonist/brother/bond
	var/datum/team/brother_team/team


/datum/action/innate/bb/convert
	name = "Blood Bond"
	desc = "Use once on a target to check if they're valid for conversion, use a second time to convert."
	button_icon_state = "convert"
	check_flags = AB_CHECK_CONSCIOUS
	click_action = TRUE
	var/lastchecked
	var/used = 0
	var/power_in_use = FALSE
	ranged_mousepointer = 'icons/effects/mouse_pointers/supplypod_pickturf.dmi'

/datum/action/innate/bb/New(datum/antagonist/brother/target)
	if(!istype(target))
		CRASH("Attempted to create [type] without an associated antag datum!")
	src.bond = target
	src.team = target.get_team()
	return ..()

/datum/action/innate/bb/convert/Trigger(trigger_flags)
	if(!..())
		return FALSE

	if (trigger_flags & TRIGGER_SECONDARY_ACTION)
		unset_ranged_ability(owner)

		return FALSE
	return TRUE

/datum/action/innate/bb/IsAvailable(feedback)
	. = ..()
	if(!.)
		return
	if(length(team.members) == 2)
		if(feedback)
			owner.balloon_alert(owner, "no blood brothers to communicate with!")
		return FALSE


/datum/action/innate/bb/convert/do_ability(mob/living/clicker, atom/clicked_on)
	if (!isliving(clicked_on))
		return TRUE

	var/mob/living/living_target = clicked_on
	var/client/my_client = GET_CLIENT(living_target)

	if (living_target == clicker)
		clicker.balloon_alert(clicker, "you cant be your own brother!")
		return TRUE

	if (isnull(living_target.mind) || !my_client)
		clicker.balloon_alert(clicker,  "[living_target.p_their()] mind is vacant!")
		return

	if (HAS_TRAIT(living_target, TRAIT_UNCONVERTABLE))
		clicker.balloon_alert(clicker, "[living_target] is unconvertable!")
		return

	if (get_dist(clicker, living_target) > 2)
		clicker.balloon_alert(clicker, "too far!")
		return TRUE

	if (living_target == lastchecked)
		if(!(ROLE_BROTHER in my_client.prefs.be_special))
			clicker.balloon_alert(clicker, "not eligible for conversion")
			return TRUE
		else
			weflashedem(clicker, living_target)
			clicker.balloon_alert(clicker, "you convert [living_target.name]")
			Remove()
			// delete ability here
	else
		lastchecked = living_target
		if(!(ROLE_BROTHER in my_client.prefs.be_special))
			clicker.balloon_alert(clicker, "not eligible for conversion")
		else
			clicker.balloon_alert(clicker, "eligible for conversion")

	unset_ranged_ability(owner) // because we sleep
	return TRUE

/datum/action/innate/bb/convert/proc/weflashedem(mob/living/source, mob/living/convert)
	for(var/datum/objective/brother_objective as anything in source.mind.get_all_objectives())
		// If the objective has a target, are we flashing them?
		if(convert == brother_objective.target?.current)
			convert.balloon_alert(source, "that's your target!")
			return

	if (convert.mind.has_antag_datum(/datum/antagonist/brother)) //Double check JUST IN CASE
		convert.balloon_alert(source, "[convert.p_theyre()] loyal to someone else!")
		return

	if (HAS_TRAIT(convert, TRAIT_UNCONVERTABLE))
		convert.balloon_alert(source, "[convert.p_they()] resist!")
		return

	if (!team.add_brother(convert, key_name(source))) // Shouldn't happen given the former, more specific checks but just in case
		convert.balloon_alert(source, "failed!")
		return

	source.log_message("converted [key_name(convert)] to blood brother", LOG_ATTACK)
	convert.log_message("was converted by [key_name(source)] to blood brother", LOG_ATTACK)
	log_game("[key_name(convert)] was made into a blood brother by [key_name(source)]", list(
		"converted" = convert,
		"converted by" = source,
	))
	convert.mind.add_memory( \
		/datum/memory/recruited_by_blood_brother, \
		protagonist = convert, \
		antagonist = owner, \
	)
	convert.balloon_alert(source, "converted")
	convert.visible_message("[convert] seizes onto the ground as [source] smears their blood over their hand!")
