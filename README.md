## MyJailbreak
a plugin pack for CS:GO jailserver
  
MyJailbreak is a redux rewrite of [Franugs Special Jailbreak](https://github.com/Franc1sco/Franug-Jailbreak/) a merge/redux of [eccas, ESK0s & zipcores Jailbreak warden](http://www.sourcemod.net/plugins.php?cat=0&mod=-1&title=warden&author=&description=&search=1) and many other plugins.
  
---
  
***Included Plugins:***
  
  
*  [**Warden**](https://github.com/shanapu/MyJailbreak/wiki/Warden) - set/become warden,vote retire warden, model, icon, open cells,gun plant prevention, handcuffs, laser pointer, drawer, set marker/quiz/EventDays/countdown/FF/nobock/mute
*  [**Request**](https://github.com/shanapu/MyJailbreak/wiki/Request) - terror requests. refuse a game, request Capitulation/Pardon, healing or repeating, report freekill.
*  [**Last Guard Rule**](https://github.com/shanapu/MyJailbreak/wiki/LastGuardRule) - When Last Guard Rule is set the last CT get more HP and all terrors become rebel
*  [**Menu**](https://github.com/shanapu/MyJailbreak/wiki/Menu) - player menus for T, CT, warden & admin
*  [**Weapons**](https://github.com/shanapu/MyJailbreak/wiki/Weapons) - weapon menus for CT &/or T(in event round)
*  [**PlayerTags**](https://github.com/shanapu/MyJailbreak/wiki/Playertags) - add player tags for T, T.Admin, CT, CT.Admin, W, WA.Admin in chat &/or stats
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
* Menu: new cvar - sm_lastguard_enable: 0 - disabled, 1 - enable this MyJailbreak SourceMod plugin
* Translation: partially chinese phrases Thx to anon
* Translation: polish phrases ThX to la$ka
*Changed*  
* Warden: no warden announcement to postroundstart
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
  
***Report Bugs, Ideas & Requests:***  
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
Weeeishy, UartigZone, Got Sw4g? terminator18, SkeLeXes, 0dieter0, maKs, TomseN48, Horoxx, zeddy, NrX, ElleVen, Bchewy for bughunting, translation & great ideas!
  
---
    
---
  


*my golden faucets not finance itself...* [ ![](http://shanapu.de/donate.gif)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=QT8TVRSYWP53J)
