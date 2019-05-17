#include sourcemod
#include rusroulette

#define FORITER(%0,%1,%2) for(int %0 = %1; %0 < %2; %0++)

ArrayList g_aModules;
bool IsStarted;
bool IsAlreadeStart[MAXPLAYERS+1];
EngineVersion eGame;

#define NumRandom 0
#define NumModule 1
#define NumIndex 2

stock char g_cColorsTag[][] = {"{WHITE}", "{RED}", "{LIME}", "{LIGHTGREEN}", "{LIGHTRED}", "{GRAY}", "{LIGHTOLIVE}", "{OLIVE}", "{LIGHTBLUE}", "{BLUE}", "{PURPLE}"}, 
            g_cColorsCSGO[][] = {"\x01", "\x02", "\x05", "\x06", "\x07", "\x08", "\x09", "\x10", "\x0B", "\x0C", "\x0E"};
stock int g_iColorsCSSOB[] = {0xFFFFFF, 0xFF0000, 0x00FF00, 0x99FF99, 0xFF4040, 0xCCCCCC, 0xFFBD6B, 0xFA8B00, 0x99CCFF, 0x3D46FF, 0xFA00FA};

public Plugin myinfo =
{
	name = "RUSRoulette",
	author = "wAries",
	description = "Russian roulette for the game chat",
	version = MAIN_VER,
	url = "whyaries.ru"
};

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
    eGame = GetEngineVersion();

    RegAPI();
    RegPluginLibrary("rusroulette");
    return APLRes_Success;
}

void RegAPI()
{
    CreateNative("Chr_RegModule", Native_RegModule);
    CreateNative("Chr_UnregModule", Native_UnRegModule);
    CreateNative("Chr_IsPlugStarted", Native_IsStarted);
    CreateNative("Chr_SendMsg", Native_SendMsg);
}

public void OnPluginStart()
{
    LoadTranslations("rusroulette.phrases");
    HookEvent("player_spawn", Event_SDpawn);
    HookEvent("player_death", Event_SDpawn);

    RegConsoleCmd("sm_roulette", Cmd_chroullete);
    
    g_aModules = new ArrayList(32, 0);

    IsStarted = true;
    OnStarted();
}

public void OnClientPutInServer(int iClient)
{
    IsAlreadeStart[iClient] = false;
}

public void Event_SDpawn(Event ev, const char[] name, bool IsSilent)
{
    int iClient = GetClientOfUserId(ev.GetInt("userid"));
    if(IsFakeClient(iClient))   return;

    if(name[7] != 'd')  Chr_OnSpawn(iClient);
    else Chr_OnDie(iClient, GetClientOfUserId(ev.GetInt("attacker")));
}

Action Cmd_chroullete(int iClient, int iArgs)
{
    if(!iClient || !IsClientInGame(iClient) || IsAlreadeStart[iClient] || GetClientTeam(iClient) < 2)
        return Plugin_Handled;

    IsAlreadeStart[iClient] = true;

    ArrayList arr = new ArrayList(8,0);
    arr.Push(GetRandomInt(1,6));
    arr.Push(GetRandomInt(0, g_aModules.Length-1));
    arr.Push(GetClientUserId(iClient));

    char sBuffer[32];
    g_aModules.GetString(arr.Get(NumModule), sBuffer, sizeof(sBuffer));
    SendColorMsg(iClient, " %t", sBuffer, arr.Get(NumRandom));   

    CreateTimer(1.0, TimerRoullete, arr, TIMER_REPEAT);
    return Plugin_Handled;
}

Action TimerRoullete(Handle hTimer, any data)
{
    static int iIter[MAXPLAYERS+1];
    static ArrayList arr;
    arr = data;

    int iClient = GetClientOfUserId(arr.Get(NumIndex));

    if(!iClient || !IsClientInGame(iClient))
    {
        iIter[iClient] = 0;
        KillTimer(hTimer);
        return Plugin_Handled;
    }

    static int iRandom[MAXPLAYERS+1];

    if(iIter[iClient] < 6)
    {
        char sIter[4];
        IntToString(iIter[iClient], sIter, sizeof(sIter));
        iRandom[iClient] = GetRandomInt(1,6);

        SendColorMsg(data, " %t", sIter, iRandom[iClient]);
        iIter[iClient]++;
        return Plugin_Continue;
    }

    iIter[data] = 0;
    arr.Set(NumIndex, iRandom[iClient]);
    iRandom[iClient] = 0;

    PostRoulette(iClient, arr);

    KillTimer(hTimer);
    return Plugin_Handled;
}

