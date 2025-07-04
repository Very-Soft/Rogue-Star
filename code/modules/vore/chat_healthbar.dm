//RS FILE

//Health bars in the game window would be pretty challenging and I don't know how to do that, so I thought this would be a good alternative
//I figured it out 17 months later lol

/mob/living/proc/chat_healthbar(var/mob/living/reciever, override = FALSE)
	if(!reciever)	//No one to send it to, don't bother
		return
	if(!reciever.client)	//No one is home, don't bother
		return
	if(!override)	//Did the person push the verb? Ignore the pref
		if(!reciever.client.is_preference_enabled(/datum/client_preference/vore_health_bars))
			return
	var/ourpercent = 0

	if(ishuman(src))	//humans don't die or become unconcious at 0%, it's actually like -50% or something, so, let's pretend they have 50 more health than they do
		ourpercent = ((health + 100) / (maxHealth + 100)) * 100
	else
		ourpercent = (health / maxHealth) * 100

	var/ourbar = ""
	var/obj/belly/ourbelly = src.loc
	var/ourmode = ourbelly.return_effective_d_mode(src)
	var/which_var = "Health"
	if(ourmode == "Absorb" || ourmode == "Drain")
		ourpercent = round(((nutrition - 100) / 2000) * 100)
		which_var = "Nutrition"	//It's secretly also a nutrition bar depending on your digest mode

	ourpercent = round(ourpercent)

	switch(ourpercent)	//I thought about trying to do this in a more automated way but my brain isn't very large so enjoy my stupid switch statement
		if(100 to INFINITY)
			ourbar = "|▓▓▓▓▓▓▓▓▓▓|"
		if(95 to 99)
			ourbar = "|▓▓▓▓▓▓▓▓▓▒|"
		if(90 to 94)
			ourbar = "|▓▓▓▓▓▓▓▓▓░|"
		if(85 to 89)
			ourbar = "|▓▓▓▓▓▓▓▓▒░|"
		if(80 to 84)
			ourbar = "|▓▓▓▓▓▓▓▓░░|"
		if(75 to 79)
			ourbar = "|▓▓▓▓▓▓▓▒░░|"
		if(70 to 74)
			ourbar = "|▓▓▓▓▓▓▓░░░|"
		if(65 to 69)
			ourbar = "|▓▓▓▓▓▓▒░░░|"
		if(60 to 64)
			ourbar = "|▓▓▓▓▓▓░░░░|"
		if(55 to 59)
			ourbar = "|▓▓▓▓▓▒░░░░|"
		if(50 to 54)
			ourbar = "|▓▓▓▓▓░░░░░|"
		if(45 to 49)
			ourbar = "|▓▓▓▓▒░░░░░|"
		if(40 to 44)
			ourbar = "|▓▓▓▓░░░░░░|"
		if(35 to 39)
			ourbar = "|▓▓▓▒░░░░░░|"
		if(30 to 34)
			ourbar = "|▓▓▓░░░░░░░|"
		if(25 to 29)
			ourbar = "|▓▓▒░░░░░░░|"
		if(20 to 24)
			ourbar = "|▓▓░░░░░░░░|"
		if(15 to 19)
			ourbar = "|▓▒░░░░░░░░|"
		if(10 to 14)
			ourbar = "|▓░░░░░░░░░|"
		if(5 to 9)
			ourbar = "|▒░░░░░░░░░|"
		if(0)
			ourbar = "|░░░░░░░░░░|"
		else
			ourbar = "!░░░░░░░░░░!"

	ourbar = "[ourbar] [which_var] - [src.name]"
	if(stat == UNCONSCIOUS)
		ourbar = "[ourbar] - UNCONSCIOUS"
	else if(stat == DEAD)
		ourbar = "[ourbar] - DEAD"
	if(absorbed)
		ourbar = "<font color='#cd45f0'>[ourbar] - ABSORBED</font>"	//Absorb is a little funny, I didn't want it to say 'absorbing ABSORBED' so we did it different
	else if(ourmode == "Drain")
		ourbar = "<font color='#e49c00'>[ourbar] - [ourmode]ing</font>"
	else if(ourmode == "Absorb")
		ourbar = "<font color='#cd45f0'>[ourbar] - [ourmode]ing</font>"
	else if(ourpercent > 75)
		ourbar = "<span class='green'>[ourbar] - [ourmode]ing</span>"
	else if(ourpercent > 50)
		ourbar = "<span class='orange'>[ourbar] - [ourmode]ing</span>"
	else if(ourpercent > 0)
		ourbar = "<span class='red'>[ourbar] - [ourmode]ing</span>"
	else
		ourbar = "<span class = 'danger'>[ourbar] - [ourmode]ing</span>"

	to_chat(reciever,ourbar)

/mob/living/verb/print_healthbars()
	set name = "Print Prey Healthbars"
	set category = "IC"

	var/nuffin = TRUE
	for(var/obj/belly/b in vore_organs)
		if(!b.contents.len)
			continue
		var/belly_announce = FALSE	//We only want to announce the belly once
		for(var/thing as anything in b.contents)
			if(!isliving(thing))
				continue
			if(!belly_announce)
				to_chat(src, "<span class='notice'>[b.digest_mode] - Within [b.name]:</span>")	//We only want to announce the belly if we found something
				belly_announce = TRUE
			var/mob/living/ourmob = thing
			ourmob.chat_healthbar(src, TRUE)
			nuffin = FALSE
	if(nuffin)
		to_chat(src, "<span class='warning'>There are no mobs within any of your bellies to print health bars for.</span>")

/mob/living/verb/print_classic_healthbar()
	set name = "Print Classic Vore Healthbar"
	set category = "IC"

	if(!isbelly(loc))
		to_chat(src, "<span class='warning'>You aren't in a belly, you can't print a healthbar, silly!</span>")
		return

	chat_healthbar(src, TRUE)
