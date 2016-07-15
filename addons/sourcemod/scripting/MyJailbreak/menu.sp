//includes
#include <sourcemod>
#include <cstrike>
#include <warden>
#include <colors>
#include <autoexecconfig>
#include <smartjaildoors>
#include <myjailbreak>
#undef REQUIRE_PLUGIN
#include <lastrequest>
#define REQUIRE_PLUGIN

//Compiler Options
#pragma semicolon 1
#pragma newdecls required

//Booleans
int g_iCoolDown;

//ConVars
ConVar gc_bPlugin;
ConVar gc_bTerror;
ConVar gc_bCTerror;
ConVar gc_bWarden;
ConVar gc_bDays;
ConVar gc_bClose;
ConVar gc_bStart;
ConVar gc_bWelcome;
ConVar gc_bTeam;
ConVar gc_sCustomCommand;
ConVar gc_iCooldownDay;
ConVar gc_iCooldownStart;
ConVar gc_sAdminFlag;
ConVar gc_bSetW;
ConVar gc_bSetA;
ConVar gc_bVoting;


//3rd party Convars
ConVar g_bMath;
ConVar g_bCheck;
ConVar g_bFF;
ConVar g_bZeus;
ConVar g_bCowboy;
ConVar g_bRules;
ConVar g_bsetFF;
ConVar g_bWar;
ConVar g_bMute;
ConVar g_bSuicideBomber;
ConVar g_bKnife;
ConVar g_bFFA;
ConVar g_bExtend;
ConVar g_bLaser;
ConVar g_bPainter;
ConVar g_bNoBlock;
ConVar g_bZombie;
ConVar g_bNoScope;
ConVar g_bHEbattle;
ConVar g_bHide;
ConVar g_bCatch;
ConVar g_bTorch;
ConVar g_bDrunk;
ConVar g_bFreeday;
ConVar g_bDuckHunt;
ConVar g_bCountdown;
ConVar g_bVote;
ConVar g_bGuns;
ConVar g_bGunsT;
ConVar g_bGunsCT;
ConVar g_bOpen;
ConVar g_bRandom;
ConVar g_bRequest;
ConVar g_bWarden;
ConVar g_bSparks;
ConVar g_bPlayerFreeday;
ConVar g_bDealDamage;
ConVar gc_sAdminFlagBulletSparks;
ConVar gc_sAdminFlagLaser;
ConVar gc_sAdminFlagPainter;

//Strings
char g_sCustomCommand[64];

char g_sAdminFlagBulletSparks[32];
char g_sAdminFlagLaser[32];
char g_sAdminFlagPainter[32];
char g_sAdminFlag[32];


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
	RegConsoleCmd("sm_voteday", VotingMenu, "opens the vote menu");
	RegConsoleCmd("sm_votedays", VotingMenu, "opens the vote menu");
	RegConsoleCmd("sm_voteeventdays", VotingMenu, "opens the vote menu");
	
	//AutoExecConfig
	AutoExecConfig_SetFile("Menu", "MyJailbreak");
	AutoExecConfig_SetCreateFile(true);
	
	AutoExecConfig_CreateConVar("sm_menu_version", PLUGIN_VERSION, "The version of the SourceMod plugin MyJailbreak - Menu", FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_DONTRECORD);
	gc_bPlugin = AutoExecConfig_CreateConVar("sm_menu_enable", "1", "0 - disabled, 1 - enable jailbrek menu", _, true,  0.0, true, 1.0);
	gc_sCustomCommand = AutoExecConfig_CreateConVar("sm_menu_cmd", "panel", "Set your custom chat command for open menu. no need for sm_ or !");
	gc_bCTerror = AutoExecConfig_CreateConVar("sm_menu_ct", "1", "0 - disabled, 1 - enable ct jailbreak menu", _, true,  0.0, true, 1.0);
	gc_bTerror = AutoExecConfig_CreateConVar("sm_menu_t", "1", "0 - disabled, 1 - enable t jailbreak menu", _, true,  0.0, true, 1.0);
	gc_bWarden = AutoExecConfig_CreateConVar("sm_menu_warden", "1", "0 - disabled, 1 - enable warden jailbreak menu", _, true,  0.0, true, 1.0);
	gc_bDays = AutoExecConfig_CreateConVar("sm_menu_days", "1", "0 - disabled, 1 - enable vote/set eventdays menu", _, true,  0.0, true, 1.0);
	gc_bClose = AutoExecConfig_CreateConVar("sm_menu_close", "0", "0 - disabled, 1 - enable close menu after action", _, true,  0.0, true, 1.0);
	gc_bStart = AutoExecConfig_CreateConVar("sm_menu_start", "1", "0 - disabled, 1 - enable open menu on every roundstart", _, true,  0.0, true, 1.0);
	gc_bTeam = AutoExecConfig_CreateConVar("sm_menu_team", "1", "0 - disabled, 1 - enable join team on menu", _, true,  0.0, true, 1.0);
	gc_bWelcome = AutoExecConfig_CreateConVar("sm_menu_welcome", "1", "Show welcome message to newly connected users.", _, true,  0.0, true, 1.0);
	gc_bVoting = AutoExecConfig_CreateConVar("sm_menu_voteday", "1", "0 - disabled, 1 - enable voteing for a eventday", _, true,  0.0, true, 1.0);
	gc_sAdminFlag = AutoExecConfig_CreateConVar("sm_menu_flag", "g", "Set flag for admin/vip to start a voting & get admin menu");
	gc_bSetW = AutoExecConfig_CreateConVar("sm_menu_voteday_warden", "1", "0 - disabled, 1 - allow warden to start a voting", _, true,  0.0, true, 1.0);
	gc_bSetA = AutoExecConfig_CreateConVar("sm_menu_voteday_admin", "1", "0 - disabled, 1 - allow admin/vip  to start a voting", _, true,  0.0, true, 1.0);
	gc_iCooldownDay = AutoExecConfig_CreateConVar("sm_menu_voteday_cooldown_day", "3", "Rounds cooldown after a voting until voting can be start again", _, true,  0.0);
	gc_iCooldownStart = AutoExecConfig_CreateConVar("sm_menu_voteday_cooldown_start", "3", "Rounds until voting can be start after mapchange.", _, true, 0.0);
	
	AutoExecConfig_ExecuteFile();
	AutoExecConfig_CleanFile();
	
	//Hooks
	HookEvent("player_spawn", Event_OnPlayerSpawn);
	HookEvent("round_start", RoundStart);
	HookConVarChange(gc_sCustomCommand, OnSettingChanged);
	HookConVarChange(gc_sAdminFlag, OnSettingChanged);
	
	//Find
	gc_sAdminFlag.GetString(g_sAdminFlag , sizeof(g_sAdminFlag));
	gc_sCustomCommand.GetString(g_sCustomCommand , sizeof(g_sCustomCommand));
	
}

