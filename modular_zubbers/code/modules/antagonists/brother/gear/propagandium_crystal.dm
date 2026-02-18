/obj/item/destabilizing_crystal/propagandium
	name = "radicalising crystal"
	desc = "Cybersun scientists have been hard at work trying to figure out the age-old question of 'How do we convert a non-sentient object to our cause?'\
			at the request of the shareholders. Through a series of drunk dartboard contests and experimenting on totally consenting engineers,\
			the chemical Propagandium was discovered, able to influence Supermatter Crystals on the molecular level to 'hate the corpos',\
			as stated by the intern assigned to the R&D team.."

	icon = 'icons/obj/machines/engine/supermatter.dmi'
	icon_state = "destabilizing_crystal"
	w_class = WEIGHT_CLASS_NORMAL
	obj_flags = CONDUCTS_ELECTRICITY
	item_flags = NO_PIXEL_RANDOM_DROP

// Im putting this here to save our maintainers time with diffs on core files

/obj/machinery/power/supermatter_crystal/attackby(obj/item/item, mob/user, list/modifiers, list/attack_modifiers)
	..()
	if(istype(item, /obj/item/destabilizing_crystal/propagandium))
		var/obj/item/destabilizing_crystal/propagandium/propagandium_crystal = item

		to_chat(user, span_warning("You begin to attach \the [propagandium_crystal] to \the [src]..."))
		if(do_after(user, 3 SECONDS, src))
			message_admins("[ADMIN_LOOKUPFLW(user)] attached [propagandium_crystal] to the supermatter at [ADMIN_VERBOSEJMP(src)].")
			user.log_message("attached [propagandium_crystal] to the supermatter", LOG_GAME)
			user.investigate_log("attached [propagandium_crystal] to a supermatter crystal.", INVESTIGATE_ENGINE)
			to_chat(user, span_danger("\The [propagandium_crystal] snaps onto \the [src]."))

			for(var/mob/player as anything in GLOB.player_list)
				if(!isdead(player))
					var/mob/living/living_player = player
					if(!living_player.is_antag())
						if(HAS_TRAIT(living_player, TRAIT_MINDSHIELD))
							to_chat(player, span_bolddanger("You feel a burning sense of grief, a pinpoint within the implant in your skull, NT's forces stood no chance to the syndicate..."))
							living_player.add_mood_event("propagandium_very_bad", /datum/mood_event/propagandium_very_bad)
						else
							to_chat(player, span_bolddanger("You feel a wave of dread wash over you, evil forces have corrupted the heart that keeps your station running..."))
							living_player.add_mood_event("propagandium_bad", /datum/mood_event/propagandium_bad)
					if(IS_TRAITOR(living_player))
						to_chat(player, span_bolddanger("Huh, seems the rookies can cook with fire if you let them... Someone's getting a promotion"))
						living_player.add_mood_event("propagandium_traitor", /datum/mood_event/propagandium_traitor)
					if(living_player?.mind?.has_antag_datum(/datum/antagonist/brother))
						to_chat(player, span_bolddanger("FUCK YES!!! We are SO getting a promotion now! Glory to the syndicate, BAYBEEEEEY!"))
						living_player.add_mood_event("propagandium_brotherascade", /datum/mood_event/propagandium_brother)
					if(IS_CHANGELING(living_player))
						to_chat(player, span_bolddanger("Eh, the syndicate and their publicity stunts... At least that'll keep the attention far away from me"))
						living_player.add_mood_event("propagandium_ling", /datum/mood_event/propagandium_ling)
					if(IS_SPY(living_player))
						to_chat(player, span_bolddanger("Huh, seems the syndicate's rookies can cook with fire if you let them... Someone's getting a promotion"))
						living_player.add_mood_event("propagandium_traitor", /datum/mood_event/propagandium_traitor)
					SEND_SOUND(player, 'sound/effects/magic/charge.ogg')
			color = COLOR_SYNDIE_RED
			start_looping_false_alerts()
			log_activation(who = user, how = propagandium_crystal)
			qdel(propagandium_crystal)
		return

	return ..()

/obj/machinery/power/supermatter_crystal/proc/start_looping_false_alerts(seconds_per_tick)
	addtimer(CALLBACK(src, PROC_REF(start_false_alerts), rand(10, 18) MINUTES))
	addtimer(CALLBACK(src, PROC_REF(start_false_alerts), rand(20, 40) MINUTES))
	addtimer(CALLBACK(src, PROC_REF(start_false_alerts), rand(50, 60) MINUTES))

/obj/machinery/power/supermatter_crystal/proc/start_false_alerts()

	message_admins("[src] is broadcasting a false alert due to blood brothers planting the radicalising shard [ADMIN_VERBOSEJMP(src)].")

	var/randfactor = (100 - rand(60, 99))
	src.radio.talk_into(src, "CRYSTAL DELAMINATION IMMINENT! Integrity: [round(randfactor, 0.01)]%", src.emergency_channel)
	src.radio.talk_into(src, "Danger! Crystal hyperstructure integrity faltering! Integrity: [round(randfactor, 0.01)]%", src.warning_channel)
	var/main_engine = src.is_main_engine
	if(!main_engine)
		var/area/sm_area = get_area(src)
		if(istype(sm_area, /area/station/engineering/supermatter))
			main_engine = TRUE

	if(main_engine)
		alert_sound_to_playing('modular_skyrat/master_files/sound/effects/reactor/core_overheating.ogg')
		return
	else
		playsound(src, 'sound/machines/engine_alert/engine_alert2.ogg', 100, FALSE, 70, 7, falloff_distance = 30)
		return
