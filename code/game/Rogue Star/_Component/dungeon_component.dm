//RS FILE
var/global/list/dungeon_components = list()

/datum/component/dungeon_mechanic
	var/id = "REPLACE ME"

/datum/component/dungeon_mechanic/Initialize(var/our_id)
	if(!isobj(parent))
		return COMPONENT_INCOMPATIBLE
	if(our_id)
		id = our_id

	dungeon_components |= src

//LOCK// - It won't work unless you unlock it
/datum/component/dungeon_mechanic/lock
	var/locked = TRUE
	var/onetime = FALSE

/datum/component/dungeon_mechanic/lock/Initialize(var/our_id)
	. = ..()
	var/obj/O = parent
	O.dungeon_lock()
	RegisterSignal(parent, COMSIG_KEY_ATTACK , PROC_REF(key_interact))

/datum/component/dungeon_mechanic/lock/proc/key_interact()
	var/obj/O = parent
	if(!istype(args[2],/obj/item/key))
		return
	var/obj/item/key/K = args[2]
	var/mob/user = args[3]
	if(K.key_id == id || K.master_key)
		if(!locked && K.one_time)
			to_chat(user,SPAN_NOTICE("\The [O] is already unlocked! You don't need to use \the [K] on it."))
			return
		if(user)
			user.visible_message(SPAN_NOTICE("\The [user] inserts \the [K] into \the [O]..."),SPAN_NOTICE("You insert \the [K] into \the [O]..."))
		if(toggle_lock(O))
			K.unlocked()
		else
			to_chat(user,SPAN_WARNING("While \the [K] fits, \the [O] won't budge! The locking mechanism won't lock again."))
		return

	if(user)
		to_chat(user,SPAN_DANGER("\The [K] doesn't fit into \the [O]..."))

/datum/component/dungeon_mechanic/lock/proc/toggle_lock(var/obj/O)
	if(onetime && !locked)
		return FALSE
	locked = !locked
	if(locked)
		return O.dungeon_lock()
	else
		return O.dungeon_unlock()

//RECIEVER// - The thing that gets told what to do
/datum/component/dungeon_mechanic/reciever

/datum/component/dungeon_mechanic/reciever/Initialize(var/our_id)
	. = ..()
	for(var/datum/component/dungeon_mechanic/trigger/T in dungeon_components)
		if(T == src)
			continue
		if(!istype(T,/datum/component/dungeon_mechanic/trigger))
			continue
		if(T.id == id)
			RegisterSignal(T,COMSIG_DUNGEON_TRIGGER,PROC_REF(link_trigger))
			RegisterSignal(T,COMSIG_DUNGEON_UNTRIGGER,PROC_REF(link_trigger))

/datum/component/dungeon_mechanic/reciever/Destroy(force, silent)
	dungeon_components -= src
	for(var/datum/component/dungeon_mechanic/trigger/T in dungeon_components)
		if(id == T.id)
			UnregisterSignal(T,COMSIG_DUNGEON_TRIGGER)
			UnregisterSignal(T,COMSIG_DUNGEON_UNTRIGGER)
	return ..()

/datum/component/dungeon_mechanic/reciever/proc/link_trigger()
	var/obj/O = parent
	O.dungeon_trigger()

//TRIGGER// - The thing that tells other things to do things
/datum/component/dungeon_mechanic/trigger
	var/triggered = FALSE	//Are we triggered or untriggered
	var/onetime = FALSE		//If true we can only be triggered, once triggered, we can not be untriggered
	var/solo = TRUE			//If FALSE will require ALL of the triggers with the same ID to be triggered before it will send the trigger signal
	var/key_lock = FALSE	//If TRUE (and solo is FALSE) requires unique ckeys to hit each trigger
	var/triggered_by		//A recording of who triggered the trigger (only relevent if key_lock is TRUE)

/datum/component/dungeon_mechanic/trigger/Initialize(our_id)
	. = ..()
	RegisterSignal(parent, COMSIG_DUNGEON_TRIGGER , PROC_REF(toggle_trigger))
	RegisterSignal(parent, COMSIG_DUNGEON_UNTRIGGER , PROC_REF(toggle_trigger))

/datum/component/dungeon_mechanic/trigger/Destroy(force, silent)
	dungeon_components -= src
	UnregisterSignal(parent, COMSIG_DUNGEON_TRIGGER)
	UnregisterSignal(parent, COMSIG_DUNGEON_UNTRIGGER)

	for(var/datum/component/dungeon_mechanic/reciever/L in dungeon_components)
		if(id == L.id)
			L.UnregisterSignal(src,COMSIG_DUNGEON_TRIGGER)
	return ..()

/datum/component/dungeon_mechanic/trigger/proc/toggle_trigger()
	var/mob/user
	if(args.len >= 2)
		user = args[2]

	if(!triggered)
		trigger(user)
	else
		untrigger()

