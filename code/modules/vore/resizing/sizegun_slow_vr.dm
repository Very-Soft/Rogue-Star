#define SIZE_SHRINK 0
#define SIZE_GROW 1

/obj/item/device/slow_sizegun
	name = "gradual size gun"
	desc = "A highly advanced ray gun, designed for progressive and gradual changing of size, along with theft of nutrition." //RS edit: adds functionality for nutrient drain mode and size_shift
	icon = 'icons/obj/gun_vr.dmi'
	icon_state = "sizegun-old-0"
	var/base_icon_state = "sizegun-old"
	w_class = ITEMSIZE_NORMAL
	origin_tech = list(TECH_BLUESPACE = 4)
	force = 0
	slot_flags = SLOT_BELT
	var/beam_range = 4 // How many tiles away it can scan. Changing this also changes the box size.
	var/busy = FALSE // Set to true when scanning, to stop multiple scans.
	var/sizeshift_mode = SIZE_SHRINK
	var/dorm_size = TRUE
	var/size_increment = 0.01
	var/current_target
	var/size_shift = FALSE //RS Edit - Allows gradiaul size gun to do do the opposite to the user. Shrink victim = grow user.
	var/nutrition_steal = FALSE //RS Edit - Allow theft of nutrition

/obj/item/device/slow_sizegun/update_icon()
	icon_state = "[base_icon_state]-[sizeshift_mode]"

	if(busy)
		icon_state = "[icon_state]-active"

/obj/item/device/slow_sizegun/proc/should_stop(var/mob/living/target, var/mob/living/user, var/active_hand)
	if(!target || !user || !active_hand || !istype(target) || !istype(user) || !busy)
		return TRUE

	if(user.get_active_hand() != active_hand)
		return TRUE

	if(user.incapacitated(INCAPACITATION_DEFAULT))
		return TRUE

	if(get_dist(user, target) > beam_range)
		return TRUE

	var/unresizable = FALSE
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		if(istype(H.gloves, /obj/item/clothing/gloves/bluespace))
			unresizable = TRUE
			return

	if(target != user)	//RS EDIT
		if(!(target.resizable && spont_pref_check(user,target,RESIZING)))	//RS EDIT
			unresizable = TRUE	//RS EDIT

	if(unresizable)
		return TRUE

	if(!(target.has_large_resize_bounds()) && (target.size_multiplier >= RESIZE_MAXIMUM) && sizeshift_mode == SIZE_GROW)
		return TRUE

	if(target.size_multiplier >= RESIZE_MAXIMUM_DORMS && sizeshift_mode == SIZE_GROW)
		return TRUE

	if(!(target.has_large_resize_bounds()) && (target.size_multiplier <= RESIZE_MINIMUM) && sizeshift_mode == SIZE_SHRINK)
		return TRUE

	if(target.size_multiplier <= RESIZE_MINIMUM_DORMS && sizeshift_mode == SIZE_SHRINK)
		return TRUE

	//RS Edit Start - Nutrition Stuff
	if(nutrition_steal && (target.nutrition <= 0 || user.nutrition <= 0))
		return TRUE
	//RS Edit End

	return FALSE

