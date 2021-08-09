
enum weaponseq_miniuzi_akimbo{
	akimbo_idle = 0,
	side_idle = 1,
	left_idle = 2,
	right_idle = 3,
	akimbo_draw = 4,
	go_left = 5,
	go_right = 6,
	go_side = 7,
	ret_from_left = 8,
	ret_from_right = 9,
	ret_from_side = 10,
	akimbo_reload = 11,
	akimbo_shoot1 = 12,
	akimbo_shoot2 = 13,
	akimbo_shoot3 = 14,
	akimbo_sshoot1 = 15,
	akimbo_sshoot2 = 16,
	akimbo_sshoot3 = 17,
	right_shoot = 18,
	left_shoot = 19,
	right_sshoot = 20,
	left_sshoot = 21,
	side_shoot = 22,
	side_sshoot = 23,
	akimbo_right_shoot = 24,
	akimbo_left_shoot = 25
};

void weapon_miniuzi_akimbo_onPrimaryAttackRelease(player pl, weapondynamic_t arg_thisWeapon){
	
}
void weapon_miniuzi_akimbo_onSecondaryAttackRelease(player pl, weapondynamic_t arg_thisWeapon){
	
}
void weapon_miniuzi_akimbo_onThink(player pl, weapondynamic_t arg_thisWeapon){
	weapon_gun_onThink(pl, (weapondata_gun_t*)ary_weaponData[WEAPON_ID::MINIUZI_AKIMBO], arg_thisWeapon);
}
void weapon_miniuzi_akimbo_onColdCock(player pl, weapondynamic_t arg_thisWeapon){
	
}

weapondata_gun_t weapon_miniuzi_akimbo =
{
	WEAPONDATA_TYPEID_GUN,
	"Akimbo Mini-Uzi",
	"models/v_uzi_akimbo.mdl",
	"models/p_uzi_akimbo.mdl",
	"models/p_uzi_akimbo_sil.mdl",
	"models/w_uzi.mdl",
	"sprites/weapons/uzi_akimbo.spr",
	weapon_miniuzi_akimbo_onPrimaryAttackRelease,
	weapon_miniuzi_akimbo_onSecondaryAttackRelease,
	weapon_miniuzi_akimbo_onThink,
	weapon_miniuzi_akimbo_onColdCock,
	weaponseq_miniuzi_akimbo::akimbo_idle,
	weaponseq_miniuzi_akimbo::akimbo_draw,
	31.0f / 35.0f,
	0.0625f,  //fire delay.
	7.0f,  //dmg
	TRUE,
	BITS_WEAPONOPT_SILENCER | BITS_WEAPONOPT_AKIMBO,
	BITS_WEAPONOPT_AKIMBO,
	2600,  //for use if bought straight-off akimbo, not upgraded.
	40,
	BUYCATEGORY_SMGS,
	5,
	{0.030000, 2.000000, 0.005000},
	-WEAPON_ID::MINIUZI,
	BITS_FIREMODE_AKIMBO_FULL_AUTO | BITS_FIREMODE_AKIMBO_FREE_FULL,
	BITS_FIREMODE_AKIMBO_FULL_AUTO,
	AMMO_ID::_9X19MM,
	32,  //clip
	4096, //range
	weaponseq_miniuzi_akimbo::akimbo_reload,
	136.0f / 45.0f,
	1,
	-1,
	-1,
	-1
};



void
w_miniuzi_akimbo_precache(void)
{
	weapon_precache(ary_weaponData[WEAPON_ID::MINIUZI_AKIMBO]);
#ifdef SERVER
	// assume the singular variant has handled sounds.
#else
	
#endif
}

void
w_miniuzi_akimbo_updateammo(player pl)
{
}

string
w_miniuzi_akimbo_wmodel(void)
{
	return (*ary_weaponData[WEAPON_ID::MINIUZI_AKIMBO]).sWorldModelPath;
}

string
w_miniuzi_akimbo_pmodel(void)
{
	// Do we have the silencer?
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	if(!(arg_thisWeapon.iBitsUpgrade & BITS_WEAPONOPT_SILENCER) ){
		return (*ary_weaponData[WEAPON_ID::MINIUZI_AKIMBO]).sPlayerModelPath;
	} else {
		return (*ary_weaponData[WEAPON_ID::MINIUZI_AKIMBO]).sPlayerSilencerModelPath;
	}
}

string
w_miniuzi_akimbo_deathmsg(void)
{
	return "";
}

void
w_miniuzi_akimbo_draw(void)
{
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	weapon_base_onEquip(pl, ary_weaponData[WEAPON_ID::MINIUZI_AKIMBO], arg_thisWeapon);
}

void
w_miniuzi_akimbo_holster(void)
{
}


