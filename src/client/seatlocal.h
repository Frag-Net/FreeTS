
// Moved here for better control of compile order.
// Must be aware of the ClientInfo_t struct, which in turn must be
// aware of some weapon-related structs before this point is reached
// in compilation.


struct
{
	// Clone of the Nuclide muzzleflash so that dual akimbo fire (both at the same time)
	// can be shown.
	// No need to handle Event_ProcessModel - TS doesn't even have model events for muzzle
	// flashes, modify the way of setting up muzzleflash-related variables to support this
	// when needed.
	entity m_eMuzzleflashAkimbo;
	
	// PENDING - probably safe to remove these
	int m_iHealthOld;
	float m_flHealthAlpha;
	int m_iArmorOld;
	float m_flArmorAlpha;
	int m_iAmmo1Old;
	float m_flAmmo1Alpha;
	int m_iAmmo2Old;
	float m_flAmmo2Alpha;
	int m_iAmmo3Old;
	float m_flAmmo3Alpha;
	int m_iPickupWeapon;
	float m_flPickupAlpha;
	int m_iHUDWeaponSelected;
	float m_flHUDWeaponSelectTime;
	
	
	//TAGGG - assuming this is a fine place to put this
	// It's the slower movement from holding shift down.
	int m_iInputSpeed;
	// Keeping for now, remove later
	float m_flUI_Display;
	
	float m_inputKeyTapped;
	float m_inputKeyDown;
	float m_inputMouseClicked;

	ClientInfo_t m_clientinfo;
	
	float m_flBlockSpawnInputTime;
	
	BOOL m_bUseItems;
	BOOL m_bChangeFiremode;
	
	
} g_seatslocal[4], *pSeatLocal;

void pSeatLocal_init(void);


//TAGGG - BobNEW.  ViewBob struct array/var moved here
struct
{
	float m_flBobTime;
	float m_flBob;
	float m_flBobCycle;
	float m_flSpeed;
	// NEW
	vector m_vCam;
} g_viewBobVars[4], *pViewBob;

void pViewBob_reset(void);

