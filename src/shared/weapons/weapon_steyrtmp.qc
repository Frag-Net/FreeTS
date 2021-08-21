
enum weaponseq_steyrtmp{
	idle,
	reload,
	draw,
	shoot,
	shoot2,
	change,
	rechange,
	idle2,
	shootb,
	shootb2,
	reloadb
};

void weapon_steyrtmp_onPrimaryAttackRelease(player pl, weapondynamic_t arg_thisWeapon){
	
}
void weapon_steyrtmp_onSecondaryAttackRelease(player pl, weapondynamic_t arg_thisWeapon){
	
}
void weapon_steyrtmp_onThink(player pl, weapondynamic_t arg_thisWeapon){
	weapon_gun_onThink(pl, (weapondata_gun_t*)ary_weaponData[WEAPON_ID::STEYRTMP], arg_thisWeapon);	
}
void weapon_steyrtmp_onColdCock(player pl, weapondynamic_t arg_thisWeapon){
	
}

weapondata_ironsight_t weapon_steyrtmp =
{
	WEAPONDATA_TYPEID_IRONSIGHT,
	"STEYR-TMP",
	"models/v_tmp.mdl",
	"models/p_tmp.mdl",
	"models/p_tmp_sil.mdl",
	"models/w_tmp.mdl",
	"sprites/weapons/tmp.spr",
	weapon_steyrtmp_onPrimaryAttackRelease,
	weapon_steyrtmp_onSecondaryAttackRelease,
	weapon_steyrtmp_onThink,
	weapon_steyrtmp_onColdCock,
	NULL,
	weaponseq_steyrtmp::idle,
	weaponseq_steyrtmp::draw,
	31.0f / 35.0f,
	0.0625f,  //fire delay.
	7.0f,  //dmg
	TRUE,
	BITS_WEAPONOPT_SILENCER | BITS_WEAPONOPT_LASERSIGHT,
	BITS_WEAPONOPT_NONE,
	1600,
	20,
	BUYCATEGORY_SMGS,
	3,
	{0.015000, 1.200000, 0.010000},
	WEAPON_AKIMBO_UPGRADE_ID::NONE,
	BITS_FIREMODE_FULL | BITS_FIREMODE_SEMI,
	BITS_FIREMODE_FULL,
	AMMO_ID::_9X19MM,
	30,  //clip
	4096, //range
	weaponseq_steyrtmp::reload,
	61.0f / 35.0f,
	1,
	-1,
	-1,
	-1,
	{
		weaponseq_steyrtmp::change,
		21.0f/40.0f,
		weaponseq_steyrtmp::rechange,
		21.0f/40.0f,
		weaponseq_steyrtmp::idle2,
		weaponseq_steyrtmp::reloadb,
		73.0f/35.0f,
		{0.015000, 1.200000, 0.010000}
	}
};



void
w_steyrtmp_precache(void)
{
	weapon_precache(ary_weaponData[WEAPON_ID::STEYRTMP]);
#ifdef SERVER
	//precache_sound("weapons/tmp/clipin.wav");
	//precache_sound("weapons/tmp/clipout.wav");
	precache_sound("weapons/tmp/fire-sil.wav");
	precache_sound("weapons/tmp/fire.wav");
	//precache_sound("weapons/tmp/slideback.wav");
#else
	
#endif
}

void
w_steyrtmp_updateammo(player pl)
{
}

string
w_steyrtmp_wmodel(void)
{
	return (*ary_weaponData[WEAPON_ID::STEYRTMP]).sWorldModelPath;
}

string
w_steyrtmp_pmodel(void)
{
	// Do we have the silencer?
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	if(!(arg_thisWeapon.iBitsUpgrade & BITS_WEAPONOPT_SILENCER) ){
		return (*ary_weaponData[WEAPON_ID::STEYRTMP]).sPlayerModelPath;
	} else {
		return (*ary_weaponData[WEAPON_ID::STEYRTMP]).sPlayerSilencerModelPath;
	}
}

string
w_steyrtmp_deathmsg(void)
{
	return "";
}

void
w_steyrtmp_draw(void)
{
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	
	weapon_base_onEquip(pl, ary_weaponData[WEAPON_ID::STEYRTMP], arg_thisWeapon);
}

