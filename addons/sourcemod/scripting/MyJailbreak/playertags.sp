//includes
#include <sourcemod>
#include <cstrike>
#include <warden>
#include <scp>
#include <myjailbreak>
#include <autoexecconfig>

//Compiler Options
#pragma semicolon 1
#pragma newdecls required

//ConVars
ConVar gc_bPlugin;
ConVar gc_bStats;
ConVar gc_bChat;
ConVar gc_sOwnerFlag;
ConVar gc_sAdminFlag;
ConVar gc_sVIPFlag;
ConVar gc_sVIP2Flag;
ConVar gc_bNoOverwrite;

char g_sAdminFlag[32];
char g_sOwnerFlag[32];
char g_sVIP2Flag[32];
char g_sVIPFlag[32];

public Plugin myinfo =
{
	name = "MyJailbreak - PlayerTags",
	description = "Define player tags in chat & stats for Jailbreak Server",
	author = "shanapu",
	version = PLUGIN_VERSION,
	url = URL_LINK
}

public void OnPluginStart()
{
	// Translation
	LoadTranslations("MyJailbreak.PlayerTags.phrases");
	
	//AutoExecConfig
	AutoExecConfig_SetFile("PlayerTags", "MyJailbreak");
	AutoExecConfig_SetCreateFile(true);
	
	AutoExecConfig_CreateConVar("sm_playertag_version", PLUGIN_VERSION, "The version of this MyJailbreak SourceMod plugin", FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_DONTRECORD);
	gc_bPlugin = AutoExecConfig_CreateConVar("sm_playertag_enable", "1", "0 - disabled, 1 - enable this MyJailbreak SourceMod plugin", _, true,  0.0, true, 1.0);
	gc_bStats = AutoExecConfig_CreateConVar("sm_playertag_stats", "1", "0 - disabled, 1 - enable PlayerTag in stats", _, true,  0.0, true, 1.0);
	gc_bChat = AutoExecConfig_CreateConVar("sm_playertag_chat", "1", "0 - disabled, 1 - enable PlayerTag in chat", _, true,  0.0, true, 1.0);
	gc_sOwnerFlag = AutoExecConfig_CreateConVar("sm_playertag_owner", "z", "Set the flag for Owner");
	gc_sAdminFlag = AutoExecConfig_CreateConVar("sm_playertag_admin", "d", "Set the flag for admin");
	gc_sVIPFlag = AutoExecConfig_CreateConVar("sm_playertag_VIP", "t", "Set the flag for VIP");
	gc_sVIP2Flag = AutoExecConfig_CreateConVar("sm_playertag_VIP2", "a", "Set the flag for VIP2");
	gc_bNoOverwrite = AutoExecConfig_CreateConVar("sm_playertag_overwrite", "1", "0 - only show tags for warden, admin,vip (no overwrite for prisionor & guards) 1 - enable tags for Prisioner & guards,too", _, true,  0.0, true, 1.0);
	
	
	AutoExecConfig_ExecuteFile();
	AutoExecConfig_CleanFile();
	
//Events to give new Tag
	
	//Hooks
	HookEvent("player_connect", checkTag);
	HookEvent("player_team", checkTag);
	HookEvent("player_spawn", checkTag);
	HookEvent("player_death", checkTag);
	HookEvent("round_start", checkTag);
	
	gc_sOwnerFlag.GetString(g_sOwnerFlag,sizeof(g_sOwnerFlag));
	gc_sAdminFlag.GetString(g_sAdminFlag,sizeof(g_sAdminFlag));
	gc_sVIPFlag.GetString(g_sVIPFlag,sizeof(g_sVIPFlag));
	gc_sVIP2Flag.GetString(g_sVIP2Flag,sizeof(g_sVIP2Flag));
}

public void OnClientPutInServer(int client)
{
	HandleTag(client);
	return;
}

public int warden_OnWardenCreated(int client)
{
	HandleTag(client);
	return;
}

