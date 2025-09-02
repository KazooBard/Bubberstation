
/**
 * # Status effect
 *
 * This is the status effect that Tremeres give to cause extra bleed
 * Deals with everything we need
 */

/atom/movable/screen/alert/status_effect/hemocatalysis
	name = "Hemocatalysis"
	desc = "Blood magicks are causing you to spill more of your blood than normally"
	icon = 'modular_zubbers/icons/mob/actions/bloodsucker.dmi'
	icon_state = "power_recover"
	alerttooltipstyle = "cult"

/datum/status_effect/hemocatalysis
	id = "Hemocatalysis"
	status_type = STATUS_EFFECT_MULTIPLE
	duration = 10
	alert_type = /atom/movable/screen/alert/status_effect/hemocatalysis
	///Boolean on whether they were an AdvancedToolUser, to give the trait back upon exiting.
	var/was_tooluser = FALSE

/datum/status_effect/hemocatalysis/on_apply()


/datum/status_effect/hemocatalysis/on_remove()


/datum/status_effect/hemocatalysis/tick()
	var/mob/living/carbon/human/user = owner
	// If duration is not -1, that means we're about to loose frenzy, let's give them some safe time.
