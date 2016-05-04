//includes
#include <cstrike>
#include <sourcemod>
#include <smartjaildoors>
#include <wardn>
#include <colors>
#include <sdkhooks>
#include <autoexecconfig>
#include <myjailbreak>

//Compiler Options
#pragma semicolon 1
#pragma newdecls required

//Booleans
bool IsFreeDay; 
bool StartFreeDay; 

//ConVars
ConVar gc_bPlugin;
ConVar gc_bSetW;
ConVar gc_bFirst;
ConVar gc_bDamage;
ConVar gc_bSetA;
ConVar gc_bVote;
ConVar gc_iCooldownDay;
ConVar gc_iRoundTime;
ConVar g_iGetRoundTime;

//Integers
int g_iOldRoundTime;
int g_iCoolDown;
int g_iVoteCount;
int FreeDayRound = 0;

//Handles
Handle FreeDayMenu;

//Strings
char g_sHasVoted[1500];

public Plugin myinfo =
{
	name = "MyJailbreak - FreeDay",
	author = "shanapu",
	description = "Event Day for Jailbreak Server",
	version = PLUGIN_VERSION,
	url = URL_LINK
};

public void OnPluginStart()
{
	// Translation
	LoadTranslations("MyJailbreak.Warden.phrases");
	LoadTranslations("MyJailbreak.FreeDay.phrases");
	
	//Client Commands
	RegConsoleCmd("sm_setfreeday", SetFreeDay, "Allows the Admin or Warden to set freeday as next round");
	RegConsoleCmd("sm_freeday", VoteFreeDay, "Allows players to vote for a freeday");

	
	//AutoExecConfig
	AutoExecConfig_SetFile("FreeDay", "MyJailbreak/EventDays");
	AutoExecConfig_SetCreateFile(true);
	
	AutoExecConfig_CreateConVar("sm_freeday_version", PLUGIN_VERSION, "The version of this MyJailbreak SourceMod plugin", FCVAR_SPONLY|FCVAR_PLUGIN|FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_DONTRECORD);
	gc_bPlugin = AutoExecConfig_CreateConVar("sm_freeday_enable", "1", "0 - disabled, 1 - enable this MyJailbreak SourceMod plugin", _, true,  0.0, true, 1.0);
	gc_bSetW = AutoExecConfig_CreateConVar("sm_freeday_warden", "1", "0 - disabled, 1 - allow warden to set freeday round", _, true,  0.0, true, 1.0);
	gc_bSetA = AutoExecConfig_CreateConVar("sm_freeday_admin", "1", "0 - disabled, 1 - allow admin to set freeday round", _, true,  0.0, true, 1.0);
	gc_bVote = AutoExecConfig_CreateConVar("sm_freeday_vote", "1", "0 - disabled, 1 - allow player to vote for freeday", _, true,  0.0, true, 1.0);
	gc_bFirst = AutoExecConfig_CreateConVar("sm_freeday_firstround", "1", "0 - disabled, 1 - auto freeday first round after mapstart", _, true,  0.0, true, 1.0);
	gc_bDamage = AutoExecConfig_CreateConVar("sm_freeday_damage", "1", "0 - disabled, 1 - enable damage on freedays", _, true,  0.0, true, 1.0);
	gc_iRoundTime = AutoExecConfig_CreateConVar("sm_freeday_roundtime", "5", "Round time in minutes for a single freeday round", _, true,  1.0);
	gc_iCooldownDay = AutoExecConfig_CreateConVar("sm_freeday_cooldown_day", "3", "Rounds until freeday can be started again.", _, true,  0.0);
	
	AutoExecConfig_ExecuteFile();
	AutoExecConfig_CleanFile();
	
	//Hooks
	HookEvent("round_start", RoundStart);
	HookEvent("round_end", RoundEnd);
	
	//FindConVar
	g_iGetRoundTime = FindConVar("mp_roundtime");
	g_iCoolDown = gc_iCooldownDay.IntValue + 1;
}

public void OnMapStart()
{

	g_iVoteCount = 0;
	FreeDayRound = 0;
	
	if (gc_bFirst.BoolValue)
	{
		StartFreeDay = true;
		SetEventDay("freeday");
	}
	else
	{
		StartFreeDay = false;	
	}
	IsFreeDay = false;
}

public Action SetFreeDay(int client,int args)
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
					else CPrintToChat(client, "%t %t", "freeday_tag" , "freeday_wait", g_iCoolDown);
				}
				else CPrintToChat(client, "%t %t", "freeday_tag" , "freeday_progress" , EventDay);
			}
			else CPrintToChat(client, "%t %t", "warden_tag" , "freeday_setbywarden");
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
						else CPrintToChat(client, "%t %t", "freeday_tag" , "freeday_wait", g_iCoolDown);
					}
					else CPrintToChat(client, "%t %t", "freeday_tag" , "freeday_progress" , EventDay);
				}
				else CPrintToChat(client, "%t %t", "freeday_tag" , "freeday_setbyadmin");
			}
			else CPrintToChat(client, "%t %t", "warden_tag" , "warden_notwarden");
	}
	else CPrintToChat(client, "%t %t", "freeday_tag" , "freeday_disabled");
}

