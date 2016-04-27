# MyJailbreak 

A rewrite version of [Franugs Special Jailbreak](https://github.com/Franc1sco/Franug-JailBreak/) and  [eccas, ESK0s & zipcores Jailbreak Warden](http://www.sourcemod.net/plugins.php?cat=0&mod=-1&title=warden&author=&description=&search=1)

## Jailbreak plugin pack for CS:GO Jailserver

see [todo list](/blob/master/TODO.md) the "must" part is todo before first release on AM

help me by posting bugs and feature ideas in [Issue list](/issues)

forks and merge requests are welcome!

### Included Plugins: 

- Warden - (set/become warden,vote against warden, open cells, set marker/quiz/eventdays/countdown/FF/nobock) - need [scp](#requires-plugins)
- Menu - (Player menus for T, CT, Warden & Admin)
- Weapons - (weapon menus for CT / T in event rounds)
- PlayerTags - (add player Tags for T, T.Admin, CT, CT.Admin, W, WA.Admin - need [scp](#requires-plugins)
- Event Days (set/vote a Event for next round) - all need [sjd](#requires-plugins)&[scp](#requires-plugins)
    - War (CT vs T TDM)
    - Free For All (FFA DM)
    - Zombie (CT(zombie) vs T(Human))
    - Noscope (FFA Scout LowGravity NoScope)
    - DodgeBall (FFA 10HP LowGravity HE Battle)
    - Hide in the Dark - (kind of HideNseek)
    - Catch - (CT must catch all T (freeze tag))
    - Duckhunt - (CT(hunter) with nova vs T(chicken in 3th person))
    - Jihad - (Ts got suicde bombs to kill all CTs)
    - Knife - (FFA Knifefight with switchable grav, ice, and TP)
    - Freeday - (auto on first round/damage disabled)

work in progress!
Files been updated ~daily so have a look at the last commits. No guarantee everything works well, but it should ;)
the uploaded compiled smxs may no uptodate! hav a look to the commits!
This is my first public project. please note that the code may is messy, stupid and inconseqent.
I would be happy and very pleased if you wannt to join this project as equal collaborator.
If you own a feature or extention for Jail/Warden that would fit in, i would be happy when you share it with us.


### Credits: 

**used code from: ecca, Zipcore, ESK0, Floody.de, Franc1sco, walmar, KeepCalm, bara, Arkarr, KissLick, headline, Hipster, ReFlexPoison** and many other I cant remember unfortunately!
# THANKS FOR MAKING FREE SOFTWARE!

### Much Thanks: 
UartigZone, Got Sw4g? for bughunting and great ideas!


### Plugin description: 

#### Warden

This plugins allows players to take control over the prison as Warden/Headguard/Commander. 
Chat, Hud & sound notifications about warden/no warden, colorize warden, open/close cell doors, automatic open cells doors, unvote warden, start different countdowns, start a Math Quiz & toggle FF/noblock.

##### Commands // why so many cmds for same action? my players are dump.
```
- sm_w / sm_warden - Allows the player taking the charge over prisoners
- sm_c / sm_commander - Allows the player taking the charge over prisoners
- sm_hg / sm_headguard - Allows the player taking the charge over prisoners
- sm_uw / sm_unwarden - Allows the player to retire from the position
- sm_uc / sm_uncommander - Allows the player to retire from the position
- sm_uhg / sm_unheadguard - Allows the player to retire from the position
- sm_vw / sm_votewarden - Allows the player to vote to retire warden
- sm_open - Allows the warden to open the cell doors
- sm_close - Allows the warden to close the cell doors
- sm_noblockon - Allows the warden to enable no block 
- sm_noblockoff - Allows the warden to disable no block
- sm_ff - Allows player to see the state and the warden to toggle friendly fire
- sm_cdmenu - Allows the warden to open the Countdown Menu
- sm_cdstart - Allows the warden to start a START! Countdown without menu
- sm_cdstop - Allows the warden to start a STOP! Countdown without menu
- sm_cdstartstop - Allows the warden to start a START! STOP! Countdown without menu
- sm_killrandom - Allows the warden to kill a random T
- sm_math  Allows the warden to start a MathQuiz 
```
##### AdminCommands // ADMFLAG_GENERIC
```
- sm_sw / sm_setwarden - Allows the Admin to set a player to warden
- sm_rw / sm_removewarden - Allows the Admin to remove a player from warden
```
##### Cvars
```
- sm_warden_version - Shows the version of the SourceMod plugin MyJailBreak - Warden
- sm_warden_enable: 0 - disabled, 1 - enable the warden plugin. Default 1
- sm_warden_become: 0 - disabled, 1 - enable !w... - player can choose to be warden. Default 1
- sm_warden_choose_random: 0 - disabled, 1 - enable pic random warden if there is still no warden after sm_warden_choose_time. Default 1
- sm_warden_choose_time: Time in seconds a random warden will picked when no warden was set. need sm_warden_choose_random 1. Default 20
- sm_warden_stay: 0 - disabled, 1 - warden will stay after round end. Default 1
- sm_warden_vote: 0 - disabled, 1 - enable player vote against warden. Default 1
- sm_warden_better_notifications: 0 - disabled , 1 - will use hint and center say for better notifications. Default 1
- sm_warden_noblock: 0 - disabled, 1 - enable setable noblock for warden. Default 1
- sm_warden_ff: 0 - disabled, 1 - enable Warden switch friendly fire. Default 1
- sm_warden_random: 0 - disabled, 1 - enable kill a random t for warden. Default 1
- sm_warden_marker: 0 - disabled, 1 - enable Warden simple markers. Default 1
- sm_warden_marker_time: Time in seconds marker will disappears. Default 20
- sm_warden_markerkey: Key to set Makrer - 1 - Look weapon / 2 - Use and shoot / 3 - walk and shoot. Default 3
- sm_warden_math: 0 - disabled, 1 - enable mathquiz for warden. Default 1	
- sm_warden_math_min: What should be the minimum number for questions. Default 1
- sm_warden_math_max: What should be the maximum number for questions. Default 100
- sm_warden_math_time: Time in seconds to give a answer to a question. Default 10
- sm_warden_countdown: 0 - disabled, 1 - enable countdown for warden. Default 1
- sm_warden_overlays_enable: 0 - disabled, 1 - enable overlay for countdown. Default 1
- sm_warden_overlays_start: Path to the start Overlay DONT TYPE .vmt or .vft. Default "overlays/MyJailbreak/start"
- sm_warden_overlays_stop: Path to the stop Overlay DONT TYPE .vmt or .vft. Default "overlays/MyJailbreak/stop"
- sm_warden_color_enable: 0 - disabled, 1 - enable colored warden. Default 1
- sm_warden_color_red - What color to turn the warden into (set R, G and B values to 0 to disable). Default 0
- sm_warden_color_green - What color to turn the warden into (rGb): x - green value. Default 0
- sm_warden_color_blue - What color to turn the warden into (rgB): x - blue value. Default 255
- sm_warden_sounds_enable: 0 - disabled, 1 - Play a sound when a player become warden or warden leaves. Default 1
- sm_warden_sounds_warden - Path to the soundfile which should be played for a new warden. Default "music/myjailbreak/warden.mp3"
- sm_warden_sounds_unwarden - Path to the soundfile which should be played when there is no warden anymore. Default "music/myjailbreak/unwarden.mp3"
- sm_warden_sounds_start - Path to the soundfile which should be played for a start countdown. Default "music/myjailbreak/start.mp3"
- sm_warden_sounds_stop - Path to the soundfile which should be played for a stop countdown. Default "music/myjailbreak/stop.mp3"
- sm_warden_open_enable: 0 - disabled, 1 - warden can open/close cell doors. Default 1
- sm_warden_open_time_enable: 0 - disabled, 1 - cell doors will open automatic after - sm_warden_open_time. Default 1
- sm_warden_open_time - Time in seconds for open doors on round start automaticly. Default 60
- sm_warden_open_time_warden: 0 - disabled, 1 - doors open automatic after - sm_warden_open_time although there is a warden. needs - sm_warden_open_time_enable 1. Default 1
- sm_warden_tag: 0 - disabled, 1 - Allow \"MyJailbreak\" to be added to the server tags? So player will find servers with MyJB faster. it dont touch your sv_tags. Default 1

```
##### Features

- Custom chat [Tag]
- Multilingual support
- Forwards
- Natives
- Colors

#### Menu

This plugins allows players to open a menu with , (buyammo) Key or command.
It will show different menus for Terrorist, Counter-Terrorist & Warden.
the menu shows only features that are turned on (e.g at event days)


##### Commands 
```
- sm_menu / sm_menus - open the player menu
- sm_days / sm_event / sm _events - open the Event Days menu for warden/admin
```
##### Cvars
```
- sm_menu_version - Shows the version of the SourceMod plugin MyJailBreak - Menu
- sm_menu_enable: 0 - disabled, 1 - enable jailbreak menu
- sm_menu_ct: 0 - disabled, 1 - enable jailbreak menu for CT
- sm_menu_t: 0 - disabled, 1 - enable jailbreak menu for terrorist
- sm_menu_warden: disabled, 1 - enable Jailbreak menu for warden
- sm_menu_days: 0 - disabled, 1 - enable eventdays menu for warden and admin
- sm_menu_close: 0 - disabled, 1 - enable close menu after action
- sm_menu_start: 0 - disabled, 1 - enable open menu on every roundstart
- sm_menu_tag: 0 - disabled, 1 - Allow \"MyJailbreak\" to be added to the server tags? So player will find servers with MyJB faster. it dont touch your sv_tags. Default 1
```
##### Features

- Custom chat [Tag]
- Multilingual support
- Colors
- only shows available features

#### PlayerTags

This plugins give players Tags for team (T,CT) and "rank" (admin/warden) in stats &/or chat

##### Cvars
```
- sm_playertag_version - Shows the version of the SourceMod plugin MyJailBreak - PlayerTags
- sm_playertag_enable: 0 - disabled, 1 - enable Player Tag
- sm_playertag_stats: 0 - disabled, 1 - enable PlayerTag in stats	
- sm_playertag_chat: 0 - disabled, 1 - enable PlayerTag in Chat

```

#### EventDay - War

This plugin allows to vote or set a war CT vs T for next 3 rounds.
On Round start Ts spawn freezed next to CT. After unfreeze time (def. 30sec) Ts can Move. After nodamage time (def. 30sec) the war CT vs T starts.
Or on Round start Ts spawn in open cells with weapons. No Freeze/-time.

##### Commands
```
- sm_war - Allows players to vote for a war 
- sm_setwar - Allows the Admin(sm_map) or Warden to set a war for next rounds
```
##### Cvars
```
- sm_war_version - Shows the version of the SourceMod plugin MyJailBreak - War
- sm_war_enable: 0 - disabled, 1 - enable the war plugin. Default 1
- sm_war_setw: 0 - disabled, 1 - allow warden to set next round war. Default 1
- sm_war_seta: 0 - disabled, 1 - allow admin to set next round war round. Default 1
- sm_war_vote: 0 - disabled, 1 - allow player to vote for war. Default 1
- sm_war_spawn: 0 - teleport Ts to CT and freeze, 1 - open cell doors an get weapons. Default 1
- sm_war_roundtime - Roundtime for a single war round in minutes. Default 5
- sm_war_freezetime- Time in seconds Ts are freezed. time to hide on map for CT (need sm_war_spawn: 0). Default 30
- sm_war_trucetime - Time in seconds after freezetime damage is disbaled. Default 30
- sm_war_cooldown_start - Rounds until event can be start after mapchange. Default 3
- sm_war_cooldown_day - Rounds until event can be started again. Default 3
- sm_war_sounds_enable: 0 - disabled, 1 - enable sounds. Default 1
- sm_war_sounds_start: Path to the soundfile which should be played on start. Default "music/myjailbreak/start.mp3"
- sm_war_overlays_enable: 0 - disabled, 1 - enable start overlay. Default 1
- sm_war_overlays_start: Path to the start Overlay DONT TYPE .vmt or .vft. Default "overlays/MyJailbreak/start"
- sm_war_tag: 0 - disabled, 1 - Allow \"MyJailbreak\" to be added to the server tags? So player will find servers with MyJB faster. it dont touch your sv_tags. Default 1

and more 
```
##### Features

- disable warden, other eventdays, lastrequest
- autoopen celldoors
- Multilingual support
- Colors
- Custom chat [Tag]

#### EventDay - FFA

This plugin allows to vote or set a FFA war for next 3 rounds
On Round start Ts spawn next to CT. CTs & Ts can get Weapon an Move. MapFog is on for better hiding. After nodamage time (def. 30sec) the war CT vs T starts and MapFog disabled.
Or on Round start Ts spawn in open cells with weapons. 

##### Commands
```
- sm_ffa / sm_warffa - Allows players to vote for a FFA 
- sm_setffa - Allows the Admin(sm_map) or Warden to set a ffa for next rounds
```
##### Cvars
```
- sm_ffa_version - Shows the version of the SourceMod plugin MyJailBreak - FFA
- sm_ffa_enable: 0 - disabled, 1 - enable the ffa plugin. Default 1
- sm_ffa_setw: 0 - disabled, 1 - allow warden to set next round ffa. Default 1
- sm_ffa_seta: 0 - disabled, 1 - allow admin to set next round ffa round. Default 1
- sm_ffa_vote: 0 - disabled, 1 - allow player to vote for ffa. Default 1
- sm_ffa_spawn: 0 - teleport Ts to CT and freeze, 1 - open cell doors an get weapons (need smartjaildoors). Default 1
- sm_ffa_roundtime - Roundtime for a single ffa round in minutes. Default 5
- sm_ffa_trucetime - Time in seconds after freezetime damage is disbaled. Default 30
- sm_ffa_cooldown_start - Rounds until event can be start after mapchange. Default 3
- sm_ffa_cooldown_day - Rounds until event can be started again. Default 3
- sm_ffa_sounds_enable: 0 - disabled, 1 - enable sounds. Default 1
- sm_ffa_sounds_start: Path to the soundfile which should be played on start. Default "music/myjailbreak/start.mp3"
- sm_ffa_overlays_enable: 0 - disabled, 1 - enable start overlay. Default 1
- sm_ffa_overlays_start: Path to the start Overlay DONT TYPE .vmt or .vft. Default "overlays/MyJailbreak/start"
- sm_ffa_tag: 0 - disabled, 1 - Allow \"MyJailbreak\" to be added to the server tags? So player will find servers with MyJB faster. it dont touch your sv_tags. Default 1

```
##### Features

- disable warden, other eventdays, lastrequest
- autoopen celldoors (need smartjaildoors)
- Multilingual support
- Colors
- Custom chat [Tag]


#### EventDay -  Zombie

This plugin allows players to vote and warden to set next round to zombie escape
On Round start Ts spawn in open cells with weapons. CT are zombies with a zombie skin, and with 10000 HP.
Zombies freezed for default 35sec so T can hide or climb.

##### Commands
```
- sm_zombie / sm_undead - Allows players to vote for a Zombie 
- sm_setzombie - Allows the Admin(sm_map) or Warden to set Zombie as next round
```
##### Cvars
```
- sm_zombie_version - Shows the version of the SourceMod plugin MyJailBreak - Zombie
- sm_zombie_setw: 0 - disabled, 1 - allow warden to set next round zombie. Default 1
- sm_zombie_seta: 0 - disabled, 1 - allow admin to set next round zombie round. Default 1
- sm_zombie_vote: 0 - disabled, 1 - allow player to vote for zombie. Default 1
- sm_zombie_enable: 0 - disabled, 1 - enable the zombie plugin. Default 1
- sm_zombie_roundtime - Roundtime for a single zombie round in minutes. Default 5
- sm_zombie_freezetime - Time in seconds Zombies freezed. Default 35
- sm_zombie_cooldown_start - Rounds until event can be start after mapchange. Default 3
- sm_zombie_cooldown_day - Rounds until event can be started again. Default 3
- sm_zombie_sounds_enable: 0 - disabled, 1 - enable sounds. Default 1
- sm_zombie_sounds_start: Path to the soundfile which should be played on start. Default "music/myjailbreak/start.mp3"
- sm_zombie_overlays_enable: 0 - disabled, 1 - enable start overlay. Default 1
- sm_zombie_overlays_start: Path to the start Overlay DONT TYPE .vmt or .vft. Default "overlays/MyJailbreak/start"
- sm_zombie_model: Path to the model for zombies. Default "models/player/custom_player/zombie/revenant/revenant_v2.mdl"
- sm_zombie_tag: 0 - disabled, 1 - Allow \"MyJailbreak\" to be added to the server tags? So player will find servers with MyJB faster. it dont touch your sv_tags. Default 1

```
##### Features

- disable warden, other eventdays, lastrequest
- autoopen celldoors (need smartjaildoors)
- Multilingual support
- Colors
- Custom chat [Tag]


#### EventDay -  Noscope

This plugin allows players to vote and warden to set next round to noscope
On Round start cells open everybody got a scout but noscope in low gravity.

##### Commands
```
- sm_noscope / sm_undead - Allows players to vote for a noscope 
- sm_setnoscope - Allows the Admin(sm_map) or Warden to set noscope as next round
```
##### Cvars
```
- sm_noscope_version - Shows the version of the SourceMod plugin MyJailBreak - noscope
- sm_noscope_enable: 0 - disabled, 1 - enable the noscope plugin. Default 1
- sm_noscope_setw: 0 - disabled, 1 - allow warden to set next round noscope. Default 1
- sm_noscope_seta: 0 - disabled, 1 - allow admin to set next round noscope round. Default 1
- sm_noscope_vote: 0 - disabled, 1 - allow player to vote for noscope. Default 1
- sm_noscope_gravity: 0 - disabled, 1 - enable low Gravity for noscope. Default 1
- sm_noscope_gravity_value - Ratio for Gravity 1.0 earth 0.5 moon. Default 0.3
- sm_noscope_roundtime - Roundtime for a single noscope round in minutes. Default 5
- sm_noscope_trucetime - Time in seconds damage is disbaled. Default 15
- sm_noscope_cooldown_start - Rounds until event can be start after mapchange. Default 3
- sm_noscope_cooldown_day - Rounds until event can be started again. Default 3
- sm_noscope_sounds_enable: 0 - disabled, 1 - enable sounds. Default 1
- sm_noscope_sounds_start: Path to the soundfile which should be played on start. Default "music/myjailbreak/start.mp3"
- sm_noscope_overlays_enable: 0 - disabled, 1 - enable start overlay. Default 1
- sm_noscope_overlays_start: Path to the start Overlay DONT TYPE .vmt or .vft. Default "overlays/MyJailbreak/start"
- sm_noscope_tag: 0 - disabled, 1 - Allow \"MyJailbreak\" to be added to the server tags? So player will find servers with MyJB faster. it dont touch your sv_tags. Default 1

```
##### Features

- disable warden, other eventdays, lastrequest
- autoopen celldoors (need smartjaildoors)
- Multilingual support
- Colors
- Custom chat [Tag]

#### EventDay - Dodgeball

This plugin allows players to vote and warden to set next round to Dodgeball
open cells Dodgeball low gravity.

##### Commands
```
- sm_dodgeball / sm_undead - Allows players to vote for a dodgeball 
- sm_setdodgeball - Allows the Admin(sm_map) or Warden to set dodgeball as next round
```
##### Cvars
```
- sm_dodgeball_version - Shows the version of the SourceMod plugin MyJailBreak - dodgeball
- sm_dodgeball_enable: 0 - disabled, 1 - enable the dodgeball plugin. Default 1
- sm_dodgeball_setw: 0 - disabled, 1 - allow warden to set next round Dodgeball. Default 1
- sm_dodgeball_seta: 0 - disabled, 1 - allow admin to set next round Dodgeball round. Default 1
- sm_dodgeball_vote: 0 - disabled, 1 - allow player to vote for Dodgeball. Default 1
- sm_dodgeball_gravity: 0 - disabled, 1 - enable low Gravity for dodgeball. Default 1
- sm_dodgeball_gravity_value - Ratio for Gravity 1.0 earth 0.5 moon. Default 0.3
- sm_dodgeball_roundtime - Roundtime for a single dodgeball round in minutes. Default 5
- sm_dodgeball_trucetime - Time in seconds damage is disbaled. Default 15
- sm_dodgeball_cooldown_start - Rounds until event can be start after mapchange. Default 3
- sm_dodgeball_cooldown_day - Rounds until event can be started again. Default 3
- sm_dodgeball_sounds_enable: 0 - disabled, 1 - enable sounds. Default 1
- sm_dodgeball_sounds_start: Path to the soundfile which should be played on start. Default "music/myjailbreak/start.mp3"
- sm_dodgeball_overlays_enable: 0 - disabled, 1 - enable start overlay. Default 1
- sm_dodgeball_overlays_start: Path to the start Overlay DONT TYPE .vmt or .vft. Default "overlays/MyJailbreak/start"
- sm_dodgeball_tag: 0 - disabled, 1 - Allow \"MyJailbreak\" to be added to the server tags? So player will find servers with MyJB faster. it dont touch your sv_tags. Default 1

```
##### Features

- disable warden, other eventdays, lastrequest
- autoopen celldoors (need smartjaildoors)
- Multilingual support
- Colors
- Custom chat [Tag]

#### EventDay -  catch

This plugin allows players to vote and warden to set next round to catch
open cells-  CT must catch and freeze all Ts by knifing.
Ts can unfreeze Freezed Ts by knife them again.

##### Commands
```
- sm_catch - Allows players to vote for a catch 
- sm_setcatch - Allows the Admin(sm_map) or Warden to set catch as next round
- sm_sprint - Start sprinting!
```

##### Cvars
```
- sm_catch_version - Shows the version of the SourceMod plugin MyJailBreak - catch
- sm_catch_setw: 0 - disabled, 1 - allow warden to set next round ffa. Default 1
- sm_catch_seta: 0 - disabled, 1 - allow admin to set next round ffa round. Default 1
- sm_catch_vote: 0 - disabled, 1 - allow player to vote for ffa. Default 1
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
- sm_catch_sounds_freeze: Path to the soundfile which should be played on freeze. Default "music/myjailbreak/freeze.mp3"
- sm_catch_sounds_unfreeze: Path to the soundfile which should be played on unfreeze. Default "music/myjailbreak/unfreeze.mp3"
- sm_catch_tag: 0 - disabled, 1 - Allow \"MyJailbreak\" to be added to the server tags? So player will find servers with MyJB faster. it dont touch your sv_tags. Default 1

```
##### Features

- disable warden, other eventdays, lastrequest

- autoopen celldoors (need smartjaildoors)
- Multilingual support
- Colors
- Custom chat [Tag]

#### EventDay -  Hide in the Dark

This plugin allows players to vote and warden to set next round to hide in the dark
Map is darken. CTs freezed, Cells open and Ts got time to hide on map. When CT got unfreed Ts get freezed (if u like)

##### Commands
```
- sm_hide / sm_undead - Allows players to vote for a hide 
- sm_sethide - Allows the Admin(sm_map) or Warden to set hide as next round
```
##### Cvars
```
- sm_hide_version - Shows the version of the SourceMod plugin MyJailBreak - hide
- sm_hide_setw: 0 - disabled, 1 - allow warden to set next round ffa. Default 1
- sm_hide_seta: 0 - disabled, 1 - allow admin to set next round ffa round. Default 1
- sm_hide_vote: 0 - disabled, 1 - allow player to vote for ffa. Default 1
- sm_hide_enable: 0 - disabled, 1 - enable the hide plugin. Default 1
- sm_hide_roundtime - Roundtime for a single hide round in minutes. Default 5
- sm_hide_hidetime - Time in seconds to hide. Default 30
- sm_hide_freezehider: 0 - disabled, 1 - enable freeze hider when hidetime gone. Default 1
- sm_hide_cooldown_start - Rounds until event can be start after mapchange. Default 3
- sm_hide_cooldown_day - Rounds until event can be started again. Default 3
- sm_hide_sounds_enable: 0 - disabled, 1 - enable sounds. Default 1
- sm_hide_sounds_start: Path to the soundfile which should be played on start. Default "music/myjailbreak/start.mp3"
- sm_hide_overlays_enable: 0 - disabled, 1 - enable start overlay. Default 1
- sm_hide_overlays_start: Path to the start Overlay DONT TYPE .vmt or .vft. Default "overlays/MyJailbreak/start"
- sm_hide_tag: 0 - disabled, 1 - Allow \"MyJailbreak\" to be added to the server tags? So player will find servers with MyJB faster. it dont touch your sv_tags. Default 1

```
##### Features

- disable warden, other eventdays, lastrequest

- autoopen celldoors (need smartjaildoors)
- Multilingual support
- Colors
- Custom chat [Tag]

#### EventDay -  Duckhunt

This plugin allows players to vote and warden to set next round to duckhunt
T are Chicken in Thirdperson. After turcetime the cells open and T got He against CT as heavy with nova.

##### Commands
```
- sm_duckhunt / sm_undead - Allows players to vote for a duckhunt 
- sm_setduckhunt - Allows the Admin(sm_map) or Warden to set duckhunt as next round
```
##### Cvars
```
- sm_duckhunt_version - Shows the version of the SourceMod plugin MyJailBreak - duckhunt
- sm_duckhunt_setw: 0 - disabled, 1 - allow warden to set next round ffa. Default 1
- sm_duckhunt_seta: 0 - disabled, 1 - allow admin to set next round ffa round. Default 1
- sm_duckhunt_vote: 0 - disabled, 1 - allow player to vote for ffa. Default 1
- sm_duckhunt_enable: 0 - disabled, 1 - enable the duckhunt plugin. Default 1
- sm_duckhunt_roundtime - Roundtime for a single duckhunt round in minutes. Default 5
- sm_duckhunt_trucetime - Time in seconds damage is disbaled. Default 15
- sm_duckhunt_cooldown_start - Rounds until event can be start after mapchange. Default 3
- sm_duckhunt_cooldown_day - Rounds until event can be started again. Default 3
- sm_duckhunt_sounds_enable: 0 - disabled, 1 - enable sounds. Default 1
- sm_duckhunt_sounds_start: Path to the soundfile which should be played on start. Default "music/myjailbreak/start.mp3"
- sm_duckhunt_overlays_enable: 0 - disabled, 1 - enable start overlay. Default 1
- sm_duckhunt_overlays_start: Path to the start Overlay DONT TYPE .vmt or .vft. Default "overlays/MyJailbreak/start"
- sm_duckhunt_tag: 0 - disabled, 1 - Allow \"MyJailbreak\" to be added to the server tags? So player will find servers with MyJB faster. it dont touch your sv_tags. Default 1

```
##### Features

- disable warden, other eventdays, lastrequest

- autoopen celldoors (need smartjaildoors)
- Multilingual support
- Colors
- Custom chat [Tag]


#### EventDay - Jihad

This plugin allows players to vote and warden to set next round to Jihad.
CTs got time to hide before cells open and Ts got Suicide bombs to kill all CT.

##### Commands
```
- sm_jihad - Allows players to vote for a duckhunt 
- sm_setjihad - Allows the Admin(sm_map) or Warden to set jihad as next round
- sm_sprint - Start sprinting!
- sm_makeboom - Suicide with bomb.

```
##### Cvars
```
- sm_jihad_version - Shows the version of the SourceMod plugin MyJailBreak - jihad
- sm_jihad_setw: 0 - disabled, 1 - allow warden to set next round ffa. Default 1
- sm_jihad_seta: 0 - disabled, 1 - allow admin to set next round ffa round. Default 1
- sm_jihad_vote: 0 - disabled, 1 - allow player to vote for ffa. Default 1
- sm_jihad_enable: 0 - disabled, 1 - enable the plugin. Default 1
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
- sm_jihad_sounds_start: Path to the soundfile which should be played on start. Default "music/myjailbreak/start.mp3"
- sm_jihad_sounds_jihad - Path to the soundfile which should be played on activate bomb. Default "music/myjailbreak/jihad.mp3"
- sm_jihad_sounds_boom - Path to the soundfile which should be played on detonation. Default "music/myjailbreak/bombe.mp3"
- sm_jihad_overlays_enable: 0 - disabled, 1 - enable start overlay. Default 1
- sm_jihad_overlays_start: Path to the start Overlay DONT TYPE .vmt or .vft. Default "overlays/MyJailbreak/start"
- sm_jihad_tag: 0 - disabled, 1 - Allow \"MyJailbreak\" to be added to the server tags? So player will find servers with MyJB faster. it dont touch your sv_tags. Default 1

```
##### Features

- disable warden, other eventdays, lastrequest

- autoopen celldoors (need smartjaildoors)
- Multilingual support
- Colors
- Custom chat [Tag]

#### EventDay -  knifefight

This plugin allows players to vote and warden to set next round to knifefight
Last man standing Knife fight with Thirdperson low gravity and iceskates

##### Commands
```
- sm_knifefight - Allows players to vote for a knifefight 
- sm_setknifefight - Allows the Admin(sm_map) or Warden to set knifefight as next round
```
##### Cvars
```
- sm_knifefight_version - Shows the version of the SourceMod plugin MyJailBreak - knifefight
- sm_knifefight_enable: 0 - disabled, 1 - enable the knifefight plugin. Default 1
- sm_knifefight_setw: 0 - disabled, 1 - allow warden to set next round knifefight. Default 1
- sm_knifefight_seta: 0 - disabled, 1 - allow admin to set next round knifefight round. Default 1
- sm_knifefight_vote: 0 - disabled, 1 - allow player to vote for knifefight. Default 1
- sm_knifefight_thirdperson: 0 - disabled, 1 - enable thirdperson for knifefight. Default 1
- sm_knifefight_gravity: 0 - disabled, 1 - enable low Gravity for knifefight. Default 1
- sm_knifefight_gravity_value - Ratio for Gravity 1.0 earth 0.5 moon. Default 0.3
- sm_knifefight_iceskate: 0 - disabled, 1 - enable iceskate for knifefight. Default 1
- sm_knifefight_iceskate_value - Ratio iceskate (5.2 normal). Default 1.0
- sm_knifefight_roundtime - Roundtime for a single knifefight round in minutes. Default 5
- sm_knifefight_trucetime - Time in seconds damage is disbaled. Default 15
- sm_knifefight_cooldown_start - Rounds until event can be start after mapchange. Default 3
- sm_knifefight_cooldown_day - Rounds until event can be started again. Default 3
- sm_knifefight_sounds_enable: 0 - disabled, 1 - enable sounds. Default 1
- sm_knifefight_sounds_start: Path to the soundfile which should be played on start. Default "music/myjailbreak/start.mp3"
- sm_knifefight_overlays_enable: 0 - disabled, 1 - enable start overlay. Default 1
- sm_knifefight_overlays_start: Path to the start Overlay DONT TYPE .vmt or .vft. Default "overlays/MyJailbreak/start"
- sm_knifefight_tag: 0 - disabled, 1 - Allow \"MyJailbreak\" to be added to the server tags? So player will find servers with MyJB faster. it dont touch your sv_tags. Default 1

```
##### Features

- disable warden, other eventdays, lastrequest

- autoopen celldoors (need smartjaildoors)
- Multilingual support
- Colors
- Custom chat [Tag]

#### EventDay - Freeday

This plugin allows players to vote and warden to set next round to freeday
auto open cells for freeday and if want no damage.

##### Commands
```
- sm_freeday - Allows players to vote for a freeday 
- sm_setfreeday - Allows the Admin(sm_map) or Warden to set freeday as next round
```
##### Cvars
```
- sm_freeday_version - Shows the version of the SourceMod plugin MyJailBreak - freeday
- sm_freeday_enable: 0 - disabled, 1 - enable the freeday plugin. Default 1
- sm_freeday_setw: 0 - disabled, 1 - allow warden to set next round freeday. Default 1
- sm_freeday_seta: 0 - disabled, 1 - allow admin to set next round freeday round. Default 1
- sm_freeday_vote: 0 - disabled, 1 - allow player to vote for freeday. Default 1
- sm_freeday_roundtime - Roundtime for a single freeday round in minutes. Default 5
- sm_freeday_firstround - auto freeday first round after mapstart. Default 1
- sm_freeday_damage: 0 - disabled, 1 - enable damage on freedays. Default 1
- sm_freeday_cooldown_day - Rounds until event can be started again. Default 3
- sm_freeday_tag: 0 - disabled, 1 - Allow \"MyJailbreak\" to be added to the server tags? So player will find servers with MyJB faster. it dont touch your sv_tags. Default 1

```
##### Features

- disable warden, other eventdays, lastrequest
- autoopen celldoors (need smartjaildoors)
- Multilingual support
- Colors
- Custom chat [Tag]


### requires plugins
- Smart Jail Doors https://github.com/Kailo97/smartjaildoors
- sm hosties https://github.com/dataviruset/sm-hosties
- SM File/Folder Downloader and Precacher https://forums.alliedmods.net/showthread.php?p=602270 for zombie/warden model download (overlays & sounds auto added)
- Simple Chat Prozessor https://bitbucket.org/minimoney1/simple-chat-processor

### recomment plugins
- [CS:GO] Flashlight (1.3.62) https://forums.alliedmods.net/showthread.php?p=2042310


based/merged/used code/idea plugins: 
* https://github.com/ecca/SourceMod-Plugins/tree/sourcemod/Warden
* https://github.com/ESK0/ESK0s_JailBreak_Warden/
* https://git.tf/Zipcore/Warden
* https://git.tf/Zipcore/Warden-Sounds
* https://git.tf/Zipcore/Warden-SimpleMarkers
* https://forums.alliedmods.net/showthread.php?t=264848
* https://github.com/Franc1sco/Franug-JailBreak/
* https://forums.alliedmods.net/showthread.php?t=231473
* https://forums.alliedmods.net/showthread.php?p=1922088
* https://github.com/walmar/ShortSprint
* https://github.com/KissLick/TeamGames/
* https://github.com/AG-Headline/Hunger-Games-Beacon
* https://forums.alliedmods.net/showthread.php?p=1086127
* if I missed someone, please tell me!
