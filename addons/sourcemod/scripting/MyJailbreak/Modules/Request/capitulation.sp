/*
 * MyJailbreak - Request Capitulation Module.
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
ConVar gc_fCapitulationTime;
ConVar gc_bCapitulation;
ConVar gc_fRebelTime;
ConVar gc_bCapitulationDamage;
ConVar gc_iCapitulationColorRed;
ConVar gc_iCapitulationColorGreen;
ConVar gc_iCapitulationColorBlue;
ConVar gc_sSoundCapitulationPath;
ConVar gc_sCustomCommandCapitulation;


//Booleans
bool g_bCapitulated[MAXPLAYERS+1];


//Handles
Handle CapitulationTimer[MAXPLAYERS+1];
Handle RebelTimer[MAXPLAYERS+1];


//Strings
char g_sSoundCapitulationPath[256];


//Start
public void Capitulation_OnPluginStart()
{
	//Client commands
	RegConsoleCmd("sm_capitulation", Command_Capitulation, "Allows a rebeling terrorist to request a capitulate");
	
	
	//AutoExecConfig
	gc_bCapitulation = AutoExecConfig_CreateConVar("sm_capitulation_enable", "1", "0 - disabled, 1 - enable Capitulation");
	gc_sCustomCommandCapitulation = AutoExecConfig_CreateConVar("sm_capitulation_cmds", "capi, capitulate, pardon, p", "Set your custom chat commands for Capitulation(!capitulation (no 'sm_'/'!')(seperate with comma ', ')(max. 12 commands)");
	gc_fCapitulationTime = AutoExecConfig_CreateConVar("sm_capitulation_timer", "10.0", "Time to decide to accept the capitulation");
	gc_fRebelTime = AutoExecConfig_CreateConVar("sm_capitulation_rebel_timer", "10.0", "Time to give a rebel on not accepted capitulation his knife back");
	gc_bCapitulationDamage = AutoExecConfig_CreateConVar("sm_capitulation_damage", "1", "0 - disabled, 1 - enable Terror make no damage after capitulation");
	gc_iCapitulationColorRed = AutoExecConfig_CreateConVar("sm_capitulation_color_red", "0", "What color to turn the capitulation Terror into (set R, G and B values to 255 to disable) (Rgb): x - red value", _, true, 0.0, true, 255.0);
	gc_iCapitulationColorGreen = AutoExecConfig_CreateConVar("sm_capitulation_color_green", "250", "What color to turn the capitulation Terror into (rGb): x - green value", _, true, 0.0, true, 255.0);
	gc_iCapitulationColorBlue = AutoExecConfig_CreateConVar("sm_capitulation_color_blue", "0", "What color to turn the capitulation Terror into (rgB): x - blue value", _, true, 0.0, true, 255.0);
	gc_sSoundCapitulationPath = AutoExecConfig_CreateConVar("sm_capitulation_sound", "music/MyJailbreak/capitulation.mp3", "Path to the soundfile which should be played for a capitulation.");
	
	
	//Hooks 
	HookEvent("round_start", Capitulation_Event_RoundStart);
	HookConVarChange(gc_sSoundCapitulationPath, Capitulation_OnSettingChanged);
	
	
	//FindConVar
	gc_sSoundCapitulationPath.GetString(g_sSoundCapitulationPath, sizeof(g_sSoundCapitulationPath));
}


public int Capitulation_OnSettingChanged(Handle convar, const char[] oldValue, const char[] newValue)
{
	if (convar == gc_sSoundCapitulationPath)
	{
		strcopy(g_sSoundCapitulationPath, sizeof(g_sSoundCapitulationPath), newValue);
		if (gc_bSounds.BoolValue) PrecacheSoundAnyDownload(g_sSoundCapitulationPath);
	}
}


/******************************************************************************
                   COMMANDS
******************************************************************************/


public Action Command_Capitulation(int client, int args)
{
	if (gc_bPlugin.BoolValue)
	{
		if (gc_bCapitulation.BoolValue)
		{
			if (GetClientTeam(client) == CS_TEAM_T && (IsPlayerAlive(client)))
			{
				if (!(g_bCapitulated[client]))
				{
					if (warden_exist())
					{
						if (!IsRequest)
						{
							IsRequest = true;
							RequestTimer = CreateTimer (gc_fCapitulationTime.FloatValue, Timer_IsRequest);
							g_bCapitulated[client] = true;
							CPrintToChatAll("%t %t", "request_tag", "request_capitulation", client);
							
							float DoubleTime = (gc_fRebelTime.FloatValue * 2);
							RebelTimer[client] = CreateTimer(DoubleTime, Timer_RebelNoAction, client);
						//	StripAllPlayerWeapons(client);
							LoopClients(i) Menu_CapitulationMenu(i);
							if (gc_bSounds.BoolValue)EmitSoundToAllAny(g_sSoundCapitulationPath);
						}
						else CReplyToCommand(client, "%t %t", "request_tag", "request_processing");
					}
					else CReplyToCommand(client, "%t %t", "request_tag", "warden_noexist");
				}
				else CReplyToCommand(client, "%t %t", "request_tag", "request_alreadycapitulated");
			}
			else CReplyToCommand(client, "%t %t", "request_tag", "request_notalivect");
		}
	}
	return Plugin_Handled;
}


/******************************************************************************
                   EVENTS
******************************************************************************/


public void Capitulation_Event_RoundStart(Event event, char [] name, bool dontBroadcast)
{
	LoopClients(client)
	{
		delete CapitulationTimer[client];
		delete RebelTimer[client];
		
		g_bCapitulated[client] = false;
	}
}


/******************************************************************************
                   FORWARDS LISTENING
******************************************************************************/


