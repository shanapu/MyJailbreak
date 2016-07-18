// Mute module for MyJailbreak - Warden

//Includes
#include <sourcemod>
#include <cstrike>
#include <warden>
#include <colors>
#include <autoexecconfig>
#include <myjailbreak>
#include <lastrequest>

//Compiler Options
#pragma semicolon 1
#pragma newdecls required

//ConVars
ConVar gc_bMute;
ConVar gc_bMuteEnd;
ConVar gc_sAdminFlagMute;

//Bools
bool IsMuted[MAXPLAYERS+1] = {false, ...};

//Strings
char g_sMuteUser[32];
char g_sAdminFlagMute[32];


public void Mute_OnPluginStart()
{
	//Client commands
	RegConsoleCmd("sm_wmute", Command_MuteMenu, "Allows a warden to mute all terrorists for a specified duration or untill the next round.");
	RegConsoleCmd("sm_wunmute", Command_UnMuteMenu, "Allows a warden to unmute the terrorists.");
	
	//AutoExecConfig
	gc_bMute = AutoExecConfig_CreateConVar("sm_warden_mute", "1", "0 - disabled, 1 - Allow the warden to mute T-side player", _, true, 0.0, true, 1.0);
	gc_bMuteEnd = AutoExecConfig_CreateConVar("sm_warden_mute_round", "1", "0 - disabled, 1 - Allow the warden to mute a player until roundend", _, true, 0.0, true, 1.0);
	gc_sAdminFlagMute = AutoExecConfig_CreateConVar("sm_warden_mute_immuntiy", "a", "Set flag for admin/vip Mute immunity. No flag immunity for all. so don't leave blank!");
	
	//Hooks 
	HookConVarChange(gc_sAdminFlagMute, Mute_OnSettingChanged);
	HookEvent("round_end", Mute_RoundEnd);
	
	//FindConVar
	gc_sAdminFlagMute.GetString(g_sAdminFlagMute , sizeof(g_sAdminFlagMute));
}

public int Mute_OnSettingChanged(Handle convar, const char[] oldValue, const char[] newValue)
{
	if(convar == gc_sAdminFlagMute)
	{
		strcopy(g_sAdminFlagMute, sizeof(g_sAdminFlagMute), newValue);
	}
}

public Action MuteMenuPlayer(int client,int args)
{
	if(gc_bPlugin.BoolValue)	
	{
		if(IsValidClient(client, false, false) && IsClientWarden(client) && gc_bMute.BoolValue)
		{
			char info1[255];
			Menu menu5 = CreateMenu(Handler_MuteMenuPlayer);
			Format(info1, sizeof(info1), "%T", "warden_choose", client);
			menu5.SetTitle(info1);
			LoopValidClients(i,true,true)
			{
				if((GetClientTeam(i) == CS_TEAM_T) && !CheckVipFlag(i,g_sAdminFlagMute))
				{
					char userid[11];
					char username[MAX_NAME_LENGTH];
					IntToString(GetClientUserId(i), userid, sizeof(userid));
					Format(username, sizeof(username), "%N", i);
					menu5.AddItem(userid,username);
				}
			}
			menu5.ExitBackButton = true;
			menu5.ExitButton = true;
			menu5.Display(client,MENU_TIME_FOREVER);
		}
		else CPrintToChat(client, "%t %t", "warden_tag", "warden_notwarden");
	}
	return Plugin_Handled;
}

