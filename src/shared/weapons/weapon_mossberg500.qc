
enum weaponseq_mossberg500{
	idle,
	shoot,
	pump,
	idleb,
	shootb,
	pumpb,
	pumpb2,
	draw,
	reload1,
	reload2,
	reload3,
	change,
	rechange,
	reload1b,
	reload2b,
	reload3b
};

void weapon_mossberg500_onPrimaryAttackRelease(player pl, weapondynamic_t arg_thisWeapon){
	
}
void weapon_mossberg500_onSecondaryAttackRelease(player pl, weapondynamic_t arg_thisWeapon){
	
}

void weapon_mossberg500_onThink(player pl, weapondynamic_t arg_thisWeapon){
	weapon_shotgun_onThink_reloadLogic(pl, (weapondata_gun_t*)ary_weaponData[WEAPON_ID::MOSSBERG500], arg_thisWeapon);
}
void weapon_mossberg500_onColdCock(player pl, weapondynamic_t arg_thisWeapon){
	
}

weapondata_ironsight_t weapon_mossberg500 =
{
	WEAPONDATA_TYPEID_IRONSIGHT,
	"Mossberg 500",
	"models/v_mossberg.mdl",
	"models/p_mossberg.mdl",
	"",
	"models/w_mossberg.mdl",
	"sprites/weapons/mossberg.spr",
	weapon_mossberg500_onPrimaryAttackRelease,
	weapon_mossberg500_onSecondaryAttackRelease,
	weapon_mossberg500_onThink,
	weapon_mossberg500_onColdCock,
	weaponseq_mossberg500::idle,
	weaponseq_mossberg500::draw,
	31.0f / 35.0f,
	
	//0.0625f,  //fire delay.
	0.24f,
	
	7.0f,  //dmg
	TRUE,
	BITS_WEAPONOPT_LASERSIGHT | BITS_WEAPONOPT_FLASHLIGHT,
	BITS_WEAPONOPT_NONE,
	2500,
	40,
	BUYCATEGORY_SHOTGUNS,
	4,
	{0.042000, 8.400000, 0.000000},
	WEAPON_AKIMBO_UPGRADE_ID::NONE,
	BITS_FIREMODE_PUMP,
	BITS_FIREMODE_PUMP,
	AMMO_ID::_SHELLS,
	8,  //clip
	4096, //range
	-1,  //shotguns don't use this stat, too complex for one reload sequence.
	0,  //delay.
	-1,
	2,
	1,
	-1,
	{
		weaponseq_mossberg500::change,
		21.0f/40.0f,
		weaponseq_mossberg500::rechange,
		21.0f/40.0f,
		weaponseq_mossberg500::idleb,
		-1,  //shotgun.. doesn't use this.
		0,
		{0.042000, 8.400000, 0.000000}
	}
};

weapondata_shotgun_extra_t weapon_mossberg500_shotgunExtra = 
{
	weaponseq_mossberg500::reload1,
	21.0f/40.0f,
	weaponseq_mossberg500::reload2,
	21.0f/50.0f,
	10.0f/50.0f,
	weaponseq_mossberg500::reload3,
	26.0f/30.0f
};
weapondata_shotgun_extra_t weapon_mossberg500_shotgunExtra_ironsight = 
{
	weaponseq_mossberg500::reload1b,
	21.0f/40.0f,
	weaponseq_mossberg500::reload2b,
	21.0f/50.0f,
	10.0f/50.0f,
	weaponseq_mossberg500::reload3b,
	26.0f/30.0f
};



void
w_mossberg500_precache(void)
{
	weapon_precache(ary_weaponData[WEAPON_ID::MOSSBERG500]);
#ifdef SERVER
	precache_sound("weapons/mossberg/fire.wav");
	// uses the benelli m3's pump sound, but that's precached there.
#else
	
#endif
}

void
w_mossberg500_updateammo(player pl)
{
}

string
w_mossberg500_wmodel(void)
{
	return (*ary_weaponData[WEAPON_ID::MOSSBERG500]).sWorldModelPath;
}

string
w_mossberg500_pmodel(void)
{
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	return (*ary_weaponData[WEAPON_ID::MOSSBERG500]).sPlayerModelPath;
}

string
w_mossberg500_deathmsg(void)
{
	return "";
}

void
w_mossberg500_draw(void)
{
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	
	// not setting shotgun extra data here, done right before reload anims are called
	// since being ironsight/not each has a set of sequences.
	
	weapon_base_onEquip(pl, ary_weaponData[WEAPON_ID::MOSSBERG500], arg_thisWeapon);
}



void
w_mossberg500_holster(void)
{
}


