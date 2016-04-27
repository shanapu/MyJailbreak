//Includes
#include <sourcemod>
#include <sdktools>
#include <cstrike>
#include <sdkhooks>
#include <wardn>
#include <emitsoundany>
#include <smartjaildoors>
#include <colors>
#include <autoexecconfig>
#include <myjailbreak>
#include <scp>

//Compiler Options
#pragma semicolon 1
#pragma newdecls required

//Defines
#define SOUND_THUNDER "ambient/weather/thunder3.wav"
#define PLUS				"+"
#define MINUS				"-"
#define DIVISOR				"/"
#define MULTIPL				"*"

//Bools
bool IsCountDown = false;
bool IsMathQuiz = false;

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
ConVar gc_bRandom;
ConVar gc_bMath;
ConVar gc_bMarker;
ConVar gc_iMarkerKey;
ConVar gc_fMarkerTime;
ConVar gc_bCountDown;
ConVar gc_bOverlays;
ConVar gc_sOverlayStartPath;
ConVar gc_sOverlayStopPath;
ConVar gc_sWarden;
ConVar gc_sUnWarden;
ConVar gc_sSoundStartPath;
ConVar gc_sStop;
//ConVar gc_sModelPath;
//ConVar gc_bModel;

ConVar gc_bBetterNotes;
ConVar g_bFF;
ConVar gc_iMinimumNumber;
ConVar gc_iMaximumNumber;
ConVar gc_iTimeAnswer;
ConVar gc_iWardenColorRed;
ConVar gc_iWardenColorGreen;
ConVar gc_iWardenColorBlue;


//Integers
int g_iVoteCount;
int Warden = -1;
int tempwarden[MAXPLAYERS+1] = -1;
int g_CollisionOffset;
int opentimer;
int randomtime;
int g_iCountStartTime = 9;
int g_iCountStopTime = 9;
int g_MarkerColor[] = {255,1,1,255};
int g_iBeamSprite = -1;
int g_iHaloSprite = -1;
int g_iSetCountStartStopTime;
int g_SmokeSprite;
int g_LightningSprite;
int g_MathMin;
int g_MathMax;
int g_MathResult;

//Handles
Handle g_fward_onBecome;
Handle g_fward_onRemove;
Handle gF_OnWardenCreatedByUser = null;
Handle gF_OnWardenCreatedByAdmin = null;
Handle gF_OnWardenDisconnected = null;
Handle gF_OnWardenDeath = null;
Handle gF_OnWardenRemovedBySelf = null;
Handle gF_OnWardenRemovedByAdmin = null;
Handle g_hOpenTimer=null;
Handle g_hRandomTimer=null;
Handle opencountertime = null;
Handle randomtimer = null;
Handle mathtimer = null;
Handle StartTimer = null;
Handle StopTimer = null;
Handle StartStopTimer = null;

//Strings
char g_sHasVoted[1500];
//char g_sModelPath[256]; // change model back on unwarden
//char g_sWardenModel[256];
char g_sUnWarden[256];
char g_sWarden[256];
char g_sSoundStartPath[256];
char g_sStop[256];
char g_sOverlayStop[256];
char g_op[32];
char g_operators[4][2] = {"+", "-", "/", "*"};

//float
float g_fMakerPos[3];


public Plugin myinfo = {
	name = "MyJailbreak - Warden",
	author = "shanapu, ecca, ESKO & .#zipcore",
	description = "Jailbreak Warden script",
	version = PLUGIN_VERSION,
	url = "shanapu.de"
};

