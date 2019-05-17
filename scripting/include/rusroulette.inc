#if defined _rusroulette_included
 #endinput
#endif
#define _rusroulette_included

#define MAIN_VER "1.1a"

native bool Chr_RegModule(const char[] moduleName);
native bool Chr_UnregModule(const char[] moduleName);
native bool Chr_IsPlugStarted();
native void Chr_SendMsg(int iClient, const char[] Msg, any ...);

forward void Chr_OnPlugStarted();

#pragma deprecated
forward void Chr_OnReceivePhrase(const char[] moduleName, char[] desc, int iLen);

forward void Chr_OnBammm(int client, const char[] moduleName);
forward void Chr_OnSpawn(int client);
forward void Chr_OnDie(int client, int attacker);

public SharedPlugin __pl_rusroulette = 
{
	name = "rusroulette",
	file = "russianRoulette.smx",
#if defined REQUIRE_PLUGIN
	required = 1,
#else
	required = 0,
#endif
};

#if !defined REQUIRE_PLUGIN
public void __pl_rusroulette_SetNTVOptional()
{
	MarkNativeAsOptional("Chr_RegModule");
	MarkNativeAsOptional("Chr_UnregModule");
	MarkNativeAsOptional("Chr_IsRulletStarted");
	MarkNativeAsOptional("Chr_SendMsg");
}
#endif
