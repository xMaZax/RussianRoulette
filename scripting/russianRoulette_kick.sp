#include rusroulette
#include sourcemod

static const char MNAME[] = "chr_kick";

public Plugin myinfo =
{
	name = "[RUSRoulette] Kick",
	author = "wAries",
	description = "Russian roulette for the game chat",
	version = MAIN_VER,
	url = "whyaries.ru"
}

public void OnPluginStart()
{
    LoadTranslations("rusroulette.phrases");

    if(Chr_IsPlugStarted())
        Chr_OnPlugStarted();
}

public void Chr_OnPlugStarted()
{
    Chr_RegModule(MNAME);
}

public void OnPluginEnd()
{
    Chr_UnregModule(MNAME);
}

public void Chr_OnBammm(int client, const char[] moduleName)
{
    if(!strcmp(moduleName, MNAME, true) && client && IsClientInGame(client))
        KickClient(client, "%t", "chr_kick_msg");
}