public int OnSettingChanged(Handle convar, const char[] oldValue, const char[] newValue)
{
	if(convar == gc_sCustomCommand)
	{
		strcopy(g_sCustomCommand, sizeof(g_sCustomCommand), newValue);
		char sBufferCMD[64];
		Format(sBufferCMD, sizeof(sBufferCMD), "sm_%s", g_sCustomCommand);
		if(GetCommandFlags(sBufferCMD) == INVALID_FCVAR_FLAGS)
			RegConsoleCmd(sBufferCMD, JbMenu, "opens the menu depends on players team/rank");
	}
	else if(convar == gc_sAdminFlag)
	{
		strcopy(g_sAdminFlag, sizeof(g_sAdminFlag), newValue);
	}
}

//FindConVar

public void OnConfigsExecuted()
{
	g_bWarden = FindConVar("sm_warden_enable");
	g_bRules = FindConVar("sm_hosties_rules_enable");
	g_bCheck = FindConVar("sm_hosties_checkplayers_enable");
	g_bMath = FindConVar("sm_warden_math");
	g_bNoBlock = FindConVar("sm_warden_noblock");
	g_bExtend = FindConVar("sm_warden_extend");
	g_bWar = FindConVar("sm_war_enable");
	g_bZeus = FindConVar("sm_zeus_enable");
	g_bFFA = FindConVar("sm_ffa_enable");
	g_bMute = FindConVar("sm_warden_mute");
	g_bTorch = FindConVar("sm_torch_enable");
	g_bPainter = FindConVar("sm_warden_painter");
	g_bLaser = FindConVar("sm_warden_laser");
	g_bSparks = FindConVar("sm_warden_bulletsparks");
	g_bZombie = FindConVar("sm_zombie_enable");
	g_bDrunk = FindConVar("sm_drunk_enable");
	g_bCowboy = FindConVar("sm_cowboy_enable");
	g_bNoScope = FindConVar("sm_noscope_enable");
	g_bHide = FindConVar("sm_hide_enable");
	g_bKnife = FindConVar("sm_knifefight_enable");
	g_bSuicideBomber = FindConVar("sm_suicidebomber_enable");
	g_bCatch = FindConVar("sm_catch_enable");
	g_bHEbattle = FindConVar("sm_hebattle_enable");
	g_bFreeday = FindConVar("sm_freeday_enable");
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
	g_bRequest = FindConVar("sm_request_enable");
	g_bDealDamage = FindConVar("sm_dealdamage_enable");
	g_bPlayerFreeday = FindConVar("sm_freekill_freeday_victim");
	gc_sAdminFlagBulletSparks = FindConVar("sm_warden_bulletsparks_flag");
	gc_sAdminFlagLaser = FindConVar("sm_warden_laser_flag");
	gc_sAdminFlagPainter = FindConVar("sm_warden_painter_flag");
	
	gc_sAdminFlagLaser.GetString(g_sAdminFlagLaser, sizeof(g_sAdminFlagLaser));
	gc_sAdminFlagPainter.GetString(g_sAdminFlagPainter, sizeof(g_sAdminFlagPainter));
	gc_sAdminFlagBulletSparks.GetString(g_sAdminFlagBulletSparks, sizeof(g_sAdminFlagBulletSparks));
	
	char sBufferCMD[64];
	Format(sBufferCMD, sizeof(sBufferCMD), "sm_%s", g_sCustomCommand);
	if(GetCommandFlags(sBufferCMD) == INVALID_FCVAR_FLAGS)
		RegConsoleCmd(sBufferCMD, JbMenu, "opens the menu depends on players team/rank");
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
		CPrintToChat(client, "%t %t", "menu_tag", "menu_info");
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
		if(IsValidClient(client,false,true))
		{
			char menuinfo[255];
			
			Format(menuinfo, sizeof(menuinfo), "%T", "menu_info_title", client);
			
			Menu mainmenu = new Menu(JBMenuHandler);
			mainmenu.SetTitle(menuinfo);
			if (warden_iswarden(client))
			{
				if(gc_bWarden.BoolValue) // HERE STARTS THE WARDEN MENU
				{
					/* Warden PLACEHOLDER
					Format(menuinfo, sizeof(menuinfo), "%T", "menu_PLACEHOLDER", client);
					mainmenu.AddItem("PLACEHOLDER", menuinfo);
					*/
					if(g_bGuns != null)
					{
						if(g_bGuns.BoolValue)
						{
							if(g_bGunsCT.BoolValue)
							{
								Format(menuinfo, sizeof(menuinfo), "%T", "menu_guns", client);
								mainmenu.AddItem("guns", menuinfo);
							}
						}
					}
					if(g_bOpen != null)
					{
						if(g_bOpen.BoolValue && SJD_IsCurrentMapConfigured())
						{
							Format(menuinfo, sizeof(menuinfo), "%T", "menu_opencell", client);
							mainmenu.AddItem("cellopen", menuinfo);
							Format(menuinfo, sizeof(menuinfo), "%T", "menu_closecell", client);
							mainmenu.AddItem("cellclose", menuinfo);
						}
					}
					if(g_bCountdown != null)
					{
						if(g_bCountdown.BoolValue)
						{
							Format(menuinfo, sizeof(menuinfo), "%T", "menu_countdown", client);
							mainmenu.AddItem("countdown", menuinfo);
						}
					}
					if(g_bPlayerFreeday != null)
					{
						if(g_bPlayerFreeday.BoolValue)
						{
							Format(menuinfo, sizeof(menuinfo), "%T", "menu_playerfreeday", client);
							mainmenu.AddItem("playerfreeday", menuinfo);
						}
					}
					if(g_bMath != null)
					{
						if(g_bMath.BoolValue)
						{
							Format(menuinfo, sizeof(menuinfo), "%T", "menu_math", client);
							mainmenu.AddItem("math", menuinfo);
						}
					}
					if(gc_bVoting.BoolValue)
					{
						Format(menuinfo, sizeof(menuinfo), "%T", "menu_voteday", client);
						mainmenu.AddItem("voteday", menuinfo);
					}
					if(gc_bDays.BoolValue)
					{
						Format(menuinfo, sizeof(menuinfo), "%T", "menu_seteventdays", client);
						mainmenu.AddItem("setdays", menuinfo);
					}
					if(g_bSparks != null)
					{
						if(g_bSparks.BoolValue && CheckVipFlag(client,g_sAdminFlagBulletSparks))
						{
							Format(menuinfo, sizeof(menuinfo), "%T", "menu_sparks", client);
							mainmenu.AddItem("sparks", menuinfo);
						}
					}
					if(g_bPainter != null)
					{
						if(g_bPainter.BoolValue && CheckVipFlag(client,g_sAdminFlagPainter))
						{
							Format(menuinfo, sizeof(menuinfo), "%T", "menu_painter", client);
							mainmenu.AddItem("painter", menuinfo);
						}
					}
					if(g_bLaser != null)
					{
						if(g_bLaser.BoolValue && CheckVipFlag(client,g_sAdminFlagLaser))
						{
							Format(menuinfo, sizeof(menuinfo), "%T", "menu_laser", client);
							mainmenu.AddItem("laser", menuinfo);
						}
					}
					if(g_bExtend != null)
					{
						if(g_bExtend.BoolValue)
						{
							Format(menuinfo, sizeof(menuinfo), "%T", "menu_extend", client);
							mainmenu.AddItem("extend", menuinfo);
						}
					}
					if(g_bMute != null)
					{
						if(g_bMute.BoolValue)
						{
							Format(menuinfo, sizeof(menuinfo), "%T", "menu_mute", client);
							mainmenu.AddItem("mute", menuinfo);
						}
					}
					if(g_bCheck != null)
					{
						if(g_bCheck.BoolValue)
						{
							Format(menuinfo, sizeof(menuinfo), "%T", "menu_check", client);
							mainmenu.AddItem("check", menuinfo);
						}
					}
					if(g_bsetFF != null)
					{
						if(g_bsetFF.BoolValue)
						{
							if(!g_bFF.BoolValue)
							{
								Format(menuinfo, sizeof(menuinfo), "%T", "menu_ffon", client);
								mainmenu.AddItem("setff", menuinfo);
							}
							else
							{
								Format(menuinfo, sizeof(menuinfo), "%T", "menu_ffoff", client);
								mainmenu.AddItem("setff", menuinfo);
							}
						}
					}
					if(g_bNoBlock != null)
					{
						if(g_bNoBlock.BoolValue)
						{
							Format(menuinfo, sizeof(menuinfo), "%T", "menu_noblock", client);
							mainmenu.AddItem("noblock", menuinfo);
						}
					}
					if(g_bRandom != null)
					{
						if(g_bRandom.BoolValue)
						{
							Format(menuinfo, sizeof(menuinfo), "%T", "menu_randomdead", client);
							mainmenu.AddItem("kill", menuinfo);
						}
					}
					Format(menuinfo, sizeof(menuinfo), "%T", "menu_unwarden", client);
					mainmenu.AddItem("unwarden", menuinfo);
				}// HERE END THE WARDEN MENU
			}
			else if(GetClientTeam(client) == CS_TEAM_CT) // HERE STARTS THE CT MENU
			{
				if(gc_bCTerror.BoolValue)
				{
					/* CT PLACEHOLDER
					Format(menuinfo, sizeof(menuinfo), "%T", "menu_PLACEHOLDER", client);
					mainmenu.AddItem("PLACEHOLDER", menuinfo);
					*/
					if(g_bGuns != null)
					{
						if(g_bGuns.BoolValue)
						{
							if(g_bGunsCT.BoolValue)
							{
								Format(menuinfo, sizeof(menuinfo), "%T", "menu_guns", client);
								mainmenu.AddItem("guns", menuinfo);
							}
						}
					}
					if(g_bWarden != null)
					{
						if(!warden_exist() && IsPlayerAlive(client))
						{
							if(g_bWarden.BoolValue)
							{
								Format(menuinfo, sizeof(menuinfo), "%T", "menu_getwarden", client);
								mainmenu.AddItem("getwarden", menuinfo);
							}
						}
					}
					char EventDay[64];
					GetEventDay(EventDay);
					
					if(StrEqual(EventDay, "none", false)) //is an other event running or set?
					{
						if(gc_bDays.BoolValue)
						{
							Format(menuinfo, sizeof(menuinfo), "%T", "menu_voteeventdays", client);
							mainmenu.AddItem("votedays", menuinfo);
						}
					}
					
					if(g_bCheck != null)
					{
						if(g_bCheck.BoolValue && IsPlayerAlive(client))
						{
							Format(menuinfo, sizeof(menuinfo), "%T", "menu_check", client);
							mainmenu.AddItem("check", menuinfo);
						}
					}
					if(gc_bTeam.BoolValue)
					{
						Format(menuinfo, sizeof(menuinfo), "%T", "menu_joint", client);
						mainmenu.AddItem("ChangeTeam", menuinfo);
					}
				}// HERE END THE CT MENU
			}
			else if(GetClientTeam(client) == CS_TEAM_T) // HERE STARTS THE T MENU
			{
				if(gc_bTerror.BoolValue)
				{
					/* TERROR PLACEHOLDER
					Format(menuinfo, sizeof(menuinfo), "%T", "menu_PLACEHOLDER", client);
					mainmenu.AddItem("PLACEHOLDER", menuinfo);
					*/
					if(g_bGuns != null)
					{
						if(g_bGuns.BoolValue)
						{
							if(g_bGunsT.BoolValue)
							{
								Format(menuinfo, sizeof(menuinfo), "%T", "menu_guns", client);
								mainmenu.AddItem("guns", menuinfo);
							}
						}
					}
					if(g_bRequest != null)
					{
						if(g_bRequest.BoolValue)
						{
							Format(menuinfo, sizeof(menuinfo), "%T", "menu_request", client);
							mainmenu.AddItem("request", menuinfo);
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
									Format(menuinfo, sizeof(menuinfo), "%T", "menu_votewarden", client);
									mainmenu.AddItem("votewarden", menuinfo);
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
							Format(menuinfo, sizeof(menuinfo), "%T", "menu_voteeventdays", client);
							mainmenu.AddItem("votedays", menuinfo);
						}
					}
					if(gc_bTeam.BoolValue)
					{
						if(GetCommandFlags("sm_guard") != INVALID_FCVAR_FLAGS)
						{
							Format(menuinfo, sizeof(menuinfo), "%T", "menu_guardct", client);
							mainmenu.AddItem("guard", menuinfo);
						}
						else
						{
							Format(menuinfo, sizeof(menuinfo), "%T", "menu_joinct", client);
							mainmenu.AddItem("ChangeTeamCT", menuinfo);
						}
					}
				}
			}
			if(g_bRules != null)
			{
				if(g_bRules.BoolValue)
				{
					Format(menuinfo, sizeof(menuinfo), "%T", "menu_rules", client);
					mainmenu.AddItem("rules", menuinfo);
				}
			}
			if (CheckVipFlag(client,g_sAdminFlag))
			{
				char EventDay[64];
				GetEventDay(EventDay);
				
				if(StrEqual(EventDay, "none", false)) //is an other event running or set?
				{
					if (!warden_iswarden(client))
					{
						if(g_bPlayerFreeday != null)
						{
							if(g_bPlayerFreeday.BoolValue)
							{
								Format(menuinfo, sizeof(menuinfo), "%T", "menu_playerfreeday", client);
								mainmenu.AddItem("playerfreeday", menuinfo);
							}
						}
						if(gc_bVoting.BoolValue)
						{
							Format(menuinfo, sizeof(menuinfo), "%T", "menu_voteday", client);
							mainmenu.AddItem("voteday", menuinfo);
						}
						if(gc_bDays.BoolValue)
						{
							Format(menuinfo, sizeof(menuinfo), "%T", "menu_seteventdays", client);
							mainmenu.AddItem("setdays", menuinfo);
						}
					}
				}
				if(g_bWarden != null)
				{
					if(g_bWarden.BoolValue)
					{
						if(warden_exist())
						{
							Format(menuinfo, sizeof(menuinfo), "%T", "menu_removewarden", client);
							mainmenu.AddItem("removewarden", menuinfo);
						}
						Format(menuinfo, sizeof(menuinfo), "%T", "menu_setwarden", client);
						mainmenu.AddItem("setwarden", menuinfo);
					}
				}
				Format(menuinfo, sizeof(menuinfo), "%T", "menu_admin", client);
				mainmenu.AddItem("admin", menuinfo);
			}
			mainmenu.ExitButton = true;
			mainmenu.Display(client, MENU_TIME_FOREVER);
		}
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
		/* Command PLACEHOLDER
		else if ( strcmp(info,"PLACEHOLDER") == 0 ) 
		{
			FakeClientCommand(client, "sm_YOURCOMMAND");
		}
		*/
		else if ( strcmp(info,"request") == 0 ) 
		{
			FakeClientCommand(client, "sm_request");
		}
		else if ( strcmp(info,"lastR") == 0 ) 
		{
			FakeClientCommand(client, "sm_lr");
		}
		else if ( strcmp(info,"setwarden") == 0 ) 
		{
			FakeClientCommand(client, "sm_sw");
		}
		else if ( strcmp(info,"rules") == 0 ) 
		{
			FakeClientCommand(client, "sm_rules");
		}
		else if ( strcmp(info,"guns") == 0 ) 
		{
			FakeClientCommand(client, "sm_guns");
		}
		else if ( strcmp(info,"playerfreeday") == 0 ) 
		{
			FakeClientCommand(client, "sm_givefreeday");
		}
		else if ( strcmp(info,"votedays") == 0 ) 
		{
			FakeClientCommand(client, "sm_days");
		}
		else if ( strcmp(info,"voteday") == 0 ) 
		{
			FakeClientCommand(client, "sm_voteday");
		}
		else if ( strcmp(info,"setdays") == 0 ) 
		{
			FakeClientCommand(client, "sm_setdays");
		}
		else if ( strcmp(info,"laser") == 0 ) 
		{
			FakeClientCommand(client, "sm_laser");
		}
		else if ( strcmp(info,"painter") == 0 ) 
		{
			FakeClientCommand(client, "sm_painter");
		}
		else if ( strcmp(info,"extend") == 0 ) 
		{
			FakeClientCommand(client, "sm_extend");
		}
		else if ( strcmp(info,"admin") == 0 ) 
		{
			FakeClientCommand(client, "sm_admin");
		}
		else if ( strcmp(info,"countdown") == 0 ) 
		{
			FakeClientCommand(client, "sm_cdmenu");
		}
		else if ( strcmp(info,"mute") == 0 ) 
		{
			FakeClientCommand(client, "sm_wmute");
		}
		else if ( strcmp(info,"kill") == 0 ) 
		{
			FakeClientCommand(client, "sm_killrandom");
		}
		else if ( strcmp(info,"check") == 0 ) 
		{
			FakeClientCommand(client, "sm_checkplayers");
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
		else if ( strcmp(info,"removewarden") == 0 ) 
		{
			FakeClientCommand(client, "sm_rw");
			if(!gc_bClose.BoolValue)
			{
				JbMenu(client,0);
			}
		}
		else if ( strcmp(info,"sparks") == 0 ) 
		{
			FakeClientCommand(client, "sm_sparks");
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
		else if ( strcmp(info,"math") == 0 ) 
		{
			FakeClientCommand(client, "sm_math");
			if(!gc_bClose.BoolValue)
			{
				JbMenu(client,0);
			}
		}
		else if ( strcmp(info,"cellclose") == 0 ) 
		{
			FakeClientCommand(client, "sm_close");
			if(!gc_bClose.BoolValue)
			{
				JbMenu(client,0);
			}
		}
		else if ( strcmp(info,"cellopen") == 0 ) 
		{
			FakeClientCommand(client, "sm_open");
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
		else if ( strcmp(info,"guard") == 0 ) 
		{
			FakeClientCommand(client, "sm_guard");
			if(!gc_bClose.BoolValue)
			{
				JbMenu(client,0);
			}
		}
		else if ( strcmp(info,"votewarden") == 0 ) 
		{
			FakeClientCommand(client, "sm_votewarden");
			if(!gc_bClose.BoolValue)
			{
				JbMenu(client,0);
			}
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
			
			char menuinfo[255];
			
			Format(menuinfo, sizeof(menuinfo), "%T", "menu_event_Titlevote", client);
			daysmenu.SetTitle(menuinfo);
			
			if(g_bWar != null)
			{
				if(g_bWar.BoolValue)
				{
					Format(menuinfo, sizeof(menuinfo), "%T", "menu_war", client);
					daysmenu.AddItem("votewar", menuinfo);
				}
			}
			if(g_bFFA != null)
			{
				if(g_bFFA.BoolValue)
				{
					Format(menuinfo, sizeof(menuinfo), "%T", "menu_ffa", client);
					daysmenu.AddItem("voteffa", menuinfo);
				}
			}
			if(g_bZombie != null)
			{
				if(g_bZombie.BoolValue)
				{
					Format(menuinfo, sizeof(menuinfo), "%T", "menu_zombie", client);
					daysmenu.AddItem("votezombie", menuinfo);
				}
			}
			if(g_bHide != null)
			{
				if(g_bHide.BoolValue)
				{
					Format(menuinfo, sizeof(menuinfo), "%T", "menu_hide", client);
					daysmenu.AddItem("votehide", menuinfo);
				}
			}
			if(g_bCatch != null)
			{
				if(g_bCatch.BoolValue)
				{
					Format(menuinfo, sizeof(menuinfo), "%T", "menu_catch", client);
					daysmenu.AddItem("votecatch", menuinfo);
				}
			}
			if(g_bSuicideBomber != null)
			{
				if(g_bSuicideBomber.BoolValue)
				{
					Format(menuinfo, sizeof(menuinfo), "%T", "menu_suicidebomber", client);
					daysmenu.AddItem("voteSuicideBomber", menuinfo);
				}
			}
			if(g_bHEbattle != null)
			{
				if(g_bHEbattle.BoolValue)
				{
					Format(menuinfo, sizeof(menuinfo), "%T", "menu_hebattle", client);
					daysmenu.AddItem("votehebattle", menuinfo);
				}
			}
			if(g_bNoScope != null)
			{
				if(g_bNoScope.BoolValue)
				{
					Format(menuinfo, sizeof(menuinfo), "%T", "menu_noscope", client);
					daysmenu.AddItem("votenoscope", menuinfo);
				}
			}
			if(g_bDuckHunt != null)
			{
				if(g_bDuckHunt.BoolValue)
				{
					Format(menuinfo, sizeof(menuinfo), "%T", "menu_duckhunt", client);
					daysmenu.AddItem("voteduckhunt", menuinfo);
				}
			}
			if(g_bZeus != null)
			{
				if(g_bZeus.BoolValue)
				{
					Format(menuinfo, sizeof(menuinfo), "%T", "menu_zeus", client);
					daysmenu.AddItem("votezeus", menuinfo);
				}
			}
			if(g_bDealDamage != null)
			{
				if(g_bDealDamage.BoolValue)
				{
					Format(menuinfo, sizeof(menuinfo), "%T", "menu_dealdamge", client);
					daysmenu.AddItem("votedeal", menuinfo);
				}
			}
			if(g_bDrunk != null)
			{
				if(g_bDrunk.BoolValue)
				{
					Format(menuinfo, sizeof(menuinfo), "%T", "menu_drunk", client);
					daysmenu.AddItem("votedrunk", menuinfo);
				}
			}
			if(g_bKnife != null)
			{
				if(g_bKnife.BoolValue)
				{
					Format(menuinfo, sizeof(menuinfo), "%T", "menu_knifefight", client);
					daysmenu.AddItem("voteknife", menuinfo);
				}
			}
			if(g_bTorch != null)
			{
				if(g_bTorch.BoolValue)
				{
					Format(menuinfo, sizeof(menuinfo), "%T", "menu_torch", client);
					daysmenu.AddItem("votetorch", menuinfo);
				}
			}
			if(g_bCowboy != null)
			{
				if(g_bCowboy.BoolValue)
				{
					Format(menuinfo, sizeof(menuinfo), "%T", "menu_cowboy", client);
					daysmenu.AddItem("votecowboy", menuinfo);
				}
			}
			if(g_bFreeday != null)
			{
				if(g_bFreeday.BoolValue)
				{
					Format(menuinfo, sizeof(menuinfo), "%T", "menu_Freeday", client);
					daysmenu.AddItem("voteFreeday", menuinfo);
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
		else if ( strcmp(info,"votedrunk") == 0 )
		{
			FakeClientCommand(client, "sm_drunk");
			if(!gc_bClose.BoolValue)
			{
				JbMenu(client,0);
			}
		}
		else if ( strcmp(info,"votecowboy") == 0 )
		{
			FakeClientCommand(client, "sm_cowboy");
			if(!gc_bClose.BoolValue)
			{
				JbMenu(client,0);
			}
		}
		else if ( strcmp(info,"voteSuicideBomber") == 0 )
		{
			FakeClientCommand(client, "sm_suicidebomber");
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
		else if ( strcmp(info,"votetorch") == 0 )
		{
			FakeClientCommand(client, "sm_torch");
			if(!gc_bClose.BoolValue)
			{
				JbMenu(client,0);
			}
		}
		else if ( strcmp(info,"votedeal") == 0 )
		{
			FakeClientCommand(client, "sm_dealdamage");
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
	if(gc_bDays.BoolValue && (warden_iswarden(client) || CheckVipFlag(client,g_sAdminFlag)))
	{
			Menu daysmenu = new Menu(SetEventMenuHandler);
			
			char menuinfo[255];
			
			Format(menuinfo, sizeof(menuinfo), "%T", "menu_event_Titlestart", client);
			daysmenu.SetTitle(menuinfo);
			
			if(g_bWar != null)
			{
				if(g_bWar.BoolValue)
				{
					Format(menuinfo, sizeof(menuinfo), "%T", "menu_war", client);
					daysmenu.AddItem("setwar", menuinfo);
				}
			}
			if(g_bFFA != null)
			{
				if(g_bFFA.BoolValue)
				{
					Format(menuinfo, sizeof(menuinfo), "%T", "menu_ffa", client);
					daysmenu.AddItem("setffa", menuinfo);
				}
			}
			if(g_bZombie != null)
			{
				if(g_bZombie.BoolValue)
				{
					Format(menuinfo, sizeof(menuinfo), "%T", "menu_zombie", client);
					daysmenu.AddItem("setzombie", menuinfo);
				}
			}
			if(g_bHide != null)
			{
				if(g_bHide.BoolValue)
				{
					Format(menuinfo, sizeof(menuinfo), "%T", "menu_hide", client);
					daysmenu.AddItem("sethide", menuinfo);
				}
			}
			if(g_bCatch != null)
			{
				if(g_bCatch.BoolValue)
				{
					Format(menuinfo, sizeof(menuinfo), "%T", "menu_catch", client);
					daysmenu.AddItem("setcatch", menuinfo);
				}
			}
			if(g_bSuicideBomber != null)
			{
				if(g_bSuicideBomber.BoolValue)
				{
					Format(menuinfo, sizeof(menuinfo), "%T", "menu_suicidebomber", client);
					daysmenu.AddItem("setSuicideBomber", menuinfo);
				}
			}
			if(g_bHEbattle != null)
			{
				if(g_bHEbattle.BoolValue)
				{
					Format(menuinfo, sizeof(menuinfo), "%T", "menu_hebattle", client);
					daysmenu.AddItem("sethebattle", menuinfo);
				}
			}
			if(g_bNoScope != null)
			{
				if(g_bNoScope.BoolValue)
				{
					Format(menuinfo, sizeof(menuinfo), "%T", "menu_noscope", client);
					daysmenu.AddItem("setnoscope", menuinfo);
				}
			}
			if(g_bDuckHunt != null)
			{
				if(g_bDuckHunt.BoolValue)
				{
					Format(menuinfo, sizeof(menuinfo), "%T", "menu_duckhunt", client);
					daysmenu.AddItem("setduckhunt", menuinfo);
				}
			}
			if(g_bDealDamage != null)
			{
				if(g_bDealDamage.BoolValue)
				{
					Format(menuinfo, sizeof(menuinfo), "%T", "menu_dealdamge", client);
					daysmenu.AddItem("setdeal", menuinfo);
				}
			}
			if(g_bZeus != null)
			{
				if(g_bZeus.BoolValue)
				{
					Format(menuinfo, sizeof(menuinfo), "%T", "menu_zeus", client);
					daysmenu.AddItem("setzeus", menuinfo);
				}
			}
			if(g_bDrunk != null)
			{
				if(g_bDrunk.BoolValue)
				{
					Format(menuinfo, sizeof(menuinfo), "%T", "menu_drunk", client);
					daysmenu.AddItem("setdrunk", menuinfo);
				}
			}
			if(g_bKnife != null)
			{
				if(g_bKnife.BoolValue)
				{
					Format(menuinfo, sizeof(menuinfo), "%T", "menu_knifefight", client);
					daysmenu.AddItem("setknife", menuinfo);
				}
			}
			if(g_bTorch != null)
			{
				if(g_bTorch.BoolValue)
				{
					Format(menuinfo, sizeof(menuinfo), "%T", "menu_torch", client);
					daysmenu.AddItem("settorch", menuinfo);
				}
			}
			if(g_bCowboy != null)
			{
				if(g_bCowboy.BoolValue)
				{
					Format(menuinfo, sizeof(menuinfo), "%T", "menu_cowboy", client);
					daysmenu.AddItem("setcowboy", menuinfo);
				}
			}
			if(g_bFreeday != null)
			{
				if(g_bFreeday.BoolValue)
				{
					Format(menuinfo, sizeof(menuinfo), "%T", "menu_Freeday", client);
					daysmenu.AddItem("setFreeday", menuinfo);
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
			FakeClientCommand(client, "sm_setwar");
			if(!gc_bClose.BoolValue)
			{
				JbMenu(client,0);
			}
		}
		else if ( strcmp(info,"setffa") == 0 ) 
		{
			FakeClientCommand(client, "sm_setffa");
			if(!gc_bClose.BoolValue)
			{
				JbMenu(client,0);
			}
		}
		else if ( strcmp(info,"setzombie") == 0 ) 
		{
			FakeClientCommand(client, "sm_setzombie");
			if(!gc_bClose.BoolValue)
			{
				JbMenu(client,0);
			}
		}
		else if ( strcmp(info,"settorch") == 0 )
		{
			FakeClientCommand(client, "sm_settorch");
			if(!gc_bClose.BoolValue)
			{
				JbMenu(client,0);
			}
		}
		else if ( strcmp(info,"setcowboy") == 0 )
		{
			FakeClientCommand(client, "sm_setcowboy");
			if(!gc_bClose.BoolValue)
			{
				JbMenu(client,0);
			}
		}
		else if ( strcmp(info,"setzeus") == 0 )
		{
			FakeClientCommand(client, "sm_setzeus");
			if(!gc_bClose.BoolValue)
			{
				JbMenu(client,0);
			}
		}
		else if ( strcmp(info,"setdeal") == 0 )
		{
			FakeClientCommand(client, "sm_setdealdamage");
			if(!gc_bClose.BoolValue)
			{
				JbMenu(client,0);
			}
		} 
		else if ( strcmp(info,"setcatch") == 0 )
		{
			FakeClientCommand(client, "sm_setcatch");
			if(!gc_bClose.BoolValue)
			{
				JbMenu(client,0);
			}
		} 
		else if ( strcmp(info,"setdrunk") == 0 )
		{
			FakeClientCommand(client, "sm_setdrunk");
			if(!gc_bClose.BoolValue)
			{
				JbMenu(client,0);
			}
		}
		else if ( strcmp(info,"setSuicideBomber") == 0 )
		{
			FakeClientCommand(client, "sm_setsuicidebomber");
			if(!gc_bClose.BoolValue)
			{
				JbMenu(client,0);
			}
		}
		else if ( strcmp(info,"setnoscope") == 0 )
		{
			FakeClientCommand(client, "sm_setnoscope");
			if(!gc_bClose.BoolValue)
			{
				JbMenu(client,0);
			}
		}
		else if ( strcmp(info,"sethebattle") == 0 )
		{
			FakeClientCommand(client, "sm_sethebattle");
			if(!gc_bClose.BoolValue)
			{
				JbMenu(client,0);
			}
		}
		else if ( strcmp(info,"setduckhunt") == 0 )
		{
			FakeClientCommand(client, "sm_setduckhunt");
			if(!gc_bClose.BoolValue)
			{
				JbMenu(client,0);
			}
		}
		else if ( strcmp(info,"sethide") == 0 )
		{
			FakeClientCommand(client, "sm_sethide");
			if(!gc_bClose.BoolValue)
			{
				JbMenu(client,0);
			}
		}
		else if ( strcmp(info,"setknife") == 0 )
		{
			FakeClientCommand(client, "sm_setknifefight");
			if(!gc_bClose.BoolValue)
			{
				JbMenu(client,0);
			}
		}
		else if ( strcmp(info,"setFreeday") == 0 )
		{
			FakeClientCommand(client, "sm_setfreeday");
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

//Switch Team Menu

public Action ChangeTeam(int client, int args)
{
	char info[255];
	Menu menu1 = CreateMenu(changemenu);
	Format(info, sizeof(info), "%T", "warden_sure", client);
	menu1.SetTitle(info);
	Format(info, sizeof(info), "%T", "warden_no", client);
	menu1.AddItem("1", info);
	Format(info, sizeof(info), "%T", "warden_yes", client);
	menu1.AddItem("0", info);
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

//Voting

public void OnMapStart()
{
	g_iCoolDown = gc_iCooldownStart.IntValue +1;
}

public void RoundStart(Handle event, char[] name, bool dontBroadcast)
{
	
	char EventDay[64];
	GetEventDay(EventDay);
	if(!StrEqual(EventDay, "none", false))
	{
		g_iCoolDown = gc_iCooldownDay.IntValue + 1;
	}
	else if (g_iCoolDown > 0) g_iCoolDown--;
}


public int VotingMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_End)
	{
		/* This is called after VoteEnd */
		delete menu;
	}
}

public void VotingResults(Menu menu, int num_votes, int num_clients, const int[][] client_info, int num_items, const int[][] item_info)
{
	/* See if there were multiple winners */
	int winner = 0;
	if (num_items > 1 && (item_info[0][VOTEINFO_ITEM_VOTES] == item_info[1][VOTEINFO_ITEM_VOTES]))
	{
		winner = GetRandomInt(0, 1);
		CPrintToChatAll("%t %t", "menu_tag", "menu_votingdraw");
	}
	char event[64];
	menu.GetItem(item_info[winner][VOTEINFO_ITEM_INDEX], event, sizeof(event));
	CPrintToChatAll("%t %t", "menu_tag", "menu_votingwon", event, num_clients, num_items);
	ServerCommand("sm_set%s", event);
}

public Action VotingMenu(int client, int args)
{
	if (gc_bPlugin.BoolValue && gc_bVoting.BoolValue)
	{
		if ((warden_iswarden(client) && gc_bSetW.BoolValue) || (CheckVipFlag(client,g_sAdminFlag) && gc_bSetA.BoolValue))
		{
			if ((GetTeamClientCount(CS_TEAM_CT) > 0) && (GetTeamClientCount(CS_TEAM_T) > 0 ))
			{
				char EventDay[64];
				GetEventDay(EventDay);
				
				if(StrEqual(EventDay, "none", false))
				{
					if (g_iCoolDown == 0)
					{
						if (IsVoteInProgress())
						{
							return;
						}
						char menuinfo[64];
						Menu menu = new Menu(VotingMenuHandler);
						menu.VoteResultCallback = VotingResults;
						Format(menuinfo, sizeof(menuinfo), "%T", "menu_voting", client);
						menu.SetTitle(menuinfo);
						
						if(GetCommandFlags("sm_setwar") != INVALID_FCVAR_FLAGS)
						{
								Format(menuinfo, sizeof(menuinfo), "%T", "menu_war", client);
								menu.AddItem("war", menuinfo);
						}
						if(GetCommandFlags("sm_setffa") != INVALID_FCVAR_FLAGS)
						{
								Format(menuinfo, sizeof(menuinfo), "%T", "menu_ffa", client);
								menu.AddItem("ffa", menuinfo);
						}
						if(GetCommandFlags("sm_setzombie") != INVALID_FCVAR_FLAGS)
						{
								Format(menuinfo, sizeof(menuinfo), "%T", "menu_zombie", client);
								menu.AddItem("zombie", menuinfo);
						}
						if(GetCommandFlags("sm_sethide") != INVALID_FCVAR_FLAGS)
						{
								Format(menuinfo, sizeof(menuinfo), "%T", "menu_hide", client);
								menu.AddItem("hide", menuinfo);
						}
						if(GetCommandFlags("sm_setcatch") != INVALID_FCVAR_FLAGS)
						{
								Format(menuinfo, sizeof(menuinfo), "%T", "menu_catch", client);
								menu.AddItem("catch", menuinfo);
						}
						if(GetCommandFlags("sm_setsuicidebomber") != INVALID_FCVAR_FLAGS)
						{
								Format(menuinfo, sizeof(menuinfo), "%T", "menu_suicidebomber", client);
								menu.AddItem("suicidebomber", menuinfo);
						}
						if(GetCommandFlags("sm_sethebattle") != INVALID_FCVAR_FLAGS)
						{
								Format(menuinfo, sizeof(menuinfo), "%T", "menu_hebattle", client);
								menu.AddItem("hebattle", menuinfo);
						}
						if(GetCommandFlags("sm_setnoscope") != INVALID_FCVAR_FLAGS)
						{
								Format(menuinfo, sizeof(menuinfo), "%T", "menu_noscope", client);
								menu.AddItem("noscope", menuinfo);
						}
						if(GetCommandFlags("sm_setduckhunt") != INVALID_FCVAR_FLAGS)
						{
								Format(menuinfo, sizeof(menuinfo), "%T", "menu_duckhunt", client);
								menu.AddItem("duckhunt", menuinfo);
						}
						if(GetCommandFlags("sm_setzeus") != INVALID_FCVAR_FLAGS)
						{
								Format(menuinfo, sizeof(menuinfo), "%T", "menu_zeus", client);
								menu.AddItem("zeus", menuinfo);
						}
						if(GetCommandFlags("sm_setdealdamage") != INVALID_FCVAR_FLAGS)
						{
								Format(menuinfo, sizeof(menuinfo), "%T", "menu_dealdamge", client);
								menu.AddItem("dealdamage", menuinfo);
						}
						if(GetCommandFlags("sm_setdrunk") != INVALID_FCVAR_FLAGS)
						{
								Format(menuinfo, sizeof(menuinfo), "%T", "menu_drunk", client);
								menu.AddItem("drunk", menuinfo);
						}
						if(GetCommandFlags("sm_setknifefight") != INVALID_FCVAR_FLAGS)
						{
								Format(menuinfo, sizeof(menuinfo), "%T", "menu_knifefight", client);
								menu.AddItem("knifefight", menuinfo);
						}
						if(GetCommandFlags("sm_settorch") != INVALID_FCVAR_FLAGS)
						{
								Format(menuinfo, sizeof(menuinfo), "%T", "menu_torch", client);
								menu.AddItem("torch", menuinfo);
						}
						if(GetCommandFlags("sm_setcowboy") != INVALID_FCVAR_FLAGS)
						{
								Format(menuinfo, sizeof(menuinfo), "%T", "menu_cowboy", client);
								menu.AddItem("cowboy", menuinfo);
						}
						if(GetCommandFlags("sm_setfreeday") != INVALID_FCVAR_FLAGS)
						{
								Format(menuinfo, sizeof(menuinfo), "%T", "menu_Freeday", client);
								menu.AddItem("freeday", menuinfo);
						}
						menu.ExitButton = true;
						menu.DisplayVoteToAll(25);
						g_iCoolDown = gc_iCooldownDay.IntValue + 1;
					}
					else CPrintToChat(client,"%t %t", "menu_tag", "menu_wait", g_iCoolDown);
				}
				else CPrintToChat(client, "%t %t", "menu_tag", "menu_progress", EventDay);
			}
			else CPrintToChat(client, "%t %t", "menu_tag", "menu_minplayer");
		}
		else CPrintToChat(client, "%t %t", "menu_tag", "warden_notwarden");
	}
	else CPrintToChat(client, "%t %t", "menu_tag", "menu_disabled");
}