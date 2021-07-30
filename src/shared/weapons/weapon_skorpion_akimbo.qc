
//TAGGG - WARNING.  Most of the stats in this are improvised, I have no idea.

enum weaponseq_skorpion_akimbo{
	//...
	idle,
	draw,
	reload,
	fire1ak,
	fire2ak,
	fireleft,
	fireright
};



BOOLEAN weapon_Skorpion_akimbo_onPrimaryAttack(player localPlayer, weapondynamic_t arg_thisWeapon, BOOLEAN hasAmmo){
	return TRUE;
}
BOOLEAN weapon_Skorpion_akimbo_onPrimaryAttackRelease(player localPlayer, weapondynamic_t arg_thisWeapon, BOOLEAN hasAmmo){
	return FALSE;
}
BOOLEAN weapon_Skorpion_akimbo_onSecondaryAttack(player localPlayer, weapondynamic_t arg_thisWeapon, BOOLEAN hasAmmo){
	return FALSE;
}
BOOLEAN weapon_Skorpion_akimbo_onSecondaryAttackRelease(player localPlayer, weapondynamic_t arg_thisWeapon, BOOLEAN hasAmmo){
	return FALSE;
}
void weapon_Skorpion_akimbo_onEquip(player localPlayer, weapondynamic_t arg_thisWeapon){
}
BOOLEAN weapon_Skorpion_akimbo_onUnEquip(player localPlayer, weapondynamic_t arg_thisWeapon){
	return FALSE;
}
void weapon_Skorpion_akimbo_onThink(player localPlayer, weapondynamic_t arg_thisWeapon){
	weapon_gun_onThink(localPlayer, (weapondata_gun_t*)ary_weaponData[WEAPON_ID::Skorpion_akimbo], arg_thisWeapon);
}
void weapon_Skorpion_akimbo_onDrawHUD(player localPlayer, weapondynamic_t arg_thisWeapon){
}
void weapon_Skorpion_akimbo_onReload(player localPlayer, weapondynamic_t arg_thisWeapon){
}
void weapon_Skorpion_akimbo_onColdCock(player localPlayer, weapondynamic_t arg_thisWeapon){
}

	
//weapondata_ironsight_t weapon_Skorpion_akimbo =
weapondata_gun_t weapon_Skorpion_akimbo =
{
	WEAPONDATA_TYPEID_GUN,
	"Akimbo Skorpions",
	"models/v_skorpion_ak.mdl",
	"models/p_skorpion_ak.mdl",
	"",
	"models/w_skorpion.mdl",
	"sprites/weapons/skorpion_akimbo.spr",
	weapon_Skorpion_akimbo_onPrimaryAttack,
	weapon_Skorpion_akimbo_onPrimaryAttackRelease,
	weapon_Skorpion_akimbo_onSecondaryAttack,
	weapon_Skorpion_akimbo_onSecondaryAttackRelease,
	weapon_Skorpion_akimbo_onEquip,
	weapon_Skorpion_akimbo_onUnEquip,
	weapon_Skorpion_akimbo_onThink,
	weapon_Skorpion_akimbo_onDrawHUD,
	weapon_Skorpion_akimbo_onReload,
	weapon_Skorpion_akimbo_onColdCock,
	weaponseq_skorpion_akimbo::idle,
	weaponseq_skorpion_akimbo::draw,
	31.0f / 30.0f,
	0.0625f,  //fire delay.
	7.0f,  //dmg
	TRUE,
	BITS_WEAPONOPT_AKIMBO,
	BITS_WEAPONOPT_AKIMBO,
	2200, //for use if bought straight-off akimbo, not upgraded.
	30,
	BUYCATEGORY_SMGS,
	5,
	{0.035000, 0.550000, 0.002500},
	-WEAPON_ID::Skorpion,
	BITS_FIREMODE_AKIMBO_FULL_AUTO | BITS_FIREMODE_AKIMBO_FREE_FULL,
	BITS_FIREMODE_AKIMBO_FULL_AUTO,
	AMMO_ID::_32ACP,
	20,  //clip
	4096, //range
	weaponseq_skorpion_akimbo::reload,
	61.0f / 30.0f,
	-1,
	-1,
	-1,
	-1
};


