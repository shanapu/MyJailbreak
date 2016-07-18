// Random Kill module for MyJailbreak - Warden

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

//Defines
#define SOUND_THUNDER "ambient/weather/thunder3.wav"

//ConVars
ConVar gc_bRandom;
ConVar gc_iRandomMode;

//Integers
int g_iKillKind;

public void RandomKill_OnPluginStart()
{
	//Client commands
	RegConsoleCmd("sm_randomkill", Command_KillMenu, "Allows the Warden to kill a random T");
	
	//AutoExecConfig
	gc_bRandom = AutoExecConfig_CreateConVar("sm_warden_random", "1", "0 - disabled, 1 - enable kill a random t for warden", _, true,  0.0, true, 1.0);
	gc_iRandomMode = AutoExecConfig_CreateConVar("sm_warden_random_mode", "2", "1 - all random / 2 - Thunder / 3 - Timebomb / 4 - Firebomb / 5 - NoKill(1,3,4 needs funcommands.smx enabled)", _, true,  1.0, true, 4.0);
	
	//Hooks
	HookEvent("round_start", Reminder_RoundStart);
	HookEvent("round_end", Reminder_RoundEnd);
}

public void RandomKill_OnConfigsExecuted()
{
	g_iKillKind = gc_iRandomMode.IntValue;
}

public Action Command_KillMenu(int client, int args)
{
	if (gc_bRandom.BoolValue) 
	{
		if (IsClientWarden(client))
		{
			char info[255];
			Menu menu1 = CreateMenu(Handler_KillMenu);
			Format(info, sizeof(info), "%T", "warden_sure", g_iWarden, client);
			menu1.SetTitle(info);
			Format(info, sizeof(info), "%T", "warden_no", client);
			menu1.AddItem("0", info);
			Format(info, sizeof(info), "%T", "warden_yes", client);
			menu1.AddItem("1", info);
			menu1.ExitBackButton = true;
			menu1.ExitButton = true;
			menu1.Display(client,MENU_TIME_FOREVER);
		}
		else CPrintToChat(client, "%t %t", "warden_tag" , "warden_notwarden"); 
	}
}

public int Handler_KillMenu(Menu menu, MenuAction action, int client, int Position)
{
	if(action == MenuAction_Select)
	{
		char Item[11];
		menu.GetItem(Position,Item,sizeof(Item));
		int choice = StringToInt(Item);
		if(choice == 1)
		{
			if (GetAlivePlayersCount(CS_TEAM_T) > 1)
			{
				int i = GetRandomPlayer(CS_TEAM_T);
				if(i > 0)
				{
					CreateTimer( 1.0, Timer_KillPlayer, i);
					CPrintToChatAll("%t %t", "warden_tag", "warden_israndom", i); 
					if(MyJBLogging(true)) LogToFileEx(g_sMyJBLogFile, "Warden %L killed random player %L", client, i);
				}
			}
			else CPrintToChatAll("%t %t", "warden_tag", "warden_minrandom"); 
		}
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

public Action Timer_KillPlayer( Handle timer, any client) 
{
	if(g_iKillKind == 1)
	{
		int randomnum = GetRandomInt(0, 2);
		
		if(randomnum == 0)PerformSmite(0, client);
		if(randomnum == 1)ServerCommand("sm_timebomb %N 1", client);
		if(randomnum == 2)ServerCommand("sm_firebomb %N 1", client);
	}
	else if(g_iKillKind == 2)PerformSmite(0, client);
	else if(g_iKillKind == 3)ServerCommand("sm_timebomb %N 1", client);
	else if(g_iKillKind == 4)ServerCommand("sm_firebomb %N 1", client);
}

public Action PerformSmite(int client, int target)
{
	// define where the lightning strike ends
	float clientpos[3];
	GetClientAbsOrigin(target, clientpos);
	clientpos[2] -= 26; // increase y-axis by 26 to strike at player's chest instead of the ground
	
	// get random numbers for the x and y starting positions
	int randomx = GetRandomInt(-500, 500);
	int randomy = GetRandomInt(-500, 500);
	
	// define where the lightning strike starts
	float startpos[3];
	startpos[0] = clientpos[0] + randomx;
	startpos[1] = clientpos[1] + randomy;
	startpos[2] = clientpos[2] + 800;
	
	// define the color of the strike
	int color[4] = {255, 255, 255, 255};
	
	// define the direction of the sparks
	float dir[3] = {0.0, 0.0, 0.0};
	
	TE_SetupBeamPoints(startpos, clientpos, g_iBeamSprite, 0, 0, 0, 0.2, 20.0, 10.0, 0, 1.0, color, 3);
	TE_SendToAll();
	
	TE_SetupSparks(clientpos, dir, 5000, 1000);
	TE_SendToAll();
	
	TE_SetupEnergySplash(clientpos, dir, false);
	TE_SendToAll();
	
	TE_SetupSmoke(clientpos, g_iSmokeSprite, 5.0, 10);
	TE_SendToAll();
	
	EmitAmbientSound(SOUND_THUNDER, startpos, target, SNDLEVEL_GUNFIRE);
	
	ForcePlayerSuicide(target);
}
