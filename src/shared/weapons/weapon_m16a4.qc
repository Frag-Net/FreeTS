
enum weaponseq_m16a4{
	idle,
	reload,
	draw,
	shoot1,
	shoot2,
	sshoot1,
	sshoot2,
	idle2,
	change,
	rechange,
	shoot3,
	shoot4,
	sshoot3,
	sshoot4,
	reload2
};

void weapon_m16a4_onPrimaryAttackRelease(player pl, weapondynamic_t arg_thisWeapon){
	
}
void weapon_m16a4_onSecondaryAttackRelease(player pl, weapondynamic_t arg_thisWeapon){
	
}
void weapon_m16a4_onThink(player pl, weapondynamic_t arg_thisWeapon){
	weapon_gun_onThink(pl, (weapondata_gun_t*)ary_weaponData[WEAPON_ID::M16A4], arg_thisWeapon);
	weapon_gun_onThink_burstFireLogic(pl, (weapondata_gun_t*)ary_weaponData[WEAPON_ID::M16A4], arg_thisWeapon);
}
void weapon_m16a4_onColdCock(player pl, weapondynamic_t arg_thisWeapon){
	
}

weapondata_ironsight_t weapon_m16a4 =
{
	WEAPONDATA_TYPEID_IRONSIGHT,
	"M16A4",
	"models/v_m16.mdl",
	"models/p_m16.mdl",
	"",
	"models/w_m16.mdl",
	"sprites/weapons/m16.spr",
	weapon_m16a4_onPrimaryAttackRelease,
	weapon_m16a4_onSecondaryAttackRelease,
	weapon_m16a4_onThink,
	weapon_m16a4_onColdCock,
	weaponseq_m16a4::idle,
	weaponseq_m16a4::draw,
	31.0f / 35.0f,
	0.0625f,  //fire delay.
	7.0f,  //dmg
	TRUE,
	BITS_WEAPONOPT_LASERSIGHT | BITS_WEAPONOPT_FLASHLIGHT | BITS_WEAPONOPT_SCOPE,
	BITS_WEAPONOPT_NONE,
	2500,
	40,
	BUYCATEGORY_RIFLES,
	4,
	{0.001000, 2.500000, 0.000000},
	WEAPON_AKIMBO_UPGRADE_ID::NONE,
	BITS_FIREMODE_SEMI | BITS_FIREMODE_BURST,
	BITS_FIREMODE_SEMI,
	AMMO_ID::_5P56NATO,
	18,  //clip
	4096, //range
	weaponseq_m16a4::reload,
	96.0f / 35.0f,
	-1,
	-1,
	-1,
	1,
	{
		weaponseq_m16a4::change,
		21.0f/60.0f,
		weaponseq_m16a4::rechange,
		21.0f/60.0f,
		weaponseq_m16a4::idle2,
		weaponseq_m16a4::reload2,
		96.0f / 35.0f,
		{0.001000, 2.500000, 0.000000}
	}
};



void
w_m16a4_precache(void)
{
	weapon_precache(ary_weaponData[WEAPON_ID::M16A4]);
#ifdef SERVER
	precache_sound("weapons/m16/fire.wav");
#else
	
#endif
}

void
w_m16a4_updateammo(player pl)
{
}

string
w_m16a4_wmodel(void)
{
	return (*ary_weaponData[WEAPON_ID::M16A4]).sWorldModelPath;
}

string
w_m16a4_pmodel(void)
{
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	return (*ary_weaponData[WEAPON_ID::M16A4]).sPlayerModelPath;
}

string
w_m16a4_deathmsg(void)
{
	return "";
}

void
w_m16a4_draw(void)
{
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	
	weapon_base_onEquip(pl, ary_weaponData[WEAPON_ID::M16A4], arg_thisWeapon);
}

void
w_m16a4_holster(void)
{
}


