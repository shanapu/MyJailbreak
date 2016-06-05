//includes
#include <cstrike>
#include <sourcemod>
#include <colors>
#include <warden>
#include <emitsoundany>
#include <autoexecconfig>
#include <myjailbreak>
#include <lastrequest>

//Compiler Options
#pragma semicolon 1
#pragma newdecls required

//ConVars
ConVar gc_fRefuseTime;
ConVar gc_bRefuse;
ConVar gc_bPlugin;
ConVar gc_bWardenAllowRefuse;
ConVar gc_iRefuseLimit;
ConVar gc_iRefuseColorRed;
ConVar gc_iRefuseColorGreen;
ConVar gc_iRefuseColorBlue;
ConVar gc_fCapitulationTime;
ConVar gc_fRebelTime;
ConVar gc_bCapitulation;
ConVar gc_bCapitulationDamage;
ConVar gc_iCapitulationColorRed;
ConVar gc_iCapitulationColorGreen;
ConVar gc_iCapitulationColorBlue;
ConVar gc_bSounds;
ConVar gc_sSoundRefusePath;
ConVar gc_sSoundRefuseStopPath;
ConVar gc_sSoundCapitulationPath;
ConVar gc_bHeal;
ConVar gc_bHealthShot;
ConVar gc_fHealTime;
ConVar gc_iHealLimit;
ConVar gc_bHealthCheck;
ConVar gc_iHealColorRed;
ConVar gc_iHealColorGreen;
ConVar gc_iHealColorBlue;
ConVar gc_bRepeat;
ConVar gc_iRepeatLimit;
ConVar gc_sSoundRepeatPath;
ConVar gc_sCustomCommandHeal;
ConVar gc_sCustomCommandCapitulation;
ConVar gc_sCustomCommandRefuse;
ConVar gc_sCustomCommandRepeat;
ConVar gc_sCustomCommandFreekill;
ConVar gc_bFreeKill;
ConVar gc_bFreeKillRespawn;
ConVar gc_bFreeKillKill;
ConVar gc_bFreeKillFreeDay;
ConVar gc_bFreeKillSwap;
ConVar gc_bReportAdmin;
ConVar gc_bReportWarden;

//Bools
bool g_bHealed[MAXPLAYERS+1];
bool g_bCapitulated[MAXPLAYERS+1];
bool g_bRefused[MAXPLAYERS+1];
bool g_bRepeated[MAXPLAYERS+1];
bool g_bFreeKilled[MAXPLAYERS+1];
bool g_bAllowRefuse;
bool IsRequest;


//Integers
int g_iRefuseCounter[MAXPLAYERS+1];
int g_iHealCounter[MAXPLAYERS+1];
int g_iRepeatCounter[MAXPLAYERS+1];
int g_iKilledBy[MAXPLAYERS+1];
int g_iCountStopTime;


//Handles
Handle RebelTimer[MAXPLAYERS+1];
Handle RefuseTimer[MAXPLAYERS+1];
Handle RepeatTimer[MAXPLAYERS+1];
Handle CapitulationTimer[MAXPLAYERS+1];
Handle HealTimer[MAXPLAYERS+1];
Handle RefusePanel;
Handle RepeatPanel;
Handle RequestTimer;
Handle AllowRefuseTimer;

//characters
char g_sSoundRefusePath[256];
char g_sSoundRefuseStopPath[256];
char g_sSoundRepeatPath[256];
char g_sSoundCapitulationPath[256];
char g_sCustomCommandHeal[64];
char g_sCustomCommandCapitulation[64];
char g_sCustomCommandRepeat[64];
char g_sCustomCommandRefuse[64];
char g_sCustomCommandFreekill[64];

public Plugin myinfo = 
{
	name = "MyJailbreak - Request",
	author = "shanapu",
	description = "Requests - refuse, capitulation/pardon, heal",
	version = PLUGIN_VERSION,
	url = URL_LINK
}

