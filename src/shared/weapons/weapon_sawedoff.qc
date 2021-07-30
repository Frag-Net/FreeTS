
enum weaponseq_sawedoff{
	idle,
	draw,
	reload,
	shoot1,
	shoot2,
	idleb,
	reloadb,
	shoot1b,
	shoot2b,
	reload_sigle,
	reloadb_sigle,
	change,
	rechange,
	coldcock
};


BOOLEAN weapon_SawedOff_onPrimaryAttack(player localPlayer, weapondynamic_t arg_thisWeapon, BOOLEAN hasAmmo){
	return TRUE;
}
BOOLEAN weapon_SawedOff_onPrimaryAttackRelease(player localPlayer, weapondynamic_t arg_thisWeapon, BOOLEAN hasAmmo){
	return FALSE;
}
BOOLEAN weapon_SawedOff_onSecondaryAttack(player localPlayer, weapondynamic_t arg_thisWeapon, BOOLEAN hasAmmo){
}
BOOLEAN weapon_SawedOff_onSecondaryAttackRelease(player localPlayer, weapondynamic_t arg_thisWeapon, BOOLEAN hasAmmo){
	return FALSE;
}

void weapon_SawedOff_onEquip(player localPlayer, weapondynamic_t arg_thisWeapon){
}
BOOLEAN weapon_SawedOff_onUnEquip(player localPlayer, weapondynamic_t arg_thisWeapon){
	return FALSE;
}
void weapon_SawedOff_onThink(player localPlayer, weapondynamic_t arg_thisWeapon){
	weapon_gun_onThink(localPlayer, (weapondata_gun_t*)ary_weaponData[WEAPON_ID::SawedOff], arg_thisWeapon);
	//weapon_shotgun_onThink_reloadLogic(localPlayer, (weapondata_gun_t*)ary_weaponData[WEAPON_ID::SawedOff], arg_thisWeapon);
}
void weapon_SawedOff_onDrawHUD(player localPlayer, weapondynamic_t arg_thisWeapon){
}
void weapon_SawedOff_onReload(player localPlayer, weapondynamic_t arg_thisWeapon){
}
void weapon_SawedOff_onColdCock(player localPlayer, weapondynamic_t arg_thisWeapon){
	player pl;
	
	if(pl.w_attack_next > 0){
		return;
	}
	
	MELEE_HIT_RESPONSE theReaper = weapon_base_coldcock(localPlayer, ary_weaponData[WEAPON_ID::SawedOff], arg_thisWeapon, 40, 66);
	weapon_base_setWholeAttackDelay(localPlayer, 0.73f);
	TS_Weapons_ViewAnimation_noLaserLock(weaponseq_sawedoff::coldcock, (30.0f/30.0f) );
	
	arg_thisWeapon.iIronSight = 0;  // disable, coldcock returns to non-ironsight look
	
	// need the fleshhit sound
	if (theReaper == MELEE_HIT_RESPONSE::NONE ) {
		TS_Weapons_PlaySoundDirect(pl, "player/closecombat.wav");
	}else if(theReaper == MELEE_HIT_RESPONSE::SOFT){
		TS_Weapons_PlaySoundDirect(pl, "player/closecombat.wav");
	}else if(theReaper == MELEE_HIT_RESPONSE::METAL){
		TS_Weapons_PlaySoundDirect(pl, "player/closecombat.wav");
	}else if(theReaper == MELEE_HIT_RESPONSE::FLESH){
		TS_Weapons_PlaySoundDirect(pl, "weapons/knife/knife_hitbody.wav");
	}
}


	
weapondata_ironsight_t weapon_SawedOff =
{
	WEAPONDATA_TYPEID_IRONSIGHT,
	"Sawed-off",
	"models/v_sawedoff.mdl",
	"models/p_sawedoff.mdl",
	"",
	"models/w_sawedoff.mdl",
	"sprites/weapons/sawedoff.spr",
	weapon_SawedOff_onPrimaryAttack,
	weapon_SawedOff_onPrimaryAttackRelease,
	weapon_SawedOff_onSecondaryAttack,
	weapon_SawedOff_onSecondaryAttackRelease,
	weapon_SawedOff_onEquip,
	weapon_SawedOff_onUnEquip,
	weapon_SawedOff_onThink,
	weapon_SawedOff_onDrawHUD,
	weapon_SawedOff_onReload,
	weapon_SawedOff_onColdCock,
	weaponseq_sawedoff::idle,
	weaponseq_sawedoff::draw,
	31.0f / 33.0f,
	0.0625f,  //fire delay.
	7.0f,  //dmg
	TRUE,
	BITS_WEAPONOPT_LASERSIGHT,
	BITS_WEAPONOPT_NONE,
	1900,
	20,
	BUYCATEGORY_SHOTGUNS,
	4,
	{0.070000, 7.000000, 0.000000},
	WEAPON_AKIMBO_UPGRADE_ID::NONE,
	BITS_FIREMODE_SEMI,
	BITS_FIREMODE_SEMI,
	AMMO_ID::_SHELLS,
	2,  //clip
	4096, //range
	weaponseq_sawedoff::reload_sigle,
	61/30,  //delay.
	-1,
	-1,
	-1,
	-1,
	{
		weaponseq_sawedoff::change,
		21.0f/40.0f,
		weaponseq_sawedoff::rechange,
		21.0f/40.0f,
		weaponseq_sawedoff::idleb,
		weaponseq_sawedoff::reloadb_sigle,
		61/30,  //delay.
		{0.070000, 7.000000, 0.000000}
	}
};



