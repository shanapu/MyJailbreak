#include <sourcemod>
#include <sdktools>
#include <autoexecconfig>
#include <colors>

#pragma semicolon 1

#define DICES 33

new Handle:c_DiceText;
new Handle:c_DiceEnable;
new Handle:c_ShowNumber;
new Handle:c_RandNumber;
new Handle:c_DiceTeam;
new Handle:c_DiceCount;
new Handle:c_DiceMoney;

new Handle:g_colorback = INVALID_HANDLE;
new Handle:g_enabled = INVALID_HANDLE;
new bool:g_refused[MAXPLAYERS+1] = false;
new Handle:Timers[MAXPLAYERS+1];

new String:DiceText[64];

new ShowNumber;
new RandNumber;
new DiceTeam;
new DiceMoney;
new DiceCount;

new friction_default = -1;
new accelerate_default = -1;

new NoclipCounter[MAXPLAYERS + 1];
new ClientDiced[MAXPLAYERS + 1];
new FroggyJumped[MAXPLAYERS + 1];
new fire[MAXPLAYERS + 1];

new bool:EnabledNumbers[DICES+1];
new bool:LongJump[MAXPLAYERS + 1];
new bool:Nightvision[MAXPLAYERS + 1];
new bool:FroggyJump[MAXPLAYERS + 1];
new bool:started;

public Plugin:myinfo =
{
	name = "SM Dice",
	author = "Popoklopsi, shanapu",
	version = "1.6.2,edit",
	description = "Roll the Dice by Popoklopsi",
	url = "https://forums.alliedmods.net/showthread.php?t=152035"
};

public APLRes:AskPluginLoad2(Handle:myself, bool:late, String:error[], err_max)
{
	MarkNativeAsOptional("GetUserMessageType");

	return APLRes_Success;
}

public OnPluginStart()
{
	
	started = false;
	
	RegConsoleCmd("sm_refuse", refusing);
	RegConsoleCmd("sm_v", refusing);
	RegConsoleCmd("sm_verweigern", refusing);
	
	AutoExecConfig_SetFile("MyJailbreak_Dice");
	AutoExecConfig_CreateConVar("sm_dice_version", "1.6.2,edit", "Dice for Souremod by Popoklopsi", FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_DONTRECORD);
	c_DiceEnable = AutoExecConfig_CreateConVar("sm_dice_enable", "1", "enable dice 0 - disabled");
	c_DiceText = AutoExecConfig_CreateConVar("sm_dice_text", "dice", "Command to dice (without exclamation mark), convert to UTF-8 without BOM for special characters");
	c_ShowNumber = AutoExecConfig_CreateConVar("sm_dice_show", "2", "Players, which see the result: 1 = Everybody, 2 = just T's, 3 = just CT's, 4 = Only you");
	c_RandNumber = AutoExecConfig_CreateConVar("sm_dice_rand", "1", "1 = Random text when result is a weapon, 0 = Off");
	c_DiceTeam = AutoExecConfig_CreateConVar("sm_dice_team", "2", "2 = Only T's can dice, 3 = Only CT's can dice, 0 = Everybody can dice");
	c_DiceCount = AutoExecConfig_CreateConVar("sm_dice_count", "1", "How often a player can dice per round");
	c_DiceMoney = AutoExecConfig_CreateConVar("sm_dice_money", "0", "x = Money one dice costs, 0 = Off");
	g_enabled = AutoExecConfig_CreateConVar("sm_refuse_enable", "1.0", "Enable or Disable Refuse Plugin");
	g_colorback = AutoExecConfig_CreateConVar("sm_refuse_time_back", "10.0", "Time after the player gets his normal colors back");
	AutoExecConfig_CleanFile();
	
	LoadEnables();

	AutoExecConfig(true, "MyJailbreak_Dice");
	
	HookConVarChange(c_ShowNumber, OnConVarChanged);
	HookConVarChange(c_RandNumber, OnConVarChanged);
	HookConVarChange(c_DiceTeam, OnConVarChanged);
	
	HookEvent("player_spawn", PlayerSpawn);
	HookEvent("player_death", PlayerDeath);
	HookEvent("player_jump", PlayerJump);
	HookEvent("round_start", RoundStart);
	
	LoadTranslations("MyJailbreakDice.phrases");
}

