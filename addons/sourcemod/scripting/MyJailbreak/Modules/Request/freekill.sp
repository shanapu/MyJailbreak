/*
 * MyJailbreak - Request Freekill Module.
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
#include <myjailbreak>


//Compiler Options
#pragma semicolon 1
#pragma newdecls required


//Console Variables
ConVar gc_sCustomCommandFreekill;
ConVar gc_bFreeKill;
ConVar gc_iFreeKillLimit;
ConVar gc_bFreeKillRespawn;
ConVar gc_bFreeKillKill;
ConVar gc_bFreeKillFreeDay;
ConVar gc_bFreeKillSwap;
ConVar gc_bFreeKillFreeDayVictim;
ConVar gc_bReportAdmin;
ConVar gc_bReportWarden;
ConVar gc_bRespawnCellClosed;
ConVar gc_sAdminFlag;


//Booleans
bool g_bFreeKilled[MAXPLAYERS+1];


//Integers
int g_iFreeKillCounter[MAXPLAYERS+1];


//Strings
char g_sCustomCommandFreekill[64];
char g_sFreeKillLogFile[PLATFORM_MAX_PATH];
char g_sAdminFlag[32];


//Start
public void Freekill_OnPluginStart()
{
	//Client commands
	RegConsoleCmd("sm_freekill", Command_Freekill, "Allows a Dead Terrorist report a Freekill");
	
	
	//AutoExecConfig
	gc_bFreeKill = AutoExecConfig_CreateConVar("sm_freekill_enable", "1", "0 - disabled, 1 - enable freekill report");
	gc_sCustomCommandFreekill = AutoExecConfig_CreateConVar("sm_freekill_cmd", "fk", "Set your custom chat command for freekill. no need for sm_ or !");
	gc_iFreeKillLimit = AutoExecConfig_CreateConVar("sm_freekill_limit", "2", "Сount how many times you can report a freekill");
	gc_bFreeKillRespawn = AutoExecConfig_CreateConVar("sm_freekill_respawn", "1", "0 - disabled, 1 - Allow the warden to respawn a Freekill victim");
	gc_bRespawnCellClosed = AutoExecConfig_CreateConVar("sm_freekill_respawn_cell", "1", "0 - cells are still open, 1 - cells will close on respawn in cell");
	gc_bFreeKillKill = AutoExecConfig_CreateConVar("sm_freekill_kill", "1", "0 - disabled, 1 - Allow the warden to Kill a Freekiller");
	gc_bFreeKillFreeDay = AutoExecConfig_CreateConVar("sm_freekill_freeday", "1", "0 - disabled, 1 - Allow the warden to set a freeday next round as pardon for all player");
	gc_bFreeKillFreeDayVictim= AutoExecConfig_CreateConVar("sm_freekill_freeday_victim", "1", "0 - disabled, 1 - Allow the warden to set a personal freeday next round as pardon for the victim");
	gc_bFreeKillSwap = AutoExecConfig_CreateConVar("sm_freekill_swap", "1", "0 - disabled, 1 - Allow the warden to swap a freekiller to terrorist");
	gc_bReportAdmin = AutoExecConfig_CreateConVar("sm_freekill_admin", "1", "0 - disabled, 1 - Report will be send to admins - if there is no admin its send to warden");
	gc_sAdminFlag = AutoExecConfig_CreateConVar("sm_freekill_flag", "g", "Set flag for admin/vip get reported freekills to decide.");
	gc_bReportWarden = AutoExecConfig_CreateConVar("sm_freekill_warden", "1", "0 - disabled, 1 - Report will be send to Warden if there is no admin");
	
	
	//Hooks 
	HookEvent("round_start", Freekill_Event_RoundStart);
	HookEvent("player_death", Freekill_Event_PlayerDeath);
	HookConVarChange(gc_sCustomCommandFreekill, Freekill_OnSettingChanged);
	HookConVarChange(gc_sAdminFlag, Freekill_OnSettingChanged);
	
	
	//FindConVar
	gc_sCustomCommandFreekill.GetString(g_sCustomCommandFreekill , sizeof(g_sCustomCommandFreekill));
	gc_sAdminFlag.GetString(g_sAdminFlag , sizeof(g_sAdminFlag));
	
	SetLogFile(g_sFreeKillLogFile, "Freekills");
}


public int Freekill_OnSettingChanged(Handle convar, const char[] oldValue, const char[] newValue)
{
	if(convar == gc_sAdminFlag)
	{
		strcopy(g_sAdminFlag, sizeof(g_sAdminFlag), newValue);
	}
	
	else if(convar == gc_sCustomCommandFreekill)
	{
		strcopy(g_sCustomCommandFreekill, sizeof(g_sCustomCommandFreekill), newValue);
		char sBufferCMD[64];
		Format(sBufferCMD, sizeof(sBufferCMD), "sm_%s", g_sCustomCommandFreekill);
		if(GetCommandFlags(sBufferCMD) == INVALID_FCVAR_FLAGS)
			RegConsoleCmd(sBufferCMD, Command_Freekill, "Allows a dead terrorist to report a freekill");
	}
}


/******************************************************************************
                   COMMANDS
******************************************************************************/


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
					if(IsValidClient(g_iKilledBy[client], true, true) && IsValidClient(client, true, true))
					{
						if (g_iFreeKillCounter[client] < gc_iFreeKillLimit.IntValue)
						{
							IsRequest = true;
							RequestTimer = CreateTimer (20.0, IsRequestTimer);
							g_bFreeKilled[client] = true;
							
							
							int a = GetRandomAdmin();
							if ((a != -1) && gc_bReportAdmin.BoolValue)
							{
								g_iFreeKillCounter[client]++;
								FreeKillAcceptMenu(a);
								CPrintToChatAll("%t %t", "request_tag", "request_freekill", client, g_iKilledBy[client], a);
								if(ActiveLogging()) LogToFileEx(g_sFreeKillLogFile, "Player %L claiming %L freekilled him. Reported to admin %L", client, g_iKilledBy[client], a);
							}
							else LoopValidClients(i, false, true) if (warden_iswarden(i) && gc_bReportWarden.BoolValue)
							{
								g_iFreeKillCounter[client]++;
								FreeKillAcceptMenu(i);
								CPrintToChatAll("%t %t", "request_tag", "request_freekill", client, g_iKilledBy[client], i);
								if(ActiveLogging()) LogToFileEx(g_sFreeKillLogFile, "Player %L claiming %L freekilled him. Reported to warden %L", client, g_iKilledBy[client], i);
							}
						}
						else CPrintToChat(client, "%t %t", "request_tag", "request_freekilltimes", gc_iFreeKillLimit.IntValue);
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


/******************************************************************************
                   EVENTS
******************************************************************************/

public Action Freekill_Event_RoundStart(Handle event, char [] name, bool dontBroadcast)
{
	LoopClients(client)
	{
		g_iFreeKillCounter[client] = 0;
		g_bFreeKilled[client] = false;
	}
}


public Action Freekill_Event_PlayerDeath(Event event, const char[] name, bool dontBroadcast) 
{
	int victim = GetClientOfUserId(GetEventInt(event, "userid")); // Get the dead clients id
	
	if (IsValidClient(victim, false, true)) GetClientAbsOrigin(victim, DeathOrigin[victim]);
}


/******************************************************************************
                   FORWARDS LISTENING
******************************************************************************/


public void Freekill_OnMapStart()
{
	if(gc_bSounds.BoolValue) PrecacheSoundAnyDownload(g_sSoundCapitulationPath);
}


public void Freekill_OnConfigsExecuted()
{
	char sBufferCMDCapitulation[64];
	
	Format(sBufferCMDCapitulation, sizeof(sBufferCMDCapitulation), "sm_%s", g_sCustomCommandCapitulation);
	if(GetCommandFlags(sBufferCMDCapitulation) == INVALID_FCVAR_FLAGS)
		RegConsoleCmd(sBufferCMDCapitulation, Command_Capitulation, "Allows a rebeling terrorist to request a capitulate");
}


public void Freekill_OnClientPutInServer(int client)
{
	g_iFreeKillCounter[client] = 0;
}



/******************************************************************************
                   MENUS
******************************************************************************/


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
			Format(info, sizeof(info), "%T", "request_freedayvictim", client);
			if(gc_bFreeKillFreeDayVictim.BoolValue) menu1.AddItem("5", info);
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
			char info[255];
			
			Menu menu1 = CreateMenu(RespawnHandler);
			Format(info, sizeof(info), "%T", "request_handlerespawn", client);
			menu1.SetTitle(info);
			Format(info, sizeof(info), "%T", "request_respawnbody", client);
			menu1.AddItem("1", info);
			Format(info, sizeof(info), "%T", "request_respawncell", client);
			menu1.AddItem("2", info);
			Format(info, sizeof(info), "%T", "request_respawnwarden", client);
			if(warden_exist()) menu1.AddItem("3", info);
			menu1.Display(client, MENU_TIME_FOREVER);
		}
		if(choice == 2) //kill freekiller
		{
			LoopClients(i) if(g_bFreeKilled[i])
			{
				g_bFreeKilled[i] = false;
				ForcePlayerSuicide(g_iKilledBy[i]);
				if(ActiveLogging()) LogToFileEx(g_sFreeKillLogFile, "Warden/Admin %L accept freekill request of %L  and killed %L", client, i, g_iKilledBy[i]);
				CPrintToChat(g_iKilledBy[i], "%t %t", "request_tag", "request_killbcfreekill");
				CPrintToChatAll("%t %t", "warden_tag", "request_killbcfreekillall", i);
			}
		}
		if(choice == 3) //freeday
		{
			LoopClients(i) if(g_bFreeKilled[i])
			{
				g_bFreeKilled[i] = false;
				if(ActiveLogging()) LogToFileEx(g_sFreeKillLogFile, "Warden/Admin %L accept freekill request of %L give a freeday", client, i);
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
				if(ActiveLogging()) LogToFileEx(g_sFreeKillLogFile, "Warden/Admin %L accept freekill request of %L  and swaped %L to T", client, i, g_iKilledBy[i]);
				CPrintToChatAll("%t %t", "warden_tag", "request_swapbcfreekillall", i);
			}
		}
		if(choice == 5) //freeday to victim
		{
			LoopClients(i) if(g_bFreeKilled[i])
			{
				g_bHaveFreeDay[i] = true;
				g_bFreeKilled[i] = false;
				CPrintToChat(i, "%t %t", "request_tag", "request_freedayforyou");
				if(ActiveLogging()) LogToFileEx(g_sFreeKillLogFile, "Warden/Admin %L accept freekill request of %L gave him a personal freeday", client, i);
				CPrintToChatAll("%t %t", "warden_tag", "request_personalfreeday", i);
			}
		}
	}
	else if (action == MenuAction_End)
	{
		delete menu;
	}
}