void
w_sawedoff_precache(void)
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
w_sawedoff_updateammo(player pl)
{
	//weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];	
	//Weapons_UpdateAmmo(pl, arg_thisWeapon.iClipLeft, pl.ary_ammoTotal[AMMO_ID::_9x19mm], -1);
}

string
w_sawedoff_wmodel(void)
{
	return (*ary_weaponData[WEAPON_ID::SawedOff]).sWorldModelPath;
}

string
w_sawedoff_pmodel(void)
{
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	return (*ary_weaponData[WEAPON_ID::SawedOff]).sPlayerModelPath;
}

string
w_sawedoff_deathmsg(void)
{
	return "";
}


void
w_sawedoff_draw(void)
{
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	weapon_base_onEquip(pl, ary_weaponData[WEAPON_ID::SawedOff], arg_thisWeapon);
}

void
w_sawedoff_holster(void)
{
}


void
w_sawedoff_primary(void)
{
	float randomChoice;
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];

	if (pl.w_attack_next > 0.0) {
		return;
	}

	if(arg_thisWeapon.iFireMode == BITS_FIREMODE_SEMI){
		INPUT_PRIMARY_TAP_GATE
	}
	
	if (!arg_thisWeapon.iClipLeft || WEAPON_UNDERWATER_CHECK) {
		PLAY_CLICK_SOUND
		return;
	}
	
	TS_Weapons_PlaySoundDirect(pl, "weapons/sawedoff/fire.wav");

	if(!arg_thisWeapon.iIronSight){
		randomChoice = random();
		if(randomChoice < 0.5){
			TS_Weapons_ViewAnimation(weaponseq_sawedoff::shoot1, 31.0f/33.0f);
		}else{
			TS_Weapons_ViewAnimation(weaponseq_sawedoff::shoot2, 31.0f/33.0f);
		}
	}else{
		if(randomChoice < 0.5){
			TS_Weapons_ViewAnimation(weaponseq_sawedoff::shoot1b, 31.0f/33.0f);
		}else{
			TS_Weapons_ViewAnimation(weaponseq_sawedoff::shoot2b, 31.0f/33.0f);
		}
	}
	
