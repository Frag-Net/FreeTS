
enum weaponseq_socommk23{
	idleb = 0,
	shootb1 = 1,
	shootb2 = 2,
	shootblast = 3,
	drawb = 4,
	idlec = 5,
	shootc1 = 6,
	shootc2 = 7,
	shootclast = 8,
	change = 9,
	rechange = 10,
	reload = 11,
	reloadb = 12
};

void weapon_socommk23_onPrimaryAttackRelease(player pl, weapondynamic_t arg_thisWeapon){
	
}
void weapon_socommk23_onSecondaryAttackRelease(player pl, weapondynamic_t arg_thisWeapon){
	
}
void weapon_socommk23_onThink(player pl, weapondynamic_t arg_thisWeapon){
	weapon_gun_onThink(pl, (weapondata_gun_t*)ary_weaponData[WEAPON_ID::SOCOMMK23], arg_thisWeapon);
}
void weapon_socommk23_onColdCock(player pl, weapondynamic_t arg_thisWeapon){
	
}

weapondata_ironsight_t weapon_socommk23 =
{
	WEAPONDATA_TYPEID_IRONSIGHT,
	"SOCOM-MK23",
	"models/v_mk23.mdl",
	"models/p_mk23.mdl",
	"models/p_mk23_sil.mdl",
	"models/w_mk23.mdl",
	"sprites/weapons/mk23.spr",
	weapon_socommk23_onPrimaryAttackRelease,
	weapon_socommk23_onSecondaryAttackRelease,
	weapon_socommk23_onThink,
	weapon_socommk23_onColdCock,
	weaponseq_socommk23::idleb,
	weaponseq_socommk23::drawb,
	31.0f / 40.0f,
	0.19f,  //fire delay
	15.0f,  //dmg
	TRUE,
	BITS_WEAPONOPT_SILENCER | BITS_WEAPONOPT_LASERSIGHT | BITS_WEAPONOPT_FLASHLIGHT | BITS_WEAPONOPT_AKIMBO,
	BITS_WEAPONOPT_NONE,
	700,
	10,
	BUYCATEGORY_HANDGUNS,
	2,
	{0.020000, 2.000000, 0.000000},
	WEAPON_AKIMBO_UPGRADE_ID::SOCOMMK23,
	BITS_FIREMODE_SEMI,
	BITS_FIREMODE_SEMI,
	AMMO_ID::_45ACP,
	12,  //clip
	4096, //range
	weaponseq_socommk23::reload,
	45.0f / 30.0f,
	1,
	2,
	2,
	-1,
	{
		weaponseq_socommk23::change,
		21.0f/60.0f,
		weaponseq_socommk23::rechange,
		21.0f/60.0f,
		weaponseq_socommk23::idlec,
		weaponseq_socommk23::reloadb,
		43.0f/30.0f,
		{0.020000, 2.000000, 0.000000}
	}
};



void
w_socommk23_precache(void)
{
	weapon_precache(ary_weaponData[WEAPON_ID::SOCOMMK23]);
#ifdef SERVER
	//precache_sound("weapons/mk23/clipin.wav");
	//precache_sound("weapons/mk23/clipout.wav");
	precache_sound("weapons/mk23/mk23-fire-sil.wav");
	precache_sound("weapons/mk23/mk23-fire.wav");
	//precache_sound("weapons/mk23/sliderelease.wav");
#else
	
#endif
}

void
w_socommk23_updateammo(player pl)
{
}

string
w_socommk23_wmodel(void)
{
	return (*ary_weaponData[WEAPON_ID::SOCOMMK23]).sWorldModelPath;
}

string
w_socommk23_pmodel(void)
{
	// Do we have the silencer?
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	if(!(arg_thisWeapon.iBitsUpgrade & BITS_WEAPONOPT_SILENCER) ){
		return (*ary_weaponData[WEAPON_ID::SOCOMMK23]).sPlayerModelPath;
	} else {
		return (*ary_weaponData[WEAPON_ID::SOCOMMK23]).sPlayerSilencerModelPath;
	}
}

string
w_socommk23_deathmsg(void)
{
	return "";
}