void
w_mossberg500_primary(void)
{
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];

	if(!weapon_shotgun_onInterrupt(pl, ary_weaponData[WEAPON_ID::MOSSBERG500], arg_thisWeapon)){
		// no reload to interrupt?  ok.
	}else{
		// reload to interrupt?  stop this.
		return;
	}
	
	// good place?  should this go above onInterrupt above?
	if (pl.w_attack_next > 0.0) {
		return;
	}
	
	
	//if(arg_thisWeapon.iFireMode == BITS_FIREMODE_PUMP){
		if(pl.shotgunWaitingForPump){
			// pump instead!
			pl.shotgunWaitingForPump = FALSE;
			
			// Sounds like the mossberg just re-uses the benelli m3's sound,
			// as the mossberg sound folder lacks a pump sound.
			//SoundPitched_Channel_Send(pl, SNDP_BENELLIM3_PUMP, CHAN_AUTO);
			TS_Weapons_PlaySoundChannelDirect(pl, "weapons/m3/m3-pump.wav", CHAN_AUTO);

			// these pumps eject shells
			weapon_EjectShell(SHELLEJECT_ID::SHOTGUN_GOLD);
			
			if(!arg_thisWeapon.iIronSight){
				TS_Weapons_ViewAnimation(weaponseq_mossberg500::pump, 31.0f/35.0f);
			}else{
				int r = (float)input_sequence % 2;
				if(r == 0){
					TS_Weapons_ViewAnimation(weaponseq_mossberg500::pumpb, 31.0f/35.0f);
				}else{
					TS_Weapons_ViewAnimation(weaponseq_mossberg500::pumpb2, 31.0f/35.0f);
				}
			}
			
			weapon_base_setWholeAttackDelay(pl, 14.0f/35.0f);
			return;
		}
	//}
	
	// we still want to be able to do a pump on firing the last in the clip
	if (!arg_thisWeapon.iClipLeft || WEAPON_UNDERWATER_CHECK) {
		PLAY_CLICK_SOUND
		return;
	}
	
	SoundPitched_Send(pl, SNDP_MOSSBERG500_FIRE);
	
	// the mossberg only has pump action

	//if(arg_thisWeapon.iFireMode == BITS_FIREMODE_PUMP){
		if(!arg_thisWeapon.iIronSight){
			TS_Weapons_ViewAnimation(weaponseq_mossberg500::shoot, 31.0f/35.0f);
		}else{
			TS_Weapons_ViewAnimation(weaponseq_mossberg500::shootb, 31.0f/35.0f);
		}
		
		// no shell!  Pumping does that.
		pl.shotgunWaitingForPump = TRUE;
		weapon_ShowMuzzleFlash(MUZZLEFLASH_ID::WEIRD);
	//}
	
	weapon_base_onAttack_multi(pl, ary_weaponData[WEAPON_ID::MOSSBERG500], arg_thisWeapon, 8, BITS_AKIMBOCHOICE_LEFT);

	//if(arg_thisWeapon.iFireMode == BITS_FIREMODE_PUMP){
		// use the TS stats for delay.
		weapon_base_setWholeAttackDelay(pl, (*ary_weaponData[arg_thisWeapon.weaponID]).fAttackDelay);
	//}
	
	if (self.flags & FL_CROUCHING){
		Animation_PlayerTop(pl, ANIM_CR_SHOOT1HAND, 0.2f);
	}else{
		Animation_PlayerTop(pl, ANIM_SHOOT1HAND, 0.2f);
	}
	
}


void
w_mossberg500_secondary(void)
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
	
	weapon_ironsight_ToggleIronsight(pl, (weapondata_ironsight_t*)ary_weaponData[WEAPON_ID::MOSSBERG500], arg_thisWeapon);
}


void
w_mossberg500_reload(void)
{
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	
	if(!arg_thisWeapon.iIronSight){
		pl.iShotgunExtraDataID = SHOTGUN_EXTRA_ID::MOSSBERG500;
	}else{
		pl.iShotgunExtraDataID = SHOTGUN_EXTRA_ID::MOSSBERG500_IRONSIGHT;
	}
	
	weapon_shotgun_reload(pl, ary_weaponData[WEAPON_ID::MOSSBERG500], arg_thisWeapon);
}

float
w_mossberg500_aimanim(void)
{
	return self.flags & FL_CROUCHING ? ANIM_CR_AIM1HAND : ANIM_AIM1HAND;
}

void
w_mossberg500_hud(void)
{
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	weapon_gun_onDrawHUD(pl, (weapondata_gun_t*)ary_weaponData[WEAPON_ID::MOSSBERG500], arg_thisWeapon);

}

void
w_mossberg500_hudpic(int selected, vector pos, float a)
{
	//
}


weapon_t w_mossberg500 =
{
	
	.name		= "mossberg500",
	.id			= 0,  // not using this
	.slot		= 2,  // ?
	.slot_pos	= 0,  // not using this
	.weight		= 0,  // not using this
	.draw		= w_mossberg500_draw,
	.holster	= w_mossberg500_holster,
	.primary	= w_mossberg500_primary,
	.secondary	= w_mossberg500_secondary,
	.reload		= w_mossberg500_reload,
	.release	= NULL,
	.crosshair	= w_mossberg500_hud,
	.precache	= w_mossberg500_precache,
	.pickup		= NULL,
	.updateammo	= w_mossberg500_updateammo,
	.wmodel		= w_mossberg500_wmodel,
	.pmodel		= w_mossberg500_pmodel,
	.deathmsg	= w_mossberg500_deathmsg,
	.aimanim	= w_mossberg500_aimanim,
	.hudpic		= NULL
	
};

