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
 

void
TSMultiplayerRules::TSMultiplayerRules(void)
{
	// Whoops!  CS stuff
	// Anything similar-looking for TS team-based gamemodes could go here then.
	/*
	forceinfokey(world, "teams", "2");
	forceinfokey(world, "team_1", "Specialists");
	forceinfokey(world, "teamscore_1", "0");
	forceinfokey(world, "team_2", "Mercenaries");
	forceinfokey(world, "teamscore_2", "0");
	*/
}

 
// respawn absolutely everything
// (check out init_respawn in case the var checked or any other part of the process changes)
void
TSMultiplayerRules::RespawnMain(void){
	
	// TAGGG TODO - anyway to tell all clients to remove all tempents like debris effects from
	// recently broken things?  Not a big deal if this can't be done
	
	/*
	// WAIT!  This has an issue, affects some things that shouldn't be, like CBaseTrigger's.
	// the Respawn method resets the CBaseEntity's target to m_oldstrTarget, which is fine for map-loaded triggers
	// but not temporary ones.  They have blank oldstr's and so are disabled.  Not quite sure why they're just
	// not deleted on-the-spot so CBaseTrigger can regenerate them or something like that.
	// Anyway, that is Nuclide (gs-entbase), but the point is to be careful about blindly respawning everything.
	// For now, re-directing to the plain "RespawnRoutine" for respawning all breakables.
	// If anything can potentially be out of alignment since round-start that should be returned that way,
	// go ahead and call respawn for that classname too
	for (entity a = world; (a = findfloat(a, ::identity, 1));) {
		CBaseEntity ent = (CBaseEntity)a;
		// Not a player, spectator, or viewmodel (if it's even possible to run into those this way)?  Go ahead
		if(
			!(ent.classname == "player" || ent.classname == "spectator" || ent.classname == "vm")
			
		){
			//printfline("I REMOVED THAT %s", ent.classname);
			ent.Respawn();
		}
	}
	*/
	
	// some entities used by ts_bikini at least,
				
	/*
	|| ent.classname == "cycler" || ent.classname == "trigger_multiple"
	|| ent.classname == "multi_manager_sub"
	|| ent.classname == "trigger_relay"
	|| ent.classname == "func_illusionary"
	|| ent.classname == "multi_manager"
	|| ent.classname == "cycler_sprite"
	|| ent.classname == "env_sprite"
	|| ent.classname == "ambient_generic"
	|| ent.classname == "func_wall"

	|| ent.classname == "light"
	|| ent.classname == "CBaseTrigger"

	|| ent.classname == "info_notnull"
	|| ent.classname == "func_conveyor"
	|| ent.classname == "func_breakable"

	//ent.classname == "CBaseTrigger"
	*/
	
	RespawnRoutine();
	
}//RespawnMain

// respawn only breakables every so often.
void
TSMultiplayerRules::RespawnRoutine(void){
	printfline("TSMultiplayerRules::TimerUpdate - I HAVE RESPAWNED THE BREAKABLES. time:%d : starttime:%d : nextrespawntime:%d", time, global_gameStartTime, global_nextBreakableRespawn);
	
	//for (entity a = world; (a = findfloat(a, ::gflags, GF_CANRESPAWN));) {
	for (entity a = world; (a = findfloat(a, ::identity, IDENTITY_CANRESPAWN));) {
		CBaseEntity caw = (CBaseEntity)a;
		if(caw.classname == "func_breakable"){
			caw.Respawn();
		}
	}
}



void
TSMultiplayerRules::InitPostEnts(void)
{
	/* let's check if we need to create buyzones */
	// TAGGG - TODO.	  NOPE.  We're TS,  create whatever zones/triggers for
	// working with team-game specific areas ('defuse the bomb', 'hack the computer', etc.)
	
	// CreateCTBuyzones(), CreateTBuyzones(), etc. was here
}


void
TSMultiplayerRules::FrameStart(void)
{
	if (cvar("mp_timelimit"))
	if (time >= (cvar("mp_timelimit") * 60)) {
		IntermissionStart();
	}

	IntermissionCycle();
	
	
	//TAGGG - NEW.
	// from GameInput, just check here too
	if (m_iIntermission) {
		
		IntermissionEnd();
		
		// for now, some mock-Nuclide-script.  Don't depend on inputs not being read because the only player is in spectator
		if (time >= m_flIntermissionTime + 5){
			localcmd("restart\n");
		}
		
		//return;
	}
	//////////////////////////////////////////////////
	
	
	//TAGGG - hook into that!
	TimerUpdate();
}



