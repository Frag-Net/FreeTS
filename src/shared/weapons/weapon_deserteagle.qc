
enum weaponseq_deserteagle{
	idle = 0,
	reload = 1,
	draw = 2,
	shoot1 = 3,
	shoot2 = 4,
	shootlast = 5,
	idleb = 6,
	shootb = 7,
	shootblast = 8,
	change = 9,
	rechange = 10,
	reloadb = 11
};



BOOLEAN weapon_DesertEagle_onPrimaryAttack(player localPlayer, weapondynamic_t arg_thisWeapon, BOOLEAN hasAmmo){
	return TRUE;
}
BOOLEAN weapon_DesertEagle_onPrimaryAttackRelease(player localPlayer, weapondynamic_t arg_thisWeapon, BOOLEAN hasAmmo){
	return FALSE;
}
BOOLEAN weapon_DesertEagle_onSecondaryAttack(player localPlayer, weapondynamic_t arg_thisWeapon, BOOLEAN hasAmmo){
	return FALSE;
}
BOOLEAN weapon_DesertEagle_onSecondaryAttackRelease(player localPlayer, weapondynamic_t arg_thisWeapon, BOOLEAN hasAmmo){
	return FALSE;
}
void weapon_DesertEagle_onEquip(player localPlayer, weapondynamic_t arg_thisWeapon){
	weapon_base_onEquip(localPlayer, ary_weaponData[WEAPON_ID::DesertEagle], arg_thisWeapon);
}
BOOLEAN weapon_DesertEagle_onUnEquip(player localPlayer, weapondynamic_t arg_thisWeapon){
	return FALSE;
}
void weapon_DesertEagle_onThink(player localPlayer, weapondynamic_t arg_thisWeapon){
	weapon_gun_onThink(localPlayer, (weapondata_gun_t*)ary_weaponData[WEAPON_ID::DesertEagle], arg_thisWeapon);
}
void weapon_DesertEagle_onDrawHUD(player localPlayer, weapondynamic_t arg_thisWeapon){
	weapon_gun_onDrawHUD(localPlayer, (weapondata_gun_t*)ary_weaponData[WEAPON_ID::DesertEagle], arg_thisWeapon);
}
void weapon_DesertEagle_onReload(player localPlayer, weapondynamic_t arg_thisWeapon){
}
void weapon_DesertEagle_onColdCock(player localPlayer, weapondynamic_t arg_thisWeapon){
	
}

	
weapondata_ironsight_t weapon_DesertEagle =
{
	WEAPONDATA_TYPEID_IRONSIGHT,
	"Desert Eagle",
	"models/v_desert.mdl",
	"models/p_desert.mdl",
	"models/p_desert.mdl",
	"models/w_desert.mdl",
	"sprites/weapons/desert.spr",
	weapon_DesertEagle_onPrimaryAttack,
	weapon_DesertEagle_onPrimaryAttackRelease,
	weapon_DesertEagle_onSecondaryAttack,
	weapon_DesertEagle_onSecondaryAttackRelease,
	weapon_DesertEagle_onEquip,
	weapon_DesertEagle_onUnEquip,
	weapon_DesertEagle_onThink,
	weapon_DesertEagle_onDrawHUD,
	weapon_DesertEagle_onReload,
	weapon_DesertEagle_onColdCock,
	weaponseq_deserteagle::idle,
	weaponseq_deserteagle::draw,
	31.0f / 50.0f,
	0.35f,  //fire delay. this is most certainly wrong. find something more accurate later.
	27.0f,
	TRUE,
	BITS_WEAPONOPT_SILENCER | BITS_WEAPONOPT_LASERSIGHT | BITS_WEAPONOPT_SCOPE,
	BITS_WEAPONOPT_NONE,
	1050,
	15,
	BUYCATEGORY_HANDGUNS,
	2,
	{0.010000, 2.900000, 0.000000},
	WEAPON_AKIMBO_UPGRADE_ID::NONE,
	BITS_FIREMODE_SEMI,
	BITS_FIREMODE_SEMI,
	AMMO_ID::_p50AE,
	7,
	4096,
	weaponseq_deserteagle::reload,
	93.0f / 42.0f,
	1,
	-1,
	-1,
	2,
	
	//ironsightdata_t
	{
		weaponseq_deserteagle::change,
		21.0f / 35.0f,
		weaponseq_deserteagle::rechange,
		21.0f / 35.0f,
		weaponseq_deserteagle::idleb,
		weaponseq_deserteagle::reloadb,
		93.0f / 42.0f,
		//can have different firestats from ordinary firing.  Dbn't know yet though.
		{0.010000, 2.900000, 0.000000}
	}
};





void
w_deserteagle_precache(void)
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
w_deserteagle_updateammo(player pl)
{
	//weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	//Weapons_UpdateAmmo(pl, arg_thisWeapon.iClipLeft, pl.ary_ammoTotal[AMMO_ID::_9x19mm], -1);
}

string
w_deserteagle_wmodel(void)
{
	return (*ary_weaponData[WEAPON_ID::DesertEagle]).sWorldModelPath;
}

string
w_deserteagle_pmodel(void)
{
	// Do we have the silencer?
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	if(!(arg_thisWeapon.iBitsUpgrade & BITS_WEAPONOPT_SILENCER) ){
		return (*ary_weaponData[WEAPON_ID::DesertEagle]).sPlayerModelPath;
	} else {
		return (*ary_weaponData[WEAPON_ID::DesertEagle]).sPlayerSilencerModelPath;
	}
}

