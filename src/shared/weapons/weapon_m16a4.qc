

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




BOOLEAN weapon_M16A4_onPrimaryAttack(player localPlayer, weapondynamic_t arg_thisWeapon, BOOLEAN hasAmmo){
	return TRUE;
}
BOOLEAN weapon_M16A4_onPrimaryAttackRelease(player localPlayer, weapondynamic_t arg_thisWeapon, BOOLEAN hasAmmo){
	return FALSE;
}
BOOLEAN weapon_M16A4_onSecondaryAttack(player localPlayer, weapondynamic_t arg_thisWeapon, BOOLEAN hasAmmo){
	return FALSE;
}
BOOLEAN weapon_M16A4_onSecondaryAttackRelease(player localPlayer, weapondynamic_t arg_thisWeapon, BOOLEAN hasAmmo){
	//most weapons don't care about releases.  Also this only happens the one frame the input is detected
	//not held after being held continuously - further logic should be handled in a think method.
	return FALSE;
}

void weapon_M16A4_onEquip(player localPlayer, weapondynamic_t arg_thisWeapon){
}
BOOLEAN weapon_M16A4_onUnEquip(player localPlayer, weapondynamic_t arg_thisWeapon){
	return FALSE;
}
void weapon_M16A4_onThink(player localPlayer, weapondynamic_t arg_thisWeapon){
	weapon_gun_onThink(localPlayer, (weapondata_gun_t*)ary_weaponData[WEAPON_ID::M16A4], arg_thisWeapon);
	weapon_gun_onThink_burstFireLogic(localPlayer, (weapondata_gun_t*)ary_weaponData[WEAPON_ID::M16A4], arg_thisWeapon);
}
void weapon_M16A4_onDrawHUD(player localPlayer, weapondynamic_t arg_thisWeapon){
}
void weapon_M16A4_onReload(player localPlayer, weapondynamic_t arg_thisWeapon){
}
void weapon_M16A4_onColdCock(player localPlayer, weapondynamic_t arg_thisWeapon){
	
}


weapondata_ironsight_t weapon_M16A4 =
{
	WEAPONDATA_TYPEID_IRONSIGHT,
	"M16A4",
	"models/v_m16.mdl",
	"models/p_m16.mdl",
	"",
	"models/w_m16.mdl",
	"sprites/weapons/m16.spr",
	weapon_M16A4_onPrimaryAttack,
	weapon_M16A4_onPrimaryAttackRelease,
	weapon_M16A4_onSecondaryAttack,
	weapon_M16A4_onSecondaryAttackRelease,
	weapon_M16A4_onEquip,
	weapon_M16A4_onUnEquip,
	weapon_M16A4_onThink,
	weapon_M16A4_onDrawHUD,
	weapon_M16A4_onReload,
	weapon_M16A4_onColdCock,
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
	AMMO_ID::_5p56Nato,
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
w_m16a4_updateammo(player pl)
{
	//weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	//Weapons_UpdateAmmo(pl, arg_thisWeapon.iClipLeft, pl.ary_ammoTotal[AMMO_ID::_9x19mm], -1);
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
	float randomChoice;
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];


	if(pl.w_attack_next > 0.0){
		return;
	}
	
	if(arg_thisWeapon.iFireMode == BITS_FIREMODE_SEMI || arg_thisWeapon.iFireMode == BITS_FIREMODE_BURST){
		INPUT_PRIMARY_TAP_GATE
	}
	
	if (!arg_thisWeapon.iClipLeft || WEAPON_UNDERWATER_CHECK) {
		PLAY_CLICK_SOUND
		return;
	}

	TS_Weapons_PlaySoundDirect(pl, "weapons/m16/fire.wav");

	if(!arg_thisWeapon.iIronSight){
		randomChoice = random();
		if(randomChoice < 1/4){
			TS_Weapons_ViewAnimation(weaponseq_m16a4::shoot1, (31.0f/30.0f) );
		}else if(randomChoice < 2/4){
			TS_Weapons_ViewAnimation(weaponseq_m16a4::shoot2, (31.0f/30.0f) );
		}else if(randomChoice < 3/4){
			TS_Weapons_ViewAnimation(weaponseq_m16a4::sshoot1, (31.0f/30.0f) );
		}else{
			TS_Weapons_ViewAnimation(weaponseq_m16a4::sshoot2, (31.0f/30.0f) );
		}
	}else{
		randomChoice = random();
		if(randomChoice < 1/4){
			TS_Weapons_ViewAnimation(weaponseq_m16a4::shoot3, (31.0f/30.0f) );
		}else if(randomChoice < 2/4){
			TS_Weapons_ViewAnimation(weaponseq_m16a4::shoot4, (31.0f/30.0f) );
		}else if(randomChoice < 3/4){
			TS_Weapons_ViewAnimation(weaponseq_m16a4::sshoot3, (31.0f/30.0f) );
		}else{
			TS_Weapons_ViewAnimation(weaponseq_m16a4::sshoot4, (31.0f/30.0f) );
		}
	}
	
	
#ifdef CLIENT
	View_ShowMuzzleflash(MUZZLE_SMALL);
	View_AddEvent(w_ejectshell_pistol, 0.0f);
#endif
	
	
	if(arg_thisWeapon.iFireMode == BITS_FIREMODE_BURST)
	{
		/*
#ifdef SERVER
		weapon_base_burstFire(pl, ary_weaponData[WEAPON_ID::M16A4], arg_thisWeapon, BITS_AKIMBOCHOICE_LEFT, 3, 0.11);
		// signal for server logic... for now.
		return FALSE;
#else
		weapon_base_onAttack(pl, ary_weaponData[WEAPON_ID::M16A4], arg_thisWeapon, BITS_AKIMBOCHOICE_LEFT);
#endif
		*/
		
		weapon_base_burstFire(pl, ary_weaponData[WEAPON_ID::M16A4], arg_thisWeapon, BITS_AKIMBOCHOICE_LEFT, 3, 0.02);
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
	
	if(pl.w_attack_next > 0){
		return;
	}
	
	INPUT_SECONDARY_TAP_GATE
	
	if(arg_thisWeapon.iBitsUpgrade & BITS_WEAPONOPT_SCOPE){
		// toggle through the zoom.
		
		switch(pl.currentZoomChoice){
			case -1:{
				//pl.viewzoom = 32/80;
				pl.setZoom(0.4f);
				pl.currentZoomChoice++;
			break;}
			case 0:{
				//pl.viewzoom = 8/80;
				pl.setZoom(0.10f);
				pl.currentZoomChoice++;
			break;}
			case 1:{
				//pl.viewzoom = 0;
				pl.setZoom(1.00f);
				pl.currentZoomChoice = -1;
			break;}
		}//END OF switch

	}else{
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


// ???
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


// NOPE!  Handled by the buysidemenu, could make this give the instructions for drawing the button
// with the icon if really wanted
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