void
TSMultiplayerRules::PlayerPreFrame(base_player pp)
{
	TSGameRules::PlayerPreFrame(pp);
	
	player pl = (player) pp;
	
	//TAGGG - TODO.  uh-oh.  was that important..?   find equivalent behavior if needed?
	// the modern CS lacks it here too at least, that's a good sign we don't need to worry.
	//BaseGun_ShotMultiplierUpdate();

	if (pl.health <= 0)
		return;

	if (g_ts_gamestate == GAME_FREEZE) {
		pl.flags |= FL_FROZEN;
	} else {
		pl.flags &= ~FL_FROZEN;
	}
	
}

void
TSMultiplayerRules::PlayerPostFrame(base_player pp)
{
	// Anything else?
	TSGameRules::PlayerPostFrame(pp);
}


void
TSMultiplayerRules::PlayerDisconnect(base_player pp)
{
	//TAGGG - no parent method call?  Really?
	TSGameRules::PlayerDisconnect(pp);
	
	if (health > 0){
		PlayerDeath(pp);
	}
}


void
TSMultiplayerRules::PlayerDeath(base_player pp)
{
	TSGameRules::PlayerDeath(pp);
	
	
	player pl = (player)pp;
	
	if (g_dmg_iHitBody == BODY_HEAD) {
		
		//TAGGG - TODO.  It sounds like "headshot1.wav" would be more fitting for taking the finishing
		// shot in the head, and headshot2.wav at varying pitches for any otherwise.
		// Just an idea, unsure how the original game handled this though.
		//sound(pl, CHAN_VOICE, sprintf("player/headshot%d.wav", floor((random() * 3) + 1)), 1, ATTN_NORM);
		
		/*
		//...of course the first one has no number too.  yaaaaaaay.
		int randomChoice = randomInRange_i(1, 2);
		if(randomChoice == 1i){
			sound(pl, CHAN_VOICE, "player/headshot.wav", 1, ATTN_NORM);
		}else{
			sound(pl, CHAN_VOICE, sprintf("player/headshot%i.wav", randomChoice), 1, ATTN_NORM);
		}
		*/
		Sound_Play(pl, CHAN_VOICE, "player.die_headshot");
		
	} else {
		///sound(pl, CHAN_VOICE, sprintf("player/die%i.wav", randomInRange_i(1, 3)), 1, ATTN_NORM);
		Sound_Play(pl, CHAN_VOICE, "player.die");
	}
	
	
	
	/* obituary networking */
	WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
	WriteByte(MSG_MULTICAST, EV_OBITUARY);
	if (g_dmg_eAttacker.netname)
		WriteString(MSG_MULTICAST, g_dmg_eAttacker.netname);
	else
		WriteString(MSG_MULTICAST, g_dmg_eAttacker.classname);
	WriteString(MSG_MULTICAST, pl.netname);
	WriteByte(MSG_MULTICAST, g_dmg_iWeapon);
	WriteByte(MSG_MULTICAST, 0);
	msg_entity = world;
	multicast([0,0,0], MULTICAST_ALL);

	Plugin_PlayerObituary(g_dmg_eAttacker, g_dmg_eTarget, g_dmg_iWeapon, g_dmg_iHitBody, g_dmg_iDamage);

	/* death-counter */
	pl.deaths++;
	forceinfokey(pl, "*deaths", ftos(pl.deaths));

	/* update score-counter */
	if (pl.flags & FL_CLIENT || pl.flags & FL_MONSTER)
	if (g_dmg_eAttacker.flags & FL_CLIENT) {
		if (pl == g_dmg_eAttacker)
			g_dmg_eAttacker.frags--;
		else
			g_dmg_eAttacker.frags++;
	}

	/* in DM we only care about the frags */
	if (cvar("mp_fraglimit"))
	if (g_dmg_eAttacker.frags >= cvar("mp_fraglimit")) {
		IntermissionStart();
	}


	/* either gib, or make a corpse */
	if (pl.health < -50) {
		FX_GibHuman(pl.origin);
	} else {
		/* Let's handle corpses on the clientside */
		entity corpse = spawn();
		setorigin(corpse, pl.origin + [0,0,32]);
		setmodel(corpse, pl.model);
		setsize(corpse, VEC_HULL_MIN, VEC_HULL_MAX);
		corpse.movetype = MOVETYPE_TOSS;
		corpse.solid = SOLID_TRIGGER;
		corpse.modelindex = pl.modelindex;
		
		
		//TAGGG - Check. Is ANIM_DIESIMPLE supported in TS playermodels?
		corpse.frame = ANIM_DIESIMPLE;
		//TAGGG - TODO. Pick from below like so instead?
		// Some method in animation.qc to handle this sounds better.
		/*
		if (pl.flags & FL_CROUCHING) {
			corpse.frame = ANIM_CROUCH_DIE;
		} else {
			switch (g_dmg_iHitBody) {
				case BODY_HEAD:
					corpse.frame = ANIM_DIE_HEAD;
					break;
				case BODY_STOMACH:
					corpse.frame = ANIM_DIE_GUT;
					break;
				case BODY_LEGLEFT:
				case BODY_ARMLEFT:
					corpse.frame = ANIM_DIE_LEFT;
					break;
				case BODY_LEGRIGHT:
				case BODY_ARMRIGHT:
					corpse.frame = ANIM_DIE_RIGHT;
					break;
				default:
					corpse.frame = ANIM_DEATH1 + floor(random() * 3);
					break;
			}
		}
		*/
		
		corpse.angles = pl.angles;
		corpse.velocity = pl.velocity;
		corpse.colormap = pl.colormap;
		
		//TAGGG - Stops the issue of re-doing animations after going out of view / back again.
		corpse.pvsflags = PVSF_NOREMOVE;
		//corpse.pvsflags = PVSF_IGNOREPVS;   //we want to remove ourselves. guaranteed.
		
		//TAGGG also fade out like in TS.
		corpse.think = entity_beginCorpseFadeOut;
		corpse.nextthink = time + 6;
		
	}// excess negative health gib check
	
	
	printfline("setInventoryEquippedIndex Flag Z");
	TS_resetViewModel(pl);
	pl.setInventoryEquippedIndex(-1);
	
	pl.resetZoom();
	

	for(int i = pl.ary_myWeapons_softMax-1; i >= 0; i--){
		pl.dropWeapon(i, TRUE);
	}
	
	//and drop our ammo pools... if we have any.  (should)
	if(pl.anyAmmoPoolNonEmpty()){
		pl.dropAmmo();
	}
	
	
	forceinfokey(pl, "*dead", "1"); 
	forceinfokey(pl, "*team", ftos(pl.team));
	CountPlayers();
	
	
	//TAGGG - yes, restart the money at death so it shows up in the buy menu.
	// Bonuses for performance in some team-based game not considered yet, always the flat start
	// amount given.
	setPlayerMoneyDefault(pl);
	
	
	// Let the player know they died (uhh what).
	// This lets client game logic know so that spectator can be told to wait
	// for a fresh key press instead of letting holding down (like dying while
	// firing auto) issue a respawn order, the player might not want that.
	// Also, is MULTICAST_ONE or _R wanted here?
	WriteByte( MSG_MULTICAST, SVC_CGAMEPACKET );
	WriteByte( MSG_MULTICAST, EVENT_TS::PLAYER_DEATH );
	msg_entity = pl;
	multicast( [0,0,0], MULTICAST_ONE_R );
	
	
	// Player model disappears since the corpse entity took its place.
	// Redundant for gibbing but doesn't hurt
	MakePlayerInvisible(pl);
	
	PlayerMakeSpectatorDelayed(pl);
	
	DeathCheck(pl);
	
	
}



