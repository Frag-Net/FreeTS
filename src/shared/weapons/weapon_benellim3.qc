

enum weaponseq_benellim3{
	idle,
	idle2,
	reload1,
	reload2,
	reload3,
	draw,
	shootsemi,
	shootpump,
	pump,
	pump2
};


BOOLEAN weapon_BenelliM3_onPrimaryAttack(player localPlayer, weapondynamic_t arg_thisWeapon, BOOLEAN hasAmmo){
	return TRUE;
}
BOOLEAN weapon_BenelliM3_onPrimaryAttackRelease(player localPlayer, weapondynamic_t arg_thisWeapon, BOOLEAN hasAmmo){
	return FALSE;
}
BOOLEAN weapon_BenelliM3_onSecondaryAttack(player localPlayer, weapondynamic_t arg_thisWeapon, BOOLEAN hasAmmo){
	return FALSE;
}
BOOLEAN weapon_BenelliM3_onSecondaryAttackRelease(player localPlayer, weapondynamic_t arg_thisWeapon, BOOLEAN hasAmmo){
	return FALSE;
}

void weapon_BenelliM3_onEquip(player localPlayer, weapondynamic_t arg_thisWeapon){
}
BOOLEAN weapon_BenelliM3_onUnEquip(player localPlayer, weapondynamic_t arg_thisWeapon){
	return FALSE;
}
void weapon_BenelliM3_onThink(player localPlayer, weapondynamic_t arg_thisWeapon){
	weapon_shotgun_onThink_reloadLogic(localPlayer, (weapondata_gun_t*)ary_weaponData[WEAPON_ID::BenelliM3], arg_thisWeapon);
}
void weapon_BenelliM3_onDrawHUD(player localPlayer, weapondynamic_t arg_thisWeapon){
}
void weapon_BenelliM3_onReload(player localPlayer, weapondynamic_t arg_thisWeapon){
}
void weapon_BenelliM3_onColdCock(player localPlayer, weapondynamic_t arg_thisWeapon){
}


weapondata_gun_t weapon_BenelliM3 =
{
	WEAPONDATA_TYPEID_GUN,
	"Benelli M3",
	"models/v_m3.mdl",
	"models/p_m3.mdl",
	"",
	"models/w_m3.mdl",
	"sprites/weapons/m3.spr",
	weapon_BenelliM3_onPrimaryAttack,
	weapon_BenelliM3_onPrimaryAttackRelease,
	weapon_BenelliM3_onSecondaryAttack,
	weapon_BenelliM3_onSecondaryAttackRelease,
	weapon_BenelliM3_onEquip,
	weapon_BenelliM3_onUnEquip,
	weapon_BenelliM3_onThink,
	weapon_BenelliM3_onDrawHUD,
	weapon_BenelliM3_onReload,
	weapon_BenelliM3_onColdCock,
	weaponseq_benellim3::idle,
	weaponseq_benellim3::draw,
	31.0f / 30.0f,
	//0.0625f,  //fire delay.
	0.24f,
	7.0f,  //dmg
	TRUE,
	BITS_WEAPONOPT_LASERSIGHT | BITS_WEAPONOPT_FLASHLIGHT | BITS_WEAPONOPT_SCOPE,
	BITS_WEAPONOPT_NONE,
	3000,
	40,
	BUYCATEGORY_SHOTGUNS,
	4,
	{0.038000, 8.000000, 0.000000},
	WEAPON_AKIMBO_UPGRADE_ID::NONE,
	BITS_FIREMODE_PUMP | BITS_FIREMODE_SEMI,
	BITS_FIREMODE_PUMP,
	AMMO_ID::_SHELLS,
	7,  //clip
	4096, //range
	-1,  //shotguns don't use this stat, too complex for one reload sequence.
	0,  //delay.
	-1,
	2,
	2,
	1
};




void
w_benellim3_precache(void)
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
w_benellim3_updateammo(player pl)
{
	//weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	//Weapons_UpdateAmmo(pl, arg_thisWeapon.iClipLeft, pl.ary_ammoTotal[AMMO_ID::_9x19mm], -1);
}

string
w_benellim3_wmodel(void)
{
	return (*ary_weaponData[WEAPON_ID::BenelliM3]).sWorldModelPath;
}

string
w_benellim3_pmodel(void)
{
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	return (*ary_weaponData[WEAPON_ID::BenelliM3]).sPlayerModelPath;
}

string
w_benellim3_deathmsg(void)
{
	return "";
}

void
w_benellim3_draw(void)
{
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	
	//shotgun reload settings: shared
	pl.shotgunReload1_seq = weaponseq_benellim3::reload1;
	pl.shotgunReload1_Duration = 21.0f/40.0f;
	pl.shotgunReload2_seq = weaponseq_benellim3::reload2;
	pl.shotgunReload2_Duration = 21.0f/50.0f;
	pl.shotgunReload3_seq = weaponseq_benellim3::reload3;
	pl.shotgunReload3_Duration = 26.0f/30.0f;
	
	
	pl.shotgunReload2_ammoLoadDelay = 10.0f/50.0f;
	
	weapon_base_onEquip(pl, ary_weaponData[WEAPON_ID::BenelliM3], arg_thisWeapon);
}



void
w_benellim3_holster(void)
{
}


