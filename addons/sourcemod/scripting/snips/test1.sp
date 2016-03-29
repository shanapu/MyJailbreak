#include <sourcemod>
#include <sdktools>
#include <cstrike>

public OnPluginStart()
{
	
	AddCommandListener(Event_Say, "say");
	AddCommandListener(Event_Say, "say_team");
	
}

public Action:Event_Say(clientIndex, const String:command[], arg)
{
	static String:menuTriggers[][] = { "!test3" };
	
	decl String:text[24];
	GetCmdArgString(text, sizeof(text));
	StripQuotes(text);
	TrimString(text);
	
	for(new i = 0; i < sizeof(menuTriggers); i++)
		{
			if (StrEqual(text, menuTriggers[i], false))
			{
				PrintToChatAll("Hello world")
			}
		}
}