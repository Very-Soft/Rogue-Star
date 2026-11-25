//RS FILE
//Created by VerySoft~
//Yes, I know, kobs are very complicated.

///// TO DO /////
/*

Rest sprites
Writing

*/
var/global/list/all_kobs = list()
var/global/list/kob_name_syllables = list(
	"aba","awa","ara","awo","ada",
	"ba","bo","bi","bonk",
	"de","da","di","donk",
	"egy","eg",
	"fa","fah","fo","foh",
	"gronk","grunk","grug","gru","gro","gri",
	"ha","hu","honk",
	"igg","ig","ia","iwa",
	"ko","korf","kah","ke","kip","konk",
	"mu","mun","murl","mab","man",
	"pa","pof","pom","pab","por","pu","ponk",
	"qu","qi",
	"ra","rah","raf","rahf","rur","ru","ror","rai","ray","roi","ronk",
	"si","sai","su","sonk","sel","soos","sos",
	"tho","thoom","thur","til","tai","tel","tal","tonk",
	"ura","uwa","uwu",
	"vi","vah","vor","vel","voh","vonk",
	"yi","yee","yav","yonk",
	"zo","zi","zoi","zel","zonk"
	)

/datum/category_item/catalogue/fauna/kob
	name = "Alien Wildlife - kob"
	desc = "KOBS WOW!!! Someone should write some info for them..."
	value = CATALOGUER_REWARD_MEDIUM

/mob/living/simple_mob/vore/kob
	low_priority = FALSE
	name = "kob"
	desc = "It's a kob!"
	icon_state = "kob"
	icon_living = "kob_base"
	icon_dead = "kob_dead"
	icon_rest = "kob_rest"
	icon = 'icons/rogue-star/kobs/kobs.dmi'

	faction = "kob"
	maxHealth = 60
	health = 60
	movement_cooldown = 0
	meat_amount = 3
	meat_type = /obj/item/weapon/reagent_containers/food/snacks/meat

	response_help = "hugs"
	response_disarm = "pushes"
	response_harm = "punches"

	harm_intent_damage = 2
	melee_damage_lower = 2
	melee_damage_upper = 20

	min_oxy = 1
	max_oxy = 0
	min_tox = 0
	max_tox = 0
	min_co2 = 0
	max_co2 = 0
	min_n2 = 0
	max_n2 = 0
	minbodytemp = 150
	maxbodytemp = 800

	has_hands = TRUE
	humanoid_hands = TRUE

	see_in_dark = 15

	catalogue_data = list(/datum/category_item/catalogue/fauna/kob)

	attacktext = list("bapped", "kicked", "chomped", "yelled at")
	friendly = list("hugs", "pats", "boops", "honks at")

	ai_holder_type = /datum/ai_holder/simple_mob/melee/evasive/kob

	mob_size = MOB_SMALL
	mob_class = MOB_CLASS_HUMANOID

	gender = "plural"

	has_langs = list(LANGUAGE_GALCOM, LANGUAGE_DRUDAKAR)
	say_list_type = /datum/say_list/kob

	loot_list = list(/obj/item/weapon/bone/horn = 100)
	butchery_loot = list(\
		/obj/item/stack/animalhide = 3,\
		/obj/item/weapon/bone/horn = 1\
		)

	voice_name = "some kob"
	load_owner = "seriouslydontsavethis"

	var/static/list/overlays_cache = list()

	var/marking_color
	var/horn_color
	var/eye_color
	var/clothing_color

	var/horn_type
	var/clothing_type
	var/marking_type
	var/set_kob = FALSE
	var/myname
	var/fortname

	var/forget_attacker_ticker = 0

/////////////////////////////////////// Vore stuff///////////////////////////////////////////
	var/obj/belly/kob/tail_belly
	var/tail_fullness = 0
	var/tail_capacity = 2
	var/vore_absorb_mechanics = TRUE	//If false, the kob won't adjust its health and size when it absorbs things

	swallowTime = 5 SECONDS
	vore_active = 1
	vore_capacity = 2
	vore_bump_chance = 1
	vore_bump_emote	= "greedily homms at"
	vore_ignores_undigestable = 0
	vore_default_mode = DM_DIGEST
	vore_icons = SA_ICON_LIVING
	vore_stomach_name = "Stomach"
	vore_default_contamination_flavor = "Wet"
	vore_default_contamination_color = "grey"
	vore_default_item_mode = IM_DIGEST

	selective_preference = DM_ABSORB

	vore_pounce_chance = 30
	vore_pounce_cooldown = 20 SECONDS
	vore_pounce_successrate	= 150
	vore_pounce_falloff = 1
	vore_pounce_maxhealth = 100
	can_be_drop_pred = TRUE
	can_be_drop_prey = TRUE
	throw_vore = FALSE //Meme strats forbidden
	ssd_vore = TRUE

/datum/say_list/kob
	speak = list("*yip","*yap","Honk!","Gronk...","YONK!!!","I used to be an adventurer. Then I found holy...", "Weather's turning.", )
	emote_hear = list("puffs", "huffs", "rumbles", "gyoohs","pants", "snoofs")
	emote_see = list("sways its tail", "stretches", "yawns", "turns their head")
	say_maybe_target = list("What's that?")
	say_got_target = list("OH NO A ENEMY!!!", "It's an enemy!")
	say_understood = list("Yeah!", "Okay!", "Sure!")
	say_cannot = list("I can't!")
	say_threaten = list("HEY!!! Go AWAY!", "Get OUTTA HERE!", "SHOO!!!", "Not WANT you here!", "No no NO! Go away from here!")
	say_stand_down = list("Yeah, better go...","Yeah get!","Kyahaha~")
	say_escalate = list("I'm gonna get them!", "Don't let them escape!", "Never should have come here!", "Meat's back on the menu!", "KYAH!!!","Now I'm MAD! RAWR!!!")
	threaten_sound = 'sound/weapons/TargetOn.ogg'
	stand_down_sound = 'sound/weapons/TargetOff.ogg'

/mob/living/simple_mob/vore/kob/examine(mob/user)
	. = ..()
	if(user == src)
		return
	if(iskob(user))
		var/mob/living/simple_mob/vore/kob/k = user
		if(faction == "kob")
			. += SPAN_NOTICE("They are an unaffiliated Kob. They are not part of any faction.")
		else if(k.faction == "kob")
			. += span_orange("They are a part of a faction, but you are not, so as long as you don't mess with them you should be good.")
		else if(faction != k.faction)
			. += SPAN_DANGER("They aren't a part of your faction! ! !")
		else
			. += span_green("They are a part of your faction~ This is a friend!")