float
TSMultiplayerRules::ConsoleCommand(base_player pp, string cmd)
{
	tokenize(cmd);

	switch (argv(0)) {
	case "bot_add":
		Bot_AddQuick();
		break;
	default:
		return (0);
	}

	return (1);
}


void
TSMultiplayerRules::TimerBegin(float tleft, int mode)
{
	if (mode == GAME_FREEZE) {
		g_ts_gamestate = GAME_FREEZE;
	} else if (mode == GAME_ACTIVE) {
		g_ts_gamestate = GAME_ACTIVE;
	} else if (mode == GAME_END) {
		g_ts_gamestate = GAME_END;
	} else if (mode == GAME_COMMENCING) {
		g_ts_gamestate = GAME_COMMENCING;
	} else if (mode == GAME_OVER) {
		g_ts_gamestate = GAME_OVER;
	}
	
	g_ts_gametime = tleft;
}


void
TSMultiplayerRules::TimerUpdate(void)
{
	for (entity eFind = world; (eFind = find(eFind, ::classname, "player"));) {
		//printfline("TimerUpdate: found player");
		player thisRef = (player)eFind;
		thisRef.frameThink_fromServer();
	}
	
	/*
	// Wait. shouldn't that mean gamerules_singleplayer.qc is being used instead?
	if (cvar("sv_playerslots") == 1) {
		g_ts_gametime = -1;
		return;
	}
	*/
	
	if (g_ts_gamestate != GAME_INACTIVE) {
		if(time >= global_nextBreakableRespawn){
			// Every minute, respawn all breakables.
			// TAGGG - TODO CRITICAL.  Perhaps each breakable can respawn in 60 seconds since it's been broken
			// instead, and still along round-restarts?
			// No idea why original TS chose to respawn everything in minutely-increments regardless
			// of when it was broken.  As in if it's been 55 seconds into a game, break something, it comes
			// back in 5 seconds.   huh.
			RespawnRoutine();
			
			/*
			//...and set the next time.
			float relativeTime = global_nextBreakableRespawn - global_gameStartTime;
			int solidFits = ((int)relativeTime) / ((int)BREAKABLE_RESPAWN_INTERVAL);
			global_nextBreakableRespawn = global_gameStartTime + (solidFits * BREAKABLE_RESPAWN_INTERVAL) + BREAKABLE_RESPAWN_INTERVAL;  //the next 60 minutes...
			//printfline("TSMultiplayerRules::TimerUpdate - %i %.2f %.2f", solidFits, time, global_nextBreakableRespawn);
			*/
			global_nextBreakableRespawn = global_nextBreakableRespawn + BREAKABLE_RESPAWN_INTERVAL;
			
		}
	}
	
	//printfline("TSMultiplayerRules::TimerUpdate - gamemode:%d time:%i", currentGameMode, (int)g_ts_gametime);
	
	if(currentGameMode == TS_GameMode::DEATHMATCH){
		if (g_ts_gamestate == GAME_INACTIVE) {
			
			if(g_ts_player_all > 0){
				//good, we can change
				printfline("***TimerUpdate: SERVER GAME_INACTIVE. THE GAME IS NOW ACTIVE.");
				
				//TODO - any special start-game criteria here like the other place that calls GAME_FREEZE?
				
				RestartRound(TRUE);  //don't reset any active players (like the one that let 
				// the game start like this).
				//TimerBegin(autocvar_mp_roundtime * 60, GAME_ACTIVE);
				//TimerBegin(autocvar_mp_freezetime, GAME_FREEZE);
				TimerBegin(0, GAME_FREEZE);
				
			}
		}else if(g_ts_gamestate == GAME_ACTIVE){

			if(g_ts_player_all <= 0){
				//last player left? uh-oh.
				printfline("***TimerUpdate: SERVER GAME_ACTIVE. THE GAME IS NOW INACTIVE.");
				g_ts_gamestate = GAME_INACTIVE;
			}else{
				
				if (g_ts_gametime <= 0) {
					TimeOut();
					
					centerprintToAll("End of round, prepare for a new one...\n");
					
					TimerBegin(5, GAME_END); // Round is over, 5 seconds til a new round starts
				}
			}//END OF any player(s) here check
			
		}else if(g_ts_gamestate == GAME_END){
			if(g_ts_player_all <= 0){
				//last player left? uh-oh.
				printfline("***TimerUpdate: SERVER GAME_END. THE GAME IS NOW INACTIVE.");
				g_ts_gamestate = GAME_INACTIVE;
			}else{
				if (g_ts_gametime <= 0){
					printfline("***TimerUpdate: SERVER GAME_END.  Delay over, respawning...");
					RestartRound(FALSE);  //this may do it
					
					//TimerBegin(autocvar_mp_freezetime, GAME_FREEZE);
					TimerBegin(0, GAME_FREEZE);
				}
			}
		}else if(g_ts_gamestate == GAME_FREEZE){
			
			if(g_ts_player_all <= 0){
				//last player left? uh-oh.
				printfline("***TimerUpdate: SERVER GAME_FREEZE. THE GAME IS NOW INACTIVE.");
				g_ts_gamestate = GAME_INACTIVE;
			}else{
				if (g_ts_gametime <= 0) {
					TimerBegin(autocvar_mp_roundtime * 60, GAME_ACTIVE); // Unfreeze
					// Anything else to do here at round start?
					// Best leave that up to gamemode choice later.
				}
			}
		}
	}// gamemode check
	
	
	if (g_ts_gamestate != GAME_OVER) {
		if (cvar("mp_timelimit") > 0) {
		
			if (time >= (cvar("mp_timelimit") * 60)) {
				centerprintToAll("mp_timelimit expired, changing map...\n");
		
				TimerBegin(5, GAME_OVER);
				printfline("Did the gamemode become GAME_OVER? %d", (float)(g_ts_gamestate==GAME_OVER));
			}
		}
	}
	
	/*
	if(g_ts_gamestate == GAME_OVER){
		printfline("GAME_OVER: what is the timer? %.2f", g_ts_gametime);
	}
	*/
	
	// whoops!  Leaving intermissions to nuclide now.
	
	if (g_ts_gamestate == GAME_INACTIVE) {
		return;
	}
	
	if (g_ts_gametime > 0) {
		g_ts_gametime -= frametime;
		if(g_ts_gametime < 0){
			g_ts_gametime = 0;
		}
	}
	
	
}


