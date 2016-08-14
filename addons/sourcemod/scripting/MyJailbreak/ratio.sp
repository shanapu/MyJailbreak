/*
 * MyJailbreak - Ratio Plugin.
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
#include <clientprefs>


//Compiler Options
#pragma semicolon 1
#pragma newdecls required


//Console Variables
ConVar gc_fPrisonerPerGuard;
ConVar gc_sCustomCommandGuard;
ConVar gc_sCustomCommandQueue;
ConVar gc_sCustomCommandLeave;
ConVar gc_sCustomCommandRatio;
ConVar gc_sCustomCommandRemove;
ConVar gc_sAdminFlag;
ConVar gc_bToggle;
ConVar gc_bToggleAnnounce;
ConVar gc_bAdsVIP;
ConVar gc_bVIPQueue;
ConVar gc_bAdminBypass;
ConVar gc_bForceTConnect;
ConVar gc_iJoinMode;
ConVar gc_iQuestionTimes;


//Booleans
bool g_bRatioEnable = true;


//Handles
Handle g_aGuardQueue;
Handle g_sCookieCTBan;
Handle ViewQueueMenu;


//Integer
int randomanswer[MAXPLAYERS+1];
int questiontimes[MAXPLAYERS+1];


//Strings
char g_sRestrictedSound[32] = "buttons/button11.wav";
char g_sRightAnswerSound[32] = "buttons/button14.wav";
char g_sAdminFlag[32];


//Info
public Plugin myinfo = {
	name = "MyJailbreak - Ratio",
	author = "shanapu, Addicted",
	description = "Jailbreak team balance / ratio plugin",
	version = PLUGIN_VERSION,
	url = URL_LINK
};


//Start
public void OnPluginStart()
{
	//Translation
	LoadTranslations("MyJailbreak.Ratio.phrases");
	LoadTranslations("MyJailbreak.Warden.phrases");
	
	
	//Client commands
	RegConsoleCmd("sm_guard", Command_JoinGuardQueue,"Allows the prisoners to queue to CT");
	RegConsoleCmd("sm_viewqueue", Command_ViewGuardQueue,"Allows a player to show queue to CT");
	RegConsoleCmd("sm_leavequeue", Command_LeaveQueue,"Allows a player to leave queue to CT");
	RegConsoleCmd("sm_ratio", Command_ToggleRatio, "Allows the admin toggle the ratio check and player to see if ratio is enabled");
	
	
	//Admin commands
	RegAdminCmd("sm_removequeue", AdminCommand_RemoveFromQueue, ADMFLAG_GENERIC,"Allows the admin to remove player from queue to CT");
	
	//AutoExecConfig
	AutoExecConfig_SetFile("Ratio", "MyJailbreak");
	AutoExecConfig_SetCreateFile(true);
	
	AutoExecConfig_CreateConVar("sm_ratio_version", PLUGIN_VERSION, "The version of this MyJailbreak SourceMod plugin", FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_DONTRECORD);
	gc_sCustomCommandGuard = AutoExecConfig_CreateConVar("sm_ratio_cmds_guard", "g,ct,guards", "Set your custom chat command for become guard(!guard (no 'sm_'/'!')(seperate with comma ',')(max. 12 commands))");
	gc_sCustomCommandQueue = AutoExecConfig_CreateConVar("sm_ratio_cmds_queue", "vq,queue", "Set your custom chat command for view guard queue (!viewqueue (no 'sm_'/'!')(seperate with comma ',')(max. 12 commands))");
	gc_sCustomCommandLeave = AutoExecConfig_CreateConVar("sm_ratio_cmds_leave", "lq,stay", "Set your custom chat command for view leave queue (!leavequeue (no 'sm_'/'!')(seperate with comma ',')(max. 12 commands))");
	gc_sCustomCommandRatio = AutoExecConfig_CreateConVar("sm_ratio_cmds_ratio", "balance", "Set your custom chat command for view/toggle ratio (!ratio (no 'sm_'/'!')(seperate with comma ',')(max. 12 commands))");
	gc_sCustomCommandRemove = AutoExecConfig_CreateConVar("sm_ratio_cmds_remove", "rq", "Set your custom chat command for admins to remove a player from guard queue (!removequeue (no 'sm_'/'!')(seperate with comma ',')(max. 12 commands))");
	gc_fPrisonerPerGuard = AutoExecConfig_CreateConVar("sm_ratio_T_per_CT", "2", "How many prisoners for each guard.", _, true, 1.0);
	gc_bVIPQueue = AutoExecConfig_CreateConVar("sm_ratio_flag", "1", "0 - disabled, 1 - enable VIPs moved to front of queue", _, true,  0.0, true, 1.0);
	gc_bForceTConnect = AutoExecConfig_CreateConVar("sm_ratio_force_t", "1", "0 - disabled, 1 - force player on connect to join T side", _, true,  0.0, true, 1.0);
	gc_sAdminFlag = AutoExecConfig_CreateConVar("sm_ratio_vipflag", "a", "Set the flag for VIP");
	gc_bToggle = AutoExecConfig_CreateConVar("sm_ratio_disable", "0", "Allow the admin to toggle 'ratio check & autoswap' on/off with !ratio", _, true,  0.0, true, 1.0);
	gc_bToggleAnnounce = AutoExecConfig_CreateConVar("sm_ratio_disable_announce", "0", "Announce in a chatmessage on roundend when ratio is disabled", _, true,  0.0, true, 1.0);
	gc_bAdsVIP = AutoExecConfig_CreateConVar("sm_ratio_adsvip", "1", "0 - disabled, 1 - enable adverstiment for 'VIPs moved to front of queue' when player types !quard ", _, true,  0.0, true, 1.0);
	gc_iJoinMode = AutoExecConfig_CreateConVar("sm_ratio_join_mode", "1", "0 - instandly join ct/queue, no confirmation / 1 - confirm rules / 2 - Qualification questions", _, true,  0.0, true, 2.0);
	gc_iQuestionTimes = AutoExecConfig_CreateConVar("sm_ratio_questions", "3", "How many question a player have to answer before join ct/queue. need sm_ratio_join_mode 2", _, true,  1.0, true, 5.0);
	gc_bAdminBypass = AutoExecConfig_CreateConVar("sm_ratio_vip_bypass", "1", "Bypass Admin/VIP though agreement / question", _, true,  0.0, true, 1.0);
	
	AutoExecConfig_ExecuteFile();
	AutoExecConfig_CleanFile();
	
	
	//Hooks
	AddCommandListener(Event_OnJoinTeam, "jointeam");
	HookEvent("player_connect_full", Event_OnFullConnect, EventHookMode_Pre);
	HookEvent("player_team", Event_PlayerTeam_Post, EventHookMode_Post);
	HookEvent("round_end", Event_RoundEnd_Post, EventHookMode_Post);
	HookEvent("player_spawn", Event_OnPlayerSpawn, EventHookMode_Post);
	
	
	//FindConVar
	gc_sAdminFlag.GetString(g_sAdminFlag,sizeof(g_sAdminFlag));
	
	
	//Prepare
	g_aGuardQueue = CreateArray();
	
	
	//Cookies
	if((g_sCookieCTBan = FindClientCookie("Banned_From_CT")) == INVALID_HANDLE)
		g_sCookieCTBan = RegClientCookie("Banned_From_CT", "Tells if you are restricted from joining the CT team", CookieAccess_Protected);
}


public void OnConfigsExecuted()
{
	Handle hConVar = FindConVar("mp_force_pick_time");
	if(hConVar == INVALID_HANDLE)
		return;
	
	HookConVarChange(hConVar, OnForcePickTimeChanged);
	SetConVarInt(hConVar, 999999);
	
	
	//Set custom Commands
	int iCount = 0;
	char sCommands[128], sCommandsL[12][32], sCommand[32];
	
	//Join Guardqueue
	gc_sCustomCommandGuard.GetString(sCommands, sizeof(sCommands));
	ReplaceString(sCommands, sizeof(sCommands), " ", "");
	iCount = ExplodeString(sCommands, ",", sCommandsL, sizeof(sCommandsL), sizeof(sCommandsL[]));
	
	for(int i = 0; i < iCount; i++)
	{
		Format(sCommand, sizeof(sCommand), "sm_%s", sCommandsL[i]);
		if(GetCommandFlags(sCommand) == INVALID_FCVAR_FLAGS)  //if command not already exist
			RegConsoleCmd(sCommand, Command_JoinGuardQueue,"Allows the prisoners to queue to CT");
	}
	
	//View guardqueue
	gc_sCustomCommandQueue.GetString(sCommands, sizeof(sCommands));
	ReplaceString(sCommands, sizeof(sCommands), " ", "");
	iCount = ExplodeString(sCommands, ",", sCommandsL, sizeof(sCommandsL), sizeof(sCommandsL[]));
	
	for(int i = 0; i < iCount; i++)
	{
		Format(sCommand, sizeof(sCommand), "sm_%s", sCommandsL[i]);
		if(GetCommandFlags(sCommand) == INVALID_FCVAR_FLAGS)  //if command not already exist
			RegConsoleCmd(sCommand, Command_ViewGuardQueue,"Allows a player to show queue to CT");
	}
	
	//leave guardqueue
	gc_sCustomCommandLeave.GetString(sCommands, sizeof(sCommands));
	ReplaceString(sCommands, sizeof(sCommands), " ", "");
	iCount = ExplodeString(sCommands, ",", sCommandsL, sizeof(sCommandsL), sizeof(sCommandsL[]));
	
	for(int i = 0; i < iCount; i++)
	{
		Format(sCommand, sizeof(sCommand), "sm_%s", sCommandsL[i]);
		if(GetCommandFlags(sCommand) == INVALID_FCVAR_FLAGS)  //if command not already exist
			RegConsoleCmd(sCommand, Command_LeaveQueue,"Allows a player to leave queue to CT");
	}
	
	//View/toggle ratio
	gc_sCustomCommandRatio.GetString(sCommands, sizeof(sCommands));
	ReplaceString(sCommands, sizeof(sCommands), " ", "");
	iCount = ExplodeString(sCommands, ",", sCommandsL, sizeof(sCommandsL), sizeof(sCommandsL[]));
	
	for(int i = 0; i < iCount; i++)
	{
		Format(sCommand, sizeof(sCommand), "sm_%s", sCommandsL[i]);
		if(GetCommandFlags(sCommand) == INVALID_FCVAR_FLAGS)  //if command not already exist
			RegConsoleCmd(sCommand, Command_ToggleRatio, "Allows the admin toggle the ratio check and player to see if ratio is enabled");
	}
	
	//Admin remove player from queue
	gc_sCustomCommandRemove.GetString(sCommands, sizeof(sCommands));
	ReplaceString(sCommands, sizeof(sCommands), " ", "");
	iCount = ExplodeString(sCommands, ",", sCommandsL, sizeof(sCommandsL), sizeof(sCommandsL[]));
	
	for(int i = 0; i < iCount; i++)
	{
		Format(sCommand, sizeof(sCommand), "sm_%s", sCommandsL[i]);
		if(GetCommandFlags(sCommand) == INVALID_FCVAR_FLAGS)  //if command not already exist
			RegAdminCmd(sCommand, AdminCommand_RemoveFromQueue, ADMFLAG_GENERIC,"Allows the admin to remove player from queue to CT");
	}
}


/******************************************************************************
                   COMMANDS
******************************************************************************/


