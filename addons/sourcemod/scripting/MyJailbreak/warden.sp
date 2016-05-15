//Includes
#include <sourcemod>
#include <cstrike>
#include <warden>
#include <emitsoundany>
#include <smartjaildoors>
#include <colors>
#include <autoexecconfig>
#include <myjailbreak>
#include <scp>
#include <lastrequest>
#include <smlib>

//Compiler Options
#pragma semicolon 1
#pragma newdecls required

//Defines
#define SOUND_THUNDER "ambient/weather/thunder3.wav"
#define PLUS				"+"
#define MINUS				"-"
#define DIVISOR				"/"
#define MULTIPL				"*"
#define MAX_BUTTONS 25

//ConVars
ConVar gc_bOpenTimer;
ConVar gc_bOpenTimerWarden;
ConVar gc_bPlugin;
ConVar gc_bVote;
ConVar gc_bStayWarden;
ConVar gc_bNoBlock;
ConVar gc_bColor;
ConVar gc_bOpen;
ConVar gc_bBecomeWarden;
ConVar gc_bChooseRandom;
ConVar gc_bSounds;
ConVar gc_bFF;
ConVar gc_bGunPlant;
ConVar gc_bGunRemove;
ConVar gc_fGunRemoveTime;
ConVar gc_iGunSlapDamage;
ConVar gc_bGunSlap;
ConVar gc_bGunNoDrop;
ConVar gc_bRandom;
ConVar gc_iRandomKind;
ConVar gc_hOpenTimer;
ConVar gc_hRandomTimer;
ConVar gc_bMath;
ConVar gc_bMarker;
ConVar gc_bDrawer;
ConVar gc_bDrawerT;
ConVar gc_bLaser;
ConVar gc_bCountDown;
ConVar gc_bIcon;
ConVar gc_sIconPath;
ConVar gc_bOverlays;
ConVar gc_sOverlayStartPath;
ConVar gc_sOverlayStopPath;
ConVar gc_sWarden;
ConVar gc_sUnWarden;
ConVar gc_sSoundStartPath;
ConVar gc_sSoundStopPath;
ConVar gc_sModelPath;
ConVar gc_bModel;
ConVar gc_bBetterNotes;
ConVar gc_iMinimumNumber;
ConVar gc_iMaximumNumber;
ConVar gc_iTimeAnswer;
ConVar gc_iWardenColorRed;
ConVar gc_iWardenColorGreen;
ConVar gc_iWardenColorBlue;
ConVar g_bFF;
ConVar g_bMenuClose;

//Bools
bool IsCountDown = false;
bool IsMathQuiz = false;
bool g_bMarkerSetup;
bool g_bCanZoom[MAXPLAYERS + 1];
bool g_bHasSilencer[MAXPLAYERS + 1];
bool g_bLaserUse[MAXPLAYERS+1];
bool g_bDrawerUse[MAXPLAYERS+1] = {false, ...};
bool g_bLaser = true;
bool g_bDrawer[MAXPLAYERS+1] = false;
bool g_bDrawerT = false;
bool g_bNoBlock = true;
bool g_bLaserColorRainbow[MAXPLAYERS+1] = true;
bool g_bDrawerColorRainbow[MAXPLAYERS+1] = true;
bool g_bWeaponDropped = false;

//Integers

int g_iWarden = -1;
int g_iTempWarden[MAXPLAYERS+1] = -1;
int g_iVoteCount;
int g_iCollisionOffset;
int g_iOpenTimer;
int g_iRandomTime;
int g_iCountStartTime = 9;
int g_iCountStopTime = 9;
int g_iBeamSprite = -1;
int g_iHaloSprite = -1;
int g_iSetCountStartStopTime;
int g_iSmokeSprite;
int g_iKillKind;
int g_iMathMin;
int g_iMathMax;
int g_iMathResult;
int g_LastButtons[MAXPLAYERS+1];
int g_iWeaponDrop[MAXPLAYERS+1];
int g_iIcon[MAXPLAYERS + 1] = {-1, ...};
int g_iHaloSpritecolor[4] = {255,255,255,255};
int g_iColors[8][4] = 
{
	{255,255,255,255},  //white
	{255,0,0,255},  //red
	{20,255,20,255},  //green
	{0,65,255,255},  //blue
	{255,255,0,255},  //yellow
	{0,255,255,255},  //cyan
	{255,0,255,255},  //magenta
	{255,80,0,255}
};
int g_iLaserColor[MAXPLAYERS+1];
int g_iDrawerColor[MAXPLAYERS+1];

//Handles
Handle g_fward_onBecome;
Handle g_fward_onRemove;
Handle gF_OnWardenCreatedByUser = null;
Handle gF_OnWardenCreatedByAdmin = null;
Handle gF_OnWardenDisconnected = null;
Handle gF_OnWardenDeath = null;
Handle gF_OnWardenRemovedBySelf = null;
Handle gF_OnWardenRemovedByAdmin = null;
Handle OpenCounterTime = null;
Handle RandomTimer = null;
Handle MathTimer = null;
Handle StartTimer = null;
Handle StopTimer = null;
Handle StartStopTimer = null;
Handle IconTimer = null;

//Strings
char g_sHasVoted[1500];
char g_sModelPath[256];
char g_sWardenModel[256];
char g_sUnWarden[256];
char g_sWarden[256];
char g_sIconPath[256];
char g_sSoundStartPath[256];
char g_sSoundStopPath[256];
char g_sOverlayStopPath[256];
char g_sOp[32];
char g_sOperators[4][2] = {"+", "-", "/", "*"};
char g_sColorNamesRed[64];
char g_sColorNamesBlue[64];
char g_sColorNamesGreen[64];
char g_sColorNamesOrange[64];
char g_sColorNamesMagenta[64];
char g_sColorNamesRainbow[64];
char g_sColorNamesYellow[64];
char g_sColorNamesCyan[64];
char g_sColorNamesWhite[64];
char g_sColorNames[8][64] ={{""},{""},{""},{""},{""},{""},{""},{""}};

//float
float g_fMarkerRadiusMin = 100.0;
float g_fMarkerRadiusMax = 500.0;
float g_fMarkerRangeMax = 1500.0;
float g_fMarkerArrowHeight = 90.0;
float g_fMarkerArrowLength = 20.0;
float g_fMarkerSetupStartOrigin[3];
float g_fMarkerSetupEndOrigin[3];
float g_fMarkerOrigin[8][3];
float g_fMarkerRadius[8];
float g_fLastDrawer[MAXPLAYERS+1][3];

public Plugin myinfo = {
	name = "MyJailbreak - Warden",
	author = "shanapu, ecca, ESKO & .#zipcore",
	description = "Jailbreak Warden script",
	version = PLUGIN_VERSION,
	url = URL_LINK
};

