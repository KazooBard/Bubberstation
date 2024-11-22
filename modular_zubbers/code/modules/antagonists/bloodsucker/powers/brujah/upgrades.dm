/datum/bloodsucker_upgrade
	var/name = "coder did a coder, call a coder today!"
	var/level_current = 0

/datum/bloodsucker_upgrade/proc/on_gain(mob/user)
	to_chat(user, span_cult("buh"))

/datum/bloodsucker_upgrade/proc/upgrade(mob/user)

/datum/bloodsucker_upgrade/brujah/coding/on_gain(mob/user)
	to_chat(user, span_cult("You feel your [name] grow in power..."))

/datum/bloodsucker_upgrade/brujah/coding
	name = "Coding" // coding skill ;)

/datum/bloodsucker_upgrade/brujah/offense
	name = "offense"

/datum/bloodsucker_upgrade/brujah/offense/on_gain(mob/user)

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
