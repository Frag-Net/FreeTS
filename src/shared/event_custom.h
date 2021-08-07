

void TS_Weapon_PrimaryAttackRelease(player pl);
void TS_Weapon_SecondaryAttackRelease(player pl);

void TS_Weapon_Draw_extra(void);


void TS_playerEquippedWeapon_Shared(player pl, int newWeaponEquipped, BOOL useAkimbo);

#ifdef CLIENT
void _TS_playerEquippedWeapon(player pl, int newWeaponEquipped, BOOL useAkimbo);

void TS_playerEquippedWeapon(player pl, int newWeaponEquipped, BOOL useAkimbo);

#endif
#ifdef SERVER
void _TS_playerEquippedWeapon(player pl, int newWeaponEquipped, BOOL useAkimbo);

void TS_playerEquippedWeapon(player pl, int newWeaponEquipped, BOOL useAkimbo);

void CSEv_TS_playerEquippedWeapon_ii(int newWeaponEquipped, BOOL useAkimbo);
#endif



#ifdef SERVER
void TS_PlayInsertShellSound(player pl);
#else
void TS_PlayInsertShellSound(player pl);
void EV_TS_PlayInsertShellSound(player pl);
#endif


#ifdef SERVER
void TS_resetViewModel(player pl);
#else
void TS_resetViewModel(player pl);
void EV_TS_resetViewModel(void);
#endif

#ifdef SERVER
void TS_resetPlayer(player pl, BOOL resetInventory)
#else
void EV_TS_resetPlayer(player pl, BOOL resetInventory)
#endif

#ifdef CLIENT
void EV_PlayerDeath(void)
#endif


#ifdef CLIENT
//NOTICE - clientside components removed, except for clientside being able
// to signal that the server should remove a weapon.
// This needs no clientside logic equivalent to be mirrored.
/*
void _TS_playerDropWeapon(player pl);
*/
void TS_playerDropWeapon(void);
/*
void EV_TS_playerDropWeapon(player pl);
*/
#endif
#ifdef SERVER
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


void playerEquipIdeal(player pl);
void playerEquipIdealSafe(player pl);

