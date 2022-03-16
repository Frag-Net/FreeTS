
enum weaponseq_usas12{
	idle,
	reload,
	draw,
	shootsemi
};

void weapon_usas12_onPrimaryAttackRelease(player pl, weapondynamic_t arg_thisWeapon){
	
}
void weapon_usas12_onSecondaryAttackRelease(player pl, weapondynamic_t arg_thisWeapon){
	
}
void weapon_usas12_onThink(player pl, weapondynamic_t arg_thisWeapon){
	weapon_gun_onThink(pl, (weapondata_gun_t*)ary_weaponData[WEAPON_ID::USAS12], arg_thisWeapon);
}
void weapon_usas12_onColdCock(player pl, weapondynamic_t arg_thisWeapon){
}

weapondata_gun_t weapon_usas12 =
{
	WEAPONDATA_TYPEID_GUN,
	"USAS-12",
	"models/v_usas.mdl",
	"models/p_usas.mdl",
	"",
	"models/w_usas.mdl",
	"sprites/weapons/usas12.spr",
	weapon_usas12_onPrimaryAttackRelease,
	weapon_usas12_onSecondaryAttackRelease,
	weapon_usas12_onThink,
	weapon_usas12_onColdCock,
	NULL,
	weaponseq_usas12::idle,
	weaponseq_usas12::draw,
	31.0f / 30.0f,
	1/6,  //fire delay.
	7.0f,  //dmg
	TRUE,
	BITS_WEAPONOPT_LASERSIGHT | BITS_WEAPONOPT_FLASHLIGHT,
	BITS_WEAPONOPT_NONE,
	5100,
	50,
	BUYCATEGORY_SHOTGUNS,
	4,
	{0.070000, 7.000000, 0.000000},
	WEAPON_AKIMBO_UPGRADE_ID::NONE,
	BITS_FIREMODE_FULL,
	BITS_FIREMODE_FULL,
	AMMO_ID::_SHELLS,
	20,  //clip
	4096, //range
	weaponseq_usas12::reload,  //I'm a shotgun that reloads like normal guns.  ok.
	91/30,  //delay.
	-1,
	2,
	1,
	-1
};



void
w_usas12_precache(void)
{
	weapon_precache(ary_weaponData[WEAPON_ID::USAS12]);
#ifdef SERVER
	//precache_sound("weapons/usas/clipin.wav");
	//precache_sound("weapons/usas/clipout.wav");
	//precache_sound("weapons/usas/slideback.wav");
	precache_sound("weapons/usas/usas-fire.wav");
#else
	
#endif
}

void
w_usas12_updateammo(player pl)
{
}

string
w_usas12_wmodel(void)
{
	return (*ary_weaponData[WEAPON_ID::USAS12]).sWorldModelPath;
}

string
w_usas12_pmodel(player pl)
{
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	return (*ary_weaponData[WEAPON_ID::USAS12]).sPlayerModelPath;
}

string
w_usas12_deathmsg(void)
{
	return "";
}

void
w_usas12_draw(player pl)
{
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	weapondata_basic_t* basicP = ary_weaponData[WEAPON_ID::USAS12];
	
	weapon_base_onEquip(pl, basicP, arg_thisWeapon);
}


void
w_usas12_holster(player pl)
{
}


void
w_usas12_primary(player pl)
{
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];

	if (pl.w_attack_next > 0.0) {
		return;
	}
	
	if (!arg_thisWeapon.iClipLeft || WEAPON_UNDERWATER_CHECK) {
		PLAY_CLICK_SOUND
		return;
	}
	
	SoundPitched_Send(pl, SNDP_USAS12_FIRE);

	TS_Weapons_ViewAnimation(weaponseq_usas12::shootsemi, 31.0f/35.0f);

	weapon_ClientEffects(MUZZLEFLASH_ID::WEIRD, SHELLEJECT_ID::SHOTGUN);

	weapon_base_onAttack_multi(pl, ary_weaponData[WEAPON_ID::USAS12], arg_thisWeapon, 8, BITS_AKIMBOCHOICE_LEFT);
	
	weapon_base_setWholeAttackDelay(pl, (*ary_weaponData[arg_thisWeapon.weaponID]).fAttackDelay);

	if (self.flags & FL_CROUCHING){
		Animation_PlayerTop(pl, ANIM_CR_SHOOT1HAND, 0.2f);
	}else{
		Animation_PlayerTop(pl, ANIM_SHOOT1HAND, 0.2f);
	}
	
}

void
w_usas12_secondary(player pl)
{
}

void
w_usas12_reload(player pl)
{
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];

	weapon_gun_Reload(pl, (weapondata_gun_t*)ary_weaponData[WEAPON_ID::USAS12], arg_thisWeapon);
}

float
w_usas12_aimanim(player pl)
{
	return self.flags & FL_CROUCHING ? ANIM_CR_AIM1HAND : ANIM_AIM1HAND;
}

void
w_usas12_hud(player pl)
{
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	weapon_gun_onDrawHUD(pl, (weapondata_gun_t*)ary_weaponData[WEAPON_ID::USAS12], arg_thisWeapon);
}

void
w_usas12_hudpic(player pl, int selected, vector pos, float a)
{
	//
}

weapon_t w_usas12 =
{
	
	.name		= "usas12",
	.id			= 0,  // not using this
	.slot		= 2,  // ?
	.slot_pos	= 0,  // not using this
	.weight		= 0,  // not using this
	.draw		= w_usas12_draw,
	.holster	= w_usas12_holster,
	.primary	= w_usas12_primary,
	.secondary	= w_usas12_secondary,
	.reload		= w_usas12_reload,
	.release	= NULL,
	.postdraw	= w_usas12_hud,
	.precache	= w_usas12_precache,
	.pickup		= NULL,
	.updateammo	= w_usas12_updateammo,
	.wmodel		= w_usas12_wmodel,
	.pmodel		= w_usas12_pmodel,
	.deathmsg	= w_usas12_deathmsg,
	.aimanim	= w_usas12_aimanim,
	.hudpic		= NULL
	
};


