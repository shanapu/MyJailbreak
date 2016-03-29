//includes
#include <cstrike>
#include <sourcemod>
#include <colors>
#include <sdktools>
#include <smartjaildoors>
#include <sdkhooks>
#include <wardn>
#include <emitsoundany>
#include <autoexecconfig>
#include <clientprefs>

//Compiler Options
#pragma semicolon 1

#define PLUGIN_VERSION   "0.x"



int VoteCount;
int CatchRound;

ConVar gc_sSoundPath1;
char g_sSoundPath1[256];
ConVar gc_sSoundPath2;
char g_sSoundPath2[256];

bool catched[MAXPLAYERS+1];

ConVar gc_bPlugin;
ConVar gc_bTag;
ConVar gc_bSetW;
ConVar gc_bSetA;
ConVar gc_bVote;
ConVar gc_bSounds;
ConVar gc_bOverlays;
ConVar gc_iRoundLimits;
ConVar gc_iRoundWait;
ConVar gc_iRoundTime;
ConVar gc_sOverlayFreeze;
ConVar g_iSetRoundTime;

ConVar gc_bSprintUse;

ConVar gc_fCooldown;
ConVar gc_bSprint;
ConVar gc_fSpeed;
ConVar gc_fTime;





int g_iOldRoundTime;
int g_iRoundLimits;

Handle CatchMenu;


Handle SprintTimer[MAXPLAYERS+1];





	

Handle UseCvar;

bool IsCatch;
bool StartCatch;

char voted[1500];
char g_sOverlayFreeze[256];


public Plugin myinfo = {
	name = "MyJailbreak - Catch & freeze",
	author = "shanapu & Floody.de, fransico",
	description = "Jailbreak Catch script",
	version = PLUGIN_VERSION,
	url = ""
};



