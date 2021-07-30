
enum weaponseq_rugermk1{
	idle,
	shoot1,
	shoot2,
	draw,
	reload
};


BOOLEAN weapon_RugerMK1_onPrimaryAttack(player localPlayer, weapondynamic_t arg_thisWeapon, BOOLEAN hasAmmo){
	return TRUE;
}
BOOLEAN weapon_RugerMK1_onPrimaryAttackRelease(player localPlayer, weapondynamic_t arg_thisWeapon, BOOLEAN hasAmmo){
	return FALSE;
}
BOOLEAN weapon_RugerMK1_onSecondaryAttack(player localPlayer, weapondynamic_t arg_thisWeapon, BOOLEAN hasAmmo){
	return FALSE;
}
BOOLEAN weapon_RugerMK1_onSecondaryAttackRelease(player localPlayer, weapondynamic_t arg_thisWeapon, BOOLEAN hasAmmo){
	return FALSE;
}

void weapon_RugerMK1_onEquip(player localPlayer, weapondynamic_t arg_thisWeapon){
}
BOOLEAN weapon_RugerMK1_onUnEquip(player localPlayer, weapondynamic_t arg_thisWeapon){
	return FALSE;
}
void weapon_RugerMK1_onThink(player localPlayer, weapondynamic_t arg_thisWeapon){
	weapon_gun_onThink(localPlayer, (weapondata_gun_t*)ary_weaponData[WEAPON_ID::RugerMK1], arg_thisWeapon);
}
void weapon_RugerMK1_onDrawHUD(player localPlayer, weapondynamic_t arg_thisWeapon){
}
void weapon_RugerMK1_onReload(player localPlayer, weapondynamic_t arg_thisWeapon){
}
void weapon_RugerMK1_onColdCock(player localPlayer, weapondynamic_t arg_thisWeapon){
	
}


weapondata_gun_t weapon_RugerMK1 =
{
	WEAPONDATA_TYPEID_GUN,
	"Ruger-MK1",
	"models/v_ruger.mdl",
	"models/p_ruger.mdl",
	"models/p_ruger.mdl",   //NOTICE - only ever has a silencer, so this never got a separate model (has it here)
	"models/w_ruger.mdl",
	"sprites/weapons/ruger.spr",
	weapon_RugerMK1_onPrimaryAttack,
	weapon_RugerMK1_onPrimaryAttackRelease,
	weapon_RugerMK1_onSecondaryAttack,
	weapon_RugerMK1_onSecondaryAttackRelease,
	weapon_RugerMK1_onEquip,
	weapon_RugerMK1_onUnEquip,
	weapon_RugerMK1_onThink,
	weapon_RugerMK1_onDrawHUD,
	weapon_RugerMK1_onReload,
	weapon_RugerMK1_onColdCock,
	weaponseq_rugermk1::idle,
	weaponseq_rugermk1::draw,
	31.0f / 35.0f,
	0.19f,  //fire delay. this is most certainly wrong. find something more accurate later.
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
	AMMO_ID::_p22LR,
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
w_rugermk1_updateammo(player pl)
{
	//weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	//Weapons_UpdateAmmo(pl, arg_thisWeapon.iClipLeft, pl.ary_ammoTotal[AMMO_ID::_9x19mm], -1);
}

string
w_rugermk1_wmodel(void)
{
	return (*ary_weaponData[WEAPON_ID::RugerMK1]).sWorldModelPath;
}

string
w_rugermk1_pmodel(void)
{
	// Do we have the silencer?  Yes, forced in fact
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	//if(!(arg_thisWeapon.iBitsUpgrade & BITS_WEAPONOPT_SILENCER) ){
		return (*ary_weaponData[WEAPON_ID::RugerMK1]).sPlayerModelPath;
	//} else {
	//	return (*ary_weaponData[WEAPON_ID::RugerMK1]).sPlayerSilencerModelPath;
	//}
}

string
w_rugermk1_deathmsg(void)
{
	return "";
}

void
w_rugermk1_draw(void)
{
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	
	weapon_base_onEquip(pl, ary_weaponData[WEAPON_ID::RugerMK1], arg_thisWeapon);
}

void
w_rugermk1_holster(void)
{
}

void
w_rugermk1_primary(void)
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
	
	// silencer only!
	TS_Weapons_PlaySoundDirect(pl, "weapons/ruger/fire.wav");

	randomChoice = random();
	if(randomChoice < 0.5){
		TS_Weapons_ViewAnimation(weaponseq_rugermk1::shoot1, 31.0f/35.0f);
	}else{
		TS_Weapons_ViewAnimation(weaponseq_rugermk1::shoot2, 31.0f/35.0f);
	}
	
#ifdef CLIENT
	View_ShowMuzzleflash(MUZZLE_SMALL);
	View_AddEvent(w_ejectshell_pistol, 0.0f);
#endif
	
	weapon_base_onAttack(pl, ary_weaponData[WEAPON_ID::RugerMK1], arg_thisWeapon, BITS_AKIMBOCHOICE_LEFT);
	
	weapon_base_setWholeAttackDelay(pl, (*ary_weaponData[arg_thisWeapon.weaponID]).fAttackDelay);

	if (self.flags & FL_CROUCHING){
		Animation_PlayerTop(pl, ANIM_CR_SHOOT1HAND, 0.2f);
	}else{
		Animation_PlayerTop(pl, ANIM_SHOOT1HAND, 0.2f);
	}
	
}

void
w_rugermk1_secondary(void)
{
}


void
w_rugermk1_reload(void)
{
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];

	weapon_gun_Reload(pl, (weapondata_gun_t*)ary_weaponData[WEAPON_ID::RugerMK1], arg_thisWeapon);
}


// ???
float
w_rugermk1_aimanim(void)
{
	return self.flags & FL_CROUCHING ? ANIM_CR_AIM1HAND : ANIM_AIM1HAND;
}

void
w_rugermk1_hud(void)
{
	player pl = (player)self;
	
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	weapon_gun_onDrawHUD(pl, (weapondata_gun_t*)ary_weaponData[WEAPON_ID::RugerMK1], arg_thisWeapon);

}

// NOPE!  Handled by the buysidemenu, could make this give the instructions for drawing the button
// with the icon if really wanted
void
w_rugermk1_hudpic(int selected, vector pos, float a)
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
	.crosshair	= w_rugermk1_hud,
	.precache	= w_rugermk1_precache,
	.pickup		= NULL,
	.updateammo	= w_rugermk1_updateammo,
	.wmodel		= w_rugermk1_wmodel,
	.pmodel		= w_rugermk1_pmodel,
	.deathmsg	= w_rugermk1_deathmsg,
	.aimanim	= w_rugermk1_aimanim,
	.hudpic		= NULL
	
};

