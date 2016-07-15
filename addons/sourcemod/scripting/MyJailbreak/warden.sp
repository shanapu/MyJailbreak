//Includes
#include <sourcemod>
#include <cstrike>
#include <warden>
#include <emitsoundany>
#include <colors>
#include <autoexecconfig>
#include <myjailbreak>
#include <scp>
#include <lastrequest>
#include <smlib>
#include <smartjaildoors>

//Compiler Options
#pragma semicolon 1
#pragma newdecls required

//Defines
#define MAX_BUTTONS 25

//ConVars
ConVar gc_bPlugin;
ConVar gc_bVote;
ConVar gc_bStayWarden;
ConVar gc_bColor;
ConVar gc_bBecomeWarden;
ConVar gc_bChooseRandom;
ConVar gc_bSounds;
ConVar gc_bGunPlant;
ConVar gc_bGunRemove;
ConVar gc_fGunRemoveTime;
ConVar gc_iGunSlapDamage;
ConVar gc_bGunSlap;
ConVar gc_bGunNoDrop;
ConVar gc_bMarker;
ConVar gc_bPainter;
ConVar gc_bPainterT;
ConVar gc_bLaser;
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
ConVar gc_iWardenColorRed;
ConVar gc_iWardenColorGreen;
ConVar gc_iWardenColorBlue;
ConVar g_bMenuClose;
ConVar gc_sCustomCommand;
ConVar gc_fAllowDropTime;
ConVar gc_bWardenColorRandom;
ConVar gc_bBackstab;
ConVar gc_iBackstabNumber;
ConVar gc_sAdminFlagBackstab;
ConVar gc_sAdminFlagLaser;
ConVar gc_sAdminFlagPainter;
ConVar gc_fRandomTimer;

//Bools
bool g_bMarkerSetup;
bool g_bCanZoom[MAXPLAYERS + 1];
bool g_bHasSilencer[MAXPLAYERS + 1];
bool g_bLaserUse[MAXPLAYERS+1];
bool g_bPainterUse[MAXPLAYERS+1] = {false, ...};
bool g_bLaser = true;
bool g_bPainter[MAXPLAYERS+1] = false;
bool g_bPainterT = false;
bool g_bLaserColorRainbow[MAXPLAYERS+1] = true;
bool g_bPainterColorRainbow[MAXPLAYERS+1] = true;
bool g_bWeaponDropped[MAXPLAYERS+1] = false;
bool g_bAllowDrop;
bool IsLR = false;

//Integers
int g_iWarden = -1;
int g_iTempWarden[MAXPLAYERS+1] = -1;
int g_iWrongWeapon[MAXPLAYERS+1];
int g_iVoteCount;
int g_iBeamSprite = -1;
int g_iHaloSprite = -1;
int g_iLastButtons[MAXPLAYERS+1];
// int g_iWeaponDrop[MAXPLAYERS+1];
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
int g_iPainterColor[MAXPLAYERS+1];
int g_iBackstabNumber[MAXPLAYERS+1];
int g_iRoundTime;

//Handles
Handle g_fward_onBecome;
Handle g_fward_onRemove;
Handle gF_OnWardenCreatedByUser = null;
Handle gF_OnWardenCreatedByAdmin = null;
Handle gF_OnWardenDisconnected = null;
Handle gF_OnWardenDeath = null;
Handle gF_OnWardenRemovedBySelf = null;
Handle gF_OnWardenRemovedByAdmin = null;
Handle RandomTimer = null;

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
char g_sCustomCommand[64];
char g_sEquipWeapon[MAXPLAYERS+1][32];
char g_sMyJBLogFile[PLATFORM_MAX_PATH];
char g_sAdminFlagBackstab[32];
char g_sAdminFlagLaser[32];
char g_sAdminFlagPainter[32];
char g_sOverlayStart[256];

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
float g_fLastPainter[MAXPLAYERS+1][3];


