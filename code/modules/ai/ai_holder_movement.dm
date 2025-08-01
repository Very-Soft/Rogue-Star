/datum/ai_holder
	// General.
	var/turf/destination = null			// The targeted tile the mob wants to walk to.
	var/min_distance_to_destination = 1	// Holds how close the mob should go to destination until they're done.

	// Home.
	var/turf/home_turf = null			// The mob's 'home' turf. It will try to stay near it if told to do so. This is the turf the AI was initialized on by default.
	var/returns_home = FALSE			// If true, makes the mob go to its 'home' if it strays too far.
	var/home_low_priority = FALSE		// If true, the mob will not go home unless it has nothing better to do, e.g. its following someone.
	var/max_home_distance = 3			// How far the mob can go away from its home before being told to go_home().
										// Note that there is a 'BYOND cap' of 14 due to limitations of get_/step_to().
	// Wandering.
	var/wander = FALSE					// If true, the mob will randomly move in the four cardinal directions when idle.
	var/wander_delay = 0				// How many ticks until the mob can move a tile in handle_wander_movement().
	var/base_wander_delay = 2			// What the above var gets set to when it wanders. Note that a tick happens every half a second.
	var/wander_when_pulled = FALSE		// If the mob will refrain from wandering if someone is pulling it.

	// Breakthrough
	var/failed_breakthroughs = 0		// How many times we've failed to breakthrough something lately

	var/walk_attempts = 0				//RS ADD - How many times did we try and fail to walk?

/datum/ai_holder/proc/walk_to_destination()
	ai_log("walk_to_destination() : Entering.",AI_LOG_TRACE)
	if(!destination)
		ai_log("walk_to_destination() : No destination.", AI_LOG_WARNING)
		forget_path()
		set_stance(stance == STANCE_REPOSITION ? STANCE_APPROACH : STANCE_IDLE)
		ai_log("walk_to_destination() : Exiting.", AI_LOG_TRACE)
		return

	var/distance = get_dist(holder, destination)
	ai_log("walk_to_destination() : get_to is [min_distance_to_destination].", AI_LOG_TRACE)

	// We're here! Or we're horribly lost
	if(distance <= min_distance_to_destination || holder.z != destination.z)
		check_use_ladder()
		give_up_movement()
		set_stance(stance == STANCE_REPOSITION ? STANCE_APPROACH : STANCE_IDLE)
		ai_log("walk_to_destination() : Destination reached. Exiting.", AI_LOG_INFO)
		return

	ai_log("walk_to_destination() : Walking.", AI_LOG_TRACE)
	walk_path(destination, min_distance_to_destination)
	ai_log("walk_to_destination() : Exiting.",AI_LOG_TRACE)

/datum/ai_holder/proc/should_go_home()
	if(stance != STANCE_IDLE)
		return FALSE
	if(!returns_home || !home_turf)
		return FALSE
	if(get_dist(holder, home_turf) > max_home_distance)
		if(!home_low_priority)
			return TRUE
		else if(!leader && !target)
			return TRUE
	return FALSE
//	return (returns_home && home_turf) && (get_dist(holder, home_turf) > max_home_distance)

/datum/ai_holder/proc/go_home()
	if(home_turf)
		ai_log("go_home() : Telling holder to go home.", AI_LOG_INFO)
		lose_follow() // So they don't try to path back and forth.
		give_destination(home_turf, max_home_distance)
	else
		ai_log("go_home() : Told to go home without home_turf.", AI_LOG_ERROR)

/datum/ai_holder/proc/give_destination(turf/new_destination, min_distance = 1, combat = FALSE)
	ai_log("give_destination() : Entering.", AI_LOG_DEBUG)

	destination = new_destination
	min_distance_to_destination = min_distance

	if(new_destination != null)
		ai_log("give_destination() : Going to new destination.", AI_LOG_INFO)
		set_stance(combat ? STANCE_REPOSITION : STANCE_MOVE)
		return TRUE
	else
		ai_log("give_destination() : Given null destination.", AI_LOG_ERROR)

	ai_log("give_destination() : Exiting.", AI_LOG_DEBUG)