// General attack method to be called by primary or secondary fire as needed.
// The firemode used determines whether only pressing primary fire works (alternate b/w
// the Akimbo weapons with each shot), or primary & secondary control the left/right
// Akimbo weapons consistently.
// Putting it here avoids duplicating a bunch of code.
// Also, "attackTypeUsed" is whether primary (FALSE) or secondary (TRUE) lead to this point.
void weapon_miniuzi_akimbo_attack(player pl, weapondynamic_t arg_thisWeapon, int attackTypeUsed){
	float randomChoice;
	int finalAkimboChoice = BITS_AKIMBOCHOICE_NONE;  //default
	
	// NOTE! weapon_akimbo_semiAttackChoice already handles telling to skip firing if
	// pl.recentAttackHadAmmo == FALSE or finalAkimboChoice is 0 or -1, no need
	// to keep track of w_attack_next per variant.
	// Also,
	//TODO - CRITICAL!
	// Muzzle flashes and shell ejections for akimbo pending!
	
	//because I am not copy/pasting this monstrosity 5 times.
	finalAkimboChoice = weapon_akimbo_fullAttackChoice(pl, ary_weaponData[WEAPON_ID::MINIUZI_AKIMBO], arg_thisWeapon, attackTypeUsed);
	
	if(finalAkimboChoice == -1){
		//pl.akimboFirePrev = 0;
		return;
	}
	
	/*
	// DEBUG
	if(finalAkimboChoice > 0){
		finalAkimboChoice = BITS_AKIMBOCHOICE_BOTH;
	}
	*/
	if(pl.recentAttackHadAmmo == FALSE){
				
		if((finalAkimboChoice & BITS_AKIMBOCHOICE_LEFT)){
			PLAY_CLICK_SOUND_LEFT
		}
		if((finalAkimboChoice & BITS_AKIMBOCHOICE_RIGHT)){
			PLAY_CLICK_SOUND_RIGHT
		}
		return;
	}
	
	// ??  Is this even possible?
	if(finalAkimboChoice == 0){
		//pl.akimboFirePrev = 0;
		return;
	}
	
	
	// Use me for things the recent firing round already did to avoid redundancy.
	// That is, if left-click was pressed a fraction of a second ago and then right-click
	// to force leading here to play the dual-fire anim, no need to do the muzzle flash,
	// shell ejection and traceattack call for the left weapon.
	// Viewmodel anims (the whole point) and fire delays are OK to set based off the
	// sudden dual-fire request though.
	int effectiveAkimboChoice = finalAkimboChoice & ~pl.akimboTest;  //finalAkimboChoice;//BITS_AKIMBOCHOICE_NONE & ~pl.akimboTest
	
	weapon_base_onAttack(pl, ary_weaponData[WEAPON_ID::MINIUZI_AKIMBO], arg_thisWeapon, effectiveAkimboChoice);
	
	
	if(effectiveAkimboChoice & BITS_AKIMBOCHOICE_LEFT){
		if(!(arg_thisWeapon.iBitsUpgrade & BITS_WEAPONOPT_SILENCER) ){
			SoundPitched_Send(pl, SNDP_MINIUZI_FIRE);
		} else {
			SoundPitched_Send(pl, SNDP_MINIUZI_FIRE_SIL);
		}
	}
	if(effectiveAkimboChoice & BITS_AKIMBOCHOICE_RIGHT){
		if(!(arg_thisWeapon.iBitsUpgrade & BITS_WEAPONOPT_SILENCER) ){
			SoundPitched_Send(pl, SNDP_MINIUZI_FIRE);
		} else {
			SoundPitched_Send(pl, SNDP_MINIUZI_FIRE_SIL);
		}
	}
	
	
	if(pl.akimboTest == 0 && !(finalAkimboChoice == BITS_AKIMBOCHOICE_BOTH)){
		
		if(finalAkimboChoice == BITS_AKIMBOCHOICE_LEFT){
			//printfline("VM: UZI: LEFT");
			TS_Weapons_ViewAnimation(weaponseq_miniuzi_akimbo::akimbo_left_shoot, (31.0f/30.0f) );
			
			weapon_base_setLeftAttackDelay(pl, (*ary_weaponData[pl.activeweapon]).fAttackDelay);
			if(arg_thisWeapon.iFireModeAkimbo == BITS_FIREMODE_AKIMBO_FULL_AUTO){
				weapon_base_setRightAttackDelay_AtLeast(pl, (*ary_weaponData[pl.activeweapon]).fAttackDelay * 0.5);
			}else if(arg_thisWeapon.iFireModeAkimbo == BITS_FIREMODE_AKIMBO_FREE_FULL){
				weapon_base_setRightAttackDelay_AtLeast(pl, (*ary_weaponData[pl.activeweapon]).fAttackDelay * 0.3);
			}
			
		}else if(finalAkimboChoice == BITS_AKIMBOCHOICE_RIGHT){
			//printfline("VM: UZI: RIGHT");
			TS_Weapons_ViewAnimation(weaponseq_miniuzi_akimbo::akimbo_right_shoot, (31.0f/30.0f) );
			
			weapon_base_setRightAttackDelay(pl, (*ary_weaponData[pl.activeweapon]).fAttackDelay);
			if(arg_thisWeapon.iFireModeAkimbo == BITS_FIREMODE_AKIMBO_FULL_AUTO){
				weapon_base_setLeftAttackDelay_AtLeast(pl, (*ary_weaponData[pl.activeweapon]).fAttackDelay * 0.5);
			}else if(arg_thisWeapon.iFireModeAkimbo == BITS_FIREMODE_AKIMBO_FREE_FULL){
				weapon_base_setLeftAttackDelay_AtLeast(pl, (*ary_weaponData[pl.activeweapon]).fAttackDelay * 0.3);
			}
		}
		
		// Firing the opposite way within this time will let the dual animation play.
		pl.akimboDualFireToleranceTime = 0.06f;
	
	}else{
		//printfline("VM: UZI: BOTH");
		randomChoice = random();
		if(randomChoice < 1/6){
			TS_Weapons_ViewAnimation(weaponseq_miniuzi_akimbo::akimbo_shoot1, (31.0f/30.0f) );
		}else if(randomChoice < 2/6){
			TS_Weapons_ViewAnimation(weaponseq_miniuzi_akimbo::akimbo_shoot2, (31.0f/30.0f) );
		}else if(randomChoice < 3/6){
			TS_Weapons_ViewAnimation(weaponseq_miniuzi_akimbo::akimbo_shoot3, (31.0f/30.0f) );
		}else if(randomChoice < 4/6){
			TS_Weapons_ViewAnimation(weaponseq_miniuzi_akimbo::akimbo_sshoot1, (31.0f/30.0f) );
		}else if(randomChoice < 5/6){
			TS_Weapons_ViewAnimation(weaponseq_miniuzi_akimbo::akimbo_sshoot2, (31.0f/30.0f) );
		}else{  // 6/6
			TS_Weapons_ViewAnimation(weaponseq_miniuzi_akimbo::akimbo_sshoot3, (31.0f/30.0f) );
		}
		
		pl.akimboDualFireToleranceTime = 0;
		weapon_base_setWholeAttackDelay(pl, (*ary_weaponData[pl.activeweapon]).fAttackDelay * 1);
	}
	
}// weapon_miniuzi_akimbo_attack


