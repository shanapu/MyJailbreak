### Change Log

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