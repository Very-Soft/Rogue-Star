///// TO DO /////
/*

Complex crafting station - uses supplies from nearby stockpile

Dragon summoning ritual?

*/

/obj/structure/kob
	icon = 'icons/rogue-star/kobs/kobx32.dmi'
	icon_state = "kob"
	var/health = 100
	var/maxhealth = 100
	var/faction							//should be set to a color hex value automatically

/obj/structure/kob/examine(mob/user, infix, suffix)
	. = ..()
	if(iskob(user))
		if(health < maxhealth)
			. += "<span class = 'danger'>It looks damaged!</span>"
			. += "<span class = 'notice'>You could use holy trash slag to repair it!</span>"

/obj/structure/kob/attack_hand(mob/user)
	var/h = health
	. = ..()
	add_fingerprint(user)
	if(health < h)
		relay_attack_to_kobs(user)

	return

/obj/structure/kob/attackby(obj/item/W as obj, mob/user as mob)
	user.setClickCooldown(user.get_attack_speed(W))
	if(istype(W, /obj/item/stack/material/trash_slag) && istype(user, /mob/living/simple_mob/vore/kob))
		var/obj/item/stack/material/trash_slag/D = W
		if(health < maxhealth)
			if(D.get_amount() < 1)
				to_chat(user, "<span class='warning'>You need one brick of holy to repair \the [src].</span>")
				return
			visible_message("<span class='notice'>[user] begins to repair \the [src].</span>")
			if(do_after(user,20) && health < maxhealth)
				if(D.use(1))
					health = maxhealth
					visible_message("<span class='notice'>[user] repairs \the [src].</span>")
				return
		return
	else
		var/h = health
		switch(W.damtype)
			if("fire")
				health -= W.force * 1
			if("brute")
				health -= W.force * 0.75
		playsound(src, 'sound/items/trayhit1.ogg', 50, 1)
		CheckHealth()
		if(health < h)
			relay_attack_to_kobs(user)

		..()

/obj/structure/kob/proc/relay_attack_to_kobs(mob/attacker)

	if(isliving(attacker))
		if(faction == attacker.faction)
			return

	if(health <= (maxhealth - (maxhealth / 4)))
		for(var/mob/living/simple_mob/vore/kob/k in view(world.view, src))
			if(k.faction != faction)
				return
			if(k.client)
				to_chat(k, "<span class = 'danger'>\The [src] is under attack by [attacker]! ! !</span>")
			if(k.ai_holder)
				k.ai_holder.add_attacker(attacker)

/obj/structure/kob/proc/CheckHealth()
	if(health <= 0)
		qdel(src)

	health = min(health, maxhealth)

	return

/obj/structure/kob/take_damage(var/damage)
	health -= damage
	CheckHealth()
	return

/obj/structure/kob/attack_generic(var/mob/user, var/damage, var/attack_verb)
	var/h = health
	visible_message("<span class='danger'>[user] [attack_verb] the [src]!</span>")
	playsound(src, 'sound/items/trayhit1.ogg', 75, 1)
	user.do_attack_animation(src)
	health -= damage
	CheckHealth()
	if(health < h)
		relay_attack_to_kobs(user)

	return

/obj/structure/kob/bullet_act(obj/item/projectile/Proj)
	. = ..()
	to_world("Hello from bullet_act on [src]")
	var/h = health
	take_damage(Proj.damage/10)
	if(health < h && Proj.firer)
		relay_attack_to_kobs(Proj.firer)

/obj/structure/kob/nest
	name = "trash nest"
	desc = "It's quiet..."
	icon_state = "trash_nest"
	anchored = FALSE
	density = FALSE
	var/resource = 0
	var/busy = FALSE

/obj/structure/kob/nest/update_icon()
	. = ..()

	cut_overlays()
	var/image/ourimage = image(icon,null,"trash_nest_flag")
	ourimage.color = faction
	ourimage.appearance_flags = RESET_COLOR|KEEP_APART|PIXEL_SCALE
	add_overlay(ourimage)

