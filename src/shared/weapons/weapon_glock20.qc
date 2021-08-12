
enum weaponseq_glock20{
	idle,
	reload,
	draw,
	shoot1,
	shoot2,
	shootempty
};

void weapon_glock20_onPrimaryAttackRelease(player pl, weapondynamic_t arg_thisWeapon){
	
}
void weapon_glock20_onSecondaryAttackRelease(player pl, weapondynamic_t arg_thisWeapon){
	
}
void weapon_glock20_onThink(player pl, weapondynamic_t arg_thisWeapon){
	weapon_gun_onThink(pl, (weapondata_gun_t*)ary_weaponData[WEAPON_ID::GLOCK20], arg_thisWeapon);
}
void weapon_glock20_onColdCock(player pl, weapondynamic_t arg_thisWeapon){
	
}

weapondata_gun_t weapon_glock20 =
{
	WEAPONDATA_TYPEID_GUN,
	"Glock-20C",
	"models/v_glock22.mdl",
	"models/p_glock22.mdl",
	"models/p_glock22_sil.mdl",
	"models/w_glock22.mdl",
	"sprites/weapons/glock22.spr",
	weapon_glock20_onPrimaryAttackRelease,
	weapon_glock20_onSecondaryAttackRelease,
	weapon_glock20_onThink,
	weapon_glock20_onColdCock,
	weaponseq_glock20::idle,
	weaponseq_glock20::draw,
	31.0f / 30.0f,
	0.19f,  //fire delay
	15.0f,  //dmg
	TRUE,
	BITS_WEAPONOPT_SILENCER | BITS_WEAPONOPT_LASERSIGHT | BITS_WEAPONOPT_FLASHLIGHT,
	BITS_WEAPONOPT_NONE,
	1300,
	10,
	BUYCATEGORY_HANDGUNS,
	2,
	{0.023000, 2.700000, 0.000000},
	WEAPON_AKIMBO_UPGRADE_ID::NONE,
	BITS_FIREMODE_SEMI,
	BITS_FIREMODE_SEMI,
	AMMO_ID::_10MMAUTO,
	15,  //clip
	4096, //range
	weaponseq_glock20::reload,
	56.0f / 28.0f,
	1,
	2,
	2,
	-1
};


void
w_glock20_precache(void)
{
	weapon_precache(ary_weaponData[WEAPON_ID::GLOCK20]);
#ifdef SERVER
	precache_sound("weapons/glock22/glock22-fire-sil.wav");
	precache_sound("weapons/glock22/glock22-fire.wav");
#else
	
#endif
}

void
w_glock20_updateammo(player pl)
{
}

string
w_glock20_wmodel(void)
{
	return (*ary_weaponData[WEAPON_ID::GLOCK20]).sWorldModelPath;
}

string
w_glock20_pmodel(void)
{
	// Do we have the silencer?
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	if(!(arg_thisWeapon.iBitsUpgrade & BITS_WEAPONOPT_SILENCER) ){
		return (*ary_weaponData[WEAPON_ID::GLOCK20]).sPlayerModelPath;
	} else {
		return (*ary_weaponData[WEAPON_ID::GLOCK20]).sPlayerSilencerModelPath;
	}
}

string
w_glock20_deathmsg(void)
{
	return "";
}

void
w_glock20_draw(void)
{
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	
	weapon_base_onEquip(pl, ary_weaponData[WEAPON_ID::GLOCK20], arg_thisWeapon);
}

void
w_glock20_holster(void)
{
}

void
w_glock20_primary(void)
{
	float randomChoice;
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
		SoundPitched_Send(pl, SNDP_GLOCK20_FIRE);
	} else {
		SoundPitched_Send(pl, SNDP_GLOCK20_FIRE_SIL);
	}

	if(arg_thisWeapon.iClipLeft > 0){
		randomChoice = random();
		if(randomChoice < 0.5){
			TS_Weapons_ViewAnimation(weaponseq_glock20::shoot1, 31.0f/30.0f);
		}else{
			TS_Weapons_ViewAnimation(weaponseq_glock20::shoot2, 31.0f/30.0f);
		}
	}else{
		// that was our last bullet?
		TS_Weapons_ViewAnimation(weaponseq_glock20::shootempty, 31.0f/30.0f);
	}

	if(!(arg_thisWeapon.iBitsUpgrade & BITS_WEAPONOPT_SILENCER) ){
		weapon_ClientEffects(MUZZLEFLASH_ID::SMALL, SHELLEJECT_ID::GENERIC);
	} else {
		weapon_EjectShell(SHELLEJECT_ID::GENERIC);
	}
	
	weapon_base_onAttack(pl, ary_weaponData[WEAPON_ID::GLOCK20], arg_thisWeapon, BITS_AKIMBOCHOICE_LEFT);
	
	weapon_base_setWholeAttackDelay(pl, (*ary_weaponData[arg_thisWeapon.weaponID]).fAttackDelay);

	if (self.flags & FL_CROUCHING){
		Animation_PlayerTop(pl, ANIM_CR_SHOOT1HAND, 0.2f);
	}else{
		Animation_PlayerTop(pl, ANIM_SHOOT1HAND, 0.2f);
	}
	
}

void
w_glock20_secondary(void)
{
}

void
w_glock20_reload(void)
{
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];

	weapon_gun_Reload(pl, (weapondata_gun_t*)ary_weaponData[WEAPON_ID::GLOCK20], arg_thisWeapon);
}

float
w_glock20_aimanim(void)
{
	return self.flags & FL_CROUCHING ? ANIM_CR_AIM1HAND : ANIM_AIM1HAND;
}

void
w_glock20_hud(void)
{
	player pl = (player)self;
	
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	weapon_gun_onDrawHUD(pl, (weapondata_gun_t*)ary_weaponData[WEAPON_ID::GLOCK20], arg_thisWeapon);

}

void
w_glock20_hudpic(int selected, vector pos, float a)
{
	//
}

weapon_t w_glock20 =
{
	
	.name		= "glock20",
	.id			= 0,  // not using this
	.slot		= 2,  // ?
	.slot_pos	= 0,  // not using this
	.weight		= 0,  // not using this
	.draw		= w_glock20_draw,
	.holster	= w_glock20_holster,
	.primary	= w_glock20_primary,
	.secondary	= w_glock20_secondary,
	.reload		= w_glock20_reload,
	.release	= NULL,
	.crosshair	= w_glock20_hud,
	.precache	= w_glock20_precache,
	.pickup		= NULL,
	.updateammo	= w_glock20_updateammo,
	.wmodel		= w_glock20_wmodel,
	.pmodel		= w_glock20_pmodel,
	.deathmsg	= w_glock20_deathmsg,
	.aimanim	= w_glock20_aimanim,
	.hudpic		= NULL
	
};