public void OnPluginStart()
{
	// Translation
	LoadTranslations("MyJailbreak.Warden.phrases");
	LoadTranslations("MyJailbreak.Request.phrases");
	
	//Client Commands
	RegConsoleCmd("sm_request", RequestMenu, "Open the requests menu");
	
	RegConsoleCmd("sm_refuse", Command_refuse, "Allows the Warden start refusing time and Terrorist to refuse a game");
	
	RegConsoleCmd("sm_capitulation", Command_Capitulation, "Allows a rebeling terrorist to request a capitulate");
	RegConsoleCmd("sm_pardon", Command_Capitulation, "Allows a rebeling terrorist to request a capitulate");
	
	RegConsoleCmd("sm_heal", Command_Heal, "Allows a Terrorist request healing");
	
	RegConsoleCmd("sm_repeat", Command_Repeat, "Allows a Terrorist request repeat");
	
	RegConsoleCmd("sm_freekill", Command_Freekill, "Allows a Dead Terrorist report a Freekill");
	
	//AutoExecConfig
	AutoExecConfig_SetFile("Request", "MyJailbreak");
	AutoExecConfig_SetCreateFile(true);
	
	AutoExecConfig_CreateConVar("sm_request_version", PLUGIN_VERSION, "The version of this MyJailbreak SourceMod plugin", FCVAR_SPONLY|FCVAR_PLUGIN|FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_DONTRECORD);
	gc_bPlugin = AutoExecConfig_CreateConVar("sm_request_enable", "1", "0 - disabled, 1 - enable Request Plugin");
	gc_bSounds = AutoExecConfig_CreateConVar("sm_request_sounds_enable", "1", "0 - disabled, 1 - enable sounds ", _, true,  0.0, true, 1.0);
	gc_bRefuse = AutoExecConfig_CreateConVar("sm_refuse_enable", "1", "0 - disabled, 1 - enable Refuse");
	gc_sCustomCommandRefuse = AutoExecConfig_CreateConVar("sm_refuse_cmd", "ref", "Set your custom chat command for Refuse. no need for sm_ or !");
	gc_bWardenAllowRefuse = AutoExecConfig_CreateConVar("sm_refuse_allow", "0", "0 - disabled, 1 - Warden must allow !refuse before T can use it");
	gc_iRefuseLimit = AutoExecConfig_CreateConVar("sm_refuse_limit", "1", "Сount how many times you can use the command");
	gc_fRefuseTime = AutoExecConfig_CreateConVar("sm_refuse_time", "5.0", "Time the player gets to refuse after warden open refuse with !refuse / colortime");
	gc_iRefuseColorRed = AutoExecConfig_CreateConVar("sm_refuse_color_red", "0","What color to turn the refusing Terror into (set R, G and B values to 255 to disable) (Rgb): x - red value", _, true, 0.0, true, 255.0);
	gc_iRefuseColorGreen = AutoExecConfig_CreateConVar("sm_refuse_color_green", "250","What color to turn the refusing Terror into (rGb): x - green value", _, true, 0.0, true, 255.0);
	gc_iRefuseColorBlue = AutoExecConfig_CreateConVar("sm_refuse_color_blue", "250","What color to turn the refusing Terror into (rgB): x - blue value", _, true, 0.0, true, 255.0);
	gc_sSoundRefusePath = AutoExecConfig_CreateConVar("sm_refuse_sound", "music/MyJailbreak/refuse.mp3", "Path to the soundfile which should be played for a refusing.");
	gc_sSoundRefuseStopPath = AutoExecConfig_CreateConVar("sm_refuse_stop_sound", "music/MyJailbreak/stop.mp3", "Path to the soundfile which should be played after a refusing.");
	gc_bCapitulation = AutoExecConfig_CreateConVar("sm_capitulation_enable", "1", "0 - disabled, 1 - enable Capitulation");
	gc_sCustomCommandCapitulation = AutoExecConfig_CreateConVar("sm_capitulation_cmd", "capi", "Set your custom chat command for Capitulation. no need for sm_ or !");
	gc_fCapitulationTime = AutoExecConfig_CreateConVar("sm_capitulation_timer", "10.0", "Time to decide to accept the capitulation");
	gc_fRebelTime = AutoExecConfig_CreateConVar("sm_capitulation_rebel_timer", "10.0", "Time to give a rebel on not accepted capitulation his knife back");
	gc_bCapitulationDamage = AutoExecConfig_CreateConVar("sm_capitulation_damage", "1", "0 - disabled, 1 - enable Terror make no damage after capitulation");
	gc_iCapitulationColorRed = AutoExecConfig_CreateConVar("sm_capitulation_color_red", "0","What color to turn the capitulation Terror into (set R, G and B values to 255 to disable) (Rgb): x - red value", _, true, 0.0, true, 255.0);
	gc_iCapitulationColorGreen = AutoExecConfig_CreateConVar("sm_capitulation_color_green", "250","What color to turn the capitulation Terror into (rGb): x - green value", _, true, 0.0, true, 255.0);
	gc_iCapitulationColorBlue = AutoExecConfig_CreateConVar("sm_capitulation_color_blue", "0","What color to turn the capitulation Terror into (rgB): x - blue value", _, true, 0.0, true, 255.0);
	gc_sSoundCapitulationPath = AutoExecConfig_CreateConVar("sm_capitulation_sound", "music/MyJailbreak/capitulation.mp3", "Path to the soundfile which should be played for a capitulation.");
	gc_bHeal = AutoExecConfig_CreateConVar("sm_heal_enable", "1", "0 - disabled, 1 - enable heal");
	gc_sCustomCommandHeal = AutoExecConfig_CreateConVar("sm_heal_cmd", "cure", "Set your custom chat command for Heal. no need for sm_ or !");
	gc_bHealthShot = AutoExecConfig_CreateConVar("sm_heal_healthshot", "1", "0 - disabled, 1 - enable give healthshot on accept to terror");
	gc_bHealthCheck = AutoExecConfig_CreateConVar("sm_heal_check", "1", "0 - disabled, 1 - enable check if player is already full health");
	gc_iHealLimit = AutoExecConfig_CreateConVar("sm_heal_limit", "2", "Сount how many times you can use the command");
	gc_fHealTime = AutoExecConfig_CreateConVar("sm_heal_time", "10.0", "Time after the player gets his normal colors back");
	gc_iHealColorRed = AutoExecConfig_CreateConVar("sm_heal_color_red", "240","What color to turn the heal Terror into (set R, G and B values to 255 to disable) (Rgb): x - red value", _, true, 0.0, true, 255.0);
	gc_iHealColorGreen = AutoExecConfig_CreateConVar("sm_heal_color_green", "0","What color to turn the heal Terror into (rGb): x - green value", _, true, 0.0, true, 255.0);
	gc_iHealColorBlue = AutoExecConfig_CreateConVar("sm_heal_color_blue", "100","What color to turn the heal Terror into (rgB): x - blue value", _, true, 0.0, true, 255.0);
	gc_bRepeat = AutoExecConfig_CreateConVar("sm_repeat_enable", "1", "0 - disabled, 1 - enable repeat");
	gc_sCustomCommandRepeat = AutoExecConfig_CreateConVar("sm_repeat_cmd", "what", "Set your custom chat command for Repeat. no need for sm_ or !");
	gc_iRepeatLimit = AutoExecConfig_CreateConVar("sm_repeat_limit", "2", "Сount how many times you can use the command");
	gc_sSoundRepeatPath = AutoExecConfig_CreateConVar("sm_repeat_sound", "music/MyJailbreak/repeat.mp3", "Path to the soundfile which should be played for a repeat.");
	
	gc_bFreeKill = AutoExecConfig_CreateConVar("sm_freekill_enable", "1", "0 - disabled, 1 - enable freekill report");
	gc_sCustomCommandFreekill = AutoExecConfig_CreateConVar("sm_freekill_cmd", "fk", "Set your custom chat command for freekill. no need for sm_ or !");
	gc_bFreeKillRespawn = AutoExecConfig_CreateConVar("sm_freekill_respawn", "1", "0 - disabled, 1 - Allow the warden to respawn a Freekill victim");
	gc_bFreeKillKill = AutoExecConfig_CreateConVar("sm_freekill_kill", "1", "0 - disabled, 1 - Allow the warden to Kill a Freekiller");
	gc_bFreeKillFreeDay = AutoExecConfig_CreateConVar("sm_freekill_freeday", "1", "0 - disabled, 1 - Allow the warden to set a freeday next round as pardon");
	gc_bFreeKillSwap = AutoExecConfig_CreateConVar("sm_freekill_swap", "1", "0 - disabled, 1 - Allow the warden to swap a freekiller to terrorist");
	gc_bReportAdmin = AutoExecConfig_CreateConVar("sm_freekill_admin", "1", "0 - disabled, 1 - Report will be send to admins - if there is no admin its send to warden");
	gc_bReportWarden = AutoExecConfig_CreateConVar("sm_freekill_warden", "1", "0 - disabled, 1 - Report will be send to Warden if there is no admin");
	
	
	AutoExecConfig_ExecuteFile();
	AutoExecConfig_CleanFile();
	
	//Hooks
	HookEvent("round_start", RoundStart);
	HookEvent("player_death", playerDeath);
	HookConVarChange(gc_sSoundRefusePath, OnSettingChanged);
	HookConVarChange(gc_sSoundRefuseStopPath, OnSettingChanged);
	HookConVarChange(gc_sSoundCapitulationPath, OnSettingChanged);
	HookConVarChange(gc_sSoundRepeatPath, OnSettingChanged);
	HookConVarChange(gc_sCustomCommandHeal, OnSettingChanged);
	HookConVarChange(gc_sCustomCommandRefuse, OnSettingChanged);
	HookConVarChange(gc_sCustomCommandRepeat, OnSettingChanged);
	HookConVarChange(gc_sCustomCommandCapitulation, OnSettingChanged);
	HookConVarChange(gc_sCustomCommandFreekill, OnSettingChanged);
	
	//FindConVar
	gc_sSoundRefusePath.GetString(g_sSoundRefusePath, sizeof(g_sSoundRefusePath));
	gc_sSoundRefuseStopPath.GetString(g_sSoundRefuseStopPath, sizeof(g_sSoundRefuseStopPath));
	gc_sSoundCapitulationPath.GetString(g_sSoundCapitulationPath, sizeof(g_sSoundCapitulationPath));
	gc_sSoundRepeatPath.GetString(g_sSoundRepeatPath, sizeof(g_sSoundRepeatPath));
	gc_sCustomCommandHeal.GetString(g_sCustomCommandHeal , sizeof(g_sCustomCommandHeal));
	gc_sCustomCommandRefuse.GetString(g_sCustomCommandRefuse , sizeof(g_sCustomCommandRefuse));
	gc_sCustomCommandRepeat.GetString(g_sCustomCommandRepeat , sizeof(g_sCustomCommandRepeat));
	gc_sCustomCommandCapitulation.GetString(g_sCustomCommandCapitulation , sizeof(g_sCustomCommandCapitulation));
	gc_sCustomCommandFreekill.GetString(g_sCustomCommandFreekill , sizeof(g_sCustomCommandFreekill));
}

