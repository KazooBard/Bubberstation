/datum/bloodsucker_upgrade/brujah/offense
	name = "offense"
	level_current = 1

/datum/bloodsucker_upgrade/brujah/offense/on_gain(mob/living/carbon/user)
	var/obj/item/bodypart/user_left_hand = user.get_bodypart(BODY_ZONE_L_ARM)
	var/obj/item/bodypart/user_right_hand = user.get_bodypart(BODY_ZONE_R_ARM)
	if(!user_right_hand || !user_left_hand)
		return
	else
		user_left_hand.unarmed_attack_verbs = list("slash")
		user_left_hand.grappled_attack_verb = "lacerate"
		user_left_hand.unarmed_attack_effect = ATTACK_EFFECT_CLAW
		user_left_hand.unarmed_attack_sound = 'sound/items/weapons/slash.ogg'
		user_left_hand.unarmed_miss_sound = 'sound/items/weapons/slashmiss.ogg'
		user_right_hand.unarmed_attack_verbs = list("slash")
		user_right_hand.grappled_attack_verb = "lacerate"
		user_right_hand.unarmed_attack_effect = ATTACK_EFFECT_CLAW
		user_right_hand.unarmed_attack_sound = 'sound/items/weapons/slash.ogg'
		user_right_hand.unarmed_miss_sound = 'sound/items/weapons/slashmiss.ogg'
		if(level_current == 1)
			user_left_hand.unarmed_damage_low = 15
			user_right_hand.unarmed_damage_low = 15
			user_left_hand.unarmed_damage_high = 15
			user_right_hand.unarmed_damage_high = 15
		else if(level_current == 2)
			user_left_hand.unarmed_damage_low = 20
			user_right_hand.unarmed_damage_low = 20
			user_left_hand.unarmed_damage_high = 20
			user_right_hand.unarmed_damage_high = 20
		else if(level_current == 3)
			user_left_hand.unarmed_damage_low = 25
			user_right_hand.unarmed_damage_low = 25
			user_left_hand.unarmed_damage_high = 25
			user_right_hand.unarmed_damage_high = 25