public int warden_OnWardenRemoved(int client)
{
	HandleTag(client);
	return;
}

public Action checkTag(Handle event, char[] name, bool dontBroadcast)
{
	CreateTimer(1.0, DelayCheck);
	return Action;
}

public Action DelayCheck(Handle timer) 
{
	LoopClients(client)
	{
		if (0 < client)
		{
			HandleTag(client);
		}
	}
	return Action;
}

//Give Tag

public int HandleTag(int client)
{
	if(gc_bPlugin.BoolValue)
	{
		if(gc_bStats.BoolValue && IsValidClient(client, true, true))
		{	
			char tags[64];
			
			if (GetClientTeam(client) == CS_TEAM_T)
			{
				if (CheckVipFlag(client, g_sOwnerFlag))
				{
					Format(tags, sizeof(tags), "%t" ,"tags_TOWN", LANG_SERVER);
					CS_SetClientClanTag(client, tags); 
				}
				else if (CheckVipFlag(client, g_sAdminFlag))
				{
					Format(tags, sizeof(tags), "%t" ,"tags_TA", LANG_SERVER);
					CS_SetClientClanTag(client, tags);
				}
				else if (CheckVipFlag(client, g_sVIPFlag))
				{
					Format(tags, sizeof(tags), "%t" ,"tags_TVIP1", LANG_SERVER);
					CS_SetClientClanTag(client, tags);
				}
				else if (CheckVipFlag(client, g_sVIP2Flag))
				{
					Format(tags, sizeof(tags), "%t" ,"tags_TVIP2", LANG_SERVER);
					CS_SetClientClanTag(client, tags);
				}
				else if (gc_bNoOverwrite.BoolValue)
				{
					Format(tags, sizeof(tags), "%t" ,"tags_T", LANG_SERVER);
					CS_SetClientClanTag(client, tags);
				}
			}
			else if (GetClientTeam(client) == CS_TEAM_CT)
			{
				if (warden_iswarden(client))
				{
					if (CheckVipFlag(client, g_sOwnerFlag))
					{
						Format(tags, sizeof(tags), "%t" ,"tags_WOWN", LANG_SERVER);
						CS_SetClientClanTag(client, tags);
					}
					else if (CheckVipFlag(client, g_sAdminFlag))
					{
						Format(tags, sizeof(tags), "%t" ,"tags_WA", LANG_SERVER);
						CS_SetClientClanTag(client, tags); 
					}
					else if (CheckVipFlag(client, g_sVIPFlag))
					{
						Format(tags, sizeof(tags), "%t" ,"tags_WVIP1", LANG_SERVER);
						CS_SetClientClanTag(client, tags); 
					}
					else if (CheckVipFlag(client, g_sVIP2Flag))
					{
						Format(tags, sizeof(tags), "%t" ,"tags_WVIP2", LANG_SERVER);
						CS_SetClientClanTag(client, tags); 
					}
					else if (gc_bNoOverwrite.BoolValue)
					{
						Format(tags, sizeof(tags), "%t" ,"tags_W", LANG_SERVER);
						CS_SetClientClanTag(client, tags); 
					}
				}
				else if (CheckVipFlag(client, g_sOwnerFlag))
				{
					Format(tags, sizeof(tags), "%t" ,"tags_CTOWN", LANG_SERVER);
					CS_SetClientClanTag(client, tags);
				}
				else if (CheckVipFlag(client, g_sAdminFlag))
				{
					Format(tags, sizeof(tags), "%t" ,"tags_CTA", LANG_SERVER);
					CS_SetClientClanTag(client, tags);
				}
				else if (CheckVipFlag(client, g_sVIPFlag))
				{
					Format(tags, sizeof(tags), "%t" ,"tags_CTVIP1", LANG_SERVER);
					CS_SetClientClanTag(client, tags); 
				}
				else if (CheckVipFlag(client, g_sVIP2Flag))
				{
					Format(tags, sizeof(tags), "%t" ,"tags_CTVIP2", LANG_SERVER);
					CS_SetClientClanTag(client, tags); 
				}
				else if (gc_bNoOverwrite.BoolValue)
				{
					Format(tags, sizeof(tags), "%t" ,"tags_CT", LANG_SERVER);
					CS_SetClientClanTag(client, tags); 
				}
			}
		}
	}
}

