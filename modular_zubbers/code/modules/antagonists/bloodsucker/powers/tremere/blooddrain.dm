/datum/action/cooldown/bloodsucker/targeted/tremere/blooddrain
	name = "Thaumaturgy: Blood Drain"
	desc = "Cast a beam of draining magic that saps the vitality of your target to steal their blood and heal yourself."
	button_icon_state = "power_thaumaturgy"
	active_background_icon_state = "tremere_power_on"
	base_background_icon_state = "tremere_power_off"
	power_explanation = "Cast a beam of draining magic that saps the vitality of your target to steal their blood and heal yourself."
	bloodsucker_check_flags = BP_CANT_USE_IN_TORPOR | BP_CANT_USE_IN_FRENZY
	purchase_flags = TREMERE_CAN_BUY
	bloodcost = 75
	level_current = 1
	cooldown_time = 10 SECONDS	// Very unlikely to ever last past 10 seconds even if the actual duration is longer. Combat is a fuck.
	target_range = 7
	power_activates_immediately = FALSE
	prefire_message = "Select your target."
	var/active_beams = 0

	// Track multiple active status effects created by this power
	var/list/active_effects = list()

/datum/action/cooldown/bloodsucker/targeted/tremere/blooddrain/FireTargetedPower(atom/target_atom)
	. = ..()
	var/mob/living/living_owner = owner
	/* var/mob/living/living_target = target_atom
	check_witnesses(living_target) */
	living_owner.face_atom(target_atom)
	living_owner.changeNext_move(CLICK_CD_RANGE)
	living_owner.newtonian_move(get_dir(target_atom, living_owner))

	// Prevent creating more beams than allowed by the current drain level
	if(active_beams >= get_drain_level())
		DeactivatePower()
		StartCooldown()
		return

	var/obj/projectile/magic/blood_drain/drain = new(living_owner.loc)
	drain.firer = living_owner
	drain.fired_from = src
	drain.power = get_drain_level()
	drain.def_zone = ran_zone(living_owner.zone_selected)
	drain.aim_projectile(target_atom, living_owner)
	INVOKE_ASYNC(drain, TYPE_PROC_REF(/obj/projectile, fire))
	pay_cost()

	playsound(living_owner, 'sound/effects/magic/wand_teleport.ogg', 60, TRUE)

/datum/action/cooldown/bloodsucker/targeted/tremere/blooddrain/proc/get_drain_level()
	if(level_current <= 2)
		return 1
	if(level_current == 3)
		return 2
	if(level_current >= 4)
		return 3

/datum/action/cooldown/bloodsucker/targeted/tremere/blooddrain/DeactivatePower()
	. = ..()
	// Do not forcibly end existing drain beams when deactivating the power.
	// Beams are their own status effects and will expire on their own.

/obj/projectile/magic/blood_drain
	name = "vitality draining stream"
	icon_state = "nothing"
	range = 7
	antimagic_flags = MAGIC_RESISTANCE_HOLY
	var/datum/beam/drain_beam
	var/power = 1

/obj/projectile/magic/blood_drain/fire(angle, atom/direct_target)
	if(!firer)
		// projectile fired without a firer — cancel safely instead of crashing server
		qdel(src)
		return
	drain_beam = firer.Beam(src, icon = 'icons/effects/beam.dmi', icon_state = "blood", time = 10 SECONDS, maxdistance = 7)
	return ..()

/obj/projectile/magic/blood_drain/on_hit(mob/living/target, blocked, pierce_hit)
	. = ..()
	if(!isliving(target))
		return
	target.apply_status_effect(/datum/status_effect/blood_drain, firer, fired_from)

/obj/projectile/magic/blood_drain/Destroy()
	if(!QDELETED(drain_beam))
		qdel(drain_beam)
	drain_beam = null
	return ..()

