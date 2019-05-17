#include rusroulette
#include sourcemod
#include sdktools
#include sdkhooks

static const char MNAME[] = "chr_mazochist";

bool IsDie[MAXPLAYERS+1];
bool IsMazo[MAXPLAYERS+1];

public Plugin myinfo =
{
	name = "[RUSRoulette] Mazochist",
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
    SDKHook(iClient, SDKHook_OnTakeDamage, OnTakeDamage);

    IsDie[iClient] = false;
    IsMazo[iClient] = false;
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
    if(!IsDie[iClient] && IsMazo[iClient])
    {
        IsMazo[iClient] = false;
        return;
    }

    else if(!IsDie[iClient] || !IsPlayerAlive(iClient))
        return;

    IsMazo[iClient] = true;
    IsDie[iClient] = !IsMazo[iClient];
}

public void Chr_OnDie(int iClient, int iAttacker)
{
    if(!IsMazo[iClient])
        return;

    IsMazo[iClient] = false;
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

        IsMazo[client] = true;
    }
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
    if(!attacker || attacker > MaxClients || !IsClientInGame(attacker) || !IsMazo[attacker]) return Plugin_Continue;

    SlapPlayer(attacker, RoundFloat(damage - damage*0.1));
    damage = 0.0;

    return Plugin_Changed;
}

