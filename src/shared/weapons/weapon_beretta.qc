

enum weaponseq_beretta{
	idle,
	shoot,
	shoot2,
	shootempty,
	draw,
	reload
};



BOOLEAN weapon_Beretta_onPrimaryAttack(player localPlayer, weapondynamic_t arg_thisWeapon, BOOLEAN hasAmmo){
	return TRUE;
}
BOOLEAN weapon_Beretta_onPrimaryAttackRelease(player localPlayer, weapondynamic_t arg_thisWeapon, BOOLEAN hasAmmo){
	return FALSE;
}
BOOLEAN weapon_Beretta_onSecondaryAttack(player localPlayer, weapondynamic_t arg_thisWeapon, BOOLEAN hasAmmo){
	return FALSE;
}
BOOLEAN weapon_Beretta_onSecondaryAttackRelease(player localPlayer, weapondynamic_t arg_thisWeapon, BOOLEAN hasAmmo){
	return FALSE;
}

void weapon_Beretta_onEquip(player localPlayer, weapondynamic_t arg_thisWeapon){
}
BOOLEAN weapon_Beretta_onUnEquip(player localPlayer, weapondynamic_t arg_thisWeapon){
	return FALSE;
}
void weapon_Beretta_onThink(player localPlayer, weapondynamic_t arg_thisWeapon){
	weapon_gun_onThink(localPlayer, (weapondata_gun_t*)ary_weaponData[WEAPON_ID::Beretta], arg_thisWeapon);
}
void weapon_Beretta_onDrawHUD(player localPlayer, weapondynamic_t arg_thisWeapon){
}
void weapon_Beretta_onReload(player localPlayer, weapondynamic_t arg_thisWeapon){
}
void weapon_Beretta_onColdCock(player localPlayer, weapondynamic_t arg_thisWeapon){
	
}


weapondata_gun_t weapon_Beretta =
{
	WEAPONDATA_TYPEID_GUN,
	"Beretta",
	"models/v_beretta.mdl",
	"models/p_beretta.mdl",
	"models/p_beretta_sil.mdl",
	"models/w_berettas.mdl",
	"sprites/weapons/beretta.spr",
	weapon_Beretta_onPrimaryAttack,
	weapon_Beretta_onPrimaryAttackRelease,
	weapon_Beretta_onSecondaryAttack,
	weapon_Beretta_onSecondaryAttackRelease,
	weapon_Beretta_onEquip,
	weapon_Beretta_onUnEquip,
	weapon_Beretta_onThink,
	weapon_Beretta_onDrawHUD,
	weapon_Beretta_onReload,
	weapon_Beretta_onColdCock,
	weaponseq_beretta::idle,
	weaponseq_beretta::draw,
	31.0f / 30.0f,
	0.19f,  //fire delay. this is most certainly wrong. find something more accurate later.
	15.0f,  //dmg
	TRUE,
	BITS_WEAPONOPT_SILENCER | BITS_WEAPONOPT_LASERSIGHT | BITS_WEAPONOPT_FLASHLIGHT | BITS_WEAPONOPT_AKIMBO,
	BITS_WEAPONOPT_NONE,
	900,
	10,
	BUYCATEGORY_HANDGUNS,
	2,
	{0.018000, 1.300000, 0.000000},  //ESTIMATE, from how a lot of other stuff went from akimbo -> singular.
	WEAPON_AKIMBO_UPGRADE_ID::Beretta,
	BITS_FIREMODE_SEMI,
	BITS_FIREMODE_SEMI,
	AMMO_ID::_9x19mm,
	15,  //clip
	4096, //range
	weaponseq_beretta::reload,
	41.0f / 35.0f,
	1,
	2,
	2,
	-1
};










void
w_beretta_precache(void)
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
w_beretta_updateammo(player pl)
{
	//weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	//Weapons_UpdateAmmo(pl, arg_thisWeapon.iClipLeft, pl.ary_ammoTotal[AMMO_ID::_9x19mm], -1);
}

string
w_beretta_wmodel(void)
{
	return (*ary_weaponData[WEAPON_ID::Beretta]).sWorldModelPath;
}

