
enum weaponseq_miniuzi{
	idle = 0,
	reload = 1,
	draw = 2,
	shoot = 3,
	shoot2 = 4,
	sshoot = 5,
	sshoot2 = 6,
	// idle for ironsight fire (holding from left).  why not "idleb"?
	idle2 = 7,
	change = 8,
	rechange = 9,
	// names further given "b"'s for separation, lacking in model sequence names
	shootb = 10,
	shootb2 = 11,
	sshootb = 12,
	sshootb2 = 13,
	// except this, came with the "b"
	reloadb = 14
};

void weapon_miniuzi_onPrimaryAttackRelease(player pl, weapondynamic_t arg_thisWeapon){
	
}
void weapon_miniuzi_onSecondaryAttackRelease(player pl, weapondynamic_t arg_thisWeapon){
	
}
void weapon_miniuzi_onThink(player pl, weapondynamic_t arg_thisWeapon){
	weapon_gun_onThink(pl, (weapondata_gun_t*)ary_weaponData[WEAPON_ID::MINIUZI], arg_thisWeapon);
}
void weapon_miniuzi_onColdCock(player pl, weapondynamic_t arg_thisWeapon){
	
}

weapondata_ironsight_t weapon_miniuzi =
{
	WEAPONDATA_TYPEID_IRONSIGHT,
	"Mini-Uzi",
	"models/v_uzi.mdl",
	"models/p_uzi.mdl",
	"models/p_uzi_sil.mdl",
	"models/w_uzi.mdl",
	"sprites/weapons/uzi.spr",
	weapon_miniuzi_onPrimaryAttackRelease,
	weapon_miniuzi_onSecondaryAttackRelease,
	weapon_miniuzi_onThink,
	weapon_miniuzi_onColdCock,
	weaponseq_miniuzi::idle,
	weaponseq_miniuzi::draw,
	31.0f / 30.0f,
	0.0625f,  //fire delay.
	7.0f,  //dmg
	TRUE,
	BITS_WEAPONOPT_SILENCER | BITS_WEAPONOPT_AKIMBO,
	BITS_WEAPONOPT_NONE,
	1300,
	20,
	BUYCATEGORY_SMGS,
	3,
	{0.030000, 2.000000, 0.005000},
	WEAPON_AKIMBO_UPGRADE_ID::MINIUZI,
	BITS_FIREMODE_FULL | BITS_FIREMODE_SEMI,
	BITS_FIREMODE_FULL,
	AMMO_ID::_9X19MM,
	32,  //clip
	4096, //range
	weaponseq_miniuzi::reload,
	111.0f / 50.0f,
	1,
	-1,
	-1,
	-1,
	{
		weaponseq_miniuzi::change,
		31.0f/40.0f,
		weaponseq_miniuzi::rechange,
		31.0f/40.0f,
		weaponseq_miniuzi::idle2,
		weaponseq_miniuzi::reloadb,
		137.0f/50.0f,
		{0.030000, 2.000000, 0.005000}
	}
};



void
w_miniuzi_precache(void)
{
	weapon_precache(ary_weaponData[WEAPON_ID::MINIUZI]);
#ifdef SERVER
	//precache_sound("weapons/uzi/clipin.wav");
	//precache_sound("weapons/uzi/clipout.wav");
	//precache_sound("weapons/uzi/slideback.wav");
	precache_sound("weapons/uzi/uzi-fire-sil.wav");
	precache_sound("weapons/uzi/uzi-fire.wav");
#else
	
#endif
}

void
w_miniuzi_updateammo(player pl)
{
}

string
w_miniuzi_wmodel(void)
{
	return (*ary_weaponData[WEAPON_ID::MINIUZI]).sWorldModelPath;
}

string
w_miniuzi_pmodel(void)
{
	// Do we have the silencer?
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	if(!(arg_thisWeapon.iBitsUpgrade & BITS_WEAPONOPT_SILENCER) ){
		return (*ary_weaponData[WEAPON_ID::MINIUZI]).sPlayerModelPath;
	} else {
		return (*ary_weaponData[WEAPON_ID::MINIUZI]).sPlayerSilencerModelPath;
	}
}

string
w_miniuzi_deathmsg(void)
{
	return "";
}

void
w_miniuzi_draw(void)
{
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	
	weapon_base_onEquip(pl, ary_weaponData[WEAPON_ID::MINIUZI], arg_thisWeapon);
}

void
w_miniuzi_holster(void)
{
}