#include "MyJailbreak/Warden/mute.sp"
#include "MyJailbreak/Warden/bulletsparks.sp"
#include "MyJailbreak/Warden/countdown.sp"
#include "MyJailbreak/Warden/math.sp"
#include "MyJailbreak/Warden/disarm.sp"
#include "MyJailbreak/Warden/noblock.sp"
#include "MyJailbreak/Warden/celldoors.sp"
#include "MyJailbreak/Warden/extendtime.sp"
#include "MyJailbreak/Warden/friendlyfire.sp"
#include "MyJailbreak/Warden/reminder.sp"
#include "MyJailbreak/Warden/randomkill.sp"
#include "MyJailbreak/Warden/handcuffs.sp"

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
	RegConsoleCmd("sm_w", Command_BecomeWarden, "Allows the player taking the charge over prisoners");
	RegConsoleCmd("sm_warden", Command_BecomeWarden, "Allows the player taking the charge over prisoners");
	RegConsoleCmd("sm_uw", Command_ExitWarden, "Allows the player to retire from the position");
	RegConsoleCmd("sm_unwarden", Command_ExitWarden, "Allows the player to retire from the position");
	RegConsoleCmd("sm_hg", Command_BecomeWarden, "Allows the player taking the charge over prisoners");
	RegConsoleCmd("sm_headguard", Command_BecomeWarden, "Allows the player taking the charge over prisoners");
	RegConsoleCmd("sm_uhg", Command_ExitWarden, "Allows the player to retire from the position");
	RegConsoleCmd("sm_unheadguard", Command_ExitWarden, "Allows the player to retire from the position");
	RegConsoleCmd("sm_com", Command_BecomeWarden, "Allows the player taking the charge over prisoners");
	RegConsoleCmd("sm_commander", Command_BecomeWarden, "Allows the player taking the charge over prisoners");
	RegConsoleCmd("sm_uc", Command_ExitWarden, "Allows the player to retire from the position");
	RegConsoleCmd("sm_uncommander", Command_ExitWarden, "Allows the player to retire from the position");
	RegConsoleCmd("sm_vw", Command_VoteWarden, "Allows the player to vote to retire Warden");
	RegConsoleCmd("sm_votewarden", Command_VoteWarden, "Allows the player to vote to retire Warden");
	RegConsoleCmd("sm_vetowarden", Command_VoteWarden, "Allows the player to vote to retire Warden");
	RegConsoleCmd("sm_laser", Command_LaserMenu, "Allows Warden to toggle on/off the wardens Laser pointer");
	RegConsoleCmd("sm_painter", Command_PainterMenu, "Allows Warden to toggle on/off the wardens Painter");
	
	//Admin commands
	RegAdminCmd("sm_sw", AdminCommand_SetWarden, ADMFLAG_GENERIC);
	RegAdminCmd("sm_setwarden", AdminCommand_SetWarden, ADMFLAG_GENERIC);
	RegAdminCmd("sm_rw", AdminCommand_RemoveWarden, ADMFLAG_GENERIC);
	RegAdminCmd("sm_fw", AdminCommand_RemoveWarden, ADMFLAG_GENERIC);
	RegAdminCmd("sm_firewarden", AdminCommand_RemoveWarden, ADMFLAG_GENERIC);
	RegAdminCmd("sm_removewarden", AdminCommand_RemoveWarden, ADMFLAG_GENERIC);
	
	//Forwards
	g_fward_onBecome = CreateGlobalForward("warden_OnWardenCreated", ET_Ignore, Param_Cell);
	g_fward_onRemove = CreateGlobalForward("warden_OnWardenRemoved", ET_Ignore, Param_Cell);
	
	
	
	gF_OnWardenCreatedByUser = CreateGlobalForward("warden_OnWardenCreatedByUser", ET_Ignore, Param_Cell);
	gF_OnWardenCreatedByAdmin = CreateGlobalForward("warden_OnWardenCreatedByAdmin", ET_Ignore, Param_Cell);
	gF_OnWardenDisconnected = CreateGlobalForward("warden_OnWardenDisconnected", ET_Ignore, Param_Cell);
	gF_OnWardenDeath = CreateGlobalForward("warden_OnWardenDeath", ET_Ignore, Param_Cell);
	gF_OnWardenRemovedBySelf = CreateGlobalForward("warden_OnWardenRemovedBySelf", ET_Ignore, Param_Cell);
	gF_OnWardenRemovedByAdmin = CreateGlobalForward("warden_OnWardenRemovedByAdmin", ET_Ignore, Param_Cell);
	
	//AutoExecConfig
	AutoExecConfig_SetFile("Warden", "MyJailbreak");
	AutoExecConfig_SetCreateFile(true);
	
	AutoExecConfig_CreateConVar("sm_warden_version", PLUGIN_VERSION, "The version of this MyJailbreak SourceMod plugin", FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_DONTRECORD);
	gc_bPlugin = AutoExecConfig_CreateConVar("sm_warden_enable", "1", "0 - disabled, 1 - enable this MyJailbreak SourceMod plugin", _, true,  0.0, true, 1.0);
	gc_sCustomCommand = AutoExecConfig_CreateConVar("sm_warden_cmd", "simon", "Set your custom chat command for become warden. no need for sm_ or !");
	gc_bBecomeWarden = AutoExecConfig_CreateConVar("sm_warden_become", "1", "0 - disabled, 1 - enable !w / !warden - player can choose to be warden. If disabled you should need sm_warden_choose_random 1", _, true,  0.0, true, 1.0);
	gc_bChooseRandom = AutoExecConfig_CreateConVar("sm_warden_choose_random", "0", "0 - disabled, 1 - enable pick random warden if there is still no warden after sm_warden_choose_time", _, true,  0.0, true, 1.0);
	gc_fRandomTimer = AutoExecConfig_CreateConVar("sm_warden_choose_time", "45.0", "Time in seconds a random warden will picked when no warden was set. need sm_warden_choose_random 1", _, true,  1.0);
	gc_bVote = AutoExecConfig_CreateConVar("sm_warden_vote", "1", "0 - disabled, 1 - enable player vote against warden", _, true,  0.0, true, 1.0);
	gc_bStayWarden = AutoExecConfig_CreateConVar("sm_warden_stay", "1", "0 - disabled, 1 - enable warden stay after round end", _, true,  0.0, true, 1.0);
	gc_bBetterNotes = AutoExecConfig_CreateConVar("sm_warden_better_notifications", "1", "0 - disabled, 1 - Will use hint and center text", _, true, 0.0, true, 1.0);
	gc_bGunPlant = AutoExecConfig_CreateConVar("sm_warden_gunplant", "1", "0 - disabled, 1 - enable Gun plant prevention", _, true,  0.0, true, 1.0);
	gc_fAllowDropTime = AutoExecConfig_CreateConVar("sm_warden_allow_time", "15.0", "Time in seconds CTs allowed to drop weapon on round beginn.", _, true,  0.1);
	gc_bGunNoDrop = AutoExecConfig_CreateConVar("sm_warden_gunnodrop", "0", "0 - disabled, 1 - disallow gun dropping for ct", _, true,  0.0, true, 1.0);
	gc_bGunRemove = AutoExecConfig_CreateConVar("sm_warden_gunremove", "1", "0 - disabled, 1 - remove planted guns", _, true,  0.0, true, 1.0);
	gc_fGunRemoveTime = AutoExecConfig_CreateConVar("sm_warden_gunremove_time", "5.0", "Time in seconds to pick up gun again before.", _, true,  0.1);
	gc_bGunSlap = AutoExecConfig_CreateConVar("sm_warden_gunslap", "1", "0 - disabled, 1 - Slap the CT for dropping a gun", _, true,  0.0, true, 1.0);
	gc_iGunSlapDamage = AutoExecConfig_CreateConVar("sm_warden_gunslap_dmg", "10", "Amoung of HP losing on slap for dropping a gun", _, true,  0.0);
	gc_bBackstab = AutoExecConfig_CreateConVar("sm_warden_backstab", "1", "0 - disabled, 1 - enable backstab protection for warden", _, true,  0.0, true, 1.0);
	gc_iBackstabNumber = AutoExecConfig_CreateConVar("sm_warden_backstab_number", "1", "How many time a warden get protected? 0 - alltime", _, true,  1.0);
	gc_sAdminFlagBackstab = AutoExecConfig_CreateConVar("sm_warden_backstab_flag", "", "Set flag for admin/vip to get warden backstab protection. No flag = feature is available for all players!");
	gc_bOverlays = AutoExecConfig_CreateConVar("sm_warden_overlays_enable", "1", "0 - disabled, 1 - enable overlays", _, true,  0.0, true, 1.0);
	gc_sOverlayStartPath = AutoExecConfig_CreateConVar("sm_warden_overlays_start", "overlays/MyJailbreak/start" , "Path to the start Overlay DONT TYPE .vmt or .vft");
	gc_sOverlayStopPath = AutoExecConfig_CreateConVar("sm_warden_overlays_stop", "overlays/MyJailbreak/stop" , "Path to the stop Overlay DONT TYPE .vmt or .vft");
	gc_bMarker = AutoExecConfig_CreateConVar("sm_warden_marker", "1", "0 - disabled, 1 - enable Warden advanced markers ", _, true,  0.0, true, 1.0);
	gc_bLaser = AutoExecConfig_CreateConVar("sm_warden_laser", "1", "0 - disabled, 1 - enable Warden Laser Pointer with +E ", _, true,  0.0, true, 1.0);
	gc_sAdminFlagLaser = AutoExecConfig_CreateConVar("sm_warden_laser_flag", "", "Set flag for admin/vip to get warden laser pointer. No flag = feature is available for all players!");
	gc_bPainter = AutoExecConfig_CreateConVar("sm_warden_painter", "1", "0 - disabled, 1 - enable Warden Painter with +E ", _, true,  0.0, true, 1.0);
	gc_sAdminFlagPainter = AutoExecConfig_CreateConVar("sm_warden_painter_flag", "", "Set flag for admin/vip to get warden painter access. No flag = feature is available for all players!");
	gc_bPainterT= AutoExecConfig_CreateConVar("sm_warden_painter_terror", "1", "0 - disabled, 1 - allow Warden to toggle Painter for Terrorist ", _, true,  0.0, true, 1.0);
	gc_bIcon = AutoExecConfig_CreateConVar("sm_warden_icon_enable", "1", "0 - disabled, 1 - enable the icon above the wardens head", _, true,  0.0, true, 1.0);
	gc_sIconPath = AutoExecConfig_CreateConVar("sm_warden_icon", "decals/MyJailbreak/warden" , "Path to the warden icon DONT TYPE .vmt or .vft");
	gc_bModel = AutoExecConfig_CreateConVar("sm_warden_model", "1", "0 - disabled, 1 - enable warden model", 0, true, 0.0, true, 1.0);
	gc_sModelPath = AutoExecConfig_CreateConVar("sm_warden_model_path", "models/player/custom_player/legacy/security/security.mdl", "Path to the model for warden.");
	gc_bColor = AutoExecConfig_CreateConVar("sm_warden_color_enable", "1", "0 - disabled, 1 - enable warden colored", _, true,  0.0, true, 1.0);
	gc_bWardenColorRandom = AutoExecConfig_CreateConVar("sm_warden_color_random", "1", "0 - disabled, 1 - enable warden rainbow colored", _, true,  0.0, true, 1.0);
	gc_iWardenColorRed = AutoExecConfig_CreateConVar("sm_warden_color_red", "0","What color to turn the warden into (set R, G and B values to 255 to disable) (Rgb): x - red value", _, true, 0.0, true, 255.0);
	gc_iWardenColorGreen = AutoExecConfig_CreateConVar("sm_warden_color_green", "0","What color to turn the warden into (rGb): x - green value", _, true, 0.0, true, 255.0);
	gc_iWardenColorBlue = AutoExecConfig_CreateConVar("sm_warden_color_blue", "255","What color to turn the warden into (rgB): x - blue value", _, true, 0.0, true, 255.0);
	gc_bSounds = AutoExecConfig_CreateConVar("sm_warden_sounds_enable", "1", "0 - disabled, 1 - enable sounds ", _, true,  0.0, true, 1.0);
	gc_sWarden = AutoExecConfig_CreateConVar("sm_warden_sounds_warden", "music/MyJailbreak/warden.mp3", "Path to the soundfile which should be played for a int warden.");
	gc_sUnWarden = AutoExecConfig_CreateConVar("sm_warden_sounds_unwarden", "music/MyJailbreak/unwarden.mp3", "Path to the soundfile which should be played when there is no warden anymore.");
	gc_sSoundStartPath = AutoExecConfig_CreateConVar("sm_warden_sounds_start", "music/MyJailbreak/start.mp3", "Path to the soundfile which should be played for a start countdown.");
	gc_sSoundStopPath = AutoExecConfig_CreateConVar("sm_warden_sounds_stop", "music/MyJailbreak/stop.mp3", "Path to the soundfile which should be played for stop countdown.");
	
	Mute_OnPluginStart();
	Disarm_OnPluginStart();
	BulletSparks_OnPluginStart();
	Countdown_OnPluginStart();
	Math_OnPluginStart();
	NoBlock_OnPluginStart();
	CellDoors_OnPluginStart();
	ExtendTime_OnPluginStart();
	FriendlyFire_OnPluginStart();
	Reminder_OnPluginStart();
	RandomKill_OnPluginStart();
	HandCuffs_OnPluginStart();
	
	AutoExecConfig_ExecuteFile();
	AutoExecConfig_CleanFile();
	
	//Hooks
	HookEvent("item_equip", ItemEquip);
	HookEvent("round_start", RoundStart);
	HookEvent("round_poststart", PostRoundStart);
	HookEvent("player_death", playerDeath);
	HookEvent("player_team", EventPlayerTeam);
	HookEvent("round_end", RoundEnd);
	HookEvent("weapon_fire", WeaponFire);
	HookConVarChange(gc_sModelPath, OnSettingChanged);
	HookConVarChange(gc_sUnWarden, OnSettingChanged);
	HookConVarChange(gc_sWarden, OnSettingChanged);
	HookConVarChange(gc_sSoundStartPath, OnSettingChanged);
	HookConVarChange(gc_sSoundStopPath, OnSettingChanged);
	HookConVarChange(gc_sOverlayStartPath, OnSettingChanged);
	HookConVarChange(gc_sOverlayStopPath, OnSettingChanged);
	HookConVarChange(gc_sIconPath, OnSettingChanged);
	HookConVarChange(gc_sAdminFlagBackstab, OnSettingChanged);
	HookConVarChange(gc_sAdminFlagLaser, OnSettingChanged);
	HookConVarChange(gc_sAdminFlagPainter, OnSettingChanged);
	
	//FindConVar
	g_bMenuClose = FindConVar("sm_menu_close");
	gc_sWarden.GetString(g_sWarden, sizeof(g_sWarden));
	gc_sUnWarden.GetString(g_sUnWarden, sizeof(g_sUnWarden));
	gc_sSoundStartPath.GetString(g_sSoundStartPath, sizeof(g_sSoundStartPath));
	gc_sSoundStopPath.GetString(g_sSoundStopPath, sizeof(g_sSoundStopPath));
	gc_sModelPath.GetString(g_sWardenModel, sizeof(g_sWardenModel));
	gc_sOverlayStartPath.GetString(g_sOverlayStart , sizeof(g_sOverlayStart));
	gc_sOverlayStopPath.GetString(g_sOverlayStopPath , sizeof(g_sOverlayStopPath));
	gc_sIconPath.GetString(g_sIconPath , sizeof(g_sIconPath));
	gc_sCustomCommand.GetString(g_sCustomCommand , sizeof(g_sCustomCommand));
	gc_sAdminFlagBackstab.GetString(g_sAdminFlagBackstab , sizeof(g_sAdminFlagBackstab));
	gc_sAdminFlagLaser.GetString(g_sAdminFlagLaser , sizeof(g_sAdminFlagLaser));
	gc_sAdminFlagPainter.GetString(g_sAdminFlagPainter , sizeof(g_sAdminFlagPainter));
	
	CreateTimer(1.0, Timer_DrawMakers, _, TIMER_REPEAT);
	
	//Prepare translation for marker colors
	Format(g_sColorNamesRed, sizeof(g_sColorNamesRed), "{darkred}%T{default}", "warden_red", LANG_SERVER);
	Format(g_sColorNamesBlue, sizeof(g_sColorNamesBlue), "{blue}%T{default}", "warden_blue", LANG_SERVER);
	Format(g_sColorNamesGreen, sizeof(g_sColorNamesGreen), "{green}%T{default}", "warden_green", LANG_SERVER);
	Format(g_sColorNamesOrange, sizeof(g_sColorNamesOrange), "{lightred}%T{default}", "warden_orange", LANG_SERVER);
	Format(g_sColorNamesMagenta, sizeof(g_sColorNamesMagenta), "{purple}%T{default}", "warden_magenta", LANG_SERVER);
	Format(g_sColorNamesYellow, sizeof(g_sColorNamesYellow), "{orange}%T{default}", "warden_yellow", LANG_SERVER);
	Format(g_sColorNamesWhite, sizeof(g_sColorNamesWhite), "{default}%T{default}", "warden_white", LANG_SERVER);
	Format(g_sColorNamesCyan, sizeof(g_sColorNamesCyan), "{blue}%T{default}", "warden_cyan", LANG_SERVER);
	Format(g_sColorNamesRainbow, sizeof(g_sColorNamesRainbow), "{lightgreen}%T{default}", "warden_rainbow", LANG_SERVER);
	
	g_sColorNames[0] = g_sColorNamesWhite;
	g_sColorNames[1] = g_sColorNamesRed;
	g_sColorNames[3] = g_sColorNamesBlue;
	g_sColorNames[2] = g_sColorNamesGreen;
	g_sColorNames[7] = g_sColorNamesOrange;
	g_sColorNames[6] = g_sColorNamesMagenta;
	g_sColorNames[4] = g_sColorNamesYellow;
	g_sColorNames[5] = g_sColorNamesCyan;
	
	SetLogFile(g_sMyJBLogFile, "MyJB");

}

