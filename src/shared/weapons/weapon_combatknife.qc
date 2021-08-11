
//TAGGG - TODO (same for seal knife): spark-effect on bouncing off something and hitting something
// (only if non-organic, i.e. not a player, probably)?
// That would be for the resulting throwable object.
// Although same effect for any melee hits with knives and the katana too I think.

enum weaponseq_combatknife{
	idle,
	idle2,   // why? identical.
	draw,
	slash1,
	left,
	right,
	hold   // WHERE WOULD WE USE THIS?  Is there any way to block with melee besides "R" in karate?
};

void weapon_combatknife_onPrimaryAttackRelease(player pl, weapondynamic_t arg_thisWeapon){
	
}
void weapon_combatknife_onSecondaryAttackRelease(player pl, weapondynamic_t arg_thisWeapon){
	
}
void weapon_combatknife_onThink(player pl, weapondynamic_t arg_thisWeapon){

}
void weapon_combatknife_onColdCock(player pl, weapondynamic_t arg_thisWeapon){

}

weapondata_throwable_t weapon_combatknife =
{
	WEAPONDATA_TYPEID_THROWABLE,
	"Combat Knife",
	"models/v_knife.mdl",
	"models/p_knife.mdl",
	"",
	"models/w_knife.mdl",
	"sprites/weapons/knife.spr",
	weapon_combatknife_onPrimaryAttackRelease,
	weapon_combatknife_onSecondaryAttackRelease,
	weapon_combatknife_onThink,
	weapon_combatknife_onColdCock,
	weaponseq_combatknife::idle,
	weaponseq_combatknife::draw,
	31.0f / 30.0f,
	0.30,  //fire delay.
	35.0f,  //dmg
	FALSE,
	BITS_WEAPONOPT_FULLLOAD,
	BITS_WEAPONOPT_NONE,
	100,
	1,
	BUYCATEGORY_SPECIALPURPOSE,
	1,
	{0.100000, 1.000000, 0.000000},
	WEAPON_AKIMBO_UPGRADE_ID::NONE,
	5,
	80,   //thrown damage
	1350,  //thrown speed
	0.83  //thrown gravity (higher = falls faster)
	
};



void
w_combatknife_precache(void)
{
	weapon_precache(ary_weaponData[WEAPON_ID::COMBATKNIFE]);
#ifdef SERVER
	precache_sound("weapons/knife/knife_hit.wav");
	precache_sound("weapons/knife/knife_hitbody.wav");
	precache_sound("weapons/knife/knife_miss.wav");
#else
	
#endif
}

void
w_combatknife_updateammo(player pl)
{
	
}

string
w_combatknife_wmodel(void)
{
	return (*ary_weaponData[WEAPON_ID::COMBATKNIFE]).sWorldModelPath;
}

string
w_combatknife_pmodel(void)
{
	return (*ary_weaponData[WEAPON_ID::COMBATKNIFE]).sPlayerModelPath;
}

string
w_combatknife_deathmsg(void)
{
	return "";
}

void
w_combatknife_draw(void)
{
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	
	weapon_base_onEquip(pl, ary_weaponData[WEAPON_ID::COMBATKNIFE], arg_thisWeapon);
}

void
w_combatknife_holster(void)
{
}

void
w_combatknife_primary(void)
{
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	float randomChoice;

	if (pl.w_attack_next > 0.0) {
		return;
	}
	
	INPUT_PRIMARY_TAP_GATE
	
	weapondata_basic_t baseRef = *ary_weaponData[WEAPON_ID::COMBATKNIFE];
	MELEE_HIT_RESPONSE hitRep =  weapon_base_onPrimaryAttack_melee(pl, ary_weaponData[WEAPON_ID::COMBATKNIFE], arg_thisWeapon, baseRef.fAttackDamage, 58);
	
	// Only the server is doing traces so far to get results for this to be worth checking.
#ifdef SERVER
	//printfline("melee hit reponse: %d soft? %d", hitRep, (hitRep==MELEE_HIT_RESPONSE::SOFT));
	if (hitRep == MELEE_HIT_RESPONSE::NONE ) {
		TS_Weapons_PlaySoundDirect(pl, "weapons/knife/knife_miss.wav");
	}else if(hitRep == MELEE_HIT_RESPONSE::SOFT){
		//nothin
	}else if(hitRep == MELEE_HIT_RESPONSE::METAL){
		TS_Weapons_PlaySoundDirect(pl, "weapons/knife/knife_hit.wav");
	}else if(hitRep == MELEE_HIT_RESPONSE::FLESH){
		arg_thisWeapon.forceBodygroup1Submodel = 2;
		TS_Weapons_PlaySoundDirect(pl, "weapons/knife/knife_hitbody.wav");
	}
#endif

	//Animation_ShootWeapon( self );
	//self.fAttackFinished = time + wptKNIFE.fAttackFinished;

	// actually do this animation the same regardless as far as we know.
	randomChoice = randomInRange_i(0, 2);
	if(randomChoice == 0){
		TS_Weapons_ViewAnimation(weaponseq_combatknife::slash1, (31.0f/30.0f) );
	}else if(randomChoice == 1){
		TS_Weapons_ViewAnimation(weaponseq_combatknife::left, (31.0f/30.0f) );
	}else if(randomChoice == 2){
		TS_Weapons_ViewAnimation(weaponseq_combatknife::right, (31.0f/30.0f) );
	}
	
}



