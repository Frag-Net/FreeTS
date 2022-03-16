
enum weaponseq_ragingbull{
	idle,
	shoot,
	shoot2,
	draw,
	reload
};

void weapon_ragingbull_onPrimaryAttackRelease(player pl, weapondynamic_t arg_thisWeapon){
	
}
void weapon_ragingbull_onSecondaryAttackRelease(player pl, weapondynamic_t arg_thisWeapon){
	
}
void weapon_ragingbull_onThink(player pl, weapondynamic_t arg_thisWeapon){
	weapon_gun_onThink(pl, (weapondata_gun_t*)ary_weaponData[WEAPON_ID::RAGINGBULL], arg_thisWeapon);
}
void weapon_ragingbull_onColdCock(player pl, weapondynamic_t arg_thisWeapon){
	
}
void weapon_ragingbull_onSetZoomLevel(player pl){
	switch(pl.iZoomLevel){
	case 0:pl.flZoomTarget = 1.00f;break;
	case 1:pl.flZoomTarget = 0.50f;break;
	}
}

weapondata_gun_t weapon_ragingbull =
{
	WEAPONDATA_TYPEID_GUN,
	"Raging Bull",
	"models/v_bull.mdl",
	"models/p_bull.mdl",
	"",
	"models/w_bull.mdl",
	"sprites/weapons/bull.spr",
	weapon_ragingbull_onPrimaryAttackRelease,
	weapon_ragingbull_onSecondaryAttackRelease,
	weapon_ragingbull_onThink,
	weapon_ragingbull_onColdCock,
	weapon_ragingbull_onSetZoomLevel,
	weaponseq_ragingbull::idle,
	weaponseq_ragingbull::draw,
	31.0f / 33.0f,
	0.35f,  //fire delay
	27.0f,
	TRUE,
	BITS_WEAPONOPT_LASERSIGHT | BITS_WEAPONOPT_SCOPE,
	BITS_WEAPONOPT_NONE,
	2100,
	15,
	BUYCATEGORY_HANDGUNS,
	2,
	{0.010000, 8.000000, 0.000000},
	WEAPON_AKIMBO_UPGRADE_ID::NONE,
	BITS_FIREMODE_SEMI,
	BITS_FIREMODE_SEMI,
	AMMO_ID::_P454CASULL,
	5,
	4096,
	weaponseq_ragingbull::reload,
	61.0f / 30.0f,
	-1,
	-1,
	-1,
	1
	
};



void
w_ragingbull_precache(void)
{
	weapon_precache(ary_weaponData[WEAPON_ID::RAGINGBULL]);
#ifdef SERVER
	//precache_sound("weapons/bull/cylinderin.wav");
	//precache_sound("weapons/bull/cylinderout.wav");
	precache_sound("weapons/bull/fire01.wav");
	//precache_sound("weapons/bull/hammerback.wav");
	//precache_sound("weapons/bull/insert-shell.wav");
	//precache_sound("weapons/bull/shellsout.wav");
#else
	
#endif
}

void
w_ragingbull_updateammo(player pl)
{
}

string
w_ragingbull_wmodel(void)
{
	return (*ary_weaponData[WEAPON_ID::RAGINGBULL]).sWorldModelPath;
}

string
w_ragingbull_pmodel(player pl)
{
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	return (*ary_weaponData[WEAPON_ID::RAGINGBULL]).sPlayerModelPath;
}

string
w_ragingbull_deathmsg(void)
{
	return "";
}

void
w_ragingbull_draw(player pl)
{
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	
	weapon_base_onEquip(pl, ary_weaponData[WEAPON_ID::RAGINGBULL], arg_thisWeapon);
}

void
w_ragingbull_holster(player pl)
{
}

void
w_ragingbull_primary(player pl)
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
	
	SoundPitched_Send(pl, SNDP_RAGINGBULL_FIRE);
	
	int r = (float)input_sequence % 2;
	if (r == 0) {
		TS_Weapons_ViewAnimation(pl, weaponseq_ragingbull::shoot, 31.0f/30.0f);
	} else {
		TS_Weapons_ViewAnimation(pl, weaponseq_ragingbull::shoot2, 31.0f/30.0f);
	}
	
	// no shell eject
	weapon_ShowMuzzleFlash(MUZZLEFLASH_ID::RIFLE);
	
	weapon_base_onAttack(pl, ary_weaponData[WEAPON_ID::RAGINGBULL], arg_thisWeapon, BITS_AKIMBOCHOICE_LEFT);
	
	weapon_base_setWholeAttackDelay(pl, (*ary_weaponData[arg_thisWeapon.weaponID]).fAttackDelay);

	if (self.flags & FL_CROUCHING){
		Animation_PlayerTop(pl, ANIM_CR_SHOOT1HAND, 0.2f);
	}else{
		Animation_PlayerTop(pl, ANIM_SHOOT1HAND, 0.2f);
	}
	
}

void
w_ragingbull_secondary(player pl)
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
w_ragingbull_reload(player pl)
{
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];

	weapon_gun_Reload(pl, (weapondata_gun_t*)ary_weaponData[WEAPON_ID::RAGINGBULL], arg_thisWeapon);
}

float
w_ragingbull_aimanim(player pl)
{
	return self.flags & FL_CROUCHING ? ANIM_CR_AIM1HAND : ANIM_AIM1HAND;
}

void
w_ragingbull_hud(player pl)
{
	
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	weapon_gun_onDrawHUD(pl, (weapondata_gun_t*)ary_weaponData[WEAPON_ID::RAGINGBULL], arg_thisWeapon);

}

void
w_ragingbull_hudpic(player pl, int selected, vector pos, float a)
{
	//
}

weapon_t w_ragingbull =
{
	
	.name		= "ragingbull",
	.id			= 0,  // not using this
	.slot		= 2,  // ?
	.slot_pos	= 0,  // not using this
	.weight		= 0,  // not using this
	.draw		= w_ragingbull_draw,
	.holster	= w_ragingbull_holster,
	.primary	= w_ragingbull_primary,
	.secondary	= w_ragingbull_secondary,
	.reload		= w_ragingbull_reload,
	.release	= NULL,
	.postdraw	= w_ragingbull_hud,
	.precache	= w_ragingbull_precache,
	.pickup		= NULL,
	.updateammo	= w_ragingbull_updateammo,
	.wmodel		= w_ragingbull_wmodel,
	.pmodel		= w_ragingbull_pmodel,
	.deathmsg	= w_ragingbull_deathmsg,
	.aimanim	= w_ragingbull_aimanim,
	.hudpic		= NULL
	
};

