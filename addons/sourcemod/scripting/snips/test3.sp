#include <sourcemod>
#include <sdktools>
#include <cstrike>

public OnPluginStart()
{
	
	RegConsoleCmd("sm_test1", TestOn);
	
}

public Action:TestOn(client, args)
{
	PrintToChatAll("Hello world")
}


