

// for client and serverside individually, data structs never need to be assigned
// more than once.  However, this does not necessarily apply to precaches, the client
// renderer may restart sometimes.
// This is why precache calls should be handled elsewhere in precache methods 
// that get called when needed.
var BOOL g_bDataStructsInit = FALSE;


// NOTE - for clientside, not called in ClientGame_RendererRestart, only 
// once in ClientGame_Init.
void SharedGame_Init(void){
	
	// Don't worry about calling the Client/ServerGame_Precache methods or any
	// other init-related ones that are only for the client or server,
	// those had to lead here to be reached (SharedGame_Init is not called by
	// Nuclide's src directly).
	
	if(!g_bDataStructsInit){
		g_bDataStructsInit = TRUE;
		setupWeaponData();
		setupPowerupData();
		setupAmmoData();
	}
	
	
	
}


