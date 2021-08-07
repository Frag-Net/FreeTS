
enum weaponseq_glock18{
	idle = 0,
	reload = 1,
	draw = 2,
	shoot1 = 3,
	shoot2 = 4,
	shootempty = 5
};

void weapon_glock18_onPrimaryAttackRelease(player pl, weapondynamic_t arg_thisWeapon){
	return FALSE;
}
void weapon_glock18_onSecondaryAttackRelease(player pl, weapondynamic_t arg_thisWeapon){
	return FALSE;
}
void weapon_glock18_onThink(player pl, weapondynamic_t arg_thisWeapon){
	weapon_gun_onThink(pl, (weapondata_gun_t*)ary_weaponData[WEAPON_ID::GLOCK18], arg_thisWeapon);
}
void weapon_glock18_onColdCock(player pl, weapondynamic_t arg_thisWeapon){
	
}

weapondata_gun_t weapon_glock18 =
{
	WEAPONDATA_TYPEID_GUN,
	"Glock-18",
	"models/v_glock18.mdl",
	"models/p_glock18.mdl",
	"models/p_glock18_sil.mdl",
	"models/w_glock18.mdl",
	"sprites/weapons/glock18.spr",
	weapon_glock18_onPrimaryAttackRelease,
	weapon_glock18_onSecondaryAttackRelease,
	weapon_glock18_onThink,
	weapon_glock18_onColdCock,
	weaponseq_glock18::idle,
	weaponseq_glock18::draw,
	31.0f / 30.0f,
	0.06,  //fire delay.
	10.0f,
	TRUE,
	BITS_WEAPONOPT_SILENCER | BITS_WEAPONOPT_LASERSIGHT | BITS_WEAPONOPT_FLASHLIGHT,
	BITS_WEAPONOPT_NONE,
	850,
	10,
	BUYCATEGORY_HANDGUNS,
	2,
	{0.022000, 1.500000, 0.007000},
	//{0.02000, 0, 0.500000},
	WEAPON_AKIMBO_UPGRADE_ID::NONE,
	BITS_FIREMODE_SEMI | BITS_FIREMODE_FULL,
	BITS_FIREMODE_FULL,
	AMMO_ID::_9X19MM,
	17,
	4096,
	weaponseq_glock18::reload,
	54.0f / 26.0f,
	1,
	2,
	2,
	-1
};



// WEAPON_GLOCK -> WEAPON_ID::GLOCK18
// .glockmag -> .ary_ammoTotal[AMMO_ID::_9x19mm]


void
w_glock18_precache(void)
{
	weapon_precache(ary_weaponData[WEAPON_ID::GLOCK18]);
#ifdef SERVER
	//precache_sound("weapons/glock/clipin.wav");
	//precache_sound("weapons/glock/clipout.wav");
	precache_sound("weapons/glock/glock-fire-sil.wav");
	precache_sound("weapons/glock/glock-fire.wav");
	//precache_sound("weapons/glock/slideback.wav");
#else
	
#endif
}

// Should FreeTS even use updateammo?  Example of how to use it if so:
void
w_glock18_updateammo(player pl)
{
	// FreeHL's way for reference:
	//Weapons_UpdateAmmo(pl, pl.glock_mag, pl.ammo_9mm, -1);
	// FreeTS way to use weapondata stats to make that call:
	//weapon_gun_updateAmmo(pl, WEAPON_ID::GLOCK18);
}

string
w_glock18_wmodel(void)
{
	return (*ary_weaponData[WEAPON_ID::GLOCK18]).sWorldModelPath;
}

string
w_glock18_pmodel(void)
{
	// Do we have the silencer?
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	if(!(arg_thisWeapon.iBitsUpgrade & BITS_WEAPONOPT_SILENCER) ){
		return (*ary_weaponData[WEAPON_ID::GLOCK18]).sPlayerModelPath;
	} else {
		return (*ary_weaponData[WEAPON_ID::GLOCK18]).sPlayerSilencerModelPath;
	}
}

