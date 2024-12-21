/datum/action/cooldown/bloodsucker/bloodshed
	name = "Shed Blood" //haha wordplay amirite?
	desc = "Let loose excess blood in order to forcefully enter rage."
	button_icon_state = "power_fortitude"
	power_flags = BP_AM_STATIC_COOLDOWN
	check_flags = BP_CANT_USE_IN_TORPOR|BP_CANT_USE_IN_FRENZY
	purchase_flags = BRUJAH_CAN_BUY
	cooldown_time = 20 SECONDS
	bloodcost = 100
	power_activates_immediately = TRUE

// TODO add a shared proc that's used for checking valid blood_volumes for vamp actions
/datum/action/cooldown/bloodsucker/bloodshed/ActivatePower(atom/target)
	if(bloodsuckerdatum_power.GetBloodVolume() <= bloodsuckerdatum_power?.my_clan.frenzy_threshold_enter)
		return
	owner.balloon_alert(owner, "Bloodrage used!.")
	to_chat(owner, span_notice("Your blood jettisons through every pore in your body, you feel lighter... and hungrier."))

