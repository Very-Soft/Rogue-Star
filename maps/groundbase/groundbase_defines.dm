//Normal map defs
/*//RS REMOVE START
#define Z_LEVEL_GB_BOTTOM  					1
#define Z_LEVEL_GB_MIDDLE  					2
#define Z_LEVEL_GB_TOP     					3
#define Z_LEVEL_GB_ENGINESAT				4
#define Z_LEVEL_GB_WILD_N  					5
#define Z_LEVEL_GB_WILD_S  					6
#define Z_LEVEL_GB_WILD_E  					7
#define Z_LEVEL_GB_WILD_W  					8
#define Z_LEVEL_CENTCOM						9
#define Z_LEVEL_MISC						10
#define Z_LEVEL_MINING						11
#define Z_LEVEL_BEACH						12
#define Z_LEVEL_BEACH_CAVE					13
#define Z_LEVEL_AEROSTAT					14
#define Z_LEVEL_AEROSTAT_SURFACE			15
#define Z_LEVEL_DEBRISFIELD					16
#define Z_LEVEL_FUELDEPOT					17
#define Z_LEVEL_OFFMAP1						18
#define Z_LEVEL_SNOWBASE					19
#define Z_LEVEL_GLACIER						20
#define Z_LEVEL_GATEWAY						21
#define Z_LEVEL_OM_ADVENTURE				22
#define Z_LEVEL_REDGATE						23

//Camera networks
#define NETWORK_HALLS "Halls"
*///RS REMOVE END
/datum/map/groundbase/New()
	if(global.using_map != src)	//RS EDIT START - Map swap related
		return ..()
	ai_shell_allowed_levels += z_list["z_misc"]
	ai_shell_allowed_levels += z_list["z_beach"]
	ai_shell_allowed_levels += z_list["z_aerostat"]
	//RS ADD END
	..()
	var/choice = pickweight(list(
		"rs_lobby" = 50,
		"rs_lobby2" = 50
	))
	if(choice)
		lobby_screens = list(choice)

/datum/map/groundbase
	name = "RascalsPass"
	full_name = "NSB Rascal's Pass"
	path = "groundbase"

	use_overmap = TRUE
	overmap_size = 62
	overmap_event_areas = 100
	usable_email_tlds = list("virgo.nt")

	zlevel_datum_type = /datum/map_z_level/groundbase

	lobby_icon = 'icons/misc/title_rs.dmi'
	lobby_screens = list("rs_lobby")	//RS EDIT
	id_hud_icons = 'icons/mob/hud_jobs_vr.dmi'


	holomap_smoosh = list(list(
		Z_LEVEL_GB_BOTTOM,
		Z_LEVEL_GB_MIDDLE,
		Z_LEVEL_GB_TOP))

