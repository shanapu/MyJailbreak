/*
 * MyJailbreak - Player HUD Plugin.
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
ConVar gc_bPlugin;

//Booleans
g_bEnableHud[MAXPLAYERS+1] = true;

//Strings


//Info
public Plugin myinfo =
{
	name = "MyJailbreak - Player HUD",
	description = "A player HUD to display game informations",
	author = "shanapu",
	version = PLUGIN_VERSION,
	url = URL_LINK
}


//Start
public void OnPluginStart()
{
	// Translation
	LoadTranslations("MyJailbreak.HUD.phrases");
		
	RegConsoleCmd("sm_hud", Command_HUD, "Allows player to toggle the hud display.");
	
	
	//AutoExecConfig
	AutoExecConfig_SetFile("HUD", "MyJailbreak");
	AutoExecConfig_SetCreateFile(true);
	
	AutoExecConfig_CreateConVar("sm_hud_version", PLUGIN_VERSION, "The version of this MyJailbreak SourceMod plugin", FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_DONTRECORD);
	gc_bPlugin = AutoExecConfig_CreateConVar("sm_hud_enable", "1", "0 - disabled, 1 - enable this MyJailbreak SourceMod plugin", _, true,  0.0, true, 1.0);
	
	
	AutoExecConfig_ExecuteFile();
	AutoExecConfig_CleanFile();
	
	
	//Hooks - Events to check for Tag
	HookEvent("player_death", Event_PlayerTeamDeath);
	HookEvent("player_team", Event_PlayerTeamDeath);
}


/******************************************************************************
                   COMMANDS
******************************************************************************/


//Become Warden
public Action Command_HUD(int client, int args)
{
	if(!g_bEnableHud[client])
	{
		g_bEnableHud[client] = true;
		CPrintToChat(client, "%t %t", "hud_tag", "hud_on");
		
	}
	else
	{
		g_bEnableHud[client] = false;
		CPrintToChat(client, "%t %t", "hud_tag", "hud_off");
		
	}
}


/******************************************************************************
                   EVENTS
******************************************************************************/


//Warden change Team
public void Event_PlayerTeamDeath(Event event, const char[] name, bool dontBroadcast)
{
	ShowHUD();
}


/******************************************************************************
                   FORWARDS LISTEN
******************************************************************************/


//Prepare Plugin & modules
public void OnMapStart()
{
	if(gc_bPlugin.BoolValue) CreateTimer(1.0, Timer_ShowHUD, _, TIMER_REPEAT);
}

public void OnClientPutInServer(int client)
{
	g_bEnableHud[client] = true;
}


public int warden_OnWardenCreated(int client)
{
	ShowHUD();
}


public int warden_OnWardenRemoved(int client)
{
	ShowHUD();
}


/******************************************************************************
                   TIMER
******************************************************************************/


public Action Timer_ShowHUD(Handle timer, Handle pack)
{
	ShowHUD();
}


/******************************************************************************
                   FUNCTIONS
******************************************************************************/


public void ShowHUD()
{
	int warden = warden_get(warden);
	int aliveCT = GetAliveTeamCount(CS_TEAM_CT);
	int allCT = GetTeamClientCount(CS_TEAM_CT);
	int aliveT = GetAliveTeamCount(CS_TEAM_T);
	int allT = GetTeamClientCount(CS_TEAM_T);
	
	
	char EventDay[64];
	GetEventDayName(EventDay);
	
	if(gc_bPlugin.BoolValue)
	{
		LoopValidClients(i,false,true)
		{
			if(g_bEnableHud[i])
			{
				if(IsLastGuardRule())
				{
					int lastCT = (GetClientTeam(i) == CS_TEAM_CT);
					
					if(IsEventDayPlanned())
					{
						PrintHintText(i, "<font face='Arial' color='#006699'>%t </font>%N</font>\n<font face='Arial' color='#B980EF'>%t</font> %s\n<font color='#5E97D8'>%t</font> %i/%i\t<font color='#E3AD39'>%t</font> %i/%i\n", "hud_lastCT", lastCT, "hud_planned", EventDay, "hud_guards", aliveCT, allCT, "hud_prisoner", aliveT, allT);
					}
					else
					{
						PrintHintText(i, "<font face='Arial' color='#006699'>%t </font>%N</font>\n<font color='#5E97D8'>%t</font> %i/%i\t<font color='#E3AD39'>%t</font> %i/%i\n", "hud_lastCT", lastCT, "hud_guards", aliveCT, allCT, "hud_prisoner", aliveT, allT);
					}
				}
				else if(IsEventDayRunning())
				{
					PrintHintText(i, "<font face='Arial' color='#B980EF'>%t </font>%s\n<font color='#5E97D8'>%t</font> %i/%i\t<font color='#E3AD39'>%t</font> %i/%i\n", "hud_running", EventDay, "hud_guards", aliveCT, allCT, "hud_prisoner", aliveT, allT);
				}
				else if(warden == -1)
				{
					if(IsEventDayPlanned())
					{
						PrintHintText(i, "<font face='Arial' color='#006699'>%t </font><font face='Arial' color='#FE4040'>%t</font>\n<font color='#B980EF'>%t</font> %s\n<font color='#5E97D8'>%t</font> %i/%i\t<font color='#E3AD39'>%t</font> %i/%i", "hud_warden", "hud_nowarden", "hud_planned", EventDay, "hud_guards", aliveCT, allCT, "hud_prisoner", aliveT, allT);
					}
					else
					{
						PrintHintText(i, "<font face='Arial' color='#006699'>%t </font><font face='Arial' color='#FE4040'>%t</font>\n<font color='#5E97D8'>%t</font> %i/%i\t<font color='#E3AD39'>%t</font> %i/%i\n", "hud_warden", "hud_nowarden", "hud_guards", aliveCT, allCT, "hud_prisoner", aliveT, allT);
					}
				}
				else
				{
					if(IsEventDayPlanned())
					{
						PrintHintText(i, "<font face='Arial' color='#006699'>%t </font>%N\n<font face='Arial' color='#B980EF'>%t</font> %s\n<font color='#5E97D8'>%t</font> %i/%i\t<font color='#E3AD39'>%t</font> %i/%i\n", "hud_warden", warden, "hud_planned", EventDay, "hud_guards", aliveCT, allCT, "hud_prisoner", aliveT, allT);
					}
					else
					{
						PrintHintText(i, "<font face='Arial' color='#006699'>%t </font>%N\n<font color='#5E97D8'>%t</font> %i/%i\t<font color='#E3AD39'>%t</font> %i/%i\n", "hud_warden", warden, "hud_guards", aliveCT, allCT, "hud_prisoner", aliveT, allT);
					}
				}
			}
		}
	}
}