//ConVarChange for Strings

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
	else if(convar == gc_sAdminFlagBackstab)
	{
		strcopy(g_sAdminFlagBackstab, sizeof(g_sAdminFlagBackstab), newValue);
	}
	else if(convar == gc_sAdminFlagLaser)
	{
		strcopy(g_sAdminFlagLaser, sizeof(g_sAdminFlagLaser), newValue);
	}
	else if(convar == gc_sAdminFlagPainter)
	{
		strcopy(g_sAdminFlagPainter, sizeof(g_sAdminFlagPainter), newValue);
	}
	else if(convar == gc_sCustomCommand)
	{
		strcopy(g_sCustomCommand, sizeof(g_sCustomCommand), newValue);
		char sBufferCMD[64];
		Format(sBufferCMD, sizeof(sBufferCMD), "sm_%s", g_sCustomCommand);
		if(GetCommandFlags(sBufferCMD) == INVALID_FCVAR_FLAGS)
			RegConsoleCmd(sBufferCMD, Command_BecomeWarden, "Allows the player taking the charge over prisoners");
	}
}

//Initialize Plugin

public void OnConfigsExecuted()
{
	Math_OnConfigsExecuted();
	RandomKill_OnConfigsExecuted();
	
	char sBufferCMD[64];
	Format(sBufferCMD, sizeof(sBufferCMD), "sm_%s", g_sCustomCommand);
	if(GetCommandFlags(sBufferCMD) == INVALID_FCVAR_FLAGS)
		RegConsoleCmd(sBufferCMD, Command_BecomeWarden, "Allows the player taking the charge over prisoners");
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
	Countdown_OnMapStart();
	Math_OnMapStart();
	HandCuffs_OnMapStart();
	
	if(gc_bSounds.BoolValue)
	{
		PrecacheSoundAnyDownload(g_sWarden);
		PrecacheSoundAnyDownload(g_sUnWarden);
		PrecacheSoundAnyDownload(g_sSoundStopPath);
		PrecacheSoundAnyDownload(g_sSoundStartPath);
	}
	PrecacheSound("weapons/c4/c4_beep1.wav", true);
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
	CreateTimer(0.1, Print_Painter, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
	g_bLaser = true;
	g_bPainterT = false;
	LoopClients(i) g_bPainter[i] = false;
}

public void OnClientPutInServer(int client)
{
	g_bLaserUse[client] = false;
	g_bPainterUse[client] = false;
	g_bPainterColorRainbow[client] = true;
	g_bLaserColorRainbow[client] = true;
	g_fLastPainter[client][0] = 0.0;
	g_fLastPainter[client][1] = 0.0;
	g_fLastPainter[client][2] = 0.0;
	
	BulletSparks_OnClientPutInServer(client);
	HandCuffs_OnClientPutInServer(client);
	
	SDKHook(client, SDKHook_OnTakeDamage, OnTakedamage);
}

//Round Start


public void PostRoundStart(Event event, const char[] name, bool dontBroadcast)
{
	if(gc_bPlugin.BoolValue)
	{
		if ((g_iWarden == -1) && gc_bBecomeWarden.BoolValue)
		{
			RandomTimer = CreateTimer(gc_fRandomTimer.FloatValue, ChooseRandom);
			CPrintToChatAll("%t %t", "warden_tag" , "warden_nowarden");
			if(gc_bBetterNotes.BoolValue)
			{
				PrintCenterTextAll("%t", "warden_nowarden_nc");
			}
		}
	}
}


public void RoundStart(Event event, const char[] name, bool dontBroadcast)
{
	if(!gc_bPlugin.BoolValue)
	{
		if (g_iWarden == 1)
		{
			CreateTimer(0.1, Timer_RemoveColor, g_iWarden);
			SetEntityModel(g_iWarden, g_sModelPath);
			Forward_OnWardenRemoved(g_iWarden);
			RemoveIcon(g_iWarden);
			g_iWarden = -1;
			g_bLaser = false;
		}
	}
	char EventDay[64];
	GetEventDay(EventDay);
	
	if(!StrEqual(EventDay, "none", false) || !gc_bStayWarden.BoolValue)
	{
		if (g_iWarden == 1)
		{
			CreateTimer( 0.1, Timer_RemoveColor, g_iWarden);
			SetEntityModel(g_iWarden, g_sModelPath);
			Forward_OnWardenRemoved(g_iWarden);
			RemoveIcon(g_iWarden);
			g_iWarden = -1;
			g_bLaser = false;
		}
	}
	if(gc_bStayWarden.BoolValue && warden_exist())
	{
		SpawnIcon(g_iWarden);
		if(gc_bModel.BoolValue) SetEntityModel(g_iWarden, g_sWardenModel);
		
	}
	g_bAllowDrop = true;
	IsLR = false;
	LoopClients(i)
	{
		g_iBackstabNumber[i] = gc_iBackstabNumber.IntValue;
	}
	CreateTimer (gc_fAllowDropTime.FloatValue, AllowDropTimer);
	
	g_iGetRoundTime = FindConVar("mp_roundtime");
	g_iRoundTime = g_iGetRoundTime.IntValue * 60;
}

//Round End

public void RoundEnd(Event event, const char[] name, bool dontBroadcast)
{
	g_bPainterT = false;
	IsLR = false;
	LoopClients(i)
	{
		if(g_bPainter[i]) g_bPainter[i] = false;
	}
}

//!w

public Action Command_BecomeWarden(int client, int args)
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

public Action Command_ExitWarden(int client, int args) 
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
			CreateTimer( 0.1, Timer_RemoveColor, g_iWarden);
			SetEntityModel(client, g_sModelPath);
			if (RandomTimer != null)
			KillTimer(RandomTimer);
			
			RandomTimer = null;
			RandomTimer = CreateTimer(gc_fRandomTimer.FloatValue, ChooseRandom);
			if(gc_bSounds.BoolValue) EmitSoundToAllAny(g_sUnWarden);
			RemoveAllMarkers();
			g_iVoteCount = 0;
			Format(g_sHasVoted, sizeof(g_sHasVoted), "");
			g_sHasVoted[0] = '\0';
			RemoveIcon(g_iWarden);
			g_iWarden = -1;
			g_bPainterT = false;
		}
		else CPrintToChat(client, "%t %t", "warden_tag" , "warden_notwarden");
	}
	else CPrintToChat(client, "%t %t", "warden_tag" , "warden_disabled");
}

