### Change Log
  
  
**[Beta 14]** - Tags & Prefixs to configs, ingonito & vote your warden
  
    
*Added*
*  Add-On: EventDay Toggle - enable/disable commands, convars & plugins while event day is active
    *  new plugin - disabled/eventday_toggle.smx
    *  new config file - addons/sourcemod/configs/MyJailbreak/eventday_toggle.cfg
*  Icons: Player command to enable/disable icons with clientprefs (cookies)
    *  new command - sm_icons - Allows player to toggle the player icons.
    *  new cvar - sm_icons_cmds - Set your custom chat commands for toggle icons(!icons (no 'sm_'/'!')(seperate with comma ', ')(max. 12 commands))
*  Warden: New overlay & sound for the player when he becomes new warden
    *  new cvar - sm_warden_sounds_youwarden - Path to the soundfile which should be played for the new warden.
    *  new cvar - sm_warden_overlays_warden - Path to the warden Overlay DONT TYPE .vmt or .vft
*  Weapons: Limit the usages of the !guns command.
    *  new cvar - sm_weapons_max_usages - Max usages of !guns command allowed.
*  Ratio: new convar to disable guard queue.
    *  new cvar - sm_ratio_disable_queue - 1 - disabled guard queue, 0 - enable guard queue
*  Add-On: Ratio - voice check - Check with Voiceannounce_EX if player has already spoken before allow move to guards
*  TeamGames: Version check
*  Add-On: restrict areas for EventDays - specify restricted areas with Franugs devzones (zone name - "MyJB-NoGo")
    *  new plugin - disabled/myjailbreak_devzones.smx
*  Suicidebomber: new cvar to smaller the bomb damage radius against teammates to counteract trolls.
    *  new cvar - sm_suicidebomber_bomb_radius_t - Radius for bomb damage on prisoners (reduce when you have problem with teamkiller) / 0 - disable team damage at all
*  Warden: new glow feature for warden & deputy - need CustomPlayerSkins
    *  new cvar - sm_warden_glow_enable - 0 - disabled, 1 - enable warden glow
    *  new cvar - sm_warden_glow_random - 0 - disabled, 1 - enable warden random glow everytime / ignores RGB values
    *  new cvar - sm_warden_glow_red - What glow to turn the warden into (set R, G and B values to 255 to disable) (Rgb): x - red value
    *  new cvar - sm_warden_glow_green - What glow to turn the warden into (rGb): x - green value
    *  new cvar - sm_warden_glow_blue - What glow to turn the warden into (rgB): x - blue value
    *  new cvar - sm_warden_glow_red_deputy - What glow to turn the deputy into (set R, G and B values to 255 to disable) (Rgb): x - red value
    *  new cvar - sm_warden_glow_green_deputy - What glow to turn the deputy into (rGb): x - green value
    *  new cvar - sm_warden_glow_blue_deputy - What glow to turn the deputy into (rgB): x - blue value
*  Add-On: Ratio: Support for r1kos VIP core
    *  new plugin - disabled/ratio_vipcore.smx
*  Zombie: new convar to adjust zombie movement speed.
    *  new cvar - sm_zombie_speed - Movement speed of zombies - 1.0 normal speed
*  Warden: New kind to choose warden. On roundbeginn guards can applicate as warden with !w. after a countdown all player get a vote menu to vote their next warden. Idea by Hexah!
    *  new cvar - sm_warden_choice - 0 - disabled, 1 - enable player choose their warden - ignores cooldowns
    *  new cvar - sm_warden_choice_team - 0 - only Prisoner, 1 - Prisoner & guards can choose their warden
    *  new cvar - sm_warden_choice_application_time - How many seconds after roundstart guards can applicate for warden
    *  new cvar - sm_warden_choice_vote_time - 0 - disabled, rounds in a row a player can be warden
    *  new cvar - sm_warden_choice_list - 0 - remove all applicans after vote, 1 - remove just the voted warden after vote, 2 - players stay on applicans list until !uw
*  Add-On: Change ConVars, block or execute commands & un/load plugins on EventDay start/end
    *  new plugin - disabled/eventday_toggle.smx
    *  new config - sourcemod/configs/MyJailbreak/eventday_toggle.cfg check comments in this cfg for configuration
*  Catch: Freezed players become an icecube model
    *  new cvar - sm_catch_model - path to the ice model
*  Add-On: Support for adding freeday to Zephyrus store
    *  new plugin - disabled/warden_zephstore_freeday.smx
		"FreeDay"
		{
			"price" "800"
			"type" "freeday"
		}
  
*Changed*
*  All Plugins: moved the plugins chat prefix (e.g. [MyJB.Tag]) from translation to plugins .cfg
    *  new cvar - sm_PLUGINNAME_prefix - Set your chat prefix for this plugin.
*  Ratio: moved guard questions from translation own cfg file - BigThx to BaFer!
    *  new config file - addons/sourcemod/configs/MyJailbreak/questions.cfg
*  PlayerTags: Plugin rewritten. Incognito mode. Support admin groups & providing support for TogsClanTags, CCC & ZstoreTags. moved all the player tags(e.g. [Warden]) from translation and to new cfg
    *  new command - sm_incognito - Allows admin to toggle incognito - show default tags instead of admin tags
    *  new config - sourcemod/configs/MyJailbreak/player_tags.cfg check comments in this cfg for configuration
    *  removed cvars - sm_playertag_flag - All cvars to set player tags are removed. check new config file.
    *  new cvar - sm_playertag_extern - 0 - disabled, 1 - don't overwrite chat tags given by extern plugins like ccc, togsclantags or zephyrus store
    *  changed cvar - sm_playertag_overwrite - 0 - if no tag is set in config clear the tag (show nothing) / 1 - if no tag is set in config show players steam group tag
    *  new cvar - sm_playertag_prefix - Set your chat prefix for this plugin.
    *  new cvar - sm_playertag_incognito_join - 0 - admins & VIP will recieve their tags right after join / 1 - admins & VIP will join incognito without admin tags
    *  new cvar - sm_playertag_incognito_time - seconds how long admins stay incognito - 0 - disabled, you have to !incognito to enable
    *  new cvar - sm_playertag_cmds - Set your custom chat commands for toggle incognito mode(!incognito (no 'sm_'/'!')(seperate with comma ', ')(max. 12 commands))
*  Warden: Set minimum value of sm_warden_cooldown_roundstart to 0
*  Freeday: Remove teleport to CT spawn
*  EventDays: restrict weapon shooting while truce/freeze-time
*  HUD: removed hosties dependency
*  HUD: use the 'new HUD' system for csgo
    *  new cvar - sm_hud_type - 0 - show hud via a center-bottom hint box (sm_hsay), 1 - show hud via 'new hud' system
    *  new cvar - sm_hud_red - Color of sm_hud_type '1' (set R, G and B values to 255 to disable) (Rgb): x - red value
    *  new cvar - sm_hud_green - Color of sm_hud_type '1' (set R, G and B values to 255 to disable) (rGb): x - green value
    *  new cvar - sm_hud_blue - Color of sm_hud_type '1' (set R, G and B values to 255 to disable) (rgB): x - blue value
    *  new cvar - sm_hud_alpha - Alpha value of sm_hud_type '1' set value to 255 to disable for transparency
    *  new cvar - sm_hud_x - x coordinate, from 0 to 1. -1.0 is the center of sm_hud_type '1'
    *  new cvar - sm_hud_y - y coordinate, from 0 to 1. -1.0 is the center of sm_hud_type '1'
*  Warden: reset cooldowns (sm_warden_cooldown_limit) when all CTs reached max.
  
  
  *Fixed*
*  War, zombie & duckhunt: fix team damage
*  Warden: taser clips
*  events: fix sm_*eventname*_randomspawn
*  minor errors, fixes & improvements
  
  
  
  
  Developer stuff*
*  New natives to dis/enable warden and check if enabled
    *  new native - void warden_enable(bool status) - Disable & enable warden plugin
    *  new native - bool warden_isenabled() - get the current status of warden plugin
*  New native & forward to check for different VIP types - the native calls the forward
    *  new native - bool MyJailbreak_CheckVIPFlags(int client, const char[] command, ConVar flags, char[] feature) - take a look at template plugin
    *  new forward - bool MyJailbreak_OnCheckVIP(int client, char[] feature) - features are named after their cvars (e.g "sm_ratio_flag")
    *  new template plugin - Add-ons/template_vip_forward.sp - example to grand vip for different features through different "Vip"-types
*  stock CheckVipFlag has been replaced with new native MyJailbreak_CheckVIPFlags
*  Added Code contribution guidelines - read before do a pull request
*  many code style adjustments - check https://github.com/shanapu/MyJailbreak/blob/dev/CONTRIBUTING.md
  
  
  
**[Beta 13]** - New Events, new features & many changes
  
*Thanks* 
Thank you, all you known & anonymous donators out there! You strengthen my motivation on this project!
Also Thanks go out to all the patient testers and bug reporter, Wihtout you we couldn't make this!
Much Thanks goes out to hexer10 aka papero for his massiv help on this update and joining the MyJailbreak project as equal collaborator. ty
  
*Added*
*  New Eventday: Teleport War - A FreeForAll Deathmatch where attacker & victim switch positions on hit.
    *  new plugin - teleport.smx - please help translate http://translator.mitchdempsey.com/sourcemod_plugins/277
        *  new command - sm_setteleport - Allows the Admin or Warden to set Teleport War
        *  new command - sm_teleport - Allows players to vote for a Teleport War
        *  new cvar - sm_teleport_enable - 0 - disabled, 1 - enable this MyJailbreak SourceMod plugin
        *  new cvar - sm_teleport_cmds_vote - Set your custom chat command for Event voting(!teleport (no 'sm_'/'!')(seperate with comma ', ')(max. 12 commands))
        *  new cvar - sm_teleport_cmds_set - Set your custom chat command for set Event(!teleport (no 'sm_'/'!')(seperate with comma ', ')(max. 12 commands))
        *  new cvar - sm_teleport_warden - 0 - disabled, 1 - allow warden to set teleport round
        *  new cvar - sm_teleport_admin - 0 - disabled, 1 - allow admin/vip to set teleport round
        *  new cvar - sm_teleport_flag - Set flag for admin/vip to set this Event Day
        *  new cvar - sm_teleport_vote - 0 - disabled, 1 - allow player to vote for teleport
        *  new cvar - sm_teleport_begin_admin - When admin set event (!setteleport) = 0 - start event next round, 1 - start event current round - Default 1
        *  new cvar - sm_teleport_begin_warden - When warden set event (!setteleport) = 0 - start event next round, 1 - start event current round - Default 1
        *  new cvar - sm_teleport_begin_vote - When users vote for event (!teleport) = 0 - start event next round, 1 - start event current round - Default 0
        *  new cvar - sm_teleport_begin_daysvote - When warden/admin start eventday voting (!sm_voteday) and event wins = 0 - start event next round, 1 - start event current round - Default 0
        *  new cvar - sm_teleport_teleport_spawn - 0 - start event in current round from current player positions, 1 - teleport players to spawn
        *  new cvar - sm_teleport_spawn - 0 - T teleport to CT spawn, 1 - cell doors auto open
        *  new cvar - sm_teleport_rounds - Rounds to play in a row
        *  new cvar - sm_teleport_aim - 0 - Keep your aim angle on switch, 1 - Use attacker/victims aim angle
        *  new cvar - sm_teleport_roundtime - Round time in minutes for a single teleport round
        *  new cvar - sm_teleport_beacon_time - Time in seconds until the beacon turned on (set to 0 to disable)
        *  new cvar - sm_teleport_trucetime - Time in seconds players can't deal damage
        *  new cvar - sm_teleport_cooldown_day - Rounds cooldown after a event until event can be start again
        *  new cvar - sm_teleport_cooldown_start - Rounds until event can be start after mapchange
        *  new cvar - sm_teleport_cooldown_admin - 0 - disabled, 1 - ignore the cooldown when admin/vip set teleport round
        *  new cvar - sm_teleport_sounds_enable - 0 - disabled, 1 - enable sounds
        *  new cvar - sm_teleport_sounds_start - Path to the soundfile which should be played for a start
        *  new cvar - sm_teleport_overlays_enable - 0 - disabled, 1 - enable overlays
        *  new cvar - sm_teleport_overlays_start - Path to the start Overlay DONT TYPE .vmt or .vft
        *  new cvar - sm_teleport_allow_lr - 0 - disabled, 1 - enable LR for last round and end eventday
