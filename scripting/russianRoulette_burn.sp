#include rusroulette
#include sourcemod
#include sdktools

static const char MNAME[] = "chr_burn";

bool IsDie[MAXPLAYERS+1];

public Plugin myinfo =
{
	name = "[RUSRoulette] Burn",
	author = "wAries",
	description = "Russian roulette for the game chat",
	version = MAIN_VER,
	url = "whyaries.ru"
}

public void OnPluginStart()
{
    if(Chr_IsPlugStarted())
        Chr_OnPlugStarted();
}

public void OnClientPutInServer(int iClient)
{
    IsDie[iClient] = false;
}

public void Chr_OnPlugStarted()
{
    Chr_RegModule(MNAME);
}

public void OnPluginEnd()
{
    if(Chr_IsPlugStarted())
        Chr_UnregModule(MNAME);
}

public void Chr_OnSpawn(int iClient)
{
    if(!IsDie[iClient] || !IsPlayerAlive(iClient))
        return;

    IgniteEntity(iClient, 60.0);
    IsDie[iClient] = false;
}

public void Chr_OnBammm(int client, const char[] moduleName)
{
    if(!strcmp(moduleName, MNAME, true) && client && IsClientInGame(client))
    {
        if(!IsPlayerAlive(client))
        {
            Chr_SendMsg(client, "%t", "chr_next");
            IsDie[client] = true;
            return;
        }

        IgniteEntity(client, 60.0);
    }
}