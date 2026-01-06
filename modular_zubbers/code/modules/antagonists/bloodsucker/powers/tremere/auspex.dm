/**
 *	# Auspex
 *
 *	Level 1 - Cloak of Darkness until clicking an area, teleports the user to the selected area (max 2 tile)
 *	Level 2 - Cloak of Darkness until clicking an area, teleports the user to the selected area (max 3 tiles)
 *	Level 3 - Cloak of Darkness until clicking an area, teleports the user to the selected area
 *	Level 4 - Cloak of Darkness until clicking an area, teleports the user to the selected area, causes nearby people to bleed.
 *	Level 5 - Cloak of Darkness until clicking an area, teleports the user to the selected area, causes nearby people to fall asleep.
 */

#define AUSPEX_BLOOD_COST_PER_CHARGE 5
#define AUSPEX_COOLDOWN_PER_CHARGE 5 SECONDS
#define AUSPEX_BLOOD_COST_PER_TILE 5
#define AUSPEX_BAT_LEVEL 2
#define AUSPEX_BAT_LIFESTEAL_LEVEL 4
#define AUSPEX_KNOCKDOWN_LEVEL 5
#define AUSPEX_ANYWHERE_LEVEL 6
/datum/action/cooldown/bloodsucker/targeted/tremere/auspex
	name = "Auspex"
	level_current = 1
	button_icon_state = "power_auspex"
	bloodsucker_check_flags = BP_CANT_USE_IN_TORPOR
	purchase_flags = TREMERE_CAN_BUY
	bloodcost = 10
	constant_bloodcost = 1
	cooldown_time = 0.5 SECONDS
	target_range = 5
	power_activates_immediately = FALSE
	prefire_message = "Right click to teleport"
	var/spawn_count = 1
	var/spawn_type = /mob/living/basic/bat/bloodsucker/temp
	var/max_charges = 2
	var/charges = 2
	var/recharge_duration = 50
	var/decimal_charges = 0
	var/list/portals = list()
	var/max_portals = 2
	var/datum/weakref/first_gate
	var/datum/weakref/second_gate
	COOLDOWN_DECLARE(auspex_recharge)

/datum/action/cooldown/bloodsucker/targeted/tremere/auspex/proc/start_charging()
	addtimer(CALLBACK(src, PROC_REF(recharge)), recharge_duration)

/datum/action/cooldown/bloodsucker/targeted/tremere/auspex/proc/recharge()
	charges = min(charges + 1, get_max_charges())
	owner.balloon_alert(owner, "regained charge")
	playsound(src, 'sound/effects/magic/enter_blood.ogg', 10, TRUE, extrarange = SILENCED_SOUND_EXTRARANGE, falloff_distance = 0)

	// if(charges < max_charges)
	// 	if(!COOLDOWN_STARTED(src, auspex_recharge))
	// 		COOLDOWN_START(src, auspex_recharge, recharge_duration)
	// 	else
	// 		var/leftover = COOLDOWN_TIMELEFT(src, auspex_recharge)
	// 		COOLDOWN_RESET(src, auspex_recharge)
	// 		COOLDOWN_START(src, auspex_recharge, recharge_duration + leftover)
	// 		if(COOLDOWN_TIMELEFT(src, auspex_recharge) <= recharge_duration)
	// 			charges++
	// 			COOLDOW





/datum/action/cooldown/bloodsucker/targeted/tremere/auspex/Grant()
	. = ..()
	charges = get_max_charges()

/datum/action/cooldown/bloodsucker/targeted/tremere/auspex/Remove()
	. = ..()
	cleanup_portals()

/datum/action/cooldown/bloodsucker/targeted/tremere/auspex/proc/cleanup_portals()
	for(var/datum/weakref/ref as anything in portals)
		var/obj/effect/portal/blood_gate/todelete = ref?.resolve()
		todelete.closing = TRUE
		portals -= ref
		addtimer(CALLBACK(todelete, GLOBAL_PROC_REF(qdel)), 2 SECONDS)

