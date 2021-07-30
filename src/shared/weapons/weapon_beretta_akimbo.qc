

enum weaponseq_beretta_akimbo{
	//...
	idle_1,
	reload,
	draw,
	rightshoot_1,
	leftshoot_1,
	rightshoot2_1,
	leftshoot2_1,
	rightshootlast_1,
	leftshootlast_1,
	rightshoots_1,
	leftshoots_1,
	rightshootlasts_1,
	leftshootlasts_1,
	// Akimbo only supports ironsight anims here???
	// we have change/rechange anims never used in game,
	// but our singular variant seems to completely lack these.  err.  okay.
	// also we have no "linkedshoot" for the ironsight variant.  just seems weird
	// to be missing.  So just like the socom oddly enough.
	idle_2,
	change,
	rechange,
	rightshoot_2,
	leftshoot_2,
	rightshoot2_2,
	leftshoot2_2,
	rightshootlast_2,
	leftshootlast_2,
	rightshoots_2,
	leftshoots_2,
	rightshootlasts_2,
	leftshootlasts_2,
	linkedshoot,
	linkedshootlast,
	reload2
	
};


BOOLEAN weapon_Beretta_akimbo_onPrimaryAttack(player localPlayer, weapondynamic_t arg_thisWeapon, BOOLEAN hasAmmo){
}
BOOLEAN weapon_Beretta_akimbo_onPrimaryAttackRelease(player localPlayer, weapondynamic_t arg_thisWeapon, BOOLEAN hasAmmo){
	return FALSE;
}
BOOLEAN weapon_Beretta_akimbo_onSecondaryAttack(player localPlayer, weapondynamic_t arg_thisWeapon, BOOLEAN hasAmmo){
	return FALSE;
}
BOOLEAN weapon_Beretta_akimbo_onSecondaryAttackRelease(player localPlayer, weapondynamic_t arg_thisWeapon, BOOLEAN hasAmmo){
	return FALSE;
}
void weapon_Beretta_akimbo_onEquip(player localPlayer, weapondynamic_t arg_thisWeapon){
}
BOOLEAN weapon_Beretta_akimbo_onUnEquip(player localPlayer, weapondynamic_t arg_thisWeapon){
	return FALSE;
}
void weapon_Beretta_akimbo_onThink(player localPlayer, weapondynamic_t arg_thisWeapon){
	weapon_gun_onThink(localPlayer, (weapondata_gun_t*)ary_weaponData[WEAPON_ID::Beretta_akimbo], arg_thisWeapon);
}
void weapon_Beretta_akimbo_onDrawHUD(player localPlayer, weapondynamic_t arg_thisWeapon){
}
void weapon_Beretta_akimbo_onReload(player localPlayer, weapondynamic_t arg_thisWeapon){
}
void weapon_Beretta_akimbo_onColdCock(player localPlayer, weapondynamic_t arg_thisWeapon){
	
}


weapondata_gun_t weapon_Beretta_akimbo =
{
	WEAPONDATA_TYPEID_GUN,
	"Akimbo Berettas",
	"models/v_berettas.mdl",
	"models/p_berettas.mdl",
	"models/p_berettas_sil.mdl",
	"models/w_berettas.mdl",
	"sprites/weapons/berettas.spr",
	weapon_Beretta_akimbo_onPrimaryAttack,
	weapon_Beretta_akimbo_onPrimaryAttackRelease,
	weapon_Beretta_akimbo_onSecondaryAttack,
	weapon_Beretta_akimbo_onSecondaryAttackRelease,
	weapon_Beretta_akimbo_onEquip,
	weapon_Beretta_akimbo_onUnEquip,
	weapon_Beretta_akimbo_onThink,
	weapon_Beretta_akimbo_onDrawHUD,
	weapon_Beretta_akimbo_onReload,
	weapon_Beretta_akimbo_onColdCock,
	weaponseq_beretta_akimbo::idle_1,
	weaponseq_beretta_akimbo::draw,
	41.0f / 55.0f,
	0.19f,  //fire delay. this is most certainly wrong. find something more accurate later.
	15.0f,  //dmg
	TRUE,
	BITS_WEAPONOPT_SILENCER | BITS_WEAPONOPT_LASERSIGHT | BITS_WEAPONOPT_FLASHLIGHT | BITS_WEAPONOPT_AKIMBO,
	BITS_WEAPONOPT_AKIMBO,
	1800,  //for use if bought straight-off akimbo, not upgraded.
	20,
	BUYCATEGORY_HANDGUNS,
	5,
	{0.028000, 1.500000, 0.000000},
	-WEAPON_ID::Beretta,
	BITS_FIREMODE_AKIMBO_SEMI_AUTO | BITS_FIREMODE_AKIMBO_FREE_SEMI,
	BITS_FIREMODE_AKIMBO_SEMI_AUTO,
	AMMO_ID::_9x19mm,
	15,  //clip
	4096, //range
	weaponseq_beretta_akimbo::reload,
	111.0f / 45.0f,
	1,
	2,
	2,
	-1
};



