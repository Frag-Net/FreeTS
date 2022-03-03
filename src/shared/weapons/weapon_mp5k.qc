
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

void weapon_mp5k_onPrimaryAttackRelease(player pl, weapondynamic_t arg_thisWeapon){
	
}
void weapon_mp5k_onSecondaryAttackRelease(player pl, weapondynamic_t arg_thisWeapon){
	
}

void weapon_mp5k_onThink(player pl, weapondynamic_t arg_thisWeapon){
	weapon_gun_onThink(pl, (weapondata_gun_t*)ary_weaponData[WEAPON_ID::MP5K], arg_thisWeapon);
	weapon_gun_onThink_burstFireLogic(pl, (weapondata_gun_t*)ary_weaponData[WEAPON_ID::MP5K], arg_thisWeapon);
}
void weapon_mp5k_onColdCock(player pl, weapondynamic_t arg_thisWeapon){
	
}
void weapon_mp5k_onSetZoomLevel(player pl){
	switch(pl.iZoomLevel){
		case 0:pl.flZoomTarget = 1.00f;break;
		case 1:pl.flZoomTarget = 0.40f;break;
	}
}

weapondata_ironsight_t weapon_mp5k =
{
	WEAPONDATA_TYPEID_IRONSIGHT,
	"MP5K",
	"models/v_mp5k.mdl",
	"models/p_mp5k.mdl",
	"models/p_mp5k_sil.mdl",
	"models/w_mp5k.mdl",
	"sprites/weapons/mp5k.spr",
	weapon_mp5k_onPrimaryAttackRelease,
	weapon_mp5k_onSecondaryAttackRelease,
	weapon_mp5k_onThink,
	weapon_mp5k_onColdCock,
	weapon_mp5k_onSetZoomLevel,
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
	AMMO_ID::_9X19MM,
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
	weapon_precache(ary_weaponData[WEAPON_ID::MP5K]);
#ifdef SERVER
	precache_sound("weapons/mp5k/mp5k-fire-sil.wav");
	precache_sound("weapons/mp5k/mp5k-fire.wav");
#else
	
#endif
}

void
w_mp5k_updateammo(player pl)
{
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
	player pl = (player)self;
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
	
	if(!(arg_thisWeapon.iBitsUpgrade & BITS_WEAPONOPT_SILENCER) ){
		SoundPitched_Send(pl, SNDP_MP5K_FIRE);
	} else {
		SoundPitched_Send(pl, SNDP_MP5K_FIRE_SIL);
	}
	
	int r;
	if(!arg_thisWeapon.iIronSight){
		r = (float)input_sequence % 2;
		if(r == 0){
			TS_Weapons_ViewAnimation(weaponseq_mp5k::shoot1, 31.0f/30.0f);
		}else{
			TS_Weapons_ViewAnimation(weaponseq_mp5k::shoot2, 31.0f/30.0f);
		}
	}else{
		r = (float)input_sequence % 2;
		if(r == 0){
			TS_Weapons_ViewAnimation(weaponseq_mp5k::shoot1b, 31.0f/30.0f);
		}else{
			TS_Weapons_ViewAnimation(weaponseq_mp5k::shoot2b, 31.0f/30.0f);
		}
	}
	
	if(!(arg_thisWeapon.iBitsUpgrade & BITS_WEAPONOPT_SILENCER) ){
		weapon_ClientEffects(MUZZLEFLASH_ID::SMALL, SHELLEJECT_ID::_9MM);
	} else {
		weapon_EjectShell(SHELLEJECT_ID::_9MM);
	}
	
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
w_mp5k_secondary(void)
{
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	
	INPUT_SECONDARY_TAP_GATE
	
	if(arg_thisWeapon.iBitsUpgrade & BITS_WEAPONOPT_SCOPE){
		// toggle through the zoom.
		int newZoomLevel = ((float)pl.iZoomLevel + 1) % 2;
		pl.setZoomLevel(newZoomLevel);
	}else{
		if(pl.w_attack_next > 0){
			return;
		}
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



