/*
 * Copyright (c) 2016-2020 Marco Hladik <marco@icculus.org>
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

#include "gamerules.h"
#include "items.h"
#include "player.h"



//TAGGG - TODO: some were intended for FreeCS like a c4 timer one, but some
// can probably be used by FreeTS anyway

// Server cvars
var int autocvar_mp_winlimit = 0;
var int autocvar_mp_halftime = 0;
var int autocvar_mp_startmoney = 30000;  //was 800
//var float autocvar_mp_buytime = 90;
var float autocvar_mp_freezetime = 6;
var float autocvar_mp_roundtime = 5;
var float autocvar_mp_timelimit = 60;
var string autocvar_motdfile = "motd.txt";
var int autocvar_mp_friendlyfire = FALSE;

//TAGGG - are we even using all these?
var int autocvar_fcs_swapteams = FALSE; /* Swaps spawnpoints */
var int autocvar_fcs_maxmoney = 99999;  //TAGG - was 16000.

//TAGGG - not used, don't know if the TS really supported denying weapon drop-ables.
// Doesn't mean that can't be implemented anyway (check this CVar, and if on while about
// to spawn a drop-able, deny the request and don't drop at all on player death)
//var int autocvar_fcs_nopickups = FALSE; /* Disable weapon items */


// Game specific fields

var int g_ts_gamestate;
var float g_ts_gametime;

// no, just have counts of players in general.  Team-based stuff will check for that later.
//var int g_cs_alive_t;
//var int g_cs_alive_ct;
var int g_ts_player_alive_specialists;
var int g_ts_player_alive_mercenaries;
var int g_ts_player_alive_total;
var int g_ts_player_spectator;   //do we even need this one?
var int g_ts_player_all;



// Very situational, not all debug printouts, nowhere near.
var float autocvar_sv_printoutspam = 0;




void initSpawnMem(void);

//TAGGG - restored?
void Game_Spawn_ObserverCam(player pl);


// Do these all still exist and need to be prototyped here??
/*
void Game_SpectatorThink(void);
void Game_SpectatorConnect(void);
void Game_SpectatorDisconnect(void);
void Game_RunClientCommand(void);
void Game_ParseClientCommand(string cmd);
void Game_InitRules(void);
void Game_Worldspawn(void);
*/


