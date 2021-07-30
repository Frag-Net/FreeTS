
enum weaponseq_ump{
	idle,
	shoot1,
	shoot2,
	shoot3,
	draw,
	reload
};



BOOLEAN weapon_UMP_onPrimaryAttack(player localPlayer, weapondynamic_t arg_thisWeapon, BOOLEAN hasAmmo){
	return TRUE;
}
BOOLEAN weapon_UMP_onPrimaryAttackRelease(player localPlayer, weapondynamic_t arg_thisWeapon, BOOLEAN hasAmmo){
	return FALSE;
}
BOOLEAN weapon_UMP_onSecondaryAttack(player localPlayer, weapondynamic_t arg_thisWeapon, BOOLEAN hasAmmo){
	return FALSE;
}
BOOLEAN weapon_UMP_onSecondaryAttackRelease(player localPlayer, weapondynamic_t arg_thisWeapon, BOOLEAN hasAmmo){
	return FALSE;
}

void weapon_UMP_onEquip(player localPlayer, weapondynamic_t arg_thisWeapon){
}
BOOLEAN weapon_UMP_onUnEquip(player localPlayer, weapondynamic_t arg_thisWeapon){
	return FALSE;
}
void weapon_UMP_onThink(player localPlayer, weapondynamic_t arg_thisWeapon){
	weapon_gun_onThink(localPlayer, (weapondata_gun_t*)ary_weaponData[WEAPON_ID::UMP], arg_thisWeapon);	
}
void weapon_UMP_onDrawHUD(player localPlayer, weapondynamic_t arg_thisWeapon){
}
void weapon_UMP_onReload(player localPlayer, weapondynamic_t arg_thisWeapon){
}
void weapon_UMP_onColdCock(player localPlayer, weapondynamic_t arg_thisWeapon){
	
}



weapondata_gun_t weapon_UMP =
{
	WEAPONDATA_TYPEID_GUN,
	"UMP",
	"models/v_ump.mdl",
	"models/p_ump.mdl",
	"models/p_ump_sil.mdl",
	"models/w_ump.mdl",
	"sprites/weapons/ump.spr",
	weapon_UMP_onPrimaryAttack,
	weapon_UMP_onPrimaryAttackRelease,
	weapon_UMP_onSecondaryAttack,
	weapon_UMP_onSecondaryAttackRelease,
	weapon_UMP_onEquip,
	weapon_UMP_onUnEquip,
	weapon_UMP_onThink,
	weapon_UMP_onDrawHUD,
	weapon_UMP_onReload,
	weapon_UMP_onColdCock,
	weaponseq_ump::idle,
	weaponseq_ump::draw,
	26.0f / 35.0f,
	0.0625f,  //fire delay.
	7.0f,  //dmg
	TRUE,
	BITS_WEAPONOPT_SILENCER | BITS_WEAPONOPT_LASERSIGHT | BITS_WEAPONOPT_FLASHLIGHT | BITS_WEAPONOPT_SCOPE,
	BITS_WEAPONOPT_NONE,
	2300,
	25,
	BUYCATEGORY_SMGS,
	3,
	{0.015000, 2.550000, 0.005000},
	WEAPON_AKIMBO_UPGRADE_ID::NONE,
	BITS_FIREMODE_FULL | BITS_FIREMODE_SEMI,
	BITS_FIREMODE_FULL,
	AMMO_ID::_45Acp,
	25,  //clip
	4096, //range
	weaponseq_ump::reload,
	85.0f / 25.0f,
	5,
	-1,
	-1,
	4
};

	
		

void
w_ump_precache(void)
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
w_ump_updateammo(player pl)
{
	//weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	//Weapons_UpdateAmmo(pl, arg_thisWeapon.iClipLeft, pl.ary_ammoTotal[AMMO_ID::_9x19mm], -1);
}

string
w_ump_wmodel(void)
{
	return (*ary_weaponData[WEAPON_ID::UMP]).sWorldModelPath;
}

