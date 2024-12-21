/datum/bloodsucker_upgrade
	var/name = "coder did a coder, call a coder today!"
	var/desc = "You feel compelled to tell a coder something went wrong..."
	var/level_current = 0
	var/purchase_flags = NONE
	var/gain_message = "You feel compelled to tell a coder something went wrong..."
	var/datum/weakref/bloodsucker_datum

/datum/bloodsucker_upgrade/proc/gain(mob/owner)
	SHOULD_NOT_OVERRIDE(TRUE)
	var/datum/antagonist/bloodsucker/vamp = IS_BLOODSUCKER(owner)
	if(!vamp)
		qdel(src)
		return FALSE
	bloodsucker_datum = WEAKREF(vamp)
	to_chat(owner, span_cult(gain_message))
	return TRUE

/datum/bloodsucker_upgrade/proc/loss(mob/owner)
	on_loss(owner)
	return TRUE

/datum/bloodsucker_upgrade/Destroy(force = FALSE)
	var/datum/antagonist/bloodsucker/vamp = bloodsucker_datum?.resolve()
	if(!vamp)
		return ..()
	vamp.RemoveUpgrade(src)
	. = ..()

/datum/bloodsucker_upgrade/proc/upgrade(mob/owner)
	SHOULD_NOT_OVERRIDE(TRUE)
	if(level_current == -1) // -1 means it doesn't rank up ever
		return FALSE
	level_current++
	to_chat(owner, span_cult("Upgraded [name]"))
	on_upgrade()
	return TRUE

/datum/bloodsucker_upgrade/proc/get_power_explanation()
	return desc

/datum/bloodsucker_upgrade/proc/on_gain(mob/owner)

/datum/bloodsucker_upgrade/proc/on_loss(mob/owner)

/datum/bloodsucker_upgrade/proc/on_upgrade()

/datum/bloodsucker_upgrade/brujah
	purchase_flags = BRUJAH_CAN_BUY
