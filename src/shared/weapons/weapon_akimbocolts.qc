
enum weaponseq_akimbocolts{
	idle,
	reload,
	draw,
	rightshoot,
	leftshoot,
	rightshootlast,
	leftshootlast,
	linkedshoot,
	linkedshootlast
	
};

void weapon_akimbocolts_akimbo_onPrimaryAttackRelease(player pl, weapondynamic_t arg_thisWeapon){
	
}
void weapon_akimbocolts_akimbo_onSecondaryAttackRelease(player pl, weapondynamic_t arg_thisWeapon){
	
}

void weapon_akimbocolts_akimbo_onThink(player pl, weapondynamic_t arg_thisWeapon){
	weapon_gun_onThink(pl, (weapondata_gun_t*)ary_weaponData[WEAPON_ID::AKIMBOCOLTS], arg_thisWeapon);
}
void weapon_akimbocolts_akimbo_onColdCock(player pl, weapondynamic_t arg_thisWeapon){
	
}

weapondata_gun_t weapon_akimbocolts =
{
	WEAPONDATA_TYPEID_GUN,
	"Golden Colts",
	"models/v_gold.mdl",
	"models/p_gold.mdl",
	"",
	"models/w_gold.mdl",
	"sprites/weapons/gold.spr",
	weapon_akimbocolts_akimbo_onPrimaryAttackRelease,
	weapon_akimbocolts_akimbo_onSecondaryAttackRelease,
	weapon_akimbocolts_akimbo_onThink,
	weapon_akimbocolts_akimbo_onColdCock,
	NULL,
	weaponseq_akimbocolts::idle,
	weaponseq_akimbocolts::draw,
	31.0f / 30.0f,
	0.19f,  //fire delay
	15.0f,  //dmg
	TRUE,
	BITS_WEAPONOPT_AKIMBO,
	BITS_WEAPONOPT_AKIMBO,
	2600,  //for use if bought straight-off akimbo, not upgraded.
	20,
	BUYCATEGORY_HANDGUNS,
	5,
	{0.015000, 2.000000, 0.000000},
	
	// No singular variant, so this stays as it is.
	WEAPON_AKIMBO_UPGRADE_ID::NONE,
	
	BITS_FIREMODE_AKIMBO_SEMI_AUTO | BITS_FIREMODE_AKIMBO_FREE_SEMI,
	BITS_FIREMODE_AKIMBO_SEMI_AUTO,
	AMMO_ID::_45ACP,
	16,  //clip
	4096, //range
	weaponseq_akimbocolts::reload,
	101.0f / 35.0f,
	1,
	-1,
	2,
	-1
};




void
w_akimbocolts_precache(void)
{
	weapon_precache(ary_weaponData[WEAPON_ID::AKIMBOCOLTS]);
#ifdef SERVER
	//precache_sound("weapons/gold/clipin.wav");
	//precache_sound("weapons/gold/clipout.wav");
	precache_sound("weapons/gold/gold-fire.wav");
	//precache_sound("weapons/gold/sliderelease.wav");
#else
	
#endif
}

void
w_akimbocolts_updateammo(player pl)
{
}

string
w_akimbocolts_wmodel(void)
{
	return (*ary_weaponData[WEAPON_ID::AKIMBOCOLTS]).sWorldModelPath;
}

string
w_akimbocolts_pmodel(player pl)
{
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	return (*ary_weaponData[WEAPON_ID::AKIMBOCOLTS]).sPlayerModelPath;
}

string
w_akimbocolts_deathmsg(void)
{
	return "";
}

void
w_akimbocolts_draw(player pl)
{
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	weapon_base_onEquip(pl, ary_weaponData[WEAPON_ID::AKIMBOCOLTS], arg_thisWeapon);
}

void
w_akimbocolts_holster(player pl)
{
}


