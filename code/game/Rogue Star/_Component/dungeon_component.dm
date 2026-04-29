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

//Locks//
/datum/component/dungeon_mechanic/lock
	var/locked = TRUE

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
	if(K.lock_id == id || K.master_key)
		if(!locked && K.one_time)
			to_chat(user,SPAN_NOTICE("\The [O] is already unlocked! You don't need to use \the [K] on it."))
			return
		if(user)
			user.visible_message(SPAN_NOTICE("\The [user] inserts \the [K] into \the [O]..."),SPAN_NOTICE("You insert \the [K] into \the [O]..."))
		if(toggle_lock(O))
			K.unlocked()
		return

	if(user)
		to_chat(user,SPAN_DANGER("\The [K] doesn't fit into \the [O]..."))

/datum/component/dungeon_mechanic/lock/proc/toggle_lock(var/obj/O)
	locked = !locked
	if(locked)
		return O.dungeon_lock()
	else
		return O.dungeon_unlock()

//LINK//
/datum/component/dungeon_mechanic/link

/datum/component/dungeon_mechanic/link/Initialize(var/our_id)
	. = ..()
	for(var/datum/component/dungeon_mechanic/trigger/T in dungeon_components)
		if(T == src)
			continue
		if(T.type != /datum/component/dungeon_mechanic/trigger)
			continue
		if(T.id == id)
			RegisterSignal(T,COMSIG_DUNGEON_TRIGGER,PROC_REF(link_trigger))
			RegisterSignal(T,COMSIG_DUNGEON_UNTRIGGER,PROC_REF(link_trigger))

/datum/component/dungeon_mechanic/link/Destroy(force, silent)
	dungeon_components -= src
	for(var/datum/component/dungeon_mechanic/trigger/T in dungeon_components)
		if(id == T.id)
			UnregisterSignal(T,COMSIG_DUNGEON_TRIGGER)
			UnregisterSignal(T,COMSIG_DUNGEON_UNTRIGGER)
	return ..()

/datum/component/dungeon_mechanic/link/proc/link_trigger()
	var/obj/O = parent
	O.dungeon_trigger()

//TRIGGER//
/datum/component/dungeon_mechanic/trigger
	var/triggered = FALSE
	var/onetime = FALSE
/datum/component/dungeon_mechanic/trigger/Initialize(our_id)
	. = ..()
	RegisterSignal(parent, COMSIG_DUNGEON_TRIGGER , PROC_REF(toggle_trigger))
	RegisterSignal(parent, COMSIG_DUNGEON_UNTRIGGER , PROC_REF(toggle_trigger))

/datum/component/dungeon_mechanic/trigger/Destroy(force, silent)
	dungeon_components -= src
	UnregisterSignal(parent, COMSIG_DUNGEON_TRIGGER)
	UnregisterSignal(parent, COMSIG_DUNGEON_UNTRIGGER)

	for(var/datum/component/dungeon_mechanic/link/L in dungeon_components)
		if(id == L.id)
			L.UnregisterSignal(src,COMSIG_DUNGEON_TRIGGER)
	return ..()

/datum/component/dungeon_mechanic/trigger/proc/toggle_trigger()
	if(triggered)
		if(!onetime)
			untrigger()
	else
		trigger()

/datum/component/dungeon_mechanic/trigger/proc/trigger()
	triggered = TRUE
/datum/component/dungeon_mechanic/trigger/proc/untrigger()
	triggered = FALSE

//////////RELATED OBJ PROCS//////////
/obj/proc/dungeon_lock()
	return FALSE

/obj/proc/dungeon_unlock()
	return FALSE

/obj/proc/dungeon_trigger()
	return FALSE

/obj/proc/islocked()
	var/datum/component/dungeon_mechanic/lock/ourlock = GetComponent(/datum/component/dungeon_mechanic/lock)
	if(ourlock?.locked)
		return TRUE
	return FALSE

/obj/proc/cantrigger()
	var/datum/component/dungeon_mechanic/trigger/trigger = GetComponent(/datum/component/dungeon_mechanic/trigger)
	if(!trigger)
		return FALSE
	if(trigger.onetime && trigger.triggered)
		return FALSE
	return TRUE
