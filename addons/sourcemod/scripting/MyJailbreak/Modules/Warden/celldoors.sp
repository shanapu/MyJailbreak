/*
 * MyJailbreak - Warden - Open Cell Doors Module.
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


//Console Variables
ConVar gc_bOpen;
ConVar gc_bOpenTimer;
ConVar gc_hOpenTimer;
ConVar gc_bOpenTimerWarden;
ConVar gc_sCustomCommandOpen;
ConVar gc_sCustomCommandClose;


//Integers
int g_iOpenTimer;


//Handles
Handle OpenCounterTime = null;


//Start
public void CellDoors_OnPluginStart()
{
	//Client commands
	RegConsoleCmd("sm_open", Command_OpenDoors, "Allows the Warden to open the cell doors");
	RegConsoleCmd("sm_close", Command_CloseDoors, "Allows the Warden to close the cell doors");
	
	//AutoExecConfig
	gc_bOpen = AutoExecConfig_CreateConVar("sm_warden_open_enable", "1", "0 - disabled, 1 - warden can open/close cells", _, true,  0.0, true, 1.0);
	gc_sCustomCommandOpen = AutoExecConfig_CreateConVar("sm_warden_cmds_open", "o,unlock,cells", "Set your custom chat commands for open cells(!open (no 'sm_'/'!')(seperate with comma ',')(max. 12 commands)");
	gc_sCustomCommandClose = AutoExecConfig_CreateConVar("sm_warden_cmds_close", "lock,shut", "Set your custom chat commands for close cells(!close (no 'sm_'/'!')(seperate with comma ',')(max. 12 commands)");
	gc_hOpenTimer = AutoExecConfig_CreateConVar("sm_warden_open_time", "60", "Time in seconds for open doors on round start automaticly", _, true, 0.0); 
	gc_bOpenTimer = AutoExecConfig_CreateConVar("sm_warden_open_time_enable", "1", "should doors open automatic 0- no 1 yes", _, true,  0.0, true, 1.0);
	gc_bOpenTimerWarden = AutoExecConfig_CreateConVar("sm_warden_open_time_warden", "1", "should doors open automatic after sm_warden_open_time when there is a warden? needs sm_warden_open_time_enable 1", _, true,  0.0, true, 1.0);
	
	//Hooks
	HookEvent("round_start", CellDoors_Event_RoundStart);
	
	//FindConVar
	g_bNoBlockSolid = FindConVar("mp_solid_teammates");
}


/******************************************************************************
                   COMMANDS
******************************************************************************/


public Action Command_OpenDoors(int client, int args)
{
	if(gc_bPlugin.BoolValue)
	{
		if(gc_bOpen.BoolValue)
		{
			if (IsClientWarden(client))
			{
				if (SJD_IsCurrentMapConfigured())
				{
					CPrintToChatAll("%t %t", "warden_tag" , "warden_dooropen"); 
					SJD_OpenDoors();
					if (OpenCounterTime != null)
					KillTimer(OpenCounterTime);
					OpenCounterTime = null;
				}
				else CReplyToCommand(client, "%t %t", "warden_tag" , "warden_dooropen_unavailable"); 
			}
			else CReplyToCommand(client, "%t %t", "warden_tag" , "warden_notwarden"); 
		}
	}
	return Plugin_Handled;
}


public Action Command_CloseDoors(int client, int args)
{
	if(gc_bPlugin.BoolValue)
	{
		if(gc_bOpen.BoolValue)
		{
			if (IsClientWarden(client))
			{
				if (SJD_IsCurrentMapConfigured()) 
				{
					CPrintToChatAll("%t %t", "warden_tag" , "warden_doorclose"); 
					SJD_CloseDoors();
				}
				else CReplyToCommand(client, "%t %t", "warden_tag" , "warden_doorclose_unavailable"); 
			}
			else CReplyToCommand(client, "%t %t", "warden_tag" , "warden_notwarden"); 
		}
	}
	return Plugin_Handled;
}


/******************************************************************************
                   EVENTS
******************************************************************************/


public void CellDoors_Event_RoundStart(Event event, const char[] name, bool dontBroadcast)
{
	if (OpenCounterTime != null)
		KillTimer(OpenCounterTime);
		
	OpenCounterTime = null;
	
	if(gc_bPlugin.BoolValue)
	{
		if (SJD_IsCurrentMapConfigured())
		{
			g_iOpenTimer = GetConVarInt(gc_hOpenTimer);
			OpenCounterTime = CreateTimer(1.0, Timer_OpenCounter, _, TIMER_REPEAT);
			if (RandomTimer != null)
			KillTimer(RandomTimer);
			
			RandomTimer = null;
		}
		else CPrintToChatAll("%t %t", "warden_tag" , "warden_openauto_unavailable"); 
	}
}


/******************************************************************************
                   FORWARDS LISTENING
******************************************************************************/


public void CellDoors_OnConfigsExecuted()
{
	//Set custom Commands
	int iCount = 0;
	char sCommands[128], sCommandsL[12][32], sCommand[32];
	
	//Open Cell doors
	gc_sCustomCommandOpen.GetString(sCommands, sizeof(sCommands));
	ReplaceString(sCommands, sizeof(sCommands), " ", "");
	iCount = ExplodeString(sCommands, ",", sCommandsL, sizeof(sCommandsL), sizeof(sCommandsL[]));
	
	for(int i = 0; i < iCount; i++)
	{
		Format(sCommand, sizeof(sCommand), "sm_%s", sCommandsL[i]);
		if(GetCommandFlags(sCommand) == INVALID_FCVAR_FLAGS)  //if command not already exist
			RegConsoleCmd(sCommand, Command_OpenDoors, "Allows the Warden to open the cell doors");
	}
	
	//Close Cell doors
	gc_sCustomCommandClose.GetString(sCommands, sizeof(sCommands));
	ReplaceString(sCommands, sizeof(sCommands), " ", "");
	iCount = ExplodeString(sCommands, ",", sCommandsL, sizeof(sCommandsL), sizeof(sCommandsL[]));
	
	for(int i = 0; i < iCount; i++)
	{
		Format(sCommand, sizeof(sCommand), "sm_%s", sCommandsL[i]);
		if(GetCommandFlags(sCommand) == INVALID_FCVAR_FLAGS)  //if command not already exist
			RegConsoleCmd(sCommand, Command_CloseDoors, "Allows the Warden to close the cell doors");
	}
}


/******************************************************************************
                   TIMER
******************************************************************************/


public Action Timer_OpenCounter(Handle timer, Handle pack)
{
	if(gc_bPlugin.BoolValue)
	{
		--g_iOpenTimer;
		if(g_iOpenTimer < 1)
		{
			if(g_iWarden == -1)
			{
				if(gc_bOpenTimer.BoolValue)
				{
					SJD_OpenDoors(); 
					CPrintToChatAll("%t %t", "warden_tag" , "warden_openauto");
					
					if (OpenCounterTime != null)
						KillTimer(OpenCounterTime);
					
					OpenCounterTime = null;
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
				if (OpenCounterTime != null)
					KillTimer(OpenCounterTime);
				OpenCounterTime = null;
			}
		}
	}
}