//includes
#include <sourcemod>
#include <cstrike>
#include <warden>
#include <colors>
#include <autoexecconfig>
#include <myjailbreak>
#undef REQUIRE_PLUGIN
#include <lastrequest>
#define REQUIRE_PLUGIN

//Compiler Options
#pragma semicolon 1
#pragma newdecls required

//ConVars
ConVar gc_bPlugin;
ConVar gc_bTerror;
ConVar gc_bCTerror;
ConVar gc_bWarden;
ConVar gc_bDays;
ConVar gc_bClose;
ConVar gc_bStart;
ConVar gc_bWelcome;
ConVar g_bMath;
ConVar g_bCheck;
ConVar g_bFF;
ConVar g_bZeus;
ConVar g_bRules;
ConVar g_bsetFF;
ConVar g_bWar;
ConVar g_bJihad;
ConVar g_bKnife;
ConVar g_bFFA;
ConVar g_bLaser;
ConVar g_bDrawer;
ConVar g_bNoBlock;
ConVar g_bZombie;
ConVar g_bNoScope;
ConVar g_bHEbattle;
ConVar g_bHide;
ConVar g_bCatch;
ConVar g_bFreeday;
ConVar g_bDuckHunt;
ConVar g_bCountdown;
ConVar g_bVote;
ConVar g_bGuns;
ConVar g_bGunsT;
ConVar g_bGunsCT;
ConVar g_bOpen;
ConVar g_bRandom;
ConVar g_bWarden;
ConVar gc_bTeam;

public Plugin myinfo = {
	name = "MyJailbreak - Menus",
	author = "shanapu, Franc1sco",
	description = "Jailbreak Menu",
	version = PLUGIN_VERSION,
	url = URL_LINK
};

public void OnPluginStart()
{
	// Translation
	LoadTranslations("MyJailbreak.Warden.phrases");
	LoadTranslations("MyJailbreak.Menu.phrases");
	
	//Client Commands
	RegConsoleCmd("sm_menu", JbMenu, "opens the menu depends on players team/rank");
	RegConsoleCmd("sm_menus", JbMenu, "opens the menu depends on players team/rank");
	RegConsoleCmd("buyammo1", JbMenu, "opens the menu depends on players team/rank");
	RegConsoleCmd("sm_days", VoteEventDays, "open a vote EventDays menu for player");
	RegConsoleCmd("sm_eventdays", VoteEventDays, "open a vote EventDays menu for player");
	RegConsoleCmd("sm_seteventdays", SetEventDays, "open a Set EventDays menu for Warden/Admin");
	RegConsoleCmd("sm_setdays", SetEventDays, "open a Set EventDays menu for Warden/Admin");
	
	//AutoExecConfig
	AutoExecConfig_SetFile("Menu", "MyJailbreak");
	AutoExecConfig_SetCreateFile(true);
	
	AutoExecConfig_CreateConVar("sm_menu_version", PLUGIN_VERSION, "The version of the SourceMod plugin MyJailbreak - Menu", FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_DONTRECORD);
	gc_bPlugin = AutoExecConfig_CreateConVar("sm_menu_enable", "1", "0 - disabled, 1 - enable jailbrek menu");
	gc_bCTerror = AutoExecConfig_CreateConVar("sm_menu_ct", "1", "0 - disabled, 1 - enable ct jailbreak menu");
	gc_bTerror = AutoExecConfig_CreateConVar("sm_menu_t", "1", "0 - disabled, 1 - enable t jailbreak menu");
	gc_bWarden = AutoExecConfig_CreateConVar("sm_menu_warden", "1", "0 - disabled, 1 - enable warden jailbreak menu");
	gc_bDays = AutoExecConfig_CreateConVar("sm_menu_days", "1", "0 - disabled, 1 - enable vote/set eventdays menu");
	gc_bClose = AutoExecConfig_CreateConVar("sm_menu_close", "0", "0 - disabled, 1 - enable close menu after action");
	gc_bStart = AutoExecConfig_CreateConVar("sm_menu_start", "1", "0 - disabled, 1 - enable open menu on every roundstart");
	gc_bTeam = AutoExecConfig_CreateConVar("sm_menu_team", "1", "0 - disabled, 1 - enable join team on menu");
	gc_bWelcome = AutoExecConfig_CreateConVar("sm_menu_welcome", "1", "Show welcome message to newly connected users.");
	
	AutoExecConfig_ExecuteFile();
	AutoExecConfig_CleanFile();
	
	//Hooks
	HookEvent("player_spawn", Event_OnPlayerSpawn);
}

//FindConVar