public void Capitulation_OnMapStart()
{
	if (gc_bSounds.BoolValue) PrecacheSoundAnyDownload(g_sSoundCapitulationPath);
}


public void Capitulation_OnConfigsExecuted()
{
	//Set custom Commands
	int iCount = 0;
	char sCommands[128], sCommandsL[12][32], sCommand[32];
	
	//Capitulation
	gc_sCustomCommandCapitulation.GetString(sCommands, sizeof(sCommands));
	ReplaceString(sCommands, sizeof(sCommands), " ", "");
	iCount = ExplodeString(sCommands, ",", sCommandsL, sizeof(sCommandsL), sizeof(sCommandsL[]));
	
	for (int i = 0; i < iCount; i++)
	{
		Format(sCommand, sizeof(sCommand), "sm_%s", sCommandsL[i]);
		if (GetCommandFlags(sCommand) == INVALID_FCVAR_FLAGS)  //if command not already exist
			RegConsoleCmd(sCommand, Command_Capitulation, "Allows a rebeling terrorist to request a capitulate");
	}
}


public void Capitulation_OnClientPutInServer(int client)
{
	g_bCapitulated[client] = false;
	
	SDKHook(client, SDKHook_WeaponCanUse, Capitulation_OnWeaponCanUse);
	SDKHook(client, SDKHook_OnTakeDamage, Capitulation_OnTakedamage);
}


public void Capitulation_OnClientDisconnect(int client)
{
	delete RebelTimer[client];
	delete CapitulationTimer[client];
}


public Action Capitulation_OnWeaponCanUse(int client, int weapon)
{
	if (g_bCapitulated[client])
	{
		char sWeapon[32];
		GetEdictClassname(weapon, sWeapon, sizeof(sWeapon));
		
		if (!StrEqual(sWeapon, "weapon_knife"))
		{
			if (IsValidClient(client, true, false))
			{
				return Plugin_Handled;
			}
		}
	}
	return Plugin_Continue;
}


public Action Capitulation_OnTakedamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (IsValidClient(attacker, true, false) && GetClientTeam(attacker) == CS_TEAM_T && IsPlayerAlive(attacker))
	{
		if (g_bCapitulated[attacker] && gc_bCapitulationDamage.BoolValue && !IsClientInLastRequest(attacker))
		{
			CPrintToChat(attacker, "%t %t", "request_tag", "request_nodamage");
			return Plugin_Handled;
		}
	}
	return Plugin_Continue;
}


public int Capitulation_OnAvailableLR(int Announced)
{
	LoopClients(i) g_bCapitulated[i] = false;
}


/******************************************************************************
                   MENUS
******************************************************************************/


public Action Menu_CapitulationMenu(int warden)
{
	if (warden_iswarden(warden))
	{
		char info5[255], info6[255], info7[255];
		Menu menu1 = CreateMenu(Handler_CapitulationMenu);
		Format(info5, sizeof(info5), "%T", "request_acceptcapitulation", warden);
		menu1.SetTitle(info5);
		Format(info6, sizeof(info6), "%T", "warden_no", warden);
		Format(info7, sizeof(info7), "%T", "warden_yes", warden);
		menu1.AddItem("1", info7);
		menu1.AddItem("0", info6);
		menu1.Display(warden, gc_fCapitulationTime.IntValue);
	}
}


public int Handler_CapitulationMenu(Menu menu, MenuAction action, int client, int Position)
{
	if (action == MenuAction_Select)
	{
		char Item[11];
		menu.GetItem(Position, Item, sizeof(Item));
		int choice = StringToInt(Item);
		if (choice == 1)  //yes
		{
			LoopClients(i) if (g_bCapitulated[i])
			{
				IsRequest = false;
				if (RequestTimer != null)
					KillTimer(RequestTimer);
				RequestTimer = null;
				if (RebelTimer[i] != null)
					KillTimer(RebelTimer[i]);
				RebelTimer[i] = null;
				StripAllPlayerWeapons(i);
				SetEntityRenderColor(client, gc_iCapitulationColorRed.IntValue, gc_iCapitulationColorGreen.IntValue, gc_iCapitulationColorBlue.IntValue, 255);
				CapitulationTimer[i] = CreateTimer(gc_fCapitulationTime.FloatValue, Timer_GiveKnifeCapitulated, i);
				CPrintToChatAll("%t %t", "warden_tag", "request_accepted", i, client);
				ChangeRebelStatus(i, false);
			}
		}
		if (choice == 0)  //no
		{
			LoopClients(i) if (g_bCapitulated[i])
			{
				IsRequest = false;
				if (RequestTimer != null)
					KillTimer(RequestTimer);
				RequestTimer = null;
				SetEntityRenderColor(i, 255, 0, 0, 255);
				g_bCapitulated[i] = false;
				if (RebelTimer[i] != null)
					KillTimer(RebelTimer[i]);
				RebelTimer[i] = null;
				CPrintToChatAll("%t %t", "warden_tag", "request_noaccepted", i, client);
				ChangeRebelStatus(i, true);
			}
		}
	}
}


/******************************************************************************
                   TIMER
******************************************************************************/


public Action Timer_GiveKnifeCapitulated(Handle timer, any client)
{
	if (IsClientConnected(client))
	{
		GivePlayerItem(client, "weapon_knife");
		CPrintToChat(client, "%t %t", "request_tag", "request_knifeback");
		SetEntityRenderColor(client, 255, 255, 255, 255);
	}
	CapitulationTimer[client] = null;
}


public Action Timer_RebelNoAction(Handle timer, any client)
{
	if (IsClientConnected(client))
	{
		SetEntityRenderColor(client, 255, 0, 0, 255);
	}
	g_bCapitulated[client] = false;
	RebelTimer[client] = null;
}
