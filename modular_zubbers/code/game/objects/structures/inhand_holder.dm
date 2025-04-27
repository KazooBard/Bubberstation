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
			src.visible_message(span_warning("[src] breaks against [target]!"))
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

	var/obj/structure/throw_structure = held_structure
	release(release_direction = user.dir)
	return throw_structure

/obj/item/inhand_structure/dropped()
	..()
	if(held_structure && isturf(loc))
		release()

/obj/item/inhand_structure/proc/release(del_on_release = TRUE, display_messages = TRUE, release_direction = SOUTH)
	if(!held_structure)
		if(del_on_release && !destroying)
			qdel(src)
		return FALSE
	var/obj/structure/dropped_structure = held_structure
	held_structure = null // stops the held mob from being release()'d twice.
	dropped_structure.forceMove(drop_location())
	dropped_structure.setDir(release_direction)
	if(display_messages)
		dropped_structure.visible_message(span_warning("[dropped_structure] uncurls!"))
	if(del_on_release && !destroying)
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

/obj/item/inhand_structure/destructible/release(del_on_release = TRUE, display_messages = TRUE, release_direction = SOUTH, delete_struct = FALSE) //Honestly no clue why you'd want a deletable on drop structure, but there's no harm in making them an option for the future
	if(delete_struct && held_structure)
		QDEL_NULL(held_structure)
	return ..()