/*
=================
RoundOver

This happens whenever an objective is complete or time is up
=================
*/
void
TSMultiplayerRules::RoundOver(int iTeamWon, int iMoneyReward, int fSilent)
{
	
	// nothing yet
}



/*
=================
RestartRound

Loop through all ents and handle them
=================
*/
void
TSMultiplayerRules::RestartRound(int iWipe)
{
	
	//TAGGG - is that right?
	BOOL startingGame = (iWipe == TRUE);
	
	if(!startingGame){
		// Spawn/Respawn everyone at their team position and give them $$$
		
		// TAGGG - CRITICAL.
		// If gamemodes where the starting cash isn't reset to a static amount at every spawn
		// are ever intended, this is bad!
		// Skipping a clean reset for all currently in spectator (classname="spectator") is bad!
		for (entity eFind = world; (eFind = find(eFind, ::classname, "player"));) {
			//self = eFind;
			player pl = (player)eFind;
			
			// only affect players ingame!
			if(pl.iState != PLAYER_STATE::SPAWNED){
				continue;
			}

			//printfline("PLAYER MONEY 1: %i", pl.money);

			// only respawn players that were ingame. Those that weren't may want to stay in spectator.
			if(pl.health > 0){
				//pl.reset(TRUE);
				
				// Something about this resets the player money..?  Is it changing to Spectator
				// right before Player that did it here?
				//PlayerMakeSpectator(pl);
				// just let PlayerMakePlayable work.
				pl.iState = PLAYER_STATE::NOCLIP;
				PlayerMakePlayable(pl);
			}
			
			// do the money set here and it works out fine, doesn't leave the player on
			// initial-round-respawn with 0 money.
			setPlayerMoneyDefault(pl);
			//printfline("PLAYER MONEY 3: %i", pl.money);
			
		}
		
		// anything to do with spectators.
		//TAGGG - CRITICAL!  As spectators, changing "pl.money" would not make sense.  Not a player now.
		/*
		for (entity eFind = world; (eFind = find(eFind, ::classname, "spectator"));) {
			
		}
		*/
		
	}//END OF !startingGame check
	
	
	// Clear the corpses/items
	for (entity eFind = world; (eFind = find(eFind, ::classname, "remove_me"));) {
		remove(eFind);
	}
	
	/*
	//unwise...
	for (entity eFind = world; (eFind = find(eFind, classname, "tempdecal"));) {
		remove(eFind);
	}
	*/
	//try this
	// !!!
	
	// TAGGG - update2020.  not yet!  See if we even need to, probably but just be safe.
	// that is re-implement the old decal.c, info_decal edits.
	//Decals_Reset();
	
	for (entity eFind = world; (eFind = find(eFind, ::classname, "decal"));) {
		remove(eFind);
	}
	for (entity eFind = world; (eFind = find(eFind, ::classname, "infodecal"));) {
		remove(eFind);
	}
	
	/*
	WriteByte( MSG_MULTICAST, SVC_CGAMEPACKET );
	WriteByte( MSG_MULTICAST, EVENT_TS::TEST );
	
	//msg_entity = world;
	//multicast( [0,0,0], MULTICAST_ONE );
	
	multicast([0,0,0], MULTICAST_ALL);
	*/
	
	
	/*
	// actually not necessary,  all map powerups get the same GF_CANRESPAWN flag anyway.
			for (entity eFind = world; (eFind = find(eFind, classname, "ts_powerup"));) {
				CBaseEntity caw = (CBaseEntity)eFind;
				caw.Respawn();
			}
	*/	
	
	
	// Respawn all the entities
	RespawnMain();
	
	// We'll respawn all breakables a minute from now, and so on
	global_gameStartTime = time;
	global_nextBreakableRespawn = time + BREAKABLE_RESPAWN_INTERVAL;
	
}