public void OnConfigsExecuted()
{
	g_bWarden = FindConVar("sm_warden_enable");
	g_bRules = FindConVar("sm_hosties_rules_enable");
	g_bCheck = FindConVar("sm_hosties_checkplayers_enable");
	g_bMath = FindConVar("sm_warden_math");
	g_bNoBlock = FindConVar("sm_warden_noblock");
	g_bWar = FindConVar("sm_war_enable");
	g_bZeus = FindConVar("sm_zeus_enable");
	g_bFFA = FindConVar("sm_ffa_enable");
	g_bDrawer = FindConVar("sm_warden_drawer");
	g_bLaser = FindConVar("sm_warden_laser");
	g_bZombie = FindConVar("sm_zombie_enable");
	g_bNoScope = FindConVar("sm_noscope_enable");
	g_bHide = FindConVar("sm_hide_enable");
	g_bKnife = FindConVar("sm_knifefight_enable");
	g_bJihad = FindConVar("sm_jihad_enable");
	g_bCatch = FindConVar("sm_catch_enable");
	g_bHEbattle = FindConVar("sm_hebattle_enable");
	g_bFreeday = FindConVar("sm_Freeday_enable");
	g_bDuckHunt = FindConVar("sm_duckhunt_enable");
	g_bCountdown = FindConVar("sm_warden_countdown");
	g_bVote = FindConVar("sm_warden_vote");
	g_bGunsCT = FindConVar("sm_weapons_ct");
	g_bGunsT = FindConVar("sm_weapons_t");
	g_bGuns = FindConVar("sm_weapons_enable");
	g_bOpen = FindConVar("sm_warden_open_enable");
	g_bsetFF = FindConVar("sm_warden_ff");
	g_bRandom = FindConVar("sm_warden_random");
	g_bFF = FindConVar("mp_teammates_are_enemies");
}

//Welcome/Info Message

public void OnClientPutInServer(int client)
{
	if (gc_bWelcome.BoolValue)
	{
		CreateTimer(35.0, Timer_WelcomeMessage, client);
	}
}

public Action Timer_WelcomeMessage(Handle timer, any client)
{	
	if (gc_bWelcome.BoolValue && IsValidClient(client, false, true))
	{	
		CPrintToChat(client, "%t", "menu_info");
	}
}

//Open Menu on Spawn

public Action Event_OnPlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	if(gc_bStart.BoolValue)
	{
		JbMenu(client,0);
	}
}

//Main Menu

