/datum/action/bb
	background_icon = 'modular_zubbers/icons/mob/actions/brother/backgrounds.dmi'
	background_icon_state = "bg_syndie"
	button_icon = 'modular_zubbers/icons/mob/actions/brother/actions_bb.dmi'
	check_flags = AB_CHECK_CONSCIOUS
	var/datum/antagonist/brother/bond
	var/datum/team/brother_team/team

/datum/action/bb/New(datum/antagonist/brother/target)
	if(!istype(target))
		CRASH("Attempted to create [type] without an associated antag datum!")
	src.bond = target
	src.team = target.get_team()
	return ..()

/datum/action/bb/IsAvailable(feedback)
	if(QDELETED(bond) || bond.owner != owner.mind)
		return FALSE
	if(QDELETED(team) || !(owner.mind in team.members))
		return FALSE
	return ..()