/obj/structure/kob/nest/attack_hand(mob/living/user)
	. = ..()
	if(iskob(user))
		if(busy)
			to_chat(user, "<span class = 'warning'>Someone else is already using this nest!</span>")
			return
		var/mob/living/simple_mob/vore/kob/k = user
		var/list/our_options = list(
			"Pick Nest Faction Color",
			"Found Nest",
			"Info"
			)
		busy = TRUE
		var/choice = tgui_input_list(k, "It's an unfounded Kob nest! What would you like to do?", "[src.name]", our_options)
		if(!choice)
			busy = FALSE
			return
		switch(choice)
			if("Pick Nest Faction Color")
				if(k.clothing_color && tgui_alert(k, "Would you like to use your existing clothing color, or pick a new one?", "Nest Faction Color", list("Existing","New")) == "Existing")
					faction = k.clothing_color
					update_icon()
					busy = FALSE
					return
				faction = input(k,"Pick a color for this nest faction!","Nest Faction Color", k.clothing_color) as null|color
				update_icon()
				busy = FALSE
				return
			if("Found Nest")
				if(!faction)
					var/list/options = list("No", "Random is Fine")
					if(k.clothing_color)
						options |= "Use my clothing color"
					var/question = tgui_alert(k,"A faction color hasn't been set yet. Are you sure you don't want to pick one? It will be random if you do not pick one.","Confirm",options)
					if(question == "Random is Fine")
						to_chat(k,"<span class = 'Notice'>Alright, we'll pick a real nice color!</span>")
						faction = random_color()
						update_icon()
					else if(question =="Use my clothing color")
						faction = k.clothing_color
						update_icon()
					else
						busy = FALSE
						return
				for(var/obj/structure/kob/fort/f in view(world.view, src.loc))
					to_chat(k,"<span class = 'warning'>You can't found a nest so close to \the [f]. Move \the [src] further away from other nests!</span>")
					busy = FALSE
					return
				if(k.client && tgui_alert(k,"Would you like to found \the [src]? Your character will be retired into the nest.","Found nest",list("No", "Yes")) != "Yes")
					busy = FALSE
					return
				var/found_one = FALSE
				var/mob/living/simple_mob/vore/kob/found_kob
				for(found_kob in view(1, src))
					if(found_kob == k)
						continue
					if(!iskob(found_kob))
						continue
					if(found_kob.client)
						to_chat(k,"<span class = 'notice'>Asking \the [found_kob] if they would like to found the nest with you... Stand still for a moment.</span>")
						if(tgui_alert(found_kob,"Would you like to found \the [src] with \the [k]? This will cause your character to be retired into the nest.","Found nest",list("No", "Yes"),timeout = 10 SECONDS) != "Yes")
							to_chat(k,"<span class = 'warning'>They did not agree.</span>")
							continue
					found_one = TRUE
					to_chat(k,"<span class = 'notice'>\The [found_kob] agreed to found \the [src] with you!</span>")
					break
				if(!found_one)
					busy = FALSE
					to_chat(k,"<span class = 'warning'>You can't found a nest alone, you need a partner!</span>")
					return
				to_chat(k,"<span class = 'notice'>You and [found_kob] begin to found \the [src]. You will both need to stay in the nest for one minute to complete the process!</span>")
				if(found_kob.client)
					to_chat(found_kob,"<span class = 'notice'>You and [k] begin to found \the [src]. You will both need to stay in the nest for one minute to complete the process!</span>")
				found_nest(k, found_kob)
			if("Info")
				busy = FALSE
				to_chat(k, "<span class = 'notice'>The Kob nest can be used to produce a Kob fort, and subsequently more Kobs! You can freely move the nest around and pick its flag color. \
				Once the nest is founded, it becomes a fort, and can no longer be moved. A Kob fort is the heart of a Kob base, without it no new Kobs can be produced, and defeat will surely follow.\
				<br><br>\
				In order to found a nest, you need to pick a faction color, and you need a total of two Kobs! New forts cannot be founded too near to other forts. You will know you are too close \
				when you try to found the nest, as founding will not initiate. When all is in place, the two founding Kobs will get to work on the nest. \
				When they are done, a fort will be constructed, and the two Kobs will retire into the fort to continue making more Kobs. If you do not wish to found the nest yourself, \
				you can bring two NPC Kobs to the nest and say '</span><b><u>'Kob'</u></b><span class = 'notice'> found'. You will want to replace '</span><b><u>'Kob'</u></b><span class = 'notice'>' with one of the Kobs' individual names. Kobs are named '</span><b><u>Fort/family name</u></b><span class = 'notice'>' '</span><b><u>Individual name</u></b><span class = 'notice'>' \
				so any orders you give to them will need to use their <Individual name>. The individual name is usually very short and easy to say.\
				<br><br>\
				When you pick a faction color, the flag on the nest will change to match, allowing you to coordinate with other Kobs as to which faction color the new fort should represent. \
				The color of the flag is important, as it represents the faction of the Kobs that the fort will produce. If you have a faction you are a part of and want to create a new fort for, \
				you will have the option to select your existing faction color for the nest. If you pick a different color, the Kobs produced from the fort will be considered at war with Kobs of \
				any other faction.</span> <span class = 'warning'>Even a slight difference in flag color will count as a new faction.</span>\
				<br><br>\
				<span class = 'notice'>Once the fort is completed, any Kobs who did not retire into the fort may click on the fort to join the fort's faction if it differs from their own.\
				<br><br>\
				The fort will slowly produce new Kobs. The kobs inside of the fort accept foodstuff as a resource. Providing resources to the fort will result in new Kobs being produced \
				more quickly for as long as the fort has resources. The fort steadily consumes resources over time.</span>")

/obj/structure/kob/nest/proc/found_nest(var/mob/living/simple_mob/vore/kob/momma, var/mob/living/simple_mob/vore/kob/pappa)
	busy = TRUE
	visible_message("<span class = 'danger'>\The [momma] and \the [pappa] begin to make a racket atop \the [src]! They are founding a nest!</span>")
	if(momma.ai_holder)
		momma.ai_holder.set_busy(TRUE)
	if(pappa.ai_holder)
		pappa.ai_holder.set_busy(TRUE)

	var/turf/our_home = get_turf(src.loc)
	momma.forceMove(our_home)
	momma.lay_down()
	pappa.forceMove(our_home)
	pappa.lay_down()
	if(!do_after(momma, 60 SECONDS,pappa,exclusive = TRUE))
		if(momma.loc != our_home || pappa.loc != our_home)
			busy = FALSE
			visible_message("<span class = 'warning'>The founding process was interrupted!</span>")
			if(momma.ai_holder)
				momma.ai_holder.set_busy(FALSE)
			if(pappa.ai_holder)
				pappa.ai_holder.set_busy(FALSE)
			return
	var/obj/structure/kob/fort/f = new (get_turf(src),faction)
	log_and_message_admins("[f] was founded: [ADMIN_JMP(f)]")
	visible_message("<span class = 'notice'>\The [momma] and \the [pappa] successfully found \the [src]! A new fort is errected! They name it [f]!</span>")
	qdel(momma)
	qdel(pappa)
	qdel(src)

