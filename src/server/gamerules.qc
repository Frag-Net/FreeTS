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
 
 
 
 
 
 
 
 
// TODO!  Should all these be instance vars of the gamerules object instead of 
// things floating around like this?


//default if unspecified.
//TODO - hook a bunch of this stuff up to console.

//Including a "changeteam" command if we implement teams.
var TS_GameMode currentGameMode = TS_GameMode::DEATHMATCH;


//TAGGG - INCLUSION - YOU BETTER NOT FORGET ABOUT THESE VARS.

//TAGGG TODO - there isn't one var / CVar to tell what gamemode this is? uhhh ok.
//until something deeper is made like a gamemode struct or CVar, this will have to do.

//defaults.  The "81" max weight slots rule is from The Specialists as-is.
var BOOL bRule_MoneyAllowed = TRUE;
var int iRule_MaxWeightSlots = 81;

var BOOL bRule_GameMod_TheOne = FALSE;
var BOOL bRule_GameMod_LastManStanding = FALSE;

// Fill these from reading the player's team list.  See notes in shared/rules.h about the
// "team list" string in Create Server options (original game)
var int iRule_teamCount = 0;
var string sRule_TeamNames[4];

var float global_gameStartTime = 0;
var float global_nextBreakableRespawn = 0;


void
TSGameRules::PlayerDeath(base_player pp)
{
}

void
TSGameRules::PlayerPain(base_player pp)
{
	//TAGGG - why was this using "self" instead of the "pp"?  haha.. the pp.
	// Also this is completely new to FreeCS and probably FreeHL.  ?
	sound(pp, CHAN_VOICE, sprintf("player/pain%i.wav", randomInRange_i(1, 3)), 1, ATTN_IDLE);
}



//TAGGG - CRITICAL.  Do any new player vars need to be copied too,
// same for LevelChangeParams further down?
void
TSGameRules::LevelDecodeParms(base_player pp)
{
	player pl = (player)pp;
	g_landmarkpos[0] = parm1;
	g_landmarkpos[1] = parm2;
	g_landmarkpos[2] = parm3;
	pl.angles[0] = parm4;
	pl.angles[1] = parm5;
	pl.angles[2] = parm6;
	pl.velocity[0] = parm7;
	pl.velocity[1] = parm8;
	pl.velocity[2] = parm9;
	pl.g_items = parm10;
	pl.activeweapon = parm11;
	pl.flags = parm64;

	//TAGGG - why was this one missing from FreeHL?  Present in FreeCS.
	pl.gflags = parm63;
	
/*
	pl.ammo_9mm = parm12;
	pl.ammo_357 = parm13;
	pl.ammo_buckshot = parm14;
	pl.ammo_m203_grenade = parm15;
	pl.ammo_bolt = parm16;
	pl.ammo_rocket = parm17;
	pl.ammo_uranium = parm18;
	pl.ammo_handgrenade = parm19;
	pl.ammo_satchel = parm20;
	pl.ammo_tripmine = parm21;
	pl.ammo_snark = parm22;
	pl.ammo_hornet = parm23;

	pl.glock_mag = parm24;
	pl.mp5_mag = parm25;
	pl.python_mag = parm26;
	pl.shotgun_mag = parm27;
	pl.crossbow_mag = parm28;
	pl.rpg_mag = parm29;
	pl.satchel_chg = parm30;
	*/


	if (pl.flags & FL_CROUCHING) {
		setsize(pl, VEC_CHULL_MIN, VEC_CHULL_MAX);
	} else {
		setsize(pl, VEC_HULL_MIN, VEC_HULL_MAX);
	}
}

