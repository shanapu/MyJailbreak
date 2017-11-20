#include <sourcemod>
#include <sdktools>

public Plugin myinfo =
{
	name = "CS:GO Dookie",
	author = "Tom Delebo, edit shanapu",
	description = "Drop a steaming hot turdburger on scrubs!",
	version = "1.1",
	url = "https://github.com/delebota/CS-GO-Dookie-Mod"
};

// Sounds
#define DOOKIE_SOUND			 "dookie/dookie.wav"
#define DOOKIE_SOUND_FULL		"sound/dookie/dookie.wav"
#define DOOKIE_SUPER_SOUND	   "dookie/superdookie.wav"
#define DOOKIE_SUPER_SOUND_FULL  "sound/dookie/superdookie.wav"

// Models
#define DOOKIE_MODEL	  "models/dookie/dookie.mdl"
#define DOOKIE_MODEL_DX80 "models/dookie/dookie.dx80.vtx"
#define DOOKIE_MODEL_DX90 "models/dookie/dookie.dx90.vtx"
#define DOOKIE_MODEL_VTX  "models/dookie/dookie.sw.vtx"
#define DOOKIE_MODEL_VVD  "models/dookie/dookie.vvd"
#define DOOKIE_MODEL_VMT  "materials/models/dookie/dookie.vmt"
#define DOOKIE_MODEL_VTF  "materials/models/dookie/dookie.vtf"

// Dookie Mod stats
new Float:playerBodyOrigins[MAXPLAYERS][3];
new playerDookiesTaken[MAXPLAYERS];
new playerDookiesAvailable[MAXPLAYERS];
new playerHeadshotCount[MAXPLAYERS];
new playerCooldown[MAXPLAYERS];

// ConVars
ConVar cv_dookie_limit_round;
ConVar cv_dookie_super_knife;
ConVar cv_dookie_super_hs;

public void OnPluginStart()
{
	// Register our dookie commands
	RegConsoleCmd("!dookie", Command_Dookie);
	RegConsoleCmd("!dookie_help", Command_Dookie_Help);
	RegAdminCmd("sm_dlr", Command_Change_cv_dookie_limit_round, ADMFLAG_GENERIC);
	RegAdminCmd("sm_dsk", Command_Change_cv_dookie_super_knife, ADMFLAG_GENERIC);
	RegAdminCmd("sm_dshs", Command_Change_cv_dookie_super_hs, ADMFLAG_GENERIC);
	
	// Hook events
	HookEvent("player_death", Event_PlayerDeath, EventHookMode_Pre);
	HookEvent("round_start", Event_RoundStart, EventHookMode_Pre);
	
	// CVars
	cv_dookie_limit_round = CreateConVar("cv_dookie_limit_round", "5", "Max number of dookies a player can take per round.", _, true, 0.0, false, 0.0);
	cv_dookie_super_knife = CreateConVar("cv_dookie_super_knife", "1", "Knife kills grant a 'super dookie'.", _, true, 0.0, true, 1.0);
	cv_dookie_super_hs = CreateConVar("cv_dookie_super_hs", "3", "Number of headshots in one round to get a 'super dookie'.", _, true, 0.0, false, 0.0);
}

public void OnMapStart() 
{
	// Cache files
	PrecacheModel(DOOKIE_MODEL, true);
	PrecacheSound(DOOKIE_SOUND, true);
	PrecacheSound(DOOKIE_SUPER_SOUND, true);
	
	// Set files for download
	AddFileToDownloadsTable(DOOKIE_MODEL);
	AddFileToDownloadsTable(DOOKIE_MODEL_DX80);
	AddFileToDownloadsTable(DOOKIE_MODEL_DX90);
	AddFileToDownloadsTable(DOOKIE_MODEL_VTX);
	AddFileToDownloadsTable(DOOKIE_MODEL_VVD);
	AddFileToDownloadsTable(DOOKIE_MODEL_VMT);
	AddFileToDownloadsTable(DOOKIE_MODEL_VTF);
	AddFileToDownloadsTable(DOOKIE_SOUND_FULL);
	AddFileToDownloadsTable(DOOKIE_SUPER_SOUND_FULL);
}