*  New Eventday: Arms Race - A FreeForAll Deathmatch like original arms race
    *  new plugin - armsrace.smx - please help translate http://translator.mitchdempsey.com/sourcemod_plugins/277
        *  new config file - addons/sourcemod/configs/MyJailbreak/armsrace.ini - define weapons & order
        *  new command - sm_setarmsrace - Allows the Admin or Warden to set Arms Race
        *  new command - sm_armsrace - Allows players to vote for a Arms Race
        *  new cvar - sm_armsrace_enable - 0 - disabled, 1 - enable this MyJailbreak SourceMod plugin
        *  new cvar - sm_armsrace_cmds_vote - Set your custom chat command for Event voting(!armsrace (no 'sm_'/'!')(seperate with comma ', ')(max. 12 commands))
        *  new cvar - sm_armsrace_cmds_set - Set your custom chat command for set Event(!setarmsrace (no 'sm_'/'!')(seperate with comma ', ')(max. 12 commands))
        *  new cvar - sm_armsrace_warden - 0 - disabled, 1 - allow warden to set armsrace round
        *  new cvar - sm_armsrace_admin - 0 - disabled, 1 - allow admin/vip to set armsrace round
        *  new cvar - sm_armsrace_flag - Set flag for admin/vip to set this Event Day
        *  new cvar - sm_armsrace_vote - 0 - disabled, 1 - allow player to vote for armsrace
        *  new cvar - sm_armsrace_kill_loser - 0 - disabled, 1 - Kill loser on event end
        *  new cvar - sm_armsrace_begin_admin - When admin set event (!setarmsrace) = 0 - start event next round, 1 - start event current round - Default 1
        *  new cvar - sm_armsrace_begin_warden - When warden set event (!setarmsrace) = 0 - start event next round, 1 - start event current round - Default 1
        *  new cvar - sm_armsrace_begin_vote - When users vote for event (!armsrace) = 0 - start event next round, 1 - start event current round - Default 0
        *  new cvar - sm_armsrace_begin_daysvote - When warden/admin start eventday voting (!sm_voteday) and event wins = 0 - start event next round, 1 - start event current round - Default 0
        *  new cvar - sm_armsrace_teleport_spawn - 0 - start event in current round from current player positions, 1 - teleport players to spawn
        *  new cvar - sm_armsrace_spawn - 0 - T teleport to CT spawn, 1 - cell doors auto open
        *  new cvar - sm_armsrace_randomspawn - 0 - disabled, 1 - use random spawns on map (sm_armsrace_spawn 1)
        *  new cvar - sm_armsrace_rounds - Rounds to play in a row
        *  new cvar - sm_armsrace_roundtime - Round time in minutes for a single armsrace round
        *  new cvar - sm_armsrace_trucetime - Time in seconds players can't deal damage
        *  new cvar - sm_armsrace_cooldown_day - Rounds cooldown after a event until event can be start again
        *  new cvar - sm_armsrace_cooldown_start - Rounds until event can be start after mapchange
        *  new cvar - sm_armsrace_cooldown_admin - 0 - disabled, 1 - ignore the cooldown when admin/vip set armsrace round
        *  new cvar - sm_armsrace_sounds_enable - 0 - disabled, 1 - enable sounds
        *  new cvar - sm_armsrace_sounds_start - Path to the soundfile which should be played for a start
        *  new cvar - sm_armsrace_overlays_enable - 0 - disabled, 1 - enable overlays
        *  new cvar - sm_armsrace_overlays_start - Path to the start Overlay DONT TYPE .vmt or .vft
*  New Eventday: One in the Chamber - A FreeForAll Deathmatch like CODs One in the Chamber - Thx @hexah!
    *  new plugin - oneinthechamber.smx - please help translate http://translator.mitchdempsey.com/sourcemod_plugins/282
        *  new command - sm_setoneinthechamber - Allows the Admin or Warden to set One in the Chamber
        *  new command - sm_oneinthechamber - Allows players to vote for a One in the Chamber
        *  new cvar - sm_oneinthechamber_enable - 0 - disabled, 1 - enable this MyJailbreak SourceMod plugin
        *  new cvar - sm_oneinthechamber_cmds_vote - Set your custom chat command for Event voting(!oneinthechamber (no 'sm_'/'!')(seperate with comma ', ')(max. 12 commands))
        *  new cvar - sm_oneinthechamber_cmds_set - Set your custom chat command for set Event(!setoneinthechamber (no 'sm_'/'!')(seperate with comma ', ')(max. 12 commands))
        *  new cvar - sm_oneinthechamber_warden - 0 - disabled, 1 - allow warden to set oneinthechamber round
        *  new cvar - sm_oneinthechamber_admin - 0 - disabled, 1 - allow admin/vip to set oneinthechamber round
        *  new cvar - sm_oneinthechamber_flag - Set flag for admin/vip to set this Event Day
        *  new cvar - sm_oneinthechamber_vote - 0 - disabled, 1 - allow player to vote for oneinthechamber
        *  new cvar - sm_oneinthechamber_begin_admin - When admin set event (!setoneinthechamber) = 0 - start event next round, 1 - start event current round - Default 1
        *  new cvar - sm_oneinthechamber_begin_warden - When warden set event (!setoneinthechamber) = 0 - start event next round, 1 - start event current round - Default 1
        *  new cvar - sm_oneinthechamber_begin_vote - When users vote for event (!oneinthechamber) = 0 - start event next round, 1 - start event current round - Default 0
        *  new cvar - sm_oneinthechamber_begin_daysvote - When warden/admin start eventday voting (!sm_voteday) and event wins = 0 - start event next round, 1 - start event current round - Default 0
        *  new cvar - sm_oneinthechamber_teleport_spawn - 0 - start event in current round from current player positions, 1 - teleport players to spawn
        *  new cvar - sm_oneinthechamber_spawn - 0 - T teleport to CT spawn, 1 - cell doors auto open
        *  new cvar - sm_oneinthechamber_randomspawn - 0 - disabled, 1 - use random spawns on map (sm_oneinthechamber_spawn 1)
        *  new cvar - sm_oneinthechamber_rounds - Rounds to play in a row
        *  new cvar - sm_oneinthechamber_roundtime - Round time in minutes for a single oneinthechamber round
        *  new cvar - sm_oneinthechamber_trucetime - Time in seconds players can't deal damage
        *  new cvar - sm_oneinthechamber_cooldown_day - Rounds cooldown after a event until event can be start again
        *  new cvar - sm_oneinthechamber_cooldown_start - Rounds until event can be start after mapchange
        *  new cvar - sm_oneinthechamber_cooldown_admin - 0 - disabled, 1 - ignore the cooldown when admin/vip set oneinthechamber round
        *  new cvar - sm_oneinthechamber_sounds_enable - 0 - disabled, 1 - enable sounds
        *  new cvar - sm_oneinthechamber_sounds_start - Path to the soundfile which should be played for a start
        *  new cvar - sm_oneinthechamber_overlays_enable - 0 - disabled, 1 - enable overlays
        *  new cvar - sm_oneinthechamber_overlays_start - Path to the start Overlay DONT TYPE .vmt or .vft
*  Add-On: Support for frans1cos Most Active
    *  new plugin - disabled/myjailbreak_mostactive.smx
        *  new cvar - sm_ratio_mostactive - 0 - disabled, how many seconds a player need to join ct? (only if MostActive is available)
        *  new cvar - sm_ratio_mostactive_team - 1 - playtime as Terror / 2 - playtime in Total (CT,T&Spec)
        *  new cvar - sm_warden_mostactive - 0 - disabled, how many seconds a player need to become warden? (only if MostActive is available)
        *  new cvar - sm_warden_mostactive_team - 0 - playtime as Counter-Terror / 1 - playtime as Terror / 2 - playtime in Total (CT,T&Spec)
*  Add-On: Support for Healines gangs - disable gang perks on event days
    *  new plugin - disabled/myjailbreak_gangs.smx
*  PlayerTags: Two new Tags SuperAdmin & CoOwner Thx @ ichiballs
    *  new cvar - sm_playertag_coownerflag - Set the flag for CoOwner. Default 'r'
    *  new cvar - sm_playertag_superadminflag - Set the flag for Super Admin. Default 's'
*  Icons: ConVar to disable Icons on all eventdays
    *  new cvar - sm_icon_eventday - 0 - use the icons, 1 - disable icons on EventDays
*  Weapons: ConVar to disable weapons for CTs on not eventday rounds. (use armory)
    *  new cvar - sm_weapons_noeventday - 0 - disabled, 1 - enable the weapon menu on non-EventDays round (normal/simon rounds)
*  Menu: added !removefreeday for warden,deputy/guard to menu
*  Menu Add-On: Add your own menu items to top/botton of wardens/deputys/guards/prisoners jailmenu with .cfg
    *  new plugin - disabled/menu_custom.smx
    *  new config file - addons/sourcemod/configs/MyJailbreak/menu_custom.ini
*  MyJailbreak: Automatic random eventday every x round
    *  new cvar - sm_myjb_random_round - 0 - disabled / Every x round could be an event day
    *  new cvar - sm_myjb_random_chance - Chance that the choosen round would be an event day/voting
    *  new cvar - sm_myjb_random_type - 0 - Start an eventday voting / 1 - start an random eventday
    *  new cvar - sm_myjb_random_mapstart_delay - Wait after mapchange x rounds before try first event day
*  Add-On: Support for nhnkl159s Simple Stats
    *  new plugin - disabled/myjailbreak_simplestats.smx
        *  new cvar - sm_ratio_simplestats - 0 - disabled, how many seconds a player need to join ct? (only if simplestats is available)
        *  new cvar - sm_warden_simplestats - 0 - disabled, how many seconds a player need to become warden? (only if simplestats is available)
*  Catch: ConVar to kill loser team
    *  new cvar - sm_catch_kill_loser - 0 - disabled, 1 - Kill loserteam on event end / not for sm_catch_allow_lr '1'
*  DealDamage: ConVar to kill loser team
    *  new cvar - sm_dealdamage_kill_loser - 0 - disabled, 1 - Kill loserteam on event end