public OnConfigsExecuted()
{
	decl String:ConsoleCmd[64];
	
	GetConVarString(c_DiceText, DiceText, sizeof(DiceText));
	
	ShowNumber = GetConVarInt(c_ShowNumber);
	RandNumber = GetConVarInt(c_RandNumber);
	DiceTeam = GetConVarInt(c_DiceTeam);
	DiceCount = GetConVarInt(c_DiceCount);
	DiceMoney = GetConVarInt(c_DiceMoney);
	accelerate_default = GetConVarInt(FindConVar("sv_accelerate"));
	friction_default = GetConVarInt(FindConVar("sv_friction"));
	
	if (!started)
	{
		Format(ConsoleCmd, sizeof(ConsoleCmd), "sm_%s", DiceText);
		RegConsoleCmd(ConsoleCmd, TypedText);
		
		started = true;
	}
}

public OnMapStart()
{
	PrecacheSound("weapons/rpg/rocketfire1.wav");
	PrecacheSound("weapons/rpg/rocket1.wav");
	PrecacheSound("weapons/hegrenade/explode3.wav");
	PrecacheModel("Effects/tp_eyefx/tp_eyefx.vmt");
}

public LoadEnables()
{
	decl String:section[5];
	
	new Handle:keycvar = CreateKeyValues("DiceEnables");
	
	if (FileExists("cfg/dice/dice_enables.txt") && FileToKeyValues(keycvar, "cfg/dice/dice_enables.txt"))
	{
		for (new x = 1; x <= DICES; x++)
		{
			Format(section, sizeof(section), "%i", x);
			
			if (KvGetNum(keycvar, section, 1) == 1)
				EnabledNumbers[x] = true;
			else
				EnabledNumbers[x] = false;
		}
	}
	else
	{
		for (new x = 1; x <= DICES; x++)
			EnabledNumbers[x] = true;
	}

	if (!getGame())
		EnabledNumbers[1] = false;
}

public Action:TypedText(client, args)
{
	if (client > 0 && client <= MaxClients && IsClientInGame(client))
		PrepareDice(client);
	
	return Plugin_Handled;
}

public OnConVarChanged(Handle:hCvar, const String:oldValue[], const String:newValue[])
{
	if (hCvar == c_ShowNumber) 
		ShowNumber = StringToInt(newValue);
		
	if (hCvar == c_RandNumber) 
		RandNumber = StringToInt(newValue);
		
	if (hCvar == c_DiceTeam) 
		DiceTeam = StringToInt(newValue);
}

public Action:refusing(client, args)
{
	new isOn = GetConVarBool(g_enabled);
	if ((isOn) == 1)
	{
		if (GetClientTeam(client) == 2 && (IsPlayerAlive(client)))
		{
			if (!(g_refused[client]))
			{
				g_refused[client] = true;
				new Float:refuse_color_time = GetConVarFloat(g_colorback);
				SetEntityRenderMode(client,RENDER_TRANSCOLOR);
				SetEntityRenderColor(client, 0, 0, 255, 255);
				TextPrint(client);
				Timers[client] = CreateTimer(refuse_color_time, ResetColor, client);
			}
			else
			{
				CPrintToChat(client, "%t", "MESSAGE_ALREADYREFUSED");
			}
		}
		else
		{
			CPrintToChat(client, "%t", "MESSAGE_DEATHORNOTT");
		}
	}
	return Plugin_Handled;
}

public OnClientDisconnect(client)
{
	if (Timers[client] != INVALID_HANDLE)
	{
		CloseHandle(Timers[client]);
		Timers[client] = INVALID_HANDLE;
	}
}

public Action:TextPrint(client)
{	
	new String:getName[MAX_NAME_LENGTH];
	GetClientName(client, getName, sizeof(getName));
	CPrintToChatAll("%t", "MESSAGE_REFUSING", getName);
}

public Action:ResetColor(Handle:timer, any:client)
{
	if (IsClientConnected(client))
	{
		SetEntityRenderMode(client,RENDER_TRANSCOLOR);
		SetEntityRenderColor(client, 255, 255, 255, 255);
	}
	Timers[client] = INVALID_HANDLE;
}