/obj/structure/kob/fort
	name = "trash fort"
	desc = "There's a ruckus happening inside!"
	icon = 'icons/rogue-star/kobs/kobx64.dmi'
	icon_state = "trash_fort"
	anchored = TRUE
	density = TRUE

	pixel_x = -16
	plane = MOB_PLANE
	layer = MOB_LAYER

	maxhealth = 500
	health = 500

	var/amount_grown = 0				//the amount a new stocked_kob is grown
	var/resource = 0					//how much resources have been put in, resources increase the growth rate
	var/stocked_kobs = 0				//how many spawns worth of Kobs are in the nest
	var/base_eject_chance = 50			//50% chance to eject a kob when over the 'stock_until_guard_spawn' var
	var/eject_modifier = 5				//the number the eject chance is reduced by per kob near the nest (so at 10, there is 0% of more kobs being ejected)
	var/stock_until_guard_spawn = 5		//how many cycles until we can spawn NPCs
	var/spawns_guards = TRUE			//does it spawn NPCs?
	var/hostile_guards = TRUE			//are those NPCs hostile?
	var/fort_name
	var/static/set_fluff_types = FALSE
	var/static/list/fluff_types
	var/ghostjoin = TRUE

/obj/structure/kob/fort/New(loc, set_faction)
	if(set_faction)
		faction = set_faction
	return ..()

/obj/structure/kob/fort/Initialize()
	if(!faction)
		faction = random_color()
	update_icon()
	kob_fort_name()
	START_PROCESSING(SSobj, src)
	active_ghost_pods |= src

	if(!set_fluff_types)
		fluff_types = subtypesof(/mob/living/simple_mob/vore/kob/fluff)
		set_fluff_types = TRUE
	return ..()

/obj/structure/kob/fort/proc/kob_fort_name()
	var/how_many_syllables = rand(3,6)

	while(how_many_syllables)
		how_many_syllables --

		fort_name = "[fort_name][pick(kob_name_syllables)]"

	if(!how_many_syllables)
		fort_name = capitalize(fort_name)

	name = "[fort_name] fort"

/obj/structure/kob/fort/Destroy()
	STOP_PROCESSING(SSobj, src)
	visible_message("\The [src] crumbles apart!")
	playsound(src, 'sound/effects/bang.ogg', 75, 1)

	if(stocked_kobs)
		if(stocked_kobs > 5)
			stocked_kobs = 5
		while(stocked_kobs > 0)
			stocked_kobs --
			if(hostile_guards)
				var/mob/living/simple_mob/vore/kob/nest_defender/k = new(c_color = faction, inherit_clothing_faction = TRUE,inherit_name = fort_name)
				k.forceMove(get_turf(src))
				k.ghostjoin = TRUE
				visible_message("<span class ='warning'>\The [k] tumbles out of \the [src]!</span>")
			else
				var/mob/living/simple_mob/vore/kob/k = new(c_color = faction, inherit_clothing_faction = TRUE,inherit_name = fort_name)
				k.forceMove(get_turf(src))
				k.ghostjoin = TRUE
				visible_message("<span class ='warning'>\The [k] tumbles out of \the [src]!</span>")

	return ..()

/obj/structure/kob/fort/update_icon()
	. = ..()

	cut_overlays()
	var/image/ourimage = image(icon,null,"flag")
	ourimage.color = faction
	ourimage.appearance_flags = RESET_COLOR|KEEP_APART|PIXEL_SCALE
	add_overlay(ourimage)

	ourimage = image(icon,null,"glow")
	ourimage.color = faction
	ourimage.appearance_flags = RESET_COLOR|KEEP_APART|PIXEL_SCALE
	ourimage.plane = PLANE_LIGHTING_ABOVE
	add_overlay(ourimage)

/obj/structure/kob/fort/process()

	if(pixel_x != -16)
		pixel_x = -16

	var/plus = 0
	if(resource > 0)
		plus += rand(1,5)
		resource -= rand(0,1)

	amount_grown += rand(0,2) + plus

	if(amount_grown >= 100)	//We only do the rest of our work if we've waited a while
		stocked_kobs ++		//More Kob
		amount_grown -= 100
		if(!spawns_guards)	//If we don't spawn guards no reason to do the rest of the work
			return
		if(stocked_kobs > stock_until_guard_spawn)

			var/count = 0
			if(eject_modifier > 0)	//In case for whatever reason we want a giant kob army, if someone sets this to 0, no reason to count the kobs nearby
				for(var/mob/living/simple_mob/vore/kob/k in view(world.view, src))
					if(iskob(k))
						count ++

			var/true_eject_chance = base_eject_chance - (count * eject_modifier)
			if(prob(true_eject_chance))
				stocked_kobs --
				var/our_turf = get_turf(src)
				if(fluff_types.len && prob(1))
					var/picked_type = pick(fluff_types)
					fluff_types -= picked_type
					new picked_type(our_turf, c_color = faction, inherit_clothing_faction = TRUE)
					visible_message("<span class ='warning'>A kob climbs out of \the [src]!</span>", runemessage = "!")
				else if(hostile_guards)
					if(prob(75))
						var/mob/living/simple_mob/vore/kob/nest_defender/k = new(our_turf, c_color = faction, inherit_clothing_faction = TRUE,inherit_name = fort_name)
						k.ai_holder.home_turf = src
						visible_message("<span class ='warning'>\The [k] climbs out of \the [src]!</span>")
					else
						var/mob/living/simple_mob/vore/kob/scout/k = new(our_turf, c_color = faction, inherit_clothing_faction = TRUE,inherit_name = fort_name)
						k.ai_holder.home_turf = src
						visible_message("<span class ='warning'>\The [k] climbs out of \the [src]!</span>")
				else
					var/mob/living/simple_mob/vore/kob/k = new(our_turf, c_color = faction, inherit_clothing_faction = TRUE,inherit_name = fort_name)
					k.ai_holder.home_turf = src
					visible_message("<span class ='warning'>\The [k] climbs out of \the [src]!</span>")