//	accessible_z_levels = list("4" = 100)

	station_name  = "NSB Rascal's Pass"
	station_short = "Rascal's Pass"
	facility_type = "base"
	dock_name     = "Virgo-3B Colony"
	dock_type     = "surface"
	boss_name     = "Central Command"
	boss_short    = "CentCom"
	company_name  = "NanoTrasen"
	company_short = "NT"
	starsys_name  = "Virgo-Erigone"

	shuttle_docked_message = "The scheduled shuttle to the %dock_name% has arrived. It will depart in approximately %ETD%."
	shuttle_leaving_dock = "The shuttle has departed. Estimate %ETA% until arrival at %dock_name%."
	shuttle_called_message = "A scheduled crew transfer to the %dock_name% is occuring. The shuttle will arrive shortly. Those departing should proceed to the upper level on the west side of the main facility within %ETA%."
	shuttle_recall_message = "The scheduled crew transfer has been cancelled."
	shuttle_name = "Crew Transport"
	emergency_shuttle_docked_message = "The evacuation shuttle has arrived. You have approximately %ETD% to board the shuttle."
	emergency_shuttle_leaving_dock = "The emergency shuttle has departed. Estimate %ETA% until arrival at %dock_name%."
	emergency_shuttle_called_message = "An emergency evacuation has begun, and an off-schedule shuttle has been called. It will arrive at the upper level on the west side of the main facility in approximately %ETA%."
	emergency_shuttle_recall_message = "The evacuation shuttle has been recalled."

	station_networks = list(
							NETWORK_CARGO,
							NETWORK_CIRCUITS,
							NETWORK_CIVILIAN,
							NETWORK_COMMAND,
							NETWORK_ENGINE,
							NETWORK_ENGINEERING,
							NETWORK_EXPLORATION,
							NETWORK_MEDICAL,
							NETWORK_MINE,
							NETWORK_RESEARCH,
							NETWORK_RESEARCH_OUTPOST,
							NETWORK_ROBOTS,
							NETWORK_SECURITY,
							NETWORK_TELECOM,
							NETWORK_HALLS
							)
	secondary_networks = list(
							NETWORK_ERT,
							NETWORK_MERCENARY,
							NETWORK_THUNDER,
							NETWORK_COMMUNICATORS,
							NETWORK_ALARM_ATMOS,
							NETWORK_ALARM_POWER,
							NETWORK_ALARM_FIRE,
							NETWORK_TALON_HELMETS,
							NETWORK_TALON_SHIP
							)

	bot_patrolling = FALSE

	allowed_spawns = list("Gateway","Cryogenic Storage","Cyborg Storage","ITV Talon Cryo", "Redgate")
	spawnpoint_died = /datum/spawnpoint/cryo
	spawnpoint_left = /datum/spawnpoint/gateway
	spawnpoint_stayed = /datum/spawnpoint/cryo


	meteor_strike_areas = list(
		/area/groundbase/level3,
		/area/groundbase/level2,
		/area/groundbase/level1
		)


	default_skybox = /datum/skybox_settings/groundbase

	unit_test_exempt_areas = list(		//These are all outside
		/area/groundbase/cargo/bay,
		/area/groundbase/civilian/bar/upper,
		/area/groundbase/exploration/shuttlepad,
		/area/groundbase/level1,
		/area/groundbase/level1/ne,
		/area/groundbase/level1/nw,
		/area/groundbase/level1/se,
		/area/groundbase/level1/sw,
		/area/groundbase/level1/centsquare,
		/area/groundbase/level1/northspur,
		/area/groundbase/level1/eastspur,
		/area/groundbase/level1/westspur,
		/area/groundbase/level1/southeastspur,
		/area/groundbase/level1/southwestspur,
		/area/groundbase/level2,
		/area/groundbase/level2/ne,
		/area/groundbase/level2/nw,
		/area/groundbase/level2/se,
		/area/groundbase/level2/sw,
		/area/groundbase/level2/northspur,
		/area/groundbase/level2/eastspur,
		/area/groundbase/level2/westspur,
		/area/groundbase/level2/southeastspur,
		/area/groundbase/level2/southwestspur,
		/area/groundbase/level3,
		/area/groundbase/level3/ne,
		/area/groundbase/level3/nw,
		/area/groundbase/level3/se,
		/area/groundbase/level3/sw,
		/area/groundbase/level3/ne/open,
		/area/groundbase/level3/nw/open,
		/area/groundbase/level3/se/open,
		/area/groundbase/level3/sw/open,
		/area/maintenance/groundbase/level1/netunnel,
		/area/maintenance/groundbase/level1/nwtunnel,
		/area/maintenance/groundbase/level1/setunnel,
		/area/maintenance/groundbase/level1/stunnel,
		/area/maintenance/groundbase/level1/swtunnel,
		/area/groundbase/science/picnic,
		/area/groundbase/medical/patio,
		/area/groundbase/civilian/hydroponics/out,
		/area/groundbase/level3/escapepad,
		/area/maintenance/groundbase/poi/caves,
		/area/submap/groundbase/poi,
		/area/maintenance/groundbase/poi/caves,
		/area/groundbase/unexplored/outdoors,
		/area/groundbase/unexplored/rock,
		/area/groundbase/engineering/solarshed,
		/area/groundbase/engineering/solarfield,
		/area/groundbase/hotspring,
		/area/groundbase/hotspring/water,
		/area/groundbase/medical/geneticslab,
		/area/groundbase/engineering/pumpingstation,
		/area/prison/cell_block/gb/abandonedbrig,
		/area/groundbase/science/abandoned,
		/area/groundbase/civilian/bar/garden
		)

	unit_test_exempt_from_atmos = list()

	unit_test_z_levels = list(
		Z_LEVEL_GB_BOTTOM,
		Z_LEVEL_GB_MIDDLE,
		Z_LEVEL_GB_TOP,
		Z_LEVEL_GB_ENGINESAT	//RS ADD
	)

	//RS ADD START
	z_list = list(
	"z_centcom" = 9,
	"z_misc" = 10,
	"z_beach" = 12,
	"z_beach_cave" = 13,
	"z_aerostat" = 14,
	"z_aerostat_surface" = 15,
	"z_debrisfield" = 16,
	"z_fueldepot" = 17,
	"z_offmap1" = 18,
	"z_snowbase" = 19,
	"z_glacier" = 20,
	"z_gateway" = 21,
	"z_om_adventure" = 22,
	"z_redgate" = 23,
	"overmap_z" = 10
	)

	station_z_levels = list("GB1","GB2","GB3","GB4")

	supplemental_station_z_levels = list(
		list("Northern Wilds 1","Northern Wilds 2","Northern Wilds 3"),
		list("Southern Wilds 1","Southern Wilds 2","Southern Wilds 3"),
		list("Eastern Wilds 1","Eastern Wilds 2"),
		list("Western Wilds 1","Western Wilds 1")
	)
	//RS ADD END

	lateload_z_levels = list(
		list("Groundbase - Central Command"),
		list("Groundbase - Misc"), //Shuttle transit zones, holodeck templates, OM
		list("V3c Underground"),
		list("Desert Planet - Z1 Beach","Desert Planet - Z2 Cave"),
		list("Remmi Aerostat - Z1 Aerostat","Remmi Aerostat - Z2 Surface"),
		list("Debris Field - Z1 Space"),
		list("Fuel Depot - Z1 Space"),
		list("Offmap Ship - Talon V2"),
		list("Virgo 5","Virgo 5 Glacier")
		)
	//List associations used in admin load selection feature
	lateload_gateway = list(
		"Carp Farm" = list("Gateway - Carp Farm"),
		"Snow Field" = list("Gateway - Snow Field"),
		"Listening Post" = list("Gateway - Listening Post"),
		"Honleth Highlands" = list(list("Gateway - Honleth Highlands A", "Gateway - Honleth Highlands B")),
		"Arynthi Lake A" = list("Gateway - Arynthi Lake Underground A","Gateway - Arynthi Lake A"),
		"Arynthi Lake B" = list("Gateway - Arynthi Lake Underground B","Gateway - Arynthi Lake B"),
		"Wild West" = list("Gateway - Wild West")
		)

	lateload_overmap = list(
		list("Grass Cave")
		)
	//List associations used in admin load selection feature
	lateload_redgate = list(
		"Teppi Ranch" = list("Redgate - Teppi Ranch"),
		"Innland" = list("Redgate - Innland"),
//		"Abandoned Island" = list("Redgate - Abandoned Island"),	//This will come back later
		"Dark Adventure" = list("Redgate - Dark Adventure"),
		"Eggnog Town" = list("Redgate - Eggnog Town Underground","Redgate - Eggnog Town"),
		"Star Dog" = list("Redgate - Star Dog"),
		"Hotsprings" = list("Redgate - Hotsprings"),
		"Rain City" = list("Redgate - Rain City"),
		"Islands" = list("Redgate - Islands Underwater","Redgate - Islands"),
		"Moving Train" = list("Redgate - Moving Train", "Redgate - Moving Train Upper Level"),
		"Fantasy Town" = list("Redgate - Fantasy Dungeon", "Redgate - Fantasy Town"),
		"Snowglobe" = list("Redgate - Snowglobe"),
		"Pet Island" = list("Redgate - Pet Island"),
//		"North Star" = list("Redgate - North Star"), // Not ready yet
		"Pizzaria" = list("Redgate - Pizzaria"),
		)

	lateload_gb_north = list(
		list("Northern Wilds 1"),
		list("Northern Wilds 2"),
		list("Northern Wilds 3")
//		list("Northern Wilds CUSTOM")
		)
	lateload_gb_south = list(
		list("Southern Wilds 1"),
		list("Southern Wilds 2"),
		list("Southern Wilds 3")
		)
	lateload_gb_east = list(
		list("Eastern Wilds 1"),
		list("Eastern Wilds 2")
		)
	lateload_gb_west = list(
		list("Western Wilds 1"),
		list("Western Wilds 2")
		)

	ai_shell_restricted = TRUE
	ai_shell_allowed_levels = list(
		Z_LEVEL_GB_BOTTOM,
		Z_LEVEL_GB_MIDDLE,
		Z_LEVEL_GB_TOP,
		Z_LEVEL_GB_ENGINESAT	//RS ADD
		)

	planet_datums_to_make = list(
		/datum/planet/virgo3b,
		/datum/planet/virgo3c,
		/datum/planet/virgo4,
		/datum/planet/snowbase)