void
TSMultiplayerRules::DeathCheck(base_player pl)
{
	
	
}


// makes more sense for team-based gamemodes, not touched yet.
void
TSMultiplayerRules::CountPlayers(void)
{
	g_ts_player_alive_specialists = 0;
	g_ts_player_alive_mercenaries = 0;
	g_ts_player_alive_total = 0;
	g_ts_player_spectator = 0;
	g_ts_player_all = 0;
	

	for (entity eFind = world; (eFind = find(eFind, ::classname, "player"));) {
		if (eFind.health > 0) {
			// TODO - when the time comes for teams.
			/*
			if (eFind.team == TEAM_T) {
				g_cs_alive_t++;
			}...
			*/
			
			g_ts_player_alive_total++;
		}else{
			// go ahead and count as a spectator as far as we care.
			g_ts_player_spectator++;
		}
	}
	
	// These would be authentic spectators, or those that can't even open the buy menu.
	for (entity eFind = world; (eFind = find(eFind, ::classname, "spectator"));) {
		g_ts_player_spectator++;
	}
	
	
	g_ts_player_all = g_ts_player_alive_total + g_ts_player_spectator;
	
}




/*
=================
TimeOut

Whenever mp_roundtime was being counted down to 0
=================
*/
void
TSMultiplayerRules::TimeOut(void)
{
	RoundOver(FALSE, 0, FALSE);
}