void
w_benellim3_primary(void)
{
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];

	if(!weapon_shotgun_onInterrupt(pl, ary_weaponData[WEAPON_ID::BenelliM3], arg_thisWeapon)){
		// no reload to interrupt?  ok.
	}else{
		// reload to interrupt?  stop this.
		return;
	}
	
	
	// good place?  should this go above onInterrupt above?
	if (pl.w_attack_next > 0.0) {
		return;
	}
	
	
	if(arg_thisWeapon.iFireMode == BITS_FIREMODE_SEMI){
		INPUT_PRIMARY_TAP_GATE
	}
	
	
	if(arg_thisWeapon.iFireMode == BITS_FIREMODE_PUMP){
		if(pl.shotgunWaitingForPump){
			// pump instead!
			pl.shotgunWaitingForPump = FALSE;
			
 			TS_Weapons_PlaySoundChannelDirect(pl, "weapons/m3/m3-pump.wav", CHAN_AUTO);
			
			// these pumps eject shells
#ifdef CLIENT
				View_AddEvent(w_ejectshell_pistol, 0.0f);
#endif
			
			// float randomChoice = random();
			// why the cast to float here?  No idea
			int r = (float)input_sequence % 2;
			if(r == 0){
				TS_Weapons_ViewAnimation(weaponseq_benellim3::pump, 29.0f/35.0f);
			}else{
				TS_Weapons_ViewAnimation(weaponseq_benellim3::pump2, 25.0f/35.0f);
			}
			
			weapon_base_setWholeAttackDelay(pl, 15.0f/35.0f);
			return;
		}
	}else{
		pl.shotgunWaitingForPump = FALSE;
	}
	
	// we still want to be able to do a pump on firing the last in the clip
	if (!arg_thisWeapon.iClipLeft || WEAPON_UNDERWATER_CHECK) {
		PLAY_CLICK_SOUND
		return;
	}
	
// 	TS_Weapons_PlaySoundDirect(pl, "weapons/m3/m3-fire.wav");
	SoundPitched_Send(pl, SNDP_M3_FIRE);

	if(arg_thisWeapon.iFireMode == BITS_FIREMODE_PUMP){
		TS_Weapons_ViewAnimation(weaponseq_benellim3::shootpump, (31.0f/35.0f) );
		// no shell!  Pumping does that here.
		pl.shotgunWaitingForPump = TRUE;
#ifdef CLIENT
			View_ShowMuzzleflash(MUZZLE_SMALL);
			// no shell, that comes in the pump soon after.
#endif
	}else{
		TS_Weapons_ViewAnimation(weaponseq_benellim3::shootsemi, (31.0f/35.0f) );
#ifdef CLIENT
			View_ShowMuzzleflash(MUZZLE_SMALL);
			View_AddEvent(w_ejectshell_pistol, 0.0f);
#endif
	}
	
	weapon_base_onAttack_multi(pl, ary_weaponData[WEAPON_ID::BenelliM3], arg_thisWeapon, 8, BITS_AKIMBOCHOICE_LEFT);

	if(arg_thisWeapon.iFireMode == BITS_FIREMODE_PUMP){
		// use the TS stats for delay.
		weapon_base_setWholeAttackDelay(pl, (*ary_weaponData[arg_thisWeapon.weaponID]).fAttackDelay);
	}else{
		// rapid!
		weapon_base_setWholeAttackDelay(pl, 0.0625f);
	}
	
	if (self.flags & FL_CROUCHING){
		Animation_PlayerTop(pl, ANIM_CR_SHOOT1HAND, 0.2f);
	}else{
		Animation_PlayerTop(pl, ANIM_SHOOT1HAND, 0.2f);
	}
	
}


void
w_benellim3_secondary(void)
{
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	
	if(pl.w_attack_next > 0){
		return;
	}
	
	INPUT_SECONDARY_TAP_GATE
	
	/*
	// I doubt this is needed
	if(pl.shotgunReloadIndex > 0){
		return FALSE;
	}
	*/
	
	if(arg_thisWeapon.iBitsUpgrade & BITS_WEAPONOPT_SCOPE){
		// toggle through the zoom.
		switch(pl.currentZoomChoice){
			case -1:{
				//pl.viewzoom = 40/80;
				pl.setZoom(0.5f);
				pl.currentZoomChoice++;
			break;}
			case 0:{
				pl.setZoom(1.00f);
				pl.currentZoomChoice = -1;
			break;}
			
		}//END OF switch

	}else{
		// no ironsight for this
	}
}


void
w_benellim3_reload(void)
{
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	weapon_shotgun_reload(pl, ary_weaponData[WEAPON_ID::BenelliM3], arg_thisWeapon);
}


// ???
float
w_benellim3_aimanim(void)
{
	return self.flags & FL_CROUCHING ? ANIM_CR_AIM1HAND : ANIM_AIM1HAND;
}

void
w_benellim3_hud(void)
{
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	weapon_gun_onDrawHUD(pl, (weapondata_gun_t*)ary_weaponData[WEAPON_ID::BenelliM3], arg_thisWeapon);

}

// NOPE!  Handled by the buysidemenu, could make this give the instructions for drawing the button
// with the icon if really wanted
void
w_benellim3_hudpic(int selected, vector pos, float a)
{
	//
}


weapon_t w_benellim3 =
{
	
	.name		= "benellim3",
	.id			= 0,  // not using this
	.slot		= 2,  // ?
	.slot_pos	= 0,  // not using this
	.weight		= 0,  // not using this
	.draw		= w_benellim3_draw,
	.holster	= w_benellim3_holster,
	.primary	= w_benellim3_primary,
	.secondary	= w_benellim3_secondary,
	.reload		= w_benellim3_reload,
	.release	= NULL,
	.crosshair	= w_benellim3_hud,
	.precache	= w_benellim3_precache,
	.pickup		= NULL,
	.updateammo	= w_benellim3_updateammo,
	.wmodel		= w_benellim3_wmodel,
	.pmodel		= w_benellim3_pmodel,
	.deathmsg	= w_benellim3_deathmsg,
	.aimanim	= w_benellim3_aimanim,
	.hudpic		= NULL
	
};


