
enum weaponseq_m60{
	idle,
	draw,
	shoot,
	shoot2,
	reload
};


BOOLEAN weapon_M60_onPrimaryAttack(player localPlayer, weapondynamic_t arg_thisWeapon, BOOLEAN hasAmmo){
	return TRUE;
}
BOOLEAN weapon_M60_onPrimaryAttackRelease(player localPlayer, weapondynamic_t arg_thisWeapon, BOOLEAN hasAmmo){
	//most weapons don't care about releases.  Also this only happens the one frame the input is detected
	//not held after being held continuously - further logic should be handled in a think method.
	return FALSE;
}
BOOLEAN weapon_M60_onSecondaryAttack(player localPlayer, weapondynamic_t arg_thisWeapon, BOOLEAN hasAmmo){
	
	return FALSE;
}
BOOLEAN weapon_M60_onSecondaryAttackRelease(player localPlayer, weapondynamic_t arg_thisWeapon, BOOLEAN hasAmmo){
	//most weapons don't care about releases.  Also this only happens the one frame the input is detected
	//not held after being held continuously - further logic should be handled in a think method.
	return FALSE;
}

void weapon_M60_onEquip(player localPlayer, weapondynamic_t arg_thisWeapon){
	weapon_base_onEquip(localPlayer, ary_weaponData[WEAPON_ID::M60], arg_thisWeapon);
}
BOOLEAN weapon_M60_onUnEquip(player localPlayer, weapondynamic_t arg_thisWeapon){
	return FALSE;
}
void weapon_M60_onThink(player localPlayer, weapondynamic_t arg_thisWeapon){
	weapon_gun_onThink(localPlayer, (weapondata_gun_t*)ary_weaponData[WEAPON_ID::M60], arg_thisWeapon);
	
}
void weapon_M60_onDrawHUD(player localPlayer, weapondynamic_t arg_thisWeapon){
	weapon_gun_onDrawHUD(localPlayer, (weapondata_gun_t*)ary_weaponData[WEAPON_ID::M60], arg_thisWeapon);
}
void weapon_M60_onReload(player localPlayer, weapondynamic_t arg_thisWeapon){
	weapon_gun_Reload(localPlayer, (weapondata_gun_t*)ary_weaponData[WEAPON_ID::M60], arg_thisWeapon);
}
void weapon_M60_onColdCock(player localPlayer, weapondynamic_t arg_thisWeapon){
	
}


weapondata_gun_t weapon_M60 =
{
	WEAPONDATA_TYPEID_GUN,
	"M60E3",
	"models/v_m60.mdl",
	"models/p_m60.mdl",
	"",
	"models/w_m60.mdl",
	"sprites/weapons/m60.spr",
	weapon_M60_onPrimaryAttack,
	weapon_M60_onPrimaryAttackRelease,
	weapon_M60_onSecondaryAttack,
	weapon_M60_onSecondaryAttackRelease,
	weapon_M60_onEquip,
	weapon_M60_onUnEquip,
	weapon_M60_onThink,
	weapon_M60_onDrawHUD,
	weapon_M60_onReload,
	weapon_M60_onColdCock,
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
	AMMO_ID::_5p56Nato,
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
w_m60_updateammo(player pl)
{
	//weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	//Weapons_UpdateAmmo(pl, arg_thisWeapon.iClipLeft, pl.ary_ammoTotal[AMMO_ID::_9x19mm], -1);
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
	
	TS_Weapons_PlaySoundDirect(pl, "weapons/m60/m60-fire.wav");
	
	randomChoice = random();
	if(randomChoice < 0.5){
		TS_Weapons_ViewAnimation(weaponseq_m60::shoot, 31.0f/33.0f);
	}else{
		TS_Weapons_ViewAnimation(weaponseq_m60::shoot2, 31.0f/33.0f);
	}


#ifdef CLIENT
	View_ShowMuzzleflash(MUZZLE_SMALL);
	View_AddEvent(w_ejectshell_pistol, 0.0f);
#endif
	
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


// ???
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

// NOPE!  Handled by the buysidemenu, could make this give the instructions for drawing the button
// with the icon if really wanted
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


