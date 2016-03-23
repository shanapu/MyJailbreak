# MyJailbreak 

## Jailbreak plugin mashup (or patchwork?) pack

### Plugins:

#### Wardn
based/merged/idea plugins: 
- https://github.com/ecca/SourceMod-Plugins/tree/sourcemod/Warden
- https://github.com/ESK0/ESK0s_JailBreak_Warden/
- https://git.tf/Zipcore/Warden
- https://git.tf/Zipcore/Warden-Sounds
- https://github.com/Franc1sco/Franug-JailBreak/blob/Only-Days-And-Captain/addons/sourcemod/scripting/jailbreak_open.sp

This plugins allows players to take control over the prison as Warden/Headguard/Commander.
Chat, Hud & sound notifications about warden/no warden, colorize warden, open/close cell doors, automatic open cells doors & toggle noblock.

##### Commands // why so many cmds for same action? my players are dump.

- sm_w / sm_warden - Allows the player taking the charge over prisoners
- sm_c / sm_commander - Allows the player taking the charge over prisoners
- sm_hg / sm_headguard - Allows the player taking the charge over prisoners
- sm_uhg / sm_unheadguard - Allows the player to retire from the position
- sm_uc / sm_uncommander - Allows the player to retire from the position
- sm_open - Allows the warden to open the cell doors
- sm_close - Allows the warden to close the cell doors
- sm_noblockon - Allows the warden to enable no block (for the warden ?)
- sm_noblockon - Allows the warden to disable no block (for the warden ?)

##### AdminCommands // ADMFLAG_GENERIC

- sm_sw / sm_setwarden - Allows the Admin to set a player to warden
- sm_rw / sm_removewarden - Allows the Admin to remove a player from warden

##### Cvars

- sm_warden_version - Shows the version of the SourceMod plugin MyJailBreak - Warden
- sm_warden_better_notifications: 0 - disabled , 1 - will use hint and center say for better notifications. Default 1
- sm_warden_enable: 0 - disabled, 1 - enable the warden plugin. Default 1
- sm_warden_nextround: 0 - disabled, 1 - warden will stay after round end. Default 1
- sm_warden_noblock: 0 - disabled, 1 - enable setable noblock for warden. Default 1
- sm_wardencolor_enable: 0 - disabled, 1 - enable colored warden. Default 1
- sm_wardencolor_red - What color to turn the warden into (set R, G and B values to 0 to disable). Default 0
- sm_wardencolor_green - What color to turn the warden into (rGb): x - green value. Default 0
- sm_wardencolor_blue - What color to turn the warden into (rgB): x - blue value. Default 255
- sm_wardensounds_enable: 0 - disabled, 1 - Play a sound when a player become warden or warden leaves. Default 1
- sm_warden_sounds_path - Path to the sound which should be played for a new warden. Default "music/myjailbreak/warden.mp3"
- sm_warden_sounds_path2 - Path to the sound which should be played when there is no warden anymore. Default "music/myjailbreak/unwarden.mp3"
- sm_wardenopen_enable: 0 - disabled, 1 - warden can open/close cell doors. Default 1
- sm_wardenopen_time_enable: 0 - disabled, 1 - cell doors will open automatic after - sm_wardenopen_time. Default 1
- sm_wardenopen_time - Time in seconds for open doors on round start automaticly. Default 60
- sm_wardenopen_time_warden: 0 - disabled, 1 - doors open automatic after - sm_wardenopen_time although there is a warden. needs - sm_wardenopen_time_enable 1. Default 1
- sm_warden_tag: 0 - disabled, 1 - Allow \"MyJailbreak\" to be added to the server tags? So player will find servers with MyJB faster. it dont touch your sv_tags. Default 1

##### Features

- Multilingual support
- Forwards
- Natives
- Colors
- Custom chat [Tag]

#### EventDay - War
based/merged/idea plugins: 
- https://forums.alliedmods.net/showpost.php?p=1657893&postcount=11?p=1657893&postcount=11
- https://github.com/Franc1sco/Franug-JailBreak/blob/Only-Days-And-Captain/addons/sourcemod/scripting/jailbreak_open.sp

