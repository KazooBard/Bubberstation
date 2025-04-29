/obj/structure/proc/structure_pickup(mob/living/user, var/stam_penalty_initial, var/assigned_max_hits)
	var/obj/item/inhand_structure/holder = new(get_turf(src), src)
	holder.stamina_cost = stam_penalty_initial
	user.visible_message(span_warning("[user] scoops up [src]!"))
	user.put_in_hands(holder)

/obj/structure/proc/structure_try_pickup(mob/living/user, instant=FALSE, ignore_anchors=FALSE, var/stam_penalty_initial, var/assigned_max_hits)
	if(!ishuman(user))
		return
	if(!user.get_empty_held_indexes())
		to_chat(user, span_warning("Your hands are full!"))
		return FALSE
	if(anchored && !ignore_anchors)
		to_chat(user, span_warning("[src] doesn't even flinch, it's bolted down tight!"))
		return FALSE
	if(!instant)
		user.visible_message(span_warning("[user] starts trying to lift [src]!"), \
						span_danger("You start lifting [src]..."), null, null, src)
		if(!do_after(user, 2 SECONDS, target = src))
			return FALSE
	structure_pickup(user, stam_penalty_initial, assigned_max_hits)
	return TRUE //SKYRAT EDIT CHANGE
