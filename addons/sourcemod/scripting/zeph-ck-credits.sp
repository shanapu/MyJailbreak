// Includes
#include <sourcemod>
#include <store>
#include <cksurf>

// Compiler Options
#pragma semicolon 1
#pragma newdecls required

ConVar gc_iCreditsNormal;
ConVar gc_iCreditsBonus;
ConVar gc_iCreditsPrac;

// Info
public Plugin myinfo = 
{
	name = "[CKsurf] Store Credits Giver",
	author = "shanapu",
	description = "Give Credits for Zephs Store on finished map",
	version = "1.0",
	url = "https://github.com/shanapu/"
};

public void OnPluginStart()
{
	gc_iCreditsNormal = CreateConVar("sm_cksurfcredits_normal", "50", "How many credits for finishing map?", _, true, 1.0);
	gc_iCreditsBonus = CreateConVar("sm_cksurfcredits_bonus", "100", "How many credits for finishing bonus?", _, true, 1.0);
	gc_iCreditsPrac = CreateConVar("sm_cksurfcredits_practise", "25", "How many credits for finishing practise?", _, true, 1.0);
}

public Action ckSurf_OnMapFinished(int client, float fRunTime, char sRunTime[54], int rank, int total)
{
	if(!IsValidClient(client))
	{
		return;
	}

	Store_SetClientCredits(client, Store_GetClientCredits(client) + gc_iCreditsNormal.IntValue);

	PrintToChat(client, "\x04[Store]\x01 You have successfully earned %d cash for finishing this map.", gc_iCreditsNormal.IntValue);
}

public Action ckSurf_OnBonusFinished(int client, float fRunTime, char sRunTime[54], int rank, int total, int bonusid)
{	
	if(!IsValidClient(client))
	{
		return;
	}

	Store_SetClientCredits(client, Store_GetClientCredits(client) + gc_iCreditsBonus.IntValue);

	PrintToChat(client, "\x04[Store]\x01 You have successfully earned %d cash for finishing the bonus.", gc_iCreditsBonus.IntValue);
}

public Action ckSurf_OnPracticeFinished(int client, float fRunTime, char sRunTime[54])
{
	if(!IsValidClient(client))
	{
		return;
	}

	Store_SetClientCredits(client, Store_GetClientCredits(client) + gc_iCreditsPrac.IntValue);

	PrintToChat(client, "\x04[Store]\x01 You have successfully earned %d cash for finishing the practise.", gc_iCreditsPrac.IntValue);
}

bool IsValidClient(int client, bool bAlive = false)
{
	if(client >= 1 && client <= MaxClients && IsClientConnected(client) && IsClientInGame(client) && (bAlive == false || IsPlayerAlive(client)))
	{
		return true;
	}
	
	return false;
}