This plugin allows players to vote and warden to set a war CT vs T for next 3 rounds
On Round start Ts spawn freezed next to CT. After unfreeze time (def. 30sec). Ts can get Weapon an Move. After nodamage time (def. 30sec) the war CT vs T starts.
Or on Round start Ts spawn in open cells with weapons. No Freezetime.

##### Commands

- !war / !krieg - Allows players to vote for a war 
- sm_setwar - Allows the Admin(sm_map) or Warden to set a war for next rounds

##### Cvars

- sm_war_version - Shows the version of the SourceMod plugin MyJailBreak - War
- sm_war_enable: 0 - disabled, 1 - enable the war plugin. Default 1
- sm_war_spawn: 0 - teleport Ts to CT and freeze, 1 - open cell doors an get weapons (need smartjaildoors). Default 1
- sm_war_roundtime - Roundtime for a single war round in minutes. Default 5
- sm_war_freezetime- Time in seconds Ts are freezed. time to hide on map for CT (need sm_war_spawn: 0). Default 30
- sm_war_nodamage - Time in seconds after freezetime damage is disbaled. Default 30
- sm_war_roundsnext - Rounds until event can be started again. Default 3
- sm_war_tag: 0 - disabled, 1 - Allow \"MyJailbreak\" to be added to the server tags? So player will find servers with MyJB faster. it dont touch your sv_tags. Default 1
- (sm_nowar_roundtime - set round time after a war round (mp_roundtime)) todo undo

##### Features

- disable warden, other eventdays, lastrequest, dice
- enable beacon for last players
- autoopen celldoors (need smartjaildoors)
- Multilingual support
- Colors
- Custom chat [Tag]

#### EventDay - FFA
based/merged/idea plugins: 
- https://forums.alliedmods.net/showpost.php?p=1657893&postcount=11?p=1657893&postcount=11
- https://github.com/Franc1sco/Franug-JailBreak/blob/Only-Days-And-Captain/addons/sourcemod/scripting/jailbreak_wartotal.sp
- https://github.com/Franc1sco/Franug-JailBreak/blob/Only-Days-And-Captain/addons/sourcemod/scripting/oscuridad.sp
- https://github.com/Franc1sco/Franug-JailBreak/blob/Only-Days-And-Captain/addons/sourcemod/scripting/jailbreak_open.sp

This plugin allows players to vote and warden to set a FFA war for next 3 rounds
On Round start Ts spawn next to CT. CTs & Ts can get Weapon an Move. MapFog is on for better hiding. After nodamage time (def. 30sec) the war CT vs T starts and MapFog disabled.
Or on Round start Ts spawn in open cells with weapons. 

##### Commands

- !ffa / !warffa - Allows players to vote for a FFA 
- sm_setffa - Allows the Admin(sm_map) or Warden to set a ffa for next rounds

##### Cvars

- sm_ffa_version - Shows the version of the SourceMod plugin MyJailBreak - FFA
- sm_ffa_enable: 0 - disabled, 1 - enable the war plugin. Default 1
- sm_ffa_spawn: 0 - teleport Ts to CT and freeze, 1 - open cell doors an get weapons (need smartjaildoors). Default 1
- sm_ffa_roundtime - Roundtime for a single war round in minutes. Default 5
- sm_ffa_nodamage - Time in seconds after freezetime damage is disbaled. Default 30
- sm_ffa_roundsnext - Rounds until event can be started again. Default 3
- sm_ffa_tag: 0 - disabled, 1 - Allow \"MyJailbreak\" to be added to the server tags? So player will find servers with MyJB faster. it dont touch your sv_tags. Default 1
- (sm_noffa_roundtime - set round time after a war round (mp_roundtime)) todo undo

##### Features

- disable warden, other eventdays, lastrequest, dice
- enable beacon for last players
- autoopen celldoors (need smartjaildoors)
- Multilingual support
- Colors
- Custom chat [Tag]


#### EventDay -  Zombie
based/merged/idea plugins: 
- https://forums.alliedmods.net/showpost.php?p=1657893&postcount=11?p=1657893&postcount=11
- https://github.com/Franc1sco/Franug-JailBreak/blob/Only-Days-And-Captain/addons/sourcemod/scripting/jailbreak_zombies.sp
- https://github.com/Franc1sco/Franug-JailBreak/blob/Only-Days-And-Captain/addons/sourcemod/scripting/jailbreak_open.sp

