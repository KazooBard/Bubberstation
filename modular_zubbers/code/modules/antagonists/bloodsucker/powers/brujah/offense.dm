/datum/bloodsucker_upgrade/offense
	name = "offense"
	purchase_flags = BRUJAH_CAN_BUY


/datum/bloodsucker_upgrade/offense/on_gain(mob/living/carbon/user)
	var/obj/item/bodypart/user_left_hand = user.get_bodypart(BODY_ZONE_L_ARM)
	var/obj/item/bodypart/user_right_hand = user.get_bodypart(BODY_ZONE_R_ARM)
	if(!user_right_hand || !user_left_hand)
		return
	else
		user_left_hand.unarmed_attack_verbs = list("slash")
		user_left_hand.grappled_attack_verb = "lacerate"
		user_left_hand.unarmed_attack_effect = ATTACK_EFFECT_CLAW
		user_left_hand.unarmed_sharpness = 1
		user_left_hand.unarmed_attack_sound = 'sound/items/weapons/slash.ogg'
		user_left_hand.unarmed_miss_sound = 'sound/items/weapons/slashmiss.ogg'
		user_right_hand.unarmed_attack_verbs = list("slash")
		user_right_hand.grappled_attack_verb = "lacerate"
		user_right_hand.unarmed_attack_effect = ATTACK_EFFECT_CLAW
		user_right_hand.unarmed_sharpness = 1
		user_right_hand.unarmed_attack_sound = 'sound/items/weapons/slash.ogg'
		user_right_hand.unarmed_miss_sound = 'sound/items/weapons/slashmiss.ogg'
		if(level_current == 1)
			user.add_traits(TRAIT_PERFECT_ATTACKER, REF(src))
			user_left_hand.unarmed_damage_high += 5
			user_right_hand.unarmed_damage_high += 5
			user_left_hand.unarmed_damage_low = user_right_hand.unarmed_damage_high
			user_right_hand.unarmed_damage_low = user_left_hand.unarmed_damage_high
			user_right_hand.unarmed_effectiveness += 5
			user_left_hand.unarmed_effectiveness += 5	//12 punches on officer, 9 if aggrograbbed to the floor
		else if(level_current == 2)
			user_left_hand.unarmed_damage_high += 5
			user_right_hand.unarmed_damage_high += 5
			user_left_hand.unarmed_damage_low = user_right_hand.unarmed_damage_high
			user_right_hand.unarmed_damage_low = user_left_hand.unarmed_damage_high
			user_right_hand.unarmed_effectiveness += 10 //8 hits to crit officer, 7 hits to crit aggrograbbed
			user_left_hand.unarmed_effectiveness += 10 //still less damage than the cargo sabre. Oversized hits threshold
		else if(level_current == 3)
			user_left_hand.unarmed_damage_high += 11 //5 hits for non oversized, 4 for oversized
			user_right_hand.unarmed_damage_high += 11
			user_left_hand.unarmed_damage_low = user_right_hand.unarmed_damage_high
			user_right_hand.unarmed_damage_low = user_left_hand.unarmed_damage_high
			user_right_hand.unarmed_effectiveness += 10 //I've chosen consistency over damage here, because unlike other antags, brujah cannot fight using a different damage type
			user_left_hand.unarmed_effectiveness += 10
			var/datum/martial_art/cqc/blocking/martial_art
			if(!locate(martial_art) in user.martial_arts)
				martial_art.teach(user)