/mob/living/simple_mob/vore/kob/init_vore()
	..()
	var/obj/belly/kob/B = vore_selected
	B.name = "stomach"
	B.desc = "It's [name]'s tumby..."
	B.mode_flags = DM_FLAG_THICKBELLY | DM_FLAG_NUMBING
	B.belly_fullscreen = "yet_another_tumby"
	B.digest_brute = 1
	B.digest_burn = 0.05
	B.digestchance = 0
	B.absorbchance = 0
	B.escapechance = 15
	B.transferchance = 10
	B.autotransferlocation = "tail"
	B.autotransferwait = 30 SECONDS
	B.autotransferchance = 25
	B.transferlocation = "tail"

	B = new /obj/belly/kob(src)
	B.immutable = TRUE
	B.mode_flags = DM_FLAG_THICKBELLY | DM_FLAG_NUMBING | DM_FLAG_JAMSENSORS
	B.digestchance = 0
	B.digest_brute = 0
	B.digest_burn = 0
	B.absorbchance = 0
	B.escapable = TRUE
	B.escapechance = 0
	B.digest_mode = DM_SELECT
	B.name = "tail"
	B.desc = "You're pressed into [name]'s tail..."
	B.belly_fullscreen = "base"
	B.fancy_vore = 1
	B.vore_verb = "absorb"
	B.transferchance = 10
	B.transferlocation = "stomach"
	tail_belly = B

/obj/belly/kob/absorb_living(mob/living/M)
	. = ..()
	if(!iskob(owner))	//Did you know that if you save your bellies while you're a mob, you also save the belly type? lol
		return
	var/mob/living/simple_mob/vore/kob/k = owner
	if(!k.vore_absorb_mechanics)
		return
	if(M.stat == DEAD)
		return
	k.update_fullness()
	if(prob(50))
		var/list/bwomp = list("bwomp","BWOMP","gllrnnn")
		if(!owner.client)
			bwomp += list("\"All mine~\"", "\"Kehehe~\"", "\"Ouh~ You got real soft~\"")
		if(!M.client)
			bwomp += list("\"hhlmmph!\"", "\"mmph...\"")
		else if(!owner.client)
			to_chat(M, "<span class = 'notice'>You've been absorbed by a Kob! You can here for as long as you like. You can also ghost out of here and join the team of the Kob that absorbed you when you are ready, if you should happen to feel like doing so! Though, doing so will make returning to your original body impossible.</span>")
		owner.visible_message(runemessage = pick(bwomp))

/obj/belly/kob/unabsorb_living(mob/living/M)
	. = ..()
	var/mob/living/simple_mob/vore/kob/k = owner
	if(k.vore_absorb_mechanics)
		k.update_fullness()

/obj/belly/kob/process(wait)
	. = ..()
	if(!iskob(owner))
		return
	var/mob/living/simple_mob/vore/kob/K = owner
	if(!contents.len)
		return
	for(var/mob/living/thing in contents)
		if(!isliving(thing))
			continue
		if(thing.stat)
			continue
		if(!thing.resting)	//Kobs heal quickly when resting, but let's say if you rest you're giving in
			continue
		if(!thing.absorbed)
			continue
		switch(digest_mode)
			if(DM_ABSORB)
				if(thing.nutrition < 250)
					K.adjust_nutrition(thing.nutrition)
					thing.nutrition = 0
				else
					K.adjust_nutrition(250)
					thing.adjust_nutrition(-250)
			else
				if(K.tail_belly)
					if(src != K.tail_belly)
						transfer_contents(thing, K.tail_belly)

/mob/living/simple_mob/vore/kob/animal_nom(mob/living/T in living_mobs(1))
	if(client)
		return ..()
	ai_holder.set_busy(TRUE)
	T.stop_pulling()
	. = ..()
	ai_holder.set_busy(FALSE)


//////////PROCS AND JUNK//////////

/mob/living/simple_mob/vore/kob/New(b_color, m_color, h_color, e_color, c_color, inherit_clothing_faction,inherit_name)
	if(b_color)
		color = b_color
	if(m_color)
		marking_color = m_color
	if(h_color)
		horn_color = h_color
	if(e_color)
		eye_color = e_color
	if(c_color)
		clothing_color = c_color
		if(inherit_clothing_faction)
			faction = clothing_color
	if(inherit_name)
		fortname = inherit_name
	return ..()

/mob/living/simple_mob/vore/kob/Initialize()
	. = ..()

	forget_attacker_ticker = rand(50,100)
	kob_setup()
	all_kobs |= src
	movement_cooldown = movement_cooldown + rand(-1,1)

/mob/living/simple_mob/vore/kob/Destroy()
	. = ..()
	all_kobs -= src

/mob/living/simple_mob/vore/kob/Life()
	. = ..()
	if(client || absorbed)
		return

	if(!isturf(loc))
		if(!resting)
			var/friend = FALSE
			if(ismicro(loc) || isbelly(loc))
				if(isliving(loc.loc))
					var/mob/living/L = loc.loc
					if(L.faction == faction)
						friend = TRUE
			if(!friend && prob(25))
				resist()
				return
	var/rest_threshold = 2
	if(ai_holder.stance != STANCE_IDLE)
		rest_threshold = 4

	if(resting)
		if(health < maxHealth && nutrition > 150)
			return
		lay_down()
		return
	else if(nutrition > 150 && health <= (maxHealth / rest_threshold))
		lay_down()
		return

	if(!ai_holder.attackers.len)
		return
	if(forget_attacker_ticker <= 0)
		ai_holder.attackers	-= pick(ai_holder.attackers)
		forget_attacker_ticker = rand(50,100)
	forget_attacker_ticker --

/mob/living/simple_mob/vore/kob/update_icon()
	. = ..()

	if(!vore_fullness && !tail_fullness)
		kob_build_sprite()
		return 0
	else if((stat == CONSCIOUS) && (!icon_rest || !resting || !incapacitated(INCAPACITATION_DISABLED)) && (vore_icons & SA_ICON_LIVING))
		icon_state = "[icon_living]-[vore_fullness]-[tail_fullness]"
	else if(stat >= DEAD && (vore_icons & SA_ICON_DEAD))
		icon_state = "[icon_dead]-[vore_fullness]-[tail_fullness]"
	else if(((stat == UNCONSCIOUS) || resting || incapacitated(INCAPACITATION_DISABLED) ) && icon_rest && (vore_icons & SA_ICON_REST))
		icon_state = "[icon_rest]-[vore_fullness]-[tail_fullness]"

	kob_build_sprite()

/*
/mob/living/simple_mob/vore/kob/update_icons()
	. = ..()
*/