public void OnPluginStart() 
{
	//Translation
	LoadTranslations("MyJailbreak.Warden.phrases");
	
	//Client commands
	RegConsoleCmd("sm_noblockon", noblockon, "Allows the Warden to enable no block"); 
	RegConsoleCmd("sm_noblockoff", noblockoff, "Allows the Warden to disable no block"); 
	RegConsoleCmd("sm_w", BecomeWarden, "Allows the player taking the charge over prisoners");
	RegConsoleCmd("sm_warden", BecomeWarden, "Allows the player taking the charge over prisoners");
	RegConsoleCmd("sm_uw", ExitWarden, "Allows the player to retire from the position");
	RegConsoleCmd("sm_unwarden", ExitWarden, "Allows the player to retire from the position");
	RegConsoleCmd("sm_hg", BecomeWarden, "Allows the player taking the charge over prisoners");
	RegConsoleCmd("sm_headguard", BecomeWarden, "Allows the player taking the charge over prisoners");
	RegConsoleCmd("sm_uhg", ExitWarden, "Allows the player to retire from the position");
	RegConsoleCmd("sm_unheadguard", ExitWarden, "Allows the player to retire from the position");
	RegConsoleCmd("sm_c", BecomeWarden, "Allows the player taking the charge over prisoners");
	RegConsoleCmd("sm_commander", BecomeWarden, "Allows the player taking the charge over prisoners");
	RegConsoleCmd("sm_uc", ExitWarden, "Allows the player to retire from the position");
	RegConsoleCmd("sm_uncommander", ExitWarden, "Allows the player to retire from the position");
	RegConsoleCmd("sm_open", OpenDoors, "Allows the Warden to open the cell doors");
	RegConsoleCmd("sm_close", CloseDoors, "Allows the Warden to close the cell doors");
	RegConsoleCmd("sm_vw", VoteWarden, "Allows the player to vote to retire Warden");
	RegConsoleCmd("sm_votewarden", VoteWarden, "Allows the player to vote to retire Warden");
	RegConsoleCmd("sm_setff", ToggleFF, "Allows player to see the state and the Warden to toggle friendly fire");
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
	AutoExecConfig_SetFile("MyJailbreak.Warden");
	AutoExecConfig_SetCreateFile(true);
	
	AutoExecConfig_CreateConVar("sm_warden_version", PLUGIN_VERSION, "The version of this MyJailBreak SourceMod plugin", FCVAR_SPONLY|FCVAR_PLUGIN|FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_DONTRECORD);
	gc_bPlugin = AutoExecConfig_CreateConVar("sm_warden_enable", "1", "0 - disabled, 1 - enable this MyJailBreak SourceMod plugin", _, true,  0.0, true, 1.0);
	gc_bBecomeWarden = AutoExecConfig_CreateConVar("sm_warden_become", "1", "0 - disabled, 1 - enable !w... - player can choose to be warden", _, true,  0.0, true, 1.0);
	gc_bChooseRandom = AutoExecConfig_CreateConVar("sm_warden_choose_random", "1", "0 - disabled, 1 - enable pic random warden if there is still no warden after sm_warden_choose_time", _, true,  0.0, true, 1.0);
	g_hRandomTimer = AutoExecConfig_CreateConVar("sm_warden_choose_time", "20", "Time in seconds a random warden will picked when no warden was set. need sm_warden_choose_random 1", _, true,  1.0);
	gc_bVote = AutoExecConfig_CreateConVar("sm_warden_vote", "1", "0 - disabled, 1 - enable player vote against warden", _, true,  0.0, true, 1.0);
	gc_bStayWarden = AutoExecConfig_CreateConVar("sm_warden_stay", "1", "0 - disabled, 1 - enable warden stay after round end", _, true,  0.0, true, 1.0);
	gc_bBetterNotes = AutoExecConfig_CreateConVar("sm_warden_better_notifications", "1", "0 - disabled, 1 - Will use hint and center text", _, true, 0.0, true, 1.0);
	gc_bNoBlock = AutoExecConfig_CreateConVar("sm_warden_noblock", "1", "0 - disabled, 1 - enable setable noblock for warden", _, true,  0.0, true, 1.0);
	gc_bFF = AutoExecConfig_CreateConVar("sm_warden_ff", "1", "0 - disabled, 1 - enable switch ff for T ", _, true,  0.0, true, 1.0);
	gc_bRandom = AutoExecConfig_CreateConVar("sm_warden_random", "1", "0 - disabled, 1 - enable kill a random t for warden", _, true,  0.0, true, 1.0);
	gc_bMarker = AutoExecConfig_CreateConVar("sm_warden_marker", "1", "0 - disabled, 1 - enable Warden simple markers ", _, true,  0.0, true, 1.0);
	gc_iMarkerKey = AutoExecConfig_CreateConVar("sm_warden_markerkey", "3", "1 - Look weapon / 2 - Use and shoot / 3 - walk and shoot", _, true,  1.0, true, 3.0);
	gc_fMarkerTime = AutoExecConfig_CreateConVar("sm_warden_marker_time", "20.0", "Time in seconds marker will disappears", _, true,  1.0);
	gc_bCountDown = AutoExecConfig_CreateConVar("sm_warden_countdown", "1", "0 - disabled, 1 - enable countdown for warden", _, true,  0.0, true, 1.0);
	gc_bOverlays = AutoExecConfig_CreateConVar("sm_warden_overlays_enable", "1", "0 - disabled, 1 - enable overlays", _, true,  0.0, true, 1.0);
	gc_sOverlayStartPath = AutoExecConfig_CreateConVar("sm_warden_overlays_start", "overlays/MyJailbreak/start" , "Path to the start Overlay DONT TYPE .vmt or .vft");
	gc_sOverlayStopPath = AutoExecConfig_CreateConVar("sm_warden_overlays_stop", "overlays/MyJailbreak/stop" , "Path to the stop Overlay DONT TYPE .vmt or .vft");
	gc_bOpen = AutoExecConfig_CreateConVar("sm_warden_open_enable", "1", "0 - disabled, 1 - warden can open/close cells", _, true,  0.0, true, 1.0);
	g_hOpenTimer = AutoExecConfig_CreateConVar("sm_warden_open_time", "60", "Time in seconds for open doors on round start automaticly", _, true, 0.0); 
	gc_bOpenTimer = AutoExecConfig_CreateConVar("sm_warden_open_time_enable", "1", "should doors open automatic 0- no 1 yes", _, true,  0.0, true, 1.0); //todo dont wokr
	gc_bOpenTimerWarden = AutoExecConfig_CreateConVar("sm_warden_open_time_warden", "1", "should doors open automatic after sm_warden_open_time when there is a warden? needs sm_warden_open_time_enable 1", _, true,  0.0, true, 1.0);
	gc_bColor = AutoExecConfig_CreateConVar("sm_warden_color_enable", "1", "0 - disabled, 1 - enable warden colored", _, true,  0.0, true, 1.0);
	gc_bMath = AutoExecConfig_CreateConVar("sm_warden_math", "1", "0 - disabled, 1 - enable mathquiz for warden", _, true,  0.0, true, 1.0);
	gc_iMinimumNumber = AutoExecConfig_CreateConVar("sm_warden_math_min", "1", "What should be the minimum number for questions ?", _, true,  1.0);
	gc_iMaximumNumber = AutoExecConfig_CreateConVar("sm_warden_math_max", "100", "What should be the maximum number for questions ?", _, true,  2.0);
	gc_iTimeAnswer = AutoExecConfig_CreateConVar("sm_warden_math_time", "10", "Time in seconds to give a answer to a question.", _, true,  3.0);
	gc_iWardenColorRed = AutoExecConfig_CreateConVar("sm_warden_color_red", "0","What color to turn the warden into (set R, G and B values to 255 to disable) (Rgb): x - red value", _, true, 0.0, true, 255.0);
	gc_iWardenColorGreen = AutoExecConfig_CreateConVar("sm_warden_color_green", "0","What color to turn the warden into (rGb): x - green value", _, true, 0.0, true, 255.0);
	gc_iWardenColorBlue = AutoExecConfig_CreateConVar("sm_warden_color_blue", "255","What color to turn the warden into (rgB): x - blue value", _, true, 0.0, true, 255.0);
	gc_bSounds = AutoExecConfig_CreateConVar("sm_warden_sounds_enable", "1", "0 - disabled, 1 - enable sounds ", _, true,  0.0, true, 1.0);
	gc_sWarden = AutoExecConfig_CreateConVar("sm_warden_sounds_warden", "music/myjailbreak/warden.mp3", "Path to the soundfile which should be played for a int warden.");
	gc_sUnWarden = AutoExecConfig_CreateConVar("sm_warden_sounds_unwarden", "music/myjailbreak/unwarden.mp3", "Path to the soundfile which should be played when there is no warden anymore.");
	gc_sSoundStartPath = AutoExecConfig_CreateConVar("sm_warden_sounds_start", "music/myjailbreak/start.mp3", "Path to the soundfile which should be played for a start countdown.");
	gc_sStop = AutoExecConfig_CreateConVar("sm_warden_sounds_stop", "music/myjailbreak/stop.mp3", "Path to the soundfile which should be played for stop countdown.");
//	gc_bModel = AutoExecConfig_CreateConVar("sm_warden_model", "1", "0 - disabled, 1 - enable warden model", 0, true, 0.0, true, 1.0);
//	gc_sModelPath = AutoExecConfig_CreateConVar("sm_warden_model_path", "models/player/custom_player/legacy/security.mdl", "Path to the model for zombies.");
	
	AutoExecConfig_ExecuteFile();
	AutoExecConfig_CleanFile();
	
	//Hooks
	HookEvent("round_start", RoundStart);
	HookEvent("player_death", playerDeath);
	HookEvent("bullet_impact", Event_BulletImpact);
	HookEvent("round_end", RoundEnd);
//	HookConVarChange(gc_sModelPath, OnSettingChanged);
	HookConVarChange(gc_sUnWarden, OnSettingChanged);
	HookConVarChange(gc_sWarden, OnSettingChanged);
	HookConVarChange(gc_sSoundStartPath, OnSettingChanged);
	HookConVarChange(gc_sStop, OnSettingChanged);
	HookConVarChange(gc_sOverlayStartPath, OnSettingChanged);
	HookConVarChange(gc_sOverlayStopPath, OnSettingChanged);
	
	//FindConVar
	g_bFF = FindConVar("mp_teammates_are_enemies");
	gc_sWarden.GetString(g_sWarden, sizeof(g_sWarden));
	gc_sUnWarden.GetString(g_sUnWarden, sizeof(g_sUnWarden));
	gc_sSoundStartPath.GetString(g_sSoundStartPath, sizeof(g_sSoundStartPath));
	gc_sStop.GetString(g_sStop, sizeof(g_sStop));
//	gc_sModelPath.GetString(g_sWardenModel, sizeof(g_sWardenModel));
	gc_sOverlayStartPath.GetString(g_sOverlayStart , sizeof(g_sOverlayStart));
	gc_sOverlayStopPath.GetString(g_sOverlayStop , sizeof(g_sOverlayStop));
	
//	AddCommandListener(HookPlayerChat, "say");
	AddCommandListener(Command_LAW, "+lookatweapon");
	
	g_CollisionOffset = FindSendPropInfo("CBaseEntity", "m_CollisionGroup");
	
	g_iVoteCount = 0;
	
	CreateTimer(1.0, Timer_DrawMakers, _, TIMER_REPEAT);
}