public int OnSettingChanged(Handle convar, const char[] oldValue, const char[] newValue)
{
	if(convar == gc_sSoundRefusePath)
	{
		strcopy(g_sSoundRefusePath, sizeof(g_sSoundRefusePath), newValue);
		if(gc_bSounds.BoolValue) PrecacheSoundAnyDownload(g_sSoundRefusePath);
	}
	else if(convar == gc_sSoundRefuseStopPath)
	{
		strcopy(g_sSoundRefuseStopPath, sizeof(g_sSoundRefuseStopPath), newValue);
		if(gc_bSounds.BoolValue) PrecacheSoundAnyDownload(g_sSoundRefuseStopPath);
	}
	else if(convar == gc_sSoundRepeatPath)
	{
		strcopy(g_sSoundRepeatPath, sizeof(g_sSoundRepeatPath), newValue);
		if(gc_bSounds.BoolValue) PrecacheSoundAnyDownload(g_sSoundRepeatPath);
	}
	else if(convar == gc_sSoundCapitulationPath)
	{
		strcopy(g_sSoundCapitulationPath, sizeof(g_sSoundCapitulationPath), newValue);
		if(gc_bSounds.BoolValue) PrecacheSoundAnyDownload(g_sSoundCapitulationPath);
	}
	else if(convar == gc_sCustomCommandHeal)
	{
		strcopy(g_sCustomCommandHeal, sizeof(g_sCustomCommandHeal), newValue);
		char sBufferCMD[64];
		Format(sBufferCMD, sizeof(sBufferCMD), "sm_%s", g_sCustomCommandHeal);
		if(GetCommandFlags(sBufferCMD) == INVALID_FCVAR_FLAGS)
			RegConsoleCmd(sBufferCMD, Command_Heal, "Allows a Terrorist request a healing");
	}
	else if(convar == gc_sCustomCommandRefuse)
	{
		strcopy(g_sCustomCommandRefuse, sizeof(g_sCustomCommandRefuse), newValue);
		char sBufferCMD[64];
		Format(sBufferCMD, sizeof(sBufferCMD), "sm_%s", g_sCustomCommandRefuse);
		if(GetCommandFlags(sBufferCMD) == INVALID_FCVAR_FLAGS)
			RegConsoleCmd(sBufferCMD, Command_refuse, "Allows the Warden start refusing time and Terrorist to refuse a game");
	}
	else if(convar == gc_sCustomCommandRepeat)
	{
		strcopy(g_sCustomCommandRepeat, sizeof(g_sCustomCommandRepeat), newValue);
		char sBufferCMD[64];
		Format(sBufferCMD, sizeof(sBufferCMD), "sm_%s", g_sCustomCommandRepeat);
		if(GetCommandFlags(sBufferCMD) == INVALID_FCVAR_FLAGS)
			RegConsoleCmd(sBufferCMD, Command_Repeat, "Allows a Terrorist request a repeat");
	}
	else if(convar == gc_sCustomCommandCapitulation)
	{
		strcopy(g_sCustomCommandCapitulation, sizeof(g_sCustomCommandCapitulation), newValue);
		char sBufferCMD[64];
		Format(sBufferCMD, sizeof(sBufferCMD), "sm_%s", g_sCustomCommandCapitulation);
		if(GetCommandFlags(sBufferCMD) == INVALID_FCVAR_FLAGS)
			RegConsoleCmd(sBufferCMD, Command_Capitulation, "Allows a rebeling terrorist to request a capitulate");
	}
	else if(convar == gc_sCustomCommandCapitulation)
	{
		strcopy(g_sCustomCommandFreekill, sizeof(g_sCustomCommandFreekill), newValue);
		char sBufferCMD[64];
		Format(sBufferCMD, sizeof(sBufferCMD), "sm_%s", g_sCustomCommandFreekill);
		if(GetCommandFlags(sBufferCMD) == INVALID_FCVAR_FLAGS)
			RegConsoleCmd(sBufferCMD, Command_Freekill, "Allows a rebeling terrorist to report a freekill");
	}
}