public RoundStart(Handle:event, const String:name[], bool:dontBroadcast)
{
	new Handle:fr = FindConVar("sv_friction");
	new Handle:ac = FindConVar("sv_accelerate");

	if (GetConVarInt(fr) != friction_default && friction_default != -1)
		SetConVarInt(fr, friction_default, true, false);

	if (GetConVarInt(ac) != accelerate_default && accelerate_default != -1)
		SetConVarInt(ac, accelerate_default, true, false);
		
	for(new client=1; client<=MaxClients; client++)
	{
		if (IsClientConnected(client))
		{
			g_refused[client] = false;
			if (Timers[client] != INVALID_HANDLE)
			{
				CloseHandle(Timers[client]);
				Timers[client] = INVALID_HANDLE;
			}
		}
	}
}

public PlayerSpawn(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	if (IsPlayerAlive(client) && IsClientInGame(client))
	{
		CPrintToChat(client, "[%t] %t", "dice", "start", DiceText);
		
		NoclipCounter[client] = 5;
		ClientDiced[client] = 0;
		FroggyJumped[client] = 0;
		Nightvision[client] = false;
		LongJump[client] = false;
		FroggyJump[client] = false;
		
		reset(client);
	}
}

public PlayerDeath(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	reset(client);
}

public PlayerJump(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	if (LongJump[client]) 
		longjump(client);
}

public Action:OnPlayerRunCmd(client, &buttons, &impulse, Float:vel[3], Float:angles[3], &weapon)
{
	if (!IsClientInGame(client) || !IsPlayerAlive(client) || !FroggyJump[client])
		return Plugin_Continue;
	
	static bool:bPressed[MAXPLAYERS+1] = false;

	if(GetEntityFlags(client) & FL_ONGROUND)
	{
		FroggyJumped[client] = 0;
		bPressed[client] = false;
	}
	else
	{
		if (buttons & IN_JUMP)
		{
			if(!bPressed[client])
			{
				if(FroggyJumped[client]++ == 1)
					froggyjump(client);
			}

			bPressed[client] = true;
		}
		else
			bPressed[client] = false;
	}

	
	return Plugin_Continue;
}

public PrepareDice(client)
{
	decl String:Prefix[64];
	
	Format(Prefix, sizeof(Prefix), "[%T] ", "dice", client);

	new money = GetEntData(client, FindSendPropOffs("CCSPlayer", "m_iAccount"));
	
	if(GetConVarInt(c_DiceEnable) == 1)
	{
	if (!DiceTeam || GetClientTeam(client) == DiceTeam)
	{
		if (ClientDiced[client] < DiceCount)
		{
			if (IsPlayerAlive(client))
			{
				if (DiceMoney > 0)
				{
					if ((money - DiceMoney) >= 0)
					{
						SetEntData(client, FindSendPropOffs("CCSPlayer", "m_iAccount"), money - DiceMoney);

						ClientDiced[client]++;
						DiceNow(client);
					}
					else CPrintToChat(client, "%s%t", Prefix, "money", DiceMoney);
				}
				else
				{
					ClientDiced[client]++;
					DiceNow(client);
				}
			}
			else CPrintToChat(client, "%s%t", Prefix, "dead");
		}
		else CPrintToChat(client, "%s%t", Prefix, "already", DiceCount);
	}
	else CPrintToChat(client, "%s%t", Prefix, "wrong");
	}
	else CPrintToChat(client, "%s%t", Prefix, "disabled");
}