/datum/map/groundbase/get_map_info()
	. = list()
	. +=  "[full_name] is a recently established base on one of Virgo 3's moons."
	return jointext(., "<br>")

/*	//RS REMOVE START
/datum/map/groundbase/perform_map_generation()	//Z_LEVEL_GB_BOTTOM,Z_LEVEL_GB_MIDDLE,Z_LEVEL_GB_TOP

	seed_submaps(list(Z_LEVEL_GB_BOTTOM,Z_LEVEL_GB_MIDDLE,Z_LEVEL_GB_TOP), 100, /area/groundbase/unexplored/outdoors, /datum/map_template/groundbase/outdoor)	//Outdoor POIs
	seed_submaps(list(Z_LEVEL_GB_BOTTOM,Z_LEVEL_GB_MIDDLE), 200, /area/groundbase/unexplored/rock, /datum/map_template/groundbase/maintcaves)	//Cave POIs
	new /datum/random_map/automata/cave_system/no_cracks(null, 1, 1, Z_LEVEL_MINING, world.maxx, world.maxy) // Create the mining Z-level.
	new /datum/random_map/noise/ore(null, 1, 1, Z_LEVEL_MINING, 64, 64)         // Create the mining ore distribution map.
	return 1
*/	//RS REMOVE END
/datum/skybox_settings/groundbase
	icon_state = "space5"
	use_stars = FALSE

