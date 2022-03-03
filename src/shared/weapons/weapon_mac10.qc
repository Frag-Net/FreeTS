
enum weaponseq_mac10{
	idle,
	reload,
	draw,
	shoot,
	shoot2,
	shoot3,
	sshoot,
	sshoot2,
	sshoot3,
	idle2,
	change,
	rechange,
	shootb,
	shootb2,
	shootb3,
	sshootb,
	sshootb2,
	sshootb3,
	reload_2   //RENAMED. Identical sequence name in model
};

void weapon_mac10_onPrimaryAttackRelease(player pl, weapondynamic_t arg_thisWeapon){
	
}
void weapon_mac10_onSecondaryAttackRelease(player pl, weapondynamic_t arg_thisWeapon){
	
}
void weapon_mac10_onThink(player pl, weapondynamic_t arg_thisWeapon){
	weapon_gun_onThink(pl, (weapondata_gun_t*)ary_weaponData[WEAPON_ID::MAC10], arg_thisWeapon);
}
void weapon_mac10_onColdCock(player pl, weapondynamic_t arg_thisWeapon){
	
}

weapondata_ironsight_t weapon_mac10 =
{
	WEAPONDATA_TYPEID_IRONSIGHT,
	"MAC10",
	"models/v_mac10.mdl",
	"models/p_mac10.mdl",
	"models/p_mac10_sil.mdl",
	"models/w_mac10.mdl",
	"sprites/weapons/mac10.spr",
	weapon_mac10_onPrimaryAttackRelease,
	weapon_mac10_onSecondaryAttackRelease,
	weapon_mac10_onThink,
	weapon_mac10_onColdCock,
	NULL,
	weaponseq_mac10::idle,
	weaponseq_mac10::draw,
	31.0f / 30.0f,
	0.0625f,  //fire delay.
	7.0f,  //dmg
	TRUE,
	BITS_WEAPONOPT_SILENCER,
	BITS_WEAPONOPT_NONE,
	2300,
	25,
	BUYCATEGORY_SMGS,
	3,
	{0.015000, 2.550000, 0.005000},
	WEAPON_AKIMBO_UPGRADE_ID::NONE,
	BITS_FIREMODE_FULL | BITS_FIREMODE_SEMI,
	BITS_FIREMODE_FULL,
	AMMO_ID::_45ACP,
	32,  //clip
	4096, //range
	weaponseq_mac10::reload,
	87.0f / 40.0f,
	1,
	-1,
	-1,
	-1,
	{
		weaponseq_mac10::change,
		21.0f/40.0f,
		weaponseq_mac10::rechange,
		21.0f/40.0f,
		weaponseq_mac10::idle2,
		weaponseq_mac10::reload_2,
		103.0f/40.0f,
		{0.015000, 2.550000, 0.005000}
	}
};



void
w_mac10_precache(void)
{
	weapon_precache(ary_weaponData[WEAPON_ID::MAC10]);
#ifdef SERVER
	//precache_sound("weapons/mac10/clipin.wav");
	//precache_sound("weapons/mac10/clipout.wav");
	precache_sound("weapons/mac10/mac10-fire-sil.wav");
	precache_sound("weapons/mac10/mac10-fire.wav");
	//precache_sound("weapons/mac10/slideback.wav");
#else
	
#endif
}

void
w_mac10_updateammo(player pl)
{
}

string
w_mac10_wmodel(void)
{
	return (*ary_weaponData[WEAPON_ID::MAC10]).sWorldModelPath;
}

string
w_mac10_pmodel(void)
{
	// Do we have the silencer?
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	if(!(arg_thisWeapon.iBitsUpgrade & BITS_WEAPONOPT_SILENCER) ){
		return (*ary_weaponData[WEAPON_ID::MAC10]).sPlayerModelPath;
	} else {
		return (*ary_weaponData[WEAPON_ID::MAC10]).sPlayerSilencerModelPath;
	}
}

string
w_mac10_deathmsg(void)
{
	return "";
}

void
w_mac10_draw(void)
{
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	
	weapon_base_onEquip(pl, ary_weaponData[WEAPON_ID::MAC10], arg_thisWeapon);
}

void
w_mac10_holster(void)
{
}

