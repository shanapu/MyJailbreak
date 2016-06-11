### Change Log
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

### Versioning
for a better understanding:
```
0.7.2  
│ │ └───patch level - fix within major/minior release  
│ └─────minor release - feature/structure added/removed/changed  
└───────major release - stable/release  
```