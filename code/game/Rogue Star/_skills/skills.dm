//RS FILE
/mob/proc/skill_check(var/skill)
	if(!etching)
		return FALSE
	return etching.skill_check(skill)

/datum/etching/proc/skill_check(var/skill, var/rank)
	var/value = xp[skill]
	if(!value)
		return FALSE
	if(!rank)
		return TRUE
	if(value >= rank)
		return value
	return FALSE