public Action JbMenu(int client, int args)
{
	if(gc_bPlugin.BoolValue)	
	{
		char menuinfo1[255], menuinfo2[255], menuinfo3[255], menuinfo5[255], menuinfo6[255], menuinfo7[255], menuinfo8[255];
		char menuinfo9[255], menuinfo10[255], menuinfo11[255], menuinfo13[255], menuinfo15[255], menuinfo16[255];
		char menuinfo17[255], menuinfo14[255], menuinfo4[255], menuinfo19[255], menuinfo20[255], menuinfo21[255], menuinfo18[255];
		char menuinfo22[255];
		//menuinfo12[255],
		Format(menuinfo1, sizeof(menuinfo1), "%T", "menu_info_title", LANG_SERVER);
		
		Menu mainmenu = new Menu(JBMenuHandler);
		mainmenu.SetTitle(menuinfo1);
		if (warden_iswarden(client) && IsPlayerAlive(client))
		{
			if(gc_bWarden.BoolValue)
			{
				if(g_bGuns != null)
				{
					if(g_bGuns.BoolValue)
					{
						if(g_bGunsCT.BoolValue)
						{
							Format(menuinfo6, sizeof(menuinfo6), "%T", "menu_guns", LANG_SERVER);
							mainmenu.AddItem("guns", menuinfo6);
						}
					}
				}
				if(g_bOpen != null)
				{
					if(g_bOpen.BoolValue)
					{
						Format(menuinfo3, sizeof(menuinfo3), "%T", "menu_opencell", LANG_SERVER);
						mainmenu.AddItem("cellopen", menuinfo3);
					}
				}
				if(g_bCountdown != null)
				{
					if(g_bCountdown.BoolValue)
					{
						Format(menuinfo2, sizeof(menuinfo2), "%T", "menu_countdown", LANG_SERVER);
						mainmenu.AddItem("countdown", menuinfo2);
					}
				}
				if(g_bMath != null)
				{
					if(g_bMath.BoolValue)
					{
						Format(menuinfo3, sizeof(menuinfo3), "%T", "menu_math", LANG_SERVER);
						mainmenu.AddItem("math", menuinfo3);
					}
				}
				if(gc_bDays.BoolValue)
				{
					Format(menuinfo5, sizeof(menuinfo5), "%T", "menu_seteventdays", LANG_SERVER);
					mainmenu.AddItem("setdays", menuinfo5);
				}
				if(g_bDrawer != null)
				{
					if(g_bDrawer.BoolValue)
					{
						Format(menuinfo21, sizeof(menuinfo21), "%T", "menu_drawer", LANG_SERVER);
						mainmenu.AddItem("drawer", menuinfo21);
					}
				}
				if(g_bLaser != null)
				{
					if(g_bLaser.BoolValue)
					{
						Format(menuinfo20, sizeof(menuinfo20), "%T", "menu_laser", LANG_SERVER);
						mainmenu.AddItem("laser", menuinfo20);
					}
				}
				if(g_bCheck != null)
				{
					if(g_bCheck.BoolValue)
					{
						Format(menuinfo4, sizeof(menuinfo4), "%T", "menu_check", LANG_SERVER);
						mainmenu.AddItem("check", menuinfo4);
					}
				}
				if(g_bsetFF != null)
				{
					if(g_bsetFF.BoolValue)
					{
						if(!g_bFF.BoolValue)
						{
							Format(menuinfo7, sizeof(menuinfo7), "%T", "menu_ffon", LANG_SERVER);
							mainmenu.AddItem("setff", menuinfo7);
						}
						else
						{
							Format(menuinfo8, sizeof(menuinfo8), "%T", "menu_ffoff", LANG_SERVER);
							mainmenu.AddItem("setff", menuinfo8);
						}
					}
				}
				if(g_bNoBlock != null)
				{
					if(g_bNoBlock.BoolValue)
					{
						Format(menuinfo22, sizeof(menuinfo22), "%T", "menu_noblock", LANG_SERVER);
						mainmenu.AddItem("noblock", menuinfo22);
					}
				}
				if(g_bRandom != null)
				{
					if(g_bRandom.BoolValue)
					{
						Format(menuinfo9, sizeof(menuinfo9), "%T", "menu_randomdead", LANG_SERVER);
						mainmenu.AddItem("kill", menuinfo9);
					}
				}
				Format(menuinfo10, sizeof(menuinfo10), "%T", "menu_unwarden", LANG_SERVER);
				mainmenu.AddItem("unwarden", menuinfo10);
			}
		}
		else if(GetClientTeam(client) == CS_TEAM_CT) 
		{
			if(gc_bCTerror.BoolValue)
			{
				if(g_bGuns != null)
				{
					if(g_bGuns.BoolValue)
					{
						if(g_bGunsCT.BoolValue)
						{
							Format(menuinfo6, sizeof(menuinfo6), "%T", "menu_guns", LANG_SERVER);
							mainmenu.AddItem("guns", menuinfo6);
						}
					}
				}
				if(g_bWarden != null)
				{
					if(!warden_exist() && IsPlayerAlive(client))
					{
						if(g_bWarden.BoolValue)
						{
							Format(menuinfo11, sizeof(menuinfo11), "%T", "menu_getwarden", LANG_SERVER);
							mainmenu.AddItem("getwarden", menuinfo11);
						}
					}
				}
				char EventDay[64];
				GetEventDay(EventDay);
				
				if(StrEqual(EventDay, "none", false)) //is an other event running or set?
				{
					if(gc_bDays.BoolValue)
					{
						Format(menuinfo5, sizeof(menuinfo5), "%T", "menu_voteeventdays", LANG_SERVER);
						mainmenu.AddItem("votedays", menuinfo5);
					}
				}
				
				if(g_bCheck != null)
				{
					if(g_bCheck.BoolValue)
					{
						Format(menuinfo4, sizeof(menuinfo4), "%T", "menu_check", LANG_SERVER);
						mainmenu.AddItem("check", menuinfo4);
					}
				}
				if(gc_bTeam.BoolValue)
				{
					Format(menuinfo13, sizeof(menuinfo13), "%T", "menu_joint", LANG_SERVER);
					mainmenu.AddItem("ChangeTeam", menuinfo13);
				}
			}
		}
		else if(GetClientTeam(client) == CS_TEAM_T) 
		{
			if(gc_bTerror.BoolValue)
			{
				if(g_bGuns != null)
				{
					if(g_bGuns.BoolValue)
					{
						if(g_bGunsT.BoolValue)
						{
							Format(menuinfo6, sizeof(menuinfo6), "%T", "menu_guns", LANG_SERVER);
							mainmenu.AddItem("guns", menuinfo6);
						}
					}
				}
				if(g_bWarden != null)
				{
					if(warden_exist())
					{
						if(g_bWarden.BoolValue)
						{
							if(g_bVote.BoolValue)
							{
								Format(menuinfo16, sizeof(menuinfo16), "%T", "menu_votewarden", LANG_SERVER);
								mainmenu.AddItem("votewarden", menuinfo16);
							}
						}
					}
				}
				
				char EventDay[64];
				GetEventDay(EventDay);
				
				if(StrEqual(EventDay, "none", false)) //is an other event running or set?
				{
					if(gc_bDays.BoolValue)
					{
						Format(menuinfo5, sizeof(menuinfo5), "%T", "menu_voteeventdays", LANG_SERVER);
						mainmenu.AddItem("votedays", menuinfo5);
					}
				}
				if(gc_bTeam.BoolValue)
				{
					Format(menuinfo15, sizeof(menuinfo15), "%T", "menu_joinct", LANG_SERVER);
					mainmenu.AddItem("ChangeTeam", menuinfo15);
				}
			}
		}
		if(g_bRules != null)
		{
			if(g_bRules.BoolValue)
			{
				Format(menuinfo14, sizeof(menuinfo14), "%T", "menu_rules", LANG_SERVER);
				mainmenu.AddItem("rules", menuinfo14);
			}
		}
		if (CheckCommandAccess(client, "sm_map", ADMFLAG_CHANGEMAP, true))
		{
			char EventDay[64];
			GetEventDay(EventDay);
			
			if(StrEqual(EventDay, "none", false)) //is an other event running or set?
			{
				if (!warden_iswarden(client))
				{
					if(gc_bDays.BoolValue)
					{
						Format(menuinfo5, sizeof(menuinfo5), "%T", "menu_seteventdays", LANG_SERVER);
						mainmenu.AddItem("setdays", menuinfo5);
					}
				}
			}
			if(g_bWarden != null)
			{
				if(g_bWarden.BoolValue)
				{
					if(warden_exist())
					{
						Format(menuinfo19, sizeof(menuinfo19), "%T", "menu_removewarden", LANG_SERVER);
						mainmenu.AddItem("removewarden", menuinfo19);
					}
					Format(menuinfo18, sizeof(menuinfo18), "%T", "menu_setwarden", LANG_SERVER);
					mainmenu.AddItem("setwarden", menuinfo18);
				}
			}
			Format(menuinfo17, sizeof(menuinfo17), "%T", "menu_admin", LANG_SERVER);
			mainmenu.AddItem("admin", menuinfo17);
		}
		mainmenu.ExitButton = true;
		mainmenu.Display(client, MENU_TIME_FOREVER);
	}
}

