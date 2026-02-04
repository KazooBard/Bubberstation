#define GAZE_MUTE_LEVEL 2
#define GAZE_ITEMDROP_LEVEL 3
#define GAZE_SHUTDOWN_LEVEL 4

/datum/action/cooldown/bloodsucker/targ

/datum/action/cooldown/bloodsucker/targeted/hypnotic_gaze
	name = "Hypnotic Gaze"
	button_icon_state = "power_auspex"
	background_icon_state = "tremere_power_off"
	active_background_icon_state = "tremere_power_on"
	base_background_icon_state = "tremere_power_off"
	button_icon = 'modular_zubbers/icons/mob/actions/tremere_bloodsucker.dmi'
	background_icon = 'modular_zubbers/icons/mob/actions/tremere_bloodsucker.dmi'
	level_current = 1
	button_icon_state = "power_dominate"
	purchase_flags = TREMERE_CAN_BUY
	bloodcost = 15
	target_range = 6
	/// Data huds to show while the power is active
	var/list/datahuds = list(DATA_HUD_SECURITY_ADVANCED, DATA_HUD_MEDICAL_ADVANCED, DATA_HUD_DIAGNOSTIC, DATA_HUD_BOT_PATH)
	var/datum/weakref/target_ref

	var/summon_duration = 30 SECONDS

/datum/action/cooldown/bloodsucker/targeted/summon/check_valid_target(atom/target_atom)
	. = ..()
	if(!.)
		return FALSE
	var/mob/living/current_target = target_atom // We already know it's carbon due to CheckValidTarget()
	// No mind
#ifndef BLOODSUCKER_TESTING
	if(!current_target.mind)
		owner.balloon_alert(owner, "[current_target] is mindless.")
		return FALSE
#endif
	// Bloodsucker
	if(IS_BLOODSUCKER(current_target))
		owner.balloon_alert(owner, "bloodsuckers are immune to [src].")
		return FALSE
	// Dead/Unconscious
	if(current_target.stat > CONSCIOUS)
		owner.balloon_alert(owner, "[current_target] is not [(current_target.stat == DEAD || HAS_TRAIT(current_target, TRAIT_FAKEDEATH)) ? "alive" : "conscious"].")
		return FALSE
	// Target has eyes?
	if(!current_target.get_organ_slot(ORGAN_SLOT_EYES) && !issilicon(current_target))
		owner.balloon_alert(owner, "[current_target] has no eyes.")
		return FALSE
	// Target blind?
	if(current_target.is_blind() && !issilicon(current_target))
		owner.balloon_alert(owner, "[current_target] is blind.")
		return FALSE

	// Gone through our checks, let's mark our guy.
	target_ref = WEAKREF(current_target)
	return TRUE





/datum/action/cooldown/bloodsucker/targeted/hypnotic_gaze/FireTargetedPower(atom/target, params)
	var/mob/living/user = owner
	var/mob/living/carbon/mesmerized_target = target_ref?.resolve()

	if(issilicon(mesmerized_target))
		var/mob/living/silicon/mesmerized = mesmerized_target
		mesmerized.emp_act(EMP_HEAVY)
		owner.balloon_alert(owner, "temporarily shut [mesmerized] down.")
		PowerActivatedSuccesfully() // PAY COST! BEGIN COOLDOWN!
		return
	// slow them down during the mesmerize
	mute_target(mesmerized_target)

	to_chat(mesmerized_target, "[user]'s eyes look into yours, and [span_hypnophrase("you feel your mind slipping away")]...")

	if(HAS_TRAIT_FROM_ONLY(mesmerized_target, TRAIT_NO_TRANSFORM, MESMERIZE_TRAIT))
		owner.balloon_alert(owner, "[mesmerized_target] is already in a hypnotic gaze.")
		return
	owner.balloon_alert(owner, "successfully mesmerized [mesmerized_target].")
	mesmerize_effects(user, mesmerized_target)
	PowerActivatedSuccesfully() // PAY COST! BEGIN COOLDOWN!

