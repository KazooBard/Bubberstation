
/**
 * # Status effect
 *
 * This is the status effect that Tremeres give to cause extra bleed
 * Deals with everything we need
 */

/datum/status_effect/stacking/hemocatalysis
	id = "hemocatalysis"
	tick_interval = 2 SECONDS
	delay_before_decay = 10
	max_stacks = 20
	stack_threshold = 10
	consumed_on_threshold = FALSE
	overlay_file = 'icons/effects/bleed.dmi'
	overlay_state = "bleed"

/datum/status_effect/stacking/hemocatalysis/on_apply()
	if(!ishuman(owner))
		return FALSE
	owner.apply_status_effect(/datum/status_effect/hemocatalysis_fake_bleed)
	var/turf/owner_turf = get_turf(owner)
	new /obj/effect/decal/cleanable/blood/tremere(owner_turf)
	return TRUE

/datum/status_effect/stacking/hemocatalysis/fadeout_effect()
	new /obj/effect/temp_visual/bleed(get_turf(owner))

	var/datum/status_effect/hemocatalysis_fake_bleed/fake_bleed = owner.has_status_effect(/datum/status_effect/hemocatalysis_fake_bleed)
	if(fake_bleed)
		qdel(fake_bleed)

/datum/status_effect/stacking/hemocatalysis/threshold_cross_effect()
	for(var/splatter_dir in GLOB.alldirs)
		owner.create_splatter(splatter_dir)
	playsound(owner, SFX_DESECRATION, 100, TRUE, -1)



/datum/status_effect/hemocatalysis_fake_bleed
	id = "hemocatalysis_fake"
	status_type = STATUS_EFFECT_UNIQUE
	alert_type = null
	duration = STATUS_EFFECT_PERMANENT

/datum/status_effect/hemocatalysis_fake_bleed/on_apply()
	if(!ishuman(owner))
		return FALSE
	var/datum/status_effect/stacking/hemocatalysis/our_hemo = owner.has_status_effect(/datum/status_effect/stacking/hemocatalysis)
	if(our_hemo)
		if(our_hemo.stacks == 0)
			return FALSE
	return TRUE

/datum/status_effect/hemocatalysis_fake_bleed/tick(seconds_between_ticks)
	if(iscarbon(owner))
		var/mob/living/carbon/bleeder = owner
		if(bleeder.blood_volume <= 224 || bleeder.stat == DEAD) //prevent infinite monkey bloodtile farms
			qdel(src)
			return
	var/datum/status_effect/stacking/hemocatalysis/our_hemo = owner.has_status_effect(/datum/status_effect/stacking/hemocatalysis)
	if(!our_hemo)
		qdel(src)
		return

	if(our_hemo)
		if(our_hemo.stacks == 0)
			qdel(src)
			return
		// if(prob(our_hemo.stacks * 10))
		if(prob(60))
			var/turf/blood_turf = get_turf(owner)
			new /obj/effect/decal/cleanable/blood/tremere(blood_turf)
			return