This plugin allows players to vote and warden to set next round to zombie escape
On Round start Ts spawn in open cells with weapons. CT are zombies with a zombie skin, and with 10000 HP.
Zombies freezed for default 35sec so T can hide or climb.

##### Commands

- !zombie / !undead - Allows players to vote for a Zombie 
- sm_setzombie - Allows the Admin(sm_map) or Warden to set Zombie as next round

##### Cvars

- sm_zombie_version - Shows the version of the SourceMod plugin MyJailBreak - Zombie
- sm_zombie_enable: 0 - disabled, 1 - enable the zombie plugin. Default 1
- sm_zombie_roundtime - Roundtime for a single war round in minutes. Default 5
- sm_zombie_freezetime - Time in seconds Zombies freezed. Default 35
- sm_zombie_roundsnext - Rounds until event can be started again. Default 3
- sm_zombie_tag: 0 - disabled, 1 - Allow \"MyJailbreak\" to be added to the server tags? So player will find servers with MyJB faster. it dont touch your sv_tags. Default 1
- (sm_nozombie_roundtime - set round time after a war round (mp_roundtime)) todo undo

##### Features

- disable warden, other eventdays, lastrequest, dice
- enable beacon for last players
- autoopen celldoors (need smartjaildoors)
- Multilingual support
- Colors
- Custom chat [Tag]


#### EventDay -  Noscope
based/merged/idea plugins: 
- https://forums.alliedmods.net/showpost.php?p=1657893&postcount=11?p=1657893&postcount=11
- https://github.com/Franc1sco/Franug-JailBreak/blob/Only-Days-And-Captain/addons/sourcemod/scripting/jailbreak_noscope.sp
- https://github.com/Franc1sco/Franug-JailBreak/blob/Only-Days-And-Captain/addons/sourcemod/scripting/jailbreak_open.sp

This plugin allows players to vote and warden to set next round to scout noscope

#### EventDay -  catch
based/merged/idea plugins: 
- https://forums.alliedmods.net/showpost.php?p=1657893&postcount=11?p=1657893&postcount=11
- https://github.com/Franc1sco/Franug-JailBreak/blob/Only-Days-And-Captain/addons/sourcemod/scripting/jailbreak_pilla.sp
- https://github.com/Franc1sco/Franug-JailBreak/blob/Only-Days-And-Captain/addons/sourcemod/scripting/jailbreak_open.sp

This plugin allows players to vote and warden to set next round to catch & freeze

#### EventDay -  Hide
based/merged/idea plugins: 
- https://forums.alliedmods.net/showpost.php?p=1657893&postcount=11?p=1657893&postcount=11
- https://github.com/Franc1sco/Franug-JailBreak/blob/Only-Days-And-Captain/addons/sourcemod/scripting/jailbreak_escondite.sp
- https://github.com/Franc1sco/Franug-JailBreak/blob/Only-Days-And-Captain/addons/sourcemod/scripting/oscuridad.sp
- https://github.com/Franc1sco/Franug-JailBreak/blob/Only-Days-And-Captain/addons/sourcemod/scripting/jailbreak_open.sp

This plugin allows players to vote and warden to set next round to hide and seek

#### EventDay -  Duckhunt
based/merged/idea plugins: 
- https://forums.alliedmods.net/showpost.php?p=1657893&postcount=11?p=1657893&postcount=11
- https://github.com/Franc1sco/Franug-JailBreak/blob/Only-Days-And-Captain/addons/sourcemod/scripting/jailbreak_open.sp

This plugin allows players to vote and warden to set next round to a duckhunt

#### beacon
- https://github.com/Headline22/Hunger-Games-Beacon/

#### dice
- https://forums.alliedmods.net/showthread.php?p=1427232

### requires plugins
- Smart Jail Doors https://github.com/Kailo97/smartjaildoors

### recomment plugins
- [CS:GO] Flashlight (1.3.62) https://forums.alliedmods.net/showthread.php?p=2042310

# Credits: 

**used code from: ecca, Zipcore, ESK0, Floody.de, franug, bara** 
and many snipptes and inspiration by so many other I cant remember
# THANKS FOR MAKING FREE SOFTWARE!


