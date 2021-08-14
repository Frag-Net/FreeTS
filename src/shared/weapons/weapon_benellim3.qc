
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

void weapon_benellim3_onPrimaryAttackRelease(player pl, weapondynamic_t arg_thisWeapon){
	
}
void weapon_benellim3_onSecondaryAttackRelease(player pl, weapondynamic_t arg_thisWeapon){
	
}
void weapon_benellim3_onThink(player pl, weapondynamic_t arg_thisWeapon){
	weapon_shotgun_onThink_reloadLogic(pl, (weapondata_gun_t*)ary_weaponData[WEAPON_ID::BENELLIM3], arg_thisWeapon);
}
void weapon_benellim3_onColdCock(player pl, weapondynamic_t arg_thisWeapon){
	
}

weapondata_gun_t weapon_benellim3 =
{
	WEAPONDATA_TYPEID_GUN,
	"Benelli M3",
	"models/v_m3.mdl",
	"models/p_m3.mdl",
	"",
	"models/w_m3.mdl",
	"sprites/weapons/m3.spr",
	weapon_benellim3_onPrimaryAttackRelease,
	weapon_benellim3_onSecondaryAttackRelease,
	weapon_benellim3_onThink,
	weapon_benellim3_onColdCock,
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

weapondata_shotgun_extra_t weapon_benellim3_shotgunExtra = 
{
	weaponseq_benellim3::reload1,
	21.0f/40.0f,
	weaponseq_benellim3::reload2,
	21.0f/50.0f,
	10.0f/50.0f,
	weaponseq_benellim3::reload3,
	26.0f/30.0f
};



void
w_benellim3_precache(void)
{
	weapon_precache(ary_weaponData[WEAPON_ID::BENELLIM3]);
#ifdef SERVER
	precache_sound("weapons/m3/m3-pump.wav");
	precache_sound("weapons/m3/m3-fire.wav");
#else
	
#endif
}

void
w_benellim3_updateammo(player pl)
{
}

string
w_benellim3_wmodel(void)
{
	return (*ary_weaponData[WEAPON_ID::BENELLIM3]).sWorldModelPath;
}

string
w_benellim3_pmodel(void)
{
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	return (*ary_weaponData[WEAPON_ID::BENELLIM3]).sPlayerModelPath;
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
	
	pl.iShotgunExtraDataID = SHOTGUN_EXTRA_ID::BENELLIM3;
	
	weapon_base_onEquip(pl, ary_weaponData[WEAPON_ID::BENELLIM3], arg_thisWeapon);
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

	if(!weapon_shotgun_onInterrupt(pl, ary_weaponData[WEAPON_ID::BENELLIM3], arg_thisWeapon)){
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
		if(arg_thisWeapon.bNeedsPump){
			// pump instead!
			
			//SoundPitched_Channel_Send(pl, SNDP_BENELLIM3_PUMP, CHAN_AUTO);
			TS_Weapons_PlaySoundChannelDirect(pl, "weapons/m3/m3-pump.wav", CHAN_AUTO);

			// these pumps eject shells
			weapon_EjectShell(SHELLEJECT_ID::SHOTGUN_BLUE);
			
			// why the cast to float here?  No idea
			int r = (float)input_sequence % 2;
			if(r == 0){
				TS_Weapons_ViewAnimation(weaponseq_benellim3::pump, 29.0f/35.0f);
			}else{
				TS_Weapons_ViewAnimation(weaponseq_benellim3::pump2, 25.0f/35.0f);
			}
			
			arg_thisWeapon.bNeedsPump = FALSE;
			weapon_base_setWholeAttackDelay(pl, 15.0f/35.0f);
			return;
		}
	}else{
		// not in PUMP firemode?  Any firing forgets the pump-need if it was set.
		arg_thisWeapon.bNeedsPump = FALSE;
	}
	
	// we still want to be able to do a pump on firing the last in the clip
	if (!arg_thisWeapon.iClipLeft || WEAPON_UNDERWATER_CHECK) {
		PLAY_CLICK_SOUND
		return;
	}
	
// 	TS_Weapons_PlaySoundDirect(pl, "weapons/m3/m3-fire.wav");
	SoundPitched_Send(pl, SNDP_BENELLIM3_FIRE);

	if(arg_thisWeapon.iFireMode == BITS_FIREMODE_PUMP){
		TS_Weapons_ViewAnimation(weaponseq_benellim3::shootpump, (31.0f/35.0f) );
		// no shell!  Pumping does that.
		arg_thisWeapon.bNeedsPump = TRUE;
		weapon_ShowMuzzleFlash(MUZZLEFLASH_ID::WEIRD);
	}else{
		TS_Weapons_ViewAnimation(weaponseq_benellim3::shootsemi, (31.0f/35.0f) );
		weapon_ClientEffects(MUZZLEFLASH_ID::WEIRD, SHELLEJECT_ID::SHOTGUN_BLUE);
	}
	
	weapon_base_onAttack_multi(pl, ary_weaponData[WEAPON_ID::BENELLIM3], arg_thisWeapon, 8, BITS_AKIMBOCHOICE_LEFT);

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
	
	INPUT_SECONDARY_TAP_GATE
	
	/*
	// I doubt this is needed
	if(pl.shotgunReloadIndex > 0){
		return FALSE;
	}
	*/
	
	if(arg_thisWeapon.iBitsUpgrade & BITS_WEAPONOPT_SCOPE){
		// toggle through the zoom.
		pl.iZoomLevel = (pl.iZoomLevel + 1) % 2;
		switch(pl.iZoomLevel){
		case 0:pl.setZoom(1.00f);break;
		case 1:pl.setZoom(0.50f);break;
		}
	}
}

void
w_benellim3_reload(void)
{
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	weapon_shotgun_reload(pl, ary_weaponData[WEAPON_ID::BENELLIM3], arg_thisWeapon);
}

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
	weapon_gun_onDrawHUD(pl, (weapondata_gun_t*)ary_weaponData[WEAPON_ID::BENELLIM3], arg_thisWeapon);

}

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


