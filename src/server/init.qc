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
 
//TAGGG - file renamed from server.qc to init.qc.
// Has only init methods like client/init.qc, so naming after that.




/*
// DEMO!  So 'enumflags' does mean they count up in powers of 2,
// so starting at 1, then 2, 4, 8, 16, 32, etc.
// (starting at 1 since 2^0 is 1; each spot is 2^i)
// typedef + name after not required, but do-able.
// And floats because FTE.  Or Quake C, one of those.
typedef enumflags
{
	TEST_ENUM_1,
	TEST_ENUM_2,
	TEST_ENUM_3,
	TEST_ENUM_4,
	TEST_ENUM_5
	
} myFlags_t;
*/



void Game_Spawn_ObserverCam(player pl){
	
	//printfline("Game_Spawn_ObserverCam: ary_spawnStart_start_softMax: %i", ary_spawnStart_start_softMax);
	if(ary_spawnStart_start_softMax == 0){
		printfline("Game_Spawn_ObserverCam: no recorded spawn locations");
		
		//printfline("MY VALS! %d %d %d %d %d", TEST_ENUM_1, TEST_ENUM_2, TEST_ENUM_3, TEST_ENUM_4, TEST_ENUM_5);
		
		initSpawnMem();
	}

	// force randomSpawnChoice to a constant to spawn in the same place always if needed
	int randomSpawnChoice = randomInRange_i(0, ary_spawnStart_deathmatch_softMax-1);
	entity eCamera = ary_spawnStart_deathmatch[randomSpawnChoice];
	
	entity eTarget;

	if (eCamera) {
		pl.origin = eCamera.origin;
		
		if (eCamera.target) {
			eTarget = find(world, ::targetname, eCamera.target);
			if (eTarget) {
				pl.angles = vectoangles(eTarget.origin - eCamera.origin);
				pl.angles[0] *= -1;
			}
		}else{
			// no target?  What else do we have?
			//entity eTarget;
			//self.angles = eCamera.angles;
			pl.angles = eCamera.angles;
			// Why do we have to do this now?  No clue.
			// something about animation.h maybe? I Forget.
			pl.v_angle = pl.angles;
			Client_FixAngle(pl, pl.angles);
		}
		
	} else {
		// Can't find a camera? Just do this lazy thing, CS seems to do the same
		eCamera = find (world, ::classname, "info_player_start");
		
		if (eCamera) {
			pl.origin = eCamera.origin;
			
			if (eCamera.target) {
				eTarget = find(world, ::targetname, eCamera.target);
				if (eTarget) {
					pl.angles = vectoangles(eTarget.origin - eCamera.origin);
					pl.angles[0] *= -1;
				}
			}
		}
	}

	// TAGGG - NEW LINE.  do we need to do this? 
	setorigin(pl, pl.origin);
	Client_FixAngle(pl, pl.angles);
	
}//END OF Game_Spawn_ObserverCam



//TAGGG - NOTE.  Should this get a 0.1 delay like nuclide's src/server/entry.qc does here:
//	entity respawntimer = spawn();
//	respawntimer.think = init_respawn;
//	respawntimer.nextthink = time + 0.1f;
// Might not be necessary. Or compare better with old FreeTS, just in case the new way of calling
// (straight from Game_Worldspawn) doesn't work.
// This needs the other info_<whatever> entities to exist for keeping track of places to spawn,
// being incomplete at the time of this call is unacceptable.

void initSpawnMem(void){
	//printfline("initSpawnMem");
	// two spawn-related entities present in the map:
	// info_player_start
	// info_player_deathmatch
	
	ary_spawnStart_start_softMax = 0;
	ary_spawnStart_deathmatch_softMax = 0;
	
	
	for(entity eFind = world; (eFind = find(eFind, classname, "info_player_start"));){
		if(ary_spawnStart_start_softMax == MAX_SPAWN_POINTS){
			printfline("ERROR!! Map exceeds maximum of %d info_player_start points. Further ones ignored.", MAX_SPAWN_POINTS);
			break;
		}
		//printfline("info_player_start: found one: %s", eFind.classname);
		
		ary_spawnStart_start[ary_spawnStart_start_softMax] = eFind;
		ary_spawnStart_start_softMax++;
	}
	
	
	for(entity eFind = world; (eFind = find(eFind, classname, "info_player_deathmatch"));){
		if(ary_spawnStart_deathmatch_softMax == MAX_SPAWN_POINTS){
			printfline("ERROR!! Map exceeds maximum of %d info_player_deathmatch points. Further ones ignored.", MAX_SPAWN_POINTS);
			break;
		}
		
		//printfline("info_player_deathmatch: found %s", eFind.classname);
		
		ary_spawnStart_deathmatch[ary_spawnStart_deathmatch_softMax] = eFind;
		ary_spawnStart_deathmatch_softMax++;
	}
	
	printfline("initSpawnMem: how many spawns, info_p_start:%i info_p_deathmatch:%i", ary_spawnStart_start_softMax, ary_spawnStart_deathmatch_softMax);
}







