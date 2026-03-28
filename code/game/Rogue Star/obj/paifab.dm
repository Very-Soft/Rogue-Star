//RS FILE
/obj/machinery/paifab
	name = "\improper Personal AI Card Fabricator"
	desc = "A little machine for making little digital friends!"

/obj/machinery/paifab/attack_ghost(mob/user)
	. = ..()
	if(!stat)
		user.client.pai_spawn(src)

/client/proc/pai_spawn(var/atom/fab)
	var/choice = tgui_alert(usr,"Would you like to play as a pAI?","pAI Spawn",list("No","Yes"))

	if(choice != "Yes")
		return
	if(!fab)
		choice = null
		var/list/fabs = list()
		for(var/obj/machinery/paifab/possible_fab in world)
			if(possible_fab.operable())
				fabs[possible_fab.loc.loc] = possible_fab

		if(fabs.len > 0)
			choice = tgui_input_list(usr,"Which fab would you like to spawn at?","Choose Starting Location",fabs)

		if(!choice)
			return
		if(!istype(fabs[choice],/obj/machinery/paifab))
			to_chat(usr,SPAN_DANGER("Something went wrong, pick a different option!"))
			return
		var/obj/machinery/paifab/ourfab = fabs[choice]
		if(!ourfab.operable())
			to_chat(usr,SPAN_DANGER("\The [ourfab] is not presently functional, and so can not fabricate a card for you at this time."))
			return
		fab = choice

	choice = null
	var/list/possible_cards = list(
		"Classic" = /obj/item/device/paicard,
		"Rugged" = /obj/item/device/paicard/typeb
		)

	choice = tgui_alert(usr,"Which card type would you prefer?","Manufacturing in progress...",possible_cards)
	if(!choice)
		return

	var/obj/item/device/paicard/ourcard = new possible_cards[choice]()
	ourcard.onboard(usr)



/obj/item/device/paicard/proc/onboard(var/to_onboard)
	if(!to_onboard)
		return

	var/mob/living/silicon/pai/new_pai = new(src)
	new_pai.key = user.key
	paikeys |= new_pai.ckey
	card.setPersonality(new_pai)
	if(!new_pai.savefile_load(new_pai))
		var/pai_name = tgui_input_text(new_pai, "Choose your character's name", "Character Name")
		actual_pai_name = sanitize_name(pai_name, ,1)
		if(isnull(actual_pai_name))
			return ..()
