//includes
#include <cstrike>
#include <sourcemod>
#include <sdktools>
#include <smartjaildoors>
#include <wardn>
#include <colors>
#include <sdkhooks>
#include <autoexecconfig>
#include <myjailbreak>

//Compiler Options
#pragma semicolon 1
#pragma newdecls required

//Defines
#define PLUGIN_VERSION "0.3"

//Booleans
bool IsDodgeBall = false; 
bool StartDodgeBall = false; 

//ConVars
ConVar gc_bPlugin;
ConVar gc_bTag;
ConVar gc_bSetW;
ConVar gc_bGrav;
ConVar gc_fGravValue;
ConVar gc_iCooldownStart;
ConVar gc_bSetA;
ConVar gc_bVote;
ConVar gc_iCooldownDay;
ConVar gc_iRoundTime;
ConVar gc_iTruceTime;
ConVar gc_bOverlays;
ConVar gc_sOverlayStartPath;
ConVar g_iSetRoundTime;

//Integers
int g_iOldRoundTime;
int g_iCoolDown;
int g_iTruceTime;
int g_iVoteCount = 0;
int DodgeBallRound = 0;

//Handles
Handle TruceTimer;
Handle DodgeBallMenu;

//Strings
char g_sHasVoted[1500];

public Plugin myinfo = {
	name = "MyJailbreak - DodgeBall",
	author = "shanapu & Floody.de, Franc1sco",
	description = "Jailbreak DodgeBall script",
	version = PLUGIN_VERSION,
	url = ""
};

