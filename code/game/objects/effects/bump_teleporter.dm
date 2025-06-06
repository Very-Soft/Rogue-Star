var/list/obj/effect/bump_teleporter/BUMP_TELEPORTERS = list()

/obj/effect/bump_teleporter
	name = "bump-teleporter"
	icon = 'icons/mob/screen1.dmi'
	icon_state = "x2"
	var/id = null			//id of this bump_teleporter.
	var/id_target = null	//id of bump_teleporter which this moves you to.
//	invisibility = 101 		//nope, can't see this	//RS REMOVE
	plane = PLANE_ADMIN_SECRET	//You CAN see it, but only in build mode uwu	// RS ADD
	anchored = TRUE
	density = TRUE
	opacity = 0

/obj/effect/bump_teleporter/New()
	..()
	BUMP_TELEPORTERS += src

/obj/effect/bump_teleporter/Destroy()
	BUMP_TELEPORTERS -= src
	return ..()

/obj/effect/bump_teleporter/Bumped(atom/user)
	if(!ismob(user))
		//user.loc = src.loc	//Stop at teleporter location
		return
	var/mob/M = user	//VOREStation edit
	if(!id_target)
		//user.loc = src.loc	//Stop at teleporter location, there is nowhere to teleport to.
		density = FALSE	//RS ADD - Then just don't get bumped bruh
		return
	for(var/obj/effect/bump_teleporter/BT in BUMP_TELEPORTERS)
		if(BT.id == src.id_target)
			M.forceMove(BT.loc)	//Teleport to location with correct id.	//VOREStation Edit
			return

/obj/effect/bump_teleporter/Initialize()	//RS ADD - One way teleporters
	. = ..()
	if(id && !id_target)
		density = FALSE
