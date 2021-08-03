
// Moved here for better control of compile order.
// Must be aware of the ClientInfo_t struct, which in turn must be
// aware of some weapon-related structs before this point is reached
// in compilation.


struct
{
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
	
	float m_flPrevVGUI;
	BOOL m_bNeedPrimaryRelease;
	float m_flReleaseTime;
	
	
	//TAGGG - assuming this is a fine place to put this
	// It's the slower movement from holding shift down.
	int iInputSpeed;
	// Keeping for now, remove later
	float fVGUI_Display;
	
	// CRITICAL:
	// Should these be per pSeat instead?  Unsure if that makes sense.
	float m_inputKeyTapped;
	float m_inputKeyDown;
	float m_inputMouseClicked;

	ClientInfo_t m_clientinfo;
	
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


