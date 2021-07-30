
enum weaponseq_usas12{
	idle,
	reload,
	draw,
	shootsemi
};


BOOLEAN weapon_USAS12_onPrimaryAttack(player localPlayer, weapondynamic_t arg_thisWeapon, BOOLEAN hasAmmo){
	return TRUE;
}
BOOLEAN weapon_USAS12_onPrimaryAttackRelease(player localPlayer, weapondynamic_t arg_thisWeapon, BOOLEAN hasAmmo){
	return FALSE;
}
BOOLEAN weapon_USAS12_onSecondaryAttack(player localPlayer, weapondynamic_t arg_thisWeapon, BOOLEAN hasAmmo){
	return FALSE;
}
BOOLEAN weapon_USAS12_onSecondaryAttackRelease(player localPlayer, weapondynamic_t arg_thisWeapon, BOOLEAN hasAmmo){
	return FALSE;
}

void weapon_USAS12_onEquip(player localPlayer, weapondynamic_t arg_thisWeapon){
}
BOOLEAN weapon_USAS12_onUnEquip(player localPlayer, weapondynamic_t arg_thisWeapon){
	return FALSE;
}
void weapon_USAS12_onThink(player localPlayer, weapondynamic_t arg_thisWeapon){
	weapon_gun_onThink(localPlayer, (weapondata_gun_t*)ary_weaponData[WEAPON_ID::USAS12], arg_thisWeapon);
}
void weapon_USAS12_onDrawHUD(player localPlayer, weapondynamic_t arg_thisWeapon){
}
void weapon_USAS12_onReload(player localPlayer, weapondynamic_t arg_thisWeapon){
}
void weapon_USAS12_onColdCock(player localPlayer, weapondynamic_t arg_thisWeapon){
}


	
weapondata_gun_t weapon_USAS12 =
{
	WEAPONDATA_TYPEID_GUN,
	"USAS-12",
	"models/v_usas.mdl",
	"models/p_usas.mdl",
	"",
	"models/w_usas.mdl",
	"sprites/weapons/usas12.spr",
	weapon_USAS12_onPrimaryAttack,
	weapon_USAS12_onPrimaryAttackRelease,
	weapon_USAS12_onSecondaryAttack,
	weapon_USAS12_onSecondaryAttackRelease,
	weapon_USAS12_onEquip,
	weapon_USAS12_onUnEquip,
	weapon_USAS12_onThink,
	weapon_USAS12_onDrawHUD,
	weapon_USAS12_onReload,
	weapon_USAS12_onColdCock,
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
w_usas12_updateammo(player pl)
{
	//weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	//Weapons_UpdateAmmo(pl, arg_thisWeapon.iClipLeft, pl.ary_ammoTotal[AMMO_ID::_9x19mm], -1);
}

string
w_usas12_wmodel(void)
{
	return (*ary_weaponData[WEAPON_ID::USAS12]).sWorldModelPath;
}

string
w_usas12_pmodel(void)
{
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	return (*ary_weaponData[WEAPON_ID::USAS12]).sPlayerModelPath;
}

string
w_usas12_deathmsg(void)
{
	return "";
}

void
w_usas12_draw(void)
{
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	weapondata_basic_t* basicP = ary_weaponData[WEAPON_ID::USAS12];
	
	weapon_base_onEquip(pl, basicP, arg_thisWeapon);
}


void
w_usas12_holster(void)
{
}


void
w_usas12_primary(void)
{
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];

	if (pl.w_attack_next > 0.0) {
		return;
	}
	
	if (!arg_thisWeapon.iClipLeft || WEAPON_UNDERWATER_CHECK) {
		PLAY_CLICK_SOUND
		return;
	}
	
	TS_Weapons_PlaySoundDirect(pl, "weapons/usas/usas-fire.wav");

	TS_Weapons_ViewAnimation(weaponseq_usas12::shootsemi, 31.0f/35.0f);

	
#ifdef CLIENT
	View_ShowMuzzleflash(MUZZLE_SMALL);
	View_AddEvent(w_ejectshell_pistol, 0.0f);
#endif

	weapon_base_onAttack_multi(pl, ary_weaponData[WEAPON_ID::USAS12], arg_thisWeapon, 8, BITS_AKIMBOCHOICE_LEFT);
	
	weapon_base_setWholeAttackDelay(pl, (*ary_weaponData[arg_thisWeapon.weaponID]).fAttackDelay);

	if (self.flags & FL_CROUCHING){
		Animation_PlayerTop(pl, ANIM_CR_SHOOT1HAND, 0.2f);
	}else{
		Animation_PlayerTop(pl, ANIM_SHOOT1HAND, 0.2f);
	}
	
}


void
w_usas12_secondary(void)
{
}

void
w_usas12_reload(void)
{
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];

	weapon_gun_Reload(pl, (weapondata_gun_t*)ary_weaponData[WEAPON_ID::USAS12], arg_thisWeapon);
}



// ???
float
w_usas12_aimanim(void)
{
	return self.flags & FL_CROUCHING ? ANIM_CR_AIM1HAND : ANIM_AIM1HAND;
}


void
w_usas12_hud(void)
{
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	weapon_gun_onDrawHUD(pl, (weapondata_gun_t*)ary_weaponData[WEAPON_ID::USAS12], arg_thisWeapon);
}



// NOPE!  Handled by the buysidemenu, could make this give the instructions for drawing the button
// with the icon if really wanted
void
w_usas12_hudpic(int selected, vector pos, float a)
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
	.crosshair	= w_usas12_hud,
	.precache	= w_usas12_precache,
	.pickup		= NULL,
	.updateammo	= w_usas12_updateammo,
	.wmodel		= w_usas12_wmodel,
	.pmodel		= w_usas12_pmodel,
	.deathmsg	= w_usas12_deathmsg,
	.aimanim	= w_usas12_aimanim,
	.hudpic		= NULL
	
};