//Main Handle

public int JBMenuHandler(Menu mainmenu, MenuAction action, int client, int selection)
{
	if (action == MenuAction_Select)
	{
		char info[32];
		mainmenu.GetItem(selection, info, sizeof(info));
		
		if ( strcmp(info,"ChangeTeam") == 0 ) 
		{
			ChangeTeam(client,0);
		}
		else if ( strcmp(info,"lastR") == 0 ) 
		{
			FakeClientCommand(client, "sm_lr");
		}
		else if ( strcmp(info,"removewarden") == 0 ) 
		{
			FakeClientCommand(client, "sm_rw");
		}
		else if ( strcmp(info,"setwarden") == 0 ) 
		{
			FakeClientCommand(client, "sm_sw");
		}
		else if ( strcmp(info,"check") == 0 ) 
		{
			FakeClientCommand(client, "sm_checkplayers");
			if(!gc_bClose.BoolValue)
			{
				JbMenu(client,0);
			}
		}
		else if ( strcmp(info,"rules") == 0 ) 
		{
			FakeClientCommand(client, "sm_rules");
		}
		else if ( strcmp(info,"votewarden") == 0 ) 
		{
			FakeClientCommand(client, "sm_votewarden");
			if(!gc_bClose.BoolValue)
			{
				JbMenu(client,0);
			}
		} 
		else if ( strcmp(info,"guns") == 0 ) 
		{
			FakeClientCommand(client, "sm_guns");
		}
		else if ( strcmp(info,"votedays") == 0 ) 
		{
			FakeClientCommand(client, "sm_days");
		}
		else if ( strcmp(info,"setdays") == 0 ) 
		{
			FakeClientCommand(client, "sm_setdays");
		}
		else if ( strcmp(info,"math") == 0 ) 
		{
			FakeClientCommand(client, "sm_math");
			if(!gc_bClose.BoolValue)
			{
				JbMenu(client,0);
			}
		}
		else if ( strcmp(info,"noblock") == 0 ) 
		{
			FakeClientCommand(client, "sm_noblock");
			if(!gc_bClose.BoolValue)
			{
				JbMenu(client,0);
			}
		}
		else if ( strcmp(info,"laser") == 0 ) 
		{
			FakeClientCommand(client, "sm_laser");
		}
		else if ( strcmp(info,"drawer") == 0 ) 
		{
			FakeClientCommand(client, "sm_drawer");
		}
		else if ( strcmp(info,"admin") == 0 ) 
		{
			FakeClientCommand(client, "sm_admin");
		}
		else if ( strcmp(info,"countdown") == 0 ) 
		{
			FakeClientCommand(client, "sm_cdmenu");
		}
		else if ( strcmp(info,"getwarden") == 0 ) 
		{
			FakeClientCommand(client, "sm_warden");
			JbMenu(client,0);
		}
		else if ( strcmp(info,"unwarden") == 0 ) 
		{
			FakeClientCommand(client, "sm_unwarden");
			JbMenu(client,0);
		}
		else if ( strcmp(info,"cellopen") == 0 ) 
		{
			FakeClientCommand(client, "sm_open");
			if(!gc_bClose.BoolValue)
			{
				JbMenu(client,0);
			}
		}
		else if ( strcmp(info,"setff") == 0 ) 
		{
			FakeClientCommand(client, "sm_setff");
			if(!gc_bClose.BoolValue)
			{
				JbMenu(client,0);
			}
		}
		else if ( strcmp(info,"kill") == 0 ) 
		{
			FakeClientCommand(client, "sm_killrandom");
		}
		else if (action == MenuAction_End)
		{
		delete mainmenu;
		}
	}
}