public void OnPluginStart() 
{
	//Translation
	LoadTranslations("MyJailbreak.Warden.phrases");
	
	//Client commands

	RegConsoleCmd("sm_w", BecomeWarden, "Allows the player taking the charge over prisoners");
	RegConsoleCmd("sm_warden", BecomeWarden, "Allows the player taking the charge over prisoners");
	RegConsoleCmd("sm_uw", ExitWarden, "Allows the player to retire from the position");
	RegConsoleCmd("sm_unwarden", ExitWarden, "Allows the player to retire from the position");
	RegConsoleCmd("sm_hg", BecomeWarden, "Allows the player taking the charge over prisoners");
	RegConsoleCmd("sm_headguard", BecomeWarden, "Allows the player taking the charge over prisoners");
	RegConsoleCmd("sm_uhg", ExitWarden, "Allows the player to retire from the position");
	RegConsoleCmd("sm_unheadguard", ExitWarden, "Allows the player to retire from the position");
	RegConsoleCmd("sm_com", BecomeWarden, "Allows the player taking the charge over prisoners");
	RegConsoleCmd("sm_commander", BecomeWarden, "Allows the player taking the charge over prisoners");
	RegConsoleCmd("sm_uc", ExitWarden, "Allows the player to retire from the position");
	RegConsoleCmd("sm_uncommander", ExitWarden, "Allows the player to retire from the position");
	RegConsoleCmd("sm_open", OpenDoors, "Allows the Warden to open the cell doors");
	RegConsoleCmd("sm_close", CloseDoors, "Allows the Warden to close the cell doors");
	RegConsoleCmd("sm_vw", VoteWarden, "Allows the player to vote to retire Warden");
	RegConsoleCmd("sm_votewarden", VoteWarden, "Allows the player to vote to retire Warden");
	RegConsoleCmd("sm_setff", ToggleFF, "Allows player to see the state and the Warden to toggle friendly fire");
	RegConsoleCmd("sm_laser", LaserMenu, "Allows Warden to toggle on/off the wardens Laser pointer");
	RegConsoleCmd("sm_drawer", DrawerMenu, "Allows Warden to toggle on/off the wardens Drawer");
	RegConsoleCmd("sm_noblock", ToggleNoBlock, "Allows the Warden to toggle no block"); 
	RegConsoleCmd("sm_cdstart", SetStartCountDown, "Allows the Warden to start a START Countdown! (start after 10sec.) - start without menu");
	RegConsoleCmd("sm_cdmenu", CDMenu, "Allows the Warden to open the Countdown Menu");
	RegConsoleCmd("sm_cdstartstop", StartStopCDMenu, "Allows the Warden to start a START/STOP Countdown! (start after 10sec./stop after 20sec.) - start without menu");
	RegConsoleCmd("sm_cdstop", SetStopCountDown, "Allows the Warden to start a STOP Countdown! (stop after 20sec.) - start without menu");
	RegConsoleCmd("sm_cdcancel", CancelCountDown, "Allows the Warden to cancel a running Countdown");
	RegConsoleCmd("sm_killrandom", KillRandom, "Allows the Warden to kill a random T");
	RegConsoleCmd("sm_math", StartMathQuestion, "Allows the Warden to start a MathQuiz. Show player with first right Answer");
	
	//Admin commands
	RegAdminCmd("sm_sw", SetWarden, ADMFLAG_GENERIC);
	RegAdminCmd("sm_setwarden", SetWarden, ADMFLAG_GENERIC);
	RegAdminCmd("sm_rw", RemoveWarden, ADMFLAG_GENERIC);
	RegAdminCmd("sm_removewarden", RemoveWarden, ADMFLAG_GENERIC);
	
	//Forwards
	gF_OnWardenCreatedByUser = CreateGlobalForward("Warden_OnWardenCreatedByUser", ET_Ignore, Param_Cell);
	gF_OnWardenCreatedByAdmin = CreateGlobalForward("Warden_OnWardenCreatedByAdmin", ET_Ignore, Param_Cell);
	g_fward_onBecome = CreateGlobalForward("warden_OnWardenCreated", ET_Ignore, Param_Cell);
	gF_OnWardenDisconnected = CreateGlobalForward("Warden_OnWardenDisconnected", ET_Ignore, Param_Cell);
	gF_OnWardenDeath = CreateGlobalForward("Warden_OnWardenDeath", ET_Ignore, Param_Cell);
	gF_OnWardenRemovedBySelf = CreateGlobalForward("Warden_OnWardenRemovedBySelf", ET_Ignore, Param_Cell);
	gF_OnWardenRemovedByAdmin = CreateGlobalForward("Warden_OnWardenRemovedByAdmin", ET_Ignore, Param_Cell);
	g_fward_onRemove = CreateGlobalForward("warden_OnWardenRemoved", ET_Ignore, Param_Cell);
	
	//AutoExecConfig
	AutoExecConfig_SetFile("Warden", "MyJailbreak");
	AutoExecConfig_SetCreateFile(true);
	
	AutoExecConfig_CreateConVar("sm_warden_version", PLUGIN_VERSION, "The version of this MyJailbreak SourceMod plugin", FCVAR_SPONLY|FCVAR_PLUGIN|FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_DONTRECORD);
	gc_bPlugin = AutoExecConfig_CreateConVar("sm_warden_enable", "1", "0 - disabled, 1 - enable this MyJailbreak SourceMod plugin", _, true,  0.0, true, 1.0);
	gc_bBecomeWarden = AutoExecConfig_CreateConVar("sm_warden_become", "1", "0 - disabled, 1 - enable !w / !warden - player can choose to be warden. If disabled you should need sm_warden_choose_random 1", _, true,  0.0, true, 1.0);
	gc_bChooseRandom = AutoExecConfig_CreateConVar("sm_warden_choose_random", "1", "0 - disabled, 1 - enable pic random warden if there is still no warden after sm_warden_choose_time", _, true,  0.0, true, 1.0);
	gc_hRandomTimer = AutoExecConfig_CreateConVar("sm_warden_choose_time", "45", "Time in seconds a random warden will picked when no warden was set. need sm_warden_choose_random 1", _, true,  1.0);
	gc_bVote = AutoExecConfig_CreateConVar("sm_warden_vote", "1", "0 - disabled, 1 - enable player vote against warden", _, true,  0.0, true, 1.0);
	gc_bStayWarden = AutoExecConfig_CreateConVar("sm_warden_stay", "1", "0 - disabled, 1 - enable warden stay after round end", _, true,  0.0, true, 1.0);
	gc_bBetterNotes = AutoExecConfig_CreateConVar("sm_warden_better_notifications", "1", "0 - disabled, 1 - Will use hint and center text", _, true, 0.0, true, 1.0);
	gc_bNoBlock = AutoExecConfig_CreateConVar("sm_warden_noblock", "1", "0 - disabled, 1 - enable setable noblock for warden", _, true,  0.0, true, 1.0);
	gc_bFF = AutoExecConfig_CreateConVar("sm_warden_ff", "1", "0 - disabled, 1 - enable switch ff for T ", _, true,  0.0, true, 1.0);
	gc_bGunPlant = AutoExecConfig_CreateConVar("sm_warden_gunplant", "1", "0 - disabled, 1 - enable Gun plant prevention", _, true,  0.0, true, 1.0);
	gc_bGunNoDrop = AutoExecConfig_CreateConVar("sm_warden_gunnodrop", "0", "0 - disabled, 1 - disallow gun dropping for ct", _, true,  0.0, true, 1.0);
	gc_bGunRemove = AutoExecConfig_CreateConVar("sm_warden_gunremove", "1", "0 - disabled, 1 - remove planted guns", _, true,  0.0, true, 1.0);
	gc_fGunRemoveTime = AutoExecConfig_CreateConVar("sm_warden_gunremove_time", "5.0", "Time in seconds to pick up gun again before.", _, true,  0.1);
	gc_bGunSlap = AutoExecConfig_CreateConVar("sm_warden_gunslap", "1", "0 - disabled, 1 - Slap the CT for dropping a gun", _, true,  0.0, true, 1.0);
	gc_iGunSlapDamage = AutoExecConfig_CreateConVar("sm_warden_gunslap_dmg", "10", "Amoung of HP losing on slap for dropping a gun", _, true,  0.0);
	gc_bRandom = AutoExecConfig_CreateConVar("sm_warden_random", "1", "0 - disabled, 1 - enable kill a random t for warden", _, true,  0.0, true, 1.0);
	gc_iRandomKind = AutoExecConfig_CreateConVar("sm_warden_randomkill", "2", "1 - all random / 2 - Thunder / 3 - Timebomb / 4 - Firebomb / 5 - NoKill(1,3,4 needs funncommands.smx enabled)", _, true,  1.0, true, 4.0);
	gc_bCountDown = AutoExecConfig_CreateConVar("sm_warden_countdown", "1", "0 - disabled, 1 - enable countdown for warden", _, true,  0.0, true, 1.0);
	gc_bIcon = AutoExecConfig_CreateConVar("sm_warden_icon_enable", "1", "0 - disabled, 1 - enable the icon above the wardens head", _, true,  0.0, true, 1.0);
	gc_sIconPath = AutoExecConfig_CreateConVar("sm_warden_icon", "decals/MyJailbreak/warden" , "Path to the warden icon DONT TYPE .vmt or .vft");
	gc_bOverlays = AutoExecConfig_CreateConVar("sm_warden_overlays_enable", "1", "0 - disabled, 1 - enable overlays", _, true,  0.0, true, 1.0);
	gc_sOverlayStartPath = AutoExecConfig_CreateConVar("sm_warden_overlays_start", "overlays/MyJailbreak/start" , "Path to the start Overlay DONT TYPE .vmt or .vft");
	gc_sOverlayStopPath = AutoExecConfig_CreateConVar("sm_warden_overlays_stop", "overlays/MyJailbreak/stop" , "Path to the stop Overlay DONT TYPE .vmt or .vft");
	gc_bOpen = AutoExecConfig_CreateConVar("sm_warden_open_enable", "1", "0 - disabled, 1 - warden can open/close cells", _, true,  0.0, true, 1.0);
	gc_hOpenTimer = AutoExecConfig_CreateConVar("sm_warden_open_time", "60", "Time in seconds for open doors on round start automaticly", _, true, 0.0); 
	gc_bOpenTimer = AutoExecConfig_CreateConVar("sm_warden_open_time_enable", "1", "should doors open automatic 0- no 1 yes", _, true,  0.0, true, 1.0); //todo dont wokr
	gc_bOpenTimerWarden = AutoExecConfig_CreateConVar("sm_warden_open_time_warden", "1", "should doors open automatic after sm_warden_open_time when there is a warden? needs sm_warden_open_time_enable 1", _, true,  0.0, true, 1.0);
	gc_bMarker = AutoExecConfig_CreateConVar("sm_warden_marker", "1", "0 - disabled, 1 - enable Warden advanced markers ", _, true,  0.0, true, 1.0);
	gc_bLaser = AutoExecConfig_CreateConVar("sm_warden_laser", "1", "0 - disabled, 1 - enable Warden Laser Pointer with +E ", _, true,  0.0, true, 1.0);
	gc_bDrawer = AutoExecConfig_CreateConVar("sm_warden_drawer", "1", "0 - disabled, 1 - enable Warden Drawer with +E ", _, true,  0.0, true, 1.0);
	gc_bDrawerT= AutoExecConfig_CreateConVar("sm_warden_drawer_terror", "1", "0 - disabled, 1 - allow Warden to toggle Drawer for Terrorist ", _, true,  0.0, true, 1.0);
	gc_bMath = AutoExecConfig_CreateConVar("sm_warden_math", "1", "0 - disabled, 1 - enable mathquiz for warden", _, true,  0.0, true, 1.0);
	gc_iMinimumNumber = AutoExecConfig_CreateConVar("sm_warden_math_min", "1", "What should be the minimum number for questions?", _, true,  1.0);
	gc_iMaximumNumber = AutoExecConfig_CreateConVar("sm_warden_math_max", "100", "What should be the maximum number for questions?", _, true,  2.0);
	gc_iTimeAnswer = AutoExecConfig_CreateConVar("sm_warden_math_time", "10", "Time in seconds to give a answer to a question.", _, true,  3.0);
	gc_bModel = AutoExecConfig_CreateConVar("sm_warden_model", "1", "0 - disabled, 1 - enable warden model", 0, true, 0.0, true, 1.0);
	gc_sModelPath = AutoExecConfig_CreateConVar("sm_warden_model_path", "models/player/custom_player/legacy/security/security.mdl", "Path to the model for warden.");
	gc_bColor = AutoExecConfig_CreateConVar("sm_warden_color_enable", "1", "0 - disabled, 1 - enable warden colored", _, true,  0.0, true, 1.0);
	gc_iWardenColorRed = AutoExecConfig_CreateConVar("sm_warden_color_red", "0","What color to turn the warden into (set R, G and B values to 255 to disable) (Rgb): x - red value", _, true, 0.0, true, 255.0);
	gc_iWardenColorGreen = AutoExecConfig_CreateConVar("sm_warden_color_green", "0","What color to turn the warden into (rGb): x - green value", _, true, 0.0, true, 255.0);
	gc_iWardenColorBlue = AutoExecConfig_CreateConVar("sm_warden_color_blue", "255","What color to turn the warden into (rgB): x - blue value", _, true, 0.0, true, 255.0);
	gc_bSounds = AutoExecConfig_CreateConVar("sm_warden_sounds_enable", "1", "0 - disabled, 1 - enable sounds ", _, true,  0.0, true, 1.0);
	gc_sWarden = AutoExecConfig_CreateConVar("sm_warden_sounds_warden", "music/MyJailbreak/warden.mp3", "Path to the soundfile which should be played for a int warden.");
	gc_sUnWarden = AutoExecConfig_CreateConVar("sm_warden_sounds_unwarden", "music/MyJailbreak/unwarden.mp3", "Path to the soundfile which should be played when there is no warden anymore.");
	gc_sSoundStartPath = AutoExecConfig_CreateConVar("sm_warden_sounds_start", "music/MyJailbreak/start.mp3", "Path to the soundfile which should be played for a start countdown.");
	gc_sSoundStopPath = AutoExecConfig_CreateConVar("sm_warden_sounds_stop", "music/MyJailbreak/stop.mp3", "Path to the soundfile which should be played for stop countdown.");
	
	AutoExecConfig_ExecuteFile();
	AutoExecConfig_CleanFile();
	
	//Hooks
	HookEvent("item_equip", Event_ItemEquip);
	HookEvent("round_start", RoundStart);
	HookEvent("player_death", playerDeath);
	HookEvent("player_team", EventPlayerTeam);
	HookEvent("round_end", RoundEnd);
	HookConVarChange(gc_sModelPath, OnSettingChanged);
	HookConVarChange(gc_sUnWarden, OnSettingChanged);
	HookConVarChange(gc_sWarden, OnSettingChanged);
	HookConVarChange(gc_sSoundStartPath, OnSettingChanged);
	HookConVarChange(gc_sSoundStopPath, OnSettingChanged);
	HookConVarChange(gc_sOverlayStartPath, OnSettingChanged);
	HookConVarChange(gc_sOverlayStopPath, OnSettingChanged);
	HookConVarChange(gc_sIconPath, OnSettingChanged);
	
	//FindConVar
	g_bMenuClose = FindConVar("sm_menu_close");
	g_bFF = FindConVar("mp_teammates_are_enemies");
	gc_sWarden.GetString(g_sWarden, sizeof(g_sWarden));
	gc_sUnWarden.GetString(g_sUnWarden, sizeof(g_sUnWarden));
	gc_sSoundStartPath.GetString(g_sSoundStartPath, sizeof(g_sSoundStartPath));
	gc_sSoundStopPath.GetString(g_sSoundStopPath, sizeof(g_sSoundStopPath));
	gc_sModelPath.GetString(g_sWardenModel, sizeof(g_sWardenModel));
	gc_sOverlayStartPath.GetString(g_sOverlayStart , sizeof(g_sOverlayStart));
	gc_sOverlayStopPath.GetString(g_sOverlayStopPath , sizeof(g_sOverlayStopPath));
	gc_sIconPath.GetString(g_sIconPath , sizeof(g_sIconPath));
	
	g_iCollisionOffset = FindSendPropInfo("CBaseEntity", "m_CollisionGroup");
	
	g_iVoteCount = 0;
	
	CreateTimer(1.0, Timer_DrawMakers, _, TIMER_REPEAT);
	
}

//ConVar Change for Strings

public int OnSettingChanged(Handle convar, const char[] oldValue, const char[] newValue)
{
	if(convar == gc_sWarden)
	{
		strcopy(g_sWarden, sizeof(g_sWarden), newValue);
		if(gc_bSounds.BoolValue) PrecacheSoundAnyDownload(g_sWarden);
	}
	else if(convar == gc_sUnWarden)
	{
		strcopy(g_sUnWarden, sizeof(g_sUnWarden), newValue);
		if(gc_bSounds.BoolValue) PrecacheSoundAnyDownload(g_sUnWarden);
	}
	else if(convar == gc_sSoundStartPath)
	{
		strcopy(g_sSoundStartPath, sizeof(g_sSoundStartPath), newValue);
		if(gc_bSounds.BoolValue) PrecacheSoundAnyDownload(g_sSoundStartPath);
	}
	else if(convar == gc_sSoundStopPath)
	{
		strcopy(g_sSoundStopPath, sizeof(g_sSoundStopPath), newValue);
		if(gc_bSounds.BoolValue) PrecacheSoundAnyDownload(g_sSoundStopPath);
	}
	else if(convar == gc_sOverlayStartPath)
	{
		strcopy(g_sOverlayStart, sizeof(g_sOverlayStart), newValue);
		if(gc_bOverlays.BoolValue) PrecacheDecalAnyDownload(g_sOverlayStart);
	}
	else if(convar == gc_sOverlayStopPath)
	{
		strcopy(g_sOverlayStopPath, sizeof(g_sOverlayStopPath), newValue);
		if(gc_bOverlays.BoolValue) PrecacheDecalAnyDownload(g_sOverlayStopPath);
	}
	else if(convar == gc_sModelPath)
	{
		strcopy(g_sWardenModel, sizeof(g_sWardenModel), newValue);
		if(gc_bModel.BoolValue) PrecacheModel(g_sWardenModel);
	}
	else if(convar == gc_sIconPath)
	{
		strcopy(g_sIconPath, sizeof(g_sIconPath), newValue);
		if(gc_bIcon.BoolValue) PrecacheModelAnyDownload(g_sIconPath);
	}
}

//Initialize Plugin

public void OnConfigsExecuted()
{
	g_iMathMin = gc_iMinimumNumber.IntValue;
	g_iMathMax = gc_iMaximumNumber.IntValue;
	g_iKillKind = gc_iRandomKind.IntValue;
}

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	CreateNative("warden_exist", Native_ExistWarden);
	CreateNative("warden_iswarden", Native_IsWarden);
	CreateNative("warden_set", Native_SetWarden);
	CreateNative("warden_removed", Native_RemoveWarden);
	CreateNative("warden_get", Native_GetWarden);
	
	RegPluginLibrary("warden");
	return APLRes_Success;
}

