

BOOLEAN TS_Weapon_PrimaryAttackRelease(player localPlayer, BOOLEAN hasAmmo);
BOOLEAN TS_Weapon_SecondaryAttackRelease(player localPlayer, BOOLEAN hasAmmo);

void TS_Weapon_Draw_extra(void);





void TS_playerEquippedWeapon_Shared(player localPlayer, int newWeaponEquipped, BOOLEAN useAkimbo);

#ifdef CSQC
void _TS_playerEquippedWeapon(player localPlayer, int newWeaponEquipped, BOOLEAN useAkimbo);

void TS_playerEquippedWeapon(player localPlayer, int newWeaponEquipped, BOOLEAN useAkimbo);

#endif
#ifdef SSQC
int _TS_playerEquippedWeapon(player localPlayer, int newWeaponEquipped, BOOLEAN useAkimbo);

void TS_playerEquippedWeapon(player localPlayer, int newWeaponEquipped, BOOLEAN useAkimbo);

void CSEv_TS_playerEquippedWeapon_ii(int newWeaponEquipped, BOOLEAN useAkimbo);
#endif



#ifdef SSQC
void TS_PlayInsertShellSound(player localPlayer);
#else
void TS_PlayInsertShellSound(player localPlayer);
void EV_TS_PlayInsertShellSound(player localPlayer);
#endif


#ifdef SSQC
void TS_resetViewModel(player localPlayer);
#else
void TS_resetViewModel(player localPlayer);
void EV_TS_resetViewModel(void);
#endif

#ifdef SSQC
void TS_resetPlayer(player localPlayer, BOOLEAN resetInventory)
#else
void EV_TS_resetPlayer(player localPlayer, BOOLEAN resetInventory)
#endif

#ifdef CLIENT
void EV_PlayerDeath(void)
#endif


#ifdef CSQC
//NOTICE - clientside components removed, except for clientside being able
// to signal that the server should remove a weapon.
// This needs no clientside logic equivalent to be mirrored.
/*
void _TS_playerDropWeapon(player localPlayer);
*/
void TS_playerDropWeapon(void);
/*
void EV_TS_playerDropWeapon(player localPlayer);
*/
#endif
#ifdef SSQC
//that's it really serverside.
void _TS_playerDropWeapon(void);
void TS_playerDropWeapon(void);
void CSEv_TS_playerDropWeapon_(void);

#endif




#ifdef SERVER
void CSEv_TS_playerChangeFiremode_(void);
#endif
void TS_playerChangeFiremode(void);
void _TS_playerChangeFiremode(void )

#ifdef SERVER
void CSEv_TS_playerUseItems_(void);
#endif
void TS_playerUseItems(void);
void _TS_playerUseItems(void);

#ifdef SERVER
void CSEv_TS_playerUsePowerup_(void);
#endif
void TS_playerUsePowerup(void);
void _TS_playerUsePowerup(void);

#ifdef SERVER
void CSEv_TS_playerCallAlt1_(void);
#endif
void TS_playerCallAlt1(void);
void _TS_playerCallAlt1(void);

#ifdef SERVER
void CSEv_TS_playerCallAlt2_(void);
#endif
void TS_playerCallAlt2(void);
void _TS_playerCallAlt2(void);


void playerEquipIdeal(player localPlayer);
void playerEquipIdealSafe(player localPlayer);

