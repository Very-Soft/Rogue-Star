//RS FILE
/atom/proc/search()
	if(!Adjacent(usr))
		return FALSE
	to_chat(usr, SPAN_DANGER("You search \the [src], but don't find anything interesting."))
	return FALSE

/mob
	var/click_flags = 0
/mob/proc/search_on()
	click_flags |= CLICK_SEARCH
/mob/proc/search_off()
	click_flags &= ~CLICK_SEARCH
/mob/verb/toggle_search()
	set name = "Toggle-Search"
	set hidden = TRUE
	if(click_flags & CLICK_SEARCH)
		search_off()
	else
		search_on()

/obj/search()
	if(micro_target)
		if(!Adjacent(usr))
			return FALSE
		micro_interact()
		return TRUE
	. = ..()
