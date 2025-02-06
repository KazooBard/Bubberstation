////////////////// Wire Gun Item //////////////////
/obj/item/gun/magic/wire
	name = "grappling wire"
	desc = "A combat-ready cable usable for closing the distance, bringing you to walls and heavy targets you hit or bringing lighter ones to you."
	ammo_type = /obj/item/ammo_casing/magic/wire
	icon_state = "hook"
	lefthand_file = 'icons/mob/inhands/weapons/melee_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/melee_righthand.dmi'
	fire_sound = 'sound/items/weapons/batonextend.ogg'
	max_charges = 3
	item_flags = NEEDS_PERMIT | DROPDEL | NOBLUDGEON
	weapon_weight = WEAPON_MEDIUM
	force = 0
	can_charge = FALSE

/obj/item/gun/magic/wire/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, HAND_REPLACEMENT_TRAIT, NOBLUDGEON)
	if(ismob(loc))
		loc.visible_message(span_warning("A long cable comes out from [loc.name]'s arm!"), span_warning("You extend the buster's wire from your arm."))


/obj/item/gun/magic/wire/process_chamber()
	. = ..()
	if(!charges)
		qdel(src)


/obj/item/ammo_casing/magic/wire
	name = "hook"
	desc = "A hook."
	projectile_type = /obj/projectile/wire
	caliber = CALIBER_HOOK


/obj/projectile/wire
	name = "hook"
	pass_flags = PASSTABLE
	damage = 0
	armour_penetration = 100
	damage_type = BRUTE
	range = 8
	hitsound = 'sound/effects/splat.ogg'
	knockdown = 0
	var/wire_icon_state = "chain"
	var/wire
	var/effect

/obj/projectile/wire/fire(setAngle)
	if(firer)
		wire = firer.Beam(src, icon_state = wire_icon_state, time = INFINITY, maxdistance = INFINITY)
	..()

/// Helper proc exclusively used for pulling the buster arm USER towards something anchored
/obj/projectile/wire/proc/zip(mob/living/user, turf/open/target)
	to_chat(user, span_warning("You pull yourself towards [target]."))
	new /obj/effect/temp_visual/mook_dust(drop_location())
	RegisterSignal(user, COMSIG_MOVABLE_IMPACT, PROC_REF(strike_target))
	user.throw_at(target = target, range = 9, speed = 1, spin = FALSE, gentle = TRUE, quickstart = TRUE)

/obj/projectile/wire/proc/strike_target(mob/living/source, mob/living/victim, datum/thrownthing/throwingdatum)
	SIGNAL_HANDLER

	if(!istype(victim))
		return

	victim.apply_damage(30)
	playsound(victim, 'sound/effects/hit_kick.ogg', 50)
	var/turf/target_turf = get_ranged_target_turf(victim, source.dir, 3)
	if(isnull(target_turf))
		return
	victim.throw_at(target = target_turf, speed = 1, spin = TRUE, range = 3)

/obj/projectile/wire/on_hit(atom/target, blocked = 0, pierce_hit)
	. = ..()
	var/mob/living/L = target
	var/mob/living/carbon/human/H = firer
	if(!L)
		return
	L.apply_status_effect(effect)
	if(isobj(target)) // If it's an object
		var/obj/item/I = target
		if(!I.anchored) // Give it to us if it's not anchored
			I.throw_at(get_step_towards(I,H), 8, 2)
			H.visible_message(span_danger("[I] is pulled by [H]'s wiresnatch!"))
			if(istype(I, /obj/item/clothing/head))
				H.equip_to_slot_if_possible(I, ITEM_SLOT_HEAD)
				H.visible_message(span_danger("[H] pulls [I] onto [H.p_their()] head!"))
			else
				H.put_in_hands(I)
			return
		zip(H, I)
	if(isliving(target)) // If it's somebody
		var/turf/T = get_step(get_turf(H), H.dir)
		var/turf/Q = get_turf(H)
		var/obj/item/bodypart/limb_to_hit = L.get_bodypart(H.zone_selected)
		L.say("OOF OUCH MY BONES")
		var/armor = L.run_armor_check(limb_to_hit, MELEE, armour_penetration = 35)
		if(!L.anchored) // Only pull them if they're unanchored
			if(istype(H))
				L.visible_message(span_danger("[L] is pulled by [H]'s wiresnatch!"),span_userdanger("A wiresnatch pierces you and pulls you towards [H]!"))
				L.Immobilize(1.0 SECONDS)
				if(T.density) // If we happen to be facing a wall after the wire snatches them
					to_chat(H, span_warning("[H] catches [L] and throws [L.p_them()] against [T]!"))
					to_chat(L, span_userdanger("[H] crushes you against [T]!"))
					playsound(L,'sound/effects/pop_expl.ogg', 130, 1)
					L.apply_damage(15, BRUTE, limb_to_hit, armor, wound_bonus=CANT_WOUND)
					L.forceMove(Q)
					L.say("OOF OUCH MY BONES")
					return
				// If we happen to be facing a dense object after the wire snatches them, like a table or window
				for(var/obj/D in T.contents)
					if(D.density == TRUE)
						D.take_damage(50)
						L.apply_damage(15, BRUTE, limb_to_hit, armor, wound_bonus=CANT_WOUND)
						L.forceMove(Q)
						to_chat(H, span_warning("[H] catches [L] throws [L.p_them()] against [D]!"))
						playsound(L,'sound/effects/pop_expl.ogg', 20, 1)
						return
				L.forceMove(T)
	if(iswallturf(target)) // If we hit a wall, pull us to it
		var/turf/W = target
		zip(H, W)

/obj/projectile/wire/Destroy()
	qdel(wire)
	return ..()
