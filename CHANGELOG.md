### Change Log
  
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