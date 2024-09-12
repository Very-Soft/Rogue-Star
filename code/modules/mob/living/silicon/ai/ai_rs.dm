/mob/living/silicon/ai/proc/ai_nom(var/mob/living/T in oview(1))
	set name = "AI Nom"
	set category = "pAI Commands"
	set desc = "Allows you to eat someone while unfolded. Can't be used while in card form."

	if (stat != CONSCIOUS)
		return
	if(deployed)
		return
	return feed_grabbed_to_self(src,T)

/mob/living/silicon/ai/get_available_emotes()

	var/list/fulllist = list()
	fulllist |= _silicon_default_emotes
	fulllist |= _robot_default_emotes
	fulllist |= _human_default_emotes
	return fulllist
