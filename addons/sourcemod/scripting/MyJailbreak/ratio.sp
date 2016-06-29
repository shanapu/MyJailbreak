//Includes
#include <sourcemod>
#include <sdktools>
#include <clientprefs>
#include <colors>
#include <cstrike>

#include <autoexecconfig>
#include <myjailbreak>

//Compiler Options
#pragma semicolon 1
#pragma newdecls required

//ConVars
//ConVar gc_bPlugin;
ConVar gc_iPrisonerPerGuard;
ConVar gc_sCustomCommand;
ConVar gc_sAdminFlag;
ConVar gc_bAdsVIP;
ConVar gc_bVIPQueue;

//Handles
Handle g_aGuardQueue;
Handle g_sCookieCTBan;
Handle ViewQueueMenu;

//Strings
char g_sRestrictedSound[32] = "buttons/button11.wav";
char g_sCustomCommand[32];
char g_sAdminFlag[32];

public Plugin myinfo = {
	name = "MyJailbreak - Ratio",
	author = "shanapu, Addicted",
	description = "Jailbreak team balance / ratio plugin",
	version = PLUGIN_VERSION,
	url = URL_LINK
};

public void OnPluginStart()
{
	//Translation
	LoadTranslations("MyJailbreak.Ratio.phrases");
	LoadTranslations("MyJailbreak.Warden.phrases");
	
	//Client commands
	RegConsoleCmd("sm_guard", OnGuardQueue,"Allows the prisoners to queue to CT");
	RegConsoleCmd("sm_viewqueue", ViewGuardQueue,"Allows a player to show queue to CT");
	RegConsoleCmd("sm_vq", ViewGuardQueue,"Allows a player to show queue to CT");
	RegConsoleCmd("sm_leavequeue", LeaveQueue,"Allows a player to leave queue to CT");
	RegConsoleCmd("sm_lq", LeaveQueue,"Allows a player to leave queue to CT");
	
	//Admin commands
	RegAdminCmd("sm_removequeue", RemoveFromQueue, ADMFLAG_GENERIC,"Allows the admin to remove player from queue to CT");
	RegAdminCmd("sm_rq", RemoveFromQueue, ADMFLAG_GENERIC,"Allows the admin to remove player from queue to CT");
	
	//AutoExecConfig
	AutoExecConfig_SetFile("Ratio", "MyJailbreak");
	AutoExecConfig_SetCreateFile(true);
	
	AutoExecConfig_CreateConVar("sm_ratio_version", PLUGIN_VERSION, "The version of this MyJailbreak SourceMod plugin", FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_DONTRECORD);
//	gc_bPlugin = AutoExecConfig_CreateConVar("sm_ratio_enable", "1", "0 - disabled, 1 - enable this MyJailbreak SourceMod plugin", _, true,  0.0, true, 1.0);
	gc_sCustomCommand = AutoExecConfig_CreateConVar("sm_ratio_cmd", "gua", "Set your custom chat command for become guard. no need for sm_ or !");
	gc_iPrisonerPerGuard = AutoExecConfig_CreateConVar("sm_ratio_T_per_CT", "2", "How many prisoners for each guard.", _, true, 1.0);
	gc_bVIPQueue = AutoExecConfig_CreateConVar("sm_ratio_flag", "1", "0 - disabled, 1 - enable VIPs moved to front of queue", _, true,  0.0, true, 1.0);
	gc_sAdminFlag = AutoExecConfig_CreateConVar("sm_ratio_vipflag", "a", "Set the flag for VIP");
	gc_bAdsVIP = AutoExecConfig_CreateConVar("sm_ratio_adsvip", "1", "0 - disabled, 1 - enable adverstiment for 'VIPs moved to front of queue' when player types !quard ", _, true,  0.0, true, 1.0);
	
	AutoExecConfig_ExecuteFile();
	AutoExecConfig_CleanFile();
	
	//Hooks
	AddCommandListener(OnJoinTeam, "jointeam");
	HookEvent("player_team", Event_PlayerTeam_Post, EventHookMode_Post);
	HookEvent("round_end", Event_RoundEnd_Post, EventHookMode_Post);
	HookEvent("player_spawn", Event_OnPlayerSpawn, EventHookMode_Post);
	HookConVarChange(gc_sCustomCommand, OnSettingChanged);
	
	gc_sAdminFlag.GetString(g_sAdminFlag,sizeof(g_sAdminFlag));
	
	g_aGuardQueue = CreateArray();
	
	if((g_sCookieCTBan = FindClientCookie("Banned_From_CT")) == INVALID_HANDLE)
		g_sCookieCTBan = RegClientCookie("Banned_From_CT", "Tells if you are restricted from joining the CT team", CookieAccess_Protected);
}

