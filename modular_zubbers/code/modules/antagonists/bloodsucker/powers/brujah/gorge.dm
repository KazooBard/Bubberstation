#define FEED_NOTICE_RANGE_GORGE 4
#define FEED_DEFAULT_TIMER_GORGE 0 SECONDS

/datum/action/cooldown/bloodsucker/feed/gorge
	name = "Gorge"
	desc = "Violently feed off of a living creature."
	button_icon_state = "power_feed"
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
	var/aggressive_feeding = FALSE
	var/resistbefore
	/// Traits the ability gives to the victim when they are being drunk from
	victim_traits = list(TRAIT_IMMOBILIZED, TRAIT_SOFTSPOKEN)
	owner_traits = list(TRAIT_IMMOBILIZED, TRAIT_MUTE, TRAIT_BRAWLING_KNOCKDOWN_BLOCKED, TRAIT_NO_STAGGER, TRAIT_PUSHIMMUNE)

/datum/action/cooldown/bloodsucker/feed/gorge/DeactivatePower(deactivate_flags)
	// run before parent checks just to ensure that this always gets cleaned up
	UnregisterSignal(owner, COMSIG_MOB_CLIENT_PRE_LIVING_MOVE)
	owner.remove_traits(owner_traits, FEED_TRAIT)
	owner.move_resist = MOVE_RESIST_DEFAULT
	. = ..()
	if(!.)
		return
	var/mob/living/user = owner
	var/mob/living/feed_target = target_ref?.resolve()

	if(!blood_taken)
		return
	if(isnull(feed_target) && blood_taken)
		log_combat(user, user, "fed on blood (target not found)", addition="(and took [blood_taken] blood)")
	else
		log_combat(user, feed_target, "fed on blood", addition="(and took [blood_taken] blood)")
		to_chat(user, span_notice("You slowly release [feed_target]."))
		if(feed_target.client && feed_target.stat == DEAD && bloodsuckerdatum_power.my_clan.blood_drink_type != BLOODSUCKER_DRINK_SLOPPILY)
			user.add_mood_event("drankkilled", /datum/mood_event/drankkilled)
			bloodsuckerdatum_power.AddHumanityLost(5)

	target_ref = null
	warning_target_bloodvol = initial(warning_target_bloodvol)
	blood_taken = initial(blood_taken)
	notified_overfeeding = initial(notified_overfeeding)

/datum/action/cooldown/bloodsucker/feed/gorge/start_feed(mob/living/feed_target)
	if(owner.pulling == feed_target && owner.grab_state >= GRAB_AGGRESSIVE)
		start_feed_aggressive(feed_target)
	else
		start_feed_silent(feed_target)

	//check if we were seen
	for(var/mob/living/watchers in oviewers(FEED_NOTICE_RANGE_GORGE) - feed_target)
		if(!watchers.client)
			continue
		if(watchers.has_unlimited_silicon_privilege)
			continue
		if(watchers.stat >= DEAD)
			continue
		if(watchers.is_blind() || watchers.is_nearsighted_currently())
			continue
		if(IS_BLOODSUCKER(watchers) || IS_GHOUL(watchers) || HAS_TRAIT(watchers.mind, TRAIT_BLOODSUCKER_HUNTER))
			continue
		owner.balloon_alert(owner, "feed noticed!")
		bloodsuckerdatum_power.give_masquerade_infraction()
		break
	owner.add_traits(owner_traits, FEED_TRAIT)
	feed_target.add_traits(victim_traits, FEED_TRAIT)
	owner.move_resist = resistbefore
	owner.move_resist = INFINITY
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
	if(!IS_BLOODSUCKER(feed_target) && !IS_GHOUL(feed_target) && !IS_MONSTERHUNTER(feed_target))
		feed_target.Unconscious(get_sleep_time())
	if(!feed_target.density)
		feed_target.Move(owner.loc)
	owner.playsound_local(get_turf(owner), 'sound/effects/magic/demon_consume.ogg', 80, FALSE, pressure_affected = FALSE, use_reverb = FALSE)
	feed_target.playsound_local(get_turf(owner), 'sound/effects/magic/demon_consume.ogg', 80, FALSE, pressure_affected = FALSE, use_reverb = FALSE)
	owner.visible_message(
		span_warning("[owner] closes [owner.p_their()] mouth around [feed_target]'s neck!"),
		span_warning("You sink your fangs into [feed_target]'s neck."))
	silent_feed = FALSE //no more mr nice guy