public Action Command_LeaveQueue(int client, int iArgNum)
{
	int iIndex = FindValueInArray(g_aGuardQueue, client);
	
	if(!g_bRatioEnable)
	{
		CReplyToCommand(client, "%t %t", "ratio_tag", "ratio_disabled");
		return Plugin_Handled;
	}
	
	if(iIndex == -1)
	{
		CReplyToCommand(client, "%t %t", "ratio_tag" , "ratio_notonqueue");
		return Plugin_Handled;
	}
	else
	{
		RemovePlayerFromGuardQueue(client);
		CReplyToCommand(client, "%t %t", "ratio_tag" , "ratio_leavedqueue");
		return Plugin_Handled;
	}
}


public Action Command_ViewGuardQueue(int client, int args)
{
	if(!IsValidClient(client, true, true))
		return Plugin_Handled;
	
	if(!g_bRatioEnable)
	{
		CReplyToCommand(client, "%t %t", "ratio_tag", "ratio_disabled");
		return Plugin_Handled;
	}
	
	if(GetArraySize(g_aGuardQueue) < 1)
	{
		CReplyToCommand(client, "%t %t", "ratio_tag" , "ratio_empty");
		return Plugin_Handled;
	}
	char info[64];
	
	ViewQueueMenu = CreatePanel();
	
	Format(info, sizeof(info), "%T", "ratio_info_title", client);
	SetPanelTitle(ViewQueueMenu, info);
	DrawPanelText(ViewQueueMenu, "-----------------------------------");
	DrawPanelText(ViewQueueMenu, "                                   ");
	
	for (int i; i < GetArraySize(g_aGuardQueue); i++)
	{
		if(!IsValidClient(GetArrayCell(g_aGuardQueue, i), true, true))
			continue;
		
		char display[120];
		Format(display, sizeof(display), "%N", GetArrayCell(g_aGuardQueue, i));
		DrawPanelText(ViewQueueMenu, display);
	}
	
	DrawPanelText(ViewQueueMenu, "                                   ");
	DrawPanelText(ViewQueueMenu, "-----------------------------------");
	Format(info, sizeof(info), "%T", "warden_close", client);
	DrawPanelItem(ViewQueueMenu, info); 
	SendPanelToClient(ViewQueueMenu, client, Handler_NullCancel, 12);
	
	return Plugin_Handled;
}


