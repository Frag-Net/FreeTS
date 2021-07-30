


// NOTE - for clientside, not called in ClientGame_RendererRestart, only 
// once in ClientGame_Init.
void SharedGame_Init(void){
	
	// Don't worry about calling the Client/ServerGame_Precache methods or any
	// other init-related ones that are only for the client or server,
	// those had to lead here to be reached (SharedGame_Init is not called by
	// Nuclide's src directly).
	
	setupWeaponData();
	setupPowerupData();
	
	
}


