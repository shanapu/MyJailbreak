#if defined _levelsranks_included_
  #endinput
#endif
#define _levelsranks_included_

#define PLUGIN_VERSION "v2.2.0"

int		iColorsOther[] = {0xFFFFFF, 0xFF0000, 0x00AD00, 0x00FF00, 0x99FF99, 0xFF4040, 0xCCCCCC, 0xFFBD6B, 0xFA8B00, 0x99CCFF, 0x3D46FF, 0xFA00FA};
char		sColors[][] = {"{DEF}", "{RED}", "{GREEN}", "{LIME}", "{LIGHTGREEN}", "{LIGHTRED}", "{GRAY}", "{LIGHTOLIVE}", "{OLIVE}", "{LIGHTBLUE}", "{BLUE}", "{PURPLE}"};
char		sColorsCSGO[][] = {"\x01", "\x02", "\x04", "\x05", "\x06", "\x07", "\x08", "\x09", "\x10", "\x0B", "\x0C", "\x0E"};

/**
 * Проверяет, запущено ли ядро
 * 
 * @return bool		Если true - запущено, иначе false
 */
native bool LR_CoreStarted();

/**
 * Проверяет, хватает ли игроков в данном раунде, чтобы им менять расчетные единицы
 * 
 * @return bool		Если true - хватает, иначе false
 */
native bool LR_CoreIsReady();

/**
 * Получает ID типа статистики
 * 
 * @return int			ID типа статистики
 */
native int LR_TypeStatistics();

/**
 * Отмечает модуль, как активный
 * 
 * @noreturn
 */
native void LR_ModuleCount();

/**
 * Получает место клиента в ТОПе
 * 
 * @param iClient		Индекс клиента.
 * @return int			Место клиента в ТОПе
 */
native int LR_GetClientPos(int iClient);

/**
 * Получает ранг клиента
 * 
 * @param iClient		Индекс клиента.
 * @return int			Ранг клиента
 */
native int LR_GetClientRank(int iClient);

/**
 * Получает значение расчетных единиц (очки опыта/счетчик времени) клиента
 * 
 * @param iClient		Индекс клиента.
 * @return int			Расчетные единицы (очки опыта/счетчик времени) клиента
 */
native int LR_GetClientValue(int iClient);

/**
 * Получает подробную статистику об игроке
 * 
 * @param iClient		Индекс клиента.
 * @param iStats		ID получаемых данных (от 0 до 5).
 * 	0 - убийств
 * 	1 - смертей
 * 	2 - выстрелов
 * 	3 - попаданий
 * 	4 - хедшотов
 * 	5 - ассистов
 * @return int			Значение выбранных данных
 */
native int LR_GetClientStats(int iClient, int iStats);

/**
 * Выдает VIP-статус игроку
 * 
 * @param iClient		Индекс клиента.
 * @param iTime		Время в Unix TimeStamp, до которого у игрока будет VIP-статус.
 * @param iGroup		ID группы VIPки присваиваемый игроку (settings_vip.ini).
 * @return bool		Если true - VIP выдан, иначе false.
 */
native bool LR_SetClientVIP(int iClient, int iTime, int iGroup);

/**
 * Удаляет VIP-статус игрока
 * 
 * @param iClient		Индекс клиента.
 * @return bool		Если true - VIP удален, иначе false.
 */
native bool LR_DeleteClientVIP(int iClient);

/**
 * Изменяет кол-во расчетных единиц у игрока
 * 
 * @param iClient		Индекс клиента.
 * @param iAmount	Кол-во расчетных единиц (очки опыта/счетчик времени)
 * @return int			Новое значение кол-ва расчетных единиц.
 */
native int LR_ChangeClientValue(int iClient, int iAmount);

/**
 * Вызывает меню инвентаря (используется модулями для возможности откатиться назад по Менюшке)
 * 
 * @param iClient		Индекс клиента.
 * @noreturn
 */
native void LR_MenuInventory(int iClient);

/**
 * Вызывается, когда ядро запущено
 * 
 * @noreturn
 */
forward void LR_OnCoreStarted();

/**
 * Вызывается, когда открывается список Инвентаря
 * 
 * @noreturn
 */
forward void LR_OnMenuCreated(int iClient, int iRank, Menu& hMenu);

