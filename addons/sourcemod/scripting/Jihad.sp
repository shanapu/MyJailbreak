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

//Defines
#define PLUGIN_VERSION "0.1"

//Booleans
bool IsJiHad;
bool StartJiHad;
bool IsSprint;
bool jihaded[MAXPLAYERS+1];

//ConVars
ConVar gc_bPlugin;
ConVar gc_bTag;
ConVar gc_bSetW;
ConVar gc_bSetA;
ConVar gc_bVote;
ConVar gc_iKey;
ConVar gc_bSounds;
ConVar gc_bOverlays;
ConVar gc_iRoundLimits;
ConVar gc_iRoundWait;
ConVar gc_iRoundTime;
ConVar gc_iFreezeTime;
ConVar gc_sOverlayFreeze;
ConVar gc_sOverlayStartPath;
ConVar gc_bSprintUse;
ConVar gc_fCooldown;
ConVar gc_bSprint;
ConVar gc_fSpeed;
ConVar gc_fTime;
ConVar gc_sSoundPath1;
ConVar gc_sSoundPath2;
ConVar g_iSetRoundTime;

//Integers
int g_iVoteCount;
int g_iOldRoundTime;
int g_iRoundLimits;
int g_iFreezeTime;
int JiHadRound;

//Handles
Handle SprintTimer[MAXPLAYERS+1];
Handle JiHadMenu;
Handle UseCvar;
Handle FreezeTimer;

//Strings
char g_sSoundPath2[256];
char g_sSoundPath1[256];
char g_sHasVoted[1500];
char g_sOverlayFreeze[256];
char g_sOverlayStart[256];



public Plugin myinfo = {
	name = "MyJailbreak - JiHad & Freeze",
	author = "shanapu & Floody.de, Franc1sco",
	description = "Jailbreak JiHad script",
	version = PLUGIN_VERSION,
	url = ""
};

