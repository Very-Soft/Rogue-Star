/////TO DO/////
/*

Nets
Net Traps
Blow darts with shrinking chems

a thing that TFs people in eggs into kobs


*/

#define MAT_TRASH			"trash slag"

/obj/item/stack/material/trash_slag
	name = "trash slag"
	icon = 'icons/rogue-star/kobs/kobx32.dmi'
	icon_state = "sheet-holy"
	desc = "It is a brick comprised of garbage. It may have USED to have been something more distinct, but now it is a brick of random bits and bobs of recognizable components!"
	default_type = MAT_TRASH
	no_variants = FALSE
	pass_color = FALSE
	strict_color_stacking = FALSE
	drop_sound = 'sound/items/drop/cardboardbox.ogg'
	pickup_sound = 'sound/items/pickup/cardboardbox.ogg'
	throwforce = 10
	persist_storable = FALSE

/obj/item/stack/material/trash_slag/attack_self(var/mob/user)
	if(iskob(user))
		if(!material.build_windows(user, src))
			..()
	else
		to_chat(user, "<span class ='warning'>It looks like a brick comprised entirely of worthless garbage...</span>")
		return

/obj/item/stack/material/trash_slag/examine(mob/user)
	. = ..()
	if(iskob(user))
		. += span_orange("It's holy... the perfect material!!! It can be made into so many things!")

/datum/material/trash_slag
	name = MAT_TRASH
	icon_base = "sheet-card"
	stack_type = /obj/item/stack/material/trash_slag
	sheet_collective_name = "pile"
	supply_conversion_value = 1
	sheet_singular_name = "brick"
	sheet_plural_name = "bricks"
	hardness = 75
	integrity = 150
	conductivity = 11
	protectiveness = 15

/datum/material/trash_slag/generate_recipes()
	recipes = list(
		new /datum/stack_recipe("nest", /obj/structure/kob/nest, 10, time = 100, one_per_turf = TRUE, on_floor = TRUE),
		new	/datum/stack_recipe("wall", /obj/structure/kob/wall, 5, time = 100, one_per_turf = TRUE, on_floor = TRUE),
		new	/datum/stack_recipe("wall (with window)", /obj/structure/kob/wall/transparent, 5, time = 100, one_per_turf = TRUE, on_floor = TRUE),
		new	/datum/stack_recipe("tunnel starter kit", /obj/item/weapon/shovel/kob, 5, time = 100, on_floor = TRUE),
		new /datum/stack_recipe("DRAGON SUMMONING RITUAL", /obj/item/weapon/material/snow/snowball, 1, time = 10, recycle_material = "[name]"),
		new /datum/stack_recipe("Food", /obj/item/weapon/reagent_containers/food/snacks/kob_food, 1, time = 10),
		new /datum/stack_recipe("Drink", /obj/item/weapon/reagent_containers/food/drinks/kob_drink, 1, time = 10),
		new /datum/stack_recipe("Construction Kit", /obj/item/kob_construction_kit, 25, time = 50),
		new	/datum/stack_recipe("House", /obj/structure/kob/house, 5, time = 100, one_per_turf = TRUE, on_floor = TRUE)

	)

/obj/item/weapon/shovel/kob
	name = "tunnel starter kit"
	desc = "It appears to be a shovel made of garbage."
	icon = 'icons/rogue-star/kobs/kobx32.dmi'
	icon_state = "trash_shovel"
	origin_tech = list()
	matter = list(MAT_TRASH = 1)

/obj/item/weapon/shovel/kob/attack_self(mob/user)

	if(!iskob(user))
		return ..()
	if(!isturf(user.loc))
		return
	var/turf/myturf = user.loc
	if(myturf.density)
		to_chat(user,"<span class = 'warning'>You can't do that here.</span>")
		return
	for(var/obj/structure/thing in myturf)
		if(thing.density && !(thing == src))
			to_chat(user,"<span class = 'warning'>You can't do that here.</span>")
			return
	if(tgui_alert(user,"Do you want to dig a tunnel here?","Dig Tunnel",list("Yes", "No")) != "Yes")
		return
	user.setClickCooldown(user.get_attack_speed(src))
	user.visible_message("<span class = 'notice'>\The [user] begins diging a tunnel...</span>", "<span class = 'notice'>You begin diging a tunnel...</span>",runemessage = "clank... shumpf... clank...")
	if(!do_after(user, 30 SECONDS, exclusive = TRUE))
		user.visible_message("<span class = 'warning'>\The [user]'s tunnel collapses!</span>", "<span class = 'warning'>Your tunnel collapses!!!</span>",runemessage = "shumpf! ! !")
		return
	var/turf/ourturf = get_turf(src.loc)
	var/obj/structure/kob/tunnel/t
	if(user.faction == "kob")
		t = new(ourturf)
	else
		t = new(ourturf, user.faction, TRUE)
	user.forceMove(t)
	t.visible_message("<span class = 'notice'>\The [t] is complete!</span>", "<span class = 'notice'>Your tunnel is complete!</span>",runemessage = "shumpf!")
	t.rename_kob_tunnel(user, TRUE)
	user.drop_from_inventory(src)
	qdel(src)

