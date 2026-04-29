//RS FILE
/obj
	var/lock_id = null		//Used with keys
	var/trigger_id = null	//Used with various event things

/obj/item/key
	name = "key"
	desc = "A small key made out of some kind of metal."
	icon = 'icons/rogue-star/keys.dmi'
	icon_state = "key"
	persist_storable = FALSE
	w_class = ITEMSIZE_TINY
	lock_id = "key"
	var/one_time = FALSE	//If true the key will delete itself after use
	var/master_key = FALSE	//If true then this key can open anything with a configured lock!

/obj/item/key/Initialize()
	. = ..()
	pixel_x = rand(-8,8)
	pixel_y = rand(-8,8)
	if(icon_state == "key")
		icon_state  = "[icon_state]-[rand(1,6)]"
		color = "#b4cacc"

/obj/item/key/resolve_attackby(atom/A, mob/user, attack_modifier, click_parameters)
	if(!lock_interact(A,user))
		return ..()

/obj/item/key/proc/lock_interact(var/atom/A,var/mob/user)
	if(!A || !user)
		return FALSE

	if(!isobj(A))
		return FALSE

	var/obj/O = A
	SEND_SIGNAL(O,COMSIG_KEY_ATTACK,src,user)
	return TRUE

/obj/item/key/proc/unlocked(var/mob/user)
	if(one_time)
		if(user)
			to_chat(user,SPAN_DANGER("\The [src] crumbles away to dust after being used."))
			user.drop_from_inventory(src,get_turf(user))
		qdel(src)

/obj/item/key/big
	name = "big key"
	desc = "It looks quite menacing! Upon very close inspection, there are some impossibly complicated and detailed engravings on this key."
	icon_state = "big-key"
	color = "#bb883b"
	lock_id = "boss"

/obj/item/key/onetime
	one_time = TRUE

/obj/item/key/scifi
	desc = "A small electronic card with a plastic case, with one end bearing exposed contact points for plugging into an electronic lock."
	icon_state = "scifi-a"
	var/static/list/overlays_cache = list()
	var/contact_color = "#f7b947"

/obj/item/key/scifi/Initialize()
	. = ..()
	update_icon()

/obj/item/key/scifi/update_icon()
	cut_overlays()
	if(contact_color)
		var/combine_key = "[icon_state]-contacts-[contact_color]"
		var/image/contact = overlays_cache[combine_key]
		if(!contact)
			contact = image(icon,null,"[icon_state]-contacts")
			contact.color = contact_color
			contact.appearance_flags = RESET_COLOR|KEEP_APART|PIXEL_SCALE
			overlays_cache[combine_key] = contact
		add_overlay(contact)

/obj/item/key/scifi/big
	icon_state = "scifi-b"
	desc = "A broad electronic card with a solid metal case. One end has precisely machined contacts exposed for plugging into an electronic lock."
	lock_id = "boss"
	var/case_color = "#776f85"

/obj/item/key/scifi/big/update_icon()
	. = ..()
	if(case_color)
		var/combine_key = "[icon_state]-case-[case_color]"
		var/image/case = overlays_cache[combine_key]
		if(!case)
			case = image(icon,null,"[icon_state]-case")
			case.color = case_color
			case.appearance_flags = RESET_COLOR|KEEP_APART|PIXEL_SCALE
			overlays_cache[combine_key] = case
		add_overlay(case)

/obj/item/key/scifi/red
	color = "#ff0000"
	lock_id = "red"
/obj/item/key/scifi/blue
	color = "#003cff"
	lock_id = "blue"
/obj/item/key/scifi/yellow
	color = "#ffd900"
	lock_id = "yellow"
/obj/item/key/scifi/magenta
	color = "#cc00ff"
	lock_id = "magenta"

/obj/item/key/scifi/big/red
	color = "#ff0000"
	case_color = "#6b5c5c"
	lock_id = "red-boss"
/obj/item/key/scifi/big/blue
	color = "#003cff"
	case_color = "#545c5c"
	lock_id = "blue-boss"
/obj/item/key/scifi/big/yellow
	color = "#ffd900"
	case_color = "#7e5c5c"
	lock_id = "yellow-boss"
/obj/item/key/scifi/big/magenta
	color = "#cc00ff"
	case_color = "#5a5c5c"
	lock_id = "magenta-boss"

/obj/item/key/card
	name = "key card"
	desc = "A small rectangular card with a magnet strip running along one side."
	icon_state = "card"

/obj/item/key/card/red
	color = "#ff0000"
	lock_id = "red"
/obj/item/key/card/blue
	color = "#003cff"
	lock_id = "blue"
/obj/item/key/card/yellow
	color = "#ffd900"
	lock_id = "yellow"
/obj/item/key/card/magenta
	color = "#cc00ff"
	lock_id = "magenta"

/obj/proc/key_event(var/obj/item/key/K)
	if(!K)
		return FALSE
	if((K.master_key && lock_id) || lock_id == K.lock_id)
		return dungeon_trigger(K.one_time)
	return FALSE