public Action Command_JoinGuardQueue(int client, int iArgNum)
{
	if(!IsValidClient(client, true, true))
	{
		return Plugin_Handled;
	}
	
	if(!g_bRatioEnable)
	{
		CReplyToCommand(client, "%t %t", "ratio_tag", "ratio_disabled");
		return Plugin_Handled;
	}
	
	if(GetClientTeam(client) != CS_TEAM_T)
	{
		ClientCommand(client, "play %s", g_sRestrictedSound);
		CReplyToCommand(client, "%t %t", "ratio_tag" , "ratio_noct");
		return Plugin_Handled;
	}
	
	char szCookie[2];
	GetClientCookie(client, g_sCookieCTBan, szCookie, sizeof(szCookie));
	if(szCookie[0] == '1')
	{
		ClientCommand(client, "play %s", g_sRestrictedSound);
		CReplyToCommand(client, "%t %t", "ratio_tag" , "ratio_banned");
		FakeClientCommand(client, "sm_isbanned @me");
		return Plugin_Handled;
	}
	
	
	int iIndex = FindValueInArray(g_aGuardQueue, client);
	
	if(iIndex == -1)
	{
		if((gc_iJoinMode.IntValue == 0) || (gc_bAdminBypass.BoolValue && CheckVipFlag(client, g_sAdminFlag))) AddToQueue(client);
		if((gc_iJoinMode.IntValue == 1) && ((gc_bAdminBypass.BoolValue && !CheckVipFlag(client, g_sAdminFlag)) || (!gc_bAdminBypass.BoolValue))) Menu_AcceptGuardRules(client);
		if((gc_iJoinMode.IntValue == 2) && ((gc_bAdminBypass.BoolValue && !CheckVipFlag(client, g_sAdminFlag)) || (!gc_bAdminBypass.BoolValue))) Menu_GuardQuestions(client);
		questiontimes[client] = gc_iQuestionTimes.IntValue-1;
		return Plugin_Handled;
	}
	else
	{
		CReplyToCommand(client, "%t %t", "ratio_tag" , "ratio_number", iIndex + 1);
		if(gc_bAdsVIP.BoolValue && gc_bVIPQueue.BoolValue && !CheckVipFlag(client, g_sAdminFlag)) CReplyToCommand(client, "%t %t", "ratio_tag" , "ratio_advip");
	}
	return Plugin_Continue;
}


