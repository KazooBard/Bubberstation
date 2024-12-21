/datum/bloodsucker_upgrade/brujah/defense
	name = "defense"
	level_current = 1
	var/physical_modifier
	purchase_flags = BRUJAH_CAN_BUY

/datum/bloodsucker_upgrade/brujah/defense/on_gain(mob/living/carbon/human/user, physical_modifier)
	physical_modifier = level_current * 0.1
	user.physiology.brute_mod *= physical_modifier
	user.physiology.burn_mod *= physical_modifier
	user.physiology.stamina_mod *= physical_modifier