/*
=================
PlayerFindSpawn

Recursive function that gets the next spawnpoint
=================
*/
// ...maybe not so recursive now, support for that "no 2 places in a row" behavior
// (at least that's what I think the complex stuff is below?)  can be done later if wanted.
// ANYWAY, the "t" will be -1 for spectator or no-team, either picks from the same points
// without a team-based mode being on.
// oh wait we're in some specific "Rules" class so that's a given.	eh.
// ALSO TODO: I don't think this accounts for any odd cases like other players being in the way
// of a picked spawn point.  Maybe do the box-testing nearby to see if a valid spawn point
// can be found, if not, re-try in 3 other randomly picked spawn locations and still if not
// (?), wait 10 seconds and try again.  That would be divinely weird though.
entity
TSMultiplayerRules::PlayerFindSpawn(float t)
{
	//TAGGG - question.
	// so... why would TS maps even have separate "start" and "deathmatch" spawns?
	// because forcing the player to spawn at either gives different results,
	// neither is missing. tested in ts_bikini
	// ...hm.  Actually free-for-all-only maps, only have "info_player_deathmatch" spawns.
	// Interesting..
	//info_player_start
	//info_player_deathmatch

	//TAGGG - TODO For team-based mode.
	// Looks like The Mercenaries use info_player_deathmatch.
	// The Specialists use info_player_start.
	
	entity eSpot;
	
	int randomSpawnChoice = randomInRange_i(0, ary_spawnStart_deathmatch_softMax-1);
	eSpot = ary_spawnStart_deathmatch[randomSpawnChoice];
	
	return eSpot;
	
}



//////////////////////////////////////////////////////////

/*
=================
PlayerRespawn

Called whenever a player survived a round and needs a basic respawn.
=================
*/
void
TSMultiplayerRules::PlayerRespawn(base_player pp, int fTeam)
{
	entity eSpawn;
	vector myOrigin;
	player pl = (player)pp;
	
	// should be no need, PlayerRespawn should only be called after MakePlayable calls for the player
	// spawnfunc, that includes setting the classname (even explicitly inside the player constructor)
	//pl.classname = "player";
	
	// fresh inventory for you
	//TAGGG - QUESTION: Why reset the player on death or going to spectator instead?
	TS_resetPlayer(pl, TRUE);
	
	// Also, FreeHL did these, but it looks like a simple way of 0'ing everything out.
	// No need with all that 'TS_resetPlayer' does now.
	//LevelNewParms();
	//LevelDecodeParms(pl);
	
	// And a Nuclide-call that may not make as much sense with 'UpdateAmmo' across the weapons
	// not being used.
	//Weapons_RefreshAmmo(pl);
	
	
	forceinfokey(pl, "*spec", "0");

	pl.health = pl.max_health = 100;
	pl.armor = 0;  // may as well enforce that too?
	forceinfokey(pl, "*dead", "0");
	CountPlayers();

	pl.takedamage = DAMAGE_YES;
	pl.solid = SOLID_SLIDEBOX;
	pl.movetype = MOVETYPE_WALK;
	pl.flags = FL_CLIENT;
	pl.iBleeds = TRUE;
	
	// other safe defaults?
	pl.gravity = NULL;
	pl.frame = 1;
	pl.velocity = [0,0,0];
	
	pl.SendFlags = UPDATE_ALL;
	// is that a good idea?
	pl.customphysics = Empty;
	pl.SetSize(VEC_HULL_MIN, VEC_HULL_MAX);
	
	// TAGGG - don't keep playing death sounds!
	// If we play it from the client instead (doubt it), we need to send a message
	// that tells clientside to do the stopping.  I think.
	stopSound(pl, CHAN_VOICE);
	
	
	eSpawn = PlayerFindSpawn(pl.team);
	
	
	// final coord to put the player.
	// to be adjusted by the "droptofloor" call further down.
	// Maybe even checks for existing entities (players?) being in the way of spawn,
	// although that probably should've been tested before picking a spawnpoint.
	// If so whatever picks a spawn point should probably come with a spawn point to
	// put the player anyway, including droptofloor.
	
	
	if(autocvar_debug_spawnpointforced == 1){
		
#ifdef TS_CUSTOM_SPAWN_ORIGIN
			myOrigin = TS_CUSTOM_SPAWN_ORIGIN;
#else
			printfline("WARNING!  debug_spawnpointforced set, but TS_CUSTOM_SPAWN_ORIGIN is not defined!");
			myOrigin = eSpawn.origin;
#endif
		
#ifdef TS_CUSTOM_SPAWN_VANGLE
			pl.angles = TS_CUSTOM_SPAWN_VANGLE;
#else
			printfline("WARNING!  debug_spawnpointforced set, but TS_CUSTOM_SPAWN_VANGLE is not defined!");
			pl.angles = eSpawn.angles;
#endif
	}else{
		
		myOrigin = eSpawn.origin;
		pl.angles = eSpawn.angles;
	}
	
	// Why do we have to do this now?  No clue.
	// something about animation.h maybe? I Forget.
	pl.v_angle = pl.angles;
	

	Client_FixAngle(pl, pl.angles);
	
	// Because, "droptofloor" needs to be dealing with the up-to-date origin.
	// wait no.  I don't think droptofloor is even applying to the player.
	// How do we make it apply to the player, despite not being the most
	// recently spawned entity?  Horray for hardcoded behavior.
	// My guess is setting 'self' before-hand, but I don't see what 'droptofloor'
	// could possibly do that a trace below couldn't anyway.
	//pl.SetOrigin(myOrigin);
	
	
	//if(!droptofloor()){
		vector vSource = myOrigin + [0,0,0];
		traceline ( vSource, vSource + ( '0 0 -1' * 160 ), TRUE, pl );
	
		if(trace_fraction < 1.0){
			//hit something? we're there.
			myOrigin[2] = trace_endpos[2] + 0.2 + -pl.mins.z;
		}
		pl.SetOrigin(myOrigin);
	//}
	
	// TEST
	//self.angles = [-270, 160, 0];
	//the 1st number actually sets v_angle.x to -89.9 degrees? (record in-game, "getangle" in console)?... oookay.
	//self.v_angle = [-270, 160, 0];
	
	//printfline("spawn stats? %.1f,%.1f,%.1f ?%d %s", eSpawn.angles.x, eSpawn.angles.y, eSpawn.angles.z, (eSpawn.target==NULL), eSpawn.target);
	
	
	////////////////////////////////////////////////////////////////////////////
	//TAGGG - CRITICAL, TODO.
	// Support model choice however original TS did, think by some preference.
	// Half-life's multiplayer model picker is probably a good inspiration for that.
	pl.model = "models/player/laurence/laurence.mdl";
	
	// FOR REFERENCE: How FreeHL does it.  Don't see use of the built-in method 'infokey' very often.
	// Looks like original TS would do something like this (let the 'model' CVar from the player determine
	// model to use), but TS does a check against HLDS models to forbid their use, makes sense as TS
	// demands a few new types of animations involving stunts, unsure if there are any other changes
	// beyond that.
	// ALSO - TS uses model choice to determine team membership, and teams are named after those models
	// in non-team-based modes, however much sense that makes.
	/*
	pl.model = "models/player.mdl";
	string mymodel = infokey(pl, "model");
	
	if (mymodel) {
		mymodel = sprintf("models/player/%s/%s.mdl", mymodel, mymodel);
		if (whichpack(mymodel)) {
			pl.model = mymodel;
		}
	}
	// wait why not use pl.SetModel?
	//setmodel(pl, pl.model);
	*/
	pl.SetModel(pl.model);
	////////////////////////////////////////////////////////////////////////////
	
	
	WriteByte( MSG_MULTICAST, SVC_CGAMEPACKET );
	WriteByte( MSG_MULTICAST, EVENT_TS::SPAWN );
	msg_entity = pl;
	multicast( [0,0,0], MULTICAST_ONE );
	
}





