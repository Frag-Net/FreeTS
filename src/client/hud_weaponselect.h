
// whatever needs to be accessed out of order.
// For now, just the helper methods, Nuclide clearly doesn't need the methods it
// calls to be prototyped.

void TS_HUD_DrawWeaponSelect(void);
int TS_HUD_DrawWeaponSelect_NextItem(int weaponID_toStartFrom, BOOLEAN freeSlotMovement, optional int forcedSlot);
int TS_HUD_DrawWeaponSelect_PreviousItem(int weaponID_toStartFrom, BOOLEAN freeSlotMovement, optional int forcedSlot);
BOOL TS_HUD_DrawWeaponSelect_CheckClick(void);
BOOL TS_HUD_CloseWeaponSelect(BOOL playOffSound);
BOOL TS_HUD_earlyTerminateCheck(void)
