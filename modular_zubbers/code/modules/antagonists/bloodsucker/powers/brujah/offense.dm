/datum/bloodsucker_upgrade/offense
	name = "offense"
	purchase_flags = BRUJAH_CAN_BUY
	var/l_damage
	var/h_damage
	var/effectiveness
	var/sharpness
	var/list/verb = list()
	var/list/attack_sounds = list()


/datum/bloodsucker_upgrade/offense/on_gain(mob/living/carbon/user)
	var/obj/item/bodypart/user_left_hand = user.get_bodypart(BODY_ZONE_L_ARM)
	var/obj/item/bodypart/user_right_hand = user.get_bodypart(BODY_ZONE_R_ARM)
	l_damage = user_left_hand.unarmed_damage_low
	h_damage = user_left_hand.unarmed_damage_high
	effectiveness = user_left_hand.unarmed_effectiveness
	sharpness = user_right_hand.unarmed_sharpness
	verb = list(user_right_hand.unarmed_attack_verbs)
	attack_sounds = list(user_right_hand.unarmed_attack_sound, user_right_hand.unarmed_miss_sound)

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
			RegisterSignal(user, COMSIG_LIVING_UNARMED_ATTACK, PROC_REF(knockback))
		else if(level_current == 3)
			user_left_hand.unarmed_damage_high += 5 //5 hits for non oversized, 4 for oversized
			user_right_hand.unarmed_damage_high += 5
			user_left_hand.unarmed_damage_low = user_right_hand.unarmed_damage_high
			user_right_hand.unarmed_damage_low = user_left_hand.unarmed_damage_high
			user_right_hand.unarmed_effectiveness += 10 //I've chosen consistency over damage here, because unlike other antags, brujah cannot fight using a different damage type
			user_left_hand.unarmed_effectiveness += 10
			var/datum/martial_art/cqc/blocking/martial_art
			if(!locate(martial_art) in user.martial_arts)
				martial_art.teach(user)

/datum/bloodsucker_upgrade/offense/proc/knockback(/mob/living/carbon/user, atom/attack_target, proximity, modifiers)
	SIGNAL_HANDLER

	var/mob/living/carbon/human/ouruser = user
	if(!proximity || !isliving(attack_target))
		return

	if(ouruser.combat_mod)
		if(HAS_TRAIT(ouruser, TRAIT_PACIFISM))
			return
		else
			var/mob/living/our_target = attack_target
			if(!our_target.pulledby && !our_target.pulledby.grab_state >= GRAB_AGGRESSIVE)
				our_target.throw_at(get_edge_target_turf(our_target, dir), range = rand(1, 2), speed = 7, thrower = src, gentle = TRUE, force = 5)
				to_chat(our_target, "[ouruser]'s punches land with inhuman strength!")
				to_chat(user, "Your punch knocks back [our_target]!")

/datum/bloodsucker_upgrade/offense/on_loss(mob/living/carbon/user)
	var/obj/item/bodypart/user_left_hand = user.get_bodypart(BODY_ZONE_L_ARM)
	var/obj/item/bodypart/user_right_hand = user.get_bodypart(BODY_ZONE_R_ARM)

	if(!user_right_hand || !user_left_hand)
		return

	// Restore original values
	user_left_hand.unarmed_damage_high = h_damage
	user_left_hand.unarmed_damage_low = l_damage
	user_left_hand.unarmed_effectiveness = effectiveness
	user_right_hand.unarmed_damage_high = h_damage
	user_right_hand.unarmed_damage_low = l_damage
	user_right_hand.unarmed_effectiveness = effectiveness
	UnregisterSignal(user, COMSIG_LIVING_UNARMED_ATTACK)
	var/datum/martial_art/cqc/blocking/martial_art
	if(locate(martial_art) in user.martial_arts)
		martial_art.unlearn(user)