public Action VoteFreeDay(int client,int args)
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
						else CPrintToChatAll("%t %t", "freeday_tag" , "freeday_need", Missing, client);
					}
					else CPrintToChat(client, "%t %t", "freeday_tag" , "freeday_voted");
				}
				else CPrintToChat(client, "%t %t", "freeday_tag" , "freeday_wait", g_iCoolDown);
			}
			else CPrintToChat(client, "%t %t", "freeday_tag" , "freeday_progress" , EventDay);
		}
		else CPrintToChat(client, "%t %t", "freeday_tag" , "freeday_voting");
	}
	else CPrintToChat(client, "%t %t", "freeday_tag" , "freeday_disabled");
}

void StartNextRound()
{
	StartFreeDay = true;
	g_iCoolDown = gc_iCooldownDay.IntValue + 1;
	g_iVoteCount = 0;
	SetEventDay("freeday");
	
	CPrintToChatAll("%t %t", "freeday_tag" , "freeday_next");
	PrintHintTextToAll("%t", "freeday_next_nc");
}


public void RoundStart(Handle event, char[] name, bool dontBroadcast)
{
	if (StartFreeDay)
	{
		char info1[255], info2[255], info3[255], info4[255], info5[255], info6[255], info7[255], info8[255];
		
		SetCvar("sm_hosties_lr", 0);
		SetCvar("sm_weapons_enable", 0);
		SetCvar("sm_weapons_t", 0);
		SetCvar("sm_warden_enable", 0);
		IsFreeDay = true;
		FreeDayRound++;
		StartFreeDay = false;
		SJD_OpenDoors();
		
		FreeDayMenu = CreatePanel();
		Format(info1, sizeof(info1), "%T", "freeday_info_title", LANG_SERVER);
		SetPanelTitle(FreeDayMenu, info1);
		DrawPanelText(FreeDayMenu, "                                   ");
		Format(info2, sizeof(info2), "%T", "freeday_info_line1", LANG_SERVER);
		DrawPanelText(FreeDayMenu, info2);
		DrawPanelText(FreeDayMenu, "-----------------------------------");
		Format(info3, sizeof(info3), "%T", "freeday_info_line2", LANG_SERVER);
		DrawPanelText(FreeDayMenu, info3);
		Format(info4, sizeof(info4), "%T", "freeday_info_line3", LANG_SERVER);
		DrawPanelText(FreeDayMenu, info4);
		Format(info5, sizeof(info5), "%T", "freeday_info_line4", LANG_SERVER);
		DrawPanelText(FreeDayMenu, info5);
		Format(info6, sizeof(info6), "%T", "freeday_info_line5", LANG_SERVER);
		DrawPanelText(FreeDayMenu, info6);
		Format(info7, sizeof(info7), "%T", "freeday_info_line6", LANG_SERVER);
		DrawPanelText(FreeDayMenu, info7);
		Format(info8, sizeof(info8), "%T", "freeday_info_line7", LANG_SERVER);
		DrawPanelText(FreeDayMenu, info8);
		DrawPanelText(FreeDayMenu, "-----------------------------------");
		for(int client=1; client <= MaxClients; client++)
			{
				SendPanelToClient(FreeDayMenu, client, NullHandler, 20);
				if (!gc_bDamage.BoolValue && IsValidClient(client))
				{
					SetEntProp(client, Prop_Data, "m_takedamage", 0, 1);
				}
				PrintCenterText(client,"%t", "freeday_start_nc");
			}
		CPrintToChatAll("%t %t", "freeday_tag" , "freeday_start");
	}
	else
	{
		if (g_iCoolDown > 0) g_iCoolDown--;
	}
}

public void RoundEnd(Handle event, char[] name, bool dontBroadcast)
{
	if (IsFreeDay)
	{
		IsFreeDay = false;
		StartFreeDay = false;
		FreeDayRound = 0;
		Format(g_sHasVoted, sizeof(g_sHasVoted), "");
		
		SetCvar("sm_hosties_lr", 1);
		SetCvar("sm_weapons_enable", 1);
		SetCvar("mp_teammates_are_enemies", 0);
		SetCvar("sm_warden_enable", 1);
		g_iGetRoundTime.IntValue = g_iOldRoundTime;
		SetEventDay("none");
		CPrintToChatAll("%t %t", "freeday_tag" , "freeday_end");
	}
	if (StartFreeDay)
	{
		g_iOldRoundTime = g_iGetRoundTime.IntValue;
		g_iGetRoundTime.IntValue = gc_iRoundTime.IntValue;
	}
}

public void OnMapEnd()
{
	if (gc_bFirst.BoolValue)
	{
		StartFreeDay = true;
	}
	else
	{
		StartFreeDay = false;
	}
	IsFreeDay = false;
	g_iVoteCount = 0;
	FreeDayRound = 0;
	g_sHasVoted[0] = '\0';
	SetEventDay("none");
}