public void OnMapStart()
{
	if(gc_bSounds.BoolValue)
	{
		PrecacheSoundAnyDownload(g_sSoundRefusePath);
		PrecacheSoundAnyDownload(g_sSoundRefuseStopPath);
		PrecacheSoundAnyDownload(g_sSoundCapitulationPath);
		PrecacheSoundAnyDownload(g_sSoundRepeatPath);
	}
}

public void OnConfigsExecuted()
{
	g_iCountStopTime = gc_fRefuseTime.IntValue;
	
	char sBufferCMDHeal[64], sBufferCMDRepeat[64], sBufferCMDRefuse[64], sBufferCMDCapitulation[64], sBufferCMDFreekill[64];
	
	Format(sBufferCMDHeal, sizeof(sBufferCMDHeal), "sm_%s", g_sCustomCommandHeal);
	Format(sBufferCMDRefuse, sizeof(sBufferCMDRefuse), "sm_%s", g_sCustomCommandRefuse);
	Format(sBufferCMDRepeat, sizeof(sBufferCMDRepeat), "sm_%s", g_sCustomCommandRepeat);
	Format(sBufferCMDCapitulation, sizeof(sBufferCMDCapitulation), "sm_%s", g_sCustomCommandCapitulation);
	Format(sBufferCMDFreekill, sizeof(sBufferCMDFreekill), "sm_%s", g_sCustomCommandFreekill);
	if(GetCommandFlags(sBufferCMDHeal) == INVALID_FCVAR_FLAGS)
		RegConsoleCmd(sBufferCMDHeal, Command_Heal, "Allows a Terrorist request healing");
	if(GetCommandFlags(sBufferCMDRepeat) == INVALID_FCVAR_FLAGS)
		RegConsoleCmd(sBufferCMDRepeat, Command_Repeat, "Allows a Terrorist request repeat");
	if(GetCommandFlags(sBufferCMDRefuse) == INVALID_FCVAR_FLAGS)
		RegConsoleCmd(sBufferCMDRefuse, Command_refuse, "Allows the Warden start refusing time and Terrorist to refuse a game");
	if(GetCommandFlags(sBufferCMDCapitulation) == INVALID_FCVAR_FLAGS)
		RegConsoleCmd(sBufferCMDCapitulation, Command_Capitulation, "Allows a rebeling terrorist to request a capitulate");
	if(GetCommandFlags(sBufferCMDFreekill) == INVALID_FCVAR_FLAGS)
		RegConsoleCmd(sBufferCMDFreekill, Command_Freekill, "Allows a rebeling terrorist to report a freekill");
}

public Action RoundStart(Handle event, char [] name, bool dontBroadcast)
{
	LoopClients(client)
	{
		delete RefuseTimer[client];
		delete CapitulationTimer[client];
		delete RebelTimer[client];
		delete HealTimer[client];
		delete RepeatTimer[client];
		delete RequestTimer;
		delete AllowRefuseTimer;
		
		g_iRefuseCounter[client] = 0;
		g_bCapitulated[client] = false;
		g_iHealCounter[client] = 0;
		g_bHealed[client] = false;
		g_bRepeated[client] = false;
		g_iRepeatCounter[client] = 0;
		g_bRefused[client] = false;
		IsRequest = false;
		g_bAllowRefuse = false;
		g_iKilledBy[client] = 0;
		g_bFreeKilled[client] = false;
	}
	g_iCountStopTime = gc_fRefuseTime.IntValue;
	return Plugin_Continue;
}

public void OnClientPutInServer(int client)
{
	g_bCapitulated[client] = false;
	g_iRepeatCounter[client] = 0;
	g_iRefuseCounter[client] = 0;
	g_iHealCounter[client] = 0;
	g_bHealed[client] = false;
	g_bRepeated[client] = false;
	g_bRefused[client] = false;
	SDKHook(client, SDKHook_WeaponCanUse, OnWeaponCanUse);
	SDKHook(client, SDKHook_OnTakeDamage, OnTakedamage);
}

public void OnClientDisconnect(int client)
{
	delete RefuseTimer[client];
	delete CapitulationTimer[client];
	delete RebelTimer[client];
	delete HealTimer[client];
	delete RepeatTimer[client];
	
	g_iRepeatCounter[client] = 0;
	g_bCapitulated[client] = false;
	g_iRefuseCounter[client] = 0;
	g_bHealed[client] = false;
	g_iHealCounter[client] = 0;
	g_bRefused[client] = false;
	g_bRepeated[client] = false;
}

public Action Command_refuse(int client, int args)
{
	if (gc_bPlugin.BoolValue)
	{
		if (gc_bRefuse.BoolValue)
		{
			if(warden_iswarden(client) && gc_bWardenAllowRefuse.BoolValue)
			{
				if(!g_bAllowRefuse)
				{
					g_bAllowRefuse = true;
					AllowRefuseTimer = CreateTimer(1.0, NoAllowRefuse, _, TIMER_REPEAT);
					CPrintToChatAll("%t %t", "request_tag", "request_openrefuse");
				}
			}
			if(!warden_iswarden(client))
			{
				if (GetClientTeam(client) == CS_TEAM_T && IsPlayerAlive(client))
				{
					if (RefuseTimer[client] == null)
					{
						if(g_bAllowRefuse || !gc_bWardenAllowRefuse.BoolValue)
						{
							if (g_iRefuseCounter[client] < gc_iRefuseLimit.IntValue)
							{
								g_iRefuseCounter[client]++;
								g_bRefused[client] = true;
								SetEntityRenderColor(client, gc_iRefuseColorRed.IntValue, gc_iRefuseColorGreen.IntValue, gc_iRefuseColorBlue.IntValue, 255);
								CPrintToChatAll("%t %t", "request_tag", "request_refusing", client);
								g_iCountStopTime = gc_fRefuseTime.IntValue;
								RefuseTimer[client] = CreateTimer(gc_fRefuseTime.FloatValue, ResetColorRefuse, client);
								if (warden_exist()) LoopClients(i) RefuseMenu(i);
								if(gc_bSounds.BoolValue)EmitSoundToAllAny(g_sSoundRefusePath);
							}
							else CPrintToChat(client, "%t %t", "request_tag", "request_refusedtimes");
						}
						else CPrintToChat(client, "%t %t", "request_tag", "request_refuseallow");
					}
					else CPrintToChat(client, "%t %t", "request_tag", "request_alreadyrefused");
				}
				else CPrintToChat(client, "%t %t", "request_tag", "request_notalivect");
			}
		}
	}
	return Plugin_Handled;
}

