/*
 * MyJailbreak - Freeday Event Day Plugin.
 * by: shanapu
 * https://github.com/shanapu/MyJailbreak/
 *
 * This file is part of the MyJailbreak SourceMod Plugin.
 *
 * This program is free software; you can redistribute it and/or modify it under
 * the terms of the GNU General Public License, version 3.0, as published by the
 * Free Software Foundation.
 * 
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
 * details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program.  If not, see <http://www.gnu.org/licenses/>.
 */


/******************************************************************************
                   STARTUP
******************************************************************************/


//Includes
#include <myjailbreak> //... all other includes in myjailbreak.inc


//Compiler Options
#pragma semicolon 1
#pragma newdecls required


//Booleans
bool IsFreeday; 
bool StartFreeday; 
//bool AutoFreeday; 


//Console Variables
ConVar gc_bPlugin;
ConVar gc_bSetW;
ConVar gc_bFirst;
ConVar gc_bAuto;
//ConVar gc_iRespawn;
ConVar gc_bdamage;
ConVar gc_bSetA;
ConVar gc_bVote;
ConVar gc_iCooldownDay;
ConVar gc_iRoundTime;
ConVar gc_sCustomCommandVote;
ConVar gc_sCustomCommandSet;
ConVar gc_sAdminFlag;


//Extern Convars
ConVar g_iMPRoundTime;


//Integers
int g_iOldRoundTime;
int g_iCoolDown;
int g_iVoteCount;
int FreedayRound = 0;


//Handles
Handle FreedayMenu;


//Strings
char g_sHasVoted[1500];
char g_sEventsLogFile[PLATFORM_MAX_PATH];
char g_sAdminFlag[32];


//Info
public Plugin myinfo =
{
	name = "MyJailbreak - Freeday",
	author = "shanapu",
	description = "Event Day for Jailbreak Server",
	version = PLUGIN_VERSION,
	url = URL_LINK
};


//Start
public void OnPluginStart()
{
	// Translation
	LoadTranslations("MyJailbreak.Warden.phrases");
	LoadTranslations("MyJailbreak.FreeDay.phrases");
	
	
	//Client Commands
	RegConsoleCmd("sm_setfreeday", Command_SetFreeday, "Allows the Admin or Warden to set freeday as next round");
	RegConsoleCmd("sm_freeday", Command_VoteFreeday, "Allows players to vote for a freeday");
	
	
	//AutoExecConfig
	AutoExecConfig_SetFile("Freeday", "MyJailbreak/EventDays");
	AutoExecConfig_SetCreateFile(true);
	
	AutoExecConfig_CreateConVar("sm_freeday_version", PLUGIN_VERSION, "The version of this MyJailbreak SourceMod plugin", FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_DONTRECORD);
	gc_bPlugin = AutoExecConfig_CreateConVar("sm_freeday_enable", "1", "0 - disabled, 1 - enable this MyJailbreak SourceMod plugin", _, true,  0.0, true, 1.0);
	gc_sCustomCommandVote = AutoExecConfig_CreateConVar("sm_freeday_cmds_vote", "fd,free", "Set your custom chat command for Event voting(!freeday (no 'sm_'/'!')(seperate with comma ',')(max. 12 commands))");
	gc_sCustomCommandSet = AutoExecConfig_CreateConVar("sm_freeday_cmds_set", "sfreeday,sfd", "Set your custom chat command for set Event(!setfreeday (no 'sm_'/'!')(seperate with comma ',')(max. 12 commands))");
	gc_bSetW = AutoExecConfig_CreateConVar("sm_freeday_warden", "1", "0 - disabled, 1 - allow warden to set freeday round", _, true,  0.0, true, 1.0);
	gc_bSetA = AutoExecConfig_CreateConVar("sm_freeday_admin", "1", "0 - disabled, 1 - allow admin/vip to set freeday round", _, true,  0.0, true, 1.0);
	gc_sAdminFlag = AutoExecConfig_CreateConVar("sm_freeday_flag", "g", "Set flag for admin/vip to set this Event Day.");
	gc_bVote = AutoExecConfig_CreateConVar("sm_freeday_vote", "1", "0 - disabled, 1 - allow player to vote for freeday", _, true,  0.0, true, 1.0);
	gc_bAuto = AutoExecConfig_CreateConVar("sm_freeday_noct", "1", "0 - disabled, 1 - auto freeday when there is no CT", _, true,  0.0, true, 1.0);
//	gc_iRespawn = AutoExecConfig_CreateConVar("sm_freeday_respawn", "1", "1 - respawn on NoCT Freeday / 2 - respawn on firstround/vote/set Freeday / 3 - Both", _, true,  0.0, true, 1.0);
	gc_bFirst = AutoExecConfig_CreateConVar("sm_freeday_firstround", "1", "0 - disabled, 1 - auto freeday first round after mapstart", _, true,  0.0, true, 1.0);
	gc_bdamage = AutoExecConfig_CreateConVar("sm_freeday_damage", "1", "0 - disabled, 1 - enable damage on freedays", _, true,  0.0, true, 1.0);
	gc_iRoundTime = AutoExecConfig_CreateConVar("sm_freeday_roundtime", "5", "Round time in minutes for a single freeday round", _, true,  1.0);
	gc_iCooldownDay = AutoExecConfig_CreateConVar("sm_freeday_cooldown_day", "0", "Rounds until freeday can be started again.", _, true,  0.0);
	
	AutoExecConfig_ExecuteFile();
	AutoExecConfig_CleanFile();
	
	
	//Hooks
	HookEvent("round_start", Event_RoundStart);
	HookEvent("round_end", Event_RoundEnd);
//	HookEvent("player_death", Event_PlayerDeath);
	HookConVarChange(gc_sAdminFlag, OnSettingChanged);
	
	
	//FindConVar
	g_iMPRoundTime = FindConVar("mp_roundtime");
	g_iCoolDown = gc_iCooldownDay.IntValue + 1;
	gc_sAdminFlag.GetString(g_sAdminFlag , sizeof(g_sAdminFlag));
	
	SetLogFile(g_sEventsLogFile, "Events");
}


