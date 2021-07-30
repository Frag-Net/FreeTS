
enum weaponseq_socom_mk23{
	idleb = 0,
	shootb1 = 1,
	shootb2 = 2,
	shootblast = 3,
	drawb = 4,
	idlec = 5,
	shootc1 = 6,
	shootc2 = 7,
	shootclast = 8,
	change = 9,
	rechange = 10,
	reload = 11,
	reloadb = 12
};



BOOLEAN weapon_SOCOM_MK23_onPrimaryAttack(player localPlayer, weapondynamic_t arg_thisWeapon, BOOLEAN hasAmmo){
	return TRUE;
}
BOOLEAN weapon_SOCOM_MK23_onPrimaryAttackRelease(player localPlayer, weapondynamic_t arg_thisWeapon, BOOLEAN hasAmmo){
	return FALSE;
}
BOOLEAN weapon_SOCOM_MK23_onSecondaryAttack(player localPlayer, weapondynamic_t arg_thisWeapon, BOOLEAN hasAmmo){
	return FALSE;
}
BOOLEAN weapon_SOCOM_MK23_onSecondaryAttackRelease(player localPlayer, weapondynamic_t arg_thisWeapon, BOOLEAN hasAmmo){
	return FALSE;
}

void weapon_SOCOM_MK23_onEquip(player localPlayer, weapondynamic_t arg_thisWeapon){
	
	weapon_base_onEquip(localPlayer, ary_weaponData[WEAPON_ID::SOCOM_MK23], arg_thisWeapon);
}
BOOLEAN weapon_SOCOM_MK23_onUnEquip(player localPlayer, weapondynamic_t arg_thisWeapon){
	return FALSE;
}
void weapon_SOCOM_MK23_onThink(player localPlayer, weapondynamic_t arg_thisWeapon){
	weapon_gun_onThink(localPlayer, (weapondata_gun_t*)ary_weaponData[WEAPON_ID::SOCOM_MK23], arg_thisWeapon);
}
void weapon_SOCOM_MK23_onDrawHUD(player localPlayer, weapondynamic_t arg_thisWeapon){
}
void weapon_SOCOM_MK23_onReload(player localPlayer, weapondynamic_t arg_thisWeapon){
}
void weapon_SOCOM_MK23_onColdCock(player localPlayer, weapondynamic_t arg_thisWeapon){
	
}


	
weapondata_ironsight_t weapon_SOCOM_MK23 =
{
	WEAPONDATA_TYPEID_IRONSIGHT,
	"SOCOM-MK23",
	"models/v_mk23.mdl",
	"models/p_mk23.mdl",
	"models/p_mk23_sil.mdl",
	"models/w_mk23.mdl",
	"sprites/weapons/mk23.spr",
	weapon_SOCOM_MK23_onPrimaryAttack,
	weapon_SOCOM_MK23_onPrimaryAttackRelease,
	weapon_SOCOM_MK23_onSecondaryAttack,
	weapon_SOCOM_MK23_onSecondaryAttackRelease,
	weapon_SOCOM_MK23_onEquip,
	weapon_SOCOM_MK23_onUnEquip,
	weapon_SOCOM_MK23_onThink,
	weapon_SOCOM_MK23_onDrawHUD,
	weapon_SOCOM_MK23_onReload,
	weapon_SOCOM_MK23_onColdCock,
	weaponseq_socom_mk23::idleb,
	weaponseq_socom_mk23::drawb,
	31.0f / 40.0f,
	0.19f,  //fire delay. this is most certainly wrong. find something more accurate later.
	15.0f,  //dmg
	TRUE,
	BITS_WEAPONOPT_SILENCER | BITS_WEAPONOPT_LASERSIGHT | BITS_WEAPONOPT_FLASHLIGHT | BITS_WEAPONOPT_AKIMBO,
	BITS_WEAPONOPT_NONE,
	700,
	10,
	BUYCATEGORY_HANDGUNS,
	2,
	{0.020000, 2.000000, 0.000000},
	WEAPON_AKIMBO_UPGRADE_ID::SOCOM_MK23,
	BITS_FIREMODE_SEMI,
	BITS_FIREMODE_SEMI,
	AMMO_ID::_45Acp,
	12,  //clip
	4096, //range
	weaponseq_socom_mk23::reload,
	45.0f / 30.0f,
	1,
	2,
	2,
	-1,
	{
		weaponseq_socom_mk23::change,
		21.0f/60.0f,
		weaponseq_socom_mk23::rechange,
		21.0f/60.0f,
		weaponseq_socom_mk23::idlec,
		weaponseq_socom_mk23::reloadb,
		43.0f/30.0f,
		{0.020000, 2.000000, 0.000000}
	}
};




void
w_socom_mk23_precache(void)
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
w_socom_mk23_updateammo(player pl)
{
	//weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	//Weapons_UpdateAmmo(pl, arg_thisWeapon.iClipLeft, pl.ary_ammoTotal[AMMO_ID::_9x19mm], -1);
}