DiceNow(client)
{
	new number;
	new count;

	if(GetConVarInt(c_DiceEnable) == 1)
	{
	CPrintToChat(client, "[%t] %t", "dice", "rolling", ClientDiced[client], DiceCount);

	number = count = GetRandomInt(1, DICES);

	while(!EnabledNumbers[number])
	{
		if (number == DICES)
			number = 1;
		else
			number = number % DICES + 1;

		if (number == count)
			return;
	}

	switch (number)
	{
		case 1:
		{
			drunk(client);
		}
		case 2:
		{
			drug(client);
		}
		case 3:
		{
			burn(client, 70);
		}
		case 4:
		{
			speed(client, 1.65);
		}
		case 5:
		{
			rocket(client);
		}
		case 7:
		{
			LongJump[client] = true;
		}
		case 8:
		{
			item(client, 1);
		}
		case 9:
		{
			health(client, 50, 3);
		}
		case 10:
		{
			health(client, 50, 2);
		}
		case 11:
		{
			speed(client, 0.65);
		}
		case 12:
		{
			item(client, 2);
		}
		case 13:
		{
			item(client, 3);
		}
		case 15:
		{
			gravity(client, 0.5);
		}
		case 16:
		{
			gravity(client, 2.0);
		}
		case 17:
		{
			speed(client, 1.65);
			health(client, 50, 2);
		}
		case 18:
		{
			health(client, 30, 3);
			gravity(client, 0.5);
			speed(client, 0.65);
		}
		case 19:
		{
			gravity(client, 2.0);
			speed(client, 0.65);
			health(client, 30, 2);
		}
		case 20:
		{
			noclip(client, true, 5.0);
			
			CPrintToChat(client, "[%t] %t", "dice", "noclip", NoclipCounter[client]);
			
			CreateTimer(1.0, NclipTimer, client, TIMER_REPEAT);
		}
		case 21:
		{
			freeze(client, true, 30.0);
		}
		case 22:
		{
			shake(client, 100, 60, 140);
		}
		case 23:
		{
			item(client, 4);
		}
		case 24:
		{
			health(client, 1, 1);
		}
		case 25:
		{
			item(client, 5);
		}
		case 26:
		{
			FroggyJump[client] = true;
		}
		case 27:
		{
			Nightvision[client] = true;
		}
		case 28:
		{
			SetEntProp(client, Prop_Send, "m_iDefaultFOV", 35);
			SetEntProp(client, Prop_Send, "m_iFOV", 35);
		}
		case 29:
		{
			SetEntProp(client, Prop_Send, "m_iDefaultFOV", 200);
			SetEntProp(client, Prop_Send, "m_iFOV", 200);
		}
		case 30:
		{
			SetInvisible(client, false);
		}
		case 31:
		{
			SetOnFire(client, false);
			speed(client, 1.65);
			health(client, 100, 2);
		}
		case 32:
		{
			new Handle:cvar = FindConVar("sv_accelerate");

			if (cvar != INVALID_HANDLE)
				SetConVarInt(cvar, -5, true, false);
		}
		case 33:
		{
			new Handle:cvar = FindConVar("sv_friction");

			if (cvar != INVALID_HANDLE)
				SetConVarInt(cvar, 1, true, false);
		}
	}
	
	ShowText(client, number);
	}
}

public Action:NclipTimer(Handle:timer, any:client)
{
	if (NoclipCounter[client] > 0 && IsPlayerAlive(client) && IsClientInGame(client))
	{
		CPrintToChat(client, "[%t] %t", "dice", "noclip", NoclipCounter[client]);

		NoclipCounter[client]--;
		
		return Plugin_Continue;
	}
	
	noclip(client, false, 0.0);
	
	return Plugin_Stop;
}

ShowText(client, DiceNumber)
{
	decl String:Prefix[64];
	decl String:trans[10];
	decl String:trans_all[20];

	new clients[MAXPLAYERS + 1];
	new ClientCount = 0;

	Format(Prefix, sizeof(Prefix), "[%T] ", "dice", LANG_SERVER);

	Format(trans, sizeof(trans), "dice%i", DiceNumber);
	Format(trans_all, sizeof(trans_all), "dice%i_all", DiceNumber);
	
	if (ShowNumber != 4)
	{
		for (new x=1; x <= MaxClients; x++)
		{
			if (IsClientInGame(x))
			{
				if (ShowNumber == 1 || ShowNumber == GetClientTeam(x))
					clients[ClientCount++] = x;
			}
		}
	}
	else
	{
		clients[0] = client;
		ClientCount = 1;
	}
	
	if ((DiceNumber == 8 || DiceNumber == 23 || DiceNumber == 25) && RandNumber == 1)
	{
		while (DiceNumber == 8 || DiceNumber == 22 || DiceNumber == 24)
			DiceNumber = GetRandomInt(1, DICES);
			
		Format(trans, sizeof(trans), "dice%i", DiceNumber);
		
		CPrintToChat(client, "%s%t", Prefix, "deagle");
		CPrintToChat(client, "%s%t", Prefix, "deagle");
	}

	if ((DiceNumber == 32 || DiceNumber == 33) && ShowNumber != 1)
		CPrintToChatAll("%s%t", Prefix, trans_all, DiceNumber);

	for (new x=0; x < ClientCount; x++)
		CPrintToChat(clients[x], "%s%t", Prefix, trans, client, DiceNumber);
}