public void OnPluginStart()
{
	// Translation
	LoadTranslations("MyJailbreakWarden.phrases");
	LoadTranslations("MyJailbreakCatch.phrases");
	
	RegConsoleCmd("sm_setcatch", SetCatch);
	RegConsoleCmd("sm_catch", VoteCatch);
	RegConsoleCmd("sm_catchfreeze", VoteCatch);
	RegConsoleCmd("sm_sprint", Command_StartSprint, "Starts the sprint.");
	
	AutoExecConfig_SetFile("MyJailbreak_catch");
	AutoExecConfig_SetCreateFile(true);
	
	AutoExecConfig_CreateConVar("sm_catch_version", "PLUGIN_VERSION", "The version of the SourceMod plugin MyJailBreak - catch", FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_DONTRECORD);
	gc_bPlugin = AutoExecConfig_CreateConVar("sm_catch_enable", "1", "0 - disabled, 1 - enable catch");
	gc_bSetW = AutoExecConfig_CreateConVar("sm_catch_setw", "1", "0 - disabled, 1 - allow warden to set catch round", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	gc_bSetA = AutoExecConfig_CreateConVar("sm_catch_seta", "1", "0 - disabled, 1 - allow admin to set catch round", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	gc_bVote = AutoExecConfig_CreateConVar("sm_catch_vote", "1", "0 - disabled, 1 - allow player to vote for catch", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	gc_bOverlays = AutoExecConfig_CreateConVar("sm_catch_overlays", "1", "0 - disabled, 1 - enable overlays", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	gc_bSounds = AutoExecConfig_CreateConVar("sm_catchsounds_enable", "1", "0 - disabled, 1 - enable warden sounds");
	gc_sSoundPath1 = AutoExecConfig_CreateConVar("sm_catch_sounds_freeze", "music/myjailbreak/freeze.mp3", "Path to the sound which should be played on freeze.");
	gc_sSoundPath1.GetString(g_sSoundPath1, sizeof(g_sSoundPath1));
	HookConVarChange(gc_sSoundPath1, OnSettingChanged);
	gc_sSoundPath2 = AutoExecConfig_CreateConVar("sm_catch_sounds_unfreeze", "music/myjailbreak/unfreeze.mp3", "Path to the sound which should be played on unfreeze.");
	gc_sSoundPath2.GetString(g_sSoundPath2, sizeof(g_sSoundPath2));
	HookConVarChange(gc_sSoundPath1, OnSettingChanged);
	gc_iRoundTime = AutoExecConfig_CreateConVar("sm_catch_roundtime", "5", "Round time for a single catch round");
	g_iSetRoundTime = FindConVar("mp_roundtime");
	gc_iRoundLimits = AutoExecConfig_CreateConVar("sm_catch_roundsnext", "3", "Rounds until event can be started again.");
	g_iRoundLimits = gc_iRoundLimits.IntValue;
	gc_iRoundWait = AutoExecConfig_CreateConVar("sm_catch_roundwait", "3", "Rounds until event can be started after mapchange.", FCVAR_NOTIFY, true, 0.0, true, 255.0);
	gc_bTag = AutoExecConfig_CreateConVar("sm_hide_tag", "1", "Allow \"MyJailbreak\" to be added to the server tags? So player will find servers with MyJB faster. it dont touch you sv_tags", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	gc_sOverlayFreeze = AutoExecConfig_CreateConVar("sm_catch_overlayfreeze_path", "overlays/MyJailbreak/ansage2" , "Path to the Freeze Overlay DONT TYPE .vmt or .vft");
	gc_sOverlayFreeze.GetString(g_sOverlayFreeze , sizeof(g_sOverlayFreeze));
	HookConVarChange(gc_sOverlayFreeze, OnSettingChanged);
	gc_bSprintUse = AutoExecConfig_CreateConVar("sm_catch_sprint_button", "1",
	"Enable/Disable +use button support", 0, true, 0.0, true, 1.0);
	 gc_fCooldown= AutoExecConfig_CreateConVar("sm_catch_sprint_cooldown", "10","Time in seconds the player must wait for the next sprint", 0, true, 1.0, true, 15.0);
	gc_bSprint= AutoExecConfig_CreateConVar("sm_catch_sprint_enable", "1","Enable/Disable ShortSprint", 0, true, 0.0, true, 1.0);
	gc_fSpeed= AutoExecConfig_CreateConVar("sm_catch_sprint_speed", "1.25","Ratio for how fast the player will sprint", 0, true, 1.01, true, 5.00);
	gc_fTime= AutoExecConfig_CreateConVar("sm_catch_sprint_time", "3.5", "Time in seconds the player will sprint",
	0, true, 1.0, true, 30.0);
	AutoExecConfig_CacheConvars();
	AutoExecConfig_ExecuteFile();
	AutoExecConfig_CleanFile();
	AutoExecConfig(true, "MyJailbreak_Catch");
	
	IsCatch = false;
	StartCatch = false;
	VoteCount = 0;
	CatchRound = 0;
	
	HookEvent("round_start", RoundStart);
	HookEvent("player_spawn", Event_PlayerSpawn);
	HookEvent("round_end", RoundEnd);
	HookEvent("player_team", EventPlayerTeam);
	HookEvent("player_death", EventPlayerTeam);
	
	for(int i = 1; i <= MaxClients; i++)
		if(IsClientInGame(i)) OnClientPutInServer(i);
}


public void OnMapStart()
{

	PrecacheSoundAnyDownload(g_sSoundPath1);
	PrecacheSoundAnyDownload(g_sSoundPath2);
	PrecacheOverlayAnyDownload(g_sOverlayFreeze);
	
	VoteCount = 0;
	CatchRound = 0;
	IsCatch = false;
	StartCatch = false;
	g_iRoundLimits = gc_iRoundWait.IntValue;
	
	PrecacheSound("player/suit_sprint.wav", true);


}

void PrecacheSoundAnyDownload(char[] sSound)
{
	if(gc_bSounds.BoolValue)	
	{
	PrecacheSoundAny(sSound);
	
	char sBuffer[256];
	Format(sBuffer, sizeof(sBuffer), "sound/%s", sSound);
	AddFileToDownloadsTable(sBuffer);
	}
}
void PrecacheOverlayAnyDownload(char[] sOverlay)
{
	if(gc_bOverlays.BoolValue)	
	{
	char sBufferVmt[256];
	char sBufferVtf[256];
	Format(sBufferVmt, sizeof(sBufferVmt), "%s.vmt", sOverlay);
	Format(sBufferVtf, sizeof(sBufferVtf), "%s.vtf", sOverlay);
	PrecacheDecal(sBufferVmt, true);
	PrecacheDecal(sBufferVtf, true);
	Format(sBufferVmt, sizeof(sBufferVmt), "materials/%s.vmt", sOverlay);
	Format(sBufferVtf, sizeof(sBufferVtf), "materials/%s.vtf", sOverlay);
	AddFileToDownloadsTable(sBufferVmt);
	AddFileToDownloadsTable(sBufferVtf);
	}
}

public void OnConfigsExecuted()
{
	g_iRoundLimits = gc_iRoundWait.IntValue;
	
	if (gc_bTag.BoolValue)
	{
		ConVar hTags = FindConVar("sv_tags");
		char sTags[128];
		hTags.GetString(sTags, sizeof(sTags));
		if (StrContains(sTags, "MyJailbreak", false) == -1)
		{
			StrCat(sTags, sizeof(sTags), ", MyJailbreak");
			hTags.SetString(sTags);
		}
	}
}

public int OnSettingChanged(Handle convar, const char[] oldValue, const char[] newValue)
{
	if(convar == gc_sSoundPath1)
	{
		strcopy(g_sSoundPath1, sizeof(g_sSoundPath1), newValue);
		PrecacheSoundAnyDownload(g_sSoundPath1);
	}
	else if(convar == gc_sSoundPath2)
	{
		strcopy(g_sSoundPath2, sizeof(g_sSoundPath2), newValue);
		PrecacheSoundAnyDownload(g_sSoundPath2);
	}
	else if(convar == gc_sOverlayFreeze)
	{
		strcopy(g_sOverlayFreeze, sizeof(g_sOverlayFreeze), newValue);
	}
}

public void RoundEnd(Handle:event, char[] name, bool:dontBroadcast)
{
	int winner = GetEventInt(event, "winner");
	
	if (IsCatch)
	{
		for(int client=1; client <= MaxClients; client++)
		{
			if (IsClientInGame(client)) SetEntData(client, FindSendPropInfo("CBaseEntity", "m_CollisionGroup"), 0, 4, true);
			
		}
		
		
		if (winner == 2) PrintCenterTextAll("%t", "catch_twin");
		if (winner == 3) PrintCenterTextAll("%t", "catch_ctwin");
		IsCatch = false;
		StartCatch = false;
		CatchRound = 0;
		Format(voted, sizeof(voted), "");
		SetCvar("sm_hosties_lr", 1);
		SetCvar("sm_war_enable", 1);
		SetCvar("sm_hide_enable", 1);
		SetCvar("sm_weapons_enable", 1);
		SetCvar("sm_zombie_enable", 1);
		SetCvar("sm_duckhunt_enable", 1);
		SetCvar("sm_dice_enable", 1);
		SetCvar("sm_beacon_enabled", 0);
		SetCvar("sv_infinite_ammo", 0);
		SetCvar("sm_ffa_enable", 1);
		SetCvar("sm_warden_enable", 1);
		g_iSetRoundTime.IntValue = g_iOldRoundTime;

		CPrintToChatAll("%t %t", "catch_tag" , "catch_end");
	}
	if (StartCatch)
	{
	g_iOldRoundTime = g_iSetRoundTime.IntValue;
	g_iSetRoundTime.IntValue = gc_iRoundTime.IntValue;


	}
}

public Action SetCatch(int client,int args)
{
	if (gc_bPlugin.BoolValue)	
	{
	if (warden_iswarden(client))
	{
	if (gc_bSetW.BoolValue)	
			{
			if (!IsCatch && !StartCatch)
				{
	if (g_iRoundLimits == 0)
	{
		StartNextRound();
	}else CPrintToChat(client, "%t %t", "catch_tag" , "catch_wait", g_iRoundLimits);
	}else CPrintToChat(client, "%t %t", "catch_tag" , "catch_progress");
	}else CPrintToChat(client, "%t %t", "warden_tag" , "catch_setbywarden");
	}else if (CheckCommandAccess(client, "sm_map", ADMFLAG_CHANGEMAP, true))
	{
	if (gc_bSetA.BoolValue)	
			{
			if (!IsCatch && !StartCatch)
				{
	if (g_iRoundLimits == 0)
	{
		StartNextRound();
	}else CPrintToChat(client, "%t %t", "catch_tag" , "catch_wait", g_iRoundLimits);
	}else CPrintToChat(client, "%t %t", "catch_tag" , "catch_progress");
	}else CPrintToChat(client, "%t %t", "catch_tag" , "catch_setbyadmin");
	}else CPrintToChat(client, "%t %t", "warden_tag" , "warden_notwarden");
	}else CPrintToChat(client, "%t %t", "catch_tag" , "catch_disabled");
}

void StartNextRound()
{
	StartCatch = true;
	g_iRoundLimits = gc_iRoundLimits.IntValue;
	VoteCount = 0;
	SetCvar("sm_hide_enable", 0);
	SetCvar("sm_ffa_enable", 0);
	SetCvar("sm_zombie_enable", 0);
	SetCvar("sm_duckhunt_enable", 0);
	SetCvar("sm_war_enable", 0);
	SetCvar("sm_noscope_enable", 0);
	CPrintToChatAll("%t %t", "catch_tag" , "catch_next");
	
	PrintCenterTextAll("%t", "catch_next_nc");
}

public OnClientPutInServer(client)
{
	catched[client] = false;
	SDKHook(client, SDKHook_WeaponCanUse, OnWeaponCanUse);
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
}

public Action:OnWeaponCanUse(client, weapon)
{
	char sWeapon[32];
	GetEdictClassname(weapon, sWeapon, sizeof(sWeapon));

	if(!StrEqual(sWeapon, "weapon_knife"))
		{
			if (IsClientInGame(client) && IsPlayerAlive(client))
			{
			if(IsCatch == true)
			{
			return Plugin_Handled;
			}
			}
		}
	return Plugin_Continue;
}

public Action:OnTakeDamage(victim, &attacker, &inflictor, &Float:damage, &damagetype)
{
	if(!IsValidClient(victim) || attacker == victim || !IsValidClient(attacker)) return Plugin_Continue;
	
	if(IsCatch == false)
	{
		return Plugin_Continue;
	}
	
	if(GetClientTeam(victim) == CS_TEAM_T && GetClientTeam(attacker) == CS_TEAM_CT && !catched[victim])
	{
		CatchEm(victim, attacker);
		CheckStatus();
	}
	if(GetClientTeam(victim) == CS_TEAM_T && GetClientTeam(attacker) == CS_TEAM_T && catched[victim] && !catched[attacker])
	{
		FreeEm(victim, attacker);
	}

	
	return Plugin_Handled;
}

public IsValidClient( client ) 
{
	if ( !( 1 <= client <= MaxClients ) || !IsClientInGame(client) ) 
	return false; 
	
	return true; 
}

public void RoundStart(Handle:event, char[] name, bool:dontBroadcast)
{
	if (StartCatch)
	{
		char info1[255], info2[255], info3[255], info4[255], info5[255], info6[255], info7[255], info8[255];
		
		SetCvar("sm_hosties_lr", 0);
		SetCvar("sm_warden_enable", 0);
		SetCvar("sm_beacon_enabled", 1);
		SetCvar("sv_infinite_ammo", 1);
		SetCvar("sm_weapons_enable", 0);
		SetCvar("sm_dice_enable", 0);
		IsCatch = true;
		CatchRound++;
		StartCatch = false;
		SJD_OpenDoors();
		CatchMenu = CreatePanel();
		Format(info1, sizeof(info1), "%T", "catch_info_Title", LANG_SERVER);
		SetPanelTitle(CatchMenu, info1);
		DrawPanelText(CatchMenu, "                                   ");
		Format(info2, sizeof(info2), "%T", "catch_info_Line1", LANG_SERVER);
		DrawPanelText(CatchMenu, info2);
		DrawPanelText(CatchMenu, "-----------------------------------");
		Format(info3, sizeof(info3), "%T", "catch_info_Line2", LANG_SERVER);
		DrawPanelText(CatchMenu, info3);
		Format(info4, sizeof(info4), "%T", "catch_info_Line3", LANG_SERVER);
		DrawPanelText(CatchMenu, info4);
		Format(info5, sizeof(info5), "%T", "catch_info_Line4", LANG_SERVER);
		DrawPanelText(CatchMenu, info5);
		Format(info6, sizeof(info6), "%T", "catch_info_Line5", LANG_SERVER);
		DrawPanelText(CatchMenu, info6);
		Format(info7, sizeof(info7), "%T", "catch_info_Line6", LANG_SERVER);
		DrawPanelText(CatchMenu, info7);
		Format(info8, sizeof(info8), "%T", "catch_info_Line7", LANG_SERVER);
		DrawPanelText(CatchMenu, info8);
		DrawPanelText(CatchMenu, "-----------------------------------");
		
		if (CatchRound > 0)
			{
				for(int client=1; client <= MaxClients; client++)
				{
					
					if (IsClientInGame(client))
					{
	if (GetClientTeam(client) == 3) //ct
	{

	}
	if (GetClientTeam(client) == 2) //t
	{
	catched[client] = false;
	}
					}
					if (IsClientInGame(client))
					{
					SetEntData(client, FindSendPropInfo("CBaseEntity", "m_CollisionGroup"), 2, 4, true);
					SendPanelToClient(CatchMenu, client, Pass, 15);
					}
				}
				
				PrintCenterTextAll("%t", "catch_start");
				CPrintToChatAll("%t %t", "catch_tag" , "catch_start");
				}
	}else
	{
		if (g_iRoundLimits > 0) g_iRoundLimits--;
	}
}

public Pass(Handle:menu, MenuAction:action, param1, param2)
{
}

public Action VoteCatch(int client,int args)
{
	char steamid[64];
	GetClientAuthId(client, AuthId_Steam2, steamid, sizeof(steamid));
	
	if (gc_bPlugin.BoolValue)
	{
		if (gc_bVote.BoolValue)
		{	
		if (GetTeamClientCount(3) > 0)
		{
		
				if (!IsCatch && !StartCatch)
				{	
				if (g_iRoundLimits == 0)
			{
					if (StrContains(voted, steamid, true) == -1)
					{
	int playercount = (GetClientCount(true) / 2);
	
	VoteCount++;
	
	int Missing = playercount - VoteCount + 1;
	
	Format(voted, sizeof(voted), "%s,%s", voted, steamid);
	
	if (VoteCount > playercount)
	{
		StartNextRound();
	}
	else CPrintToChatAll("%t %t", "catch_tag" , "catch_need", Missing, client);
	
					}
					else CPrintToChat(client, "%t %t", "catch_tag" , "catch_voted");
				}
			else CPrintToChat(client, "%t %t", "catch_tag" , "war_wait", g_iRoundLimits);
				}
				else CPrintToChat(client, "%t %t", "catch_tag" , "catch_progress");
			
		}
		else CPrintToChat(client, "%t %t", "catch_tag" , "catch_minct");
		}else CPrintToChat(client, "%t %t", "catch_tag" , "catch_voting");
	}
	else CPrintToChat(client, "%t %t", "catch_tag" , "catch_disabled");
}



public SetCvar(char cvarName[64], value)
{
	UseCvar = FindConVar(cvarName);
	if(UseCvar == null) return;
	
	int flags = GetConVarFlags(UseCvar);
	flags &= ~FCVAR_NOTIFY;
	SetConVarFlags(UseCvar, flags);

	SetConVarInt(UseCvar, value);

	flags |= FCVAR_NOTIFY;
	SetConVarFlags(UseCvar, flags);
}

public SetCvarF(char cvarName[64], Float:value)
{
	UseCvar = FindConVar(cvarName);
	if(UseCvar == null) return;

	int flags = GetConVarFlags(UseCvar);
	flags &= ~FCVAR_NOTIFY;
	SetConVarFlags(UseCvar, flags);

	SetConVarFloat(UseCvar, value);

	flags |= FCVAR_NOTIFY;
	SetConVarFlags(UseCvar, flags);
}

public OnMapEnd()
{
	IsCatch = false;
	StartCatch = false;
	VoteCount = 0;
	CatchRound = 0;
	
	voted[0] = '\0';
}

public OnClientDisconnect_Post(client)
{
	if(IsCatch == false)
	{
		return;
	}
	CheckStatus();
}
public Action:EventPlayerTeam(Handle:event, const char[] name, bool:dontBroadcast)
{
	if(IsCatch == false)
	{
		return;
	}
	CheckStatus();
	
	new iClient = GetClientOfUserId(GetEventInt(event, "userid"));
	ResetSprint(iClient);
}

CatchEm(client, attacker)
{
	SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 0.0);
	SetEntityRenderColor(client, 0, 0, 255, 255);
	catched[client] = true;
	CreateTimer( 0.0, ShowOverlayFreeze, client );
	if(gc_bSounds.BoolValue)	
	{
	EmitSoundToAllAny(g_sSoundPath1);
	}
	CPrintToChatAll("%t %t", "catch_tag" , "catch_catch", attacker, client);
}

FreeEm(client, attacker)
{
	SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 1.0);
	SetEntityRenderColor(client, 255, 255, 255, 0);
	catched[client] = false;
	CreateTimer( 0.0, DeleteOverlay, client );
	if(gc_bSounds.BoolValue)	
	{
	EmitSoundToAllAny(g_sSoundPath2);
	}
	CPrintToChatAll("%t %t", "catch_tag" , "catch_unfreeze", attacker, client);
}

CheckStatus()
{
	int number = 0;
	for (int i = 1; i <= MaxClients; i++)
	if(IsClientInGame(i) && IsPlayerAlive(i) && GetClientTeam(i) == CS_TEAM_T && !catched[i]) number++;
	if(number == 0)
	{
	CS_TerminateRound(5.0, CSRoundEnd_CTWin);
	CPrintToChatAll("%t %t", "catch_tag" , "catch_win");
	CreateTimer( 1.0, DeleteOverlay);
	}
}

public Action ShowOverlayFreeze( Handle timer, any client ) {
	
	if(gc_bOverlays.BoolValue)
	{
	int iFlag = GetCommandFlags( "r_screenoverlay" ) & ( ~FCVAR_CHEAT ); 
	SetCommandFlags( "r_screenoverlay", iFlag ); 
	ClientCommand( client, "r_screenoverlay \"%s.vtf\"", g_sOverlayFreeze);
	
	// CreateTimer( 5.0, DeleteOverlay, client );
	}
	return Plugin_Continue;
	
}

public Action  DeleteOverlay( Handle timer, any client ) {
	int iFlag = GetCommandFlags( "r_screenoverlay" ) & ( ~FCVAR_CHEAT ); 
	SetCommandFlags( "r_screenoverlay", iFlag ); 
	ClientCommand( client, "r_screenoverlay \"\"" );
	
	return Plugin_Continue;
}


public Action:Command_StartSprint(client, args)
{
	if (IsCatch)
	{
		if(gc_bSprint.BoolValue && client > 0 && IsClientInGame(client) && IsPlayerAlive(client) && GetClientTeam(client) > 1)
		{
		SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", gc_fSpeed.FloatValue);
		EmitSoundToClient(client, "player/suit_sprint.wav", SOUND_FROM_PLAYER, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, 0.8);
		CPrintToChat(client, "%t %t", "catch_tag" ,"catch_sprint");
		SprintTimer[client] = CreateTimer(gc_fTime.FloatValue, Timer_SprintEnd, client);
		}
		return(Plugin_Handled);
	}else CPrintToChat(client, "%t %t", "catch_tag" , "catch_disabled");
	return(Plugin_Handled);
}

public OnGameFrame()
{
	if (IsCatch)
	{
	if(gc_bSprintUse.BoolValue)
	{
		for(new i = 1; i <= MaxClients; i++)
		{
			if(IsClientInGame(i) && (GetClientButtons(i) & IN_USE))
			{
			Command_StartSprint(i, 0);
			}
		}
		}
		return;
	}
return;
}


ResetSprint(client)
{
	if(SprintTimer[client] != null)
	{
	KillTimer(SprintTimer[client]);
	SprintTimer[client] = null;
	}

	if(GetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue") != 1)
	{
		SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 1.0);
	}
	return;
}

public Action:Timer_SprintEnd(Handle:timer, any:client)
{
	SprintTimer[client] = null;

	if(IsClientInGame(client))
	{

		SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 1.0);

		if(IsPlayerAlive(client) && GetClientTeam(client) > 1)
		{
			SprintTimer[client] = CreateTimer(gc_fCooldown.FloatValue, Timer_SprintCooldown, client);
		}
	}

	return;
}

public Action:Timer_SprintCooldown(Handle:timer, any:client)
{
	SprintTimer[client] = null;

	return;
}

public Event_PlayerSpawn(Handle:event,const String:name[],bool:dontBroadcast)
{
	new iClient = GetClientOfUserId(GetEventInt(event, "userid"));

	ResetSprint(iClient);
	
	return;
}
