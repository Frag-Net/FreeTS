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
 
//TAGGG - Although TS is not very singleplayer-friendly, could this still use
// some things like the corpse fade think call instead?  Being a copy of FreeHL is just sloppy.
// Heck just have stuff not dependent on being single/multiplayer moved to TSGameRules::PlayerDeath
// instead, 99% of the stuff does not care about being multiplayer.

void
TSSingleplayerRules::PlayerDeath(base_player pp)
{
	TSGameRules::PlayerDeath(pp);
	
	player pl = (player)pp;
	
	pp.movetype = MOVETYPE_NONE;
	pp.solid = SOLID_NOT;
	pp.takedamage = DAMAGE_NO;
	
	//pp.gflags &= ~GF_FLASHLIGHT;
	
	//TAGGG - good idea too?
	pl.setInventoryEquippedIndex(-1);
	
	pp.armor = pp.activeweapon = pp.g_items = pp.weapon = 0;
	pp.health = 0;
	Sound_Play(pp, CHAN_AUTO, "player.die");

	if (cvar("coop") == 1) {
		pp.think = PutClientInServer;
		pp.nextthink = time + 4.0f;
	}

	if (pp.health < -50) {
		FX_GibHuman(pl.origin, vectoangles(pl.origin - g_dmg_eAttacker.origin), g_dmg_iDamage * 2.0f);
	}

	/* Let's handle corpses on the clientside */
	entity corpse = spawn();
	setorigin(corpse, pp.origin + [0,0,32]);
	setmodel(corpse, pp.model);
	setsize(corpse, VEC_HULL_MIN, VEC_HULL_MAX);
	corpse.movetype = MOVETYPE_TOSS;
	corpse.solid = SOLID_TRIGGER;
	corpse.modelindex = pp.modelindex;
	corpse.frame = ANIM_DIESIMPLE;
	corpse.angles = pp.angles;
	corpse.velocity = pp.velocity;
}

void
TSSingleplayerRules::PlayerSpawn(base_player pp)
{
	pp.classname = "player";
	pp.health = pp.max_health = 100;
	pp.takedamage = DAMAGE_YES;
	pp.solid = SOLID_SLIDEBOX;
	pp.movetype = MOVETYPE_WALK;
	pp.flags = FL_CLIENT;
	pp.viewzoom = 1.0;
	pp.model = "models/player.mdl";


	if (cvar("coop") == 1) {
		string mymodel = infokey(pp, "model");
		if (mymodel) {
			mymodel = sprintf("models/player/%s/%s.mdl", mymodel, mymodel);
			if (whichpack(mymodel)) {
				pp.model = mymodel;
			}
		}
	}

	setmodel(pp, pp.model);

	setsize(pp, VEC_HULL_MIN, VEC_HULL_MAX);
	pp.velocity = [0,0,0];
	pp.gravity = __NULL__;
	pp.frame = 1;
	//pp.SendEntity = Player_SendEntity;
	pp.SendFlags = UPDATE_ALL;
	pp.customphysics = Empty;
	pp.iBleeds = TRUE;
	forceinfokey(pp, "*spec", "0");
	forceinfokey(pp, "*deaths", ftos(pp.deaths));

	/* this is where the mods want to deviate */
	entity spot;

	if (startspot != "") {
		dprint(sprintf("^3Gamerules_Spawn^7: Startspot is %s\n", startspot));
		LevelDecodeParms(pp);
		setorigin(pp, Landmark_GetSpot());
	} else {
		LevelNewParms();
		spot = find(world, ::classname, "info_player_start");
		setorigin(pp, spot.origin);
		pp.angles = spot.angles;
	}

	Weapons_RefreshAmmo(pp);
	Client_FixAngle(pp, pp.angles);
} 
