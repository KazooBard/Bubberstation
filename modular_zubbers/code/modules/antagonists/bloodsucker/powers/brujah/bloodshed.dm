/datum/action/cooldown/bloodsucker/bloodshed
	name = "Shed Blood" //haha wordplay amirite?
	desc = "Let loose excess blood in order to forcefully enter rage."
	button_icon_state = "power_fortitude"
	power_flags = BP_CONTINUOUS_EFFECT|BP_AM_COSTLESS_UNCONSCIOUS
	check_flags = BP_CANT_USE_IN_TORPOR|BP_CANT_USE_IN_FRENZY
	purchase_flags = BRUJAH_CAN_BUY
	cooldown_time = 20 SECONDS
	bloodcost = -(my.clan.frenzy_enter_threshold - owner.blood_volume)

/datum/action/cooldown/bloodsucker/bloodshedActivatePower(atom/target)
	if(owner.blood_volume <= my_clan.frenzy_enter_threshold)
	owner.balloon_alert(owner, "Bloodrage used!.")
	to_chat(owner, span_notice("Your blood jettisons through every pore in your body, you feel lighter... and hungrier."))

