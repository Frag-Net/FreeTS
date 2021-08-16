
// assumes pSeatLocal is set appropriately in advance.
// Would send something of that struct's type, but... looks like that isn't really 
// an option.  Like "structType* arg_this".
void
pSeatLocal_init(void)
{
	pSeatLocal->m_eMuzzleflashAkimbo = NULL;
	pSeatLocal->m_flUI_Display = UI_SCREEN::NONE;
	
	pSeatLocal->m_inputKeyTapped = 0;
	pSeatLocal->m_inputKeyDown = 0;
	pSeatLocal->m_inputMouseClicked = FALSE;
}

//TAGGG - BobNEW.  helper method
void
pViewBob_reset(void)
{
	pViewBob->m_flBobTime = 0;
	pViewBob->m_flBob = 0;
	pViewBob->m_flBobCycle = 0;
	pViewBob->m_flSpeed = 0;
	pViewBob->m_vCam = [0,0,0];
}
