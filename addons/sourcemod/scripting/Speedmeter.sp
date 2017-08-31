//small edit by shanapu 29/08/2017

#pragma semicolon 1
#include <sourcemod>
#include <sdktools>
#include <colors>
#include <smlib>
#include <store>
#include <kento_rankme/rankme>
//	0.04263157894736842105263157894737 - km/h
new bool:IsSPMEnabled[MAXPLAYERS+1] = {true,...};
new g_iButtonsPressed[MAXPLAYERS+1] = {0,...};
new PlayerDeaths[MAXPLAYERS+1] = {0,...};
new PlayerKills[MAXPLAYERS+1] = {0,...};
new PlayTime[MAXPLAYERS+1] = 0;
public OnPluginStart()
{
HookEvent("player_disconnect", Event_Disc);
HookEvent("player_death",player_death);
RegConsoleCmd("sm_tsp", Command_Togglespeedmeter);
CreateTimer(0.05,Tick,_,TIMER_REPEAT);
CreateTimer(1.0,TickPlay,_,TIMER_REPEAT);
}
public Action:Event_Disc(Handle:event, const String:name[], bool:dontBroadcast)
{
new client = GetClientOfUserId(GetEventInt(event, "userid"));
g_iButtonsPressed[client] = 0;
IsSPMEnabled[client] = true;
PlayTime[client] = 0;
}
//		new loser = GetClientOfUserId(GetEventInt(event, "userid"));
//		new winner = GetClientOfUserId(GetEventInt(event, "attacker"));
public Action:player_death(Handle:event, const String:name[], bool:dontBroadcast)
{
new loser = GetClientOfUserId(GetEventInt(event, "userid"));
new winner = GetClientOfUserId(GetEventInt(event, "attacker"));
PlayerDeaths[loser] += 1;
PlayerKills[winner] += 1;
}
public Action:Command_Togglespeedmeter(client, args)
{
	if ( IsClientInGame(client) )
	{
	if(IsSPMEnabled[client])
	{
	PrintToChat(client,"Speedmeter disabled");
	IsSPMEnabled[client] = false;
	} else
	{
	IsSPMEnabled[client] = true;
	PrintToChat(client,"Speedmeter enabled");
	}
	}
	return Plugin_Handled;
}
public Action:OnPlayerRunCmd(client, &buttons, &impulse, Float:vel[3], Float:angles[3], &weapon)
{
	g_iButtonsPressed[client] = buttons;
}
public Action:TickPlay(Handle:timer)
{
	for(new ix = 1; ix <= MaxClients; ix++) 
	{
	if(IsClientInGame(ix) && IsClientConnected(ix) && !IsFakeClient(ix))
	{
	PlayTime[ix]+=1;
	}
	}
}
public Action:Tick(Handle:timer)
{
	for(new ix = 1; ix <= MaxClients; ix++) 
	{
	if(IsClientInGame(ix) && IsClientConnected(ix))
	{
	if(IsPlayerAlive(ix))
	{
	if(!IsFakeClient(ix))
	{
	if(IsSPMEnabled[ix])
	{
	ShowStats(ix,ix);
	}
	}
	} else
	{
	new target;
	target = GetEntPropEnt(ix, Prop_Send, "m_hObserverTarget");
	if (target > 0 && target <= MaxClients && IsClientInGame(target) && IsPlayerAlive(target))
	{
	if(IsSPMEnabled[target])
	{
	ShowStats(target,ix);
	}
	}
	}
	}
	}
}




ShowStats(client,target)
{
	int stats_return[22];
	RankMe_GetStats(client,stats_return);

	int kills = stats_return[1];
	int deaths = stats_return[2];
	int connected = stats_return[9];

	new String:sOutput[20480];
	new Float:clientVel[3];
	Entity_GetAbsVelocity(client,clientVel);
	
	//new Float:fallSpeed = clientVel[2];
	new Float:KDR;
	if(deaths == 0)
	{
	KDR = float(kills);
	} else
	{
	KDR = float(kills) / float(deaths);
	}
	clientVel[2] = 0.0;
	//%.2f
	//00D4FF
	//<font color='#00FF00'></font>
	//<font color='#00b8ff'>
	new Float:Speed = GetVectorLength(clientVel);

	Format(sOutput, sizeof(sOutput), "<font color='#00D4FF'>Speed:</font>%.1f Km/h | <font color='#00D4FF'>Playtime:</font> %d:%d\n",Speed*0.04263157894736842105263157894737,connected/3600%24,connected/60%60);

	Format(sOutput, sizeof(sOutput), "%s<font color='#00D4FF'>CR:</font>%d | <font color='#00D4FF'>K/D:</font>%.2f\n",sOutput,Store_GetClientCredits(client),KDR);
	new iButtons = g_iButtonsPressed[client];
	if(iButtons & IN_FORWARD)
	Format(sOutput, sizeof(sOutput), "%s W",sOutput);
		else
	Format(sOutput, sizeof(sOutput), "%s _",sOutput);
	
	if(iButtons & IN_MOVELEFT)
	Format(sOutput, sizeof(sOutput), "%s A",sOutput);
		else
	Format(sOutput, sizeof(sOutput), "%s _",sOutput);
	
	if(iButtons & IN_BACK)
	Format(sOutput, sizeof(sOutput), "%s S",sOutput);
		else
	Format(sOutput, sizeof(sOutput), "%s _",sOutput);
	
	if(iButtons & IN_MOVERIGHT)
	Format(sOutput, sizeof(sOutput), "%s D",sOutput);
		else
	Format(sOutput, sizeof(sOutput), "%s _",sOutput);
	
	if(iButtons & IN_JUMP)
	Format(sOutput, sizeof(sOutput), "%s | J",sOutput);
		else
	Format(sOutput, sizeof(sOutput), "%s | _",sOutput);
	
	if(iButtons & IN_USE)
	Format(sOutput, sizeof(sOutput), "%s E",sOutput);
		else
	Format(sOutput, sizeof(sOutput), "%s _",sOutput);
	
	if(iButtons & IN_DUCK)
	Format(sOutput, sizeof(sOutput), "%s C",sOutput);
		else
	Format(sOutput, sizeof(sOutput), "%s _",sOutput);
				
	if(iButtons & IN_SPEED)
	Format(sOutput, sizeof(sOutput), "%s WLK",sOutput);
		else
	Format(sOutput, sizeof(sOutput), "%s ___",sOutput);

	if(iButtons & IN_ATTACK)
	Format(sOutput, sizeof(sOutput), "%s M1",sOutput);
		else
	Format(sOutput, sizeof(sOutput), "%s __",sOutput);
			
	if(iButtons & IN_ATTACK2)
	Format(sOutput, sizeof(sOutput), "%s M2",sOutput);
		else
	Format(sOutput, sizeof(sOutput), "%s __",sOutput);
	PrintHintText(target,"%s",sOutput);
	//PrintToChat(target,"%s",sOutput);
}