void
TSGameRules::LevelChangeParms(base_player pp)
{
	player pl = (player)pp;
	parm1 = g_landmarkpos[0];
	parm2 = g_landmarkpos[1];
	parm3 = g_landmarkpos[2];
	parm4 = pl.angles[0];
	parm5 = pl.angles[1];
	parm6 = pl.angles[2];
	parm7 = pl.velocity[0];
	parm8 = pl.velocity[1];
	parm9 = pl.velocity[2];
	
	//TAGGG - why was this one missing from FreeHL?  Present in FreeCS.
	parm63 = pl.gflags;
	
	parm64 = pl.flags;
	parm10 = pl.g_items;
	parm11 = pl.activeweapon;
	
	/*
	parm12 = pl.ammo_9mm;
	parm13 = pl.ammo_357;
	parm14 = pl.ammo_buckshot;
	parm15 = pl.ammo_m203_grenade;
	parm16 = pl.ammo_bolt;
	parm17 = pl.ammo_rocket;
	parm18 = pl.ammo_uranium;
	parm19 = pl.ammo_handgrenade;
	parm20 = pl.ammo_satchel;
	parm21 = pl.ammo_tripmine;
	parm22 = pl.ammo_snark;
	parm23 = pl.ammo_hornet;
	parm24 = pl.glock_mag;
	parm25 = pl.mp5_mag;
	parm26 = pl.python_mag;
	parm27 = pl.shotgun_mag;
	parm28 = pl.crossbow_mag;
	parm29 = pl.rpg_mag;
	parm30 = pl.satchel_chg;
	*/
	
}

void
TSGameRules::LevelNewParms(void)
{
	//TAGGG - parm63 added, absent in FreeHL.
	parm1 = parm2 = parm3 = parm4 = parm5 = parm6 = parm7 =
	parm8 = parm9 = parm10 = parm11 = parm12 = parm13 = parm14 =
	parm15 = parm16 = parm17 = parm18 = parm19 = parm20 = parm21 =
	parm22 = parm23 = parm24 = parm25 = parm26 = parm27 = parm28 =
	parm29 = parm30 = parm63 = 0;
	parm64 = FL_CLIENT;
}






//TAGGG - NEW.  Need PlayerPreFrame as well.
void
TSGameRules::PlayerPreFrame(base_player pp)
{
	//TAGGG - NEW
	// Is this null check redundant?
	if(pp != NULL){
		player pl = (player)pp;
		pl.preThink();
	}
	
}

/* we check what fields have changed over the course of the frame and network
 * only the ones that have actually changed */
void
TSGameRules::PlayerPostFrame(base_player pp)
{
	//TAGGG - NEW
	// Is this null check redundant?
	if(pp != NULL){
		player pl = (player)pp;
		pl.postThink();
	}
	
}

void
TSGameRules::PlayerConnect(base_player pl)
{
	if (Plugin_PlayerConnect(pl) == FALSE)
		bprint(PRINT_HIGH, sprintf("%s connected\n", pl.netname));
}

void
TSGameRules::PlayerDisconnect(base_player pl)
{
	if (Plugin_PlayerDisconnect(pl) == FALSE)
		bprint(PRINT_HIGH, sprintf("%s disconnected\n", pl.netname));

	/* Make this unusable */
	pl.solid = SOLID_NOT;
	pl.movetype = MOVETYPE_NONE;
	pl.modelindex = 0;
	pl.health = 0;
	pl.takedamage = 0;
	
	//TAGGG
	// FreeHL way.
	pl.SendFlags = -1;
	// why does FreeCS do this instead? Check for mentions of PLAYER_MODELINDEX
	// in FreeCS that aren't in FreeHL maybe.
	//pl.SendFlags = PLAYER_MODELINDEX;
	
}

void
TSGameRules::PlayerKill(base_player pl)
{
	//because we are TS.
	//Damage_Apply(pl, pl, pl.health, WEAPON_NONE, DMG_SKIP_ARMOR);
	Damage_Apply(pl, pl, pl.health, WEAPON_ID::NONE, DMG_SKIP_ARMOR);
} 





void
Money_AddMoney(player pl, int iMoneyValue)
{
	//dprint(sprintf("^2Money_AddMoney^7: giving %s $%i\n", pl.netname, iMoneyValue));
	pl.money += iMoneyValue;

	if (pl.money > autocvar_fcs_maxmoney) {
		pl.money = autocvar_fcs_maxmoney;
	}

	if (pl.money < 0) {
		pl.money = 0;
	}
}