string
w_socom_mk23_wmodel(void)
{
	return (*ary_weaponData[WEAPON_ID::SOCOM_MK23]).sWorldModelPath;
}

string
w_socom_mk23_pmodel(void)
{
	// Do we have the silencer?
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	if(!(arg_thisWeapon.iBitsUpgrade & BITS_WEAPONOPT_SILENCER) ){
		return (*ary_weaponData[WEAPON_ID::SOCOM_MK23]).sPlayerModelPath;
	} else {
		return (*ary_weaponData[WEAPON_ID::SOCOM_MK23]).sPlayerSilencerModelPath;
	}
}

string
w_socom_mk23_deathmsg(void)
{
	return "";
}

void
w_socom_mk23_draw(void)
{
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	weapondata_basic_t* basicP = ary_weaponData[WEAPON_ID::SOCOM_MK23];
	
	weapon_base_onEquip(pl, basicP, arg_thisWeapon);
}


void
w_socom_mk23_holster(void)
{
}


void
w_socom_mk23_primary(void)
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
		TS_Weapons_PlaySoundDirect(pl, "weapons/mk23/mk23-fire.wav");
	} else {
		TS_Weapons_PlaySoundDirect(pl, "weapons/mk23/mk23-fire-sil.wav");
	}

	if(!arg_thisWeapon.iIronSight){
		if ( random() <= 0.5 ) {
			TS_Weapons_ViewAnimation(weaponseq_socom_mk23::shootb1, (31.0f/30.0f));
		} else {
			TS_Weapons_ViewAnimation(weaponseq_socom_mk23::shootb2, (31.0f/30.0f));
		}
	}else{
		if ( random() <= 0.5 ) {
			TS_Weapons_ViewAnimation(weaponseq_socom_mk23::shootc1, (31.0f/30.0f));
		} else {
			TS_Weapons_ViewAnimation(weaponseq_socom_mk23::shootc2, (31.0f/30.0f));
		}
	}
	
#ifdef CLIENT
	View_ShowMuzzleflash(MUZZLE_SMALL);
	View_AddEvent(w_ejectshell_pistol, 0.0f);
#endif

	
	weapon_base_onAttack(pl, ary_weaponData[WEAPON_ID::SOCOM_MK23], arg_thisWeapon, BITS_AKIMBOCHOICE_LEFT);
	
	weapon_base_setWholeAttackDelay(pl, (*ary_weaponData[arg_thisWeapon.weaponID]).fAttackDelay);

	if (self.flags & FL_CROUCHING){
		Animation_PlayerTop(pl, ANIM_CR_SHOOT1HAND, 0.2f);
	}else{
		Animation_PlayerTop(pl, ANIM_SHOOT1HAND, 0.2f);
	}
	
}



void
w_socom_mk23_secondary(void)
{
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	
	if(pl.w_attack_next > 0){
		return;
	}
	
	INPUT_SECONDARY_TAP_GATE
	
	weapon_ironsight_ToggleIronsight(pl, (weapondata_ironsight_t*)ary_weaponData[WEAPON_ID::SOCOM_MK23], arg_thisWeapon);
}



void
w_socom_mk23_reload(void)
{
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];

	weapon_ironsight_Reload(pl, (weapondata_ironsight_t*)ary_weaponData[WEAPON_ID::SOCOM_MK23], arg_thisWeapon);
}

// ???
float
w_socom_mk23_aimanim(void)
{
	return self.flags & FL_CROUCHING ? ANIM_CR_AIM1HAND : ANIM_AIM1HAND;
}

void
w_socom_mk23_hud(void)
{
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	weapon_gun_onDrawHUD(pl, (weapondata_gun_t*)ary_weaponData[WEAPON_ID::SOCOM_MK23], arg_thisWeapon);
}

// NOPE!  Handled by the buysidemenu, could make this give the instructions for drawing the button
// with the icon if really wanted
void
w_socom_mk23_hudpic(int selected, vector pos, float a)
{
	//
}

weapon_t w_socom_mk23 =
{
	
	.name		= "socom_mk23",
	.id			= 0,  // not using this
	.slot		= 2,  // ?
	.slot_pos	= 0,  // not using this
	.weight		= 0,  // not using this
	.draw		= w_socom_mk23_draw,
	.holster	= w_socom_mk23_holster,
	.primary	= w_socom_mk23_primary,
	.secondary	= w_socom_mk23_secondary,
	.reload		= w_socom_mk23_reload,
	.release	= NULL,
	.crosshair	= w_socom_mk23_hud,
	.precache	= w_socom_mk23_precache,
	.pickup		= NULL,
	.updateammo	= w_socom_mk23_updateammo,
	.wmodel		= w_socom_mk23_wmodel,
	.pmodel		= w_socom_mk23_pmodel,
	.deathmsg	= w_socom_mk23_deathmsg,
	.aimanim	= w_socom_mk23_aimanim,
	.hudpic		= NULL
	
};