//Check Chat & add Tag

public Action OnChatMessage(int &author, Handle recipients, char[] name, char[] message)
{
	if(gc_bPlugin.BoolValue)
	{
		if(gc_bChat.BoolValue)
		{
			if (GetClientTeam(author) == CS_TEAM_T) 
			{
				if (CheckVipFlag(author, g_sOwnerFlag))
					{
						Format(name, MAXLENGTH_NAME, "%t %s","tags_TOWN", name);
						return Plugin_Changed;
					}
					else if (CheckVipFlag(author, g_sAdminFlag))
					{
						Format(name, MAXLENGTH_NAME, "%t %s","tags_TA", name);
						return Plugin_Changed;
					}
					else if (CheckVipFlag(author, g_sVIPFlag))
					{
						Format(name, MAXLENGTH_NAME, "%t %s","tags_TVIP1", name);
						return Plugin_Changed;
					}
					else if (CheckVipFlag(author, g_sVIP2Flag))
					{
						Format(name, MAXLENGTH_NAME, "%t %s","tags_TVIP2", name);
						return Plugin_Changed;
					}
					else if (gc_bNoOverwrite.BoolValue)
					{
						Format(name, MAXLENGTH_NAME, "%t %s","tags_T", name);
						return Plugin_Changed;
					}
			}
			else if (GetClientTeam(author) == CS_TEAM_CT)
				{
					if (warden_iswarden(author))
					{
						if (CheckVipFlag(author, g_sOwnerFlag))
						{
							Format(name, MAXLENGTH_NAME, "%t %s","tags_WOWN", name);
							return Plugin_Changed;
						}
						else if (CheckVipFlag(author, g_sAdminFlag))
						{
							Format(name, MAXLENGTH_NAME, "%t %s","tags_WA", name);
							return Plugin_Changed;
						}
						else if (CheckVipFlag(author, g_sVIPFlag))
						{
							Format(name, MAXLENGTH_NAME, "%t %s","tags_WVIP1", name);
							return Plugin_Changed;
						}
						else if (CheckVipFlag(author, g_sVIP2Flag))
						{
							Format(name, MAXLENGTH_NAME, "%t %s","tags_WVIP2", name);
							return Plugin_Changed;
						}
						else if (gc_bNoOverwrite.BoolValue)
						{
							Format(name, MAXLENGTH_NAME, "%t %s","tags_W", name);
							return Plugin_Changed;
						}
					}
					else if (CheckVipFlag(author, g_sOwnerFlag))
					{
						Format(name, MAXLENGTH_NAME, "%t %s","tags_CTOWN", name);
						return Plugin_Changed;
					}
					else if (CheckVipFlag(author, g_sAdminFlag))
					{
						Format(name, MAXLENGTH_NAME, "%t %s","tags_CTA", name);
						return Plugin_Changed;
					}
					else if (CheckVipFlag(author, g_sVIPFlag))
					{
						Format(name, MAXLENGTH_NAME, "%t %s","tags_CTVIP1", name);
						return Plugin_Changed;
					}
					else if (CheckVipFlag(author, g_sVIP2Flag))
					{
						Format(name, MAXLENGTH_NAME, "%t %s","tags_CTVIP2", name);
						return Plugin_Changed;
					}
					else if (gc_bNoOverwrite.BoolValue)
					{
						Format(name, MAXLENGTH_NAME, "%t %s","tags_CT", name);
						return Plugin_Changed;
					}
				}
		}return Plugin_Continue;
	}
	return Plugin_Continue;
}