public int OnSettingChanged(Handle convar, const char[] oldValue, const char[] newValue)
{
	if(convar == gc_sCustomCommand)
	{
		strcopy(g_sCustomCommand, sizeof(g_sCustomCommand), newValue);
		char sBufferCMD[64];
		Format(sBufferCMD, sizeof(sBufferCMD), "sm_%s", g_sCustomCommand);
		if(GetCommandFlags(sBufferCMD) == INVALID_FCVAR_FLAGS)
			RegConsoleCmd(sBufferCMD, OnGuardQueue, "Allows the prisoners to queue to CT");
	}
}

public void OnConfigsExecuted()
{
	Handle hConVar = FindConVar("mp_force_pick_time");
	if(hConVar == INVALID_HANDLE)
		return;
	
	HookConVarChange(hConVar, OnForcePickTimeChanged);
	SetConVarInt(hConVar, 999999);
	
	char sBufferCMD[64];
	Format(sBufferCMD, sizeof(sBufferCMD), "sm_%s", g_sCustomCommand);
	if(GetCommandFlags(sBufferCMD) == INVALID_FCVAR_FLAGS)
		RegConsoleCmd(sBufferCMD, OnGuardQueue, "Allows the prisoners to queue to CT");
}

public void OnForcePickTimeChanged(Handle hConVar, const char[] szOldValue, const char[] szNewValue)
{
	SetConVarInt(hConVar, 999999);
}

public void OnClientDisconnect_Post(int client)
{
	RemovePlayerFromGuardQueue(client);
}

public Action Event_OnPlayerSpawn(Event event, const char[] name, bool bDontBroadcast) 
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	if (GetClientTeam(client) != 3) 
		return Plugin_Continue;
		
	if (!IsValidClient(client, true, false))
		return Plugin_Continue;
		
	char sData[2];
	GetClientCookie(client, g_sCookieCTBan, sData, sizeof(sData));
	
	if(sData[0] == '1')
	{
		CPrintToChat(client, "%t %t", "ratio_tag" , "ratio_banned");
		PrintHintText(client, "%t", "ratio_banned");
		CreateTimer(5.0, SlayPlayer, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
		return Plugin_Continue;
	}
	
	return Plugin_Continue;
}

public Action SlayPlayer(Handle hTimer, any iUserId) 
{
	int client = GetClientOfUserId(iUserId);
	
	if ((IsValidClient(client, false, false)) && (GetClientTeam(client) == CS_TEAM_CT))
	{
		ForcePlayerSuicide(client);
		ChangeClientTeam(client, CS_TEAM_T);
		CS_RespawnPlayer(client);
	}
	return Plugin_Stop;
}

public void Event_PlayerTeam_Post(Handle hEvent, const char[] szName, bool bDontBroadcast)
{
	if(GetEventInt(hEvent, "team") != CS_TEAM_CT)
		return;
	
	int client = GetClientOfUserId(GetEventInt(hEvent, "userid"));
	RemovePlayerFromGuardQueue(client);
}

public Action Event_RoundEnd_Post(Handle hEvent, const char[] szName, bool bDontBroadcast)
{
	FixTeamRatio();
}

public Action OnJoinTeam(int client, const char[] szCommand, int iArgCount)
{
	if(iArgCount < 1)
		return Plugin_Continue;
	
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
		int iQueueSize = GetArraySize(g_aGuardQueue);
		ClientCommand(client, "play %s", g_sRestrictedSound);
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
				CPrintToChat(client, "%t %t", "ratio_tag" , "ratio_fullqueue", iIndex + 1);
				return Plugin_Handled;
			}
			else
			{
				iIndex = PushArrayCell(g_aGuardQueue, client);
				
				CPrintToChat(client, "%t %t", "ratio_tag" , "ratio_fullqueue", iIndex + 1);
				if(gc_bAdsVIP.BoolValue && gc_bVIPQueue.BoolValue) CPrintToChat(client, "%t %t", "ratio_tag" , "ratio_advip");
				
				return Plugin_Handled;
			}
		}
		else
		{
			CPrintToChat(client, "%t %t", "ratio_tag" , "ratio_fullqueue", iIndex + 1);
			if(gc_bAdsVIP.BoolValue && gc_bVIPQueue.BoolValue && !CheckVipFlag(client, g_sAdminFlag)) CPrintToChat(client, "%t %t", "ratio_tag" , "ratio_advip");
			return Plugin_Handled;
		}
	}
	
	return Plugin_Continue;
}

