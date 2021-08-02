
// assumes pSeatLocal is set appropriately in advance.
// Would send something of that struct's type, but... looks like that isn't really 
// an option.  Like "structType* arg_this".
void
pSeatLocal_init(void)
{
	pSeatLocal->m_flPrevVGUI = VGUI_SCREEN::NONE;
	pSeatLocal->m_bNeedPrimaryRelease = FALSE;
	pSeatLocal->m_flReleaseTime = 0;
	
	pSeatLocal->m_inputKeyTapped = 0;
	pSeatLocal->m_inputKeyDown = 0;
	pSeatLocal->m_inputMouseClicked = 0;
}