public void OnMapStart()
{
	if(gc_bSounds.BoolValue)
	{
		PrecacheSoundAnyDownload(g_sWarden);
		PrecacheSoundAnyDownload(g_sUnWarden);
		PrecacheSoundAnyDownload(g_sSoundStopPath);
		PrecacheSoundAnyDownload(g_sSoundStartPath);
	}	
	g_iVoteCount = 0;
	PrecacheModel(g_sWardenModel);
	if(gc_bOverlays.BoolValue) PrecacheDecalAnyDownload(g_sOverlayStart);
	if(gc_bOverlays.BoolValue) PrecacheDecalAnyDownload(g_sOverlayStopPath);
	if(gc_bIcon.BoolValue) PrecacheModelAnyDownload(g_sIconPath);
	g_iBeamSprite = PrecacheModel("materials/sprites/laserbeam.vmt");
	g_iHaloSprite = PrecacheModel("materials/sprites/glow01.vmt");
	g_iSmokeSprite = PrecacheModel("materials/sprites/steam1.vmt");
	PrecacheSound(SOUND_THUNDER, true);
	RemoveAllMarkers();
	CreateTimer(0.1, Print_Drawer, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
	g_bLaser = true;
	for(int client=1; client <= MaxClients; client++) g_bDrawer[client] = false;
	g_bDrawerT = false;
}

//Round Start

public void RoundStart(Event event, const char[] name, bool dontBroadcast)
{
	if (OpenCounterTime != null)
		KillTimer(OpenCounterTime);
		
	OpenCounterTime = null;
	
	if (RandomTimer != null)
		KillTimer(RandomTimer);
			
	RandomTimer = null;
	
	if(gc_bModel.BoolValue)
	{
		for(int client=1; client <= MaxClients; client++) if(IsValidClient(client, true, true))
		{
			if (client == g_iWarden)
			{
				SetEntityModel(g_iWarden, g_sWardenModel);
			}
		}
	}
	
	if(gc_bPlugin.BoolValue)	
	{
		g_iOpenTimer = GetConVarInt(gc_hOpenTimer);
		OpenCounterTime = CreateTimer(1.0, OpenCounter, _, TIMER_REPEAT);
		g_iRandomTime = GetConVarInt(gc_hRandomTimer);
		RandomTimer = CreateTimer(1.0, ChooseRandom, _, TIMER_REPEAT);
		if ((g_iWarden == -1) && gc_bBecomeWarden.BoolValue)
		{
			CPrintToChatAll("%t %t", "warden_tag" , "warden_nowarden");
			if(gc_bBetterNotes.BoolValue)
			{
				PrintCenterTextAll("%t", "warden_nowarden_nc");
			}
		}
	}
	else
	{
		if (g_iWarden == 1)
		{
			CreateTimer(0.1, RemoveColor, g_iWarden);
			SetEntityModel(g_iWarden, g_sModelPath);
			Forward_OnWardenRemoved(g_iWarden);
			SafeDelete(g_iIcon[g_iWarden]);
			g_iIcon[g_iWarden] = -1;
			g_iWarden = -1;
			g_bLaser = false;
			for(int client=1; client <= MaxClients; client++) g_bDrawer[client] = false;
		}
	}
	char EventDay[64];
	GetEventDay(EventDay);
	
	if(!StrEqual(EventDay, "none", false) || !gc_bStayWarden.BoolValue)
	{
		if (g_iWarden == 1)
		{
			CreateTimer( 0.1, RemoveColor, g_iWarden);
			SetEntityModel(g_iWarden, g_sModelPath);
			Forward_OnWardenRemoved(g_iWarden);
			SafeDelete(g_iIcon[g_iWarden]);
			g_iIcon[g_iWarden] = -1;
			g_iWarden = -1;
			g_bLaser = false;
			for(int client=1; client <= MaxClients; client++) g_bDrawer[client] = false;
		}
	}
	if(gc_bStayWarden.BoolValue && warden_exist())
	{
		IconTimer = CreateTimer(0.5, Create_Icon, g_iWarden, TIMER_REPEAT);
	}
}

//Round End

public void RoundEnd(Event event, const char[] name, bool dontBroadcast)
{
	if(gc_bPlugin.BoolValue)
	{
		if (g_bFF.BoolValue) 
		{
			SetCvar("mp_teammates_are_enemies", 0);
			g_bFF = FindConVar("mp_teammates_are_enemies");
			CPrintToChatAll("%t %t", "warden_tag", "warden_ffisoff" );
		}
	}
	if(gc_bPlugin.BoolValue)
	{
		for(int client=1; client <= MaxClients; client++) if(IsValidClient(client, true, true))
		{
			CancelCountDown(client, 0);
		}
	}
	if (StopTimer != null) KillTimer(StopTimer);
	if (StartTimer != null) KillTimer(StartTimer);
	if (StartStopTimer != null) KillTimer(StartStopTimer);
	g_bDrawerT = false;
}

//!w

public Action BecomeWarden(int client, int args)
{
	if(gc_bPlugin.BoolValue)
	{
		if (g_iWarden == -1)
		{
			if (gc_bBecomeWarden.BoolValue)
			{
				if (GetClientTeam(client) == CS_TEAM_CT)
				{
					if (IsPlayerAlive(client))
					{
						SetTheWarden(client);
						Call_StartForward(gF_OnWardenCreatedByUser);
						Call_PushCell(client);
						Call_Finish();
					}
					else CPrintToChat(client, "%t %t", "warden_tag" , "warden_playerdead");
				}
				else CPrintToChat(client, "%t %t", "warden_tag" , "warden_ctsonly");
			}
			else CPrintToChat(client, "%t %t", "warden_tag" , "warden_nobecome", g_iWarden);
		}
		else CPrintToChat(client, "%t %t", "warden_tag" , "warden_exist", g_iWarden);
	}
	else CPrintToChat(client, "%t %t", "warden_tag" , "warden_disabled");
}

//!uw

public Action ExitWarden(int client, int args) 
{
	if(gc_bPlugin.BoolValue)
	{
		if(client == g_iWarden)
		{
			CPrintToChatAll("%t %t", "warden_tag" , "warden_retire", client);
			
			if(gc_bBetterNotes.BoolValue)
			{
				PrintCenterTextAll("%t", "warden_retire_nc", client);
			}
			Forward_OnWardenRemoved(client);
			CreateTimer( 0.1, RemoveColor, g_iWarden);
			SetEntityModel(client, g_sModelPath);
			g_iRandomTime = GetConVarInt(gc_hRandomTimer);
			RandomTimer = CreateTimer(1.0, ChooseRandom, _, TIMER_REPEAT);
			if(gc_bSounds.BoolValue) EmitSoundToAllAny(g_sUnWarden);
			RemoveAllMarkers();
			g_iVoteCount = 0;
			Format(g_sHasVoted, sizeof(g_sHasVoted), "");
			g_sHasVoted[0] = '\0';
			SafeDelete(g_iIcon[client]);
			g_iIcon[client] = -1;
			IconTimer = null;
			g_iWarden = -1;
			g_bDrawerT = false;
		}
		else CPrintToChat(client, "%t %t", "warden_tag" , "warden_notwarden");
	}
	else CPrintToChat(client, "%t %t", "warden_tag" , "warden_disabled");
}

//!vw

public Action VoteWarden(int client,int args)
{
	if(gc_bPlugin.BoolValue)
	{
		if(gc_bVote.BoolValue)
		{
			char steamid[64];
			GetClientAuthId(client, AuthId_Steam2, steamid, sizeof(steamid));
			if (warden_exist())
			{
				if (StrContains(g_sHasVoted, steamid, true) == -1)
				{
					int playercount = (GetClientCount(true) / 2);
					g_iVoteCount++;
					int Missing = playercount - g_iVoteCount + 1;
					Format(g_sHasVoted, sizeof(g_sHasVoted), "%s,%s", g_sHasVoted, steamid);
					
					if (g_iVoteCount > playercount)
					{
						LogMessage("[MyJB] Player %L was kick as warden by voting", g_iWarden);
						RemoveTheWarden(client);
					}
					else CPrintToChatAll("%t %t", "warden_tag" , "warden_need", Missing, client);
				}
				else CPrintToChat(client, "%t %t", "warden_tag" , "warden_voted");
			}
			else CPrintToChat(client, "%t %t", "warden_tag" , "warden_noexist");
		}
		else CPrintToChat(client, "%t %t", "warden_tag" , "warden_voting");
	}
	else CPrintToChat(client, "%t %t", "warden_tag" , "warden_disabled");
}

//Warden died

public Action playerDeath(Event event, const char[] name, bool dontBroadcast) 
{
	int client = GetClientOfUserId(GetEventInt(event, "userid")); // Get the dead clients id
	
	if(client == g_iWarden) // Aww damn , he is the warden
	{
		CPrintToChatAll("%t %t", "warden_tag" , "warden_dead", client);
		
		if(gc_bBetterNotes.BoolValue)
		{
			PrintCenterTextAll("%t", "warden_dead_nc", client);
		}
		if(gc_bSounds.BoolValue)
		{
			EmitSoundToAllAny(g_sUnWarden);
		}
		g_iRandomTime = GetConVarInt(gc_hRandomTimer);
		RandomTimer = CreateTimer(1.0, ChooseRandom, _, TIMER_REPEAT);
		Call_StartForward(gF_OnWardenDeath);
		Call_PushCell(client);
		Call_Finish();
		SafeDelete(g_iIcon[client]);
		g_iIcon[client] = -1;
		delete IconTimer;
		g_iWarden = -1;
	}
	g_fLastDrawer[client][0] = 0.0;
	g_fLastDrawer[client][1] = 0.0;
	g_fLastDrawer[client][2] = 0.0;
	g_bDrawerUse[client] = false;
}

//Set new Warden for Admin Menu

public Action SetWarden(int client,int args)
{
	if(gc_bPlugin.BoolValue)	
	{
		if(IsValidClient(client, false, false))
		{
			char info1[255];
			Menu menu = CreateMenu(SetWardenHandler);
			Format(info1, sizeof(info1), "%T", "warden_choose", client);
			menu.SetTitle(info1);
			for(int i = 1;i <= MaxClients;i++) if(IsValidClient(i, true))
			{
				if(GetClientTeam(i) == CS_TEAM_CT && IsClientWarden(i) == false)
				{
					char userid[11];
					char username[MAX_NAME_LENGTH];
					IntToString(GetClientUserId(i), userid, sizeof(userid));
					Format(username, sizeof(username), "%N", i);
					menu.AddItem(userid,username);
				}
			}
			menu.ExitBackButton = true;
			menu.ExitButton = true;
			menu.Display(client,MENU_TIME_FOREVER);
		}
	}
	return Plugin_Handled;
}

//Overwrite new Warden for Admin Menu

public int SetWardenHandler(Menu menu, MenuAction action, int client, int Position)
{
	if(action == MenuAction_Select)
	{
		char Item[11];
		menu.GetItem(Position,Item,sizeof(Item));
		
		for(int i = 1;i <= MaxClients;i++) if(IsValidClient(i, true))
		{
			if(GetClientTeam(i) == CS_TEAM_CT && IsClientWarden(i) == false)
			{
				char info4[255], info2[255], info3[255];
				int userid = GetClientUserId(i);
				if(userid == StringToInt(Item))
				{
					if(IsWarden() == true)
					{
						g_iTempWarden[client] = userid;
						Menu menu1 = CreateMenu(m_WardenOverwrite);
						Format(info4, sizeof(info4), "%T", "warden_remove", client);
						menu1.SetTitle(info4);
						Format(info3, sizeof(info3), "%T", "warden_yes", client);
						Format(info2, sizeof(info2), "%T", "warden_no", client);
						menu1.AddItem("1", info3);
						menu1.AddItem("0", info2);
						menu1.ExitBackButton = true;
						menu1.ExitButton = true;
						menu1.Display(client,MENU_TIME_FOREVER);
					}
					else
					{
						g_iWarden = i;
						CPrintToChatAll("%t %t", "warden_tag" , "warden_new", i);
						
						if(gc_bBetterNotes.BoolValue)
						{
							PrintCenterTextAll("%t", "warden_new_nc", i);
						}
						if(gc_bSounds.BoolValue)
						{
							EmitSoundToAllAny(g_sWarden);
						}
						CreateTimer(0.5, Timer_WardenFixColor, i, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
						IconTimer = CreateTimer(0.5, Create_Icon, client, TIMER_REPEAT);
						GetEntPropString(client, Prop_Data, "m_ModelName", g_sModelPath, sizeof(g_sModelPath));
						if(gc_bModel.BoolValue)
						{
							SetEntityModel(client, g_sWardenModel);
						}
						Call_StartForward(gF_OnWardenCreatedByAdmin);
						Call_PushCell(i);
						Call_Finish();
					}
				}
			}
		}
	}
	else if(action == MenuAction_Cancel)
	{
		if(Position == MenuCancel_ExitBack) 
		{
			FakeClientCommand(client, "sm_menu");
		}
	}
	else if(action == MenuAction_End)
	{
		delete menu;
	}
}

//Set/Overwrite new Warden for Admin Handler

public int m_WardenOverwrite(Menu menu, MenuAction action, int client, int Position)
{
	if(action == MenuAction_Select)
	{
		char Item[11];
		menu.GetItem(Position,Item,sizeof(Item));
		int choice = StringToInt(Item);
		if(choice == 1)
		{
			int newwarden = GetClientOfUserId(g_iTempWarden[client]);
			CPrintToChatAll("%t %t", "warden_tag" , "warden_removed", client, g_iWarden);
			CPrintToChatAll("%t %t", "warden_tag" , "warden_new", newwarden);
			if(gc_bSounds.BoolValue)
			{
				EmitSoundToAllAny(g_sWarden);
			}
			if(gc_bBetterNotes.BoolValue)
			{
				PrintCenterTextAll("%t", "warden_new_nc", newwarden);
			}
			LogMessage("[MyJB] Admin %L kick player %N warden and set &N as new", client, g_iWarden, newwarden);
			g_iWarden = newwarden;
			CreateTimer(0.5, Timer_WardenFixColor, newwarden, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
			IconTimer = CreateTimer(0.5, Create_Icon, newwarden, TIMER_REPEAT);
			GetEntPropString(newwarden, Prop_Data, "m_ModelName", g_sModelPath, sizeof(g_sModelPath));
			if(gc_bModel.BoolValue)
			{
				SetEntityModel(client, g_sWardenModel);
			}
			Call_StartForward(gF_OnWardenCreatedByAdmin);
			Call_PushCell(newwarden);
			Call_Finish();
		}
		if(g_bMenuClose != null)
		{
			if(!g_bMenuClose)
			{
				FakeClientCommand(client, "sm_menu");
			}
		}
	}
	else if(action == MenuAction_Cancel)
	{
		if(Position == MenuCancel_ExitBack) 
		{
			FakeClientCommand(client, "sm_menu");
		}
	}
	else if(action == MenuAction_End)
	{
		delete menu;
	}
}

//Give Warden color

public Action Timer_WardenFixColor(Handle timer,any client)
{
	if(IsValidClient(client, false, false))
	{
		if(IsClientWarden(client))
		{
			if(gc_bPlugin.BoolValue)
			{ 
				if(gc_bColor.BoolValue)
				{
					SetEntityRenderColor(client, gc_iWardenColorRed.IntValue, gc_iWardenColorGreen.IntValue, gc_iWardenColorBlue.IntValue, 255);
				}
			}
		}
		else
		{
			SetEntityRenderColor(client);
			return Plugin_Stop;
		}
	}
	else
	{
		return Plugin_Stop;
	}
	return Plugin_Continue;
}

//Warden change Team

public Action PlayerTeam(Handle event, const char[] name, bool dontBroadcast) 
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	g_fLastDrawer[client][0] = 0.0;
	g_fLastDrawer[client][1] = 0.0;
	g_fLastDrawer[client][2] = 0.0;
	g_bDrawerUse[client] = false;
	g_bDrawer[client] = false;
	if(client == g_iWarden)
		RemoveTheWarden(client);
}

//Warden disconnect

public void OnClientDisconnect(int client)
{
	if(client == g_iWarden)
	{
		CPrintToChatAll("%t %t", "warden_tag" , "warden_disconnected");
		
		if(gc_bBetterNotes.BoolValue)
		{
			PrintCenterTextAll("%t", "warden_disconnected_nc", client);
		}
		Forward_OnWardenRemoved(client);
		Call_StartForward(gF_OnWardenDisconnected);
		Call_PushCell(client);
		Call_Finish();
		if(gc_bSounds.BoolValue)
		{
			EmitSoundToAllAny(g_sUnWarden);
		}
		RemoveAllMarkers();
		g_iWarden = -1;
		g_bDrawerT = false;
	}
	g_LastButtons[client] = 0;
}

//warden change team

public Action EventPlayerTeam(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	if(client == g_iWarden)
	{	
		CPrintToChatAll("%t %t", "warden_tag" , "warden_retire");
		
		if(gc_bBetterNotes.BoolValue)
		{
			PrintCenterTextAll("%t", "warden_retire_nc", client);
		}
		g_iWarden = -1;
		Forward_OnWardenRemoved(client);
		Call_StartForward(gF_OnWardenDisconnected);
		Call_PushCell(client);
		Call_Finish();
		if(gc_bSounds.BoolValue)
		{
			EmitSoundToAllAny(g_sUnWarden);
		}
		RemoveAllMarkers();
		g_bDrawerT = false;
	}
	g_LastButtons[client] = 0;
}

//Set a new warden

void SetTheWarden(int client)
{
	if(gc_bPlugin.BoolValue)
	{
		CPrintToChatAll("%t %t", "warden_tag" , "warden_new", client);
		
		if(gc_bBetterNotes.BoolValue)
		{
			PrintCenterTextAll("%t", "warden_new_nc", client);
		}
		g_iWarden = client;
		CreateTimer(0.5, Timer_WardenFixColor, client, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
		IconTimer = CreateTimer(0.5, Create_Icon, client, TIMER_REPEAT);
		GetEntPropString(client, Prop_Data, "m_ModelName", g_sModelPath, sizeof(g_sModelPath));
		if(gc_bModel.BoolValue)
		{
			SetEntityModel(client, g_sWardenModel);
		}
		SetClientListeningFlags(client, VOICE_NORMAL);
		Forward_OnWardenCreation(client);
		if(gc_bSounds.BoolValue)
		{
			EmitSoundToAllAny(g_sWarden);
		}
		RemoveAllMarkers();
	}
	else CPrintToChat(client, "%t %t", "warden_tag" , "warden_disabled");
}

//Remove player Warden

public Action RemoveWarden(int client, int args)
{
	if(g_iWarden != -1)
	{
		RemoveTheWarden(client);
		Call_StartForward(gF_OnWardenRemovedByAdmin);
		Call_PushCell(client);
		Call_Finish();
		
	}
//	else CPrintToChatAll("%t %t", "warden_tag" , "warden_noexist");
	return Plugin_Handled;
}

void RemoveTheWarden(int client)
{
	CPrintToChatAll("%t %t", "warden_tag" , "warden_removed", client, g_iWarden);  // if client is console !=
	
	if(gc_bBetterNotes.BoolValue)
	{
		PrintCenterTextAll("%t", "warden_removed_nc", client, g_iWarden);
	}
	LogMessage("[MyJB] Admin %L removed player %N as warden", client, g_iWarden);
	CreateTimer( 0.1, RemoveColor, g_iWarden);
	SetEntityModel(client, g_sModelPath);
	g_iRandomTime = GetConVarInt(gc_hRandomTimer);
	RandomTimer = CreateTimer(1.0, ChooseRandom, _, TIMER_REPEAT);
	Call_StartForward(gF_OnWardenRemovedBySelf);
	Call_PushCell(g_iWarden);
	Call_Finish();
	Forward_OnWardenRemoved(g_iWarden);
	if(gc_bSounds.BoolValue)
	{
		EmitSoundToAllAny(g_sUnWarden);
	}
	RemoveAllMarkers();
	g_bDrawerT = false;
	g_iVoteCount = 0;
	Format(g_sHasVoted, sizeof(g_sHasVoted), "");
	g_sHasVoted[0] = '\0';
	SafeDelete(g_iIcon[g_iWarden]);
	g_iIcon[g_iWarden] = -1;
	delete IconTimer;
	g_iWarden = -1;
}

//Math Quizz

public Action EndMathQuestion(Handle timer)
{
	SendEndMathQuestion(-1);
}

public Action StartMathQuestion(int client, int args)
{
	if(gc_bMath.BoolValue)
	{
		if(client == g_iWarden)
		{
			if (!IsMathQuiz)
			{
				CreateTimer( 4.0, CreateMathQuestion, client);
							
				CPrintToChatAll("%t %t", "warden_tag" , "warden_startmathquiz");
		
				if(gc_bBetterNotes.BoolValue)
				{
					PrintCenterTextAll("%t", "warden_startmathquiz_nc");
				}
						
				IsMathQuiz = true;
			}
		}
		else CPrintToChat(client, "%t %t", "warden_tag" , "warden_notwarden");
	}
}

public Action CreateMathQuestion( Handle timer, any client )
{
	if(gc_bMath.BoolValue)	
	{
		if(client == g_iWarden)
		{
			int NumOne = GetRandomInt(g_iMathMin, g_iMathMax);
			int NumTwo = GetRandomInt(g_iMathMin, g_iMathMax);
			
			Format(g_sOp, sizeof(g_sOp), g_sOperators[GetRandomInt(0,3)]);
			
			if(StrEqual(g_sOp, PLUS))
			{
				g_iMathResult = NumOne + NumTwo;
			}
			else if(StrEqual(g_sOp, MINUS))
			{
				g_iMathResult = NumOne - NumTwo;
			}
			else if(StrEqual(g_sOp, DIVISOR))
			{
				do
				{
					NumOne = GetRandomInt(g_iMathMin, g_iMathMax);
					NumTwo = GetRandomInt(g_iMathMin, g_iMathMax);
				}
				while(NumOne % NumTwo != 0);
				g_iMathResult = NumOne / NumTwo;
			}
			else if(StrEqual(g_sOp, MULTIPL))
			{
				g_iMathResult = NumOne * NumTwo;
			}
			
			
			CPrintToChatAll("%t %N: %i %s %i = ?? ", "warden_tag", client, NumOne, g_sOp, NumTwo);
		
			if(gc_bBetterNotes.BoolValue)
			{
				PrintHintTextToAll("%i %s %i = ?? ", NumOne, g_sOp, NumTwo);
			}
			
			
			MathTimer = CreateTimer(gc_iTimeAnswer.FloatValue, EndMathQuestion);
		}
		else CPrintToChat(client, "%t %t", "warden_tag" , "warden_notwarden");
	}
}

public Action OnChatMessage(int &author, Handle recipients, char[] name, char[] message)
{
	if(IsMathQuiz)
	{
		char bit[1][5];
		ExplodeString(message, " ", bit, sizeof bit, sizeof bit[]);

		if(ProcessSolution(author, StringToInt(bit[0])))
			SendEndMathQuestion(author);
	}
}

public bool ProcessSolution(int client, int number)
{
	if(g_iMathResult == number)
	{		
		return true;
	}
	else
	{
		return false;
	}
}

public void SendEndMathQuestion(int client)
{
	if(MathTimer != INVALID_HANDLE)
	{
		KillTimer(MathTimer);
		MathTimer = INVALID_HANDLE;
	}
	
	char answer[100];
	
	if(client != -1)
	{
		Format(answer, sizeof(answer), "%t %t", "warden_tag", "warden_math_correct", client);
		CreateTimer( 5.0, RemoveColor, client);
		SetEntityRenderColor(client, 0, 255, 0, 255);
	}
	else Format(answer, sizeof(answer), "%t %t", "warden_tag", "warden_math_time");
	
	if(gc_bOverlays.BoolValue)
	{
		CreateTimer( 0.5, ShowOverlayStop, client);
	}
	if(gc_bSounds.BoolValue)	
	{
		EmitSoundToAllAny(g_sSoundStopPath);
	}
	Handle pack = CreateDataPack();
	CreateDataTimer(0.3, AnswerQuestion, pack);
	WritePackString(pack, answer);
	
	IsMathQuiz = false;
}

public Action RemoveColor( Handle timer, any client ) 
{
	if(IsValidClient(client, false, true))
	{
		SetEntityRenderColor(client, 255, 255, 255, 255);
	}
}

public Action AnswerQuestion(Handle timer, Handle pack)
{
	char str[100];
	ResetPack(pack);
	ReadPackString(pack, str, sizeof(str));
	CPrintToChatAll(str);
}

//New Marker thanks zipcore!

public Action Event_ItemEquip(Handle event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	g_bCanZoom[client] = GetEventBool(event, "canzoom");
	g_bHasSilencer[client] = GetEventBool(event, "hassilencer");
}

public void OnMapEnd()
{
	RemoveAllMarkers();
	g_bDrawerT = false;
	delete IconTimer;
	if (g_iWarden != -1)
	{
		CreateTimer(0.1, RemoveColor, g_iWarden);
		Forward_OnWardenRemoved(g_iWarden);
		SafeDelete(g_iIcon[g_iWarden]);
		g_iIcon[g_iWarden] = -1;
		g_iWarden = -1;
	}
	g_bLaser = false;
	for(int client=1; client <= MaxClients; client++) 
	{
	g_fLastDrawer[client][0] = 0.0;
	g_fLastDrawer[client][1] = 0.0;
	g_fLastDrawer[client][2] = 0.0;
	g_bDrawerUse[client] = false;
	g_bDrawer[client] = false;
	}
}

public Action Timer_DrawMakers(Handle timer, any data)
{
	Draw_Markers();
	return Plugin_Continue;
}

stock void Draw_Markers()
{
	if (g_iWarden == -1)
		return;
	
	for(int i = 0; i<8; i++)
	{
		if (g_fMarkerRadius[i] <= 0.0)
			continue;
		
		float fWardenOrigin[3];
		Entity_GetAbsOrigin(g_iWarden, fWardenOrigin);
		
		if (GetVectorDistance(fWardenOrigin, g_fMarkerOrigin[i]) > g_fMarkerRangeMax)
		{
			CPrintToChat(g_iWarden, "%t %t", "warden_tag", "warden_marker_faraway", g_sColorNames[i]);
			RemoveMarker(i);
			continue;
		}
		
		for(int client=1;client<=MaxClients;client++)
		{
			if(!IsClientInGame(client))
				continue;
			
			if (IsFakeClient(client))
				continue;
			
			if(!IsPlayerAlive(client))
				continue;
			
			// Show the ring
			
			TE_SetupBeamRingPoint(g_fMarkerOrigin[i], g_fMarkerRadius[i], g_fMarkerRadius[i]+0.1, g_iBeamSprite, g_iHaloSprite, 0, 10, 1.0, 2.0, 0.0, g_iColors[i], 10, 0);
			TE_SendToAll();
			
			// Show the arrow
			
			float fStart[3];
			AddVectors(fStart, g_fMarkerOrigin[i], fStart);
			fStart[2] += g_fMarkerArrowHeight;
			
			float fEnd[3];
			AddVectors(fEnd, fStart, fEnd);
			fEnd[2] += g_fMarkerArrowLength;
			
			TE_SetupBeamPoints(fStart, fEnd, g_iBeamSprite, g_iHaloSprite, 0, 10, 1.0, 2.0, 16.0, 1, 0.0, g_iColors[i], 5);
			TE_SendToAll();
		}
	}
}

stock void MarkerMenu(int client)
{
	for(int iClient=1; iClient <= MaxClients; iClient++)
	{
		//Prepare translation for marker colors
		Format(g_sColorNamesRed, sizeof(g_sColorNamesRed), "{darkred}%T{default}", "warden_red", iClient);
		Format(g_sColorNamesBlue, sizeof(g_sColorNamesBlue), "{blue}%T{default}", "warden_blue", iClient);
		Format(g_sColorNamesGreen, sizeof(g_sColorNamesGreen), "{green}%T{default}", "warden_green", iClient);
		Format(g_sColorNamesOrange, sizeof(g_sColorNamesOrange), "{lightred}%T{default}", "warden_orange", iClient);
		Format(g_sColorNamesMagenta, sizeof(g_sColorNamesMagenta), "{purple}%T{default}", "warden_magenta", iClient);
		Format(g_sColorNamesYellow, sizeof(g_sColorNamesYellow), "{orange}%T{default}", "warden_yellow", iClient);
		Format(g_sColorNamesWhite, sizeof(g_sColorNamesWhite), "{default}%T{default}", "warden_white", iClient);
		Format(g_sColorNamesCyan, sizeof(g_sColorNamesCyan), "{blue}%T{default}", "warden_cyan", iClient);
		Format(g_sColorNamesRainbow, sizeof(g_sColorNamesRainbow), "{lightgreen}%T{default}", "warden_rainbow", iClient);
		
		g_sColorNames[0] = g_sColorNamesWhite;
		g_sColorNames[1] = g_sColorNamesRed;
		g_sColorNames[3] = g_sColorNamesBlue;
		g_sColorNames[2] = g_sColorNamesGreen;
		g_sColorNames[7] = g_sColorNamesOrange;
		g_sColorNames[6] = g_sColorNamesMagenta;
		g_sColorNames[4] = g_sColorNamesYellow;
		g_sColorNames[5] = g_sColorNamesCyan;
	}
	
	if(!(0 < client < MaxClients) || client != g_iWarden)
	{
		CPrintToChat(client, "%t %t", "warden_tag", "warden_notwarden");
		return;
	}
	
	int marker = IsMarkerInRange(g_fMarkerSetupStartOrigin);
	if (marker != -1)
	{
		RemoveMarker(marker);
		CPrintToChatAll("%t %t", "warden_tag", "warden_marker_remove", g_sColorNames[marker]);
		return;
	}
	
	float radius = 2*GetVectorDistance(g_fMarkerSetupEndOrigin, g_fMarkerSetupStartOrigin);
	if (radius <= 0.0)
	{
		RemoveMarker(marker);
		CPrintToChat(client, "%t %t", "warden_tag", "warden_wrong");
		return;
	}
	
	float pos[3];
	Entity_GetAbsOrigin(g_iWarden, pos);
	
	float range = GetVectorDistance(pos, g_fMarkerSetupStartOrigin);
	if (range > g_fMarkerRangeMax)
	{
		CPrintToChat(client, "%t %t", "warden_tag", "warden_range");
		return;
	}
	
	if (0 < client < MaxClients)
	{
		Handle menu = CreateMenu(Handle_MarkerMenu);
		
		char menuinfo1[255],menuinfo2[255],menuinfo3[255],menuinfo4[255],menuinfo5[255],menuinfo6[255],menuinfo7[255],menuinfo8[255],menuinfo9[255];
		Format(menuinfo1, sizeof(menuinfo1), "%T", "warden_marker_title", client);
		Format(menuinfo2, sizeof(menuinfo2), "%T", "warden_red", client);
		Format(menuinfo3, sizeof(menuinfo3), "%T", "warden_blue", client);
		Format(menuinfo4, sizeof(menuinfo4), "%T", "warden_green", client);
		Format(menuinfo5, sizeof(menuinfo5), "%T", "warden_orange", client);
		Format(menuinfo6, sizeof(menuinfo6), "%T", "warden_white", client);
		Format(menuinfo7, sizeof(menuinfo7), "%T", "warden_cyan", client);
		Format(menuinfo8, sizeof(menuinfo8), "%T", "warden_magenta", client);
		Format(menuinfo9, sizeof(menuinfo9), "%T", "warden_yellow", client);
		
		SetMenuTitle(menu, menuinfo1);
		
		AddMenuItem(menu, "1", menuinfo2);
		AddMenuItem(menu, "3", menuinfo3);
		AddMenuItem(menu, "2", menuinfo4);
		AddMenuItem(menu, "7", menuinfo5);
		AddMenuItem(menu, "0", menuinfo6);
		AddMenuItem(menu, "5", menuinfo7);
		AddMenuItem(menu, "6", menuinfo8);
		AddMenuItem(menu, "4", menuinfo9);
		
		DisplayMenu(menu, client, 20);
	}
}

public int Handle_MarkerMenu(Handle menu, MenuAction action, int client, int itemNum)
{
	if(!(0 < client < MaxClients))
		return;
	
	if(!IsValidClient(client, false, false))
		return;
	
	if (client != g_iWarden)
	{
		CPrintToChat(client, "%t %t", "warden_tag", "warden_notwarden");
		return;
	}
	
	if (action == MenuAction_Select)
	{
		char info[32]; char info2[32];
		bool found = GetMenuItem(menu, itemNum, info, sizeof(info), _, info2, sizeof(info2));
		int marker = StringToInt(info);
		
		if (found)
		{
			SetupMarker(client, marker);
			CPrintToChatAll("%t %t", "warden_tag", "warden_marker_set", g_sColorNames[marker]);
		}
	}
}

stock void SetupMarker(int client, int marker)
{
	g_fMarkerOrigin[marker][0] = g_fMarkerSetupStartOrigin[0];
	g_fMarkerOrigin[marker][1] = g_fMarkerSetupStartOrigin[1];
	g_fMarkerOrigin[marker][2] = g_fMarkerSetupStartOrigin[2];
	
	float radius = 2*GetVectorDistance(g_fMarkerSetupEndOrigin, g_fMarkerSetupStartOrigin);
	if (radius > g_fMarkerRadiusMax)
		radius = g_fMarkerRadiusMax;
	else if (radius < g_fMarkerRadiusMin)
		radius = g_fMarkerRadiusMin;
	g_fMarkerRadius[marker] = radius;
}

stock int GetClientAimTargetPos(int client, float pos[3]) 
{
	if (client < 1) 
		return -1;
	
	float vAngles[3]; float vOrigin[3];
	
	GetClientEyePosition(client,vOrigin);
	GetClientEyeAngles(client, vAngles);
	
	Handle trace = TR_TraceRayFilterEx(vOrigin, vAngles, MASK_SHOT, RayType_Infinite, TraceFilterAllEntities, client);
	
	TR_GetEndPosition(pos, trace);
	pos[2] += 5.0;
	
	int entity = TR_GetEntityIndex(trace);
	
	CloseHandle(trace);
	
	return entity;
}

stock void RemoveMarker(int marker)
{
	if(marker != -1)
	{
		g_fMarkerRadius[marker] = 0.0;
	}
}

stock void RemoveAllMarkers()
{
	for(int i = 0; i < 8;i++)
		RemoveMarker(i);
}

stock int IsMarkerInRange(float pos[3])
{
	for(int i = 0; i < 8;i++)
	{
		if (g_fMarkerRadius[i] <= 0.0)
			continue;
		
		if (GetVectorDistance(g_fMarkerOrigin[i], pos) < g_fMarkerRadius[i])
			return i;
	}
	return -1;
}

public bool TraceFilterAllEntities(int entity, int contentsMask, any client)
{
	if (entity == client)
		return false;
	if (entity > MaxClients)
		return false;
	if(!IsClientInGame(entity))
		return false;
	if(!IsPlayerAlive(entity))
		return false;
	
	return true;
}

// check keyboard input -> marker & lasers

public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon)
{
	if (client == g_iWarden)
	{
		if (buttons & IN_ATTACK2)
		{
			if (gc_bMarker.BoolValue && !g_bCanZoom[client] && !g_bHasSilencer[client])
			{
				if(!g_bMarkerSetup)
					GetClientAimTargetPos(client, g_fMarkerSetupStartOrigin);
				
				GetClientAimTargetPos(client, g_fMarkerSetupEndOrigin);
				
				float radius = 2*GetVectorDistance(g_fMarkerSetupEndOrigin, g_fMarkerSetupStartOrigin);
				
				if (radius > g_fMarkerRadiusMax)
					radius = g_fMarkerRadiusMax;
				else if (radius < g_fMarkerRadiusMin)
					radius = g_fMarkerRadiusMin;
				
				if (radius > 0)
				{
					TE_SetupBeamRingPoint(g_fMarkerSetupStartOrigin, radius, radius+0.1, g_iBeamSprite, g_iHaloSprite, 0, 10, 0.1, 2.0, 0.0, {255,255,255,255}, 10, 0);
					TE_SendToClient(client);
				}
				
				g_bMarkerSetup = true;
			}
		}
		else if (g_bMarkerSetup)
		{
			MarkerMenu(client);
			g_bMarkerSetup = false;
		}
		if((buttons & IN_USE))
		{
			if (gc_bLaser.BoolValue)
			{
				if (g_bLaser)
				{
					g_bLaserUse[client] = true;
					if(IsClientInGame(client) && g_bLaserUse[client])
					{
						float m_fOrigin[3], m_fImpact[3];
						
						if(g_bLaserColorRainbow[client]) g_iLaserColor[client] = GetRandomInt(0,6);
						
						GetClientEyePosition(client, m_fOrigin);
						GetClientSightEnd(client, m_fImpact);
						TE_SetupBeamPoints(m_fOrigin, m_fImpact, g_iBeamSprite, 0, 0, 0, 0.1, 0.12, 0.0, 1, 0.0, g_iColors[g_iLaserColor[client]], 0);
						TE_SendToAll();
						TE_SetupGlowSprite(m_fImpact, g_iHaloSprite, 0.1, 0.25, g_iHaloSpritecolor[3]);
						TE_SendToAll();
					}
				}
			}
		}
		else if(!(buttons & IN_USE))
		{
			g_bLaserUse[client] = false;
		}
	}
	if (((client == g_iWarden) && gc_bDrawer.BoolValue && g_bDrawer[client]) || ((GetClientTeam(client) == CS_TEAM_T) && gc_bDrawer.BoolValue && g_bDrawerT))
	{
		for (int i = 0; i < MAX_BUTTONS; i++)
		{
			int button = (1 << i);
			
			if ((buttons & button))
			{
				if (!(g_LastButtons[client] & button))
				{
					OnButtonPress(client, button);
				}
			}
			else if ((g_LastButtons[client] & button))
			{
				OnButtonRelease(client, button);
			}
		}
		g_LastButtons[client] = buttons;
	}
	return Plugin_Continue;
}

public Action LaserMenu(int client, int args)
{
	if(gc_bLaser.BoolValue)
	{
		if (client == g_iWarden)
		{
			char menuinfo5[255], menuinfo6[255], menuinfo7[255], menuinfo8[255], menuinfo9[255], menuinfo10[255], menuinfo11[255], menuinfo12[255], menuinfo13[255], menuinfo14[255], menuinfo15[255];
			Format(menuinfo5, sizeof(menuinfo5), "%T", "warden_laser_title", client);
			Format(menuinfo6, sizeof(menuinfo6), "%T", "warden_laser_off", client);
			Format(menuinfo7, sizeof(menuinfo7), "%T", "warden_rainbow", client);
			Format(menuinfo8, sizeof(menuinfo8), "%T", "warden_white", client);
			Format(menuinfo9, sizeof(menuinfo9), "%T", "warden_red", client);
			Format(menuinfo10, sizeof(menuinfo10), "%T", "warden_green", client);
			Format(menuinfo11, sizeof(menuinfo11), "%T", "warden_blue", client);
			Format(menuinfo12, sizeof(menuinfo12), "%T", "warden_yellow", client);
			Format(menuinfo13, sizeof(menuinfo13), "%T", "warden_cyan", client);
			Format(menuinfo14, sizeof(menuinfo14), "%T", "warden_magenta", client);
			Format(menuinfo15, sizeof(menuinfo15), "%T", "warden_orange", client);
			
			Menu menu = new Menu(LaserHandler);
			menu.SetTitle(menuinfo5);
			menu.AddItem("off", menuinfo6);
			menu.AddItem("rainbow", menuinfo7);
			menu.AddItem("white", menuinfo8);
			menu.AddItem("red", menuinfo9);
			menu.AddItem("green", menuinfo10);
			menu.AddItem("blue", menuinfo11);
			menu.AddItem("yellow", menuinfo12);
			menu.AddItem("cyan", menuinfo13);
			menu.AddItem("magenta", menuinfo14);
			menu.AddItem("orange", menuinfo15);
			
			menu.ExitBackButton = true;
			menu.ExitButton = true;
			menu.Display(client, 20);
		}
		else CPrintToChat(client, "%t %t", "warden_tag", "warden_notwarden" );
	}
	return Plugin_Handled;
}

public int LaserHandler(Menu menu, MenuAction action, int client, int selection)
{
if (action == MenuAction_Select)
	{
		char info[32];
		menu.GetItem(selection, info, sizeof(info));
		
		if ( strcmp(info,"off") == 0 ) 
		{
			g_bLaser = false;
			CPrintToChat(client, "%t %t", "warden_tag", "warden_laseroff");
		}
		else if ( strcmp(info,"rainbow") == 0 ) 
		{
			if(!g_bLaser) CPrintToChat(client, "%t %t", "warden_tag", "warden_laseron");
			CPrintToChat(client, "%t %t", "warden_tag", "warden_laser", g_sColorNamesRainbow);
			g_bLaser = true;
			g_bLaserColorRainbow[client] = true;
		}
		else if ( strcmp(info,"white") == 0 ) 
		{
			if(!g_bLaser) CPrintToChat(client, "%t %t", "warden_tag", "warden_laseron");
			CPrintToChat(client, "%t %t", "warden_tag", "warden_laser", g_sColorNamesWhite);
			g_bLaser = true;
			g_bLaserColorRainbow[client] = false;
			g_iLaserColor[client] = 0;
			
		}
		else if ( strcmp(info,"red") == 0 ) 
		{
			if(!g_bLaser) CPrintToChat(client, "%t %t", "warden_tag", "warden_laseron");
			CPrintToChat(client, "%t %t", "warden_tag", "warden_laser", g_sColorNamesRed);
			g_bLaser = true;
			g_bLaserColorRainbow[client] = false;
			g_iLaserColor[client] = 1;
			
		}
		else if ( strcmp(info,"green") == 0 ) 
		{
			if(!g_bLaser) CPrintToChat(client, "%t %t", "warden_tag", "warden_laseron");
			CPrintToChat(client, "%t %t", "warden_tag", "warden_laser", g_sColorNamesGreen);
			g_bLaser = true;
			g_bLaserColorRainbow[client] = false;
			g_iLaserColor[client] = 2;
			
		}
		else if ( strcmp(info,"blue") == 0 ) 
		{
			if(!g_bLaser) CPrintToChat(client, "%t %t", "warden_tag", "warden_laseron");
			CPrintToChat(client, "%t %t", "warden_tag", "warden_laser", g_sColorNamesBlue);
			g_bLaser = true;
			g_bLaserColorRainbow[client] = false;
			g_iLaserColor[client] = 3;
			
		}
		else if ( strcmp(info,"yellow") == 0 ) 
		{
			if(!g_bLaser) CPrintToChat(client, "%t %t", "warden_tag", "warden_laseron");
			CPrintToChat(client, "%t %t", "warden_tag", "warden_laser", g_sColorNamesYellow);
			g_bLaser = true;
			g_bLaserColorRainbow[client] = false;
			g_iLaserColor[client] = 4;
			
		}
		else if ( strcmp(info,"cyan") == 0 ) 
		{
			if(!g_bLaser) CPrintToChat(client, "%t %t", "warden_tag", "warden_laseron");
			CPrintToChat(client, "%t %t", "warden_tag", "warden_laser", g_sColorNamesCyan);
			g_bLaser = true;
			g_bLaserColorRainbow[client] = false;
			g_iLaserColor[client] = 5;
			
		}
		else if ( strcmp(info,"magenta") == 0 ) 
		{
			if(!g_bLaser) CPrintToChat(client, "%t %t", "warden_tag", "warden_laseron");
			CPrintToChat(client, "%t %t", "warden_tag", "warden_laser", g_sColorNamesMagenta);
			g_bLaser = true;
			g_bLaserColorRainbow[client] = false;
			g_iLaserColor[client] = 6;
			
		}
		else if ( strcmp(info,"orange") == 0 ) 
		{
			if(!g_bLaser) CPrintToChat(client, "%t %t", "warden_tag", "warden_laseron");
			CPrintToChat(client, "%t %t", "warden_tag", "warden_laser", g_sColorNamesOrange);
			g_bLaser = true;
			g_bLaserColorRainbow[client] = false;
			g_iLaserColor[client] = 7;
			
		}
		if(g_bMenuClose != null)
		{
			if(!g_bMenuClose)
			{
				FakeClientCommand(client, "sm_menu");
			}
		}
	}
	else if(action == MenuAction_Cancel)
	{
		if(selection == MenuCancel_ExitBack) 
		{
			FakeClientCommand(client, "sm_menu");
		}
	}
	else if(action == MenuAction_End)
	{
		delete menu;
	}
}

public Action DrawerMenu(int client, int args)
{
	if(gc_bDrawer.BoolValue)
	{
		if ((client == g_iWarden) || ((GetClientTeam(client) == CS_TEAM_T) && gc_bDrawer.BoolValue && g_bDrawerT))
		{
			char menuinfo5[255], menuinfo6[255], menuinfo7[255], menuinfo8[255], menuinfo9[255], menuinfo10[255], menuinfo11[255], menuinfo12[255], menuinfo13[255], menuinfo14[255], menuinfo15[255], menuinfo16[255];
			Format(menuinfo5, sizeof(menuinfo5), "%T", "warden_drawer_title", client);
			Format(menuinfo15, sizeof(menuinfo15), "%T", "warden_drawert", client);
			Format(menuinfo6, sizeof(menuinfo6), "%T", "warden_drawer_off", client);
			Format(menuinfo7, sizeof(menuinfo7), "%T", "warden_rainbow", client);
			Format(menuinfo8, sizeof(menuinfo8), "%T", "warden_white", client);
			Format(menuinfo9, sizeof(menuinfo9), "%T", "warden_red", client);
			Format(menuinfo10, sizeof(menuinfo10), "%T", "warden_green", client);
			Format(menuinfo11, sizeof(menuinfo11), "%T", "warden_blue", client);
			Format(menuinfo12, sizeof(menuinfo12), "%T", "warden_yellow", client);
			Format(menuinfo13, sizeof(menuinfo13), "%T", "warden_cyan", client);
			Format(menuinfo14, sizeof(menuinfo14), "%T", "warden_magenta", client);
			Format(menuinfo16, sizeof(menuinfo16), "%T", "warden_orange", client);
			
			Menu menu = new Menu(DrawerHandler);
			menu.SetTitle(menuinfo5);
			menu.AddItem("off", menuinfo6);
			if (GetClientTeam(client) == CS_TEAM_CT) menu.AddItem("terror", menuinfo15);
			menu.AddItem("rainbow", menuinfo7);
			menu.AddItem("white", menuinfo8);
			menu.AddItem("red", menuinfo9);
			menu.AddItem("green", menuinfo10);
			menu.AddItem("blue", menuinfo11);
			menu.AddItem("yellow", menuinfo12);
			menu.AddItem("cyan", menuinfo13);
			menu.AddItem("magenta", menuinfo14);
			menu.AddItem("orange", menuinfo16);
			
			menu.ExitBackButton = true;
			menu.ExitButton = true;
			menu.Display(client, 20);
		}
	}
	return Plugin_Handled;
}

public int DrawerHandler(Menu menu, MenuAction action, int client, int selection)
{
if (action == MenuAction_Select)
	{
		char info[32];
		menu.GetItem(selection, info, sizeof(info));
		
		if ( strcmp(info,"off") == 0 ) 
		{
			g_bDrawer[client] = false;
			CPrintToChat(client, "%t %t", "warden_tag", "warden_draweroff");
		}
		else if ( strcmp(info,"terror") == 0 ) 
		{
			ToggleDrawerT(client,0);
		}
		else if ( strcmp(info,"rainbow") == 0 ) 
		{
			if(!g_bDrawer[client]) CPrintToChat(client, "%t %t", "warden_tag", "warden_draweron");
			CPrintToChat(client, "%t %t", "warden_tag", "warden_drawer", g_sColorNamesRainbow);
			g_bDrawer[client] = true;
			g_bDrawerColorRainbow[client] = true;
			
		}
		else if ( strcmp(info,"white") == 0 ) 
		{
			if(!g_bDrawer[client]) CPrintToChat(client, "%t %t", "warden_tag", "warden_draweron");
			CPrintToChat(client, "%t %t", "warden_tag", "warden_drawer", g_sColorNamesWhite);
			g_bDrawer[client] = true;
			g_bDrawerColorRainbow[client] = false;
			g_iDrawerColor[client] = 0;
			
		}
		else if ( strcmp(info,"red") == 0 ) 
		{
			if(!g_bDrawer[client]) CPrintToChat(client, "%t %t", "warden_tag", "warden_draweron");
			CPrintToChat(client, "%t %t", "warden_tag", "warden_drawer", g_sColorNamesRed);
			g_bDrawer[client] = true;
			g_bDrawerColorRainbow[client] = false;
			g_iDrawerColor[client] = 1;
			
		}
		else if ( strcmp(info,"green") == 0 ) 
		{
			if(!g_bDrawer[client]) CPrintToChat(client, "%t %t", "warden_tag", "warden_draweron");
			CPrintToChat(client, "%t %t", "warden_tag", "warden_drawer", g_sColorNamesGreen);
			g_bDrawer[client] = true;
			g_bDrawerColorRainbow[client] = false;
			g_iDrawerColor[client] = 2;
			
		}
		else if ( strcmp(info,"blue") == 0 ) 
		{
			if(!g_bDrawer[client]) CPrintToChat(client, "%t %t", "warden_tag", "warden_draweron");
			CPrintToChat(client, "%t %t", "warden_tag", "warden_drawer", g_sColorNamesBlue);
			g_bDrawer[client] = true;
			g_bDrawerColorRainbow[client] = false;
			g_iDrawerColor[client] = 3;
			
		}
		else if ( strcmp(info,"yellow") == 0 ) 
		{
			if(!g_bDrawer[client]) CPrintToChat(client, "%t %t", "warden_tag", "warden_draweron");
			CPrintToChat(client, "%t %t", "warden_tag", "warden_drawer", g_sColorNamesYellow);
			g_bDrawer[client] = true;
			g_bDrawerColorRainbow[client] = false;
			g_iDrawerColor[client] = 4;
			
		}
		else if ( strcmp(info,"cyan") == 0 ) 
		{
			if(!g_bDrawer[client]) CPrintToChat(client, "%t %t", "warden_tag", "warden_draweron");
			CPrintToChat(client, "%t %t", "warden_tag", "warden_drawer", g_sColorNamesCyan);
			g_bDrawer[client] = true;
			g_bDrawerColorRainbow[client] = false;
			g_iDrawerColor[client] = 5;
			
		}
		else if ( strcmp(info,"magenta") == 0 ) 
		{
			if(!g_bDrawer[client]) CPrintToChat(client, "%t %t", "warden_tag", "warden_draweron");
			CPrintToChat(client, "%t %t", "warden_tag", "warden_drawer", g_sColorNamesMagenta);
			g_bDrawer[client] = true;
			g_bDrawerColorRainbow[client] = false;
			g_iDrawerColor[client] = 6;
			
		}
		else if ( strcmp(info,"orange") == 0 ) 
		{
			if(!g_bDrawer[client]) CPrintToChat(client, "%t %t", "warden_tag", "warden_draweron");
			CPrintToChat(client, "%t %t", "warden_tag", "warden_drawer", g_sColorNamesOrange);
			g_bDrawer[client] = true;
			g_bDrawerColorRainbow[client] = false;
			g_iDrawerColor[client] = 7;
			
		}
	}
	else if(action == MenuAction_Cancel)
	{
		if(selection == MenuCancel_ExitBack) 
		{
			FakeClientCommand(client, "sm_menu");
		}
	}
	else if(action == MenuAction_End)
	{
		delete menu;
	}
}

//Lasers

public void OnClientPutInServer(int client)
{
	g_bLaserUse[client] = false;
	g_bDrawerUse[client] = false;
	g_bDrawerColorRainbow[client] = true;
	g_bLaserColorRainbow[client] = true;
	g_fLastDrawer[client][0] = 0.0;
	g_fLastDrawer[client][1] = 0.0;
	g_fLastDrawer[client][2] = 0.0;
}

//Laser Pointer

stock void GetClientSightEnd(int client, float out[3])
{
	float m_fEyes[3];
	float m_fAngles[3];
	GetClientEyePosition(client, m_fEyes);
	GetClientEyeAngles(client, m_fAngles);
	TR_TraceRayFilter(m_fEyes, m_fAngles, MASK_PLAYERSOLID, RayType_Infinite, TraceRayDontHitPlayers);
	if(TR_DidHit())
		TR_GetEndPosition(out);
}

public bool TraceRayDontHitPlayers(int entity,int mask, any data)
{
	if(0 < entity <= MaxClients)
		return false;
	return true;
}

//Laser drawer

public Action ToggleDrawerT(int client, int args)
{
	if (gc_bDrawerT.BoolValue) 
	{
		if (client == g_iWarden)
		{
			if (!g_bDrawerT) 
			{
				g_bDrawerT = true;
				CPrintToChatAll("%t %t", "warden_tag", "warden_tdraweron");
				
				for(int iClient=1; iClient <= MaxClients; iClient++)
				{
					if (IsValidClient(iClient, false, false))
					{
						if (GetClientTeam(iClient) == CS_TEAM_T) DrawerMenu(iClient,0);
					}
				}
			}
			else
			{
				for(int iClient=1; iClient <= MaxClients; iClient++)
				{
					if (IsValidClient(iClient, false, false))
					{
						if (GetClientTeam(iClient) == CS_TEAM_T)
						{
							g_fLastDrawer[iClient][0] = 0.0;
							g_fLastDrawer[iClient][1] = 0.0;
							g_fLastDrawer[iClient][2] = 0.0;
							g_bDrawerUse[iClient] = false;
						}
					}
				}
				g_bDrawerT = false;
				CPrintToChatAll("%t %t", "warden_tag", "warden_tdraweroff");
			}
		}
	}
}

public Action Print_Drawer(Handle timer)
{
	float pos[3];

	for(int Y = 1; Y <= MaxClients; Y++) 
	{
		if(g_bDrawerColorRainbow[Y]) g_iDrawerColor[Y] = GetRandomInt(0,6);
		if(IsClientInGame(Y) && g_bDrawerUse[Y])
		{
			TraceEye(Y, pos);
			if(GetVectorDistance(pos, g_fLastDrawer[Y]) > 6.0) {
				Connect_Drawer(g_fLastDrawer[Y], pos, g_iColors[g_iDrawerColor[Y]]);
				g_fLastDrawer[Y][0] = pos[0];
				g_fLastDrawer[Y][1] = pos[1];
				g_fLastDrawer[Y][2] = pos[2];
			}
		} 
	}
}
stock void OnButtonPress(int client,int button)
{
	if(button == IN_USE)
	{
		TraceEye(client, g_fLastDrawer[client]);
		g_bDrawerUse[client] = true;
	}
}

stock void OnButtonRelease(int client,int button)
{
	if(button == IN_USE)
	{
		g_fLastDrawer[client][0] = 0.0;
		g_fLastDrawer[client][1] = 0.0;
		g_fLastDrawer[client][2] = 0.0;
		g_bDrawerUse[client] = false;
	}
}
public Action Connect_Drawer(float start[3], float end[3],int color[4])
{
	TE_SetupBeamPoints(start, end, g_iBeamSprite, 0, 0, 0, 25.0, 2.0, 2.0, 10, 0.0, color, 0);
	TE_SendToAll();
}
public Action TraceEye(int client, float pos[3]) 
{
	float vAngles[3], vOrigin[3];
	GetClientEyePosition(client, vOrigin);
	GetClientEyeAngles(client, vAngles);
	TR_TraceRayFilter(vOrigin, vAngles, MASK_SHOT, RayType_Infinite, TraceEntityFilterPlayer);
	if(TR_DidHit(INVALID_HANDLE)) TR_GetEndPosition(pos, INVALID_HANDLE);
	return;
}
public bool TraceEntityFilterPlayer(int entity, int contentsMask) {
	return (entity > GetMaxClients() || !entity);
}

//Icon

public Action Create_Icon(Handle iTimer, any client)
{
	if(g_iWarden != -1)
	{
		SafeDelete(g_iIcon[client]);
		g_iIcon[client] = CreateIcon();
		PlaceAndBindIcon(client, g_iIcon[client]);
	}
}

stock int CreateIcon()
{
	int sprite = CreateEntityByName("env_sprite_oriented");
	
	if(sprite == -1)	return -1;
	
	char iconbuffer[256];
	Format(iconbuffer, sizeof(iconbuffer), "materials/%s.vmt", g_sIconPath);
	
	DispatchKeyValue(sprite, "classname", "env_sprite_oriented");
	DispatchKeyValue(sprite, "spawnflags", "1");
	DispatchKeyValue(sprite, "scale", "0.3");
	DispatchKeyValue(sprite, "rendermode", "1");
	DispatchKeyValue(sprite, "rendercolor", "255 255 255");
	DispatchKeyValue(sprite, "model", iconbuffer);
	if(DispatchSpawn(sprite))	return sprite;
	
	return -1;
}

public Action PlaceAndBindIcon(int client, int entity)
{
	float origin[3];
	if(IsClientInGame(client)) 
	{
		if(IsValidEntity(entity)) 
		{
			GetClientAbsOrigin(client, origin);
			origin[2] = origin[2] + 90.0;
			TeleportEntity(entity, origin, NULL_VECTOR, NULL_VECTOR);

			SetVariantString("!activator");
			AcceptEntityInput(entity, "SetParent", client);
		}
	}
}

public Action SafeDelete(int entity)
{
	if(IsValidEntity(entity)) {
		AcceptEntityInput(entity, "Kill");
	}
}

//Countdown

public Action CDMenu(int client, int args)
{
	if(gc_bCountDown.BoolValue)
	{
		if (client == g_iWarden)
		{
			char menuinfo1[255], menuinfo2[255], menuinfo3[255], menuinfo4[255];
			Format(menuinfo1, sizeof(menuinfo1), "%T", "warden_cdmenu_title", client);
			Format(menuinfo2, sizeof(menuinfo2), "%T", "warden_cdmenu_start", client);
			Format(menuinfo3, sizeof(menuinfo3), "%T", "warden_cdmenu_stop", client);
			Format(menuinfo4, sizeof(menuinfo4), "%T", "warden_cdmenu_startstop", client);
			
			Menu menu = new Menu(CDHandler);
			menu.SetTitle(menuinfo1);
			menu.AddItem("start", menuinfo2);
			menu.AddItem("stop", menuinfo3);
			menu.AddItem("startstop", menuinfo4);
			menu.ExitButton = true;
			menu.ExitBackButton = true;
			menu.Display(client, 20);
		}
		else CPrintToChat(client, "%t %t", "warden_tag", "warden_notwarden" );
	}
	return Plugin_Handled;
}

public int CDHandler(Menu menu, MenuAction action, int client, int selection)
{
	if (action == MenuAction_Select)
	{
		char info[32];
		menu.GetItem(selection, info, sizeof(info));
		
		if ( strcmp(info,"start") == 0 ) 
		{
			FakeClientCommand(client, "sm_cdstart");
			
			if(g_bMenuClose != null)
			{
				if(!g_bMenuClose)
				{
					FakeClientCommand(client, "sm_menu");
				}
			}
		}
		else if ( strcmp(info,"stop") == 0 ) 
		{
			FakeClientCommand(client, "sm_cdstop");
			
			if(g_bMenuClose != null)
			{
				if(!g_bMenuClose)
				{
					FakeClientCommand(client, "sm_menu");
				}
			}
		}
		else if ( strcmp(info,"startstop") == 0 ) 
		{
		FakeClientCommand(client, "sm_cdstartstop");
		}
	}
	else if(selection == MenuCancel_ExitBack) 
	{
		FakeClientCommand(client, "sm_menu");
	}
	else if (action == MenuAction_End)
	{
		delete menu;
	}
}

public Action CancelCountDown(int client, int args)
{
	if (IsCountDown)
	{
		g_iCountStopTime = -1;
		g_iCountStartTime = -1;
		StartTimer = null;
		StartStopTimer = null;
		StopTimer = null;
		IsCountDown = false;
		CPrintToChatAll("%t %t", "warden_tag", "warden_countdowncanceled" );
	}
}

public Action StartStopCDMenu(int client, int args)
{
	if(gc_bCountDown.BoolValue)
	{
		if (client == g_iWarden)
		{
			char menuinfo5[255], menuinfo6[255], menuinfo7[255], menuinfo8[255], menuinfo9[255], menuinfo10[255], menuinfo11[255], menuinfo12[255], menuinfo13[255];
			Format(menuinfo5, sizeof(menuinfo5), "%T", "warden_cdmenu_Title2", client);
			Format(menuinfo6, sizeof(menuinfo6), "%T", "warden_15", client);
			Format(menuinfo7, sizeof(menuinfo7), "%T", "warden_30", client);
			Format(menuinfo8, sizeof(menuinfo8), "%T", "warden_45", client);
			Format(menuinfo9, sizeof(menuinfo9), "%T", "warden_60", client);
			Format(menuinfo10, sizeof(menuinfo10), "%T", "warden_90", client);
			Format(menuinfo11, sizeof(menuinfo11), "%T", "warden_120", client);
			Format(menuinfo12, sizeof(menuinfo12), "%T", "warden_180", client);
			Format(menuinfo13, sizeof(menuinfo13), "%T", "warden_300", client);
			
			Menu menu = new Menu(StartStopCDHandler);
			menu.SetTitle(menuinfo5);
			menu.AddItem("15", menuinfo6);
			menu.AddItem("30", menuinfo7);
			menu.AddItem("45", menuinfo8);
			menu.AddItem("60", menuinfo9);
			menu.AddItem("90", menuinfo10);
			menu.AddItem("120", menuinfo11);
			menu.AddItem("180", menuinfo12);
			menu.AddItem("300", menuinfo13);
			
			menu.ExitBackButton = true;
			menu.ExitButton = true;
			menu.Display(client, 20);
		}
		else CPrintToChat(client, "%t %t", "warden_tag", "warden_notwarden" );
	}
	return Plugin_Handled;
}

public int StartStopCDHandler(Menu menu, MenuAction action, int client, int selection)
{
	if (action == MenuAction_Select)
	{
		char info[32];
		menu.GetItem(selection, info, sizeof(info));
		
		if ( strcmp(info,"15") == 0 ) 
		{
			g_iSetCountStartStopTime = 25;
			SetStartStopCountDown(client, 0);
		}
		else if ( strcmp(info,"30") == 0 ) 
		{
			g_iSetCountStartStopTime = 40;
			SetStartStopCountDown(client, 0);
		}
		else if ( strcmp(info,"45") == 0 ) 
		{
			g_iSetCountStartStopTime = 55;
			SetStartStopCountDown(client, 0);
		}
		else if ( strcmp(info,"60") == 0 ) 
		{
			g_iSetCountStartStopTime = 70;
			SetStartStopCountDown(client, 0);
		}
		else if ( strcmp(info,"90") == 0 ) 
		{
			g_iSetCountStartStopTime = 100;
			SetStartStopCountDown(client, 0);
		}
		else if ( strcmp(info,"120") == 0 ) 
		{
			g_iSetCountStartStopTime = 130;
			SetStartStopCountDown(client, 0);
		}
		else if ( strcmp(info,"180") == 0 ) 
		{
			g_iSetCountStartStopTime = 190;
			SetStartStopCountDown(client, 0);
		}
		else if ( strcmp(info,"300") == 0 ) 
		{
			g_iSetCountStartStopTime = 310;
			SetStartStopCountDown(client, 0);
		}
		if(g_bMenuClose != null)
		{
			if(!g_bMenuClose)
			{
				FakeClientCommand(client, "sm_menu");
			}
		}
	}
	else if(action == MenuAction_Cancel)
	{
		if(selection == MenuCancel_ExitBack) 
		{
			FakeClientCommand(client, "sm_cdmenu");
		}
	}
	else if(action == MenuAction_End)
	{
		delete menu;
	}
}

public Action SetStartCountDown(int client, int args)
{
	if(gc_bCountDown.BoolValue)
	{
		if (client == g_iWarden)
		{
			if (!IsCountDown)
			{
				g_iCountStopTime = 9;
				StartTimer = CreateTimer( 1.0, StartCountdown, client, TIMER_REPEAT);
				
				CPrintToChatAll("%t %t", "warden_tag" , "warden_startcountdownhint");
		
				if(gc_bBetterNotes.BoolValue)
				{
					PrintHintTextToAll("%t", "warden_startcountdownhint_nc");
				}
	
			
				IsCountDown = true;
			}
			else CPrintToChat(client, "%t %t", "warden_tag" , "warden_countdownrunning");
		}
		else CPrintToChat(client, "%t %t", "warden_tag" , "warden_notwarden");
	}
}

public Action SetStopCountDown(int client, int args)
{
	if(gc_bCountDown.BoolValue)
	{
		if (client == g_iWarden)
		{
			if (!IsCountDown)
			{
				g_iCountStopTime = 20;
				StopTimer = CreateTimer( 1.0, StopCountdown, client, TIMER_REPEAT);
				
				
				CPrintToChatAll("%t %t", "warden_tag" , "warden_stopcountdownhint");
		
				if(gc_bBetterNotes.BoolValue)
				{
					PrintHintTextToAll("%t", "warden_stopcountdownhint_nc");
				}
												
				IsCountDown = true;
			}
			else CPrintToChat(client, "%t %t", "warden_tag" , "warden_countdownrunning");
		}
		else CPrintToChat(client, "%t %t", "warden_tag" , "warden_notwarden");
	}
}

public Action SetStartStopCountDown(int client, int args)
{
	if(gc_bCountDown.BoolValue)
	{
		if (client == g_iWarden)
		{
			if (!IsCountDown)
			{
				g_iCountStartTime = 9;
				StartTimer = CreateTimer( 1.0, StartCountdown, client, TIMER_REPEAT);
				StartStopTimer = CreateTimer( 1.0, StopStartStopCountdown, client, TIMER_REPEAT);
				
				CPrintToChatAll("%t %t", "warden_tag" , "warden_startstopcountdownhint");
				
				if(gc_bBetterNotes.BoolValue)
				{
					PrintHintTextToAll("%t", "warden_startstopcountdownhint_nc");
				}
				IsCountDown = true;
			}
			else CPrintToChat(client, "%t %t", "warden_tag" , "warden_countdownrunning");
		}
		else CPrintToChat(client, "%t %t", "warden_tag" , "warden_notwarden");
	}
}

public Action StartCountdown( Handle timer, any client ) 
{
	if (g_iCountStartTime > 0)
	{
		if (IsClientInGame(client) && IsPlayerAlive(client))
		{
			if (g_iCountStartTime < 6) 
			{
				PrintHintText(client,"%t", "warden_startcountdown_nc", g_iCountStartTime);
				CPrintToChatAll("%t %t", "warden_tag" , "warden_startcountdown", g_iCountStartTime);
			}
		}
		g_iCountStartTime--;
		return Plugin_Continue;
	}
	if (g_iCountStartTime == 0)
	{
		if(IsClientInGame(client) && IsClientConnected(client) && !IsFakeClient(client))
		{
			PrintHintText(client, "%t", "warden_countdownstart_nc");
			CPrintToChatAll("%t %t", "warden_tag" , "warden_countdownstart");
			
			if(gc_bOverlays.BoolValue)
			{
				CreateTimer( 0.0, ShowOverlayStart, client);
			}
			if(gc_bSounds.BoolValue)	
			{
				EmitSoundToAllAny(g_sSoundStartPath);
			}
			StartTimer = null;
			IsCountDown = false;
			g_iCountStopTime = 20;
			g_iCountStartTime = 9;
			return Plugin_Stop;
		}
	}
	return Plugin_Continue;
}

public Action StopCountdown( Handle timer, any client ) 
{
	if (g_iCountStopTime > 0)
	{
		if (IsClientInGame(client) && IsPlayerAlive(client))
		{
			if (g_iCountStopTime < 16) 
			{
				PrintHintText(client,"%t", "warden_stopcountdown_nc", g_iCountStopTime);
				CPrintToChatAll("%t %t", "warden_tag" , "warden_stopcountdown", g_iCountStopTime);
			}
		}
		g_iCountStopTime--;
		return Plugin_Continue;
	}
	if (g_iCountStopTime == 0)
	{
		if(IsClientInGame(client) && IsClientConnected(client) && !IsFakeClient(client))
		{
			PrintHintText(client, "%t", "warden_countdownstop_nc");
			CPrintToChatAll("%t %t", "warden_tag" , "warden_countdownstop");

			if(gc_bOverlays.BoolValue)
			{
				CreateTimer( 0.0, ShowOverlayStop, client);
			}
			if(gc_bSounds.BoolValue)	
			{
				EmitSoundToAllAny(g_sSoundStopPath);
			}
			StopTimer = null;
			IsCountDown = false;
			g_iCountStopTime = 20;
			g_iCountStartTime = 9;
			return Plugin_Stop;
		}
	}
	return Plugin_Continue;
}

public Action StopStartStopCountdown( Handle timer, any client ) 
{
	if ( g_iSetCountStartStopTime > 0)
	{
		if (IsClientInGame(client) && IsPlayerAlive(client))
		{
			if ( g_iSetCountStartStopTime < 11) 
			{
				PrintHintText(client,"%t", "warden_stopcountdown_nc", g_iSetCountStartStopTime);
				CPrintToChatAll("%t %t", "warden_tag" , "warden_stopcountdown", g_iSetCountStartStopTime);
			}
		}
		g_iSetCountStartStopTime--;
		IsCountDown = true;
		return Plugin_Continue;
	}
	if ( g_iSetCountStartStopTime == 0)
	{
		if(IsClientInGame(client) && IsClientConnected(client) && !IsFakeClient(client))
		{
			PrintHintText(client, "%t", "warden_countdownstop_nc");
			CPrintToChatAll("%t %t", "warden_tag" , "warden_countdownstop");
			
			if(gc_bOverlays.BoolValue)
			{
				CreateTimer( 0.0, ShowOverlayStop, client);
			}
			if(gc_bSounds.BoolValue)	
			{
				EmitSoundToAllAny(g_sSoundStopPath);
			}
			StartStopTimer = null;
			IsCountDown = false;
			g_iCountStopTime = 20;
			g_iCountStartTime = 9;
			return Plugin_Stop;
		}
	}
	
	return Plugin_Continue;
}

//Overlays

public Action ShowOverlayStop( Handle timer, any client ) 
{
	if(gc_bOverlays.BoolValue && IsValidClient(client, false, true))
	{
		int iFlag = GetCommandFlags( "r_screenoverlay" ) & ( ~FCVAR_CHEAT ); 
		SetCommandFlags( "r_screenoverlay", iFlag ); 
		ClientCommand( client, "r_screenoverlay \"%s.vtf\"", g_sOverlayStopPath);
		CreateTimer( 2.0, DeleteOverlay, client );
	}
	return Plugin_Continue;
}

//No Block

public Action ToggleNoBlock(int client, int args)
{
	if (gc_bNoBlock.BoolValue) 
	{
		if (client == g_iWarden)
		{
			if (!g_bNoBlock) 
			{
				g_bNoBlock = true;
				CPrintToChatAll("%t %t", "warden_tag" , "warden_noblockon");
				for(int i=1; i <= MaxClients; i++) if(IsValidClient(i, true))
				{
					SetEntData(i, g_iCollisionOffset, 2, 4, true);
				}
			}
			else
			{
				g_bNoBlock = false;
				CPrintToChatAll("%t %t", "warden_tag" , "warden_noblockoff");
				for(int i=1; i <= MaxClients; i++) if(IsValidClient(i, true))
				{
					SetEntData(i, g_iCollisionOffset, 5, 4, true);
				}
			}
		}
		else CPrintToChat(client, "%t %t", "warden_tag" , "warden_notwarden");
	}
}

//Friendy Fire 

public Action ToggleFF(int client, int args)
{
	if (gc_bFF.BoolValue) 
	{
		if (g_bFF.BoolValue) 
		{
			if (client == g_iWarden)
			{
				SetCvar("mp_teammates_are_enemies", 0);
				g_bFF = FindConVar("mp_teammates_are_enemies");
				CPrintToChatAll("%t %t", "warden_tag", "warden_ffisoff" );
			}else CPrintToChatAll("%t %t", "warden_tag", "warden_ffison" );
			
		}else
		{	
			if (client == g_iWarden)
			{
				SetCvar("mp_teammates_are_enemies", 1);
				g_bFF = FindConVar("mp_teammates_are_enemies");
				CPrintToChatAll("%t %t", "warden_tag", "warden_ffison" );
			}
			else CPrintToChatAll("%t %t", "warden_tag", "warden_ffisoff" );
		}
	}
}

//Kill a Random T

public Action KillRandom(int client, int args)
{
	if (gc_bRandom.BoolValue) 
	{
		if (client == g_iWarden)
		{
			char info5[255], info6[255], info7[255];
			Menu menu1 = CreateMenu(killmenu);
			Format(info5, sizeof(info5), "%T", "warden_sure", g_iWarden, client);
			menu1.SetTitle(info5);
			Format(info6, sizeof(info6), "%T", "warden_no", client);
			Format(info7, sizeof(info7), "%T", "warden_yes", client);
			menu1.AddItem("0", info6);
			menu1.AddItem("1", info7);
			menu1.ExitBackButton = true;
			menu1.ExitButton = true;
			menu1.Display(client,MENU_TIME_FOREVER);
		}
		else CPrintToChat(client, "%t %t", "warden_tag" , "warden_notwarden"); 
	}
}

public int killmenu(Menu menu, MenuAction action, int client, int Position)
{
	if(action == MenuAction_Select)
	{
		char Item[11];
		menu.GetItem(Position,Item,sizeof(Item));
		int choice = StringToInt(Item);
		if(choice == 1)
		{
			if (GetAlivePlayersCount(CS_TEAM_T) > 1)
			{
				int i = GetRandomPlayer(CS_TEAM_T);
				if(i > 0)
				{
					CreateTimer( 1.0, KillPlayer, i);
					CPrintToChatAll("%t %t", "warden_tag", "warden_israndom", i); 
					LogMessage("[MyJB] Warden %L killed random player %N", client, i);
				}
			}
			else CPrintToChatAll("%t %t", "warden_tag", "warden_minrandom"); 
		}
		if(g_bMenuClose != null)
		{
			if(!g_bMenuClose)
			{
				FakeClientCommand(client, "sm_menu");
			}
		}
		
	}
	else if(action == MenuAction_Cancel)
	{
		if(Position == MenuCancel_ExitBack) 
		{
			FakeClientCommand(client, "sm_menu");
		}
	}
	else if(action == MenuAction_End)
	{
		delete menu;
	}
}

stock int GetAlivePlayersCount(int iTeam)
{
	int iCount, i; iCount = 0;

	for( i = 1; i <= MaxClients; i++ )
		if( IsClientInGame( i ) && IsPlayerAlive( i )  && !IsClientRebel(i) && GetClientTeam( i ) == iTeam )
		iCount++;

	return iCount;
}

public Action KillPlayer( Handle timer, any client) 
{
	if(g_iKillKind == 1)
	{
		int randomnum = GetRandomInt(0, 2);
		
		if(randomnum == 0)PerformSmite(0, client);
		if(randomnum == 1)ServerCommand("sm_timebomb %N 1", client);
		if(randomnum == 2)ServerCommand("sm_firebomb %N 1", client);
	}
	else if(g_iKillKind == 2)PerformSmite(0, client);
	else if(g_iKillKind == 3)ServerCommand("sm_timebomb %N 1", client);
	else if(g_iKillKind == 4)ServerCommand("sm_firebomb %N 1", client);
}

stock int GetRandomPlayer(int team) 
{
	int[] clients = new int[MaxClients];
	int clientCount;
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i) && (GetClientTeam(i) == team) && IsPlayerAlive(i) && !IsClientRebel(i))
		{
			clients[clientCount++] = i;
		}
	}
	return (clientCount == 0) ? -1 : clients[GetRandomInt(0, clientCount-1)];
}

