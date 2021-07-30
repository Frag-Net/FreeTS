

enum weaponseq_fiveseven{
	idle = 0,
	reload = 1,
	draw = 2,
	shoot = 3,
	shootlast = 4
};



BOOLEAN weapon_FiveSeven_onPrimaryAttack(player localPlayer, weapondynamic_t arg_thisWeapon, BOOLEAN hasAmmo){
	return TRUE;
}
BOOLEAN weapon_FiveSeven_onPrimaryAttackRelease(player localPlayer, weapondynamic_t arg_thisWeapon, BOOLEAN hasAmmo){
	return FALSE;
}
BOOLEAN weapon_FiveSeven_onSecondaryAttack(player localPlayer, weapondynamic_t arg_thisWeapon, BOOLEAN hasAmmo){
	return FALSE;
}
BOOLEAN weapon_FiveSeven_onSecondaryAttackRelease(player localPlayer, weapondynamic_t arg_thisWeapon, BOOLEAN hasAmmo){
	return FALSE;
}

void weapon_FiveSeven_onEquip(player localPlayer, weapondynamic_t arg_thisWeapon){
}
BOOLEAN weapon_FiveSeven_onUnEquip(player localPlayer, weapondynamic_t arg_thisWeapon){
	return FALSE;
}
void weapon_FiveSeven_onThink(player localPlayer, weapondynamic_t arg_thisWeapon){
	weapon_gun_onThink(localPlayer, (weapondata_gun_t*)ary_weaponData[WEAPON_ID::FiveSeven], arg_thisWeapon);
}
void weapon_FiveSeven_onDrawHUD(player localPlayer, weapondynamic_t arg_thisWeapon){
}
void weapon_FiveSeven_onReload(player localPlayer, weapondynamic_t arg_thisWeapon){
}
void weapon_FiveSeven_onColdCock(player localPlayer, weapondynamic_t arg_thisWeapon){
	
}


weapondata_gun_t weapon_FiveSeven =
{
	WEAPONDATA_TYPEID_GUN,
	"Five-seveN",
	"models/v_fnh.mdl",
	"models/p_fnh.mdl",
	"models/p_fnh_sil.mdl",
	"models/w_fnh.mdl",
	"sprites/weapons/fnh.spr",
	weapon_FiveSeven_onPrimaryAttack,
	weapon_FiveSeven_onPrimaryAttackRelease,
	weapon_FiveSeven_onSecondaryAttack,
	weapon_FiveSeven_onSecondaryAttackRelease,
	weapon_FiveSeven_onEquip,
	weapon_FiveSeven_onUnEquip,
	weapon_FiveSeven_onThink,
	weapon_FiveSeven_onDrawHUD,
	weapon_FiveSeven_onReload,
	weapon_FiveSeven_onColdCock,
	weaponseq_fiveseven::idle,
	weaponseq_fiveseven::draw,
	31.0f / 30.0f,
	0.19f,  //fire delay. this is most certainly wrong. find something more accurate later.
	15.0f,  //dmg
	TRUE,
	BITS_WEAPONOPT_SILENCER | BITS_WEAPONOPT_LASERSIGHT | BITS_WEAPONOPT_FLASHLIGHT | BITS_WEAPONOPT_AKIMBO,
	BITS_WEAPONOPT_NONE,
	1250,
	10,
	BUYCATEGORY_HANDGUNS,
	2,
	{0.010000, 1.300000, 0.000000},
	WEAPON_AKIMBO_UPGRADE_ID::FiveSeven,
	BITS_FIREMODE_SEMI,
	BITS_FIREMODE_SEMI,
	AMMO_ID::_5p7x28,
	20,  //clip
	4096, //range
	weaponseq_fiveseven::reload,
	45.0f / 30.0f,
	1,
	2,
	2,
	-1
};




void
w_fiveseven_precache(void)
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
w_fiveseven_updateammo(player pl)
{
	//weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	//Weapons_UpdateAmmo(pl, arg_thisWeapon.iClipLeft, pl.ary_ammoTotal[AMMO_ID::_9x19mm], -1);
}