*  Warden - Mathquiz: resume support for simplechatprocessor. Now support both scp or chat-processor.
*  PlayerTags: resume support for simplechatprocessor. Now support both scp or chat-processor.
*  Warden: Withheld (forbid) last request command (need sm_hosties_lr_autodisplay "0") ThX Hexah
    *  new command - sm_nolastrequest - toggle withheld/release the last request
    *  new cvar - sm_warden_withheld_lr_enable - 0 - disabled, 1 - warden can witheld prisoners Last request commands
    *  new cvar - sm_warden_withheld_lr_deputy - 0 - disabled, 1 - deputy can witheld prisoners Last request commands
    *  new cvar - sm_warden_cmds_withheld_lr - Set your custom chat commands for witheld Last request(!nolastrequest (no 'sm_'/'!')(seperate with comma ', ')(max. 12 commands)
    *  new cvar - sm_warden_cmds_lr - Set your last request commands (add custom !lr cmds)(no 'sm_'/'!')(seperate with comma ', ')(max. 12 commands)
*  Warden - Math quiz: force using chat trigger as input for answers instead of using an installed chat processor
    *  new cvar - sm_warden_math_input - 0 - use chat trigger to receive chat input e.g. answer = '!math 526'. This is forced when no chat-processor is installed / 1 - use a chat-processor to recieve chat input e.g. answer = '526' / use '0' when chat input of will not recognized cause conflics with chat manipulation plugins like 'CCC'
*  Warden frienldy fire - toggle also cts ff - Thx @hexah!*
    *  new cvar - sm_warden_ff_ct_enable - 0 - disabled, 1 - enable ff for cts also
*  MyJailbreak: you can sort the order of event days in menus with config file
    *  new config file - addons/sourcemod/configs/MyJailbreak/config/sorting-eventdays.ini
*  Menu: Suffle the eventdays in menu on a event day voting 
    *  new cvar - sm_menu_shuffle - 0 - use 'sorting-eventdays.ini' on event day voting / 1 - Shuffle EventDays on voting
*  Zeus: Dis/Allow droping Zeus
    *  new cvar - sm_zeus_drop - 0 - disabled, 1 - allow player to drop their zeus - Thx @hexah!*
*  Warden - Disarm: Dis/Allow disarm knife on shoting hands
    *  new cvar - sm_warden_disarm_knife - 0 - negate the knife disarm, 1 - disarm all weapon - Thx @hexah!*
*  MyJailbreak: the possibility to end a planned or running event
    *  new command - sm_resetevent - End all running or planned event days
  
*Changed*
*  All Event Days: Possibility to start an event during the current round, instead wait for next round
    *  new cvars - sm_EVENTNAME_begin_admin - When admin set event (!setEVENTNAME) = 0 - start event next round, 1 - start event current round - Default 1
    *  new cvars - sm_EVENTNAME_begin_warden - When warden set event (!setEVENTNAME) = 0 - start event next round, 1 - start event current round - Default 1
    *  new cvars - sm_EVENTNAME_begin_vote - When users vote for event (!EVENTNAME) = 0 - start event next round, 1 - start event current round - Default 0
    *  new cvars - sm_EVENTNAME_begin_daysvote - When warden/admin start eventday voting (!sm_voteday) and event wins = 0 - start event next round, 1 - start event current round - Default 0
    *  new cvars - sm_EVENTNAME_teleport_spawn - 0 - start event in current round from current player positions, 1 - teleport players to spawn
*  Freeday: Allow warden on freeday event day
    *  new cvar - sm_freeday_allow_warden - 0 - warden disabled, 1 - allow player to become warden
*  Menu: Moved menu items 1. & 2. backwords so menu start on 3.
    *  new cvar - sm_menu_clean - remove 1. & 2. on first page, to avoid conflict with weapon switch
*  Weapons: Moved menu items 1. & 2. backwords so menu start on 3.
    *  new cvar - sm_weapons_cleanmenu - remove 1. & 2. on first page, to avoid conflict with weapon switch
*  Ratio: Moved menu items 1. & 2. (Yes / No)to 3. & 4. to avoid conflict with weapon switch
*  DealDamage: Changed from T vs CT to even teams Blue vs Red (model,glow,colorize) - Thx skyprah for great idea!
    *  new cvar - sm_dealdamage_color - 0 - disabled, 1 - color the model of the players
    *  new cvar - sm_dealdamage_model_blue - Path to the model for team blue.
    *  new cvar - sm_dealdamage_model_red - Path to the model for team red.
    *  new cvar - sm_dealdamage_overlays_blue - Path to the blue Overlay DONT TYPE .vmt or .vft
    *  new cvar - sm_dealdamage_overlays_red - Path to the red Overlay DONT TYPE .vmt or .vft
*  Hide/War/Zombie: Darken screen while in freeze
*  Ratio: When last guard move to prisoners, a prisoner from queue or random will be moved to guard - THX @mrkos9i4ok
*  Flags: all ConVars to set admin/vip flag has been extended to support mutliple flags ex. "r,s,t" use comma
*  renamed plugin - ratio_ctbans_fantom to ratio_ctbans_r1ko on authors request
*  PlayerTags: removed dependencies of chat-processor(optional now)
*  Warden: no warden/deputy on Last Request
    *  new cvar - sm_warden_remove_lr - 0 - disabled, 1 - enable warden will be removed on last request
    *  new cvar - sm_warden_deputy_remove_lr - 0 - disabled, 1 - enable deputy will be removed on last request
*  HUD: disbale hud for dead player
    *  new cvar - sm_hud_alive - 0 - show hud only to alive player, 1 - show hud to dead & alive player
*  MyJailbreak: disable hosties announcements on event days
*  Warden - Marker: remove on Last request.
*  Ratio CTbans: updated for databombs CTbans v2. You must update to CTbans v2! - Thx @databomb!
*  Ratio: Swap Spectators to T when joining guard queue - Thx @hexah!
    *  new cvar - sm_ratio_swap_spec_queue - 0 - Don't do anything if a Spec join in queue / 1 - Swap to T the Spectators who join in queue
*  Warden - Mute/Talkover: disable Warden/Deputy TalkOver after LR Announced - Thx @hexah!*
*  Warden - Mute/Talkover: disable Spectators also.
*  HUD - disable HUD on TeamGames game.
*  Menu: Allow player to vote for no event.
    *  new cvar - sm_menu_vote_noevent - 0 - disabled, 1 - allow player vote for 'no Event Day' on eventday voting
*  MyJailbreak: disable Medic room / heal stations while eventday
    *  new cvar - sm_myjb_medic - 0 - disabled, 1 - disable medic room when event day running
  
  
  *Fixed*
*  Menu: fixed setdays for warden (don't show restricted/disabled days)
*  Ratio: fixed custom VIP/Admin flags
*  Warden - mute: fixed confict with sourcecomms
*  Warden - bulletspark: fixed
*  PlayerTags: fixed custom VIP/Admin flags
*  PlayerTags: fixed tags in chat on foreign national players
*  Zombie: respawn with ratio restriction
*  Freeday: fixed roundtime when only one team has player
*  Freeday: NoBlock (no player collision)
*  Request - Killreason: fixed display all reasons
*  Duckhunt & KnifeFight: fix gravity ladderfix
*  Store Credits & paperclips: fix chat colors
*  Zombie: Respawn with restiction addon
*  Weapons: add/remove kevlar/helmet on eventday
*  Zeus: disable dropping taser - Thx @hexah!
*  Many minor fixes -> study commits ;D
  
  
*Removed*
*  removed dependencies of 'File/Folder Downloader and Precacher'-plugin. No need of downloads.txt or such plugins
    *  files will be downloaded automaticly. smartdm awesomeshit @zephyrus
*  removed cvars - sm_weapons_ct - obsolete cvars. **Please remove them from your configs!**
*  removed cvars - sm_weapons_t - obsolete cvars. **Please remove them from your configs!**
  
  
*Developer stuff*
*  Register EventDays plugins to myjb core and recieve them
    *  new native - MyJailbreak_AddEventDay(char[] name) - Register a eventday to myjailbreak core
    *  new native - MyJailbreak_RemoveEventDay(char[] name) - Remove a eventday to myjailbreak core
    *  new native - MyJailbreak_GetEventDays(char[] name) - Get a array with all event day name
*  New Forward for end and running or planned event day
    *  new forward - MyJailbreak_ResetEventDay()
*  Changed the way how weapons access is handled. natives insetad of switch ConVars
    *  new native - MyWeapons_AllowTeam(int client, bool status) - Allow a team to pick weapons from weapons menu 
    *  new native - MyWeapons_GetTeamStatus(int iTeam) - Get team status if weapons are allowed
*  Extented parameter of a warden forwards & native - new caller clientid - 0 on random
    *  changed forward - warden_OnWardenCreate(int client, int caller) - The client who called the set or become warden command
    *  changed native - warden_set(int client, int caller) -  The client who set the new warden
*  New Forwards for add items to menu - see template_custom_menu.sp
    *  new forward - MyJailbreak_MenuStart(int client, Menu menu)
    *  new forward - MyJailbreak_MenuEnd(int client, Menu menu)
    *  new forward - MyJailbreak_MenuHandler(Menu menu, MenuAction action, int client, int itemNum)
*  Removed smlib

  
  
  

**[Beta 12.0]** - removed dependencies & store support
  
*Added*
*  Add-On: Support for adding paperclips to Zephyrus store
    *  new plugin - disabled/warden_zephstore_paperclips.smx
        *  new cvar - sm_store_paperclips_round_limit - Number of times you can buy paperclips in a round (find in plugin.store.cfg)
        *  new cvar - sm_store_paperclips_amount - Number of paperclips you get (find in plugin.store.cfg)
*  Add-On: Support plugins for get credits for Zephyrus store & SM-Store on event day win
    *  new plugin - disabled/myjailbreak_zephstore_credits.smx
    *  new plugin - disabled/myjailbreak_sm-store_credits.smx
        *  new cvar - sm_store_credit_amount_eventdays - Number of credits to give out for winning an eventday (find in plugin.store.cfg)
        *  new cvar - sm_store_credit_eventdays_alive- Give out credits for winning an eventday for dead & alive player (find in plugin.store.cfg)
*  Zombie: respawn dead terrors as zombie - experimental
    *  new cvar - sm_zombie_terror - 0 - disabled, 1 - transform terrors into Zombie on death - experimental!
    *  new cvar - sm_zombie_terror_infect - 0 - all dead terrors become zombie, 1 - only terrors killed by zombie transform into Zombie
*  Warden: remove a freeday from player
    *  new command - sm_removefreeday - Allows a warden to remove a freeday from a player
    *  new cvar - sm_warden_cmds_freeday_remove - Set your custom chat command for give a freeday(!givefreeday (no 'sm_'/'!')(seperate with comma ', ')(max. 12 commands)
*  Menu: Added gangs for terror when a gangs plugin is installed
*  Warden - Marker: new command for clients to bind for marker
    *  new command - +beacons - Bind for markers to use instead rightclick mouse
  
  
*Changed*
*  *Sourcemod: Canceled support for sourcemod lower 1.8.0-git5597*
*  Warden: No command cooldown on roundstart when only one CT
*  HUD: Disable hud when player is in a last request
  
  
*Fixed*
*  Warden: Mathquiz with latest chat-processor
*  Warden - freedays: When player get freeday but joins ct
*  some minor fixes
  
  
*Removed*
*  Dependencies: removed dependencies of chat-processor & smartjaildoors (both are optional now)
  

**[Beta 11.0]** - Support for addicted CT Bans plugin
  
*Added*
*  Ratio: Support for new CTBans plugin by addicted
    *  new plugin - disabled/ratio_ctbans_addicted.smx - Support plugin for addicted CT Bans plugin
  
  
*Changed*
*  Support Plugins: changed name for ctbans plugins - to many ct bans
    *  renamed plugin - ratio_ctban to ratio_ctbans_databomb
    *  renamed plugin - ratio_ct_bans to ratio_ctbans_fantom
  
  
  
**[Beta 10]** - Ghosts War, Warden restrict & limits
  
*Added*
*  Ratio: Support for SteamRep.com, FantoMs CT Bans & Steam Groups - new switch commands & more
    *  new command - sm_prisoner - Allows a player to join prisoner
    *  new command - sm_spectator - Allows a player to join spectator
    *  new cvar - sm_ratio_cmds_clear - Set your custom chat command for admins to clear the guard queue (!clearqueue (no 'sm_'/'!')(seperate with comma ', ')(max. 12 commands))
    *  new cvar - sm_ratio_cmds_prisoner - Set your custom chat command for player to move to prisoner (!prisoner (no 'sm_'/'!')(seperate with comma ', ')(max. 12 commands))
    *  new cvar - sm_ratio_cmds_spec - Set your custom chat command for player to move to spectator (!spectator (no 'sm_'/'!')(seperate with comma ', ')(max. 12 commands))
    *  new plugin - disabled/ratio_ct_bans.smx - Support plugin for FantoMs CT Bans plugin
    *  new plugin - disabled/ratio_steamrep.smx - Support plugin for Jameless SteamRep.com Checker plugin
        *  new cvar - sm_ratio_steamrep_exclude - Which tags you DO NOT trust for reported scammers. Input the tags here for any community whose bans you DO NOT TRUST.
        *  new cvar - sm_ratio_steamrep_checkip - Include IP address of connecting players in query. Set to 0 to disable
    *  new plugin - disabled/myjailbreak_steamgroup.smx - Warden & Ratio support plugin for Steam Groups (need SteamWorks extension!)
        *  new cvar - sm_ratio_steamgroup - Steamgroup a player must be member before join CT (Find it on your steam groups edit page) (0000000 = disabled)
*  Warden: Added restict system for become warden like ratio restricts
    *  new cvar - sm_warden_stamm - 0 - disabled, how many stamm points a player need to become warden? (only if stamm is available)
    *  new cvar - sm_warden_reputation - 0 - disabled, how many reputation a player need to join ct? (only if reputation is available)
    *  new cvar - sm_warden_rankme - 0 - disabled, how many rankme points a player need to become warden? (only if stamm is available)
    *  new plugin - disabled/myjailbreak_steamgroup.smx - Warden & Ratio support plugin for Steam Groups (need SteamWorks extension!)
        *  new cvar - sm_warden_steamgroup - Steamgroup a player must be member before become Warden (Find it on your steam groups edit page) (0000000 = disabled)
*  New Eventday: Ghosts War - All Players are invisbile & immortal - every 6 seconds they go visible and mortal for 2 seconds. Last alive wins.
    *  new plugin - ghosts.smx - please help translate http://translator.mitchdempsey.com/sourcemod_plugins/271
        *  new command - sm_setghosts - Allows the Admin or Warden to set Ghosts
        *  new command - sm_ghosts - Allows players to vote for a Ghosts
        *  new cvar - sm_ghosts_enable - 0 - disabled, 1 - enable this MyJailbreak SourceMod plugin
        *  new cvar - sm_ghosts_cmds_vote - Set your custom chat command for Event voting(!ghosts (no 'sm_'/'!')(seperate with comma ', ')(max. 12 commands))
        *  new cvar - sm_ghosts_cmds_set - Set your custom chat command for set Event(!ghosts (no 'sm_'/'!')(seperate with comma ', ')(max. 12 commands))
        *  new cvar - sm_ghosts_warden - 0 - disabled, 1 - allow warden to set ghosts round
        *  new cvar - sm_ghosts_admin - 0 - disabled, 1 - allow admin/vip to set ghosts round
        *  new cvar - sm_ghosts_flag - Set flag for admin/vip to set this Event Day
        *  new cvar - sm_ghosts_vote - 0 - disabled, 1 - allow player to vote for ghosts
        *  new cvar - sm_ghosts_spawn - 0 - T teleport to CT spawn, 1 - cell doors auto open
        *  new cvar - sm_ghosts_rounds - Rounds to play in a row
        *  new cvar - sm_ghosts_invisible_time - Time in seconds players are invisible & immortal
        *  new cvar - sm_ghosts_visisble_time - Time in seconds players are visible & mortal
        *  new cvar - sm_ghosts_roundtime - Round time in minutes for a single ghosts round
        *  new cvar - sm_ghosts_beacon_time - Time in seconds until the beacon turned on (set to 0 to disable)
        *  new cvar - sm_ghosts_trucetime - Time in seconds players can't deal damage
        *  new cvar - sm_ghosts_cooldown_day - Rounds cooldown after a event until event can be start again
        *  new cvar - sm_ghosts_cooldown_start - Rounds until event can be start after mapchange
        *  new cvar - sm_ghosts_cooldown_admin - 0 - disabled, 1 - ignore the cooldown when admin/vip set ghosts round
        *  new cvar - sm_ghosts_sounds_enable - 0 - disabled, 1 - enable sounds
        *  new cvar - sm_ghosts_sounds_start - Path to the soundfile which should be played for a start
        *  new cvar - sm_ghosts_overlays_enable - 0 - disabled, 1 - enable overlays
        *  new cvar - sm_ghosts_overlays_start - Path to the start Overlay DONT TYPE .vmt or .vft
        *  new cvar - sm_ghosts_allow_lr - 0 - disabled, 1 - enable LR for last round and end eventday
    * Menu: added new eventday ghosts to set/voting menu
*  Hide: Added last request for hide in the dark
    *  new cvar - sm_hide_allow_lr - 0 - disabled, 1 - enable LR for last round and end eventday
*  Warden - Orders: Set your custom commands for every single order.
*  Warden: Limit max rounds in a row as warden incl cooldown
    *  new cvar - sm_warden_limit - 0 - disabled, rounds in a row a player can be warden
    *  new cvar - sm_warden_limit_minplayer - How many CT must be online before sm_warden_limit is active
    *  new cvar - sm_warden_cooldown_limit - 0 - disabled, rounds player can't become warden after he reached the warden limit (sm_warden_limit)
*  Warden: Player cooldown for become warden after a remove vote or remove warden by admin
    *  new cvar - sm_warden_cooldown_remove - 0 - disabled, rounds player can't become warden after he was vote out or removed by admin
*  Warden: Player cooldown for become warden after a roundstart, when player was warden in last round. to give other players chance to become warden
    *  new cvar - sm_warden_cooldown_roundstart - Time in seconds a the warden of last round must wait until become warden again, to give other player chance to be warden (need sm_warden_stay '0')
*  Warden: Cvar to allow all Guards to give personal freedays
    *  new cvar - sm_warden_freeday_guard - 0 - disabled, 1 - Allow all the guards to set a personal freeday. Default 0
*  Zombie: Health Regeneration for zombies
    *  new cvar - sm_zombie_zombie_regen - 0 - disabled, HPs a Zombie regenerates every 5 seconds
*  Weapons: Added Revolver
*  TeamGames: Stop current game, remove player from teams & destroy fence on active LastGuardRule
  
  
*Changed*
*  Warden - disarm: disbale weapon disarm (shot hand to drop weapon) on last request
*  Menu: Moved admin commands to !admin menu & split vote/set menu with changed cvars
    *  new cvar - sm_menu_admin - 0 - disable admin commands in all menus, 1 - show admin commands only in Myjailbreak menu, 2 - show admin command only in !admin menu, 3 - display admin command in all menus
    *  removed cvar - sm_menu_days - obsolete cvar. **Please remove from your config!**
    *  new cvar - sm_menu_setdays - 0 - disable, 1 - enable set eventdays menu for warden & admins
    *  new cvar - sm_menu_votedays - 0 - disable, 1 - enable vote eventdays menu all players
*  Warden - freeday: changed cvar 'sm_warden_freeday_victim_deputy' to 'sm_warden_freeday_deputy'
    *  removed cvar - sm_warden_freeday_victim_deputy - obsolete cvar. **Please remove them from your configs!**
    *  new cvar - sm_warden_freeday_deputy - 0 - disabled, 1 - Allow the deputy to set a personal freeday
*  Menu: Add voteitem 'No Eventday' to a event day voting
*  Support Plugins: changed name for plugins which support ratio & warden
    *  renamed plugin - ratio_kento_rankme to myjailbreak_kento_rankme
    *  renamed plugin - ratio_rankme to myjailbreak_rankme
    *  renamed plugin - ratio_reputation to myjailbreak_reputation
    *  renamed plugin - ratio_stamm to myjailbreak_stamm
*  Removed: 
  
  
*Fixed*
*  Warden - small error with logging & vote warden
*  Weapons - rar error when client left server in timer
*  Menu - Eventday Voting - fix double Event when event was set while voting
*  Warden - dropguns: no more punishment on empty taser
*  Warden - deputy: missing translation
*  Warden - friendly fire: working toggle with TeamGames
*  Hide: Remove icons on hide in the dark
*  DealDamage: fix result screen
*  Icons: fix some *_enable cvars
*  Weapons: restrict !guns for player in LastRequest
*  Late loading: re/load plugin in round Thx @olegtsvetkov
*  some translation
*  rar error weapon not owned by client
*  removed some debug messages
*  minor errors
  
  
*Developer stuff*
*  Forwards: New Forwards for start/end of a Eventday & LastGuardRuleStart
    *  new Forwards - MyJailbreak_OnLastGuardRuleStart()
    *  new Forwards - MyJailbreak_OnEventDayStart(char[] EventDayName)
    *  new Forwards - MyJailbreak_OnEventDayEnd(char[] EventDayName, int winner)
*  Change forward warden_OnWardenCreated from void to Action to block warden creation
*  Removed define marco loops - LoopClients(i) & LoopValidClients(i) https://forums.alliedmods.net/showthread.php?t=250251
*  Add source code files to travis auto builds
*  Builds website - bootstrap website for auto build binary download
*  Code optimizing Thx @olegtsvetkov
*  Changed code style on many parts
*  Clean up code
  
  
  
**[Beta 9.1]** - fixes
  
*Added*
*  Menu: added orders menu for warden/deputy
*  Ratio: cvar for move to CT and respawned.
    *  new cvar - sm_ratio_respawn - 0 - Move player on next round to CT / 1 - Move player immediately to CT and respawn
  
  
*Changed*
*  Translations:  using preferred method of shipping translations (single file per language)
  
  
*Fixed*
*  Warden - small error with remove warden
*  Menu - fix showing myjailshop without installed
*  Minior fixes
*  fixed build script THX bara!
  
  
  
**[Beta 9.0]** - icons, 3th party plugins & much more
  
*Added*
*  Weapons: allow maschine-guns per cvar
    *  new cvar - sm_weapons_negev - 0 - disabled, 1 - enable negev in weapon menu
    *  new cvar - sm_weapons_m249 - 0 - disabled, 1 - enable m249 in weapon menu
*  Ratio: Support for 3rd party plugins (moved CT Bans support to extra plugin)
    *  new plugin - disabled/ratio_ctban.smx - Support plugin for databombs CT Bans plugin
    *  new plugin - ratio_reputation.smx - Support plugin for oaaron99 Player Reputations plugin
        *  new cvar -sm_ratio_reputation - 0 - disabled, how many reputation a player need to join ct? (only if reputation is available)
    *  new plugin - disabled/ratio_stamm.smx - Support plugin for popoklopsis Stamm plugin
        *  new cvar - sm_ratio_stamm - 0 - disabled, how many stamm points a player need to join ct? (only if stamm is available)
    *  new plugin - disabled/ratio_rankme.smx - Support plugin for lok1s, Scoobys RankMe plugin
        *  new cvar - sm_ratio_rankme - 0 - disabled, how many rankme points a player need to join ct? (only if rankme is available)
    *  new plugin - disabled/ratio_kento_rankme.smx - Support plugin for Kentos RankMe plugin
        *  new cvar - sm_ratio_rankme - 0 - disabled, how many rankme points a player need to join ct? (only if kento rankme is available)
    *  new plugin - disabled/ratio_teambans.smx - Support plugin for baras TeamBans plugin
*  Zombie: KnockbackFix
    *  new cvar - sm_zombie_knockback - Force of the knockback when shot at. Zombies only
*  Menu: Added MyJailshop for Prisoners when installed
*  Request - Capitulation: Allow capitulated players to take up weapons per cvar & healthshot & c4 as standart
    *  new cvar - sm_capitulation_weapons - 0 - disabled, 1 - enable Terror can not pick up weapons after capitulation
*  Request/Warden - freedays: Menu to choose the personal freeday for this or next round. !givefreeday
*  MyJailbreak: Disabled command !endround (& sm_myjb_cmds_endround) on default. This command was thought for testing/debug
    *  new cvar - sm_myjb_allow_endround - 0 - disabled, 1 - enable !endround command for testing (disable against abusing)
*  TeamGames: Better Support on FFA-Events for KissLicks TeamGames (TeamGames 1.1.0.7)
    *  new plugin - disabled/myjailbreak_teamgames.smx - Support plugin for KissLicks TeamGames plugin
*  Warden: Orders menu for preconfigured order/calls with chat, hud, sounds & overlays support. Each order can be dis/enabled per map.
    *  new command - sm_order - opens the order menu
    *  new cvar - sm_warden_orders - 0 - disabled, 1 - enable allow warden to use the orders menu
    *  new cvar - sm_warden_orders_deputy - 0 - disabled, 1 - enable orders-feature for deputy, too",
    *  new cvar - sm_warden_cmds_orders - Set your custom chat command for open menu(!menu (no 'sm_'/'!')(seperate with comma ',')(max. 12 commands))
    *  new config file - addons/sourcemod/configs/MyJailbreak/orders.cfg
*  New builds system - sourcecode on github / binarys at http://shanapu.de/MyJailbreak
  
  
  
*Changed*
*  Warden - Handcuffs: a cuffed player have to press & hold +USE to lockpick with small progress animation
*  Warden - icons: Moved wardens icon module to a seperate plugin. New icons for cuffed, rebel & freeday
    *  removed cvars - sm_warden_icon_*** - obsolete cvars. **Please remove them from your configs!**
    *  new plugin - icons.smx - new icons & native to remove icon for client
        *  new cvar - sm_icons_warden_enable - 0 - disabled, 1 - enable the icon above the wardens head
        *  new cvar - sm_icons_warden_path - Path to the warden icon DONT TYPE .vmt or .vft
        *  new cvar - sm_icons_deputy_enable - 0 - disabled, 1 - enable the icon above the deputy head
        *  new cvar - sm_icons_deputy_path - Path to the deputy icon DONT TYPE .vmt or .vft
        *  new cvar - sm_icons_ct_enable - 0 - disabled, 1 - enable the icon above the guards head
        *  new cvar - sm_icons_ct_path - Path to the guard icon DONT TYPE .vmt or .vft
        *  new cvar - sm_icons_t_enable - 0 - disabled, 1 - enable the icon above the prisoners head
        *  new cvar - sm_icons_t_path - Path to the prisoner icon DONT TYPE .vmt or .vft
        *  new cvar - sm_icons_rebel_enable - 0 - disabled, 1 - enable the icon above the rebel prisoners head
        *  new cvar - sm_icons_rebel_path - Path to the rebel icon DONT TYPE .vmt or .vft
        *  new cvar - sm_icons_cuffs_enable - 0 - disabled, 1 - enable the icon above the cuffed prisoners head
        *  new cvar - sm_icons_cuffs_path - Path to the cuffed prisoner icon DONT TYPE .vmt or .vft
        *  new cvar - sm_icons_freeday_enable - 0 - disabled, 1 - enable the icon above the freeday prisoners head
        *  new cvar - sm_icons_freeday_path - Path to the freeday icon DONT TYPE .vmt or .vft
        *  new config file - cfg/MyJailbreak/Icons.cfg
*  Warden: Choose color of handcuffed client
    *  new cvar - sm_warden_color_cuffs_red - What color to turn the cuffed player into (set R, G and B values to 255 to disable) (Rgb): x - red value
    *  new cvar - sm_warden_color_cuffs_green - What color to turn the cuffed player into (rGb): x - green value
    *  new cvar - sm_warden_color_cuffs_blue - What color to turn the cuffed player into (rgB): x - blue value
*  Ratio: T will be moved instandly to CT and respawned when there is space.
*  Request/Warden - freedays:  Moved requests freeday module to warden plugin
    *  removed cvars - sm_freekill_freeday_*** - obsolete cvars. **Please remove them from your configs!**
        *  new cvar - sm_warden_freeday_enable - Allows a warden to give a freeday to a player
        *  new cvar - sm_warden_freeday_cmd - Set your custom chat command for give a freeday. no need for sm_ or !
        *  new cvar - sm_warden_freeday_color_red - What color to turn the warden into (set R, G and B values to 255 to disable) (Rgb): x - red value
        *  new cvar - sm_warden_freeday_color_green - What color to turn the warden into (rGb): x - green value
        *  new cvar - sm_warden_freeday_color_blue - What color to turn the warden into (rgB): x - blue value  
        *  new cvar - sm_warden_freeday_victim_deputy - 0 - disabled, 1 - Allow the deputy to set a personal freeday next round");
*  Catch: new overlay to fix misspelling. Frozen instead of freezed
    *  removed overlay - overlays/MyJailbreak/freeze - I recommend to change it in you config to:
    *  new overlay - overlays/MyJailbreak/frozen - I recommend this as overlays/MyJailbreak/freeze replacement
*  Zombie: Removed humans spawn with weapons & nades. Use weapon menu or armory.
    *  new cvar - sm_zombie_ammo - 0 - disabled, 1 - enable infinty ammo (with reload) for humans
  
  
  
*Fixed*
*  Warden - Painter: fix bug when enabled for t and t dies paint still active
*  Freeday: fix problem on sm_freeday_firstround and roundrestart
*  Drunk: fix invert movement on the x-axis/y-axis much thanks @ peace-maker!
*  Ratio: Unmute CT on teambalance
*  Eventdays with freeze: rar glitch player push out of map
*  download.txt: removed .bz2 file extension for deputy
*  Cowboy: Fix command sm_setcowboy
*  Request: Fix chat messages or freekill
*  Zeus: fix missing en translation
*  minor errors & smaller fixes
  
  
  
  
*Removed*
*  Removed Dependencies of the required plugins. So the plugins can be used as standalone
    *  Warden: Dependencies of MyJailbreak(core), hosties, smartjaildoors, chat-processor, VoiceannounceEX
    *  Ratio: Dependencies of MyJailbreak(core), warden
    *  Last Guard Rule: Dependencies of MyJailbreak(core), hosties, smartjaildoors, warden
    *  Weapons: Dependencies of MyJailbreak(core), warden
*  removed cvars - sm_warden_icon_*** - obsolete cvars. **Please remove them from your configs!**
*  removed cvars - sm_freekill_freeday_*** - obsolete cvars. **Please remove them from your configs!**
*  added & removed arms support.
  
  
  
  *Developer stuff*
*  Warden: New native to add paperclips (for MyJailShop support)
    *  new native - warden_handcuff_givepaperclip - Give a player a specific amount of paperclips
    *  new native - warden_handcuff_iscuffed - Check is player is in handcuffs
    *  new native - warden_freeday_has - returns if client has a freeday now
    *  new native - warden_freeday_set - Set the client get a freeday
*  MyJailbreak Natives: Changed all native names by adding MyJailbreak_* in front to avoid conflicts with 3rd party plugins
*  Forwards: New Forwards to add ratio support (restrict from guards/CT) for 3rd party plugins
    *  new forward - MyJailbreak_OnJoinGuardQueue - Called when a client trys to join the Guards(CT) or GuardQueue
*  Icons: New native to block a client icon
    *  new native - MyIcons_BlockClientIcon - Set status (true/false) if the icon of a player will be displayed
*  more comments in code
  
  
**[Beta *8.0*]** - Deputy, custom commands & much more
  
*Added*
*  Warden: Shoot weapon on ground to remove it
    *  new cvar - sm_warden_shootguns_enable - 0 - disabled, 1 - enable shoot guns on ground to remove
    *  new cvar - sm_warden_shootguns_mode - 1 - only warden / 2 - warden & deputy / 3 - warden, deputy & ct / 4 - all player
*  Ratio: Added one round cooldown for guard queue on wrong answer.
*  Ratio: New system to choose players to switch on unbalanced teams.
    *  new cvar - sm_ratio_balance_terror - 0 = Could result in unbalanced teams. 1 = Switch a random T, when nobody is in guardqueue to balance the teams.
    *  new cvar - sm_ratio_balance_guard - Mode to choose a guard to be switch to T on balance the teams. 1 = Last In First Out / 0 = Random Guard
    *  new cvar - sm_ratio_balance_warden - Prevent warden & deputy to be switch to T on balance the teams. Could result in unbalanced teams
*  Weapons: Kevlar & Helm for guards on roundstart except on event days
    *  new cvar - sm_weapons_kevlar - 0 - disabled, 1 - CT get Kevlar & helm on Spawn
*  Request - Capitulation: instand accept capitulation - the warden dont need to accept the capitulation per menu
    *  new cvar - sm_capitulation_accept - 0 - disabled, 1 - the warden have to accept capitulation on menupopup Default 1
*  Duckhunt: New kind to fly for ducks
    *  new keybind - +drop (drop weapon) - toggle fly and walk for ducks when sm_duckhunt_flymode 1
    *  new cvar - sm_duckhunt_flymode - 0 - Low gravity (old way), 1 - 'Flymode' (like a slow noclip with clipping). Bit difficult
*  Freeday: Player respawn on event freeday
    *  new cvar - sm_freeday_respawn - 1 - respawn on AutoFreeday when no CTs / 2 - respawn on firstround/vote/set Freeday / 3 - Both
    *  new cvar - sm_freeday_respawn_time - Time in seconds the player will respawn after round begin. Default 120
*  Catch: Freezetime for CTs. CTs can see freezed T though walls. Kill terror if he get catched more than once, make it available for LR & insert beacon.
    *  new cvar - sm_catch_freezetime - Time in seconds CTs are freezed. Default 15
    *  new cvar - sm_catch_overlays_start - Path to the start Overlay DONT TYPE .vmt or .vft
    *  new cvar - sm_catch_sound_start - Path to the soundfile which should be played for a start.
    *  new cvar - sm_catch_wallhack - 0 - disabled, 1 - enable wallhack for CT to see freezed enemeys
    *  new cvar - sm_catch_count - How many times a terror can be catched before he get killed. 0 = T dont get killed ever all T must be catched- Default 0
    *  new cvar - sm_catch_allow_lr - 0 - disabled, 1 - enable LR for last round and end eventday (need sm_catch_count min 1)
    *  new cvar - sm_catch_beacon_time - Time in seconds until the beacon turned on (set to 0 to disable)
*  Warden - Cell Doors: automatic open cell doors on warmup
*  Warden - Mute: new fuctions with cvars mute all T on roundbegin & dont mute dead player on warden talkover
    *  new cvar - sm_warden_mute_default - 0 - disabled, 1 - Prisoners are muted on roundstart by default. Warden have to unmute them. Default 0
    *  new cvar - sm_warden_talkover_dead - 0 - mute death & alive player on talkover, 1 - only mute alive player on talkover. Default 0
*  Warden - Deputy: The warden get a deputy to his side with configurable warden features.
    *  new model for deputy - "models/player/custom_player/kuristaja/jailbreak/guard3/guard3.mdl" - dont forget your downloads.ini and fastDL
    *  new command - sm_deputy - Allows the warden to choose a deputy or a player to become deputy
    *  new command - sm_undeputy - Allows the warden to remove the deputy and the deputy to retire from the position
    *  new admin command - sm_removedeputy - Allows the admin to remove the deputy
    *  new cvar - sm_warden_deputy_enable - 0 - disabled, 1 - enable this MyJailbreak SourceMod plugin
    *  new cvar - sm_warden_deputy_set - 0 - disabled, 1 - enable !w / !deputy - warden can choose his deputy.
    *  new cvar - sm_warden_deputy_become - 0 - disabled, 1 - enable !w / !deputy - player can choose to be deputy.
    *  new cvar - sm_warden_deputy_model - 0 - disabled, 1 - enable deputy model
    *  new cvar - sm_warden_deputy_model_path -  Path to the model for deputy. Default "models/player/custom_player/kuristaja/jailbreak/guard3/guard3.mdl"
    *  new cvar - sm_warden_deputy_warden_dead - 0 - Deputy will removed on warden death, 1 - Deputy will be new warden
    *  new cvar - sm_warden_backstab_deputy - 0 - disabled, 1 - enable backstab protection for deputy, too
    *  new cvar - sm_warden_bulletsparks_deputy - 0 - disabled, 1 - enable smaller bulletimpact sparks for deputy, too
    *  new cvar - sm_warden_open_deputy - 0 - disabled, 1 - deputy can open/close cells
    *  new cvar - sm_warden_color_red_deputy - What color to turn the deputy into (set R, G and B values to 255 to disable) (Rgb)
    *  new cvar - sm_warden_color_green_deputy - What color to turn the deputy into (rGb): x - green value
    *  new cvar - sm_warden_color_blue_deputy - What color to turn the deputy into (rgB): x - blue value
    *  new cvar - sm_warden_countdown_deputy - 0 - disabled, 1 - enable countdown for deputy, too
    *  new cvar - sm_warden_counter_deputy - 0 - disabled, 1 - Allow the deputy count player in radius, too
    *  new cvar - sm_warden_extend_deputy - 0 - disabled, 1 - enable the 'extend the roundtime'-feature for deputy,too
    *  new cvar - sm_warden_ff_deputy - 0 - disabled, 1 - enable switch ff for the deputy, too
    *  new cvar - sm_warden_handcuffs_deputy - 0 - disabled, 1 - enable handcuffs for deputy, too
    *  new cvar - sm_warden_icon_deputy_enable - 0 - disabled, 1 - enable the icon above the deputy head
    *  new cvar - sm_warden_icon_deputy - Path to the deputy icon DONT TYPE .vmt or .vft Default "decals/MyJailbreak/warden-4"
    *  new cvar - sm_warden_laser_deputy - 0 - disabled, 1 - enable Laser Pointer for Deputy, too
    *  new cvar - sm_warden_marker_deputy - 0 - disabled, 1 - enable 'advanced markers'-feature for deputy
    *  new cvar - sm_warden_math_deputy - 0 - disabled, 1 - enable mathquiz for deputy,too
    *  new cvar - sm_warden_mute_deputy - 0 - disabled, 1 - Allow to mute T-side player for deputy, too
    *  new cvar - sm_warden_noblock_deputy - 0 - disabled, 1 - enable noblock toggle for deputy, too
    *  new cvar - sm_warden_painter_deputy - 0 - disabled, 1 - enable 'Warden Painter'-feature for deputy, too
    *  new cvar - sm_warden_painter_terror_deputy - 0 - disabled, 1 - allow to toggle Painter for Terrorist as deputy, too
    *  new cvar - sm_warden_random_deputy - 0 - disabled, 1 - enable kill a random t for deputy,too
    *  new cvar - sm_warden_mark_rebel_deputy - 0 - disabled, 1 - enable 'mark/unmark prisoner as rebel'-feature for deputy, too
    *  new cvar - sm_warden_cmds_deputy - Set your custom chat command for open menu(!menu (no 'sm_'/'!')(seperate with comma ',')(max. 12 commands). Default "d"
    *  new cvar - sm_warden_cmds_undeputy - Set your custom chat command for open menu(!menu (no 'sm_'/'!')(seperate with comma ',')(max. 12 commands). Default "ud"
    *  new cvar - sm_warden_cmds_removedeputy - Set your custom chat commands for admins to remove a warden(!removewarden (no 'sm_'/'!')(seperate with comma ',')(max. 12 commands) Default "rd,fd"
    *  new cvar - sm_freekill_freeday_victim_deputy - 0 - disabled, 1 - Allow the deputy to set a personal freeday next round
    *  changed cvar - sm_warden_disarm_mode - 1 - Only warden can disarm, 2 - warden & deputy can disarm, 3 - All CT can disarm, 4 - Everyone can disarm (CT & T)
*  Event Days: bypass on eventday cooldown for admins
    +  new cvar - sm_EVENTDAYNAME_cooldown_admin - 0 - disabled, 1 - ignore the cooldown when admin/vip set event day
  
  
  
*Changed*
*  Commands: Add up to 12 custom commands to almost all myjailbreak commands.
    *  new cvar - sm_PLUGINNAME_cmds_FEATURENAME - Set your custom chat commands for *FEATURENAME*(no 'sm_'/'!')(seperate with comma ',')(max. 12 commands)
    *  removed cvar - sm_PLUGINNAME_cmd - obsolete cvars. **Please remove them from your configs!**
    *  removed commands - sm_ALTERNATIVE - double/different commands for same action. Use sm_PLUGINNAME_cmds_FEATURENAME
*  Warden: Chathint on successful vote to kick warden
*  Warden counter: Use the wardens FOV instead radius around him to count terrors
    *  removed cvar - sm_warden_counter_radius - obsolete cvar. Please remove them from your config!
*  Weapons: Players can get weapons from menu more than once in a round. No need to wait until next round.
*  Duckhunt: Changed the way to set health for hunter based on enemey count. https://github.com/shanapu/MyJailbreak/issues/77#issuecomment-242951426
    *  new cvar - sm_duckhunt_hunter_hp_extra - HP the Hunter get additional per extra duck.
*  Zombie: Changed the way to set health for zombies based on enemey count. https://github.com/shanapu/MyJailbreak/issues/77#issuecomment-242951426
    *  new cvar - sm_zombie_zombie_hp_extra - HP the zombie get additional per extra human.
  
  
  
*Fixed*
*  Warden - Icon: missing FastDL files
*  Warden - Icon Terror: fix black icon on decals/MyJailbreak/terror - **use sm_warden_icon_t "decals/MyJailbreak/terror-fix"**
*  Warden - Mark rebel: remove color on unmark
*  Warden - Handcuffs: Move cuffed player though walls... kind of fix not perfect!
*  Warden - Painter: fix painter for terrors. THX devu4!
*  Request - Freedays: fix player check for !givefreeday
*  Last Guard: fix sm_lastguard_minct bypass. THX devu4!
*  PlayerTags: fix tags on warden remove
*  Weapons: glitch to use menu on T side. THX devu4!
*  minor errors & smaller fixes
  
  
  
*Changed Requirements*
*  removed - Simple Chat Prozessor - https://bitbucket.org/minimoney1/simple-chat-processor - **remove/disable simple-chatprocessor.smx. Use new chat-processor!**
*  replacement - [Any] Chat-Processor - https://forums.alliedmods.net/showthread.php?p=2449343
  
  
  
**[Beta 7.2]** - fix for 1.7.x 
   
*Fixed* 
*  Compatibility issues with sourcemod 1.7.x 
  
  
  
**[Beta 7.1]** - smaller fixes
  
*Fixed*
*  Warden - Icon: sm_warden_icon_ct_enable 0 will not disable warden icon. THX devu4!
*  Ratio: missing quote in translation. THX Kailo97!
*  Ratio: minor error
*  CReplyToCommand for Commands instead CPrintToChat. THX good_live!
  
  
*removed*
*  Menu: TeamGames Menu Items - use https://github.com/shanapu/MyJailbreak/wiki/Add-Menu-Item
  
  
*updated*
*  RU translation: HUD, Menu, Ratio & Warden THX include!
  
  
  
**[Beta 7.0]** - Automute/Talkover, more icons, beacon & more!
  
*Added*
*  Ratio: Force player on connect or mapstart to terror team
    *  new cvar - sm_ratio_force_t 0 - disabled, 1 - force player on connect to join T side
*  Myjailbreak: Player can shoot buttons to toggle them. Big Thx to good_live & devu4!
    *  new cvar - sm_myjb_shoot_buttons 0 - disabled, 1 - allow player to trigger a map button by shooting it
*  Warden: A small menu to Mark or Unmark a player as rebel
    *  new command - sm_markrebel - Allows Warden to mark/unmark prisoner as rebel
    *  new cvar - sm_warden_mark_rebel - 0 - disabled, 1 - enable allow warden to mark/unmark prisoner as rebel (hosties)
*  HUD: Show LastGuards name on active Last Guard Rule
*  Warden - Mute: Automute player when warden speaks (talkover / be quiet). Exluding admin/vip
    *  new cvar - sm_warden_talkover - 0 - disabled, 1 - temporary mutes all client when the warden speaks
    *  new cvar - sm_warden_talkover_team - 0 - mute prisoner & guards on talkover, 1 - only mute prisoners on talkover
*  Warden - Counter: Count all terrorist in a radius around warden
    *  new command - sm_count - Allows Warden to count the prisoners in his radius
    *  new cvar - sm_warden_counter - 0 - disabled, 1 - Allow the warden count player in radius
    *  new cvar - sm_warden_counter_radius - Radius in meter to count prisoners inside
    *  new cvar - sm_warden_counter_mode - 1 - Show prisoner count in chat / 2 - Show prisoner count in HUD / 3 - Show prisoner count in chat & HUD / 4 - Show names in Menu / 5 - Show prisoner count in chat & show names in Menu / 6 - Show prisoner count in HUD & show names in Menu / 7 - Show prisoner count in chat & HUD & show names in Menu
*  Warden - Icons: Icons above Players head for warden, guard & prisoners
    *  new cvar - sm_warden_icon_ct_enable - 0 - disabled, 1 - enable the icon above the guards head
    *  new cvar - sm_warden_icon_ct - Path to the guard icon DONT TYPE .vmt or .vft
    *  new cvar - sm_warden_icon_t_enable - 0 - disabled, 1 - enable the icon above the prisoner head
    *  new cvar - sm_warden_icon_t - Path to the prisoner icon DONT TYPE .vmt or .vft
    *  new icons - http://shanapu.de/myjb/icons.jpg
*  Ratio: Possibility for admin to toggle ratio plugin on/off
    *  new command - sm_ratio - Allows the admin toggle the ratio check and player to see if ratio is enabled
    *  new cvar - sm_ratio_disabled - Allow the admin to toggle 'ratio check & autoswap' on/off with !ratio
    *  new cvar - sm_ratio_disbaled_announce - Announce in a chatmessage on roundend when ratio is disabled
*  Ratio: No Agreement, or Questions, or force to T connect for VIP/Admins
    *  new cvar - sm_ratio_vip_bypass - Bypass Admin/VIP though agreement / question
*  Torch Relay: Added wallhack for the torch.
    *  new cvar - sm_torch_wallhack - 0 - disabled, 1 - enable wallhack for the torch to find enemeys
*  Eventdays: Added Beacon to most event days
    *  new cvar - sm_myjb_beacon_radius - Sets the radius for the beacons rings
    *  new cvar - sm_myjb_beacon_width - Sets the thickness for the beacons rings
    *  new cvar - sm_myjb_beacon_CT_color_red - What color to turn the CT beacons into (set R, G and B values to 255 to disable) (Rgb): x - red value
    *  new cvar - sm_myjb_beacon_CT_color_green - What color to turn the CT beacons into (rGb): x - green value
    *  new cvar - sm_myjb_beacon_CT_color_blue - What color to turn the CT beacons into (rgB): x - blue value
    *  new cvar - sm_myjb_beacon_T_color_red - What color to turn the T beacons  into (set R, G and B values to 255 to disable) (Rgb): x - red value
    *  new cvar - sm_myjb_beacon_T_color_green - What color to turn the T beacons into (rGb): x - green value
    *  new cvar - sm_myjb_beacon_T_color_blue - What color to turn the T beacons into (rgB): x - blue value
    *  new cvar - sm_cowboy_beacon_time - Time in seconds until the beacon turned on (set to 0 to disable)
    *  new cvar - sm_dealdamage_beacon_time - Time in seconds until the beacon turned on (set to 0 to disable)
    *  new cvar - sm_drunk_beacon_time - Time in seconds until the beacon turned on (set to 0 to disable)
    *  new cvar - sm_duckhunt_beacon_time - Time in seconds until the beacon turned on (set to 0 to disable)
    *  new cvar - sm_ffa_beacon_time - Time in seconds until the beacon turned on (set to 0 to disable)
    *  new cvar - sm_hebattle_beacon_time - Time in seconds until the beacon turned on (set to 0 to disable)
    *  new cvar - sm_hide_beacon_time - Time in seconds until the beacon turned on (set to 0 to disable)
    *  new cvar - sm_knifefight_beacon_time - Time in seconds until the beacon turned on (set to 0 to disable)
    *  new cvar - sm_noscope_beacon_time - Time in seconds until the beacon turned on (set to 0 to disable)
    *  new cvar - sm_suicide_beacon_time - Time in seconds until the beacon turned on (set to 0 to disable)
    *  new cvar - sm_war_beacon_time - Time in seconds until the beacon turned on (set to 0 to disable)
    *  new cvar - sm_zeus_beacon_time - Time in seconds until the beacon turned on (set to 0 to disable)
    *  new cvar - sm_zombie_beacon_time - Time in seconds until the beacon turned on (set to 0 to disable)
    *  new cvar - sm_lastguard_beacon_time - Time in seconds until the beacon turned on (set to 0 to disable)
  
  
*Changed*
*  Zombie - Glow/wallhack begin on end of freezetime instead roundstart
  
  
*Fixed*
*  Zombie: Conflict with sm_skinchooser (no zombie model)
*  Duckhunt: Conflict with sm_skinchooser (no models)
*  Freeday: harmless warning on compile
*  Request: Freekill report show (on player reconnect) wrong names
*  HUD: Conflics with StartTimer & EventDay HUDs
*  Bug when "sm_eventday_allow_lr 1" and T count on roundstart = sm_hosties_lr_ts_max
*  minor errors, fixes & typos
*  Wiki rewrite & new tutorials
  
  
*New Requirements*
*  [ANY] VoiceannounceEX (VoiceHook) - https://forums.alliedmods.net/showthread.php?p=2177167
*  DHooks (Dynamic Hooks - Dev Preview) - https://forums.alliedmods.net/showthread.php?t=180114
  
  
*Developer stuff*
*  Natives: New natives for on/off beacons
    *  new native - BeaconOn Set client Beacon & intervall as float
    *  new native - BeaconOff Remove client Beacon
  
  
  
  **[Beta 6.1]** - smaller fixes
  
*Fixed*
*  Menu: personal freeday seen as admin
*  HUD: enable on start
*  Freeday: fix roundtime bug
*  Request: missing "en" translation
  
  
  
 **[Beta 6.0]** - Personal Freeday, Kill reason, allow LR on Eventday, Guard Questions & more
  
*Added*
*  Myjailbreak: Admincommand to force end the round as a draw 
    *  new command - sm_endround - Allows the Admin to force the roundend. (ADMFLAG_CHANGEMAP)
*  Ratio: Join guard agreement. Join Guard Qualification questions.
    *  new cvar - sm_ratio_join_mode - 0 - instandly join ct/queue, no confirmation / 1 - confirm rules / 2 - Qualification questions
    *  new cvar - sm_ratio_questions - How many question a player have to answer before join ct/queue. need sm_ratio_join_mode 2
*  Warden - Mute: Mute & Unmute all terrors
*  Request: Warden can give a personal Freeday a single player for next nonevent round. 
    *  new command - sm_givefreeday - Allows the Warden to give a freeday to a player
    *  new cvar - sm_freekill_freeday_victim - Allow the warden to set a personal freeday next round as pardon for the victim
    *  new cvar - sm_freekill_freeday_cmd - Set your custom chat command for give a freeday. no need for sm_ or !
    *  new cvar - sm_freekill_freeday_color_red - What color to turn the warden into (set R, G and B values to 255 to disable) (Rgb): x - red value
    *  new cvar - sm_freekill_freeday_color_green - What color to turn the warden into (rGb): x - green value
    *  new cvar - sm_freekill_freeday_color_blue - What color to turn the warden into (rgB): x - blue value
*  Request: Kill reason - When a CT kill a T, a menu pop up for the killer and he can give an statement (beta)
    *  new cvar - sm_killreason_enable - CT can answer with a menu the kill reason
*  Last Guard Rule: Adjust round time on runnnig Last Guard Rule
    *  new cvar - sm_lastguard_time - Time in minutes to end the last guard rule - 0 = keep original time
    *  new cvar - sm_lastguard_time_per_T - Time in seconds to add to sm_lastguard_time per living terror - 0 = no extra time per t
*  Event Days: new cvars for end last round of a running Eventday when Last Request is available. Much Thx to devu4!
    *  new cvar - sm_cowboy_allow_lr - enable, Last Request on last round
    *  new cvar - sm_drunk_allow_lr - enable, Last Request on last round
    *  new cvar - sm_duckhunt_allow_lr - enable, Last Request on last round
    *  new cvar - sm_ffa_allow_lr - enable, Last Request on last round
    *  new cvar - sm_war_allow_lr - enable, Last Request on last round
    *  new cvar - sm_hebattle_allow_lr - enable, Last Request on last round
    *  new cvar - sm_knifefight_allow_lr - enable, Last Request on last round
    *  new cvar - sm_noscope_allow_lr - enable, Last Request on last round
    *  new cvar - sm_zeus_allow_lr - enable, Last Request on last round
    *  new cvar - sm_zombie_allow_lr - enable, Last Request on last round
*  HUD: A players HUD display: Current Warden, Guards/Prisoner Count & planned/running eventday name
    *  new command - sm_hud - Allows player to toggle the hud display.
    * new cvar - sm_hud_enable - 0 - disabled, 1 - enable this MyJailbreak SourceMod plugin
*  Warden - Cell Doors: Check is current map is configurated in smartjaildoors. Thx to NomisCZ!
*  Menu: Added TeamGames commands !tg !games if these team games commands are available
*  Menu - Cell Doors: Check is current map is configurated in smartjaildoors. If not items not shown
*  Event Days - Cell Doors: Check is current map is configurated in smartjaildoors. If not force sm_*eventday*_spawn "1"
  
  
*Changed*
*  Warden - Handcuffs: Strip weapons on Cuffed
*  Warden: Splitted Overlays & sounds for countdown & math
    *  removed cvar - sm_warden_overlays_start
    *  removed cvar - sm_warden_overlays_stop
    *  removed cvar - sm_warden_sounds_start
    *  removed cvar - sm_warden_sounds_stop
    *  new cvar - sm_warden_countdown_overlays_enable - enable overlays for countdown
    *  new cvar - sm_warden_countdown_overlays_start - Path to the start Overlay  DONT TYPE .vmt or .vft
    *  new cvar - sm_warden_countdown_overlays_stop - Path to the stop Overlay DONT TYPE .vmt or .vft
    *  new cvar - sm_warden_countdown_sounds_enable - enable sounds for countdown
    *  new cvar - sm_warden_countdown_sounds_start - Path to the soundfile which should be played for a start countdown.
    *  new cvar - sm_warden_countdown_sounds_stop - Path to the soundfile which should be played for stop countdown.
    *  new cvar - sm_warden_math_sounds_enable - enable sounds for math quiz
    *  new cvar - sm_warden_math_sounds_stop - Path to the soundfile which should be played for stop countdown.
    *  new cvar - sm_warden_math_overlays_enable - enable overlays for math quiz
    *  new cvar - sm_warden_math_overlays_stop - Path to the stop Overlay DONT TYPE .vmt or .vft
*  Event Days: Translations for Event day name
*  Last Guard Rule: Remove cuffs on last guard rule start
*  Ratio: changed default custom command from !gua to !ct
*  Ratio: Prevent warden from move to terror when unbalanced team
*  Deal Damage: Better looking for HUD
*  Zombie: New Glow effect with wallhack for zombies, fix old glow bug
    *  new cvar - sm_zombie_glow_mode - 1 - human contours with wallhack for zombies, 2 - human glow effect without wallhack for zombies
*  Request: Change Rebel status on capitulation 
*  Player Tags: Splitted translation to chat & stats = different tags for chat & stats
  
  
*Fixed*
*  Warden - Mathquiz: Bug when type last answer before new quiz started
*  Last Guard Rule: Bug on first round -> auto restart -> stuck on last guard rule
*  Zombie: fix glow bug -> new glowing
*  Ratio: Fixed custom command !gua / !ct
*  Freeday: Bug on sm_freeday_firstround "1" and 1min round time
*  Player Tags: Shorten RU Tags  Thx to include1!
*  minor errors, fixes & typos
  
  
*Developer stuff*
*  Natives: Changed some existing native names
    *  changed native - before:"SetEventDay" now:"SetEventDayName" Set the name(char) of the planned/running Event Day
    *  changed native - before:"GetEventDay" now:"GetEventDayName" Get the name(char) of the planned/running Event Day
    *  changed native - before:"MyJBLogging" now:"ActiveLogging" Get the name of the planned/running Event Day
*  Natives: New natives for better Eventday/LastGuardRule detection - changed some existing native names
    *  new native - SetEventDayPlanned Boolean to set Event Day is planned true/false
    *  new native - IsEventDayPlanned Boolean to check Event Day is planned true/false
    *  new native - SetEventDayRunning Boolean to set Event Day is running true/false
    *  new native - IsEventDayRunning Boolean to check Event Day is running true/false
    *  new native - SetLastGuardRule Boolean to set Last Guard Rule is running true/false
    *  new native - IsLastGuardRule Boolean to check Last Guard Rule is running true/false
*  Renamed many functions & stocks and other shit for better visibility
*  Warden: Splitted warden.sp source to module .sp files
*  Request: Splitted request.sp source to module .sp files
*  Cleaned up code and more comments
  
  
*Bug found*
  
+  RU translation. Not shown completly cause cyrillic letters. Find fix or shorten phrases
  
  
**[Beta .5.2]** - VotingMenu fix   
  
*Fixed*  
*  menu: fixed translation  
  
  
**[Beta .5.1]** - LastGuard fixes   
  
*Fixed*  
*  LastGuardRule: missing phrases  
  
*Changed*
*  LastGuardRule: weapon menu open after trucetime
  
  **[Beta 5.0]** - Ratio,VoteDay,Disarm...more
  
*Added*
*  Ratio: Manage team ratios and a queue system for prisoners to join guard through. Supports priority queue to allow players with a certain flag to skip all players in the queue without that flag. Allows Admin to remove a player from guardqueue. Can be used with CTBans to block joining queue/guard when CTBanned.
    *  new command - sm_guard - Allows the prisoners to queue to CT
    *  new command - sm_viewqueue / sm_vq - Allows a player to show queue to CT.
    *  new command - sm_leavequeue / sm_lq - Allows a player to leave queue to CT.
    *  new admin command - sm_removequeue - Allows the admin to remove player from queue to CT.
    *  new cvar - sm_ratio_cmd - Set your custom chat command for become guard. no need for sm_ or ! Default  "gua"
    *  new cvar - sm_ratio_T_per_CT - How many prisoners for each guard. Default 2
    *  new cvar - sm_ratio_flag - 0 - disabled, 1 - enable VIPs moved to front of queue. Default 1
    *  new cvar - sm_ratio_vipflag - Set the flag for VIP. Default "a"
    *  new cvar - sm_ratio_adsvip - 0 - disabled, 1 - enable adverstiment for 'VIPs moved to front of queue' when player types !quard. Default 1
*  Menu: Admin &/or warden can start a voting which eventday should played next.
    *  new command - sm_voteday / sm_votedays / sm_voteeventdays - opens/start the vote a eventday menu for all player
    *  new cvar - sm_menu_voteday - 0 - disabled, 1 - enable voteing for a eventday
    *  new cvar - sm_menu_voteday_warden - 0 - disabled, 1 - allow warden to start a voting
    *  new cvar - sm_menu_voteday_admin - 0 - disabled, 1 - allow admin/vip  to start a voting
    *  new cvar - sm_menu_voteday_cooldown_day" - Rounds cooldown after a voting until voting can be start again
    *  new cvar - sm_menu_voteday_cooldown_start - Rounds until voting can be start after mapchange.
*  Warden: Disarm a players weapon by shoot his hand/arm
    *  new cvar - sm_warden_disarm - 0 - disabled, 1 - enable disarm weapon on shot the arms/hands
    *  new cvar - sm_warden_disarm_mode - 1 - Only warden can disarm, 2 - All CT can disarm, 3 - Everyone can disarm (CT & T)
    *  new cvar - sm_warden_disarm_drop - 1 - weapon will drop, 2 - weapon  disappears
*  Warden: RoundEndTime Reminder - warden gets a sound signal & chat/hud hint when 30sec, 60sec, 2min, 3min round time left
    *  new cvar - sm_warden_roundtime_reminder - 0 - disabled, 1 - announce remaining round time in chat & hud 3min,2min,1min,30sec before roundend
*  Translation: russian phrases Thx to include1 & murr
  
*Changed*
*  Warden: renamed drawer to painter
*  Translation: Better english translation Thx to JacobThePigeon
*  Menu: Admin flag
    *  new cvar - sm_menu_flag - Set flag for admin/vip to start a voting & see admin menus. Default "g"
*  Warden: reduced Bullet sparks size
*  Menu: Added "Close Cell Doors" to menu
*  Warden: determine pick up radius for cuffed Ts
    *  new cvar - sm_warden_handcuffs_distance", "2", "How many meters distance from warden to handcuffed T to pick up?
*  Warden: paperclip translatable
  
*Fixed*
*  Cowboy: Can't pickup revolver bug
*  Menu: Checkplayers
*  Warden: Painter/drawer toggle on spectator
*  Warden: MathQuiz "The Answer was {" bug
*  minor errors
*  minor translation typos
  
  
**[Beta 4.1]** - fixes (careless mistakes)
  
*Fixed*
*  PlayerTags: Prisoner translation fix (fange)
*  DealDamage: disable T weapons on roundend
*  Menu: minor error
  
  
**[Beta 4.0]** - DealDamage,Vip,Backstab,Paperclip...more
  
*Added*
*  Request: Admin/warden can choose respawn position on a freekill
    *  new cvar - sm_freekill_respawn_cell: 0 - cells are still open on respawn, 1 - cells will close on respawn in cell. Default 1
*  Request: Set bonus request (one more heal-,repeat-& refuserequest) with admin/vip flag.
    *  new cvar - sm_repeat_vip: Set flag for VIP to get one more repeat. No flag = feature is available for all players! Default a
    *  new cvar - sm_refuse_vip: Set flag for VIP to get one more refuse. No flag = feature is available for all players! Default a
    *  new cvar - sm_heal_vip: Set flag for VIP to get one more heal. No flag = feature is available for all players! Default a
*  Warden: Backstab protection
    *  new cvar - sm_warden_backstab: 0 - disabled, 1 - enable backstab protection for warden. Default 1
    *  new cvar - sm_warden_backstab_number: How many time a warden get protected? 0 - alltime. Default 1
*  Warden: Set features to admin/vip flag
    *  new cvar - sm_warden_painter_flag: Set flag for admin/vip to get painter access. No flag = feature is available for all players! Default ""
    *  new cvar - sm_warden_laser_flag: Set flag for admin/vip to get warden laser pointer. No flag = feature is available for all players! Default ""
    *  new cvar - sm_warden_bulletsparks_flag: Set flag for admin/vip to get warden bulletimpact sparks. No flag = feature is available for all players! Default ""
    *  new cvar - sm_warden_backstab_flag: Set flag for admin/vip to get warden backstab protection. No flag = feature is available for all players! Default ""
*  Warden: Chance a Terror got a paperclip to unleash when he get cuffed. Also a chance the paperclip break on unleashing attempt.
    *  new cvar - sm_warden_handcuffs_paperclip_chance: Set the chance (1:x) a cuffed Terroris get a paperclip to free themself. Default 5
    *  new cvar - sm_warden_handcuffs_unlock_chance: Set the chance (1:x) a cuffed Terroris who has a paperclip to free themself. Default 3
    *  new cvar - sm_warden_handcuffs_unlock_mintime: Min. Time in seconds Ts need free themself with a paperclip. Default 15
    *  new cvar - sm_warden_handcuffs_unlock_maxtime: Max. Time in seconds Ts need free themself with a paperclip. Default 35
    *  new cvar - sm_warden_handcuffs_flag: Set flag for admin/vip must have to get access to paperclip. No flag = feature is available for all players! Default ""
*  Translation: Russian Thx Murr & Include1!
*  Translation: Partially Italian Thx alsacchi!
*  New Day: Deal Damage - Deal so much damage as you can against enemey team. Team with most dealed damage wins.
    *  new command - sm_setdealdamage: Allows the Admin or Warden to set dealdamage as next round
    *  new command - sm_dealdamage: Allows players to vote for a dealdamage
    *  new cvar - sm_dealdamage_enable: 0 - disabled, 1 - enable this MyJailbreak SourceMod plugin. Default 1
    *  new cvar - sm_dealdamage_cmd: Set your custom chat command for Event voting. no need for sm_ or ! Default "dd" results in !dd /dd sm_dd
    *  new cvar - sm_dealdamage_warden: 0 - disabled, 1 - allow warden to set dealdamage round. Default 1
    *  new cvar - sm_dealdamage_admin: 0 - disabled, 1 - allow admin/vip to set dealdamage round. Default 1
    *  new cvar - sm_dealdamage_flag: Set flag for admin/vip to set this Event Day. Default g
    *  new cvar - sm_dealdamage_vote: 0 - disabled, 1 - allow player to vote for dealdamage. Default 1
    *  new cvar - sm_dealdamage_spawn: 0 - T teleport to CT spawn, 1 - cell doors auto open. Default 0
    *  *new cvar - sm_dealdamage_randomspawn: 0 - disabled, 1 - use random spawns on map (sm_dealdamage_spawn 1). Default 1*
        *  this is new as a test with random spawn points - if works good implement in other days.
    *  new cvar - sm_dealdamage_panel: 0 - disabled, 1 - enable show results on a panel. Default 1
    *  new cvar - sm_dealdamage_chat: 0 - disabled, 1 - enable print results in chat. Default 1
    *  new cvar - sm_dealdamage_console: 0 - disabled, 1 - enable print results in client console. Default 1
    *  new cvar - sm_dealdamage_rounds: Rounds to play in a row. Default 2
    *  new cvar - sm_dealdamage_roundtime: Round time in minutes for a single dealdamage round. Default 2
    *  new cvar - sm_dealdamage_trucetime: Time in seconds players can't deal damage. Default 15
    *  new cvar - sm_dealdamage_cooldown_day" - Rounds cooldown after a event until event can be start again. Default 3
    *  new cvar - sm_dealdamage_cooldown_start - Rounds until event can be start after mapchange. Default 3
    *  new cvar - sm_dealdamage_sounds_enable: 0 - disabled, 1 - enable sounds. Default 1
    *  new cvar - sm_dealdamage_sounds_start: Path to the soundfile which should be played for a start. Default "music/MyJailbreak/start.mp3"
    *  new cvar - sm_dealdamage_overlays_enable: 0 - disabled, 1 - enable overlays. Default 1
    *  new cvar - sm_dealdamage_overlays_start: Path to the start Overlay DONT TYPE .vmt or .vft. Default "overlays/MyJailbreak/start"
  
*Changed*
*  Warden: Limit number of extend rounds
    *  new cvar - sm_warden_extend_limit: How many time a warden can extend the round?. Default 2
*  Warden: Mute immunity
    *  new cvar - sm_warden_muteimmuntiy: Set flag for admin/vip mute immunity. No flag = immunity for all. so don't leave blank! Default a
*  Request: Limit number of freekill reports
    *  new cvar - sm_freekill_limit: Сount how many times you can report a freekill. Default 2
*  LastGuardRule: Cvar for freeze
    *  new cvar - sm_lastguard_freeze: Freeze all players the half of trucetime. Default 0
*  PlayerTags: Define your own admin/vip flags
    *  new cvar - sm_playertag_ownerflag: Set the flag for Owner. Default z
    *  new cvar - sm_playertag_adminflag: Set the flag for Admin. Default d
    *  new cvar - sm_playertag_vipflag: Set the flag for VIP. Default t
    *  new cvar - sm_playertag_vip2flag: Set the flag for VIP2. Default a
*  PlayerTags: Only overwrite PlayerTags for warden, admin & vip. Prisoner & guards use steamTag
    *  new cvar - sm_playertag_overwrite: 0 - only show tags for warden, admin & vip (no overwrite for prisoner & guards) 1 - enable tags for Prisioner & guards,too. Default 1
*  All Eventdays & request: Define your own admin/vip flags to set a Event Day
    *  new cvars - sm_'eventdayname'_flag: Set flag for admin/vip to set this Event Day. Default g
    *  new cvar - sm_freekill_flag: Set flag for admin/vip get reported freekills to decide. Default g
*  All Eventdays: Rules info panel will already shown on round end before a Eventday.
*  All Eventdays & LastGuard: Added close button to rules info panel
*  Hide: darken the sky (new skybox)
*  Duckhunt: Refillammo from a refilltimer to smilib
*  Warden: Unmute only alive player on LastRequest
*  Warden: flashing warden colors only main colours (no more brown,...)
*  Warden: Cuffs sound hearable for all
*  minor code improvements
*  minor notification changes
  
*Fixed*
*  Warden: remove warden color an teamchange
*  Warden: cvar sm_warden_bulletsparks 0
*  Request: Check for suicide on freekill report.
*  some translations
*  minor errors
*  double check IsClientInLastRequest & IsLastRequest
*  missing fog
  
*Disabled*  
*  Drunken: disbaled x/y axis invertion cuase unknown bug
  
  
**[Beta .3.1]** - extend roundtime & fixes   
*Added*  
* Warden: extend roundtime
    * new command - sm_extend - Allows the warden to extend the roundtime
    * new cvar - sm_warden_extend: 0- disabled, 1- Allows the warden to extend the roundtime. Default 1
* Warden: rainbow warden colors
    * new cvar - sm_warden_color_random: 0 - disabled, 1 - enable warden rainbow colored. Default 1
  
*Fixed*  
* Request: missing freekill translation  
  
  
**[Beta 3.0]** - introduce Last Guard Rule & more  
*Added*  
* Last Guard Rule: On last CT all terror become rebel
    * new command - sm_lastguard - Allows terrors to vote and last CT to set Last Guard Rule
    * new cvar - sm_lastguard_enable: 0 - disabled, 1 - enable this MyJailbreak SourceMod plugin
    * new cvar - sm_lastguard_cmd: Set your custom chat command for Last Guard Rule. no need for sm_ or !. Default "lg" results in !lg /lg & sm_lg
    * new cvar - sm_lastguard_ct: 0 - disabled, 1 - allow last CT to set Last Guard Rule
    * new cvar - sm_lastguard_vote: 0 - disabled, 1 - allow alive player to vote for Last Guard Rule
    * new cvar - sm_lastguard_auto: 0 - disabled, 1 - Last Guard Rule will start automatic if there is only 1 ct. Disables sm_lastguard_vote & sm_lastguard_ct
    * new cvar - sm_lastguard_hp: How many percent of the combined Terror Health the CT get? (3 terror alive with 100HP = 300HP / 50% = CT get 150HP: Default 50
    * new cvar - sm_lastguard_trucetime: Time in seconds players can't deal damage. Half of this time you are freezed. Default 10
    * new cvar - sm_lastguard_sounds_enable: 0 - disabled, 1 - enable sounds 
    * new cvar - sm_lastguard_sounds_start: Path to the soundfile which should be played for LGR beginn. "music/MyJailbreak/start.mp3"
    * new cvar - sm_lastguard_sounds_beginn: Path to the soundfile which should be played for LGR anouncment. "music/MyJailbreak/lastct.mp3"
    * new cvar - sm_lastguard_overlays_enable: 0 - disabled, 1 - enable overlays. Default 1
    * new cvar - sm_lastguard_overlays_start: Path to the start Overlay DONT TYPE .vmt or .vft. Default "overlays/MyJailbreak/start"
* Warden: Bullet impact sparks
    * new command - sm_sparks - Allows Warden to toggle on/off the wardens bullet sparks
    * new cvar - sm_warden_bulletsparks: 0 - disabled, 1 - enable Warden bulletimpact sparks
* Logging for warden, freekills & eventdays in logs/MyJailbreak
    * new cvar - sm_myjb_log: 0 - disabled, 1 - Allow MyJailbreak to log events, freekills & eventdays in logs/MyJailbreak by day
* Menu: new cvar - sm_menu_cmd: Set your custom chat command for Last Guard Rule. no need for sm_ or !. Default "panel" results in !panel /panel & sm_panel
* PlayerTags: Added more "ranks" for VIP-& Adminstags (ADMFLAG_ROOT(z), ADMFLAG_CHANGEMAP(g), ADMFLAG_CUSTOM6(t), ADMFLAG_RESERVATION(a))
* Translation: partially chinese phrases Thx to anon
* Translation: polish phrases ThX to la$ka  
  
*Fixed*  
* fit for SM 1.8
* bug where roundtime set to 1 when set new eventday on roundend of a eventday 
* Zombie: remove nightvision on roundend
* Translation: typos
* minor errors
  
  
**[Beta 2.1]** - bug fixes & typos  
*Fixed*  
* Warden: No movement on spec when died while cuffed
* Request: typo in freekill menu  
  
*Removed*  
* Warden: Debug messages on LR
* File: \fastDL\bz.bat
  
  
**[Beta 2.0]** - report freekill & fixes  
 *Added*  
* Warden: new cvar - "sm_warden_handcuffs_ct" 0 - disabled, 1 - Warden can also handcuff CTs  
* Request: report freekill to random admin or warden - respawn victim, kill freekiller, set freeday next round, move freekiller to terror  
    * new command - sm_freekill - Allows a Dead Terrorist report a Freekill
    * new cvar - sm_freekill_enable: 0 - disabled, 1 - Enable freekill report. Default 1
    * new cvar - sm_freekill_cmd: Set your custom chat command for freekill. no need for sm_ or !. Default "fk" results in !fk /fk & sm_fk
    * new cvar - sm_freekill_respawn: 0 - disabled, 1 - Allow the admin/warden to respawn a Freekill victim. Default 1
    * new cvar - sm_freekill_kill: 0 - disabled, 1 - Allow the admin/warden to Kill a Freekiller. Default 1
    * new cvar - sm_freekill_freeday: 0 - disabled, 1 - Allow the admin/warden to set a freeday next round as pardon. Default 1
    * new cvar - sm_freekill_swap: 0 - disabled, 1 - Allow the admin/warden to swap a freekiller to terrorist. Default 1
    * new cvar - sm_freekill_admin: 0 - disabled, 1 - Report will be send to admins - if there is no admin its send to warden. Default 1
    * new cvar - sm_freekill_warden: 0 - disabled, 1 - Report will be send to Warden if there is no admin. Default 1
  
 *Changed*  
* Request: Capitulation - weaponstrip only when warden accept  
* Freeday: default sm_freeday_cooldown_day from "3" to "0"  
  
 *Fixed*  
* Warden: bug on knife related !lr warden keeps taser (now remove taser on LR)  
* Warden: minor error - unmute msg & no warden  
* Menu: fix setfreeday, missing cowboy & zombies dont show if cowboy disabled  
* Weapons: fix warden lost knife on roundstart when choose new weapon  
  
 *Bug found*  
* Warden - MathQuiz: Response is not detected if user using Zephyrus stores message color  
  
  
**[Beta 1.0]** - first public beta release

### Versioning
for a better understanding:
```
0.7.2  
│ │ └───patch level - fix within major/minior release  
│ └─────minor release - feature/structure added/removed/changed  
└───────major release - stable/release  
```