public Action LeaveQueue(int client, int iArgNum)
{
	int iIndex = FindValueInArray(g_aGuardQueue, client);
	
	if(iIndex == -1)
	{
		CPrintToChat(client, "%t %t", "ratio_tag" , "ratio_notonqueue");
		return Plugin_Handled;
	}
	else
	{
		RemovePlayerFromGuardQueue(client);
		CPrintToChat(client, "%t %t", "ratio_tag" , "ratio_leavedqueue");
		return Plugin_Handled;
	}
}

public Action ViewGuardQueue(int client, int args)
{
	if(!IsValidClient(client, true, true))
		return Plugin_Handled;

	if(GetArraySize(g_aGuardQueue) < 1)
	{
		CPrintToChat(client, "%t %t", "ratio_tag" , "ratio_empty");
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
	SendPanelToClient(ViewQueueMenu, client, NullHandler, 12);
	
	return Plugin_Handled;
}

public Action RemoveFromQueue(int client, int args)
{
	if(!IsValidClient(client, true, true))
		return Plugin_Handled;

	if(GetArraySize(g_aGuardQueue) < 1)
	{
		CPrintToChat(client, "%t %t", "ratio_tag" , "ratio_empty");
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

public Action OnGuardQueue(int client, int iArgNum)
{
	if(!IsValidClient(client, true, true))
	{
		return Plugin_Handled;
	}
	
	if(GetClientTeam(client) != CS_TEAM_T)
	{
		ClientCommand(client, "play %s", g_sRestrictedSound);
		CPrintToChat(client, "%t %t", "ratio_tag" , "ratio_noct");
		return Plugin_Handled;
	}
	
	char szCookie[2];
	GetClientCookie(client, g_sCookieCTBan, szCookie, sizeof(szCookie));
	if(szCookie[0] == '1')
	{
		ClientCommand(client, "play %s", g_sRestrictedSound);
		CPrintToChat(client, "%t %t", "ratio_tag" , "ratio_banned");
		FakeClientCommand(client, "sm_isbanned @me");
		return Plugin_Handled;
	}
	
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
			return Plugin_Handled;
		}
		else
		{
			iIndex = PushArrayCell(g_aGuardQueue, client);
			
			CPrintToChat(client, "%t %t", "ratio_tag" , "ratio_number", iIndex + 1);
			if(gc_bAdsVIP.BoolValue && gc_bVIPQueue.BoolValue) CPrintToChat(client, "%t %t", "ratio_tag" , "ratio_advip");
			
			return Plugin_Handled;
		}
	}
	else
	{
		CPrintToChat(client, "%t %t", "ratio_tag" , "ratio_number", iIndex + 1);
		if(gc_bAdsVIP.BoolValue && gc_bVIPQueue.BoolValue && !CheckVipFlag(client, g_sAdminFlag)) CPrintToChat(client, "%t %t", "ratio_tag" , "ratio_advip");
	}
	return Plugin_Continue;
}

stock bool RemovePlayerFromGuardQueue(int client)
{
	int iIndex = FindValueInArray(g_aGuardQueue, client);
	if(iIndex == -1)
		return;
	
	RemoveFromArray(g_aGuardQueue, iIndex);
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

	if(iNumGuards <= RoundToFloor(float(iNumPrisoners) / GetConVarFloat(gc_iPrisonerPerGuard)))
		return false;

	return true;
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

	if(float(iNumPrisoners) / float(iNumGuards) < GetConVarFloat(gc_iPrisonerPerGuard))
		return false;
	
	return true;
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
	if(fNumPrisonersPerGuard < GetConVarFloat(gc_iPrisonerPerGuard))
		return false;
	
	int iGuardsNeeded = RoundToCeil(fNumPrisonersPerGuard - GetConVarFloat(gc_iPrisonerPerGuard));
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

stock void SetClientPendingTeam(int client, int iTeam)
{
	SetEntProp(client, Prop_Send, "m_iPendingTeamNum", iTeam);
}


stock void PrintToChatAndConsole(int client, char [] szFormat, any ...)
{
	char szBuffer[256];
	Format(szBuffer, sizeof(szBuffer), szFormat);
	
	CPrintToChat(client, szBuffer);
	
	CRemoveTags(szBuffer, sizeof(szBuffer)); // Remove color tags for console print
	PrintToConsole(client, szBuffer);
}

stock void PrintToChatAndConsoleAll(char [] szFormat, any ...)
{
	char szBuffer[256];
	Format(szBuffer, sizeof(szBuffer), szFormat);
	
	LoopValidClients(i, false,true)
	{
		CPrintToChat(i, szBuffer);
		
		CRemoveTags(szBuffer, sizeof(szBuffer)); // Remove color tags for console print
		PrintToConsole(i, szBuffer);
	}
} 