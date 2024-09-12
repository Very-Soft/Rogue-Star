/mob/living/silicon/ai
	var/obj/screen/ai_hud_deploy_display = null

/obj/screen/ai/multicam/Click()
    if(..())
        return
    var/mob/living/silicon/ai/AI = usr
    AI.toggle_multicam()

/obj/screen/ai/add_multicam/Click()
    if(..())
        return
    var/mob/living/silicon/ai/AI = usr
    AI.drop_new_multicam()

/obj/screen/ai/up/Click()
	var/mob/living/silicon/ai/AI = usr
	AI.zMove(UP)

/obj/screen/ai/down/Click()
	var/mob/living/silicon/ai/AI = usr
	AI.zMove(DOWN)

/mob/living/silicon/ai/create_mob_hud(datum/hud/HUD, apply_to_client = TRUE)
	..()

	HUD.ui_style = 'icons/mob/screen_ai.dmi'

	HUD.adding = list()
	HUD.other = list()
	HUD.alt = list()
	HUD.hotkeybuttons = list()
	HUD.hud_elements = list()

	var/obj/screen/using

//AI core
	using = new /obj/screen()
	using.name = "AI Core"
	using.icon = HUD.ui_style
	using.icon_state = "ai_core"
	using.screen_loc = ui_ai_core
	using.layer = SCREEN_LAYER
	HUD.adding += using

//Camera list
	using = new /obj/screen()
	using.name = "Show Camera List"
	using.icon = HUD.ui_style
	using.icon_state = "camera"
	using.screen_loc = ui_ai_camera_list
	using.layer = SCREEN_LAYER
	HUD.adding += using

//Track
	using = new /obj/screen()
	using.name = "Track With Camera"
	using.icon = HUD.ui_style
	using.icon_state = "track"
	using.screen_loc = ui_ai_track_with_camera
	using.layer = SCREEN_LAYER
	HUD.adding += using

//Camera light
	using = new /obj/screen()
	using.name = "Toggle Camera Light"
	using.icon = HUD.ui_style
	using.icon_state = "camera_light"
	using.screen_loc = ui_ai_camera_light
	using.layer = SCREEN_LAYER
	HUD.adding += using

//Crew Monitoring
	using = new /obj/screen()
	using.name = "Crew Monitoring"
	using.icon = HUD.ui_style
	using.icon_state = "crew_monitor"
	using.screen_loc = ui_ai_crew_monitor
	using.layer = SCREEN_LAYER
	HUD.adding += using

//Crew Manifest
	using = new /obj/screen()
	using.name = "Show Crew Manifest"
	using.icon = HUD.ui_style
	using.icon_state = "manifest"
	using.screen_loc = ui_ai_crew_manifest
	using.layer = SCREEN_LAYER
	HUD.adding += using

//Alerts
	using = new /obj/screen()
	using.name = "Show Alerts"
	using.icon = HUD.ui_style
	using.icon_state = "alerts"
	using.screen_loc = ui_ai_alerts
	using.layer = SCREEN_LAYER
	HUD.adding += using

//Announcement
	using = new /obj/screen()
	using.name = "Announcement"
	using.icon = HUD.ui_style
	using.icon_state = "announcement"
	using.screen_loc = ui_ai_announcement
	using.layer = SCREEN_LAYER
	HUD.adding += using

//Shuttle
	using = new /obj/screen()
	using.name = "Call Emergency Shuttle"
	using.icon = HUD.ui_style
	using.icon_state = "call_shuttle"
	using.screen_loc = ui_ai_shuttle
	using.layer = SCREEN_LAYER
	HUD.adding += using

//Laws
	using = new /obj/screen()
	using.name = "State Laws"
	using.icon = HUD.ui_style
	using.icon_state = "state_laws"
	using.screen_loc = ui_ai_state_laws
	using.layer = SCREEN_LAYER
	HUD.adding += using

//PDA message
	using = new /obj/screen()
	using.name = "PDA - Send Message"
	using.icon = HUD.ui_style
	using.icon_state = "pda_send"
	using.screen_loc = ui_ai_pda_send
	using.layer = SCREEN_LAYER
	HUD.adding += using

