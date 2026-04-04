//RS FILE
#define ED_OVERLAY_LIGHT 1
#define ED_OVERLAY_MEDIUM 2
#define ED_OVERLAY_HEAVY 3
#define ED_OVERLAY_EXTREME 4

/mob/living
	var/ether_damage = 0.0

/mob/living/proc/handle_ether_damage()
	if(!stat && health - ether_damage <= 0)
		death()

/mob/living/carbon/human/handle_ether_damage()
	species.handle_ether_damage(src)

/datum/species
	var/ether_slow = 1

/datum/species/proc/handle_ether_damage(var/mob/living/carbon/human/H)
	if(!H.stat && (H.health + 100) - H.ether_damage <= 0)
		H.death()
		var/mob/living/simple_mob/hostile/seething/S = new(get_turf(H))
		S.visible_message(SPAN_DANGER("\The [S] seems to climb out of \the [H]!!!"))

/mob/living/proc/ether_death()
	ether_damage = 0.0
	var/mob/living/simple_mob/hostile/seething/S = new(get_turf(src))
	S.visible_message(SPAN_DANGER("\The [S] seems to climb out of \the [src]!!!"))

/mob/living/carbon/human/ether_death()
	ether_damage = 0.0

/mob/living/proc/getEtherDamage()
	return ether_damage

/mob/living/proc/adjustEtherDamage(var/amount = 0.0)
	ether_damage += amount

	if(ether_damage < 0)
		ether_damage = 0
	if(amount > 0)
		add_modifier(/datum/modifier/ether_damage)

/datum/modifier/ether_damage
	name = "Ether Damage"

	var/last_dmg = 0.0
	var/ticks_since_dmg = 0
	var/heal_factor = 0
	var/overlay_state
	var/obj/screen/fullscreen/ether_damage/our_overlay

/datum/modifier/ether_damage/expire(silent)
	. = ..()
	clear_overlay()

/datum/modifier/ether_damage/tick()
	var/current_dmg = holder.getEtherDamage()
	if(current_dmg <= 0)
		expire()
		return
	if(holder.stat == DEAD)
		holder.ether_death()
		expire()
		return
	new /obj/particle_emitter/ether_damage/limited(get_turf(holder))
	if(current_dmg > last_dmg)
		ticks_since_dmg = 0
		heal_factor = 0
	else
		ticks_since_dmg ++
		if(ticks_since_dmg >= 10)
			heal_factor ++
			holder.adjustEtherDamage(-heal_factor)
	last_dmg = current_dmg
	assess_overlay()

/datum/modifier/ether_damage/proc/assess_overlay()
	if(!holder.client)
		return
	var/which = null
	switch(holder.getEtherDamage())
		if(10 to 49)
			which = ED_OVERLAY_LIGHT
		if(50 to 99)
			which = ED_OVERLAY_MEDIUM
		if(100 to 149)
			which = ED_OVERLAY_HEAVY
		if(150 to INFINITY)
			which = ED_OVERLAY_EXTREME
		else
			which = null

	if(overlay_state == which)
		return
	overlay_state = which
	if(!which)
		clear_overlay()
		return

	if(!our_overlay)
		our_overlay = holder.overlay_fullscreen("ether", /obj/screen/fullscreen/ether_damage)

	switch(which)
		if(ED_OVERLAY_LIGHT)
			slowdown = 0
			our_overlay.particles.count = 100
			our_overlay.particles.spawning = 0.1
		if(ED_OVERLAY_MEDIUM)
			slowdown = 0.5
			our_overlay.particles.count = 100
			our_overlay.particles.spawning = 0.25
		if(ED_OVERLAY_HEAVY)
			slowdown = 1
			our_overlay.particles.count = 500
			our_overlay.particles.spawning = 1
		if(ED_OVERLAY_EXTREME)
			slowdown = 1
			our_overlay.particles.count = 5000
			our_overlay.particles.spawning = 10
	our_overlay.icon_state = "[which]"

/datum/modifier/ether_damage/proc/clear_overlay()
	holder.clear_fullscreen("ether")
	holder.clear_fullscreen("ether_damage")

/obj/particle_emitter/ether_damage
	particles = new/particles/ether_damage

/obj/particle_emitter/ether_damage/limited
	lifespan = 3

/particles/ether_damage
	icon = 'icons/rogue-star/particlesx32.dmi'
	icon_state = list("eh1","eh2","eh3","eh4","eh5","eh6","eh7",)
	color = "#ae00ff"
	width = 1000
	height = 1000
	count = 10
	spawning = 1
	bound1 = list(-1000, -1000, -1000)
	lifespan = 10
	fade = 5
	position = generator("box", list(-8,-8,0), list(8,8,0))
	gravity = list(0,0.5)
	friction = 0.1
	velocity = generator("vector",list(-3,0),list(3,0))
	spin = generator("num", -10,10)
	scale = 0.25
	grow = 0.1
	gradient = list(0, "#ae00ff", 1, "#520079", 2, "#ff00ff", "loop")

/particles/ether_damage/fullscreen
	width = 500
	height = 500
	spawning = 0.1
	position = generator("box", list(-250,-300,0), list(250,-300,0))
	gravity = list(0,1)
	grow = 0.05
	drift = generator("sphere", 0, 2)
	lifespan = 50

/particles/ether_damage/fullscreen/medium
	count = 100
	spawning = 0.25
/particles/ether_damage/fullscreen/heavy
	count = 500
	spawning = 1
/particles/ether_damage/fullscreen/extreme
	count = 5000
	spawning = 10

/obj/aoe
	name = "ether damage applier"
	icon = null
	icon_state = null
	anchored = TRUE
	mouse_opacity = FALSE
	plane = PLANE_LIGHTING_ABOVE
	particles = new/particles/ether_damage

/obj/aoe/Crossed(O)
	if(!isliving(O))
		return
	var/mob/living/L = O
	L.adjustEtherDamage(25)

/obj/particle_emitter/ether_damage/screen
	particles = new/particles/ether_damage/fullscreen

/obj/screen/fullscreen/ether_damage
	icon = 'icons/rogue-star/full_screen_effects.dmi'
	icon_state = null
	mouse_opacity = FALSE
	layer = 18.4

	particles = new/particles/ether_damage/fullscreen

/////
/mob/living/simple_mob/hostile/seething/handle_ether_damage()
	health = maxHealth
	ether_damage = 0.0

/mob/living/simple_mob/hostile/seething_spawner/handle_ether_damage()
	health = maxHealth
	ether_damage = 0.0

#undef ED_OVERLAY_LIGHT
#undef ED_OVERLAY_MEDIUM
#undef ED_OVERLAY_HEAVY
#undef ED_OVERLAY_EXTREME