void
w_m16a4_primary(void)
{
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];


	if(pl.w_attack_next > 0.0){
		return;
	}
	
	if(arg_thisWeapon.iFireMode == BITS_FIREMODE_SEMI || arg_thisWeapon.iFireMode == BITS_FIREMODE_BURST){
		INPUT_PRIMARY_TAP_GATE
	}
	
	if(
		pl.aryNextBurstShotTime_listenIndex != -1 &&
		arg_thisWeapon.iFireMode != BITS_FIREMODE_NONE
	){
		// the player is trying to manually fire while burst-fire is in the middle
		// of sending shots?  STOP
		return;
	}
	
	if (!arg_thisWeapon.iClipLeft || WEAPON_UNDERWATER_CHECK) {
		PLAY_CLICK_SOUND
		return;
	}

	SoundPitched_Send(pl, SNDP_M16A4_FIRE);
	
	int r;
	if(!arg_thisWeapon.iIronSight){
		r = (float)input_sequence % 4;
		if(r == 0){
			TS_Weapons_ViewAnimation(weaponseq_m16a4::shoot1, (31.0f/30.0f) );
		}else if(r == 1){
			TS_Weapons_ViewAnimation(weaponseq_m16a4::shoot2, (31.0f/30.0f) );
		}else if(r == 2){
			TS_Weapons_ViewAnimation(weaponseq_m16a4::sshoot1, (31.0f/30.0f) );
		}else{
			TS_Weapons_ViewAnimation(weaponseq_m16a4::sshoot2, (31.0f/30.0f) );
		}
	}else{
		r = (float)input_sequence % 4;
		if(r == 0){
			TS_Weapons_ViewAnimation(weaponseq_m16a4::shoot3, (31.0f/30.0f) );
		}else if(r == 1){
			TS_Weapons_ViewAnimation(weaponseq_m16a4::shoot4, (31.0f/30.0f) );
		}else if(r == 2){
			TS_Weapons_ViewAnimation(weaponseq_m16a4::sshoot3, (31.0f/30.0f) );
		}else{
			TS_Weapons_ViewAnimation(weaponseq_m16a4::sshoot4, (31.0f/30.0f) );
		}
	}
	
	weapon_ClientEffects(MUZZLEFLASH_ID::RIFLE, SHELLEJECT_ID::_56);
	
	if(arg_thisWeapon.iFireMode == BITS_FIREMODE_BURST)
	{
		weapon_gun_burstFire(pl, (weapondata_gun_t*)ary_weaponData[WEAPON_ID::M16A4], arg_thisWeapon, BITS_AKIMBOCHOICE_LEFT, 3, 0.02, 0.18);
	}
	else if(arg_thisWeapon.iFireMode == BITS_FIREMODE_SEMI)
	{
		weapon_base_onAttack(pl, ary_weaponData[WEAPON_ID::M16A4], arg_thisWeapon, BITS_AKIMBOCHOICE_LEFT);
		
		weapon_base_setWholeAttackDelay(pl, (*ary_weaponData[arg_thisWeapon.weaponID]).fAttackDelay);

	}else if(arg_thisWeapon.iFireMode == BITS_FIREMODE_NONE)
	{
		// !!! Burst-fire automatics only
		weapon_base_onAttack(pl, ary_weaponData[WEAPON_ID::M16A4], arg_thisWeapon, BITS_AKIMBOCHOICE_LEFT);
		
		//weapon_base_setWholeAttackDelay(pl, 0.5);
	}
	
	
	if (self.flags & FL_CROUCHING){
		Animation_PlayerTop(pl, ANIM_CR_SHOOT1HAND, 0.2f);
	}else{
		Animation_PlayerTop(pl, ANIM_SHOOT1HAND, 0.2f);
	}
	
}



void
w_m16a4_secondary(void)
{
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	
	INPUT_SECONDARY_TAP_GATE
	
	if(arg_thisWeapon.iBitsUpgrade & BITS_WEAPONOPT_SCOPE){
		// toggle through the zoom.
		pl.iZoomLevel = (pl.iZoomLevel + 1) % 3;
		switch(pl.iZoomLevel){
		case 0:pl.setZoom(1.00f);break;
		case 1:pl.setZoom(0.40f);break;
		case 2:pl.setZoom(0.10f);break;
		}
	}else{
		if(pl.w_attack_next > 0){
			return;
		}
		// no scope?  we use ironsights then.
		weapon_ironsight_ToggleIronsight(pl , (weapondata_ironsight_t*)ary_weaponData[WEAPON_ID::M16A4], arg_thisWeapon);
	}
	
}

void
w_m16a4_reload(void)
{
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];

	weapon_ironsight_Reload(pl, (weapondata_ironsight_t*)ary_weaponData[WEAPON_ID::M16A4], arg_thisWeapon);
}

float
w_m16a4_aimanim(void)
{
	return self.flags & FL_CROUCHING ? ANIM_CR_AIM1HAND : ANIM_AIM1HAND;
}

void
w_m16a4_hud(void)
{
	player pl = (player)self;
	
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	weapon_gun_onDrawHUD(pl, (weapondata_gun_t*)ary_weaponData[WEAPON_ID::M16A4], arg_thisWeapon);

}

void
w_m16a4_hudpic(int selected, vector pos, float a)
{
	//
}

weapon_t w_m16a4 =
{
	
	.name		= "m16a4",
	.id			= 0,  // not using this
	.slot		= 2,  // ?
	.slot_pos	= 0,  // not using this
	.weight		= 0,  // not using this
	.draw		= w_m16a4_draw,
	.holster	= w_m16a4_holster,
	.primary	= w_m16a4_primary,
	.secondary	= w_m16a4_secondary,
	.reload		= w_m16a4_reload,
	.release	= NULL,
	.crosshair	= w_m16a4_hud,
	.precache	= w_m16a4_precache,
	.pickup		= NULL,
	.updateammo	= w_m16a4_updateammo,
	.wmodel		= w_m16a4_wmodel,
	.pmodel		= w_m16a4_pmodel,
	.deathmsg	= w_m16a4_deathmsg,
	.aimanim	= w_m16a4_aimanim,
	.hudpic		= NULL
	
};