/datum/action/cooldown/bloodsucker/targeted/hypnotic_gaze/FireSecondaryTargetedPower(atom/target, params)
	if(!isliving(target))
		CRASH("[src] somehow casted on a non-living target, should have been stopped by CheckCanTarget.")
	if(timer || !COOLDOWN_FINISHED(src, mesmerize_cooldown))
		return
	var/mob/living/mesmerized_target = target
	owner.balloon_alert(owner, "gazing [mesmerized_target]...")
	owner.say("Fall.", spans = span_abductor,)
	mesmerized_target.Knockdown(get_power_time())
	PowerActivatedSuccesfully()



/datum/action/cooldown/bloodsucker/targeted/hypnotic_gaze/proc/mesmerize_effects(mob/living/user, mob/living/mesmerized_target)
	var/power_time = get_power_time()
	mute_target(mesmerized_target)
	mesmerized_target.Immobilize(power_time)
	mesmerized_target.next_move = world.time + power_time
	mesmerized_target.apply_status_effect(/datum/status_effect/summoned, summon_duration, owner)



/datum/action/cooldown/bloodsucker/targeted/hypnotic_gaze/proc/combat_mesmerize_effects(mob/living/user, mob/living/mesmerized_target)
	if(!ContinueActive(user, mesmerized_target))
		StartCooldown(cooldown_time * 0.5)
		owner.balloon_alert(owner, "failed!")
		return
	to_chat(mesmerized_target, "[src]'s eyes look into yours, and [span_hypnophrase("your head becomes fuzzy for a moment")]...")
	var/effect_time = combat_mesmerize_time()
	mute_target(mesmerized_target)
	if(knockdown_on_secondary)
		mesmerized_target.Knockdown(effect_time)
	else
		mesmerized_target.adjust_confusion(effect_time)
	PowerActivatedSuccesfully(cost_override = bloodcost * 0.5)

/datum/action/cooldown/bloodsucker/targeted/hypnotic_gaze/proc/get_power_time()
	return 3 SECONDS + level_current * 1 SECONDS

/datum/action/cooldown/bloodsucker/targeted/hypnotic_gaze/proc/get_mute_time()
	return get_power_time() * 2

/datum/action/cooldown/bloodsucker/targeted/hypnotic_gaze/proc/combat_mesmerize_time()
	return get_power_time() * 0.3

/datum/action/cooldown/bloodsucker/targeted/hypnotic_gaze/proc/blind_target(mob/living/mesmerized_target)
	if(!blind_at_level && level_current < blind_at_level)
		return
	mesmerized_target.become_blind(MESMERIZE_TRAIT)

/datum/action/cooldown/bloodsucker/targeted/hypnotic_gaze/proc/mute_target(mob/living/mesmerized_target)
	if(level_current >= MESMERIZE_MUTE_LEVEL)
		mesmerized_target.set_silence_if_lower(get_mute_time())

/datum/action/cooldown/bloodsucker/targeted/hypnotic_gaze/DeactivatePower(deactivate_flags)
	. = ..()
	target_ref = null
	timer = null






/datum/action/cooldown/bloodsucker/targeted/summon/FireTargetedPower(atom/target_atom)
	. = ..()
	var/mob/living/carbon/carbon_target = target_atom

	carbon_target.apply_status_effect(/datum/status_effect/summoned, summon_duration, owner)

	owner.balloon_alert(owner, "summoning [carbon_target]")
	to_chat(carbon_target, span_awe("An irresistible compulsion draws you towards [owner]..."), type = MESSAGE_TYPE_WARNING)
	to_chat(owner, span_notice("You beckon [carbon_target] towards you."), type = MESSAGE_TYPE_INFO)


/// Status effect for being summoned towards the bloodsucker
/datum/status_effect/summoned
	id = "summoned"
	status_type = STATUS_EFFECT_UNIQUE
	duration = 30 SECONDS
	tick_interval = 0.5 SECONDS
	processing_speed = STATUS_EFFECT_PRIORITY
	alert_type = /atom/movable/screen/alert/status_effect/summoned
	/// The bloodsucker who is summoning us
	var/mob/living/source_bloodsucker
	/// The move loop handling our movement
	var/datum/move_loop/move_loop
	/// How long between each step (slow, staggering movement)
	var/step_delay = 1.5 SECONDS