/datum/action/cooldown/bloodsucker/targeted/tremere/auspex/proc/get_max_charges()
	if(level_current <= 2)
		return 2
	if(level_current == 3)
		return 3
	if(level_current >= 4)
		return level_current

/datum/action/cooldown/bloodsucker/targeted/tremere/auspex/update_button_status(atom/movable/screen/movable/action_button/button, force)
	. = ..()
	if(next_use_time - world.time <= 0)
		button.maptext = MAPTEXT_TINY_UNICODE(span_center("[charges]/[get_max_charges()]"))

/datum/action/cooldown/bloodsucker/targeted/tremere/auspex/on_power_upgrade()
	// 1 + for default, the other + is for the upgrade that hasn't been added yet.
	spawn_count = level_current
	bloodcost = get_max_charges() * AUSPEX_BLOOD_COST_PER_CHARGE
	// just in case you somehow level up while the power is active
	charges = get_max_charges()
	. = ..()

/datum/action/cooldown/bloodsucker/targeted/tremere/auspex/get_power_desc_extended()
	. = "Hide yourself within a Cloak of Darkness, click on a tile to teleport"
	. = "Costs [AUSPEX_BLOOD_COST_PER_TILE] blood per tile teleported."
	if(target_range)
		. += " up to [target_range] tiles away."
	else
		. += " anywhere you can see."
	if(level_current >= AUSPEX_BAT_LIFESTEAL_LEVEL)
		if(level_current >= AUSPEX_KNOCKDOWN_LEVEL)
			. += " This will cause people at your destination to start bleeding and fall asleep."
		else
			. += " This will cause people at your destination to start bleeding."

/datum/action/cooldown/bloodsucker/targeted/tremere/auspex/get_power_explanation_extended()
	. = list()
	. += "When Activated, you will be hidden in a Cloak of Darkness."
	. += "[target_range ? "Click to teleport up to [target_range] tiles away, as long as you can see it" : "You can teleport anywhere you can see"]."
	. += "Teleporting will refill your stamina to full."
	. += "At level [AUSPEX_BAT_LIFESTEAL_LEVEL] you will cause people at your end location to start bleeding."
	. += "At level [AUSPEX_KNOCKDOWN_LEVEL] you will cause people at your end location to be knocked down."
	. += "At level [AUSPEX_ANYWHERE_LEVEL] you will be able to teleport anywhere, even if you cannot properly see the tile."
	. += "The power will cost [AUSPEX_BLOOD_COST_PER_TILE] blood per tile that you teleport."

/datum/action/cooldown/bloodsucker/targeted/tremere/auspex/CheckValidTarget(atom/target_atom)
	. = ..()
	if(!.)
		return FALSE
	if(!isturf(target_atom))
		return FALSE
	var/turf/target_turf = target_atom
	if(target_turf.is_blocked_turf_ignore_climbable())
		return FALSE
	if(!(target_turf in view(owner.client.view, owner.client)))
		owner.balloon_alert(owner, "out of view!")
		return FALSE
	return TRUE

/datum/action/cooldown/bloodsucker/targeted/tremere/auspex/ActivatePower(trigger_flags)
	. = ..()
	if(trigger_flags & TRIGGER_SECONDARY_ACTION)
		owner.say("removing")
		cleanup_portals()
	if(charges <= 0)
		owner.balloon_alert(owner, "not enough charges!")
		return
	return TRUE

/datum/action/cooldown/bloodsucker/targeted/tremere/auspex/DeactivatePower(deactivate_flags)
	. = ..()
	if(!.)
		return FALSE