/obj/structure/kob/fort/attack_ghost(mob/observer/dead/user as mob)
	if(!ghostjoin)
		return ..()
	update_icon()
	if(!isobserver(user))
		return ..()
	if(jobban_isbanned(user, "GhostRoles"))
		to_chat(user, "<span class='warning'>You cannot inhabit a Kob because you are banned from playing ghost roles.</span>")
		return
	if(!stocked_kobs)
		to_chat(user, "<span class ='warning'>There are no Kobs ready to leave the nest, you will have to wait a little longer! The next Kob is [amount_grown]% ready!</span>")
		return
	if(!ticker || ticker.current_state <= GAME_STATE_PREGAME)
		to_chat(user, "<span class ='warning'>Not yet, wait for the game to start!</span>")
		return
	if(tgui_alert(user, "A Kob is ready to leave the nest. Would you like to play as a Kob?", "Become Kob", list("No","Yes")) == "Yes")
		var/mob/living/simple_mob/vore/kob/k = new(c_color = faction, inherit_clothing_faction = TRUE,inherit_name = fort_name)
		k.forceMove(get_turf(src))
		k.ckey = user.ckey
		stocked_kobs --
		log_and_message_admins("[k.ckey]'s has been spawned as [k] via \the [src].", user)
		visible_message("<span class ='warning'>\The [k] climbs out of \the [src]!</span>")
	return ..()

/obj/structure/kob/fort/MouseDrop_T(mob/living/M, mob/living/user)
	. = ..()
	if(!iskob(M))
		return
	if(M != user)
		if(tgui_alert(user, "Would you like to send [M] into the nest and leave the round?", "Enter Nest", list("No","Yes")) != "Yes")
			return
	else
		if(tgui_alert(user, "Would you like to retire into the nest and leave the round?", "Enter Nest", list("No","Yes")) != "Yes")
			return
	M.visible_message("<span class = 'notice'>\The [M] begins to climb into \the [src]!</span>")
	if(do_after(user, 10 SECONDS, exclusive = TRUE))
		M.visible_message("<span class = 'notice'>\The [M] climbs into \the [src]!</span>")
		qdel(M)
		stocked_kobs ++

/obj/structure/kob/fort/attack_hand(mob/living/user)
	. = ..()
	if(iskob(user))
		var/mob/living/simple_mob/vore/kob/k = user
		if(k.faction != faction)
			if(tgui_alert(k, "Would you like to join this nest's faction?", "Change Faction", list("No","Yes")) != "Yes")
				return
			k.visible_message("<span class = 'notice'>\The [k] is attempting to join \the [src]'s faction!</span>")
			if(do_after(k, 30 SECONDS, exclusive = TRUE))
				k.faction = faction
				k.clothing_color = faction
				if(!k.clothing_type)
					k.clothing_type = rand(1,7)
				k.update_icon()
				k.visible_message("<span class = 'notice'>\The [k] joined \the [src]'s faction!</span>")

/obj/structure/kob/fort/attackby(obj/item/O, mob/user)
	if(istype(O,/obj/item/weapon/reagent_containers/food))
		var/obj/item/weapon/reagent_containers/food/yummers = O
		resource += round(yummers.reagents.total_volume / 4)
		user.drop_from_inventory(yummers)
		visible_message("<span class ='notice'>\The [user] hands a Kob in \the [src] \the [yummers]. The Kobs inside eat \the [yummers].</span>")
		for(var/mob/living/l in yummers)
			l.forceMove(get_turf(src.loc))
		for(var/obj/item/weapon/holder/h in yummers)
			h.forceMove(get_turf(src.loc))
		qdel(yummers)
		playsound(src, 'sound/items/eatfood.ogg', 75, 1)

	else if(istype(O,/obj/item/weapon/holder))
		if(tgui_alert(user,"Are you sure you want to offer [O] to the Kobs in the nest? You probably won't get them back if the Kobs accept them...","Confirm",list("No", "Yes")) != "Yes")
			return
		var/obj/item/weapon/holder/h = O
		if(h.held_mob)
			var/mob/living/l = h.held_mob
			if(l.devourable && l.digestable)
				if(l.client)
					to_chat(user,"<span class = 'warning'>Checking with [l], please stand still.</span>")
					if(tgui_alert(l,"\The [user] is trying to offer you to \the [src] for the Kobs to eat. Is that okay? Your character will be stripped so your items aren't lost.","Confirm",list("No", "Yes"), 10 SECONDS) != "Yes")
						return
				if(!Adjacent(user))
					to_chat(user,"<span class = 'warning'>You need to get closer to \the [src].</span>")
					return
				visible_message("<span class ='warning'>\The [user] hands a Kob in \the [src] \the [l].</span>")
				resource += round(l.mob_size)
				if(l.client)
					resource += 20
					user.drop_from_inventory(h)
					qdel(h)
					to_chat(l,"<span class = 'notice'>Scaly fingers wrap around your body, holding you firmly and pulling you into \the [src]. It's rather gloomy and filled with activity in the dim glow! The hot touch of the Kob who held you is firm enough to ensure you won't get away, while also being gentle enough to not harm you. Still, you're carried inside, deeper away from the outside, and over to a nest with several other Kobs settled and sprawled out, looking at the one carrying you... looking at YOU. Your captor carries you into the nest, and offers you out, dangling you over the Kobs in the nest, each of whom's eyes glitter, and they clamor over one another to get toward you! Jaws flash open, glistening maws puff humid clouds of breath up at you as they coo and humm at the offering! The one who holds you gives a little smile, and tosses you up into the air, and out toward the nest, right over the shoulders of the ones looking to get you. You tumble over and land heavily on soft bedding, whereupon the nest Kobs POUNCE!!! There's no hope for escape, scaly bodies smush and grind against you, pinning you against tummy and thigh and tail. Any clothing or items you had on you is grabbed and yanked away, shortly leaving you bare against the writhing mass of Kobs! Heavy bodies all writhing and wrestling with you at the middle, overpowered and pinned between those smooth scales while the Kobs make a contest of being the one who will have you! The wrestling is rough and hot and heavy, with your small body lost between the writhing heaps of scales and nippy yips! You see an opening though, and try to slink out from between those rolling waves of scale, when suddenly the warm wet of something slick glides over your feet and up across your body!!! You can briefly see the outline of jaws framing your vision as you are yanked up and tossed back into the waiting gullet of a hungry Kob, able to see the disappointed faces of the Kobs who weren't quick enough to claim you. GLLRMMPTCH... Nothing but Kob food, to be used to fuel this Kob fun~</span>")
					var/said_it = FALSE
					for(var/obj/item/W in l)
						if(istype(W, /obj/item/weapon/implant/backup) || istype(W, /obj/item/device/nif))
							continue
						if(!said_it)
							visible_message("<span class ='notice'>\The Kob in \the [src] toss something back out!!!</span>")
							said_it = TRUE
						l.drop_from_inventory(W)
					log_admin("[user] fed [l] to [src], [x],[y],[z].")
					l.ghostize()
					qdel(l)
					playsound(src, 'sound/vore/gulp.ogg', 75, 1)

	else return ..()

