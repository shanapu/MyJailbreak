//includes
#include <sourcemod>
#include <cstrike>
#include <wardn>
#include <scp>

//Compiler Options
#pragma semicolon 1

//Defines
#define PLUGIN_VERSION "0.1"

//ConVars
ConVar gc_bPlugin;
ConVar gc_bStats;
ConVar gc_bChat;

public Plugin:myinfo =
{
	name = "MyJailbreak - PlayerTags",
	description = "define player tags for JB",
	author = "shanapu, KeepCalm,Dragonidas",
	version = PLUGIN_VERSION,
	url = ""
}

public OnPluginStart()
{
	LoadTranslations("MyJailbreakPlayerTags.phrases");
	
	CreateConVar("sm_playertag_version", PLUGIN_VERSION,	"The version of the SourceMod plugin MyJailBreak - PlayerTag", FCVAR_REPLICATED|FCVAR_SPONLY|FCVAR_NOTIFY|FCVAR_DONTRECORD);
	gc_bPlugin = CreateConVar("sm_playertag_enable", "1", "0 - disabled, 1 - enable PlayerTag");	
	gc_bStats = CreateConVar("sm_playertag_stats", "1", "0 - disabled, 1 - enable PlayerTag in stats");	
	gc_bChat = CreateConVar("sm_playertag_chat", "1", "0 - disabled, 1 - enable PlayerTag in Chat");	
	
	HookEvent("player_connect", checkTag);
	HookEvent("player_team", checkTag);
	HookEvent("player_spawn", checkTag);
	return;
}

public OnClientPutInServer(client)
{
	HandleTag(client);
	return;
}

public warden_OnWardenCreated(client)
{
	HandleTag(client);
	return;
}

public warden_OnWardenRemoved(client)
{
	HandleTag(client);
	return;
}

public Action:checkTag(Handle:event, String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	if (0 < client)
	{
		HandleTag(client);
	}
	return Action:0;
}

HandleTag(client)
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

public Action:OnChatMessage(&author, Handle:recipients, String:name[], String:message[])
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