public int Handler_MuteMenuPlayer(Menu menu5, MenuAction action, int client, int Position)
{
	if(action == MenuAction_Select)
	{
		menu5.GetItem(Position,g_sMuteUser,sizeof(g_sMuteUser));
		
		char menuinfo[255];
		
		Menu menu3 = new Menu(Handler_MuteMenuTime);
		Format(menuinfo, sizeof(menuinfo), "%T", "warden_time_title", client);
		menu3.SetTitle(menuinfo);
		Format(menuinfo, sizeof(menuinfo), "%T", "warden_roundend", client);
		if(gc_bMuteEnd.BoolValue) menu3.AddItem("0", menuinfo);
		Format(menuinfo, sizeof(menuinfo), "%T", "warden_15", client);
		menu3.AddItem("15", menuinfo);
		Format(menuinfo, sizeof(menuinfo), "%T", "warden_30", client);
		menu3.AddItem("30", menuinfo);
		Format(menuinfo, sizeof(menuinfo), "%T", "warden_45", client);
		menu3.AddItem("45", menuinfo);
		Format(menuinfo, sizeof(menuinfo), "%T", "warden_60", client);
		menu3.AddItem("60", menuinfo);
		Format(menuinfo, sizeof(menuinfo), "%T", "warden_90", client);
		menu3.AddItem("90", menuinfo);
		Format(menuinfo, sizeof(menuinfo), "%T", "warden_120", client);
		menu3.AddItem("120", menuinfo);
		Format(menuinfo, sizeof(menuinfo), "%T", "warden_180", client);
		menu3.AddItem("180", menuinfo);
		Format(menuinfo, sizeof(menuinfo), "%T", "warden_300", client);
		menu3.AddItem("300", menuinfo);
		menu3.ExitBackButton = true;
		menu3.ExitButton = true;
		menu3.Display(client, 20);
	}
	else if(action == MenuAction_Cancel)
	{
		if(Position == MenuCancel_ExitBack) 
		{
			FakeClientCommand(client, "sm_menu");
		}
	}
	else if(action == MenuAction_End)
	{
		delete menu5;
	}
}

public int Handler_MuteMenuTime(Menu menu3, MenuAction action, int client, int selection)
{
	if (action == MenuAction_Select)
	{
		char info[32];
		menu3.GetItem(selection, info, sizeof(info));
		int duration = StringToInt(info);
		int user = GetClientOfUserId(StringToInt(g_sMuteUser)); 
		
		MuteClient(user,duration);
		
		if(g_bMenuClose != null)
		{
			if(!g_bMenuClose)
			{
				FakeClientCommand(client, "sm_menu");
			}
		}
	}
	else if(action == MenuAction_Cancel)
	{
		if(selection == MenuCancel_ExitBack) 
		{
			FakeClientCommand(client, "sm_wmute");
		}
	}
	else if(action == MenuAction_End)
	{
		delete menu3;
	}
}

public Action Command_UnMuteMenu(int client, any args)
{
	if(gc_bPlugin.BoolValue)	
	{
		if(IsValidClient(client, false, false) && IsClientWarden(client) && gc_bMute.BoolValue)
		{
			char info1[255];
			Menu menu4 = CreateMenu(Handler_UnMuteMenu);
			Format(info1, sizeof(info1), "%T", "warden_choose", client);
			menu4.SetTitle(info1);
			LoopValidClients(i,true,true)
			{
				if((GetClientTeam(i) == CS_TEAM_T) && IsMuted[i])
				{
					char userid[11];
					char username[MAX_NAME_LENGTH];
					IntToString(GetClientUserId(i), userid, sizeof(userid));
					Format(username, sizeof(username), "%N", i);
					menu4.AddItem(userid,username);
				}
				else
				{
					CPrintToChat(client, "%t %t", "warden_tag", "warden_nomuted");
					FakeClientCommand(client, "sm_wmute");
				}
			}
			menu4.ExitBackButton = true;
			menu4.ExitButton = true;
			menu4.Display(client,MENU_TIME_FOREVER);
		}
		else CPrintToChat(client, "%t %t", "warden_tag", "warden_notwarden");
	}
	return Plugin_Handled;
}