/obj/structure/kob/fort/examine(mob/user, infix, suffix)
	. = ..()
	if(stocked_kobs)
		. += "<span class ='warning'>There are Kobs inside!</span>"
	if(iskob(user))
		. += "<span class ='notice'>There are [resource] resources in the nest!</span>"

/obj/structure/kob/fort/red
	faction = "#b00b1e"

/obj/structure/kob/fort/blue
	faction = "#0b3fdb"

/obj/structure/kob/fort/magenta
	faction = "#b000ba"

/obj/structure/kob/fort/yellow
	faction = "#ddbd3f"

/*
/obj/structure/kob/fort/proto
	name = "BASIC Type-K hab"

/obj/structure/kob/fort/proto/Initialize()

	if(name == "kob fort")

	var/list/proto_kob_name = list(
		"Blue",
		"Red",

		"Brown",
	)

	if(!faction)
		faction = random_color()
	update_icon()
	kob_fort_name()
	START_PROCESSING(SSobj, src)
	active_ghost_pods |= src

	if(!set_fluff_types)
		fluff_types = subtypesof(/mob/living/simple_mob/vore/kob/fluff)
		set_fluff_types = TRUE
	return ..()
*/

/obj/structure/kob/wall
	name = "trash wall"
	desc = "It's a wall made of trash!"
	icon_state = "trash_wall1"
	density = TRUE
	anchored = TRUE
	opacity = TRUE

	maxhealth = 1000
	health = 1000

/obj/structure/kob/wall/LateInitialize()
	. = ..()
	icon_state = "trash_wall[rand(1,4)]"

/obj/structure/kob/wall/transparent
	desc = "It's a wall made of trash! It has a hole in it you can see through!"
	opacity = FALSE

/obj/structure/kob/tunnel
	name = "tunnel"
	desc = "Some grubby hole, reinforced by what appears to be garbage."
	icon_state = "trash_hole"

	anchored = TRUE
	density = TRUE

	faction = "kob"
	var/we_have_flag = FALSE
	var/magic = FALSE	//For events and stuff, if true, this tunnel will show up in the list regardless of whether it's in valid range, of if you're in a tunnel with this var, all tunnels of the same faction will show up redardless of range

/obj/structure/kob/tunnel/New(loc, inherited_faction, do_flag = FALSE)
	. = ..()
	if(inherited_faction)
		faction = inherited_faction
	if(do_flag)
		we_have_flag = TRUE
	update_icon()

/obj/structure/kob/tunnel/Initialize()
	. = ..()
	var/area/our_area = get_area(src)
	name = "[our_area.name] tunnel"

/obj/structure/kob/tunnel/Destroy()
	visible_message("<span class = 'warning'>\The [src] collapses!</span>")
	for(var/mob/thing in src.contents)
		visible_message("<span class = 'warning'>\The [thing] tumbles out!</span>")
		thing.forceMove(get_turf(src.loc))

	return ..()

/obj/structure/kob/tunnel/update_icon()
	. = ..()

	if(!we_have_flag)
		return
	cut_overlays()
	var/image/ourimage = image(icon,null,"trash_hole_flag")
	ourimage.color = faction
	ourimage.appearance_flags = RESET_COLOR|KEEP_APART|PIXEL_SCALE
	add_overlay(ourimage)

/obj/structure/kob/tunnel/Bump(atom/A)
	. = ..()
	if(!iskob(A))
		return

	var/mob/living/simple_mob/vore/kob/k = A

	k.visible_message("<span class = 'notice'>\The [k] begins climbing into \the [src]!</span>")
	if(!do_after(k, 3 SECONDS, exclusive = TRUE))
		to_chat(k, "<span class = 'warning'>You didn't go into \the [src]!</span>")
		return

	enter_tunnel(k)

/obj/structure/kob/tunnel/attack_hand(mob/user)
	if(user.loc == src)
		var/choice = tgui_alert(user,"It's dark and gloomy in here. What would you like to do?","Tunnel",list("Exit", "Move"))
		switch(choice)
			if("Exit")
				user.forceMove(get_turf(src.loc))
				user.visible_message("<span class = 'notice'>\The [user] climbs out of \the [src]!</span>")
				return
			if("Move")
				var/list/destinations = list()
				var/turf/myturf = get_turf(src.loc)
				var/datum/planet/planet
				for(var/datum/planet/P in SSplanets.planets)
					if(myturf.z in P.expected_z_levels)
						planet = P
					else
				for(var/obj/structure/kob/tunnel/t in world)
					if(faction != t.faction)
						continue
					if(t == src)
						continue
					if(magic || t.magic)
						destinations |= t
						continue
					if(t.z == z)
						destinations |= t
						continue
					var/turf/targetturf = get_turf(t.loc)
					if(planet)
						if(targetturf.z in planet.expected_z_levels)
							destinations |= t
							continue
						else
					var/above = GetAbove(myturf)
					if(above && t.z == z + 1)
						destinations |= t
						continue
					var/below = GetBelow(myturf)
					if(below && t.z == z - 1)
						destinations |= t

				if(!destinations.len)
					to_chat(user, "<span class = 'warning'>There are no other tunnels connected to this one!</span>")
					return
				if(iskob(user) || user.faction == faction)
					choice = tgui_input_list(user, "Where would you like to go?", "Pick a tunnel", destinations)
					to_chat(user,"<span class = 'notice'>You begin moving...</span>")
				else
					choice = pick(destinations)
					to_chat(user,"<span class = 'warning'>You begin stumbling around in the unfamiliar darkness. . .</span>")
				if(!choice)
					return
				if(!do_after(user, 10 SECONDS, exclusive = TRUE))
					return
				user.forceMove(choice)
				return

	if(user.a_intent != I_HELP)
		return ..()
	if(tgui_alert(user,"Do you want to go into the tunnel?","Enter Tunnel",list("Yes", "No")) != "Yes")
		return
	user.visible_message("<span class = 'notice'>\The [user] begins climbing into \the [src]!</span>")
	if(!do_after(user, 3 SECONDS, exclusive = TRUE))
		to_chat(user, "<span class = 'warning'>You didn't go into \the [src]!</span>")
		return

	enter_tunnel(user)

