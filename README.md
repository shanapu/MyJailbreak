## MyJailbreak
a plugin pack for CS:GO jailserver
  
MyJailbreak is a redux rewrite of [Franugs Special Jailbreak](https://github.com/Franc1sco/Franug-Jailbreak/) a merge/redux of [eccas, ESK0s & zipcores Jailbreak warden](http://www.sourcemod.net/plugins.php?cat=0&mod=-1&title=warden&author=&description=&search=1) and many other plugins.
  
---
  
***Included Plugins:***
  
  
*  [**Warden**](https://github.com/shanapu/MyJailbreak/wiki/Warden) - set/become warden,vote retire warden, model, icon, extend roundtime, open cells,gun plant prevention, handcuffs, laser pointer, painter, set marker/quiz/EventDays/countdown/FF/nobock/mute
*  [**Request**](https://github.com/shanapu/MyJailbreak/wiki/Request) - terror requests. refuse a game, request Capitulation/Pardon, healing or repeating, report freekill.
*  [**Last Guard Rule**](https://github.com/shanapu/MyJailbreak/wiki/LastGuardRule) - When Last Guard Rule is set the last CT get more HP and all terrors become rebel
*  [**Menu**](https://github.com/shanapu/MyJailbreak/wiki/Menu) - player menus for T, CT, warden & admin
*  [**Weapons**](https://github.com/shanapu/MyJailbreak/wiki/Weapons) - weapon menus for CT &/or T(in event round)
*  [**PlayerTags**](https://github.com/shanapu/MyJailbreak/wiki/Playertags) - add player tags for T, T.Admin, CT, CT.Admin, W, WA.Admin in chat &/or stats
*  [**Ratio**](https://github.com/shanapu/MyJailbreak/wiki/Ratio) - Manage team ratios and a queue system for prisoners to join guard through
*  [**EventDays**](https://github.com/shanapu/MyJailbreak/wiki/Eventdays-core) - vote/set a Event Day for next round with cooldowns, rounds in row, sounds & overlays
    *    [**War**](https://github.com/shanapu/MyJailbreak/wiki/War) - CT vs T Team Deathmatch
    *    [**Free For All**](https://github.com/shanapu/MyJailbreak/wiki/Freeforall) - Deathmatch
    *    [**Zombie**](https://github.com/shanapu/MyJailbreak/wiki/Zombie) - CT(zombie) vs T(Human) stripped down zombiereloaded
    *    [**NoScope**](https://github.com/shanapu/MyJailbreak/wiki/Noscope) - No Scope Deathmatch with low gravity & configurable or random sniper
    *    [**HE Battle**](https://github.com/shanapu/MyJailbreak/wiki/Hebattle) - Grenade Deathmatch with low gravity
    *    [**Hide in the Dark**](https://github.com/shanapu/MyJailbreak/wiki/Hideinthedark) - CT(Seeker) vs T(Hider) kind of HideNseek
    *    [**Catch & Freeze**](https://github.com/shanapu/MyJailbreak/wiki/Catchfreeze) - CT must catch all T (freeze tag)
    *    [**DuckHunt**](https://github.com/shanapu/MyJailbreak/wiki/DuckHunt) - CT(hunter) with nova vs T(chicken in 3th person) with 'nades
    *    [**Suicide Bomber**](https://github.com/shanapu/MyJailbreak/wiki/SuicideBomber) - Ts got suicde bombs to kill all CTs
    *    [**Deal Damage**](https://github.com/shanapu/MyJailbreak/wiki/DealDamage) - Deal so much damage as you can to enemy team. Team with most damage dealed wins
    *    [**Zeus**](https://github.com/shanapu/MyJailbreak/wiki/Zeus) - Taser Deathmatch and get a new Zeus on Kill
    *    [**Drunken**](https://github.com/shanapu/MyJailbreak/wiki/Drunk) - Deathmatch under bad condisions
    *    [**Torch Relay**](https://github.com/shanapu/MyJailbreak/wiki/TorchRelay) - Random player set on fire. he must burn other to extinguish the fire
    *    [**Cowboy**](https://github.com/shanapu/MyJailbreak/wiki/Cowboy) - Revolver or Dual Baretta DM
    *    [**Knife**](https://github.com/shanapu/MyJailbreak/wiki/Knifefight) - Knife Deathmatch with configurable gravity, iceskate, and thirdperson
    *    [**Freeday**](https://github.com/shanapu/MyJailbreak/wiki/Freeday) - Auto freeday on first round &/or if there is no CT
  
---
  
***Features:***
  
* SourcePawn Transitional Syntax 1.7
* Multilingual support
* Custom chat commands !mycommand
* Custom chat tags [MyJB.tag]
* Colors
* Sounds & overlays
* Natives & forwards from [original warden plugins](http://www.sourcemod.net/plugins.php?cat=0&mod=-1&title=warden&author=&description=&search=1) to keep compatibility
* [Template](https://github.com/shanapu/MyJailbreak/wiki/Eventdays-template) to make your own Eventday
* some other fancy stuff
  
---
  
**I would be happy and very pleased if you want to join this project as equal collaborator. 
Even if you are a beginner and willing to learn or you just want to help with translations.** 
If you own a feature or extention for jail or have an idea that would fit in, i would be happy when you *share it with us*.
  
This is my first public project. please note that the code may is messy, stupid and inconseqent or mix different coding styles.  
  
coded with ![](http://shanapu.de/githearth-small.png) free software
  
---
  
***Change Log***
  
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
    *  new cvar - sm_menu_voteday_warden - 0 - disabled, 1 - allow warden to start a voting
    *  new cvar - sm_menu_voteday_admin - 0 - disabled, 1 - allow admin/vip  to start a voting
    *  new cvar - sm_menu_voteday_cooldown_day - Rounds cooldown after a voting until voting can be start again
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
    *  new cvar - sm_warden_handcuffs_distance - How many meters distance from warden to handcuffed T to pick up?
*  Warden: paperclip translatable
  
*Fixed*
*  Cowboy: Can't pickup revolver bug
*  Menu: Checkplayers
*  Warden: Drawer/Painter toggle on spectator
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
    *  new cvar - sm_dealdamage_cooldown_day - Rounds cooldown after a event until event can be start again. Default 3
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

  
---
  
***Known Bugs***
> 
> Weapons: sm_weapons_ct/sm_weapons_t is blocking ["Stamm - Vip Models Menu"](https://github.com/popoklopsi/Stamm/blob/master/stamm_models.sp) - *can anyone tell me why?*  
> Duckhunt & HE Battle: player get new grenade but sometimes rarly can't throw anymore - *need help!*
> 
> you found a bug? tell it please!
> 
  
---
  
***Recommended plugins***
  
* [CS:GO] Flashlight https://forums.alliedmods.net/showthread.php?p=2042310

* [CSS/CS:GO] Disable Radar https://forums.alliedmods.net/showthread.php?p=2138783
  
  
***Requires plugins***
  
* Sourcemod 1.7.0+
* SM hosties 2 https://github.com/dataviruset/sm-hosties/
* Smart Jail Doors https://github.com/Kailo97/smartjaildoors
* SM File/Folder Downloader and Precacher https://forums.alliedmods.net/showthread.php?p=602270 for zombie/warden model download
* Simple Chat Prozessor https://bitbucket.org/minimoney1/simple-chat-processor
* CustomPlayerSkins https://forums.alliedmods.net/showthread.php?t=240703

*Include files needed for compile*
* autoexecconfig.inc https://forums.alliedmods.net/showthread.php?t=204254
* colors.inc https://forums.alliedmods.net/showthread.php?t=96831
* emitsoundany.inc https://forums.alliedmods.net/showthread.php?t=237045
* myjailbreak.inc https://github.com/shanapu/MyJailbreak/blob/master/addons/sourcemod/scripting/include/myjailbreak.inc
* scp.inc https://forums.alliedmods.net/showthread.php?t=198501
* smartjaildoors.inc https://forums.alliedmods.net/showthread.php?p=2306289
* warden.inc https://github.com/shanapu/MyJailbreak/blob/master/addons/sourcemod/scripting/include/warden.inc (myjailbreak version)
* smlib.inc https://github.com/bcserv/smlib
* CustomPlayerSkins.inc https://forums.alliedmods.net/showthread.php?t=240703
  
---
  
***Installation***

1. Make sure you have the *latest versions* of the **required plugins**
2. Download the [latest release](https://github.com/shanapu/MyJailbreak/releases
3. Copy the folders ```addons/```,``` cfg/```, ```materials/```, ```models/``` &``` sound/``` to *your root* ```csgo/``` directory  
4. Copy the folders ```materials/```, ```models/``` & ```sound/``` *in the fastDL/ directory* to *your* ```FastDownload server```  
5. Open *your* ```downloads.ini``` in ```your csgo/addons/sourcemod/configs``` directory and add the content of ```downloads.txt```  
6. Run plugin for the first time and **all necessary .cfg files will be generated** 
7. Configure all settings in ```cfg/MyJailbreak``` to your needs
8. Have fun! Give feedback!
  
---
  
***Download Latest***  
https://github.com/shanapu/MyJailbreak/releases  
  
***Wiki:*** need some work  
https://github.com/shanapu/MyJailbreak/wiki/  
  
***Report Bugs, Ideas, Requests & see todo:***  
https://github.com/shanapu/MyJailbreak/issues  
https://forums.alliedmods.net/showthread.php?t=283212  
  
***Code changes:***  
https://github.com/shanapu/MyJailbreak/commits/master  
  
---
  
***Credits:***
used code & stuff from: **ecca, Zipcore, ESK0, Floody.de, Franc1sco, walmar, KeepCalm, bara, Arkarr, KissLick, headline, MasterOfTheXP, Hipster, ReFlexPoison, 8guawong, Mitchell, Xines, Jackmaster, Impact123, Kaesar, andi67** and many other I cant remember unfortunately!
Also thanks to all sourcemod & metamod developers out there!
  
based/merged/used code/idea plugins:  
* https://github.com/ecca/SourceMod-Plugins/tree/sourcemod/Warden
* https://github.com/ESK0/ESK0s_Jailbreak_warden/
* https://forums.alliedmods.net/showpost.php?p=1657893&postcount=11?p=1657893&postcount=11
* https://git.tf/Zipcore/Warden
* https://git.tf/Zipcore/Warden-Sounds
* https://git.tf/Zipcore/Warden-SimpleMarkers
* https://forums.alliedmods.net/showthread.php?t=264848
* https://github.com/Franc1sco/Franug-Jailbreak/
* https://forums.alliedmods.net/showthread.php?t=231473
* https://forums.alliedmods.net/showthread.php?p=1922088
* https://github.com/walmar/ShortSprint
* https://github.com/KissLick/TeamGames/
* https://github.com/AG-Headline/Hunger-Games-Beacon
* https://forums.alliedmods.net/showthread.php?p=1086127
* https://forums.alliedmods.net/showthread.php?t=234169
* https://forums.alliedmods.net/showthread.php?p=1749220
* https://forums.alliedmods.net/showthread.php?t=188799
* https://forums.alliedmods.net/showthread.php?t=189956
* https://forums.alliedmods.net/showthread.php?t=188773
* https://forums.alliedmods.net/showpost.php?p=2393733&postcount=12
* https://forums.alliedmods.net/showthread.php?p=1965643
* https://forums.alliedmods.net/showpost.php?p=2231099&postcount=22
+ https://github.com/Zipcore/Timer/ (sound)
* https://git.tf/TTT/Plugin (sound)
* https://forums.alliedmods.net/showthread.php?t=262170 (model)
* http://www.andi67.bplaced.net/Forum/viewtopic.php?f=40&t=342 (model)
* if I missed someone, please tell me!
* THANK YOU ALL!

# THANKS FOR MAKING FREE SOFTWARE!
**Much Thanks:**
Weeeishy, UartigZone, Got Sw4g? terminator18, SkeLeXes, 0dieter0, maKs, TomseN48, Horoxx, zeddy, NrX, ElleVen, Bchewy, Include1, alsacchi, Murr, poppin-fresh, databomb, r3D w0LF for bughunting, translation & great ideas!

  
---
    
---
  


*my golden faucets not finance itself...* [ ![](http://shanapu.de/donate.gif)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=QT8TVRSYWP53J)
