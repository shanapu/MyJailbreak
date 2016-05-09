# MyJailbreak 

A rewrite of [Franugs Special Jailbreak](https://github.com/Franc1sco/Franug-Jailbreak/) and merge/redux of [eccas, ESK0s & zipcores Jailbreak Warden](http://www.sourcemod.net/plugins.php?cat=0&mod=-1&title=Warden&author=&description=&search=1)

## Jailbreak plugin pack for CS:GO Jailserver

see [todo list](/TODO.md) the "must" part is todo before first release on AM  
help me by posting bugs and feature ideas in [Issue list](https://github.com/shanapu/MyJailbreak/issues) (on github)  
help, ideas, forks and merge requests are welcome!  

This is my first public project. please note that the code may is messy, stupid and inconseqent or mix different coding styles.  
I would be happy and very pleased if you wannt to join this project as equal collaborator.  
If you own a feature or extention for Jail/Warden that would fit in, i would be happy when you share it with us.  

# coded with ![alt text](http://shanapu.de/githearth-small.png "LOVE")  
# ![alt text](http://shanapu.de/githearth-small.png "LOVE") free software

### Included Plugins: 

- [Warden](#warden) - (set/become Warden,vote against Warden, Model, Icon, open cells, set marker/quiz/EventDays/countdown/FF/nobock) - need [scp](#requires-plugins)
- [Menu](#menu) - (Player menus for T, CT, Warden & Admin)
- [Weapons](#weapons) - (weapon menus for CT / T in event rounds)
- [PlayerTags](#playertags) - (add player Tags for T, T.Admin, CT, CT.Admin, W, WA.Admin - need [scp](#requires-plugins)
- [EventDays](#eventdays-core) (vote/set a Event for next round with cooldowns, sounds & overlays) - all need [sjd](#requires-plugins)&[scp](#requires-plugins)
    - [War](#war) (CT vs T TDM)
    - [Free For All](#freeforall) (FFA DM)
    - [Zombie](#zombie) (CT(zombie) vs T(Human))
    - [NoScope](#noscope) (FFA Scout LowGravity NoScope)
    - [HEbattle](#hebattle) (FFA LowHP LowGravity HE Battle)
    - [Hide in the Dark](#hideinthedark) - (kind of HideNseek)
    - [Catch & Freeze](#catchfreeze) - (CT must catch all T (freeze tag))
    - [DuckHunt](#duckHunt) - (CT(hunter) with nova vs T(chicken in 3th person))
    - [Jihad](#jihad) - (Ts got suicde bombs to kill all CTs)
    - [Zeus](#zeus) - (FFA ZeusRound - get a new Zeus on Kill)
    - [Knife](#knifefight) - (FFA Knifefight with switchable grav, ice, and TP)
    - [Freeday](#freeday) - (auto Freeday on first round/damage disabled)


work in progress!  
Files been updated ~daily so have a look at the last commits.  
**the uploaded compiled smxs may no uptodate! hav a look to the commits!** have a look for [requires plugins](#requires-plugins)  
I recommend until full release, when update to overwrite all files (plugins, translations, sounds, Overlays,...).

### Change Log
####  ~~[0.7.2]~~ - VERSIONING BEGINNS WITH RELEASE ON ALLIED - sry


### Versioning
for a better understanding:
```
e.g.  
  
0.7.2  
│ │ └───patch level - fix within major/minior release (you should update for fixes)  
│ └─────minor release - feature/structure added/removed/changed (you can update if you want for new stuff or paticular changes) 
└───────major release - stable/release (big new update - recommended) 
```

### Credits: 

**used code & stuff from: ecca, Zipcore, ESK0, Floody.de, Franc1sco, walmar, KeepCalm, bara, Arkarr, KissLick, headline, Hipster, ReFlexPoison, Kaesar, andi67** and many other I cant remember unfortunately! [detailed](#detailed-credits)  
**thanks to all sourcemod & metamod developers out there!**

# THANKS FOR MAKING FREE SOFTWARE!

#### Much Thanks: 
UartigZone, Got Sw4g? terminator18, Skelexes, 0dieter0, maks, zeddy for bughunting / great ideas!
  
  
  
### Plugin descriptions: 

#### Warden

This plugins allows players to take control over the prison as Warden/Headguard/Commander.  
Chat, Hud & sound notifications about Warden/no Warden.  
Colorize Warden, Warden Model, open/close cell doors, automatic open cells doors, vote retire Warden, Icon above Head, different countdowns(start/stop) with overlays & sound, MathQuiz & toggle FF/noblock.

##### Commands ~~// why so many cmds for same action? some JB players are dump assholes ;D~~
```
- sm_w / sm_warden - Allows the player taking the charge over prisoners
- sm_c / sm_commander - Allows the player taking the charge over prisoners
- sm_hg / sm_headguard - Allows the player taking the charge over prisoners
- sm_uw / sm_unWarden - Allows the player to retire from the position
- sm_uc / sm_uncommander - Allows the player to retire from the position
- sm_uhg / sm_unheadguard - Allows the player to retire from the position
- sm_vw / sm_voteWarden - Allows the player to vote to retire Warden
- sm_open - Allows the Warden to open the cell doors
- sm_close - Allows the Warden to close the cell doors
- sm_noblockon - Allows the Warden to enable no block 
- sm_noblockoff - Allows the Warden to disable no block
- sm_setff - Allows player to see the state and the Warden to toggle friendly fire
- sm_cdmenu - Allows the Warden to open the Countdown Menu
- sm_cdstart - Allows the Warden to start a START Countdown! (start after 10sec.) - start without menu
- sm_cdstop - Allows the Warden to start a STOP Countdown! (stop after 20sec.) - start without menu
- sm_cdstartstop - Allows the Warden to start a START/STOP Countdown! (start after 10sec./stop after 20sec.) - start without menu
- sm_cdcancel - Allows the Warden to cancel a running Countdown
- sm_killrandom - Allows the Warden to kill a random T
- sm_math  Allows the Warden to start a MathQuiz. Show player with first right Answer
```
##### AdminCommands // ADMFLAG_GENERIC
```
- sm_sw / sm_setWarden - Allows the Admin to set a player to Warden
- sm_rw / sm_removeWarden - Allows the Admin to remove a player from Warden
```
##### Cvars
```
- sm_warden_version - Shows the version of the SourceMod plugin MyJailbreak - Warden
- sm_warden_enable: 0 - disabled, 1 - enable the Warden plugin. Default 1
- sm_warden_become: 0 - disabled, 1 - enable !w / !warden - player can choose to be Warden. If disabled you should need sm_warden_choose_random 1. Default 1
- sm_warden_choose_random: 0 - disabled, 1 - enable pic random Warden if there is still no Warden after sm_warden_choose_time. Default 1
- sm_warden_choose_time: Time in seconds a random Warden will picked when no Warden was set. need sm_warden_choose_random 1. Default 20
- sm_warden_stay: 0 - disabled, 1 - Warden will stay after round end. Default 1
- sm_warden_vote: 0 - disabled, 1 - enable player vote against Warden. Default 1
- sm_warden_better_notifications: 0 - disabled , 1 - will use hint and center say for better notifications. Default 1
- sm_warden_icon_enable: 0 - disabled , 1 - enable the icon above the wardens head. Default 1
- sm_warden_icon: Path to the floating warden icon DONT TYPE .vmt or .vft. Default: "decals/MyJailbreak/warden"
- sm_warden_noblock: 0 - disabled, 1 - enable setable noblock for Warden. Default 1
- sm_warden_ff: 0 - disabled, 1 - enable Warden switch friendly fire. Default 1
- sm_warden_random: 0 - disabled, 1 - enable kill a random t for Warden. Default 1
- sm_warden_randomkind: 1 - all random / 2 - Thunder / 3 - Timebomb / 4 - Firebomb / 5 - NoKill (1,3,4 needs funncommands.smx enabled). Default 2
- sm_warden_marker: 0 - disabled, 1 - enable Warden advanced markers. Default 1
- sm_warden_math: 0 - disabled, 1 - enable mathquiz for Warden. Default 1
- sm_warden_math_min: What should be the minimum number for questions. Default 1
- sm_warden_math_max: What should be the maximum number for questions. Default 100
- sm_warden_math_time: Time in seconds to give a answer to a question. Default 20
- sm_warden_countdown: 0 - disabled, 1 - enable countdown for Warden. Default 1
- sm_warden_overlays_enable: 0 - disabled, 1 - enable overlay for countdown. Default 1
- sm_warden_overlays_start: Path to the start Overlay DONT TYPE .vmt or .vft. Default "overlays/MyJailbreak/start"
- sm_warden_overlays_stop: Path to the stop Overlay DONT TYPE .vmt or .vft. Default "overlays/MyJailbreak/stop"
- sm_warden_model: 0 - disabled, 1 - enable warden model. Default 1
- sm_warden_model_path:Path to the model for zombies. Default "models/player/custom_player/legacy/security/security.mdl"
- sm_warden_color_enable: 0 - disabled, 1 - enable colored Warden. Default 1
- sm_warden_color_red - What color to turn the Warden into (set R, G and B values to 0 to disable). Default 0
- sm_warden_color_green - What color to turn the Warden into (rGb): x - green value. Default 0
- sm_warden_color_blue - What color to turn the Warden into (rgB): x - blue value. Default 255
- sm_warden_sounds_enable: 0 - disabled, 1 - Play a sound when a player become Warden or Warden leaves. Default 1
- sm_warden_sounds_warden - Path to the soundfile which should be played for a new Warden. Default "music/myJailbreak/Warden.mp3"
- sm_warden_sounds_unWarden - Path to the soundfile which should be played when there is no Warden anymore. Default "music/myJailbreak/unWarden.mp3"
- sm_warden_sounds_start - Path to the soundfile which should be played for a start countdown. Default "music/myJailbreak/start.mp3"
- sm_warden_sounds_stop - Path to the soundfile which should be played for a stop countdown. Default "music/myJailbreak/stop.mp3"
- sm_warden_open_enable: 0 - disabled, 1 - Warden can open/close cell doors. Default 1
- sm_warden_open_time_enable: 0 - disabled, 1 - cell doors will open automatic after - sm_warden_open_time. Default 1
- sm_warden_open_time - Time in seconds for open doors on round start automaticly. Default 60
- sm_warden_open_time_warden: 0 - disabled, 1 - doors open automatic after - sm_warden_open_time although there is a Warden. needs - sm_warden_open_time_enable 1. Default 1

```
##### Features

- Custom chat [Tag]
- 1.7 SourcePawn Transitional Syntax
- Multilingual support
- Forwards
- Natives
- Colors

[![HowTo Marker](http://img.youtube.com/vi/tp6k_Q6K37c/0.jpg)](http://www.youtube.com/watch?v=tp6k_Q6K37c)

#### Menu

This plugins allows players to open a menu with ","-Key (buyammo) or command.  
It will show different menus for Terrorists, Counter-Terrorists Admin & Warden.  
The menu shows only features that are enabled per round (e.g at EventDays no Warden menu)

##### Commands 
```
- sm_menu / sm_menus - opens the menu depends on players team/rank
- sm_days / sm_event / sm _events - open a Set EventDays menu for Warden/Admin & vote EventDays menu for player
```
##### Cvars
```
- sm_menu_version - Shows the version of the SourceMod plugin MyJailbreak - Menu
- sm_menu_enable: 0 - disabled, 1 - enable Jailbreak menu
- sm_menu_ct: 0 - disabled, 1 - enable Jailbreak menu for CT
- sm_menu_t: 0 - disabled, 1 - enable Jailbreak menu for Terrorists
- sm_menu_warden: disabled, 1 - enable Jailbreak menu for Warden
- sm_menu_days: 0 - disabled, 1 - enable vote/set EventDays menu
- sm_menu_close: 0 - disabled, 1 - close menu after action
- sm_menu_start: 0 - disabled, 1 - open menu on every roundstart
- sm_menu_team: 0 - disabled, 1 - enable join team on menu
- sm_menu_tag: 0 - disabled, 1 - Allow \"MyJailbreak\" to be added to the server tags? So player will find servers with MyJB faster. it dont touch your sv_tags. Default 1
```
##### Features

- Custom chat [Tag]
- 1.7 SourcePawn Transitional Syntax
- Multilingual support
- Colors
- **only shows available/enabled features**

#### Menu Structure

##### WardenMenu
* [Gun Menu](/shanapu/MyJailbreak/wiki/Weapons)
* Open Cells
* Countdown
    * Beginn a Start Countdown
    * Beginn a Stop Countdown
    * Set a Start/Stop Countdown
        * 15 seconds
        * 30 seconds
        * 45 seconds
        * 1 Minute
        * 1 Minute 30 seconds
        * 2 Minutes
        * 3 Minutes
        * 5 Minutes
* Math Quiz
* Set a Event Days
    * War
    * FFA
    * Zombie
    * Hide
    * Catch & Freeze
    * Jihad
    * HEbattle
    * NoScope
    * DuckHunt
    * Zeus
    * Knifefight
    * Freeday
* Checkplayer
* Toggle Friendly Fire
* Kill a random Player
    * Are you sure?
        * Yes
        * No
* Leave Warden
* Rules

##### Counter-Terrorists Menu
* [Gun Menu](/shanapu/MyJailbreak/wiki/Weapons)
* Become Warden
* Vote for Event Days
    * War
    * FFA
    * Zombie
    * Hide
    * Catch & Freeze
    * Jihad
    * HEbattle
    * NoScope
    * DuckHunt
    * Zeus
    * Knifefight
    * Freeday
* Checkplayer
* Join Terrorists
    * Are you sure?
        * Yes
        * No
* Rules


##### Counter-Terrorists Menu
* [Gun Menu](/shanapu/MyJailbreak/wiki/Weapons)
* Vote against Warden
* Vote for Event Days
    * War
    * FFA
    * Zombie
    * Hide
    * Catch & Freeze
    * Jihad
    * HEbattle
    * NoScope
    * DuckHunt
    * Zeus
    * Knifefight
    * Freeday
* Join Counter-Terrorists
    * Are you sure?
        * Yes
        * No
* Rules

###### additionally for Admin
* Remove Warden
* Set new Warden
    * Choose Player
        * sure kick old Warden?
            * Yes
            * No
* Admin menu

#### Weapons

This plugins open a Gunmenu to players if weapons are enabled for EventDays.

##### Commands 
```
- sm_gun / sm_guns / sm_gunmenu - Open the weapon menu if enabled (in EventDays/for CT)
- sm_weapon / sm_weapons / sm_weaponsmenu - Open the weapon menu if enabled (in EventDays/for CT)
- sm_arms / sm_firearms - Open the weapon menu if enabled (in EventDays/for CT)
- sm_giveweapon - Open the weapon menu if enabled (in EventDays/for CT)
```
##### Cvars
```
- sm_weapons_version - Shows the version of the SourceMod plugin MyJailbreak - Weapons
- sm_weapons_enable: 0 - disabled, 1 - enable weapons menu - you shouldn't touch these, cause events days will handle them
- sm_weapons_ct: 0 - disabled, 1 - enable weapons menu for CT - you shouldn't touch these, cause events days will handle them
- sm_weapons_t: 0 - disabled, 1 - enable weapons menu for T - you shouldn't touch these, cause events days will handle them
- sm_weapons_spawnmenu: disabled, 1 - enable autoopen weapon menu on spawn if enabled
- sm_weapons_awp: 0 - disabled, 1 - enable AWP in weapon menu
- sm_weapons_autosniper: 0 - disabled, 1 - enable scar20 & g3sg1 in menu
- sm_weapons_tagrenade: 0 - disabled, 1 - warden get a TA grenade with weapons
- sm_weapons_warden_healthshot: 0 - disabled, 1 - warden get a healthshot with weapons
- sm_weapons_jbmenu: 0 - disabled, 1 - enable autoopen the MyJailbreak menu after weapon given.
```
##### Features

- Custom chat [Tag]
- Multilingual support
- Colors
- only shows in available EventDays

#### PlayerTags

This plugins give players Tags for team (T,CT) and "rank" (Admin/Warden) in stats &/or chat

##### Cvars
```
- sm_playertag_version - Shows the version of the SourceMod plugin MyJailbreak - PlayerTags
- sm_playertag_enable: 0 - disabled, 1 - enable Player Tag
- sm_playertag_stats: 0 - disabled, 1 - enable PlayerTag in stats
- sm_playertag_chat: 0 - disabled, 1 - enable PlayerTag in Chat

```
##### Features

- 1.7 SourcePawn Transitional Syntax
- Multilingual support

#### EventDays core

This plugins is the "interface" between Eventdays. need for cooldowns and disable other days on running Eventday.

##### Cvars
```
- sm_myjb_tag: 0 - disabled, 1 - Allow "MyJailbreak" to be added to your server tags. So player will find servers with MyJB faster. it dont touch youR sv_tags

```
##### Features

- 1.7 SourcePawn Transitional Syntax
- Natives

#### War

This plugin allows to vote or set a war CT vs T for next 3 rounds.  
On Round start Ts spawn freezed next to CT. After unfreeze time (def. 30sec) Ts can Move. After nodamage time (def. 30sec) the war CT vs T starts.  
Or on Round start Ts spawn in open cells with weapons and weaponmenu. No Freeze/-time. (Default)  

##### Commands
```
- sm_war - Allows players to vote for a war
- sm_setwar - Allows the Admin or Warden to set a war for next rounds
```
##### Cvars
```
- sm_war_version - Shows the version of the SourceMod plugin MyJailbreak - War
- sm_war_enable: 0 - disabled, 1 - enable the war plugin. Default 1
- sm_war_setw: 0 - disabled, 1 - allow Warden to set next round war. Default 1
- sm_war_seta: 0 - disabled, 1 - allow Admin to set next round war round. Default 1
- sm_war_rounds: Rounds to play in a row
- sm_war_vote: 0 - disabled, 1 - allow player to vote for war. Default 1
- sm_war_spawn: 0 - teleport Ts to CT and freeze, 1 - open cell doors an get weapons. Default 0
- sm_war_roundtime - Roundtime for a single war round in minutes. Default 5
- sm_war_freezetime- Time in seconds Ts are freezed. time to hide on map for CT (need sm_war_spawn: 0). Default 30
- sm_war_trucetime - Time in seconds after freezetime damage is disbaled. Default 30
- sm_war_cooldown_start - Rounds until event can be start after mapchange. Default 3
- sm_war_cooldown_day - Rounds until event can be started again. Default 3
- sm_war_sounds_enable: 0 - disabled, 1 - enable sounds. Default 1
- sm_war_sounds_start: Path to the soundfile which should be played on start. Default "music/myJailbreak/start.mp3"
- sm_war_overlays_enable: 0 - disabled, 1 - enable start overlay. Default 1
- sm_war_overlays_start: Path to the start Overlay DONT TYPE .vmt or .vft. Default "overlays/MyJailbreak/start"

and more 
```
##### Features

- disable Warden, other EventDays, lastrequest
- 1.7 SourcePawn Transitional Syntax
- autoopen celldoors
- Multilingual support
- Colors
- Custom chat [Tag]

#### FreeForAll

This plugin allows to vote or set a FFA war for next 3 rounds.  
On Round start Ts spawn next to CT. CTs & Ts can get Weapon an Move. MapFog is on for better hiding. After nodamage time (def. 30sec) the war CT vs T starts and MapFog disabled.  
Or on Round start Ts spawn in open cells with weapons & weaponmenu. (Default)  

##### Commands
```
- sm_ffa - Allows players to vote for a FFA 
- sm_setffa - Allows the Admin or Warden to set a ffa for next rounds
```
##### Cvars
```
- sm_ffa_version - Shows the version of the SourceMod plugin MyJailbreak - FFA
- sm_ffa_enable: 0 - disabled, 1 - enable the ffa plugin. Default 1
- sm_ffa_setw: 0 - disabled, 1 - allow Warden to set next round ffa. Default 1
- sm_ffa_seta: 0 - disabled, 1 - allow Admin to set next round ffa round. Default 1
- sm_ffa_rounds: Rounds to play in a row
- sm_ffa_vote: 0 - disabled, 1 - allow player to vote for ffa. Default 1
- sm_ffa_spawn: 0 - teleport Ts to CT and freeze, 1 - open cell doors an get weapons (need smartjaildoors). Default 0
- sm_ffa_roundtime - Roundtime for a single ffa round in minutes. Default 5
- sm_ffa_trucetime - Time in seconds after freezetime damage is disbaled. Default 30
- sm_ffa_cooldown_start - Rounds until event can be start after mapchange. Default 3
- sm_ffa_cooldown_day - Rounds until event can be started again. Default 3
- sm_ffa_sounds_enable: 0 - disabled, 1 - enable sounds. Default 1
- sm_ffa_sounds_start: Path to the soundfile which should be played on start. Default "music/myJailbreak/start.mp3"
- sm_ffa_overlays_enable: 0 - disabled, 1 - enable start overlay. Default 1
- sm_ffa_overlays_start: Path to the start Overlay DONT TYPE .vmt or .vft. Default "overlays/MyJailbreak/start"

```
##### Features

- disable Warden, other EventDays, lastrequest
- 1.7 SourcePawn Transitional Syntax
- autoopen celldoors (need smartjaildoors)
- Multilingual support
- Colors
- Custom chat [Tag]


#### Zombie

This plugin allows players to vote and Warden to set next round to zombie escape.  
On Round start Ts spawn in open cells with weapons & weaponmenu. CT are zombies with a zombie model, and with 10000 HP.  
Zombies freezed for 35sec (default) so T can hide &/or climb.  

##### Commands
```
- sm_zombie - Allows players to vote for a Zombie 
- sm_setzombie - Allows the Admin or Warden to set Zombie as next round
```
##### Cvars
```
- sm_zombie_version - Shows the version of the SourceMod plugin MyJailbreak - Zombie
- sm_zombie_setw: 0 - disabled, 1 - allow Warden to set next round zombie. Default 1
- sm_zombie_seta: 0 - disabled, 1 - allow Admin to set next round zombie round. Default 1
- sm_zombie_vote: 0 - disabled, 1 - allow player to vote for zombie. Default 1
- sm_zombie_enable: 0 - disabled, 1 - enable the zombie plugin. Default 1
- sm_zombie_spawn: 0 - teleport Ts to CT and freeze, 1 - open cell doors an get weapons. Default 0
- sm_zombie_rounds: Rounds to play in a row
- sm_zombie_roundtime - Roundtime for a single zombie round in minutes. Default 5
- sm_zombie_freezetime - Time in seconds Zombies freezed. Default 35
- sm_zombie_cooldown_start - Rounds until event can be start after mapchange. Default 3
- sm_zombie_cooldown_day - Rounds until event can be started again. Default 3
- sm_zombie_sounds_enable: 0 - disabled, 1 - enable sounds. Default 1
- sm_zombie_sounds_start: Path to the soundfile which should be played on start. Default "music/myJailbreak/start.mp3"
- sm_zombie_overlays_enable: 0 - disabled, 1 - enable start overlay. Default 1
- sm_zombie_overlays_start: Path to the start Overlay DONT TYPE .vmt or .vft. Default "overlays/MyJailbreak/start"
- sm_zombie_model: Path to the model for zombies. Default "models/player/custom_player/zombie/revenant/revenant_v2.mdl"

```
##### Features

- disable Warden, other EventDays, lastrequest
- change the sky of map
- 1.7 SourcePawn Transitional Syntax
- autoopen celldoors (need smartjaildoors)
- Multilingual support
- Colors
- Custom chat [Tag]


#### Noscope

This plugin allows players to vote and Warden to set next round to noscope  
On Round start cells open everybody got sniper rifle with noscope and low gravity. Nodamage time (def. 30sec).

##### Commands
```
- sm_noscope - Allows players to vote for a noscope
- sm_setnoscope - Allows the Admin or Warden to set noscope as next round
```
##### Cvars
```
- sm_noscope_version - Shows the version of the SourceMod plugin MyJailbreak - noscope
- sm_noscope_enable: 0 - disabled, 1 - enable the noscope plugin. Default 1
- sm_noscope_setw: 0 - disabled, 1 - allow Warden to set next round noscope. Default 1
- sm_noscope_seta: 0 - disabled, 1 - allow Admin to set next round noscope round. Default 1
- sm_noscope_spawn: 0 - teleport Ts to CT and freeze, 1 - open cell doors an get weapons. Default 0
- sm_noscope_vote: 0 - disabled, 1 - allow player to vote for noscope. Default 1
- sm_noscope_rounds: Rounds to play in a row. Default 1
- sm_noscope_weapon: 1 - ssg08 / 2 - awp / 3 - scar20 / 4 - g3sg1. Default 1
- sm_noscope_random: 0 - disabled, 1 - get a random weapon (ssg08,awp,scar20,g3sg1) ignore: sm_noscope_weapon. Default 0
- sm_noscope_gravity: 0 - disabled, 1 - enable low Gravity for noscope. Default 1
- sm_noscope_gravity_value - Ratio for Gravity 1.0 earth 0.5 moon. Default 0.3
- sm_noscope_roundtime - Roundtime for a single noscope round in minutes. Default 5
- sm_noscope_trucetime - Time in seconds damage is disbaled. Default 15
- sm_noscope_cooldown_start - Rounds until event can be start after mapchange. Default 3
- sm_noscope_cooldown_day - Rounds until event can be started again. Default 3
- sm_noscope_sounds_enable: 0 - disabled, 1 - enable sounds. Default 1
- sm_noscope_sounds_start: Path to the soundfile which should be played on start. Default "music/myJailbreak/start.mp3"
- sm_noscope_overlays_enable: 0 - disabled, 1 - enable start overlay. Default 1
- sm_noscope_overlays_start: Path to the start Overlay DONT TYPE .vmt or .vft. Default "overlays/MyJailbreak/start"

```
##### Features

- disable Warden, other EventDays, lastrequest
- 1.7 SourcePawn Transitional Syntax
- autoopen celldoors (need smartjaildoors)
- Multilingual support
- Colors
- Custom chat [Tag]

#### HEbattle

This plugin allows players to vote and Warden to set next round to HEbattle.  
On Round start cells open everybody got HE grenate with low gravity(Default) and reduced HP.

##### Commands
```
- sm_hebattle - Allows players to vote for a hebattle
- sm_sethebattle - Allows the Admin or Warden to set hebattle as next round
```
##### Cvars
```
- sm_hebattle_version - Shows the version of the SourceMod plugin MyJailbreak - hebattle
- sm_hebattle_enable: 0 - disabled, 1 - enable the hebattle plugin. Default 1
- sm_hebattle_setw: 0 - disabled, 1 - allow Warden to set next round HEbattle. Default 1
- sm_hebattle_seta: 0 - disabled, 1 - allow Admin to set next round HEbattle round. Default 1
- sm_hebattle_spawn: 0 - teleport Ts to CT and freeze, 1 - open cell doors an get weapons. Default 0
- sm_hebattle_vote: 0 - disabled, 1 - allow player to vote for HEbattle. Default 1
- sm_hebattle_rounds: Rounds to play in a row
- sm_hebattle_gravity: 0 - disabled, 1 - enable low Gravity for hebattle. Default 1
- sm_hebattle_gravity_value - Ratio for Gravity 1.0 earth 0.5 moon. Default 0.3
- sm_hebattle_roundtime - Roundtime for a single hebattle round in minutes. Default 5
- sm_hebattle_trucetime - Time in seconds damage is disbaled. Default 15
- sm_hebattle_cooldown_start - Rounds until event can be start after mapchange. Default 3
- sm_hebattle_cooldown_day - Rounds until event can be started again. Default 3
- sm_hebattle_sounds_enable: 0 - disabled, 1 - enable sounds. Default 1
- sm_hebattle_sounds_start: Path to the soundfile which should be played on start. Default "music/myJailbreak/start.mp3"
- sm_hebattle_overlays_enable: 0 - disabled, 1 - enable start overlay. Default 1
- sm_hebattle_overlays_start: Path to the start Overlay DONT TYPE .vmt or .vft. Default "overlays/MyJailbreak/start"

```
##### Features

- disable Warden, other EventDays, lastrequest
- 1.7 SourcePawn Transitional Syntax
- autoopen celldoors (need smartjaildoors)
- Multilingual support
- Colors
- Custom chat [Tag]

#### Catch&Freeze

This plugin allows players to vote and Warden to set next round to catch.  
On Round start cells open an Ts must "runaway". CT must catch and freeze all Ts by knifing.  
Ts can unfreeze Freezed Ts by knife them again.  
CT and T can Sprint with USE-Key (default). 

##### Commands
```
- sm_catch - Allows players to vote for a catch 
- sm_setcatch - Allows the Admin or Warden to set catch as next round
- sm_sprint - Start sprinting!
```

##### Cvars
```
- sm_catch_version - Shows the version of the SourceMod plugin MyJailbreak - catch
- sm_catch_setw: 0 - disabled, 1 - allow Warden to set next round ffa. Default 1
- sm_catch_seta: 0 - disabled, 1 - allow Admin to set next round ffa round. Default 1
- sm_catch_vote: 0 - disabled, 1 - allow player to vote for ffa. Default 1
- sm_catch_rounds: Rounds to play in a row
- sm_catch_enable: 0 - disabled, 1 - enable the catch plugin. Default 1
- sm_catch_sprint_enable: 0 - disabled, 1 - enable ShortSprint. Default 1
- sm_catch_sprint_button: 0 - disabled, 1 - enable +use button support. Default 1
- sm_catch_sprint_cooldown: Time in seconds the player must wait for the next sprint. Default 10
- sm_catch_sprint_speed: Ratio for how fast the player will sprint. Default 1.25
- sm_catch_sprint_time: Time in seconds the player will sprint. Default 3.5
- sm_catch_roundtime - Roundtime for a single catch round in minutes. Default 5
- sm_catch_cooldown_start - Rounds until event can be start after mapchange. Default 3
- sm_catch_cooldown_day - Rounds until event can be started again. Default 3
- sm_catch_overlays_enable: 0 - disabled, 1 - enable freezed overlays. Default 1
- sm_catch_stayoverlay: 0 - overlays will removed after 3sec. , 1 - overlays will stay until unfreeze. Default 1
- sm_catch_overlayfreeze_path: Path to the start Overlay DONT TYPE .vmt or .vft. Default "overlays/MyJailbreak/freeze"
- sm_catch_sounds_enable: 0 - disabled, 1 - enable un/-Freeze sounds. Default 1
- sm_catch_sounds_freeze: Path to the soundfile which should be played on freeze. Default "music/myJailbreak/freeze.mp3"
- sm_catch_sounds_unfreeze: Path to the soundfile which should be played on unfreeze. Default "music/myJailbreak/unfreeze.mp3"
- sm_catch_noblood: 0 - Disable, 1 - enable No Blood. Default 1
- sm_catch_noblood_splatter: 0 - Disable, 1 - enable No Blood Splatter. Default 1
- sm_catch_noblood_splash: 0 - Disable, 1 - enable No Blood Splash. Default 1


```
##### Features

- disable Warden, other EventDays, lastrequest
- 1.7 SourcePawn Transitional Syntax
- autoopen celldoors (need smartjaildoors)
- Multilingual support
- Colors
- Custom chat [Tag]

#### HideInTheDark

This plugin allows players to vote and Warden to set next round to hide in the dark.  
Map is darken. CTs freezed, Cells open and Ts got time to hide on map. CT got a TA Grenade & more movement speed.  
When CT unfreezed (30sec. default) Ts get freezed (default).  

##### Commands
```
- sm_hide - Allows players to vote for a hide
- sm_sethide - Allows the Admin or Warden to set hide as next round
```
##### Cvars
```
- sm_hide_version - Shows the version of the SourceMod plugin MyJailbreak - hide
- sm_hide_setw: 0 - disabled, 1 - allow Warden to set next round ffa. Default 1
- sm_hide_seta: 0 - disabled, 1 - allow Admin to set next round ffa round. Default 1
- sm_hide_vote: 0 - disabled, 1 - allow player to vote for ffa. Default 1
- sm_hide_enable: 0 - disabled, 1 - enable the hide plugin. Default 1
- sm_hide_rounds: Rounds to play in a row
- sm_hide_roundtime - Roundtime for a single hide round in minutes. Default 5
- sm_hide_hidetime - Time in seconds to hide. Default 30
- sm_hide_freezehider: 0 - disabled, 1 - enable freeze hider when hidetime gone. Default 1
- sm_hide_cooldown_start - Rounds until event can be start after mapchange. Default 3
- sm_hide_cooldown_day - Rounds until event can be started again. Default 3
- sm_hide_sounds_enable: 0 - disabled, 1 - enable sounds. Default 1
- sm_hide_sounds_start: Path to the soundfile which should be played on start. Default "music/myJailbreak/start.mp3"
- sm_hide_overlays_enable: 0 - disabled, 1 - enable start overlay. Default 1
- sm_hide_overlays_start: Path to the start Overlay DONT TYPE .vmt or .vft. Default "overlays/MyJailbreak/start"

```
##### Features

- disable Warden, other EventDays, lastrequest
- 1.7 SourcePawn Transitional Syntax
- autoopen celldoors (need smartjaildoors)
- Multilingual support
- Colors
- Custom chat [Tag]

#### DuckHunt

This plugin allows players to vote and Warden to set next round to duckhunt.  
T are Chicken in Thirdperson. After trucetime the cells open and T got HE grenade **but only secondary Attack!** CT as heavy with nova .  

##### Commands
```
- sm_duckhunt - Allows players to vote for a duckhunt
- sm_setduckhunt - Allows the Admin or Warden to set duckhunt as next round
```
##### Cvars
```
- sm_duckhunt_version - Shows the version of the SourceMod plugin MyJailbreak - duckhunt
- sm_duckhunt_setw: 0 - disabled, 1 - allow Warden to set next round ffa. Default 1
- sm_duckhunt_seta: 0 - disabled, 1 - allow Admin to set next round ffa round. Default 1
- sm_duckhunt_vote: 0 - disabled, 1 - allow player to vote for ffa. Default 1
- sm_duckhunt_enable: 0 - disabled, 1 - enable the duckhunt plugin. Default 1
- sm_duckhunt_rounds: Rounds to play in a row
- sm_duckhunt_roundtime - Roundtime for a single duckhunt round in minutes. Default 5
- sm_duckhunt_trucetime - Time in seconds damage is disbaled. Default 15
- sm_duckhunt_cooldown_start - Rounds until event can be start after mapchange. Default 3
- sm_duckhunt_cooldown_day - Rounds until event can be started again. Default 3
- sm_duckhunt_sounds_enable: 0 - disabled, 1 - enable sounds. Default 1
- sm_duckhunt_sounds_start: Path to the soundfile which should be played on start. Default "music/myJailbreak/start.mp3"
- sm_duckhunt_overlays_enable: 0 - disabled, 1 - enable start overlay. Default 1
- sm_duckhunt_overlays_start: Path to the start Overlay DONT TYPE .vmt or .vft. Default "overlays/MyJailbreak/start"

```
##### Features

- disable Warden, other EventDays, lastrequest
- 1.7 SourcePawn Transitional Syntax
- autoopen celldoors (need smartjaildoors)
- Multilingual support
- Colors
- Custom chat [Tag]


#### Jihad

This plugin allows players to vote and Warden to set next round to Jihad.  
On Round start CTs got time to hide before cells open and Ts got Suicide bombs to kill all CT.  
CT and T can Sprint with USE-Key (default).  

##### Commands
```
- sm_jihad - Allows players to vote for a duckhunt
- sm_setjihad - Allows the Admin or Warden to set jihad as next round
- sm_sprint - Start sprinting!
- sm_makeboom - Suicide with bomb.

```
##### Cvars
```
- sm_jihad_version - Shows the version of the SourceMod plugin MyJailbreak - jihad
- sm_jihad_setw: 0 - disabled, 1 - allow Warden to set next round ffa. Default 1
- sm_jihad_seta: 0 - disabled, 1 - allow Admin to set next round ffa round. Default 1
- sm_jihad_vote: 0 - disabled, 1 - allow player to vote for ffa. Default 1
- sm_jihad_enable: 0 - disabled, 1 - enable the plugin. Default 1
- sm_jihad_rounds: Rounds to play in a row
- sm_jihad_key: 1 - Inspect(look) weapon / 2 - walk / 3 - Secondary Attack. Default 1
- sm_jihad_standstill: 0 - disabled, 1 - standstill(cant move) on Activate bomb. Default 0
- sm_jihad_bomb_radius: Radius for bomb damage. Default 200
- sm_jihad_sprint_enable: 0 - disabled, 1 - enable ShortSprint. Default 1
- sm_jihad_sprint_button: 0 - disabled, 1 - enable +use button support. Default 1
- sm_jihad_sprint_cooldown: Time in seconds the player must wait for the next sprint. Default 10
- sm_jihad_sprint_speed: Ratio for how fast the player will sprint. Default 1.25
- sm_jihad_sprint_time: Time in seconds the player will sprint. Default 3.5
- sm_jihad_roundtime - Roundtime for a single jihad round in minutes. Default 5
- sm_jihad_hidetime - Time to hide. Default 20
- sm_jihad_cooldown_start - Rounds until event can be start after mapchange. Default 3
- sm_jihad_cooldown_day - Rounds until event can be started again. Default 3
- sm_jihad_sounds_enable: 0 - disabled, 1 - enable sounds. Default 1
- sm_jihad_sounds_start: Path to the soundfile which should be played on start. Default "music/myJailbreak/start.mp3"
- sm_jihad_sounds_jihad - Path to the soundfile which should be played on activate bomb. Default "music/myJailbreak/jihad.mp3"
- sm_jihad_sounds_boom - Path to the soundfile which should be played on detonation. Default "music/myJailbreak/boom.mp3"
- sm_jihad_overlays_enable: 0 - disabled, 1 - enable start overlay. Default 1
- sm_jihad_overlays_start: Path to the start Overlay DONT TYPE .vmt or .vft. Default "overlays/MyJailbreak/start"

```
##### Features

- disable Warden, other EventDays, lastrequest
- 1.7 SourcePawn Transitional Syntax
- autoopen celldoors (need smartjaildoors)
- Multilingual support
- Colors
- Custom chat [Tag]

#### Zeus

This plugin allows players to vote and Warden to set next round to zeus  
On Round start cells open everybody got a scout with zeus in low gravity. Nodamage time (def. 30sec).

##### Commands
```
- sm_zeus - Allows players to vote for a zeus round
- sm_setzeus - Allows the Admin or Warden to set zeus as next round
```
##### Cvars
```
- sm_zeus_version - Shows the version of the SourceMod plugin MyJailbreak - zeus
- sm_zeus_enable: 0 - disabled, 1 - enable the zeus plugin. Default 1
- sm_zeus_setw: 0 - disabled, 1 - allow Warden to set next round zeus. Default 1
- sm_zeus_seta: 0 - disabled, 1 - allow Admin to set next round zeus round. Default 1
- sm_zeus_vote: 0 - disabled, 1 - allow player to vote for zeus. Default 1
- sm_zeus_spawn: 0 - teleport Ts to CT and freeze, 1 - open cell doors an get weapons. Default 0
- sm_zeus_rounds: Rounds to play in a row
- sm_zeus_roundtime - Roundtime for a single zeus round in minutes. Default 5
- sm_zeus_trucetime - Time in seconds damage is disbaled. Default 15
- sm_zeus_cooldown_start - Rounds until event can be start after mapchange. Default 3
- sm_zeus_cooldown_day - Rounds until event can be started again. Default 3
- sm_zeus_sounds_enable: 0 - disabled, 1 - enable sounds. Default 1
- sm_zeus_sounds_start: Path to the soundfile which should be played on start. Default "music/myJailbreak/start.mp3"
- sm_zeus_overlays_enable: 0 - disabled, 1 - enable start overlay. Default 1
- sm_zeus_overlays_start: Path to the start Overlay DONT TYPE .vmt or .vft. Default "overlays/MyJailbreak/start"

```
##### Features

- disable Warden, other EventDays, lastrequest
- 1.7 SourcePawn Transitional Syntax
- autoopen celldoors (need smartjaildoors)
- Multilingual support
- Colors
- Custom chat [Tag]

#### KnifeFight

This plugin allows players to vote and Warden to set next round to knifefight.  
On Round start cells open everybody KnifeOnly with thirdperson, low gravity(Default), Iceskates and reduced HP(Default).

##### Commands
```
- sm_knifefight - Allows players to vote for a knifefight 
- sm_setknifefight - Allows the Admin or Warden to set knifefight as next round
```
##### Cvars
```
- sm_knifefight_version - Shows the version of the SourceMod plugin MyJailbreak - knifefight
- sm_knifefight_enable: 0 - disabled, 1 - enable the knifefight plugin. Default 1
- sm_knifefight_setw: 0 - disabled, 1 - allow Warden to set next round knifefight. Default 1
- sm_knifefight_seta: 0 - disabled, 1 - allow Admin to set next round knifefight round. Default 1
- sm_knifefight_vote: 0 - disabled, 1 - allow player to vote for knifefight. Default 1
- sm_knifefight_spawn: 0 - teleport Ts to CT and freeze, 1 - open cell doors an get weapons. Default 0
- sm_knifefight_thirdperson: 0 - disabled, 1 - enable thirdperson for knifefight. Default 1
- sm_knifefight_rounds: Rounds to play in a row
- sm_knifefight_gravity: 0 - disabled, 1 - enable low Gravity for knifefight. Default 1
- sm_knifefight_gravity_value - Ratio for Gravity 1.0 earth 0.5 moon. Default 0.3
- sm_knifefight_iceskate: 0 - disabled, 1 - enable iceskate for knifefight. Default 1
- sm_knifefight_iceskate_value - Ratio iceskate (5.2 normal). Default 0.8
- sm_knifefight_roundtime - Roundtime for a single knifefight round in minutes. Default 5
- sm_knifefight_trucetime - Time in seconds damage is disbaled. Default 15
- sm_knifefight_cooldown_start - Rounds until event can be start after mapchange. Default 3
- sm_knifefight_cooldown_day - Rounds until event can be started again. Default 3
- sm_knifefight_sounds_enable: 0 - disabled, 1 - enable sounds. Default 1
- sm_knifefight_sounds_start: Path to the soundfile which should be played on start. Default "music/myJailbreak/start.mp3"
- sm_knifefight_overlays_enable: 0 - disabled, 1 - enable start overlay. Default 1
- sm_knifefight_overlays_start: Path to the start Overlay DONT TYPE .vmt or .vft. Default "overlays/MyJailbreak/start"

```
##### Features

- disable Warden, other EventDays, lastrequest
- 1.7 SourcePawn Transitional Syntax
- autoopen celldoors (need smartjaildoors)
- Multilingual support
- Colors
- Custom chat [Tag]

#### Freeday

This plugin allows players to vote and Warden to set next round to freeday.  
Auto Freeday on first round after mapstart (Default).
On Round start cells open for freeday and enabled damage (Default).

##### Commands
```
- sm_freeday - Allows players to vote for a freeday 
- sm_setfreeday - Allows the Admin or Warden to set freeday as next round
```
##### Cvars
```
- sm_freeday_version - Shows the version of the SourceMod plugin MyJailbreak - freeday
- sm_freeday_enable: 0 - disabled, 1 - enable the freeday plugin. Default 1
- sm_freeday_setw: 0 - disabled, 1 - allow Warden to set next round freeday. Default 1
- sm_freeday_seta: 0 - disabled, 1 - allow Admin to set next round freeday round. Default 1
- sm_freeday_vote: 0 - disabled, 1 - allow player to vote for freeday. Default 1
- sm_freeday_roundtime - Roundtime for a single freeday round in minutes. Default 5
- sm_freeday_firstround - auto freeday first round after mapstart. Default 1
- sm_freeday_damage: 0 - disabled, 1 - enable damage on freedays. Default 1
- sm_freeday_cooldown_day - Rounds until event can be started again. Default 3

```
##### Features

- disable Warden, other EventDays, lastrequest
- 1.7 SourcePawn Transitional Syntax
- autoopen celldoors (need smartjaildoors)
- Multilingual support
- Colors
- Custom chat [Tag]


### requires plugins
- Smart Jail Doors https://github.com/Kailo97/smartjaildoors
- SM File/Folder Downloader and Precacher https://forums.alliedmods.net/showthread.php?p=602270 only for [zombie/(Warden) model download (download.ini)](/downloads.ini) (overlays & sounds will be auto added)
- Simple Chat Prozessor https://bitbucket.org/minimoney1/simple-chat-processor
- SM hosties 2 https://github.com/dataviruset/sm-hosties/

### files needed for compilation, besides the sourcemods standards 
- [autoexecconfig.inc](https://forums.alliedmods.net/showthread.php?t=204254)
- [colors.inc](https://forums.alliedmods.net/showthread.php?t=96831)
- [emitsoundany.inc](https://forums.alliedmods.net/showthread.php?t=237045)
- [myjailbreak.inc](/addons/sourcemod/scripting/include/myjailbreak.inc)
- [scp.inc](https://forums.alliedmods.net/showthread.php?t=198501)
- [smartjaildoors.inc](https://forums.alliedmods.net/showthread.php?p=2306289)
- [wardn.inc](/addons/sourcemod/scripting/include/wardn.inc)


##### dependencies within MyJailbreak:
- warden - you can use warden as standalone. no need to use Myjailbreak Eventdays(core), menu... please tell me if not!
- warden - sm_warden_randomkind 1,3,4 needs funncommands.smx enabled
- menu - if you dont wanna use the menu, make sm_weapons_jbmenu 0
- weapons - if you dont wanna use the weapons menu, on EventDays player get "standart weapons".
- EventDays - you can use only the EventDays you want. you just need MyJailbreak & one EventDay
....more

### Installation
> 
> Make sure you have the latest versions of the [required plugins](#requires-plugins)  
>   
> Download the [latest release](https://github.com/shanapu/MyJailbreak/archive/master.zip) or [dev version](https://github.com/shanapu/MyJailbreak/archive/master.zip) (same until release on AM)  
>   
> Copy the folders addons/, cfg/, materials/, models/ & sound/ to your root csgo/ directory  
>   
> Copy the folders materials/, models/ & sound/ in the fastDL/ directory to your FastDownload server  
>   
> Open your downloads.ini in the your csgo/addons/sourcemod/configs directory and add the content of downloads.txt..
>   
> Run plugin for the first time and all nessasery .cfg files will be generate  
>   
> Configure all settings in cfg/MyJailbreak to your needs  
>   
>   
> Have fun! Give feedback!  
> 



### detailed credits
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
* https://forums.alliedmods.net/showpost.php?p=2231099&postcount=22
+ https://github.com/Zipcore/Timer/ (sound)
* https://git.tf/TTT/Plugin (sound)
* https://forums.alliedmods.net/showthread.php?t=262170 (model)
* http://www.andi67.bplaced.net/Forum/viewtopic.php?f=40&t=342 (model)
* if I missed someone, please tell me!
* THANK YOU ALL!
