#include rusroulette
#include sourcemod
#include sdktools_functions

static const char MNAME[] = "chr_jail";

bool IsDie[MAXPLAYERS+1];

public Plugin myinfo =
{
	name = "[RUSRoulette] Jail",
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

    DoJail(iClient);
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

        DoJail(client);
    }
}

void DoJail(int client)
{
    SetEntityMoveType(client, MOVETYPE_NONE);

    float vec[3] = {1.0, 1.0, 1.0};
    TeleportEntity(client, vec, NULL_VECTOR, NULL_VECTOR);

    CreateTimer(0.2, DoDmg, GetClientUserId(client), TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
}

Action DoDmg(Handle hTimer, any data)
{
    data = GetClientOfUserId(data);
    if(!data || !IsPlayerAlive(data))
    {
        KillTimer(hTimer);
        return Plugin_Handled;
    }
    
    SlapPlayer(data, 10, true);
    return Plugin_Continue;
}