public Action AdminCommand_RemoveFromQueue(int client, int args)
{
	if(!IsValidClient(client, true, true))
		return Plugin_Handled;
	
	if(!g_bRatioEnable)
	{
		CReplyToCommand(client, "%t %t", "ratio_tag", "ratio_disabled");
		return Plugin_Handled;
	}
	
	if(GetArraySize(g_aGuardQueue) < 1)
	{
		CReplyToCommand(client, "%t %t", "ratio_tag" , "ratio_empty");
		return Plugin_Handled;
	}
	
	Menu hMenu = CreateMenu(ViewQueueMenuHandle);
	SetMenuTitle(hMenu, "Remove from Queue:");
	
	for (int i; i < GetArraySize(g_aGuardQueue); i++)
	{
		if(!IsValidClient(GetArrayCell(g_aGuardQueue, i),true,true))
			continue;
		
		char userid[11];
		char username[MAX_NAME_LENGTH];
		IntToString(GetClientUserId(i+1), userid, sizeof(userid));
		Format(username, sizeof(username), "%N", GetArrayCell(g_aGuardQueue, i));
		hMenu.AddItem(userid,username);
	}
	hMenu.ExitBackButton = true;
	hMenu.ExitButton = true;
	DisplayMenu(hMenu, client, 15);
	
	return Plugin_Handled;
}


public Action Command_ToggleRatio(int client, int args)
{
	if(CheckVipFlag(client, g_sAdminFlag) && gc_bToggle.BoolValue)
	{
		if(g_bRatioEnable)
		{
			g_bRatioEnable = false;
			CPrintToChatAll("%t %t", "ratio_tag", "ratio_hasdisabled");
		}
		else
		{
			g_bRatioEnable = true;
			CPrintToChatAll("%t %t", "ratio_tag", "ratio_hasactivated");
		}
	}
	else
	{
		if(g_bRatioEnable)
		{
			CReplyToCommand(client, "%t %t", "ratio_tag", "ratio_active", gc_fPrisonerPerGuard.FloatValue);
		}
		else
		{
			CReplyToCommand(client, "%t %t", "ratio_tag", "ratio_disabled");
		}
	}
}


/******************************************************************************
                   EVENTS
******************************************************************************/


public Action Event_OnPlayerSpawn(Event event, const char[] name, bool bDontBroadcast) 
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	
	if (GetClientTeam(client) != 3) 
		return Plugin_Continue;
		
	if (!IsValidClient(client, true, false))
		return Plugin_Continue;
		
	char sData[2];
	GetClientCookie(client, g_sCookieCTBan, sData, sizeof(sData));
	
	if(sData[0] == '1')
	{
		CPrintToChat(client, "%t %t", "ratio_tag" , "ratio_banned");
		PrintCenterText(client, "%t", "ratio_banned");
		CreateTimer(5.0, Timer_SlayPlayer, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
		return Plugin_Continue;
	}
	
	return Plugin_Continue;
}


public void Event_PlayerTeam_Post(Event event, const char[] szName, bool bDontBroadcast)
{
	if(GetEventInt(event, "team") != CS_TEAM_CT)
		return;
	
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	RemovePlayerFromGuardQueue(client);
}


public Action Event_RoundEnd_Post(Event event, const char[] szName, bool bDontBroadcast)
{
	if(g_bRatioEnable) FixTeamRatio();
	else if(gc_bToggleAnnounce.BoolValue) CPrintToChatAll("%t %t", "ratio_tag", "ratio_disabled");
}


public Action Event_OnFullConnect(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	if(gc_bForceTConnect.BoolValue && g_bRatioEnable && ((gc_bAdminBypass.BoolValue && !CheckVipFlag(client, g_sAdminFlag)) || !gc_bAdminBypass.BoolValue)) CreateTimer(1.0, Timer_ForceTSide, client);
	return Plugin_Continue;
}


