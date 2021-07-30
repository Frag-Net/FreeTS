

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
	//printfline("***SharedGame_Precache called***");
	
	
	precache_model("models/powerup.mdl");
	
	// nearly identical..?
	precache_model("models/56_shell.mdl");
	precache_model("models/556_shell.mdl");
	
	// identical..?
	precache_model("models/22_shell.mdl");
	precache_model("models/9mm_shell.mdl");
	precache_model("models/shell.mdl");
	
	precache_model("models/shotgun_shell.mdl");
	precache_model("models/shotgun_shell_blue.mdl");
	precache_model("models/shotgun_shell_gold.mdl");

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

	
	//FROM BASE HL (Valve folder)
	precache_sound("common/wpn_denyselect.wav");
	precache_sound("common/wpn_select.wav");


	precache_sound("items/gunpickup2.wav");
	precache_sound("items/weapondrop1.wav");
	
	// similar sounds... but the 1st one is more authentic to what I heard.
	precache_sound("items/9mmclip1.wav");
	//precache_sound("weapons/reload1.wav");

	precache_sound("weapons/pistol-empty.wav");
	precache_sound("weapons/insert-shell.wav");
	precache_sound("weapons/m3/m3-pump.wav");
	
	precache_sound("weapons/weapondrop.wav");
	
	
	
	//karate
	precache_sound("player/closecombat.wav");
	precache_sound("player/kevlarhit.wav");
	precache_sound("player/kungfuhit.wav");
	precache_sound("player/block.wav");
	
	precache_sound("player/land.wav");
	precache_sound("player/superjump-land.wav");
	precache_sound("player/airwheel.wav");
	precache_sound("player/dive.wav");
	
	
	
	// ... what?
	precache_sound("player/pl_pain2.wav");
	precache_sound("player/pl_pain4.wav");
	
	
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
	
	
	
	precache_sound("weapons/ak47/clipin.wav");
	precache_sound("weapons/ak47/clipout.wav");
	precache_sound("weapons/ak47/fire.wav");
	precache_sound("weapons/ak47/slideback.wav");
	precache_sound("weapons/aug/aug-fire-sil.wav");
	precache_sound("weapons/aug/aug-fire.wav");
	precache_sound("weapons/aug/boltpull.wav");
	precache_sound("weapons/aug/boltslap.wav");
	precache_sound("weapons/aug/clipin.wav");
	precache_sound("weapons/aug/clipout.wav");
	precache_sound("weapons/barrett/clipin.wav");
	precache_sound("weapons/barrett/clipout.wav");
	precache_sound("weapons/barrett/fire.wav");
	precache_sound("weapons/barrett/slideback.wav");
	precache_sound("weapons/beretta/clipin.wav");
	precache_sound("weapons/beretta/clipout.wav");
	precache_sound("weapons/beretta/fire-sil.wav");
	precache_sound("weapons/beretta/fire.wav");
	precache_sound("weapons/beretta/sliderelease.wav");
	precache_sound("weapons/bull/cylinderin.wav");
	precache_sound("weapons/bull/cylinderout.wav");
	precache_sound("weapons/bull/fire01.wav");
	precache_sound("weapons/bull/hammerback.wav");
	precache_sound("weapons/bull/insert-shell.wav");
	precache_sound("weapons/bull/shellsout.wav");
	precache_sound("weapons/contender/close.wav");
	precache_sound("weapons/contender/fire.wav");
	precache_sound("weapons/contender/hammerback.wav");
	precache_sound("weapons/contender/insert-shell.wav");
	precache_sound("weapons/contender/open.wav");
	precache_sound("weapons/contender/shellout.wav");
	precache_sound("weapons/deagle/clipin.wav");
	precache_sound("weapons/deagle/clipout.wav");
	precache_sound("weapons/deagle/fire-sil.wav");
	precache_sound("weapons/deagle/fire.wav");
	precache_sound("weapons/deagle/slideback.wav");
	precache_sound("weapons/draw.wav");
	precache_sound("weapons/fire-inslow-sil.wav");
	precache_sound("weapons/fire-inslow.wav");
	precache_sound("weapons/fnh/clipin.wav");
	precache_sound("weapons/fnh/clipout.wav");
	precache_sound("weapons/fnh/fnh-fire-sil.wav");
	precache_sound("weapons/fnh/fnh-fire.wav");
	precache_sound("weapons/fnh/sliderelease.wav");
	precache_sound("weapons/generic_reload.wav");
	precache_sound("weapons/glock/clipin.wav");
	precache_sound("weapons/glock/clipout.wav");
	precache_sound("weapons/glock/glock-fire-sil.wav");
	precache_sound("weapons/glock/glock-fire.wav");
	precache_sound("weapons/glock/slideback.wav");
	precache_sound("weapons/glock22/glock22-fire-sil.wav");
	precache_sound("weapons/glock22/glock22-fire.wav");
	precache_sound("weapons/gold/clipin.wav");
	precache_sound("weapons/gold/clipout.wav");
	precache_sound("weapons/gold/gold-fire.wav");
	precache_sound("weapons/gold/sliderelease.wav");
	precache_sound("weapons/grenbounce1.wav");
	precache_sound("weapons/grenbounce2.wav");
	precache_sound("weapons/grenbounce3.wav");
	precache_sound("weapons/grenbounce4.wav");
	precache_sound("weapons/gr_pull.wav");
	precache_sound("weapons/gr_safe.wav");
	precache_sound("weapons/insert-shell.wav");
	precache_sound("weapons/items.wav");
	precache_sound("weapons/katana/hit-body.wav");
	precache_sound("weapons/katana/hit.wav");
	precache_sound("weapons/katana/hit1.wav");
	precache_sound("weapons/katana/miss.wav");
	precache_sound("weapons/katana/miss1.wav");
	precache_sound("weapons/knife/knife_hit.wav");
	precache_sound("weapons/knife/knife_hitbody.wav");
	precache_sound("weapons/knife/knife_miss.wav");
	precache_sound("weapons/m16/fire.wav");
	precache_sound("weapons/m3/m3-fire.wav");
	precache_sound("weapons/m3/m3-pump.wav");
	precache_sound("weapons/m4/boltpull.wav");
	precache_sound("weapons/m4/clipin.wav");
	precache_sound("weapons/m4/clipout.wav");
	precache_sound("weapons/m4/m4-fire-sil.wav");
	precache_sound("weapons/m4/m4-fire.wav");
	precache_sound("weapons/m60/ammo_belt.wav");
	precache_sound("weapons/m60/boltpull.wav");
	precache_sound("weapons/m60/close.wav");
	precache_sound("weapons/m60/m60-fire.wav");
	precache_sound("weapons/m60/open.wav");
	precache_sound("weapons/mac10/clipin.wav");
	precache_sound("weapons/mac10/clipout.wav");
	precache_sound("weapons/mac10/mac10-fire-sil.wav");
	precache_sound("weapons/mac10/mac10-fire.wav");
	precache_sound("weapons/mac10/slideback.wav");
	precache_sound("weapons/mk23/clipin.wav");
	precache_sound("weapons/mk23/clipout.wav");
	precache_sound("weapons/mk23/mk23-fire-sil.wav");
	precache_sound("weapons/mk23/mk23-fire.wav");
	precache_sound("weapons/mk23/sliderelease.wav");
	precache_sound("weapons/mossberg/fire.wav");
	precache_sound("weapons/mp5/boltpull.wav");
	precache_sound("weapons/mp5/boltslap.wav");
	precache_sound("weapons/mp5/clipin.wav");
	precache_sound("weapons/mp5/clipout.wav");
	precache_sound("weapons/mp5k/mp5k-fire-sil.wav");
	precache_sound("weapons/mp5k/mp5k-fire.wav");
	precache_sound("weapons/mp5sd/mp5sd-fire.wav");
	precache_sound("weapons/pdw/clipin.wav");
	precache_sound("weapons/pdw/clipout.wav");
	precache_sound("weapons/pdw/fire-sil.wav");
	precache_sound("weapons/pdw/fire.wav");
	precache_sound("weapons/pdw/slideback.wav");
	precache_sound("weapons/pistol-empty.wav");
	precache_sound("weapons/ruger/clipin.wav");
	precache_sound("weapons/ruger/clipout.wav");
	precache_sound("weapons/ruger/fire.wav");
	precache_sound("weapons/ruger/slide.wav");
	precache_sound("weapons/sawedoff/close.wav");
	precache_sound("weapons/sawedoff/fire.wav");
	
	// the ak47 fire sound is copied here... why?
	//precache_sound("weapons/sawedoff/fire1.wav");
	
	precache_sound("weapons/sawedoff/insert-shell.wav");
	precache_sound("weapons/sawedoff/open.wav");
	precache_sound("weapons/sawedoff/shelldrop.wav");
	precache_sound("weapons/sawedoff/shellout.wav");
	precache_sound("weapons/sawedoff/tapspan.wav");
	precache_sound("weapons/sfire-inslow.wav");
	precache_sound("weapons/shell.wav");
	precache_sound("weapons/skorpion/fire.wav");
	precache_sound("weapons/spas12/spas12-fire.wav");
	precache_sound("weapons/spas12/spas12-pump.wav");
	precache_sound("weapons/sshell.wav");
	precache_sound("weapons/sshell1.wav");
	precache_sound("weapons/sshell2.wav");
	precache_sound("weapons/sshell3.wav");
	
	// TODO - precache only clientside later, UI-only sound.
	// Same for others where that applies
	precache_sound("weapons/switch.wav");
	
	precache_sound("weapons/tmp/clipin.wav");
	precache_sound("weapons/tmp/clipout.wav");
	precache_sound("weapons/tmp/fire-sil.wav");
	precache_sound("weapons/tmp/fire.wav");
	precache_sound("weapons/tmp/slideback.wav");
	precache_sound("weapons/ump/boltpull.wav");
	precache_sound("weapons/ump/boltslap.wav");
	precache_sound("weapons/ump/clipin.wav");
	precache_sound("weapons/ump/clipout.wav");
	precache_sound("weapons/ump/clipslap.wav");
	precache_sound("weapons/ump/slideback.wav");
	precache_sound("weapons/ump/ump-fire-sil.wav");
	precache_sound("weapons/ump/ump-fire.wav");
	precache_sound("weapons/usas/clipin.wav");
	precache_sound("weapons/usas/clipout.wav");
	precache_sound("weapons/usas/slideback.wav");
	precache_sound("weapons/usas/usas-fire.wav");
	precache_sound("weapons/uzi/clipin.wav");
	precache_sound("weapons/uzi/clipout.wav");
	precache_sound("weapons/uzi/slideback.wav");
	precache_sound("weapons/uzi/uzi-fire-sil.wav");
	precache_sound("weapons/uzi/uzi-fire.wav");
	precache_sound("weapons/weapondrop.wav");
	precache_sound("weapons/weapon_items.wav");

	//Needed, apparently.
	precache_sound("common/null.wav");
	
	
	precache_model("sprites/new/glow02.spr");
	
	
}
