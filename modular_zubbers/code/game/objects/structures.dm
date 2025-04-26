/obj/structure/proc/structure_pickup(mob/living/user)
	var/obj/item/inhand_structure/holder = new(get_turf(src), src)
	user.visible_message(span_warning("[user] scoops up [src]!"))
	user.put_in_hands(holder)

/obj/structure/proc/structure_try_pickup(mob/living/user, instant=FALSE)
	if(!ishuman(user))
		return
	if(!user.get_empty_held_indexes())
		to_chat(user, span_warning("Your hands are full!"))
		return FALSE
	if(anchored)
		to_chat(user, span_warning("[src] is anchored down!"))
		return FALSE
	if(!instant)
		user.visible_message(span_warning("[user] starts trying to lift [src]!"), \
						span_danger("You start lifting [src]..."), null, null, src)
		if(!do_after(user, 2 SECONDS, target = src))
			return FALSE
	structure_pickup(user)
	return TRUE //SKYRAT EDIT CHANGE