public Action RefuseMenu(int warden)
{
	if (IsValidClient(warden, false, false) && warden_iswarden(warden))
	{
		char info1[255];
		RefusePanel = CreatePanel();
		Format(info1, sizeof(info1), "%T", "request_refuser", warden);
		SetPanelTitle(RefusePanel, info1);
		DrawPanelText(RefusePanel, "-----------------------------------");
		DrawPanelText(RefusePanel, "                                   ");
		LoopValidClients(i,true,false)
		{
			if(g_bRefused[i])
			{
				char userid[11];
				char username[MAX_NAME_LENGTH];
				IntToString(GetClientUserId(i), userid, sizeof(userid));
				Format(username, sizeof(username), "%N", i);
				DrawPanelText(RefusePanel,username);
			}
		}
		DrawPanelText(RefusePanel, "                                   ");
		DrawPanelText(RefusePanel, "-----------------------------------");
		SendPanelToClient(RefusePanel, warden, NullHandler, 23);
	}
}

//repeat

public Action Command_Repeat(int client, int args)
{
	if (gc_bPlugin.BoolValue)
	{
		if (gc_bRepeat.BoolValue)
		{
			if (GetClientTeam(client) == CS_TEAM_T && IsPlayerAlive(client))
			{
				if (RepeatTimer[client] == null)
				{
					if (g_iRepeatCounter[client] < gc_iRepeatLimit.IntValue)
					{
						g_iRepeatCounter[client]++;
						g_bRepeated[client] = true;
						CPrintToChatAll("%t %t", "request_tag", "request_repeatpls", client);
						RepeatTimer[client] = CreateTimer(10.0, RepeatEnd, client);
						if (warden_exist()) LoopClients(i) RepeatMenu(i);
						if(gc_bSounds.BoolValue)EmitSoundToAllAny(g_sSoundRepeatPath);
					}
					else CPrintToChat(client, "%t %t", "request_tag", "request_repeattimes");
				}
				else CPrintToChat(client, "%t %t", "request_tag", "request_alreadyrepeat");
			}
			else CPrintToChat(client, "%t %t", "request_tag", "request_notalivect");
		}
	}
	return Plugin_Handled;
}

public Action RepeatMenu(int warden)
{
	if (IsValidClient(warden, false, false) && warden_iswarden(warden))
	{
		char info1[255];
		RepeatPanel = CreatePanel();
		Format(info1, sizeof(info1), "%T", "request_repeat", warden);
		SetPanelTitle(RepeatPanel, info1);
		DrawPanelText(RepeatPanel, "-----------------------------------");
		DrawPanelText(RepeatPanel, "                                   ");
		for(int i = 1;i <= MaxClients;i++) if(IsValidClient(i, true))
		{
			if(g_bRepeated[i])
			{
				char userid[11];
				char username[MAX_NAME_LENGTH];
				IntToString(GetClientUserId(i), userid, sizeof(userid));
				Format(username, sizeof(username), "%N", i);
				DrawPanelText(RepeatPanel,username);
			}
		}
		DrawPanelText(RepeatPanel, "                                   ");
		DrawPanelText(RepeatPanel, "-----------------------------------");
		SendPanelToClient(RepeatPanel, warden, NullHandler, 20);
	}
}

public Action Command_Capitulation(int client, int args)
{
	if (gc_bPlugin.BoolValue)
	{
		if (gc_bCapitulation.BoolValue)
		{
			if (GetClientTeam(client) == CS_TEAM_T && (IsPlayerAlive(client)))
			{
				if (!(g_bCapitulated[client]))
				{
					if (warden_exist())
					{
						if(!IsRequest)
						{
							IsRequest = true;
							RequestTimer = CreateTimer (gc_fCapitulationTime.FloatValue, IsRequestTimer);
							g_bCapitulated[client] = true;
							CPrintToChatAll("%t %t", "request_tag", "request_capitulation", client);
							
							float DoubleTime = (gc_fRebelTime.FloatValue * 2);
							RebelTimer[client] = CreateTimer(DoubleTime, RebelNoAction, client);
						//	StripAllWeapons(client);
							LoopClients(i) CapitulationMenu(i);
							if(gc_bSounds.BoolValue)EmitSoundToAllAny(g_sSoundCapitulationPath);
						}
						else CPrintToChat(client, "%t %t", "request_tag", "request_processing");
					}
					else CPrintToChat(client, "%t %t", "request_tag", "warden_noexist");
				}
				else CPrintToChat(client, "%t %t", "request_tag", "request_alreadycapitulated");
			}
			else CPrintToChat(client, "%t %t", "request_tag", "request_notalivect");
		}
	}
	return Plugin_Handled;
}

public Action CapitulationMenu(int warden)
{
	if (IsValidClient(warden, false, false) && warden_iswarden(warden))
	{
		char info5[255], info6[255], info7[255];
		Menu menu1 = CreateMenu(CapitulationMenuHandler);
		Format(info5, sizeof(info5), "%T", "request_acceptcapitulation", warden);
		menu1.SetTitle(info5);
		Format(info6, sizeof(info6), "%T", "warden_no", warden);
		Format(info7, sizeof(info7), "%T", "warden_yes", warden);
		menu1.AddItem("1", info7);
		menu1.AddItem("0", info6);
		menu1.Display(warden, gc_fCapitulationTime.IntValue);
	}
}