/obj/structure/kob/tunnel/attack_generic(mob/user, damage, attack_verb)
	. = ..()
	if(!iskob(user) || user.a_intent == I_HURT)
		return ..()
	attack_hand(user)

/obj/structure/kob/tunnel/MouseDrop_T(mob/living/M, mob/living/user)
	. = ..()
	if(!iskob(M))
		return
	if(M != user)
		return

	var/mob/living/simple_mob/vore/kob/k = M

	k.visible_message("<span class = 'notice'>\The [k] begins climbing into \the [src]!</span>")
	if(!do_after(k, 3 SECONDS, exclusive = TRUE))
		to_chat(k, "<span class = 'warning'>You didn't go into \the [src]!</span>")
		return

	enter_tunnel(k)

/obj/structure/kob/tunnel/proc/enter_tunnel(mob/living/simple_mob/vore/kob/k)
	k.visible_message("<span class = 'notice'>\The [k] climbs into \the [src]!</span>")
	k.forceMove(src)
	to_chat(k,"<span class = 'notice'>You are inside of \the [src]. It's dark and gloomy inside of here. You can click upon the tunnel to exit, or travel to another tunnel if there are other tunnels linked to it.</span>")

/obj/structure/kob/tunnel/verb/rename_tunnel(mob/user)
	set name = "Rename Tunnel"
	set desc = "Rename the tunnel!"
	set category = "Object"

	rename_kob_tunnel(user)

/obj/structure/kob/tunnel/proc/rename_kob_tunnel(mob/user, skip_faction = FALSE)
	if(!skip_faction)
		if(user.faction != faction)
			to_chat(user, "<span class = 'warning'>You can't rename this tunnel!</span>")
			return

	if(tgui_alert(user,"Do you want to name this tunnel entrance?","Name Tunnel",list("Yes", "No")) != "Yes")
		return
	var/newname
	newname = sanitizeSafe(tgui_input_text(user,"Name the tunnel! Max 52 chars.", "Name Tunnel",name, MAX_NAME_LEN), MAX_NAME_LEN)
	if (newname)
		name = newname

/obj/structure/kob/tunnel/magic
	magic = TRUE

/obj/structure/trash_pile
	var/next_kob_harvest = 0
	var/kob_busy = FALSE

/obj/structure/trash_pile/examine(mob/user, infix, suffix)
	. = ..()
	if(!iskob(user))
		return
	. += "<span class = 'notice'>A divine site, where one might be able to acquire Holy. Respect is required of all Kobs who encounter such a site as this. \The [src] can provide much, so long as we respect the holy!</span>"

	if(world.time < next_kob_harvest)
		var/cooldowntime = round((next_kob_harvest - world.time) * 0.1)
		. += "<span class = 'warning'>It will be ready in [cooldowntime] seconds.</span>"

/obj/structure/trash_pile/attack_hand(mob/user)
	. = ..()
	if(!iskob(user))
		return
	if(kob_busy)
		to_chat(user, "<span class = 'warning'>Someone else is already searching \the [src]!</span>")
		return
	if(world.time < next_kob_harvest)
		var/cooldowntime = round((next_kob_harvest - world.time) * 0.1)
		to_chat(user, "<span class = 'warning'>It is not time yet, you must wait [cooldowntime] seconds.</span>")
		return
	kob_busy = TRUE
	user.visible_message("<span class = 'notice'>\The [user] rummages in \the [src]...</span>","<span class = 'notice'>You rummage around in \the [src]...</span>", runemessage = "clank clunk...")
	if(!do_after(user, 3 SECONDS, exclusive = TRUE))
		kob_busy = FALSE
		return

	var/this_many = rand(1,5)
	user.visible_message("<span class = 'notice'>\The [user] pulls out [this_many] trash slag!</span>","<span class = 'notice'>You pull out [this_many] Holy!</span>", runemessage = "!!!")
	new /obj/item/stack/material/trash_slag(get_turf(src), this_many)
	var/our_time = rand(3,10) MINUTES

	next_kob_harvest = world.time + our_time
	kob_busy = FALSE

/obj/structure/kob/door
	name = "trash door"
	desc = "Some garbage fashioned to be able to be able to open, close, and lock."

	icon = 'icons/rogue-star/kobs/kobx64.dmi'
	icon_state = "trash_door-closed"
	anchored = TRUE
	density = TRUE

	pixel_x = -16
	plane = MOB_PLANE
	layer = MOB_LAYER

	density = TRUE
	anchored = TRUE
	opacity = TRUE

	maxhealth = 500
	health = 500

	var/isSwitchingStates = FALSE
	var/locked = TRUE

