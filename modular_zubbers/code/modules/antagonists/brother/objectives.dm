/datum/objective/supermatter_sabotage
	name = "Corrupt the supermatter crystal with a provided "
	description = "Sabotage the supermatter with the propagandium shard. Go to %AREA% to retrieve the subversive crystal \
		and use it on the supermatter."

	///area type the objective owner must be in to receive the destabilizing crystal
	var/area/dest_crystal_area_pickup
	///checker on whether we have sent the crystal yet.
	var/sent_crystal = FALSE

/datum/objective/supermatter_sabotage/can_generate_objective(generating_for, list/possible_duplicates)
	. = ..()
	if(!.)
		return FALSE

	if(isnull(GLOB.main_supermatter_engine))
		return FALSE
	var/obj/machinery/power/supermatter_crystal/engine/crystal = locate() in GLOB.main_supermatter_engine
	if(!is_station_level(crystal.z) && !is_mining_level(crystal.z))
		return FALSE

	return TRUE

/datum/objective/supermatter_sabotage/generate_objective(datum/mind/generating_for, list/possible_duplicates)
	var/list/possible_areas = GLOB.the_station_areas.Copy()
	for(var/area/possible_area as anything in possible_areas)
		//remove areas too close to the destination, too obvious for our poor shmuck, or just unfair
		if(ispath(possible_area, /area/station/hallway) || ispath(possible_area, /area/station/security))
			possible_areas -= possible_area
	if(length(possible_areas) == 0)
		return FALSE
	dest_crystal_area_pickup = pick(possible_areas)
	replace_in_name("%AREA%", initial(dest_crystal_area_pickup.name))
	return TRUE

/datum/objective/supermatter_sabotage/generate_ui_buttons(mob/user)
	var/list/buttons = list()
	if(!sent_crystal)
		buttons += add_ui_button("", "Pressing this will call down a pod with the supermatter cascade kit.", "biohazard", "destabilizing_crystal")
	return buttons

/datum/objective/supermatter_sabotageui_perform_action(mob/living/user, action)
	. = ..()
	switch(action)
		if("destabilizing_crystal")
			if(sent_crystal)
				return
			var/area/delivery_area = get_area(user)
			if(delivery_area.type != dest_crystal_area_pickup)
				to_chat(user, span_warning("You must be in [initial(dest_crystal_area_pickup.name)] to receive the supermatter cascade kit."))
				return
			sent_crystal = TRUE
			podspawn(list(
				"target" = get_turf(user),
				"style" = /datum/pod_style/syndicate,
				"spawn" = /obj/item/cascade_emitter_kit,
			))

// /datum/team/brother_team/forge_brother_objectives()
// 	objectives = list()

// 	add_objective(new /datum/objective/convert_brother)

// 	var/is_hijacker = prob(10)
// 	for(var/i = 1 to max(1, CONFIG_GET(number/brother_objectives_amount) + (brothers_left > 2) - is_hijacker))
// 		forge_single_objective()
// 	if(is_hijacker)
// 		if(!locate(/datum/objective/hijack) in objectives)
// 			add_objective(new /datum/objective/hijack)
// 	else if(!locate(/datum/objective/escape) in objectives)
// 		add_objective(new /datum/objective/escape)

// /datum/team/brother_team/proc/forge_single_objective()
// 	if(prob(50))
// 		if(LAZYLEN(active_ais()) && prob(100/GLOB.joined_player_list.len))
// 			add_objective(new /datum/objective/destroy, needs_target = TRUE)
// 		else if(prob(30))
// 			add_objective(new /datum/objective/maroon, needs_target = TRUE)
// 		else
// 			add_objective(new /datum/objective/assassinate, needs_target = TRUE)
// 	else
// 		add_objective(new /datum/objective/steal, needs_target = TRUE)

// /datum/objective/convert_brother
// 	explanation_text = "Convert a brainwashable person using your Blood Bonds ability."