public Action Event_OnJoinTeam(int client, const char[] szCommand, int iArgCount)
{
	if(iArgCount < 1)
		return Plugin_Continue;
	
	if(!g_bRatioEnable)
	{
		CPrintToChat(client, "%t %t", "ratio_tag", "ratio_disabled");
		return Plugin_Continue;
	}
	
	char szData[2];
	GetCmdArg(1, szData, sizeof(szData));
	int iTeam = StringToInt(szData);
	
	if(!iTeam)
	{
		ClientCommand(client, "play %s", g_sRestrictedSound);
		CPrintToChat(client, "%t %t", "ratio_tag" , "ratio_auto");
		return Plugin_Handled;
	}
	
	if(iTeam != CS_TEAM_CT)
		return Plugin_Continue;
	
	GetClientCookie(client, g_sCookieCTBan, szData, sizeof(szData));
	
	if(szData[0] == '1')
	{
		ClientCommand(client, "play %s", g_sRestrictedSound);
		CPrintToChat(client, "%t %t", "ratio_tag" , "ratio_banned");
		FakeClientCommand(client, "sm_isbanned @me");
		return Plugin_Handled;
	}
	if(!CanClientJoinGuards(client))
	{
		int iIndex = FindValueInArray(g_aGuardQueue, client);
		
		ClientCommand(client, "play %s", g_sRestrictedSound);
		
		if(iIndex == -1)
		{
			if((gc_iJoinMode.IntValue == 0) || (gc_bAdminBypass.BoolValue && CheckVipFlag(client, g_sAdminFlag))) FullAddToQueue(client);
			if((gc_iJoinMode.IntValue == 1) && ((gc_bAdminBypass.BoolValue && !CheckVipFlag(client, g_sAdminFlag)) || (!gc_bAdminBypass.BoolValue))) Menu_AcceptGuardRules(client);
			if((gc_iJoinMode.IntValue == 2) && ((gc_bAdminBypass.BoolValue && !CheckVipFlag(client, g_sAdminFlag)) || (!gc_bAdminBypass.BoolValue))) Menu_GuardQuestions(client);
			questiontimes[client] = gc_iQuestionTimes.IntValue-1;
			return Plugin_Handled;
		}
		else
		{
			CPrintToChat(client, "%t %t", "ratio_tag" , "ratio_fullqueue", iIndex + 1);
			if(gc_bAdsVIP.BoolValue && gc_bVIPQueue.BoolValue && !CheckVipFlag(client, g_sAdminFlag)) CPrintToChat(client, "%t %t", "ratio_tag" , "ratio_advip");
			return Plugin_Handled;
		}
	}
	
	if((gc_iJoinMode.IntValue == 0) || (gc_bAdminBypass.BoolValue && CheckVipFlag(client, g_sAdminFlag))) return Plugin_Continue;
	if((gc_iJoinMode.IntValue == 1) && ((gc_bAdminBypass.BoolValue && !CheckVipFlag(client, g_sAdminFlag)) || (!gc_bAdminBypass.BoolValue))) Menu_AcceptGuardRules(client);
	if((gc_iJoinMode.IntValue == 2) && ((gc_bAdminBypass.BoolValue && !CheckVipFlag(client, g_sAdminFlag)) || (!gc_bAdminBypass.BoolValue))) Menu_GuardQuestions(client);
	questiontimes[client] = gc_iQuestionTimes.IntValue-1;
	return Plugin_Handled;
}


/******************************************************************************
                   FUNCTIONS
******************************************************************************/


/*
void MinusDeath(int client)
{
	if(IsValidClient(client, true, true))
	{
		int frags = GetEntProp(client, Prop_Data, "m_iFrags");
		int deaths = GetEntProp(client, Prop_Data, "m_iDeaths");
		SetEntProp(client, Prop_Data, "m_iFrags", (frags++));
		SetEntProp(client, Prop_Data, "m_iDeaths", (deaths-1));
		
	}
}
*/


public void AddToQueue(int client)
{
	int iIndex = FindValueInArray(g_aGuardQueue, client);
	int iQueueSize = GetArraySize(g_aGuardQueue);
	
	if(iIndex == -1)
	{
		if (CheckVipFlag(client, g_sAdminFlag) && gc_bVIPQueue.BoolValue)
		{
			if (iQueueSize == 0)
				iIndex = PushArrayCell(g_aGuardQueue, client);
			else
			{
				ShiftArrayUp(g_aGuardQueue, 0);
				SetArrayCell(g_aGuardQueue, 0, client);
			}
			CPrintToChat(client, "%t %t", "ratio_tag" , "ratio_thxvip");
			CPrintToChat(client, "%t %t", "ratio_tag" , "ratio_number", iIndex + 1);
		}
		else
		{
			iIndex = PushArrayCell(g_aGuardQueue, client);
			
			CPrintToChat(client, "%t %t", "ratio_tag" , "ratio_number", iIndex + 1);
			if(gc_bAdsVIP.BoolValue && gc_bVIPQueue.BoolValue) CPrintToChat(client, "%t %t", "ratio_tag" , "ratio_advip");
		}
	}
}