// General attack method to be called by primary or secondary fire as needed.
// The firemode used determines whether only pressing primary fire works (alternate b/w
// the Akimbo weapons with each shot), or primary & secondary control the left/right
// Akimbo weapons consistently.
// Putting it here avoids duplicating a bunch of code.
// Also, "attackTypeUsed" is whether primary (FALSE) or secondary (TRUE) lead to this point.
void weapon_akimbocolts_akimbo_attack(player pl, weapondynamic_t arg_thisWeapon, int attackTypeUsed){
	//weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	
	//special case
	int finalAkimboChoice = BITS_AKIMBOCHOICE_NONE;  //default
	
	// NOTE! weapon_akimbo_semiAttackChoice already handles telling to skip firing if
	// pl.recentAttackHadAmmo == FALSE or finalAkimboChoice is 0 or -1, no need
	// to keep track of w_attack_next per variant.
	// Also,
	//TODO - CRITICAL!
	// Muzzle flashes and shell ejections for akimbo pending!
	
	// because I am not copy/pasting this monstrosity 5 times.
	finalAkimboChoice = weapon_akimbo_semiAttackChoice(pl, ary_weaponData[WEAPON_ID::AKIMBOCOLTS], arg_thisWeapon, attackTypeUsed);
	
	if(finalAkimboChoice == -1){
		//pl.akimboFirePrev = 0;
		return;
	}
	
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
	
	weapon_base_onAttack(pl, ary_weaponData[WEAPON_ID::AKIMBOCOLTS], arg_thisWeapon, effectiveAkimboChoice);
	
	if(effectiveAkimboChoice & BITS_AKIMBOCHOICE_LEFT){
		SoundPitched_Send(pl, SNDP_AKIMBOCOLTS_FIRE);
	}
	if(effectiveAkimboChoice & BITS_AKIMBOCHOICE_RIGHT){
		SoundPitched_Send(pl, SNDP_AKIMBOCOLTS_FIRE);
	}
	
	
	if(pl.akimboTest == 0 && !(finalAkimboChoice == BITS_AKIMBOCHOICE_BOTH)){
		// Not both fire types chosen
		// Firing the opposite way within this time will let the dual animation play.
		pl.akimboDualFireToleranceTime = 0.06f; //3.0f;  //0.07f;
		
		if(finalAkimboChoice == BITS_AKIMBOCHOICE_LEFT){
			//printfline("VM: LEFT");
			if(!arg_thisWeapon.iIronSight){
				if(arg_thisWeapon.iClipLeft > 0 ){
					TS_Weapons_ViewAnimation(weaponseq_akimbocolts::leftshoot, 31.0f/30.0f);
				}else{
					TS_Weapons_ViewAnimation(weaponseq_akimbocolts::leftshootlast, 31.0f/30.0f);
				}
			}else{
				// ...
			}
			
			weapon_base_setLeftAttackDelay(pl, (*ary_weaponData[pl.activeweapon]).fAttackDelay);

			if(arg_thisWeapon.iFireModeAkimbo == BITS_FIREMODE_AKIMBO_SEMI_AUTO){
				// in semi fire, set the opposite delay a little too.
				weapon_base_setRightAttackDelay_AtLeast(pl, (*ary_weaponData[pl.activeweapon]).fAttackDelay * 0.5);
			}else if(arg_thisWeapon.iFireModeAkimbo == BITS_FIREMODE_AKIMBO_FREE_SEMI){
				weapon_base_setRightAttackDelay_AtLeast(pl, (*ary_weaponData[pl.activeweapon]).fAttackDelay * 0.3);
			}
		}else if(finalAkimboChoice == BITS_AKIMBOCHOICE_RIGHT){
			//printfline("VM: RIGHT");
			if(!arg_thisWeapon.iIronSight){
				if(arg_thisWeapon.iClipAkimboLeft > 0 ){
					TS_Weapons_ViewAnimation(weaponseq_akimbocolts::rightshoot, 31.0f/30.0f);
				}else{
					TS_Weapons_ViewAnimation(weaponseq_akimbocolts::rightshootlast, 31.0f/30.0f);
				}
			}else{
				// ...
			}
			
			weapon_base_setRightAttackDelay(pl, (*ary_weaponData[pl.activeweapon]).fAttackDelay);

			if(arg_thisWeapon.iFireModeAkimbo == BITS_FIREMODE_AKIMBO_SEMI_AUTO){
				weapon_base_setLeftAttackDelay_AtLeast(pl, (*ary_weaponData[pl.activeweapon]).fAttackDelay * 0.5);
			}else if(arg_thisWeapon.iFireModeAkimbo == BITS_FIREMODE_AKIMBO_FREE_SEMI){
				weapon_base_setLeftAttackDelay_AtLeast(pl, (*ary_weaponData[pl.activeweapon]).fAttackDelay * 0.3);
			}
		}
	}else{
		//printfline("VM: BOTH");
		
		// dual fire'd?  Don't use it for doing this again.
		pl.akimboDualFireToleranceTime = 0;
		
		// both fire types?
		if(!arg_thisWeapon.iIronSight){
			if(arg_thisWeapon.iClipLeft > 0 || arg_thisWeapon.iClipAkimboLeft > 0 ){
				TS_Weapons_ViewAnimation(weaponseq_akimbocolts::linkedshoot, 31.0f/30.0f);
			}else{
				TS_Weapons_ViewAnimation(weaponseq_akimbocolts::linkedshootlast, 31.0f/30.0f);
			}
		}else{
			// ...
		}
		
		weapon_base_setWholeAttackDelay(pl, (*ary_weaponData[pl.activeweapon]).fAttackDelay * 1);
	}
	
	if(!(arg_thisWeapon.iBitsUpgrade & BITS_WEAPONOPT_SILENCER) ){
		weapon_ClientEffectsAkimbo(MUZZLEFLASH_ID::SMALL, SHELLEJECT_ID::GENERIC, finalAkimboChoice);
	} else {
		weapon_EjectShellAkimbo(SHELLEJECT_ID::GENERIC, finalAkimboChoice);
	}
	
}// weapon_akimbocolts_akimbo_attack


