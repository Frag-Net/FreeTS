
enum weaponseq_steyr_tmp{
	idle,
	reload,
	draw,
	shoot,
	shoot2,
	change,
	rechange,
	idle2,
	shootb,
	shootb2,
	reloadb
};



BOOLEAN weapon_STEYR_TMP_onPrimaryAttack(player localPlayer, weapondynamic_t arg_thisWeapon, BOOLEAN hasAmmo){
	return TRUE;
}
BOOLEAN weapon_STEYR_TMP_onPrimaryAttackRelease(player localPlayer, weapondynamic_t arg_thisWeapon, BOOLEAN hasAmmo){
	return FALSE;
}
BOOLEAN weapon_STEYR_TMP_onSecondaryAttack(player localPlayer, weapondynamic_t arg_thisWeapon, BOOLEAN hasAmmo){
	return FALSE;
}
BOOLEAN weapon_STEYR_TMP_onSecondaryAttackRelease(player localPlayer, weapondynamic_t arg_thisWeapon, BOOLEAN hasAmmo){
	return FALSE;
}

void weapon_STEYR_TMP_onEquip(player localPlayer, weapondynamic_t arg_thisWeapon){
}
BOOLEAN weapon_STEYR_TMP_onUnEquip(player localPlayer, weapondynamic_t arg_thisWeapon){
	return FALSE;
}
void weapon_STEYR_TMP_onThink(player localPlayer, weapondynamic_t arg_thisWeapon){
	weapon_gun_onThink(localPlayer, (weapondata_gun_t*)ary_weaponData[WEAPON_ID::STEYR_TMP], arg_thisWeapon);	
}
void weapon_STEYR_TMP_onDrawHUD(player localPlayer, weapondynamic_t arg_thisWeapon){
}
void weapon_STEYR_TMP_onReload(player localPlayer, weapondynamic_t arg_thisWeapon){
}
void weapon_STEYR_TMP_onColdCock(player localPlayer, weapondynamic_t arg_thisWeapon){
	
}


weapondata_ironsight_t weapon_STEYR_TMP =
{
	WEAPONDATA_TYPEID_IRONSIGHT,
	"STEYR-TMP",
	"models/v_tmp.mdl",
	"models/p_tmp.mdl",
	"models/p_tmp_sil.mdl",
	"models/w_tmp.mdl",
	"sprites/weapons/tmp.spr",
	weapon_STEYR_TMP_onPrimaryAttack,
	weapon_STEYR_TMP_onPrimaryAttackRelease,
	weapon_STEYR_TMP_onSecondaryAttack,
	weapon_STEYR_TMP_onSecondaryAttackRelease,
	weapon_STEYR_TMP_onEquip,
	weapon_STEYR_TMP_onUnEquip,
	weapon_STEYR_TMP_onThink,
	weapon_STEYR_TMP_onDrawHUD,
	weapon_STEYR_TMP_onReload,
	weapon_STEYR_TMP_onColdCock,
	weaponseq_steyr_tmp::idle,
	weaponseq_steyr_tmp::draw,
	31.0f / 35.0f,
	0.0625f,  //fire delay.
	7.0f,  //dmg
	TRUE,
	BITS_WEAPONOPT_SILENCER | BITS_WEAPONOPT_LASERSIGHT,
	BITS_WEAPONOPT_NONE,
	1600,
	20,
	BUYCATEGORY_SMGS,
	3,
	{0.015000, 1.200000, 0.010000},
	WEAPON_AKIMBO_UPGRADE_ID::NONE,
	BITS_FIREMODE_FULL | BITS_FIREMODE_SEMI,
	BITS_FIREMODE_FULL,
	AMMO_ID::_9x19mm,
	30,  //clip
	4096, //range
	weaponseq_steyr_tmp::reload,
	61.0f / 35.0f,
	1,
	-1,
	-1,
	-1,
	{
		weaponseq_steyr_tmp::change,
		21.0f/40.0f,
		weaponseq_steyr_tmp::rechange,
		21.0f/40.0f,
		weaponseq_steyr_tmp::idle2,
		weaponseq_steyr_tmp::reloadb,
		73.0f/35.0f,
		{0.015000, 1.200000, 0.010000}
	}
};






void
w_steyr_tmp_precache(void)
{
#ifdef SERVER
	//Sound_Precache("weapon_glock.fire");
	//precache_model("models/w_9mmhandgun.mdl");
	//precache_model("models/shell.mdl");
#else
	//precache_model("models/v_9mmhandgun.mdl");
	//precache_model("models/p_9mmhandgun.mdl");
	//precache_model("models/shell.mdl");
	//Sound_Precache("modelevent_shell.land");
#endif
}

// I guess?  I don't know if we really benefit from doing this.
void
w_steyr_tmp_updateammo(player pl)
{
	//weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	//Weapons_UpdateAmmo(pl, arg_thisWeapon.iClipLeft, pl.ary_ammoTotal[AMMO_ID::_9x19mm], -1);
}