/datum/status_effect/summoned/on_creation(mob/living/new_owner, set_duration, mob/living/bloodsucker)
	if(IS_SAFE_NUM(set_duration))
		duration = set_duration
	source_bloodsucker = bloodsucker
	return ..()

/datum/status_effect/summoned/Destroy()
	source_bloodsucker = null
	QDEL_NULL(move_loop)
	return ..()

/datum/status_effect/summoned/on_apply()
	if(!iscarbon(owner))
		return FALSE
	owner.add_traits(list(TRAIT_INCAPACITATED, TRAIT_MUTE), TRAIT_STATUS_EFFECT(id))
	RegisterSignal(owner, COMSIG_MOB_CLIENT_PRE_MOVE, PROC_REF(block_player_move))
	owner.add_client_colour(/datum/client_colour/glass_colour/pink)
	start_movement()
	return TRUE

/// Blocks the player from moving themselves while summoned
/datum/status_effect/summoned/proc/block_player_move(mob/source, atom/new_loc)
	SIGNAL_HANDLER
	return COMSIG_MOB_CLIENT_BLOCK_PRE_MOVE

/// Starts or restarts the movement loop towards the bloodsucker
/datum/status_effect/summoned/proc/start_movement()
	if(move_loop)
		qdel(move_loop)
	if(QDELETED(source_bloodsucker) || QDELETED(owner))
		return
	move_loop = SSmove_manager.home_onto(owner, source_bloodsucker, step_delay, timeout = INFINITY)
	if(move_loop)
		RegisterSignal(move_loop, COMSIG_QDELETING, PROC_REF(on_move_loop_deleted))

/// Called when the move loop is deleted externally
/datum/status_effect/summoned/proc/on_move_loop_deleted(datum/source)
	SIGNAL_HANDLER
	move_loop = null

/datum/status_effect/summoned/on_remove()
	owner.remove_traits(list(TRAIT_INCAPACITATED, TRAIT_MUTE), TRAIT_STATUS_EFFECT(id))

	UnregisterSignal(owner, COMSIG_MOB_CLIENT_PRE_MOVE)

	owner.remove_client_colour(/datum/client_colour/glass_colour/pink)

	if(move_loop)
		UnregisterSignal(move_loop, COMSIG_QDELETING)
		qdel(move_loop)
		move_loop = null

	// Stop any residual movement
	SSmove_manager.stop_looping(owner)

	to_chat(owner, span_awe("The compulsion fades and you regain control of yourself."))

/datum/status_effect/summoned/tick(seconds_between_ticks)
	// Check if bloodsucker is still valid
	if(QDELETED(source_bloodsucker) || source_bloodsucker.stat == DEAD)
		qdel(src)
		return

	// Check if we've reached the bloodsucker (adjacent)
	if(owner.Adjacent(source_bloodsucker))
		to_chat(owner, span_awe("You have arrived before [source_bloodsucker]..."))
		to_chat(source_bloodsucker, span_notice("[owner] has arrived before you."))
		// Brief stun when arriving so we don’t look weird with the movespeed
		owner.Stun(2 SECONDS)
		qdel(src)
		return

	// Check line of sight - if broken, end the effect
	if(!CAN_SEE_RANGED(source_bloodsucker, owner, 10))
		to_chat(owner, span_awe("You lose sight of your summoner and the compulsion breaks."))
		qdel(src)
		return

	// Make sure we're facing the bloodsucker
	owner.face_atom(source_bloodsucker)

	// Restart movement if it stopped for some reason (blocked by obstacle, etc)
	if(!move_loop)
		start_movement()

/datum/status_effect/summoned/get_examine_text()
	return span_warning("[owner.p_They()] [owner.p_are()] walking with a blank expression, as if compelled.")

/// Alert for summoned status
/atom/movable/screen/alert/status_effect/summoned
	name = "Summoned"
	desc = "You are being compelled to approach someone. You cannot resist."
	icon_state = "mind_control"


#undef GAZE_MUTE_LEVEL
#undef GAZE_ITEMDROP_LEVEL