// PRESETS

public reset(client)
{
	if (!IsClientInGame(client)) 
		return;
	
	new Float:pos[3];
	new Float:angs[3];
	
	gravity(client, 1.0);
	noclip(client, false, 0.0);
	freeze(client, false, 0.0);
	speed(client, 1.0);
	godmode(client, false);

	SetInvisible(client, true);
	SetOnFire(client, true);
	
	ExtinguishEntity(client);
	ClientCommand(client, "r_screenoverlay 0");
	
	GetClientAbsOrigin(client, pos);
	GetClientEyeAngles(client, angs);

	SetEntProp(client, Prop_Send, "m_iDefaultFOV", 90);
	
	angs[2] = 0.0;
	
	TeleportEntity(client, pos, angs, NULL_VECTOR);	
	
	new Handle:message = StartMessageOne("Fade", client, USERMSG_RELIABLE|USERMSG_BLOCKHOOKS);
			
	if(GetFeatureStatus(FeatureType_Native, "GetUserMessageType") == FeatureStatus_Available && GetUserMessageType() == UM_Protobuf) 
	{
		PbSetInt(message, "duration", 1536);
		PbSetInt(message, "hold_time", 1536);
		PbSetInt(message, "flags", (0x0001 | 0x0010));
		PbSetColor(message, "clr", {0, 0, 0, 0});
	}
	else
	{
		BfWriteShort(message, 1536);
		BfWriteShort(message, 1536);
		BfWriteShort(message, (0x0001 | 0x0010));
		BfWriteByte(message, 0);
		BfWriteByte(message, 0);
		BfWriteByte(message, 0);
		BfWriteByte(message, 0);
	}

	EndMessage();
	
	message = StartMessageOne("Shake", client, USERMSG_RELIABLE|USERMSG_BLOCKHOOKS);

	if(GetFeatureStatus(FeatureType_Native, "GetUserMessageType") == FeatureStatus_Available && GetUserMessageType() == UM_Protobuf) 
	{
		PbSetInt(message, "command", 1);
		PbSetFloat(message, "local_amplitude", 0.0);
		PbSetFloat(message, "frequency", 0.0);
		PbSetFloat(message, "duration", 1.0);
	}
	else
	{
		BfWriteByte(message, 1);
		BfWriteFloat(message, 0.0);
		BfWriteFloat(message, 0.0);
		BfWriteFloat(message, 1.0);
	}
	
	EndMessage();	
}

public longjump(client)
{
	if (!IsClientInGame(client) || !IsPlayerAlive(client)) 
		return;
	
	new Float:velocity[3];
	new Float:velocity0;
	new Float:velocity1;
	
	velocity0 = GetEntPropFloat(client, Prop_Send, "m_vecVelocity[0]");
	velocity1 = GetEntPropFloat(client, Prop_Send, "m_vecVelocity[1]");
	
	velocity[0] = (7.0 * velocity0) * (1.0 / 4.1);
	velocity[1] = (7.0 * velocity1) * (1.0 / 4.1);
	velocity[2] = 0.0;
	
	SetEntPropVector(client, Prop_Send, "m_vecBaseVelocity", velocity);
}

public froggyjump(client)
{
	new Float:velocity[3];
	new Float:velocity0;
	new Float:velocity1;
	new Float:velocity2;
	new Float:velocity2_new;

	velocity0 = GetEntPropFloat(client, Prop_Send, "m_vecVelocity[0]");
	velocity1 = GetEntPropFloat(client, Prop_Send, "m_vecVelocity[1]");
	velocity2 = GetEntPropFloat(client, Prop_Send, "m_vecVelocity[2]");

	velocity2_new = 260.0;

	if (velocity2 < 150.0) 
		velocity2_new = 270.0;
	if (velocity2 < 100.0) 
		velocity2_new = 300.0;
	if (velocity2 < 50.0) 
		velocity2_new = 330.0;
	if (velocity2 < 0.0) 
		velocity2_new = 380.0;
	if (velocity2 < -50.0) 
		velocity2_new = 400.0;
	if (velocity2 < -100.0) 
		velocity2_new = 430.0;
	if (velocity2 < -150.0) 
		velocity2_new = 450.0;
	if (velocity2 < -200.0) 
		velocity2_new = 470.0;

	velocity[0] = velocity0 * 0.1;
	velocity[1] = velocity1 * 0.1;
	velocity[2] = velocity2_new;
	
	SetEntPropVector(client, Prop_Send, "m_vecBaseVelocity", velocity);
}

