#include <sourcemod>
#include <sdktools>
#include <cstrike>

public OnPluginStart()
{
	
	HookEvent("player_say", PlayerSay);
	
}


public PlayerSay(Handle:event, String:name[], bool:dontBroadcast)
{
	
	decl String:text[256];
	GetEventString(event, "text", text, sizeof(text));
	if (StrEqual(text, "!test2"))
	{
		PrintToChatAll("Hello world")
	}
}