public void FullAddToQueue(int client)
{
	int iIndex = FindValueInArray(g_aGuardQueue, client);
	int iQueueSize = GetArraySize(g_aGuardQueue);
	
	if(iIndex == -1)
	{
		if (CheckVipFlag(client, g_sAdminFlag) && gc_bVIPQueue.BoolValue)
		{
			if (iQueueSize == 0)
				iIndex = PushArrayCell(g_aGuardQueue, client);
			else
			{
				ShiftArrayUp(g_aGuardQueue, 0);
				SetArrayCell(g_aGuardQueue, 0, client);
			}
			CPrintToChat(client, "%t %t", "ratio_tag" , "ratio_thxvip");
			CPrintToChat(client, "%t %t", "ratio_tag" , "ratio_number", iIndex + 1);
		}
		else
		{
			iIndex = PushArrayCell(g_aGuardQueue, client);
			
			CPrintToChat(client, "%t %t", "ratio_tag" , "ratio_number", iIndex + 1);
			if(gc_bAdsVIP.BoolValue && gc_bVIPQueue.BoolValue) CPrintToChat(client, "%t %t", "ratio_tag" , "ratio_advip");
		}
	}
}


public void OnForcePickTimeChanged(Handle hConVar, const char[] szOldValue, const char[] szNewValue)
{
	SetConVarInt(hConVar, 999999);
}


bool ShouldMoveGuardToPrisoner()
{
	int iNumGuards, iNumPrisoners;
	
	LoopValidClients(i, true,true)
	{	
		if (GetClientPendingTeam(i) == CS_TEAM_T)
			iNumPrisoners++;
		else if (GetClientPendingTeam(i) == CS_TEAM_CT)
			 iNumGuards++;
	}
	
	if(iNumGuards <= 1)
		return false;
	
	if(iNumGuards <= RoundToFloor(float(iNumPrisoners) / GetConVarFloat(gc_fPrisonerPerGuard)))
		return false;
	
	return true;
}


/******************************************************************************
                   FORWARDS LISTEN
******************************************************************************/


public void OnClientDisconnect_Post(int client)
{
	RemovePlayerFromGuardQueue(client);
}


public void OnMapStart()
{
	g_bRatioEnable = true;
}


/******************************************************************************
                   MENUS
******************************************************************************/


public Action Menu_AcceptGuardRules(int client)
{
	char info[64];
	
	Handle AcceptMenu = CreatePanel();
	
	Format(info, sizeof(info), "%T", "ratio_accept_title", client);
	SetPanelTitle(AcceptMenu, info);
	DrawPanelText(AcceptMenu, "-----------------------------------");
	Format(info, sizeof(info), "%T", "ratio_accept_line1", client);
	DrawPanelText(AcceptMenu, info);
	DrawPanelText(AcceptMenu, "    ");
	Format(info, sizeof(info), "%T", "ratio_accept_line2", client);
	DrawPanelText(AcceptMenu, info);
	Format(info, sizeof(info), "%T", "ratio_accept_line3", client);
	DrawPanelText(AcceptMenu, info);
	Format(info, sizeof(info), "%T", "ratio_accept_line4", client);
	DrawPanelText(AcceptMenu, info);
	Format(info, sizeof(info), "%T", "ratio_accept_line5", client);
	DrawPanelText(AcceptMenu, info);
	DrawPanelText(AcceptMenu, "    ");
	DrawPanelText(AcceptMenu, "-----------------------------------");
	DrawPanelText(AcceptMenu, "    ");
	Format(info, sizeof(info), "%T", "ratio_accept", client);
	DrawPanelItem(AcceptMenu, info); 
	Format(info, sizeof(info), "%T", "ratio_notaccept", client);
	DrawPanelItem(AcceptMenu, info); 
	SendPanelToClient(AcceptMenu, client, Handler_AcceptGuardRules, 20);
}


public int Handler_AcceptGuardRules(Handle menu, MenuAction action, int param1, int param2)
{
	int client = param1;
	if (action == MenuAction_Select)
	{
		switch(param2)
		{
			case 1:
			{
				if(CanClientJoinGuards(client))
				{
					ForcePlayerSuicide(client);
					ChangeClientTeam(client, CS_TEAM_CT);
					// MinusDeath(client);
				//	CS_RespawnPlayer(client);
				}
				else AddToQueue(client);
				ClientCommand(client, "play %s", g_sRightAnswerSound);
			}
			case 2:
			{
				ClientCommand(client, "play %s", g_sRestrictedSound);
			}
		}
	}
}