public void RoundStart(Event event, const char[] name, bool dontBroadcast)
{
	if (opencountertime != null)
		KillTimer(opencountertime);
		
	opencountertime = null;
	
	if (randomtimer != null)
		KillTimer(randomtimer);
			
	randomtimer = null;
	
	if(gc_bPlugin.BoolValue)	
	{
		opentimer = GetConVarInt(g_hOpenTimer);
		opencountertime = CreateTimer(1.0, OpenCounter, _, TIMER_REPEAT);
		randomtime = GetConVarInt(g_hRandomTimer);
		randomtimer = CreateTimer(1.0, ChooseRandom, _, TIMER_REPEAT);
	}
	else
	{
			Warden = -1;
	}
	if(!gc_bStayWarden.BoolValue)
	{
			Warden = -1;
	}
}

public void OnConfigsExecuted()
{
	g_MathMin = gc_iMinimumNumber.IntValue;
	g_MathMax = gc_iMaximumNumber.IntValue;
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
		PrecacheSoundAnyDownload(g_sStop);
		PrecacheSoundAnyDownload(g_sSoundStartPath);
	}	
	g_iVoteCount = 0;
//	PrecacheModel(g_sWardenModel);
//	PrecacheModel("models/player/ctm_gsg9.mdl");
	if(gc_bOverlays.BoolValue) PrecacheOverlayAnyDownload(g_sOverlayStart);
	if(gc_bOverlays.BoolValue) PrecacheOverlayAnyDownload(g_sOverlayStop);
	g_iBeamSprite = PrecacheModel("materials/sprites/laserbeam.vmt");
	g_iHaloSprite = PrecacheModel("materials/sprites/glow01.vmt");
	g_SmokeSprite = PrecacheModel("materials/sprites/steam1.vmt");
	g_LightningSprite = g_iBeamSprite;
	PrecacheSound(SOUND_THUNDER, true);
}

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
	else if(convar == gc_sStop)
	{
		strcopy(g_sStop, sizeof(g_sStop), newValue);
		if(gc_bSounds.BoolValue) PrecacheSoundAnyDownload(g_sStop);
	}
	else if(convar == gc_sOverlayStartPath)
	{
		strcopy(g_sOverlayStart, sizeof(g_sOverlayStart), newValue);
		if(gc_bOverlays.BoolValue) PrecacheOverlayAnyDownload(g_sOverlayStart);
	}
	else if(convar == gc_sOverlayStopPath)
	{
		strcopy(g_sOverlayStop, sizeof(g_sOverlayStop), newValue);
		if(gc_bOverlays.BoolValue) PrecacheOverlayAnyDownload(g_sOverlayStop);
	}
	//else if(convar == gc_sModelPath)
	//{
	//	strcopy(g_sWardenModel, sizeof(g_sWardenModel), newValue);
	//	PrecacheModel(g_sWardenModel);
	//}
}

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
		for(int client=1; client <= MaxClients; client++) if(IsValidClient(client, true))
		{
			EnableBlock(client);
			CancelCountDown(client, 0);
		}
	}
	if (StopTimer != null) KillTimer(StopTimer);
	if (StartTimer != null) KillTimer(StartTimer);
	if (StartStopTimer != null) KillTimer(StartStopTimer);

}

