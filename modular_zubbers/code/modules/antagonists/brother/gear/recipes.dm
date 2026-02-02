/datum/bb_gear/granter/summon(mob/living/summoner, datum/team/brother_team/team)
	var/obj/item/book/granter/granter = new spawn_path
	granter.uses = length(team.members)
	podspawn(list(
		"target" = get_turf(summoner),
		"style" = /datum/pod_style/syndicate,
		"spawn" = granter
	))

/datum/bb_gear/granter/trash_cannon
	name = "Recipe: Trash Cannon"
	desc = "Contains a recipe book, allowing you to learn the knowledge to build a trash cannon."
	spawn_path = /obj/item/book/granter/crafting_recipe/trash_cannon
	preview_path = /obj/structure/cannon/trash

/datum/bb_gear/granter/pipegun
	name = "Recipe: Regal Pipegun"
	desc = "Contains a recipe book, allowing you to learn the knowledge to build a regal pipegun."
	spawn_path = /obj/item/book/granter/crafting_recipe/pipegun_prime
	preview_path = /obj/item/gun/ballistic/rifle/boltaction/pipegun/prime

/datum/bb_gear/granter/laser
	name = "Recipe: Heroic Laser Musket"
	desc = "Contains a recipe book, allowing you to learn the knowledge to build a heroic laser musket."
	spawn_path = /obj/item/book/granter/crafting_recipe/laser_musket_prime
	preview_path = /obj/item/gun/energy/laser/musket/prime

/datum/bb_gear/granter/death_sandwich
	name = "Recipe: Death Sandwich"
	desc = "Contains a recipe book, allowing you to learn the knowledge to build a death sandwich."
	spawn_path = /obj/item/book/granter/crafting_recipe/death_sandwich
	preview_path = /obj/item/food/sandwich/death

