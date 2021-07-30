
enum weaponseq_mac10{
	idle,
	reload,
	draw,
	shoot,
	shoot2,
	shoot3,
	sshoot,
	sshoot2,
	sshoot3,
	idle2,
	change,
	rechange,
	shootb,
	shootb2,
	shootb3,
	sshootb,
	sshootb2,
	sshootb3,
	reload_2   //RENAMED... really guys, identical name.
};


BOOLEAN weapon_MAC10_onPrimaryAttack(player localPlayer, weapondynamic_t arg_thisWeapon, BOOLEAN hasAmmo){
	return TRUE;
}
BOOLEAN weapon_MAC10_onPrimaryAttackRelease(player localPlayer, weapondynamic_t arg_thisWeapon, BOOLEAN hasAmmo){
	return FALSE;
}
BOOLEAN weapon_MAC10_onSecondaryAttack(player localPlayer, weapondynamic_t arg_thisWeapon, BOOLEAN hasAmmo){
	return FALSE;
}
BOOLEAN weapon_MAC10_onSecondaryAttackRelease(player localPlayer, weapondynamic_t arg_thisWeapon, BOOLEAN hasAmmo){
	return FALSE;
}

void weapon_MAC10_onEquip(player localPlayer, weapondynamic_t arg_thisWeapon){
}
BOOLEAN weapon_MAC10_onUnEquip(player localPlayer, weapondynamic_t arg_thisWeapon){
	return FALSE;
}
void weapon_MAC10_onThink(player localPlayer, weapondynamic_t arg_thisWeapon){
	weapon_gun_onThink(localPlayer, (weapondata_gun_t*)ary_weaponData[WEAPON_ID::MAC10], arg_thisWeapon);
}
void weapon_MAC10_onDrawHUD(player localPlayer, weapondynamic_t arg_thisWeapon){
}
void weapon_MAC10_onReload(player localPlayer, weapondynamic_t arg_thisWeapon){
}
void weapon_MAC10_onColdCock(player localPlayer, weapondynamic_t arg_thisWeapon){
	
}


weapondata_ironsight_t weapon_MAC10 =
{
	WEAPONDATA_TYPEID_IRONSIGHT,
	"MAC10",
	"models/v_mac10.mdl",
	"models/p_mac10.mdl",
	"models/p_mac10_sil.mdl",
	"models/w_mac10.mdl",
	"sprites/weapons/mac10.spr",
	weapon_MAC10_onPrimaryAttack,
	weapon_MAC10_onPrimaryAttackRelease,
	weapon_MAC10_onSecondaryAttack,
	weapon_MAC10_onSecondaryAttackRelease,
	weapon_MAC10_onEquip,
	weapon_MAC10_onUnEquip,
	weapon_MAC10_onThink,
	weapon_MAC10_onDrawHUD,
	weapon_MAC10_onReload,
	weapon_MAC10_onColdCock,
	weaponseq_mac10::idle,
	weaponseq_mac10::draw,
	31.0f / 30.0f,
	0.0625f,  //fire delay.
	7.0f,  //dmg
	TRUE,
	BITS_WEAPONOPT_SILENCER,
	BITS_WEAPONOPT_NONE,
	2300,
	25,
	BUYCATEGORY_SMGS,
	3,
	{0.015000, 2.550000, 0.005000},
	WEAPON_AKIMBO_UPGRADE_ID::NONE,
	BITS_FIREMODE_FULL | BITS_FIREMODE_SEMI,
	BITS_FIREMODE_FULL,
	AMMO_ID::_45Acp,
	32,  //clip
	4096, //range
	weaponseq_mac10::reload,
	87.0f / 40.0f,
	1,
	-1,
	-1,
	-1,
	{
		weaponseq_mac10::change,
		21.0f/40.0f,
		weaponseq_mac10::rechange,
		21.0f/40.0f,
		weaponseq_mac10::idle2,
		weaponseq_mac10::reload_2,
		103.0f/40.0f,
		{0.015000, 2.550000, 0.005000}
	}
};






void
w_mac10_precache(void)
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
w_mac10_updateammo(player pl)
{
	//weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	//Weapons_UpdateAmmo(pl, arg_thisWeapon.iClipLeft, pl.ary_ammoTotal[AMMO_ID::_9x19mm], -1);
}

string
w_mac10_wmodel(void)
{
	return (*ary_weaponData[WEAPON_ID::MAC10]).sWorldModelPath;
}

string
w_mac10_pmodel(void)
{
	// Do we have the silencer?
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	if(!(arg_thisWeapon.iBitsUpgrade & BITS_WEAPONOPT_SILENCER) ){
		return (*ary_weaponData[WEAPON_ID::MAC10]).sPlayerModelPath;
	} else {
		return (*ary_weaponData[WEAPON_ID::MAC10]).sPlayerSilencerModelPath;
	}
}

string
w_mac10_deathmsg(void)
{
	return "";
}

void
w_mac10_draw(void)
{
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	
	weapon_base_onEquip(pl, ary_weaponData[WEAPON_ID::MAC10], arg_thisWeapon);
}

