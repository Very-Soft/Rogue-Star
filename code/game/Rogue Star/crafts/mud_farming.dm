//RS FILE
/turf/proc/reagent_interact(var/reagent_id, var/amount)
	return

/turf/simulated/floor
//	var/mushroom_init = TRUE			//If we will attempt to spore or mushroom a turf on init
	var/mushroom_capacity = 0			//How many mushrooms can grow here
	var/shrooming = 0					//Progress toward generating a new mushroom
	var/shroom_hospitality = 0			//How quickly will the mushrooms grow here
	var/spored = FALSE					//Mushrooms will only grow on turfs with some spores!

/turf/simulated/floor/outdoors/Initialize(mapload)
	. = ..()
	if(!mapload)
		return
	if(shroom_hospitality)
		var/chance_time = rand(1,20)
		if(chance_time > 10)
			spored = TRUE
		if(chance_time == 20)
			var/obj/structure/flora/mushroom/grower/M = shroom()
			M.full_grow()

/turf/simulated/floor/outdoors/reagent_interact(reagent_id, amount)
	if(!reagent_id || !amount)
		return FALSE

	if(reagent_id == "water")
		water(amount, list(src))

/turf/simulated/floor/outdoors/wet_floor(wet_val)
	if(wet_val == 3)
		return ..()
	if(water_saturation <= 0)
		return ..()

/turf/simulated/floor/proc/begin_shrooming()
	if(mushroom_capacity <= 0 || shroom_hospitality <= 0 || !spored)
		return
	START_PROCESSING(SSturfs, src)

/turf/simulated/floor/outdoors/process()
	return mushroom_update()

/turf/simulated/floor/outdoors/water_update()
	. = ..()
	if(water >= 50)
		begin_shrooming()

/turf/simulated/floor/outdoors/mushroom_update()
	if(water < 50)
		STOP_PROCESSING(SSturfs, src)
		return
	if(contents.len >= mushroom_capacity)	//I don't really want to iterate through a potentially huge list to check for exactly how many mushrooms there are every tick, we'll just use the contents len, it will be close enough.
		return
	var/howbright = get_lumcount()
	if(howbright > 0.3)
		water --
		return
	var/grow_rate = 0.5
	if(howbright >= 0.2)
		grow_rate = 0.5
	else if(howbright >= 0.1)
		grow_rate = 1
	else if(howbright < 0.1)
		grow_rate = 2
	shrooming += grow_rate
	if(shrooming >= 100)
		shroom()

/turf/simulated/floor/outdoors/proc/shroom()
	shrooming = 0
	water -= 100
	var/obj/structure/flora/mushroom/grower/M = new(src)
	M.visible_message(span_green("\The [M] appears from \the [src]..."),runemessage = "🍄")
	return M

/turf/simulated/floor/outdoors/grass
	water_saturation = 200
	mushroom_capacity = 1
	shroom_hospitality = 0.25

/turf/simulated/floor/outdoors/dirt
	water_saturation = 200
	shroom_hospitality = 0.05

/turf/simulated/floor/outdoors/dirt/water_update()
	. = ..()
	if(water > 200)
		return mudify()

/turf/simulated/floor/outdoors/dirt/proc/mudify()
	var/stored_water = water
	var/oldspore = spored
	var/turf/simulated/floor/outdoors/mud/M = ChangeTurf(/turf/simulated/floor/outdoors/mud, preserve_outdoors = TRUE)
	M.water = stored_water
	spored = oldspore
	M.begin_shrooming()
	return M

/turf/simulated/floor/outdoors/mud
	water = 200
	water_saturation = 200
	mushroom_capacity = 6
	shroom_hospitality = 1

/turf/simulated/floor/outdoors/mud/process()
	if(water <= 0)
		water = 0
		ChangeTurf(/turf/simulated/floor/outdoors/dirt/soft, preserve_outdoors = TRUE)
		return
	return ..()

/turf/simulated/floor/outdoors/mud/water(amount, var/communism = TRUE)
	var/oldwater = water
	. = ..()
	if(oldwater <= 50 && water > 50)
		START_PROCESSING(SSturfs, src)
		for(var/obj/structure/flora/mushroom/grower/G in contents)
			if(istype(G, /obj/structure/flora/mushroom/grower))
				if(G.grown >= 100)
					continue
				START_PROCESSING(SSobj, src)