public OnGameFrame()
{
	for (new i = 1; i < MaxClients + 1; i++)
	{
		if (IsClientInGame(i) && IsPlayerAlive(i) && Nightvision[i])
			SetEntProp(i, Prop_Send, "m_bNightVisionOn", 1);
	}
}

public SetInvisible(client, bool:visible)
{
	new weapon;	

	new RenderMode:mode;
	new alpha;

	if (visible)
	{
		mode = RENDER_NORMAL;
		alpha = 255;
	}
	else
	{
		mode = RENDER_TRANSCOLOR;
		alpha = 20;
	}

	for (new i = 0; i < 4; i++)
	{
		if ((weapon = GetPlayerWeaponSlot(client, i)) != -1)
		{
			SetEntityRenderMode(weapon, mode);
			SetEntityRenderColor(weapon, 255, 255, 255, alpha);
		}
	}

	SetEntityRenderColor(client, 255, 255, 255, alpha);
	SetEntityRenderMode(client, mode);
}

public SetOnFire(client, bool:extinguish)
{
	if (fire[client] != 0) 
	{
		if (IsValidEntity(fire[client]))
		{
			decl String:class[128];
			
			GetEdictClassname(fire[client], class, sizeof(class));
			
			if (StrEqual(class, "env_fire")) 
				RemoveEdict(fire[client]);
		}
		
		fire[client] = 0;
	}

	if (!extinguish)
		CreateTimer(2.0, SetOnFireTimer, client);
}

public Action:SetOnFireTimer(Handle:timer, any:client)
{
	if (IsClientInGame(client))
	{
		if ((GetClientTeam(client) == 2 || GetClientTeam(client) == 3) && IsPlayerAlive(client))
		{
			new view = CreateEntityByName("env_fire");
			
			if (view != -1)
			{
				DispatchKeyValue(view, "ignitionpoint", "0");
				DispatchKeyValue(view, "spawnflags", "285");
				DispatchKeyValue(view, "fireattack", "0");
				DispatchKeyValue(view, "firesize", "512");
				DispatchKeyValueFloat(view, "damagescale", 0.0);
				
				if (DispatchSpawn(view))
				{
					decl Float:origin[3];
					decl String:steamid[20];
					
					if (IsValidEntity(view))
					{
						fire[client] = view;
						
						GetClientAbsOrigin(client, origin);
						
						TeleportEntity(view, origin, NULL_VECTOR, NULL_VECTOR);

						origin[2] = origin[2] + 90;

						AcceptEntityInput(view, "StartFire");
						
						GetClientAuthId(client, AuthId_Steam2, steamid, sizeof(steamid));
						DispatchKeyValue(client, "targetname", steamid);
						
						SetVariantString(steamid);
						AcceptEntityInput(view, "SetParent");
					}
				}
			}
		}
	}
}

public gravity(client, Float:amount)
{
	SetEntityGravity(client, amount);
}

public item(client, type)
{
	switch(type)
	{
		case 1:
		{
			GivePlayerItem(client, "weapon_deagle");
		}
		case 2:
		{
			GivePlayerItem(client, "weapon_hegrenade");
		}
		case 3:
		{
			GivePlayerItem(client, "weapon_flashbang");
			GivePlayerItem(client, "weapon_flashbang");
		}
		case 4:
		{
			GivePlayerItem(client, "weapon_glock");
		}
		case 5:
		{
			if (getGame())
				GivePlayerItem(client, "weapon_m3");
			else
				GivePlayerItem(client, "weapon_sawedoff");
		}
	}
}

public bool:getGame()
{
	decl String:game[64];

	GetGameFolderName(game, sizeof(game));

	return (StrEqual(game, "cstrike", false));
}

