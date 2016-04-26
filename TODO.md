sorry for bad spelling and loose cues

bugs:

- [x] catch: sprint bug release T
- [x] jihad: Hp & burn for not nearby
- [x] mp_roundtime 1 after set event on a eventend
- [x] catch: Just, sometimes they don't freeze
- [x] Thirdperson: on disconnect make fp
- [x] randomkill lighting bold missing
- [x] menu: infomessage on first spawn
- [ ] countdown: start-cancel-start- bug?
- [ ] warden:autoOpen broke

must:

- [x] disbale FF on roundend
- [ ] clean up code 
- [ ] comments
- [ ] some polishing
- [ ] clean/translate ConVars 
- [ ] sv_tags to core
- [x] warden:translate menu set
- [x] find better STOP SOUND!
- [x] duckhunt: more ammo for CT
- [x] duckhunt: chicken only secAttack
- [x] Finsih ice skate knife
- [x] countdown: translation and 10sek fix more times
- [x] jailbreak user menu
- [x] duckhunt: chicken thirdperson
- [x] all days: remember mp_roundtime for end // https://wiki.alliedmods.net/ConVars_(SourceMod_Scripting)#Using.2FChanging_Values
- [x] all days: dis/enable set day as admin / warden
- [x] all days: dis/enable vote by player
- [x] all days: set rounds to wait after mapstart
- [x] all days: start overlay
- [x] all days: start sound
- [x] all days: msg when deactivated by set
- [x] 1.7 syntax (ausser weapons)
- [x] new day: decoy/flash 1hp -> dodgeball
- [x] dodgeball: make it HE
- [x] dodgeball: disbable knife
- [x] countdown: is CD running? no double 
- [x] catch: freeze sound & overlay
- [x] catch: sprint build in
- [x] catch: freeze overlay stay or just 2sek. bool
- [x] alldays: cooldown cross days
- [x] zombie: define zombie model
- [x] warden: unvote
- [x] duckhunt: infi ammo
- [x] Marker: timer disaprears
- [x] warden: allow unvote
- [x] new day: suicid bomber
- [x] jihad: activate bomb when cells open 
- [x] jihad: need equit bomb to use jihad
- [x] warden: countdown
- [x] playertags: as chat tag
- [x] catch: T win when time run out
- [x] hide: T win when time run out
- [x] jihad: CT win when time run out
- [x] move FF from menu to warden
- [x] move randomkill from menu to warden
- [x] hide: freeze hide bool
- [x] Freeday: Damage disbaled 



want:
- [ ] register plugins to core
- [ ] playertags: only admin only warden...
- [ ] disarm
- [ ] add LR to menu - !rules !lastrequest !checkplayers - !stoplr 
- [ ] updater
- [ ] warden: model
- [ ] duckhunt: +attack -> not block. change to attack2
- [ ] custom command support
- [ ] make jailbreak menu customizeable (ADD OWN COMMANDS & OWN ORDER) -> keyvalues
- [ ] make centertext formating PrintCenterText(client, "<font size='30' color='#FF00FF'>test</font>");
- [ ] all days: restrict map heal station https://forums.alliedmods.net/showthread.php?t=267167
- [ ] knife: vote on roundstart for grav skate tp or all
- [ ] menu: bool show on days
- [ ] toggle noblock
- [ ] AddFileToDownloadsTable
- [ ] make zeus day
- [x] zombie: change skybox
- [x] randomkill smite
- [ ] randomkill switchable bomb, fire....
- [ ] warden: unwarden roundstart and delay old warden.
- [ ] warden: icon above head (material or model?)
- [x] warden: markers
- [ ] warden: killrandom - are you sure?
- [ ] zombie: knockbackfix
- [x] jihad: freeze by activate bool
- [x] new day: knife only (ice skate/third person?)
- [ ] new day: A day where you spawn with one single low random weapon and get 500 HP :D
- [ ] warden: improve markers (2 kind)  https://github.com/KissLick/TeamGames/blob/master/addons/sourcemod/scripting/Marks.sp
- [ ] warden: limits (max x.times in row)
- [x] warden: pick random if there is no warden
- [ ] make ShowOverlayFreeze/start/delete to once
- [x] valid client and co to inc
- [ ] playertags: add VIP flag
- [ ] playertags: define colorize chat tag
- [x] noscope: dis/enable lowgrav
- [x] noscope: set grav
- [ ] warden: talkpower per menu only some sec https://forums.alliedmods.net/showthread.php?t=257229
- [x] jihad: set radius
- [x] jihad: bool movement on bomb activate
- [x] countdown: start stop sound
- [x] countdown: stop roundend
- [x] countdown cancel all running
- [ ] countdown cancel in menu
- [x] countdown: set time - or menu with differnt times?!?!
- [ ] warden: mathboard
- [x] catch: enable/disbale sprint
- [x] warden: !w or random warden
- [ ] menu: noblock insert
- [ ] warden: color prisioners (color roulette)
- [x] weapons: open menu on spawn bool
- [ ] weapons: set menu delay
- [ ] weapons: set menu time
- [x] weapons: give warden ta&health bool
- [x] menu: set menu time
- [ ] menu: set menu delay
- [ ] weapons: menu spawn timing
- [ ] zombie: hp
- [ ] duckhunt: hunter hp
- [ ] duckhunt: chicken hp
- [x] zombie: atmo sounds <- start soudn ;)
- [x] zombie: define model
- [ ] war&ffa/all?: define how many rounds to play
- [ ] all days: set panel time/delay
- [ ] (all days: cfg to add sm_ for event start end)
- [ ] hide: MovementValue hider/seeker
- [ ] new day: Tron like - all player Molotov rain https://forums.alliedmods.net/showthread.php?p=2398902
- [ ] warden: bomb toss https://github.com/KissLick/TeamGames/blob/master/addons/sourcemod/scripting/modules/TG_BombToss.sp
- [ ] 

need?
- [ ] events on random days? no voting/set - core2
- [ ] silent mp_roundtime?
- [ ] jihad: burn dead bodies?
- [ ] jihad: body counter?
- [ ] warden: ff not for ct?
- [ ] SetCvarString flags?


future:
- [ ] rewrite/merge to one master plugin (e.g. hosties,ttt..)
- [ ] remove features they are still in TG by kisslick 


maybe:
- [ ] beacon for days
- [ ] warden: extend roundtime (possible)
- [ ] all days: admin force end days
- [ ] warden: color prisioners (& color roulette)
- [ ] all days: start instant not next round
- [ ] dice: verweigern 2x (native?)
- [ ] dice: freeze sound & overlay
- [ ] dice: healthshot
- [ ] dice: third person
- [ ] dice: switch wsad
- [ ] refuse: chickensound
- [ ] capitulate: punish if rebel again
- [ ] hide: include flashlight?
- [ ] new day: "rats" size player in cell
- [ ] new day: save the T vip
- [ ] 