string
w_deserteagle_deathmsg(void)
{
	return "";
}

void
w_deserteagle_draw(void)
{
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	weapondata_basic_t* basicP = ary_weaponData[WEAPON_ID::DesertEagle];
	
	weapon_base_onEquip(pl, basicP, arg_thisWeapon);
}


void
w_deserteagle_holster(void)
{
}


void
w_deserteagle_primary(void)
{
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];

	if (pl.w_attack_next > 0.0) {
		return;
	}
		
	//if(arg_thisWeapon.iFireMode == BITS_FIREMODE_SEMI){
		INPUT_PRIMARY_TAP_GATE
	//}
	
	if (!arg_thisWeapon.iClipLeft || WEAPON_UNDERWATER_CHECK) {
		PLAY_CLICK_SOUND
		return;
	}
	
	
	if(!(arg_thisWeapon.iBitsUpgrade & BITS_WEAPONOPT_SILENCER) ){
		TS_Weapons_PlaySoundDirect(pl, "weapons/deagle/fire.wav");
	} else {
		TS_Weapons_PlaySoundDirect(pl, "weapons/deagle/fire-sil.wav");
	}


	if(!arg_thisWeapon.iIronSight){
		if(arg_thisWeapon.iClipLeft > 0){
			if ( random() <= 0.5 ) {
				TS_Weapons_ViewAnimation(weaponseq_deserteagle::shoot1, 31.0f/30.0f);
			} else {
				TS_Weapons_ViewAnimation(weaponseq_deserteagle::shoot2, 31.0f/30.0f);
			}
		}else{
			// DONT "EndIdle" THIS ONE!
			TS_Weapons_ViewAnimation(weaponseq_deserteagle::shootlast, 31.0f/30.0f);
		}
	}else{
		if(arg_thisWeapon.iClipLeft > 0){
			TS_Weapons_ViewAnimation(weaponseq_deserteagle::shootb, 31.0f/30.0f);
		} else {
			// DONT "EndIdle" THIS ONE!
			TS_Weapons_ViewAnimation(weaponseq_deserteagle::shootblast, 31.0f/30.0f);
		}
	}

#ifdef CLIENT
	View_ShowMuzzleflash(MUZZLE_SMALL);
	View_AddEvent(w_ejectshell_pistol, 0.0f);
#endif
	
	weapon_base_onAttack(pl, ary_weaponData[WEAPON_ID::DesertEagle], arg_thisWeapon, BITS_AKIMBOCHOICE_LEFT);
	
	weapon_base_setWholeAttackDelay(pl, (*ary_weaponData[arg_thisWeapon.weaponID]).fAttackDelay);

	if (self.flags & FL_CROUCHING){
		Animation_PlayerTop(pl, ANIM_CR_SHOOT1HAND, 0.2f);
	}else{
		Animation_PlayerTop(pl, ANIM_SHOOT1HAND, 0.2f);
	}
	
}



void
w_deserteagle_secondary(void)
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
				//pl.viewzoom = 60/80;
				pl.setZoom(0.75f);
				pl.currentZoomChoice++;
			break;}
			case 0:{
				pl.setZoom(1.00f);
				pl.currentZoomChoice = -1;
			break;}
			
		}//END OF switch

	}else{
		// no scope?  we use ironsights then.
		weapon_ironsight_ToggleIronsight(pl, (weapondata_ironsight_t*)ary_weaponData[WEAPON_ID::DesertEagle], arg_thisWeapon);
	}
}

void
w_deserteagle_reload(void)
{
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];

	weapon_ironsight_Reload(pl, (weapondata_ironsight_t*)ary_weaponData[WEAPON_ID::DesertEagle], arg_thisWeapon);
}

// ???
float
w_deserteagle_aimanim(void)
{
	return self.flags & FL_CROUCHING ? ANIM_CR_AIM1HAND : ANIM_AIM1HAND;
}

void
w_deserteagle_hud(void)
{
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	weapon_gun_onDrawHUD(pl, (weapondata_gun_t*)ary_weaponData[WEAPON_ID::DesertEagle], arg_thisWeapon);
}



// NOPE!  Handled by the buysidemenu, could make this give the instructions for drawing the button
// with the icon if really wanted
void
w_deserteagle_hudpic(int selected, vector pos, float a)
{
	//
}


weapon_t w_deserteagle =
{
	
	.name		= "deserteagle",
	.id			= 0,  // not using this
	.slot		= 2,  // ?
	.slot_pos	= 0,  // not using this
	.weight		= 0,  // not using this
	.draw		= w_deserteagle_draw,
	.holster	= w_deserteagle_holster,
	.primary	= w_deserteagle_primary,
	.secondary	= w_deserteagle_secondary,
	.reload		= w_deserteagle_reload,
	.release	= NULL,
	.crosshair	= w_deserteagle_hud,
	.precache	= w_deserteagle_precache,
	.pickup		= NULL,
	.updateammo	= w_deserteagle_updateammo,
	.wmodel		= w_deserteagle_wmodel,
	.pmodel		= w_deserteagle_pmodel,
	.deathmsg	= w_deserteagle_deathmsg,
	.aimanim	= w_deserteagle_aimanim,
	.hudpic		= NULL
	
};

