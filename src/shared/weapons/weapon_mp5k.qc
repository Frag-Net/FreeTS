
enum weaponseq_mp5k{
	idle,
	reload,
	draw,
	shoot1,
	shoot2,
	change,
	rechange,
	idleb,
	shoot1b,
	shoot2b,
	reload2
};




BOOLEAN weapon_MP5K_onPrimaryAttack(player localPlayer, weapondynamic_t arg_thisWeapon, BOOLEAN hasAmmo){
	return TRUE;
}
BOOLEAN weapon_MP5K_onPrimaryAttackRelease(player localPlayer, weapondynamic_t arg_thisWeapon, BOOLEAN hasAmmo){
	return FALSE;
}
BOOLEAN weapon_MP5K_onSecondaryAttack(player localPlayer, weapondynamic_t arg_thisWeapon, BOOLEAN hasAmmo){
	return FALSE;
}
BOOLEAN weapon_MP5K_onSecondaryAttackRelease(player localPlayer, weapondynamic_t arg_thisWeapon, BOOLEAN hasAmmo){
	return FALSE;
}

void weapon_MP5K_onEquip(player localPlayer, weapondynamic_t arg_thisWeapon){
}
BOOLEAN weapon_MP5K_onUnEquip(player localPlayer, weapondynamic_t arg_thisWeapon){
	return FALSE;
}
void weapon_MP5K_onThink(player localPlayer, weapondynamic_t arg_thisWeapon){
	weapon_gun_onThink(localPlayer, (weapondata_gun_t*)ary_weaponData[WEAPON_ID::MP5K], arg_thisWeapon);
	weapon_gun_onThink_burstFireLogic(localPlayer, (weapondata_gun_t*)ary_weaponData[WEAPON_ID::MP5K], arg_thisWeapon);
}
void weapon_MP5K_onDrawHUD(player localPlayer, weapondynamic_t arg_thisWeapon){
}
void weapon_MP5K_onReload(player localPlayer, weapondynamic_t arg_thisWeapon){
}
void weapon_MP5K_onColdCock(player localPlayer, weapondynamic_t arg_thisWeapon){
	
}


weapondata_ironsight_t weapon_MP5K =
{
	WEAPONDATA_TYPEID_IRONSIGHT,
	"MP5K",
	"models/v_mp5k.mdl",
	"models/p_mp5k.mdl",
	"models/p_mp5k_sil.mdl",
	"models/w_mp5k.mdl",
	"sprites/weapons/mp5k.spr",
	weapon_MP5K_onPrimaryAttack,
	weapon_MP5K_onPrimaryAttackRelease,
	weapon_MP5K_onSecondaryAttack,
	weapon_MP5K_onSecondaryAttackRelease,
	weapon_MP5K_onEquip,
	weapon_MP5K_onUnEquip,
	weapon_MP5K_onThink,
	weapon_MP5K_onDrawHUD,
	weapon_MP5K_onReload,
	weapon_MP5K_onColdCock,
	weaponseq_mp5k::idle,
	weaponseq_mp5k::draw,
	31.0f / 30.0f,
	0.0625f,  //fire delay.
	7.0f,  //dmg
	TRUE,
	BITS_WEAPONOPT_SILENCER | BITS_WEAPONOPT_LASERSIGHT | BITS_WEAPONOPT_FLASHLIGHT | BITS_WEAPONOPT_SCOPE,
	BITS_WEAPONOPT_NONE,
	1500,
	20,
	BUYCATEGORY_SMGS,
	3,
	{0.010000, 2.300000, 0.005000},
	WEAPON_AKIMBO_UPGRADE_ID::NONE,
	BITS_FIREMODE_FULL | BITS_FIREMODE_SEMI | BITS_FIREMODE_BURST,
	BITS_FIREMODE_FULL,
	AMMO_ID::_9x19mm,
	30,  //clip
	4096, //range
	weaponseq_mp5k::reload,
	71.0f / 30.0f,
	2,
	-1,
	-1,
	1,
	{
		weaponseq_mp5k::change,
		21.0f/40.0f,
		weaponseq_mp5k::rechange,
		21.0f/40.0f,
		weaponseq_mp5k::idleb,
		weaponseq_mp5k::reload2,
		76.0f/30.0f,
		{0.010000, 2.300000, 0.005000}
	}
};