public int Handler_UnMuteMenu(Menu menu4, MenuAction action, int client, int selection)
{
	if (action == MenuAction_Select)
	{
		char info[32];
		menu4.GetItem(selection, info, sizeof(info));
		int user = GetClientOfUserId(StringToInt(info)); 
		
		UnMuteClient(user);
		
		if(g_bMenuClose != null)
		{
			if(!g_bMenuClose)
			{
				FakeClientCommand(client, "sm_menu");
			}
		}
	}
	else if(action == MenuAction_Cancel)
	{
		if(selection == MenuCancel_ExitBack) 
		{
			FakeClientCommand(client, "sm_menu");
		}
	}
	else if(action == MenuAction_End)
	{
		delete menu4;
	}
}

public Action Command_MuteMenu(int client, int args)
{
	if (gc_bMute.BoolValue) 
	{
		if (IsClientWarden(client))
		{
			char info[255];
			Menu menu1 = CreateMenu(Handler_MuteMenu);
			Format(info, sizeof(info), "%T", "warden_mute_title", g_iWarden, client);
			menu1.SetTitle(info);
			Format(info, sizeof(info), "%T", "warden_menu_mute", client);
			menu1.AddItem("0", info);
			Format(info, sizeof(info), "%T", "warden_menu_unmute", client);
			menu1.AddItem("1", info);
			menu1.ExitBackButton = true;
			menu1.ExitButton = true;
			menu1.Display(client,MENU_TIME_FOREVER);
		}
		else CPrintToChat(client, "%t %t", "warden_tag" , "warden_notwarden"); 
	}
}

public int Handler_MuteMenu(Menu menu, MenuAction action, int client, int Position)
{
	if(action == MenuAction_Select)
	{
		char Item[11];
		menu.GetItem(Position,Item,sizeof(Item));
		int choice = StringToInt(Item);
		if(choice == 1)
		{
			Command_UnMuteMenu(client,0);
		}
		if(choice == 0)
		{
			MuteMenuPlayer(client,0);
		}
	}
	else if(action == MenuAction_Cancel)
	{
		if(Position == MenuCancel_ExitBack) 
		{
			FakeClientCommand(client, "sm_menu");
		}
	}
	else if(action == MenuAction_End)
	{
		delete menu;
	}
}

public Action MuteClient(int client, int time)
{
	if(IsValidClient(client,true,true))
	{
		if(GetClientTeam(client) == CS_TEAM_T)
		{
			SetClientListeningFlags(client, VOICE_MUTED);
			IsMuted[client] = true;
			
			if (time == 0)
			{
				CPrintToChatAll("%t %t", "warden_tag", "warden_muteend", g_iWarden, client);
				if(MyJBLogging(true)) LogToFileEx(g_sMyJBLogFile, "Warden %L muted player %L until round end", g_iWarden, client);
			}
			else
			{
				CPrintToChatAll("%t %t", "warden_tag", "warden_mute", g_iWarden, client, time);
				if(MyJBLogging(true)) LogToFileEx(g_sMyJBLogFile, "Warden %L muted player %L for %i seconds", g_iWarden, client, time);
			}
		}
	}
	if(time > 0)
	{
		float timing = float(time);
		CreateTimer(timing, Timer_UnMute,client);
	}
}

public void UnMuteClient(any client)
{
	if(IsValidClient(client,true,true) && IsMuted[client])
	{
		SetClientListeningFlags(client, VOICE_NORMAL);
		IsMuted[client] = false;
		CPrintToChat(client,"%t %t", "warden_tag", "warden_unmute", client);
		if(g_iWarden != -1) CPrintToChat(g_iWarden,"%t %t", "warden_tag", "warden_unmute", client);
	}
}

public Action Timer_UnMute(Handle timer, any client)
{
	UnMuteClient(client);
}

public void Mute_RoundEnd(Event event, const char[] name, bool dontBroadcast)
{
	LoopClients(i) if(IsMuted[i]) UnMuteClient(i);
}

public void Mute_OnAvailableLR(int Announced)
{
	LoopClients(i) if(IsMuted[i] && IsPlayerAlive(i)) UnMuteClient(i);
}

public void Mute_OnMapEnd()
{
	LoopClients(i) if(IsMuted[i]) UnMuteClient(i);
}
