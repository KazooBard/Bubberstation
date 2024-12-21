/datum/bloodsucker_upgrade
	var/name = "coder did a coder, call a coder today!"
	var/level_current = 0
	var/purchase_flags = NONE
	var/datum/antagonist/bloodsucker/bloodsuckerdatum_upgrade

/datum/bloodsucker_upgrade/brujah
	purchase_flags = BRUJAH_CAN_BUY


/datum/bloodsucker_upgrade/proc/upgrade_upgrade()
	SHOULD_CALL_PARENT(TRUE)
	if(level_current == -1) // -1 means it doesn't rank up ever
		return FALSE
	level_current++
	on_upgrade_upgrade()
	return TRUE

/datum/bloodsucker_upgrade/proc/on_upgrade_upgrade()
	SHOULD_CALL_PARENT(TRUE)
	return TRUE

/datum/bloodsucker_upgrade/proc/on_gain(mob/owner)
	to_chat(owner, span_cult("something broke, invalid upgrade given"))

/datum/bloodsucker_upgrade/proc/upgrade(mob/owner)
	level_current += 1

/datum/bloodsucker_upgrade/proc/on_loss(mob/owner)

/datum/bloodsucker_upgrade/brujah/coding/on_gain(mob/user)
	to_chat(user, span_cult("You feel your [name] grow in power..."))

/datum/bloodsucker_upgrade/brujah/coding
	name = "Coding" // coding skill ;)P

/datum/bloodsucker_upgrade/brujah/offense
	name = "offense"

/datum/bloodsucker_upgrade/brujah/defense
	name = "defense"

/datum/bloodsucker_upgrade/brujah/defense/on_gain(mob/user)

/datum/bloodsucker_upgrade/brujah/mobility
	name = "mobility"

/datum/bloodsucker_upgrade/brujah/mobility/on_gain(mob/user)

/datum/bloodsucker_upgrade/brujah/hunting
	name = "hunting"

/datum/bloodsucker_upgrade/brujah/huntinge/on_gain(mob/user)

/datum/bloodsucker_upgrade/brujah/rage
	name = "rage"
