
enum weaponseq_barrett_m82{
	idle,
	reload,
	draw,
	shoot,
	shoot2
};



BOOLEAN weapon_Barrett_M82_onPrimaryAttack(player localPlayer, weapondynamic_t arg_thisWeapon, BOOLEAN hasAmmo){
	return TRUE;
}
BOOLEAN weapon_Barrett_M82_onPrimaryAttackRelease(player localPlayer, weapondynamic_t arg_thisWeapon, BOOLEAN hasAmmo){
	return FALSE;
}
BOOLEAN weapon_Barrett_M82_onSecondaryAttack(player localPlayer, weapondynamic_t arg_thisWeapon, BOOLEAN hasAmmo){
	return FALSE;
}
BOOLEAN weapon_Barrett_M82_onSecondaryAttackRelease(player localPlayer, weapondynamic_t arg_thisWeapon, BOOLEAN hasAmmo){
	return FALSE;
}

void weapon_Barrett_M82_onEquip(player localPlayer, weapondynamic_t arg_thisWeapon){
}
BOOLEAN weapon_Barrett_M82_onUnEquip(player localPlayer, weapondynamic_t arg_thisWeapon){
	return FALSE;
}
void weapon_Barrett_M82_onThink(player localPlayer, weapondynamic_t arg_thisWeapon){
	weapon_gun_onThink(localPlayer, (weapondata_gun_t*)ary_weaponData[WEAPON_ID::Barrett_M82], arg_thisWeapon);
}
void weapon_Barrett_M82_onDrawHUD(player localPlayer, weapondynamic_t arg_thisWeapon){
}
void weapon_Barrett_M82_onReload(player localPlayer, weapondynamic_t arg_thisWeapon){
}
void weapon_Barrett_M82_onColdCock(player localPlayer, weapondynamic_t arg_thisWeapon){
	
}


weapondata_gun_t weapon_Barrett_M82 =
{
	WEAPONDATA_TYPEID_GUN,
	"Barrett M82A1",
	"models/v_m82.mdl",
	"models/p_m82.mdl",
	"",
	"models/w_m82.mdl",
	"sprites/weapons/m82.spr",
	weapon_Barrett_M82_onPrimaryAttack,
	weapon_Barrett_M82_onPrimaryAttackRelease,
	weapon_Barrett_M82_onSecondaryAttack,
	weapon_Barrett_M82_onSecondaryAttackRelease,
	weapon_Barrett_M82_onEquip,
	weapon_Barrett_M82_onUnEquip,
	weapon_Barrett_M82_onThink,
	weapon_Barrett_M82_onDrawHUD,
	weapon_Barrett_M82_onReload,
	weapon_Barrett_M82_onColdCock,
	weaponseq_barrett_m82::idle,
	weaponseq_barrett_m82::draw,
	31.0f / 30.0f,
	0.0625f,  //fire delay.
	7.0f,  //dmg
	FALSE,
	BITS_WEAPONOPT_LASERSIGHT | BITS_WEAPONOPT_SCOPE,
	BITS_WEAPONOPT_SCOPE,
	9000,
	70,
	BUYCATEGORY_RIFLES,
	4,
	{0.001000, 10.000000, 0.100000},
	WEAPON_AKIMBO_UPGRADE_ID::NONE,
	BITS_FIREMODE_SEMI,
	BITS_FIREMODE_SEMI,
	AMMO_ID::_50BMG,
	5,  //clip
	4096, //range
	weaponseq_barrett_m82::reload,
	57.0f / 30.0f,
	-1,
	-1,
	-1,
	-1
};




void
w_barrett_m82_precache(void)
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
w_barrett_m82_updateammo(player pl)
{
	//weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	//Weapons_UpdateAmmo(pl, arg_thisWeapon.iClipLeft, pl.ary_ammoTotal[AMMO_ID::_9x19mm], -1);
}

string
w_barrett_m82_wmodel(void)
{
	return (*ary_weaponData[WEAPON_ID::Barrett_M82]).sWorldModelPath;
}

string
w_barrett_m82_pmodel(void)
{
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	return (*ary_weaponData[WEAPON_ID::Barrett_M82]).sPlayerModelPath;
}

