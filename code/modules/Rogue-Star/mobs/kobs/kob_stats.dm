//RS FILE
/proc/report_kob_wars()
	var/count = 0
	var/list/kobs = list()

	for(var/mob/living/simple_mob/vore/kob/k in world)
		kobs |= k
		if(k.ckey)
			count ++
	if(kobs.len)
		var/biggest_size = 0
		var/absorbed = 0
		to_world("<br><b>KOB STATS:</b>")
		to_world("There were [kobs.len] Kobs!")
		if(count)
			to_world("[count] of them were player controlled!")
		var/list/colors = list()
		for(var/obj/structure/kob/fort/f in world)
			colors |= f.faction
		if(colors.len > 1)
			to_world("<h2 style=\"color:#A50400\">THE KOB WARS HAVE ENDED</h2>")
			to_world("There were [colors.len] Kob factions.")
			for(var/color in colors)
				count = 0
				biggest_size = 0
				absorbed = 0
				for(var/mob/living/simple_mob/vore/kob/k in kobs)
					if(color == k.faction)
						if(k.stat)
							continue
						if(k.absorbed)
							absorbed ++
							continue
						count ++
						if(k.size_multiplier > biggest_size)
							biggest_size = k.size_multiplier
				to_world("<font color='[color]'><b>There were [count] free and alive kobs on [color] team!</b></font>")
				if(absorbed)
					to_world("([absorbed] absorbed, making [count + absorbed] in total.)")
				to_world("The biggest kob on this team is [biggest_size * 100]% scale!<br>")
		biggest_size = 0
		absorbed = 0
		count = 0
		for(var/mob/living/simple_mob/vore/kob/k in kobs)
			if(k.faction == "kob")
				if(k.stat)
					continue
				if(k.absorbed)
					absorbed ++
					continue
				count ++
				if(k.size_multiplier > biggest_size)
					biggest_size = k.size_multiplier
		if(count)
			to_world("<span class = 'notice'>There were [count] free and alive unaffiliated kobs!</span>")
			if(absorbed)
				to_world("([absorbed] absorbed, making [count + absorbed] in total.)")
			to_world("The biggest unaffiliated kob is [biggest_size * 100]% scale!")