/datum/planet/virgo3c/New()	//RS EDIT START
	expected_z_levels = list(
		Z_LEVEL_GB_BOTTOM,
		Z_LEVEL_GB_MIDDLE,
		Z_LEVEL_GB_TOP,
		Z_LEVEL_GB_WILD_N,
		Z_LEVEL_GB_WILD_S,
		Z_LEVEL_GB_WILD_E,
		Z_LEVEL_GB_WILD_W
		)
	. = ..()	//RS EDIT END

/obj/effect/landmark/map_data/groundbase
	height = 3

/obj/effect/overmap/visitable/sector/virgo3c
	name = "Virgo 3C"
	desc = "A small, volcanically active moon."
	scanner_desc = @{"[i]Registration[/i]: NSB Rascal's Pass
[i]Class[/i]: Installation
[i]Transponder[/i]: Transmitting (CIV), NanoTrasen IFF
[b]Notice[/b]: NanoTrasen Base, authorized personnel only"}
	known = TRUE
	in_space = TRUE

	icon = 'icons/obj/overmap.dmi'
	icon_state = "lush"

	skybox_icon = 'icons/skybox/skybox_rs.dmi'
	skybox_icon_state = "3c"

	skybox_pixel_x = 0
	skybox_pixel_y = 0

	initial_generic_waypoints = list("groundbase", "gb_excursion_pad","omship_axolotl")
	initial_restricted_waypoints = list()

	extra_z_levels = list(
		Z_LEVEL_GB_ENGINESAT,
		Z_LEVEL_MINING,
		Z_LEVEL_GB_WILD_N,
		Z_LEVEL_GB_WILD_S,
		Z_LEVEL_GB_WILD_E,
		Z_LEVEL_GB_WILD_W
		)

	space_zs = list(Z_LEVEL_GB_ENGINESAT)

/obj/effect/overmap/visitable/sector/virgo3c/generate_skybox(zlevel)
	var/static/image/smallone = image(icon = 'icons/skybox/skybox_rs.dmi', icon_state = "3c")
	return smallone

// We have a bunch of stuff common to the station z levels
/datum/map_z_level/groundbase
	flags = MAP_LEVEL_STATION|MAP_LEVEL_CONTACT|MAP_LEVEL_PLAYER|MAP_LEVEL_CONSOLES|MAP_LEVEL_XENOARCH_EXEMPT|MAP_LEVEL_PERSIST|MAP_LEVEL_SEALED
	holomap_legend_x = 220
	holomap_legend_y = 160
	transit_chance = 0

/datum/map_z_level/groundbase/level_one
	z = Z_LEVEL_GB_BOTTOM
	name = "Level 1"
	base_turf = /turf/simulated/floor/outdoors/newdirt_nograss/virgo3c
	transit_chance = 0
	holomap_offset_x = SHIP_HOLOMAP_MARGIN_X
	holomap_offset_y = SHIP_HOLOMAP_MARGIN_Y

/datum/map_z_level/groundbase/deck_two
	z = Z_LEVEL_GB_MIDDLE
	name = "Level 2"
	base_turf = /turf/simulated/open/virgo3c
	transit_chance = 0
	holomap_offset_x = SHIP_HOLOMAP_MARGIN_X
	holomap_offset_y = SHIP_HOLOMAP_MARGIN_Y + SHIP_MAP_SIZE

/datum/map_z_level/groundbase/deck_three
	z = Z_LEVEL_GB_TOP
	name = "Level 3"
	base_turf = /turf/simulated/open/virgo3c
	transit_chance = 0
	holomap_offset_x = HOLOMAP_ICON_SIZE - SHIP_HOLOMAP_MARGIN_X - SHIP_MAP_SIZE
	holomap_offset_y = SHIP_HOLOMAP_MARGIN_Y + SHIP_MAP_SIZE

/datum/map_z_level/groundbase/gb_enginesat
	z = Z_LEVEL_GB_ENGINESAT
	name = "Engine Satellite"
	flags = MAP_LEVEL_PLAYER|MAP_LEVEL_CONTACT|MAP_LEVEL_CONSOLES
	base_turf = /turf/space
	transit_chance = 100

/datum/map_template/gb_lateload
	allow_duplicates = FALSE

/////STATIC LATELOAD/////

#include "../expedition_vr/snowbase/submaps/glacier.dm"
#include "../expedition_vr/snowbase/submaps/glacier_areas.dm"

/datum/map_template/gb_lateload/on_map_loaded(z)
	if(!associated_map_datum || !ispath(associated_map_datum))
		log_game("Extra z-level [src] has no associated map datum")
		return

	new associated_map_datum(using_map, z)

//RS ADD START
/datum/map_template/station_map/gb1
	name = "GB1"
	mappath = 'maps/groundbase/rp-z1.dmm'

	associated_map_datum = /datum/map_z_level/groundbase/level_one

/datum/map_template/station_map/gb2
	name = "GB2"
	mappath = 'maps/groundbase/rp-z2.dmm'

	associated_map_datum = /datum/map_z_level/groundbase/deck_two

/datum/map_template/station_map/gb3
	name = "GB3"
	mappath = 'maps/groundbase/rp-z3.dmm'

	associated_map_datum = /datum/map_z_level/groundbase/deck_three

/datum/map_template/station_map/gb4
	name = "GB4"
	mappath = 'maps/groundbase/rp-z4.dmm'

	associated_map_datum = /datum/map_z_level/groundbase/gb_enginesat

/datum/map_template/station_map/gb3/on_map_loaded(z)

	seed_submaps(list(Z_LEVEL_GB_BOTTOM,Z_LEVEL_GB_MIDDLE,Z_LEVEL_GB_TOP), 100, /area/groundbase/unexplored/outdoors, /datum/map_template/groundbase/outdoor)	//Outdoor POIs
	seed_submaps(list(Z_LEVEL_GB_BOTTOM,Z_LEVEL_GB_MIDDLE), 200, /area/groundbase/unexplored/rock, /datum/map_template/groundbase/maintcaves)	//Cave POIs
//RS ADD END

/*
/datum/map_template/gb_lateload/gb_enginesat
	name = "Groundbase - Engine Satellite"
	desc = "Small satellite station to power Rascal's Pass."
	mappath = 'rp-z4.dmm'

	associated_map_datum = /datum/map_z_level/gb_lateload/gb_enginesat
*/

/datum/map_template/gb_lateload/gb_centcom
	name = "Groundbase - Central Command"
	desc = "Central Command lives here!"
	mappath = 'gb-centcomm.dmm'

	associated_map_datum = /datum/map_z_level/gb_lateload/gb_centcom

/datum/map_z_level/gb_lateload/gb_centcom
	name = "Centcom"
	flags = MAP_LEVEL_ADMIN|MAP_LEVEL_SEALED|MAP_LEVEL_CONTACT|MAP_LEVEL_XENOARCH_EXEMPT
	base_turf = /turf/simulated/floor/outdoors/rocks

/datum/map_z_level/gb_lateload/gb_centcom/New(datum/map/map)	//RS ADD START - Map swap related
	z = using_map.z_list["z_centcom"]
	. = ..()	//RS ADD END

/area/centcom //Just to try to make sure there's not space!!!
	base_turf = /turf/simulated/floor/outdoors/rocks

/datum/map_template/gb_lateload/gb_misc
	name = "Groundbase - Misc"
	desc = "Misc areas, like some transit areas, holodecks, merc area."
	mappath = 'gb-misc.dmm'

	associated_map_datum = /datum/map_z_level/gb_lateload/misc

/datum/map_z_level/gb_lateload/misc

	name = "Misc"
	flags = MAP_LEVEL_ADMIN|MAP_LEVEL_SEALED|MAP_LEVEL_CONTACT|MAP_LEVEL_XENOARCH_EXEMPT

/datum/map_z_level/gb_lateload/misc/New(datum/map/map)	//RS ADD START - Map swap related
	z = using_map.z_list["z_misc"]
	. = ..()	//RS ADD END

#include "groundbase_mining.dm"
/datum/map_template/gb_lateload/mining
	name = "V3c Underground"
	desc = "The caves underneath the survace of Virgo 3C"
	mappath = 'maps/groundbase/gb-mining.dmm'

	associated_map_datum = /datum/map_z_level/gb_lateload/mining

/datum/map_template/gb_lateload/mining/on_map_loaded(z)
	. = ..()
//	seed_submaps(list(Z_LEVEL_MINING), 60, /area/gb_mine/unexplored, /datum/map_template/space_rocks)	//POI seeding
	new /datum/random_map/automata/cave_system/no_cracks(null, 3, 3, Z_LEVEL_MINING, world.maxx - 4, world.maxy - 4)
	new /datum/random_map/noise/ore/gb_mining(null, 1, 1, Z_LEVEL_MINING, 64, 64)

/datum/map_z_level/gb_lateload/mining
	z = Z_LEVEL_MINING
	name = "V3c Underground"
	base_turf = /turf/simulated/floor/outdoors/newdirt_nograss/virgo3c
	flags = MAP_LEVEL_PLAYER|MAP_LEVEL_CONTACT|MAP_LEVEL_CONSOLES

#include "../expedition_vr/aerostat/_aerostat.dm"
/datum/map_template/common_lateload/away_aerostat
	name = "Remmi Aerostat - Z1 Aerostat"
	desc = "The Virgo 2 Aerostat away mission."
	mappath = 'maps/expedition_vr/aerostat/aerostat.dmm'
	associated_map_datum = /datum/map_z_level/common_lateload/away_aerostat

////////////////////////////////////////////////////////////////////////

/datum/map_template/gb_lateload/wilds
	name = "GB Wilderness Submap"
	desc = "Please do not use this."
	mappath = null
	associated_map_datum = null

/datum/map_z_level/gb_lateload/gb_north_wilds
	name = "GB North Wilderness"
	z = Z_LEVEL_GB_WILD_N
	flags = MAP_LEVEL_PLAYER|MAP_LEVEL_CONTACT|MAP_LEVEL_CONSOLES|MAP_LEVEL_SEALED

/datum/map_z_level/gb_lateload/gb_south_wilds
	name = "GB South Wilderness"
	z = Z_LEVEL_GB_WILD_S
	flags = MAP_LEVEL_PLAYER|MAP_LEVEL_CONTACT|MAP_LEVEL_CONSOLES|MAP_LEVEL_SEALED

/datum/map_z_level/gb_lateload/gb_east_wilds
	name = "GB East Wilderness"
	z = Z_LEVEL_GB_WILD_E
	flags = MAP_LEVEL_PLAYER|MAP_LEVEL_CONTACT|MAP_LEVEL_CONSOLES|MAP_LEVEL_SEALED

/datum/map_z_level/gb_lateload/gb_west_wilds
	name = "GB West Wilderness"
	z = Z_LEVEL_GB_WILD_W
	flags = MAP_LEVEL_PLAYER|MAP_LEVEL_CONTACT|MAP_LEVEL_CONSOLES|MAP_LEVEL_SEALED

/datum/map_template/gb_lateload/wilds/north/on_map_loaded(z)
	. = ..()
	new /datum/random_map/automata/cave_system/no_cracks(null, 3, 3, Z_LEVEL_GB_WILD_N, world.maxx, world.maxy)
	new /datum/random_map/noise/ore/mining(null, 1, 1, Z_LEVEL_GB_WILD_N, 64, 64)

/datum/map_template/gb_lateload/wilds/south/on_map_loaded(z)
	. = ..()
	new /datum/random_map/automata/cave_system/no_cracks(null, 3, 3, Z_LEVEL_GB_WILD_S, world.maxx, world.maxy)
	new /datum/random_map/noise/ore/mining(null, 1, 1, Z_LEVEL_GB_WILD_N, 64, 64)

/datum/map_template/gb_lateload/wilds/east/on_map_loaded(z)
	. = ..()
	new /datum/random_map/automata/cave_system/no_cracks(null, 3, 3, Z_LEVEL_GB_WILD_E, world.maxx, world.maxy)
	new /datum/random_map/noise/ore/mining(null, 1, 1, Z_LEVEL_GB_WILD_N, 64, 64)

/datum/map_template/gb_lateload/wilds/west/on_map_loaded(z)
	. = ..()
	new /datum/random_map/automata/cave_system/no_cracks(null, 3, 3, Z_LEVEL_GB_WILD_W, world.maxx, world.maxy)
	new /datum/random_map/noise/ore/mining(null, 1, 1, Z_LEVEL_GB_WILD_N, 64, 64)


/datum/map_template/gb_lateload/wilds/north/type1
	name = "Northern Wilds 1"
	desc = "Wilderness"
	mappath = 'maps/groundbase/northwilds/northwilds1.dmm'
	associated_map_datum = /datum/map_z_level/gb_lateload/gb_north_wilds
/datum/map_template/gb_lateload/wilds/north/type2
	name = "Northern Wilds 2"
	desc = "Wilderness"
	mappath = 'maps/groundbase/northwilds/northwilds2.dmm'
	associated_map_datum = /datum/map_z_level/gb_lateload/gb_north_wilds
/datum/map_template/gb_lateload/wilds/north/type3
	name = "Northern Wilds 3"
	desc = "Wilderness"
	mappath = 'maps/groundbase/northwilds/northwilds3.dmm'
	associated_map_datum = /datum/map_z_level/gb_lateload/gb_north_wilds

/datum/map_template/gb_lateload/wilds/north/typecustom
	name = "Northern Wilds CUSTOM"
	desc = "Wilderness"
	mappath = 'maps/groundbase/northwilds/northwilds_custom.dmm'
	associated_map_datum = /datum/map_z_level/gb_lateload/gb_north_wilds

/datum/map_template/gb_lateload/wilds/south/type1
	name = "Southern Wilds 1"
	desc = "Wilderness"
	mappath = 'maps/groundbase/southwilds/southwilds1.dmm'
	associated_map_datum = /datum/map_z_level/gb_lateload/gb_south_wilds
/datum/map_template/gb_lateload/wilds/south/type2
	name = "Southern Wilds 2"
	desc = "Wilderness"
	mappath = 'maps/groundbase/southwilds/southwilds2.dmm'
	associated_map_datum = /datum/map_z_level/gb_lateload/gb_south_wilds
/datum/map_template/gb_lateload/wilds/south/type3
	name = "Southern Wilds 3"
	desc = "Wilderness"
	mappath = 'maps/groundbase/southwilds/southwilds3.dmm'
	associated_map_datum = /datum/map_z_level/gb_lateload/gb_south_wilds
/datum/map_template/gb_lateload/wilds/south/type3/on_map_loaded(z)
	. = ..()
	// Using landmarks for this now.
	//seed_submaps(list(Z_LEVEL_GB_WILD_S), 6, /area/submap/groundbase/poi/wildvillage/plot/square, /datum/map_template/groundbase/wildvillage/square)	//POI seeding
	//seed_submaps(list(Z_LEVEL_GB_WILD_S), 2, /area/submap/groundbase/poi/wildvillage/plot/wide, /datum/map_template/groundbase/wildvillage/wide)
	//seed_submaps(list(Z_LEVEL_GB_WILD_S), 1, /area/submap/groundbase/poi/wildvillage/plot/long, /datum/map_template/groundbase/wildvillage/long)

/datum/map_template/gb_lateload/wilds/east/type1
	name = "Eastern Wilds 1"
	desc = "Wilderness"
	mappath = 'maps/groundbase/eastwilds/eastwilds1.dmm'
	associated_map_datum = /datum/map_z_level/gb_lateload/gb_east_wilds
/datum/map_template/gb_lateload/wilds/east/type2
	name = "Eastern Wilds 2"
	desc = "Wilderness"
	mappath = 'maps/groundbase/eastwilds/eastwilds2.dmm'
	associated_map_datum = /datum/map_z_level/gb_lateload/gb_east_wilds

/datum/map_template/gb_lateload/wilds/west/type1
	name = "Western Wilds 1"
	desc = "Wilderness"
	mappath = 'maps/groundbase/westwilds/westwilds1.dmm'
	associated_map_datum = /datum/map_z_level/gb_lateload/gb_west_wilds
/datum/map_template/gb_lateload/wilds/west/type2
	name = "Western Wilds 2"
	desc = "Wilderness"
	mappath = 'maps/groundbase/westwilds/westwilds2.dmm'
	associated_map_datum = /datum/map_z_level/gb_lateload/gb_west_wilds

/*
/datum/map_template/gb_lateload/wilds/north1/on_map_loaded(z)
	. = ..()
	seed_submaps(list(z), 60, /area/om_adventure/grasscave/unexplored, /datum/map_template/om_adventure/outdoor)
	seed_submaps(list(z), 60, /area/om_adventure/grasscave/rocks, /datum/map_template/om_adventure/cave)
	new /datum/random_map/automata/cave_system/no_cracks(null, 3, 3, z, world.maxx - 4, world.maxy - 4)
	new /datum/random_map/noise/ore/grasscave(null, 1, 1, z, 64, 64)
*/

////////////////////////////////////////////////////////////////////////