//
public void Menu_GuardQuestions(int client)
{
	char info[64], random[64];
	
	Handle AcceptMenu = CreatePanel();
	int randomquestion = GetRandomInt(1,5);
	randomanswer[client] = GetRandomInt(1,3);
	
	Format(info, sizeof(info), "%T", "ratio_question_title", client);
	SetPanelTitle(AcceptMenu, info);
	DrawPanelText(AcceptMenu, "-----------------------------------");
	Format(random, sizeof(random), "ratio_question%i_line1", randomquestion);
	Format(info, sizeof(info), "%T", random, client);
	DrawPanelText(AcceptMenu, info);
	Format(random, sizeof(random), "ratio_question%i_line2", randomquestion);
	Format(info, sizeof(info), "%T", random, client);
	DrawPanelText(AcceptMenu, info);
	DrawPanelText(AcceptMenu, "-----------------------------------");
	
	if(randomanswer[client] == 1)
	{
		DrawPanelText(AcceptMenu, "    ");
		Format(random, sizeof(random), "ratio_question%i_right", randomquestion);
		Format(info, sizeof(info), "%T", random, client);
		DrawPanelItem(AcceptMenu, info);
	}
	
	DrawPanelText(AcceptMenu, "    ");
	Format(random, sizeof(random), "ratio_question%i_wrong1", randomquestion);
	Format(info, sizeof(info), "%T", random, client);
	DrawPanelItem(AcceptMenu, info);
	
	if(randomanswer[client] == 2)
	{
		DrawPanelText(AcceptMenu, "    ");
		Format(random, sizeof(random), "ratio_question%i_right", randomquestion);
		Format(info, sizeof(info), "%T", random, client);
		DrawPanelItem(AcceptMenu, info);
	}
	
	DrawPanelText(AcceptMenu, "    ");
	Format(random, sizeof(random), "ratio_question%i_wrong2", randomquestion);
	Format(info, sizeof(info), "%T", random, client);
	DrawPanelItem(AcceptMenu, info);
	
	if(randomanswer[client] == 3)
	{
		DrawPanelText(AcceptMenu, "    ");
		Format(random, sizeof(random), "ratio_question%i_right", randomquestion);
		Format(info, sizeof(info), "%T", random, client);
		DrawPanelItem(AcceptMenu, info);
	}
	
	SendPanelToClient(AcceptMenu, client, Handler_GuardQuestions, 20);
}

//
public int Handler_GuardQuestions(Handle menu, MenuAction action, int param1, int param2)
{
	int client = param1;
	if (action == MenuAction_Select)
	{
		switch(param2)
		{
			case 1:
			{
				if(randomanswer[client] == 1)
				{
					if (questiontimes[client] <= 0)
					{
						if(CanClientJoinGuards(client))
						{
							ForcePlayerSuicide(client);
							ChangeClientTeam(client, CS_TEAM_CT);
							// MinusDeath(client);
						//	CS_RespawnPlayer(client);
						}
						else AddToQueue(client);
					}
					else Menu_GuardQuestions(client);
					ClientCommand(client, "play %s", g_sRightAnswerSound);
					questiontimes[client]--;
				}
				else ClientCommand(client, "play %s", g_sRestrictedSound);
			}
			case 2:
			{
				if(randomanswer[client] == 2)
				{
					if (questiontimes[client] <= 0)
					{
						if(CanClientJoinGuards(client))
						{
							ForcePlayerSuicide(client);
							ChangeClientTeam(client, CS_TEAM_CT);
							// MinusDeath(client);
						//	CS_RespawnPlayer(client);
						}
						else AddToQueue(client);
					}
					else Menu_GuardQuestions(client);
					ClientCommand(client, "play %s", g_sRightAnswerSound);
					questiontimes[client]--;
				}
				else ClientCommand(client, "play %s", g_sRestrictedSound);
			}
			case 3:
			{
				if(randomanswer[client] == 3)
				{
					if (questiontimes[client] <= 0)
					{
						if(CanClientJoinGuards(client))
						{
							ForcePlayerSuicide(client);
							ChangeClientTeam(client, CS_TEAM_CT);
							// MinusDeath(client);
						//	CS_RespawnPlayer(client);
						}
						else AddToQueue(client);
					}
					else Menu_GuardQuestions(client);
					ClientCommand(client, "play %s", g_sRightAnswerSound);
					questiontimes[client]--;
				}
				else ClientCommand(client, "play %s", g_sRestrictedSound);
			}
		}
	}
}


public int ViewQueueMenuHandle(Menu hMenu, MenuAction action, int client, int option)
{
	if (action == MenuAction_Select)
	{
		char info[32];
		hMenu.GetItem(option, info, sizeof(info));
		int user = GetClientOfUserId(StringToInt(info)); 
		
		RemovePlayerFromGuardQueue(user);
		
		CPrintToChatAll("%t %t", "ratio_tag", "ratio_removed", client, user);
		
	}
	else if(action == MenuAction_Cancel)
	{
		if(option == MenuCancel_ExitBack) 
		{
			FakeClientCommand(client, "sm_menu");
		}
	}
	else if(action == MenuAction_End)
	{
		delete hMenu;
	}
}


/******************************************************************************
                   TIMER
******************************************************************************/


public Action Timer_SlayPlayer(Handle hTimer, any iUserId) 
{
	int client = GetClientOfUserId(iUserId);
	
	if ((IsValidClient(client, false, false)) && (GetClientTeam(client) == CS_TEAM_CT))
	{
		ForcePlayerSuicide(client);
		ChangeClientTeam(client, CS_TEAM_T);
		CS_RespawnPlayer(client);
		// MinusDeath(client);
	}
	return Plugin_Stop;
}


