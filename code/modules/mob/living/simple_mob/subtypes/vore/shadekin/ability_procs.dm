// Phase shifting procs (and related procs)
/mob/living/simple_mob/shadekin/proc/phase_shift()
	var/turf/T = get_turf(src)
	var/area/A = T.loc	//RS ADD
	if(!T.CanPass(src,T) || loc != T)
		to_chat(src,"<span class='warning'>You can't use that here!</span>")
		return FALSE
	if(!client?.holder && A.block_phase_shift)	//RS EDIT START
		to_chat(src,"<span class='warning'>You can't use that here!</span>")
		return FALSE							//RS EDIT END

	forceMove(T)
	var/original_canmove = canmove
	SetStunned(0)
	SetWeakened(0)
	if(buckled)
		buckled.unbuckle_mob()
	if(pulledby)
		pulledby.stop_pulling()
	stop_pulling()
	canmove = FALSE

	//RS EDIT START
	//Shifting in
	if(ability_flags & AB_PHASE_SHIFTED)
		phase_in()
	//Shifting out
	else
		ability_flags |= AB_PHASE_SHIFTED
		mouse_opacity = 0
		custom_emote(1,"phases out!")
		real_name = name
		name = "Something"

		for(var/obj/belly/B as anything in vore_organs)
			B.escapable = FALSE

		cut_overlays()
		flick("tp_out",src)
		sleep(5)
		invisibility = INVISIBILITY_LEVEL_TWO
		see_invisible = INVISIBILITY_LEVEL_TWO
		update_icon()
		alpha = 127

		canmove = original_canmove
		incorporeal_move = TRUE
		density = FALSE
		force_max_speed = TRUE

/mob/living/simple_mob/shadekin/proc/phase_in()
	var/original_canmove = canmove		//RS EDIT END
	//Shifting in
	if(ability_flags & AB_PHASE_SHIFTED)
		ability_flags &= ~AB_PHASE_SHIFTED
		mouse_opacity = 1
		name = real_name
		for(var/obj/belly/B as anything in vore_organs)
			B.escapable = TRUE // RS edit

		cut_overlays()
		alpha = initial(alpha)
		invisibility = initial(invisibility)
		see_invisible = initial(see_invisible)
		incorporeal_move = initial(incorporeal_move)
		density = initial(density)
		force_max_speed = initial(force_max_speed)

		//Cosmetics mostly
		flick("tp_in",src)
		custom_emote(1,"phases in!")
		sleep(5) //The duration of the TP animation
		canmove = original_canmove

		//Potential phase-in vore
		if(can_be_drop_pred) //Toggleable in vore panel
			var/list/potentials = living_mobs(0)
			if(potentials.len)
				for(var/mob/living/target in potentials)	//RS EDIT START
					if(spont_pref_check(src,target,SPONT_PRED))
						target.forceMove(vore_selected)
						to_chat(target,"<span class='warning'>\The [src] phases in around you, [vore_selected.vore_verb]ing you into their [vore_selected.name]!</span>")
															//RS EDIT END

		// Do this after the potential vore, so we get the belly
		update_icon()

		//Affect nearby lights
		var/destroy_lights = 0
		if(eye_state == RED_EYES)
			destroy_lights = 80
		if(eye_state == PURPLE_EYES)
			destroy_lights = 25

		for(var/obj/machinery/light/L in machines)
			if(L.z != z || get_dist(src,L) > 10)
				continue

			if(prob(destroy_lights))
				spawn(rand(5,25))
					L.broken()
			else
				L.flicker(10)

/mob/living/simple_mob/shadekin/UnarmedAttack()
	if(ability_flags & AB_PHASE_SHIFTED)
		return FALSE //Nope.

	. = ..()

/mob/living/simple_mob/shadekin/can_fall()
	if(ability_flags & AB_PHASE_SHIFTED)
		return FALSE //Nope!

	return ..()

/mob/living/simple_mob/shadekin/zMove(direction)
	if(ability_flags & AB_PHASE_SHIFTED)
		var/turf/destination = (direction == UP) ? GetAbove(src) : GetBelow(src)
		if(destination)
			forceMove(destination)
		return TRUE

	return ..()

// Healing others
/mob/living/simple_mob/shadekin/proc/mend_other()
	//I hate to crunch a view() but I only want ones I can see
	var/list/viewed = oview(1)
	var/list/targets = list()
	for(var/mob/living/L in viewed)
		targets += L
	if(!targets.len)
		to_chat(src,"<span class='warning'>Nobody nearby to mend!</span>")
		return FALSE

	var/mob/living/target = tgui_input_list(src,"Pick someone to mend:","Mend Other", targets)
	if(!target)
		return FALSE

	target.add_modifier(/datum/modifier/shadekin/heal_boop,1 MINUTE)
	visible_message("<span class='notice'>\The [src] gently places a hand on \the [target]...</span>")
	face_atom(target)
	return TRUE