/obj/item/device/slow_sizegun/afterattack(atom/target, mob/living/user, proximity_flag) //RS Edit
	// Things that invalidate the scan immediately.
	if(isturf(target))
		for(var/atom/A as anything in target) // If we can't scan the turf, see if we can scan anything on it, to help with aiming.
			if(isliving(A))
				target = A
				break

	if(busy && !(target == current_target))
		to_chat(user, span("warning", "\The [src] is already targeting something."))
		return

	if(!isliving(target))
		to_chat(user, span("warning", "\the [target] is not a valid target."))
		return

	var/mob/living/L = target

	if(get_dist(target, user) > beam_range)
		to_chat(user, span("warning", "You are too far away from \the [target] to affect it. Get closer."))
		return

	if(target == current_target && busy)
		busy = FALSE
		return

	var/unresizable = FALSE
	var/shot_self = FALSE
	if(ishuman(L))
		var/mob/living/carbon/human/H = L
		if(istype(H.gloves, /obj/item/clothing/gloves/bluespace))
			unresizable = TRUE

	if(target != user)
		if(!(L.resizable && spont_pref_check(user,target,RESIZING)))	//RS EDIT
			unresizable = TRUE	//RS EDIT
	else
		shot_self = TRUE

	if(unresizable)
		to_chat(user, span("warning", "\the [target] is immune to resizing."))
		return	//RS EDIT

	// Start the effects
	current_target = target
	busy = TRUE
	update_icon()
	var/datum/beam/scan_beam = user.Beam(target, icon = 'icons/effects/beam_vr.dmi', icon_state = "zappy1", time = 6000)
	var/filter = filter(type = "outline", size = 1, color = "#00FF00")
	target.filters += filter
	var/list/box_segments = list()
	if(user.client)
		box_segments = draw_box(target, beam_range, user.client)
		color_box(box_segments, "#00FF00", 5)

	playsound(src, 'sound/weapons/wave.ogg', 50)

	var/active_hand = user.get_active_hand()

	while(!should_stop(target, user, active_hand))
		stoplag(3)
		if(!nutrition_steal) //RS EDIT START - Size Transfer & Nutrition Steal
			if(sizeshift_mode == SIZE_SHRINK)
				L.resize((L.size_multiplier - size_increment), uncapped = L.has_large_resize_bounds(), ignore_prefs = shot_self, aura_animation = FALSE)
			else if(sizeshift_mode == SIZE_GROW)
				L.resize((L.size_multiplier + size_increment), uncapped = L.has_large_resize_bounds(), ignore_prefs = shot_self, aura_animation = FALSE)

			//Size Transfer
			if(isliving(user) && size_shift)
				if(sizeshift_mode == SIZE_SHRINK)
					user.resize((user.size_multiplier + size_increment), uncapped = L.has_large_resize_bounds(), ignore_prefs = shot_self, aura_animation = FALSE)
				else if(sizeshift_mode == SIZE_GROW)
					user.resize((user.size_multiplier - size_increment), uncapped = L.has_large_resize_bounds(), ignore_prefs = shot_self, aura_animation = FALSE)
		else
			if(sizeshift_mode == SIZE_SHRINK) //Steal nutrition from target!
				L.nutrition -= 10 //Drain a base 10 nutrition per tick.
				user.nutrition += 10
			else //Give nutrition to target!
				L.nutrition += 10
				user.nutrition -= 10
		//RS EDIT END

	busy = FALSE
	current_target = null

	// Now clean up the effects.
	update_icon()
	QDEL_NULL(scan_beam)
	if(target)
		target.filters -= filter
	if(user.client) // If for some reason they logged out mid-scan the box will be gone anyways.
		delete_box(box_segments, user.client)

/obj/item/device/slow_sizegun/attack_self(mob/living/user)
	if(busy)
		busy = !busy
	else
		sizeshift_mode = !sizeshift_mode
		update_icon()
		to_chat(user, span("notice", "\The [src] will now [sizeshift_mode ? "grow" : "shrink"] its targets."))


#undef SIZE_SHRINK
#undef SIZE_GROW


#define ICON_SIZE 32