public int RespawnHandler(Menu menu, MenuAction action, int client, int Position)
{
	if(action == MenuAction_Select)
	{
		char Item[11];
		menu.GetItem(Position,Item,sizeof(Item));
		int choice = StringToInt(Item);
		
		IsRequest = false;
		RequestTimer = null;
		
		if(choice == 1) //respawnbody
		{
			LoopClients(i) if(g_bFreeKilled[i])
			{
				g_bFreeKilled[i] = false;
				CS_RespawnPlayer(i);
				
				TeleportEntity(i, DeathOrigin[i], NULL_VECTOR, NULL_VECTOR);
				
				if(ActiveLogging()) LogToFileEx(g_sFreeKillLogFile, "Warden/Admin %L accept freekill request and respawned %L on his body", client, i);
				CPrintToChat(i, "%t %t", "request_tag", "request_respawned");
				CPrintToChatAll("%t %t", "warden_tag", "request_respawnedall", i);
			}
		}
		if(choice == 2) //respawncell
		{
			LoopClients(i) if(g_bFreeKilled[i])
			{
				g_bFreeKilled[i] = false;
				
				if(gc_bRespawnCellClosed.BoolValue) SJD_CloseDoors();
				CS_RespawnPlayer(i);
				
				if(ActiveLogging()) LogToFileEx(g_sFreeKillLogFile, "Warden/Admin %L accept freekill request and respawned %L in cell", client, i);
				CPrintToChat(i, "%t %t", "request_tag", "request_respawned");
				CPrintToChatAll("%t %t", "warden_tag", "request_respawnedall", i);
			}
		}
		if(choice == 3) //respawnwarden
		{
			LoopClients(i) if(g_bFreeKilled[i])
			{
				g_bFreeKilled[i] = false;
				CS_RespawnPlayer(i);
				
				int warden = warden_get(warden);
				
				float origin[3];
				GetClientAbsOrigin(warden, origin);
				float location[3];
				GetClientEyePosition(warden, location);
				float ang[3];
				GetClientEyeAngles(warden, ang);
				float location2[3];
				location2[0] = (location[0]+(100*((Cosine(DegToRad(ang[1]))) * (Cosine(DegToRad(ang[0]))))));
				location2[1] = (location[1]+(100*((Sine(DegToRad(ang[1]))) * (Cosine(DegToRad(ang[0]))))));
				ang[0] -= (2*ang[0]);
				location2[2] = origin[2] += 5.0;
				
				TeleportEntity(i, location2, NULL_VECTOR, NULL_VECTOR);
				
				if(ActiveLogging()) LogToFileEx(g_sFreeKillLogFile, "Warden/Admin %L accept freekill request and respawned %L in front of warden", client, i);
				CPrintToChat(i, "%t %t", "request_tag", "request_respawned");
				CPrintToChatAll("%t %t", "warden_tag", "request_respawnedall", i);
				CPrintToChatAll("debug warden is %N", warden);
			}
		}
	}
}


/******************************************************************************
                   STOCKS
******************************************************************************/


stock int GetRandomAdmin() 
{
	int[] admins = new int[MaxClients];
	int adminsCount;
	LoopClients(i)
	{
		if (CheckVipFlag(i,g_sAdminFlag))
		{
			admins[adminsCount++] = i;
		}
	}
	return (adminsCount == 0) ? -1 : admins[GetRandomInt(0, adminsCount-1)];
}
