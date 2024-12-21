
/datum/antagonist
	var/antag_panel_title = "Antagonist Panel"
	var/antag_panel_description = "This is the antagonist panel. It contains all the abilities you have access to as an antagonist. Use them wisely."

/datum/antagonist/proc/ability_ui_data(actions = list())
	var/list/data = list()
	data["title"] = "[antag_panel_title]\n[antag_panel_data()]"
	data["description"] = antag_panel_description
	for(var/datum/action/cooldown/power as anything in actions)
		var/list/power_data = list()

		power_data["power_name"] = power.name
		power_data["power_icon"] = power.button_icon_state
		var/extra_desc = power.get_action_explanation()
		if(extra_desc)
			power_data["power_explanation"] = extra_desc

		data["powers"] += list(power_data)
	return data

/// A further detailed description of the action, used in the antagonist panel.
/datum/action/cooldown/proc/get_action_explanation()
	return null