/datum/action/cooldown/bloodsucker/feed/gorge/process(seconds_per_tick)
	if(!active) //If we aren't active (running on SSfastprocess)
		return ..() //Manage our cooldown timers
	var/mob/living/user = owner
	var/mob/living/feed_target = target_ref?.resolve()
	if(!feed_target)
		DeactivatePower()
		return
	if(!ContinueActive(user, feed_target, !silent_feed, !silent_feed))
		throat_rip()
		DeactivatePower()
		return
	var/feed_strength_mult = 0
	if(bloodsuckerdatum_power.frenzied)
		feed_strength_mult = 2
	else if(owner.pulling == feed_target && owner.grab_state >= GRAB_AGGRESSIVE)
		feed_strength_mult = 1
	else
		feed_strength_mult = 0.6 //They really dont get much time to feed, let tehm do it a bit quicker
	var/already_drunk = targets_and_blood[target_ref] || 0
	var/blood_eaten = bloodsuckerdatum_power.handle_feeding(feed_target, feed_strength_mult, level_current, already_drunk)
	blood_taken += blood_eaten
	targets_and_blood[target_ref] += blood_eaten
	decrement_blood_drunk(blood_eaten * 0.5)
	var/bite_modifier = 0
	if(bloodsuckerdatum_power.frenzied)
		bite_modifier = 3
	else if(owner.pulling == feed_target && owner.grab_state >= GRAB_AGGRESSIVE)
		bite_modifier = 2
	else
		bite_modifier = 1
	if(!silent_feed)
		feed_target.apply_damage(5*bite_modifier, BRUTE, BODY_ZONE_HEAD)
	if(feed_strength_mult > 5)
		user.add_mood_event("drankblood", /datum/mood_event/drankblood)
	// Drank mindless as Ventrue? - BAD
	if((bloodsuckerdatum_power.my_clan && bloodsuckerdatum_power.my_clan.blood_drink_type == BLOODSUCKER_DRINK_SNOBBY) && !feed_target.mind)
		user.add_mood_event("drankblood", /datum/mood_event/drankblood_bad)
	// Brujah does not care from where the blood flows, unless it's dishonorable yucky mindless/vamps
	if(feed_target.stat >= DEAD)
		if(!(bloodsuckerdatum_power.my_clan.blood_drink_type == BLOODSUCKER_DRINK_SLOPPILY && feed_target.mind))
			user.add_mood_event("drankblood", /datum/mood_event/drankblood_dead)
			return
	if(feed_target.mind && feed_target.mind?.has_antag_datum(/datum/antagonist/bloodsucker) || feed_target.mind?.has_antag_datum(/datum/antagonist/ghoul))
		user.add_mood_event("drankblood", /datum/mood_event/drankblood_dishonorable)

	if(!IS_BLOODSUCKER(feed_target))
		if(feed_target.blood_volume <= BLOOD_VOLUME_BAD && warning_target_bloodvol > BLOOD_VOLUME_BAD)
			owner.balloon_alert(owner, "your victim's blood is fatally low!")
		else if(feed_target.blood_volume <= BLOOD_VOLUME_OKAY && warning_target_bloodvol > BLOOD_VOLUME_OKAY)
			owner.balloon_alert(owner, "your victim's blood is dangerously low.")
		else if(feed_target.blood_volume <= BLOOD_VOLUME_SAFE && warning_target_bloodvol > BLOOD_VOLUME_SAFE)
			owner.balloon_alert(owner, "your victim's blood is at an unsafe level.")
		else if(feed_target.blood_volume <= BLOOD_VOLUME_SAFE && bloodsuckerdatum_power.GetBloodVolume() >= BLOOD_VOLUME_SAFE && owner.pulling != feed_target && bloodsuckerdatum_power.my_clan.blood_drink_type != BLOODSUCKER_DRINK_SLOPPILY)
			owner.balloon_alert(owner, "you cannot drink more without first getting a better grip!.")

			DeactivatePower()
		warning_target_bloodvol = feed_target.blood_volume

	if(bloodsuckerdatum_power.GetBloodVolume() >= bloodsuckerdatum_power.max_blood_volume && !notified_overfeeding)
		user.balloon_alert(owner, "full on blood! Anything more we drink now will be burnt on quicker healing")
		notified_overfeeding = TRUE
	if(feed_target.blood_volume <= 0)
		user.balloon_alert(owner, "no blood left!")

		DeactivatePower()
		return
	owner.playsound_local(null, 'sound/effects/singlebeat.ogg', 40, TRUE)
	//play sound to target to show they're dying.
	if(owner.pulling == feed_target && owner.grab_state >= GRAB_AGGRESSIVE)
		feed_target.playsound_local(null, 'sound/effects/singlebeat.ogg', 40, TRUE)

#undef FEED_DEFAULT_TIMER_GORGE
#undef FEED_NOTICE_RANGE_GORGE
