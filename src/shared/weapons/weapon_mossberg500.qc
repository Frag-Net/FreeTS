
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


BOOLEAN weapon_Mossberg500_onPrimaryAttack(player localPlayer, weapondynamic_t arg_thisWeapon, BOOLEAN hasAmmo){
	return TRUE;
}
BOOLEAN weapon_Mossberg500_onPrimaryAttackRelease(player localPlayer, weapondynamic_t arg_thisWeapon, BOOLEAN hasAmmo){
	return FALSE;
}
BOOLEAN weapon_Mossberg500_onSecondaryAttack(player localPlayer, weapondynamic_t arg_thisWeapon, BOOLEAN hasAmmo){
	return FALSE;
}
BOOLEAN weapon_Mossberg500_onSecondaryAttackRelease(player localPlayer, weapondynamic_t arg_thisWeapon, BOOLEAN hasAmmo){
	return FALSE;
}

void weapon_Mossberg500_onEquip(player localPlayer, weapondynamic_t arg_thisWeapon){
}
BOOLEAN weapon_Mossberg500_onUnEquip(player localPlayer, weapondynamic_t arg_thisWeapon){
	return FALSE;
}
void weapon_Mossberg500_onThink(player localPlayer, weapondynamic_t arg_thisWeapon){
	//weapon_gun_onThink(localPlayer, (weapondata_gun_t*)ary_weaponData[WEAPON_ID::Mossberg500], arg_thisWeapon);
	weapon_shotgun_onThink_reloadLogic(localPlayer, (weapondata_gun_t*)ary_weaponData[WEAPON_ID::Mossberg500], arg_thisWeapon);
}
void weapon_Mossberg500_onDrawHUD(player localPlayer, weapondynamic_t arg_thisWeapon){
	weapon_gun_onDrawHUD(localPlayer, (weapondata_gun_t*)ary_weaponData[WEAPON_ID::Mossberg500], arg_thisWeapon);
}
void weapon_Mossberg500_onReload(player localPlayer, weapondynamic_t arg_thisWeapon){
}
void weapon_Mossberg500_onColdCock(player localPlayer, weapondynamic_t arg_thisWeapon){
	
}

	
weapondata_ironsight_t weapon_Mossberg500 =
{
	WEAPONDATA_TYPEID_IRONSIGHT,
	"Mossberg 500",
	"models/v_mossberg.mdl",
	"models/p_mossberg.mdl",
	"",
	"models/w_mossberg.mdl",
	"sprites/weapons/mossberg.spr",
	weapon_Mossberg500_onPrimaryAttack,
	weapon_Mossberg500_onPrimaryAttackRelease,
	weapon_Mossberg500_onSecondaryAttack,
	weapon_Mossberg500_onSecondaryAttackRelease,
	weapon_Mossberg500_onEquip,
	weapon_Mossberg500_onUnEquip,
	weapon_Mossberg500_onThink,
	weapon_Mossberg500_onDrawHUD,
	weapon_Mossberg500_onReload,
	weapon_Mossberg500_onColdCock,
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





void
w_mossberg500_precache(void)
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
w_mossberg500_updateammo(player pl)
{
	//weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	//Weapons_UpdateAmmo(pl, arg_thisWeapon.iClipLeft, pl.ary_ammoTotal[AMMO_ID::_9x19mm], -1);
}

string
w_mossberg500_wmodel(void)
{
	return (*ary_weaponData[WEAPON_ID::Mossberg500]).sWorldModelPath;
}

string
w_mossberg500_pmodel(void)
{
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	return (*ary_weaponData[WEAPON_ID::Mossberg500]).sPlayerModelPath;
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
	
	// not setting shotgun stats here, save right before reload anims are called
	// since being ironsight or not each gives its own set of sequences.
	
	weapon_base_onEquip(pl, ary_weaponData[WEAPON_ID::Mossberg500], arg_thisWeapon);
}



void
w_mossberg500_holster(void)
{
}


void
w_mossberg500_primary(void)
{
	float randomChoice;
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];

	if(!weapon_shotgun_onInterrupt(pl, ary_weaponData[WEAPON_ID::Mossberg500], arg_thisWeapon)){
		// no reload to interrupt?  ok.
	}else{
		// reload to interrupt?  stop this.
		return;
	}
	
	// good place?  should this go above onInterrupt above?
	if (pl.w_attack_next > 0.0) {
		return;
	}
	
	/*
	if(arg_thisWeapon.iFireMode == BITS_FIREMODE_SEMI){
		INPUT_PRIMARY_TAP_GATE
	}
	*/
	
	//if(arg_thisWeapon.iFireMode == BITS_FIREMODE_PUMP){
		if(pl.shotgunWaitingForPump){
			// pump instead!
			pl.shotgunWaitingForPump = FALSE;
			
			// Sounds like the mossberg just re-uses the benelli m3's sound,
			// as the mossberg sound folder lacks a pump sound.
			TS_Weapons_PlaySoundChannelDirect(pl, "weapons/m3/m3-pump.wav", CHAN_AUTO);
			
			// these pumps eject shells
			#ifdef CLIENT
				View_AddEvent(w_ejectshell_pistol, 0.0f);
			#endif
			
			if(!arg_thisWeapon.iIronSight){
				TS_Weapons_ViewAnimation(weaponseq_mossberg500::pump, 31.0f/35.0f);
			}else{
				randomChoice = random();
				if(randomChoice > 0.5){
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
	
	TS_Weapons_PlaySoundDirect(pl, "weapons/mossberg/fire.wav");
	
	// the mossberg only has pump action

	//if(arg_thisWeapon.iFireMode == BITS_FIREMODE_PUMP){
		if(!arg_thisWeapon.iIronSight){
			TS_Weapons_ViewAnimation(weaponseq_mossberg500::shoot, 31.0f/35.0f);
		}else{
			TS_Weapons_ViewAnimation(weaponseq_mossberg500::shootb, 31.0f/35.0f);
		}
		
		// no shell!  Pumping does that here.
		pl.shotgunWaitingForPump = TRUE;
		
		#ifdef CLIENT
			View_ShowMuzzleflash(MUZZLE_SMALL);
			// no shell, that comes in the pump soon after.
		#endif
	//}
	
	weapon_base_onAttack_multi(pl, ary_weaponData[WEAPON_ID::Mossberg500], arg_thisWeapon, 8, BITS_AKIMBOCHOICE_LEFT);

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
	
	return weapon_ironsight_ToggleIronsight(pl, (weapondata_ironsight_t*)ary_weaponData[WEAPON_ID::Mossberg500], arg_thisWeapon);
}


void
w_mossberg500_reload(void)
{
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	
		
	if(!arg_thisWeapon.iIronSight){
		//shotgun reload settings: shared
		pl.shotgunReload1_seq = weaponseq_mossberg500::reload1;
		pl.shotgunReload1_Duration = 21/40;
		pl.shotgunReload2_seq = weaponseq_mossberg500::reload2;
		pl.shotgunReload2_Duration = 21/50;
		pl.shotgunReload3_seq = weaponseq_mossberg500::reload3;
		pl.shotgunReload3_Duration = 26/30;
		pl.shotgunReload2_ammoLoadDelay = 10/50;
	}else{
		//shotgun reload settings: shared
		pl.shotgunReload1_seq = weaponseq_mossberg500::reload1b;
		pl.shotgunReload1_Duration = 21/40;
		pl.shotgunReload2_seq = weaponseq_mossberg500::reload2b;
		pl.shotgunReload2_Duration = 21/50;
		pl.shotgunReload3_seq = weaponseq_mossberg500::reload3b;
		pl.shotgunReload3_Duration = 26/30;
		pl.shotgunReload2_ammoLoadDelay = 10/50;
	}
	
	
	weapon_shotgun_reload(pl, ary_weaponData[WEAPON_ID::Mossberg500], arg_thisWeapon);
}


// ???
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
	weapon_gun_onDrawHUD(pl, (weapondata_gun_t*)ary_weaponData[WEAPON_ID::Mossberg500], arg_thisWeapon);

}

// NOPE!  Handled by the buysidemenu, could make this give the instructions for drawing the button
// with the icon if really wanted
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