/mob/living/simple_mob/vore/kob/update_fullness()
	var/new_fullness = 0
	var/do_hp = initial(maxHealth)
	var/do_size = 1
	for(var/obj/belly/B as anything in vore_organs)
		if(B == tail_belly)
			continue
		for(var/mob/living/M in B)
			new_fullness += M.size_multiplier
			if(M.absorbed && M.stat != DEAD && vore_absorb_mechanics)
				do_hp += round(M.health * 0.25,1)
				do_size += M.size_multiplier * (0.25 * (mob_size/20))
	new_fullness = new_fullness / size_multiplier
	new_fullness = round(new_fullness, 1)
	vore_fullness = min(vore_capacity, new_fullness)
	new_fullness = 0
	for(var/mob/living/M in tail_belly)
		new_fullness += M.size_multiplier
		if(M.absorbed && M.stat != DEAD && vore_absorb_mechanics)
			do_hp += round(M.health * 0.25,1)
			do_size += M.size_multiplier * (0.25 * (mob_size/20))
	new_fullness = new_fullness / size_multiplier
	new_fullness = round(new_fullness, 1)
	tail_fullness = min(tail_capacity, new_fullness)

	if(vore_absorb_mechanics)
		if(maxHealth != do_hp)
			setMaxHealth(do_hp)
		if(size_multiplier != do_size)
			resize(do_size,uncapped = TRUE)

/mob/living/simple_mob/vore/kob/attackby(var/obj/item/weapon/reagent_containers/food/snacks/O as obj, var/mob/user as mob)
	if(!istype(O, /obj/item/weapon/reagent_containers))
		return ..()
	if(resting)
		to_chat(user, "<span class='notice'>\The [src] is napping, and doesn't respond to \the [O].</span>")
		return
	if(nutrition >= max_nutrition)
		if(user == src)
			to_chat(src, "<span class='notice'>You're too full to eat another bite.</span>")
			return
		to_chat(user, "<span class='notice'>\The [src] seems too full to eat.</span>")
		return

	var/holy_amount = O.reagents?.get_reagent_amount("holyessence")

	if(holy_amount)
		if(stat == DEAD)
			revive()
			sight = initial(sight)
			see_in_dark = initial(see_in_dark)
			see_invisible = initial(see_invisible)
			update_icon()
			visible_message("\The [src] lifts their head and looks at [user].", runemessage = "looks at [user]")

		adjustBruteLoss(-50)
		adjustFireLoss(-50)
		if(nutrition < 500) //Don't overfill, but if we're running low let's fix that
			nutrition += 500
		var/list/holy_adjectives = list("GREAT","WONDERFUL","DIVINE","HOLY","SPECIAL","DELIGHTFUL","AMAZING","LOVELY","MAGICAL")
		to_chat(src, "<span class='notice'>This tastes [pick(holy_adjectives)]!!!</span>")

	if(stat)
		return ..()

	if(!istype(O, /obj/item/weapon/reagent_containers/food/snacks))
		return ..()

	if(istype(O, /obj/item/weapon/reagent_containers/food/snacks/kob_food))
		egg_tf()
	user.setClickCooldown(user.get_attack_speed(O))
	if(O.reagents)
		O.reagents.trans_to_mob(src, O.bitesize, CHEM_INGEST)
		adjust_nutrition(O.bitesize * 5)
	O.bitecount ++
	O.On_Consume(src)
	if(O)
		to_chat(user, "<span class='notice'>\The [src] takes a bite of \the [O].</span>")
		if(user != src)
			to_chat(src, "<span class='notice'>\The [user] feeds \the [O] to you.</span>")
	playsound(src, 'sound/items/eatfood.ogg', 75, 1)

/mob/living/simple_mob/vore/kob/adjustBruteLoss(amount, include_robo)
	. = ..()
	damagestun(amount)

/mob/living/simple_mob/vore/kob/adjustFireLoss(amount, include_robo)
	. = ..()
	damagestun(amount)

