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
	frenzy_threshold_enter = 100
	frenzy_threshold_exit = 200

/datum/bloodsucker_clan/brujah/on_enter_frenzy(datum/antagonist/bloodsucker/source)
	ADD_TRAIT(source, TRAIT_STUNIMMUNE, FRENZY_TRAIT)

/datum/bloodsucker_clan/brujah/on_exit_frenzy(datum/antagonist/bloodsucker/source)
	REMOVE_TRAIT(source, TRAIT_STUNIMMUNE, FRENZY_TRAIT)

/datum/bloodsucker_clan/brujah/New(datum/antagonist/bloodsucker/owner_datum)
	. = ..()
	ADD_TRAIT(bloodsuckerdatum.owner.current, TRAIT_TOSS_GUN_HARD, BLOODSUCKER_TRAIT)
	owner_datum.max_blood_volume = 300
	// owner_datum.owner.blood_volume = 300
	owner_datum.owner.current.playsound_local(get_turf(owner_datum), 'sound/effects/hallucinations/wail.ogg', 80, FALSE, pressure_affected = FALSE, use_reverb = FALSE)
	to_chat(owner_datum, span_cult("You hunger..."))
	owner_datum.remove_nondefault_powers(return_levels = TRUE)
	for(var/datum/bloodsucker_upgrade/upgrade as anything in owner_datum.all_bloodsucker_upgrades)
		if((initial(upgrade.purchase_flags) & buy_power_flags) && initial(upgrade.level_current) == 1)
			owner_datum.BuyUpgrade(upgrade)
	owner_datum.BuyPower(/datum/action/cooldown/bloodsucker/feed/gorge)
	bloodsuckerdatum.BuyPower(/datum/action/cooldown/bloodsucker/bloodshed)
	owner_datum.RemovePowerByPath(/datum/action/cooldown/bloodsucker/masquerade)
	owner_datum.RemovePowerByPath(/datum/action/cooldown/bloodsucker/veil)
	owner_datum.RemovePowerByPath(/datum/action/cooldown/bloodsucker/feed)
	owner_datum.BuyUpgrades(/datum/bloodsucker_upgrade/brujah/defense, /datum/bloodsucker_upgrade/brujah/offense, /datum/bloodsucker_upgrade/brujah/mobility, /datum/bloodsucker_upgrade/brujah/hunting)

/datum/bloodsucker_clan/brujah/max_ghouls()
	return 0

/datum/bloodsucker_clan/brujah/free_ghoul_slots()
	return 0

/datum/bloodsucker_clan/brujah/Destroy(force)
	REMOVE_TRAIT(bloodsuckerdatum.owner.current, TRAIT_TOSS_GUN_HARD, BLOODSUCKER_TRAIT)
	for(var/datum/action/cooldown/bloodsucker/power in bloodsuckerdatum.powers)
		if(power.purchase_flags & buy_power_flags)
			bloodsuckerdatum.RemovePower(power)
	return ..()

/datum/bloodsucker_clan/brujah/list_available_powers(already_known, upgrades_list)
	var/list/options = list()
	for(var/datum/bloodsucker_upgrade/upgrade as anything in upgrades_list)
		if(initial(upgrade.purchase_flags) & buy_power_flags && !(locate(upgrade) in already_known))
			options[initial(upgrade.name)] = upgrade
	return options

/datum/bloodsucker_clan/brujah/is_valid_choice(power, cost_rank, blood_cost, requires_coffin)
	if(!.)
		return FALSE
	return istype(power, /datum/bloodsucker_upgrade)

/datum/bloodsucker_clan/brujah/purchase_choice_upgrade(datum/antagonist/bloodsucker/source, datum/bloodsucker_upgrade/upgrade)
	return upgrade.upgrade()

/datum/bloodsucker_clan/brujah/level_up_powers(datum/antagonist/bloodsucker/source)
	return

/datum/bloodsucker_clan/brujah/level_message(power_name)
	var/mob/living/carbon/human/human_user = bloodsuckerdatum.owner.current
	human_user.balloon_alert(human_user, "upgraded [power_name]!")
	to_chat(human_user, span_notice("You have upgraded [power_name]!"))
