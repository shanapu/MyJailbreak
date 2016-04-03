#include <sourcemod>
#include <cstrike>

public Plugin:myinfo =
{
	name = "PlayerTag",
	description = "define player tags for JB",
	author = "shanapu, KeepCalm,Dragonidas",
	version = "0.1",
	url = ""
};


public OnPluginStart()
{
	HookEvent("player_connect", checkTag);
	HookEvent("player_team", checkTag);
	HookEvent("player_spawn", checkTag);
	return 0;
}

public OnClientPutInServer(client)
{
	HandleTag(client);
	return 0;
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
    if (GetClientTeam(client) == CS_TEAM_T) 
    { 
        
        if (CheckCommandAccess(client, "sm_map", ADMFLAG_CHANGEMAP, true))
			{ 
				CS_SetClientClanTag(client, "[TerrorAdmin]"); 
			} 
			else CS_SetClientClanTag(client, "[Terror]");
    }
    else if (GetClientTeam(client) == CS_TEAM_CT)
		{ 
			if (warden_iswarden(client))
			{ 
				if (CheckCommandAccess(client, "sm_map", ADMFLAG_CHANGEMAP, true))
		    	{ 
			       	CS_SetClientClanTag(client, "[WardenAdmin]"); 
		       	} 
		    	else CS_SetClientClanTag(client, "[warden]"); 
			} 
			else if (CheckCommandAccess(client, "sm_map", ADMFLAG_CHANGEMAP, true))
			{ 
				CS_SetClientClanTag(client, "[GuardAdmin]"); 
			} 
			else CS_SetClientClanTag(client, "[Guard]"); 
			 
								
}