#ifdef CLIENT
	View_ShowMuzzleflash(MUZZLE_SMALL);
	View_AddEvent(w_ejectshell_pistol, 0.0f);
#endif
	
	weapon_base_onAttack(pl, ary_weaponData[WEAPON_ID::SawedOff], arg_thisWeapon, BITS_AKIMBOCHOICE_LEFT);
	
	weapon_base_setWholeAttackDelay(pl, (*ary_weaponData[arg_thisWeapon.weaponID]).fAttackDelay);

	if (self.flags & FL_CROUCHING){
		Animation_PlayerTop(pl, ANIM_CR_SHOOT1HAND, 0.2f);
	}else{
		Animation_PlayerTop(pl, ANIM_SHOOT1HAND, 0.2f);
	}
	
}


void
w_sawedoff_secondary(void)
{
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	return weapon_ironsight_ToggleIronsight(pl, (weapondata_ironsight_t*)ary_weaponData[WEAPON_ID::SawedOff], arg_thisWeapon);
}

// need custom reload logic, works more like a typical weapon
void
w_sawedoff_reload(void)
{
	int reloadSeq;
	float reloadDur;
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];

	//weapon_ironsight_Reload(pl, (weapondata_ironsight_t*)ary_weaponData[WEAPON_ID::SawedOff], arg_thisWeapon);
	
	// CHECK - we have two reload anims for ordinary and ironsight mode each.
	// One for if we have 1 clip left, another for if we have 0 clip left.
	if(arg_thisWeapon.iClipLeft == 0){
		//do the both-empty reload anim.
		if(!arg_thisWeapon.iIronSight){
			reloadSeq = weaponseq_sawedoff::reload;
		}else{
			reloadSeq = weaponseq_sawedoff::reloadb;
		}
	}else{
		//wasn't 0? must be 1.  Otherwise we wouldn't have reached this point.
		if(!arg_thisWeapon.iIronSight){
			reloadSeq = weaponseq_sawedoff::reload_sigle;
		}else{
			reloadSeq = weaponseq_sawedoff::reloadb_sigle;
		}
	}
	
	reloadDur = 61.0f/30.0f;
	
	weapon_gun_Reload_CustomSequence(pl, (weapondata_gun_t*)ary_weaponData[WEAPON_ID::SawedOff], arg_thisWeapon, reloadSeq, reloadDur);
}


// ???
float
w_sawedoff_aimanim(void)
{
	return self.flags & FL_CROUCHING ? ANIM_CR_AIM1HAND : ANIM_AIM1HAND;
}

void
w_sawedoff_hud(void)
{
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	weapon_gun_onDrawHUD(pl, (weapondata_gun_t*)ary_weaponData[WEAPON_ID::SawedOff], arg_thisWeapon);

}

// NOPE!  Handled by the buysidemenu, could make this give the instructions for drawing the button
// with the icon if really wanted
void
w_sawedoff_hudpic(int selected, vector pos, float a)
{
	//
}


weapon_t w_sawedoff =
{
	
	.name		= "sawedoff",
	.id			= 0,  // not using this
	.slot		= 2,  // ?
	.slot_pos	= 0,  // not using this
	.weight		= 0,  // not using this
	.draw		= w_sawedoff_draw,
	.holster	= w_sawedoff_holster,
	.primary	= w_sawedoff_primary,
	.secondary	= w_sawedoff_secondary,
	.reload		= w_sawedoff_reload,
	.release	= NULL,
	.crosshair	= w_sawedoff_hud,
	.precache	= w_sawedoff_precache,
	.pickup		= NULL,
	.updateammo	= w_sawedoff_updateammo,
	.wmodel		= w_sawedoff_wmodel,
	.pmodel		= w_sawedoff_pmodel,
	.deathmsg	= w_sawedoff_deathmsg,
	.aimanim	= w_sawedoff_aimanim,
	.hudpic		= NULL
	
};