public int CapitulationMenuHandler(Menu menu, MenuAction action, int client, int Position)
{
	if(action == MenuAction_Select)
	{
		char Item[11];
		menu.GetItem(Position,Item,sizeof(Item));
		int choice = StringToInt(Item);
		if(choice == 1)  //yes
		{
			LoopClients(i) if(g_bCapitulated[i])
			{
				IsRequest = false;
				if (RequestTimer != null)
					KillTimer(RequestTimer);
				RequestTimer = null;
				if (RebelTimer[i] != null)
					KillTimer(RebelTimer[i]);
				RebelTimer[i] = null;
				StripAllWeapons(i);
				SetEntityRenderColor(client, gc_iCapitulationColorRed.IntValue, gc_iCapitulationColorGreen.IntValue, gc_iCapitulationColorBlue.IntValue, 255);
				CapitulationTimer[i] = CreateTimer(gc_fCapitulationTime.FloatValue, GiveKnifeCapitulated, i);
				CPrintToChatAll("%t %t", "warden_tag", "request_accepted", i, client);
			}
		}
		if(choice == 0)  //no
		{
			LoopClients(i) if(g_bCapitulated[i])
			{
				IsRequest = false;
				if (RequestTimer != null)
					KillTimer(RequestTimer);
				RequestTimer = null;
				SetEntityRenderColor(i, 255, 0, 0, 255);
				g_bCapitulated[i] = false;
				if (RebelTimer[i] != null)
					KillTimer(RebelTimer[i]);
				RebelTimer[i] = null;
				CPrintToChatAll("%t %t", "warden_tag", "request_noaccepted", i, client);
			}
		}
	}
}

//heal
public Action Command_Heal(int client, int args)
{
	if (gc_bPlugin.BoolValue)
	{
		if (gc_bHeal.BoolValue)
		{
			if (GetClientTeam(client) == CS_TEAM_T && (IsPlayerAlive(client)))
			{
				if (HealTimer[client] == null)
				{
					if (g_iHealCounter[client] < gc_iHealLimit.IntValue)
					{
						if (warden_exist())
						{
							if((GetClientHealth(client) < 100) || !gc_bHealthCheck.BoolValue)
							{
								if(!IsRequest)
								{
									IsRequest = true;
									RequestTimer = CreateTimer (gc_fHealTime.FloatValue, IsRequestTimer);
									g_bHealed[client] = true;
									g_iHealCounter[client]++;
									CPrintToChatAll("%t %t", "request_tag", "request_heal", client);
									SetEntityRenderColor(client, gc_iHealColorRed.IntValue, gc_iHealColorGreen.IntValue, gc_iHealColorBlue.IntValue, 255);
									HealTimer[client] = CreateTimer(gc_fHealTime.FloatValue, ResetColorHeal, client);
									LoopClients(i) HealMenu(i);
								}
								else CPrintToChat(client, "%t %t", "request_tag", "request_processing");
							}
							else CPrintToChat(client, "%t %t", "request_tag", "request_fullhp");
						}
						else CPrintToChat(client, "%t %t", "request_tag", "warden_noexist");
					}
					else CPrintToChat(client, "%t %t", "request_tag", "request_healtimes");
				}
				else CPrintToChat(client, "%t %t", "request_tag", "request_alreadyhealed");
			}
			else CPrintToChat(client, "%t %t", "request_tag", "request_notalivect");
		}
	}
	return Plugin_Handled;
}

public Action HealMenu(int warden)
{
	if (IsValidClient(warden, false, false) && warden_iswarden(warden))
	{
		char info5[255], info6[255], info7[255];
		Menu menu1 = CreateMenu(HealMenuHandler);
		Format(info5, sizeof(info5), "%T", "request_acceptheal", warden);
		menu1.SetTitle(info5);
		Format(info6, sizeof(info6), "%T", "warden_no", warden);
		Format(info7, sizeof(info7), "%T", "warden_yes", warden);
		menu1.AddItem("1", info7);
		menu1.AddItem("0", info6);
		menu1.Display(warden,gc_fHealTime.IntValue);
	}
}

public int HealMenuHandler(Menu menu, MenuAction action, int client, int Position)
{
	if(action == MenuAction_Select)
	{
		char Item[11];
		menu.GetItem(Position,Item,sizeof(Item));
		int choice = StringToInt(Item);
		if(choice == 1)
		{
			LoopClients(i) if(g_bHealed[i])
			{
				IsRequest = false;
				RequestTimer = null;
				if(gc_bHealthShot) GivePlayerItem(i, "weapon_healthshot");
				CPrintToChat(i, "%t %t", "request_tag", "request_health");
				CPrintToChatAll("%t %t", "warden_tag", "request_accepted", i, client);
			}
		}
		if(choice == 0)
		{
			IsRequest = false;
			RequestTimer = null;
			LoopClients(i) if(g_bHealed[i])
			{
				CPrintToChatAll("%t %t", "warden_tag", "request_noaccepted", i, client);
			}
		}
	}
}

// Request Menu

public Action RequestMenu(int client, int args)
{
	if(gc_bPlugin.BoolValue)
	{
		if (GetClientTeam(client) == CS_TEAM_T)
		{
			Menu reqmenu = new Menu(RequestMenuHandler);
			
			char menuinfo19[255], menuinfo20[255], menuinfo21[255], menuinfo22[255], menuinfo29[255];
			
			Format(menuinfo29, sizeof(menuinfo29), "%T", "request_menu_title", client);
			reqmenu.SetTitle(menuinfo29);
			
			if(gc_bFreeKill.BoolValue && (!IsPlayerAlive(client)))
			{
				Format(menuinfo19, sizeof(menuinfo19), "%T", "request_menu_freekill", client);
				reqmenu.AddItem("freekill", menuinfo19);
			}
			if(gc_bRefuse.BoolValue && (IsPlayerAlive(client)))
			{
				Format(menuinfo19, sizeof(menuinfo19), "%T", "request_menu_refuse", client);
				reqmenu.AddItem("refuse", menuinfo19);
			}
			if(gc_bCapitulation.BoolValue && (IsPlayerAlive(client)))
			{
				Format(menuinfo20, sizeof(menuinfo20), "%T", "request_menu_capitulation", client);
				reqmenu.AddItem("capitulation", menuinfo20);
			}
			if(gc_bRepeat.BoolValue && (IsPlayerAlive(client)))
			{
				Format(menuinfo21, sizeof(menuinfo21), "%T", "request_menu_repeat", client);
				reqmenu.AddItem("repeat", menuinfo21);
			}
			if(gc_bHeal.BoolValue && (IsPlayerAlive(client)))
			{
				Format(menuinfo22, sizeof(menuinfo22), "%T", "request_menu_heal", client);
				reqmenu.AddItem("heal", menuinfo22);
			}
			reqmenu.ExitButton = true;
			reqmenu.ExitBackButton = true;
			reqmenu.Display(client, MENU_TIME_FOREVER);
		}
		else CPrintToChat(client, "%t %t", "request_tag", "request_notalivect");
	}
}


