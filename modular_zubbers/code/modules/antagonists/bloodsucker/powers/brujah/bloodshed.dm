/datum/action/cooldown/bloodsucker/bloodshed
	name = "Shed Blood" //haha wordplay amirite?
	desc = "Let loose excess blood in order to forcefully enter rage."
	button_icon_state = "power_fortitude"
	power_flags = BP_CONTINUOUS_EFFECT|BP_AM_COSTLESS_UNCONSCIOUS
	check_flags = BP_CANT_USE_IN_TORPOR|BP_CANT_USE_IN_FRENZY
	purchase_flags = BRUJAH_CAN_BUY
	cooldown_time = 20 SECONDS
	bloodcost = 0

/datum/action/cooldown/bloodsucker/bloodshedActivatePower(atom/target)
	if(owner.blood_volume <= owner.my_clan.frenzy_enter_threshold)
		owner.balloon_alert(owner, "Losing more blood would kill you!")
		!return
	else
		to_chat(owner, span_notice("Your blood sprays through every pore in your body in a crimson mist, you feel lighter... and hungrier."))
		owner.blood_volume = owner.my_clan.frenzy_enter_threshold
		return TRUE