public Action PerformSmite(int client, int target)
{
	// define where the lightning strike ends
	float clientpos[3];
	GetClientAbsOrigin(target, clientpos);
	clientpos[2] -= 26; // increase y-axis by 26 to strike at player's chest instead of the ground
	
	// get random numbers for the x and y starting positions
	int randomx = GetRandomInt(-500, 500);
	int randomy = GetRandomInt(-500, 500);
	
	// define where the lightning strike starts
	float startpos[3];
	startpos[0] = clientpos[0] + randomx;
	startpos[1] = clientpos[1] + randomy;
	startpos[2] = clientpos[2] + 800;
	
	// define the color of the strike
	int color[4] = {255, 255, 255, 255};
	
	// define the direction of the sparks
	float dir[3] = {0.0, 0.0, 0.0};
	
	TE_SetupBeamPoints(startpos, clientpos, g_iBeamSprite, 0, 0, 0, 0.2, 20.0, 10.0, 0, 1.0, color, 3);
	TE_SendToAll();
	
	TE_SetupSparks(clientpos, dir, 5000, 1000);
	TE_SendToAll();
	
	TE_SetupEnergySplash(clientpos, dir, false);
	TE_SendToAll();
	
	TE_SetupSmoke(clientpos, g_iSmokeSprite, 5.0, 10);
	TE_SendToAll();
	
	EmitAmbientSound(SOUND_THUNDER, startpos, target, SNDLEVEL_GUNFIRE);
	
	ForcePlayerSuicide(target);
}