//Event Day Voting Menu

public Action VoteEventDays(int client, int args)
{
	if(gc_bDays.BoolValue)
	{
			Menu daysmenu = new Menu(VoteEventMenuHandler);
			
			char menuinfo19[255], menuinfo20[255], menuinfo21[255], menuinfo22[255], menuinfo23[255], menuinfo24[255], menuinfo25[255], menuinfo26[255], menuinfo27[255], menuinfo28[255], menuinfo29[255];
			char menuinfo17[255];
			
			Format(menuinfo29, sizeof(menuinfo29), "%T", "menu_event_Titlevote", LANG_SERVER);
			daysmenu.SetTitle(menuinfo29);
			
			if(g_bWar != null)
			{
				if(g_bWar.BoolValue)
				{
					Format(menuinfo19, sizeof(menuinfo19), "%T", "menu_war", LANG_SERVER);
					daysmenu.AddItem("votewar", menuinfo19);
				}
			}
			if(g_bFFA != null)
			{
				if(g_bFFA.BoolValue)
				{
					Format(menuinfo20, sizeof(menuinfo20), "%T", "menu_ffa", LANG_SERVER);
					daysmenu.AddItem("voteffa", menuinfo20);
				}
			}
			if(g_bZombie != null)
			{
				if(g_bZombie.BoolValue)
				{
					Format(menuinfo21, sizeof(menuinfo21), "%T", "menu_zombie", LANG_SERVER);
					daysmenu.AddItem("votezombie", menuinfo21);
				}
			}
			if(g_bHide != null)
			{
				if(g_bHide.BoolValue)
				{
					Format(menuinfo22, sizeof(menuinfo22), "%T", "menu_hide", LANG_SERVER);
					daysmenu.AddItem("votehide", menuinfo22);
				}
			}
			if(g_bCatch != null)
			{
				if(g_bCatch.BoolValue)
				{
					Format(menuinfo23, sizeof(menuinfo23), "%T", "menu_catch", LANG_SERVER);
					daysmenu.AddItem("votecatch", menuinfo23);
				}
			}
			if(g_bJihad != null)
			{
				if(g_bJihad.BoolValue)
				{
					Format(menuinfo23, sizeof(menuinfo23), "%T", "menu_jihad", LANG_SERVER);
					daysmenu.AddItem("voteJihad", menuinfo23);
				}
			}
			if(g_bHEbattle != null)
			{
				if(g_bHEbattle.BoolValue)
				{
					Format(menuinfo27, sizeof(menuinfo27), "%T", "menu_hebattle", LANG_SERVER);
					daysmenu.AddItem("votehebattle", menuinfo27);
				}
			}
			if(g_bNoScope != null)
			{
				if(g_bNoScope.BoolValue)
				{
					Format(menuinfo24, sizeof(menuinfo24), "%T", "menu_noscope", LANG_SERVER);
					daysmenu.AddItem("votenoscope", menuinfo24);
				}
			}
			if(g_bDuckHunt != null)
			{
				if(g_bDuckHunt.BoolValue)
				{
					Format(menuinfo25, sizeof(menuinfo25), "%T", "menu_duckhunt", LANG_SERVER);
					daysmenu.AddItem("voteduckhunt", menuinfo25);
				}
			}
			if(g_bZeus != null)
			{
				if(g_bZeus.BoolValue)
				{
					Format(menuinfo17, sizeof(menuinfo17), "%T", "menu_zeus", LANG_SERVER);
					daysmenu.AddItem("votezeus", menuinfo17);
				}
			}
			if(g_bKnife != null)
			{
				if(g_bKnife.BoolValue)
				{
					Format(menuinfo28, sizeof(menuinfo28), "%T", "menu_knifefight", LANG_SERVER);
					daysmenu.AddItem("voteknife", menuinfo28);
				}
			}
			if(g_bFreeday != null)
			{
				if(g_bFreeday.BoolValue)
				{
					Format(menuinfo26, sizeof(menuinfo26), "%T", "menu_Freeday", LANG_SERVER);
					daysmenu.AddItem("voteFreeday", menuinfo26);
				}
			}
			daysmenu.ExitButton = true;
			daysmenu.ExitBackButton = true;
			daysmenu.Display(client, MENU_TIME_FOREVER);
	}
}

