
enum weaponseq_m4a1{
	idle,
	reload,
	draw,
	shoot1,
	shoot2,
	sshoot1,
	sshoot2,
	idle2,
	change,
	rechange,
	shoot3,
	shoot4,
	sshoot3,
	sshoot4,
	reload2,
	coldcock
};


void weapon_m4a1_onPrimaryAttackRelease(player pl, weapondynamic_t arg_thisWeapon){
	
}
void weapon_m4a1_onSecondaryAttackRelease(player pl, weapondynamic_t arg_thisWeapon){
	
}

void weapon_m4a1_onThink(player pl, weapondynamic_t arg_thisWeapon){
	weapon_gun_onThink(pl, (weapondata_gun_t*)ary_weaponData[WEAPON_ID::M4A1], arg_thisWeapon);
}
void weapon_m4a1_onColdCock(player pl, weapondynamic_t arg_thisWeapon){
	
	if(pl.w_attack_next > 0){
		return;
	}
	
	MELEE_HIT_RESPONSE hitRep = weapon_base_coldcock(pl, ary_weaponData[WEAPON_ID::M4A1], arg_thisWeapon, 40, 66);
	weapon_base_setWholeAttackDelay(pl, 0.73f);
	TS_Weapons_ViewAnimation_noLaserLock(weaponseq_m4a1::coldcock, 30.0f/40.0f);
	arg_thisWeapon.iIronSight = 0;  //disable, coldcock returns to non-ironsight look
	
	if (hitRep == MELEE_HIT_RESPONSE::NONE ) {
		TS_Weapons_PlaySoundDirect(pl, "player/closecombat.wav");
	}else if(hitRep == MELEE_HIT_RESPONSE::SOFT){
		TS_Weapons_PlaySoundDirect(pl, "player/closecombat.wav");
	}else if(hitRep == MELEE_HIT_RESPONSE::METAL){
		TS_Weapons_PlaySoundDirect(pl, "player/closecombat.wav");
	}else if(hitRep == MELEE_HIT_RESPONSE::FLESH){
		TS_Weapons_PlaySoundDirect(pl, "weapons/knife/knife_hitbody.wav");
	}
	
}

	
weapondata_ironsight_t weapon_m4a1 =
{
	WEAPONDATA_TYPEID_IRONSIGHT,
	"M4A1",
	"models/v_m4.mdl",
	"models/p_m4.mdl",
	"models/p_m4_sil.mdl",
	"models/w_m4.mdl",
	"sprites/weapons/m4.spr",
	weapon_m4a1_onPrimaryAttackRelease,
	weapon_m4a1_onSecondaryAttackRelease,
	weapon_m4a1_onThink,
	weapon_m4a1_onColdCock,
	weaponseq_m4a1::idle,
	weaponseq_m4a1::draw,
	31.0f / 35.0f,
	0.0625f,  //fire delay.
	7.0f,  //dmg
	TRUE,
	BITS_WEAPONOPT_SILENCER | BITS_WEAPONOPT_LASERSIGHT | BITS_WEAPONOPT_FLASHLIGHT | BITS_WEAPONOPT_SCOPE,
	BITS_WEAPONOPT_NONE,
	4500,
	40,
	BUYCATEGORY_RIFLES,
	4,
	{0.007500, 2.750000, 0.000000},
	WEAPON_AKIMBO_UPGRADE_ID::NONE,
	BITS_FIREMODE_FULL | BITS_FIREMODE_SEMI,
	BITS_FIREMODE_FULL,
	AMMO_ID::_5P56NATO,
	30,  //clip
	4096, //range
	weaponseq_m4a1::reload,
	96.0f / 35.0f,
	1,
	3,
	2,
	4,
	{
		weaponseq_m4a1::change,
		21.0f/60.0f,
		weaponseq_m4a1::rechange,
		21.0f/60.0f,
		weaponseq_m4a1::idle2,
		weaponseq_m4a1::reload2,
		96.0f / 35.0f,
		{0.007500, 2.750000, 0.000000}
	}
};



void
w_m4a1_precache(void)
{
	weapon_precache(ary_weaponData[WEAPON_ID::M4A1]);
#ifdef SERVER
	//precache_sound("weapons/m4/boltpull.wav");
	//precache_sound("weapons/m4/clipin.wav");
	//precache_sound("weapons/m4/clipout.wav");
	precache_sound("weapons/m4/m4-fire-sil.wav");
	precache_sound("weapons/m4/m4-fire.wav");
#else
	
#endif
}

void
w_m4a1_updateammo(player pl)
{
}

string
w_m4a1_wmodel(void)
{
	return (*ary_weaponData[WEAPON_ID::M4A1]).sWorldModelPath;
}

string
w_m4a1_pmodel(void)
{
	// Do we have the silencer?
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	if(!(arg_thisWeapon.iBitsUpgrade & BITS_WEAPONOPT_SILENCER) ){
		return (*ary_weaponData[WEAPON_ID::M4A1]).sPlayerModelPath;
	} else {
		return (*ary_weaponData[WEAPON_ID::M4A1]).sPlayerSilencerModelPath;
	}
}

string
w_m4a1_deathmsg(void)
{
	return "";
}

void
w_m4a1_draw(void)
{
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	
	weapon_base_onEquip(pl, ary_weaponData[WEAPON_ID::M4A1], arg_thisWeapon);
}

void
w_m4a1_holster(void)
{
}

