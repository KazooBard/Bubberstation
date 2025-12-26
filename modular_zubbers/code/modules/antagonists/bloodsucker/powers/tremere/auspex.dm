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
	var/datum/weakref/ourgate
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
		portals -= ref
		qdel(ref)

/datum/action/cooldown/bloodsucker/targeted/tremere/auspex/proc/get_max_charges()
	if(level_current <= 2)
		return 2
	else
		return 4

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
	if(charges <= 0)
		owner.balloon_alert(owner, "not enough charges!")
		return
	if(trigger_flags & TRIGGER_SECONDARY_ACTION)
		cleanup_portals()
	return TRUE

/datum/action/cooldown/bloodsucker/targeted/tremere/auspex/DeactivatePower(deactivate_flags)
	. = ..()
	if(!.)
		return FALSE

/datum/action/cooldown/bloodsucker/targeted/tremere/auspex/FireSecondaryTargetedPower(atom/target, params)
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
		SpawnBats(user, targeted_turf)
		start_charging()
	user.say("raghhh Im a fuken vampire raghhh")

/datum/action/cooldown/bloodsucker/targeted/tremere/auspex/proc/SpawnBats(mob/living/user, turf/targeted_turf)
	// do_tell()
	var/spawns = spawn_count
	var/blood_cost = 40
	if(!can_pay_blood(blood_cost))
		owner.balloon_alert(owner, "not enough blood!")
		return
	if(owner.stat >= HARD_CRIT)
		spawns = 1
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
		if(SpawnGates(user, targeted_turf))
			playsound(user, 'sound/effects/magic/summon_karp.ogg', 60)
			playsound(targeted_turf, 'sound/effects/magic/summon_karp.ogg', 60)
			PowerActivatedSuccesfully()
		start_charging()
	user.say("IM GATINGGGGG")

/datum/action/cooldown/bloodsucker/targeted/tremere/auspex/proc/SpawnGates(mob/living/user, turf/targeted_turf)
	if(!can_pay_blood(bloodcost))
		owner.balloon_alert(owner, "not enough blood!")
		return FALSE

	user.say("aaaa")
	var/obj/effect/portal/blood_gate/unlinkedgate = ourgate?.resolve()

	if(length(portals) >= max_portals)
		portals -= portals[1]
		qdel(portals[1])
		user.say("lenght > max_portals")

	if(isnull(unlinkedgate))
		unlinkedgate = new(targeted_turf)
		ourgate = WEAKREF(unlinkedgate)
		portals += WEAKREF(unlinkedgate)
		user.say("unlinkedgate is null")
		return TRUE

	if(!length(portals))
		user.say("no lenght to portals")
		return FALSE

	var/obj/effect/portal/blood_gate/oursecondgate = new /obj/effect/portal/blood_gate(targeted_turf)
	user.say("made new")
	oursecondgate.link_portal(unlinkedgate)
	unlinkedgate.link_portal(oursecondgate)
	portals += WEAKREF(unlinkedgate)
	unlinkedgate = null

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
	wibbles = TRUE
	impact_sound = SFX_BULLET_IMPACT_GLASS
	resistance_flags = FIRE_PROOF | UNACIDABLE | ACID_PROOF



/obj/effect/portal/blood_gate/teleport(atom/movable/moving, force = FALSE)
	if(!force && (!istype(moving) || iseffect(moving) || (ismecha(moving) && !mech_sized) || (!isobj(moving) && !ismob(moving)))) //Things that shouldn't teleport.
		return
	var/turf/real_target = get_link_target_turf()
	if(!istype(real_target))
		return FALSE

	if(!force && (!ismecha(moving) && moving.anchored && !allow_anchored))
		return
	var/no_effect = FALSE
	if(last_effect == world.time || sparkless)
		no_effect = TRUE
	else
		last_effect = world.time
	var/turf/start_turf = get_turf(moving)
	if(do_teleport(moving, real_target, innate_accuracy_penalty, no_effects = no_effect, channel = teleport_channel, forced = force_teleport))
		if(isprojectile(moving))
			var/obj/projectile/proj = moving
			proj.ignore_source_check = TRUE
		if(iscarbon(moving))
			var/mob/living/carbon/our_mob = moving
			playsound(real_target, 'sound/effects/magic/exit_blood.ogg', 50, TRUE, -1)
			if(!IS_BLOODSUCKER(our_mob))
				our_mob.add_atom_colour(COLOR_BUBBLEGUM_RED, TEMPORARY_COLOUR_PRIORITY)
				addtimer(CALLBACK(our_mob, TYPE_PROC_REF(/atom/, remove_atom_colour), TEMPORARY_COLOUR_PRIORITY, COLOR_BUBBLEGUM_RED), 6 SECONDS)

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
	melee_damage_lower = 10
	melee_damage_upper = 10
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