void
w_miniuzi_akimbo_primary(void)
{
	weapon_gun_akimbo_full_primaryAttack(weapon_miniuzi_akimbo_attack);
}



void
w_miniuzi_akimbo_secondary(void)
{
	weapon_gun_akimbo_full_secondaryAttack(weapon_miniuzi_akimbo_attack);
}


void
w_miniuzi_akimbo_reload(void)
{
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];

	weapon_gun_Reload(pl, (weapondata_gun_t*)ary_weaponData[WEAPON_ID::MINIUZI_AKIMBO], arg_thisWeapon);

}


float
w_miniuzi_akimbo_aimanim(void)
{
	return self.flags & FL_CROUCHING ? ANIM_CR_AIM1HAND : ANIM_AIM1HAND;
}


void
w_miniuzi_akimbo_hud(void)
{
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	weapon_gun_onDrawHUD(pl, (weapondata_gun_t*)ary_weaponData[WEAPON_ID::MINIUZI_AKIMBO], arg_thisWeapon);

}

void
w_miniuzi_akimbo_hudpic(int selected, vector pos, float a)
{
	//
}


weapon_t w_miniuzi_akimbo =
{
	
	.name		= "miniuzi",
	.id			= 0,  // not using this
	.slot		= 2,  // ?
	.slot_pos	= 0,  // not using this
	.weight		= 0,  // not using this
	.draw		= w_miniuzi_akimbo_draw,
	.holster	= w_miniuzi_akimbo_holster,
	.primary	= w_miniuzi_akimbo_primary,
	.secondary	= w_miniuzi_akimbo_secondary,
	.reload		= w_miniuzi_akimbo_reload,
	.release	= NULL,
	.crosshair	= w_miniuzi_akimbo_hud,
	.precache	= w_miniuzi_akimbo_precache,
	.pickup		= NULL,
	.updateammo	= w_miniuzi_akimbo_updateammo,
	.wmodel		= w_miniuzi_akimbo_wmodel,
	.pmodel		= w_miniuzi_akimbo_pmodel,
	.deathmsg	= w_miniuzi_akimbo_deathmsg,
	.aimanim	= w_miniuzi_akimbo_aimanim,
	.hudpic		= NULL
	
};