void PostRoulette(int iClient, ArrayList adt)
{
    IsAlreadeStart[iClient] = false;

    if(adt.Get(NumIndex) != adt.Get(NumRandom))
    {
        SendColorMsg(iClient, " %t", "chr_win");
        return;
    }

    SendColorMsg(iClient, " %t", "chr_lose");

    char sBuffer[32];
    g_aModules.GetString(adt.Get(NumModule), sBuffer, sizeof(sBuffer));

    OnWin__(iClient, sBuffer);
}

void SendColorMsg(int iClient, const char[] sMsg, any ...)
{
	char szBuffer[256];

    SetGlobalTransTarget(iClient);
	VFormat(szBuffer, sizeof(szBuffer), sMsg, 3);

	if(eGame == Engine_CSGO)
	{
		FORITER(i, 1, 11)
            ReplaceString(szBuffer, sizeof(szBuffer), g_cColorsTag[i], g_cColorsCSGO[i], false);
	}
	else if(eGame == Engine_CSS)
	{
		char sBuffer[32];
		FORITER(i, 0, 11)
		{
			FormatEx(sBuffer, sizeof(sBuffer), "\x07%06X", g_iColorsCSSOB[i]);
			ReplaceString(szBuffer, sizeof(szBuffer), g_cColorsTag[i], sBuffer, false);
		}
	}
	
	ReplaceString(szBuffer, sizeof(szBuffer), "{DEFAULT}", g_cColorsCSGO[0], false);
	ReplaceString(szBuffer, sizeof(szBuffer), "{TEAM}", "\x03", false);
	ReplaceString(szBuffer, sizeof(szBuffer), "{GREEN}", "\x04", false);

	PrintToChat(iClient, szBuffer);
}

/*
        API Section
*/

void OnStarted()
{
    Handle hStart = CreateGlobalForward("Chr_OnPlugStarted", ET_Ignore);
    Call_StartForward(hStart);
    Call_Finish();
}

void OnWin__(int iClient, const char[] sModule)
{
    static Handle hForward;
    if(hForward == null)
        hForward = CreateGlobalForward("Chr_OnBammm", ET_Ignore, Param_Cell, Param_String);
    
    Call_StartForward(hForward);
    Call_PushCell(iClient);
    Call_PushString(sModule);
    Call_Finish();
}

void Chr_OnSpawn(int iClient)
{
    static Handle hForward;
    if(hForward == null)
        hForward = CreateGlobalForward("Chr_OnSpawn", ET_Ignore, Param_Cell);
    
    Call_StartForward(hForward);
    Call_PushCell(iClient);
    Call_Finish();
}

void Chr_OnDie(int iClient, int iAttacker)
{
    static Handle hForward;
    if(hForward == null)
        hForward = CreateGlobalForward("Chr_OnDie", ET_Ignore, Param_Cell, Param_Cell);
    
    Call_StartForward(hForward);
    Call_PushCell(iClient);
    Call_PushCell(iAttacker);
    Call_Finish();
}

public int Native_IsStarted(Handle hPlug, int iParams)
{
    return IsStarted;
}

public int Native_RegModule(Handle hPlug, int iParams)
{
    char sBuffer[32];
    GetNativeString(1, sBuffer, sizeof(sBuffer));
    //PrintToServer(sBuffer);

    if(g_aModules.FindString(sBuffer) != -1)
        return 0;
    
    g_aModules.PushString(sBuffer);

    return 1;
}

public int Native_UnRegModule(Handle hPlug, int iParams)
{
    char sBuffer[32];
    GetNativeString(1, sBuffer, sizeof(sBuffer));

    int iPos;

    if((iPos = g_aModules.FindString(sBuffer)) == -1)
        return 0;
    
    g_aModules.Erase(iPos);

    return 1;
}

public int Native_SendMsg(Handle hPlug, int iParams)
{
    int iClient = GetNativeCell(1);
    
    char cMsg[256];

    FormatNativeString(0, 2, 3, sizeof(cMsg), _, cMsg);

    SendColorMsg(iClient, cMsg);
}