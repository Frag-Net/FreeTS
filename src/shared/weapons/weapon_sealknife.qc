
enum weaponseq_sealknife{
	idle,
	draw,
	slash1,
	slash2,
	slash3
};


BOOLEAN weapon_SealKnife_onPrimaryAttack(player localPlayer, weapondynamic_t arg_thisWeapon, BOOLEAN hasAmmo){
	return TRUE;
}
BOOLEAN weapon_SealKnife_onPrimaryAttackRelease(player localPlayer, weapondynamic_t arg_thisWeapon, BOOLEAN hasAmmo){
	return FALSE;
}

BOOLEAN weapon_SealKnife_onSecondaryAttack(player localPlayer, weapondynamic_t arg_thisWeapon, BOOLEAN hasAmmo){
	return TRUE;
}
BOOLEAN weapon_SealKnife_onSecondaryAttackRelease(player localPlayer, weapondynamic_t arg_thisWeapon, BOOLEAN hasAmmo){
	return FALSE;
}
void weapon_SealKnife_onEquip(player localPlayer, weapondynamic_t arg_thisWeapon){
}

BOOLEAN weapon_SealKnife_onUnEquip(player localPlayer, weapondynamic_t arg_thisWeapon){
}
void weapon_SealKnife_onThink(player localPlayer, weapondynamic_t arg_thisWeapon){
}
void weapon_SealKnife_onDrawHUD(player localPlayer, weapondynamic_t arg_thisWeapon){
}
void weapon_SealKnife_onReload(player localPlayer, weapondynamic_t arg_thisWeapon){
}
void weapon_SealKnife_onColdCock(player localPlayer, weapondynamic_t arg_thisWeapon){
}

weapondata_throwable_t weapon_SealKnife =
{
	WEAPONDATA_TYPEID_THROWABLE,
	"Seal Knife",
	"models/v_sealknife.mdl",
	"models/p_sealknife.mdl",
	"",
	"models/w_sealknife.mdl",
	"sprites/weapons/sealknife.spr",
	weapon_SealKnife_onPrimaryAttack,
	weapon_SealKnife_onPrimaryAttackRelease,
	weapon_SealKnife_onSecondaryAttack,
	weapon_SealKnife_onSecondaryAttackRelease,
	weapon_SealKnife_onEquip,
	weapon_SealKnife_onUnEquip,
	weapon_SealKnife_onThink,
	weapon_SealKnife_onDrawHUD,
	weapon_SealKnife_onReload,
	weapon_SealKnife_onColdCock,
	weaponseq_sealknife::idle,
	weaponseq_sealknife::draw,
	31.0f / 30.0f,
	0.24,  //fire delay. this is most certainly wrong. find something more accurate later.
	15.0f,  //dmg
	FALSE,
	BITS_WEAPONOPT_FULLLOAD,
	BITS_WEAPONOPT_NONE,
	100,
	1,
	BUYCATEGORY_SPECIALPURPOSE,
	1,
	{0.100000, 1.000000, 0.000000},
	WEAPON_AKIMBO_UPGRADE_ID::NONE,
	10,
	50,   //thrown damage
	1350,  //thrown speed
	0.22  //thrown gravity (higher = falls faster)
	
};




void
w_sealknife_precache(void)
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

void
w_sealknife_updateammo(player pl)
{
	
}

string
w_sealknife_wmodel(void)
{
	return (*ary_weaponData[WEAPON_ID::SealKnife]).sWorldModelPath;
}

string
w_sealknife_pmodel(void)
{
	return (*ary_weaponData[WEAPON_ID::SealKnife]).sPlayerModelPath;
}

string
w_sealknife_deathmsg(void)
{
	return "";
}

void
w_sealknife_draw(void)
{
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	
	weapon_base_onEquip(pl, ary_weaponData[WEAPON_ID::SealKnife], arg_thisWeapon);
}

void
w_sealknife_holster(void)
{
}