void TSMultiplayerRules::MakePlayerInvisible(player pl){
	pl.SetModelindex(0);
	pl.SetMovetype(MOVETYPE_NONE);
	pl.SetSolid(SOLID_NOT);
	pl.takedamage = DAMAGE_NO;
}




/*
=================
PlayerMakePlayable

Called whenever need a full-reinit of a player.
This may be after a player had died or when the game starts for the first time.
=================
*/

static void
MakePlayable(entity targ)
{
	entity oself = self;
	self = targ;

	// Bots for FreeTS?  Not touching that.
	//if (clienttype(targ) != CLIENTTYPE_REAL)
	//	spawnfunc_csbot();
	//else
		spawnfunc_player();

	self = oself;
}
static void
MakeSpectator(entity targ)
{
	entity oself = self;
	self = targ;
	spawnfunc_spectator();
	self = oself;
}
void
TSMultiplayerRules::PlayerMakePlayable(base_player pp)
{
	player pl = (player)pp;
	if(pl.iState == PLAYER_STATE::SPAWNED){
		// no need to do this again.
		// Set pl.iState to something else first if this was an intentional re-spawn
		// for an ingame player
		return;
	}
	
	pl.iState = PLAYER_STATE::SPAWNED;
	// Nope!
	//MakePlayable(pp);

	forceinfokey(pl, "*team", ftos(pl.team)); 
	PlayerRespawn(pl, pl.team);
}

