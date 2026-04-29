//RS FILE
/obj/component_adder	//This base type doesn't do anything!
	name = "component adder"
	desc = "You shouldn't see this."
	icon = 'icons/rogue-star/component_adder.dmi'
	icon_state = "adder"
	plane = PLANE_ADMIN_SECRET
	color = "#1ae200"
	var/component_type
	var/id = "REPLACE ME"
	var/list/valid_types = list()
	var/static/list/overlays_cache = list()

/obj/component_adder/New(loc, new_id)
	. = ..()
	if(new_id)
		id = new_id

/obj/component_adder/Initialize(mapload)
	. = ..()
	seek_valid_target()
	qdel(src)

/obj/component_adder/proc/seek_valid_target()
	if(!component_type)
		return
	var/turf/T = get_turf(src)
	for(var/atom/thing in T.contents)
		if(thing == src)
			continue
		for(var/type_check in valid_types)
			if(istype(thing,type_check))
				var/overlay_state = consider_overlay_state(thing)
				if(!special_check(thing))
					add_component(thing)
				do_overlay(thing,overlay_state)

/obj/component_adder/proc/add_component(var/atom/target)
	if(!target)
		return
	. = target.LoadComponent(component_type,id)

/obj/component_adder/proc/do_overlay(var/atom/target,var/overlay_state)
	if(!target)
		return
	if(!overlay_state)
		overlay_state = "[icon_state]_s"
	var/key = "[overlay_state]-[color]"
	var/image/overlay = overlays_cache[key]
	if(!overlay)
		overlay = image(icon,null,overlay_state)
		overlay.color = color
		overlay.plane = PLANE_ADMIN_SECRET
		overlay.appearance_flags = RESET_COLOR|KEEP_APART|PIXEL_SCALE
		overlays_cache[key] = overlay
	target.add_overlay(overlay)

/obj/component_adder/proc/consider_overlay_state(var/atom/consider)
	return null

/obj/component_adder/proc/special_check(var/atom/consider)
	return FALSE

/obj/component_adder/lock
	name = "lock component"
	icon_state = "lock"
	component_type = /datum/component/dungeon_mechanic/lock
	valid_types = list(
		/obj/item/key,
		/obj/machinery/door/airlock,
		/obj/structure/simple_door,
		/obj/dungeon_obstacle,
		/obj/machinery/door/blast,
		/obj/dungeon_switch
	)

/obj/component_adder/lock/consider_overlay_state(var/atom/consider)
	if(istype(consider,/obj/item/key))
		return "key"
	return null

/obj/component_adder/lock/special_check(var/atom/consider)
	if(istype(consider,/obj/item/key))
		var/obj/item/key/K = consider
		K.lock_id = id
		return TRUE
	return FALSE

/obj/component_adder/trigger
	name = "trigger component"
	icon_state = "trigger"
	component_type = /datum/component/dungeon_mechanic/trigger
	valid_types = list(
		/obj/dungeon_obstacle,
		/obj/dungeon_switch,
		/obj/machinery/door/airlock,
		/obj/structure/simple_door,
		/obj/machinery/door/blast
	)
	var/onetime = FALSE

/obj/component_adder/trigger/add_component()
	var/datum/component/dungeon_mechanic/trigger/T = ..()
	T.onetime = onetime

/obj/component_adder/link
	name = "link component"
	icon_state = "link"
	component_type = /datum/component/dungeon_mechanic/link
	valid_types = list(
		/obj/machinery/door/airlock,
		/obj/structure/simple_door,
		/obj/dungeon_obstacle,
		/obj/machinery/door/blast,
		/obj/dungeon_switch
	)