string
w_barrett_m82_deathmsg(void)
{
	return "";
}

void
w_barrett_m82_draw(void)
{
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	weapondata_basic_t* basicP = ary_weaponData[WEAPON_ID::Barrett_M82];
	
	weapon_base_onEquip(pl, basicP, arg_thisWeapon);
}


void
w_barrett_m82_holster(void)
{
}


void
w_barrett_m82_primary(void)
{
	float randomChoice;
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];

	if (pl.w_attack_next > 0.0) {
		return;
	}
		
	//if(arg_thisWeapon.iFireMode == BITS_FIREMODE_SEMI){
		INPUT_PRIMARY_TAP_GATE
	//}
	
	if (!arg_thisWeapon.iClipLeft || WEAPON_UNDERWATER_CHECK) {
		PLAY_CLICK_SOUND
		return;
	}
	
	TS_Weapons_PlaySoundDirect(pl, "weapons/barrett/fire.wav");
	
	if(randomChoice < 0.5){
		TS_Weapons_ViewAnimation(weaponseq_barrett_m82::shoot, 31.0f/30.0f);
	}else{
		TS_Weapons_ViewAnimation(weaponseq_barrett_m82::shoot2, 31.0f/30.0f);
	}

#ifdef CLIENT
	View_ShowMuzzleflash(MUZZLE_SMALL);
	View_AddEvent(w_ejectshell_pistol, 0.0f);
#endif
	
	weapon_base_onAttack(pl, ary_weaponData[WEAPON_ID::Barrett_M82], arg_thisWeapon, BITS_AKIMBOCHOICE_LEFT);
	
	weapon_base_setWholeAttackDelay(pl, (*ary_weaponData[arg_thisWeapon.weaponID]).fAttackDelay);

	if (self.flags & FL_CROUCHING){
		Animation_PlayerTop(pl, ANIM_CR_SHOOT1HAND, 0.2f);
	}else{
		Animation_PlayerTop(pl, ANIM_SHOOT1HAND, 0.2f);
	}
	
}



void
w_barrett_m82_secondary(void)
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
		
	}
	
}

void
w_barrett_m82_reload(void)
{
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];

	weapon_gun_Reload(pl, (weapondata_gun_t*)ary_weaponData[WEAPON_ID::Barrett_M82], arg_thisWeapon);
}

// ???
float
w_barrett_m82_aimanim(void)
{
	return self.flags & FL_CROUCHING ? ANIM_CR_AIM1HAND : ANIM_AIM1HAND;
}

void
w_barrett_m82_hud(void)
{
	player pl = (player)self;
	weapondynamic_t arg_thisWeapon = pl.ary_myWeapons[pl.inventoryEquippedIndex];
	weapon_gun_onDrawHUD(pl, (weapondata_gun_t*)ary_weaponData[WEAPON_ID::Barrett_M82], arg_thisWeapon);
}



// NOPE!  Handled by the buysidemenu, could make this give the instructions for drawing the button
// with the icon if really wanted
void
w_barrett_m82_hudpic(int selected, vector pos, float a)
{
	//
}


weapon_t w_barrett_m82 =
{
	
	.name		= "barrett_m82",
	.id			= 0,  // not using this
	.slot		= 2,  // ?
	.slot_pos	= 0,  // not using this
	.weight		= 0,  // not using this
	.draw		= w_barrett_m82_draw,
	.holster	= w_barrett_m82_holster,
	.primary	= w_barrett_m82_primary,
	.secondary	= w_barrett_m82_secondary,
	.reload		= w_barrett_m82_reload,
	.release	= NULL,
	.crosshair	= w_barrett_m82_hud,
	.precache	= w_barrett_m82_precache,
	.pickup		= NULL,
	.updateammo	= w_barrett_m82_updateammo,
	.wmodel		= w_barrett_m82_wmodel,
	.pmodel		= w_barrett_m82_pmodel,
	.deathmsg	= w_barrett_m82_deathmsg,
	.aimanim	= w_barrett_m82_aimanim,
	.hudpic		= NULL
	
};