public int RequestMenuHandler(Menu reqmenu, MenuAction action, int client, int selection)
{
	if (action == MenuAction_Select)
	{
		char info[32];
		
		reqmenu.GetItem(selection, info, sizeof(info));
		
		if ( strcmp(info,"refuse") == 0 ) 
		{
			FakeClientCommand(client, "sm_refuse");
		} 
		else if ( strcmp(info,"freekill") == 0 ) 
		{
			FakeClientCommand(client, "sm_freekill");
		} 
		else if ( strcmp(info,"repeat") == 0 ) 
		{
			FakeClientCommand(client, "sm_repeat");
		} 
		else if ( strcmp(info,"capitulation") == 0 ) 
		{
			FakeClientCommand(client, "sm_capitulation");
		} 
		else if ( strcmp(info,"heal") == 0 )
		{
			FakeClientCommand(client, "sm_heal");
		}
	}
	else if(action == MenuAction_Cancel) 
	{
		if(selection == MenuCancel_ExitBack) 
		{
			FakeClientCommand(client, "sm_menu");
		}
	}
	else if (action == MenuAction_End)
	{
		delete reqmenu;
	}
}

public Action NoAllowRefuse(Handle timer)
{
	if (g_iCountStopTime > 0)
	{
		if (g_iCountStopTime < 4)
		{
			LoopValidClients(client, false, true)
			{
				PrintHintText(client,"%t", "warden_stopcountdown_nc", g_iCountStopTime);
			}
			CPrintToChatAll("%t %t", "warden_tag" , "warden_stopcountdown", g_iCountStopTime);
		}
		g_iCountStopTime--;
		return Plugin_Continue;
	}
	if (g_iCountStopTime == 0)
	{
		LoopValidClients(client, false, true)
		{
			PrintHintText(client, "%t", "warden_countdownstop_nc");
			if(gc_bSounds.BoolValue)
			{
				EmitSoundToAllAny(g_sSoundRefuseStopPath);
			}
			g_bAllowRefuse = false;
			AllowRefuseTimer = null;
			g_iCountStopTime = gc_fRefuseTime.IntValue;
			return Plugin_Stop;
		}
		CPrintToChatAll("%t %t", "warden_tag" , "warden_countdownstop");
	}
	return Plugin_Continue;
}

//FreeKill

public Action Command_Freekill(int client, int args)
{
	if (gc_bPlugin.BoolValue)
	{
		if (gc_bFreeKill.BoolValue)
		{
			if (GetClientTeam(client) == CS_TEAM_T && (!IsPlayerAlive(client)))
			{
				if(!IsRequest)
				{
					if(g_iKilledBy[client] != -1)
					{
						IsRequest = true;
						RequestTimer = CreateTimer (20.0, IsRequestTimer);
						g_bFreeKilled[client] = true;
						
						LogMessage("Player %L reports %L for freekilling", client, g_iKilledBy[client]);
						int a = GetRandomAdmin();
						if ((a != -1) && gc_bReportAdmin.BoolValue)
						{
							FreeKillAcceptMenu(a);
							CPrintToChatAll("%t %t", "request_tag", "request_freekill", client, g_iKilledBy[client], a);
						}
						else LoopClients(i) if (warden_iswarden(i) && gc_bReportWarden.BoolValue)
						{
							FreeKillAcceptMenu(i);
							CPrintToChatAll("%t %t", "request_tag", "request_freekill", client, g_iKilledBy[client], i);
						}
					}
					else CPrintToChat(client, "%t %t", "request_tag", "request_nokiller");
				}
				else CPrintToChat(client, "%t %t", "request_tag", "request_processing");
			}
			else CPrintToChat(client, "%t %t", "request_tag", "request_aliveorct");
		}
	}
	return Plugin_Handled;
}

stock int GetRandomAdmin() 
{
	int[] admins = new int[MaxClients];
	int adminsCount;
	LoopClients(i)
	{
		if (CheckCommandAccess(i, "sm_map", ADMFLAG_CHANGEMAP, true))
		{
			admins[adminsCount++] = i;
		}
	}
	return (adminsCount == 0) ? -1 : admins[GetRandomInt(0, adminsCount-1)];
}

public Action FreeKillAcceptMenu(int client)
{
	if (IsValidClient(client, false, true))
	{
		char info[255];
		Menu menu1 = CreateMenu(FreeKillAcceptHandler);
		Format(info, sizeof(info), "%T", "request_pardonfreekill", client);
		menu1.SetTitle(info);
		Format(info, sizeof(info), "%T", "warden_no", client);
		menu1.AddItem("0", info);
		Format(info, sizeof(info), "%T", "warden_yes", client);
		menu1.AddItem("1", info);
		menu1.ExitButton = true;
		menu1.Display(client, MENU_TIME_FOREVER);
	}
}

