int g_iMaxLevel;
Handle g_aWeapons;

void GetConVars()
{
	char g_filename[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, g_filename, sizeof(g_filename), "configs/MyJailbreak/convars.ini");

	Handle file = OpenFile(g_filename, "rt");

	if (file == INVALID_HANDLE)
	{
		SetFailState("MyJailbreak ConVar Toggle - Can't read %s correctly! (ImportFromFile)", g_filename);
	}

	g_aWeapons = CreateArray(32);

	while (!IsEndOfFile(file))
	{
		char line[128];

		if(!ReadFileLine(file, line, sizeof(line)))
		{
			break;
		}

		TrimString(line);

		if (StrContains(line, "/", false) != -1)
		{
			continue;
		}

		if (!line[0])
		{
			continue;
		}

		PushArrayString(g_aWeapons, line);
	}

	CloseHandle(file);
	
	g_iMaxLevel = GetArraySize(g_aWeapons);
}

MyJailbreak_EventStart
{
	for (int i = 0; i <= GetArraySize(g_aWeapons)-1; i++)
	{
		char buffer[32];
		GetArrayString(g_aWeapons, i, buffer, sizeof(buffer));
	}
}
