/obj/item/clothing/gloves/gasharpoon //BUBBERSTATION EDIT- YOG PORT (I love you yogstation ^_^)
	name = "gasharpoon"
	desc = "A metal gauntlet with a harpoon attached, powered by gasoline and traditionally used by space-whalers."
	///reminder to channge all this -- I changed it :)
	icon = 'icons/obj/weapons/dusters.dmi'
	icon_state = "gasharpoon"
	worn_icon = "modular_zubbers/icons/mob/inhands/weapons/knuckles_righthand.dmi"
	worn_icon_state = "gasharpoon"
	inhand_icon_state = "gasharpoon"
	lefthand_file = 'modular_zubbers/icons/mob/inhands/weapons/knuckles_lefthand.dmi'
	righthand_file = 'modular_zubbers/icons/mob/inhands/weapons/knuckles_righthand.dmi'
	attack_verb_continuous = list("attacks", "pokes", "jabs", "tears", "lacerates", "gores")
	attack_verb_simple = list("attack", "poke", "jab", "tear", "lacerate", "gore")
	force = 10
	throwforce = 10
	throw_range = 7
	strip_delay = 15 SECONDS
	cold_protection = HANDS
	heat_protection = HANDS
	wound_bonus = -10
	bare_wound_bonus = 5
	w_class = WEIGHT_CLASS_NORMAL
	resistance_flags = FIRE_PROOF | ACID_PROOF
	var/click_delay = 1.5
	COOLDOWN_DECLARE(harpoon_cd)
	armor_type = /datum/armor/gasharpoon

/datum/armor/gasharpoon
	melee = 0
	bullet = 0
	laser = 0
	energy = 0
	bomb = 0
	bio = 0
	acid = 100
	fire = 100 //Giant metal fucking harpoon, I can see the OG's vision.

/obj/item/clothing/gloves/gasharpoon/examine(mob/user)
	. = ..()
	. += "Right click to fire the harpoon."

/obj/item/clothing/gloves/gasharpoon/equipped(mob/user, slot)
	. = ..()
	if(slot & ITEM_SLOT_GLOVES)
		RegisterSignal(user, COMSIG_LIVING_EARLY_UNARMED_ATTACK, PROC_REF(power_harpoon))
		RegisterSignal(user, COMSIG_MOB_ATTACK_RANGED_SECONDARY, PROC_REF(on_click))

/obj/item/clothing/gloves/gasharpoon/dropped(mob/user)
	. = ..()
	if(user.get_item_by_slot(ITEM_SLOT_GLOVES)==src)
		UnregisterSignal(user, COMSIG_LIVING_EARLY_UNARMED_ATTACK)
		UnregisterSignal(user, COMSIG_MOB_ATTACK_RANGED_SECONDARY)
	return ..()

/obj/item/clothing/gloves/gasharpoon/proc/on_click(mob/living/user, atom/target, modifiers)
	if(!user.combat_mode || !isturf(user.loc))
		to_chat(user, span_notice("[src] noturfnocombat..."))
		return NONE
	if(HAS_TRAIT(user, TRAIT_PACIFISM))
		to_chat(user, span_notice("[src] is lethally chambered! You don't want to risk harming anyone..."))
		return COMSIG_MOB_CANCEL_CLICKON
	if(!COOLDOWN_FINISHED(src, harpoon_cd))
		balloon_alert(user, "can't do that yet!")
		return COMSIG_MOB_CANCEL_CLICKON
	to_chat(user, span_warning("You fire out a harpoon!"))
	user.changeNext_move(CLICK_CD_RANGE)
	user.newtonian_move(get_dir(target, user))
	var/obj/projectile/wire/harpoon/harpoon_shot = new /obj/projectile/wire/harpoon(get_turf(user))
	harpoon_shot.firer = user
	harpoon_shot.preparePixelProjectile(target, user)
	to_chat(user, span_notice("[src] fired..."))
	INVOKE_ASYNC(harpoon_shot, TYPE_PROC_REF(/obj/projectile, fire))
	playsound(src, 'sound/items/weapons/batonextend.ogg', 50, FALSE)
	COOLDOWN_START(src, harpoon_cd, 2 SECONDS)
	return COMSIG_MOB_CANCEL_CLICKON

/obj/item/clothing/gloves/gasharpoon/proc/power_harpoon(mob/living/user, atom/movable/target)
	if(!user || !user.combat_mode || (!isliving(target) && !isobj(target)) || isitem(target))
		return NONE
	do_attack(user, target, force * 2)
	playsound(loc, 'sound/items/weapons/bladeslice.ogg', 50, 1)
	target.visible_message(span_danger("[user]'s gasharpoon pierces through [target.name]!"))
	return COMPONENT_CANCEL_ATTACK_CHAIN

/obj/item/clothing/gloves/gasharpoon/attack(mob/living/target, mob/living/user)
	power_harpoon(user, target)

/obj/item/clothing/gloves/gasharpoon/proc/do_attack(mob/living/user, atom/target, punch_force)
	if(isliving(target))
		var/mob/living/target_mob = target
		target_mob.apply_damage(punch_force, BRUTE, wound_bonus = 30)
	else if(isobj(target))
		var/obj/target_obj = target
		target_obj.take_damage(punch_force, BRUTE, MELEE, FALSE)
	user.do_attack_animation(target, ATTACK_EFFECT_SLASH)
	user.changeNext_move(CLICK_CD_MELEE * click_delay)