void
w_akimbocolts_primary(player pl)
{
	weapon_gun_akimbo_semi_primaryAttack(weapon_akimbocolts_akimbo_attack);
}


void
w_akimbocolts_secondary(player pl)
{
	weapon_gun_akimbo_semi_secondaryAttack(weapon_akimbocolts_akimbo_attack);
	
}


void
w_akimbocolts_reload(player pl)
{
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	weapon_gun_Reload(pl, (weapondata_gun_t*)ary_weaponData[WEAPON_ID::AKIMBOCOLTS], arg_thisWeapon);
	
}

float
w_akimbocolts_aimanim(player pl)
{
	return self.flags & FL_CROUCHING ? ANIM_CR_AIM1HAND : ANIM_AIM1HAND;
}

void
w_akimbocolts_hud(player pl)
{
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	weapon_gun_onDrawHUD(pl, (weapondata_gun_t*)ary_weaponData[WEAPON_ID::AKIMBOCOLTS], arg_thisWeapon);
}

void
w_akimbocolts_hudpic(player pl, int selected, vector pos, float a)
{
	//
}

weapon_t w_akimbocolts =
{
	
	.name		= "akimbocolts",
	.id			= 0,  // not using this
	.slot		= 2,  // ?
	.slot_pos	= 0,  // not using this
	.weight		= 0,  // not using this
	.draw		= w_akimbocolts_draw,
	.holster	= w_akimbocolts_holster,
	.primary	= w_akimbocolts_primary,
	.secondary	= w_akimbocolts_secondary,
	.reload		= w_akimbocolts_reload,
	.release	= NULL,
	.postdraw	= w_akimbocolts_hud,
	.precache	= w_akimbocolts_precache,
	.pickup		= NULL,
	.updateammo	= w_akimbocolts_updateammo,
	.wmodel		= w_akimbocolts_wmodel,
	.pmodel		= w_akimbocolts_pmodel,
	.deathmsg	= w_akimbocolts_deathmsg,
	.aimanim	= w_akimbocolts_aimanim,
	.hudpic		= NULL
	
};