public void OnPluginStart()
{
	// Translation
	LoadTranslations("MyJailbreakWarden.phrases");
	LoadTranslations("MyJailbreakDodgeBall.phrases");
	
	//Client Commands
	RegConsoleCmd("sm_setdodgeball", SetDodgeBall);
	RegConsoleCmd("sm_dodgeball", VoteDodgeBall);
	
	//AutoExecConfig
	AutoExecConfig_SetFile("MyJailbreak_dodgeball");
	AutoExecConfig_SetCreateFile(true);
	
	AutoExecConfig_CreateConVar("sm_dodgeball_version", PLUGIN_VERSION, "The version of the SourceMod plugin MyJailBreak - dodgeball", FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_DONTRECORD);
	gc_bPlugin = AutoExecConfig_CreateConVar("sm_dodgeball_enable", "1", "0 - disabled, 1 - enable dodgeball");
	gc_bSetW = AutoExecConfig_CreateConVar("sm_dodgeball_warden", "1", "0 - disabled, 1 - allow warden to set dodgeball round", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	gc_bSetA = AutoExecConfig_CreateConVar("sm_dodgeball_admin", "1", "0 - disabled, 1 - allow admin to set dodgeball round", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	gc_bVote = AutoExecConfig_CreateConVar("sm_dodgeball_vote", "1", "0 - disabled, 1 - allow player to vote for dodgeball", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	gc_bGrav = AutoExecConfig_CreateConVar("sm_dodgeball_gravity", "1", "0 - disabled, 1 - enable low Gravity for dodgeball", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	gc_fGravValue= AutoExecConfig_CreateConVar("sm_dodgeball_gravity_value", "0.3","Ratio for Gravity 1.0 earth 0.5 moon", 0, true, 0.1, true, 1.0);
	gc_iRoundTime = AutoExecConfig_CreateConVar("sm_dodgeball_roundtime", "5", "Round time for a single dodgeball round");
	gc_iTruceTime = AutoExecConfig_CreateConVar("sm_dodgeball_trucetime", "15", "Time for no damage");
	gc_iCooldownDay = AutoExecConfig_CreateConVar("sm_dodgeball_cooldown_day", "3", "Rounds cooldown after a event until this event can startet");
	gc_iCooldownStart = AutoExecConfig_CreateConVar("sm_dodgeball_cooldown_start", "3", "Rounds until event can be started after mapchange.", FCVAR_NOTIFY, true, 0.0, true, 255.0);
	gc_bOverlays = AutoExecConfig_CreateConVar("sm_dodgeball_overlays", "1", "0 - disabled, 1 - enable overlays", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	gc_sOverlayStartPath = AutoExecConfig_CreateConVar("sm_dodgeball_overlaystart_path", "overlays/MyJailbreak/start" , "Path to the start Overlay DONT TYPE .vmt or .vft");
	gc_bTag = AutoExecConfig_CreateConVar("sm_dodgeball_tag", "1", "Allow \"MyJailbreak\" to be added to the server tags? So player will find servers with MyJB faster", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	
	AutoExecConfig_ExecuteFile();
	AutoExecConfig_CleanFile();
	
	//Hooks
	HookEvent("round_start", RoundStart);
	HookConVarChange(gc_sOverlayStartPath, OnSettingChanged);
	HookEvent("round_end", RoundEnd);
	HookEvent("hegrenade_detonate", HE_Detonate);
	
	//Find
	g_iSetRoundTime = FindConVar("mp_roundtime");
	g_iCoolDown = gc_iCooldownDay.IntValue + 1;
	g_iTruceTime = gc_iTruceTime.IntValue;
	gc_sOverlayStartPath.GetString(g_sOverlayStart , sizeof(g_sOverlayStart));
	
	IsDodgeBall = false;
	StartDodgeBall = false;
	g_iVoteCount = 0;
	DodgeBallRound = 0;
}

public int OnSettingChanged(Handle convar, const char[] oldValue, const char[] newValue)
{
	if(convar == gc_sOverlayStartPath)
	{
		strcopy(g_sOverlayStart, sizeof(g_sOverlayStart), newValue);
		if(gc_bOverlays.BoolValue) PrecacheOverlayAnyDownload(g_sOverlayStart);
	}
}

public void OnMapStart()
{
	if(gc_bOverlays.BoolValue) PrecacheOverlayAnyDownload(g_sOverlayStart);
	g_iVoteCount = 0;
	DodgeBallRound = 0;
	IsDodgeBall = false;
	StartDodgeBall = false;
	g_iCoolDown = gc_iCooldownStart.IntValue + 1;
	g_iTruceTime = gc_iTruceTime.IntValue;
}

public void OnConfigsExecuted()
{
	g_iTruceTime = gc_iTruceTime.IntValue;
	g_iCoolDown = gc_iCooldownStart.IntValue + 1;
	
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

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_WeaponCanUse, OnWeaponCanUse);
}

public Action SetDodgeBall(int client,int args)
{
	if (gc_bPlugin.BoolValue)
	{
		if (warden_iswarden(client))
		{
			if (gc_bSetW.BoolValue)
			{
				char EventDay[64];
				GetEventDay(EventDay);
				
				if(StrEqual(EventDay, "none", false))
				{
					if (g_iCoolDown == 0)
					{
						StartNextRound();
					}
					else CPrintToChat(client, "%t %t", "dodgeball_tag" , "dodgeball_wait", g_iCoolDown);
				}
				else CPrintToChat(client, "%t %t", "dodgeball_tag" , "dodgeball_progress" , EventDay);
			}
			else CPrintToChat(client, "%t %t", "warden_tag" , "nocscope_setbywarden");
		}
		else if (CheckCommandAccess(client, "sm_map", ADMFLAG_CHANGEMAP, true))
			{
				if (gc_bSetA.BoolValue)
				{
					char EventDay[64];
					GetEventDay(EventDay);
					
					if(StrEqual(EventDay, "none", false))
					{
						if (g_iCoolDown == 0)
						{
							StartNextRound();
						}
						else CPrintToChat(client, "%t %t", "dodgeball_tag" , "dodgeball_wait", g_iCoolDown);
					}
					else CPrintToChat(client, "%t %t", "dodgeball_tag" , "dodgeball_progress" , EventDay);
				}
				else CPrintToChat(client, "%t %t", "nocscope_tag" , "dodgeball_setbyadmin");
			}
			else CPrintToChat(client, "%t %t", "warden_tag" , "warden_notwarden");
	}
	else CPrintToChat(client, "%t %t", "dodgeball_tag" , "dodgeball_disabled");
}

public Action VoteDodgeBall(int client,int args)
{
	char steamid[64];
	GetClientAuthId(client, AuthId_Steam2, steamid, sizeof(steamid));
	
	if (gc_bPlugin.BoolValue)
	{
		if (gc_bVote.BoolValue)
		{
			char EventDay[64];
			GetEventDay(EventDay);
			
			if(StrEqual(EventDay, "none", false))
			{
				if (g_iCoolDown == 0)
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
						else CPrintToChatAll("%t %t", "dodgeball_tag" , "dodgeball_need", Missing, client);
					}
					else CPrintToChat(client, "%t %t", "dodgeball_tag" , "dodgeball_voted");
				}
				else CPrintToChat(client, "%t %t", "dodgeball_tag" , "dodgeball_wait", g_iCoolDown);
			}
			else CPrintToChat(client, "%t %t", "dodgeball_tag" , "dodgeball_progress" , EventDay);
		}
		else CPrintToChat(client, "%t %t", "dodgeball_tag" , "dodgeball_voting");
	}
	else CPrintToChat(client, "%t %t", "dodgeball_tag" , "dodgeball_disabled");
}

void StartNextRound()
{
	StartDodgeBall = true;
	g_iCoolDown = gc_iCooldownDay.IntValue + 1;
	g_iVoteCount = 0;
	
	SetEventDay("dodgeball");
	
	CPrintToChatAll("%t %t", "dodgeball_tag" , "dodgeball_next");
	PrintHintTextToAll("%t", "dodgeball_next_nc");

}

public void RoundStart(Handle event, char[] name, bool dontBroadcast)
{
	if (StartDodgeBall)
	{
		char info1[255], info2[255], info3[255], info4[255], info5[255], info6[255], info7[255], info8[255];
		SetCvar("sm_hosties_lr", 0);
		SetCvar("sm_weapons_enable", 0);
		SetCvar("sm_warden_enable", 0);
		SetCvar("mp_teammates_are_enemies", 1);
		IsDodgeBall = true;
		ServerCommand("sm_removewarden");
		DodgeBallRound++;
		StartDodgeBall = false;
		SJD_OpenDoors();
		DodgeBallMenu = CreatePanel();
		Format(info1, sizeof(info1), "%T", "dodgeball_info_Title", LANG_SERVER);
		SetPanelTitle(DodgeBallMenu, info1);
		DrawPanelText(DodgeBallMenu, "                                   ");
		Format(info2, sizeof(info2), "%T", "dodgeball_info_Line1", LANG_SERVER);
		DrawPanelText(DodgeBallMenu, info2);
		DrawPanelText(DodgeBallMenu, "-----------------------------------");
		Format(info3, sizeof(info3), "%T", "dodgeball_info_Line2", LANG_SERVER);
		DrawPanelText(DodgeBallMenu, info3);
		Format(info4, sizeof(info4), "%T", "dodgeball_info_Line3", LANG_SERVER);
		DrawPanelText(DodgeBallMenu, info4);
		Format(info5, sizeof(info5), "%T", "dodgeball_info_Line4", LANG_SERVER);
		DrawPanelText(DodgeBallMenu, info5);
		Format(info6, sizeof(info6), "%T", "dodgeball_info_Line5", LANG_SERVER);
		DrawPanelText(DodgeBallMenu, info6);
		Format(info7, sizeof(info7), "%T", "dodgeball_info_Line6", LANG_SERVER);
		DrawPanelText(DodgeBallMenu, info7);
		Format(info8, sizeof(info8), "%T", "dodgeball_info_Line7", LANG_SERVER);
		DrawPanelText(DodgeBallMenu, info8);
		DrawPanelText(DodgeBallMenu, "-----------------------------------");
		
		if (DodgeBallRound > 0)
			{
				for(int client=1; client <= MaxClients; client++)
				{
					if (IsClientInGame(client))
					{
						
						if (gc_bGrav.BoolValue)
						{
							SetEntityGravity(client, gc_fGravValue.FloatValue);	
						}
						SendPanelToClient(DodgeBallMenu, client, Pass, 15);
						SetEntProp(client, Prop_Data, "m_takedamage", 0, 1);
						StripAllWeapons(client);
						GivePlayerItem(client, "weapon_hegrenade");
						SetEntityHealth(client, 10);
					}
				}
				g_iTruceTime--;
				TruceTimer = CreateTimer(1.0, DodgeBall, _, TIMER_REPEAT);
			}
	}
	else
	{
		char EventDay[64];
		GetEventDay(EventDay);
		
		if(!StrEqual(EventDay, "none", false))
		{
			g_iCoolDown = gc_iCooldownDay.IntValue + 1;
		}
		else if (g_iCoolDown > 0) g_iCoolDown--;
	}
}

public Action OnWeaponCanUse(int client, int weapon)
{
	if(IsDodgeBall == true)
	{
		char sWeapon[32];
		GetEdictClassname(weapon, sWeapon, sizeof(sWeapon));
		if(StrEqual(sWeapon, "weapon_hegrenade"))
		{
			if (IsClientInGame(client) && IsPlayerAlive(client))
			{
				return Plugin_Continue;
			}
		}
		return Plugin_Handled;
	}
	return Plugin_Continue;
}

public Action HE_Detonate(Handle event, const char[] name, bool dontBroadcast)
{
	if (IsDodgeBall == true)
	{
		int  target = GetClientOfUserId(GetEventInt(event, "userid"));
		if (GetClientTeam(target) == 1 && !IsPlayerAlive(target))
		{
			return;
		}
		GivePlayerItem(target, "weapon_hegrenade");
	}
	return;
}

public Action DodgeBall(Handle timer)
{
	if (g_iTruceTime > 1)
	{
		g_iTruceTime--;
		for (int client=1; client <= MaxClients; client++)
		if (IsClientInGame(client) && IsPlayerAlive(client))
			{
				PrintCenterText(client,"%t", "dodgeball_timetounfreeze_nc", g_iTruceTime);
			}
		return Plugin_Continue;
	}
	
	g_iTruceTime = gc_iTruceTime.IntValue;
	
	if (DodgeBallRound > 0)
	{
		for (int client=1; client <= MaxClients; client++)
		{
			if (IsClientInGame(client) && IsPlayerAlive(client))
			{
				SetEntProp(client, Prop_Data, "m_takedamage", 2, 1);
				if (gc_bGrav.BoolValue)
				{
					SetEntityGravity(client, gc_fGravValue.FloatValue);	
				}
			}
			CreateTimer( 0.0, ShowOverlayStart, client);
			
		}
	}
	PrintHintTextToAll("%t", "dodgeball_start_nc");
	CPrintToChatAll("%t %t", "dodgeball_tag" , "dodgeball_start");
	
	TruceTimer = null;
	
	return Plugin_Stop;
}

public void RoundEnd(Handle event, char[] name, bool dontBroadcast)
{
	int winner = GetEventInt(event, "winner");
	
	if (IsDodgeBall)
	{
		for(int client=1; client <= MaxClients; client++)
		{
			if (IsClientInGame(client)) SetEntityGravity(client, 1.0);
		}
		
		if (TruceTimer != null) KillTimer(TruceTimer);
		if (winner == 2) PrintHintTextToAll("%t", "dodgeball_twin_nc");
		if (winner == 3) PrintHintTextToAll("%t", "dodgeball_ctwin_nc");
		IsDodgeBall = false;
		StartDodgeBall = false;
		DodgeBallRound = 0;
		Format(g_sHasVoted, sizeof(g_sHasVoted), "");
		SetCvar("sm_hosties_lr", 1);
		SetCvar("sm_weapons_enable", 1);
		SetCvar("mp_teammates_are_enemies", 0);
		SetCvar("sm_warden_enable", 1);
		
		g_iSetRoundTime.IntValue = g_iOldRoundTime;
		SetEventDay("none");
		CPrintToChatAll("%t %t", "dodgeball_tag" , "dodgeball_end");
	}
	if (StartDodgeBall)
	{
		g_iOldRoundTime = g_iSetRoundTime.IntValue;
		g_iSetRoundTime.IntValue = gc_iRoundTime.IntValue;
	}
}

public void OnMapEnd()
{
	IsDodgeBall = false;
	StartDodgeBall = false;
	g_iVoteCount = 0;
	DodgeBallRound = 0;
	g_sHasVoted[0] = '\0';
}