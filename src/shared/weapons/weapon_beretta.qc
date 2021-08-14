
enum weaponseq_beretta{
	idle,
	shoot,
	shoot2,
	shootempty,
	draw,
	reload
};

void weapon_beretta_onPrimaryAttackRelease(player pl, weapondynamic_t arg_thisWeapon){
	
}
void weapon_beretta_onSecondaryAttackRelease(player pl, weapondynamic_t arg_thisWeapon){
	
}

void weapon_beretta_onThink(player pl, weapondynamic_t arg_thisWeapon){
	weapon_gun_onThink(pl, (weapondata_gun_t*)ary_weaponData[WEAPON_ID::BERETTA], arg_thisWeapon);
}
void weapon_beretta_onColdCock(player pl, weapondynamic_t arg_thisWeapon){
	
}

weapondata_gun_t weapon_beretta =
{
	WEAPONDATA_TYPEID_GUN,
	"beretta",
	"models/v_beretta.mdl",
	"models/p_beretta.mdl",
	"models/p_beretta_sil.mdl",
	"models/w_berettas.mdl",
	"sprites/weapons/beretta.spr",
	weapon_beretta_onPrimaryAttackRelease,
	weapon_beretta_onSecondaryAttackRelease,
	weapon_beretta_onThink,
	weapon_beretta_onColdCock,
	weaponseq_beretta::idle,
	weaponseq_beretta::draw,
	31.0f / 30.0f,
	0.19f,  //fire delay
	15.0f,  //dmg
	TRUE,
	BITS_WEAPONOPT_SILENCER | BITS_WEAPONOPT_LASERSIGHT | BITS_WEAPONOPT_FLASHLIGHT | BITS_WEAPONOPT_AKIMBO,
	BITS_WEAPONOPT_NONE,
	900,
	10,
	BUYCATEGORY_HANDGUNS,
	2,
	{0.018000, 1.300000, 0.000000},  //ESTIMATE, from how a lot of other stuff went from akimbo -> singular.
	WEAPON_AKIMBO_UPGRADE_ID::BERETTA,
	BITS_FIREMODE_SEMI,
	BITS_FIREMODE_SEMI,
	AMMO_ID::_9X19MM,
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
	weapon_precache(ary_weaponData[WEAPON_ID::BERETTA]);
#ifdef SERVER
	//precache_sound("weapons/beretta/clipin.wav");
	//precache_sound("weapons/beretta/clipout.wav");
	precache_sound("weapons/beretta/fire-sil.wav");
	precache_sound("weapons/beretta/fire.wav");
	//precache_sound("weapons/beretta/sliderelease.wav");
#else
	
#endif
}

void
w_beretta_updateammo(player pl)
{
}

string
w_beretta_wmodel(void)
{
	return (*ary_weaponData[WEAPON_ID::BERETTA]).sWorldModelPath;
}

string
w_beretta_pmodel(void)
{
	// Do we have the silencer?
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	if(!(arg_thisWeapon.iBitsUpgrade & BITS_WEAPONOPT_SILENCER) ){
		return (*ary_weaponData[WEAPON_ID::BERETTA]).sPlayerModelPath;
	} else {
		return (*ary_weaponData[WEAPON_ID::BERETTA]).sPlayerSilencerModelPath;
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
	weapondata_basic_t* basicP = ary_weaponData[WEAPON_ID::BERETTA];
	
	weapon_base_onEquip(pl, basicP, arg_thisWeapon);
}


void
w_beretta_holster(void)
{
}


void
w_beretta_primary(void)
{
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
		SoundPitched_Send(pl, SNDP_BERETTA_FIRE);
	} else {
		SoundPitched_Send(pl, SNDP_BERETTA_FIRE_SIL);
	}
	
	
	
	if(arg_thisWeapon.iClipLeft > 0){
		int r = (float)input_sequence % 2;
		if(r == 0){
			TS_Weapons_ViewAnimation(weaponseq_beretta::shoot, 31.0f/35.0f);
		}else{
			TS_Weapons_ViewAnimation(weaponseq_beretta::shoot2, 31.0f/35.0f);
		}
	}else{
		//that was our last bullet?
		TS_Weapons_ViewAnimation(weaponseq_beretta::shootempty, 31.0f/35.0f);
	}
	
	if(!(arg_thisWeapon.iBitsUpgrade & BITS_WEAPONOPT_SILENCER) ){
		weapon_ClientEffects(MUZZLEFLASH_ID::SMALL, SHELLEJECT_ID::_9MM);
	} else {
		weapon_EjectShell(SHELLEJECT_ID::_9MM);
	}
	
	weapon_base_onAttack(pl, ary_weaponData[WEAPON_ID::BERETTA], arg_thisWeapon, BITS_AKIMBOCHOICE_LEFT);
	
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

	weapon_gun_Reload(pl, (weapondata_gun_t*)ary_weaponData[WEAPON_ID::BERETTA], arg_thisWeapon);
}

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
	weapon_gun_onDrawHUD(pl, (weapondata_gun_t*)ary_weaponData[WEAPON_ID::BERETTA], arg_thisWeapon);
}

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







