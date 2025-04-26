
#define BRUJAH_STARTING_BLOOD 300

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
	purchasable_typepath = /datum/bloodsucker_upgrade

/datum/bloodsucker_clan/brujah/on_enter_frenzy(datum/antagonist/bloodsucker/source)
	ADD_TRAIT(source, TRAIT_STUNIMMUNE, FRENZY_TRAIT)

/datum/bloodsucker_clan/brujah/on_exit_frenzy(datum/antagonist/bloodsucker/source)
	REMOVE_TRAIT(source, TRAIT_STUNIMMUNE, FRENZY_TRAIT)

/datum/bloodsucker_clan/brujah/New(datum/antagonist/bloodsucker/owner_datum)
	. = ..()
	var/mob/user = owner_datum.owner.current
	ADD_TRAIT(user, TRAIT_TOSS_GUN_HARD, BLOODSUCKER_TRAIT)
	owner_datum.max_blood_volume = BRUJAH_STARTING_BLOOD
	owner_datum.SetBloodVolume(BRUJAH_STARTING_BLOOD)
	user.playsound_local(get_turf(user), 'sound/effects/hallucinations/wail.ogg', 80, FALSE, pressure_affected = FALSE, use_reverb = FALSE)
	to_chat(user, span_cult("You hunger..."))
	owner_datum.remove_nondefault_powers(return_levels = TRUE)
	for(var/datum/bloodsucker_upgrade/upgrade as anything in owner_datum.all_bloodsucker_upgrades)
		if((initial(upgrade.purchase_flags) & buy_power_flags) && initial(upgrade.level_current) == 1)
			owner_datum.BuyUpgrade(upgrade)
	owner_datum.RemovePowerByPath(/datum/action/cooldown/bloodsucker/masquerade)
	owner_datum.RemovePowerByPath(/datum/action/cooldown/bloodsucker/veil)
	owner_datum.RemovePowerByPath(/datum/action/cooldown/bloodsucker/feed)
	owner_datum.BuyPowers(/datum/action/cooldown/bloodsucker/feed/gorge, /datum/action/cooldown/bloodsucker/frenzy)
	user.balloon_alert(bloodsuckerdatum.owner.current, "new recipes learned!")
	var/mob/living/carbon/carbon_user = user
	if(iscarbon(carbon_user))
		user.mind.teach_crafting_recipe(/datum/crafting_recipe/brutalthrone)

/datum/bloodsucker_clan/brujah/max_ghouls()
	return 0

/datum/bloodsucker_clan/brujah/free_ghoul_slots()
	return 0

/datum/bloodsucker_clan/brujah/Destroy(force)
	REMOVE_TRAIT(bloodsuckerdatum.owner.current, TRAIT_TOSS_GUN_HARD, BLOODSUCKER_TRAIT)
	for(var/datum/action/cooldown/bloodsucker/power in bloodsuckerdatum.powers)
		if(power.purchase_flags & buy_power_flags)
			bloodsuckerdatum.RemovePower(power)
	for(var/datum/bloodsucker_upgrade/upgrade in bloodsuckerdatum.upgrades)
		if(upgrade.purchase_flags & buy_power_flags)
			bloodsuckerdatum.RemoveUpgrade(upgrade)
	return ..()

/datum/bloodsucker_clan/brujah/list_available_choices(
		already_known = bloodsuckerdatum.upgrades,
		upgrades_list = bloodsuckerdatum.all_bloodsucker_upgrades
	)
	var/list/options = list()
	for(var/datum/bloodsucker_upgrade/upgrade as anything in upgrades_list)
		if(initial(upgrade.purchase_flags) & buy_power_flags)
			var/datum/bloodsucker_upgrade/found_upgrade = locate(upgrade) in already_known
			if(found_upgrade)
				options["[upgrade.name]: [upgrade.level_current]"] = upgrade
			else
				options[initial(upgrade.name)] = upgrade
	return options

// fuckery: we are modifying the default args
/datum/bloodsucker_clan/brujah/is_valid_choice(
		datum/action/cooldown/bloodsucker/power,
		cost_rank,
		blood_cos,
		requires_coffin,
		check_list = bloodsuckerdatum.upgrades
	)
	. = ..()


/datum/bloodsucker_clan/brujah/purchase_choice(datum/antagonist/bloodsucker/source, datum/bloodsucker_upgrade/upgrade)
	var/datum/bloodsucker_upgrade/already_known = locate(upgrade) in bloodsuckerdatum.upgrades
	if(!already_known)
		already_known = bloodsuckerdatum.BuyUpgrade(upgrade)
	return already_known.upgrade(bloodsuckerdatum.owner.current, !already_known)

/datum/bloodsucker_clan/brujah/level_up_powers(datum/antagonist/bloodsucker/source)
	return

#undef BRUJAH_STARTING_BLOOD
