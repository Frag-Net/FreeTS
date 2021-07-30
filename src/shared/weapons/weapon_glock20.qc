
enum weaponseq_glock20{
	idle,
	reload,
	draw,
	shoot1,
	shoot2,
	shootempty
};


BOOLEAN weapon_Glock20_onPrimaryAttack(player localPlayer, weapondynamic_t arg_thisWeapon, BOOLEAN hasAmmo){
	return TRUE;
}
BOOLEAN weapon_Glock20_onPrimaryAttackRelease(player localPlayer, weapondynamic_t arg_thisWeapon, BOOLEAN hasAmmo){
	return FALSE;
}
BOOLEAN weapon_Glock20_onSecondaryAttack(player localPlayer, weapondynamic_t arg_thisWeapon, BOOLEAN hasAmmo){
	return FALSE;
}
BOOLEAN weapon_Glock20_onSecondaryAttackRelease(player localPlayer, weapondynamic_t arg_thisWeapon, BOOLEAN hasAmmo){
	return FALSE;
}

void weapon_Glock20_onEquip(player localPlayer, weapondynamic_t arg_thisWeapon){
}
BOOLEAN weapon_Glock20_onUnEquip(player localPlayer, weapondynamic_t arg_thisWeapon){
	return FALSE;
}
void weapon_Glock20_onThink(player localPlayer, weapondynamic_t arg_thisWeapon){
	weapon_gun_onThink(localPlayer, (weapondata_gun_t*)ary_weaponData[WEAPON_ID::Glock20], arg_thisWeapon);
}
void weapon_Glock20_onDrawHUD(player localPlayer, weapondynamic_t arg_thisWeapon){
}
void weapon_Glock20_onReload(player localPlayer, weapondynamic_t arg_thisWeapon){
}
void weapon_Glock20_onColdCock(player localPlayer, weapondynamic_t arg_thisWeapon){
	
}


weapondata_gun_t weapon_Glock20 =
{
	WEAPONDATA_TYPEID_GUN,
	"Glock-20C",
	"models/v_glock22.mdl",
	"models/p_glock22.mdl",
	"models/p_glock22_sil.mdl",
	"models/w_glock22.mdl",
	"sprites/weapons/glock22.spr",
	weapon_Glock20_onPrimaryAttack,
	weapon_Glock20_onPrimaryAttackRelease,
	weapon_Glock20_onSecondaryAttack,
	weapon_Glock20_onSecondaryAttackRelease,
	weapon_Glock20_onEquip,
	weapon_Glock20_onUnEquip,
	weapon_Glock20_onThink,
	weapon_Glock20_onDrawHUD,
	weapon_Glock20_onReload,
	weapon_Glock20_onColdCock,
	weaponseq_glock20::idle,
	weaponseq_glock20::draw,
	31.0f / 30.0f,
	0.19f,  //fire delay. this is most certainly wrong. find something more accurate later.
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
	AMMO_ID::_10mmAUTO,
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
w_glock20_updateammo(player pl)
{
	//weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	//Weapons_UpdateAmmo(pl, arg_thisWeapon.iClipLeft, pl.ary_ammoTotal[AMMO_ID::_9x19mm], -1);
}

string
w_glock20_wmodel(void)
{
	return (*ary_weaponData[WEAPON_ID::Glock20]).sWorldModelPath;
}

string
w_glock20_pmodel(void)
{
	// Do we have the silencer?
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	if(!(arg_thisWeapon.iBitsUpgrade & BITS_WEAPONOPT_SILENCER) ){
		return (*ary_weaponData[WEAPON_ID::Glock20]).sPlayerModelPath;
	} else {
		return (*ary_weaponData[WEAPON_ID::Glock20]).sPlayerSilencerModelPath;
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
	
	weapon_base_onEquip(pl, ary_weaponData[WEAPON_ID::Glock20], arg_thisWeapon);
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
		TS_Weapons_PlaySoundDirect(pl, "weapons/glock22/glock22-fire.wav");
	} else {
		TS_Weapons_PlaySoundDirect(pl, "weapons/glock22/glock22-fire-sil.wav");
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

	
#ifdef CLIENT
	View_ShowMuzzleflash(MUZZLE_SMALL);
	View_AddEvent(w_ejectshell_pistol, 0.0f);
#endif
	
	weapon_base_onAttack(pl, ary_weaponData[WEAPON_ID::Glock20], arg_thisWeapon, BITS_AKIMBOCHOICE_LEFT);
	
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

	weapon_gun_Reload(pl, (weapondata_gun_t*)ary_weaponData[WEAPON_ID::Glock20], arg_thisWeapon);
}


// ???
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
	weapon_gun_onDrawHUD(pl, (weapondata_gun_t*)ary_weaponData[WEAPON_ID::Glock20], arg_thisWeapon);

}

// NOPE!  Handled by the buysidemenu, could make this give the instructions for drawing the button
// with the icon if really wanted
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

