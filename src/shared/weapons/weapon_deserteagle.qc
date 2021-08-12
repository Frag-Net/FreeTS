
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

void weapon_deserteagle_onPrimaryAttackRelease(player pl, weapondynamic_t arg_thisWeapon){
	
}
void weapon_deserteagle_onSecondaryAttackRelease(player pl, weapondynamic_t arg_thisWeapon){
	
}
void weapon_deserteagle_onThink(player pl, weapondynamic_t arg_thisWeapon){
	weapon_gun_onThink(pl, (weapondata_gun_t*)ary_weaponData[WEAPON_ID::DESERTEAGLE], arg_thisWeapon);
}
void weapon_deserteagle_onColdCock(player pl, weapondynamic_t arg_thisWeapon){
	
}

weapondata_ironsight_t weapon_deserteagle =
{
	WEAPONDATA_TYPEID_IRONSIGHT,
	"Desert Eagle",
	"models/v_desert.mdl",
	"models/p_desert.mdl",
	"models/p_desert.mdl",
	"models/w_desert.mdl",
	"sprites/weapons/desert.spr",
	weapon_deserteagle_onPrimaryAttackRelease,
	weapon_deserteagle_onSecondaryAttackRelease,
	weapon_deserteagle_onThink,
	weapon_deserteagle_onColdCock,
	weaponseq_deserteagle::idle,
	weaponseq_deserteagle::draw,
	31.0f / 50.0f,
	0.35f,  //fire delay
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
	AMMO_ID::_P50AE,
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
	weapon_precache(ary_weaponData[WEAPON_ID::DESERTEAGLE]);
#ifdef SERVER
	//precache_sound("weapons/deagle/clipin.wav");
	//precache_sound("weapons/deagle/clipout.wav");
	precache_sound("weapons/deagle/fire-sil.wav");
	precache_sound("weapons/deagle/fire.wav");
	//precache_sound("weapons/deagle/slideback.wav");
#else
	
#endif
}

void
w_deserteagle_updateammo(player pl)
{
}

string
w_deserteagle_wmodel(void)
{
	return (*ary_weaponData[WEAPON_ID::DESERTEAGLE]).sWorldModelPath;
}

string
w_deserteagle_pmodel(void)
{
	// Do we have the silencer?
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	if(!(arg_thisWeapon.iBitsUpgrade & BITS_WEAPONOPT_SILENCER) ){
		return (*ary_weaponData[WEAPON_ID::DESERTEAGLE]).sPlayerModelPath;
	} else {
		return (*ary_weaponData[WEAPON_ID::DESERTEAGLE]).sPlayerSilencerModelPath;
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
	weapondata_basic_t* basicP = ary_weaponData[WEAPON_ID::DESERTEAGLE];
	
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
		SoundPitched_Send(pl, SNDP_DESERTEAGLE_FIRE);
	} else {
		SoundPitched_Send(pl, SNDP_DESERTEAGLE_FIRE_SIL);
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

	if(!(arg_thisWeapon.iBitsUpgrade & BITS_WEAPONOPT_SILENCER) ){
		weapon_ClientEffects(MUZZLEFLASH_ID::SMALL, SHELLEJECT_ID::GENERIC);
	} else {
		weapon_EjectShell(SHELLEJECT_ID::GENERIC);
	}
	
	weapon_base_onAttack(pl, ary_weaponData[WEAPON_ID::DESERTEAGLE], arg_thisWeapon, BITS_AKIMBOCHOICE_LEFT);
	
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
		pl.iZoomLevel = (pl.iZoomLevel + 1) % 2;
		switch(pl.iZoomLevel){
			case 0:{
				pl.setZoom(1.00f);
			break;}
			case 1:{
				pl.setZoom(0.75f);
			break;}
		}
	}else{
		// no scope?  we use ironsights then.
		weapon_ironsight_ToggleIronsight(pl, (weapondata_ironsight_t*)ary_weaponData[WEAPON_ID::DESERTEAGLE], arg_thisWeapon);
	}
}

void
w_deserteagle_reload(void)
{
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];

	weapon_ironsight_Reload(pl, (weapondata_ironsight_t*)ary_weaponData[WEAPON_ID::DESERTEAGLE], arg_thisWeapon);
}

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
	weapon_gun_onDrawHUD(pl, (weapondata_gun_t*)ary_weaponData[WEAPON_ID::DESERTEAGLE], arg_thisWeapon);
}

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