/**
 * Вызывается, когда открывается список Инвентаря
 * 
 * @noreturn
 */
forward void LR_OnMenuItemSelected(int iClient, int iRank, const char[] sInfo);

stock bool IsValidClient(int iClient)
{
	return (1 <= iClient <= MaxClients && IsClientInGame(iClient)) ? true : false;
}

stock void LR_PrintToChat(int iClient, char[] szMessage, any ...)
{
	if(IsValidClient(iClient) && !IsFakeClient(iClient))
	{
		char	szBuffer[PLATFORM_MAX_PATH],
			szNewMessage[PLATFORM_MAX_PATH];

		SetGlobalTransTarget(iClient);

		switch(GetEngineVersion())
		{
			case Engine_CSGO:
			{
				Format(szBuffer, sizeof(szBuffer), " \x01%s", szMessage);
				VFormat(szNewMessage, sizeof(szNewMessage), szBuffer, 3);

				for(int i = 0; i < 12; i++)
				{
					ReplaceString(szNewMessage, sizeof(szNewMessage), sColors[i], sColorsCSGO[i]);
				}
				ReplaceString(szNewMessage, sizeof(szNewMessage), "{TEAM}", "\x03");
			}

			case Engine_CSS, Engine_TF2:
			{
				char sBuff[64];
				Format(szBuffer, sizeof(szBuffer), "\x01%s", szMessage);
				VFormat(szNewMessage, sizeof(szNewMessage), szBuffer, 3);

				switch(GetClientTeam(iClient))
				{
					case 1: Format(sBuff, sizeof(sBuff), "\x07%06X", iColorsOther[6]);
					case 2: Format(sBuff, sizeof(sBuff), "\x07%06X", iColorsOther[5]);
					case 3: Format(sBuff, sizeof(sBuff), "\x07%06X", iColorsOther[9]);
				}
				ReplaceString(szNewMessage, sizeof(szNewMessage), "{TEAM}", sBuff);

				for(int i = 0; i < 12; i++)
				{
					Format(sBuff, sizeof(sBuff), "\x07%06X", iColorsOther[i]);
					ReplaceString(szNewMessage, sizeof(szNewMessage), sColors[i], sBuff);
				}
			}
		}

		Handle hBf = StartMessageOne("SayText2", iClient, USERMSG_RELIABLE | USERMSG_BLOCKHOOKS);
		if(hBf != null)
		{
			if(GetUserMessageType() == UM_Protobuf)
			{
				Protobuf hProtoBuffer = UserMessageToProtobuf(hBf);
				hProtoBuffer.SetInt("ent_idx", iClient);
				hProtoBuffer.SetBool("chat", true);
				hProtoBuffer.SetString("msg_name", szNewMessage);
				hProtoBuffer.AddString("params", "");
				hProtoBuffer.AddString("params", "");
				hProtoBuffer.AddString("params", "");
				hProtoBuffer.AddString("params", "");
			}
			else
			{
				BfWrite hBfBuffer = UserMessageToBfWrite(hBf);
				hBfBuffer.WriteByte(iClient);
				hBfBuffer.WriteByte(true);
				hBfBuffer.WriteString(szNewMessage);
			}
		}
		EndMessage();
	}
}

public SharedPlugin __pl_levelsranks = 
{
	name = "levelsranks",
	file = "levelsranks.smx",

	#if defined REQUIRE_PLUGIN
		required = 1,
	#else
		required = 0,
	#endif
};

#if !defined REQUIRE_PLUGIN
public __pl_levelsranks_SetNTVOptional()
{
	MarkNativeAsOptional("LR_CoreStarted");
	MarkNativeAsOptional("LR_CoreIsReady");
	MarkNativeAsOptional("LR_TypeStatistics");
	MarkNativeAsOptional("LR_ModuleCount");
	MarkNativeAsOptional("LR_GetClientPos");
	MarkNativeAsOptional("LR_GetClientRank");
	MarkNativeAsOptional("LR_GetClientValue");
	MarkNativeAsOptional("LR_GetClientStats");
	MarkNativeAsOptional("LR_SetClientVIP");
	MarkNativeAsOptional("LR_DeleteClientVIP");
	MarkNativeAsOptional("LR_ChangeClientValue");
	MarkNativeAsOptional("LR_MenuInventory");
}
#endif