/turf/simulated/floor/attack_hand(mob/user)
	. = ..()
	if(!water_saturation || !water)
		return
	if(isliving(user))
		user.visible_message(SPAN_NOTICE("\The [user] touches \the [src]..."),SPAN_NOTICE("You touch \the [src]..."))
		var/msg
		var/saturation_percent = round((water / water_saturation) * 100)
		switch(saturation_percent)
			if(90 to INFINITY)
				msg = "It's soaking wet! If it gets any more wet, the water will probably spread."
			if(75 to 89)
				msg = "It's very wet."
			if(50 to 74)
				msg = "It's wet."
			if(25 to 49)
				msg = "It's damp."
			if(1 to 24)
				msg = "It's a little moist."
			else
				msg = null
		if(!msg)
			return

		to_chat(user,SPAN_OCCULT(msg))

//////🍄🍄🍄🍄🍄//////
///🍄 MUSHROOMS!!! 🍄///
//////🍄🍄🍄🍄🍄//////

/obj/structure/flora/mushroom/grower
	name = "mushroom"
	desc = "Shroomy!"
	icon = 'icons/rogue-star/mushroom.dmi'
	icon_state = "shroom-prime"
	var/shroom_state = "shroom"
	var/grown = 0
	var/growth_rate = 0.1
	var/max_growth = 100
	var/stage = 1

/obj/structure/flora/mushroom/grower/Initialize()
	. = ..()
	update_icon()
	START_PROCESSING(SSobj, src)
	pixel_x = rand(-14,14)
	pixel_y = rand(2,30)
	layer = layer - ((y * 0.005) + (pixel_y * 0.0001))
	var/turf/simulated/floor/T = get_turf(src)
	T.spored = TRUE

/obj/structure/flora/mushroom/grower/process()
	grow()

/obj/structure/flora/mushroom/grower/proc/grow()
	var/turf/simulated/floor/T = get_turf(src)
	var/hospitality = 0
	if(istype(T, /turf/simulated/floor))
		hospitality = T.shroom_hospitality
	if(hospitality <= 0 || T.water <= 0)
		STOP_PROCESSING(SSobj, src)
		return
	var/howbright = T.get_lumcount()
	if(howbright > 0.4)
		return
	var/adjusted_grow_rate = growth_rate
	if(howbright >= 0.2)
		adjusted_grow_rate *= 0.5
	else if(howbright < 0.1)
		adjusted_grow_rate *= 2
	grown += adjusted_grow_rate * hospitality

	var/grow_percent = round((grown / max_growth) * 100)
	switch(grow_percent)
		if(0 to 10)
			stage = 1
		if(11 to 25)
			stage = 2
		if(26 to 75)
			stage = 3
		if(76 to 99)
			stage = 4
		if(100 to INFINITY)
			full_grow()
	update_icon()

/obj/structure/flora/mushroom/grower/proc/full_grow()
	STOP_PROCESSING(SSobj, src)
	grown = 100
	stage = 5
	update_icon()

/obj/structure/flora/mushroom/grower/proc/spore()
	var/list/neighbors = oview(1,src)
	for(var/turf/simulated/floor/T in neighbors)
		if(istype(T,/turf/simulated/floor))
			continue
		if(prob(50))
			T.spored = TRUE

/obj/structure/flora/mushroom/grower/update_icon()
	. = ..()
	switch(stage)
		if(1)
			icon_state = "[shroom_state]_nub"
		if(2)
			icon_state = "[shroom_state]_stem"
		if(3)
			icon_state = "[shroom_state]_bud-[rand(1,3)]"
		if(4)
			icon_state = "[shroom_state]-[rand(1,3)]"
		if(5)
			icon_state = "[shroom_state]_prime"

/////DEBUG/////

/client/proc/water()
	set name = "WATER"
	set category = "Debug"
	set desc = "Add 100 water to the turf you are standing on."

	if(!check_rights(R_DEBUG,FALSE,usr))
		return FALSE

	var/turf/simulated/floor/outdoors/T = get_turf(mob)
	if(istype(T, /turf/simulated/floor/outdoors))
		T.water(100)
		to_chat(mob, SPAN_OCCULT("You add 100 water \the [T]... [T.water]"))
		playsound(mob, 'sound/effects/sink.ogg', 75, 1)