/datum/action/cooldown/bloodsucker/targeted/tremere/auspex/FireSecondaryTargetedPower(atom/target, params)
	var/mob/living/user = owner
	var/turf/targeted_turf = get_turf(target)
	if(level_current < AUSPEX_BAT_LEVEL)
		return
	if(!CheckValidTarget(target))
		return
	if(charges <= 0)
		user.balloon_alert(user, "out of charges!")
		return
	if(charges > 0)
		--charges
		spawn_bats(user, targeted_turf)
		start_charging()
	user.say("raghhh Im a fuken vampire raghhh")

/datum/action/cooldown/bloodsucker/targeted/tremere/auspex/proc/spawn_bats(mob/living/user, turf/targeted_turf)
	// do_tell()
	var/spawns = spawn_count
	var/blood_cost = 40
	if(!can_pay_blood(blood_cost))
		owner.balloon_alert(owner, "not enough blood!")
		return
	if(owner.stat >= HARD_CRIT)
		spawns = 1
	var/obj/effect/portal/blood_gate/gate = locate(/obj/effect/portal/blood_gate) in targeted_turf
	if(gate && gate.linked)
		targeted_turf = gate.get_link_target_turf()
	for(var/i in 1 to spawns)
		var/mob/living/basic/bat/bloodsucker/temp/summoned_minion = new(targeted_turf)
		// var/obj/effect/portal/teleport = new(target)
		summoned_minion.faction = list("[REF(owner)]")
		if(level_current >= AUSPEX_BAT_LIFESTEAL_LEVEL)
			summoned_minion.new_master = owner
	playsound(owner, 'sound/effects/magic/summon_karp.ogg', 60)
	playsound(targeted_turf, 'sound/effects/magic/summon_karp.ogg', 60)
	PowerActivatedSuccesfully(cost_override = blood_cost)

/datum/action/cooldown/bloodsucker/targeted/tremere/auspex/FireTargetedPower(atom/target, params)
	. = ..()
	var/mob/living/user = owner
	var/turf/targeted_turf = get_turf(target)
	if(!CheckValidTarget(target))
		return
	if(charges <= 0)
		user.balloon_alert(user, "out of charges!")
		return
	if(charges > 0)
		--charges
		if(spawn_gates(user, targeted_turf))
			playsound(user, 'sound/effects/magic/summon_karp.ogg', 60)
			playsound(targeted_turf, 'sound/effects/magic/summon_karp.ogg', 60)
			PowerActivatedSuccesfully()
		start_charging()
	user.say("IM GATINGGGGG")

/datum/action/cooldown/bloodsucker/targeted/tremere/auspex/proc/make_single_gate(turf/target_turf, obj/effect/portal/blood_gate/other_gate)
	var/obj/effect/portal/blood_gate/new_gate = new /obj/effect/portal/blood_gate(target_turf)
	if(other_gate)
		other_gate.link_portal(new_gate)
		new_gate.link_portal(other_gate)
	return WEAKREF(new_gate)

/datum/action/cooldown/bloodsucker/targeted/tremere/auspex/proc/spawn_gates(mob/living/user, turf/targeted_turf)
	var/obj/effect/portal/blood_gate/first_gate_resolved = first_gate?.resolve()
	var/obj/effect/portal/blood_gate/second_gate_resolved = second_gate?.resolve()
	if(!can_pay_blood(bloodcost))
		owner.balloon_alert(owner, "not enough blood!")
		return FALSE

	if(first_gate_resolved && second_gate_resolved)
		var/obj/effect/portal/blood_gate/new_gate = new /obj/effect/portal/blood_gate(targeted_turf)
		first_gate_resolved.close_gate()
		first_gate = WEAKREF(second_gate_resolved)
		second_gate = WEAKREF(new_gate)
		second_gate_resolved.link_portal(new_gate)
		new_gate.link_portal(second_gate_resolved)
		return

	if(!first_gate_resolved)
		first_gate = make_single_gate(targeted_turf, second_gate_resolved)
		return
	if(!second_gate_resolved)
		second_gate = make_single_gate(targeted_turf, first_gate_resolved)

	return TRUE