///
/// Status Effect. Literally copied from life drain spell of wizards, but modified to work with bloodsuckers.
///
/datum/status_effect/blood_drain
	id = "blood_drain"
	duration = 20 SECONDS
	tick_interval = 0.25 SECONDS
	status_type = STATUS_EFFECT_REPLACE
	processing_speed = STATUS_EFFECT_PRIORITY
	alert_type = null
	var/datum/beam/drain_beam
	var/mob/living/carbon/bloodsucker
	var/datum/action/cooldown/bloodsucker/targeted/tremere/blooddrain/spell
	var/blood_drain = 3	 // Amount of blood drained per tick, at 0.25 this is 12 blood per second
	var/stamina_drain = 7
	var/datum/antagonist/bloodsucker/our_sucker // need this to add blood

/datum/status_effect/blood_drain/on_creation(mob/living/new_owner, mob/living/firer, fired_from, duration_override)
	if(isnull(firer) || isnull(fired_from) || !iscarbon(firer) || !iscarbon(new_owner))
		qdel(src)
		return
	bloodsucker = firer
	our_sucker = IS_BLOODSUCKER(firer)
	spell = fired_from
	// Track this new active effect for the casting power
	if(!isnull(spell))
		spell.active_effects += src
		spell.active_beams += 1
	drain_beam = bloodsucker.Beam(new_owner, icon = 'icons/effects/beam.dmi', icon_state = "g_beam", time = 22 SECONDS, maxdistance = 7, beam_color = COLOR_RED)
	RegisterSignal(drain_beam, COMSIG_QDELETING, PROC_REF(end_drain))
	new_owner.visible_message(span_boldwarning("[bloodsucker] begins draining the life force from [new_owner]!"), span_boldwarning("[bloodsucker] is draining your life force! You need to get away from them to stop it!"))
	. = ..()

/datum/status_effect/blood_drain/on_apply()
	. = ..()
	owner.add_movespeed_modifier(/datum/movespeed_modifier/status_effect/life_drain)

/datum/status_effect/blood_drain/on_remove()
	. = ..()
	owner.remove_movespeed_modifier(/datum/movespeed_modifier/status_effect/life_drain)
	end_drain()

/datum/status_effect/blood_drain/tick()
	if(!iscarbon(owner) || owner.stat > HARD_CRIT) //If they're dead or non-humanoid, this spell fails
		end_drain()
		return
	if(!iscarbon(bloodsucker)) //You never know what might happen with wizards around
		end_drain()
		return

	if(HAS_TRAIT(owner, TRAIT_INCAPACITATED) || owner.stat)
		//If the victim is incapacitated, drain their blood
		owner.blood_volume -= blood_drain
	else
		//If they aren't incapacitated yet, drain only their stamina
		owner.apply_damage(stamina_drain, STAMINA)

	if(prob(20))
		INVOKE_ASYNC(owner, TYPE_PROC_REF(/mob, emote), "scream")
		owner.visible_message(span_boldwarning("[bloodsucker] absorbs blood from [owner]!"), span_boldwarning("It BURNS!"))

	//bloodsucker heals at a steady rate over the duration of the spell regardless of the victim's state
	bloodsucker.heal_overall_damage(brute = 0.5, burn = 0.5, stamina = 5)

	our_sucker.AdjustBloodVolume(blood_drain)
	our_sucker.total_blood_drank += blood_drain// bloodsuckers get double the blood drained because of balance
	drain_beam.redrawing()

/datum/status_effect/blood_drain/proc/end_drain()
	SIGNAL_HANDLER
	// Remove this effect from the power's active list and decrement beam count
	if(!isnull(spell))
		spell.active_effects -= src
		spell.active_beams -= 1
		if(spell.active_beams < 0)
			spell.active_beams = 0
	if(QDELING(src))
		return
	if(!QDELETED(drain_beam))
		QDEL_NULL(drain_beam)
	qdel(src)

/datum/movespeed_modifier/status_effect/life_drain
	multiplicative_slowdown = 1.25
