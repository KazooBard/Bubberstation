/obj/item/clothing/gloves/dusters
	name = "Knuckledusters"
	desc = "A pair of small, metal weapons designed to be worn around one's knuckles for extra oomf in every punch."
	var/punch_force = 1.5 // Multiplier
	var/animation = ATTACK_EFFECT_SLASH

/obj/item/clothing/gloves/dusters/proc/do_attack(mob/living/user, atom/target, punch_force)
	if(isliving(target))
		var/mob/living/target_mob = target
		target_mob.apply_damage(punch_force, BRUTE, wound_bonus = 30)
	else if(isobj(target))
		var/obj/target_obj = target
		target_obj.take_damage(punch_force, BRUTE, MELEE, FALSE)
	user.do_attack_animation(target, animation)
	target.visible_message(span_danger("[user] hits [target.name] with their [name]!"))
	return COMPONENT_CANCEL_ATTACK_CHAIN
