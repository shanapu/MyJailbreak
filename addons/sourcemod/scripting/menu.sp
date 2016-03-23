#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <cstrike>
#include <wardn>
#include <colors>
#include <autoexecconfig>

new Handle:cvar_ff;
ConVar gc_bTagEnabled;

#pragma semicolon 1

#define PLUGIN_VERSION   "0.x"

public Plugin myinfo = {
	name = "MyJailbreak - Menus",
	author = "shanapu, fransico",
	description = "Jailbreak Menu",
	version = PLUGIN_VERSION,
	url = ""
};

public OnConfigsExecuted()
{
	if (gc_bTagEnabled.BoolValue)
	{
		ConVar hTags = FindConVar("sv_tags");
		char sTags[128];
		hTags.GetString(sTags, sizeof(sTags));
		if (StrContains(sTags, "MyJailbreak", false) == -1)
		{
			StrCat(sTags, sizeof(sTags), ", MyJailbreak");
			hTags.SetString(sTags);
		}
	}
}

public OnPluginStart()
{
	RegConsoleCmd("sm_menu", JbMenu);
	RegConsoleCmd("sm_menus", JbMenu);

	RegConsoleCmd("sm_days", EventDays);
	RegConsoleCmd("sm_events", EventDays);
	
	RegConsoleCmd("buyammo1", JbMenu);
	
	AutoExecConfig_SetFile("MyJailbreak_menu");
	AutoExecConfig_SetCreateFile(true);
	
	gc_bTagEnabled = AutoExecConfig_CreateConVar("sm_menu_tag", "1", "Allow \"MyJailbreak\" to be added to the server tags? So player will find servers with MyJB faster. it dont touch you sv_tags", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	
	AutoExecConfig_CacheConvars();
	AutoExecConfig_ExecuteFile();
	AutoExecConfig_CleanFile();
	AutoExecConfig(true, "MyJailbreak_menu");
	
	cvar_ff = FindConVar("mp_teammates_are_enemies");
}

public Action:JbMenu(client,args)
{
	decl String:menuinfo1[255], String:menuinfo2[255], String:menuinfo3[255], String:menuinfo4[255], String:menuinfo5[255], String:menuinfo6[255], String:menuinfo7[255], String:menuinfo8[255];
	decl String:menuinfo9[255], String:menuinfo10[255], String:menuinfo11[255], String:menuinfo12[255], String:menuinfo13[255], String:menuinfo14[255], String:menuinfo15[255], String:menuinfo16[255];
	decl String:menuinfo17[255], String:menuinfo177[255]; 
	
	new Handle:menu = CreateMenu(JBMenuHandler);
	
	Format(menuinfo1, sizeof(menuinfo1), "%T", "menu_info_Title", LANG_SERVER);
	SetMenuTitle(menu, menuinfo1);
	if (warden_iswarden(client)) 
	{
	Format(menuinfo2, sizeof(menuinfo2), "%T", "menu_overlays", LANG_SERVER);
	AddMenuItem(menu, "overlays", menuinfo2);
	Format(menuinfo3, sizeof(menuinfo3), "%T", "menu_opencell", LANG_SERVER);
	AddMenuItem(menu, "cellopen", menuinfo3);
	Format(menuinfo4, sizeof(menuinfo4), "%T", "menu_teamgames", LANG_SERVER);
	AddMenuItem(menu, "teams", menuinfo4);
	Format(menuinfo5, sizeof(menuinfo5), "%T", "menu_eventdays", LANG_SERVER);
	AddMenuItem(menu, "days", menuinfo5);
	Format(menuinfo6, sizeof(menuinfo6), "%T", "menu_guns", LANG_SERVER);
	AddMenuItem(menu, "guns", menuinfo6);
	
	
	if(!GetConVarBool(cvar_ff)) 
	{
	Format(menuinfo7, sizeof(menuinfo7), "%T", "menu_ffon", LANG_SERVER);
	AddMenuItem(menu, "ffa1", menuinfo7);
	}
	else 
	{
	Format(menuinfo8, sizeof(menuinfo8), "%T", "menu_ffoff", LANG_SERVER);
	AddMenuItem(menu, "ffa2", menuinfo8);
	}
	
	Format(menuinfo9, sizeof(menuinfo9), "%T", "menu_randomdead", LANG_SERVER);
	AddMenuItem(menu, "kill", menuinfo9);
	
	
	Format(menuinfo10, sizeof(menuinfo10), "%T", "menu_unwarden", LANG_SERVER);
	AddMenuItem(menu, "unwarden", menuinfo10);
	}
	
	else if(GetClientTeam(client) == CS_TEAM_CT) 
	{
	Format(menuinfo11, sizeof(menuinfo11), "%T", "menu_getwarden", LANG_SERVER);
	AddMenuItem(menu, "getwarden", menuinfo11);
	Format(menuinfo12, sizeof(menuinfo12), "%T", "menu_guns", LANG_SERVER);
	AddMenuItem(menu, "guns", menuinfo12);
	Format(menuinfo13, sizeof(menuinfo13), "%T", "menu_joint", LANG_SERVER);
	AddMenuItem(menu, "joinT", menuinfo13);
	
	}	
 	else if(GetClientTeam(client) == CS_TEAM_T) 
	{	
	Format(menuinfo14, sizeof(menuinfo14), "%T", "menu_dice", LANG_SERVER);
	AddMenuItem(menu, "jbdice", menuinfo14);	
	Format(menuinfo15, sizeof(menuinfo15), "%T", "menu_joinct", LANG_SERVER);
	AddMenuItem(menu, "joinCT", menuinfo15);
	Format(menuinfo16, sizeof(menuinfo16), "%T", "menu_votect", LANG_SERVER);
	AddMenuItem(menu, "votewarden", menuinfo16);	
	Format(menuinfo17, sizeof(menuinfo17), "%T", "menu_votewarden", LANG_SERVER);
	AddMenuItem(menu, "voteCT", menuinfo17);	
	
	}
	if (CheckCommandAccess(client, "sm_map", ADMFLAG_CHANGEMAP, true))
	{
	Format(menuinfo177, sizeof(menuinfo177), "%T", "menu_admin", LANG_SERVER);
	AddMenuItem(menu, "admin", menuinfo177);
	}
	
//	AddMenuItem(menu, "servercmd", "Spieler Menu");
//	AddMenuItem(menu, "jailregeln", "Jail Regeln");
//	AddMenuItem(menu, "spielregeln", "Spiel Regeln");
//	AddMenuItem(menu, "serverregeln", "Server Regeln");
	
	SetMenuExitButton(menu, true);
	DisplayMenu(menu, client, 15);
}


public Action:EventDays(client, args)
{
	if (warden_iswarden(client))  
	{
	
	new Handle:menu = CreateMenu(EventMenuHandler);
	
	decl String:menuinfo18[255], String:menuinfo19[255], String:menuinfo20[255], String:menuinfo21[255], String:menuinfo22[255], String:menuinfo23[255], String:menuinfo24[255], String:menuinfo25[255];
		
	Format(menuinfo18, sizeof(menuinfo18), "%T", "menu_event_Title", LANG_SERVER);
	SetMenuTitle(menu, menuinfo18);
	Format(menuinfo19, sizeof(menuinfo19), "%T", "menu_war", LANG_SERVER);
	AddMenuItem(menu, "war", menuinfo19);
	Format(menuinfo20, sizeof(menuinfo20), "%T", "menu_ffa", LANG_SERVER);
	AddMenuItem(menu, "ffa", menuinfo20);
	Format(menuinfo21, sizeof(menuinfo21), "%T", "menu_zombie", LANG_SERVER);
	AddMenuItem(menu, "zombie", menuinfo21);
	Format(menuinfo22, sizeof(menuinfo22), "%T", "menu_hide", LANG_SERVER);
	AddMenuItem(menu, "hide", menuinfo22);
	Format(menuinfo23, sizeof(menuinfo23), "%T", "menu_catch", LANG_SERVER);
	AddMenuItem(menu, "catch", menuinfo23);
	Format(menuinfo24, sizeof(menuinfo24), "%T", "menu_noscope", LANG_SERVER);
	AddMenuItem(menu, "noscope", menuinfo24);
	Format(menuinfo25, sizeof(menuinfo25), "%T", "menu_duckhunt", LANG_SERVER);
	AddMenuItem(menu, "duckhunt", menuinfo25);

	SetMenuExitButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
	} else CPrintToChat(client, "%t %t", "menu_tag", "menu_notwarden" );
}



public JBMenuHandler(Handle:menu, MenuAction:action, client, itemNum) 
{
	if ( action == MenuAction_Select ) 
	{
		new String:info[32];
		
		GetMenuItem(menu, itemNum, info, sizeof(info));
		
		if ( strcmp(info,"joinT") == 0 ) 
		{
			ClientCommand(client, "jointeam %i", CS_TEAM_T);
			
		}
		else if ( strcmp(info,"ct") == 0 ) 
		{
			ClientCommand(client, "jointeam %i", CS_TEAM_CT);
		} 
		else if ( strcmp(info,"teams") == 0 ) 
		{
			FakeClientCommand(client, "say !tg");
			
		} 
		else if ( strcmp(info,"games") == 0 ) 
		{
			FakeClientCommand(client, "say !games");
			
		} 
		else if ( strcmp(info,"servercmd") == 0 ) 
		{
			FakeClientCommand(client, "say !menu2");
		} 
	
		else if ( strcmp(info,"jbdice") == 0 ) 
		{
			FakeClientCommand(client, "say !dice");
		} 
		else if ( strcmp(info,"votewarden") == 0 ) 
		{
			FakeClientCommand(client, "say !votect");
		} 
		else if ( strcmp(info,"voteCT") == 0 ) 
		{
			FakeClientCommand(client, "say !votegov");
		}
		else if ( strcmp(info,"joinCT") == 0 ) 
		{
			FakeClientCommand(client, "say !guard");
		}
		else if ( strcmp(info,"guns") == 0 ) 
		{
			FakeClientCommand(client, "say !guns");
		}
		else if ( strcmp(info,"spielregeln") == 0 ) 
		{
			FakeClientCommand(client, "say !spielregeln");
		}
		else if ( strcmp(info,"days") == 0 ) 
		{
			FakeClientCommand(client, "say !events");
		}
		else if ( strcmp(info,"serverregeln") == 0 ) 
		{
			FakeClientCommand(client, "say !rules");
		}
		else if ( strcmp(info,"jailregeln") == 0 ) 
		{
			FakeClientCommand(client, "say !jailregeln");
		}
		else if ( strcmp(info,"admin") == 0 ) 
		{
			FakeClientCommand(client, "say /admin");
		}
		else if ( strcmp(info,"overlays") == 0 ) 
		{
			FakeClientCommand(client, "say !jboverlays");
		}
		else if ( strcmp(info,"getwarden") == 0 ) 
		{
			FakeClientCommand(client, "sm_governor");
			JbMenu(client,0);
		}
		else if ( strcmp(info,"unwarden") == 0 ) 
		{
			FakeClientCommand(client, "sm_ungovernor");
			
		}
		else if ( strcmp(info,"cellopen") == 0 ) 
		{
			FakeClientCommand(client, "say !open");
			JbMenu(client,0);
		}
	
		else if ( strcmp(info,"ffa1") == 0 ) 
		{
			SetCvar("mp_teammates_are_enemies", 1);
			CPrintToChatAll("%t %t", "menu_tag", "menu_ffison" );
			JbMenu(client,0);
		}
		else if ( strcmp(info,"ffa2") == 0 ) 
		{
			SetCvar("mp_teammates_are_enemies", 0);
			CPrintToChatAll("%t %t", "menu_tag", "menu_ffisoff" );
			JbMenu(client,0);
		}
		else if ( strcmp(info,"kill") == 0 ) 
		{
			new clientV = GetRandomPlayer(CS_TEAM_T);
			if(clientV > 0)
			{
				ForcePlayerSuicide(clientV);
				CPrintToChatAll("%t %t", "menu_tag", "menu_israndomdead", clientV); 
				
			}
			JbMenu(client,0);
		}
	}
	else if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
}

public EventMenuHandler(Handle:menu, MenuAction:action, client, itemNum) 
{
	if ( action == MenuAction_Select ) 
	{
		new String:info[32];
		
		GetMenuItem(menu, itemNum, info, sizeof(info));
		
		if ( strcmp(info,"war") == 0 ) 
		{
			FakeClientCommand(client, "sm_setwar");
		} 
		else if ( strcmp(info,"ffa") == 0 ) 
		{
			FakeClientCommand(client, "sm_setffa");
		} 
		else if ( strcmp(info,"zombie") == 0 ) 
		{
			FakeClientCommand(client, "sm_setzombie");
		} 
			else if ( strcmp(info,"catch") == 0 ) 
		{
			FakeClientCommand(client, "sm_setcatch");
		} 
		else if ( strcmp(info,"noscope") == 0 ) 
		{
			FakeClientCommand(client, "sm_setnoscope");
		} 
		else if ( strcmp(info,"duckhunt") == 0 ) 
		{
			FakeClientCommand(client, "sm_setduckhunt");
		}
		else if ( strcmp(info,"hide") == 0 ) 
		{
			FakeClientCommand(client, "sm_sethide");
		}
			JbMenu(client,0);
	}
	else if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
}



public SetCvar(String:cvarName[64], value)
{
	new Handle:cvar;
	cvar = FindConVar(cvarName);

	new flags = GetConVarFlags(cvar);
	flags &= ~FCVAR_NOTIFY;
	SetConVarFlags(cvar, flags);

	SetConVarInt(cvar, value);

	flags |= FCVAR_NOTIFY;
	SetConVarFlags(cvar, flags);
}


GetRandomPlayer(team)
{
	new clients[MaxClients+1], clientCount;
	for (new i = 1; i <= MaxClients; i++)
		if (IsClientInGame(i) && GetClientTeam(i) == team) clients[clientCount++] = i;
		
	return (clientCount == 0) ? -1 : clients[GetRandomInt(0, clientCount-1)];
}