string
w_steyr_tmp_wmodel(void)
{
	return (*ary_weaponData[WEAPON_ID::STEYR_TMP]).sWorldModelPath;
}

string
w_steyr_tmp_pmodel(void)
{
	// Do we have the silencer?
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	if(!(arg_thisWeapon.iBitsUpgrade & BITS_WEAPONOPT_SILENCER) ){
		return (*ary_weaponData[WEAPON_ID::STEYR_TMP]).sPlayerModelPath;
	} else {
		return (*ary_weaponData[WEAPON_ID::STEYR_TMP]).sPlayerSilencerModelPath;
	}
}

string
w_steyr_tmp_deathmsg(void)
{
	return "";
}

void
w_steyr_tmp_draw(void)
{
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	
	weapon_base_onEquip(pl, ary_weaponData[WEAPON_ID::STEYR_TMP], arg_thisWeapon);
}

void
w_steyr_tmp_holster(void)
{
}

void
w_steyr_tmp_primary(void)
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
		TS_Weapons_PlaySoundDirect(pl, "weapons/tmp/fire.wav");
	} else {
		TS_Weapons_PlaySoundDirect(pl, "weapons/tmp/fire-sil.wav");
	}
	
	if(!arg_thisWeapon.iIronSight){
		randomChoice = random();
		if(randomChoice < 1/2){
			TS_Weapons_ViewAnimation(weaponseq_steyr_tmp::shoot, 31.0f/30.0f);
		}else{
			TS_Weapons_ViewAnimation(weaponseq_steyr_tmp::shoot2, 31.0f/30.0f);
		}
	}else{
		randomChoice = random();
		if(randomChoice < 1/2){
			TS_Weapons_ViewAnimation(weaponseq_steyr_tmp::shootb, 31.0f/30.0f);
		}else{
			TS_Weapons_ViewAnimation(weaponseq_steyr_tmp::shootb2, 31.0f/30.0f);
		}
	}
	
#ifdef CLIENT
	View_ShowMuzzleflash(MUZZLE_SMALL);
	View_AddEvent(w_ejectshell_pistol, 0.0f);
#endif
	
	weapon_base_onAttack(pl, ary_weaponData[WEAPON_ID::STEYR_TMP], arg_thisWeapon, BITS_AKIMBOCHOICE_LEFT);
	
	weapon_base_setWholeAttackDelay(pl, (*ary_weaponData[arg_thisWeapon.weaponID]).fAttackDelay);

	if (self.flags & FL_CROUCHING){
		Animation_PlayerTop(pl, ANIM_CR_SHOOT1HAND, 0.2f);
	}else{
		Animation_PlayerTop(pl, ANIM_SHOOT1HAND, 0.2f);
	}
	
}

void
w_steyr_tmp_secondary(void)
{
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	
	if(pl.w_attack_next > 0){
		return;
	}
	
	INPUT_SECONDARY_TAP_GATE
	
	weapon_ironsight_ToggleIronsight(pl, (weapondata_ironsight_t*)ary_weaponData[WEAPON_ID::STEYR_TMP], arg_thisWeapon);
	
}


void
w_steyr_tmp_reload(void)
{
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];

	weapon_ironsight_Reload(pl, (weapondata_ironsight_t*)ary_weaponData[WEAPON_ID::STEYR_TMP], arg_thisWeapon);
}


// ???
float
w_steyr_tmp_aimanim(void)
{
	return self.flags & FL_CROUCHING ? ANIM_CR_AIM1HAND : ANIM_AIM1HAND;
}

void
w_steyr_tmp_hud(void)
{
	player pl = (player)self;
	
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	weapon_gun_onDrawHUD(pl, (weapondata_gun_t*)ary_weaponData[WEAPON_ID::STEYR_TMP], arg_thisWeapon);

}

// NOPE!  Handled by the buysidemenu, could make this give the instructions for drawing the button
// with the icon if really wanted
void
w_steyr_tmp_hudpic(int selected, vector pos, float a)
{
	//
}

weapon_t w_steyr_tmp =
{
	
	.name		= "steyr_tmp",
	.id			= 0,  // not using this
	.slot		= 2,  // ?
	.slot_pos	= 0,  // not using this
	.weight		= 0,  // not using this
	.draw		= w_steyr_tmp_draw,
	.holster	= w_steyr_tmp_holster,
	.primary	= w_steyr_tmp_primary,
	.secondary	= w_steyr_tmp_secondary,
	.reload		= w_steyr_tmp_reload,
	.release	= NULL,
	.crosshair	= w_steyr_tmp_hud,
	.precache	= w_steyr_tmp_precache,
	.pickup		= NULL,
	.updateammo	= w_steyr_tmp_updateammo,
	.wmodel		= w_steyr_tmp_wmodel,
	.pmodel		= w_steyr_tmp_pmodel,
	.deathmsg	= w_steyr_tmp_deathmsg,
	.aimanim	= w_steyr_tmp_aimanim,
	.hudpic		= NULL
	
};


