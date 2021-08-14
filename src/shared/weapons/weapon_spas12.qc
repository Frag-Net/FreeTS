
enum weaponseq_spas12{
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

void weapon_spas12_onPrimaryAttackRelease(player pl, weapondynamic_t arg_thisWeapon){
	
}
void weapon_spas12_onSecondaryAttackRelease(player pl, weapondynamic_t arg_thisWeapon){
	
}
void weapon_spas12_onThink(player pl, weapondynamic_t arg_thisWeapon){
	weapon_shotgun_onThink_reloadLogic(pl, (weapondata_gun_t*)ary_weaponData[WEAPON_ID::SPAS12], arg_thisWeapon);
}
void weapon_spas12_onColdCock(player pl, weapondynamic_t arg_thisWeapon){
	
}

weapondata_gun_t weapon_spas12 =
{
	WEAPONDATA_TYPEID_GUN,
	"SPAS-12",
	"models/v_spas12.mdl",
	"models/p_spas12.mdl",
	"",
	"models/w_spas12.mdl",
	"sprites/weapons/spas12.spr",
	weapon_spas12_onPrimaryAttackRelease,
	weapon_spas12_onSecondaryAttackRelease,
	weapon_spas12_onThink,
	weapon_spas12_onColdCock,
	weaponseq_spas12::idle,
	weaponseq_spas12::draw,
	31.0f / 30.0f,
	
	//0.0625f,  //fire delay.
	0.24f,
	
	7.0f,  //dmg
	TRUE,
	BITS_WEAPONOPT_LASERSIGHT | BITS_WEAPONOPT_FLASHLIGHT,
	BITS_WEAPONOPT_NONE,
	2100,
	40,
	BUYCATEGORY_SHOTGUNS,
	4,
	{0.040000, 7.000000, 0.000000},
	WEAPON_AKIMBO_UPGRADE_ID::NONE,
	BITS_FIREMODE_PUMP | BITS_FIREMODE_SEMI,
	BITS_FIREMODE_PUMP,
	AMMO_ID::_SHELLS,
	8,  //clip
	4096, //range
	-1,  //shotguns don't use this stat, too complex for one reload sequence.
	0,  //delay.
	-1,
	-1,
	-1,
	-1
};

weapondata_shotgun_extra_t weapon_spas12_shotgunExtra = 
{
	weaponseq_spas12::reload1,
	// cut the time a little
	18.0f/30.0f, //31.0f/30.0f,
	weaponseq_spas12::reload2,
	21.0f/40.0f,
	9.0f/40.0f,
	weaponseq_spas12::reload3,
	31.0f/30.0f
};



void
w_spas12_precache(void)
{
	weapon_precache(ary_weaponData[WEAPON_ID::SPAS12]);
#ifdef SERVER
	precache_sound("weapons/spas12/spas12-fire.wav");
	precache_sound("weapons/spas12/spas12-pump.wav");
#else
	
#endif
}

void
w_spas12_updateammo(player pl)
{
}

string
w_spas12_wmodel(void)
{
	return (*ary_weaponData[WEAPON_ID::SPAS12]).sWorldModelPath;
}

string
w_spas12_pmodel(void)
{
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	return (*ary_weaponData[WEAPON_ID::SPAS12]).sPlayerModelPath;
}

string
w_spas12_deathmsg(void)
{
	return "";
}

void
w_spas12_draw(void)
{
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	
	pl.iShotgunExtraDataID = SHOTGUN_EXTRA_ID::SPAS12;
	
	weapon_base_onEquip(pl, ary_weaponData[WEAPON_ID::SPAS12], arg_thisWeapon);
}

void
w_spas12_holster(void)
{
}


void
w_spas12_primary(void)
{
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];

	if(!weapon_shotgun_onInterrupt(pl, ary_weaponData[WEAPON_ID::SPAS12], arg_thisWeapon)){
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
			
			//SoundPitched_Channel_Send(pl, SNDP_SPAS12_PUMP, CHAN_AUTO);
			TS_Weapons_PlaySoundChannelDirect(pl, "weapons/spas12/spas12-pump.wav", CHAN_AUTO);

			// these pumps eject shells
			weapon_EjectShell(SHELLEJECT_ID::SHOTGUN);
			
			int r = (float)input_sequence % 2;
			if(r == 0){
				TS_Weapons_ViewAnimation(weaponseq_spas12::pump, 31.0f/35.0f);
			}else{
				TS_Weapons_ViewAnimation(weaponseq_spas12::pump2, 31.0f/35.0f);
			}
			
			arg_thisWeapon.bNeedsPump = FALSE;
			weapon_base_setWholeAttackDelay(pl, 14.0f/35.0f);
			return;
		}
	}else{
		arg_thisWeapon.bNeedsPump = FALSE;
	}
	
	// we still want to be able to do a pump on firing the last in the clip
	if (!arg_thisWeapon.iClipLeft || WEAPON_UNDERWATER_CHECK) {
		PLAY_CLICK_SOUND
		return;
	}
	
	SoundPitched_Send(pl, SNDP_SPAS12_FIRE);

	if(arg_thisWeapon.iFireMode == BITS_FIREMODE_PUMP){
		TS_Weapons_ViewAnimation(weaponseq_spas12::shootpump, (31.0f/35.0f) );
		// no shell!  Pumping does that.
		arg_thisWeapon.bNeedsPump = TRUE;
		weapon_ShowMuzzleFlash(MUZZLEFLASH_ID::WEIRD);
	}else{
		TS_Weapons_ViewAnimation(weaponseq_spas12::shootsemi, (31.0f/35.0f) );
		weapon_ClientEffects(MUZZLEFLASH_ID::WEIRD, SHELLEJECT_ID::SHOTGUN);
	}
	
	weapon_base_onAttack_multi(pl, ary_weaponData[WEAPON_ID::SPAS12], arg_thisWeapon, 8, BITS_AKIMBOCHOICE_LEFT);

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
w_spas12_secondary(void)
{
	
}


void
w_spas12_reload(void)
{
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	weapon_shotgun_reload(pl, ary_weaponData[WEAPON_ID::SPAS12], arg_thisWeapon);
}

float
w_spas12_aimanim(void)
{
	return self.flags & FL_CROUCHING ? ANIM_CR_AIM1HAND : ANIM_AIM1HAND;
}

void
w_spas12_hud(void)
{
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	weapon_gun_onDrawHUD(pl, (weapondata_gun_t*)ary_weaponData[WEAPON_ID::SPAS12], arg_thisWeapon);

}

void
w_spas12_hudpic(int selected, vector pos, float a)
{
	//
}


weapon_t w_spas12 =
{
	
	.name		= "spas12",
	.id			= 0,  // not using this
	.slot		= 2,  // ?
	.slot_pos	= 0,  // not using this
	.weight		= 0,  // not using this
	.draw		= w_spas12_draw,
	.holster	= w_spas12_holster,
	.primary	= w_spas12_primary,
	.secondary	= w_spas12_secondary,
	.reload		= w_spas12_reload,
	.release	= NULL,
	.crosshair	= w_spas12_hud,
	.precache	= w_spas12_precache,
	.pickup		= NULL,
	.updateammo	= w_spas12_updateammo,
	.wmodel		= w_spas12_wmodel,
	.pmodel		= w_spas12_pmodel,
	.deathmsg	= w_spas12_deathmsg,
	.aimanim	= w_spas12_aimanim,
	.hudpic		= NULL
	
};