/datum/component/dungeon_mechanic/trigger/proc/should_key_trigger(var/key)
	if(!key_lock)
		return TRUE

	for(var/datum/component/dungeon_mechanic/trigger/T in dungeon_components)
		if(T.id != id)
			continue
		if(!T.triggered_by)
			continue
		if(T.triggered_by == key)
			return FALSE

	return TRUE

/datum/component/dungeon_mechanic/trigger/proc/trigger(var/mob/user)
	var/signal = TRUE
	if(!solo)
		for(var/datum/component/dungeon_mechanic/trigger/T in dungeon_components)
			if(T == src)
				continue
			if(T.id != id)
				continue
			if(key_lock)	//If key_lock is true then we need unique ckeys for each trigger.
				if(!user)
					return
				if(!user.ckey)
					return
				if(T.triggered_by == user.ckey)
					to_chat(user,SPAN_WARNING("\The [parent] very unsatisfyingly does nothing when you interact with it. Perhaps someone else needs to interact with this one."))
					return
			if(!T.triggered)
				signal = FALSE
				var/obj/O = T.parent
				to_world("[O] on [O.x],[O.y],[O.z] isn't triggered, so we shouldn't send the trigger signal.")

	if(user?.ckey)
		triggered_by = user.ckey

	triggered = TRUE
	var/obj/P = parent
	P.dungeon_trigger()
	if(signal)
		SEND_SIGNAL(src,COMSIG_DUNGEON_TRIGGER)
		to_world("Should have signaled")
	else
		to_world("Shouldn't have signaled")
	var/turf/T = get_turf(parent)
	T.visible_message("\The [parent] clicks audibly as it is triggered...",runemessage = "click...")

/datum/component/dungeon_mechanic/trigger/proc/untrigger()
	if(onetime)
		return
	SEND_SIGNAL(src,COMSIG_DUNGEON_UNTRIGGER)
	triggered = FALSE
	triggered_by = null

	var/obj/P = parent
	P.dungeon_untrigger()

	var/turf/T = get_turf(parent)
	T.visible_message("\The [parent] clunks audibly as it is untriggered...",runemessage = "clunk...")

//PAIR// - So things can know about eachother, such as teleporters
/datum/component/dungeon_mechanic/pair
	var/list/partner = list()

/datum/component/dungeon_mechanic/pair/Initialize(our_id)
	. = ..()
	pair_with_partners()

/datum/component/dungeon_mechanic/pair/proc/pair_with_partners()
	for(var/datum/component/dungeon_mechanic/pair/P in dungeon_components)
		if(P.type != type)
			continue
		if(P == src)
			continue
		if(id == P.id)
			partner |= P
			P.partner |= src

/datum/component/dungeon_mechanic/pair/proc/unpair_with_partners()
	for(var/datum/component/dungeon_mechanic/pair/P in partner)
		P.partner -= src
		partner -= P

//////////RELATED OBJ PROCS//////////
/obj/proc/dungeon_trigger(var/mob/user)	//This is the main trigger action, if you want something that always does the same thing, use this, all the other procs default to this
	return FALSE
/obj/proc/dungeon_untrigger(var/mob/user)	//If you need a specific untrigger action
	dungeon_trigger(user)

/obj/proc/dungeon_lock(var/mob/user)	//If you need a specific lock action
	dungeon_trigger(user)

/obj/proc/dungeon_unlock(var/mob/user)	//If you need a specific unlock action
	dungeon_trigger(user)

/obj/proc/getlock()
	return GetComponent(/datum/component/dungeon_mechanic/lock)

/obj/proc/islocked()
	var/datum/component/dungeon_mechanic/lock/ourlock = GetComponent(/datum/component/dungeon_mechanic/lock)
	if(ourlock?.locked)
		return TRUE
	return FALSE

/obj/proc/cantrigger(var/mob/user)
	var/datum/component/dungeon_mechanic/trigger/trigger = GetComponent(/datum/component/dungeon_mechanic/trigger)
	if(!trigger)
		return FALSE
	if(trigger.onetime && trigger.triggered)
		return FALSE
	if(trigger.key_lock)
		if(!user.ckey)
			return FALSE
		return trigger.should_key_trigger(user.ckey)

	return TRUE

/obj/proc/istriggered()
	var/datum/component/dungeon_mechanic/trigger/trigger = GetComponent(/datum/component/dungeon_mechanic/trigger)
	if(!trigger)
		return FALSE
	return trigger.triggered

/obj/proc/get_dungeon_pair()
	var/datum/component/dungeon_mechanic/pair/P = GetComponent(/datum/component/dungeon_mechanic/pair)
	if(!P)
		return FALSE
	if(P.partner)
		if(P.partner.len <= 0)
			return FALSE
	return P.partner