/obj/structure/kob/door/New(loc, our_faction = null)
	. = ..()
	if(our_faction)
		faction = our_faction
	if(faction)
		do_flag()
		verbs |= /obj/structure/kob/door/proc/lock
	else
		verbs |= /obj/structure/kob/door/proc/claim

/obj/structure/kob/door/update_icon()
	. = ..()
	if(density)
		icon_state = "trash_door-closed"
	else
		icon_state = "trash_door-open"

/obj/structure/kob/door/proc/claim()
	set name = "Claim Door"
	set desc = "Claim and lock a door"
	set category = "Object"
	set src in oview(1)

	if(!iskob(usr))
		to_chat(usr, "<span class = 'warning'>You can't claim this door!</span>")
		return
	if(faction)
		to_chat(usr, "<span class = 'warning'>This door has already been claimed!</span>")
		verbs -= /obj/structure/kob/door/proc/claim
		return
	if(usr.faction == "kob")
		to_chat(usr, "<span class = 'warning'>You need to join a kob faction first!</span>")
		return

	faction = usr.faction
	do_flag()
	to_chat(usr, "<span class = 'notice'>You set up a flag and lock the door!</span>")
	verbs -= /obj/structure/kob/door/proc/claim
	verbs |= /obj/structure/kob/door/proc/lock

/obj/structure/kob/door/proc/lock()
	set name = "Toggle Door Lock"
	set desc = "Lock or unlock a door!"
	set category = "Object"
	set src in oview(1)

	if(usr.faction != faction)
		to_chat(usr, "<span class = 'warning'>You can't mess with this door's locks!</span>")
		return

	locked = !locked

	if(locked)
		to_chat(usr, "<span class = 'notice'>You locked the door!</span>")
	else
		to_chat(usr, "<span class = 'notice'>You unlocked the door!</span>")

/obj/structure/kob/door/proc/do_flag()
	cut_overlays()
	if(faction)
		var/image/ourimage = image(icon,null,"trash_door-pole")
		ourimage.appearance_flags = RESET_COLOR|KEEP_APART|PIXEL_SCALE
		add_overlay(ourimage)

		ourimage = image(icon,null,"trash_door-flag")
		ourimage.color = faction
		ourimage.appearance_flags = RESET_COLOR|KEEP_APART|PIXEL_SCALE
		add_overlay(ourimage)

/obj/structure/kob/door/Bumped(atom/user)
	..()
	if(density)
		TryToSwitchState(user)

/obj/structure/kob/door/attack_ai(mob/user as mob)
	if(user.faction == src.faction)
		TryToSwitchState(user)
	else return

/obj/structure/kob/door/AltClick(mob/user as mob)
	. = ..()
	user.setClickCooldown(DEFAULT_ATTACK_COOLDOWN)
	if(!Adjacent(user))
		return
	else if(user.a_intent == I_HURT)
		src.visible_message("<span class='warning'>[user] hammers on \the [src]!</span>", "<span class='warning'>Someone hammers loudly on \the [src]!</span>")
		src.add_fingerprint(user)
		playsound(src, 'sound/weapons/sonic_jackhammer.ogg', 50, 0, 3)
	else if(user.a_intent == I_HELP)
		src.visible_message("[user] knocks on \the [src].", "Someone knocks on \the [src].")
		src.add_fingerprint(user)
		playsound(src, 'sound/machines/door/knock_glass.ogg', 50, 0, 3)
	return

/obj/structure/kob/door/CanPass(atom/movable/mover, turf/target)
	if(istype(mover, /obj/effect/beam))
		return !opacity
	return !density

/obj/structure/kob/door/attack_hand(mob/user as mob)
	return TryToSwitchState(user)

/obj/structure/kob/door/proc/TryToSwitchState(atom/user)
	if(isSwitchingStates) return
	if(ismob(user))
		var/mob/M = user
		if(world.time - user.last_bumped <= 60)
			return
		if(faction && locked && M.faction != faction)
			return
		if(M.client)
			if(iscarbon(M))
				var/mob/living/carbon/C = M
				if(!C.handcuffed)
					SwitchState()
			else
				SwitchState()

/obj/structure/kob/door/proc/SwitchState()
	if(density)
		Open()
	else
		Close()

/obj/structure/kob/door/proc/Open()
	isSwitchingStates = 1
	playsound(src, 'sound/effects/stonedoor_openclose.ogg', 100, 1)
	flick("trash_door-opening",src)
	sleep(5)
	density = FALSE
	set_opacity(0)
	update_icon()
	isSwitchingStates = 0
	update_nearby_tiles()

/obj/structure/kob/door/proc/Close()
	isSwitchingStates = 1
	playsound(src, 'sound/effects/stonedoor_openclose.ogg', 100, 1)
	flick("trash_door-closing",src)
	sleep(5)
	density = TRUE
	set_opacity(1)
	update_icon()
	isSwitchingStates = 0
	update_nearby_tiles()

/obj/structure/kob/stockpile
	name = "stockpile"
	desc = "Quite literally a pile of trash."
	icon_state = "trash_stockpile"
	density = TRUE
	anchored = TRUE

	var/stocked_holy = 0

/obj/structure/kob/stockpile/examine(mob/user, infix, suffix)
	. = ..()
	if(iskob(user))
		. += "<span class = 'danger'>There is [stocked_holy] holy bricks stored here.</span>"

/obj/structure/kob/stockpile/New(loc, our_faction = null)
	. = ..()
	if(our_faction)
		faction = our_faction
	if(faction)
		do_flag()

/obj/structure/kob/stockpile/proc/do_flag()
	cut_overlays()
	if(faction)
		var/image/ourimage = image(icon,null,"trash_stockpile-flag")
		ourimage.color = faction
		ourimage.appearance_flags = RESET_COLOR|KEEP_APART|PIXEL_SCALE
		add_overlay(ourimage)