void
w_m4a1_primary(void)
{
	float randomChoice;
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];

	if (pl.w_attack_next > 0.0) {
		return;
	}
	
	if(arg_thisWeapon.iFireMode == BITS_FIREMODE_SEMI){
		INPUT_PRIMARY_TAP_GATE
	}
	
	if (!arg_thisWeapon.iClipLeft || WEAPON_UNDERWATER_CHECK) {
		PLAY_CLICK_SOUND
		return;
	}
	
	if(!(arg_thisWeapon.iBitsUpgrade & BITS_WEAPONOPT_SILENCER) ){
		SoundPitched_Send(pl, SNDP_M4A1_FIRE);
	} else {
		SoundPitched_Send(pl, SNDP_M4A1_FIRE_SIL);
	}

	if(!arg_thisWeapon.iIronSight){
		randomChoice = random();
		if(randomChoice < 1/4){
			TS_Weapons_ViewAnimation(weaponseq_m4a1::shoot1, (31.0f/30.0f) );
		}else if(randomChoice < 2/4){
			TS_Weapons_ViewAnimation(weaponseq_m4a1::shoot2, (31.0f/30.0f) );
		}else if(randomChoice < 3/4){
			TS_Weapons_ViewAnimation(weaponseq_m4a1::sshoot1, (31.0f/30.0f) );
		}else{
			TS_Weapons_ViewAnimation(weaponseq_m4a1::sshoot2, (31.0f/30.0f) );
		}
	}else{
		randomChoice = random();
		if(randomChoice < 1/4){
			TS_Weapons_ViewAnimation(weaponseq_m4a1::shoot3, (31.0f/30.0f) );
		}else if(randomChoice < 2/4){
			TS_Weapons_ViewAnimation(weaponseq_m4a1::shoot4, (31.0f/30.0f) );
		}else if(randomChoice < 3/4){
			TS_Weapons_ViewAnimation(weaponseq_m4a1::sshoot3, (31.0f/30.0f) );
		}else{
			TS_Weapons_ViewAnimation(weaponseq_m4a1::sshoot4, (31.0f/30.0f) );
		}
	}
	
#ifdef CLIENT
	View_ShowMuzzleflash(MUZZLE_SMALL);
	View_AddEvent(w_ejectshell_pistol, 0.0f);
#endif
	
	weapon_base_onAttack(pl, ary_weaponData[WEAPON_ID::M4A1], arg_thisWeapon, BITS_AKIMBOCHOICE_LEFT);
	
	weapon_base_setWholeAttackDelay(pl, (*ary_weaponData[arg_thisWeapon.weaponID]).fAttackDelay);

	if (self.flags & FL_CROUCHING){
		Animation_PlayerTop(pl, ANIM_CR_SHOOT1HAND, 0.2f);
	}else{
		Animation_PlayerTop(pl, ANIM_SHOOT1HAND, 0.2f);
	}
	
}

void
w_m4a1_secondary(void)
{
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	
	if(pl.w_attack_next > 0){
		return;
	}
	
	INPUT_SECONDARY_TAP_GATE
	
	if(arg_thisWeapon.iBitsUpgrade & BITS_WEAPONOPT_SCOPE){
		// toggle through the zoom.
		
		switch(pl.currentZoomChoice){
			case -1:{
				//pl.viewzoom = 26/80;
				pl.setZoom(0.325f);
				pl.currentZoomChoice++;
			break;}
			case 0:{
				//pl.viewzoom = 0;
				pl.setZoom(1.00f);
				pl.currentZoomChoice = -1;
			break;}
			
		}//END OF switch

	}else{
		// no scope?  we use ironsights then.
		weapon_ironsight_ToggleIronsight(pl, (weapondata_ironsight_t*)ary_weaponData[WEAPON_ID::M4A1], arg_thisWeapon);
	}
	
}


void
w_m4a1_reload(void)
{
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];

	weapon_ironsight_Reload(pl, (weapondata_ironsight_t*)ary_weaponData[WEAPON_ID::M4A1], arg_thisWeapon);
}

float
w_m4a1_aimanim(void)
{
	return self.flags & FL_CROUCHING ? ANIM_CR_AIM1HAND : ANIM_AIM1HAND;
}

void
w_m4a1_hud(void)
{
	player pl = (player)self;
	
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	weapon_gun_onDrawHUD(pl, (weapondata_gun_t*)ary_weaponData[WEAPON_ID::M4A1], arg_thisWeapon);

}

void
w_m4a1_hudpic(int selected, vector pos, float a)
{
	//
}

weapon_t w_m4a1 =
{
	
	.name		= "m4a1",
	.id			= 0,  // not using this
	.slot		= 2,  // ?
	.slot_pos	= 0,  // not using this
	.weight		= 0,  // not using this
	.draw		= w_m4a1_draw,
	.holster	= w_m4a1_holster,
	.primary	= w_m4a1_primary,
	.secondary	= w_m4a1_secondary,
	.reload		= w_m4a1_reload,
	.release	= NULL,
	.crosshair	= w_m4a1_hud,
	.precache	= w_m4a1_precache,
	.pickup		= NULL,
	.updateammo	= w_m4a1_updateammo,
	.wmodel		= w_m4a1_wmodel,
	.pmodel		= w_m4a1_pmodel,
	.deathmsg	= w_m4a1_deathmsg,
	.aimanim	= w_m4a1_aimanim,
	.hudpic		= NULL
	
};