void
w_socommk23_draw(void)
{
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	weapondata_basic_t* basicP = ary_weaponData[WEAPON_ID::SOCOMMK23];
	
	weapon_base_onEquip(pl, basicP, arg_thisWeapon);
}


void
w_socommk23_holster(void)
{
}


void
w_socommk23_primary(void)
{
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
		SoundPitched_Send(pl, SNDP_SOCOMMK23_FIRE);
	} else {
		SoundPitched_Send(pl, SNDP_SOCOMMK23_FIRE_SIL);
	}

	int r;
	if(!arg_thisWeapon.iIronSight){
		r = (float)input_sequence % 2;
		if(r == 0){
			TS_Weapons_ViewAnimation(weaponseq_socommk23::shootb1, (31.0f/30.0f));
		} else {
			TS_Weapons_ViewAnimation(weaponseq_socommk23::shootb2, (31.0f/30.0f));
		}
	}else{
		r = (float)input_sequence % 2;
		if(r == 0){
			TS_Weapons_ViewAnimation(weaponseq_socommk23::shootc1, (31.0f/30.0f));
		} else {
			TS_Weapons_ViewAnimation(weaponseq_socommk23::shootc2, (31.0f/30.0f));
		}
	}
	
	if(!(arg_thisWeapon.iBitsUpgrade & BITS_WEAPONOPT_SILENCER) ){
		weapon_ClientEffects(MUZZLEFLASH_ID::SMALL, SHELLEJECT_ID::GENERIC);
	} else {
		weapon_EjectShell(SHELLEJECT_ID::GENERIC);
	}	
	
	weapon_base_onAttack(pl, ary_weaponData[WEAPON_ID::SOCOMMK23], arg_thisWeapon, BITS_AKIMBOCHOICE_LEFT);
	
	weapon_base_setWholeAttackDelay(pl, (*ary_weaponData[arg_thisWeapon.weaponID]).fAttackDelay);

	if (self.flags & FL_CROUCHING){
		Animation_PlayerTop(pl, ANIM_CR_SHOOT1HAND, 0.2f);
	}else{
		Animation_PlayerTop(pl, ANIM_SHOOT1HAND, 0.2f);
	}
	
}



void
w_socommk23_secondary(void)
{
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	
	if(pl.w_attack_next > 0){
		return;
	}
	
	INPUT_SECONDARY_TAP_GATE
	
	weapon_ironsight_ToggleIronsight(pl, (weapondata_ironsight_t*)ary_weaponData[WEAPON_ID::SOCOMMK23], arg_thisWeapon);
}



void
w_socommk23_reload(void)
{
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];

	weapon_ironsight_Reload(pl, (weapondata_ironsight_t*)ary_weaponData[WEAPON_ID::SOCOMMK23], arg_thisWeapon);
}

float
w_socommk23_aimanim(void)
{
	return self.flags & FL_CROUCHING ? ANIM_CR_AIM1HAND : ANIM_AIM1HAND;
}

void
w_socommk23_hud(void)
{
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	weapon_gun_onDrawHUD(pl, (weapondata_gun_t*)ary_weaponData[WEAPON_ID::SOCOMMK23], arg_thisWeapon);
}

void
w_socommk23_hudpic(int selected, vector pos, float a)
{
	//
}

weapon_t w_socommk23 =
{
	
	.name		= "socommk23",
	.id			= 0,  // not using this
	.slot		= 2,  // ?
	.slot_pos	= 0,  // not using this
	.weight		= 0,  // not using this
	.draw		= w_socommk23_draw,
	.holster	= w_socommk23_holster,
	.primary	= w_socommk23_primary,
	.secondary	= w_socommk23_secondary,
	.reload		= w_socommk23_reload,
	.release	= NULL,
	.crosshair	= w_socommk23_hud,
	.precache	= w_socommk23_precache,
	.pickup		= NULL,
	.updateammo	= w_socommk23_updateammo,
	.wmodel		= w_socommk23_wmodel,
	.pmodel		= w_socommk23_pmodel,
	.deathmsg	= w_socommk23_deathmsg,
	.aimanim	= w_socommk23_aimanim,
	.hudpic		= NULL
	
};

