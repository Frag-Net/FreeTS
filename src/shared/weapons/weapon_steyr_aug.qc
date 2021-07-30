
enum weaponseq_steyr_aug{
	idle,
	draw,
	shoot,
	reload
};



BOOLEAN weapon_STEYR_AUG_onPrimaryAttack(player localPlayer, weapondynamic_t arg_thisWeapon, BOOLEAN hasAmmo){
	return TRUE;
}
BOOLEAN weapon_STEYR_AUG_onPrimaryAttackRelease(player localPlayer, weapondynamic_t arg_thisWeapon, BOOLEAN hasAmmo){
	return FALSE;
}
BOOLEAN weapon_STEYR_AUG_onSecondaryAttack(player localPlayer, weapondynamic_t arg_thisWeapon, BOOLEAN hasAmmo){
	return FALSE;
}
BOOLEAN weapon_STEYR_AUG_onSecondaryAttackRelease(player localPlayer, weapondynamic_t arg_thisWeapon, BOOLEAN hasAmmo){
	return FALSE;
}

void weapon_STEYR_AUG_onEquip(player localPlayer, weapondynamic_t arg_thisWeapon){
}
BOOLEAN weapon_STEYR_AUG_onUnEquip(player localPlayer, weapondynamic_t arg_thisWeapon){
	return FALSE;
}
void weapon_STEYR_AUG_onThink(player localPlayer, weapondynamic_t arg_thisWeapon){
	weapon_gun_onThink(localPlayer, (weapondata_gun_t*)ary_weaponData[WEAPON_ID::STEYR_AUG], arg_thisWeapon);
}
void weapon_STEYR_AUG_onDrawHUD(player localPlayer, weapondynamic_t arg_thisWeapon){
}
void weapon_STEYR_AUG_onReload(player localPlayer, weapondynamic_t arg_thisWeapon){
}
void weapon_STEYR_AUG_onColdCock(player localPlayer, weapondynamic_t arg_thisWeapon){
	
}


	
weapondata_gun_t weapon_STEYR_AUG =
{
	WEAPONDATA_TYPEID_GUN,
	"STEYR-AUG",
	"models/v_aug.mdl",
	"models/p_aug.mdl",
	"models/p_aug_sil.mdl",
	"models/w_aug.mdl",
	"sprites/weapons/aug.spr",
	weapon_STEYR_AUG_onPrimaryAttack,
	weapon_STEYR_AUG_onPrimaryAttackRelease,
	weapon_STEYR_AUG_onSecondaryAttack,
	weapon_STEYR_AUG_onSecondaryAttackRelease,
	weapon_STEYR_AUG_onEquip,
	weapon_STEYR_AUG_onUnEquip,
	weapon_STEYR_AUG_onThink,
	weapon_STEYR_AUG_onDrawHUD,
	weapon_STEYR_AUG_onReload,
	weapon_STEYR_AUG_onColdCock,
	weaponseq_steyr_aug::idle,
	weaponseq_steyr_aug::draw,
	31.0f / 30.0f,
	0.0625f,  //fire delay.
	7.0f,  //dmg
	TRUE,
	BITS_WEAPONOPT_SILENCER | BITS_WEAPONOPT_LASERSIGHT | BITS_WEAPONOPT_SCOPE,
	BITS_WEAPONOPT_SCOPE,
	5000,
	40,
	BUYCATEGORY_RIFLES,
	4,
	{0.005000, 1.000000, 0.015000},
	WEAPON_AKIMBO_UPGRADE_ID::NONE,
	BITS_FIREMODE_FULL | BITS_FIREMODE_SEMI,
	BITS_FIREMODE_FULL,
	AMMO_ID::_5p56Nato,
	30,  //clip
	4096, //range
	weaponseq_steyr_aug::reload,
	74.0f / 30.0f,
	1,
	-1,
	-1,
	-1
};





void
w_steyr_aug_precache(void)
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
w_steyr_aug_updateammo(player pl)
{
	//weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	//Weapons_UpdateAmmo(pl, arg_thisWeapon.iClipLeft, pl.ary_ammoTotal[AMMO_ID::_9x19mm], -1);
}

string
w_steyr_aug_wmodel(void)
{
	return (*ary_weaponData[WEAPON_ID::STEYR_AUG]).sWorldModelPath;
}