//Make super kob drink that heals kobs real good, but it's rediculous alchohol to anyone else

/obj/item/weapon/reagent_containers/food/snacks/kob_food
	name = "kob food"
	desc = "It's basically poison."
	icon = 'icons/obj/food.dmi'
	icon_state = "grubmeat"

/obj/item/weapon/reagent_containers/food/snacks/kob_food/Initialize()
	. = ..()
	reagents.add_reagent("holyessence", rand(1,3))

	var/list/random_stuff = list("nutriment","protein","tofu","seafood","cheese","egg","murk_protein","bean_protein","chocolate","instantgrape","instantapple","soysauce","vinegar","ketchup","mustard","barbecue","rice")
	reagents.add_reagent(pick(random_stuff), rand(1,10))
	if(prob(50))
		reagents.add_reagent(pick(random_stuff), rand(1,10))
		if(prob(50))
			reagents.add_reagent(pick(random_stuff), rand(1,10))

	bitesize = 3

/obj/item/weapon/reagent_containers/food/drinks/kob_drink
	name = "holy"
	desc = "It's basically poison."
	icon = 'icons/rogue-star/kobs/kobx32.dmi'
	icon_state = "holy_drink"
	trash = /obj/item/trash/kob_drink
	drop_sound = 'sound/items/drop/bottle.ogg'
	pickup_sound = 'sound/items/pickup/bottle.ogg'

/obj/item/weapon/reagent_containers/food/drinks/kob_drink/Initialize()
	. = ..()
	reagents.add_reagent("holyessence", rand(1,3))

	var/list/random_stuff = list("nutriment","protein","tofu","seafood","cheese","egg","murk_protein","bean_protein","chocolate","instantgrape","instantapple","soysauce","vinegar","ketchup","mustard","barbecue","rice")
	reagents.add_reagent(pick(random_stuff), rand(1,10))
	if(prob(50))
		reagents.add_reagent(pick(random_stuff), rand(1,10))
		if(prob(50))
			reagents.add_reagent(pick(random_stuff), rand(1,10))

/obj/item/trash/kob_drink
	name = "empty bottle"
	icon = 'icons/rogue-star/kobs/kobx32.dmi'
	icon_state = "holy_drink_trash"
	drop_sound = 'sound/items/drop/bottle.ogg'
	pickup_sound = 'sound/items/pickup/bottle.ogg'

/datum/reagent/ethanol/holy
	name = "Essence of Holy"
	id = "holyessence"
	description = "It's basically poison."
	taste_description = "something positively holy"
	strength = 20
	druggy = 100
	halluci = 100
	color = "#ffda35"

	glass_name = "Essence of Holy"
	glass_desc = "It shimmers mysteriously..."

/datum/reagent/ethanol/holy/affect_ingest(var/mob/living/carbon/M, var/alien, var/removed)

	if(M.species.organic_food_coeff)
		switch(alien)
			if(IS_UNATHI)	//Close enough
				M.adjust_nutrition(10 * removed)
				M.adjustFireLoss(-5)
				M.adjustBruteLoss(-5)
				return
			if(IS_CHIMERA)
				M.adjust_nutrition(10 * removed)
				M.adjustFireLoss(-5)
				M.adjustBruteLoss(-5)
				return
	..()
	M.adjustToxLoss(10)
	M.adjust_fire_stacks(0.5)
	M.IgniteMob()

/obj/item/kob_construction_kit
	name = "trash construction kit"
	desc = "It's a small pile of trash."
	icon = 'icons/rogue-star/kobs/kobx32.dmi'
	icon_state = "trash_construction"

/obj/item/kob_construction_kit/attack_self(mob/user)

	if(!iskob(user))
		return ..()
	if(!isturf(user.loc))
		return
	var/turf/myturf = user.loc
	if(myturf.density)
		to_chat(user,"<span class = 'warning'>You can't do that here.</span>")
		return
	for(var/obj/structure/thing in myturf)
		if(thing.density && !(thing == src))
			to_chat(user,"<span class = 'warning'>You can't do that here.</span>")
			return

	var/list/possible_types = list(
		"door" = /obj/structure/kob/door,
		"stockpile" = /obj/structure/kob/stockpile
		)
	var/choice = tgui_input_list(user, "What would you like to build?", "Pick Building", possible_types)

	if(!choice)
		return

	var/myfaction
	if(user.faction != "kob")
		myfaction = user.faction

	var/chosen_type = possible_types[choice]

	user.setClickCooldown(user.get_attack_speed(src))
	user.visible_message("<span class = 'notice'>\The [user] begins building something...</span>","<span class = 'notice'>You begin to build...</span>",runemessage = "clank clank")

	if(!do_after(user, 30 SECONDS, exclusive = TRUE))
		to_chat(user, "<span class = 'warning'>You were interrupted!</span>")
		return

	if(myfaction)
		new chosen_type (myturf, myfaction)
	else
		new chosen_type (myturf)

	user.drop_from_inventory(src)
	qdel(src)