/obj/structure/kob/stockpile/attack_hand(mob/user)
	. = ..()
	if(!faction || (faction && user.faction == faction))
		var/this_many = 0
		if(stocked_holy > 50)
			this_many = 50
		else
			this_many = stocked_holy

		if(!this_many)
			to_chat(user, "<span class='warning'>There's none left!</span>")
			return
		stocked_holy -= this_many
		new /obj/item/stack/material/trash_slag(get_turf(user), this_many)
		user.visible_message("<span class='notice'>\The [user] removes [this_many] from \the [src]!</span>")

/obj/structure/kob/stockpile/attackby(obj/item/W, mob/living/user)
	. = ..()
	if(istype(W, /obj/item/stack/material/trash_slag))
		var/obj/item/stack/material/trash_slag/h = W
		var/how_many = round(h.get_amount())
		if(how_many >= 1)
			stocked_holy += how_many
			user.drop_from_inventory(h)
			user.visible_message("<span class='notice'>\The [user] loads [how_many] [h] into \the [src]!</span>")
			qdel(h)

/obj/structure/kob/stockpile/Destroy()
	. = ..()
	var/this_many = 0
	while(stocked_holy)
		if(stocked_holy >= 50)
			this_many = 50
			stocked_holy -= this_many
		else
			this_many = stocked_holy
			stocked_holy -= this_many

		new /obj/item/stack/material/trash_slag(get_turf(src), this_many)

/obj/structure/kob/house
	name = "trash house"
	desc = "At least they're honest."
	icon_state = "trash_house"

	density = TRUE
	anchored = TRUE

	var/locked = FALSE
	var/kob_light_color

/obj/structure/kob/house/update_icon()
	. = ..()
	cut_overlays()
	var/image/ourimage
	if(contents.len)
		if(kob_light_color)
			ourimage = image(icon,null,"trash_house_lights")
			ourimage.color = kob_light_color
		else
			ourimage = image(icon,null,"trash_house_lights-b")
		ourimage.appearance_flags = RESET_COLOR|KEEP_APART|PIXEL_SCALE
		ourimage.plane = PLANE_LIGHTING_ABOVE
		add_overlay(ourimage)
	if(locked)
		ourimage = image(icon,null,"trash_house_door")
		ourimage.appearance_flags = RESET_COLOR|KEEP_APART|PIXEL_SCALE
		add_overlay(ourimage)

/obj/structure/kob/house/attack_hand(mob/living/user)
	. = ..()
	user.setClickCooldown(user.get_attack_speed())
	var/list/containted_mobs = list()
	for(var/mob/m in src.contents)
		if(m == user)
			continue
		if(isliving(m))
			containted_mobs |= m

	if(user.loc == src)
		var/list/options = list("Exit", "Toggle Lock")
		if(!kob_light_color)
			options |= "Light Color"
		if(containted_mobs.len)
			options |= "Examine"
			options |= "Eat"

		options |= "Cancel"
		var/choice = tgui_alert(user,"It's pretty cozy in here! What would you like to do?","House", options)
		switch(choice)
			if("Exit")
				locked = FALSE
				to_chat(user, "<span class = 'notice'>You begin climbing out of \the [src]. . .</span>")
				if(do_after(user, 10 SECONDS, exclusive = TRUE))
					user.forceMove(get_turf(src.loc))
					user.visible_message("<span class = 'notice'>\The [user] climbs out of \the [src]!</span>")
					update_icon()
				return
			if("Toggle Lock")
				locked = !locked
				if(locked)
					to_chat(user, "<span class = 'notice'>You locked the door.</span>")
				else
					to_chat(user, "<span class = 'notice'>You unlocked the door.</span>")
				visible_message("<span class = 'notice'>\The [src] clicks. . .</span>")
				update_icon()
				return
			if("Examine")
				var/mob/ex_choice
				if(containted_mobs.len == 1)
					ex_choice = pick(containted_mobs)
				else
					ex_choice = tgui_input_list(user,"Who would you like to examine?","Examine", containted_mobs)
				if(!ex_choice)
					return

				var/list/results = ex_choice.examine(user)
				if(!results || !results.len)
					results = list("You were unable to examine that. Tell a developer!")
				to_chat(user, jointext(results, "<br>"))
				return
			if("Eat")
				var/mob/eat_choice
				if(containted_mobs.len == 1)
					eat_choice = pick(containted_mobs)
				else
					eat_choice = tgui_input_list(user,"Who would you like to eat?","Eat", containted_mobs)

				if(eat_choice)
					user.feed_grabbed_to_self(user, eat_choice)
					return
			if("Light Color")
				if(iskob(user))
					var/mob/living/simple_mob/vore/kob/k = user
					if(k.clothing_color)
						if(tgui_alert(k, "Will you color the lights the same as your clothes? You only get to pick once.", "Light Color", list("New Color","My Color")) == "My Color")
							kob_light_color = k.clothing_color
							update_icon()
							return

				var/new_color = input(user,"What color will the lights be? You only get to pick once.","Light Color") as null|color
				if(new_color)
					kob_light_color = new_color
					update_icon()
				return
			if("Cancel")
				return

	if(locked && containted_mobs.len)
		to_chat(user, "<span class = 'warning'>The door is locked, you can't enter \the [src].</span>")
		return
	if(user.a_intent != I_HELP)
		return ..()
	if(tgui_alert(user,"Do you want to go into the [src]?","Enter House",list("Yes", "No")) != "Yes")
		return
	if(!do_after(user, 10 SECONDS, exclusive = TRUE))
		to_chat(user, "<span class = 'warning'>You didn't go into \the [src]!</span>")
		return
	user.forceMove(src)
	user.visible_message("<span class = 'notice'>\The [user] climbs into \the [src]!</span>")
	update_icon()

/obj/structure/kob/house/Destroy()
	var/turf/myturf = get_turf(src.loc)
	for(var/atom/movable/A in src.contents)
		A.forceMove(myturf)
	..()