//PDA log
	using = new /obj/screen()
	using.name = "PDA - Show Message Log"
	using.icon = HUD.ui_style
	using.icon_state = "pda_receive"
	using.screen_loc = ui_ai_pda_log
	using.layer = SCREEN_LAYER
	HUD.adding += using

//Take image
	using = new /obj/screen()
	using.name = "Take Image"
	using.icon = HUD.ui_style
	using.icon_state = "take_picture"
	using.screen_loc = ui_ai_take_picture
	using.layer = SCREEN_LAYER
	HUD.adding += using

//View images
	using = new /obj/screen()
	using.name = "View Images"
	using.icon = HUD.ui_style
	using.icon_state = "view_images"
	using.screen_loc = ui_ai_view_images
	using.layer = SCREEN_LAYER
	HUD.adding += using

//Multicamera mode
	using = new /obj/screen/ai/multicam() // special
	using.name = "Multicamera Mode"
	using.icon = HUD.ui_style
	using.icon_state = "multicam"
	using.screen_loc = ui_ai_multicam
	using.layer = SCREEN_LAYER
	HUD.adding += using

//Add multicamera camera
	using = new /obj/screen/ai/add_multicam() // special
	using.name = "New Camera"
	using.icon = HUD.ui_style
	using.icon_state = "new_cam"
	using.screen_loc = ui_ai_add_multicam
	using.layer = SCREEN_LAYER
	HUD.adding += using

//Up and Down
	using = new /obj/screen/ai/up() // special
	using.name = "Move Upwards"
	using.icon = HUD.ui_style
	using.icon_state = "up"
	using.screen_loc = ui_ai_updown
	using.layer = SCREEN_LAYER
	HUD.adding += using

	using = new /obj/screen/ai/down() // special
	using.name = "Move Downwards"
	using.icon = HUD.ui_style
	using.icon_state = "down"
	using.screen_loc = ui_ai_updown
	using.layer = SCREEN_LAYER
	HUD.adding += using

// COMMON STUFF
	var/obj/screen/aw
	var/aw_icon = 'icons/mob/screen/minimalist.dmi'

	aw = new /obj/screen()
	aw.icon = aw_icon
	aw.icon_state = "autowhisper"
	aw.name = "autowhisper"
	aw.screen_loc = ui_under_health
	HUD.other |= aw

	aw = new /obj/screen()
	aw.icon = aw_icon
	aw.icon_state = "aw-select"
	aw.name = "autowhisper mode"
	aw.screen_loc = ui_under_health
	HUD.other |= aw

	aw = new /obj/screen()
	aw.icon = aw_icon
	aw.icon_state = "lang"
	aw.name = "check known languages"
	aw.screen_loc = ui_under_health
	HUD.other |= aw

	aw = new /obj/screen()
	aw.icon = aw_icon
	aw.icon_state = "pose"
	aw.name = "set pose"
	aw.screen_loc = ui_under_health
	HUD.other |= aw

	aw = new /obj/screen()
	aw.icon = aw_icon
	aw.icon_state = "up"
	aw.name = "move upwards"
	aw.screen_loc = ui_under_health
	HUD.other |= aw

	aw = new /obj/screen()
	aw.icon = aw_icon
	aw.icon_state = "down"
	aw.name = "move downwards"
	aw.screen_loc = ui_under_health
	HUD.other |= aw

	ai_hud_deploy_display = new /obj/screen()
	ai_hud_deploy_display.name = "mode switch"
	ai_hud_deploy_display.desc = "Toggles between mobile mode or hooking into the network."
	ai_hud_deploy_display.icon = 'icons/mob/pai_hud.dmi'
	ai_hud_deploy_display.screen_loc = ui_health
	ai_hud_deploy_display.icon_state = "folded"
	HUD.other |= ai_hud_deploy_display

