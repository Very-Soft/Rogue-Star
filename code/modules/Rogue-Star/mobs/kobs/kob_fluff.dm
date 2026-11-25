/mob/living/simple_mob/vore/kob/fluff
	ghostjoin = TRUE
	var/special_name
	var/fluff_ckey

/mob/living/simple_mob/vore/kob/fluff/New(b_color, m_color, h_color, e_color, c_color, inherit_clothing_faction, inherit_name)
	. = ..()
	if(inherit_clothing_faction && c_color)
		clothing_color = c_color

/mob/living/simple_mob/vore/kob/fluff/kob_name()
	if(!special_name)
		return ..()

	var/ourname = special_name

	var/how_many_syllables = rand(1,3)

	while(how_many_syllables)
		how_many_syllables --

		ourname = "[ourname][pick(kob_name_syllables)]"

	myname = capitalize(myname)
	ourname = "[ourname] [myname]"
	name = ourname
	real_name = ourname

/mob/living/simple_mob/vore/kob/fluff/attack_ghost(mob/observer/dead/user)
	if(!fluff_ckey)
		return ..()
	if(ghostjoin && user.ckey != fluff_ckey)
		to_chat(user, "<span class = 'warning'>[src] is reserved for someone else, you cannot join as this Kob.</span>")
		return
	else return ..()

/mob/living/simple_mob/vore/kob/fluff/cass
	set_kob = TRUE
	myname = "Cass"
	color = "#c69c85"
	marking_color = "#eeb698"
	horn_color = "#272523"
	eye_color = "#612c08"
	clothing_color = "#4848a7"
	horn_type =  1
	clothing_type = 6
	special_name = "Soft"
	fluff_ckey = "verysoft"
	gender = "plural"

/mob/living/simple_mob/vore/kob/fluff/lira
	set_kob = TRUE
	myname = "Lira"
	color = "#ffffc0"
	marking_color = "#fdfae9"
	horn_color = "#ffc965"
	eye_color = "#1d7fb7"
	clothing_color = "#121242"
	horn_type = 1
	clothing_type = 1
	fluff_ckey = "lira13"
	gender = "female"

/mob/living/simple_mob/vore/kob/fluff/kenzie
	set_kob = TRUE
	myname = "Kenzie"
	color = "#777777"
	marking_color = "#660066"
	horn_color = "#660066"
	eye_color = "#003500"
	clothing_color = "#333333"
	horn_type = 1
	clothing_type = 1
	special_name = "Houser"
	fluff_ckey = "lm40"
	gender = "female"

/mob/living/simple_mob/vore/kob/fluff/fizzle
	set_kob = TRUE
	myname = "Fizzle"
	color = "#cd0053"
	marking_color = "#790232"
	horn_color = "#790232"
	eye_color = "#575757"
	clothing_color = "#ffee00"
	horn_type = 1
	clothing_type = 3
	fluff_ckey = "residentcody"
	gender = "female"

/mob/living/simple_mob/vore/kob/fluff/alexie
	set_kob = TRUE
	myname = "Alexie"
	color = "#b4693e"
	marking_color = "#c9c0bd"
	horn_color = "#6b1e00"
	eye_color = "#219037"
	clothing_color = "#375533"
	horn_type = 1
	clothing_type = 6
	fluff_ckey = "azerothmargican"
	gender = "female"

/mob/living/simple_mob/vore/kob/fluff/chai
	set_kob = TRUE
	myname = "Chai"
	color = "#ffb443"
	marking_color = "#ffb443"
	horn_color = "#63498a"
	eye_color = "#333300"
	clothing_color = "#2a2a82"
	horn_type = 1
	clothing_type = 6
	fluff_ckey = "blueleafy"
	gender = "female"

/mob/living/simple_mob/vore/kob/fluff/lilly
	set_kob = TRUE
	myname = "Lilly"
	color = "#eeceb3"
	marking_color = "#f8f8f8"
	horn_color = "#cc3300"
	eye_color = "#0000cc"
	clothing_color = "#3366ff"
	horn_type = 2
	clothing_type = 6
	special_name = "Palmer"
	fluff_ckey = "digitalsquirrel95"
	gender = "female"

/mob/living/simple_mob/vore/kob/fluff/fink
	set_kob = TRUE
	myname = "Fink"
	color = "#eeceb3"
	marking_color = "#dddddd"
	horn_color = "#dddddd"
	eye_color = "#cc0000"
	clothing_color = "#ad1414"
	horn_type = 2
	clothing_type = 3
	fluff_ckey = "itsaket"
	gender = "male"