//ConVarChange for Strings
public int OnSettingChanged(Handle convar, const char[] oldValue, const char[] newValue)
{
	if(convar == gc_sAdminFlag)
	{
		strcopy(g_sAdminFlag, sizeof(g_sAdminFlag), newValue);
	}
}


//Initialize Event
public void OnConfigsExecuted()
{
	//Set custom Commands
	int iCount = 0;
	char sCommands[128], sCommandsL[12][32], sCommand[32];
	
	//Vote
	gc_sCustomCommandVote.GetString(sCommands, sizeof(sCommands));
	ReplaceString(sCommands, sizeof(sCommands), " ", "");
	iCount = ExplodeString(sCommands, ",", sCommandsL, sizeof(sCommandsL), sizeof(sCommandsL[]));
	
	for(int i = 0; i < iCount; i++)
	{
		Format(sCommand, sizeof(sCommand), "sm_%s", sCommandsL[i]);
		if(GetCommandFlags(sCommand) == INVALID_FCVAR_FLAGS)  //if command not already exist
			RegConsoleCmd(sCommand, Command_VoteFreeday, "Allows players to vote for a freeday");
	}
	
	//Set
	gc_sCustomCommandSet.GetString(sCommands, sizeof(sCommands));
	ReplaceString(sCommands, sizeof(sCommands), " ", "");
	iCount = ExplodeString(sCommands, ",", sCommandsL, sizeof(sCommandsL), sizeof(sCommandsL[]));
	
	for(int i = 0; i < iCount; i++)
	{
		Format(sCommand, sizeof(sCommand), "sm_%s", sCommandsL[i]);
		if(GetCommandFlags(sCommand) == INVALID_FCVAR_FLAGS)  //if command not already exist
			RegConsoleCmd(sCommand, Command_SetFreeday, "Allows the Admin or Warden to set freeday as next round");
	}
}


/******************************************************************************
                   COMMANDS
******************************************************************************/


