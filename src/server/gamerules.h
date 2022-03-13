/*
 * Copyright (c) 2016-2020 Marco Cawthorne <marco@icculus.org>
 *
 * Permission to use, copy, modify, and distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF MIND, USE, DATA OR PROFITS, WHETHER
 * IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING
 * OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 */


// Blended from the old FreeTS Gamerules and FreeCS, some remnants of FreeHL may be
// floating around.  Most of the codebase is FreeHL inspired but this is an exception.


// TODO - move someplace better perhaps?
#define MAX_SPAWN_POINTS 32


extern TS_GameMode currentGameMode;

extern BOOL bRule_MoneyAllowed;
extern int iRule_MaxWeightSlots;

extern BOOL bRule_GameMod_TheOne;
extern BOOL bRule_GameMod_LastManStanding;

extern int iRule_teamCount;
extern string sRule_TeamNames[4];

// Not keeping track of when to start the game,
// for recalling when the game started after it has.
extern float global_gameStartTime;
extern float global_nextBreakableRespawn;

//not meant to be customizable... yet?
#define BREAKABLE_RESPAWN_INTERVAL 60



var entity ary_spawnStart_start[MAX_SPAWN_POINTS];
var int ary_spawnStart_start_softMax = 0;
var entity ary_spawnStart_deathmatch[MAX_SPAWN_POINTS];
var int ary_spawnStart_deathmatch_softMax = 0;




 
class player;


class TSGameRules:CGameRules
{
	virtual void(base_player) PlayerConnect;
	virtual void(base_player) PlayerDisconnect;
	virtual void(base_player) PlayerKill;
	virtual void(base_player) PlayerPreFrame;
	virtual void(base_player) PlayerPostFrame;
	virtual void(base_player) PlayerDeath;
	virtual void(base_player) PlayerPain;

	virtual void(base_player) LevelDecodeParms;
	virtual void(base_player) LevelChangeParms;
	virtual void(void) LevelNewParms;
};

class TSSingleplayerRules:TSGameRules
{
	/* client */
	virtual void(base_player) PlayerSpawn;
	virtual void(base_player) PlayerDeath;
};

class TSMultiplayerRules:TSGameRules
{
	int m_iIntermission;
	int m_iIntermissionTime;

	void() TSMultiplayerRules;
	
	virtual void(void) RespawnMain;
	virtual void(void) RespawnRoutine;
	
	virtual void(void) InitPostEnts;
	virtual void(void) FrameStart;

	/* client */
	virtual void(base_player) PlayerDisconnect;
	virtual void(base_player) PlayerSpawn;
	virtual void(base_player) PlayerPreFrame;
	virtual void(base_player) PlayerPostFrame;
	virtual void(base_player) PlayerDeath;
	virtual float(base_player, string) ConsoleCommand;
	
	virtual void(float, int) TimerBegin;
	virtual void(void) TimerUpdate;
	

	virtual void(int, int, int) RoundOver;
	virtual void(int) RestartRound;
	virtual void(base_player) DeathCheck;
	virtual void(void) CountPlayers;
	//virtual void(void) SwitchTeams;
	virtual void(void) TimeOut;


	virtual void(player pl) MakePlayerInvisible;
	virtual void(base_player) PlayerMakePlayable;
	virtual void(base_player pp) PlayerMakePlayableWithDefaultMoney;
	virtual void(base_player) PlayerMakeSpectator;
	virtual void(base_player) PlayerMakeSpectatorAndNotify;
	virtual void(base_player pp) PlayerMakeSpectatorDelayed;
	virtual void(base_player, int) PlayerRespawn;
	virtual entity(float) PlayerFindSpawn;
	
	virtual void(player pl) setPlayerMoneyDefault;


};




void Money_AddMoney(player ePlayer, int iMoneyValue);

