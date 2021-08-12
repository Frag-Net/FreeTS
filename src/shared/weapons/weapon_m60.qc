
enum weaponseq_m60{
	idle,
	draw,
	shoot,
	shoot2,
	reload
};

void weapon_m60_onPrimaryAttackRelease(player pl, weapondynamic_t arg_thisWeapon){
}
void weapon_m60_onSecondaryAttackRelease(player pl, weapondynamic_t arg_thisWeapon){
}
void weapon_m60_onThink(player pl, weapondynamic_t arg_thisWeapon){
	weapon_gun_onThink(pl, (weapondata_gun_t*)ary_weaponData[WEAPON_ID::M60], arg_thisWeapon);
}
void weapon_m60_onColdCock(player pl, weapondynamic_t arg_thisWeapon){
	
}

weapondata_gun_t weapon_m60 =
{
	WEAPONDATA_TYPEID_GUN,
	"M60E3",
	"models/v_m60.mdl",
	"models/p_m60.mdl",
	"",
	"models/w_m60.mdl",
	"sprites/weapons/m60.spr",
	weapon_m60_onPrimaryAttackRelease,
	weapon_m60_onSecondaryAttackRelease,
	weapon_m60_onThink,
	weapon_m60_onColdCock,
	weaponseq_m60::idle,
	weaponseq_m60::draw,
	31.0f / 33.0f,
	0.0625f,  //fire delay.
	7.0f,  //dmg
	TRUE,
	BITS_WEAPONOPT_NONE,
	BITS_WEAPONOPT_NONE,
	8000,
	70,
	BUYCATEGORY_SPECIALPURPOSE,
	4,
	{0.005000, 1.000000, 0.015000},
	WEAPON_AKIMBO_UPGRADE_ID::NONE,
	BITS_FIREMODE_FULL,
	BITS_FIREMODE_FULL,
	AMMO_ID::_5P56NATO,
	100,  //clip
	4096, //range
	weaponseq_m60::reload,
	91.0f / 30.0f,
	-1,
	-1,
	-1,
	-1
};



void
w_m60_precache(void)
{
	weapon_precache(ary_weaponData[WEAPON_ID::M60]);
#ifdef SERVER
	//precache_sound("weapons/m60/ammo_belt.wav");
	//precache_sound("weapons/m60/boltpull.wav");
	//precache_sound("weapons/m60/close.wav");
	precache_sound("weapons/m60/m60-fire.wav");
	//precache_sound("weapons/m60/open.wav");
#else
	
#endif
}

void
w_m60_updateammo(player pl)
{
}

string
w_m60_wmodel(void)
{
	return (*ary_weaponData[WEAPON_ID::M60]).sWorldModelPath;
}

string
w_m60_pmodel(void)
{
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	return (*ary_weaponData[WEAPON_ID::M60]).sPlayerModelPath;
}

string
w_m60_deathmsg(void)
{
	return "";
}

void
w_m60_draw(void)
{
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	
	weapon_base_onEquip(pl, ary_weaponData[WEAPON_ID::M60], arg_thisWeapon);
}

void
w_m60_holster(void)
{
}

void
w_m60_primary(void)
{
	float randomChoice;
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];

	if (pl.w_attack_next > 0.0) {
		return;
	}
	
	if (!arg_thisWeapon.iClipLeft || WEAPON_UNDERWATER_CHECK) {
		PLAY_CLICK_SOUND
		return;
	}
	
		SoundPitched_Send(pl, SNDP_M60_FIRE);
	
	randomChoice = random();
	if(randomChoice < 0.5){
		TS_Weapons_ViewAnimation(weaponseq_m60::shoot, 31.0f/33.0f);
	}else{
		TS_Weapons_ViewAnimation(weaponseq_m60::shoot2, 31.0f/33.0f);
	}

	weapon_ClientEffects(MUZZLEFLASH_ID::RIFLE, SHELLEJECT_ID::_56);
	
	weapon_base_onAttack(pl, ary_weaponData[WEAPON_ID::M60], arg_thisWeapon, BITS_AKIMBOCHOICE_LEFT);
	
	weapon_base_setWholeAttackDelay(pl, (*ary_weaponData[arg_thisWeapon.weaponID]).fAttackDelay);

	if (self.flags & FL_CROUCHING){
		Animation_PlayerTop(pl, ANIM_CR_SHOOT1HAND, 0.2f);
	}else{
		Animation_PlayerTop(pl, ANIM_SHOOT1HAND, 0.2f);
	}
	
}

void
w_m60_secondary(void)
{
}


void
w_m60_reload(void)
{
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];

	weapon_gun_Reload(pl, (weapondata_gun_t*)ary_weaponData[WEAPON_ID::M60], arg_thisWeapon);
}


float
w_m60_aimanim(void)
{
	return self.flags & FL_CROUCHING ? ANIM_CR_AIM1HAND : ANIM_AIM1HAND;
}

void
w_m60_hud(void)
{
	player pl = (player)self;
	
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	weapon_gun_onDrawHUD(pl, (weapondata_gun_t*)ary_weaponData[WEAPON_ID::M60], arg_thisWeapon);

}

void
w_m60_hudpic(int selected, vector pos, float a)
{
	//
}

weapon_t w_m60 =
{
	
	.name		= "m60",
	.id			= 0,  // not using this
	.slot		= 2,  // ?
	.slot_pos	= 0,  // not using this
	.weight		= 0,  // not using this
	.draw		= w_m60_draw,
	.holster	= w_m60_holster,
	.primary	= w_m60_primary,
	.secondary	= w_m60_secondary,
	.reload		= w_m60_reload,
	.release	= NULL,
	.crosshair	= w_m60_hud,
	.precache	= w_m60_precache,
	.pickup		= NULL,
	.updateammo	= w_m60_updateammo,
	.wmodel		= w_m60_wmodel,
	.pmodel		= w_m60_pmodel,
	.deathmsg	= w_m60_deathmsg,
	.aimanim	= w_m60_aimanim,
	.hudpic		= NULL
	
};


