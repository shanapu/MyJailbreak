//includes
#include <sourcemod>
#include <cstrike>
#include <wardn>
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

public Plugin myinfo =
{
	name = "MyJailbreak - PlayerTags",
	description = "Define player tags in chat & stats for Jailbreak Server",
	author = "shanapu",
	version = PLUGIN_VERSION,
	url = "shanapu.de"
}

public void OnPluginStart()
{
	// Translation
	LoadTranslations("MyJailbreak.PlayerTags.phrases");
	
	//AutoExecConfig
	AutoExecConfig_SetFile("MyJailbreak.PlayerTags");
	AutoExecConfig_SetCreateFile(true);
	
	AutoExecConfig_CreateConVar("sm_playertag_version", PLUGIN_VERSION, "The version of this MyJailBreak SourceMod plugin", FCVAR_SPONLY|FCVAR_PLUGIN|FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_DONTRECORD);
	gc_bPlugin = AutoExecConfig_CreateConVar("sm_playertag_enable", "1", "0 - disabled, 1 - enable this MyJailBreak SourceMod plugin", _, true,  0.0, true, 1.0);
	gc_bStats = AutoExecConfig_CreateConVar("sm_playertag_stats", "1", "0 - disabled, 1 - enable PlayerTag in stats", _, true,  0.0, true, 1.0);
	gc_bChat = AutoExecConfig_CreateConVar("sm_playertag_chat", "1", "0 - disabled, 1 - enable PlayerTag in chat", _, true,  0.0, true, 1.0);
	
	AutoExecConfig_ExecuteFile();
	AutoExecConfig_CleanFile();
	
	//Hooks
	HookEvent("player_connect", checkTag);
	HookEvent("player_team", checkTag);
	HookEvent("player_spawn", checkTag);

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
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	if (0 < client)
	{
		HandleTag(client);
	}
	return Action;
}

public int HandleTag(int client)
{
	if(gc_bPlugin.BoolValue)
	{
		if(gc_bStats.BoolValue)
		{	
			char tagsTA[255], tagsT[255], tagsCT[255], tagsCTA[255], tagsW[255], tagsWA[255];
			
			if (GetClientTeam(client) == CS_TEAM_T) 
			{
				if (CheckCommandAccess(client, "sm_map", ADMFLAG_CHANGEMAP, true))
					{
						Format(tagsTA, sizeof(tagsTA), "%t" ,"tags_TA", LANG_SERVER);
						CS_SetClientClanTag(client, tagsTA); 
					}
					else
					{
						Format(tagsT, sizeof(tagsT), "%t" ,"tags_T", LANG_SERVER);
						CS_SetClientClanTag(client, tagsT);
					}
			}
			else if (GetClientTeam(client) == CS_TEAM_CT)
				{
					if (warden_iswarden(client))
					{
						if (CheckCommandAccess(client, "sm_map", ADMFLAG_CHANGEMAP, true))
						{
							Format(tagsWA, sizeof(tagsWA), "%t" ,"tags_WA", LANG_SERVER);
							CS_SetClientClanTag(client, tagsWA);
						}
						else
						{
							Format(tagsW, sizeof(tagsW), "%t" ,"tags_W", LANG_SERVER);
							CS_SetClientClanTag(client, tagsW); 
						}
					}
					else if (CheckCommandAccess(client, "sm_map", ADMFLAG_CHANGEMAP, true))
					{
						Format(tagsCTA, sizeof(tagsCTA), "%t" ,"tags_CTA", LANG_SERVER);
						CS_SetClientClanTag(client, tagsCTA);
					}
					else
					{
						Format(tagsCT, sizeof(tagsCT), "%t" ,"tags_CT", LANG_SERVER);
						CS_SetClientClanTag(client, tagsCT); 
					}
				}
		}
	}
}

public Action OnChatMessage(int &author, Handle recipients, char[] name, char[] message)
{
	if(gc_bPlugin.BoolValue)
	{
		if(gc_bChat.BoolValue)
		{
			if (GetClientTeam(author) == CS_TEAM_T) 
			{
				if (CheckCommandAccess(author, "sm_map", ADMFLAG_CHANGEMAP, true))
					{
						Format(name, MAXLENGTH_NAME, "%t %s","tags_TA", name);
						return Plugin_Changed;
					}
					else
					{
						Format(name, MAXLENGTH_NAME, "%t %s","tags_T", name);
						return Plugin_Changed;
					}
			}
			else if (GetClientTeam(author) == CS_TEAM_CT)
				{
					if (warden_iswarden(author))
					{
						if (CheckCommandAccess(author, "sm_map", ADMFLAG_CHANGEMAP, true))
						{
							Format(name, MAXLENGTH_NAME, "%t %s","tags_WA", name);
							return Plugin_Changed;
						}
						else
						{
							Format(name, MAXLENGTH_NAME, "%t %s","tags_W", name);
							return Plugin_Changed;
						}
					}
					else if (CheckCommandAccess(author, "sm_map", ADMFLAG_CHANGEMAP, true))
					{
						Format(name, MAXLENGTH_NAME, "%t %s","tags_CTA", name);
						return Plugin_Changed;
					}
					else
					{
						Format(name, MAXLENGTH_NAME, "%t %s","tags_CT", name);
						return Plugin_Changed;
					}
				}
		}return Plugin_Continue;
	}
	return Plugin_Continue;
}