//Event Day Voting Handler

public int VoteEventMenuHandler(Menu daysmenu, MenuAction action, int client, int selection)
{
	if (action == MenuAction_Select)
	{
		char info[32];
		
		daysmenu.GetItem(selection, info, sizeof(info));
		
		if ( strcmp(info,"votewar") == 0 ) 
		{
			FakeClientCommand(client, "sm_war");
			if(!gc_bClose.BoolValue)
			{
				JbMenu(client,0);
			}
		} 
		else if ( strcmp(info,"voteffa") == 0 ) 
		{
			FakeClientCommand(client, "sm_ffa");
			if(!gc_bClose.BoolValue)
			{
				JbMenu(client,0);
			}
		} 
		else if ( strcmp(info,"votezombie") == 0 ) 
		{
			FakeClientCommand(client, "sm_zombie");
			if(!gc_bClose.BoolValue)
			{
				JbMenu(client,0);
			}
		} 
		else if ( strcmp(info,"votezeus") == 0 )
		{
			FakeClientCommand(client, "sm_zeus");
			if(!gc_bClose.BoolValue)
			{
					JbMenu(client,0);
			}
		} 
		else if ( strcmp(info,"votecatch") == 0 )
		{
			FakeClientCommand(client, "sm_catch");
			if(!gc_bClose.BoolValue)
			{
				JbMenu(client,0);
			}
		}
		else if ( strcmp(info,"voteJihad") == 0 )
		{
			FakeClientCommand(client, "sm_jihad");
			if(!gc_bClose.BoolValue)
			{
				JbMenu(client,0);
			}
		}
		else if ( strcmp(info,"votenoscope") == 0 )
		{
			FakeClientCommand(client, "sm_noscope");
			if(!gc_bClose.BoolValue)
			{
				JbMenu(client,0);
			}
		}
		else if ( strcmp(info,"votehebattle") == 0 )
		{
			FakeClientCommand(client, "sm_hebattle");
			if(!gc_bClose.BoolValue)
			{
				JbMenu(client,0);
			}
		}
		else if ( strcmp(info,"voteduckhunt") == 0 )
		{
			FakeClientCommand(client, "sm_duckhunt");
			if(!gc_bClose.BoolValue)
			{
				JbMenu(client,0);
			}
		}
		else if ( strcmp(info,"votehide") == 0 )
		{
			FakeClientCommand(client, "sm_hide");
			if(!gc_bClose.BoolValue)
			{
				JbMenu(client,0);
			}
		}
		else if ( strcmp(info,"voteknife") == 0 )
		{
			FakeClientCommand(client, "sm_knifefight");
			if(!gc_bClose.BoolValue)
			{
				JbMenu(client,0);
			}
		}
		else if ( strcmp(info,"voteFreeday") == 0 )
		{
			FakeClientCommand(client, "sm_Freeday");
			if(!gc_bClose.BoolValue)
			{
				JbMenu(client,0);
			}
		}
	}
	else if(action == MenuAction_Cancel) 
	{
		if(selection == MenuCancel_ExitBack) 
		{
			JbMenu(client,0);
		}
	}
	else if (action == MenuAction_End)
	{
		delete daysmenu;
	}
}

// Event Days Set Menu

