/obj/item/inhand_structure
	name = "bugged structure"
	desc = "Yell at coderbrush."
	icon = null
	icon_state = ""
	w_class = WEIGHT_CLASS_BULKY
	force = 50
	throwforce = 35
	item_flags = SLOWS_WHILE_IN_HAND
	slowdown = 1.2
	var/obj/structure/held_structure
	var/release_direction
	var/hits = 0
	var/beingthrown = FALSE


/obj/item/inhand_structure/Initialize(mapload, obj/structure/M, worn_state, head_icon, lh_icon, rh_icon, worn_slot_flags = NONE)
	AddComponent(/datum/component/two_handed, require_twohands=TRUE)
	if(lh_icon)
		lefthand_file = lh_icon
	if(rh_icon)
		righthand_file = rh_icon
	deposit(M)
	. = ..()

/obj/item/inhand_structure/attack(mob/living/target, mob/living/user, params)
	.=..()
	if(HAS_TRAIT(user, TRAIT_PACIFISM))
		to_chat(user, span_warning("You don't want to harm other living beings!"))
		return
	hits += 1
	playsound(loc, 'sound/effects/grillehit.ogg', 50, TRUE)
	var/atom/throw_target = get_edge_target_turf(target, get_dir(user, get_step_away(target, user)))
	target.throw_at(throw_target, 5, 2)
	user.adjustStaminaLoss(25)
	if(hits>=3)
		if(istype(src, /obj/structure/reagent_dispensers))
			var/obj/structure/reagent_dispensers/tank = src
			tank.rig_boom()
		else
			visible_message(span_warning("[src] breaks against [target]!"))
			release(TRUE)
	log_combat(user, target, "structure slammed", src)
	user.changeNext_move(CLICK_CD_SLOW)

/obj/item/inhand_structure/Destroy()
	if(held_structure)
		release(FALSE)
	return ..()

/obj/item/inhand_structure/proc/deposit(obj/structure/L)
	if(!istype(L))
		return FALSE
	L.setDir(SOUTH)
	update_visuals(L)
	held_structure = L
	L.forceMove(src)
	name = L.name
	desc = L.desc
	return TRUE

/obj/item/inhand_structure/proc/update_visuals(obj/structure/L)
	appearance = L.appearance

/obj/item/inhand_structure/on_thrown(mob/living/carbon/user, atom/target)
	if((item_flags & ABSTRACT) || HAS_TRAIT(src, TRAIT_NODROP))
		return

	if(HAS_TRAIT(user, TRAIT_PACIFISM))
		to_chat(user, span_notice("You set [src] down gently on the ground."))
		release(release_direction = user.dir)
		return

	if(held_structure)
		beingthrown = TRUE
		say("Registering landed release") // Debug
		RegisterSignal(src, COMSIG_MOVABLE_THROW_LANDED, PROC_REF(landed_release))
		throw_at(target)
		user.adjustStaminaLoss(25)

/obj/item/inhand_structure/proc/bonk(mob/living/target)
	if(target.body_position == STANDING_UP)
		target.Stun(0.3 SECONDS) //drop weapons, etc
		target.Knockdown(5 SECONDS)
		target.visible_message(span_danger("[src] crashes into [target.name], flinging them back!"), \
			span_userdanger("You feel [src] crashing into you with great force!"), \
			span_hear("You hear a heavy thunk!"))
		var/atom/throw_target = get_edge_target_turf(target, get_dir(src, get_step_away(target, src)))
		target.throw_at(throw_target, 5, 2)
		playsound(src, 'sound/effects/bang.ogg', 40)
		release()

/obj/item/inhand_structure/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	. = ..()
	if(!QDELETED(hit_atom) && isliving(hit_atom))
		bonk(hit_atom)

/obj/item/inhand_structure/dropped()
	..()
	if(held_structure && isturf(loc))
		release()

/obj/item/inhand_structure/proc/release(del_on_release = TRUE, display_messages = TRUE, release_direction = SOUTH, beingthrown = FALSE)
	if(!held_structure)
		if(del_on_release)
			qdel(src)
		return FALSE
	if(beingthrown)
		say("Signal fired!") // Debugging: Ensure the signal is being called.
		beingthrown = FALSE
		return TRUE

	// Object release logic
	var/obj/structure/dropped_structure = held_structure
	held_structure = null // Stop holding the object
	dropped_structure.forceMove(drop_location())
	dropped_structure.setDir(release_direction)
	if(display_messages)
		dropped_structure.visible_message(span_warning("[dropped_structure] falls to the ground!"))
	if(del_on_release)
		qdel(src)
	return TRUE

/obj/item/inhand_structure/proc/landed_release()
	SIGNAL_HANDLER
	if(!held_structure)
		return

	var/obj/structure/landed_structure = held_structure
	if(isturf(loc))
		var/turf/location = loc
		held_structure = null
		landed_structure.forceMove(location)
		landed_structure.setDir(release_direction)
		landed_structure.visible_message(span_warning("[landed_structure] lands on the ground!"))
		UnregisterSignal(src, COMSIG_MOVABLE_THROW_LANDED, PROC_REF(landed_release))
		qdel(src)
		return TRUE


/obj/item/inhand_structure/relaymove(mob/living/user, direction)
	release()

/obj/item/inhand_structure/container_resist_act()
	release()

/obj/item/inhand_structure/Exited(atom/movable/gone, direction)
	. = ..()
	if(held_structure && held_structure == gone)
		release()

/obj/item/inhand_structure/destructible

/obj/item/inhand_structure/destructible/Destroy()
	if(held_structure)
		release(FALSE, TRUE, TRUE)
	return ..()

/obj/item/inhand_structure/destructible/release(del_on_release = TRUE, display_messages = TRUE, release_direction = SOUTH, delete_struct = FALSE, beingthrown = FALSE) //Honestly no clue why you'd want a deletable on drop structure, but there's no harm in making them an option for the future
	if(delete_struct && held_structure)
		QDEL_NULL(held_structure)
	return ..()
