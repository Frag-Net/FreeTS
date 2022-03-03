
enum weaponseq_ump{
	idle,
	shoot1,
	shoot2,
	shoot3,
	draw,
	reload
};

void weapon_ump_onPrimaryAttackRelease(player pl, weapondynamic_t arg_thisWeapon){
	
}
void weapon_ump_onSecondaryAttackRelease(player pl, weapondynamic_t arg_thisWeapon){
	
}
void weapon_ump_onThink(player pl, weapondynamic_t arg_thisWeapon){
	weapon_gun_onThink(pl, (weapondata_gun_t*)ary_weaponData[WEAPON_ID::UMP], arg_thisWeapon);	
}
void weapon_ump_onColdCock(player pl, weapondynamic_t arg_thisWeapon){
	
}
void weapon_ump_onSetZoomLevel(player pl){
	switch(pl.iZoomLevel){
	case 0:pl.flZoomTarget = 1.00f;break;
	case 1:pl.flZoomTarget = 0.50f;break;
	}
}

weapondata_gun_t weapon_ump =
{
	WEAPONDATA_TYPEID_GUN,
	"UMP",
	"models/v_ump.mdl",
	"models/p_ump.mdl",
	"models/p_ump_sil.mdl",
	"models/w_ump.mdl",
	"sprites/weapons/ump.spr",
	weapon_ump_onPrimaryAttackRelease,
	weapon_ump_onSecondaryAttackRelease,
	weapon_ump_onThink,
	weapon_ump_onColdCock,
	weapon_ump_onSetZoomLevel,
	weaponseq_ump::idle,
	weaponseq_ump::draw,
	26.0f / 35.0f,
	0.0625f,  //fire delay.
	7.0f,  //dmg
	TRUE,
	BITS_WEAPONOPT_SILENCER | BITS_WEAPONOPT_LASERSIGHT | BITS_WEAPONOPT_FLASHLIGHT | BITS_WEAPONOPT_SCOPE,
	BITS_WEAPONOPT_NONE,
	2300,
	25,
	BUYCATEGORY_SMGS,
	3,
	{0.015000, 2.550000, 0.005000},
	WEAPON_AKIMBO_UPGRADE_ID::NONE,
	BITS_FIREMODE_FULL | BITS_FIREMODE_SEMI,
	BITS_FIREMODE_FULL,
	AMMO_ID::_45ACP,
	25,  //clip
	4096, //range
	weaponseq_ump::reload,
	85.0f / 25.0f,
	5,
	-1,
	-1,
	4
};



void
w_ump_precache(void)
{
	weapon_precache(ary_weaponData[WEAPON_ID::UMP]);
#ifdef SERVER
	//precache_sound("weapons/ump/boltpull.wav");
	//precache_sound("weapons/ump/boltslap.wav");
	//precache_sound("weapons/ump/clipin.wav");
	//precache_sound("weapons/ump/clipout.wav");
	//precache_sound("weapons/ump/clipslap.wav");
	//precache_sound("weapons/ump/slideback.wav");
	precache_sound("weapons/ump/ump-fire-sil.wav");
	precache_sound("weapons/ump/ump-fire.wav");
#else
	
#endif
}

void
w_ump_updateammo(player pl)
{
}

string
w_ump_wmodel(void)
{
	return (*ary_weaponData[WEAPON_ID::UMP]).sWorldModelPath;
}

string
w_ump_pmodel(void)
{
	// Do we have the silencer?
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	if(!(arg_thisWeapon.iBitsUpgrade & BITS_WEAPONOPT_SILENCER) ){
		return (*ary_weaponData[WEAPON_ID::UMP]).sPlayerModelPath;
	} else {
		return (*ary_weaponData[WEAPON_ID::UMP]).sPlayerSilencerModelPath;
	}
}

string
w_ump_deathmsg(void)
{
	return "";
}

void
w_ump_draw(void)
{
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	
	weapon_base_onEquip(pl, ary_weaponData[WEAPON_ID::UMP], arg_thisWeapon);
}

void
w_ump_holster(void)
{
}

void
w_ump_primary(void)
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
		SoundPitched_Send(pl, SNDP_UMP_FIRE);
	} else {
		SoundPitched_Send(pl, SNDP_UMP_FIRE_SIL);
	}
	
	int r = (float)input_sequence % 3;
	if(r == 0){
		TS_Weapons_ViewAnimation(weaponseq_ump::shoot1, 19.0f/30.0f);
	}else if(r == 1){
		TS_Weapons_ViewAnimation(weaponseq_ump::shoot2, 19.0f/30.0f);
	}else{
		TS_Weapons_ViewAnimation(weaponseq_ump::shoot3, 19.0f/30.0f);
	}

	if(!(arg_thisWeapon.iBitsUpgrade & BITS_WEAPONOPT_SILENCER) ){
		weapon_ClientEffects(MUZZLEFLASH_ID::SMALL, SHELLEJECT_ID::GENERIC);
	} else {
		weapon_EjectShell(SHELLEJECT_ID::GENERIC);
	}
	
	weapon_base_onAttack(pl, ary_weaponData[WEAPON_ID::UMP], arg_thisWeapon, BITS_AKIMBOCHOICE_LEFT);
	
	weapon_base_setWholeAttackDelay(pl, (*ary_weaponData[arg_thisWeapon.weaponID]).fAttackDelay);

	if (self.flags & FL_CROUCHING){
		Animation_PlayerTop(pl, ANIM_CR_SHOOT1HAND, 0.2f);
	}else{
		Animation_PlayerTop(pl, ANIM_SHOOT1HAND, 0.2f);
	}
	
}

void
w_ump_secondary(void)
{
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	
	INPUT_SECONDARY_TAP_GATE
	
	if(arg_thisWeapon.iBitsUpgrade & BITS_WEAPONOPT_SCOPE){
		// toggle through the zoom.
		int newZoomLevel = ((float)pl.iZoomLevel + 1) % 2;
		pl.setZoomLevel(newZoomLevel);
	}
	
}


void
w_ump_reload(void)
{
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];

	weapon_gun_Reload(pl, (weapondata_gun_t*)ary_weaponData[WEAPON_ID::UMP], arg_thisWeapon);
}

float
w_ump_aimanim(void)
{
	return self.flags & FL_CROUCHING ? ANIM_CR_AIM1HAND : ANIM_AIM1HAND;
}

void
w_ump_hud(void)
{
	player pl = (player)self;
	
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	weapon_gun_onDrawHUD(pl, (weapondata_gun_t*)ary_weaponData[WEAPON_ID::UMP], arg_thisWeapon);

}

void
w_ump_hudpic(int selected, vector pos, float a)
{
	//
}

weapon_t w_ump =
{
	
	.name		= "ump",
	.id			= 0,  // not using this
	.slot		= 2,  // ?
	.slot_pos	= 0,  // not using this
	.weight		= 0,  // not using this
	.draw		= w_ump_draw,
	.holster	= w_ump_holster,
	.primary	= w_ump_primary,
	.secondary	= w_ump_secondary,
	.reload		= w_ump_reload,
	.release	= NULL,
	.crosshair	= w_ump_hud,
	.precache	= w_ump_precache,
	.pickup		= NULL,
	.updateammo	= w_ump_updateammo,
	.wmodel		= w_ump_wmodel,
	.pmodel		= w_ump_pmodel,
	.deathmsg	= w_ump_deathmsg,
	.aimanim	= w_ump_aimanim,
	.hudpic		= NULL
	
};