/mob/living/simple_mob/vore/kob/attack_hand(mob/living/carbon/human/M as mob)

	if(stat == DEAD)
		return ..()
	if(M.a_intent == I_GRAB || M.a_intent == I_HURT)
		return ..()
	if(M.a_intent == I_DISARM)
		. = ..()
		var/chance = 20 + ((M.size_multiplier - size_multiplier) * 5)
		if(ishuman(M))
			chance += 10
		if(prob(chance))
			Weaken(rand(3,8))
		return
	playsound(src, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
	if(resting)
		M.visible_message("<span class='notice'>\The [M.name] shakes \the [src] awake from their nap.</span>","<span class='notice'>You shake \the [src] awake!</span>")
		lay_down()
		ai_holder.go_wake()
		return
	if(M.zone_sel.selecting == BP_HEAD)
		M.visible_message( \
			"<span class='notice'>[M] pats \the [src] on the head.</span>", \
			"<span class='notice'>You pat \the [src] on the head.</span>", )
		if(client)
			return
		if(prob(10))
			visible_message("<span class='notice'>\The [src] leans into [M]'s hand and trills happily.</span>")
	else if(M.zone_sel.selecting == BP_R_HAND || M.zone_sel.selecting == BP_L_HAND)
		M.visible_message( \
			"<span class='notice'>[M] shakes \the [src]'s hand.</span>", \
			"<span class='notice'>You shake \the [src]'s hand.</span>", )
		if(client)
			return
		if(prob(10))
			visible_message("<span class='notice'>\The [src] looks a little anxious at [M]'s attempt to steal their hand...</span>")
	else if(M.zone_sel.selecting == "mouth")
		if(will_eat(M) && !client)
			visible_message("<span class='notice'>\The [M] reaches for \the [src]'s snout.</span>!")
			M.visible_message("<span class='danger'>\The [src] pushes [M] over, pinning them down to devour!</span>!","<span class = 'notice'>\The [src]'s jaws part as your hand approaches their snoot! A hot, slick tongue laps over your hands as they pounce upon you at this offering of your body to their mouth~ How kind of you!</span>")
			M.Weaken(5)
			playsound(src, pick(bodyfall_sound), 75, 1)
			animal_nom(M)
			return
		M.visible_message( \
			"<span class='notice'>[M] boops \the [src]'s nose.</span>", \
			"<span class='notice'>You boop \the [src] on the nose.</span>", )
		if(client)
			return
		if(prob(10))
			visible_message("<span class='notice'>\The [src]'s honks goofily at [M].</span>")
	else if(M.zone_sel.selecting == BP_GROIN)
		M.visible_message( \
			"<span class='notice'>[M] rubs \the [src]'s tummy...</span>", \
			"<span class='notice'>You rub \the [src]'s tummy...</span>")
		if(client)
			return
		visible_message("<span class='notice'>\The [src] coos happily and presses their tummy into [M]'s hand, letting it squish~</span>")
	else
		return ..()


/mob/living/simple_mob/vore/kob/Login()
	. = ..()

	verbs -= /mob/living/simple_mob/proc/set_name

	if(faction == "kob")
		to_chat(src, "<span class ='notice'>You are a Kob, a force of nature in garbage management. \
		You can take just about anything that's not nailed down and turn it into Trash slag bricks, or as the Kobs call it, Holy. \
		Holy can be used to craft structures and items that can support your cause in Kob warfare. Your enemy in Kob warfare are Kobs of other faction colors, or they would be \
		</span>if you were a part of a faction! <span class ='notice'>You are an </span>unaffiliated Kob<span class ='notice'>, which means that you are not presently involved with any Kob faction, and should not be bothered by any warring Kobs. \
		Should you find a faction you wish to join, you can click on one of their forts to join their side. Otherwise, so long as you stay out of the warring Kobs' way, you are free from war...\
		<br><br></span>\
		<span class ='warning'>Or maybe you will start your own faction and begin a war to take all of the Holy for yourself?</span>\
		<br><br>\
		<span class ='notice'>Either way, you can tell whether or not a Kob is a part of your faction by looking at their clothes, or examining them. \
		Enemy Kobs will typically attempt to attack or devour you on sight, while talking is not impossible, you should expect a fight if you encounter an enemy Kob.\
		<br><br>\
		Some Kobs may be unaffiliated with any faction, like yourself, and you can tell this by examining them. \
		These Kobs are not participating in war, and so should be left alone as long as they are not interfering with war efforts or territory.</span>\
		<br><br>\
		<span class ='warning'><b>You are not enemies with the station crew.</b></span> \
		<span class ='notice'>You like the crew, they produce the trash you want. You should avoid getting in their way or causing undue harm to them, \
		as this will reduce their trash production. If the crew is on your side, you may earn advantages in your garbage conquest. \
		You are only ever at war with the station crew when the station crew initiates war with you, and even then, only with those who attack your faction.</span>")

	else
		to_chat(src, "<span class ='notice'>You are a Kob, a force of nature in garbage management. \
		You can take just about anything that's not nailed down and turn it into Trash slag bricks, or as the Kobs call it, Holy. \
		Holy can be used to craft structures and items that can support your cause in Kob warfare. Your enemy in Kob warfare are Kobs of other faction colors. \
		You can tell them apart by looking at their clothes, or examining them. \
		Enemy Kobs will typically attempt to attack or devour you on sight, while talking is not impossible, you should expect a fight if you encounter an enemy Kob.\
		<br><br>\
		Some Kobs may be unaffiliated with any faction, and you can tell this by examining them. \
		These Kobs are not participating in war, and so should be left alone as long as they are not interfering with your efforts or territory.</span>\
		<br><br>\
		<span class ='warning'><b>You are not enemies with the station crew.</b></span> \
		<span class ='notice'>You like the crew, they produce the trash you want. You should avoid getting in their way or causing undue harm to them, \
		as this will reduce their trash production. If the crew is on your side, you may earn advantages in your garbage conquest. \
		You are only ever at war with the station crew when the station crew initiates war with you, and even then, only with those who attack your faction.</span>")

	to_chat(src, "<span class ='notice'>For more info on what you can do, check out your 'Kob info' verb!</span>")

/mob/living/simple_mob/vore/kob/get_available_emotes()

	var/list/fulllist = list()

	fulllist |= _simple_mob_default_emotes
	fulllist |= _human_default_emotes
	return fulllist

/mob/living/simple_mob/vore/kob/UnarmedAttack(var/atom/A, var/proximity)
	if(a_intent != I_HELP)
		return ..()
	if(!isliving(A))
		return ..()
	var/mob/living/H = A
	if(!H.attempt_to_scoop(src))
		H.attack_hand(src)
		setClickCooldown(get_attack_speed())

/mob/living/simple_mob/vore/kob/IIsAlly(mob/living/L)
	if(!ismob(L))
		return FALSE
	if(ai_holder.check_attacker(L))
		return ..()
	if(iskob(L) && faction != L.faction && L.faction != "kob")
		return ..()
	if(L.ai_holder)
		if(!L.ai_holder.hostile)
			return TRUE
	if(L.faction == "neutral" || L.faction == "kob")
		return TRUE
	return ..()

/mob/living/simple_mob/vore/kob/stun_effect_act(stun_amount, agony_amount, def_zone, used_weapon)
	var/stunDam = 0
	var/agonyDam = 0
	var/sr
	if(!shock_resist)
		sr = 1
	else
		sr = shock_resist

	if(stun_amount)
		stunDam = (stun_amount * 0.5) / sr
		Stun(stunDam)
	if(agony_amount)
		agonyDam = (agony_amount * 0.5) / sr
		Weaken(agonyDam)

	if(used_weapon && istype(used_weapon, /obj/item/weapon))
		var/obj/item/weapon/w = used_weapon
		if(isliving(w.loc) && ai_holder)
			ai_holder.react_to_attack(w.loc)

//////////KOB SPECIFIC PROCS//////////

/atom/proc/random_color()
	var/color = rgb(rand(25,230), rand(25,230), rand(25,230))	//No pure white or pure black, as that generally won't look good with grayscale sprites
	return color

/mob/living/simple_mob/vore/kob/proc/kob_setup()
	kob_name()

	var/static/list/possiblebody = list("#423c2f" = 10,"#2f3c42" = 10,"#372f42" = 10,"#1f1f1f" = 10,"#2f3e4f" = 10,"#6b5a3f" = 10,"#ad9772" = 10,"#e3d7c3" = 10,"#f2b24b" = 1,"#3d374f" = 10,"#697596" = 10,"#846996" = 10,"#483b52" = 10,"#9ea36a" = 10,"#294521" = 10,"#082101" = 10,"#0f7a5a" = 1,"#e6c5e5" = 1,"#5e5441" = 10,"#301f11" = 10,"#c69c85" = 10,"#301711" = 10,"#75473d" = 10,"#7a2411" = 10,"#a81f00" = 1,"#a81f00" = 1,"#8bafb0" = 1)
	var/static/list/possiblemarking = list("#800000" = 1,"#804200" = 1,"#808000" = 1,"#428000" = 1,"#008000" = 1,"#008042" = 1,"#008080" = 1,"#004280" = 1,"#000080" = 1,"#420080" = 1,"#800080" = 1,"#800042" = 1,"#f2b24b" = 1,"#8bafb0" = 1)
	var/static/list/possiblehorns = list("#241515" = 10, "#242415" = 10, "#172415" = 10, "#152422" = 10,"#151624" = 10,"#1d1524" = 10,"#24151e" = 10,"#b07b9a" = 5,"#543b28" = 10,"#917a59" = 10, "#ffc965" = 1,"#a3d5d7" = 1)
	var/static/list/possibleeyes = list("#ba0000" = 1,"#ba5100" = 1,"#bab400" = 1,"#2bba00" = 1,"#00ba51" = 1,"#00b7ba" = 1,"#001cba" = 1,"#4e00ba" = 1,"#ba00ba" = 1,"#ba0057" = 1,"#de8509" = 1,"#90d6de" = 1,"#333333" = 1,"#362929" = 1,"#471b1b" = 1,"#1b1b47" = 1,"#3b1b47" = 1,"#20471b" = 1,)
	var/static/list/possibleclothing = list("#3d352b" = 1,"#292826" = 1,"#6b5952" = 1,"#6b5952" = 1,"#871b2b" = 1,"#1b4187" = 1,"#56bd26" = 1,"#541353" = 1)

	if(set_kob)
		update_icon()
		return
	if(!clothing_type)
		if(!clothing_color)
			clothing_type = rand(0,7)
		else
			clothing_type = rand(1,7)
	if(!horn_type)
		horn_type = rand(0,2)
	if(!marking_type)
		marking_type = rand(0,0)
	if(!color)
		if(prob(90))
			color = pickweight(possiblebody)
		else
			color = random_color()
	if(!marking_color)
		if(prob(75))
			marking_color = pickweight(possiblemarking)
		else
			marking_color = random_color()
	if(!eye_color)
		if(prob(50))
			eye_color = pickweight(possibleeyes)
		else
			eye_color = random_color()
	if(!horn_color)
		if(horn_type)
			if(prob(90))
				horn_color = pickweight(possiblehorns)
			else
				horn_color = random_color()
	if(!clothing_color)
		if(clothing_type)
			if(prob(50))
				clothing_color = pickweight(possibleclothing)
			else
				clothing_color = random_color()


	update_icon()

/mob/living/simple_mob/vore/kob/proc/kob_name()
	var/ourname

	if(!fortname)
		var/how_many_syllables = rand(3,6)

		while(how_many_syllables)
			how_many_syllables --

			ourname = "[ourname][pick(kob_name_syllables)]"
	else
		ourname = fortname
	ourname = capitalize(ourname)

	if(!myname)
		myname = pick(kob_name_syllables)

	myname = capitalize(myname)
	ourname = "[ourname] [myname]"
	name = ourname
	real_name = ourname

/mob/living/simple_mob/vore/kob/proc/kob_build_sprite()

	var/marking_key = "marking-[marking_type]-[marking_color]"
	var/clothing_key = "clothing-[clothing_type]-[clothing_color]"
	var/horn_key = "horn-[horn_type]-[horn_color]"
	var/eye_key = "eye-[eye_color]"

	var/our_state = "base"	//For helping the images know what icon state they should be grabbing
	if(icon_state == icon_living)
		our_state = "base"
	if(icon_state == icon_rest)
		our_state = "rest"
	if(icon_state == icon_dead)
		cut_overlays()
		return

	/////LOWEST LAYER/////
	if(marking_type)
		var/image/marking_image = overlays_cache[marking_key+our_state]
		if(!marking_image)
			marking_image = image(icon,null,"kob_marking_[our_state]-[marking_type]")
			marking_image.color = marking_color
			marking_image.appearance_flags = RESET_COLOR|KEEP_APART|PIXEL_SCALE
			overlays_cache[marking_key+our_state] = marking_image
		add_overlay(marking_image)

	if(horn_type)
		var/image/horn_image = overlays_cache[horn_key+our_state]
		if(!horn_image)
			horn_image = image(icon,null,"kob_horn_[our_state]-[horn_type]")
			horn_image.color = horn_color
			horn_image.appearance_flags = RESET_COLOR|KEEP_APART|PIXEL_SCALE
			overlays_cache[horn_key+our_state] = horn_image
		add_overlay(horn_image)

	var/image/eye_image = overlays_cache[eye_key+our_state]
	if(!eye_image)
		eye_image = image(icon,null,"kob_eye_[our_state]")
		eye_image.color = eye_color
		eye_image.appearance_flags = RESET_COLOR|KEEP_APART|PIXEL_SCALE
		overlays_cache[eye_key+our_state] = eye_image
	add_overlay(eye_image)

	if(clothing_type)
		var/image/clothing_image = overlays_cache["[clothing_key][our_state][vore_fullness][tail_fullness]"]
		if(!clothing_image)
			if(vore_fullness || tail_fullness)
				clothing_image = image(icon,null,"kob_clothes_[our_state]-[clothing_type]-[vore_fullness]-[tail_fullness]")
			else
				clothing_image = image(icon,null,"kob_clothes_[our_state]-[clothing_type]")
			clothing_image.color = clothing_color
			clothing_image.appearance_flags = RESET_COLOR|KEEP_APART|PIXEL_SCALE
			overlays_cache[clothing_key+our_state] = clothing_image
		add_overlay(clothing_image)

	/////HIGHEST LAYER/////

/mob/living/simple_mob/vore/kob/verb/kob_info()
	set name = "Kob Info"
	set desc = "Get more info about Kobs!"
	set category = "Kob"

	to_chat(src, "<span class ='notice'>You are a Kob, a force of nature in garbage management. \
	You can take just about anything that's not nailed down and turn it into Trash slag bricks, or as the Kobs call it, Holy. \
	Holy can be used to craft structures and items that can support your cause in Kob warfare. Your enemy in Kob warfare are Kobs of other faction colors. \
	You can tell them apart by looking at their clothes, or examining them. \
	Enemy Kobs will typically attempt to attack or devour you on sight, while talking is not impossible, you should expect a fight if you encounter an enemy Kob.\
	<br><br>\
	Some Kobs may be unaffiliated with any faction, and you can tell this by examining them. \
	These Kobs are not participating in war, and so should be left alone as long as they are not interfering with your efforts or territory.</span>\
	<br><br>\
	<span class ='warning'><b>You are not enemies with the station crew.</b></span> \
	<span class ='notice'>You like the crew, they produce the trash you want. You should avoid getting in their way or causing undue harm to them, \
	as this will reduce their trash production. If the crew is on your side, you may earn advantages in your garbage conquest. \
	You are only ever at war with the station crew when the station crew initiates war with you, and even then, only with those who attack your faction.\
	<br><br>\
	As a Kob, you have a few unique abilities and interactions. You can use the 'Consider Holy Garbage' verb to count the garbage around yourself. \
	This will let you know how many bricks of trash slag you could create. \
	This verb's counterpart is 'Craft Holy Bricks', and as the name implies, this verb will turn the garbage around you into trash slag bricks. \
	When producing trash slag bricks you use up just about any kind of item on the floor around yourself to create your bricks. Anything with contents will not be processed. \
	Be sure to empty out bags and boxes. Some things also simply cannot be converted into trash slag.\
	<br><br>\
	Trash slag, or Holy, can be used as a crafting material by Kobs. You can create nests to found new forts, walls, homes, tools to dig tunnels or build certain kinds of structures, \
	among other things. One of the most valuable things one can create from Holy is a golden elixir, which when drunk can heal injuries, and revive seemingly dead Kobs. \
	Needless to say, other Kobs, and even the station crew may seek to acquire your hard won Holy.\
	<br><br>\
	Certain sites around the station are also important to Kobs, Trash piles, as the station crew calls them, are veritable wellsprings of Holy. \
	These bountiful sites can be gathered from periodically, and repeatedly by Kobs to attain Holy. Kobs respect these sites above all others, \
	and treat them with appropriate reverence and care, so as not to spoil or destroy them. As such, Kobs can only harvest Holy from trash piles occasionally, \
	after paying appropriate respect and care for the site.\
	<br><br>\
	Kobs heal more quickly when resting than they do otherwise. Just be sure that you aren't too hungry. \
	If you are in a bad state, always remember to retreat to somewhere safe and rest up! A Kob who has taken significant damage may be more easily stunned and captured by enemies. \
	Kobs are also susceptible to disarm strikes. These may briefly stun a Kob and leave them open to capture. \
	Kobs who have been devoured by an enemy will become passive until released, as such, Kobs will often seek to devour their foes to subdue them.\
	<br><br>\
	Kobs also grow according to the number of entities they have made a part of themselves through absorption. \
	Their increase in size also comes with an increase in health, but it can also make it more difficult to engage enemies, and may make you a preferred target by the smarter of enemy Kobs.\
	<br><br>\
	Lastly, Kob forts are the places from which new Kobs come to be. If all of your forts are destroyed, your faction will be unable to produce new Kobs. \
	The nest always produces more Kobs slowly over time. One can provide food to the fort to increase Kob production speed. The Kobs in the nest can be inhabited by ghosts, \
	allowing those who die to respawn, or generally to allow new Kob players to enter the field. After a few Kobs have been produced, nest defenders and scouts\
	will begin to leave the nest. These Kobs are hostile to Kobs of opposing factions. They can be issued orders by Kobs of the same faction though! 'Follow', 'Stop', 'Fight', 'Run', 'Go home', 'Found'\
	are all commands they recognize. Most of the orders are self explanatory, but one to note is the 'Stop' command. This will make all AI controlled Kobs of your faction who can hear you\
	stop attacking and non-hostile. This is useful for forgiving mistakes from the station crew, or allowing an enemy Kob to approach your base. Enemy Kobs can touch your base to \
	join your faction. Kobs can also click drag themselves onto a fort to retire from the round. 'Found' is a special order you can use to get other Kobs of your faction to found \
	a nest to form a new fort, if the conditions are right. Be aware though, they can be picky.</span>")

/mob/living/simple_mob/vore/kob/verb/create_trash_slag()
	set name = "Craft Holy Bricks"
	set desc = "Turn trash into something holy and useful!"
	set category = "Kob"

	do_trash_slag(TRUE)

/mob/living/simple_mob/vore/kob/verb/count_trash_slag()
	set name = "Consider Holy Garbage"
	set desc = "Count the things near you for turning into holy bricks!"
	set category = "Kob"

	do_trash_slag()

/mob/living/simple_mob/vore/kob/proc/do_trash_slag(create = FALSE)

	if(create)
		visible_message("<span class = 'notice'>\The [src] begins scrounging around for any trash nearby to work on!</span>","<span class = 'notice'>You begin scrounging around for any trash nearby to work on! This will only succeed if there is sufficient trash nearby for you to work with!</span>", runemessage = "clank clank")
		if(!do_after(src, 30 SECONDS, exclusive = TRUE))
			to_chat(src, "<span class = 'warning'>You were interrupted! You can't move while creating holy!!!</span>")
			return
	var/list/nearby_garbage = list()
	var/material_count = 0
	var/list/stuff_we_dont_want = list(
		/obj/item/stack/material/trash_slag,
		/obj/item/weapon/reagent_containers,
		/obj/item/weapon/paper,
		/obj/item/weapon/card/id
	)

	stuff_we_dont_want += item_vore_blacklist

	for(var/obj/item/I in view(1, src))
		if(is_type_in_list(I,stuff_we_dont_want))
			continue
		if(I.anchored || !I.trash_eatable)
			continue
		if(I.contents.len)
			var/stuff = FALSE
			for(var/i in I.contents)
				if(!istype(i,/obj/item/weapon/storage/internal))
					stuff = TRUE
					continue
				var/obj/pocket = i
				if(pocket.contents.len)
					stuff = TRUE
			if(stuff)
				continue
		if(istype(I,/obj/item/stack))
			var/obj/item/stack/s = I
			if(s.get_amount() > 5)
				nearby_garbage |= s
				material_count += s.get_amount()
				continue
			else continue

		nearby_garbage |= I

	var/how_many = round((nearby_garbage.len + (material_count / 5)) / 4)
	if(create)
		if(how_many >= 1)
			for(var/thing in nearby_garbage)
				qdel(thing)
			to_chat(src, "<span class = 'notice'>You made [how_many] holy bricks!</span>")
			while(how_many)
				var/this_many
				if(how_many > 50)
					this_many = 50
					how_many -= 50
				else
					this_many = how_many
					how_many -= how_many
				new /obj/item/stack/material/trash_slag(get_turf(src), this_many)
		else
			to_chat(src, "<span class = 'warning'>There wasn't enough trash to make any holy bricks! You need more material near you!</span>")
	else
		if(how_many >= 1)
			to_chat(src, "<span class = 'notice'>You could turn the things near you right now into [how_many] holy bricks!</span>")
		else
			to_chat(src, "<span class = 'warning'>There is not enough garbage here to turn into holy bricks...</span>")

/mob/living/simple_mob/vore/kob/proc/egg_tf()
	for(var/obj/belly/tummy in vore_organs)
		for(var/obj/item/weapon/storage/vore_egg/egg in tummy)
			for(var/obj/item/weapon/holder/h in egg)
				var/mob/living/M = h.held_mob
				if(!istype(M))
					continue
				if(!M.client)
					continue
				if(!M.allow_spontaneous_tf)
					continue
				if(M.stat == DEAD)
					continue
				var/do_faction = FALSE
				if(faction != "kob")
					do_faction = TRUE
				if(iskob(M))
					var/mob/living/simple_mob/vore/kob/k = M
					k.clothing_color = clothing_color
					k.faction = faction
					k.update_icon()
					return
				var/mob/living/simple_mob/vore/kob/new_kob = new (egg, c_color = src.clothing_color, inherit_clothing_faction = do_faction)

				if(!new_kob)
					continue

				var/mob_holder_type = M.holder_type || /obj/item/weapon/holder
				new mob_holder_type(egg, new_kob)

				for(var/obj/belly/B as anything in new_kob.vore_organs)
					new_kob.vore_organs -= B
					qdel(B)
				new_kob.vore_organs = list()
				new_kob.name = M.name
				new_kob.real_name = M.real_name
				for(var/lang in M.languages)
					new_kob.languages |= lang
				M.copy_vore_prefs_to_mob(new_kob)
				new_kob.vore_selected = M.vore_selected
				if(ishuman(M))
					var/mob/living/carbon/human/H = M
					new_kob.gender = H.identifying_gender
				else
					new_kob.gender = M.gender

				for(var/obj/belly/B as anything in M.vore_organs)
					B.loc = new_kob
					B.forceMove(new_kob)
					B.owner = new_kob
					M.vore_organs -= B
					new_kob.vore_organs += B

				new_kob.ckey = M.ckey
				if(M.ai_holder && new_kob.ai_holder)
					var/datum/ai_holder/old_AI = M.ai_holder
					old_AI.set_stance(STANCE_SLEEP)
					var/datum/ai_holder/new_AI = new_kob.ai_holder
					new_AI.hostile = old_AI.hostile
					new_AI.retaliate = old_AI.retaliate
				M.loc = new_kob
				M.forceMove(new_kob)
				new_kob.tf_mob_holder = M
				if(h)
					if(h.held_mob)
						if(h.held_mob.loc == h)
							h.held_mob.forceMove(new_kob)
						h.held_mob = null

					qdel(h)

/mob/living/simple_mob/vore/kob/proc/damagestun(amount)
//If we're sufficiently damaged we may get stunned when taking additional damage
//This should hopefully allow more Kobs to get eaten instead of killed when NPCs are involved.

	if(!isturf(loc))	// We're probably in some weird situation, like inside a tummy, where we're not fighting someone, let's ignore the stuns so we can push resist
		return
	if(amount > 0)		//If it's 0 or lower it's not damage
		var/stunnum = 0		//0 is default value, we don't want to get any extra stuns if we are above 50% HP
		if(health <= (maxHealth / 6))	//We're very hurt and may die very soon, if we land in this damage zone, let's just give it to them!
			stunnum = 100
		else if(health <= (maxHealth / 4))	//Kobs only have 60 HP by default, and can deal up to 20 damage, if they land in this zone they can only take a couple more hits
			stunnum = 90
		else if(health <= (maxHealth / 2))	// Stuns start at 50%
			stunnum = 35

		if(stunnum)
			if(prob(stunnum))
				Weaken(rand(5,10)) //Pretty strong, plenty of time for the gettings.

//////////SUBTYPES//////////

/mob/living/simple_mob/vore/kob/nest_defender
	ai_holder_type = /datum/ai_holder/simple_mob/melee/evasive/kob/kob_defender

/mob/living/simple_mob/vore/kob/scout
	ai_holder_type = /datum/ai_holder/simple_mob/melee/evasive/kob/scout

/mob/living/simple_mob/vore/kob/joinable
	ghostjoin = TRUE

//////////AI STUFF//////////

/datum/ai_holder/simple_mob/melee/evasive/kob
	hostile = FALSE
	retaliate = TRUE
	cooperative = TRUE
	returns_home = FALSE
	can_flee = TRUE
	speak_chance = 1
	wander = TRUE
	base_wander_delay = 4
	threaten = TRUE
	intelligence_level = AI_SMART
	threaten_delay = 30 SECONDS
	returns_home = FALSE
	unconscious_vore = TRUE

/datum/ai_holder/simple_mob/melee/evasive/kob/kob_defender
	hostile = TRUE
	returns_home = TRUE
	max_home_distance = 3

/datum/ai_holder/simple_mob/melee/evasive/kob/scout
	hostile = TRUE
	returns_home = FALSE

/datum/ai_holder/simple_mob/melee/evasive/kob/can_attack(atom/movable/the_target, var/vision_required = TRUE)
	ai_log("can_attack() : Entering.", AI_LOG_TRACE)
	if(!can_see_target(the_target) && vision_required)
		return FALSE

	if(isbelly(holder.loc))	//We give up when in a tummy.
		return FALSE

	if(isliving(the_target))
		var/mob/living/L = the_target
		if(ishuman(L) || issilicon(L))
			if(L.key && !L.client)	// SSD players get a pass
				return FALSE
		if(L.stat)
			var/mob/living/simple_mob/vore/kob/k = holder
			if(iskob(L) && k.will_eat(L) && L.faction != k.faction)
				return TRUE
			if(L.stat == DEAD && !handle_corpse) // Leave dead things alone
				return FALSE
			if(L.stat == UNCONSCIOUS)	// Do we have mauling? Yes? Then maul people who are sleeping but not SSD
				if(mauling)
					return TRUE
				//VOREStation Add Start
				else if(unconscious_vore && L.allowmobvore)
					var/mob/living/simple_mob/vore/eater = holder
					if(eater.will_eat(L))
						return TRUE
					else
						return FALSE
				//VOREStation Add End
				else
					return FALSE
		if(holder.IIsAlly(L))
			return FALSE
		return TRUE

	if(istype(the_target, /obj/mecha))
		var/obj/mecha/M = the_target
		if(M.occupant)
			return can_attack(M.occupant)
		return destructive // Empty mechs are 'neutral'.

	if(istype(the_target, /obj/machinery/porta_turret))
		var/obj/machinery/porta_turret/P = the_target
		if(P.stat & BROKEN)
			return FALSE // Already dead.
		if(P.faction == holder.faction)
			return FALSE // Don't shoot allied turrets.
		if(!P.raised && !P.raising)
			return FALSE // Turrets won't get hurt if they're still in their cover.
		return TRUE

	if(istype(the_target, /obj/structure/blob)) // Blob mobs are always blob faction, but the blob can anger other things.
		var/obj/structure/blob/Blob = the_target
		if(holder.faction == Blob.faction)
			return FALSE

	return TRUE

/datum/ai_holder/simple_mob/melee/evasive/kob/on_hear_say(mob/living/speaker, message)
	if(holder.client || !speaker.client)
		return
	if(holder.stat || !holder.say_list || !message || speaker == holder)
		return
	var/mob/living/simple_mob/vore/kob/k = holder
	if((findtext(message, "follow [k.myname]") || findtext(message, "[k.myname] follow") || findtext(message, "follow me [k.myname]") || findtext(message, "[k.myname] follow me") || findtext(message, "come [k.myname]") || findtext(message, "[k.myname] come") || findtext(message, "come with me [k.myname]") || findtext(message, "[k.myname] come with me") || findtext(message, "let's go [k.myname]") || findtext(message, "[k.myname] let's go") || findtext(message, "lets go [k.myname]") || findtext(message, "[k.myname] lets go ")) && k.faction == speaker.faction)
		holder.ISay(safepick(holder.say_list.say_understood))
		returns_home = FALSE
		set_follow(speaker, follow_for = 10 MINUTES)

	if((findtext(message, "found [k.myname]") || findtext(message, "[k.myname] found") || findtext(message, "found nest [k.myname]") ||findtext(message, "[k.myname] found nest") || findtext(message, "found this nest [k.myname]") || findtext(message, "[k.myname] found this nest") || findtext(message, "found that nest [k.myname]") || findtext(message, "[k.myname] found that nest")) && k.faction == speaker.faction)
		var/list/nests = list()
		for(var/obj/structure/kob/nest/n in view(2, holder.loc))
			if(!n.busy)
				nests |= n

		if(!nests.len)
			spawn(50)
			holder.ISay("What nest? I not close enough to nest! ! !")
			return
		var/found_one = FALSE
		var/obj/structure/kob/nest/ournest = pick(nests)
		for(var/obj/structure/kob/fort/f in view(world.view, ournest.loc))
			holder.ISay("Nest is too close to fort! ! ! MOVE NEST SOMEWHERE ELSE! ! !")
			return
		if(!ournest.faction)
			spawn(50)
			holder.ISay("Need FLAG COLOR! ! ! Can't found in these conditions!")
			return
		var/mob/living/simple_mob/vore/kob/found_kob
		for(found_kob in view(2, ournest))
			if(found_kob == k)
				continue
			if(!iskob(found_kob))
				continue
			if(found_kob.client)
				if(tgui_alert(found_kob,"Would you like to found \the [ournest] with \the [holder]? This will cause your character to be retired into the nest.","Found nest",list("No", "Yes"),timeout = 10 SECONDS) != "Yes")
					continue
			found_one = TRUE
			break
		if(!found_one)
			busy = FALSE
			spawn(50)
			holder.ISay("No mates? ? ? Need MATES for founding! ! ! ! S K R E E E E E E E E E ! ! !")
			return

		if(found_kob.client)
			to_chat(found_kob,"<span class = 'notice'>You and [holder] begin to found \the [ournest]. You will both need to stay in the nest for one minute to complete the process!</span>")
		if(ournest.busy)
			holder.ISay("Not enough ROOM for [src]! ! !")
			return
		ournest.found_nest(holder, found_kob)

	else if((findtext(message, "stand down") || findtext(message, "stop") || findtext(message, "don't") || findtext(message, "dont")) && holder.faction == speaker.faction)
		holder.ISay(safepick(holder.say_list.say_understood))
		hostile = FALSE
		set_stance(STANCE_IDLE)
		lose_follow()

	else if((findtext(message, "attack") || findtext(message, "fight") || findtext(message, "defend") || findtext(message, "help")) && holder.faction == speaker.faction)
		holder.ISay(safepick(holder.say_list.say_understood))
		hostile = TRUE
		set_stance(STANCE_FIGHT)

	else if(findtext(message, "flee") || findtext(message, "run") || findtext(message, "run away") && holder.faction == speaker.faction)
		set_stance(STANCE_FLEE)

	else if((findtext(message, "go home") || findtext(message, "return to base"))  && holder.faction == speaker.faction)
		if(home_turf.z == k.z)
			holder.ISay(safepick(holder.say_list.say_understood))
			returns_home = TRUE
		else
			holder.ISay(safepick(holder.say_list.say_cannot))
	else
		var/datum/say_list/S = holder.say_list
		S.speak |= message





/datum/ai_holder/simple_mob/melee/evasive/kob/react_to_attack(atom/movable/attacker, ignore_timers)
	if(isliving(attacker))
		var/mob/living/m = attacker
		if(m.faction != holder.faction)
			add_attacker(m)
			for(var/mob/living/simple_mob/vore/kob/k in viewers(holder))
				if(!k.ai_holder)
					continue
				if(k.faction == holder.faction)
					k.ai_holder.add_attacker(m)
	return ..()

/datum/ai_holder/simple_mob/melee/evasive/kob/help_requested(mob/living/friend)
	ai_log("help_requested() : Entering.", AI_LOG_DEBUG)
	if(stance == STANCE_SLEEP)
		ai_log("help_requested() : Help requested by [friend] but we are asleep.", AI_LOG_INFO)
		return
	if(!cooperative)
		ai_log("help_requested() : Help requested by [friend] but we're not cooperative.", AI_LOG_INFO)
		return
	if(stance in STANCES_COMBAT)
		ai_log("help_requested() : Help requested by [friend] but we are busy fighting something else.", AI_LOG_INFO)
		return
	if(!can_act())
		ai_log("help_requested() : Help requested by [friend] but cannot act (stunned or dead).", AI_LOG_INFO)
		return
	if(!holder.IIsAlly(friend)) // Extra sanity.
		ai_log("help_requested() : Help requested by [friend] but we hate them.", AI_LOG_INFO)
		return
	var/their_target = friend?.ai_holder?.target
	if(their_target) // They have a target and aren't just shouting for no reason
		if(!can_attack(their_target, vision_required = FALSE))
			ai_log("help_requested() : Help requested by [friend] but we don't want to fight their target.", AI_LOG_INFO)
			return
		if(get_dist(holder, friend) <= follow_distance)
			ai_log("help_requested() : Help requested by [friend] but we're already here.", AI_LOG_INFO)
			return
		if(get_dist(holder, friend) <= vision_range) // Within our sight.
			ai_log("help_requested() : Help requested by [friend], and within target sharing range.", AI_LOG_INFO)
			last_conflict_time = world.time // So we attack immediately and not threaten.
			give_target(their_target, urgent = TRUE) // This will set us to the appropiate stance.
			ai_log("help_requested() : Given target [target] by [friend]. Exiting", AI_LOG_DEBUG)
			return

	// Otherwise they're outside our sight, lack a target, or aren't AI controlled, but within call range.
	// So assuming we're AI controlled, we'll go to them and see whats wrong.
	ai_log("help_requested() : Help requested by [friend], going to go to friend.", AI_LOG_INFO)
	set_follow(friend, 10 SECONDS)
	ai_log("help_requested() : Exiting.", AI_LOG_DEBUG)
