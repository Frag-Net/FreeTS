

// IMPORTANT NOTE!!!
// "precache_pic" is for clientside only and can handle .tga files without any change.
// example:
//	 precache_pic("path/file.tga");   is fine.
// It is unknown if precache_pic can handle .spr files.
// "precache_model" can take .spr files without any change.
//	  precache_model("path/file.spr")
// HOWEVER, in use in drawing methods, you often have to add "_0.tga" to the name:
//	 ..."path/file.spr_0.tga"
// It is unknown if precache_model can take .tga files.


void SharedGame_Precache(void){
	printfline("***SharedGame_Precache called***");
	
	
	// good idea to have precache shared?  Unsure, but it has script client and serverside
	CTSPowerUp::precache();
	
	precache_model("models/powerup.mdl");
	
	// In FreeTS, looks like shell eject effects are precached both client and serverside
	// (so here in shared/precache.qc is good).
	
	// physics-related / slow-mo?
	precache_model("models/bullet.mdl");
	precache_model("models/long_bullet.mdl");
	
	
	// some model for dirt effects?
	precache_model("models/pellet.mdl");

	// Strangely only in 3rd-person, these are dropped by certain weapons reloading, 
	// I'm guessing most things that aren't shotguns or the m61 large machine gun
	// (reloads without a visible clip)
	precache_model("models/generic_clip.mdl");
	//it appears to be missing the bottom polygon or have it culled.
	// Raging bull drops 6 bullet shells in 3rd person instead (not 1st person)

	
	// FROM BASE HL (Valve folder)
	precache_sound("common/wpn_denyselect.wav");
	precache_sound("common/wpn_select.wav");


	// similar sounds, but the first one is more authentic to what I heard.
	precache_sound("items/9mmclip1.wav");
	//precache_sound("weapons/reload1.wav");
	
	// should any of these be server or client only?  No idea with a lot of these
	// common ones
	precache_sound("weapons/pistol-empty.wav");
	precache_sound("weapons/insert-shell.wav");
	precache_sound("weapons/weapondrop.wav");
	precache_sound("items/weapondrop1.wav");
	precache_sound("items/gunpickup2.wav");
	
	
	// Needed, apparently.
	precache_sound("common/null.wav");
	
	//precache_sound("weapons/insert-shell.wav");
	precache_sound("weapons/items.wav");
	precache_sound("weapons/weapon_items.wav");
	
	// TODO - precache only clientside later, UI-only sound.
	// Same for others where that applies
	precache_sound("weapons/switch.wav");
	
	//precache_sound("weapons/weapondrop.wav");
	
	
	// ? Are these leftover test sounds?  Awfully inspecific
	precache_sound("weapons/fire-inslow-sil.wav");
	precache_sound("weapons/fire-inslow.wav");
	precache_sound("weapons/sfire-inslow.wav");
	
	precache_sound("weapons/generic_reload.wav");
	
	// Anything with a coldcock attack needs these too, but some melee
	// weapon precache methods handle them.
	//precache_sound("player/closecombat.wav");
	//precache_sound("weapons/knife/knife_hitbody.wav");
	
	
	precache_sound("player/land.wav");
	precache_sound("player/superjump-land.wav");
	precache_sound("player/airwheel.wav");
	precache_sound("player/dive.wav");
	
	// Is this for karate?  Unsure, but it was grouped with those sounds before.
	// TODO: when does this play, if it does, in original TS?
	// Bullet hits with kevlar on?  Melee hits with kevlar on?  Verify.
	precache_sound("player/kevlarhit.wav");
	
	// ... what?
	precache_sound("player/pl_pain2.wav");
	precache_sound("player/pl_pain4.wav");
	
	
	//TAGGG - TODO.  A lot of these are likely redundant with fx_breakmodel.
	// TS might not even make use of that at all, I forget if it does.
	// For now, not precaching this.  Should be precached clientside only most
	// likely anyway, it is for fx_breakmodel.
	/*
	precache_sound("debris/bustcrate1.wav");
	precache_sound("debris/bustcrate2.wav");
	precache_sound("debris/bustcrate3.wav");
	precache_sound("debris/bustglass1.wav");
	precache_sound("debris/bustglass2.wav");
	precache_sound("debris/bustglass3.wav");
	precache_sound("debris/cement1.wav");
	precache_sound("debris/cement2.wav");
	precache_sound("debris/cement3.wav");
	precache_sound("debris/cement4.wav");
	precache_sound("debris/cement5.wav");
	precache_sound("debris/cement6.wav");
	precache_sound("debris/glass1.wav");
	precache_sound("debris/glass2.wav");
	precache_sound("debris/glass3.wav");
	precache_sound("debris/glass4.wav");
	precache_sound("debris/gravel1.wav");
	precache_sound("debris/gravel2.wav");
	precache_sound("debris/gravel3.wav");
	precache_sound("debris/gravel4.wav");
	precache_sound("debris/metal1.wav");
	precache_sound("debris/metal2.wav");
	precache_sound("debris/metal3.wav");
	precache_sound("debris/metal4.wav");
	precache_sound("debris/metal5.wav");
	precache_sound("debris/ric1.wav");
	precache_sound("debris/ric2.wav");
	precache_sound("debris/ric3.wav");
	precache_sound("debris/ric4.wav");
	precache_sound("debris/ric5.wav");
	precache_sound("debris/wood1.wav");
	precache_sound("debris/wood2.wav");
	precache_sound("debris/wood3.wav");
	*/
	
	
	// ? What uses these?  No clue, could be shared, but handled by model
	// precaches (event-driven) if needed anyway.
	//precache_sound("weapons/mp5/boltpull.wav");
	//precache_sound("weapons/mp5/boltslap.wav");
	//precache_sound("weapons/mp5/clipin.wav");
	//precache_sound("weapons/mp5/clipout.wav");
	
	
}