// Walk towards whatever.
/datum/ai_holder/proc/walk_path(atom/A, get_to = 1)
	ai_log("walk_path() : Entered.", AI_LOG_TRACE)
	var/turf/ourturf = get_turf(holder)	//RS ADD
	if(use_astar)
		if(!path.len) // If we're missing a path, make a new one.
			ai_log("walk_path() : No path. Attempting to calculate path.", AI_LOG_DEBUG)
			calculate_path(A, get_to)

		if(!path.len) // If we still don't have one, then the target's probably somewhere inaccessible to us. Get as close as we can.
			ai_log("walk_path() : Failed to obtain path to target. Using get_step_to() instead.", AI_LOG_INFO)
		//	step_to(holder, A)
			if(holder.IMove(get_step_to(holder, A)) == MOVEMENT_FAILED)
				ai_log("walk_path() : Failed to move, attempting breakthrough.", AI_LOG_INFO)
				if(!breakthrough(A) && failed_breakthroughs++ >= 5) // We failed to move, time to smash things.
					give_up_movement()
					failed_breakthroughs = 0
			return

		if(move_once() == FALSE) // Start walking the path.
			ai_log("walk_path() : Failed to step.", AI_LOG_TRACE)
			++failed_steps
			if(failed_steps > 3) // We're probably stuck.
				ai_log("walk_path() : Too many failed_steps.", AI_LOG_DEBUG)
				forget_path() // So lets try again with a new path.
				failed_steps = 0

	else
	//	step_to(holder, A)
		ai_log("walk_path() : Going to IMove().", AI_LOG_TRACE)
		if(holder.IMove(get_step_to(holder, A)) == MOVEMENT_FAILED )
			ai_log("walk_path() : Failed to move, attempting breakthrough.", AI_LOG_INFO)
			if(!breakthrough(A) && failed_breakthroughs++ >= 5) // We failed to move, time to smash things.
				give_up_movement()
				failed_breakthroughs = 0

	ai_log("walk_path() : Exited.", AI_LOG_TRACE)

	if(ourturf == get_turf(holder))	//RS ADD START
		walk_attempts ++
	else
		walk_attempts = 0
	if(walk_attempts >= 10)
		lose_target()
		give_up_movement()
		walk_attempts = 0	//RS ADD END

//Take one step along a path
/datum/ai_holder/proc/move_once()
	ai_log("move_once() : Entered.", AI_LOG_TRACE)
	if(!path.len)
		return

	if(path_display)
		var/turf/T = src.path[1]
		T.cut_overlay(path_overlay)

//	step_towards(holder, src.path[1])
	if(holder.IMove(get_step_towards(holder, src.path[1])) != MOVEMENT_ON_COOLDOWN)
		if(holder.loc != src.path[1])
			ai_log("move_once() : Failed step. Exiting.", AI_LOG_TRACE)
			return MOVEMENT_FAILED
		else
			path -= src.path[1]
			ai_log("move_once() : Successful step. Exiting.", AI_LOG_TRACE)
			return MOVEMENT_SUCCESSFUL
	ai_log("move_once() : Mob movement on cooldown. Exiting.", AI_LOG_TRACE)
	return MOVEMENT_ON_COOLDOWN

/datum/ai_holder/proc/should_wander()
	return (stance == STANCE_IDLE) && wander && !leader

// Wanders randomly in cardinal directions.
/datum/ai_holder/proc/handle_wander_movement()
	if(!holder)
		return
	ai_log("handle_wander_movement() : Entered.", AI_LOG_TRACE)
	if(busy)	//RS ADD START
		ai_log("handle_wander_movement() : Busy is set to true. Exiting.", AI_LOG_DEBUG)
		return	//RS ADD END
	if(isturf(holder.loc) && can_act())
		wander_delay--
		if(wander_delay <= 0)
			if(!wander_when_pulled && (holder.pulledby || holder.grabbed_by.len))
				ai_log("handle_wander_movement() : Being pulled and cannot wander. Exiting.", AI_LOG_DEBUG)
				return

			var/moving_to = 0 // Apparently this is required or it always picks 4, according to the previous developer for simplemob AI.
			moving_to = pick(cardinal)
			holder.set_dir(moving_to)
			holder.IMove(get_step(holder,moving_to))
			wander_delay = base_wander_delay
	ai_log("handle_wander_movement() : Exited.", AI_LOG_TRACE)

/datum/ai_holder/proc/check_use_ladder()
	// No target, don't use the ladder
	// Target is visible, don't use the ladder
	if(!target || can_see_target(target))
		return

	var/has_hands = TRUE
	if(istype(holder, /mob/living/simple_mob))
		var/mob/living/simple_mob/S = holder
		has_hands = S.has_hands

	// Don't have means to use a ladder or the space around it, don't use the ladder
	if(!has_hands && !holder.hovering)
		return

	var/obj/structure/ladder/L = locate() in get_turf(holder)
	if(!istype(L))
		return // No ladder, can't use it

	if(!holder.may_climb_ladders(L))
		return // Can't climb the ladder for other reasons (Probably inconsequential?)

	var/list/directions = list()
	if(L.allowed_directions & DOWN)
		directions += L.target_down
	if(L.allowed_directions & UP)
		directions += L.target_up

	if(directions.len)
		L.climbLadder(holder, pick(directions))