// Draws a box showing the limits of movement while scanning something.
// Only the client supplied will see the box.
/obj/item/device/slow_sizegun/proc/draw_box(atom/A, box_size, client/C)
	. = list()
	// Things moved with pixel_[x|y] will move the box, so this is to correct that.
	var/pixel_x_correction = -A.pixel_x
	var/pixel_y_correction = -A.pixel_y

	// First, place the bottom-left corner.
	. += draw_line(A, SOUTHWEST, (-box_size * ICON_SIZE) + pixel_x_correction, (-box_size * ICON_SIZE) + pixel_y_correction, C)

	// Make a line on the bottom, going right.
	for(var/i = 1 to (box_size * 2) - 1)
		var/x_displacement = (-box_size * ICON_SIZE) + (ICON_SIZE * i) + pixel_x_correction
		var/y_displacement = (-box_size * ICON_SIZE) + pixel_y_correction
		. += draw_line(A, SOUTH, x_displacement, y_displacement, C)

	// Bottom-right corner.
	. += draw_line(A, SOUTHEAST, (box_size * ICON_SIZE) + pixel_x_correction, (-box_size * ICON_SIZE) + pixel_y_correction, C)

	// Second line, for the right side going up.
	for(var/i = 1 to (box_size * 2) - 1)
		var/x_displacement = (box_size * ICON_SIZE) + pixel_x_correction
		var/y_displacement = (-box_size * ICON_SIZE) + (ICON_SIZE * i) + pixel_y_correction
		. += draw_line(A, EAST, x_displacement, y_displacement, C)

	// Top-right corner.
	. += draw_line(A, NORTHEAST, (box_size * ICON_SIZE) + pixel_x_correction, (box_size * ICON_SIZE) + pixel_y_correction, C)

	// Third line, for the top, going right.
	for(var/i = 1 to (box_size * 2) - 1)
		var/x_displacement = (-box_size * ICON_SIZE) + (ICON_SIZE * i) + pixel_x_correction
		var/y_displacement = (box_size * ICON_SIZE) + pixel_y_correction
		. += draw_line(A, NORTH, x_displacement, y_displacement, C)

	// Top-left corner.
	. += draw_line(A, NORTHWEST, (-box_size * ICON_SIZE) + pixel_x_correction, (box_size * ICON_SIZE) + pixel_y_correction, C)

	// Fourth and last line, for the left side going up.
	for(var/i = 1 to (box_size * 2) - 1)
		var/x_displacement = (-box_size * ICON_SIZE) + pixel_x_correction
		var/y_displacement = (-box_size * ICON_SIZE) + (ICON_SIZE * i) + pixel_y_correction
		. += draw_line(A, WEST, x_displacement, y_displacement, C)

#undef ICON_SIZE

// Draws an individual segment of the box.
/obj/item/device/slow_sizegun/proc/draw_line(atom/A, line_dir, line_pixel_x, line_pixel_y, client/C)
	var/image/line = image(icon = 'icons/effects/effects.dmi', loc = A, icon_state = "stripes", dir = line_dir)
	line.pixel_x = line_pixel_x
	line.pixel_y = line_pixel_y
	line.plane = PLANE_FULLSCREEN // It's technically a HUD element but it doesn't need to show above item slots.
	line.appearance_flags = RESET_TRANSFORM|RESET_COLOR|RESET_ALPHA|NO_CLIENT_COLOR|TILE_BOUND
	line.alpha = 125
	C.images += line
	return line

// Removes the box that was generated before from the client.
/obj/item/device/slow_sizegun/proc/delete_box(list/box_segments, client/C)
	for(var/i in box_segments)
		C.images -= i
		qdel(i)

/obj/item/device/slow_sizegun/proc/color_box(list/box_segments, new_color, new_time)
	for(var/i in box_segments)
		animate(i, color = new_color, time = new_time)




//RS Edit Start
/obj/item/device/slow_sizegun/verb/size_shift()
	set name = "Toggle Size Shift"
	set desc = "Toggle if you want to shift size while the gun is in use! (If you shrink the target, you grow. Vice versa!)"
	set category = "Object"
	set src in usr

	size_shift = !size_shift
	if(size_shift)
		to_chat(usr, "<span class='warning'>You will now grow if you shrink the target, or shrink if you grow the target!</span>")
	else
		to_chat(usr, "<span class='warning'>Special size shifting operations have been disabled. The gun now functions like normal!</span>")
	return

/obj/item/device/slow_sizegun/verb/nutrition_shift()
	set name = "Toggle Nutrition Shift"
	set desc = "Toggle if you want to steal nutrition/transfer your nutrtion to the target!"
	set category = "Object"
	set src in usr

	nutrition_steal = !nutrition_steal
	if(nutrition_steal)
		to_chat(usr, "<span class='warning'>The ray will now steal nutrition or transfer nutrition to/from the target instead of size! This disables the size modulator on the ray!</span>")
	else
		to_chat(usr, "<span class='warning'>Special nutrition stealing operations have been disabled. The gun now functions like normal!</span>")
	return

/obj/item/device/slow_sizegun/examine(mob/user)
	. = ..()
	if(Adjacent(user))
		if(nutrition_steal && size_shift)
			. += "The gun has both 'nutrition shift' and 'size shift' mode enabled, although there is a warning on the display that nutrition steal mode takes priority."
		else
			if(nutrition_steal)
				. += "The gun seems to be set to 'nutrition steal' mode."
			if(size_shift)
				. += "The gun seems to be set to 'size shift' mode."
	return
//RS Edit End
