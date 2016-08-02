/*
 * MyJailbreak - Warden - Counter Module.
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
ConVar gc_bCounter;
ConVar gc_iCounterMode;
ConVar gc_fRadius;


//Boolean
bool g_bCounted[MAXPLAYERS+1];


//Floats
float g_fDistance[MAXPLAYERS+1];


//Start
public void Counter_OnPluginStart()
{
	//Client commands
	RegConsoleCmd("sm_count", Command_Counter, "Allows a warden to count all terrorists in radius");
	
	
	//AutoExecConfig
	gc_bCounter = AutoExecConfig_CreateConVar("sm_warden_counter", "1", "0 - disabled, 1 - Allow the warden count player in radius", _, true, 0.0, true, 1.0);
	gc_fRadius = AutoExecConfig_CreateConVar("sm_warden_counter_radius", "30.0", "Radius in meter to count prisoners inside", _, true, 1.0);
	gc_iCounterMode = AutoExecConfig_CreateConVar("sm_warden_counter_mode", "7", "1 - Show prisoner count in chat / 2 - Show prisoner count in HUD / 3 - Show prisoner count in chat & HUD / 4 - Show names in Menu / 5 - Show prisoner count in chat & show names in Menu / 6 - Show prisoner count in HUD & show names in Menu / 7 - Show prisoner count in chat & HUD & show names in Menu", _, true, 1.0, true, 7.0);
	
}


/******************************************************************************
                   COMMANDS
******************************************************************************/


public Action Command_Counter(int client, any args)
{
	if(gc_bPlugin.BoolValue)	
	{
		if(IsValidClient(client, false, false) && IsClientWarden(client) && gc_bCounter.BoolValue)
		{
			float wardenOrigin[3];
			GetClientAbsOrigin(client, wardenOrigin);
			
			int counter = 0;
			
			LoopValidClients(i,true,false)
			{
				if(GetClientTeam(i) == CS_TEAM_T)
				{
					g_bCounted[i] = false;
					g_fDistance[i] = 0.0;
					
					float clientOrigin[3];
					GetClientAbsOrigin(i, clientOrigin);
					
					float distance = GetVectorDistance(clientOrigin, wardenOrigin, false);
					
					if(distance <= (gc_fRadius.FloatValue/0.01905)) //meter to units
					{
						counter++;
						g_bCounted[i] = true;
						g_fDistance[i] = distance;
					}
				}
			}
			
			if((gc_iCounterMode.IntValue == 1 ) || (gc_iCounterMode.IntValue == 3 ) || (gc_iCounterMode.IntValue == 5 ) || (gc_iCounterMode.IntValue == 7)) CPrintToChat(client, "%t %t", "warden_tag", "warden_counter", counter);
			if((gc_iCounterMode.IntValue == 2 ) || (gc_iCounterMode.IntValue == 3 ) || (gc_iCounterMode.IntValue == 6 ) || (gc_iCounterMode.IntValue == 7)) PrintCenterText(client, "%t", "warden_counter", counter);
			if((gc_iCounterMode.IntValue == 4 ) || (gc_iCounterMode.IntValue == 5 ) || (gc_iCounterMode.IntValue == 6 ) || (gc_iCounterMode.IntValue == 7))
			{
				char info1[255];
				Handle CounterPanel = CreatePanel();
				Format(info1, sizeof(info1), "%T", "warden_info_counter", client);
				SetPanelTitle(CounterPanel, info1);
				DrawPanelText(CounterPanel, "-----------------------------------");
				DrawPanelText(CounterPanel, "                                   ");
				LoopValidClients(i,true,false)
				{
					if(g_bCounted[i])
					{
						int userdistance = RoundToNearest(Math_UnitsToMeters(g_fDistance[i]));
						char userid[11];
						char username[MAX_NAME_LENGTH];
						IntToString(GetClientUserId(i), userid, sizeof(userid));
						Format(username, sizeof(username), "%N (%im)", i, userdistance);
						DrawPanelText(CounterPanel,username);
					}
				}
				DrawPanelText(CounterPanel, "                                   ");
				DrawPanelText(CounterPanel, "-----------------------------------");
				Format(info1, sizeof(info1), "%T", "warden_close", client);
				DrawPanelItem(CounterPanel, info1); 
				SendPanelToClient(CounterPanel, client, Handler_NullCancel, 23);
			}
		}
		else CPrintToChat(client, "%t %t", "warden_tag", "warden_notwarden");
	}
	return Plugin_Handled;
}



