///// The contents of this file are terrible and shouldn't be used, but they can be if you want to play Kobgario /////
///// This file is not ticked on purpose. /////

/*
/mob/living/simple_mob/vore/kob/Bump(atom/A)
	if(attempt_vr(src,"Bump_vr",list(A))) return
	return ..()

/mob/living/simple_mob/vore/kob/Bump_vr(atom/A)
	if(A == src)
		return
	if(iskob(A))
		var/mob/living/simple_mob/vore/kob/k = A
		if(faction != "kob")
			if(k.faction == faction)
				return

		if(k.size_multiplier <= size_multiplier - (size_multiplier * 0.25))
			if(!kob_game_nom(k))
				return
			adjust_nutrition(k.nutrition)
			k.nutrition = 1

	else if(ismouse(A))
		var/mob/living/l = A
		if(!kob_game_nom(l))
			return
		adjust_nutrition(l.nutrition)
		l.nutrition = 1

	else if(isliving(A))
		var/mob/living/l = A
		if(l.mob_size < mob_size)
			if(!kob_game_nom(l))
				return
			adjust_nutrition(l.nutrition)
			l.nutrition = 1
		else if(l.size_multiplier <= size_multiplier - (size_multiplier * 0.25))
			if(!kob_game_nom(l))
				return
			adjust_nutrition(l.nutrition)
			l.nutrition = 1
	else return
*/

/*
/mob/living/simple_mob/vore/kob/Moved(atom/oldloc, direct, forced, movetime)
	. = ..()
	if(!isturf(loc))
		return
	for(var/mob/living/l in loc)
		if(!(size_multiplier >= l.size_multiplier + (size_multiplier * 0.25) || ismouse(l)))
			return
		if(isbelly(l.loc))
			return
		if(!kob_game_nom(l))
			return
		adjust_nutrition(l.nutrition)
		l.nutrition = 1
*/

/mob/living/simple_mob/vore/kob/Life()
	. = ..()
	if(stat)
		return
	if(!isturf(loc))
		return
	for(var/mob/living/l in view(1, src))
		if(l == src)
			continue
		if(!isturf(l.loc))
			continue
		if(faction != "kob")
			if(l.faction == faction)
				continue
		var/chance = (size_multiplier * 100) - (l.size_multiplier * 100)
		if(prob(chance) || ismouse(l))
			if(!kob_game_nom(l))
				continue
			adjust_nutrition(l.nutrition)
			l.nutrition = 1

/mob/living/simple_mob/vore/kob/proc/kob_game_nom(mob/living/T)
	if(T == src)
		return FALSE
	if(!will_eat_game(T))
		return FALSE
	T.Weaken(10)
	game_nom(T, src, vore_selected)
	update_icon()
	return TRUE

/mob/living/simple_mob/vore/kob/proc/will_eat_game(var/mob/living/M)
	if(!istype(M))
		return FALSE
	if(src == M)
		return FALSE
	if(!M.allowmobvore || !M.devourable)
		return FALSE
	if(M in prey_excludes)
		return FALSE
	return TRUE

/mob/living/simple_mob/vore/kob/proc/game_nom(mob/living/prey, mob/living/pred, obj/belly/belly)

	if(pred == prey)
		return FALSE

	var/success_msg = "<span class='warning'>[pred] manages to [lowertext(belly.vore_verb)] [prey] into their [lowertext(belly.name)]!</span>"

	pred.visible_message(success_msg)

	// Actually shove prey into the belly.
	belly.nom_mob(prey, pred)
	pred.update_icons()

	return TRUE
