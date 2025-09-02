/datum/action/cooldown/bloodsucker/blood_weapon
	name = "Manifest Blood Weapon"
	desc = "Withstand egregious physical wounds and walk away from attacks that would stun, pierce, and dismember lesser beings, but will render you unable to heal."
	active_background_icon_state = "tremere_power_on"
	base_background_icon_state = "tremere_power_off"
	button_icon = 'modular_zubbers/icons/mob/actions/tremere_bloodsucker.dmi'
	background_icon = 'modular_zubbers/icons/mob/actions/tremere_bloodsucker.dmi'

	level_current = 1
	// Targeted stuff

	power_flags = BP_CONTINUOUS_EFFECT
	check_flags = BP_CANT_USE_IN_TORPOR|BP_CANT_USE_IN_FRENZY
	purchase_flags = TREMERE_CAN_BUY
	cooldown_time = 5 SECONDS
	bloodcost = 30
	var/list/availible_weapons = list()
	var/current_weapon
	var/turning_off

/datum/action/cooldown/bloodsucker/blood_weapon/get_power_explanation_extended()
	. = list()
	. += "Manifest blood weapon allows you to create powerful tools out of your own blood."
	. += "Your arsenal of blood weapons expands as you upgrade this ability. All of them apply stacks of Hemocatalysis"
	. += "Blood daggers are about as potent as a meat cleaver, and in addition apply hemocatalysis on throw."
	. += "The Javelin has more reach than the daggers do, absorbing blood as it flies to boost it's damage on hit."
	. += "The Zweihander deals potent damage, it's attacks cleave - striking adjacent targets for half the damage."

/datum/action/cooldown/bloodsucker/blood_weapon/proc/get_weapons_list()
	to_chat(world, "DEBUG: level_current is [level_current]")
	availible_weapons["Bloody Dagger"] = image(icon = 'icons/obj/weapons/spear.dmi', icon_state = "occultpoleaxe0")
	if(level_current >= 2)
		availible_weapons["Blood Javelin"] = image(icon = 'icons/obj/weapons/spear.dmi', icon_state = "occultjavelin0")
		to_chat(world, "DEBUG: spells list is [availible_weapons]")
	return

/datum/action/cooldown/bloodsucker/blood_weapon/ActivatePower()
	get_weapons_list()
	var/list/spells = availible_weapons
	var/mob/living/carbon/human/caster = owner
	to_chat(caster, "1")
	if(!current_weapon)
		current_weapon = show_radial_menu(
		caster,
		caster,
		spells,
		custom_check = CALLBACK(src, PROC_REF(check_menu)),
		require_near = TRUE,
		tooltips = TRUE,
		)
		turning_off = FALSE
		var/turf/current_position = get_turf(caster)
		switch(current_weapon)
			if("Bloody Dagger")
				var/obj/item/melee/bloodsucker/dagger/summon = new(current_position)
				current_weapon = summon
				if(caster.put_in_hands(summon))
					to_chat(caster, span_cult_italic("A [summon.name] appears in your hand!"))
				else
					caster.visible_message(span_warning("A [summon.name] appears at [caster]'s feet!"), \
						span_cult_italic("A [summon.name] materializes at your feet."))

			if("Blood Javelin")
				var/obj/item/melee/bloodsucker/javelin/summon = new(current_position)
				current_weapon = summon
				if(caster.put_in_hands(summon))
					to_chat(caster, span_cult_italic("A [summon.name] appears in your hand!"))
				else
					caster.visible_message(span_warning("A [summon.name] appears at [caster]'s feet!"), \
						span_cult_italic("A [summon.name] materializes at your feet."))
	else
		turning_off = TRUE

/datum/action/cooldown/bloodsucker/blood_weapon/DeactivatePower(deactivate_flags)
	if(current_weapon && turning_off)
		var/turf/flavour_spill = get_turf(current_weapon)
		new /obj/effect/decal/cleanable/blood(flavour_spill)
		qdel(current_weapon)
		to_chat(owner, span_cult_italic("You dispel your blood weapon into a puddle!"))
		turning_off = FALSE

	return ..()

/datum/action/cooldown/bloodsucker/blood_weapon/proc/check_menu()
	if(QDELETED(src))
		return FALSE
	if(!IS_BLOODSUCKER(owner))
		return FALSE
	return TRUE