void
w_miniuzi_primary(void)
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
		SoundPitched_Send(pl, SNDP_MINIUZI_FIRE);
	} else {
		SoundPitched_Send(pl, SNDP_MINIUZI_FIRE_SIL);
	}

	if(!arg_thisWeapon.iIronSight){
		randomChoice = random();
		if(randomChoice < 1/4){
			TS_Weapons_ViewAnimation(weaponseq_miniuzi::shoot, (31.0f/30.0f) );
		}else if(randomChoice < 2/4){
			TS_Weapons_ViewAnimation(weaponseq_miniuzi::shoot2, (31.0f/30.0f) );
		}else if(randomChoice < 3/4){
			TS_Weapons_ViewAnimation(weaponseq_miniuzi::sshoot, (31.0f/30.0f) );
		}else{  //4/4
			TS_Weapons_ViewAnimation(weaponseq_miniuzi::sshoot2, (31.0f/30.0f) );
		}
	}else{
		randomChoice = random();
		if(randomChoice < 1/4){
			TS_Weapons_ViewAnimation(weaponseq_miniuzi::shootb, (31.0f/30.0f) );
		}else if(randomChoice < 2/4){
			TS_Weapons_ViewAnimation(weaponseq_miniuzi::shootb2, (31.0f/30.0f) );
		}else if(randomChoice < 3/4){
			TS_Weapons_ViewAnimation(weaponseq_miniuzi::sshootb, (31.0f/30.0f) );
		}else{  //4/4
			TS_Weapons_ViewAnimation(weaponseq_miniuzi::sshootb2, (31.0f/30.0f) );
		}
	}
	
#ifdef CLIENT
	View_ShowMuzzleflash(MUZZLE_SMALL);
	View_AddEvent(w_ejectshell_pistol, 0.0f);
#endif
	
	weapon_base_onAttack(pl, ary_weaponData[WEAPON_ID::MINIUZI], arg_thisWeapon, BITS_AKIMBOCHOICE_LEFT);
	
	weapon_base_setWholeAttackDelay(pl, (*ary_weaponData[arg_thisWeapon.weaponID]).fAttackDelay);

	if (self.flags & FL_CROUCHING){
		Animation_PlayerTop(pl, ANIM_CR_SHOOT1HAND, 0.2f);
	}else{
		Animation_PlayerTop(pl, ANIM_SHOOT1HAND, 0.2f);
	}
}



void
w_miniuzi_secondary(void)
{
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	
	if(pl.w_attack_next > 0){
		return;
	}
	
	INPUT_SECONDARY_TAP_GATE
	
	weapon_ironsight_ToggleIronsight(pl, (weapondata_ironsight_t*)ary_weaponData[WEAPON_ID::MINIUZI], arg_thisWeapon);
}


void
w_miniuzi_reload(void)
{
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];

	weapon_ironsight_Reload(pl, (weapondata_ironsight_t*)ary_weaponData[WEAPON_ID::MINIUZI], arg_thisWeapon);

}

float
w_miniuzi_aimanim(void)
{
	return self.flags & FL_CROUCHING ? ANIM_CR_AIM1HAND : ANIM_AIM1HAND;
}

void
w_miniuzi_hud(void)
{
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	weapon_gun_onDrawHUD(pl, (weapondata_gun_t*)ary_weaponData[WEAPON_ID::MINIUZI], arg_thisWeapon);

}

void
w_miniuzi_hudpic(int selected, vector pos, float a)
{
	//
}


weapon_t w_miniuzi =
{
	
	.name		= "miniuzi",
	.id			= 0,  // not using this
	.slot		= 2,  // ?
	.slot_pos	= 0,  // not using this
	.weight		= 0,  // not using this
	.draw		= w_miniuzi_draw,
	.holster	= w_miniuzi_holster,
	.primary	= w_miniuzi_primary,
	.secondary	= w_miniuzi_secondary,
	.reload		= w_miniuzi_reload,
	.release	= NULL,
	.crosshair	= w_miniuzi_hud,
	.precache	= w_miniuzi_precache,
	.pickup		= NULL,
	.updateammo	= w_miniuzi_updateammo,
	.wmodel		= w_miniuzi_wmodel,
	.pmodel		= w_miniuzi_pmodel,
	.deathmsg	= w_miniuzi_deathmsg,
	.aimanim	= w_miniuzi_aimanim,
	.hudpic		= NULL
	
};

