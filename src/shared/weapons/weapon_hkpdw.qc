
enum weaponseq_hkpdw{
	idle,
	reload,
	draw,
	shoot,
	shoot2,
	shoot3
};

void weapon_hkpdw_onPrimaryAttackRelease(player pl, weapondynamic_t arg_thisWeapon){
	
}
void weapon_hkpdw_onSecondaryAttackRelease(player pl, weapondynamic_t arg_thisWeapon){
	
}
void weapon_hkpdw_onThink(player pl, weapondynamic_t arg_thisWeapon){
	weapon_gun_onThink(pl, (weapondata_gun_t*)ary_weaponData[WEAPON_ID::HKPDW], arg_thisWeapon);	
}
void weapon_hkpdw_onColdCock(player pl, weapondynamic_t arg_thisWeapon){
	
}
void weapon_hkpdw_onSetZoomLevel(player pl){
	switch(pl.iZoomLevel){
	case 0:pl.flZoomTarget = 1.00f;break;
	case 1:pl.flZoomTarget = 0.50f;break;
	}
}

weapondata_gun_t weapon_hkpdw =
{
	WEAPONDATA_TYPEID_GUN,
	"MP7-PDW",
	"models/v_pdw.mdl",
	"models/p_pdw.mdl",
	"models/p_pdw_Sil.mdl",
	"models/w_pdw.mdl",
	"sprites/weapons/pdw.spr",
	weapon_hkpdw_onPrimaryAttackRelease,
	weapon_hkpdw_onSecondaryAttackRelease,
	weapon_hkpdw_onThink,
	weapon_hkpdw_onColdCock,
	weapon_hkpdw_onSetZoomLevel,
	weaponseq_hkpdw::idle,
	weaponseq_hkpdw::draw,
	31.0f / 30.0f,
	0.0625f,  //fire delay.
	7.0f,  //dmg
	TRUE,
	BITS_WEAPONOPT_SILENCER | BITS_WEAPONOPT_LASERSIGHT | BITS_WEAPONOPT_SCOPE,
	BITS_WEAPONOPT_NONE,
	2800,
	30,
	BUYCATEGORY_SMGS,
	3,
	{0.003000, 1.900000, 0.007500},
	WEAPON_AKIMBO_UPGRADE_ID::NONE,
	BITS_FIREMODE_FULL | BITS_FIREMODE_SEMI,
	BITS_FIREMODE_FULL,
	AMMO_ID::_5P7X28,
	40,  //clip
	4096, //range
	weaponseq_hkpdw::reload,
	81.0f / 35.0f,
	1,
	-1,
	-1,
	2
};



void
w_hkpdw_precache(void)
{
	weapon_precache(ary_weaponData[WEAPON_ID::HKPDW]);
#ifdef SERVER
	//precache_sound("weapons/pdw/clipin.wav");
	//precache_sound("weapons/pdw/clipout.wav");
	precache_sound("weapons/pdw/fire-sil.wav");
	precache_sound("weapons/pdw/fire.wav");
	//precache_sound("weapons/pdw/slideback.wav");
#else
	
#endif
}

void
w_hkpdw_updateammo(player pl)
{
}

string
w_hkpdw_wmodel(void)
{
	return (*ary_weaponData[WEAPON_ID::HKPDW]).sWorldModelPath;
}

string
w_hkpdw_pmodel(player pl)
{
	// Do we have the silencer?
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	if(!(arg_thisWeapon.iBitsUpgrade & BITS_WEAPONOPT_SILENCER) ){
		return (*ary_weaponData[WEAPON_ID::HKPDW]).sPlayerModelPath;
	} else {
		return (*ary_weaponData[WEAPON_ID::HKPDW]).sPlayerSilencerModelPath;
	}
}

string
w_hkpdw_deathmsg(void)
{
	return "";
}

