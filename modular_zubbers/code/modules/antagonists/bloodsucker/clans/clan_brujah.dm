/datum/bloodsucker_clan/brujah
	name = CLAN_BRUJAH
	description = "Clan Brujah has long since fallen into disrepair, what remains are rebels and thugs for the most part - all tied by violence and fierce physique. \n\
		They are unable to have ghouls due to their solitary nature, but are themselves forces to be reckoned with."
	join_icon_state = "brujah"
	join_description = "Ghoulless and spelless, you can choose to upgrade Mobility, Defense, Offense and Sanguinity to gain\
		passive boosts."
	blood_drink_type = BLOODSUCKER_DRINK_SLOPPILY
	buy_power_flags = CAN_BUY_OWNED|BRUJAH_CAN_BUY
	blood_volume_per_level = BRUJAH_BLOOD_VOLUME_PER_LEVEL
	regeneration_modifier_per_level = 0.1
	frenzy_enter_threshold = 100
	frenzy_exit_threshold = 200


/datum/bloodsucker_clan/brujah/on_enter_frenzy(datum/antagonist/bloodsucker/source)
	ADD_TRAIT(bloodsuckerdatum.owner.current, TRAIT_STUNIMMUNE, FRENZY_TRAIT)
	bloodsucker.max_blood_volume = 600

/datum/bloodsucker_clan/brujah/on_exit_frenzy(datum/antagonist/bloodsucker/source)
	REMOVE_TRAIT(bloodsuckerdatum.owner.current, TRAIT_STUNIMMUNE, FRENZY_TRAIT)

/datum/bloodsucker_clan/brujah/New(datum/antagonist/bloodsucker/owner_datum)
	. = ..()
	ADD_TRAIT(bloodsuckerdatum.owner.current, TRAIT_TOSS_GUN_HARD, BLOODSUCKER_TRAIT)
	bloodsucker.max_blood_volume = 300
	bloodsuckerdatum.owner.current.playsound_local(get_turf(bloodsuckerdatum.owner.current), 'sound/effects/hallucinations/wail.ogg', 80, FALSE, pressure_affected = FALSE, use_reverb = FALSE)
	to_chat(bloodsuckerdatum.owner.current, span_cult("You hunger..."))
	bloodsuckerdatum.remove_nondefault_powers(return_levels = TRUE)
	for(var/datum/action/cooldown/bloodsucker/upgrade as anything in bloodsuckerdatum.all_bloodsucker_upgrades)
		if((initial(upgrade.purchase_flags) & buy_power_flags) && initial(power.level_current) == 1)
			bloodsuckerdatum.BuyUpgrade(upgrade)
	if(istype(power, /datum/action/cooldown/bloodsucker/masquerade) || istype(power, /datum/action/cooldown/bloodsucker/veil))
		bloodsuckerdatum.RemovePower(power)
	bloodsuckerdatum.AddPower(/datum/action/cooldown/bloodsucker/bloodshed	)

/datum/bloodsucker_clan/brujah/max_ghouls()
	return 0

/datum/bloodsucker_clan/brujah/free_ghoul_slots()
	return 0

/datum/bloodsucker_clan/brujah/Destroy(force)
	UnregisterSignal(SSdcs, COMSIG_BLOODSUCKER_BROKE_MASQUERADE)
	REMOVE_TRAIT(bloodsuckerdatum.owner.current, TRAIT_TOSS_GUN_HARD, BLOODSUCKER_TRAIT)
	for(var/datum/action/cooldown/bloodsucker/power in bloodsuckerdatum.powers)
		if(power.purchase_flags & buy_power_flags)
			bloodsuckerdatum.RemovePower(power)
	return ..()

/datum/bloodsucker_clan/brujah/list_available_upgrades(already_known, upgrades_list)
	var/list/options = list()
	for(var/datum/bloodsucker_upgrade/upgrade as anything in upgrades_list)
		if(initial(upgrade.purchase_flags) & buy_power_flags && !(locate(upgrade) in already_known))
			options[initial(upgrade.name)] = upgrade
	return options

/datum/bloodsucker_clan/brujah/is_valid_choice(power, cost_rank, blood_cost, requires_coffin)
	if(!.)
		return FALSE
	return istype(power, /datum/bloodsucker_upgrade)

/datum/bloodsucker_clan/brujah/purchase_choice(datum/antagonist/bloodsucker/source, datum/bloodsucker_upgrade/upgrade)
	upgrade.upgrade()

/datum/bloodsucker_clan/brujah/level_up_powers(datum/antagonist/bloodsucker/source)
	return

/datum/bloodsucker_clan/brujah/level_message(power_name)
	var/mob/living/carbon/human/human_user = bloodsuckerdatum.owner.current
	human_user.balloon_alert(human_user, "upgraded [power_name]!")
	to_chat(human_user, span_notice("You have upgraded [power_name]!"))

// redefine the default args
/datum/bloodsucker_clan/brujah/list_available_powers(already_known, powers_list)
	return bloodsuckerdatum.upgrades

/datum/bloodsucker_clan/brujah/purchase_choice(datum/antagonist/bloodsucker/source, /datum/bloodsucker_upgrade/upgrade)
	return purchased_power.upgrade_power()