/////////////////////////////////////////////////////

	var/obj/screen/mobile
	var/mobile_icon = 'icons/mob/pai_hud.dmi'

	mobile = new /obj/screen()
	mobile.name = I_HELP
	mobile.icon = mobile_icon
	mobile.icon_state = "intent_help-s"
	mobile.screen_loc = ui_acti
	mobile.alpha = 255
	mobile.layer = LAYER_HUD_ITEM //These sit on the intent box
	HUD.alt += mobile
	HUD.help_intent = mobile

	mobile = new /obj/screen()
	mobile.name = I_DISARM
	mobile.icon = mobile_icon
	mobile.icon_state = "intent_disarm-n"
	mobile.screen_loc = ui_acti
	mobile.alpha = 255
	mobile.layer = LAYER_HUD_ITEM
	HUD.alt += mobile
	HUD.disarm_intent = mobile

	mobile = new /obj/screen()
	mobile.name = I_GRAB
	mobile.icon = mobile_icon
	mobile.icon_state = "intent_grab-n"
	mobile.screen_loc = ui_acti
	mobile.alpha = 255
	mobile.layer = LAYER_HUD_ITEM
	HUD.alt += mobile
	HUD.grab_intent = mobile

	mobile = new /obj/screen()
	mobile.name = I_HURT
	mobile.icon = mobile_icon
	mobile.icon_state = "intent_harm-n"
	mobile.screen_loc = ui_acti
	mobile.alpha = 255
	mobile.layer = LAYER_HUD_ITEM
	HUD.alt += mobile
	HUD.hurt_intent = mobile

	//Move intent (walk/run)
	mobile = new /obj/screen()
	mobile.name = "mov_intent"
	mobile.icon = mobile_icon
	mobile.icon_state = (m_intent == "run" ? "running" : "walking")
	mobile.screen_loc = ui_movi
	mobile.color = "#ffffff"
	mobile.alpha = 255
	HUD.alt += mobile
	HUD.move_intent = mobile

	//Resist button
	mobile = new /obj/screen()
	mobile.name = "resist"
	mobile.icon = mobile_icon
	mobile.icon_state = "act_resist"
	mobile.screen_loc = ui_movi
	mobile.color = "#ffffff"
	mobile.alpha = 255
	HUD.alt += mobile
	HUD.hotkeybuttons += mobile

	//Pull button
	pullin = new /obj/screen()
	pullin.icon = mobile_icon
	pullin.icon_state = "pull0"
	pullin.name = "pull"
	pullin.screen_loc = ui_movi
	HUD.alt += mobile
	HUD.hotkeybuttons += pullin
	HUD.hud_elements |= pullin

	//Health status
	healths = new /obj/screen()
	healths.icon = mobile_icon
	healths.icon_state = "health0"
	healths.name = "health"
	healths.screen_loc = ui_health
	HUD.alt += mobile
	HUD.hud_elements |= healths

	pain = new /obj/screen( null )

	zone_sel = new /obj/screen/zone_sel( null )
	zone_sel.icon = mobile_icon
	zone_sel.color = "#ffffff"
	zone_sel.alpha = 255
	zone_sel.cut_overlays()
	zone_sel.update_icon()
	HUD.alt += mobile
	HUD.hud_elements |= zone_sel

/////////////////////////////////////////////////////////////////

	mobile = new /obj/screen()
	mobile.icon = mobile_icon
	mobile.icon_state = "autowhisper"
	mobile.name = "autowhisper"
	mobile.screen_loc = ui_under_health
	HUD.other |= mobile

	if(client && apply_to_client)
		client.screen = list()
		client.screen += HUD.adding + HUD.other
		client.screen += client.void

/mob/living/silicon/ai/handle_regular_hud_updates()
	. = ..()
	if(deployed)
		ai_hud_deploy_display.icon_state = "folded"
	else
		ai_hud_deploy_display.icon_state = "unfolded"

/obj/screen/Click(location, control, params)
	. = ..()
	if(!usr)	return 1
	if(isAI(usr))
		switch(name)
			if("mode switch")
				var/mob/living/silicon/ai/ourAI = usr
				ourAI.ai_mode_switch()
				if(!ourAI.deployed)
					ourAI.client.screen -= ourAI.hud_used.adding
					ourAI.client.screen |= ourAI.hud_used.alt
				else
					ourAI.client.screen -= ourAI.hud_used.alt
					ourAI.client.screen |= ourAI.hud_used.adding