void
Game_InitRules(void)
{
	if (cvar("sv_playerslots") == 1 || cvar("coop") == 1) {
		g_grMode = spawn(TSSingleplayerRules);
	} else {
		g_grMode = spawn(TSMultiplayerRules);
	}
	
}



// Effectvely, ServerGame_Init
void
Game_Worldspawn(void)
{
	printfline("***ServerGame_Init (Game_Worldspawn) called***");
	//TAGGG - NEW
	SharedGame_Init();
	ServerGame_Precache();
	
	// calls each weapon's .precache method.
	Weapons_Init();
	Player_Precache();
	
	
	//TAGGG - new stuff
	
	string sTemp;
	int iMOTDLines = 0;


	printfline("Game_Worldspawn");


	// The message of the day.
	// This saves the contents of the MoTD text file (path given by CVar motdfile) to a series of
	// serverinfo entries named motdline0, 1, 2, ...  for reading back in client/ui.qc from the server
	// at client-connect time (UI_Init) to go in the MoTD window whenever needed.
	localcmd(sprintf("echo [MOTD] Loading %s.\n", autocvar_motdfile));
	filestream fmMOTD = fopen(autocvar_motdfile, FILE_READ);
	if (fmMOTD >= 0) {
		for (int i = 0; i < 25; i++) {
			sTemp = fgets(fmMOTD);

			if not (sTemp) {
				break;
			} 
			
			if (sTemp == NULL) {
				localcmd(sprintf("serverinfo motdline%i /\n", iMOTDLines));
			} else {
				localcmd(sprintf("serverinfo motdline%i %s\n", iMOTDLines, sTemp));
			}
			iMOTDLines++;
		}
		localcmd(sprintf("serverinfo motdlength %i\n", iMOTDLines));
		fclose(fmMOTD);
	} else {
		error("[MOTD] Loading failed.\n");	
	}



//TAGGG - REMOVED!  Nuclide now handles mapcycle
/*
	// The mapcycle information.
	localcmd(sprintf("echo [MAPCYCLE] Loading %s.\n", autocvar_mapcyclefile));
	filestream fmMapcycle = fopen(autocvar_mapcyclefile, FILE_READ);
	
	if (fmMapcycle >= 0) {
		for (int i = 0;; i++) {
			sTemp = fgets(fmMapcycle);
			if not (sTemp) {
				break;
			} 
			
			if (sTemp != NULL) {
				iMapCycleCount++;
			}
		}
		
		fseek(fmMapcycle, 0);
		localcmd(sprintf("echo [MAPCYCLE] List has %i maps.\n", iMapCycleCount));
		sMapCycle = memalloc(sizeof(string) * iMapCycleCount);
		for (int i = 0; i < iMapCycleCount; i++) {
			sMapCycle[i] = fgets(fmMapcycle);
		}
		fclose(fmMapcycle);
		
		for (int i = 0; i < iMapCycleCount; i++) {
			if (sMapCycle[i] == mapname) {
				if ((i + 1) < iMapCycleCount) {
					localcmd(sprintf("echo [MAPCYCLE] Next map: %s\n", sMapCycle[i + 1]));
				} else {
					break;
				}
			}
		}
	} else {
		iMapCycleCount = 0;
		error("[MAPCYCLE] Loading failed.\n");	
	}
*/
	
	/*Bot_Init();*/
	
	
	//How many weight slots does this player have?
	//...oh wait, we already receive whatever the actual playerSlots is, even if the inventorylogic
	// clientside never had to refer to it.
	// That is, pl.iTotalSlots is set by serverside when we spawn with a config (filled by whatever
	// weapons are applied).
	// Then, serverside pl.iTotalSlots gets written to clientside pl.iTotalSlots too each frame.
	//pointerstat(STAT_WEIGHTSLOTS, EV_FLOAT, iTotalSlots);
	
	
	// NEW.
	pointerstat(STAT_RULE_MONEYALLOWED, EV_INTEGER, &bRule_MoneyAllowed);
	pointerstat(STAT_RULE_MAXWEIGHTSLOTS, EV_INTEGER, &iRule_MaxWeightSlots);

	//iBombRadius = 1024;
	localcmd(sprintf("serverinfo slots %d\n", cvar("sv_playerslots")));
	localcmd("teamplay 1\n");
	
	// Shouldn't these get explicit defaults?
	g_ts_gamestate = GAME_INACTIVE;
	g_ts_gametime = 0;
	
	
	// Go ahead, setup some info about all possible locations for players to spawn.
	// All entities have loaded at this point, right?  Sure they have for this to be Game_Worldspawn,
	// see what calls that if uncertain from nuclide.
	initSpawnMem();
	
	
	clientstat(STAT_MONEY, EV_INTEGER, player::money);
	pointerstat(STAT_GAMETIME, EV_FLOAT, &g_ts_gametime);
	pointerstat(STAT_GAMESTATE, EV_INTEGER, &g_ts_gamestate);
	
	
}