public Action Command_Dookie_Help(int client, int args)
{
	// Send to console
	PrintToConsole(client, " ***** CS:GO Dookie Mod Help ***** ", client);
	PrintToConsole(client, "Type !dookie in the console. Bind it for easy access.", client);
	PrintToConsole(client, "Kills grant dookies, use them near dead players.", client);
	PrintToConsole(client, "By default three headshots grants an earth shaking superdookie.", client);

	// Send to their chatbox as well
	PrintToChat(client, " ***** CS:GO Dookie Mod Help ***** ", client);
	PrintToChat(client, "Type !dookie in the console. Bind it for easy access.", client);
	PrintToChat(client, "Kills grant dookies, use them near dead players.", client);
	PrintToChat(client, "By default three headshots grants an earth shaking superdookie.", client);
 
	return Plugin_Handled;
}

public Action Command_Dookie(int client, int args)
{
	// Check that player using this is alive
	if (!IsPlayerAlive(client))
	{
		// Not Alive, exit
		return Plugin_Handled;
	}
	
	// Check if we are allowed another this round and if we have one available
	if ((playerDookiesTaken[client] < cv_dookie_limit_round.IntValue) && (playerDookiesAvailable[client] > 0))
	{
		// Player position
		new Float:clientPos[3];
		GetClientAbsOrigin(client, clientPos);

		// Track closest body
		new closestBodyPlayer;
		new Float:closestBodyDist = 9999.0;
		
		// Find nearest player body
		for (new i = 1; i <= MaxClients; i++) 
		{
			// Check if they are in-game and dead
			if (IsClientInGame(i) && !IsPlayerAlive(i)) 
			{
				// Check if this is the closest to the player yet
				new Float:bodyDist = GetVectorDistance(clientPos, playerBodyOrigins[i]);
				if (bodyDist < closestBodyDist)
				{
					closestBodyDist = bodyDist;
					closestBodyPlayer = i;
				}
			}
		}
		
		// Check if the player is near the body
		if (closestBodyDist <= 100.0)
		{
			// Prepare message
			new String:victimName[32];
			GetClientName(closestBodyPlayer, victimName, sizeof(victimName));
			new String:clientName[32];
			GetClientName(client, clientName, sizeof(clientName));
			new String:msg[128];
		
			if (playerHeadshotCount[client] >= cv_dookie_super_hs.IntValue)
			{
				// Super dookie
				CreateSuperDookie(client, clientPos)
				EmitSoundToAll(DOOKIE_SUPER_SOUND);
				
				// Decrement headshots, so they can't keep using it
				playerHeadshotCount[client] -= cv_dookie_super_hs.IntValue;
				
				// Print message
				Format(msg, sizeof(msg), "%s just dropped an earth-shaking dookie on %s's dead body!", clientName, victimName);
				PrintToChatAll(msg);
			}
			else
			{
				// Normal dookie
				CreateDookie(client, clientPos);
				EmitSoundToAll(DOOKIE_SOUND);
			
				// Print message
				Format(msg, sizeof(msg), "%s just took a nasty dookie on %s's dead body.", clientName, victimName);
				PrintToChatAll(msg);
			}
			
			// Change dookie counts
			playerDookiesTaken[client]++;
			playerDookiesAvailable[client]--;
		}
		else
		{
			PrintToChat(client, "There are no dead players near you.", client);
		}
	}
	else
	{
		// Display an appropriate message
		if (playerDookiesTaken[client] >= cv_dookie_limit_round.IntValue)
		{
			PrintToChat(client, "You can't take another dookie this round.", client);
		}
		else if (playerDookiesAvailable[client] < 1)
		{
			PrintToChat(client, "You can't take a dookie right now, get another kill first.", client);
		}
	}
 
	return Plugin_Handled;
}

public Action Command_Change_cv_dookie_limit_round(int client, int args)
{
	new String:arg[128];
	GetCmdArg(1, arg, sizeof(arg));
	cv_dookie_limit_round.SetInt(StringToInt(arg), false, false);
	new String:msg[128];
	Format(msg, sizeof(msg), "Max number of dookies per round set to: %s.", arg);
	PrintToConsole(client, msg, client);
	PrintToChat(client, msg, client);
	return Plugin_Handled;
}

public Action Command_Change_cv_dookie_super_knife(int client, int args)
{
	new String:arg[128];
	GetCmdArg(1, arg, sizeof(arg));
	cv_dookie_super_knife.SetInt(StringToInt(arg), false, false);
	if (StrEqual(arg, "1")) {
		PrintToChat(client, "Knife kills grant super dookie enabled.", client);
		PrintToConsole(client, "Knife kills grant super dookie enabled.", client);
	} else {
		PrintToChat(client, "Knife kills grant super dookie disabled.", client);
		PrintToConsole(client, "Knife kills grant super dookie disabled.", client);
	}
	return Plugin_Handled;
}

