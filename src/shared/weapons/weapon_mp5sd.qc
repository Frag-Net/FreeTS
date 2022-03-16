
enum weaponseq_mp5sd{
	idle,
	shoot1,
	shoot2,
	shoot3,
	draw,
	reload
};

void weapon_mp5sd_onPrimaryAttackRelease(player pl, weapondynamic_t arg_thisWeapon){
	
}
void weapon_mp5sd_onSecondaryAttackRelease(player pl, weapondynamic_t arg_thisWeapon){
	
}
void weapon_mp5sd_onThink(player pl, weapondynamic_t arg_thisWeapon){
	weapon_gun_onThink(pl, (weapondata_gun_t*)ary_weaponData[WEAPON_ID::MP5SD], arg_thisWeapon);
	weapon_gun_onThink_burstFireLogic(pl, (weapondata_gun_t*)ary_weaponData[WEAPON_ID::MP5SD], arg_thisWeapon);
}
void weapon_mp5sd_onColdCock(player pl, weapondynamic_t arg_thisWeapon){
	
}
void weapon_mp5sd_onSetZoomLevel(player pl){
	switch(pl.iZoomLevel){
	case 0:pl.flZoomTarget = 1.00f;break;
	case 1:pl.flZoomTarget = 0.40f;break;
	}
}

weapondata_gun_t weapon_mp5sd =
{
	WEAPONDATA_TYPEID_GUN,
	"MP5 SD",
	"models/v_mp5sd.mdl",
	"models/p_mp5sd.mdl",
	"",
	"models/w_mp5sd.mdl",
	"sprites/weapons/mp5sd.spr",
	weapon_mp5sd_onPrimaryAttackRelease,
	weapon_mp5sd_onSecondaryAttackRelease,
	weapon_mp5sd_onThink,
	weapon_mp5sd_onColdCock,
	weapon_mp5sd_onSetZoomLevel,
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
	AMMO_ID::_9X19MM,
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
	weapon_precache(ary_weaponData[WEAPON_ID::MP5SD]);
#ifdef SERVER
	precache_sound("weapons/mp5sd/mp5sd-fire.wav");
#else
	
#endif
}

void
w_mp5sd_updateammo(player pl)
{
}

string
w_mp5sd_wmodel(void)
{
	return (*ary_weaponData[WEAPON_ID::MP5SD]).sWorldModelPath;
}

string
w_mp5sd_pmodel(player pl)
{
	// Do we have the silencer?
	// Oh.  Guaranteed for the mp5.  Oh well.
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
w_mp5sd_draw(player pl)
{
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	
	weapon_base_onEquip(pl, ary_weaponData[WEAPON_ID::MP5SD], arg_thisWeapon);
}

void
w_mp5sd_holster(player pl)
{
}

void
w_mp5sd_primary(player pl)
{
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];

	if (pl.w_attack_next > 0.0) {
		return;
	}
	
	if(arg_thisWeapon.iFireMode == BITS_FIREMODE_SEMI || arg_thisWeapon.iFireMode == BITS_FIREMODE_BURST){
		INPUT_PRIMARY_TAP_GATE
	}
	
	if(
		pl.aryNextBurstShotTime_listenIndex != -1 &&
		arg_thisWeapon.iFireMode != BITS_FIREMODE_NONE
	){
		// the player is trying to manually fire while burst-fire is in the middle
		// of sending shots?  STOP
		return;
	}
	
	if (!arg_thisWeapon.iClipLeft || WEAPON_UNDERWATER_CHECK) {
		PLAY_CLICK_SOUND
		return;
	}
	
	// silencer only!
	SoundPitched_Send(pl, SNDP_MP5SD_FIRE);


	int r = (float)input_sequence % 3;
	if(r == 0){
		TS_Weapons_ViewAnimation(pl, weaponseq_mp5sd::shoot1, 31.0f/30.0f);
	}else if(r == 1){
		TS_Weapons_ViewAnimation(pl, weaponseq_mp5sd::shoot2, 31.0f/30.0f);
	}else{
		TS_Weapons_ViewAnimation(pl, weaponseq_mp5sd::shoot3, 31.0f/30.0f);
	}
	
	weapon_EjectShell(SHELLEJECT_ID::_9MM);
	
	if(arg_thisWeapon.iFireMode == BITS_FIREMODE_BURST)
	{
		weapon_gun_burstFire(pl, (weapondata_gun_t*)ary_weaponData[WEAPON_ID::MP5SD], arg_thisWeapon, BITS_AKIMBOCHOICE_LEFT, 3, 0.02, 0.18);
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
w_mp5sd_secondary(player pl)
{
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	
	INPUT_SECONDARY_TAP_GATE
	
	if(arg_thisWeapon.iBitsUpgrade & BITS_WEAPONOPT_SCOPE){
		// toggle through the zoom.
		int newZoomLevel = ((float)pl.iZoomLevel + 1) % 2;
		pl.setZoomLevel(newZoomLevel);
	}
	
}


void
w_mp5sd_reload(player pl)
{
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];

	weapon_gun_Reload(pl, (weapondata_gun_t*)ary_weaponData[WEAPON_ID::MP5SD], arg_thisWeapon);
}

float
w_mp5sd_aimanim(player pl)
{
	return self.flags & FL_CROUCHING ? ANIM_CR_AIM1HAND : ANIM_AIM1HAND;
}

void
w_mp5sd_hud(player pl)
{
	
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	weapon_gun_onDrawHUD(pl, (weapondata_gun_t*)ary_weaponData[WEAPON_ID::MP5SD], arg_thisWeapon);

}

void
w_mp5sd_hudpic(player pl, int selected, vector pos, float a)
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
	.postdraw	= w_mp5sd_hud,
	.precache	= w_mp5sd_precache,
	.pickup		= NULL,
	.updateammo	= w_mp5sd_updateammo,
	.wmodel		= w_mp5sd_wmodel,
	.pmodel		= w_mp5sd_pmodel,
	.deathmsg	= w_mp5sd_deathmsg,
	.aimanim	= w_mp5sd_aimanim,
	.hudpic		= NULL
	
};

