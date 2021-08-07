


void ServerGame_Precache(void){
	printfline("***ServerGame_Precache called***");
	SharedGame_Precache();
	
	
	//TAGGG - From FreeHL.  Anything that ends up unused by FreeTS can be removed,
	// including sound config files that are then unused.
	////////////////////////////////////////////////////////////
	Sound_Precache("player.die");
	Sound_Precache("player.die_headshot");
	Sound_Precache("player.fall");
	Sound_Precache("player.lightfall");

	precache_model("models/player.mdl");
	////////////////////////////////////////////////////////////
	
	
	precache_model("models/powerup.mdl");
	
	
	// player models in cstrike are precached
	// serverside only, so we can too I suppose
	precache_model("models/player/agent/agent.mdl");
	precache_model("models/player/castor/castor.mdl");
	precache_model("models/player/gordon/gordon.mdl");
	precache_model("models/player/hitman/hitman.mdl");
	precache_model("models/player/laurence/laurence.mdl");
	precache_model("models/player/merc/merc.mdl");
	precache_model("models/player/seal/seal.mdl");
	
	
	
	// do 3D models too.
	precache_model("models/ammopack.mdl");
	
	precache_model("sprites/glow01.spr");
	
	
	
	precache_sound("player/die1.wav");
	precache_sound("player/die2.wav");
	precache_sound("player/die3.wav");
	precache_sound("player/headshot.wav");
	precache_sound("player/headshot2.wav");
	precache_sound("player/bodyhit1.wav");
	precache_sound("player/bodyhit2.wav");
	precache_sound("player/bodyhit3.wav");
	precache_sound("player/bodyhit4.wav");
	precache_sound("player/pain1.wav");
	precache_sound("player/pain2.wav");
	precache_sound("player/pain3.wav");
	precache_sound("player/pain4.wav");
	
	// for the grenade only so far.
	precache_sound("weapons/grenbounce1.wav");
	precache_sound("weapons/grenbounce2.wav");
	precache_sound("weapons/grenbounce3.wav");
	precache_sound("weapons/grenbounce4.wav");
	precache_sound("explo/explode.wav");
	precache_sound("explo/explode1.wav");
	precache_sound("explo/explode2.wav");
	precache_sound("explo/explode3.wav");
	precache_sound("explo/explode4.wav");
	
	precache_sound("goslow.wav");
	
	
	
}