public Action Command_Change_cv_dookie_super_hs(int client, int args)
{
	new String:arg[128];
	GetCmdArg(1, arg, sizeof(arg));
	cv_dookie_super_hs.SetInt(StringToInt(arg), false, false);
	new String:msg[128];
	Format(msg, sizeof(msg), "Headshots to grant a super dookie set to: %s.", arg);
	PrintToConsole(client, msg, client);
	PrintToChat(client, msg, client);
	return Plugin_Handled;
}

public CreateDookie(int client, Float:origin[3])
{
	// Create dookie model
	new entDookieIndex = CreateEntityByName("prop_dynamic");
	if (entDookieIndex != -1 && IsValidEntity(entDookieIndex))
	{
		// Set dookie model values
		DispatchKeyValue(entDookieIndex, "model", DOOKIE_MODEL);
		DispatchKeyValueFloat(entDookieIndex, "solid", 4.0);
		
		// Spawn dookie model
		DispatchSpawn(entDookieIndex);
		TeleportEntity(entDookieIndex, origin, NULL_VECTOR, NULL_VECTOR);
	}
	
	// Add steam sprite
	CreateSteamSprite(origin);
}

public CreateSuperDookie(int client, Float:origin[3])
{
	// Create dookie model and steam
	CreateDookie(client, origin);
	
	// Add shake
	new entShakeIndex = CreateEntityByName("env_shake");
	if (entShakeIndex != -1 && IsValidEntity(entShakeIndex))
	{
		// Set shake values
		DispatchKeyValue(entShakeIndex, "SpawnFlags", "1");
		DispatchKeyValueFloat(entShakeIndex, "Amplitude", 8.0);
		DispatchKeyValueFloat(entShakeIndex, "Radius", 512.0);
		DispatchKeyValueFloat(entShakeIndex, "Duration", 2.0);
		DispatchKeyValueFloat(entShakeIndex, "Frequency", 128.0);
		
		// Spawn shake
		DispatchSpawn(entShakeIndex);
		AcceptEntityInput(entShakeIndex, "StartShake");
		TeleportEntity(entShakeIndex, origin, NULL_VECTOR, NULL_VECTOR);
	}
	
	// Add explosion
	new entExplosionIndex = CreateEntityByName("env_explosion");
	if (entExplosionIndex != -1 && IsValidEntity(entExplosionIndex))
	{
		// Set explosion values
		DispatchKeyValue(entExplosionIndex, "SpawnFlags", "1");
		DispatchKeyValue(entExplosionIndex, "iMagnitude", "1000");
		DispatchKeyValue(entExplosionIndex, "RenderMode", "0");
		
		// Spawn explosion
		DispatchSpawn(entExplosionIndex);
		TeleportEntity(entExplosionIndex, origin, NULL_VECTOR, NULL_VECTOR);
		AcceptEntityInput(entExplosionIndex, "Explode");
	}
}

public CreateSteamSprite(Float:origin[3])
{
	// Add steam sprite
	new entSteamIndex = CreateEntityByName("env_steam");
	if (entSteamIndex != -1 && IsValidEntity(entSteamIndex))
	{
		// Set steam sprite values
		DispatchKeyValue(entSteamIndex, "SpawnFlags", "1");
		DispatchKeyValue(entSteamIndex, "RenderColor", "79 141 57");
		DispatchKeyValue(entSteamIndex, "SpreadSpeed", "1.5");
		DispatchKeyValue(entSteamIndex, "Speed", "3");
		DispatchKeyValue(entSteamIndex, "StartSize", "1");
		DispatchKeyValue(entSteamIndex, "EndSize", "2");
		DispatchKeyValue(entSteamIndex, "Rate", "1");
		DispatchKeyValue(entSteamIndex, "JetLength", "20");
		DispatchKeyValue(entSteamIndex, "RenderAmt", "128");
		DispatchKeyValue(entSteamIndex, "InitialState", "1");
		
		// Spawn steam sprite
		origin[2] += 11.0;
		new Float:angles[3] = {-90.0, 0.0, 0.0};
		DispatchSpawn(entSteamIndex);
		AcceptEntityInput(entSteamIndex, "TurnOn");
		TeleportEntity(entSteamIndex, origin, angles, NULL_VECTOR);
	}
}