public Action Timer_ForceTSide(Handle timer, any client)
{
	if(IsValidClient(client,true,true)) ChangeClientTeam(client, CS_TEAM_T);
}


/******************************************************************************
                   STOCKS
******************************************************************************/


stock bool RemovePlayerFromGuardQueue(int client)
{
	int iIndex = FindValueInArray(g_aGuardQueue, client);
	if(iIndex == -1)
		return;
	
	RemoveFromArray(g_aGuardQueue, iIndex);
}


bool ShouldMovePrisonerToGuard()
{
	int iNumGuards, iNumPrisoners;
	
	LoopValidClients(i, true,true)
	{	
		if (GetClientPendingTeam(i) == CS_TEAM_T)
			iNumPrisoners++;
		else if (GetClientPendingTeam(i) == CS_TEAM_CT)
			 iNumGuards++;
	}
	
	iNumPrisoners--;
	iNumGuards++;
	
	if(iNumPrisoners < 1)
		return false;
	
	if(float(iNumPrisoners) / float(iNumGuards) < GetConVarFloat(gc_fPrisonerPerGuard))
		return false;
	
	return true;
}


stock void FixTeamRatio()
{
	bool bMovedPlayers;
	while(ShouldMovePrisonerToGuard())
	{
		int client;
		if(GetArraySize(g_aGuardQueue))
		{
			client = GetArrayCell(g_aGuardQueue, 0);
			RemovePlayerFromGuardQueue(client);
			
			CPrintToChatAll("%t %t", "ratio_tag", "ratio_find", client);
		}
		else
		{
			client = GetRandomClientFromTeam(CS_TEAM_T, true);
			CPrintToChatAll("%t %t", "ratio_tag", "ratio_random", client);
		}
		
		if(!IsValidClient(client,true,true))
		{
			CPrintToChatAll("%t %t", "ratio_tag", "ratio_novalid");
			break;
		}
		
		SetClientPendingTeam(client, CS_TEAM_CT);
		// MinusDeath(client);
		bMovedPlayers = true;
	}
	
	if(bMovedPlayers)
		return;
	
	while(ShouldMoveGuardToPrisoner())
	{
		int client = GetRandomClientFromTeam(CS_TEAM_CT, true);
		if(!client)
			break;
			
		CPrintToChatAll("%t %t", "ratio_tag", "ratio_movetot" ,client);
		SetClientPendingTeam(client, CS_TEAM_T);
	}
}


stock int GetRandomClientFromTeam(int iTeam, bool bSkipCTBanned=true)
{
	int iNumFound;
	int clients[MAXPLAYERS];
	char szCookie[2];
	
	LoopValidClients(i, true,true)
	{
		if(!IsClientInGame(i))
			continue;
		
		if(warden_iswarden(i))
			continue;
		
		if(GetClientPendingTeam(i) != iTeam)
			continue;
		
		if(bSkipCTBanned)
		{
			if(!AreClientCookiesCached(i))
				continue;
			
			GetClientCookie(i, g_sCookieCTBan, szCookie, sizeof(szCookie));
			if(szCookie[0] == '1')
				continue;
		}
		
		clients[iNumFound++] = i;
	}
	
	if(!iNumFound)
		return 0;
	
	return clients[GetRandomInt(0, iNumFound-1)];
}


stock bool CanClientJoinGuards(int client)
{
	int iNumGuards, iNumPrisoners;
	
	LoopValidClients(i, true,true)
	{	
		if (GetClientPendingTeam(i) == CS_TEAM_T)
			iNumPrisoners++;
		else if (GetClientPendingTeam(i) == CS_TEAM_CT)
			 iNumGuards++;
	}
	
	iNumGuards++;
	if(GetClientPendingTeam(client) == CS_TEAM_T)
		iNumPrisoners--;
	
	if(iNumGuards <= 1)
		return true;
	
	float fNumPrisonersPerGuard = float(iNumPrisoners) / float(iNumGuards);
	if(fNumPrisonersPerGuard < GetConVarFloat(gc_fPrisonerPerGuard))
		return false;
	
	int iGuardsNeeded = RoundToCeil(fNumPrisonersPerGuard - GetConVarFloat(gc_fPrisonerPerGuard));
	if(iGuardsNeeded < 1)
		iGuardsNeeded = 1;
	
	int iQueueSize = GetArraySize(g_aGuardQueue);
	if(iGuardsNeeded > iQueueSize)
		return true;
	
	for(int i; i < iGuardsNeeded; i++)
	{
		if (!IsValidClient(i, true, true))
			continue;
		
		if(client == GetArrayCell(g_aGuardQueue, i))
			return true;
	}
	
	return false;
}


stock int GetClientPendingTeam(int client)
{
	return GetEntProp(client, Prop_Send, "m_iPendingTeamNum");
}


stock void SetClientPendingTeam(int client, int team)
{
	SetEntProp(client, Prop_Send, "m_iPendingTeamNum", team);
	// MinusDeath(client);
}