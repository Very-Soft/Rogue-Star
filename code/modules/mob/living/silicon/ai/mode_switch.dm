/mob/living/silicon/ai
	var/chassis = "13"
//	var/icon/holo_icon
	var/icon/holo_icon_north
	var/holo_icon_dimension_X = 32
	var/holo_icon_dimension_Y = 32

	var/global/list/possible_chassis = list(
		"Drone" = "pai-repairbot",
		"Cat" = "pai-cat",
		"Mouse" = "pai-mouse",
		"Monkey" = "pai-monkey",
		"Borgi" = "pai-borgi",
		"Fox" = "pai-fox",
		"Parrot" = "pai-parrot",
		"Rabbit" = "pai-rabbit",
		"Dire wolf" = "pai-diredog",
		"Horse (Lune)" = "pai-horse_lune",
		"Horse (Soleil)" = "pai-horse_soleil",
		"Dragon" = "pai-pdragon",
		"Bear" = "pai-bear",
		"Fennec" = "pai-fen",
		"Type Zero" = "pai-typezero",
		"Raccoon" = "pai-raccoon",
		"Raptor" = "pai-raptor",
		"Corgi" = "pai-corgi",
		"Bat" = "pai-bat",
		"Butterfly" = "pai-butterfly",
		"Hawk" = "pai-hawk",
		"Duffel" = "pai-duffel",
		"Rat" = "rat",
		"Panther" = "panther",
		"Cyber Elf" = "cyberelf",
		"Teppi" = "teppi",
		"Catslug" = "catslug",
		"Car" = "car",
		"Type One" = "typeone",
		"Type Thirteen" = "13"
	)
	var/global/list/wide_chassis = list(
		"rat",
		"panther",
		"teppi",
		"pai-diredog",
		"pai-horse_lune",
		"pai-horse_soleil",
		"pai-pdragon"
		)

/mob/living/silicon/ai/proc/ai_mode_switch()
	set category = "AI Commands"
	set name = "Mode Switch"
	set desc = "Toggles between mobile mode or hooking into the network."


	deployed = !deployed

	view_core()

	if(deployed)
		icon = 'icons/mob/AI.dmi'
		icon_state = "ai"
		canmove = FALSE
		anchored = TRUE
		if(eyeobj)
			client.eye = eyeobj
			eyeobj.use_static = TRUE
		to_chat(src,"You hook into the network, becoming immobile.")
	else
		var/oursize = size_multiplier
		resize(1, FALSE, TRUE, TRUE, FALSE)		//We resize ourselves to normal here for a moment to let the vis_height get reset
		set_mobile_sprite(oursize)
		canmove = TRUE
		anchored = FALSE
		client.eye = src
		if(eyeobj)
			eyeobj.use_static = FALSE
		to_chat(src,"You disconnect from the network and become mobile.")


/mob/living/silicon/ai/verb/choose_chassis()
	set category = "AI Commands"
	set name = "Choose Chassis"
	var/choice

	choice = tgui_input_list(usr, "What would you like to use for your mobile chassis icon?", "Chassis Choice", possible_chassis)
	if(!choice) return
	var/oursize = size_multiplier
	resize(1, FALSE, TRUE, TRUE, FALSE)		//We resize ourselves to normal here for a moment to let the vis_height get reset
	chassis = possible_chassis[choice]
	set_mobile_sprite(oursize)

/mob/living/silicon/ai/proc/set_mobile_sprite(var/oursize = 1)
	if(chassis == "13")
		if(!holo_icon)
			if(!get_character_icon())
				return
		icon_state = null
		icon = holo_icon
	else if(chassis in wide_chassis)
		icon = 'icons/mob/pai_vr64x64.dmi'
		vis_height = 64
	else
		icon = 'icons/mob/pai_vr.dmi'
		vis_height = 32
	resize(oursize, FALSE, TRUE, TRUE, FALSE)	//And then back again now that we're sure the vis_height is correct.

	update_icon()

/mob/living/silicon/ai/proc/get_character_icon()
	if(!client || !client.prefs) return FALSE
	var/mob/living/carbon/human/dummy/dummy = new ()
	//This doesn't include custom_items because that's ... hard.
	client.prefs.dress_preview_mob(dummy)
	sleep(1 SECOND) //Strange bug in preview code? Without this, certain things won't show up. Yay race conditions?
	dummy.regenerate_icons()

	var/icon/new_holo = getCompoundIcon(dummy)

	dummy.tail_alt = TRUE
	dummy.set_dir(NORTH)
	var/icon/new_holo_north = getCompoundIcon(dummy)

	qdel(holo_icon)
	qdel(holo_icon_north)
	qdel(dummy)
	holo_icon = new_holo
	holo_icon_north = new_holo_north
	return TRUE