public Action BecomeWarden(int client, int args)
{
	if(gc_bPlugin.BoolValue)
	{
		if (Warden == -1)
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
			else CPrintToChat(client, "%t %t", "warden_tag" , "warden_nobecome", Warden);
		}
		else CPrintToChat(client, "%t %t", "warden_tag" , "warden_exist", Warden);
	}
	else CPrintToChat(client, "%t %t", "warden_tag" , "warden_disabled");
}

public Action ExitWarden(int client, int args) 
{
	if(gc_bPlugin.BoolValue)
	{
		if(client == Warden)
		{
			CPrintToChatAll("%t %t", "warden_tag" , "warden_retire", client);
			
			if(gc_bBetterNotes.BoolValue)
			{
				PrintCenterTextAll("%t", "warden_retire_nc", client);
				PrintHintTextToAll("%t", "warden_retire_nc", client);
			}
			Warden = -1;
			Forward_OnWardenRemoved(client);
			SetEntityRenderColor(client, 255, 255, 255, 255);
			randomtime = GetConVarInt(g_hRandomTimer);
			randomtimer = CreateTimer(1.0, ChooseRandom, _, TIMER_REPEAT);
//			SetEntityModel(client, "models/player/ctm_gsg9.mdl");
			if(gc_bSounds.BoolValue)	
			{
				EmitSoundToAllAny(g_sUnWarden);
			}
			ResetMarker();
			g_iVoteCount = 0;
			Format(g_sHasVoted, sizeof(g_sHasVoted), "");
			g_sHasVoted[0] = '\0';
		}
		else CPrintToChat(client, "%t %t", "warden_tag" , "warden_notwarden");
	}
	else CPrintToChat(client, "%t %t", "warden_tag" , "warden_disabled");
}

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

public void playerDeath(Event event, const char[] name, bool dontBroadcast) 
{
	int client = GetClientOfUserId(GetEventInt(event, "userid")); // Get the dead clients id
	
	if(client == Warden) // Aww damn , he is the warden
	{
		if(gc_bSounds.BoolValue)
		{
			EmitSoundToAllAny(g_sUnWarden);
		}
		CPrintToChatAll("%t %t", "warden_tag" , "warden_dead", client);
		
		if(gc_bBetterNotes.BoolValue)
		{
			PrintCenterTextAll("%t", "warden_dead_nc", client);
			PrintHintTextToAll("%t", "warden_dead_nc", client);
		}
		randomtime = GetConVarInt(g_hRandomTimer);
		randomtimer = CreateTimer(1.0, ChooseRandom, _, TIMER_REPEAT);
		Warden = -1;
		Call_StartForward(gF_OnWardenDeath);
		Call_PushCell(client);
		Call_Finish();
	}
}

public Action SetWarden(int client,int args)
{
	if(gc_bPlugin.BoolValue)	
	{
		if(IsValidClient(client))
		{
			char info1[255];
			Menu menu = CreateMenu(m_SetWarden);
			Format(info1, sizeof(info1), "%T", "warden_choose", LANG_SERVER);
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
			menu.ExitButton = true;
			menu.Display(client,MENU_TIME_FOREVER);
		}
	}
	return Plugin_Handled;
}

public int m_SetWarden(Menu menu, MenuAction action, int client, int Position)
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
						tempwarden[client] = userid;
						Menu menu1 = CreateMenu(m_WardenOverwrite);
						Format(info4, sizeof(info4), "%T", "warden_remove", Warden, LANG_SERVER);
						menu1.SetTitle(info4);
						Format(info3, sizeof(info3), "%T", "warden_yes", LANG_SERVER);
						Format(info2, sizeof(info2), "%T", "warden_no", LANG_SERVER);
						menu1.AddItem("1", info3);
						menu1.AddItem("0", info2);
						menu1.ExitButton = false;
						menu1.Display(client,MENU_TIME_FOREVER);
					}
					else
					{
						Warden = i;
						CPrintToChatAll("%t %t", "warden_tag" , "warden_new", i);
		
						if(gc_bBetterNotes.BoolValue)
						{
							PrintCenterTextAll("%t", "warden_new_nc", i);
							PrintHintTextToAll("%t", "warden_new_nc", i);
						}
						CreateTimer(0.5, Timer_WardenFixColor, i, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
						Call_StartForward(gF_OnWardenCreatedByAdmin);
						Call_PushCell(i);
						Call_Finish();
					}
				}
			}
		}
	}
}