/*
=================
PlayerMakeSpectator

Force the player to become an observer.
=================
*/
void
TSMultiplayerRules::PlayerMakeSpectator(base_player pp)
{
	player pl = (player)pp;
	
	if(pl.iState == PLAYER_STATE::NOCLIP){
		// Already in fake spectator!  Stop.
		return;
	}
	
	if(pl.modelindex != 0){
		// assume this is necessary
		MakePlayerInvisible(pl);
	}
	
	// is that necessary still?
	//TS_resetPlayer(pl, TRUE);
	// And don't do this!  Just change iState
	//MakeSpectator(pl);
	pl.iState = PLAYER_STATE::NOCLIP;
	
	// And do the rest of the lines to finish that
	// (copied from the Nuclide spectator's constructor)
	// Lines already handled by MakePlayerInvisible not here. 
	pl.flags = FL_CLIENT;
	pl.think = NULL;
	pl.nextthink = 0.0f;
	pl.maxspeed = 250;
	//pl.spec_ent = 0;
	//pl.spec_mode = 0;

	//#ifdef SERVER
		forceinfokey(pl, "*spec", "1");
	//#endif
	
	pl.armor = pl.activeweapon = pl.g_items = 0;
	pl.health = 0;
	pl.SetMovetype(MOVETYPE_NOCLIP);
}



// Similar to above, but mimicks the FreeCS way of setting the 
// "think" to a tiny method that calls spawnfunc_spectator.
void
TSMultiplayerRules::PlayerMakeSpectatorDelayed(base_player pp)
{
	// Nevermind, this has no significance anymore with the client entity change no longer
	// happening.  Redirect to the normal version
	player pl = (player)pp;
	PlayerMakeSpectator(pp);
	
	/*
	player pl = (player)pp;
	if(pl.classname != "spectator" && pl.modelindex != 0){
		// assume this is necessary
		MakePlayerInvisible(pl);
	}
	
	//TS_resetPlayer(pl, TRUE);
	static void GoSpec(void) {
		spawnfunc_spectator();
	}
	pl.think = GoSpec;
	pl.nextthink = time;
	// ?  Is this for the specator-spawn to sense that the classname
	// wasn't already "spectator" in case this happens twice in the
	// same frame?
	pl.classname = "player";
	// "dead" should already be set.
	//forceinfokey(pl, "*dead", "1"); 
	//forceinfokey(pl, "*team", ftos(pl.team));
	*/
}

/*
=================
PlayerSpawn

Called on the client first joining the server.
=================
*/
// NOTE - this is as said above, fist time connecting to a server.
// NOT spawning ingame with collision, weapon viewmodel, seen by other players, etc.
void
TSMultiplayerRules::PlayerSpawn(base_player pp)
{
	player pl = (player)pp;
	
	//printfline("PlayerSpawn, what is classname before anything has been done? %s %s", self.classname, pp.classname);
	
	// Apparently the player already arrives as a "player", a Nuclide-implemented event called
	// ClientConnect makes the client entity a "player" by using spawnfunc.
	// Having the "player" class available that early makes me wonder why "base_player" is used so
	// often in implemented methods, but not an issue.
	// ClientConnect is called before PutClientInServer (the one that leads to the gamerules
	// PlayerSpawn, right here), just for info.
	
	// What this means is, no need for spawnfunc_player here.
	
	
	// should "Frags" be an infokey to be better preserved through player/spectator changes?
	// No clue.  And setting these only that way further down by forceinfokey too.
	//pl.frags = 0;
	//pl.deaths = 0;
	//pl.team = TEAM_SPECTATOR;
	
	
	// immediately put us into spectating mode
	// (iState forced to a wrong value to stop MakeSpectator from being skipped)
	pl.iState = PLAYER_STATE::SPAWNED;
	PlayerMakeSpectator(pl);
	// Use our game's custom ObserverCam instead.
	Game_Spawn_ObserverCam(pl);

	// give the initial server-joining money
	//TAGGG - WARNING!  This sets 'pl.money', should that be some infokey stat instead
	// for player/spectator entity-change reasons?
	setPlayerMoneyDefault(pl);

	// I guess this state counts as "dead"?
	forceinfokey(pl, "*dead", "1");
	
	// we don't belong to any team
	forceinfokey(pl, "*team", "0"); 
	forceinfokey(pl, "*deaths", "0"); //ftos(pl.deaths));
	
	forceinfokey(pl, "done_connecting", "1");
}



void
TSMultiplayerRules::setPlayerMoneyDefault(player pl)
{
	pl.money = 0;
	Money_AddMoney(pl, autocvar_mp_startmoney);
}



// An order from the client (while in spectator) that they want to spawn.
void
CSEv_GamePlayerSpawn(void)
{
	TSMultiplayerRules rules = (TSMultiplayerRules)g_grMode;
	player pl = (player)self;
	
	if(pl.iState == PLAYER_STATE::SPAWNED){
		// what.
		return;
	}
	
	//self.dmg_take = 0;
	//self.dmg_inflictor = NULL; //good idea?

	// For now stop deathspammin'
	if (pl.health > 0) {
		return;
	}
	
	rules.PlayerMakeSpectator(pl);
	rules.PlayerMakePlayable(pl);
	
	// reset the money
	rules.setPlayerMoneyDefault(pl);
}