public int FreeKillAcceptHandler(Menu menu, MenuAction action, int client, int Position)
{
	if(action == MenuAction_Select)
	{
		char Item[11];
		menu.GetItem(Position,Item,sizeof(Item));
		int choice = StringToInt(Item);
		if(choice == 1) //yes
		{
			char info[255];
			
			Menu menu1 = CreateMenu(FreeKillHandler);
			Format(info, sizeof(info), "%T", "request_handlefreekill", client);
			menu1.SetTitle(info);
			Format(info, sizeof(info), "%T", "request_respawnvictim", client);
			if(gc_bFreeKillRespawn.BoolValue) menu1.AddItem("1", info);
			Format(info, sizeof(info), "%T", "request_killfreekiller", client);
			if(gc_bFreeKillKill.BoolValue) menu1.AddItem("2", info);
			Format(info, sizeof(info), "%T", "request_freeday", client);
			if(gc_bFreeKillFreeDay.BoolValue) menu1.AddItem("3", info);
			Format(info, sizeof(info), "%T", "request_swapfreekiller", client);
			if(gc_bFreeKillSwap.BoolValue) menu1.AddItem("4", info);
			menu1.Display(client, MENU_TIME_FOREVER);
			LoopClients(i) if(g_bFreeKilled[i]) CPrintToChatAll("%t %t", "warden_tag", "request_accepted", i, client);
		}
		if(choice == 0) //no
		{
			IsRequest = false;
			RequestTimer = null;
			
			LoopClients(i) if(g_bFreeKilled[i])
			{
				CPrintToChatAll("%t %t", "warden_tag", "request_noaccepted", i, client);
				g_bFreeKilled[i] = false;
			}
		}
	}
}

public int FreeKillHandler(Menu menu, MenuAction action, int client, int Position)
{
	if(action == MenuAction_Select)
	{
		char Item[11];
		menu.GetItem(Position,Item,sizeof(Item));
		int choice = StringToInt(Item);
		
		IsRequest = false;
		RequestTimer = null;
		
		if(choice == 1) //respawn
		{
			LoopClients(i) if(g_bFreeKilled[i])
			{
				g_bFreeKilled[i] = false;
				CS_RespawnPlayer(i);
				LogMessage("Warden %L accept freekill request and respawned %L", client, i);
				CPrintToChat(i, "%t %t", "request_tag", "request_respawned");
				CPrintToChatAll("%t %t", "warden_tag", "request_respawnedall", i);
			}
		}
		if(choice == 2) //kill freekiller
		{
			LoopClients(i) if(g_bFreeKilled[i])
			{
				g_bFreeKilled[i] = false;
				ForcePlayerSuicide(g_iKilledBy[i]);
				LogMessage("Warden %L accept freekill request of %L  and killed %L", client, i, g_iKilledBy[i]);
				CPrintToChat(g_iKilledBy[i], "%t %t", "request_tag", "request_killbcfreekill");
				CPrintToChatAll("%t %t", "warden_tag", "request_killbcfreekillall", i);
			}
		}
		if(choice == 3) //freeday
		{
			LoopClients(i) if(g_bFreeKilled[i])
			{
				g_bFreeKilled[i] = false;
				LogMessage("Warden %L accept freekill request of %L give a freeday", client, i);
				FakeClientCommand(client, "sm_setfreeday");
			}
		}
		if(choice == 4) //swap freekiller
		{
			LoopClients(i) if(g_bFreeKilled[i])
			{
				g_bFreeKilled[i] = false;
				ClientCommand(g_iKilledBy[i], "jointeam %i", CS_TEAM_T);
				CPrintToChat(g_iKilledBy[i], "%t %t", "request_tag", "request_swapbcfreekill");
				LogMessage("Warden %L accept freekill request of %L  and swaped %L to T", client, i, g_iKilledBy[i]);
				CPrintToChatAll("%t %t", "warden_tag", "request_swapbcfreekillall", i);
			}
		}
	}
	else if (action == MenuAction_End)
	{
		delete menu;
	}
}

public Action playerDeath(Event event, const char[] name, bool dontBroadcast) 
{
	int victim = GetClientOfUserId(GetEventInt(event, "userid")); // Get the dead clients id
	int attacker = GetClientOfUserId(GetEventInt(event, "attacker")); // Get the attacker clients id
	
	if(IsValidClient(attacker, true, false) && (attacker != victim)) g_iKilledBy[victim] = attacker;
}

public Action IsRequestTimer(Handle timer, any client)
{
	IsRequest = false;
	RequestTimer = null;
	LoopClients(i) if(g_bFreeKilled[i]) g_bFreeKilled[i] = false;
}

public Action RepeatEnd(Handle timer, any client)
{
	RepeatTimer[client] = null;
	g_bRepeated[client] = false;
}

public Action ResetColorRefuse(Handle timer, any client)
{
	if (IsClientConnected(client))
	{
		SetEntityRenderColor(client, 255, 255, 255, 255);
	}
	RefuseTimer[client] = null;
	g_bRefused[client] = false;
}

public Action ResetColorHeal(Handle timer, any client)
{
	if (IsClientConnected(client))
	{
		SetEntityRenderColor(client, 255, 255, 255, 255);
	}
	HealTimer[client] = null;
	g_bHealed[client] = false;
}

public Action GiveKnifeCapitulated(Handle timer, any client)
{
	if (IsClientConnected(client))
	{
		GivePlayerItem(client,"weapon_knife");
		CPrintToChat(client, "%t %t", "request_tag", "request_knifeback");
		SetEntityRenderColor(client, 255, 255, 255, 255);
	}
	CapitulationTimer[client] = null;
}


public Action RebelNoAction(Handle timer, any client)
{
	if (IsClientConnected(client))
	{
		SetEntityRenderColor(client, 255, 0, 0, 255);
	}
	g_bCapitulated[client] = false;
	RebelTimer[client] = null;
}


public Action OnWeaponCanUse(int client, int weapon)
{
	if(g_bCapitulated[client])
	{
		char sWeapon[32];
		GetEdictClassname(weapon, sWeapon, sizeof(sWeapon));
		
		if(!StrEqual(sWeapon, "weapon_knife"))
		{
			if (IsValidClient(client, true, false))
			{
				return Plugin_Handled;
			}
		}
	}
	return Plugin_Continue;
}

public Action OnTakedamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (IsValidClient(attacker, true, false) && GetClientTeam(attacker) == CS_TEAM_T && IsPlayerAlive(attacker))
	{
		if(g_bCapitulated[attacker] && gc_bCapitulationDamage.BoolValue)
		{
			CPrintToChat(attacker, "%t %t", "request_tag", "request_nodamage");
			return Plugin_Handled;
		}
	}
	return Plugin_Continue;
}

public int OnAvailableLR(int Announced)
{
	LoopClients(i) g_bCapitulated[i] = false;
}