//choose random warden

public Action ChooseRandom(Handle timer, Handle pack)
{
	if(gc_bPlugin.BoolValue)
	{
		--g_iRandomTime;
		if(g_iRandomTime < 1)
		{
			if(warden_exist() != 1)
			{
				if(gc_bChooseRandom.BoolValue)
				{
					int i = GetRandomPlayer(CS_TEAM_CT);
					if(i > 0)
					{
						CPrintToChatAll("%t %t", "warden_tag", "warden_israndomwarden", i); 
						SetTheWarden(i);
					}
				}
			}
			if (RandomTimer != null)
				KillTimer(RandomTimer);
			
			RandomTimer = null;
		}
	}
}

//Open Cell Doors

public Action OpenCounter(Handle timer, Handle pack)
{
	if(gc_bPlugin.BoolValue)
	{
		--g_iOpenTimer;
		if(g_iOpenTimer < 1)
		{
			if(warden_exist() != 1)
			{
				if(gc_bOpenTimer.BoolValue)	
				{
				SJD_OpenDoors(); 
				CPrintToChatAll("%t %t", "warden_tag" , "warden_openauto");
				
				if (OpenCounterTime != null)
					KillTimer(OpenCounterTime);
				
				OpenCounterTime = null;
				}
				
			}
			else if(gc_bOpenTimer.BoolValue)
			{
				if(gc_bOpenTimerWarden.BoolValue)
				{
					SJD_OpenDoors(); 
					CPrintToChatAll("%t %t", "warden_tag" , "warden_openauto");
					
					
				}
				else CPrintToChatAll("%t %t", "warden_tag" , "warden_opentime"); 
				if (OpenCounterTime != null)
				KillTimer(OpenCounterTime);
				OpenCounterTime = null;
			} 
		}
	}
}