void
w_mac10_primary(void)
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
	
	if(!(arg_thisWeapon.iBitsUpgrade & BITS_WEAPONOPT_SILENCER) ){
		SoundPitched_Send(pl, SNDP_MAC10_FIRE);
	} else {
		SoundPitched_Send(pl, SNDP_MAC10_FIRE_SIL);
	}

	int r = (float)input_sequence % 6;
	if(!arg_thisWeapon.iIronSight){
		if(r == 0){
			TS_Weapons_ViewAnimation(weaponseq_mac10::shoot, 31.0f/30.0f);
		}else if(r == 1){
			TS_Weapons_ViewAnimation(weaponseq_mac10::shoot2, 31.0f/30.0f);
		}else if(r == 2){
			TS_Weapons_ViewAnimation(weaponseq_mac10::shoot3, 31.0f/30.0f);
		}else if(r == 3){
			TS_Weapons_ViewAnimation(weaponseq_mac10::sshoot, 31.0f/30.0f);
		}else if(r == 4){
			TS_Weapons_ViewAnimation(weaponseq_mac10::sshoot2, 31.0f/30.0f);
		}else{
			TS_Weapons_ViewAnimation(weaponseq_mac10::sshoot3, 31.0f/30.0f);
		}
	}else{
		r = (float)input_sequence % 6;
		if(r == 1){
			TS_Weapons_ViewAnimation(weaponseq_mac10::shootb, 31.0f/30.0f);
		}else if(r == 2){
			TS_Weapons_ViewAnimation(weaponseq_mac10::shootb2, 31.0f/30.0f);
		}else if(r == 3){
			TS_Weapons_ViewAnimation(weaponseq_mac10::shootb3, 31.0f/30.0f);
		}else if(r == 4){
			TS_Weapons_ViewAnimation(weaponseq_mac10::sshootb, 31.0f/30.0f);
		}else if(r == 5){
			TS_Weapons_ViewAnimation(weaponseq_mac10::sshootb2, 31.0f/30.0f);
		}else{
			TS_Weapons_ViewAnimation(weaponseq_mac10::sshootb3, 31.0f/30.0f);
		}
	}

	if(!(arg_thisWeapon.iBitsUpgrade & BITS_WEAPONOPT_SILENCER) ){
		weapon_ClientEffects(MUZZLEFLASH_ID::SMALL, SHELLEJECT_ID::GENERIC);
	} else {
		weapon_EjectShell(SHELLEJECT_ID::GENERIC);
	}
	
	weapon_base_onAttack(pl, ary_weaponData[WEAPON_ID::MAC10], arg_thisWeapon, BITS_AKIMBOCHOICE_LEFT);
	
	weapon_base_setWholeAttackDelay(pl, (*ary_weaponData[arg_thisWeapon.weaponID]).fAttackDelay);

	if (self.flags & FL_CROUCHING){
		Animation_PlayerTop(pl, ANIM_CR_SHOOT1HAND, 0.2f);
	}else{
		Animation_PlayerTop(pl, ANIM_SHOOT1HAND, 0.2f);
	}
	
}

void
w_mac10_secondary(void)
{
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	
	if(pl.w_attack_next > 0){
		return;
	}
	
	INPUT_SECONDARY_TAP_GATE
	
	weapon_ironsight_ToggleIronsight(pl, (weapondata_ironsight_t*)ary_weaponData[WEAPON_ID::MAC10], arg_thisWeapon);
	
}


void
w_mac10_reload(void)
{
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];

	weapon_ironsight_Reload(pl, (weapondata_ironsight_t*)ary_weaponData[WEAPON_ID::MAC10], arg_thisWeapon);
}

float
w_mac10_aimanim(void)
{
	return self.flags & FL_CROUCHING ? ANIM_CR_AIM1HAND : ANIM_AIM1HAND;
}

void
w_mac10_hud(void)
{
	player pl = (player)self;
	
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	weapon_gun_onDrawHUD(pl, (weapondata_gun_t*)ary_weaponData[WEAPON_ID::MAC10], arg_thisWeapon);

}

void
w_mac10_hudpic(int selected, vector pos, float a)
{
	//
}

weapon_t w_mac10 =
{
	
	.name		= "mac10",
	.id			= 0,  // not using this
	.slot		= 2,  // ?
	.slot_pos	= 0,  // not using this
	.weight		= 0,  // not using this
	.draw		= w_mac10_draw,
	.holster	= w_mac10_holster,
	.primary	= w_mac10_primary,
	.secondary	= w_mac10_secondary,
	.reload		= w_mac10_reload,
	.release	= NULL,
	.crosshair	= w_mac10_hud,
	.precache	= w_mac10_precache,
	.pickup		= NULL,
	.updateammo	= w_mac10_updateammo,
	.wmodel		= w_mac10_wmodel,
	.pmodel		= w_mac10_pmodel,
	.deathmsg	= w_mac10_deathmsg,
	.aimanim	= w_mac10_aimanim,
	.hudpic		= NULL
	
};