//!vw

public Action Command_VoteWarden(int client,int args)
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
						if(MyJBLogging(true)) LogToFileEx(g_sMyJBLogFile, "Player %L was kick as warden by voting", g_iWarden);
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
		if (RandomTimer != null)
		KillTimer(RandomTimer);
			
		RandomTimer = null;
		RandomTimer = CreateTimer(gc_fRandomTimer.FloatValue, ChooseRandom);
		Call_StartForward(gF_OnWardenDeath);
		Call_PushCell(client);
		Call_Finish();
		RemoveIcon(g_iWarden);
		g_iWarden = -1;
	}
	
	g_fLastPainter[client][0] = 0.0;
	g_fLastPainter[client][1] = 0.0;
	g_fLastPainter[client][2] = 0.0;
	g_bPainterUse[client] = false;
}

//Set new Warden for Admin Menu

public Action AdminCommand_SetWarden(int client,int args)
{
	if(gc_bPlugin.BoolValue)	
	{
		if(IsValidClient(client, false, false))
		{
			char info1[255];
			Menu menu = CreateMenu(SetWardenHandler);
			Format(info1, sizeof(info1), "%T", "warden_choose", client);
			menu.SetTitle(info1);
			LoopValidClients(i, true, false)
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
		
		LoopValidClients(i, true, false)
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
						CreateTimer(1.0, Timer_WardenFixColor, i, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
						
						SpawnIcon(i);
						GetEntPropString(i, Prop_Data, "m_ModelName", g_sModelPath, sizeof(g_sModelPath));
						if(gc_bModel.BoolValue)
						{
							SetEntityModel(i, g_sWardenModel);
						}
						Call_StartForward(gF_OnWardenCreatedByAdmin);
						Call_PushCell(i);
						Call_Finish();
						if (RandomTimer != null)
						KillTimer(RandomTimer);
			
						RandomTimer = null;
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
			if (g_iWarden != -1)CPrintToChatAll("%t %t", "warden_tag" , "warden_removed", client, g_iWarden);
			CPrintToChatAll("%t %t", "warden_tag" , "warden_new", newwarden);
			if(gc_bSounds.BoolValue)
			{
				EmitSoundToAllAny(g_sWarden);
			}
			if(gc_bBetterNotes.BoolValue)
			{
				PrintCenterTextAll("%t", "warden_new_nc", newwarden);
			}
			if(MyJBLogging(true)) LogToFileEx(g_sMyJBLogFile, "Admin %L kick player %L warden and set %L as new", client, g_iWarden, newwarden);
			RemoveIcon(g_iWarden);
			CreateTimer( 0.1, Timer_RemoveColor, g_iWarden);
			SetEntityModel(g_iWarden, g_sModelPath);
			g_iWarden = newwarden;
			CreateTimer(1.0, Timer_WardenFixColor, newwarden, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
			SpawnIcon(newwarden);
			GetEntPropString(newwarden, Prop_Data, "m_ModelName", g_sModelPath, sizeof(g_sModelPath));
			if(gc_bModel.BoolValue)
			{
				SetEntityModel(newwarden, g_sWardenModel);
			}
			Call_StartForward(gF_OnWardenCreatedByAdmin);
			Call_PushCell(newwarden);
			Call_Finish();
			if (RandomTimer != null)
			KillTimer(RandomTimer);
			
			RandomTimer = null;
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
					if(gc_bWardenColorRandom.BoolValue)
					{
						int i = GetRandomInt(1, 7);
						SetEntityRenderColor(client, g_iColors[i][0], g_iColors[i][1], g_iColors[i][2], g_iColors[i][3]);
					}
					else SetEntityRenderColor(client, gc_iWardenColorRed.IntValue, gc_iWardenColorGreen.IntValue, gc_iWardenColorBlue.IntValue, 255);
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
	g_fLastPainter[client][0] = 0.0;
	g_fLastPainter[client][1] = 0.0;
	g_fLastPainter[client][2] = 0.0;
	g_bPainterUse[client] = false;
	g_bPainter[client] = false;
	if(client == g_iWarden) RemoveTheWarden(client);
}

//Warden disconnect

public void OnClientDisconnect(int client)
{
	if(client == g_iWarden)
	{
		CPrintToChatAll("%t %t", "warden_tag" , "warden_disconnected", client);
		
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
		g_bPainterT = false;
	}
	g_iLastButtons[client] = 0;
	
	HandCuffs_OnClientDisconnect(client);
}

//warden change team

public Action EventPlayerTeam(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	if(client == g_iWarden)
	{	
		CPrintToChatAll("%t %t", "warden_tag" , "warden_retire", client);
		
		if(gc_bBetterNotes.BoolValue)
		{
			PrintCenterTextAll("%t", "warden_retire_nc", client);
		}
		g_iWarden = -1;
		Forward_OnWardenRemoved(client);
		Call_StartForward(gF_OnWardenDisconnected);
		Call_PushCell(client);
		Call_Finish();
		CreateTimer( 0.1, Timer_RemoveColor, client);
		
		if (RandomTimer != null)
		KillTimer(RandomTimer);
			
		RandomTimer = null;
		RandomTimer = CreateTimer(gc_fRandomTimer.FloatValue, ChooseRandom);
		if(gc_bSounds.BoolValue)
		{
			EmitSoundToAllAny(g_sUnWarden);
		}
		RemoveAllMarkers();
		g_bPainterT = false;
	}
	g_iLastButtons[client] = 0;
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
		CreateTimer(1.0, Timer_WardenFixColor, client, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
		SpawnIcon(client);
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
		if (RandomTimer != null)
		KillTimer(RandomTimer);
			
		RandomTimer = null;
	}
	else CPrintToChat(client, "%t %t", "warden_tag" , "warden_disabled");
}

//Remove player Warden

public Action AdminCommand_RemoveWarden(int client, int args)
{
	if(g_iWarden != -1)
	{
		RemoveTheWarden(client);
		Call_StartForward(gF_OnWardenRemovedByAdmin);
		Call_PushCell(client);
		Call_Finish();
		
	}
	return Plugin_Handled;
}

void RemoveTheWarden(int client)
{
	CPrintToChatAll("%t %t", "warden_tag" , "warden_removed", client, g_iWarden);  // if client is console !=
	
	if(gc_bBetterNotes.BoolValue)
	{
		PrintCenterTextAll("%t", "warden_removed_nc", client, g_iWarden);
	}
	if(MyJBLogging(true)) LogToFileEx(g_sMyJBLogFile, "Admin %L removed player %L as warden", client, g_iWarden);
	CreateTimer( 0.1, Timer_RemoveColor, g_iWarden);
	SetEntityModel(client, g_sModelPath);
	if (RandomTimer != null)
		KillTimer(RandomTimer);
			
	RandomTimer = null;
	RandomTimer = CreateTimer(gc_fRandomTimer.FloatValue, ChooseRandom);
	Call_StartForward(gF_OnWardenRemovedBySelf);
	Call_PushCell(g_iWarden);
	Call_Finish();
	Forward_OnWardenRemoved(g_iWarden);
	if(gc_bSounds.BoolValue)
	{
		EmitSoundToAllAny(g_sUnWarden);
	}
	RemoveAllMarkers();
	g_bPainterT = false;
	g_iVoteCount = 0;
	Format(g_sHasVoted, sizeof(g_sHasVoted), "");
	g_sHasVoted[0] = '\0';

	RemoveIcon(g_iWarden);
	g_iWarden = -1;
}



//New Marker

public Action ItemEquip(Handle event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	g_bCanZoom[client] = GetEventBool(event, "canzoom");
	g_bHasSilencer[client] = GetEventBool(event, "hassilencer");
	g_iWrongWeapon[client] = GetEventInt(event, "weptype");
}

public void OnMapEnd()
{
	RemoveAllMarkers();
	if (g_iWarden != -1)
	{
		CreateTimer(0.1, Timer_RemoveColor, g_iWarden);
		Forward_OnWardenRemoved(g_iWarden);
		RemoveIcon(g_iWarden);
		g_iWarden = -1;
	}
	g_bLaser = false;
	g_bPainterT = false;
	
	LoopClients(client)
	{
		g_fLastPainter[client][0] = 0.0;
		g_fLastPainter[client][1] = 0.0;
		g_fLastPainter[client][2] = 0.0;
		g_bPainterUse[client] = false;
		g_bPainter[client] = false;
	}
	
	Math_OnMapEnd();
	Mute_OnMapEnd();
	Countdown_OnMapEnd();
	Reminder_OnMapEnd();
	HandCuffs_OnMapEnd();
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
		
		LoopValidClients(iClient, false, false)
		{
			
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
	
	float g_fPos[3];
	Entity_GetAbsOrigin(g_iWarden, g_fPos);
	
	float range = GetVectorDistance(g_fPos, g_fMarkerSetupStartOrigin);
	if (range > g_fMarkerRangeMax)
	{
		CPrintToChat(client, "%t %t", "warden_tag", "warden_range");
		return;
	}
	
	if (0 < client < MaxClients)
	{
		Handle menu = CreateMenu(Handle_MarkerMenu);
		
		char menuinfo[255];
		
		Format(menuinfo, sizeof(menuinfo), "%T", "warden_marker_title", client);
		SetMenuTitle(menu, menuinfo);
		
		Format(menuinfo, sizeof(menuinfo), "%T", "warden_red", client);
		AddMenuItem(menu, "1", menuinfo);
		Format(menuinfo, sizeof(menuinfo), "%T", "warden_blue", client);
		AddMenuItem(menu, "3", menuinfo);
		Format(menuinfo, sizeof(menuinfo), "%T", "warden_green", client);
		AddMenuItem(menu, "2", menuinfo);
		Format(menuinfo, sizeof(menuinfo), "%T", "warden_orange", client);
		AddMenuItem(menu, "7", menuinfo);
		Format(menuinfo, sizeof(menuinfo), "%T", "warden_white", client);
		AddMenuItem(menu, "0", menuinfo);
		Format(menuinfo, sizeof(menuinfo), "%T", "warden_cyan", client);
		AddMenuItem(menu, "5", menuinfo);
		Format(menuinfo, sizeof(menuinfo), "%T", "warden_magenta", client);
		AddMenuItem(menu, "6", menuinfo);
		Format(menuinfo, sizeof(menuinfo), "%T", "warden_yellow", client);
		AddMenuItem(menu, "4", menuinfo);
		
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

stock int GetClientAimTargetPos(int client, float g_fPos[3]) 
{
	if (client < 1) 
		return -1;
	
	float vAngles[3]; float vOrigin[3];
	
	GetClientEyePosition(client,vOrigin);
	GetClientEyeAngles(client, vAngles);
	
	Handle trace = TR_TraceRayFilterEx(vOrigin, vAngles, MASK_SHOT, RayType_Infinite, TraceFilterAllEntities, client);
	
	TR_GetEndPosition(g_fPos, trace);
	g_fPos[2] += 5.0;
	
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

stock int IsMarkerInRange(float g_fPos[3])
{
	for(int i = 0; i < 8;i++)
	{
		if (g_fMarkerRadius[i] <= 0.0)
			continue;
		
		if (GetVectorDistance(g_fMarkerOrigin[i], g_fPos) < g_fMarkerRadius[i])
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
	if (client == g_iWarden && gc_bPlugin.BoolValue)
	{
		HandCuffs_OnPlayerRunCmd(client, buttons, impulse, vel, angles, weapon);
		
		if (buttons & IN_ATTACK2)
		{
			if (gc_bMarker.BoolValue && !g_bCanZoom[client] && !g_bHasSilencer[client] && (g_iWrongWeapon[client] != 0) && (g_iWrongWeapon[client] != 8) && (!StrEqual(g_sEquipWeapon[client], "taser")))
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
			if (gc_bLaser.BoolValue && CheckVipFlag(client,g_sAdminFlagLaser))
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
	if (((client == g_iWarden) && gc_bPainter.BoolValue && g_bPainter[client] && CheckVipFlag(client,g_sAdminFlagPainter)) || ((GetClientTeam(client) == CS_TEAM_T) && gc_bPainter.BoolValue && g_bPainterT))
	{
		for (int i = 0; i < MAX_BUTTONS; i++)
		{
			int button = (1 << i);
			
			if ((buttons & button))
			{
				if (!(g_iLastButtons[client] & button))
				{
					OnButtonPress(client, button);
				}
			}
			else if ((g_iLastButtons[client] & button))
			{
				OnButtonRelease(client, button);
			}
		}
		g_iLastButtons[client] = buttons;
	}
	return Plugin_Continue;
}

public Action Command_LaserMenu(int client, int args)
{
	if(gc_bLaser.BoolValue)
	{
		if (client == g_iWarden)
		{
			if(CheckVipFlag(client,g_sAdminFlagLaser))
			{
				char menuinfo[255];
				
				Menu menu = new Menu(LaserHandler);
				Format(menuinfo, sizeof(menuinfo), "%T", "warden_laser_title", client);
				menu.SetTitle(menuinfo);
				Format(menuinfo, sizeof(menuinfo), "%T", "warden_laser_off", client);
				menu.AddItem("off", menuinfo);
				Format(menuinfo, sizeof(menuinfo), "%T", "warden_rainbow", client);
				menu.AddItem("rainbow", menuinfo);
				Format(menuinfo, sizeof(menuinfo), "%T", "warden_white", client);
				menu.AddItem("white", menuinfo);
				Format(menuinfo, sizeof(menuinfo), "%T", "warden_red", client);
				menu.AddItem("red", menuinfo);
				Format(menuinfo, sizeof(menuinfo), "%T", "warden_green", client);
				menu.AddItem("green", menuinfo);
				Format(menuinfo, sizeof(menuinfo), "%T", "warden_blue", client);
				menu.AddItem("blue", menuinfo);
				Format(menuinfo, sizeof(menuinfo), "%T", "warden_yellow", client);
				menu.AddItem("yellow", menuinfo);
				Format(menuinfo, sizeof(menuinfo), "%T", "warden_cyan", client);
				menu.AddItem("cyan", menuinfo);
				Format(menuinfo, sizeof(menuinfo), "%T", "warden_magenta", client);
				menu.AddItem("magenta", menuinfo);
				Format(menuinfo, sizeof(menuinfo), "%T", "warden_orange", client);
				menu.AddItem("orange", menuinfo);
				
				menu.ExitBackButton = true;
				menu.ExitButton = true;
				menu.Display(client, 20);
			}
			else CPrintToChat(client, "%t %t", "warden_tag", "warden_vipfeature");
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

public Action Command_PainterMenu(int client, int args)
{
	if(gc_bPainter.BoolValue && CheckVipFlag(client,g_sAdminFlagPainter))
	{
		if ((client == g_iWarden) || ((GetClientTeam(client) == CS_TEAM_T) && g_bPainterT))
		{
			if(CheckVipFlag(client,g_sAdminFlagPainter) || (GetClientTeam(client) == CS_TEAM_T))
			{
				char menuinfo[255];
				
				Menu menu = new Menu(PainterHandler);
				Format(menuinfo, sizeof(menuinfo), "%T", "warden_painter_title", client);
				menu.SetTitle(menuinfo);
				Format(menuinfo, sizeof(menuinfo), "%T", "warden_painter_off", client);
				menu.AddItem("off", menuinfo);
				Format(menuinfo, sizeof(menuinfo), "%T", "warden_paintert", client);
				if (GetClientTeam(client) == CS_TEAM_CT) menu.AddItem("terror", menuinfo);
				Format(menuinfo, sizeof(menuinfo), "%T", "warden_rainbow", client);
				menu.AddItem("rainbow", menuinfo);
				Format(menuinfo, sizeof(menuinfo), "%T", "warden_white", client);
				menu.AddItem("white", menuinfo);
				Format(menuinfo, sizeof(menuinfo), "%T", "warden_red", client);
				menu.AddItem("red", menuinfo);
				Format(menuinfo, sizeof(menuinfo), "%T", "warden_green", client);
				menu.AddItem("green", menuinfo);
				Format(menuinfo, sizeof(menuinfo), "%T", "warden_blue", client);
				menu.AddItem("blue", menuinfo);
				Format(menuinfo, sizeof(menuinfo), "%T", "warden_yellow", client);
				menu.AddItem("yellow", menuinfo);
				Format(menuinfo, sizeof(menuinfo), "%T", "warden_cyan", client);
				menu.AddItem("cyan", menuinfo);
				Format(menuinfo, sizeof(menuinfo), "%T", "warden_magenta", client);
				menu.AddItem("magenta", menuinfo);
				Format(menuinfo, sizeof(menuinfo), "%T", "warden_orange", client);
				menu.AddItem("orange", menuinfo);
				
				menu.ExitBackButton = true;
				menu.ExitButton = true;
				menu.Display(client, 20);
			}
			else CPrintToChat(client, "%t %t", "warden_tag", "warden_vipfeature");
		}
	}
	return Plugin_Handled;
}

public int PainterHandler(Menu menu, MenuAction action, int client, int selection)
{
if (action == MenuAction_Select)
	{
		char info[32];
		menu.GetItem(selection, info, sizeof(info));
		
		if ( strcmp(info,"off") == 0 ) 
		{
			g_bPainter[client] = false;
			CPrintToChat(client, "%t %t", "warden_tag", "warden_painteroff");
		}
		else if ( strcmp(info,"terror") == 0 ) 
		{
			TogglePainterT(client,0);
		}
		else if ( strcmp(info,"rainbow") == 0 ) 
		{
			if(!g_bPainter[client]) CPrintToChat(client, "%t %t", "warden_tag", "warden_painteron");
			CPrintToChat(client, "%t %t", "warden_tag", "warden_painter", g_sColorNamesRainbow);
			g_bPainter[client] = true;
			g_bPainterColorRainbow[client] = true;
			
		}
		else if ( strcmp(info,"white") == 0 ) 
		{
			if(!g_bPainter[client]) CPrintToChat(client, "%t %t", "warden_tag", "warden_painteron");
			CPrintToChat(client, "%t %t", "warden_tag", "warden_painter", g_sColorNamesWhite);
			g_bPainter[client] = true;
			g_bPainterColorRainbow[client] = false;
			g_iPainterColor[client] = 0;
			
		}
		else if ( strcmp(info,"red") == 0 ) 
		{
			if(!g_bPainter[client]) CPrintToChat(client, "%t %t", "warden_tag", "warden_painteron");
			CPrintToChat(client, "%t %t", "warden_tag", "warden_painter", g_sColorNamesRed);
			g_bPainter[client] = true;
			g_bPainterColorRainbow[client] = false;
			g_iPainterColor[client] = 1;
			
		}
		else if ( strcmp(info,"green") == 0 ) 
		{
			if(!g_bPainter[client]) CPrintToChat(client, "%t %t", "warden_tag", "warden_painteron");
			CPrintToChat(client, "%t %t", "warden_tag", "warden_painter", g_sColorNamesGreen);
			g_bPainter[client] = true;
			g_bPainterColorRainbow[client] = false;
			g_iPainterColor[client] = 2;
			
		}
		else if ( strcmp(info,"blue") == 0 ) 
		{
			if(!g_bPainter[client]) CPrintToChat(client, "%t %t", "warden_tag", "warden_painteron");
			CPrintToChat(client, "%t %t", "warden_tag", "warden_painter", g_sColorNamesBlue);
			g_bPainter[client] = true;
			g_bPainterColorRainbow[client] = false;
			g_iPainterColor[client] = 3;
			
		}
		else if ( strcmp(info,"yellow") == 0 ) 
		{
			if(!g_bPainter[client]) CPrintToChat(client, "%t %t", "warden_tag", "warden_painteron");
			CPrintToChat(client, "%t %t", "warden_tag", "warden_painter", g_sColorNamesYellow);
			g_bPainter[client] = true;
			g_bPainterColorRainbow[client] = false;
			g_iPainterColor[client] = 4;
			
		}
		else if ( strcmp(info,"cyan") == 0 ) 
		{
			if(!g_bPainter[client]) CPrintToChat(client, "%t %t", "warden_tag", "warden_painteron");
			CPrintToChat(client, "%t %t", "warden_tag", "warden_painter", g_sColorNamesCyan);
			g_bPainter[client] = true;
			g_bPainterColorRainbow[client] = false;
			g_iPainterColor[client] = 5;
			
		}
		else if ( strcmp(info,"magenta") == 0 ) 
		{
			if(!g_bPainter[client]) CPrintToChat(client, "%t %t", "warden_tag", "warden_painteron");
			CPrintToChat(client, "%t %t", "warden_tag", "warden_painter", g_sColorNamesMagenta);
			g_bPainter[client] = true;
			g_bPainterColorRainbow[client] = false;
			g_iPainterColor[client] = 6;
			
		}
		else if ( strcmp(info,"orange") == 0 ) 
		{
			if(!g_bPainter[client]) CPrintToChat(client, "%t %t", "warden_tag", "warden_painteron");
			CPrintToChat(client, "%t %t", "warden_tag", "warden_painter", g_sColorNamesOrange);
			g_bPainter[client] = true;
			g_bPainterColorRainbow[client] = false;
			g_iPainterColor[client] = 7;
			
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

//Laser painter

public Action TogglePainterT(int client, int args)
{
	if (gc_bPainterT.BoolValue) 
	{
		if (client == g_iWarden)
		{
			if (!g_bPainterT) 
			{
				g_bPainterT = true;
				CPrintToChatAll("%t %t", "warden_tag", "warden_tpainteron");
				
				LoopValidClients(iClient, false, true)
				{
					if (GetClientTeam(iClient) == CS_TEAM_T) Command_PainterMenu(iClient,0);
				}
			}
			else
			{
				LoopValidClients(iClient, false, true)
				{
					if (GetClientTeam(iClient) == CS_TEAM_T)
					{
						g_fLastPainter[iClient][0] = 0.0;
						g_fLastPainter[iClient][1] = 0.0;
						g_fLastPainter[iClient][2] = 0.0;
						g_bPainterUse[iClient] = false;
					}
				}
				g_bPainterT = false;
				CPrintToChatAll("%t %t", "warden_tag", "warden_tpainteroff");
			}
		}
	}
}

public Action Print_Painter(Handle timer)
{
	float g_fPos[3];

	for(int Y = 1; Y <= MaxClients; Y++) 
	{
		if(g_bPainterColorRainbow[Y]) g_iPainterColor[Y] = GetRandomInt(0,6);
		if(IsClientInGame(Y) && g_bPainterUse[Y])
		{
			TraceEye(Y, g_fPos);
			if(GetVectorDistance(g_fPos, g_fLastPainter[Y]) > 6.0) {
				Connect_Painter(g_fLastPainter[Y], g_fPos, g_iColors[g_iPainterColor[Y]]);
				g_fLastPainter[Y][0] = g_fPos[0];
				g_fLastPainter[Y][1] = g_fPos[1];
				g_fLastPainter[Y][2] = g_fPos[2];
			}
		} 
	}
}
stock void OnButtonPress(int client,int button)
{
	if(button == IN_USE)
	{
		TraceEye(client, g_fLastPainter[client]);
		g_bPainterUse[client] = true;
	}
}

stock void OnButtonRelease(int client,int button)
{
	if(button == IN_USE)
	{
		g_fLastPainter[client][0] = 0.0;
		g_fLastPainter[client][1] = 0.0;
		g_fLastPainter[client][2] = 0.0;
		g_bPainterUse[client] = false;
	}
}
public Action Connect_Painter(float start[3], float end[3],int color[4])
{
	TE_SetupBeamPoints(start, end, g_iBeamSprite, 0, 0, 0, 25.0, 2.0, 2.0, 10, 0.0, color, 0);
	TE_SendToAll();
}
public Action TraceEye(int client, float g_fPos[3]) 
{
	float vAngles[3], vOrigin[3];
	GetClientEyePosition(client, vOrigin);
	GetClientEyeAngles(client, vAngles);
	TR_TraceRayFilter(vOrigin, vAngles, MASK_SHOT, RayType_Infinite, TraceEntityFilterPlayer);
	if(TR_DidHit(INVALID_HANDLE)) TR_GetEndPosition(g_fPos, INVALID_HANDLE);
	return;
}
public bool TraceEntityFilterPlayer(int entity, int contentsMask) {
	return (entity > GetMaxClients() || !entity);
}

//Icon

stock int SpawnIcon(int client) 
{
	if(!IsClientInGame(client) || !IsPlayerAlive(client) || !gc_bIcon.BoolValue) return -1;
	
	char iTarget[16];
	Format(iTarget, 16, "client%d", client);
	DispatchKeyValue(client, "targetname", iTarget);

	g_iIcon[client] = CreateEntityByName("env_sprite");

	if(!g_iIcon[client]) return -1;
	char iconbuffer[256];
	Format(iconbuffer, sizeof(iconbuffer), "materials/%s.vmt", g_sIconPath);
	
	DispatchKeyValue(g_iIcon[client], "model", iconbuffer);
	DispatchKeyValue(g_iIcon[client], "classname", "env_sprite");
	DispatchKeyValue(g_iIcon[client], "spawnflags", "1");
	DispatchKeyValue(g_iIcon[client], "scale", "0.3");
	DispatchKeyValue(g_iIcon[client], "rendermode", "1");
	DispatchKeyValue(g_iIcon[client], "rendercolor", "255 255 255");
	DispatchSpawn(g_iIcon[client]);
	
	float origin[3];
	GetClientAbsOrigin(client, origin);
	origin[2] = origin[2] + 90.0;
	
	TeleportEntity(g_iIcon[client], origin, NULL_VECTOR, NULL_VECTOR);
	SetVariantString(iTarget);
	AcceptEntityInput(g_iIcon[client], "SetParent", g_iIcon[client], g_iIcon[client], 0);
	SDKHook(g_iIcon[client], SDKHook_SetTransmit, Should_Transmit);
	return g_iIcon[client];
} 

public Action Should_Transmit(int entity, int client)
{
	char m_ModelName[PLATFORM_MAX_PATH];
	char iconbuffer[256];
	Format(iconbuffer, sizeof(iconbuffer), "materials/%s.vmt", g_sIconPath);
	GetEntPropString(entity, Prop_Data, "m_ModelName", m_ModelName, sizeof(m_ModelName));
	if (StrEqual( iconbuffer, m_ModelName))
		return Plugin_Continue;
	return Plugin_Handled;
}

stock void RemoveIcon(int client) 
{
	if(g_iIcon[client] > 0 && IsValidEdict(g_iIcon[client]))
	{
		AcceptEntityInput(g_iIcon[client], "Kill");
		g_iIcon[client] = -1;
	}
}





//choose random warden

public Action ChooseRandom(Handle timer, Handle pack)
{
	if(gc_bPlugin.BoolValue)
	{
		if(warden_exist() != 1)
		{
			if(gc_bChooseRandom.BoolValue)
			{
				int i = GetRandomPlayer(CS_TEAM_CT);
				if(i > 0)
				{
					CPrintToChatAll("%t %t", "warden_tag", "warden_randomwarden"); 
					SetTheWarden(i);
				}
			}
		}
	}
	if (RandomTimer != null)
		KillTimer(RandomTimer);
			
	RandomTimer = null;
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
				if(!g_bAllowDrop && !IsClientInLastRequest(client))
				{
					if (g_bWeaponDropped[client]) 
						return Plugin_Handled;
						
					if(gc_bGunNoDrop.BoolValue)
						return Plugin_Handled;
						
				//	g_iWeaponDrop[client] = weapon;
					
					Handle hData = CreateDataPack();
					WritePackCell(hData, client);
					WritePackCell(hData, weapon);
					
					
					
					if(IsValidEntity(weapon))
					{
						if (!g_bWeaponDropped[client]) CreateTimer(0.1, DroppedWeapon, hData, TIMER_FLAG_NO_MAPCHANGE);
					}
				}
			}
		}
	}
	return Plugin_Continue;
}

public Action DroppedWeapon(Handle timer, Handle hData)
{
	ResetPack(hData);
	int client = ReadPackCell(hData);
	int iWeapon = ReadPackCell(hData);
	
	if(IsValidEdict(iWeapon))
	{
		if (Entity_GetOwner(iWeapon) == -1)
		{
			if(IsValidClient(client, false, false))  // && !IsClientInLastRequest(client)
			{
				char g_sWeaponName[80];
				
				GetEntityClassname(iWeapon, g_sWeaponName, sizeof(g_sWeaponName));
				ReplaceString(g_sWeaponName, sizeof(g_sWeaponName), "weapon_", "", false); 
				g_bWeaponDropped[client] = true;
				
				Handle hData2 = CreateDataPack();
				WritePackCell(hData2, client);
				WritePackCell(hData2, iWeapon);
				
				CPrintToChat(client, "%t %t", "warden_tag" , "warden_noplant", client , g_sWeaponName);
				if(g_iWarden != -1) CPrintToChat(g_iWarden, "%t %t", "warden_tag" , "warden_gunplant", client , g_sWeaponName);
				if((g_iWarden != -1) && gc_bBetterNotes.BoolValue) PrintHintText(g_iWarden, "%t", "warden_gunplant_nc", client , g_sWeaponName);
				if(gc_bGunRemove.BoolValue) CreateTimer(gc_fGunRemoveTime.FloatValue, RemoveWeapon, hData2, TIMER_FLAG_NO_MAPCHANGE);
				if(gc_bGunSlap.BoolValue) SlapPlayer(client, gc_iGunSlapDamage.IntValue, true);
			}
		}
	}
}

public Action RemoveWeapon(Handle timer, Handle hData2)
{
	ResetPack(hData2);
	int client = ReadPackCell(hData2);
	int iWeapon = ReadPackCell(hData2);
	
	if(IsValidEdict(iWeapon))
	{
		if (Entity_GetOwner(iWeapon) == -1)
		{
			AcceptEntityInput(iWeapon, "Kill");
		}
	}
	g_bWeaponDropped[client] = false;
}

public Action AllowDropTimer(Handle timer)
{
	g_bAllowDrop = false;
}

//Natives, Forwards & stocks

public int OnAvailableLR(int Announced)
{
	IsLR = true;
	g_bAllowDrop = true;
	Mute_OnAvailableLR(Announced);
	HandCuffs_OnAvailableLR(Announced);
}

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


public Action OnTakedamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom)
{
	if(!IsValidClient(victim, true, false) || attacker == victim || !IsValidClient(attacker, true, false)) return Plugin_Continue;
	
	char sWeapon[32];
	if(IsValidEntity(weapon)) GetEntityClassname(weapon, sWeapon, sizeof(sWeapon));
	
	//Backstab protection
	
	if(gc_bBackstab.BoolValue && IsClientInGame(attacker) && IsClientWarden(victim) && !IsClientInLastRequest(victim) && CheckVipFlag(victim,g_sAdminFlagBackstab))
	{
		if((StrEqual(sWeapon, "weapon_knife", false)) && (damage > 99.0))
		{
			if (gc_iBackstabNumber.IntValue == 0)
			{
				PrintCenterText(attacker,"%t", "warden_backstab");
				return Plugin_Handled;
			}
			else if (g_iBackstabNumber[victim] > 0)
			{
				PrintCenterText(attacker,"%t", "warden_backstab");
				g_iBackstabNumber[victim]--;
				return Plugin_Handled;
			}
		}
	}
	return Plugin_Handled;
}