void
w_hkpdw_draw(player pl)
{
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	
	weapon_base_onEquip(pl, ary_weaponData[WEAPON_ID::HKPDW], arg_thisWeapon);
}

void
w_hkpdw_holster(player pl)
{
}

void
w_hkpdw_primary(player pl)
{
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
		SoundPitched_Send(pl, SNDP_HKPDW_FIRE);
	} else {
		SoundPitched_Send(pl, SNDP_HKPDW_FIRE_SIL);
	}

	int r = (float)input_sequence % 3;
	if(r == 0){
		TS_Weapons_ViewAnimation(pl, weaponseq_hkpdw::shoot, 21.0f/30.0f);
	}else if(r == 1){
		TS_Weapons_ViewAnimation(pl, weaponseq_hkpdw::shoot2, 21.0f/30.0f);
	}else{
		TS_Weapons_ViewAnimation(pl, weaponseq_hkpdw::shoot3, 21.0f/30.0f);
	}
	
	if(!(arg_thisWeapon.iBitsUpgrade & BITS_WEAPONOPT_SILENCER) ){
		weapon_ClientEffects(MUZZLEFLASH_ID::RIFLE, SHELLEJECT_ID::_56);
	} else {
		weapon_EjectShell(SHELLEJECT_ID::_56);
	}
	
	weapon_base_onAttack(pl, ary_weaponData[WEAPON_ID::HKPDW], arg_thisWeapon, BITS_AKIMBOCHOICE_LEFT);
	
	weapon_base_setWholeAttackDelay(pl, (*ary_weaponData[arg_thisWeapon.weaponID]).fAttackDelay);

	if (self.flags & FL_CROUCHING){
		Animation_PlayerTop(pl, ANIM_CR_SHOOT1HAND, 0.2f);
	}else{
		Animation_PlayerTop(pl, ANIM_SHOOT1HAND, 0.2f);
	}
	
}

void
w_hkpdw_secondary(player pl)
{
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	
	INPUT_SECONDARY_TAP_GATE
	
	if(arg_thisWeapon.iBitsUpgrade & BITS_WEAPONOPT_SCOPE){
		// toggle through the zoom.
		int newZoomLevel = ((float)pl.iZoomLevel + 1) % 2;
		pl.setZoomLevel(newZoomLevel);
	}
	
}

void
w_hkpdw_reload(player pl)
{
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];

	weapon_gun_Reload(pl, (weapondata_gun_t*)ary_weaponData[WEAPON_ID::HKPDW], arg_thisWeapon);
}

float
w_hkpdw_aimanim(player pl)
{
	return self.flags & FL_CROUCHING ? ANIM_CR_AIM1HAND : ANIM_AIM1HAND;
}

void
w_hkpdw_hud(player pl)
{
	
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	weapon_gun_onDrawHUD(pl, (weapondata_gun_t*)ary_weaponData[WEAPON_ID::HKPDW], arg_thisWeapon);

}

void
w_hkpdw_hudpic(player pl, int selected, vector pos, float a)
{
	//
}

weapon_t w_hkpdw =
{
	
	.name		= "hkpdw",
	.id			= 0,  // not using this
	.slot		= 2,  // ?
	.slot_pos	= 0,  // not using this
	.weight		= 0,  // not using this
	.draw		= w_hkpdw_draw,
	.holster	= w_hkpdw_holster,
	.primary	= w_hkpdw_primary,
	.secondary	= w_hkpdw_secondary,
	.reload		= w_hkpdw_reload,
	.release	= NULL,
	.postdraw	= w_hkpdw_hud,
	.precache	= w_hkpdw_precache,
	.pickup		= NULL,
	.updateammo	= w_hkpdw_updateammo,
	.wmodel		= w_hkpdw_wmodel,
	.pmodel		= w_hkpdw_pmodel,
	.deathmsg	= w_hkpdw_deathmsg,
	.aimanim	= w_hkpdw_aimanim,
	.hudpic		= NULL
	
};