string
w_glock18_deathmsg(void)
{
	return "";
}


void
w_glock18_draw(void)
{
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	
	weapon_base_onEquip(pl, ary_weaponData[WEAPON_ID::GLOCK18], arg_thisWeapon);
}

void
w_glock18_holster(void)
{

}


void
w_glock18_primary(void)
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
	
	//TAGGG - TODO - make sndshd files to contain lists for these instead.
	if(!(arg_thisWeapon.iBitsUpgrade & BITS_WEAPONOPT_SILENCER) ){
		SoundPitched_Send(pl, SNDP_GLOCK18_FIRE);
	} else {
		SoundPitched_Send(pl, SNDP_GLOCK18_FIRE_SIL);
	}
	
	if(arg_thisWeapon.iClipLeft > 1){
		// more than 1 bullet left? Typical
		if ( random() <= 0.5 ) {
			TS_Weapons_ViewAnimation(weaponseq_glock18::shoot1, (31.0f/30.0f));
		} else {
			TS_Weapons_ViewAnimation(weaponseq_glock18::shoot2, (31.0f/30.0f));
		}
	}else{
		// Only 1 left?  Assume it's about to be gone
		TS_Weapons_ViewAnimation(weaponseq_glock18::shootempty, (31.0f/30.0f) );
	}
	
	
#ifdef CLIENT
	View_ShowMuzzleflash(MUZZLE_SMALL);
	// Why even be an event?  Sometimes it happens, sometimes it doesn't?
	// shell ejection can happen instantly in the weapon_base_onAttack call
	// further down anyway
	View_AddEvent(w_ejectshell_pistol, 0.0f);
#endif
	
	weapon_base_onAttack(pl, ary_weaponData[WEAPON_ID::GLOCK18], arg_thisWeapon, BITS_AKIMBOCHOICE_LEFT);
	
	// nothing too special for that.
	weapon_base_setWholeAttackDelay(pl, (*ary_weaponData[arg_thisWeapon.weaponID]).fAttackDelay);

	if (self.flags & FL_CROUCHING){
		Animation_PlayerTop(pl, ANIM_CR_SHOOT1HAND, 0.2f);
	}else{
		Animation_PlayerTop(pl, ANIM_SHOOT1HAND, 0.2f);
	}
	
}


void
w_glock18_reload(void)
{
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];

	weapon_gun_Reload(pl, (weapondata_gun_t*)ary_weaponData[WEAPON_ID::GLOCK18], arg_thisWeapon);

}



// ???
float
w_glock18_aimanim(void)
{
	return self.flags & FL_CROUCHING ? ANIM_CR_AIM1HAND : ANIM_AIM1HAND;
}


void
w_glock18_hud(void)
{
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	weapon_gun_onDrawHUD(pl, (weapondata_gun_t*)ary_weaponData[WEAPON_ID::GLOCK18], arg_thisWeapon);

}

// NOPE! Handled by the BuyMenu, could make this give the instructions for drawing the
// button with the icon if really wanted
void
w_glock18_hudpic(int selected, vector pos, float a)
{
	//
}


weapon_t w_glock18 =
{
	
	.name		= "glock18",
	.id			= 0,  // not using this
	.slot		= 2,  // ?
	.slot_pos	= 0,  // not using this
	.weight		= 0,  // not using this
	.draw		= w_glock18_draw,
	.holster	= w_glock18_holster,
	.primary	= w_glock18_primary,
	.secondary	= NULL,
	.reload		= w_glock18_reload,
	.release	= NULL,
	.crosshair	= w_glock18_hud,
	.precache	= w_glock18_precache,
	.pickup		= NULL,
	.updateammo	= w_glock18_updateammo,
	.wmodel		= w_glock18_wmodel,
	.pmodel		= w_glock18_pmodel,
	.deathmsg	= w_glock18_deathmsg,
	.aimanim	= w_glock18_aimanim,
	.hudpic		= NULL
	
};