public Action OpenDoors(int client, int args)
{
	if(gc_bPlugin.BoolValue)	
	{
		if(gc_bOpen.BoolValue)
		{
			if (client == g_iWarden)
			{
				CPrintToChatAll("%t %t", "warden_tag" , "warden_dooropen"); 
				SJD_OpenDoors();
				if (OpenCounterTime != null)
				KillTimer(OpenCounterTime);
				OpenCounterTime = null;
			}
			else CPrintToChat(client, "%t %t", "warden_tag" , "warden_notwarden"); 
		}
	}
}

public Action CloseDoors(int client, int args)
{
	if(gc_bPlugin.BoolValue)	
	{
		if(gc_bOpen.BoolValue)
		{
			if (client == g_iWarden)
			{
				CPrintToChatAll("%t %t", "warden_tag" , "warden_doorclose"); 
				SJD_CloseDoors();
			}
			else CPrintToChat(client, "%t %t", "warden_tag" , "warden_notwarden"); 
		}
	}
}

//GunPlant


public Action CS_OnCSWeaponDrop(int client, int weapon)
{
	if(gc_bPlugin.BoolValue)	
	{
		if(gc_bGunPlant.BoolValue)
		{
			if(GetClientTeam(client) == CS_TEAM_CT)
			{
				if (g_bWeaponDropped) 
					return Plugin_Handled;
					
				if(gc_bGunNoDrop.BoolValue)
					return Plugin_Handled;
					
				g_iWeaponDrop[client] = weapon;
				
				if (!g_bWeaponDropped) CreateTimer(0.1, DroppedWeapon, client);
			}
		}
	}
	return Plugin_Continue;
}

