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
	button_icon_state = "weapons"
	check_flags = AB_CHECK_CONSCIOUS
	var/lastchecked
	var/used = 0
	var/power_in_use = FALSE

/datum/action/innate/bb/New(datum/antagonist/brother/target)
	if(!istype(target))
		CRASH("Attempted to create [type] without an associated antag datum!")
	src.bond = target
	src.team = target.get_team()
	return ..()

/datum/action/innate/bb/IsAvailable(feedback)
	if(QDELETED(bond) || bond.owner != owner.mind)
		return FALSE
	if(QDELETED(team) || !(owner.mind in team.members))
		return FALSE
	return ..()


/datum/action/innate/bb/convert/do_ability(mob/living/clicker, atom/clicked_on)
	if (!isliving(clicked_on))
		return TRUE


	var/mob/living/living_target = clicked_on

	if (living_target == clicker)
		clicker.balloon_alert("you can't be your own brother!")
		return TRUE
	if (isnull(living_target.mind) || !GET_CLIENT(living_target))
		living_target.balloon_alert(living_target, "[living_target.p_their()] mind is vacant!")
		return

	if (get_dist(clicker, living_target) > 2)
		clicker.balloon_alert("too far!")
		return TRUE

	if (living_target == lastchecked)
		weflashedem(living_target)
		clicker.balloon_alert("you convert em")
	else
		lastchecked = living_target
		clicker.balloon_alert("you check them")
	unset_ranged_ability(owner) // because we sleep

	weflashedem(living_target)
	return TRUE

/datum/action/innate/bb/convert/proc/weflashedem(mob/living/source, mob/living/convert)
	for(var/datum/objective/brother_objective as anything in source.mind.get_all_objectives())
		// If the objective has a target, are we flashing them?
		if(convert == brother_objective.target?.current)
			convert.balloon_alert(source, "that's your target!")
			return

	if (convert.mind.has_antag_datum(/datum/antagonist/brother))
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

