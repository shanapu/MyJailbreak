# MyJailbreak 

## work in progress! a rough AlphaVersion 
### This is my first public project. please note that the code may is messy, stupid and miscarriage.
### I would be happy and very pleased if you wannt to join this project as equal collaborator.
### If you own a feature or extention for Jail/Warden that would fit in, i would be happy when you share it with us.
### see [todo list](https://git.tf/shanapu/MyJailbreak/blob/master/TODO.md) the "must" part is todo before first release on AM
### "future dreams" make it to a allinone plugin.
### help me by posting bugs and feature ideas in [Issue list](https://git.tf/shanapu/MyJailbreak/issues)
### forks and merge requests are welcome

A "rewrite" version of [Franugs Special Jailbreak](https://github.com/Franc1sco/Franug-JailBreak/) and  [eccas, ESK0s & zipcores Jailbreak Warden](http://www.sourcemod.net/plugins.php?cat=0&mod=-1&title=warden&author=&description=&search=1)

## Jailbreak plugin pack for CS:GO Jailserver

### Included Plugins: 

- Warden - (set/become warden,vote against warden, open cells, set eventdays/countdown/FF/nobock)
- Menu - (Player menus for T, CT, Warden & Admin)
- Weapons - (weapon menus for CT / T in event rounds)
- Event Days (set/vote a Event for next round)
    - War (CT vs T TDM)
    - Free For All (FFA DM)
    - Zombie (CT(zombie) vs T(Human))
    - Noscope (FFA Scout LowGravity NoScope)
    - Hide in the Dark - (kind of HideNseek)
    - Catch - (CT must catch all T (freeze tag))
    - Duckhunt - (CT(hunter) with nova vs T(chicken in 3th person))
    - Freeday - (auto on first round/damage disabled)

# Credits: 

## **used code from: ecca, Zipcore, ESK0, Floody.de, franug, bara, headline, ReFlexPoison** and many other I cant remember!
# THANKS FOR MAKING FREE SOFTWARE!


#### Menu

This plugins allows players to open a menu with , (buyammo) Key or command.
It will show different menus for Terrorist, Counter-Terrorist & Warden.


based/merged/used code/idea plugins: 
* https://github.com/Franc1sco/Franug-JailBreak/blob/Only-Days-And-Captain/addons/sourcemod/scripting/jailbreak_menu.sp
* https://github.com/AG-Headline/Hunger-Games-Beacon
* if I missed someone, please tell me!

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
- only shows enabled features

#### EventDay - War

This plugin allows to vote or set a war CT vs T for next 3 rounds.
On Round start Ts spawn freezed next to CT. After unfreeze time (def. 30sec) Ts can Move. After nodamage time (def. 30sec) the war CT vs T starts.
Or on Round start Ts spawn in open cells with weapons. No Freeze/-time.

based/merged/used code/idea plugins: 
* https://forums.alliedmods.net/showpost.php?p=1657893&postcount=11?p=1657893&postcount=11
* https://github.com/Franc1sco/Franug-JailBreak/blob/Only-Days-And-Captain/addons/sourcemod/scripting/jailbreak_open.sp
* https://forums.alliedmods.net/showthread.php?t=231473
* https://github.com/AG-Headline/Hunger-Games-Beacon
* if I missed someone, please tell me!

##### Commands
```
- sm_war / sm_krieg - Allows players to vote for a war 
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
- sm_war_nodamage - Time in seconds after freezetime damage is disbaled. Default 30
- sm_war_roundwait - Rounds until event can be started after mapchange. Default 3
- sm_war_roundsnext - Rounds until event can be started again. Default 3
- sm_war_overlays: 0 - disabled, 1 - enable start overlay. Default 1
- sm_war_overlaystart_path: Path to the start Overlay DONT TYPE .vmt or .vft. Default "overlays/MyJailbreak/start"
- sm_war_tag: 0 - disabled, 1 - Allow \"MyJailbreak\" to be added to the server tags? So player will find servers with MyJB faster. it dont touch your sv_tags. Default 1

and more 
```
##### Features

- disable warden, other eventdays, lastrequest, dice
- enable beacon for last players (need Hg beacon)
- autoopen celldoors
- Multilingual support
- Colors
- Custom chat [Tag]

#### EventDay - FFA

This plugin allows to vote or set a FFA war for next 3 rounds
On Round start Ts spawn next to CT. CTs & Ts can get Weapon an Move. MapFog is on for better hiding. After nodamage time (def. 30sec) the war CT vs T starts and MapFog disabled.
Or on Round start Ts spawn in open cells with weapons. 

based/merged/used code/idea plugins: 
* https://forums.alliedmods.net/showpost.php?p=1657893&postcount=11?p=1657893&postcount=11
* https://github.com/Franc1sco/Franug-JailBreak/blob/Only-Days-And-Captain/addons/sourcemod/scripting/jailbreak_wartotal.sp
* https://github.com/Franc1sco/Franug-JailBreak/blob/Only-Days-And-Captain/addons/sourcemod/scripting/oscuridad.sp
* https://github.com/Franc1sco/Franug-JailBreak/blob/Only-Days-And-Captain/addons/sourcemod/scripting/jailbreak_open.sp
* https://github.com/AG-Headline/Hunger-Games-Beacon
* https://github.com/Franc1sco/Franug-JailBreak/blob/Only-Days-And-Captain/addons/sourcemod/scripting/oscuridad.sp
* if I missed someone, please tell me!

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
- sm_ffa_nodamage - Time in seconds after freezetime damage is disbaled. Default 30
- sm_ffa_roundwait - Rounds until event can be started after mapchange. Default 3
- sm_ffa_roundsnext - Rounds until event can be started again. Default 3
- sm_ffa_overlays: 0 - disabled, 1 - enable start overlay. Default 1
- sm_ffa_overlaystart_path: Path to the start Overlay DONT TYPE .vmt or .vft. Default "overlays/MyJailbreak/start"
- sm_ffa_tag: 0 - disabled, 1 - Allow \"MyJailbreak\" to be added to the server tags? So player will find servers with MyJB faster. it dont touch your sv_tags. Default 1

```
##### Features

- disable warden, other eventdays, lastrequest, dice
- enable beacon for last players (need Hgbeacon)
- autoopen celldoors (need smartjaildoors)
- Multilingual support
- Colors
- Custom chat [Tag]


#### EventDay -  Zombie

This plugin allows players to vote and warden to set next round to zombie escape
On Round start Ts spawn in open cells with weapons. CT are zombies with a zombie skin, and with 10000 HP.
Zombies freezed for default 35sec so T can hide or climb.

based/merged/used code/idea plugins: 
* https://forums.alliedmods.net/showpost.php?p=1657893&postcount=11?p=1657893&postcount=11
* https://github.com/Franc1sco/Franug-JailBreak/blob/Only-Days-And-Captain/addons/sourcemod/scripting/jailbreak_zombies.sp
* https://github.com/Franc1sco/Franug-JailBreak/blob/Only-Days-And-Captain/addons/sourcemod/scripting/jailbreak_open.sp
* https://forums.alliedmods.net/showthread.php?t=231473
* https://github.com/AG-Headline/Hunger-Games-Beacon
* if I missed someone, please tell me!

##### Commands
```
- sm_zombie / sm_undead - Allows players to vote for a Zombie 
- sm_setzombie - Allows the Admin(sm_map) or Warden to set Zombie as next round
```
##### Cvars
```
- sm_zombie_version - Shows the version of the SourceMod plugin MyJailBreak - Zombie
- sm_zombie_setw: 0 - disabled, 1 - allow warden to set next round ffa. Default 1
- sm_zombie_seta: 0 - disabled, 1 - allow admin to set next round ffa round. Default 1
- sm_zombie_vote: 0 - disabled, 1 - allow player to vote for ffa. Default 1
- sm_zombie_enable: 0 - disabled, 1 - enable the zombie plugin. Default 1
- sm_zombie_roundtime - Roundtime for a single zombie round in minutes. Default 5
- sm_zombie_freezetime - Time in seconds Zombies freezed. Default 35
- sm_zombie_roundwait - Rounds until event can be started after mapchange. Default 3
- sm_zombie_roundsnext - Rounds until event can be started again. Default 3
- sm_zombie_overlays: 0 - disabled, 1 - enable start overlay. Default 1
- sm_zombie_overlaystart_path: Path to the start Overlay DONT TYPE .vmt or .vft. Default "overlays/MyJailbreak/start"
- sm_zombie_model: Path to the model for zombies. Default "models/player/custom_player/zombie/revenant/revenant_v2.mdl"
- sm_zombie_tag: 0 - disabled, 1 - Allow \"MyJailbreak\" to be added to the server tags? So player will find servers with MyJB faster. it dont touch your sv_tags. Default 1

```
##### Features

- disable warden, other eventdays, lastrequest, dice
- enable beacon for last players (need Hg beacon)
- autoopen celldoors (need smartjaildoors)
- Multilingual support
- Colors
- Custom chat [Tag]


#### EventDay -  Noscope

This plugin allows players to vote and warden to set next round to noscope
open cells noscope scout low gravity. no reload

based/merged/used code/idea plugins: 
* https://forums.alliedmods.net/showpost.php?p=1657893&postcount=11?p=1657893&postcount=11
* https://github.com/Franc1sco/Franug-JailBreak/blob/Only-Days-And-Captain/addons/sourcemod/scripting/jailbreak_noscope.sp
* https://github.com/Franc1sco/Franug-JailBreak/blob/Only-Days-And-Captain/addons/sourcemod/scripting/jailbreak_open.sp
* https://forums.alliedmods.net/showthread.php?t=231473
* https://github.com/AG-Headline/Hunger-Games-Beacon
* if I missed someone, please tell me!

##### Commands
```
- sm_noscope / sm_undead - Allows players to vote for a noscope 
- sm_setnoscope - Allows the Admin(sm_map) or Warden to set noscope as next round
```
##### Cvars
```
- sm_noscope_version - Shows the version of the SourceMod plugin MyJailBreak - noscope
- sm_noscope_setw: 0 - disabled, 1 - allow warden to set next round ffa. Default 1
- sm_noscope_seta: 0 - disabled, 1 - allow admin to set next round ffa round. Default 1
- sm_noscope_vote: 0 - disabled, 1 - allow player to vote for ffa. Default 1
- sm_noscope_enable: 0 - disabled, 1 - enable the noscope plugin. Default 1
- sm_noscope_roundtime - Roundtime for a single noscope round in minutes. Default 5
- sm_noscope_nodamage - Time in seconds damage is disbaled. Default 15
- sm_noscope_roundwait - Rounds until event can be started after mapchange. Default 3
- sm_noscope_roundsnext - Rounds until event can be started again. Default 3
- sm_noscope_overlays: 0 - disabled, 1 - enable start overlay. Default 1
- sm_noscope_overlaystart_path: Path to the start Overlay DONT TYPE .vmt or .vft. Default "overlays/MyJailbreak/start"
- sm_noscope_tag: 0 - disabled, 1 - Allow \"MyJailbreak\" to be added to the server tags? So player will find servers with MyJB faster. it dont touch your sv_tags. Default 1

```
##### Features

- disable warden, other eventdays, lastrequest, dice
- enable beacon for last players (need Hg beacon)
- autoopen celldoors (need smartjaildoors)
- Multilingual support
- Colors
- Custom chat [Tag]

#### EventDay -  catch

This plugin allows players to vote and warden to set next round to catch
open cells-  CT must catch and freeze all Ts by knifing.
Ts can unfreeze Freezed Ts by knife them again.

based/merged/used code/idea plugins: 
* https://forums.alliedmods.net/showpost.php?p=1657893&postcount=11?p=1657893&postcount=11
* https://github.com/Franc1sco/Franug-JailBreak/blob/Only-Days-And-Captain/addons/sourcemod/scripting/jailbreak_pilla.sp
* https://github.com/Franc1sco/Franug-JailBreak/blob/Only-Days-And-Captain/addons/sourcemod/scripting/jailbreak_open.sp
* https://forums.alliedmods.net/showthread.php?t=231473
* https://github.com/AG-Headline/Hunger-Games-Beacon
* if I missed someone, please tell me!

##### Commands
```
- sm_catch / sm_catchfreeze - Allows players to vote for a catch 
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
- sm_catch_sprint_enable", "1","Enable/Disable ShortSprint. Default 1
- sm_catch_sprint_button: 0 - disabled, 1 - enable +use button support or use/bind sm_sprint. Default 1
- sm_catch_sprint_cooldown: Time in seconds the player must wait for the next sprint. Default 10
- sm_catch_sprint_speed: Ratio for how fast the player will sprint. Default 1.25
- sm_catch_sprint_time: Time in seconds the player will sprint. Default 3.5
- sm_catch_roundtime - Roundtime for a single catch round in minutes. Default 5
- sm_catch_nodamage - Time in seconds damage is disbaled. Default 15
- sm_catch_roundwait - Rounds until event can be started after mapchange. Default 3
- sm_catch_roundsnext - Rounds until event can be started again. Default 3
- sm_catch_overlays: 0 - disabled, 1 - enable freezed overlays. Default 1
- sm_catch_stayoverlay: 0 - overlays will removed after 3sec. , 1 - overlays will stay until unfreeze
- sm_catch_overlayfreeze_path: Path to the start Overlay DONT TYPE .vmt or .vft. Default "overlays/MyJailbreak/freeze"
- sm_catch_sounds_enable: 0 - disabled, 1 - enable un/-Freeze sounds");
- sm_catch_sounds_freeze: Path to the sound which should be played on freeze. Default "music/myjailbreak/freeze.mp3"
- sm_catch_sounds_unfreeze: Path to the sound which should be played on unfreeze. Default "music/myjailbreak/unfreeze.mp3"
- sm_catch_tag: 0 - disabled, 1 - Allow \"MyJailbreak\" to be added to the server tags? So player will find servers with MyJB faster. it dont touch your sv_tags. Default 1

```
##### Features

- disable warden, other eventdays, lastrequest, dice
- enable beacon for last players (need Hg beacon)
- autoopen celldoors (need smartjaildoors)
- Multilingual support
- Colors
- Custom chat [Tag]

#### EventDay -  Hide in the Dark

This plugin allows players to vote and warden to set next round to hide in the dark
Map is darken. CTs freezed, Cells open and Ts got time to hide on map. When CT got unfreed Ts get freezed (if u like)

based/merged/used code/idea plugins: 
* https://forums.alliedmods.net/showpost.php?p=1657893&postcount=11?p=1657893&postcount=11
* https://github.com/Franc1sco/Franug-JailBreak/blob/Only-Days-And-Captain/addons/sourcemod/scripting/jailbreak_escondite.sp
* https://github.com/Franc1sco/Franug-JailBreak/blob/Only-Days-And-Captain/addons/sourcemod/scripting/oscuridad.sp
* https://github.com/Franc1sco/Franug-JailBreak/blob/Only-Days-And-Captain/addons/sourcemod/scripting/jailbreak_open.sp
* https://forums.alliedmods.net/showthread.php?t=231473
* https://github.com/Franc1sco/Franug-JailBreak/blob/Only-Days-And-Captain/addons/sourcemod/scripting/oscuridad.sphttps://github.com/Franc1sco/Franug-JailBreak/blob/Only-Days-And-Captain/addons/sourcemod/scripting/oscuridad.sp
* https://github.com/AG-Headline/Hunger-Games-Beacon
* if I missed someone, please tell me!

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
- sm_hide_roundwait - Rounds until event can be started after mapchange. Default 3
- sm_hide_roundsnext - Rounds until event can be started again. Default 3
- sm_hide_overlays: 0 - disabled, 1 - enable start overlay. Default 1
- sm_hide_overlaystart_path: Path to the start Overlay DONT TYPE .vmt or .vft. Default "overlays/MyJailbreak/start"
- sm_hide_tag: 0 - disabled, 1 - Allow \"MyJailbreak\" to be added to the server tags? So player will find servers with MyJB faster. it dont touch your sv_tags. Default 1

```
##### Features

- disable warden, other eventdays, lastrequest, dice
- enable beacon for last players (need Hg beacon)
- autoopen celldoors (need smartjaildoors)
- Multilingual support
- Colors
- Custom chat [Tag]

#### EventDay -  Duckhunt

This plugin allows players to vote and warden to set next round to duckhunt
open cells duckhunt scout low gravity. no reload

based/merged/used code/idea plugins: 
* https://forums.alliedmods.net/showpost.php?p=1657893&postcount=11?p=1657893&postcount=11
* https://github.com/Franc1sco/Franug-JailBreak/blob/Only-Days-And-Captain/addons/sourcemod/scripting/jailbreak_open.sp
* https://forums.alliedmods.net/showthread.php?t=231473
* https://github.com/AG-Headline/Hunger-Games-Beacon
* if I missed someone, please tell me!

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
- sm_duckhunt_nodamage - Time in seconds damage is disbaled. Default 15
- sm_duckhunt_roundwait - Rounds until event can be started after mapchange. Default 3
- sm_duckhunt_roundsnext - Rounds until event can be started again. Default 3
- sm_duckhunt_overlays: 0 - disabled, 1 - enable start overlay. Default 1
- sm_duckhunt_overlaystart_path: Path to the start Overlay DONT TYPE .vmt or .vft. Default "overlays/MyJailbreak/start"
- sm_duckhunt_tag: 0 - disabled, 1 - Allow \"MyJailbreak\" to be added to the server tags? So player will find servers with MyJB faster. it dont touch your sv_tags. Default 1

```
##### Features

- disable warden, other eventdays, lastrequest, dice
- enable beacon for last players (need Hg beacon)
- autoopen celldoors (need smartjaildoors)
- Multilingual support
- Colors
- Custom chat [Tag]


### requires plugins
- Smart Jail Doors https://github.com/Kailo97/smartjaildoors
- sm hosties https://github.com/dataviruset/sm-hosties
- SM File/Folder Downloader and Precacher https://forums.alliedmods.net/showthread.php?p=602270 for model download

### recomment plugins
- [CS:GO] Flashlight (1.3.62) https://forums.alliedmods.net/showthread.php?p=2042310
- [CS:GO] Hunger Games Beacon https://github.com/AG-Headline/Hunger-Games-Beacon