public Action DroppedWeapon(Handle timer, any client)
{
	if(Weapon_GetOwner(g_iWeaponDrop[client]) == -1)
	{
		if(IsValidClient(client, false, false) && !IsClientInLastRequest(client))
		{
			char g_sWeaponName[80];
			
			GetEntityClassname(g_iWeaponDrop[client], g_sWeaponName, sizeof(g_sWeaponName));
			ReplaceString(g_sWeaponName, sizeof(g_sWeaponName), "weapon_", "", false); 
			g_bWeaponDropped = true;
			
			CPrintToChat(client, "%t %t", "warden_tag" , "warden_noplant", client , g_sWeaponName);
			if(g_iWarden != -1) CPrintToChat(g_iWarden, "%t %t", "warden_tag" , "warden_gunplant", client , g_sWeaponName);
			if((g_iWarden != -1) && gc_bBetterNotes.BoolValue) PrintHintText(g_iWarden, "%t", "warden_gunplant_nc", client , g_sWeaponName);
			if(gc_bGunRemove.BoolValue) CreateTimer(gc_fGunRemoveTime.FloatValue, RemoveWeapon, client);
			if(gc_bGunSlap.BoolValue) SlapPlayer(client, gc_iGunSlapDamage.IntValue, true);
		}
	}
}