string
w_steyr_aug_pmodel(void)
{
	// Do we have the silencer?
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	if(!(arg_thisWeapon.iBitsUpgrade & BITS_WEAPONOPT_SILENCER) ){
		return (*ary_weaponData[WEAPON_ID::STEYR_AUG]).sPlayerModelPath;
	} else {
		return (*ary_weaponData[WEAPON_ID::STEYR_AUG]).sPlayerSilencerModelPath;
	}
}

string
w_steyr_aug_deathmsg(void)
{
	return "";
}

void
w_steyr_aug_draw(void)
{
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	
	weapon_base_onEquip(pl, ary_weaponData[WEAPON_ID::STEYR_AUG], arg_thisWeapon);
}

void
w_steyr_aug_holster(void)
{
}

void
w_steyr_aug_primary(void)
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
		TS_Weapons_PlaySoundDirect(pl, "weapons/aug/aug-fire.wav");
	} else {
		TS_Weapons_PlaySoundDirect(pl, "weapons/aug/aug-fire-sil.wav");
	}

	TS_Weapons_ViewAnimation(weaponseq_steyr_aug::shoot, 31.0f/30.0f);
	
#ifdef CLIENT
	View_ShowMuzzleflash(MUZZLE_SMALL);
	View_AddEvent(w_ejectshell_pistol, 0.0f);
#endif
	
	weapon_base_onAttack(pl, ary_weaponData[WEAPON_ID::STEYR_AUG], arg_thisWeapon, BITS_AKIMBOCHOICE_LEFT);
	
	weapon_base_setWholeAttackDelay(pl, (*ary_weaponData[arg_thisWeapon.weaponID]).fAttackDelay);

	if (self.flags & FL_CROUCHING){
		Animation_PlayerTop(pl, ANIM_CR_SHOOT1HAND, 0.2f);
	}else{
		Animation_PlayerTop(pl, ANIM_SHOOT1HAND, 0.2f);
	}
	
}

void
w_steyr_aug_secondary(void)
{
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	
	if(pl.w_attack_next > 0){
		return;
	}
	
	INPUT_SECONDARY_TAP_GATE
	
	if(arg_thisWeapon.iBitsUpgrade & BITS_WEAPONOPT_SCOPE){
		// toggle through the zoom.
		
		switch(pl.currentZoomChoice){
			case -1:{
				//pl.viewzoom = 40/80;
				pl.setZoom(0.5f);
				pl.currentZoomChoice++;
			break;}
			case 0:{
				//pl.viewzoom = 0;
				pl.setZoom(1.00f);
				pl.currentZoomChoice = -1;
			break;}
			
		}//END OF switch

	}
	
}


void
w_steyr_aug_reload(void)
{
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];

	weapon_gun_Reload(pl, (weapondata_gun_t*)ary_weaponData[WEAPON_ID::STEYR_AUG], arg_thisWeapon);
}


// ???
float
w_steyr_aug_aimanim(void)
{
	return self.flags & FL_CROUCHING ? ANIM_CR_AIM1HAND : ANIM_AIM1HAND;
}

void
w_steyr_aug_hud(void)
{
	player pl = (player)self;
	
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	weapon_gun_onDrawHUD(pl, (weapondata_gun_t*)ary_weaponData[WEAPON_ID::STEYR_AUG], arg_thisWeapon);

}

// NOPE!  Handled by the buysidemenu, could make this give the instructions for drawing the button
// with the icon if really wanted
void
w_steyr_aug_hudpic(int selected, vector pos, float a)
{
	//
}

weapon_t w_steyr_aug =
{
	
	.name		= "steyr_aug",
	.id			= 0,  // not using this
	.slot		= 2,  // ?
	.slot_pos	= 0,  // not using this
	.weight		= 0,  // not using this
	.draw		= w_steyr_aug_draw,
	.holster	= w_steyr_aug_holster,
	.primary	= w_steyr_aug_primary,
	.secondary	= w_steyr_aug_secondary,
	.reload		= w_steyr_aug_reload,
	.release	= NULL,
	.crosshair	= w_steyr_aug_hud,
	.precache	= w_steyr_aug_precache,
	.pickup		= NULL,
	.updateammo	= w_steyr_aug_updateammo,
	.wmodel		= w_steyr_aug_wmodel,
	.pmodel		= w_steyr_aug_pmodel,
	.deathmsg	= w_steyr_aug_deathmsg,
	.aimanim	= w_steyr_aug_aimanim,
	.hudpic		= NULL
	
};