string
w_fiveseven_wmodel(void)
{
	return (*ary_weaponData[WEAPON_ID::FiveSeven]).sWorldModelPath;
}

string
w_fiveseven_pmodel(void)
{
	// Do we have the silencer?
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	if(!(arg_thisWeapon.iBitsUpgrade & BITS_WEAPONOPT_SILENCER) ){
		return (*ary_weaponData[WEAPON_ID::FiveSeven]).sPlayerModelPath;
	} else {
		return (*ary_weaponData[WEAPON_ID::FiveSeven]).sPlayerSilencerModelPath;
	}
}

string
w_fiveseven_deathmsg(void)
{
	return "";
}

void
w_fiveseven_draw(void)
{
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	weapondata_basic_t* basicP = ary_weaponData[WEAPON_ID::FiveSeven];
	
	weapon_base_onEquip(pl, basicP, arg_thisWeapon);
}


void
w_fiveseven_holster(void)
{
}


void
w_fiveseven_primary(void)
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
		TS_Weapons_PlaySoundDirect(pl, "weapons/fnh/fnh-fire.wav");
	} else {
		TS_Weapons_PlaySoundDirect(pl, "weapons/fnh/fnh-fire-sil.wav");
	}

	if(arg_thisWeapon.iClipLeft > 0){
		TS_Weapons_ViewAnimation(weaponseq_fiveseven::shoot, 31.0f/40.0f);
	}else{
		// that was our last bullet?
		TS_Weapons_ViewAnimation(weaponseq_fiveseven::shootlast, 31.0f/40.0f);
	}
	
#ifdef CLIENT
	View_ShowMuzzleflash(MUZZLE_SMALL);
	View_AddEvent(w_ejectshell_pistol, 0.0f);
#endif

	
	weapon_base_onAttack(pl, ary_weaponData[WEAPON_ID::FiveSeven], arg_thisWeapon, BITS_AKIMBOCHOICE_LEFT);
	
	weapon_base_setWholeAttackDelay(pl, (*ary_weaponData[arg_thisWeapon.weaponID]).fAttackDelay);

	if (self.flags & FL_CROUCHING){
		Animation_PlayerTop(pl, ANIM_CR_SHOOT1HAND, 0.2f);
	}else{
		Animation_PlayerTop(pl, ANIM_SHOOT1HAND, 0.2f);
	}
	
}



void
w_fiveseven_secondary(void)
{
}



void
w_fiveseven_reload(void)
{
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];

	weapon_gun_Reload(pl, (weapondata_gun_t*)ary_weaponData[WEAPON_ID::FiveSeven], arg_thisWeapon);
}

// ???
float
w_fiveseven_aimanim(void)
{
	return self.flags & FL_CROUCHING ? ANIM_CR_AIM1HAND : ANIM_AIM1HAND;
}

void
w_fiveseven_hud(void)
{
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	weapon_gun_onDrawHUD(pl, (weapondata_gun_t*)ary_weaponData[WEAPON_ID::FiveSeven], arg_thisWeapon);
}

// NOPE!  Handled by the buysidemenu, could make this give the instructions for drawing the button
// with the icon if really wanted
void
w_fiveseven_hudpic(int selected, vector pos, float a)
{
	//
}

weapon_t w_fiveseven =
{
	
	.name		= "fiveseven",
	.id			= 0,  // not using this
	.slot		= 2,  // ?
	.slot_pos	= 0,  // not using this
	.weight		= 0,  // not using this
	.draw		= w_fiveseven_draw,
	.holster	= w_fiveseven_holster,
	.primary	= w_fiveseven_primary,
	.secondary	= w_fiveseven_secondary,
	.reload		= w_fiveseven_reload,
	.release	= NULL,
	.crosshair	= w_fiveseven_hud,
	.precache	= w_fiveseven_precache,
	.pickup		= NULL,
	.updateammo	= w_fiveseven_updateammo,
	.wmodel		= w_fiveseven_wmodel,
	.pmodel		= w_fiveseven_pmodel,
	.deathmsg	= w_fiveseven_deathmsg,
	.aimanim	= w_fiveseven_aimanim,
	.hudpic		= NULL
	
};

