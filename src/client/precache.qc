

void ClientGame_Precache(void){
	// Yes, this seems to be happening twice at startup since the
	// hook from RendererRestart.
	// IDEA: test in FreeHL / FreeCS.  Do they call RendererRestart twice at startup too?
	printfline("***ClientGame_Precache called***");
	SharedGame_Precache();
	
	
	// things from ClientGame_RendererRestart from FreeHL mostly for referred-to effects
	////////////////////////////////////////////////////////////////////////////////////
	Obituary_Precache();

	// All forked effects!
	FX_Blood_Init();
	FX_Impact_Init();
	////////////////////////////////////////////////////////////////////////////////////
	
	CTSShellEject::precache();
	FX_TS_Explosion_Grenade_Init();
	FX_Impact_Melee_Init();
	MuzzleFlash_precache();
	
	
	// from Valve
	// ALSO - important note.  If this is precached serverside - at all, exclusively
	// or in addition to this - this will still show up clientside at first.
	// However, any "vid_restart" (or simialr reason to restart the window I assume)
	// will make this model disappear (go checkerboard).
	// And yes, even SharedGame_Precache is called by RendererRestart (in fact the
	// very call is above in here, and ClientGame_Preche is called by RendererRestart).
	precache_model("sprites/glow02.spr");
	
	precache_sound("weapons/draw.wav");
	
	precache_model("sprites/mapsprites/ts_gpc1.spr");
	precache_model("sprites/mapsprites/ts_gpc2.spr");
	
	
	precache_model("sprites/wires/bwire.spr");
	precache_model("sprites/wires/bwirecutted.spr");
	precache_model("sprites/wires/gwire.spr");
	precache_model("sprites/wires/gwirecutted.spr");
	precache_model("sprites/wires/rwire.spr");
	precache_model("sprites/wires/rwirecutted.spr");
	
	precache_model("sprites/3dm_branch.spr");
	precache_model("sprites/3dm_leaves1.spr");
	precache_model("sprites/3dm_leaves2.spr");
	precache_model("sprites/3dm_leaves3.spr");
	precache_model("sprites/3dm_leaves4.spr");
	precache_model("sprites/3dm_palm_01.spr");
	precache_model("sprites/3dm_palm_02.spr");
	precache_model("sprites/3dm_palm_03.spr");
	precache_model("sprites/3dm_sfa_tva.spr");
	precache_model("sprites/3dm_sfa_tvb.spr");
	precache_model("sprites/3dm_sfa_tvc.spr");
	precache_model("sprites/3dm_sfa_tvd.spr");
	precache_model("sprites/3dm_sfa_tve.spr");
	precache_model("sprites/3dm_trunk.spr");
	precache_model("sprites/3dm_trunk1.spr");
	precache_model("sprites/3dm_trunk2.spr");
	precache_model("sprites/black_smoke1.spr");
	precache_model("sprites/blood_smoke.spr");
	precache_model("sprites/blood_smoke_add.spr");
	precache_model("sprites/bloodfrag.spr");
	precache_model("sprites/bloodfrag2.spr");
	precache_model("sprites/bullet_trail.spr");
	precache_model("sprites/bullet_trail2.spr");
	precache_model("sprites/bullet_trail3.spr");
	precache_model("sprites/bullet_wave.spr");
	precache_model("sprites/bullet_wave2.spr");
	precache_model("sprites/compass.spr");
	precache_model("sprites/conc_decal.spr");
	precache_model("sprites/confrag.spr");
	precache_model("sprites/cross_e.spr");
	precache_model("sprites/cross_t.spr");
	
	//precache_model("sprites/cross2.spr");
	precache_pic("textures/cross2.tga");
	
	
	precache_model("sprites/cursor.spr");
	precache_model("sprites/debris_concrete1.spr");
	precache_model("sprites/debris_concrete2.spr");
	precache_model("sprites/debris_concrete3.spr");
	precache_model("sprites/downarrow.spr");
	precache_model("sprites/drop.spr");
	precache_model("sprites/dust.spr");
	precache_model("sprites/flash.spr");
	precache_model("sprites/glassfrag.spr");
	precache_model("sprites/glow01.spr");
	precache_model("sprites/gun_muzzle.spr");
	precache_model("sprites/gun_muzzle2.spr");
	precache_model("sprites/gun_smoke_add.spr");
	precache_model("sprites/knife_decal.spr");
	precache_model("sprites/laserbeam.spr");
	precache_model("sprites/laserdot.spr");
	precache_model("sprites/mazyleaves1.spr");
	precache_model("sprites/mazyleaves2.spr");
	precache_model("sprites/mazyleaves3.spr");
	precache_model("sprites/mazyleaves4.spr");
	precache_model("sprites/mazytrunk1.spr");
	precache_model("sprites/metal_decal.spr");
	precache_model("sprites/muzzle1.spr");
	precache_model("sprites/numbers.spr");
	precache_model("sprites/ombra.spr");
	precache_model("sprites/quarterscope.spr");
	precache_model("sprites/redfl1.spr");
	precache_model("sprites/scintille.spr");
	precache_model("sprites/scintille_metal.spr");
	precache_model("sprites/scintille2.spr");
	precache_model("sprites/shotgun_pellets.spr");
	precache_model("sprites/slowmotion.spr");
	precache_model("sprites/ts_muzzleflash1.spr");
	precache_model("sprites/ts_muzzleflash1h.spr");
	precache_model("sprites/ts_muzzleflash1s.spr");
	precache_model("sprites/ts_muzzleflash2h.spr");
	precache_model("sprites/ts_muzzleflash6.spr");
	precache_model("sprites/ts_muzzleflash6b.spr");
	precache_model("sprites/uparrow.spr");
	precache_model("sprites/wood_decal.spr");
	precache_model("sprites/wood_smoke_add.spr");
	precache_model("sprites/woodfrag.spr");
	precache_model("sprites/xsmoke1.spr");
	
	
	// for tga's only
	precache_pic("textures/quarterscope.tga");
	//precache_pic("textures/scope_cross_plus.tga");
	precache_pic("textures/scope_cross_plus_odd.tga");
	//precache_pic("textures/quarterscope_small.tga");
	//precache_pic("textures/cal_9x18mm.tga");
	
	
	// do we know what of these we even need?
	precache_model("sprites/fexplo.spr");
	
	precache_sound("common/wpn_hudon.wav");
	precache_sound("common/wpn_hudoff.wav");
	precache_sound("common/wpn_moveselect.wav");
	// "common/wpn_select.wav" is precached shared according to FreeHL?
	
	
}