string
w_ump_pmodel(void)
{
	// Do we have the silencer?
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	if(!(arg_thisWeapon.iBitsUpgrade & BITS_WEAPONOPT_SILENCER) ){
		return (*ary_weaponData[WEAPON_ID::UMP]).sPlayerModelPath;
	} else {
		return (*ary_weaponData[WEAPON_ID::UMP]).sPlayerSilencerModelPath;
	}
}

string
w_ump_deathmsg(void)
{
	return "";
}

void
w_ump_draw(void)
{
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	
	weapon_base_onEquip(pl, ary_weaponData[WEAPON_ID::UMP], arg_thisWeapon);
}

void
w_ump_holster(void)
{
}

void
w_ump_primary(void)
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
		TS_Weapons_PlaySoundDirect(pl, "weapons/ump/ump-fire.wav");
	} else {
		TS_Weapons_PlaySoundDirect(pl, "weapons/ump/ump-fire-sil.wav");
	}
	
	randomChoice = random();
	if(randomChoice < 1/3){
		TS_Weapons_ViewAnimation(weaponseq_ump::shoot1, 19.0f/30.0f);
	}else if(randomChoice < 2/3){
		TS_Weapons_ViewAnimation(weaponseq_ump::shoot2, 19.0f/30.0f);
	}else{
		TS_Weapons_ViewAnimation(weaponseq_ump::shoot3, 19.0f/30.0f);
	}

#ifdef CLIENT
	View_ShowMuzzleflash(MUZZLE_SMALL);
	View_AddEvent(w_ejectshell_pistol, 0.0f);
#endif
	
	weapon_base_onAttack(pl, ary_weaponData[WEAPON_ID::UMP], arg_thisWeapon, BITS_AKIMBOCHOICE_LEFT);
	
	weapon_base_setWholeAttackDelay(pl, (*ary_weaponData[arg_thisWeapon.weaponID]).fAttackDelay);

	if (self.flags & FL_CROUCHING){
		Animation_PlayerTop(pl, ANIM_CR_SHOOT1HAND, 0.2f);
	}else{
		Animation_PlayerTop(pl, ANIM_SHOOT1HAND, 0.2f);
	}
	
}

void
w_ump_secondary(void)
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
				pl.setZoom(0.50f);
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
w_ump_reload(void)
{
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];

	weapon_gun_Reload(pl, (weapondata_gun_t*)ary_weaponData[WEAPON_ID::UMP], arg_thisWeapon);
}


// ???
float
w_ump_aimanim(void)
{
	return self.flags & FL_CROUCHING ? ANIM_CR_AIM1HAND : ANIM_AIM1HAND;
}

void
w_ump_hud(void)
{
	player pl = (player)self;
	
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	weapon_gun_onDrawHUD(pl, (weapondata_gun_t*)ary_weaponData[WEAPON_ID::UMP], arg_thisWeapon);

}

// NOPE!  Handled by the buysidemenu, could make this give the instructions for drawing the button
// with the icon if really wanted
void
w_ump_hudpic(int selected, vector pos, float a)
{
	//
}

weapon_t w_ump =
{
	
	.name		= "ump",
	.id			= 0,  // not using this
	.slot		= 2,  // ?
	.slot_pos	= 0,  // not using this
	.weight		= 0,  // not using this
	.draw		= w_ump_draw,
	.holster	= w_ump_holster,
	.primary	= w_ump_primary,
	.secondary	= w_ump_secondary,
	.reload		= w_ump_reload,
	.release	= NULL,
	.crosshair	= w_ump_hud,
	.precache	= w_ump_precache,
	.pickup		= NULL,
	.updateammo	= w_ump_updateammo,
	.wmodel		= w_ump_wmodel,
	.pmodel		= w_ump_pmodel,
	.deathmsg	= w_ump_deathmsg,
	.aimanim	= w_ump_aimanim,
	.hudpic		= NULL
	
};

