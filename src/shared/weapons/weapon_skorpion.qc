
enum weaponseq_skorpion{
	idle,
	draw,
	reload,
	fire1,
	fire2,
	fire3,
	idlealt
};

void weapon_skorpion_onPrimaryAttackRelease(player pl, weapondynamic_t arg_thisWeapon){
	
}
void weapon_skorpion_onSecondaryAttackRelease(player pl, weapondynamic_t arg_thisWeapon){
	
}
void weapon_skorpion_onThink(player pl, weapondynamic_t arg_thisWeapon){
	weapon_gun_onThink(pl, (weapondata_gun_t*)ary_weaponData[WEAPON_ID::SKORPION], arg_thisWeapon);
}
void weapon_skorpion_onColdCock(player pl, weapondynamic_t arg_thisWeapon){
	
}

weapondata_gun_t weapon_skorpion =
{
	WEAPONDATA_TYPEID_GUN,
	"Skorpion",
	"models/v_skorpion.mdl",
	"models/p_skorpion.mdl",
	"",
	"models/w_skorpion.mdl",
	"sprites/weapons/skorpion.spr",
	weapon_skorpion_onPrimaryAttackRelease,
	weapon_skorpion_onSecondaryAttackRelease,
	weapon_skorpion_onThink,
	weapon_skorpion_onColdCock,
	NULL,
	weaponseq_skorpion::idle,
	weaponseq_skorpion::draw,
	31.0f / 30.0f,
	0.0625f,  //fire delay.
	7.0f,  //dmg
	TRUE,
	BITS_WEAPONOPT_AKIMBO,
	BITS_WEAPONOPT_NONE,
	1100,
	15,
	BUYCATEGORY_SMGS,
	3,
	//TAGGG We have to guess these,  TS 3.0 where this came form doesn't have this info stored anymore.
	{0.030000, 0.250000, 0.002500},
	WEAPON_AKIMBO_UPGRADE_ID::SKORPION,
	BITS_FIREMODE_FULL | BITS_FIREMODE_SEMI,
	BITS_FIREMODE_FULL,
	AMMO_ID::_32ACP,
	20,  //clip
	4096, //range
	weaponseq_skorpion::reload,
	31.0f / 30.0f,
	-1,
	-1,
	-1,
	-1
};



void
w_skorpion_precache(void)
{
	weapon_precache(ary_weaponData[WEAPON_ID::SKORPION]);
#ifdef SERVER
	precache_sound("weapons/skorpion/fire.wav");
#else
	
#endif
}

void
w_skorpion_updateammo(player pl)
{
}

string
w_skorpion_wmodel(void)
{
	return (*ary_weaponData[WEAPON_ID::SKORPION]).sWorldModelPath;
}

string
w_skorpion_pmodel(player pl)
{
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	return (*ary_weaponData[WEAPON_ID::SKORPION]).sPlayerModelPath;
}

string
w_skorpion_deathmsg(void)
{
	return "";
}

void
w_skorpion_draw(player pl)
{
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	weapon_base_onEquip(pl, ary_weaponData[WEAPON_ID::SKORPION], arg_thisWeapon);
}

void
w_skorpion_holster(player pl)
{
}


void
w_skorpion_primary(player pl)
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
	
	SoundPitched_Send(pl, SNDP_SKORPION_FIRE);
	
	int r = (float)input_sequence % 3;
	if(r == 0){
		TS_Weapons_ViewAnimation(pl, weaponseq_skorpion::fire1, 31.0f/30.0f);
	}else if(r == 1){
		TS_Weapons_ViewAnimation(pl, weaponseq_skorpion::fire2, 31.0f/30.0f);
	}else{
		TS_Weapons_ViewAnimation(pl, weaponseq_skorpion::fire3, 31.0f/30.0f);
	}
	
	weapon_ClientEffects(MUZZLEFLASH_ID::SMALL, SHELLEJECT_ID::GENERIC);
	
	weapon_base_onAttack(pl, ary_weaponData[WEAPON_ID::SKORPION], arg_thisWeapon, BITS_AKIMBOCHOICE_LEFT);
	
	weapon_base_setWholeAttackDelay(pl, (*ary_weaponData[arg_thisWeapon.weaponID]).fAttackDelay);

	if (self.flags & FL_CROUCHING){
		Animation_PlayerTop(pl, ANIM_CR_SHOOT1HAND, 0.2f);
	}else{
		Animation_PlayerTop(pl, ANIM_SHOOT1HAND, 0.2f);
	}
}



void
w_skorpion_secondary(player pl)
{
}


void
w_skorpion_reload(player pl)
{
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	weapon_gun_Reload(pl, (weapondata_gun_t*)ary_weaponData[WEAPON_ID::SKORPION], arg_thisWeapon);
}

float
w_skorpion_aimanim(player pl)
{
	return self.flags & FL_CROUCHING ? ANIM_CR_AIM1HAND : ANIM_AIM1HAND;
}

void
w_skorpion_hud(player pl)
{
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	weapon_gun_onDrawHUD(pl, (weapondata_gun_t*)ary_weaponData[WEAPON_ID::SKORPION], arg_thisWeapon);

}

void
w_skorpion_hudpic(player pl, int selected, vector pos, float a)
{
	//
}


weapon_t w_skorpion =
{
	
	.name		= "skorpion",
	.id			= 0,  // not using this
	.slot		= 2,  // ?
	.slot_pos	= 0,  // not using this
	.weight		= 0,  // not using this
	.draw		= w_skorpion_draw,
	.holster	= w_skorpion_holster,
	.primary	= w_skorpion_primary,
	.secondary	= w_skorpion_secondary,
	.reload		= w_skorpion_reload,
	.release	= NULL,
	.postdraw	= w_skorpion_hud,
	.precache	= w_skorpion_precache,
	.pickup		= NULL,
	.updateammo	= w_skorpion_updateammo,
	.wmodel		= w_skorpion_wmodel,
	.pmodel		= w_skorpion_pmodel,
	.deathmsg	= w_skorpion_deathmsg,
	.aimanim	= w_skorpion_aimanim,
	.hudpic		= NULL
	
};