void
w_mp5k_precache(void)
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
w_mp5k_updateammo(player pl)
{
	//weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	//Weapons_UpdateAmmo(pl, arg_thisWeapon.iClipLeft, pl.ary_ammoTotal[AMMO_ID::_9x19mm], -1);
}

string
w_mp5k_wmodel(void)
{
	return (*ary_weaponData[WEAPON_ID::MP5K]).sWorldModelPath;
}

string
w_mp5k_pmodel(void)
{
	// Do we have the silencer?
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	if(!(arg_thisWeapon.iBitsUpgrade & BITS_WEAPONOPT_SILENCER) ){
		return (*ary_weaponData[WEAPON_ID::MP5K]).sPlayerModelPath;
	} else {
		return (*ary_weaponData[WEAPON_ID::MP5K]).sPlayerSilencerModelPath;
	}
}

string
w_mp5k_deathmsg(void)
{
	return "";
}

void
w_mp5k_draw(void)
{
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	
	weapon_base_onEquip(pl, ary_weaponData[WEAPON_ID::MP5K], arg_thisWeapon);
}

void
w_mp5k_holster(void)
{
}

void
w_mp5k_primary(void)
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
	
	if(!(arg_thisWeapon.iBitsUpgrade & BITS_WEAPONOPT_SILENCER) ){
		TS_Weapons_PlaySoundDirect(pl, "weapons/mp5k/mp5k-fire.wav");
	} else {
		TS_Weapons_PlaySoundDirect(pl, "weapons/mp5k/mp5k-fire-sil.wav");
	}
	
	if(!arg_thisWeapon.iIronSight){
		randomChoice = random();
		if(randomChoice < 1/2){
			TS_Weapons_ViewAnimation(weaponseq_mp5k::shoot1, 31.0f/30.0f);
		}else{
			TS_Weapons_ViewAnimation(weaponseq_mp5k::shoot2, 31.0f/30.0f);
		}
	}else{
		randomChoice = random();
		if(randomChoice < 1/2){
			TS_Weapons_ViewAnimation(weaponseq_mp5k::shoot1b, 31.0f/30.0f);
		}else{
			TS_Weapons_ViewAnimation(weaponseq_mp5k::shoot2b, 31.0f/30.0f);
		}
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
w_mp5k_secondary(void)
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

	}else{
		// no scope?  we use ironsights then.
		weapon_ironsight_ToggleIronsight(pl, (weapondata_ironsight_t*)ary_weaponData[WEAPON_ID::MP5K], arg_thisWeapon);
	}
	
}


void
w_mp5k_reload(void)
{
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];

	weapon_ironsight_Reload(pl, (weapondata_ironsight_t*)ary_weaponData[WEAPON_ID::MP5K], arg_thisWeapon);
}


// ???
float
w_mp5k_aimanim(void)
{
	return self.flags & FL_CROUCHING ? ANIM_CR_AIM1HAND : ANIM_AIM1HAND;
}

void
w_mp5k_hud(void)
{
	player pl = (player)self;
	
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	weapon_gun_onDrawHUD(pl, (weapondata_gun_t*)ary_weaponData[WEAPON_ID::MP5K], arg_thisWeapon);

}

// NOPE!  Handled by the buysidemenu, could make this give the instructions for drawing the button
// with the icon if really wanted
void
w_mp5k_hudpic(int selected, vector pos, float a)
{
	//
}

weapon_t w_mp5k =
{
	
	.name		= "mp5k",
	.id			= 0,  // not using this
	.slot		= 2,  // ?
	.slot_pos	= 0,  // not using this
	.weight		= 0,  // not using this
	.draw		= w_mp5k_draw,
	.holster	= w_mp5k_holster,
	.primary	= w_mp5k_primary,
	.secondary	= w_mp5k_secondary,
	.reload		= w_mp5k_reload,
	.release	= NULL,
	.crosshair	= w_mp5k_hud,
	.precache	= w_mp5k_precache,
	.pickup		= NULL,
	.updateammo	= w_mp5k_updateammo,
	.wmodel		= w_mp5k_wmodel,
	.pmodel		= w_mp5k_pmodel,
	.deathmsg	= w_mp5k_deathmsg,
	.aimanim	= w_mp5k_aimanim,
	.hudpic		= NULL
	
};