public noclip(client, bool:turnOn, Float:time)
{
	if (IsClientInGame(client))
	{
		if (turnOn)
		{
			SetEntityMoveType(client, MOVETYPE_NOCLIP);
		}
		else
			SetEntityMoveType(client, MOVETYPE_WALK);
	}
}

public freeze(client, bool:turnOn, Float:time)
{	
	if (IsClientInGame(client))
	{
		if (turnOn)
		{
			SetEntityMoveType(client, MOVETYPE_NONE);
			
			if (time > 0) 
				CreateTimer(time, freezeOff, client);
		}
		else
			SetEntityMoveType(client, MOVETYPE_WALK);
	}
}

public health(client, amount, type)
{
	switch(type)
	{
		case 1:
		{
			SetEntityHealth(client, amount);
		}
		case 2:
		{
			SetEntityHealth(client, GetClientHealth(client) + amount);
		}
		case 3:
		{
			new nhealth = GetClientHealth(client) - amount;

			if (nhealth <= 0)
				ForcePlayerSuicide(client);
			else
				SetEntityHealth(client, nhealth);
		}
	}
}

public drunk(client)
{
	ClientCommand(client, "r_screenoverlay Effects/tp_eyefx/tp_eyefx.vmt");
}

public drug(client)
{
	CreateTimer(1.0, drug_loop, client, TIMER_REPEAT);	
}

public burn(client, health)
{
	new Float:time = float(health) / 5.0;
	
	if (health < 100) 
		IgniteEntity(client, time);
	else 
		IgniteEntity(client, 100.0);
}

public speed(client, Float:speed)
{
	SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", speed); 
}

public rocket(client)
{
	new Float:Origin[3];
	
	GetClientAbsOrigin(client, Origin);
	
	Origin[2] = Origin[2] + 20;
	
	godmode(client, true);
	shake(client, 10, 40, 25);
	
	EmitSoundToAll("weapons/rpg/rocketfire1.wav", client, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, 0.5);
	
	CreateTimer(1.0, PlayRocketSound, client);
	CreateTimer(3.1, EndRocket, client);
}

public godmode(client, bool:turnOn)
{
	if (turnOn) 
		SetEntProp(client, Prop_Data, "m_takedamage", 0, 1);
	else
		SetEntProp(client, Prop_Data, "m_takedamage", 2, 1);
}

stock shake(client, time, distance, value)
{
	new Handle:message = StartMessageOne("Shake", client, USERMSG_RELIABLE|USERMSG_BLOCKHOOKS);

	if(GetFeatureStatus(FeatureType_Native, "GetUserMessageType") == FeatureStatus_Available && GetUserMessageType() == UM_Protobuf) 
	{
		PbSetInt(message, "command", 0);
		PbSetFloat(message, "local_amplitude", float(value));
		PbSetFloat(message, "frequency", float(distance));
		PbSetFloat(message, "duration", float(time));
	}
	else
	{
		BfWriteByte(message, 0);
		BfWriteFloat(message, float(value));
		BfWriteFloat(message, float(distance));
		BfWriteFloat(message, float(time));
	}
	
	EndMessage();	
}

public Action:PlayRocketSound(Handle:timer, any:client)
{
	if (!IsClientInGame(client) || !IsPlayerAlive(client)) 
		return;
	
	new Float:Origin[3];
	
	GetClientAbsOrigin(client, Origin);
	
	Origin[2] = Origin[2] + 50;
	
	EmitSoundToAll("weapons/rpg/rocket1.wav", client, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, 0.5);
	
	for (new x=1; x <= 15; x++) 
		CreateTimer(0.2*x, rocket_loop, client);
	
	TeleportEntity(client, Origin, NULL_VECTOR, NULL_VECTOR);
}