string
w_beretta_pmodel(void)
{
	// Do we have the silencer?
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	if(!(arg_thisWeapon.iBitsUpgrade & BITS_WEAPONOPT_SILENCER) ){
		return (*ary_weaponData[WEAPON_ID::Beretta]).sPlayerModelPath;
	} else {
		return (*ary_weaponData[WEAPON_ID::Beretta]).sPlayerSilencerModelPath;
	}
}

string
w_beretta_deathmsg(void)
{
	return "";
}

void
w_beretta_draw(void)
{
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	weapondata_basic_t* basicP = ary_weaponData[WEAPON_ID::Beretta];
	
	weapon_base_onEquip(pl, basicP, arg_thisWeapon);
}


void
w_beretta_holster(void)
{
}


void
w_beretta_primary(void)
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
	
	
	if(!(arg_thisWeapon.iBitsUpgrade & BITS_WEAPONOPT_SILENCER) ){
		SoundPitched_Send(pl, SNDP_BERETTA);
	} else {
		SoundPitched_Send(pl, SNDP_BERETTA_SIL);
	}
	
	
	
	if(arg_thisWeapon.iClipLeft > 0){
		randomChoice = random();
		if(randomChoice <= 0.5){
			TS_Weapons_ViewAnimation(weaponseq_beretta::shoot, 31.0f/35.0f);
		}else{
			TS_Weapons_ViewAnimation(weaponseq_beretta::shoot2, 31.0f/35.0f);
		}
	}else{
		//that was our last bullet?
		TS_Weapons_ViewAnimation(weaponseq_beretta::shootempty, 31.0f/35.0f);
	}
	
	
#ifdef CLIENT
	View_ShowMuzzleflash(MUZZLE_SMALL);
	View_AddEvent(w_ejectshell_pistol, 0.0f);
#endif

	
	weapon_base_onAttack(pl, ary_weaponData[WEAPON_ID::Beretta], arg_thisWeapon, BITS_AKIMBOCHOICE_LEFT);
	
	weapon_base_setWholeAttackDelay(pl, (*ary_weaponData[arg_thisWeapon.weaponID]).fAttackDelay);

	if (self.flags & FL_CROUCHING){
		Animation_PlayerTop(pl, ANIM_CR_SHOOT1HAND, 0.2f);
	}else{
		Animation_PlayerTop(pl, ANIM_SHOOT1HAND, 0.2f);
	}
	
}



void
w_beretta_secondary(void)
{
}



void
w_beretta_reload(void)
{
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];

	weapon_gun_Reload(pl, (weapondata_gun_t*)ary_weaponData[WEAPON_ID::Beretta], arg_thisWeapon);
}



// ???
float
w_beretta_aimanim(void)
{
	return self.flags & FL_CROUCHING ? ANIM_CR_AIM1HAND : ANIM_AIM1HAND;
}


void
w_beretta_hud(void)
{
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	weapon_gun_onDrawHUD(pl, (weapondata_gun_t*)ary_weaponData[WEAPON_ID::Beretta], arg_thisWeapon);
}



// NOPE!  Handled by the buysidemenu, could make this give the instructions for drawing the button
// with the icon if really wanted
void
w_beretta_hudpic(int selected, vector pos, float a)
{
	//
}



weapon_t w_beretta =
{
	
	.name		= "beretta",
	.id			= 0,  // not using this
	.slot		= 2,  // ?
	.slot_pos	= 0,  // not using this
	.weight		= 0,  // not using this
	.draw		= w_beretta_draw,
	.holster	= w_beretta_holster,
	.primary	= w_beretta_primary,
	.secondary	= w_beretta_secondary,
	.reload		= w_beretta_reload,
	.release	= NULL,
	.crosshair	= w_beretta_hud,
	.precache	= w_beretta_precache,
	.pickup		= NULL,
	.updateammo	= w_beretta_updateammo,
	.wmodel		= w_beretta_wmodel,
	.pmodel		= w_beretta_pmodel,
	.deathmsg	= w_beretta_deathmsg,
	.aimanim	= w_beretta_aimanim,
	.hudpic		= NULL
	
};