public Action SetEventDays(int client, int args)
{
	if(gc_bDays.BoolValue)
	{
			Menu daysmenu = new Menu(SetEventMenuHandler);
			
			char menuinfo18[255], menuinfo19[255], menuinfo20[255], menuinfo21[255], menuinfo22[255], menuinfo23[255], menuinfo24[255], menuinfo25[255], menuinfo26[255], menuinfo27[255], menuinfo28[255];
			char menuinfo17[255];
			
			Format(menuinfo18, sizeof(menuinfo18), "%T", "menu_event_Titlestart", LANG_SERVER);
			daysmenu.SetTitle(menuinfo18);
			
			if(g_bWar != null)
			{
				if(g_bWar.BoolValue)
				{
					Format(menuinfo19, sizeof(menuinfo19), "%T", "menu_war", LANG_SERVER);
					daysmenu.AddItem("setwar", menuinfo19);
				}
			}
			if(g_bFFA != null)
			{
				if(g_bFFA.BoolValue)
				{
					Format(menuinfo20, sizeof(menuinfo20), "%T", "menu_ffa", LANG_SERVER);
					daysmenu.AddItem("setffa", menuinfo20);
				}
			}
			if(g_bZombie != null)
			{
				if(g_bZombie.BoolValue)
				{
					Format(menuinfo21, sizeof(menuinfo21), "%T", "menu_zombie", LANG_SERVER);
					daysmenu.AddItem("setzombie", menuinfo21);
				}
			}
			if(g_bHide != null)
			{
				if(g_bHide.BoolValue)
				{
					Format(menuinfo22, sizeof(menuinfo22), "%T", "menu_hide", LANG_SERVER);
					daysmenu.AddItem("sethide", menuinfo22);
				}
			}
			if(g_bCatch != null)
			{
				if(g_bCatch.BoolValue)
				{
					Format(menuinfo23, sizeof(menuinfo23), "%T", "menu_catch", LANG_SERVER);
					daysmenu.AddItem("setcatch", menuinfo23);
				}
			}
			if(g_bJihad != null)
			{
				if(g_bJihad.BoolValue)
				{
					Format(menuinfo23, sizeof(menuinfo23), "%T", "menu_jihad", LANG_SERVER);
					daysmenu.AddItem("setJihad", menuinfo23);
				}
			}
			if(g_bHEbattle != null)
			{
				if(g_bHEbattle.BoolValue)
				{
					Format(menuinfo27, sizeof(menuinfo27), "%T", "menu_hebattle", LANG_SERVER);
					daysmenu.AddItem("sethebattle", menuinfo27);
				}
			}
			if(g_bNoScope != null)
			{
				if(g_bNoScope.BoolValue)
				{
					Format(menuinfo24, sizeof(menuinfo24), "%T", "menu_noscope", LANG_SERVER);
					daysmenu.AddItem("setnoscope", menuinfo24);
				}
			}
			if(g_bDuckHunt != null)
			{
				if(g_bDuckHunt.BoolValue)
				{
					Format(menuinfo25, sizeof(menuinfo25), "%T", "menu_duckhunt", LANG_SERVER);
					daysmenu.AddItem("setduckhunt", menuinfo25);
				}
			}
			if(g_bZeus != null)
			{
				if(g_bZeus.BoolValue)
				{
					Format(menuinfo17, sizeof(menuinfo17), "%T", "menu_zeus", LANG_SERVER);
					daysmenu.AddItem("setzeus", menuinfo17);
				}
			}
			if(g_bKnife != null)
			{
				if(g_bKnife.BoolValue)
				{
					Format(menuinfo28, sizeof(menuinfo28), "%T", "menu_knifefight", LANG_SERVER);
					daysmenu.AddItem("setknife", menuinfo28);
				}
			}
			if(g_bFreeday != null)
			{
				if(g_bFreeday.BoolValue)
				{
					Format(menuinfo26, sizeof(menuinfo26), "%T", "menu_Freeday", LANG_SERVER);
					daysmenu.AddItem("setFreeday", menuinfo26);
				}
			}
			daysmenu.ExitButton = true;
			daysmenu.ExitBackButton = true;
			daysmenu.Display(client, MENU_TIME_FOREVER);
	}
}

// Event Days Set Handler