public Action:EndRocket(Handle:timer, any:client)
{
	if (!IsClientInGame(client) || !IsPlayerAlive(client))
		return Plugin_Stop;
	
	new Float:Origin[3];
	
	GetClientAbsOrigin(client, Origin);
	
	Origin[2] = Origin[2] + 50;
	
	for (new x=1; x <= MaxClients; x++)
	{
		if (IsClientConnected(x)) 
			StopSound(x, SNDCHAN_AUTO, "weapons/rpg/rocket1.wav");
	}
	
	EmitSoundToAll("weapons/hegrenade/explode3.wav", client, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, 0.5);
	
	new expl = CreateEntityByName("env_explosion");
	
	TeleportEntity(expl, Origin, NULL_VECTOR, NULL_VECTOR);
	
	DispatchKeyValue(expl, "fireballsprite", "sprites/zerogxplode.spr");
	DispatchKeyValue(expl, "spawnflags", "0");
	DispatchKeyValue(expl, "iMagnitude", "1000");
	DispatchKeyValue(expl, "iRadiusOverride", "100");
	DispatchKeyValue(expl, "rendermode", "0");
	
	DispatchSpawn(expl);
	ActivateEntity(expl);
	
	AcceptEntityInput(expl, "Explode");
	AcceptEntityInput(expl, "Kill");
	
	godmode(client, false);
	ForcePlayerSuicide(client);

	return Plugin_Handled;
}

public Action:drug_loop(Handle:timer, any:client)
{
	if (!IsClientInGame(client)) 
		return Plugin_Stop;
	
	new Float:DrugAngles[20] = {0.0, 5.0, 10.0, 15.0, 20.0, 25.0, 20.0, 15.0, 10.0, 5.0, 0.0, -5.0, -10.0, -15.0, -20.0, -25.0, -20.0, -15.0, -10.0, -5.0};

	if (!IsPlayerAlive(client))
	{
		new Float:pos[3];
		new Float:angs[3];
		
		GetClientAbsOrigin(client, pos);
		GetClientEyeAngles(client, angs);
		
		angs[2] = 0.0;
		
		TeleportEntity(client, pos, angs, NULL_VECTOR);	
		
		new Handle:message = StartMessageOne("Fade", client, USERMSG_RELIABLE|USERMSG_BLOCKHOOKS);
		
		if(GetFeatureStatus(FeatureType_Native, "GetUserMessageType") == FeatureStatus_Available && GetUserMessageType() == UM_Protobuf) 
		{
			PbSetInt(message, "duration", 1536);
			PbSetInt(message, "hold_time", 1536);
			PbSetInt(message, "flags", (0x0001 | 0x0010));
			PbSetColor(message, "clr", {0, 0, 0, 0});
		}
		else
		{
			BfWriteShort(message, 1536);
			BfWriteShort(message, 1536);
			BfWriteShort(message, (0x0001 | 0x0010));
			BfWriteByte(message, 0);
			BfWriteByte(message, 0);
			BfWriteByte(message, 0);
			BfWriteByte(message, 0);
		}
		
		EndMessage();	
		
		return Plugin_Stop;
	}
	
	new Float:pos[3];
	new Float:angs[3];
	new coloring[4];

	coloring[0] = GetRandomInt(0,255);
	coloring[1] = GetRandomInt(0,255);
	coloring[2] = GetRandomInt(0,255);
	coloring[3] = 128;
	
	GetClientAbsOrigin(client, pos);
	GetClientEyeAngles(client, angs);
	
	angs[2] = DrugAngles[GetRandomInt(0,100) % 20];
	
	TeleportEntity(client, pos, angs, NULL_VECTOR);

	new Handle:message = StartMessageOne("Fade", client);

	if(GetFeatureStatus(FeatureType_Native, "GetUserMessageType") == FeatureStatus_Available && GetUserMessageType() == UM_Protobuf) 
	{
		PbSetInt(message, "duration", 255);
		PbSetInt(message, "hold_time", 255);
		PbSetInt(message, "flags", (0x0002));
		PbSetColor(message, "clr", coloring);
	}
	else
	{
		BfWriteShort(message, 255);
		BfWriteShort(message, 255);
		BfWriteShort(message, (0x0002));
		BfWriteByte(message, GetRandomInt(0,255));
		BfWriteByte(message, GetRandomInt(0,255));
		BfWriteByte(message, GetRandomInt(0,255));
		BfWriteByte(message, 128);
	}
	
	EndMessage();	
		
	return Plugin_Handled;
}

public Action:rocket_loop(Handle:timer, any:client)
{
	if (!IsClientInGame(client) || !IsPlayerAlive(client))
		return Plugin_Stop;
		
	new Float:velocity[3];
	
	velocity[2] = 300.0;
	
	TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, velocity);
	
	return Plugin_Handled;
}

public Action:freezeOff(Handle:timer, any:client)
{
	freeze(client, false, 0.0);
	
	return Plugin_Handled;
}