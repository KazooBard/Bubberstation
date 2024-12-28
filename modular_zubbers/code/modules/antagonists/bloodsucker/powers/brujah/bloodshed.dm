/datum/action/cooldown/bloodsucker/frenzy
	name = "Frenzy"
	desc = "Tap into your primal side to enter frenzy!"
	button_icon_state = "power_bleed"
	power_flags = BP_AM_STATIC_COOLDOWN
	purchase_flags = BRUJAH_CAN_BUY
	cooldown_time = 20 SECONDS
	bloodcost = 100
	power_activates_immediately = TRUE
	level_current = -1

// TODO add a shared proc that's used for checking valid blood_volumes for vamp actions
/datum/action/cooldown/bloodsucker/frenzy/ActivatePower(mob/living/carbon/user)
	user.apply_status_effect(/datum/status_effect/frenzy)
