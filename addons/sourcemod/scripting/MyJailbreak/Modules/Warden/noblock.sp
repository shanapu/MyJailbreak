/*
 * MyJailbreak - Warden - No Block Module.
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
ConVar gc_bNoBlock;
ConVar g_bNoBlockSolid;
ConVar gc_bNoBlockMode;


//Booleans
bool g_bNoBlock = true;


//Integers
int g_iCollisionOffset;


//Start
public void NoBlock_OnPluginStart()
{
	//Client commands
	RegConsoleCmd("sm_noblock", Command_ToggleNoBlock, "Allows the Warden to toggle no block"); 
	
	
	//AutoExecConfig
	gc_bNoBlock = AutoExecConfig_CreateConVar("sm_warden_noblock", "1", "0 - disabled, 1 - enable noblock toggle for warden", _, true,  0.0, true, 1.0);
	gc_bNoBlockMode = AutoExecConfig_CreateConVar("sm_warden_noblock_mode", "1", "0 - collision only between CT & T, 1 - collision within a team.", _, true,  0.0, true, 1.0);
	
	
	//Hooks
	HookEvent("round_end", NoBlock_RoundEnd);
	
	
	//FindConVar
	g_iCollisionOffset = FindSendPropInfo("CBaseEntity", "m_CollisionGroup");
	g_bNoBlockSolid = FindConVar("mp_solid_teammates");
}


/******************************************************************************
                   COMMANDS
******************************************************************************/


public Action Command_ToggleNoBlock(int client, int args)
{
	if (gc_bNoBlock.BoolValue) 
	{
		if (IsClientWarden(client))
		{
			if (!g_bNoBlock) 
			{
				g_bNoBlock = true;
				CPrintToChatAll("%t %t", "warden_tag" , "warden_noblockon");
				LoopValidClients(i, true, true)
				{
					SetEntData(i, g_iCollisionOffset, 2, 4, true);
					if(gc_bNoBlockMode.BoolValue) SetCvar("mp_solid_teammates", 0);
				}
			}
			else
			{
				g_bNoBlock = false;
				CPrintToChatAll("%t %t", "warden_tag" , "warden_noblockoff");
				LoopValidClients(i, true, true)
				{
					SetEntData(i, g_iCollisionOffset, 5, 4, true);
					if(gc_bNoBlockMode.BoolValue) SetCvar("mp_solid_teammates", 1);
				}
			}
		}
		else CPrintToChat(client, "%t %t", "warden_tag" , "warden_notwarden");
	}
}


/******************************************************************************
                   EVENTS
******************************************************************************/


public void NoBlock_RoundEnd(Event event, const char[] name, bool dontBroadcast)
{
	SetCvar("mp_solid_teammates", g_bNoBlockSolid.BoolValue);
}