
//TODO - is "stock" a melee attack??
enum weaponseq_contenderg2{
	idle,
	draw,
	reload,
	shoot1,
	shoot2,
	stock
};

void weapon_contenderg2_onPrimaryAttackRelease(player pl, weapondynamic_t arg_thisWeapon){
	
}
void weapon_contenderg2_onSecondaryAttackRelease(player pl, weapondynamic_t arg_thisWeapon){
	
}
void weapon_contenderg2_onThink(player pl, weapondynamic_t arg_thisWeapon){
	weapon_gun_onThink(pl, (weapondata_gun_t*)ary_weaponData[WEAPON_ID::CONTENDERG2], arg_thisWeapon);
}
void weapon_contenderg2_onColdCock(player pl, weapondynamic_t arg_thisWeapon){
}

weapondata_gun_t weapon_contenderg2 =
{
	WEAPONDATA_TYPEID_GUN,
	"Contender G2",
	"models/v_contender.mdl",
	"models/p_contender.mdl",
	"",
	"models/w_contender.mdl",
	"sprites/weapons/contender.spr",
	weapon_contenderg2_onPrimaryAttackRelease,
	weapon_contenderg2_onSecondaryAttackRelease,
	weapon_contenderg2_onThink,
	weapon_contenderg2_onColdCock,
	weaponseq_contenderg2::idle,
	weaponseq_contenderg2::draw,
	31.0f / 30.0f,
	0.35f,  //fire delay
	60.0f,
	TRUE,
	BITS_WEAPONOPT_LASERSIGHT | BITS_WEAPONOPT_SCOPE,
	BITS_WEAPONOPT_NONE,
	1500,
	15,
	BUYCATEGORY_HANDGUNS,
	2,
	
	{0.001000, 12.000000, 0.000000},
	
	WEAPON_AKIMBO_UPGRADE_ID::NONE,
	BITS_FIREMODE_SEMI,
	BITS_FIREMODE_SEMI,
	
	AMMO_ID::_7P62X51MM,
	1,
	
	4096,
	weaponseq_contenderg2::reload,
	61.0f / 35.0f,
	-1,
	1,
	-1,
	2
	
};



void
w_contenderg2_precache(void)
{
	weapon_precache(ary_weaponData[WEAPON_ID::CONTENDERG2]);
#ifdef SERVER
	//precache_sound("weapons/contender/close.wav");
	precache_sound("weapons/contender/fire.wav");
	//precache_sound("weapons/contender/hammerback.wav");
	//precache_sound("weapons/contender/insert-shell.wav");
	//precache_sound("weapons/contender/open.wav");
	//precache_sound("weapons/contender/shellout.wav");
#else
	
#endif
}

void
w_contenderg2_updateammo(player pl)
{
}

string
w_contenderg2_wmodel(void)
{
	return (*ary_weaponData[WEAPON_ID::CONTENDERG2]).sWorldModelPath;
}

string
w_contenderg2_pmodel(void)
{
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	return (*ary_weaponData[WEAPON_ID::CONTENDERG2]).sPlayerModelPath;
}

string
w_contenderg2_deathmsg(void)
{
	return "";
}

void
w_contenderg2_draw(void)
{
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	weapon_base_onEquip(pl, ary_weaponData[WEAPON_ID::CONTENDERG2], arg_thisWeapon);
}

void
w_contenderg2_holster(void)
{
}

void
w_contenderg2_primary(void)
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
	
	SoundPitched_Send(pl, SNDP_CONTENDERG2_FIRE);
	
	int r = (float)input_sequence % 2;
	if (r == 0) {
		TS_Weapons_ViewAnimation(weaponseq_contenderg2::shoot1, 31.0f/30.0f);
	} else {
		TS_Weapons_ViewAnimation(weaponseq_contenderg2::shoot2, 31.0f/30.0f);
	}
	
	// guessing a shell-eject doesn't happen, could be wrong.
	//weapon_ClientEffects(MUZZLEFLASH_ID::RIFLE, SHELLEJECT_ID::_56);
	weapon_ShowMuzzleFlash(MUZZLEFLASH_ID::RIFLE);
	
	weapon_base_onAttack(pl, ary_weaponData[WEAPON_ID::CONTENDERG2], arg_thisWeapon, BITS_AKIMBOCHOICE_LEFT);
	
	weapon_base_setWholeAttackDelay(pl, (*ary_weaponData[arg_thisWeapon.weaponID]).fAttackDelay);

	if (self.flags & FL_CROUCHING){
		Animation_PlayerTop(pl, ANIM_CR_SHOOT1HAND, 0.2f);
	}else{
		Animation_PlayerTop(pl, ANIM_SHOOT1HAND, 0.2f);
	}
	
}

void
w_contenderg2_secondary(void)
{
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	
	INPUT_SECONDARY_TAP_GATE
	
	if(arg_thisWeapon.iBitsUpgrade & BITS_WEAPONOPT_SCOPE){
		// toggle through the zoom.
		pl.iZoomLevel = (pl.iZoomLevel + 1) % 2;
		switch(pl.iZoomLevel){
		case 0:pl.setZoom(1.00f);break;
		case 1:pl.setZoom(0.325f);break;
		}
	}
	
}

void
w_contenderg2_reload(void)
{
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];

	weapon_gun_Reload(pl, (weapondata_gun_t*)ary_weaponData[WEAPON_ID::CONTENDERG2], arg_thisWeapon);
}

float
w_contenderg2_aimanim(void)
{
	return self.flags & FL_CROUCHING ? ANIM_CR_AIM1HAND : ANIM_AIM1HAND;
}

void
w_contenderg2_hud(void)
{
	player pl = (player)self;
	
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	weapon_gun_onDrawHUD(pl, (weapondata_gun_t*)ary_weaponData[WEAPON_ID::CONTENDERG2], arg_thisWeapon);
}

void
w_contenderg2_hudpic(int selected, vector pos, float a)
{
	//
}

weapon_t w_contenderg2 =
{
	
	.name		= "contenderg2",
	.id			= 0,  // not using this
	.slot		= 2,  // ?
	.slot_pos	= 0,  // not using this
	.weight		= 0,  // not using this
	.draw		= w_contenderg2_draw,
	.holster	= w_contenderg2_holster,
	.primary	= w_contenderg2_primary,
	.secondary	= w_contenderg2_secondary,
	.reload		= w_contenderg2_reload,
	.release	= NULL,
	.crosshair	= w_contenderg2_hud,
	.precache	= w_contenderg2_precache,
	.pickup		= NULL,
	.updateammo	= w_contenderg2_updateammo,
	.wmodel		= w_contenderg2_wmodel,
	.pmodel		= w_contenderg2_pmodel,
	.deathmsg	= w_contenderg2_deathmsg,
	.aimanim	= w_contenderg2_aimanim,
	.hudpic		= NULL
	
};

