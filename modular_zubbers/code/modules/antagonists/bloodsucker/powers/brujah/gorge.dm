#define FEED_NOTICE_RANGE_GORGE 4
#define FEED_DEFAULT_TIMER_GORGE 0 SECONDS

/datum/action/cooldown/bloodsucker/feed/gorge
	name = "Gorge"
	desc = "Violently feed off of a living creature."
	button_icon_state = "power_gorge"
	power_explanation = list(
		"Activate Gorge while next to someone and you will begin to feed blood off of them.",
		"The time needed before you start feeding speeds up the more you invest into hunting.",
		"Feeding off of someone while you have them aggressively grabbed will put them to sleep and start mauling them.",
		"While feeding, you can't speak, as your mouth is covered.",
		"You get no infractions for feeding, but everyone in 4 tiles including the target can see you feeding",
		"You can feed off of the dead without penalty, but never off the mindless. The thrill of the hunt courses through your veins",
		"You must use the ability again to stop sucking blood.",
	)
	cooldown_time = 10 SECONDS
	silent_feed = TRUE
	purchase_flags = BRUJAH_CAN_BUY
	/// Traits the ability gives to the victim when they are being drunk from
	victim_traits = list(TRAIT_IMMOBILIZED, TRAIT_SOFTSPOKEN)
	owner_traits = list(TRAIT_IMMOBILIZED, TRAIT_MUTE, TRAIT_BRAWLING_KNOCKDOWN_BLOCKED, TRAIT_NO_STAGGER, TRAIT_PUSHIMMUNE)
	var/aggressive_feeding = FALSE
	var/resist_before

/datum/action/cooldown/bloodsucker/feed/gorge/DeactivatePower(deactivate_flags)
	owner.move_resist = MOVE_RESIST_DEFAULT
	. = ..()

/datum/action/cooldown/bloodsucker/feed/gorge/proc/chew(mob/user, mob/living/feed_target)
	if(silent_feed)
		return
	user.visible_message(
		span_warning("[user] is tearing at [feed_target]'s throat! [feed_target.p_Their(TRUE)] blood sprays everywhere!"),
		span_warning("You start tearing at [feed_target]'s throat. [feed_target.p_Their(TRUE)] blood sprays everywhere!"))
	var/bite_modifier = 0
	if(bloodsuckerdatum_power.frenzied)
		bite_modifier = 3
	else if(owner.pulling == feed_target && owner.grab_state >= GRAB_AGGRESSIVE)
		bite_modifier = 2
	else
		bite_modifier = 1
	if(!silent_feed)
		feed_target.apply_damage(5*bite_modifier, BRUTE, BODY_ZONE_HEAD)
	INVOKE_ASYNC(feed_target, TYPE_PROC_REF(/mob, emote), "scream")
	return FALSE

/datum/action/cooldown/bloodsucker/feed/gorge/start_feed(mob/living/feed_target)
	. = ..()
	owner.move_resist = resist_before
	owner.move_resist = MOVE_FORCE_STRONG
	RegisterSignal(owner, COMSIG_MOB_CLIENT_PRE_LIVING_MOVE, PROC_REF(notify_move_block))
	return TRUE

/datum/action/cooldown/bloodsucker/feed/gorge/start_feed_silent(mob/living/feed_target)
	if(!(owner.pulling == feed_target && owner.grab_state >= GRAB_AGGRESSIVE))
		var/dead_message = feed_target.stat != DEAD ? " <i>[feed_target.p_they(TRUE)] lets out a silent gasp, they will remember this'.</i>" : ""
		owner.visible_message(
			span_warning("[owner] clamps down his jaws on [feed_target]'s neck [owner.p_their()]."), \
			span_notice("You clamp your jaws around [feed_target]'s neck.[dead_message]"), \
			vision_distance = FEED_NOTICE_RANGE_GORGE)

/datum/action/cooldown/bloodsucker/feed/start_feed_aggressive(mob/living/feed_target)
	. = ..()
	owner.playsound_local(get_turf(owner), 'sound/effects/magic/demon_consume.ogg', 80, FALSE, pressure_affected = FALSE, use_reverb = FALSE)
	feed_target.playsound_local(get_turf(owner), 'sound/effects/magic/demon_consume.ogg', 80, FALSE, pressure_affected = FALSE, use_reverb = FALSE)
	owner.visible_message(
		span_warning("[owner] closes [owner.p_their()] mouth around [feed_target]'s neck!"),
		span_warning("You sink your fangs into [feed_target]'s neck."))
	silent_feed = FALSE //no more mr nice guy

/datum/action/cooldown/bloodsucker/feed/gorge/process(seconds_per_tick)
	. = ..()
	chew()

#undef FEED_DEFAULT_TIMER_GORGE
#undef FEED_NOTICE_RANGE_GORGE