void
w_sealknife_primary(void)
{
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	float randomChoice;

	if (pl.w_attack_next > 0.0) {
		return;
	}
	
	INPUT_PRIMARY_TAP_GATE
	
	weapondata_basic_t baseRef = *ary_weaponData[WEAPON_ID::SealKnife];
	MELEE_HIT_RESPONSE theReaper =  weapon_base_onPrimaryAttack_melee(pl, ary_weaponData[WEAPON_ID::SealKnife], arg_thisWeapon, baseRef.fAttackDamage, 55);
	
	// Only the server is doing traces so far to get results for this to be worth checking.
#ifdef SSQC
	//printfline("melee hit reponse: %d soft? %d", theReaper, (theReaper==MELEE_HIT_RESPONSE::SOFT));
	if (theReaper == MELEE_HIT_RESPONSE::NONE ) {
		TS_Weapons_PlaySoundDirect(pl, "weapons/knife/knife_miss.wav");
	}else if(theReaper == MELEE_HIT_RESPONSE::SOFT){
		//nothin
	}else if(theReaper == MELEE_HIT_RESPONSE::METAL){
		TS_Weapons_PlaySoundDirect(pl, "weapons/knife/knife_hit.wav");
	}else if(theReaper == MELEE_HIT_RESPONSE::FLESH){
		arg_thisWeapon.forceBodygroup1Submodel = 2;
		TS_Weapons_PlaySoundDirect(pl, "weapons/knife/knife_hitbody.wav");
	}
#endif


	//Animation_ShootWeapon( self );
	//self.fAttackFinished = time + wptKNIFE.fAttackFinished;

	// actually do this animation the same regardless as far as we know.
	randomChoice = randomInRange_i(0, 2);
	if(randomChoice == 0){
		TS_Weapons_ViewAnimation(weaponseq_sealknife::slash1, (31.0f/30.0f) );
	}else if(randomChoice == 1){
		TS_Weapons_ViewAnimation(weaponseq_sealknife::slash2, (31.0f/30.0f) );
	}else if(randomChoice == 2){
		TS_Weapons_ViewAnimation(weaponseq_sealknife::slash3, (31.0f/30.0f) );
	}
	
}



void
w_sealknife_secondary(void)
{
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	float randomChoice;
	
	if (pl.w_attack_next > 0.0) {
		return;
	}
	
	INPUT_SECONDARY_TAP_GATE
	
	weapondata_basic_t baseRef = *ary_weaponData[WEAPON_ID::SealKnife];
	weapon_base_setWholeAttackDelay(pl, baseRef.fAttackDelay);
	
	if(arg_thisWeapon.iCount > 0){
		//throw it!  play this sound too.
		arg_thisWeapon.iCount -= 1;
		pl.updateSlotCountsForEquippedWeapon();
		arg_thisWeapon.forceBodygroup1Submodel = 1;  //reset, new knife is not bloody.
		TS_Weapons_PlaySoundDirect(pl, "weapons/knife/knife_miss.wav", 1);
#ifdef SSQC
		TSThrownProjectile::generate2(pl, arg_thisWeapon);
#endif
	}
	
	if(arg_thisWeapon.iCount > 0){
		// another knife left?  Bring it up with a draw animation.
		TS_Weapons_ViewAnimation(weaponseq_sealknife::draw, (31.0f / 30.0f) );
	}else{
		// No knives left?  Unequip, pick something else.
		removeWeaponFromInventory(pl, pl.inventoryEquippedIndex);
		playerEquipIdealSafe(pl);
		
		return FALSE;
	}
	
}


void
w_sealknife_reload(void)
{
	// how do you reload a sword
}

// ???
float
w_sealknife_aimanim(void)
{
	return self.flags & FL_CROUCHING ? ANIM_CR_AIM1HAND : ANIM_AIM1HAND;
}


void
w_sealknife_hud(void)
{
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	
	weapon_throwable_onDrawHUD(pl, (weapondata_throwable_t*)ary_weaponData[WEAPON_ID::SealKnife], arg_thisWeapon);
}


// NOPE!  Handled by the buysidemenu, could make this give the instructions for drawing the button
// with the icon if really wanted
void
w_sealknife_hudpic(int selected, vector pos, float a)
{
	//
}


weapon_t w_sealknife =
{
	
	.name		= "sealknife",
	.id			= 0,  // not using this
	.slot		= 2,  // ?
	.slot_pos	= 0,  // not using this
	.weight		= 0,  // not using this
	.draw		= w_sealknife_draw,
	.holster	= w_sealknife_holster,
	.primary	= w_sealknife_primary,
	.secondary	= w_sealknife_secondary,
	.reload		= w_sealknife_reload,
	.release	= NULL,
	.crosshair	= w_sealknife_hud,
	.precache	= w_sealknife_precache,
	.pickup		= NULL,
	.updateammo	= w_sealknife_updateammo,
	.wmodel		= w_sealknife_wmodel,
	.pmodel		= w_sealknife_pmodel,
	.deathmsg	= w_sealknife_deathmsg,
	.aimanim	= w_sealknife_aimanim,
	.hudpic		= NULL
	
};