void
w_combatknife_secondary(void)
{
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	float randomChoice;
	
	if (pl.w_attack_next > 0.0) {
		return;
	}
	
	INPUT_SECONDARY_TAP_GATE
	
	weapondata_basic_t baseRef = *ary_weaponData[WEAPON_ID::COMBATKNIFE];
	weapon_base_setWholeAttackDelay(pl, baseRef.fAttackDelay);
	
	if(arg_thisWeapon.iCount > 0){
		//throw it!  play this sound too.
		arg_thisWeapon.iCount -= 1;
		pl.updateSlotCountsForEquippedWeapon();
		arg_thisWeapon.forceBodygroup1Submodel = 1;  //reset, new knife is not bloody.
		TS_Weapons_PlaySoundDirect(pl, "weapons/knife/knife_miss.wav");
#ifdef SERVER
		CTSThrownProjectile::generate2(pl, arg_thisWeapon);
#endif
	}
	
	// TODO - Beware!  This method may be called many many times for a single knife throw
	// especially with packet delays.  So this draw may not even happen, not sure the
	// best way around that yet.
	printfline("IM A KNIFE I GOT THROWN YES current count: %i", arg_thisWeapon.iCount);
	if(arg_thisWeapon.iCount > 0){
		// another knife left?  Bring it up with a draw animation.
		TS_Weapons_ViewAnimation(weaponseq_combatknife::draw, (31.0f / 30.0f) );
	}else{
		
#ifdef SERVER
		// No knives left?  Unequip, pick something else.
		printfline("REMOVED, PRE.  invcount:%i", pl.ary_myWeapons_softMax);
		removeWeaponFromInventory(pl, pl.inventoryEquippedIndex);
		printfline("REMOVED, POST.  invcount:%i", pl.ary_myWeapons_softMax);
		playerEquipIdealSafe(pl);
#endif
		
		return FALSE;
	}
	
}

void
w_combatknife_reload(void)
{
	// how do you reload a sword
}

float
w_combatknife_aimanim(void)
{
	return self.flags & FL_CROUCHING ? ANIM_CR_AIM1HAND : ANIM_AIM1HAND;
}

void
w_combatknife_hud(void)
{
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	
	weapon_throwable_onDrawHUD(pl, (weapondata_throwable_t*)ary_weaponData[WEAPON_ID::COMBATKNIFE], arg_thisWeapon);
}

void
w_combatknife_hudpic(int selected, vector pos, float a)
{
	//
}

weapon_t w_combatknife =
{
	
	.name		= "combatknife",
	.id			= 0,  // not using this
	.slot		= 2,  // ?
	.slot_pos	= 0,  // not using this
	.weight		= 0,  // not using this
	.draw		= w_combatknife_draw,
	.holster	= w_combatknife_holster,
	.primary	= w_combatknife_primary,
	.secondary	= w_combatknife_secondary,
	.reload		= w_combatknife_reload,
	.release	= NULL,
	.crosshair	= w_combatknife_hud,
	.precache	= w_combatknife_precache,
	.pickup		= NULL,
	.updateammo	= w_combatknife_updateammo,
	.wmodel		= w_combatknife_wmodel,
	.pmodel		= w_combatknife_pmodel,
	.deathmsg	= w_combatknife_deathmsg,
	.aimanim	= w_combatknife_aimanim,
	.hudpic		= NULL
	
};

