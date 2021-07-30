
enum weaponseq_mp5sd{
	idle,
	shoot1,
	shoot2,
	shoot3,
	draw,
	reload
};



BOOLEAN weapon_MP5SD_onPrimaryAttack(player localPlayer, weapondynamic_t arg_thisWeapon, BOOLEAN hasAmmo){
	return TRUE;
}
BOOLEAN weapon_MP5SD_onPrimaryAttackRelease(player localPlayer, weapondynamic_t arg_thisWeapon, BOOLEAN hasAmmo){
	return FALSE;
}
BOOLEAN weapon_MP5SD_onSecondaryAttack(player localPlayer, weapondynamic_t arg_thisWeapon, BOOLEAN hasAmmo){
	return FALSE;
}
BOOLEAN weapon_MP5SD_onSecondaryAttackRelease(player localPlayer, weapondynamic_t arg_thisWeapon, BOOLEAN hasAmmo){
	return FALSE;
}

void weapon_MP5SD_onEquip(player localPlayer, weapondynamic_t arg_thisWeapon){
}
BOOLEAN weapon_MP5SD_onUnEquip(player localPlayer, weapondynamic_t arg_thisWeapon){
	return FALSE;
}
void weapon_MP5SD_onThink(player localPlayer, weapondynamic_t arg_thisWeapon){
	weapon_gun_onThink(localPlayer, (weapondata_gun_t*)ary_weaponData[WEAPON_ID::MP5SD], arg_thisWeapon);
	weapon_gun_onThink_burstFireLogic(localPlayer, (weapondata_gun_t*)ary_weaponData[WEAPON_ID::MP5SD], arg_thisWeapon);
	
}
void weapon_MP5SD_onDrawHUD(player localPlayer, weapondynamic_t arg_thisWeapon){
}
void weapon_MP5SD_onReload(player localPlayer, weapondynamic_t arg_thisWeapon){
}
void weapon_MP5SD_onColdCock(player localPlayer, weapondynamic_t arg_thisWeapon){
	
}

	
weapondata_gun_t weapon_MP5SD =
{
	WEAPONDATA_TYPEID_GUN,
	"MP5 SD",
	"models/v_mp5sd.mdl",
	"models/p_mp5sd.mdl",
	"",
	"models/w_mp5sd.mdl",
	"sprites/weapons/mp5sd.spr",
	weapon_MP5SD_onPrimaryAttack,
	weapon_MP5SD_onPrimaryAttackRelease,
	weapon_MP5SD_onSecondaryAttack,
	weapon_MP5SD_onSecondaryAttackRelease,
	weapon_MP5SD_onEquip,
	weapon_MP5SD_onUnEquip,
	weapon_MP5SD_onThink,
	weapon_MP5SD_onDrawHUD,
	weapon_MP5SD_onReload,
	weapon_MP5SD_onColdCock,
	weaponseq_mp5sd::idle,
	weaponseq_mp5sd::draw,
	31.0f / 30.0f,
	0.0625f,  //fire delay.
	7.0f,  //dmg
	TRUE,
	BITS_WEAPONOPT_SILENCER | BITS_WEAPONOPT_LASERSIGHT | BITS_WEAPONOPT_FLASHLIGHT | BITS_WEAPONOPT_SCOPE,
	BITS_WEAPONOPT_SILENCER,
	2500,
	25,
	BUYCATEGORY_SMGS,
	3,
	{0.005000, 1.300000, 0.013000},
	WEAPON_AKIMBO_UPGRADE_ID::NONE,
	BITS_FIREMODE_FULL | BITS_FIREMODE_SEMI | BITS_FIREMODE_BURST,
	BITS_FIREMODE_FULL,
	AMMO_ID::_9x19mm,
	30,  //clip
	4096, //range
	weaponseq_mp5sd::reload,
	71.0f / 30.0f,
	-1,
	-1,
	-1,
	1
};




void
w_mp5sd_precache(void)
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
w_mp5sd_updateammo(player pl)
{
	//weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	//Weapons_UpdateAmmo(pl, arg_thisWeapon.iClipLeft, pl.ary_ammoTotal[AMMO_ID::_9x19mm], -1);
}

string
w_mp5sd_wmodel(void)
{
	return (*ary_weaponData[WEAPON_ID::MP5SD]).sWorldModelPath;
}

string
w_mp5sd_pmodel(void)
{
	// Do we have the silencer?
	// Oh.  Guaranteed for the mp5.  Oh well.
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	//if(!(arg_thisWeapon.iBitsUpgrade & BITS_WEAPONOPT_SILENCER) ){
	//	return (*ary_weaponData[WEAPON_ID::MP5SD]).sPlayerModelPath;
	//} else {
		return (*ary_weaponData[WEAPON_ID::MP5SD]).sPlayerSilencerModelPath;
	//}
}

string
w_mp5sd_deathmsg(void)
{
	return "";
}