public int SetEventMenuHandler(Menu daysmenu, MenuAction action, int client, int selection)
{
	if (action == MenuAction_Select)
	{
		char info[32];
		
		daysmenu.GetItem(selection, info, sizeof(info));
		
		if ( strcmp(info,"setwar") == 0 ) 
		{
			if (warden_iswarden(client) || (CheckCommandAccess(client, "sm_map", ADMFLAG_CHANGEMAP, true)))
			{
				FakeClientCommand(client, "sm_setwar");
				if(!gc_bClose.BoolValue)
				{
					JbMenu(client,0);
				}
			}
		} 
		else if ( strcmp(info,"setffa") == 0 ) 
		{
			if (warden_iswarden(client) || (CheckCommandAccess(client, "sm_map", ADMFLAG_CHANGEMAP, true)))
			{
				FakeClientCommand(client, "sm_setffa");
				if(!gc_bClose.BoolValue)
				{
					JbMenu(client,0);
				}
			}
		} 
		else if ( strcmp(info,"setzombie") == 0 ) 
		{
			if (warden_iswarden(client) || (CheckCommandAccess(client, "sm_map", ADMFLAG_CHANGEMAP, true)))
			{
				FakeClientCommand(client, "sm_setzombie");
				if(!gc_bClose.BoolValue)
				{
					JbMenu(client,0);
				}
			}
		} 
		else if ( strcmp(info,"setzeus") == 0 )
		{
			if (warden_iswarden(client) || (CheckCommandAccess(client, "sm_map", ADMFLAG_CHANGEMAP, true)))
			{
				FakeClientCommand(client, "sm_setzeus");
				if(!gc_bClose.BoolValue)
				{
					JbMenu(client,0);
				}
			}
		} 
		else if ( strcmp(info,"setcatch") == 0 )
		{
			if (warden_iswarden(client) || (CheckCommandAccess(client, "sm_map", ADMFLAG_CHANGEMAP, true)))
			{
				FakeClientCommand(client, "sm_setcatch");
				if(!gc_bClose.BoolValue)
				{
					JbMenu(client,0);
				}
			}
		}
		else if ( strcmp(info,"setJihad") == 0 )
		{
			if (warden_iswarden(client) || (CheckCommandAccess(client, "sm_map", ADMFLAG_CHANGEMAP, true)))
			{
				FakeClientCommand(client, "sm_setjihad");
				if(!gc_bClose.BoolValue)
				{
					JbMenu(client,0);
				}
			}
		}
		else if ( strcmp(info,"setnoscope") == 0 )
		{
			
			if (warden_iswarden(client) || (CheckCommandAccess(client, "sm_map", ADMFLAG_CHANGEMAP, true)))
			{
				FakeClientCommand(client, "sm_setnoscope");
				if(!gc_bClose.BoolValue)
				{
					JbMenu(client,0);
				}
			}
		}
		else if ( strcmp(info,"sethebattle") == 0 )
		{
			if (warden_iswarden(client) || (CheckCommandAccess(client, "sm_map", ADMFLAG_CHANGEMAP, true)))
			{
				FakeClientCommand(client, "sm_sethebattle");
				if(!gc_bClose.BoolValue)
				{
					JbMenu(client,0);
				}
			}
		}
		else if ( strcmp(info,"setduckhunt") == 0 )
		{
			if (warden_iswarden(client) || (CheckCommandAccess(client, "sm_map", ADMFLAG_CHANGEMAP, true)))
			{
				FakeClientCommand(client, "sm_setduckhunt");
				if(!gc_bClose.BoolValue)
				{
					JbMenu(client,0);
				}
			}
		}
		else if ( strcmp(info,"sethide") == 0 )
		{
			if (warden_iswarden(client) || (CheckCommandAccess(client, "sm_map", ADMFLAG_CHANGEMAP, true)))
			{
				FakeClientCommand(client, "sm_sethide");
				if(!gc_bClose.BoolValue)
				{
					JbMenu(client,0);
				}
			}
		}
		else if ( strcmp(info,"setknife") == 0 )
		{
			if (warden_iswarden(client) || (CheckCommandAccess(client, "sm_map", ADMFLAG_CHANGEMAP, true)))
			{
				FakeClientCommand(client, "sm_setknifefight");
				if(!gc_bClose.BoolValue)
				{
					JbMenu(client,0);
				}
			}
		}
		else if ( strcmp(info,"setFreeday") == 0 )
		{
			if (warden_iswarden(client) || (CheckCommandAccess(client, "sm_map", ADMFLAG_CHANGEMAP, true)))
			{
				FakeClientCommand(client, "sm_setFreeday");
				if(!gc_bClose.BoolValue)
				{
					JbMenu(client,0);
				}
			}
		}
	}
	else if(action == MenuAction_Cancel) 
	{
		if(selection == MenuCancel_ExitBack) 
		{
			JbMenu(client,0);
		}
	}
	else if (action == MenuAction_End)
	{
		delete daysmenu;
	}
}

//Switch Team Menu

public Action ChangeTeam(int client, int args)
{
			char info5[255], info6[255], info7[255];
			Menu menu1 = CreateMenu(changemenu);
			Format(info5, sizeof(info5), "%T", "warden_sure", LANG_SERVER);
			menu1.SetTitle(info5);
			Format(info6, sizeof(info6), "%T", "warden_no", LANG_SERVER);
			Format(info7, sizeof(info7), "%T", "warden_yes", LANG_SERVER);
			menu1.AddItem("1", info6);
			menu1.AddItem("0", info7);
			menu1.ExitBackButton = true;
			menu1.ExitButton = true;
			menu1.Display(client,MENU_TIME_FOREVER);
}

//Switch Team Handler

public int changemenu(Menu menu, MenuAction action, int client, int selection)
{
	if(action == MenuAction_Select)
	{
		char Item[11];
		menu.GetItem(selection,Item,sizeof(Item));
		int choice = StringToInt(Item);
		if(choice == 1)
		{
			JbMenu(client,0);
		}
		else if(choice == 0)
		{
			if (GetClientTeam(client) == CS_TEAM_T)
			{
			ClientCommand(client, "jointeam %i", CS_TEAM_CT);
			}
			if (GetClientTeam(client) == CS_TEAM_CT)
			{
			ClientCommand(client, "jointeam %i", CS_TEAM_T);
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
	else if (action == MenuAction_End)
	{
		delete menu;
	}
}