// Regular sprites

/datum/robot_sprite/combat
	module_type = "Combat"
	sprite_icon = 'icons/mob/robot/combat.dmi'

/datum/robot_sprite/combat/default
	name = DEFAULT_ROBOT_SPRITE_NAME
	default_sprite = TRUE
	sprite_icon_state = "default"

/datum/robot_sprite/combat/marina
	name = "Haruka"
	sprite_icon_state = "marina"
	sprite_flags = ROBOT_HAS_SHIELD_SPRITE | ROBOT_HAS_SPEED_SPRITE //RS EDIT

/datum/robot_sprite/combat/droid
	name = "Android"
	sprite_icon_state = "droid"
	sprite_flags = ROBOT_HAS_SHIELD_SPRITE | ROBOT_HAS_SPEED_SPRITE //RS EDIT

/datum/robot_sprite/combat/droid/get_eyes_overlay(var/mob/living/silicon/robot/ourborg)
	if(ourborg.has_active_type(/obj/item/borg/combat/mobility)) //RS Edit
		return
	else
		return ..()

/datum/robot_sprite/combat/insekt
	name = "Insekt"
	sprite_icon_state = "insekt"
	sprite_flags = ROBOT_HAS_SHIELD_SPRITE //RS EDIT

/datum/robot_sprite/combat/decapod
	name = "Decapod"
	sprite_icon_state = "decapod"
	has_custom_open_sprites = TRUE
	sprite_flags = ROBOT_HAS_SHIELD_SPRITE //RS EDIT

/datum/robot_sprite/combat/mechoid
	name = "Acheron"
	sprite_icon_state = "mechoid"
	sprite_flags = ROBOT_HAS_SHIELD_SPRITE | ROBOT_HAS_SPEED_SPRITE //RS EDIT

/datum/robot_sprite/combat/zoomba
	name = "ZOOM-BA"
	sprite_icon_state = "zoomba"
	has_dead_sprite = TRUE
	sprite_flags = ROBOT_HAS_SHIELD_SPRITE | ROBOT_HAS_SPEED_SPRITE //RS EDIT

/datum/robot_sprite/combat/worm
	name = "W02M"
	sprite_icon_state = "worm"
	has_custom_open_sprites = TRUE
	sprite_flags = ROBOT_HAS_SHIELD_SPRITE //RS EDIT

/datum/robot_sprite/combat/uptall
	name = "Feminine Humanoid"
	sprite_icon_state = "uptall"

// Wide/dogborg sprites
/*
/datum/robot_sprite/dogborg/combat
	module_type = "Combat"
	sprite_icon = 'icons/mob/robot/combat_wide.dmi'

		// None yet
*/
// Tall sprites

/datum/robot_sprite/dogborg/tall/combat
	module_type = "Combat"
	sprite_icon = 'icons/mob/robot/combat_large.dmi'
	has_custom_equipment_sprites = TRUE

/datum/robot_sprite/dogborg/tall/combat/do_equipment_glamour(var/obj/item/weapon/robot_module/module)
	if(!has_custom_equipment_sprites)
		return

	..()

	var/obj/item/weapon/melee/robotic/dagger/CBB = locate() in module.modules
	if(CBB)
		CBB.name = "sword tail"
		CBB.icon_state = "swordtail"
		CBB.desc = "A glowing dagger normally attached to the end of a cyborg's tail. It appears to be extremely sharp."

	var/obj/item/weapon/melee/robotic/borg_combat_shocker/BCS = locate() in module.modules
	if(BCS)
		BCS.name = "combat jaws"
		BCS.desc = "Shockingly chompy!"
		BCS.icon_state = "ertjaws"
		BCS.hitsound = 'sound/weapons/bite.ogg'
		BCS.attack_verb = list("chomped", "bit", "ripped", "mauled", "enforced")
		BCS.dogborg = TRUE

	var/obj/item/device/dogborg/sleeper/K9/ert/DE = locate() in module.modules
	if(DE)
		DE.icon_state = "sleeperert"

/datum/robot_sprite/dogborg/tall/combat/derg
	name = "ERT Dragon"
	sprite_icon_state = "derg"
	sprite_hud_icon_state = "ert"
	rest_sprite_options = list("Default", "Sit")
	sprite_flags = ROBOT_HAS_GUN_SPRITE | ROBOT_HAS_SHIELD_SPRITE //RS Edit
/datum/robot_sprite/dogborg/tall/combat/derg/handle_extra_icon_updates(var/mob/living/silicon/robot/ourborg)
    ..()
    if(ourborg.has_active_type(/obj/item/borg/combat/mobility))
        ourborg.add_overlay("[sprite_icon_state]-roll")

/datum/robot_sprite/dogborg/tall/combat/derg/get_eyes_overlay(var/mob/living/silicon/robot/ourborg)
	if(ourborg.has_active_type(/obj/item/borg/combat/mobility)) //RS Edit
		return
	else
		return ..()

/datum/robot_sprite/dogborg/tall/combat/hound
	name = "Hound"
	sprite_icon_state = "hound"
	sprite_hud_icon_state = "ert"
	rest_sprite_options = list("Default")

/datum/robot_sprite/dogborg/tall/combat/borgi
	name = "Borgi"
	sprite_icon_state = "borgi"
	sprite_hud_icon_state = "ert"
	rest_sprite_options = list("Default")
	has_eye_sprites = FALSE
	has_eye_light_sprites = TRUE

/datum/robot_sprite/dogborg/tall/combat/raptor
	name = "Raptor V-4"
	sprite_icon_state = "raptor"
	sprite_hud_icon_state = "ert"
	rest_sprite_options = list("Default", "Bellyup")
	sprite_flags = ROBOT_HAS_GUN_SPRITE | ROBOT_HAS_SHIELD_SPRITE | ROBOT_HAS_SPEED_SPRITE //RS Edit
	has_eye_light_sprites = TRUE

/datum/robot_sprite/dogborg/tall/combat/raptor/get_eyes_overlay(var/mob/living/silicon/robot/ourborg)
	if(ourborg.has_active_type(/obj/item/borg/combat/mobility)) //RS Edit
		return
	else
		return ..()
/datum/robot_sprite/dogborg/tall/combat/raptor/get_eye_light_overlay(var/mob/living/silicon/robot/ourborg)
	if(ourborg.has_active_type(/obj/item/borg/combat/mobility)) //RS Edit
		return
	else
		return ..()
/datum/robot_sprite/dogborg/tall/combat/raptor/get_belly_overlay(var/mob/living/silicon/robot/ourborg)
	if(ourborg.has_active_type(/obj/item/borg/combat/mobility)) //RS Edit
		return
	else
		return ..()