/datum/action/cooldown/bloodsucker/targeted/tremere/auspex/proc/auspex_blink(mob/living/user, turf/targeted_turf)
	var/blood_cost = AUSPEX_BLOOD_COST_PER_TILE * get_dist(user, targeted_turf)
	if(!can_pay_blood(blood_cost))
		owner.balloon_alert(owner, "not enough blood!")
		return
	playsound(user, 'sound/effects/magic/summon_karp.ogg', 60)
	playsound(targeted_turf, 'sound/effects/magic/summon_karp.ogg', 60)

	new /obj/effect/particle_effect/fluid/smoke/vampsmoke(user.drop_location())
	new /obj/effect/particle_effect/fluid/smoke/vampsmoke(targeted_turf)

	for(var/mob/living/carbon/living_mob in range(1, targeted_turf)-user)
		if(IS_BLOODSUCKER(living_mob) || IS_GHOUL(living_mob))
			continue
		if(level_current >= AUSPEX_BAT_LIFESTEAL_LEVEL)
			var/obj/item/bodypart/bodypart = pick(living_mob.bodyparts)
			bodypart.force_wound_upwards(/datum/wound/slash/flesh/critical)
			living_mob.adjustBruteLoss(15)
		if(level_current >= AUSPEX_KNOCKDOWN_LEVEL)
			living_mob.Knockdown(10 SECONDS, ignore_canstun = TRUE)

	do_teleport(owner, targeted_turf, no_effects = TRUE, channel = TELEPORT_CHANNEL_QUANTUM)
	user.adjustStaminaLoss(-user.staminaloss)
	PowerActivatedSuccesfully(cost_override = blood_cost)


//////////////////////////////////// BLOOD GATES PART////////////////////////////

/datum/status_effect/blood_gated
	id = "blood_gated"
	alert_type = /atom/movable/screen/alert/status_effect/freezing_blast
	duration = 2 SECONDS
	status_type = STATUS_EFFECT_REPLACE

/atom/movable/screen/alert/status_effect/blood_gated
	name = "Freezing Blast"
	desc = "You've been struck by a freezing blast! Your body moves more slowly!"
	icon_state = "frozen"

/datum/status_effect/blood_gated/on_apply()
	owner.add_movespeed_modifier(/datum/movespeed_modifier/blood_gated, update = TRUE)
	return ..()

/datum/status_effect/blood_gated/on_remove()
	owner.remove_movespeed_modifier(/datum/movespeed_modifier/blood_gated, update = TRUE)

/datum/movespeed_modifier/blood_gated
	multiplicative_slowdown = 2

/obj/effect/portal/blood_gate
	name = "Blood Gate"
	desc = "Looks unstable. Best to test it with the clown."
	icon = 'icons/mob/simple/lavaland/nest.dmi'
	icon_state = "nether"
	max_integrity = 100
	density = TRUE // dense for receiving bumps
	light_color = COLOR_RED_LIGHT
	hardlinked = FALSE
	uses_integrity = TRUE
	sparkless = TRUE
	wibbles = TRUE
	impact_sound = SFX_BULLET_IMPACT_GLASS
	resistance_flags = FIRE_PROOF | UNACIDABLE | ACID_PROOF
	var/faux_integrity = 100
	var/closing = FALSE //Is the gate shutting down?
	var/tryit = FALSE

/obj/effect/portal/blood_gate/proc/close_gate()
	var/turf/new_hard_target = get_turf(linked)
	hard_target = new_hard_target
	closing = TRUE
	alpha = 150
	QDEL_IN(src, 2 SECONDS)

/obj/effect/portal/blood_gate/proc/damage_gate(damage)
	faux_integrity -= damage
	if(faux_integrity <= 0)
		close_gate()

/obj/effect/portal/blood_gate/attackby(obj/item/W, mob/user, list/modifiers, list/attack_modifiers)
	. = ..()
	if(user && Adjacent(user))
		if(isliving(user))
			var/mob/living/living_user = user
			if(living_user.combat_mode)
				return FALSE
			else
				teleport(user)
				return TRUE
		else
			return TRUE