public Action Event_PlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
	// Set death vector
	int victimId = event.GetInt("userid");
	int victim = GetClientOfUserId(victimId);
	GetClientAbsOrigin(victim, playerBodyOrigins[victim]);
	
	// Grant killer a dookie
	int attackerId = event.GetInt("attacker");
	int attacker = GetClientOfUserId(attackerId);
	playerDookiesAvailable[attacker]++;
	
	// Check for HS or knife kill
	new String:weapon[64];
	event.GetString("weapon", weapon, sizeof(weapon));
	bool headshot = event.GetBool("headshot");
	bool knifeKill = (StrContains(weapon, "knife") != -1);
	if ((cv_dookie_super_knife.IntValue == 1) && knifeKill)
	{
		// Super dookie
		new Float:attackerPos[3];
		GetClientAbsOrigin(attacker, attackerPos);
		CreateSuperDookie(attacker, attackerPos)
		EmitSoundToAll(DOOKIE_SUPER_SOUND);
		
		// Remove a dookie since we are using it right away
		playerDookiesAvailable[attacker]++;
		
		// Prepare message
		new String:victimName[32];
		GetClientName(victim, victimName, sizeof(victimName));
		new String:attackerName[32];
		GetClientName(attacker, attackerName, sizeof(attackerName));
		new String:msg[128];
		Format(msg, sizeof(msg), "%s just dropped an earth-shaking dookie on %s's dead body!", attackerName, victimName);
			
		// Print message
		PrintToChatAll(msg);
	}
	else if (headshot)
	{
		playerHeadshotCount[attacker]++;
	}
	
	return Plugin_Continue;
}

public Action Event_RoundStart(Event event, const char[] name, bool dontBroadcast)
{
	// Clear Dookie Mod stats
	for (new i = 1; i <= MaxClients; i++) 
	{
		// Check they are in-game
		if (IsClientInGame(i)) 
		{
			// Body position
			playerBodyOrigins[i][0] = 0.0;
			playerBodyOrigins[i][1] = 0.0;
			playerBodyOrigins[i][2] = 0.0;
			
			// Dookies
			playerDookiesTaken[i] = 0;
			playerDookiesAvailable[i] = 0;
			
			// Headshots
			playerHeadshotCount[i] = 0;
		}
	}
	
	return Plugin_Continue;
}

public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon) 
{
	if (!IsPlayerAlive(client))
	{
		// Not Alive, exit
		return Plugin_Continue;
	}

	if (buttons & IN_DUCK)
	{

		if (playerCooldown[client] > GetTime())
			return Plugin_Continue;
		
		// Check if we are allowed another this round and if we have one available
		if ((playerDookiesTaken[client] < cv_dookie_limit_round.IntValue) && (playerDookiesAvailable[client] > 0))
		{
			// Player position
			new Float:clientPos[3];
			GetClientAbsOrigin(client, clientPos);

			// Track closest body
			new closestBodyPlayer;
			new Float:closestBodyDist = 9999.0;
			
			// Find nearest player body
			for (new i = 1; i <= MaxClients; i++) 
			{
				// Check if they are in-game and dead
				if (IsClientInGame(i) && !IsPlayerAlive(i)) 
				{
					// Check if this is the closest to the player yet
					new Float:bodyDist = GetVectorDistance(clientPos, playerBodyOrigins[i]);
					if (bodyDist < closestBodyDist)
					{
						closestBodyDist = bodyDist;
						closestBodyPlayer = i;
					}
				}
			}
			
			// Check if the player is near the body
			if (closestBodyDist <= 100.0)
			{
				// Prepare message
				new String:victimName[32];
				GetClientName(closestBodyPlayer, victimName, sizeof(victimName));
				new String:clientName[32];
				GetClientName(client, clientName, sizeof(clientName));
				new String:msg[128];
			
				if (playerHeadshotCount[client] >= cv_dookie_super_hs.IntValue)
				{
					// Super dookie
					CreateSuperDookie(client, clientPos)
					EmitSoundToAll(DOOKIE_SUPER_SOUND);
					
					// Decrement headshots, so they can't keep using it
					playerHeadshotCount[client] -= cv_dookie_super_hs.IntValue;
					
					// Print message
					Format(msg, sizeof(msg), "%s just dropped an earth-shaking dookie on %s's dead body!", clientName, victimName);
					PrintToChatAll(msg);
				}
				else
				{
					// Normal dookie
					CreateDookie(client, clientPos);
					EmitSoundToAll(DOOKIE_SOUND);
				
					// Print message
					Format(msg, sizeof(msg), "%s just took a nasty dookie on %s's dead body.", clientName, victimName);
					PrintToChatAll(msg);
				}
				
				// Change dookie counts
				playerDookiesTaken[client]++;
				playerDookiesAvailable[client]--;
				
				playerCooldown[client] = GetTime() + 3;
			}
		}
	}

	return Plugin_Continue;
}
