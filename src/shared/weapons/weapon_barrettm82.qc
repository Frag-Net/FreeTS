
enum weaponseq_barrettm82{
	idle,
	reload,
	draw,
	shoot,
	shoot2
};

void weapon_barrettm82_onPrimaryAttackRelease(player pl, weapondynamic_t arg_thisWeapon){
	
}
void weapon_barrettm82_onSecondaryAttackRelease(player pl, weapondynamic_t arg_thisWeapon){
	
}

void weapon_barrettm82_onThink(player pl, weapondynamic_t arg_thisWeapon){
	weapon_gun_onThink(pl, (weapondata_gun_t*)ary_weaponData[WEAPON_ID::BARRETTM82], arg_thisWeapon);
}
void weapon_barrettm82_onColdCock(player pl, weapondynamic_t arg_thisWeapon){
	
}
void weapon_barrettm82_onSetZoomLevel(player pl){
	switch(pl.iZoomLevel){
	case 0:pl.flZoomTarget = 1.00f;break;
	case 1:pl.flZoomTarget = 0.40f;break;
	case 2:pl.flZoomTarget = 0.10f;break;
	}
}

weapondata_gun_t weapon_barrettm82 =
{
	WEAPONDATA_TYPEID_GUN,
	"Barrett M82A1",
	"models/v_m82.mdl",
	"models/p_m82.mdl",
	"",
	"models/w_m82.mdl",
	"sprites/weapons/m82.spr",
	weapon_barrettm82_onPrimaryAttackRelease,
	weapon_barrettm82_onSecondaryAttackRelease,
	weapon_barrettm82_onThink,
	weapon_barrettm82_onColdCock,
	weapon_barrettm82_onSetZoomLevel,
	weaponseq_barrettm82::idle,
	weaponseq_barrettm82::draw,
	31.0f / 30.0f,
	0.0625f,  //fire delay.
	7.0f,  //dmg
	FALSE,
	BITS_WEAPONOPT_LASERSIGHT | BITS_WEAPONOPT_SCOPE,
	BITS_WEAPONOPT_SCOPE,
	9000,
	70,
	BUYCATEGORY_RIFLES,
	4,
	{0.001000, 10.000000, 0.100000},
	WEAPON_AKIMBO_UPGRADE_ID::NONE,
	BITS_FIREMODE_SEMI,
	BITS_FIREMODE_SEMI,
	AMMO_ID::_50BMG,
	5,  //clip
	4096, //range
	weaponseq_barrettm82::reload,
	57.0f / 30.0f,
	-1,
	-1,
	-1,
	-1
};




void
w_barrettm82_precache(void)
{
	weapon_precache(ary_weaponData[WEAPON_ID::BARRETTM82]);
#ifdef SERVER
	//precache_sound("weapons/barrett/clipin.wav");
	//precache_sound("weapons/barrett/clipout.wav");
	precache_sound("weapons/barrett/fire.wav");
	//precache_sound("weapons/barrett/slideback.wav");
#else
	
#endif
}

void
w_barrettm82_updateammo(player pl)
{
}

string
w_barrettm82_wmodel(void)
{
	return (*ary_weaponData[WEAPON_ID::BARRETTM82]).sWorldModelPath;
}

string
w_barrettm82_pmodel(player pl)
{
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	return (*ary_weaponData[WEAPON_ID::BARRETTM82]).sPlayerModelPath;
}

string
w_barrettm82_deathmsg(void)
{
	return "";
}

void
w_barrettm82_draw(player pl)
{
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	weapondata_basic_t* basicP = ary_weaponData[WEAPON_ID::BARRETTM82];
	
	weapon_base_onEquip(pl, basicP, arg_thisWeapon);
}


void
w_barrettm82_holster(player pl)
{
}


void
w_barrettm82_primary(player pl)
{
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];

	if (pl.w_attack_next > 0.0) {
		return;
	}
	
	//if(arg_thisWeapon.iFireMode == BITS_FIREMODE_SEMI){
		INPUT_PRIMARY_TAP_GATE
	//}
	
	if (!arg_thisWeapon.iClipLeft || WEAPON_UNDERWATER_CHECK) {
		PLAY_CLICK_SOUND
		return;
	}

	SoundPitched_Send(pl, SNDP_BARRETTM82_FIRE);
	
	int r = (float)input_sequence % 2;
	if(r == 0){
		TS_Weapons_ViewAnimation(pl, weaponseq_barrettm82::shoot, 31.0f/30.0f);
	}else{
		TS_Weapons_ViewAnimation(pl, weaponseq_barrettm82::shoot2, 31.0f/30.0f);
	}

	weapon_ClientEffects(MUZZLEFLASH_ID::RIFLE, SHELLEJECT_ID::_56);
	
	weapon_base_onAttack(pl, ary_weaponData[WEAPON_ID::BARRETTM82], arg_thisWeapon, BITS_AKIMBOCHOICE_LEFT);
	
	weapon_base_setWholeAttackDelay(pl, (*ary_weaponData[arg_thisWeapon.weaponID]).fAttackDelay);

	if (self.flags & FL_CROUCHING){
		Animation_PlayerTop(pl, ANIM_CR_SHOOT1HAND, 0.2f);
	}else{
		Animation_PlayerTop(pl, ANIM_SHOOT1HAND, 0.2f);
	}
	
}



void
w_barrettm82_secondary(player pl)
{
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	
	INPUT_SECONDARY_TAP_GATE
	
	if(arg_thisWeapon.iBitsUpgrade & BITS_WEAPONOPT_SCOPE){
		// toggle through the zoom.
		int newZoomLevel = ((float)pl.iZoomLevel + 1) % 3;
		pl.setZoomLevel(newZoomLevel);
	}
	
}

void
w_barrettm82_reload(player pl)
{
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];

	weapon_gun_Reload(pl, (weapondata_gun_t*)ary_weaponData[WEAPON_ID::BARRETTM82], arg_thisWeapon);
}

float
w_barrettm82_aimanim(player pl)
{
	return self.flags & FL_CROUCHING ? ANIM_CR_AIM1HAND : ANIM_AIM1HAND;
}

void
w_barrettm82_hud(player pl)
{
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	weapon_gun_onDrawHUD(pl, (weapondata_gun_t*)ary_weaponData[WEAPON_ID::BARRETTM82], arg_thisWeapon);
}

void
w_barrettm82_hudpic(player pl, int selected, vector pos, float a)
{
	//
}

weapon_t w_barrettm82 =
{
	
	.name		= "barrettm82",
	.id			= 0,  // not using this
	.slot		= 2,  // ?
	.slot_pos	= 0,  // not using this
	.weight		= 0,  // not using this
	.draw		= w_barrettm82_draw,
	.holster	= w_barrettm82_holster,
	.primary	= w_barrettm82_primary,
	.secondary	= w_barrettm82_secondary,
	.reload		= w_barrettm82_reload,
	.release	= NULL,
	.postdraw	= w_barrettm82_hud,
	.precache	= w_barrettm82_precache,
	.pickup		= NULL,
	.updateammo	= w_barrettm82_updateammo,
	.wmodel		= w_barrettm82_wmodel,
	.pmodel		= w_barrettm82_pmodel,
	.deathmsg	= w_barrettm82_deathmsg,
	.aimanim	= w_barrettm82_aimanim,
	.hudpic		= NULL
	
};