void
w_steyrtmp_holster(void)
{
}

void
w_steyrtmp_primary(void)
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
		SoundPitched_Send(pl, SNDP_STEYRTMP_FIRE);
	} else {
		SoundPitched_Send(pl, SNDP_STEYRTMP_FIRE_SIL);
	}
	
	int r;
	if(!arg_thisWeapon.iIronSight){
		r = (float)input_sequence % 2;
		if(r == 0){
			TS_Weapons_ViewAnimation(weaponseq_steyrtmp::shoot, 31.0f/30.0f);
		}else{
			TS_Weapons_ViewAnimation(weaponseq_steyrtmp::shoot2, 31.0f/30.0f);
		}
	}else{
		r = (float)input_sequence % 2;
		if(r == 0){
			TS_Weapons_ViewAnimation(weaponseq_steyrtmp::shootb, 31.0f/30.0f);
		}else{
			TS_Weapons_ViewAnimation(weaponseq_steyrtmp::shootb2, 31.0f/30.0f);
		}
	}
	
	if(!(arg_thisWeapon.iBitsUpgrade & BITS_WEAPONOPT_SILENCER) ){
		weapon_ClientEffects(MUZZLEFLASH_ID::SMALL, SHELLEJECT_ID::_9MM);
	} else {
		weapon_EjectShell(SHELLEJECT_ID::_9MM);
	}
	
	weapon_base_onAttack(pl, ary_weaponData[WEAPON_ID::STEYRTMP], arg_thisWeapon, BITS_AKIMBOCHOICE_LEFT);
	
	weapon_base_setWholeAttackDelay(pl, (*ary_weaponData[arg_thisWeapon.weaponID]).fAttackDelay);

	if (self.flags & FL_CROUCHING){
		Animation_PlayerTop(pl, ANIM_CR_SHOOT1HAND, 0.2f);
	}else{
		Animation_PlayerTop(pl, ANIM_SHOOT1HAND, 0.2f);
	}
	
}

void
w_steyrtmp_secondary(void)
{
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	
	if(pl.w_attack_next > 0){
		return;
	}
	
	INPUT_SECONDARY_TAP_GATE
	
	weapon_ironsight_ToggleIronsight(pl, (weapondata_ironsight_t*)ary_weaponData[WEAPON_ID::STEYRTMP], arg_thisWeapon);
	
}


void
w_steyrtmp_reload(void)
{
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];

	weapon_ironsight_Reload(pl, (weapondata_ironsight_t*)ary_weaponData[WEAPON_ID::STEYRTMP], arg_thisWeapon);
}

float
w_steyrtmp_aimanim(void)
{
	return self.flags & FL_CROUCHING ? ANIM_CR_AIM1HAND : ANIM_AIM1HAND;
}

void
w_steyrtmp_hud(void)
{
	player pl = (player)self;
	
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	weapon_gun_onDrawHUD(pl, (weapondata_gun_t*)ary_weaponData[WEAPON_ID::STEYRTMP], arg_thisWeapon);

}

void
w_steyrtmp_hudpic(int selected, vector pos, float a)
{
	//
}

weapon_t w_steyrtmp =
{
	
	.name		= "steyrtmp",
	.id			= 0,  // not using this
	.slot		= 2,  // ?
	.slot_pos	= 0,  // not using this
	.weight		= 0,  // not using this
	.draw		= w_steyrtmp_draw,
	.holster	= w_steyrtmp_holster,
	.primary	= w_steyrtmp_primary,
	.secondary	= w_steyrtmp_secondary,
	.reload		= w_steyrtmp_reload,
	.release	= NULL,
	.crosshair	= w_steyrtmp_hud,
	.precache	= w_steyrtmp_precache,
	.pickup		= NULL,
	.updateammo	= w_steyrtmp_updateammo,
	.wmodel		= w_steyrtmp_wmodel,
	.pmodel		= w_steyrtmp_pmodel,
	.deathmsg	= w_steyrtmp_deathmsg,
	.aimanim	= w_steyrtmp_aimanim,
	.hudpic		= NULL
	
};