void
w_mp5sd_draw(void)
{
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	
	weapon_base_onEquip(pl, ary_weaponData[WEAPON_ID::MP5SD], arg_thisWeapon);
}

void
w_mp5sd_holster(void)
{
}

void
w_mp5sd_primary(void)
{
	float randomChoice;
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];

	if (pl.w_attack_next > 0.0) {
		return;
	}
	
	if(arg_thisWeapon.iFireMode == BITS_FIREMODE_SEMI || arg_thisWeapon.iFireMode == BITS_FIREMODE_BURST){
		INPUT_PRIMARY_TAP_GATE
	}
	
	if (!arg_thisWeapon.iClipLeft || WEAPON_UNDERWATER_CHECK) {
		PLAY_CLICK_SOUND
		return;
	}
	
	// silencer only!
	TS_Weapons_PlaySoundDirect(pl, "weapons/mp5sd/mp5sd-fire.wav");


	randomChoice = random();
	if(randomChoice < 1/3){
		TS_Weapons_ViewAnimation(weaponseq_mp5sd::shoot1, 31.0f/30.0f);
	}else if(randomChoice < 2/3){
		TS_Weapons_ViewAnimation(weaponseq_mp5sd::shoot2, 31.0f/30.0f);
	}else{
		TS_Weapons_ViewAnimation(weaponseq_mp5sd::shoot3, 31.0f/30.0f);
	}
	
#ifdef CLIENT
	View_ShowMuzzleflash(MUZZLE_SMALL);
	View_AddEvent(w_ejectshell_pistol, 0.0f);
#endif

	if(arg_thisWeapon.iFireMode == BITS_FIREMODE_BURST)
	{
		weapon_base_burstFire(pl, ary_weaponData[WEAPON_ID::MP5SD], arg_thisWeapon, BITS_AKIMBOCHOICE_LEFT, 3, 0.02);
	}
	else if(arg_thisWeapon.iFireMode == BITS_FIREMODE_SEMI || arg_thisWeapon.iFireMode == BITS_FIREMODE_FULL)
	{
		// Semi or AUTO, normal behavior.
		weapon_base_onAttack(pl, ary_weaponData[WEAPON_ID::MP5SD], arg_thisWeapon, BITS_AKIMBOCHOICE_LEFT);
		weapon_base_setWholeAttackDelay(pl, (*ary_weaponData[arg_thisWeapon.weaponID]).fAttackDelay);
	}else if(arg_thisWeapon.iFireMode == BITS_FIREMODE_NONE)
	{
		// !!! Burst-fire automatics only
		weapon_base_onAttack(pl, ary_weaponData[WEAPON_ID::MP5SD], arg_thisWeapon, BITS_AKIMBOCHOICE_LEFT);
		//weapon_base_setWholeAttackDelay(pl, 0.5);
	}

	if (self.flags & FL_CROUCHING){
		Animation_PlayerTop(pl, ANIM_CR_SHOOT1HAND, 0.2f);
	}else{
		Animation_PlayerTop(pl, ANIM_SHOOT1HAND, 0.2f);
	}
	
}

void
w_mp5sd_secondary(void)
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
				//pl.viewzoom = 32/80;
				pl.setZoom(0.40f);
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
w_mp5sd_reload(void)
{
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];

	weapon_gun_Reload(pl, (weapondata_gun_t*)ary_weaponData[WEAPON_ID::MP5SD], arg_thisWeapon);
}


// ???
float
w_mp5sd_aimanim(void)
{
	return self.flags & FL_CROUCHING ? ANIM_CR_AIM1HAND : ANIM_AIM1HAND;
}

void
w_mp5sd_hud(void)
{
	player pl = (player)self;
	
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	weapon_gun_onDrawHUD(pl, (weapondata_gun_t*)ary_weaponData[WEAPON_ID::MP5SD], arg_thisWeapon);

}

// NOPE!  Handled by the buysidemenu, could make this give the instructions for drawing the button
// with the icon if really wanted
void
w_mp5sd_hudpic(int selected, vector pos, float a)
{
	//
}

weapon_t w_mp5sd =
{
	
	.name		= "mp5sd",
	.id			= 0,  // not using this
	.slot		= 2,  // ?
	.slot_pos	= 0,  // not using this
	.weight		= 0,  // not using this
	.draw		= w_mp5sd_draw,
	.holster	= w_mp5sd_holster,
	.primary	= w_mp5sd_primary,
	.secondary	= w_mp5sd_secondary,
	.reload		= w_mp5sd_reload,
	.release	= NULL,
	.crosshair	= w_mp5sd_hud,
	.precache	= w_mp5sd_precache,
	.pickup		= NULL,
	.updateammo	= w_mp5sd_updateammo,
	.wmodel		= w_mp5sd_wmodel,
	.pmodel		= w_mp5sd_pmodel,
	.deathmsg	= w_mp5sd_deathmsg,
	.aimanim	= w_mp5sd_aimanim,
	.hudpic		= NULL
	
};