public int m_WardenOverwrite(Menu menu, MenuAction action, int client, int Position)
{
	if(action == MenuAction_Select)
	{
		char Item[11];
		menu.GetItem(Position,Item,sizeof(Item));
		int choice = StringToInt(Item);
		if(choice == 1)
		{
			int newwarden = GetClientOfUserId(tempwarden[client]);
			CPrintToChatAll("%t %t", "warden_tag" , "warden_removed", client, Warden);
			CPrintToChatAll("%t %t", "warden_tag" , "warden_new", newwarden);
		
			if(gc_bBetterNotes.BoolValue)
			{
				PrintCenterTextAll("%t", "warden_new_nc", newwarden);
				PrintHintTextToAll("%t", "warden_new_nc", newwarden);
			}
			Warden = newwarden;
			CreateTimer(0.5, Timer_WardenFixColor, newwarden, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
			Call_StartForward(gF_OnWardenCreatedByAdmin);
			Call_PushCell(newwarden);
			Call_Finish();
		}
	}
}

public Action Timer_WardenFixColor(Handle timer,any client)
{
	if(IsValidClient(client, true))
	{
		int iWardenColorRed;								// Need this way on new syntax ? 				
		int iWardenColorGreen;								// Need this way on new syntax ? 	
		int iWardenColorBlue;								// Need this way on new syntax ? 	
		iWardenColorRed = gc_iWardenColorRed.IntValue;		// Need this way on new syntax ? 	
		iWardenColorGreen = gc_iWardenColorGreen.IntValue;	// Need this way on new syntax ? 	
		iWardenColorBlue = gc_iWardenColorBlue.IntValue;	// Need this way on new syntax ? 		

		if(IsClientWarden(client))
		{
			if(gc_bPlugin.BoolValue)	
			{ 
				if(gc_bColor.BoolValue)	
				{
					SetEntityRenderColor(client, iWardenColorRed, iWardenColorGreen, iWardenColorBlue, 255);
				}
//				if(gc_bModel.BoolValue)
//				{
//					//GetClientModel(client, g_sModelPath, sizeof(g_sModelPath));
//					//GetEntPropString(client, Prop_Data, "m_ModelName",g_sModelPath, sizeof(g_sModelPath));
//					SetEntityModel(client, g_sWardenModel);
//				}
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

public Action playerTeam(Handle event, const char[] name, bool dontBroadcast) 
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	if(client == Warden)
		RemoveTheWarden(client);
}

public void OnClientDisconnect(int client)
{
	if(client == Warden)
	{
		CPrintToChatAll("%t %t", "warden_tag" , "warden_disconnected");
		
		if(gc_bBetterNotes.BoolValue)
		{
			PrintCenterTextAll("%t", "warden_disconnected_nc", client);
			PrintHintTextToAll("%t", "warden_disconnected_nc", client);
		}
		
		Warden = -1;
		Forward_OnWardenRemoved(client);
		Call_StartForward(gF_OnWardenDisconnected);
		Call_PushCell(client);
		Call_Finish();
		if(gc_bSounds.BoolValue)	
		{
			EmitSoundToAllAny(g_sUnWarden);
		}
		ResetMarker();
	}
}

public Action RemoveWarden(int client, int args)
{
	if(Warden != -1)
	{
		RemoveTheWarden(client);
		Call_StartForward(gF_OnWardenRemovedByAdmin);
		Call_PushCell(client);
		Call_Finish();
		
	}
//	else CPrintToChatAll("%t %t", "warden_tag" , "warden_noexist");
	return Plugin_Handled;
	}


void SetTheWarden(int client)
{
	if(gc_bPlugin.BoolValue)	
	{
		CPrintToChatAll("%t %t", "warden_tag" , "warden_new", client);
		
		if(gc_bBetterNotes.BoolValue)
		{
			PrintCenterTextAll("%t", "warden_new_nc", client);
			PrintHintTextToAll("%t", "warden_new_nc", client);
		}
		Warden = client;
		CreateTimer(0.5, Timer_WardenFixColor, client, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
		SetClientListeningFlags(client, VOICE_NORMAL);
		Forward_OnWardenCreation(client);
		if(gc_bSounds.BoolValue)	
		{
			EmitSoundToAllAny(g_sWarden);
		}
		ResetMarker();
	}
	else CPrintToChat(client, "%t %t", "warden_tag" , "warden_disabled");
}

void RemoveTheWarden(int client)
{
	CPrintToChatAll("%t %t", "warden_tag" , "warden_removed", client, Warden);
	
	if(gc_bBetterNotes.BoolValue)
	{
		PrintCenterTextAll("%t", "warden_removed_nc", client, Warden);
		PrintHintTextToAll("%t", "warden_removed_nc", client, Warden);
	}
	
	if(IsClientInGame(client) && IsPlayerAlive(client))
	{
		SetEntityRenderColor(Warden, 255, 255, 255, 255);
	//	SetEntityModel(client, "models/player/ctm_gsg9.mdl");
		Warden = -1;
		randomtime = GetConVarInt(g_hRandomTimer);
		randomtimer = CreateTimer(1.0, ChooseRandom, _, TIMER_REPEAT);
		Call_StartForward(gF_OnWardenRemovedBySelf);
		Call_PushCell(client);
		Call_Finish();
		Forward_OnWardenRemoved(client);
		if(gc_bSounds.BoolValue)	
		{
			EmitSoundToAllAny(g_sUnWarden);
		}
		ResetMarker();
		g_iVoteCount = 0;
		Format(g_sHasVoted, sizeof(g_sHasVoted), "");
		g_sHasVoted[0] = '\0';
	}
}

public Action EndMathQuestion(Handle timer)
{
	SendEndMathQuestion(-1);
}

public Action StartMathQuestion(int client, int args)
{
	if(gc_bMath.BoolValue)	
	{
		if(client == Warden)
		{
			if (!IsMathQuiz)
			{
				CreateTimer( 4.0, CreateMathQuestion, client);
							
				CPrintToChatAll("%t %t", "warden_tag" , "warden_startmathquiz");
		
				if(gc_bBetterNotes.BoolValue)
				{
					PrintCenterTextAll("%t", "warden_startmathquiz_nc");
					PrintHintTextToAll("%t", "warden_startmathquiz_nc");
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
		if(client == Warden)
		{
			int NumOne = GetRandomInt(g_MathMin, g_MathMax);
			int NumTwo = GetRandomInt(g_MathMin, g_MathMax);
			
			Format(g_op, sizeof(g_op), g_operators[GetRandomInt(0,3)]);
			
			if(StrEqual(g_op, PLUS))
			{
				g_MathResult = NumOne + NumTwo;
			}
			else if(StrEqual(g_op, MINUS))
			{
				g_MathResult = NumOne - NumTwo;
			}
			else if(StrEqual(g_op, DIVISOR))
			{
				do
				{
					NumOne = GetRandomInt(g_MathMin, g_MathMax);
					NumTwo = GetRandomInt(g_MathMin, g_MathMax);
				}
				while(NumOne % NumTwo != 0);
				g_MathResult = NumOne / NumTwo;
			}
			else if(StrEqual(g_op, MULTIPL))
			{
				g_MathResult = NumOne * NumTwo;
			}
			
			
			CPrintToChatAll("%t %N: %i %s %i = ?? ", "warden_tag", client, NumOne, g_op, NumTwo);
		
			if(gc_bBetterNotes.BoolValue)
			{
				PrintCenterTextAll("%i %s %i = ?? ", NumOne, g_op, NumTwo);
				PrintHintTextToAll("%i %s %i = ?? ", NumOne, g_op, NumTwo);
			}
			
			
			mathtimer = CreateTimer(gc_iTimeAnswer.FloatValue, EndMathQuestion);
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
	if(g_MathResult == number)
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
	if(mathtimer != INVALID_HANDLE)
	{
		KillTimer(mathtimer);
		mathtimer = INVALID_HANDLE;
	}
	
	char answer[100];
	
	if(client != -1)
		Format(answer, sizeof(answer), "%t %t", "warden_tag", "warden_math_correct", client);
	else
		Format(answer, sizeof(answer), "%t %t", "warden_tag", "warden_math_time");
		
	Handle pack = CreateDataPack();
	CreateDataTimer(0.3, AnswerQuestion, pack);
	WritePackString(pack, answer);
	
	IsMathQuiz = false;
}

public Action AnswerQuestion(Handle timer, Handle pack)
{
	char str[100];
	ResetPack(pack);
	ReadPackString(pack, str, sizeof(str));
 
	CPrintToChatAll(str);
}

public Action Command_LAW(int client, const char[] command, int argc)
{
	if(!gc_bMarker.BoolValue)
		return Plugin_Continue;
	
	if(!client || !IsClientInGame(client) || !IsPlayerAlive(client))
		return Plugin_Continue;
		
	if(client != Warden)
		return Plugin_Continue;
	
	if(gc_iMarkerKey.IntValue == 1)
	{
		GetClientAimTargetPos(client, g_fMakerPos);
		g_fMakerPos[2] += 5.0;
	}
	
	return Plugin_Continue;
}

public Action Event_BulletImpact(Handle hEvent,const char [] sName, bool bDontBroadcast)
{
	if(gc_bMarker.BoolValue)	
	{
		int client = GetClientOfUserId(GetEventInt(hEvent, "userid"));
		
		if (IsValidClient(client) && IsPlayerAlive(client) && warden_iswarden(client))
		{
			if (GetClientButtons(client) & IN_USE) 
			{
				if(gc_iMarkerKey.IntValue == 2)
				{
					GetClientAimTargetPos(client, g_fMakerPos);
					g_fMakerPos[2] += 5.0;
					CPrintToChat(client, "%t %t", "warden_tag" , "warden_marker");
				}
			}
			else if (GetClientButtons(client) & IN_SPEED) 
				{
					if(gc_iMarkerKey.IntValue == 3)
					{
						GetClientAimTargetPos(client, g_fMakerPos);
						g_fMakerPos[2] += 5.0;
						CPrintToChat(client, "%t %t", "warden_tag" , "warden_marker");
					}
				}
		}
	}
}

int GetClientAimTargetPos(int client, float pos[3]) 
{
	if (!client) 
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

void ResetMarker()
{
	for(int i = 0; i < 3; i++)
		g_fMakerPos[i] = 0.0;
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

public Action Timer_DrawMakers(Handle timer, any data)
{
	Draw_Markers();
	return Plugin_Continue;
}

void Draw_Markers()
{
	if (!gc_bMarker.BoolValue)
		return;
	
	if (g_fMakerPos[0] == 0.0)
		return;
	
	if(!warden_exist())
		return;
		
	// Show the ring
	
	TE_SetupBeamRingPoint(g_fMakerPos, 155.0, 155.0+0.1, g_iBeamSprite, g_iHaloSprite, 0, 10, 1.0, 6.0, 0.0, g_MarkerColor, 2, 0);
	TE_SendToAll();
	
	// Show the arrow
	
	float fStart[3];
	AddVectors(fStart, g_fMakerPos, fStart);
	fStart[2] += 0.0;
	
	float fEnd[3];
	AddVectors(fEnd, fStart, fEnd);
	fEnd[2] += 200.0;
	
	TE_SetupBeamPoints(fStart, fEnd, g_iBeamSprite, g_iHaloSprite, 0, 10, 1.0, 4.0, 16.0, 1, 0.0, g_MarkerColor, 5);
	TE_SendToAll();
	
	CreateTimer(gc_fMarkerTime.FloatValue, DeleteMarker);
}

public Action DeleteMarker( Handle timer) 
{
	ResetMarker();
}

public Action CDMenu(int client, int args)
{
	if(gc_bCountDown.BoolValue)
	{
		if (client == Warden)
		{
			char menuinfo1[255], menuinfo2[255], menuinfo3[255], menuinfo4[255];
			Format(menuinfo1, sizeof(menuinfo1), "%T", "warden_cdmenu_Title", LANG_SERVER);
			Format(menuinfo2, sizeof(menuinfo2), "%T", "warden_cdmenu_start", LANG_SERVER);
			Format(menuinfo3, sizeof(menuinfo3), "%T", "warden_cdmenu_stop", LANG_SERVER);
			Format(menuinfo4, sizeof(menuinfo4), "%T", "warden_cdmenu_startstop", LANG_SERVER);
			
			Menu menu = new Menu(CDHandler);
			menu.SetTitle(menuinfo1);
			menu.AddItem("start", menuinfo2);
			menu.AddItem("stop", menuinfo3);
			menu.AddItem("startstop", menuinfo4);
			menu.ExitButton = false;
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
		}
		else if ( strcmp(info,"stop") == 0 ) 
		{
		FakeClientCommand(client, "sm_cdstop");
		}
		else if ( strcmp(info,"startstop") == 0 ) 
		{
		FakeClientCommand(client, "sm_cdstartstop");
		}
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
		if (client == Warden)
		{
			char menuinfo5[255], menuinfo6[255], menuinfo7[255], menuinfo8[255], menuinfo9[255], menuinfo10[255], menuinfo11[255], menuinfo12[255], menuinfo13[255];
			Format(menuinfo5, sizeof(menuinfo5), "%T", "warden_cdmenu_Title2", LANG_SERVER);
			Format(menuinfo6, sizeof(menuinfo6), "%T", "warden_cdmenu_15", LANG_SERVER);
			Format(menuinfo7, sizeof(menuinfo7), "%T", "warden_cdmenu_30", LANG_SERVER);
			Format(menuinfo8, sizeof(menuinfo8), "%T", "warden_cdmenu_45", LANG_SERVER);
			Format(menuinfo9, sizeof(menuinfo9), "%T", "warden_cdmenu_60", LANG_SERVER);
			Format(menuinfo10, sizeof(menuinfo10), "%T", "warden_cdmenu_90", LANG_SERVER);
			Format(menuinfo11, sizeof(menuinfo11), "%T", "warden_cdmenu_120", LANG_SERVER);
			Format(menuinfo12, sizeof(menuinfo12), "%T", "warden_cdmenu_180", LANG_SERVER);
			Format(menuinfo13, sizeof(menuinfo13), "%T", "warden_cdmenu_300", LANG_SERVER);
			
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
			
			menu.ExitButton = false;
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
	}
	else if (action == MenuAction_End)
	{
		delete menu;
	}
}

public Action SetStartCountDown(int client, int args)
{
	if(gc_bCountDown.BoolValue)
	{
		if (client == Warden)
		{
			if (!IsCountDown)
			{
				g_iCountStopTime = 9;
				StartTimer = CreateTimer( 1.0, StartCountdown, client, TIMER_REPEAT);
				
				CPrintToChatAll("%t %t", "warden_tag" , "warden_startcountdownhint");
		
				if(gc_bBetterNotes.BoolValue)
				{
					PrintCenterTextAll("%t", "warden_startcountdownhint_nc");
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
		if (client == Warden)
		{
			if (!IsCountDown)
			{
				g_iCountStopTime = 20;
				StopTimer = CreateTimer( 1.0, StopCountdown, client, TIMER_REPEAT);
				
				
				CPrintToChatAll("%t %t", "warden_tag" , "warden_stopcountdownhint");
		
				if(gc_bBetterNotes.BoolValue)
				{
					PrintCenterTextAll("%t", "warden_stopcountdownhint_nc");
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
		if (client == Warden)
		{
			if (!IsCountDown)
			{
				g_iCountStartTime = 9;
				StartTimer = CreateTimer( 1.0, StartCountdown, client, TIMER_REPEAT);
				StartStopTimer = CreateTimer( 1.0, StopStartStopCountdown, client, TIMER_REPEAT);
				
				CPrintToChatAll("%t %t", "warden_tag" , "warden_startstopcountdownhint");
		
				if(gc_bBetterNotes.BoolValue)
				{
					PrintCenterTextAll("%t", "warden_startstopcountdownhint_nc");
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
				PrintCenterText(client,"%t", "warden_startcountdown_nc", g_iCountStartTime);
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
			PrintCenterText(client, "%t", "warden_countdownstart_nc");
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
				PrintCenterText(client,"%t", "warden_stopcountdown_nc", g_iCountStopTime);
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
			PrintCenterText(client, "%t", "warden_countdownstop_nc");
			CPrintToChatAll("%t %t", "warden_tag" , "warden_countdownstop");

			if(gc_bOverlays.BoolValue)
			{
				CreateTimer( 0.0, ShowOverlayStop, client);
			}
			if(gc_bSounds.BoolValue)	
			{
				EmitSoundToAllAny(g_sStop);
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
				PrintCenterText(client,"%t", "warden_stopcountdown_nc", g_iSetCountStartStopTime);
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
			PrintCenterText(client, "%t", "warden_countdownstop_nc");
			CPrintToChatAll("%t %t", "warden_tag" , "warden_countdownstop");
			
			if(gc_bOverlays.BoolValue)
			{
				CreateTimer( 0.0, ShowOverlayStop, client);
			}
			if(gc_bSounds.BoolValue)	
			{
				EmitSoundToAllAny(g_sStop);
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



public Action ShowOverlayStop( Handle timer, any client ) 
{
	if(gc_bOverlays.BoolValue && IsClientInGame(client) && IsClientConnected(client) && !IsFakeClient(client))
	{
		int iFlag = GetCommandFlags( "r_screenoverlay" ) & ( ~FCVAR_CHEAT ); 
		SetCommandFlags( "r_screenoverlay", iFlag ); 
		ClientCommand( client, "r_screenoverlay \"%s.vtf\"", g_sOverlayStop);
		CreateTimer( 2.0, DeleteOverlay, client );
	}
	return Plugin_Continue;
}



public Action EnableNoBlock(int client)
{
	SetEntData(client, g_CollisionOffset, 2, 4, true);
}

public Action EnableBlock(int client)
{
	SetEntData(client, g_CollisionOffset, 5, 4, true);
}

public Action noblockon(int client, int args)
{
	if(gc_bNoBlock.BoolValue)
	{
		if (client == Warden)
		{
			for(int i=1; i <= MaxClients; i++) if(IsValidClient(i, true))
			{
				EnableNoBlock(i);
			}
			CPrintToChatAll("%t %t", "warden_tag" , "warden_noblockon");
		}
		else
		{
		CPrintToChat(client, "%t %t", "warden_tag" , "warden_notwarden");
		}
	}
}

public Action noblockoff(int client, int args)
{ 
	if (client == Warden)
	{
		for(int i=1; i <= MaxClients; i++) if(IsValidClient(i, true))
		{
			EnableBlock(i);	
		}
		CPrintToChatAll("%t %t", "warden_tag" , "warden_noblockoff");
	}
	else
	{
		CPrintToChat(client, "%t %t", "warden_tag" , "warden_notwarden"); 
	}
}

public Action ToggleFF(int client, int args)
{
	if (gc_bFF.BoolValue) 
	{
		if (g_bFF.BoolValue) 
		{
			if (client == Warden)
			{
				SetCvar("mp_teammates_are_enemies", 0);
				g_bFF = FindConVar("mp_teammates_are_enemies");
				CPrintToChatAll("%t %t", "warden_tag", "warden_ffisoff" );
			}else CPrintToChatAll("%t %t", "warden_tag", "warden_ffison" );
			
		}else
		{	
			if (client == Warden)
			{
				SetCvar("mp_teammates_are_enemies", 1);
				g_bFF = FindConVar("mp_teammates_are_enemies");
				CPrintToChatAll("%t %t", "warden_tag", "warden_ffison" );
			}
			else CPrintToChatAll("%t %t", "warden_tag", "warden_ffisoff" );
		}
	}
}

public Action KillRandom(int client, int args)
{
	if (gc_bRandom.BoolValue) 
	{
		if (client == Warden)
		{
			char info5[255], info6[255], info7[255];
			Menu menu1 = CreateMenu(killmenu);
			Format(info5, sizeof(info5), "%T", "warden_sure", Warden, LANG_SERVER);
			menu1.SetTitle(info5);
			Format(info6, sizeof(info6), "%T", "warden_yes", LANG_SERVER);
			Format(info7, sizeof(info7), "%T", "warden_no", LANG_SERVER);
			menu1.AddItem("1", info6);
			menu1.AddItem("0", info7);
			menu1.ExitButton = false;
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
			DoKillRandom(client, 0);
		}
	}
}

public Action DoKillRandom(int client, int args)
{
		int i = GetRandomPlayer(CS_TEAM_T);
		if(i > 0)
		{
			PerformSmite(client, i);
			CPrintToChatAll("%t %t", "warden_tag", "warden_israndomdead", i); 
		}
}

stock int GetRandomPlayer(int team) 
{
	int[] clients = new int[MaxClients];
	int clientCount;
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i) && (GetClientTeam(i) == team))    // IsPlayerAlive(i) ???
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
	
	TE_SetupBeamPoints(startpos, clientpos, g_LightningSprite, 0, 0, 0, 0.2, 20.0, 10.0, 0, 1.0, color, 3);
	TE_SendToAll();
	
	TE_SetupSparks(clientpos, dir, 5000, 1000);
	TE_SendToAll();
	
	TE_SetupEnergySplash(clientpos, dir, false);
	TE_SendToAll();
	
	TE_SetupSmoke(clientpos, g_SmokeSprite, 5.0, 10);
	TE_SendToAll();
	
	EmitAmbientSound(SOUND_THUNDER, startpos, client, SNDLEVEL_GUNFIRE);
	
	ForcePlayerSuicide(target);
}

public Action ChooseRandom(Handle timer, Handle pack)
{
	if(gc_bPlugin.BoolValue)
	{
		--randomtime;
		if(randomtime < 1)
		{
			if(warden_exist() != 1)
			{
				if(gc_bChooseRandom.BoolValue)
				{
					int i = GetRandomPlayer(CS_TEAM_CT);
					if(i > 0)
					{
						SetTheWarden(i);
						CPrintToChatAll("%t %t", "warden_tag", "warden_israndomwarden", i); 
					}
				}
			}
			if (randomtimer != null)
				KillTimer(randomtimer);
			
			randomtimer = null;
		}
	}
}

public Action OpenCounter(Handle timer, Handle pack)
{
	if(gc_bPlugin.BoolValue)
	{
		--opentimer;
		if(opentimer < 1)
		{
			if(warden_exist() != 1)
			{
				if(gc_bOpenTimer.BoolValue)	
				{
				SJD_OpenDoors(); 
				CPrintToChatAll("%t %t", "warden_tag" , "warden_openauto");
				
				if (opencountertime != null)
					KillTimer(opencountertime);
				
				opencountertime = null;
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
				if (opencountertime != null)
				KillTimer(opencountertime);
				opencountertime = null;
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
			if (client == Warden)
			{
				CPrintToChatAll("%t %t", "warden_tag" , "warden_dooropen"); 
				SJD_OpenDoors();
				if (opencountertime != null)
				KillTimer(opencountertime);
				opencountertime = null;
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
			if (client == Warden)
			{
				CPrintToChatAll("%t %t", "warden_tag" , "warden_doorclose"); 
				SJD_CloseDoors();
			}
			else CPrintToChat(client, "%t %t", "warden_tag" , "warden_notwarden"); 
		}
	}
}

public int Native_ExistWarden(Handle plugin, int numParams)
{
	if(Warden != -1)
		return true;
	
	return false;
}

public int Native_IsWarden(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	
	if(!IsClientInGame(client) && !IsClientConnected(client))
		ThrowNativeError(SP_ERROR_INDEX, "Client index %i is invalid", client);
	
	if(client == Warden)
		return true;
	
	return false;
}

public int Native_SetWarden(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	
	if (!IsClientInGame(client) && !IsClientConnected(client))
		ThrowNativeError(SP_ERROR_INDEX, "Client index %i is invalid", client);
	
	if(Warden == -1)
		SetTheWarden(client);
}

public int Native_RemoveWarden(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	
	if (!IsClientInGame(client) && !IsClientConnected(client))
		ThrowNativeError(SP_ERROR_INDEX, "Client index %i is invalid", client);
	
	if(client == Warden)
		RemoveTheWarden(client);
}

public int Native_GetWarden(Handle plugin, int argc)
{	
		return Warden;
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
	if(Warden != -1)
	{
	return true;
	}
	return false;
}

stock bool IsClientWarden(int client)
{
	if(client == Warden)
	{
	return true;
	}
	return false;
}

public void warden_OnWardenCreated(int client)
{

}

