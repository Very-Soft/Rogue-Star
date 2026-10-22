//RS FILE
SUBSYSTEM_DEF(rs_water)
	name = "Water"
	flags = SS_NO_INIT | SS_BACKGROUND
	var/list/update_queue = list()
	var/list/spread_instance = list()

/datum/controller/subsystem/rs_water/fire(resumed)
	while(update_queue.len)
		var/turf/simulated/floor/T = update_queue[1]
		update_queue.Cut(1, 2)
		if(istype(T) && !QDELETED(T))
			T.water_update()
		if(MC_TICK_CHECK)
			return
	while(spread_instance.len)
		var/thing = spread_instance[1]
		var/input = spread_instance[thing]
		spread_instance -= thing
		spread(input)
		if(MC_TICK_CHECK)
			return

/datum/controller/subsystem/rs_water/proc/queue_spread(var/input)
	if(istype(input, /turf/simulated/floor))
		spread_instance[input] = input
	else if(islist(input) && length(input))
		var/list/turfs = input
		turfs = turfs.Copy()
		spread_instance["\ref[turfs]"] = turfs

/datum/controller/subsystem/rs_water/proc/spread(var/input)
	to_world("spread - [input]")
	var/list/to_process
	var/list/processed = list()
	var/total_water = 0
	if(istype(input, /turf/simulated/floor))
		var/turf/simulated/floor/T = input
		if(QDELETED(T) || T.water_saturation <= 0)
			return
		to_process = T.get_viable_waterspread_neighbors()
		processed |= T
	else if(islist(input))
		to_world("list")
		to_process = list()
		processed |= input
		for(var/turf/simulated/floor/T in processed)
			if(!QDELETED(T) && T.water_saturation > 0)
				to_process |= T.get_viable_waterspread_neighbors()
			CHECK_TICK
	else
		to_process = list()
		processed |= spread_instance[input]
		for(var/turf/simulated/floor/T in processed)
			if(!QDELETED(T) && T.water_saturation > 0)
				to_process |= T.get_viable_waterspread_neighbors()
			CHECK_TICK
	if(!to_process.len)
		log_debug("spread got input it couldn't use: [input]")
		return
	processed |= to_process
	to_process = list()
	for(var/turf/simulated/floor/F in processed)
		if(QDELETED(F) || F.water_saturation <= 0)
			continue
		total_water += F.water
		to_process += F
	processed = to_process
	if(!total_water)
		return
	var/average = total_water / processed.len
	to_process = list()
	for(var/turf/simulated/floor/F in processed)
		F.water = average
	for(var/turf/simulated/floor/F in processed)
		if(QDELETED(F))
			continue
		var/turf/simulated/floor/post_update = F.water_update()
		if(!QDELETED(post_update) && post_update.water > post_update.water_saturation)
			to_process |= post_update
			post_update.visible_message(runemessage = post_update.water)
		CHECK_TICK

	queue_spread(to_process)

/*
	for(var/instance in spread_instance)
		var/list/our_turfs = spread_instance[instance]
		for(var/turf/simulated/floor/F in our_turfs)
		var/list/search_turfs = get_viable_waterspread_neighbors()
		var/how_much = instance
		var/average = how_much / our_turfs.len
		var/leftover = 0
		for(var/turf/simulated/floor/T in our_turfs)
			leftover += T.water(average, FALSE)


/datum/controller/subsystem/rs_water/proc/water_spread(var/turf/simulated/floor/T)
	if(!istype(T,/turf/simulated/floor))
		return
	var/budget = T.water - T.water_saturation
	T.water -= budget
	var/list/viable = T.get_viable_waterspread_neighbors()
	if(!viable.len)
		return
	var/average = budget / viable.len
	var/leftover = 0
	for(var/turf/simulated/floor/F in viable)
		leftover += F.water(average, FALSE)

	if(leftover)
		spread_instance[leftover] = viable
*/

/turf/simulated/floor
	var/water = 0						//Current water volume
	var/water_saturation = 0			//How much can the turf hold before negative effects
	var/water_flooding_threshold = 0	//How much water before the turf floods
	var/mushroom_capacity = 0			//How many mushrooms can grow here
	var/shrooming = 0					//Progress toward generating a new mushroom
	var/shroom_hospitality = 0			//How quickly will the mushrooms grow here
	var/spored = FALSE					//Mushrooms will only grow on turfs with some spores!

/turf/simulated/floor/proc/water_spread(var/list/sources)
	if(water < water_saturation)
		return
	SSrs_water.queue_spread(src)
/*
	var/search = get_step(src,NORTH)
	if(assess_neighbor(search))
		viable_neighbors += search
	search = get_step(src,SOUTH)
	if(assess_neighbor(search))
		viable_neighbors += search
	search = get_step(src,EAST)
	if(assess_neighbor(search))
		viable_neighbors += search
	search = get_step(src,WEST)
	if(assess_neighbor(search))
		viable_neighbors += search

	if(!islist(sources))
		sources = list(src)
	else
		sources |= src
	for(var/thing in viable_neighbors)
		if(thing in sources)
			viable_neighbors -= thing

	if(!viable_neighbors.len)
		return
	var/total_water = water
	for(var/turf/simulated/floor/outdoors/thing in viable_neighbors)
		total_water += thing.water
	var/average_water = total_water / (viable_neighbors.len + 1)
	if(total_water == average_water)
		return
	for(var/turf/simulated/floor/outdoors/thing in viable_neighbors)
		if(thing in sources)
			continue
		var/transfer = min(water, average_water - thing.water)
		water -= transfer
		thing.water(transfer, sources)
*/

/turf/simulated/floor/proc/get_viable_waterspread_neighbors()
//	var/list/search = oview(1,src)

	var/list/search = list()
	search += get_step(src,NORTH)
	search += get_step(src,SOUTH)
	search += get_step(src,EAST)
	search += get_step(src,WEST)

	var/list/viable_neighbors = list()
	for(var/turf/simulated/floor/T in search)
		if(!istype(T,/turf/simulated/floor) || T.water_saturation <= 0)
			continue
//		if(T.water >= T.water_saturation)	//If it's full don't spread
//			continue
		if(T.water >= water)	//Don't spread to larger water values
			continue
		viable_neighbors |= T
	return viable_neighbors

/turf/simulated/floor/outdoors/proc/assess_neighbor(var/turf/simulated/floor/neighbor,var/list/sources)
	if(!istype(neighbor, /turf/simulated/floor/outdoors))	//Only outdoors turfs have the water var so let's only think about them
		return FALSE
	if(neighbor.water_saturation <= 0)	//Okay it has the water var but can it actually hold water?
		return FALSE
	if(neighbor.water >= water)	//Okay we only want water to spread between turfs that have less water
		return FALSE
	if(islist(sources))
		if(neighbor in sources)
			return FALSE
	return neighbor

/turf/simulated/floor/proc/water(var/amount)
	if(!amount)
		return 0
	if(water_saturation <= 0)
		return amount
	water += amount
	var/turf/simulated/floor/post_update = water_update()
	if(!QDELETED(post_update) && post_update.water > post_update.water_saturation)
		SSrs_water.queue_spread(post_update)

/turf/simulated/floor/proc/mushroom_update()
	return
/turf/simulated/floor/proc/water_update()
	return src