//Admin & Warden set Event
public Action Command_SetFreeday(int client,int args)
{
	if (gc_bPlugin.BoolValue)
	{
		if(client == 0)
		{
			StartNextRound();
			if(ActiveLogging()) LogToFileEx(g_sEventsLogFile, "Event FreeDay was started by groupvoting");
		}
		else if (warden_iswarden(client))
		{
			if (gc_bSetW.BoolValue)
			{
				char EventDay[64];
				GetEventDayName(EventDay);
				
				if(!IsEventDayPlanned())
				{
					if (g_iCoolDown == 0)
					{
						StartNextRound();
						if(ActiveLogging()) LogToFileEx(g_sEventsLogFile, "Event Freeday was started by warden %L", client);
					}
					else CReplyToCommand(client, "%t %t", "freeday_tag" , "freeday_wait", g_iCoolDown);
				}
				else CReplyToCommand(client, "%t %t", "freeday_tag" , "freeday_progress" , EventDay);
			}
			else CReplyToCommand(client, "%t %t", "warden_tag" , "freeday_setbywarden");
		}
		else if (CheckVipFlag(client,g_sAdminFlag))
		{
			if (gc_bSetA.BoolValue)
			{
				char EventDay[64];
				GetEventDayName(EventDay);
				
				if(!IsEventDayPlanned())
				{
					if (g_iCoolDown == 0)
					{
						StartNextRound();
						if(ActiveLogging()) LogToFileEx(g_sEventsLogFile, "Event Freeday was started by admin %L", client);
					}
					else CReplyToCommand(client, "%t %t", "freeday_tag" , "freeday_wait", g_iCoolDown);
				}
				else CReplyToCommand(client, "%t %t", "freeday_tag" , "freeday_progress" , EventDay);
			}
			else CReplyToCommand(client, "%t %t", "freeday_tag" , "freeday_setbyadmin");
		}
		else CReplyToCommand(client, "%t %t", "warden_tag" , "warden_notwarden");
	}
	else CReplyToCommand(client, "%t %t", "freeday_tag" , "freeday_disabled");
	return Plugin_Handled;
}


//Voting for Event
public Action Command_VoteFreeday(int client,int args)
{
	char steamid[64];
	GetClientAuthId(client, AuthId_Steam2, steamid, sizeof(steamid));
	
	if (gc_bPlugin.BoolValue)
	{	
		if (gc_bVote.BoolValue)
		{
			char EventDay[64];
			GetEventDayName(EventDay);
			
			if(!IsEventDayPlanned())
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
							if(ActiveLogging()) LogToFileEx(g_sEventsLogFile, "Event freeday was started by voting");
						}
						else CPrintToChatAll("%t %t", "freeday_tag" , "freeday_need", Missing, client);
					}
					else CReplyToCommand(client, "%t %t", "freeday_tag" , "freeday_voted");
				}
				else CReplyToCommand(client, "%t %t", "freeday_tag" , "freeday_wait", g_iCoolDown);
			}
			else CReplyToCommand(client, "%t %t", "freeday_tag" , "freeday_progress" , EventDay);
		}
		else CReplyToCommand(client, "%t %t", "freeday_tag" , "freeday_voting");
	}
	else CReplyToCommand(client, "%t %t", "freeday_tag" , "freeday_disabled");
	return Plugin_Handled;
}


/******************************************************************************
                   EVENTS
******************************************************************************/


//Round start

public void Event_RoundStart(Event event, char[] name, bool dontBroadcast)
{
	if ((GetTeamClientCount(CS_TEAM_CT) < 1) && gc_bAuto.BoolValue)
	{
		char EventDay[64];
		GetEventDayName(EventDay);
		
		if(!IsEventDayPlanned())
		{
			StartFreeday = true;
			g_iCoolDown = gc_iCooldownDay.IntValue + 1;
			g_iVoteCount = 0;
			char buffer[32];
			Format(buffer, sizeof(buffer), "%T", "freeday_name", LANG_SERVER);
			SetEventDayName(buffer);
			SetEventDayRunning(true);
		//	AutoFreeday = true;
		}
	}
	if (StartFreeday)
	{
		SetCvar("sm_hosties_lr", 0);
		SetCvar("sm_weapons_enable", 0);
		SetCvar("sm_weapons_t", 0);
		SetCvar("sm_warden_enable", 0);
		SetEventDayPlanned(false);
		SetEventDayRunning(true);
		IsFreeday = true;
		FreedayRound++;
		StartFreeday = false;
		SJD_OpenDoors();
		
		LoopClients(client)
		{
			CreateInfoPanel(client);
			
			if (!gc_bdamage.BoolValue && IsValidClient(client))
			{
				SetEntProp(client, Prop_Data, "m_takedamage", 0, 1);
			}
			if (IsPlayerAlive(client)) 
			{
				PrintCenterText(client,"%t", "freeday_start_nc");
			}
		}
		CPrintToChatAll("%t %t", "freeday_tag" , "freeday_start");
	}
	else
	{
		if (g_iCoolDown > 0) g_iCoolDown--;
	}
}


