/*
 * MyJailbreak - Warden - Friendly Fire Module.
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
ConVar gc_bFF;
ConVar gc_sCustomCommandFF;


//Extern Convars
ConVar g_bFF;


//Start
public void FriendlyFire_OnPluginStart()
{
	//Client commands
	RegConsoleCmd("sm_setff", Command_FriendlyFire, "Allows player to see the state and the Warden to toggle friendly fire");
	
	//AutoExecConfig
	gc_bFF = AutoExecConfig_CreateConVar("sm_warden_ff", "1", "0 - disabled, 1 - enable switch ff for T ", _, true,  0.0, true, 1.0);
	gc_sCustomCommandFF = AutoExecConfig_CreateConVar("sm_warden_cmds_ff", "isff,friendlyfire", "Set your custom chat commands for set/see friendly fire(!setff (no 'sm_'/'!')(seperate with comma ',')(max. 12 commands)");
	
	//Hooks
	HookEvent("round_end", FriendlyFire_Event_RoundEnd);
	
	//FindConVar
	g_bFF = FindConVar("mp_teammates_are_enemies");
}


/******************************************************************************
                   COMMANDS
******************************************************************************/


public Action Command_FriendlyFire(int client, int args)
{
	if (gc_bFF.BoolValue) 
	{
		if (g_bFF.BoolValue) 
		{
			if (IsClientWarden(client))
			{
				SetCvar("mp_teammates_are_enemies", 0);
				g_bFF = FindConVar("mp_teammates_are_enemies");
				CPrintToChatAll("%t %t", "warden_tag", "warden_ffisoff" );
			}else CPrintToChatAll("%t %t", "warden_tag", "warden_ffison" );
			
		}
		else
		{	
			if (IsClientWarden(client))
			{
				SetCvar("mp_teammates_are_enemies", 1);
				g_bFF = FindConVar("mp_teammates_are_enemies");
				CPrintToChatAll("%t %t", "warden_tag", "warden_ffison" );
			}
			else CPrintToChatAll("%t %t", "warden_tag", "warden_ffisoff" );
		}
	}
	return Plugin_Handled;
}


/******************************************************************************
                   EVENTS
******************************************************************************/


public void FriendlyFire_Event_RoundEnd(Event event, const char[] name, bool dontBroadcast)
{
	if(gc_bPlugin.BoolValue)
	{
		if (g_bFF.BoolValue) 
		{
			SetCvar("mp_teammates_are_enemies", 0);
			g_bFF = FindConVar("mp_teammates_are_enemies");
			CPrintToChatAll("%t %t", "warden_tag", "warden_ffisoff" );
		}
	}
}


/******************************************************************************
                   FORWARDS LISTENING
******************************************************************************/


public void FriendlyFire_OnConfigsExecuted()
{
	//Set custom Commands
	int iCount = 0;
	char sCommands[128], sCommandsL[12][32], sCommand[32];
	
	//Friendly fire
	gc_sCustomCommandFF.GetString(sCommands, sizeof(sCommands));
	ReplaceString(sCommands, sizeof(sCommands), " ", "");
	iCount = ExplodeString(sCommands, ",", sCommandsL, sizeof(sCommandsL), sizeof(sCommandsL[]));
	
	for(int i = 0; i < iCount; i++)
	{
		Format(sCommand, sizeof(sCommand), "sm_%s", sCommandsL[i]);
		if(GetCommandFlags(sCommand) == INVALID_FCVAR_FLAGS)  //if command not already exist
			RegConsoleCmd(sCommand, Command_FriendlyFire, "Allows player to see the state and the Warden to toggle friendly fire");
	}
}