public Action RemoveWeapon(Handle timer, any client)
{
	if(IsValidEntity(g_iWeaponDrop[client]))
	{
		if(!(Weapon_GetOwner(g_iWeaponDrop[client]) != -1))
		{
			if(IsValidEdict(g_iWeaponDrop[client])) AcceptEntityInput(g_iWeaponDrop[client], "Kill");
			
		}
		
	}
	g_bWeaponDropped = false;
}

//Natives, Forwards & stocks

public int Native_ExistWarden(Handle plugin, int numParams)
{
	if(g_iWarden != -1)
		return true;
	
	return false;
}

public int Native_IsWarden(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	
	if(!IsClientInGame(client) && !IsClientConnected(client))
		ThrowNativeError(SP_ERROR_INDEX, "Client index %i is invalid", client);
	
	if(client == g_iWarden)
		return true;
	
	return false;
}

public int Native_SetWarden(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	
	if (!IsClientInGame(client) && !IsClientConnected(client))
		ThrowNativeError(SP_ERROR_INDEX, "Client index %i is invalid", client);
	
	if(g_iWarden == -1)
		SetTheWarden(client);
}

public int Native_RemoveWarden(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	
	if (!IsClientInGame(client) && !IsClientConnected(client))
		ThrowNativeError(SP_ERROR_INDEX, "Client index %i is invalid", client);
	
	if(client == g_iWarden)
		RemoveTheWarden(client);
}

public int Native_GetWarden(Handle plugin, int argc)
{	
		return g_iWarden;
}

void Forward_OnWardenCreation(int client)
{
	Call_StartForward(g_fward_onBecome);
	Call_PushCell(client);
	Call_Finish();
}

void Forward_OnWardenRemoved(int client)
{
	Call_StartForward(g_fward_onRemove);
	Call_PushCell(client);
	Call_Finish();
}

stock bool IsWarden()
{
	if(g_iWarden != -1)
	{
	return true;
	}
	return false;
}

stock bool IsClientWarden(int client)
{
	if(client == g_iWarden)
	{
	return true;
	}
	return false;
}

public void warden_OnWardenCreated(int client)
{

}

