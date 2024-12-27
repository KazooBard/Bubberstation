/datum/actionspeed_modifier/bloodsucker_1
	multiplicative_slowdown = -0.1

/datum/actionspeed_modifier/bloodsucker_2
	multiplicative_slowdown = -0.15

/datum/actionspeed_modifier/bloodsucker_3
	multiplicative_slowdown = -0.2

/datum/actionspeed_modifier/bloodsucker_4
	multiplicative_slowdown = -0.25

/datum/bloodsucker_upgrade/brujah/mobility
	name = "mobility"
	var/level_stamina_mod
	var/starting_stamina

/datum/bloodsucker_upgrade/brujah/mobility/on_gain(mob/living/carbon/human/user, datum/antagonist/bloodsucker/owner_datum)
	starting_stamina = user.physiology.stamina_mod
	level_stamina_mod= min(1 - (0.05 * level_current)) // 10% dmr per level
	user.physiology.stamina_mod = level_stamina_mod
	if(level_current >= 1)
		user.add_actionspeed_modifier(/datum/actionspeed_modifier/bloodsucker_1)
	if(level_current >= 2)
		user.add_actionspeed_modifier(/datum/actionspeed_modifier/bloodsucker_1)
		user.add_actionspeed_modifier(/datum/actionspeed_modifier/bloodsucker_2)
		if(user == owner_datum.owner.current) //if they're a bloodsucker, give them the power
			owner_datum.BuyPower()
	if(level_current >= 3)
		user.add_actionspeed_modifier(/datum/actionspeed_modifier/bloodsucker_1)
		user.add_actionspeed_modifier(/datum/actionspeed_modifier/bloodsucker_2)
		user.add_actionspeed_modifier(/datum/actionspeed_modifier/bloodsucker_3)
	if(level_current >= 4)
		user.add_actionspeed_modifier(/datum/actionspeed_modifier/bloodsucker_1)
		user.add_actionspeed_modifier(/datum/actionspeed_modifier/bloodsucker_2)
		user.add_actionspeed_modifier(/datum/actionspeed_modifier/bloodsucker_3)
		user.add_actionspeed_modifier(/datum/actionspeed_modifier/bloodsucker_4)

/datum/bloodsucker_upgrade/brujah/mobility/on_loss(mob/living/carbon/human/user)
	user.physiology.stamina_mod = starting_stamina
	user.remove_actionspeed_modifier(/datum/actionspeed_modifier/bloodsucker_1)
	user.remove_actionspeed_modifier(/datum/actionspeed_modifier/bloodsucker_2)
	user.remove_actionspeed_modifier(/datum/actionspeed_modifier/bloodsucker_3)
	user.remove_actionspeed_modifier(/datum/actionspeed_modifier/bloodsucker_4)
	. = ..()

