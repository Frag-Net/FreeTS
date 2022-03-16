
enum weaponseq_rugermk1{
	idle,
	shoot1,
	shoot2,
	draw,
	reload
};

void weapon_rugermk1_onPrimaryAttackRelease(player pl, weapondynamic_t arg_thisWeapon){
	
}
void weapon_rugermk1_onSecondaryAttackRelease(player pl, weapondynamic_t arg_thisWeapon){
	
}
void weapon_rugermk1_onThink(player pl, weapondynamic_t arg_thisWeapon){
	weapon_gun_onThink(pl, (weapondata_gun_t*)ary_weaponData[WEAPON_ID::RUGERMK1], arg_thisWeapon);
}
void weapon_rugermk1_onColdCock(player pl, weapondynamic_t arg_thisWeapon){
	
}

weapondata_gun_t weapon_rugermk1 =
{
	WEAPONDATA_TYPEID_GUN,
	"Ruger-MK1",
	"models/v_ruger.mdl",
	"models/p_ruger.mdl",
	"models/p_ruger.mdl",   //NOTICE - only ever has a silencer, so this never got a separate model (has it here)
	"models/w_ruger.mdl",
	"sprites/weapons/ruger.spr",
	weapon_rugermk1_onPrimaryAttackRelease,
	weapon_rugermk1_onSecondaryAttackRelease,
	weapon_rugermk1_onThink,
	weapon_rugermk1_onColdCock,
	NULL,
	weaponseq_rugermk1::idle,
	weaponseq_rugermk1::draw,
	31.0f / 35.0f,
	0.19f,  //fire delay
	15.0f,  //dmg
	TRUE,
	BITS_WEAPONOPT_SILENCER | BITS_WEAPONOPT_LASERSIGHT,
	BITS_WEAPONOPT_SILENCER,
	1500,
	5,
	BUYCATEGORY_HANDGUNS,
	2,
	{0.001000, 0.700000, 0.000000},
	WEAPON_AKIMBO_UPGRADE_ID::NONE,
	BITS_FIREMODE_SEMI,
	BITS_FIREMODE_SEMI,
	AMMO_ID::_P22LR,
	17,  //clip
	4096, //range
	weaponseq_rugermk1::reload,
	46.0f / 33.0f,
	-1,
	-1,
	-1,
	-1
};



void
w_rugermk1_precache(void)
{
	weapon_precache(ary_weaponData[WEAPON_ID::RUGERMK1]);
#ifdef SERVER
	//precache_sound("weapons/ruger/clipin.wav");
	//precache_sound("weapons/ruger/clipout.wav");
	precache_sound("weapons/ruger/fire.wav");
	//precache_sound("weapons/ruger/slide.wav");
#else
	
#endif
}

void
w_rugermk1_updateammo(player pl)
{
}

string
w_rugermk1_wmodel(void)
{
	return (*ary_weaponData[WEAPON_ID::RUGERMK1]).sWorldModelPath;
}

string
w_rugermk1_pmodel(player pl)
{
	// Do we have the silencer?  Yes, forced in fact
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	//if(!(arg_thisWeapon.iBitsUpgrade & BITS_WEAPONOPT_SILENCER) ){
		return (*ary_weaponData[WEAPON_ID::RUGERMK1]).sPlayerModelPath;
	//} else {
	//	return (*ary_weaponData[WEAPON_ID::RUGERMK1]).sPlayerSilencerModelPath;
	//}
}

string
w_rugermk1_deathmsg(void)
{
	return "";
}

void
w_rugermk1_draw(player pl)
{
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	
	weapon_base_onEquip(pl, ary_weaponData[WEAPON_ID::RUGERMK1], arg_thisWeapon);
}

void
w_rugermk1_holster(player pl)
{
}

void
w_rugermk1_primary(player pl)
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
	
	// silencer only!
	SoundPitched_Send(pl, SNDP_RUGERMK1_FIRE);

	int r = (float)input_sequence % 2;
	if(r == 0){
		TS_Weapons_ViewAnimation(pl, weaponseq_rugermk1::shoot1, 31.0f/35.0f);
	}else{
		TS_Weapons_ViewAnimation(pl, weaponseq_rugermk1::shoot2, 31.0f/35.0f);
	}
	
	weapon_EjectShell(SHELLEJECT_ID::GENERIC);
	
	weapon_base_onAttack(pl, ary_weaponData[WEAPON_ID::RUGERMK1], arg_thisWeapon, BITS_AKIMBOCHOICE_LEFT);
	
	weapon_base_setWholeAttackDelay(pl, (*ary_weaponData[arg_thisWeapon.weaponID]).fAttackDelay);

	if (self.flags & FL_CROUCHING){
		Animation_PlayerTop(pl, ANIM_CR_SHOOT1HAND, 0.2f);
	}else{
		Animation_PlayerTop(pl, ANIM_SHOOT1HAND, 0.2f);
	}
	
}

void
w_rugermk1_secondary(player pl)
{
}


void
w_rugermk1_reload(player pl)
{
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];

	weapon_gun_Reload(pl, (weapondata_gun_t*)ary_weaponData[WEAPON_ID::RUGERMK1], arg_thisWeapon);
}

float
w_rugermk1_aimanim(player pl)
{
	return self.flags & FL_CROUCHING ? ANIM_CR_AIM1HAND : ANIM_AIM1HAND;
}

void
w_rugermk1_hud(player pl)
{
	
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	weapon_gun_onDrawHUD(pl, (weapondata_gun_t*)ary_weaponData[WEAPON_ID::RUGERMK1], arg_thisWeapon);

}

void
w_rugermk1_hudpic(player pl, int selected, vector pos, float a)
{
	//
}

weapon_t w_rugermk1 =
{
	
	.name		= "rugermk1",
	.id			= 0,  // not using this
	.slot		= 2,  // ?
	.slot_pos	= 0,  // not using this
	.weight		= 0,  // not using this
	.draw		= w_rugermk1_draw,
	.holster	= w_rugermk1_holster,
	.primary	= w_rugermk1_primary,
	.secondary	= w_rugermk1_secondary,
	.reload		= w_rugermk1_reload,
	.release	= NULL,
	.postdraw	= w_rugermk1_hud,
	.precache	= w_rugermk1_precache,
	.pickup		= NULL,
	.updateammo	= w_rugermk1_updateammo,
	.wmodel		= w_rugermk1_wmodel,
	.pmodel		= w_rugermk1_pmodel,
	.deathmsg	= w_rugermk1_deathmsg,
	.aimanim	= w_rugermk1_aimanim,
	.hudpic		= NULL
	
};