void
w_mac10_holster(void)
{
}

void
w_mac10_primary(void)
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
		TS_Weapons_PlaySoundDirect(pl, "weapons/mac10/mac10-fire.wav");
	} else {
		TS_Weapons_PlaySoundDirect(pl, "weapons/mac10/mac10-fire-sil.wav");
	}

	if(!arg_thisWeapon.iIronSight){
		randomChoice = random();
		if(randomChoice < 1/6){
			TS_Weapons_ViewAnimation(weaponseq_mac10::shoot, 31.0f/30.0f);
		}else if(randomChoice < 2/6){
			TS_Weapons_ViewAnimation(weaponseq_mac10::shoot2, 31.0f/30.0f);
		}else if(randomChoice < 3/6){
			TS_Weapons_ViewAnimation(weaponseq_mac10::shoot3, 31.0f/30.0f);
		}else if(randomChoice < 4/6){
			TS_Weapons_ViewAnimation(weaponseq_mac10::sshoot, 31.0f/30.0f);
		}else if(randomChoice < 5/6){
			TS_Weapons_ViewAnimation(weaponseq_mac10::sshoot2, 31.0f/30.0f);
		}else{
			TS_Weapons_ViewAnimation(weaponseq_mac10::sshoot3, 31.0f/30.0f);
		}
	}else{
		randomChoice = random();
		if(randomChoice < 1/6){
			TS_Weapons_ViewAnimation(weaponseq_mac10::shootb, 31.0f/30.0f);
		}else if(randomChoice < 2/6){
			TS_Weapons_ViewAnimation(weaponseq_mac10::shootb2, 31.0f/30.0f);
		}else if(randomChoice < 3/6){
			TS_Weapons_ViewAnimation(weaponseq_mac10::shootb3, 31.0f/30.0f);
		}else if(randomChoice < 4/6){
			TS_Weapons_ViewAnimation(weaponseq_mac10::sshootb, 31.0f/30.0f);
		}else if(randomChoice < 5/6){
			TS_Weapons_ViewAnimation(weaponseq_mac10::sshootb2, 31.0f/30.0f);
		}else{
			TS_Weapons_ViewAnimation(weaponseq_mac10::sshootb3, 31.0f/30.0f);
		}
	}

	
#ifdef CLIENT
	View_ShowMuzzleflash(MUZZLE_SMALL);
	View_AddEvent(w_ejectshell_pistol, 0.0f);
#endif
	
	weapon_base_onAttack(pl, ary_weaponData[WEAPON_ID::MAC10], arg_thisWeapon, BITS_AKIMBOCHOICE_LEFT);
	
	weapon_base_setWholeAttackDelay(pl, (*ary_weaponData[arg_thisWeapon.weaponID]).fAttackDelay);

	if (self.flags & FL_CROUCHING){
		Animation_PlayerTop(pl, ANIM_CR_SHOOT1HAND, 0.2f);
	}else{
		Animation_PlayerTop(pl, ANIM_SHOOT1HAND, 0.2f);
	}
	
}

void
w_mac10_secondary(void)
{
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	
	if(pl.w_attack_next > 0){
		return;
	}
	
	INPUT_SECONDARY_TAP_GATE
	
	weapon_ironsight_ToggleIronsight(pl, (weapondata_ironsight_t*)ary_weaponData[WEAPON_ID::MAC10], arg_thisWeapon);
	
}


void
w_mac10_reload(void)
{
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];

	weapon_ironsight_Reload(pl, (weapondata_ironsight_t*)ary_weaponData[WEAPON_ID::MAC10], arg_thisWeapon);
}


// ???
float
w_mac10_aimanim(void)
{
	return self.flags & FL_CROUCHING ? ANIM_CR_AIM1HAND : ANIM_AIM1HAND;
}

void
w_mac10_hud(void)
{
	player pl = (player)self;
	
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	weapon_gun_onDrawHUD(pl, (weapondata_gun_t*)ary_weaponData[WEAPON_ID::MAC10], arg_thisWeapon);

}

// NOPE!  Handled by the buysidemenu, could make this give the instructions for drawing the button
// with the icon if really wanted
void
w_mac10_hudpic(int selected, vector pos, float a)
{
	//
}

weapon_t w_mac10 =
{
	
	.name		= "mac10",
	.id			= 0,  // not using this
	.slot		= 2,  // ?
	.slot_pos	= 0,  // not using this
	.weight		= 0,  // not using this
	.draw		= w_mac10_draw,
	.holster	= w_mac10_holster,
	.primary	= w_mac10_primary,
	.secondary	= w_mac10_secondary,
	.reload		= w_mac10_reload,
	.release	= NULL,
	.crosshair	= w_mac10_hud,
	.precache	= w_mac10_precache,
	.pickup		= NULL,
	.updateammo	= w_mac10_updateammo,
	.wmodel		= w_mac10_wmodel,
	.pmodel		= w_mac10_pmodel,
	.deathmsg	= w_mac10_deathmsg,
	.aimanim	= w_mac10_aimanim,
	.hudpic		= NULL
	
};