void
w_beretta_akimbo_precache(void)
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
w_beretta_akimbo_updateammo(player pl)
{
	//weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	//Weapons_UpdateAmmo(pl, arg_thisWeapon.iClipLeft, pl.ary_ammoTotal[AMMO_ID::_9x19mm], -1);
}

string
w_beretta_akimbo_wmodel(void)
{
	return (*ary_weaponData[WEAPON_ID::Beretta_akimbo]).sWorldModelPath;
}

string
w_beretta_akimbo_pmodel(void)
{
	// Do we have the silencer?
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	if(!(arg_thisWeapon.iBitsUpgrade & BITS_WEAPONOPT_SILENCER) ){
		return (*ary_weaponData[WEAPON_ID::Beretta_akimbo]).sPlayerModelPath;
	} else {
		return (*ary_weaponData[WEAPON_ID::Beretta_akimbo]).sPlayerSilencerModelPath;
	}
}

string
w_beretta_akimbo_deathmsg(void)
{
	return "";
}

void
w_beretta_akimbo_draw(void)
{
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	weapon_base_onEquip(pl, ary_weaponData[WEAPON_ID::Beretta_akimbo], arg_thisWeapon);
}

void
w_beretta_akimbo_holster(void)
{
}


// General attack method to be called by primary or secondary fire as needed.
// The firemode used determines whether only pressing primary fire works (alternate b/w
// the Akimbo weapons with each shot), or primary & secondary control the left/right
// Akimbo weapons consistently.
// Putting it here avoids duplicating a bunch of code.
// Also, "attackTypeUsed" is whether primary (FALSE) or secondary (TRUE) lead to this point.
BOOLEAN weapon_Beretta_akimbo_attack(player localPlayer, weapondynamic_t arg_thisWeapon, int attackTypeUsed){
	float randomChoice;
	player pl = localPlayer;
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
	finalAkimboChoice = weapon_akimbo_semiAttackChoice(localPlayer, ary_weaponData[WEAPON_ID::Beretta_akimbo], arg_thisWeapon, attackTypeUsed);
	
#ifdef CLIENT
	SAVE_STATE(pl.nextAkimboAttackPreference);
#endif
	
	if(finalAkimboChoice == -1){
		//pl.akimboFirePrev = 0;
		return FALSE;
	}
	
	
	if(pl.recentAttackHadAmmo == FALSE){
		if((finalAkimboChoice & BITS_AKIMBOCHOICE_LEFT)){
			PLAY_CLICK_SOUND_LEFT
		}
		if((finalAkimboChoice & BITS_AKIMBOCHOICE_RIGHT)){
			PLAY_CLICK_SOUND_RIGHT
		}
		return FALSE;
	}
	
	
	// ??  Is this even possible?
	if(finalAkimboChoice == 0){
		//pl.akimboFirePrev = 0;
		return FALSE;
	}
	
	// Use me for things the recent firing round already did to avoid redundancy.
	// That is, if left-click was pressed a fraction of a second ago and then right-click
	// to force leading here to play the dual-fire anim, no need to do the muzzle flash,
	// shell ejection and traceattack call for the left weapon.
	// Viewmodel anims (the whole point) and fire delays are OK to set based off the
	// sudden dual-fire request though.
	int effectiveAkimboChoice = finalAkimboChoice & ~pl.akimboTest;  //finalAkimboChoice;//BITS_AKIMBOCHOICE_NONE & ~pl.akimboTest
	
	weapon_base_onAttack(localPlayer, ary_weaponData[WEAPON_ID::Beretta_akimbo], arg_thisWeapon, effectiveAkimboChoice);
	
	
	if(effectiveAkimboChoice & BITS_AKIMBOCHOICE_LEFT){
		if(!(arg_thisWeapon.iBitsUpgrade & BITS_WEAPONOPT_SILENCER) ){
			TS_Weapons_PlaySoundDirect(pl, "weapons/beretta/fire.wav");
		} else {
			TS_Weapons_PlaySoundDirect(pl, "weapons/beretta/fire-sil.wav");
		}
	}
	if(effectiveAkimboChoice & BITS_AKIMBOCHOICE_RIGHT){
		if(!(arg_thisWeapon.iBitsUpgrade & BITS_WEAPONOPT_SILENCER) ){
			TS_Weapons_PlaySoundDirect(pl, "weapons/beretta/fire.wav");
		} else {
			TS_Weapons_PlaySoundDirect(pl, "weapons/beretta/fire-sil.wav");
		}
	}
	
	
	if(pl.akimboTest == 0 && !(finalAkimboChoice == BITS_AKIMBOCHOICE_BOTH)){
		// Not both fire types chosen
		// Firing the opposite way within this time will let the dual animation play.
		pl.akimboDualFireToleranceTime = 0.06f; //3.0f;  //0.07f;
		
		if(finalAkimboChoice == BITS_AKIMBOCHOICE_LEFT){
			//printfline("VM: LEFT");
			if(!arg_thisWeapon.iIronSight){
				if(arg_thisWeapon.iClipLeft > 0 ){
					randomChoice = random();
					if(randomChoice <= 0.33){
						TS_Weapons_ViewAnimation(weaponseq_beretta_akimbo::leftshoot_1, 31.0f/31.0f);
					}else if(randomChoice <= 0.66){
						TS_Weapons_ViewAnimation(weaponseq_beretta_akimbo::leftshoot2_1, 31.0f/31.0f);
					}else{
						TS_Weapons_ViewAnimation(weaponseq_beretta_akimbo::leftshoots_1, 31.0f/31.0f);
					}
				}else{
					randomChoice = random();
					if(randomChoice <= 0.5){
						TS_Weapons_ViewAnimation(weaponseq_beretta_akimbo::leftshootlast_1, 31.0f/31.0f);
					}else{
						TS_Weapons_ViewAnimation(weaponseq_beretta_akimbo::leftshootlasts_1, 31.0f/31.0f);
					}
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
					randomChoice = random();
					if(randomChoice <= 0.33){
						TS_Weapons_ViewAnimation(weaponseq_beretta_akimbo::rightshoot_1, 31.0f/31.0f);
					}else if(randomChoice <= 0.66){
						TS_Weapons_ViewAnimation(weaponseq_beretta_akimbo::rightshoot2_1, 31.0f/31.0f);
					}else{
						TS_Weapons_ViewAnimation(weaponseq_beretta_akimbo::rightshoots_1, 31.0f/31.0f);
					}
				}else{
					randomChoice = random();
					if(randomChoice <= 0.5){
						TS_Weapons_ViewAnimation(weaponseq_beretta_akimbo::rightshootlast_1, 31.0f/31.0f);
					}else{
						TS_Weapons_ViewAnimation(weaponseq_beretta_akimbo::rightshootlasts_1, 31.0f/31.0f);
					}
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
			if(arg_thisWeapon.iClipLeft > 0 || arg_thisWeapon.iClipAkimboLeft > 0){
				TS_Weapons_ViewAnimation(weaponseq_beretta_akimbo::linkedshoot, 31.0f/31.0f);
			}else{
				TS_Weapons_ViewAnimation(weaponseq_beretta_akimbo::linkedshootlast, 31.0f/31.0f);
			}
		}else{
			// ...
		}
		
		weapon_base_setWholeAttackDelay(pl, (*ary_weaponData[pl.activeweapon]).fAttackDelay * 1);
	}
	
	return TRUE;
}//END OF weapon_Beretta_akimbo_attack


void
w_beretta_akimbo_primary(void)
{
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	
	// reset
	pl.akimboTest = 0;
	
	// in addition to the primary input, which lead to '_primary' being called at all.
	if(input_buttons & INPUT_BUTTON3){
		if(!weapon_akimbo_semiAttackDualHack(pl, arg_thisWeapon, BITS_AKIMBOCHOICE_BOTH, &weapon_Beretta_akimbo_attack)){
			// nothing unusual here.
			pl.akimboTest = 0;
			weapon_Beretta_akimbo_attack(pl, arg_thisWeapon, BITS_AKIMBOCHOICE_BOTH);
		}else{
		}
	}else{
		if(!weapon_akimbo_semiAttackDualHack(pl, arg_thisWeapon, BITS_AKIMBOCHOICE_RIGHT, &weapon_Beretta_akimbo_attack)){
			weapon_Beretta_akimbo_attack(pl, arg_thisWeapon, BITS_AKIMBOCHOICE_LEFT);
			pl.akimboFirePrev = BITS_AKIMBOCHOICE_LEFT;
		}
		
	}
	
}


void
w_beretta_akimbo_secondary(void)
{
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	
	// reset
	pl.akimboTest = 0;
	
	// NOTE - holding primary is impossible, would've called _primary above if so.
	// Only secondary could possibly be held (and, is).
	if(arg_thisWeapon.iFireModeAkimbo == BITS_FIREMODE_AKIMBO_SEMI_AUTO){
		// no ironsights, nothing to do here.
	}else{
		// fires the right weapon always
		
		//weapon_Beretta_akimbo_attack(pl, arg_thisWeapon, BITS_AKIMBOCHOICE_RIGHT);
		//return;
		
		if(!weapon_akimbo_semiAttackDualHack(pl, arg_thisWeapon, BITS_AKIMBOCHOICE_LEFT, &weapon_Beretta_akimbo_attack)){
			weapon_Beretta_akimbo_attack(pl, arg_thisWeapon, BITS_AKIMBOCHOICE_RIGHT);
			pl.akimboFirePrev = BITS_AKIMBOCHOICE_RIGHT;
		}
	}
	
}


void
w_beretta_akimbo_reload(void)
{
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	weapon_gun_Reload(pl, (weapondata_gun_t*)ary_weaponData[WEAPON_ID::Beretta_akimbo], arg_thisWeapon);
	
	leftCount = 0;
	rightCount = 0;
}

// ???
float
w_beretta_akimbo_aimanim(void)
{
	return self.flags & FL_CROUCHING ? ANIM_CR_AIM1HAND : ANIM_AIM1HAND;
}


void
w_beretta_akimbo_hud(void)
{
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	weapon_gun_onDrawHUD(pl, (weapondata_gun_t*)ary_weaponData[WEAPON_ID::Beretta_akimbo], arg_thisWeapon);
}


// NOPE!  Handled by the buysidemenu, could make this give the instructions for drawing the button
// with the icon if really wanted
void
w_beretta_akimbo_hudpic(int selected, vector pos, float a)
{
	//
}


weapon_t w_beretta_akimbo =
{
	
	.name		= "beretta",
	.id			= 0,  // not using this
	.slot		= 2,  // ?
	.slot_pos	= 0,  // not using this
	.weight		= 0,  // not using this
	.draw		= w_beretta_akimbo_draw,
	.holster	= w_beretta_akimbo_holster,
	.primary	= w_beretta_akimbo_primary,
	.secondary	= w_beretta_akimbo_secondary,
	.reload		= w_beretta_akimbo_reload,
	.release	= NULL,
	.crosshair	= w_beretta_akimbo_hud,
	.precache	= w_beretta_akimbo_precache,
	.pickup		= NULL,
	.updateammo	= w_beretta_akimbo_updateammo,
	.wmodel		= w_beretta_akimbo_wmodel,
	.pmodel		= w_beretta_akimbo_pmodel,
	.deathmsg	= w_beretta_akimbo_deathmsg,
	.aimanim	= w_beretta_akimbo_aimanim,
	.hudpic		= NULL
	
};