void
w_skorpion_akimbo_precache(void)
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
w_skorpion_akimbo_updateammo(player pl)
{
	//weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	//Weapons_UpdateAmmo(pl, arg_thisWeapon.iClipLeft, pl.ary_ammoTotal[AMMO_ID::_9x19mm], -1);
}

string
w_skorpion_akimbo_wmodel(void)
{
	return (*ary_weaponData[WEAPON_ID::Skorpion_akimbo]).sWorldModelPath;
}

string
w_skorpion_akimbo_pmodel(void)
{
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	return (*ary_weaponData[WEAPON_ID::Skorpion_akimbo]).sPlayerModelPath;
}

string
w_skorpion_akimbo_deathmsg(void)
{
	return "";
}

void
w_skorpion_akimbo_draw(void)
{
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	weapon_base_onEquip(pl, ary_weaponData[WEAPON_ID::Skorpion_akimbo], arg_thisWeapon);
}

void
w_skorpion_akimbo_holster(void)
{
}


// General attack method to be called by primary or secondary fire as needed.
// The firemode used determines whether only pressing primary fire works (alternate b/w
// the Akimbo weapons with each shot), or primary & secondary control the left/right
// Akimbo weapons consistently.
// Putting it here avoids duplicating a bunch of code.
// Also, "attackTypeUsed" is whether primary (FALSE) or secondary (TRUE) lead to this point.
BOOLEAN weapon_Skorpion_akimbo_attack(player localPlayer, weapondynamic_t arg_thisWeapon, int attackTypeUsed){
	float randomChoice;
	player pl = localPlayer;
	int finalAkimboChoice = BITS_AKIMBOCHOICE_NONE;  //default
	
	// NOTE! weapon_akimbo_semiAttackChoice already handles telling to skip firing if
	// pl.recentAttackHadAmmo == FALSE or finalAkimboChoice is 0 or -1, no need
	// to keep track of w_attack_next per variant.
	// Also,
	//TODO - CRITICAL!
	// Muzzle flashes and shell ejections for akimbo pending!
	
	//because I am not copy/pasting this monstrosity 5 times.
	finalAkimboChoice = weapon_akimbo_fullAttackChoice(localPlayer, ary_weaponData[WEAPON_ID::Skorpion_akimbo], arg_thisWeapon, attackTypeUsed);
	
	SAVE_STATE(pl.nextAkimboAttackPreference);
	
	if(finalAkimboChoice == -1){
		//pl.akimboFirePrev = 0;
		return FALSE;
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
	
	weapon_base_onAttack(localPlayer, ary_weaponData[WEAPON_ID::Skorpion_akimbo], arg_thisWeapon, effectiveAkimboChoice);
	
	
	if(effectiveAkimboChoice & BITS_AKIMBOCHOICE_LEFT){
		TS_Weapons_PlaySoundDirect(pl, "weapons/skorpion/fire.wav");
	}
	if(effectiveAkimboChoice & BITS_AKIMBOCHOICE_RIGHT){
		TS_Weapons_PlaySoundDirect(pl, "weapons/skorpion/fire.wav");
	}
	
	
	if(pl.akimboTest == 0 && !(finalAkimboChoice == BITS_AKIMBOCHOICE_BOTH)){
		
		if(finalAkimboChoice == BITS_AKIMBOCHOICE_LEFT){
			//printfline("VM: UZI: LEFT");
			TS_Weapons_ViewAnimation(weaponseq_skorpion_akimbo::fireleft, (31.0f/30.0f) );
			
			weapon_base_setLeftAttackDelay(pl, (*ary_weaponData[pl.activeweapon]).fAttackDelay);
			if(arg_thisWeapon.iFireModeAkimbo == BITS_FIREMODE_AKIMBO_FULL_AUTO){
				weapon_base_setRightAttackDelay_AtLeast(pl, (*ary_weaponData[pl.activeweapon]).fAttackDelay * 0.5);
			}else if(arg_thisWeapon.iFireModeAkimbo == BITS_FIREMODE_AKIMBO_FREE_FULL){
				weapon_base_setRightAttackDelay_AtLeast(pl, (*ary_weaponData[pl.activeweapon]).fAttackDelay * 0.3);
			}
			
		}else if(finalAkimboChoice == BITS_AKIMBOCHOICE_RIGHT){
			//printfline("VM: UZI: RIGHT");
			TS_Weapons_ViewAnimation(weaponseq_skorpion_akimbo::fireright, (31.0f/30.0f) );
			
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
		if(randomChoice < 0.5){
			TS_Weapons_ViewAnimation(weaponseq_skorpion_akimbo::fire1ak, (31.0f/30.0f) );
		}else{
			TS_Weapons_ViewAnimation(weaponseq_skorpion_akimbo::fire2ak, (31.0f/30.0f) );
		}
		
		pl.akimboDualFireToleranceTime = 0;
		weapon_base_setWholeAttackDelay(pl, (*ary_weaponData[pl.activeweapon]).fAttackDelay * 1);
	}
	
	return TRUE;
}//END OF weapon_Skorpion_akimbo_attack


void
w_skorpion_akimbo_primary(void)
{
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	
	pl.akimboTest = 0;
	
	if(input_buttons & INPUT_BUTTON3){
		weapon_Skorpion_akimbo_attack(pl, arg_thisWeapon, BITS_AKIMBOCHOICE_BOTH);
	}else{
		weapon_Skorpion_akimbo_attack(pl, arg_thisWeapon, BITS_AKIMBOCHOICE_LEFT);
	}
}



void
w_skorpion_akimbo_secondary(void)
{
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	
	// reset
	pl.akimboTest = 0;
	
	if(arg_thisWeapon.iFireModeAkimbo == BITS_FIREMODE_AKIMBO_FREE_FULL){
		weapon_Skorpion_akimbo_attack(pl, arg_thisWeapon, BITS_AKIMBOCHOICE_RIGHT);
		//pl.akimboFirePrev = BITS_AKIMBOCHOICE_RIGHT;
	}
}


void
w_skorpion_akimbo_reload(void)
{
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	weapon_gun_Reload(pl, (weapondata_gun_t*)ary_weaponData[WEAPON_ID::Skorpion_akimbo], arg_thisWeapon);
}


// ???
float
w_skorpion_akimbo_aimanim(void)
{
	return self.flags & FL_CROUCHING ? ANIM_CR_AIM1HAND : ANIM_AIM1HAND;
}


void
w_skorpion_akimbo_hud(void)
{
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	weapon_gun_onDrawHUD(pl, (weapondata_gun_t*)ary_weaponData[WEAPON_ID::Skorpion_akimbo], arg_thisWeapon);

}

// NOPE!  Handled by the buysidemenu, could make this give the instructions for drawing the button
// with the icon if really wanted
void
w_skorpion_akimbo_hudpic(int selected, vector pos, float a)
{
	//
}


weapon_t w_skorpion_akimbo =
{
	
	.name		= "skorpion",
	.id			= 0,  // not using this
	.slot		= 2,  // ?
	.slot_pos	= 0,  // not using this
	.weight		= 0,  // not using this
	.draw		= w_skorpion_akimbo_draw,
	.holster	= w_skorpion_akimbo_holster,
	.primary	= w_skorpion_akimbo_primary,
	.secondary	= w_skorpion_akimbo_secondary,
	.reload		= w_skorpion_akimbo_reload,
	.release	= NULL,
	.crosshair	= w_skorpion_akimbo_hud,
	.precache	= w_skorpion_akimbo_precache,
	.pickup		= NULL,
	.updateammo	= w_skorpion_akimbo_updateammo,
	.wmodel		= w_skorpion_akimbo_wmodel,
	.pmodel		= w_skorpion_akimbo_pmodel,
	.deathmsg	= w_skorpion_akimbo_deathmsg,
	.aimanim	= w_skorpion_akimbo_aimanim,
	.hudpic		= NULL
	
};