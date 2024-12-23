/datum/action/cooldown/bloodsucker/bloodshed
	name = "Shed Blood" //haha wordplay amirite?
	desc = "Let loose excess blood in order to forcefully enter rage."
	button_icon_state = "power_fortitude"
	power_flags = BP_CONTINUOUS_EFFECT|BP_AM_STATIC_COOLDOWN
	purchase_flags = BRUJAH_CAN_BUY
	cooldown_time = 20 SECONDS
	bloodcost = 100
	power_activates_immediately = TRUE
	level_current = -1

// TODO add a shared proc that's used for checking valid blood_volumes for vamp actions
/datum/action/cooldown/bloodsucker/bloodshed/ActivatePower(mob/living/carbon/user)
	if(bloodsuckerdatum_power.GetBloodVolume() <= bloodsuckerdatum_power?.my_clan.frenzy_threshold_enter)
		return
	user.apply_status_effect(/datum/status_effect/frenzy)
	user.balloon_alert(owner, "Bloodrage used!.")
	to_chat(user, span_notice("Your blood jettisons through every pore in your body, you feel lighter... and hungrier."))
	pay_cost()
