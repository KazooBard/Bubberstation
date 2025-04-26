#define DEFENSE_ANTI_DELIMB_LEVEL 1
#define DEFENSE_ANTI_SPRAYFLASH_LEVEL 2
#define DEFENSE_ANTI_WOUND_LEVEL 3
#define DEFENSE_BONUS_HP_LEVEL 4

/datum/bloodsucker_upgrade/defense
	name = "defense"
	gain_message = "You have gained defense upgrade 1!"
	purchase_flags = BRUJAH_CAN_BUY
	var/physical_modifier
	var/starting_brute
	var/starting_burn
	var/starting_stamina
	var/bonus_max_hp = 90

/datum/bloodsucker_upgrade/defense/on_gain(mob/living/carbon/human/user)
	user.playsound_local(get_turf(user), 'sound/effects/hallucinations/wail.ogg', 80, FALSE, pressure_affected = FALSE, use_reverb = FALSE)
	physical_modifier = min(1 - (0.05 * level_current)) // 10% dmr per level
	starting_brute = user.physiology.brute_mod
	starting_burn = user.physiology.burn_mod
	user.physiology.brute_mod = physical_modifier * starting_brute
	user.physiology.burn_mod = physical_modifier * starting_burn
	if(level_current >= DEFENSE_ANTI_DELIMB_LEVEL)
		ADD_TRAIT(user, TRAIT_NODISMEMBER, BLOODSUCKER_TRAIT)
	if(level_current >= DEFENSE_ANTI_SPRAYFLASH_LEVEL)
		var/obj/item/organ/eyes/our_eyes = user.get_organ_slot(ORGAN_SLOT_EYES)
		our_eyes.pepperspray_protect = TRUE
		our_eyes.flash_protect = FLASH_PROTECTION_NONE
	if(level_current >= DEFENSE_ANTI_WOUND_LEVEL)
		ADD_TRAIT(user, TRAIT_HARDLY_WOUNDED, BLOODSUCKER_TRAIT)

/datum/bloodsucker_upgrade/defense/on_loss(mob/living/carbon/human/user)
	user.physiology.brute_mod = starting_brute
	user.physiology.burn_mod = starting_burn

#undef DEFENSE_ANTI_DELIMB_LEVEL
#undef DEFENSE_ANTI_SPRAYFLASH_LEVEL
#undef DEFENSE_ANTI_WOUND_LEVEL
#undef DEFENSE_BONUS_HP_LEVEL