public void OnPluginStart()
{
	// Translation
	LoadTranslations("MyJailbreakWarden.phrases");
	LoadTranslations("MyJailbreakJiHad.phrases");
	
	//Client Commands

	RegConsoleCmd("sm_setjihad", SetJiHad);
	RegConsoleCmd("sm_jihad", VoteJiHad);
	RegConsoleCmd("sm_jihadfreeze", VoteJiHad);
	RegConsoleCmd("sm_sprint", Command_StartSprint, "Starts the sprint.");
	RegConsoleCmd("sm_makeboom", Command_BombJihad, "Starts the bomb.");
	
	//AutoExecConfig
	AutoExecConfig_SetFile("MyJailbreak_jihad");
	AutoExecConfig_SetCreateFile(true);
	
	AutoExecConfig_CreateConVar("sm_jihad_version", PLUGIN_VERSION, "The version of the SourceMod plugin MyJailBreak - jihad", FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_DONTRECORD);
	gc_bPlugin = AutoExecConfig_CreateConVar("sm_jihad_enable", "1", "0 - disabled, 1 - enable jihad");
	gc_bSetW = AutoExecConfig_CreateConVar("sm_jihad_setw", "1", "0 - disabled, 1 - allow warden to set jihad round", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	gc_bSetA = AutoExecConfig_CreateConVar("sm_jihad_seta", "1", "0 - disabled, 1 - allow admin to set jihad round", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	gc_bVote = AutoExecConfig_CreateConVar("sm_jihad_vote", "1", "0 - disabled, 1 - allow player to vote for jihad", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	gc_iKey = AutoExecConfig_CreateConVar("sm_jihad_key", "1", "1 - Look weapon / 2 - walk / 3 - Secondary Attack");
	gc_iFreezeTime = AutoExecConfig_CreateConVar("sm_zombie_freezetime", "35", "Time freeze zombies");
	gc_iRoundTime = AutoExecConfig_CreateConVar("sm_jihad_roundtime", "5", "Round time for a single jihad round");
	gc_iRoundLimits = AutoExecConfig_CreateConVar("sm_jihad_roundsnext", "3", "Rounds until event can be started again.");
	gc_iRoundWait = AutoExecConfig_CreateConVar("sm_jihad_roundwait", "3", "Rounds until event can be started after mapchange.", FCVAR_NOTIFY, true, 0.0, true, 255.0);
	gc_bOverlays = AutoExecConfig_CreateConVar("sm_jihad_overlays", "1", "0 - disabled, 1 - enable overlays", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	gc_sOverlayStartPath = AutoExecConfig_CreateConVar("sm_zombie_overlaystart_path", "overlays/MyJailbreak/start" , "Path to the start Overlay DONT TYPE .vmt or .vft");
	gc_sOverlayFreeze = AutoExecConfig_CreateConVar("sm_jihad_overlayfreeze_path", "overlays/MyJailbreak/freeze" , "Path to the Freeze Overlay DONT TYPE .vmt or .vft");
	gc_bSounds = AutoExecConfig_CreateConVar("sm_jihad_sounds_enable", "1", "0 - disabled, 1 - enable warden sounds");
	gc_sSoundPath1 = AutoExecConfig_CreateConVar("sm_jihad_sounds_jihad", "music/myjailbreak/jihad.mp3", "Path to the sound which should be played on freeze.");
	gc_sSoundPath2 = AutoExecConfig_CreateConVar("sm_jihad_sounds_boom", "music/myjailbreak/bombe.mp3", "Path to the sound which should be played on unfreeze.");
	gc_bSprintUse = AutoExecConfig_CreateConVar("sm_jihad_sprint_button", "1", "Enable/Disable +use button support", 0, true, 0.0, true, 1.0);
	gc_fCooldown= AutoExecConfig_CreateConVar("sm_jihad_sprint_cooldown", "10","Time in seconds the player must wait for the next sprint", 0, true, 1.0, true, 15.0);
	gc_bSprint= AutoExecConfig_CreateConVar("sm_jihad_sprint_enable", "1","Enable/Disable ShortSprint", 0, true, 0.0, true, 1.0);
	gc_fSpeed= AutoExecConfig_CreateConVar("sm_jihad_sprint_speed", "1.25","Ratio for how fast the player will sprint", 0, true, 1.01, true, 5.00);
	gc_fTime= AutoExecConfig_CreateConVar("sm_jihad_sprint_time", "1.0", "Time in seconds the player will sprint",0, true, 1.0, true, 30.0);
	gc_bTag = AutoExecConfig_CreateConVar("sm_jihad_tag", "1", "Allow \"MyJailbreak\" to be added to the server tags? So player will find servers with MyJB faster. it dont touch you sv_tags", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	
	AutoExecConfig_ExecuteFile();
	AutoExecConfig_CleanFile();
	
	//Hooks
	HookEvent("round_start", RoundStart);
	HookEvent("player_spawn", Event_PlayerSpawn);
	HookEvent("round_end", RoundEnd);
	HookConVarChange(gc_sOverlayFreeze, OnSettingChanged);
	HookConVarChange(gc_sSoundPath1, OnSettingChanged);
	HookConVarChange(gc_sSoundPath2, OnSettingChanged);
	
	//FindConVar
	g_iSetRoundTime = FindConVar("mp_roundtime");
	g_iRoundLimits = gc_iRoundLimits.IntValue;
	g_iFreezeTime = gc_iFreezeTime.IntValue;
	gc_sSoundPath1.GetString(g_sSoundPath1, sizeof(g_sSoundPath1));
	gc_sSoundPath2.GetString(g_sSoundPath2, sizeof(g_sSoundPath2));
	gc_sOverlayFreeze.GetString(g_sOverlayFreeze , sizeof(g_sOverlayFreeze));
	gc_sOverlayStartPath.GetString(g_sOverlayStart , sizeof(g_sOverlayStart));
	
	AddCommandListener(Command_LAW, "+lookatweapon");
	
	IsSprint = false;
	IsJiHad = false;
	StartJiHad = false;
	g_iVoteCount = 0;
	JiHadRound = 0;
	
	for(int i = 1; i <= MaxClients; i++)
		if(IsClientInGame(i)) OnClientPutInServer(i);
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
		PrecacheOverlayAnyDownload(g_sOverlayFreeze);
	}
	else if(convar == gc_sOverlayStartPath)
	{
		strcopy(g_sOverlayStart, sizeof(g_sOverlayStart), newValue);
		PrecacheOverlayAnyDownload(g_sOverlayStart);
	}
}

public void OnMapStart()
{
	PrecacheSoundAnyDownload(g_sSoundPath1);
	PrecacheSoundAnyDownload(g_sSoundPath2);
	PrecacheOverlayAnyDownload(g_sOverlayStart);
	PrecacheOverlayAnyDownload(g_sOverlayFreeze);
	PrecacheSound("player/suit_sprint.wav", true);
	g_iVoteCount = 0;
	JiHadRound = 0;
	IsJiHad = false;
	IsSprint = false;
	StartJiHad = false;
	g_iRoundLimits = gc_iRoundWait.IntValue;
	g_iFreezeTime = gc_iFreezeTime.IntValue;
}

public void OnConfigsExecuted()
{
	g_iRoundLimits = gc_iRoundWait.IntValue;
	g_iFreezeTime = gc_iFreezeTime.IntValue;

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

public OnClientPutInServer(client)
{
	jihaded[client] = false;
	SDKHook(client, SDKHook_WeaponCanUse, OnWeaponCanUse);
}


public Action SetJiHad(int client,int args)
{
	if (gc_bPlugin.BoolValue)	
	{
		if (warden_iswarden(client))
		{
			if (gc_bSetW.BoolValue)	
			{
				if (!IsJiHad && !StartJiHad)
				{
					if (g_iRoundLimits == 0)
					{
						StartNextRound();
					}
					else CPrintToChat(client, "%t %t", "jihad_tag" , "jihad_wait", g_iRoundLimits);
				}
				else CPrintToChat(client, "%t %t", "jihad_tag" , "jihad_progress");
			}
			else CPrintToChat(client, "%t %t", "warden_tag" , "jihad_setbywarden");
		}
		else if (CheckCommandAccess(client, "sm_map", ADMFLAG_CHANGEMAP, true))
			{
				if (gc_bSetA.BoolValue)
				{
					if (!IsJiHad && !StartJiHad)
					{
						if (g_iRoundLimits == 0)
						{
							StartNextRound();
						}
						else CPrintToChat(client, "%t %t", "jihad_tag" , "jihad_wait", g_iRoundLimits);
					}
					else CPrintToChat(client, "%t %t", "jihad_tag" , "jihad_progress");
				}
				else CPrintToChat(client, "%t %t", "jihad_tag" , "jihad_setbyadmin");
			}
			else CPrintToChat(client, "%t %t", "warden_tag" , "warden_notwarden");
	}
	else CPrintToChat(client, "%t %t", "jihad_tag" , "jihad_disabled");
}

public Action VoteJiHad(int client,int args)
{
	char steamid[64];
	GetClientAuthId(client, AuthId_Steam2, steamid, sizeof(steamid));
	
	if (gc_bPlugin.BoolValue)
	{
		if (gc_bVote.BoolValue)
		{	
			if (GetTeamClientCount(CS_TEAM_CT) > 0)
			{
				if (!IsJiHad && !StartJiHad)
				{	
					if (g_iRoundLimits == 0)
					{
						if (StrContains(g_sHasVoted, steamid, true) == -1)
						{
							int playercount = (GetClientCount(true) / 2);
							g_iVoteCount++;
							int Missing = playercount - g_iVoteCount + 1;
							Format(g_sHasVoted, sizeof(g_sHasVoted), "%s,%s", g_sHasVoted, steamid);
							
							if (g_iVoteCount > playercount)
							{
								StartNextRound();
							}
							else CPrintToChatAll("%t %t", "jihad_tag" , "jihad_need", Missing, client);
						}
						else CPrintToChat(client, "%t %t", "jihad_tag" , "jihad_voted");
					}
					else CPrintToChat(client, "%t %t", "jihad_tag" , "jihad_wait", g_iRoundLimits);
				}
				else CPrintToChat(client, "%t %t", "jihad_tag" , "jihad_progress");
			}
			else CPrintToChat(client, "%t %t", "jihad_tag" , "jihad_minct");
		}
		else CPrintToChat(client, "%t %t", "jihad_tag" , "jihad_voting");
	}
	else CPrintToChat(client, "%t %t", "jihad_tag" , "jihad_disabled");
}

void StartNextRound()
{
	StartJiHad = true;
	g_iRoundLimits = gc_iRoundLimits.IntValue;
	g_iVoteCount = 0;
	SetCvar("sm_hide_enable", 0);
	SetCvar("sm_ffa_enable", 0);
	SetCvar("sm_dodgeball_enable", 0);
	SetCvar("sm_catch_enable", 0);
	SetCvar("sm_zombie_enable", 0);
	SetCvar("sm_duckhunt_enable", 0);
	SetCvar("sm_freeday_enable", 0);
	SetCvar("sm_war_enable", 0);
	SetCvar("sm_noscope_enable", 0);
	CPrintToChatAll("%t %t", "jihad_tag" , "jihad_next");
	PrintHintTextToAll("%t", "jihad_next_nc");
}

public void RoundStart(Handle:event, char[] name, bool:dontBroadcast)
{
	if (StartJiHad)
	{
		char info1[255], info2[255], info3[255], info4[255], info5[255], info6[255], info7[255], info8[255];
		
		SetCvar("sm_hosties_lr", 0);
		SetCvar("sm_warden_enable", 0);
		SetCvar("sm_beacon_enabled", 1);

		SetCvar("sm_weapons_enable", 0);
		SetCvar("sm_dice_enable", 0);
		IsJiHad = true;
		JiHadRound++;
		StartJiHad = false;

		ServerCommand("sm_removewarden");
		JiHadMenu = CreatePanel();
		Format(info1, sizeof(info1), "%T", "jihad_info_Title", LANG_SERVER);
		SetPanelTitle(JiHadMenu, info1);
		DrawPanelText(JiHadMenu, "                                   ");
		Format(info2, sizeof(info2), "%T", "jihad_info_Line1", LANG_SERVER);
		DrawPanelText(JiHadMenu, info2);
		DrawPanelText(JiHadMenu, "-----------------------------------");
		Format(info3, sizeof(info3), "%T", "jihad_info_Line2", LANG_SERVER);
		DrawPanelText(JiHadMenu, info3);
		Format(info4, sizeof(info4), "%T", "jihad_info_Line3", LANG_SERVER);
		DrawPanelText(JiHadMenu, info4);
		Format(info5, sizeof(info5), "%T", "jihad_info_Line4", LANG_SERVER);
		DrawPanelText(JiHadMenu, info5);
		Format(info6, sizeof(info6), "%T", "jihad_info_Line5", LANG_SERVER);
		DrawPanelText(JiHadMenu, info6);
		Format(info7, sizeof(info7), "%T", "jihad_info_Line6", LANG_SERVER);
		DrawPanelText(JiHadMenu, info7);
		Format(info8, sizeof(info8), "%T", "jihad_info_Line7", LANG_SERVER);
		DrawPanelText(JiHadMenu, info8);
		DrawPanelText(JiHadMenu, "-----------------------------------");
		
		if (JiHadRound > 0)
			{
				for(int client=1; client <= MaxClients; client++)
				{
					if (IsClientInGame(client))
					{
						StripAllWeapons(client);
						
						SetEntData(client, FindSendPropInfo("CBaseEntity", "m_CollisionGroup"), 2, 4, true);
						SendPanelToClient(JiHadMenu, client, Pass, 15);
						
						if (GetClientTeam(client) == CS_TEAM_T)
						{
							GivePlayerItem(client, "weapon_c4");
						}
						if (GetClientTeam(client) == CS_TEAM_CT)
						{
							GivePlayerItem(client, "weapon_knife");
						}
					}
				}
				g_iFreezeTime--;
				FreezeTimer = CreateTimer(1.0, JiHad, _, TIMER_REPEAT);
				
			}
	}
	else
	{
		if (g_iRoundLimits > 0) g_iRoundLimits--;
	}
}

public Action Command_LAW(int client, const char[] command, int argc)
{
	if(IsJiHad)
	{
		if(gc_iKey.IntValue == 1)
		{
			Command_BombJihad(client, 0);
		}
	}
	
	return Plugin_Continue;
}

public Action:JiHad(Handle:timer)
{
	if (g_iFreezeTime > 1)
	{
		g_iFreezeTime--;
		for (int client=1; client <= MaxClients; client++)
		if (IsClientInGame(client) && IsPlayerAlive(client))
			{
				if (GetClientTeam(client) == CS_TEAM_CT)
				{
					PrintCenterText(client,"%t", "jihad_timetojihad_nc", g_iFreezeTime);
				}
				if (GetClientTeam(client) == CS_TEAM_T)
				{
					PrintCenterText(client,"%t", "jihad_timetoopen_nc", g_iFreezeTime);
				}
		}
		return Plugin_Continue;
	}
	
	g_iFreezeTime = gc_iFreezeTime.IntValue;
	
	if (JiHadRound > 0)
	{
		for (int client=1; client <= MaxClients; client++)
		{
			if (IsClientInGame(client) && IsPlayerAlive(client))
			{
				SetEntProp(client, Prop_Data, "m_takedamage", 2, 1);
						
			}
			CreateTimer( 0.0, ShowOverlayStart, client);
		}
	}
	SJD_OpenDoors();
	
	PrintHintTextToAll("%t", "jihad_start_nc");
	CPrintToChatAll("%t %t", "jihad_tag" , "jihad_start");
	FreezeTimer = null;
	
	return Plugin_Stop;
}

public Action:Command_BombJihad(client, args)
{
	if (IsJiHad)
	{
		if (IsClientInGame(client) && IsPlayerAlive(client) && (GetClientTeam(client) == CS_TEAM_T))
		{
			EmitSoundToAllAny(g_sSoundPath1);
			SetEntityMoveType(client, MOVETYPE_NONE);
			CreateTimer( 2.0, DoDaBomb, client);
		}
	}
}

public Action DoDaBomb( Handle timer, any client ) 
{

	EmitSoundToAllAny(g_sSoundPath2);
	
	float suicide_bomber_vec[3];
	GetClientAbsOrigin(client, suicide_bomber_vec);
	
	int iMaxClients = GetMaxClients();
	int deathList[MAXPLAYERS+1]; //store players that this bomb kills
	int numKilledPlayers = 0;
	
	for (int i = 1; i <= iMaxClients; ++i)
	
	{
		//Check that client is a real player who is alive and is a CT
		if (IsClientInGame(i) && IsPlayerAlive(i))
		{
			float ct_vec[3];
			GetClientAbsOrigin(i, ct_vec);
			
			float distance = GetVectorDistance(ct_vec, suicide_bomber_vec, false);
			
			//If CT was in explosion radius, damage or kill them
			//Formula used: damage = 200 - (d/2)
			int damage = RoundToFloor(200.0 - (distance / 2.0));
			
			if (damage <= 0) //this player was not damaged 
			continue;
			
			//Damage the surrounding players
			int curHP = GetClientHealth(i);
			if (curHP - damage <= 0) 
			{
				deathList[numKilledPlayers] = i;
				++numKilledPlayers;
			}
			else
			{ //Survivor
				SetEntityHealth(i, curHP - damage);
				IgniteEntity(i, 2.0);
			}
		}
	}
	//Kill any players that may have died
	if (numKilledPlayers > 0) 
	{
		//Kill all players on death list
		for (int i = 0; i < numKilledPlayers; ++i)
		{
			ForcePlayerSuicide(deathList[i]);
		}
	}
	ForcePlayerSuicide(client);
	
	
}

public Action ShowOverlayStart( Handle timer, any client ) 
{
	if(gc_bOverlays.BoolValue && IsClientInGame(client) && IsClientConnected(client) && !IsFakeClient(client))
		{
			int iFlag = GetCommandFlags( "r_screenoverlay" ) & ( ~FCVAR_CHEAT ); 
			SetCommandFlags( "r_screenoverlay", iFlag ); 
			ClientCommand( client, "r_screenoverlay \"%s.vtf\"", g_sOverlayStart);
			CreateTimer( 2.0, DeleteOverlay, client );
		}
	return Plugin_Continue;
}


public Action:OnWeaponCanUse(client, weapon)
{
	char sWeapon[32];
	GetEdictClassname(weapon, sWeapon, sizeof(sWeapon));

	if((GetClientTeam(client) == 2 && !StrEqual(sWeapon, "weapon_c4")) || (GetClientTeam(client) == 3 && !StrEqual(sWeapon, "weapon_knife")))
		{
			if (IsClientInGame(client) && IsPlayerAlive(client))
			{
				if(IsJiHad == true)
				{
					return Plugin_Handled;
				}
			}
		}
	return Plugin_Continue;
}


public void RoundEnd(Handle:event, char[] name, bool:dontBroadcast)
{
	int winner = GetEventInt(event, "winner");
	
	if (IsJiHad)
	{
		for(int client=1; client <= MaxClients; client++)
		{
			if (IsClientInGame(client)) SetEntData(client, FindSendPropInfo("CBaseEntity", "m_CollisionGroup"), 0, 4, true);
			
		}
		if (FreezeTimer != null) KillTimer(FreezeTimer);
		
		if (winner == 2) PrintHintTextToAll("%t", "jihad_twin_nc");
		if (winner == 3) PrintHintTextToAll("%t", "jihad_ctwin_nc");
		IsJiHad = false;
		StartJiHad = false;
		JiHadRound = 0;
		Format(g_sHasVoted, sizeof(g_sHasVoted), "");
		SetCvar("sm_hosties_lr", 1);
		SetCvar("sm_war_enable", 1);
		SetCvar("sm_hide_enable", 1);
		SetCvar("sm_weapons_enable", 1);
		SetCvar("sm_zombie_enable", 1);
		SetCvar("sm_freeday_enable", 1);
		SetCvar("sm_duckhunt_enable", 1);
		SetCvar("sm_dice_enable", 1);
		SetCvar("sm_dodgeball_enable", 1);
		SetCvar("sm_beacon_enabled", 0);
		SetCvar("sv_infinite_ammo", 0);
		SetCvar("sm_ffa_enable", 1);
		SetCvar("sm_warden_enable", 1);
		g_iSetRoundTime.IntValue = g_iOldRoundTime;
		CPrintToChatAll("%t %t", "jihad_tag" , "jihad_end");
	}
	if (StartJiHad)
	{
	g_iOldRoundTime = g_iSetRoundTime.IntValue;
	g_iSetRoundTime.IntValue = gc_iRoundTime.IntValue;
	}
}

public Pass(Handle:menu, MenuAction:action, param1, param2)
{
}

public Action ShowOverlayFreeze( Handle timer, any client ) {
	
	if(gc_bOverlays.BoolValue && IsClientInGame(client) && IsClientConnected(client) && !IsFakeClient(client))
	{
	int iFlag = GetCommandFlags( "r_screenoverlay" ) & ( ~FCVAR_CHEAT ); 
	SetCommandFlags( "r_screenoverlay", iFlag ); 
	ClientCommand( client, "r_screenoverlay \"%s.vtf\"", g_sOverlayFreeze);
	
	// CreateTimer( 5.0, DeleteOverlay, client );
	}
	return Plugin_Continue;
	
}

public Action  DeleteOverlay( Handle timer, any client ) 
{
	if(IsClientInGame(client) && IsClientConnected(client) && !IsFakeClient(client))
	{
	int iFlag = GetCommandFlags( "r_screenoverlay" ) & ( ~FCVAR_CHEAT ); 
	SetCommandFlags( "r_screenoverlay", iFlag ); 
	ClientCommand( client, "r_screenoverlay \"\"" );
	}
	return Plugin_Continue;
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

public IsValidClient( client ) 
{
	if ( !( 1 <= client <= MaxClients ) || !IsClientInGame(client) ) 
	return false; 
	
	return true; 
}

public Action:Command_StartSprint(client, args)
{
	if (IsJiHad)
	{
		if (!IsSprint)
		{
			if(gc_bSprint.BoolValue && client > 0 && IsClientInGame(client) && IsPlayerAlive(client) && GetClientTeam(client) > 1)
			{
				IsSprint = true;
				SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", gc_fSpeed.FloatValue);
				EmitSoundToClient(client, "player/suit_sprint.wav", SOUND_FROM_PLAYER, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, 0.8);
				CPrintToChat(client, "%t %t", "jihad_tag" ,"jihad_sprint");
				SprintTimer[client] = CreateTimer(gc_fTime.FloatValue, Timer_SprintEnd, client);
			}
			return(Plugin_Handled);
		}
	}
	else CPrintToChat(client, "%t %t", "jihad_tag" , "jihad_disabled");
	return(Plugin_Handled);
}

public OnGameFrame()
{
	if (IsJiHad)
	{
		for(new i = 1; i <= MaxClients; i++)
		{
			if(gc_iKey.IntValue == 2)
			{
				if(IsClientInGame(i) && (GetClientButtons(i) & IN_SPEED))
				{
					Command_BombJihad(i, 0);
				}
			}
			else if(gc_iKey.IntValue == 3)
			{
				if(IsClientInGame(i) && (GetClientButtons(i) & IN_ATTACK2))
				{
					Command_BombJihad(i, 0);
				}
			}
			if(gc_bSprintUse.BoolValue)
			{
				if(IsClientInGame(i) && (GetClientButtons(i) & IN_USE))
				{
					Command_StartSprint(i, 0);
				}
			}
		}
	}
	return;

}

ResetSprint(client)
{
	if(SprintTimer[client] != null)
	{
		KillTimer(SprintTimer[client]);
		SprintTimer[client] = null;
		IsSprint = false;
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
	IsSprint = false;
	return;
}

public Event_PlayerSpawn(Handle:event,const String:name[],bool:dontBroadcast)
{
	new iClient = GetClientOfUserId(GetEventInt(event, "userid"));
	ResetSprint(iClient);
	return;
}

stock StripAllWeapons(iClient)
{
	int iEnt;
	for (int i = 0; i <= 4; i++)
	{
		while ((iEnt = GetPlayerWeaponSlot(iClient, i)) != -1)
		{
			RemovePlayerItem(iClient, iEnt);
			AcceptEntityInput(iEnt, "Kill");
		}
	}
}

public OnMapEnd()
{
	IsJiHad = false;
	StartJiHad = false;
	g_iVoteCount = 0;
	JiHadRound = 0;
	g_sHasVoted[0] = '\0';
}