/obj/effect/portal/blood_gate/projectile_hit(obj/projectile/hitting_projectile, def_zone, piercing_hit, blocked)
	if(!istype(hitting_projectile, /obj/projectile/magic/arcane_barrage/bloodsucker))
		var/damage_to_gate = hitting_projectile.force
		damage_gate(damage_to_gate)
		return BULLET_ACT_HIT
	else
		if(tryit)
			hitting_projectile.forceMove(get_turf(linked))
			return BULLET_ACT_FORCE_PIERCE
		else
			return BULLET_ACT_HIT

/obj/effect/portal/blood_gate/teleport(atom/movable/moving, force = FALSE)
	if(!force && (!istype(moving) || iseffect(moving) || (ismecha(moving) && !mech_sized) || (!isobj(moving) && !ismob(moving)))) //Things that shouldn't teleport.
		return
	var/turf/real_target = get_link_target_turf()
	if(!istype(real_target))
		return FALSE

	if(!force && (!ismecha(moving) && !isprojectile(moving) && moving.anchored && !allow_anchored))
		return
	var/turf/start_turf = get_turf(moving)
	if(do_teleport(moving, real_target, innate_accuracy_penalty, channel = teleport_channel, forced = force_teleport))
		if(closing && isliving(moving))
			var/mob/living/crunchedmob = moving
			crunchedmob.adjustBruteLoss(30)
			playsound(crunchedmob, 'sound/effects/magic/demon_attack1.ogg', 50, TRUE, -1)

		if(iscarbon(moving))
			var/mob/living/carbon/our_mob = moving
			playsound(real_target, 'sound/effects/magic/exit_blood.ogg', 50, TRUE, -1)
			if(!IS_BLOODSUCKER(our_mob))
				our_mob.add_atom_colour(COLOR_BUBBLEGUM_RED, TEMPORARY_COLOUR_PRIORITY)
				addtimer(CALLBACK(our_mob, TYPE_PROC_REF(/atom/, remove_atom_colour), TEMPORARY_COLOUR_PRIORITY, COLOR_BUBBLEGUM_RED), 6 SECONDS)
				our_mob.apply_status_effect(/datum/status_effect/blood_gated)

		new /obj/effect/temp_visual/portal_animation(start_turf, src, moving)
		playsound(start_turf, SFX_PORTAL_ENTER, 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
		playsound(real_target, SFX_PORTAL_ENTER, 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
		return TRUE
	return FALSE
//////////////////////////////////// BATS ////////////////////////////////////

/mob/living/basic/bat/bloodsucker/temp
	maxHealth = 30
	health = 30
	basic_mob_flags = DEL_ON_DEATH
	melee_damage_lower = 8
	melee_damage_upper = 8
	sharpness = SHARP_EDGED
	var/lifespan = 30 SECONDS
	var/new_master
	var/datum/weakref/vampiric_master

/mob/living/basic/bat/bloodsucker/temp/Initialize(mapload, new_master)
	. = ..()
	if(new_master)
		vampiric_master = WEAKREF(new_master)
	addtimer(CALLBACK(src, PROC_REF(death)), lifespan)


/mob/living/basic/bat/bloodsucker/temp/melee_attack(atom/target, list/modifiers, ignore_cooldown)
	. = ..()
	if(!isliving(target))
		return

	if(isliving(new_master))
		var/mob/living/my_master = new_master
		for(my_master in orange(7, src))
			my_master.adjustBruteLoss(-2)
			my_master.adjustFireLoss(-1.5)

#undef AUSPEX_BLOOD_COST_PER_TILE
#undef AUSPEX_BAT_LIFESTEAL_LEVEL
#undef AUSPEX_KNOCKDOWN_LEVEL
#undef AUSPEX_ANYWHERE_LEVEL
