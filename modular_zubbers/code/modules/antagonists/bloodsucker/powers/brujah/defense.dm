/datum/bloodsucker_upgrade/brujah/defense
	name = "defense"
	level_current = 1
	purchase_flags = BRUJAH_CAN_BUY
	gain_message = "You have gained defense upgrade 1!"
	var/physical_modifier

/datum/bloodsucker_upgrade/brujah/defense/on_gain(mob/living/carbon/human/user)
	..()
	physical_modifier = level_current * 0.1
	user.physiology.brute_mod *= physical_modifier
	user.physiology.burn_mod *= physical_modifier
	user.physiology.stamina_mod *= physical_modifier