//Round End
public void Event_RoundEnd(Event event, char[] name, bool dontBroadcast)
{
	if (IsFreeday)
	{
		IsFreeday = false;
		StartFreeday = false;
		FreedayRound = 0;
		Format(g_sHasVoted, sizeof(g_sHasVoted), "");
		SetCvar("sm_hosties_lr", 1);
		SetCvar("sm_weapons_enable", 1);
		SetCvar("mp_teammates_are_enemies", 0);
		SetCvar("sm_warden_enable", 1);
		g_iMPRoundTime.IntValue = g_iOldRoundTime;
	//	AutoFreeday = false;
		SetEventDayName("none");
		SetEventDayRunning(false);
		CPrintToChatAll("%t %t", "freeday_tag" , "freeday_end");
	}
	if (StartFreeday)
	{
		LoopClients(i) CreateInfoPanel(i);
		
		CPrintToChatAll("%t %t", "freeday_tag" , "freeday_next");
		PrintCenterTextAll("%t", "freeday_next_nc");
	}
}


/*
public void Event_PlayerDeath(Event event, const char[] name, bool dontBroadcast) 
{
	if((AutoFreeday && gc_iRespawn.IntValue == 1) || (IsFreeday && gc_iRespawn.IntValue == 2) || ((IsFreeday || AutoFreeday) && gc_iRespawn.IntValue == 3))
	{
		int client = GetClientOfUserId(event.GetInt("userid")); // Get the dead clients id
		
		CS_RespawnPlayer(client);
	}
}
*/


/******************************************************************************
                   FORWARDS LISTEN
******************************************************************************/


//Initialize Event
public void OnMapStart()
{
	g_iVoteCount = 0;
	FreedayRound = 0;
	
	if (gc_bFirst.BoolValue)
	{
		StartFreeday = true;
		
		char buffer[32];
		Format(buffer, sizeof(buffer), "%T", "freeday_name", LANG_SERVER);
		SetEventDayName(buffer);
		
		SetEventDayRunning(true);
		
		g_iOldRoundTime = g_iMPRoundTime.IntValue;
		g_iMPRoundTime.IntValue = gc_iRoundTime.IntValue;
	}
	else
	{
		StartFreeday = false;	
	}
	IsFreeday = false;
//	AutoFreeday = false;
}


//Map End
public void OnMapEnd()
{
	if (gc_bFirst.BoolValue)
	{
		StartFreeday = true;
	}
	else
	{
		StartFreeday = false;
	}
	IsFreeday = false;
//	AutoFreeday = false;
	g_iVoteCount = 0;
	FreedayRound = 0;
	g_sHasVoted[0] = '\0';
	SetEventDayName("none");
}


/******************************************************************************
                   FUNCTIONS
******************************************************************************/


//Prepare Event
void StartNextRound()
{
	StartFreeday = true;
	g_iCoolDown = gc_iCooldownDay.IntValue + 1;
	g_iVoteCount = 0;
	char buffer[32];
	Format(buffer, sizeof(buffer), "%T", "freeday_name", LANG_SERVER);
	SetEventDayName(buffer);
	SetEventDayPlanned(true);
	g_iOldRoundTime = g_iMPRoundTime.IntValue;
	g_iMPRoundTime.IntValue = gc_iRoundTime.IntValue;
	
	CPrintToChatAll("%t %t", "freeday_tag" , "freeday_next");
	PrintCenterTextAll("%t", "freeday_next_nc");
}


/******************************************************************************
                   MENUS
******************************************************************************/


stock void CreateInfoPanel(int client)
{
	//Create info Panel
	char info[255];
	
	FreedayMenu = CreatePanel();
	Format(info, sizeof(info), "%T", "freeday_info_title", client);
	SetPanelTitle(FreedayMenu, info);
	DrawPanelText(FreedayMenu, "                                   ");
	Format(info, sizeof(info), "%T", "freeday_info_line1", client);
	DrawPanelText(FreedayMenu, info);
	DrawPanelText(FreedayMenu, "-----------------------------------");
	Format(info, sizeof(info), "%T", "freeday_info_line2", client);
	DrawPanelText(FreedayMenu, info);
	Format(info, sizeof(info), "%T", "freeday_info_line3", client);
	DrawPanelText(FreedayMenu, info);
	Format(info, sizeof(info), "%T", "freeday_info_line4", client);
	DrawPanelText(FreedayMenu, info);
	Format(info, sizeof(info), "%T", "freeday_info_line5", client);
	DrawPanelText(FreedayMenu, info);
	Format(info, sizeof(info), "%T", "freeday_info_line6", client);
	DrawPanelText(FreedayMenu, info);
	Format(info, sizeof(info), "%T", "freeday_info_line7", client);
	DrawPanelText(FreedayMenu, info);
	DrawPanelText(FreedayMenu, "-----------------------------------");
	Format(info, sizeof(info), "%T", "warden_close", client);
	DrawPanelItem(FreedayMenu, info); 
	SendPanelToClient(FreedayMenu, client, Handler_NullCancel, 20);
}