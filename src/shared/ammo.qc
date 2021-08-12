
DECLARE_AMMODATA(NONE, "_NONE_", 0, 0)
DECLARE_AMMODATA(_9X19MM, "9 x 19mm", 1.6666666666, 210)
DECLARE_AMMODATA(_45ACP, ".45Acp", 5.1, 200)
DECLARE_AMMODATA(_P50AE, ".50AE", 7, 70)
DECLARE_AMMODATA(_5P7X28, "5.7 x 28", 6, 200)
DECLARE_AMMODATA(_10MMAUTO, "10mm AUTO", 4.9, 100)
DECLARE_AMMODATA(_P22LR, ".22 LR", 6, 150)
DECLARE_AMMODATA(_P454CASULL, ".454 Casull", 30, 50)
DECLARE_AMMODATA(_5P56NATO, "5.56 Nato", 2.6666666666, 90)
DECLARE_AMMODATA(_7P62X39MM, "7.62 x 39mm", 3.3333333333, 90)
DECLARE_AMMODATA(_50BMG, "50BMG", 100, 20)
DECLARE_AMMODATA(_SHELLS, "SHELLS", 16, 60)
DECLARE_AMMODATA(_32ACP, ".32 ACP", 0.5, 300)
DECLARE_AMMODATA(_7P62X51MM, "7.62 x 51mm", 30, 35)



#ifdef CLIENT
DECLARE_SHELLEJECTDATA(NONE, "", "")
DECLARE_SHELLEJECTDATA(_56, "models/56_shell.mdl", "modelevent_shell.land")
DECLARE_SHELLEJECTDATA(_556, "models/556_shell.mdl", "modelevent_shell.land")
DECLARE_SHELLEJECTDATA(_22, "models/22_shell.mdl", "modelevent_shell.land")
DECLARE_SHELLEJECTDATA(_9MM, "models/9mm_shell.mdl", "modelevent_shell.land")
DECLARE_SHELLEJECTDATA(GENERIC, "models/shell.mdl", "modelevent_shell.land")
DECLARE_SHELLEJECTDATA(SHOTGUN, "models/shotgun_shell.mdl", "modelevent_shotgunshell.land")
DECLARE_SHELLEJECTDATA(SHOTGUN_BLUE, "models/shotgun_shell_blue.mdl", "modelevent_shotgunshell.land")
DECLARE_SHELLEJECTDATA(SHOTGUN_GOLD, "models/shotgun_shell_gold.mdl", "modelevent_shotgunshell.land")


DECLARE_MUZZLEFLASHDATA(NONE, "")
DECLARE_MUZZLEFLASHDATA(RIFLE, "sprites/muzzleflash1.spr")
DECLARE_MUZZLEFLASHDATA(SMALL, "sprites/muzzleflash2.spr")
DECLARE_MUZZLEFLASHDATA(WEIRD, "sprites/muzzleflash3.spr")

// some muzzleflash candidates from TS files:
/*
gun_muzzle.spr
gun_muzzle2.spr
shotgun_pellets.spr  a glowing effect?  what?
ts_muzzleflash1.spr
ts_muzzleflash1h.spr
ts_muzzleflash1s.spr
ts_muzzleflash2h.spr
ts_muzzleflash6.spr
ts_muzzleflash6b.spr
*/


// In here since the MuzzleFlash isn't getting a class.
// Also, only clientside for now.
void MuzzleFlash_precache(void){
	int i;
	// taking these from Nuclide for now, may as well.
	// Wait, why precache these if Nuclide already does getmodelindex to fetch the ID's?
	//precache_model("sprites/muzzleflash1.spr");
	//precache_model("sprites/muzzleflash2.spr");
	//precache_model("sprites/muzzleflash3.spr");
	
	// oh hey, arrow operator works in QuakeC.
	// ...     don't tell me how long this has been the case, alright.
	(ary_muzzleFlashData[MUZZLEFLASH_ID::RIFLE])->iSpritePrecacheID = MUZZLE_RIFLE;
	(ary_muzzleFlashData[MUZZLEFLASH_ID::SMALL])->iSpritePrecacheID = MUZZLE_SMALL;
	(ary_muzzleFlashData[MUZZLEFLASH_ID::WEIRD])->iSpritePrecacheID = MUZZLE_WEIRD;
	
	// NOTE - lines like this:
	//     (*whatever).var = thing
	// will not save the change!  Or, sometimes it seems they do?  Maybe this rarely comes up
	
	// For the rest, do the whole process
	// start at 4 because 0 is for NONE, then 1,2,3's prechaches are handled by Nuclide
	for(i = 4; i < MUZZLEFLASH_ID::LAST_ID; i++){
		muzzleflashdata_t* tempRef = ary_muzzleFlashData[i];
		int theModelIndex;
		if((*tempRef).sSpritePath != NULL){
			theModelIndex = (int)getmodelindex((*tempRef).sSpritePath);
		}else{
			theModelIndex = 0;
		}
		tempRef->iSpritePrecacheID = theModelIndex;
	}
	
}
#endif


// for ammodata structs and all the other oddities
void setupAmmoData(void){
	

	ASSIGN_AMMODATA(NONE)
	ASSIGN_AMMODATA(_9X19MM)
	ASSIGN_AMMODATA(_45ACP)
	ASSIGN_AMMODATA(_P50AE)
	ASSIGN_AMMODATA(_5P7X28)
	ASSIGN_AMMODATA(_10MMAUTO)
	ASSIGN_AMMODATA(_P22LR)
	ASSIGN_AMMODATA(_P454CASULL)
	ASSIGN_AMMODATA(_5P56NATO)
	ASSIGN_AMMODATA(_7P62X39MM)
	ASSIGN_AMMODATA(_50BMG)
	ASSIGN_AMMODATA(_SHELLS)
	ASSIGN_AMMODATA(_32ACP)
	ASSIGN_AMMODATA(_7P62X51MM)
	
	
#ifdef CLIENT
	ASSIGN_SHELLEJECTDATA(NONE)
	ASSIGN_SHELLEJECTDATA(_56)
	ASSIGN_SHELLEJECTDATA(_556)
	ASSIGN_SHELLEJECTDATA(_22)
	ASSIGN_SHELLEJECTDATA(_9MM)
	ASSIGN_SHELLEJECTDATA(GENERIC)
	ASSIGN_SHELLEJECTDATA(SHOTGUN)
	ASSIGN_SHELLEJECTDATA(SHOTGUN_BLUE)
	ASSIGN_SHELLEJECTDATA(SHOTGUN_GOLD)
	
	ASSIGN_MUZZLEFLASHDATA(NONE)
	ASSIGN_MUZZLEFLASHDATA(SMALL)
	ASSIGN_MUZZLEFLASHDATA(RIFLE)
	ASSIGN_MUZZLEFLASHDATA(WEIRD)
	
#endif
	
}// setupAmmoData


