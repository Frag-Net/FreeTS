
void
CShellEject::CShellEject(void){
}

void
CShellEject::precache(void){
	Sound_Precache("modelevent_shell.land");
	Sound_Precache("modelevent_shotgunshell.land");
	// no need, handled in soundscript preaches
	/*
	precache_sound("weapons/shell.wav");
	precache_sound("weapons/sshell.wav");
	precache_sound("weapons/sshell1.wav");
	precache_sound("weapons/sshell2.wav");
	precache_sound("weapons/sshell3.wav");
	*/
	
	// nearly identical..?
	precache_model("models/56_shell.mdl");
	precache_model("models/556_shell.mdl");
	
	// identical..?
	precache_model("models/22_shell.mdl");
	precache_model("models/9mm_shell.mdl");
	precache_model("models/shell.mdl");
	
	precache_model("models/shotgun_shell.mdl");
	precache_model("models/shotgun_shell_blue.mdl");
	precache_model("models/shotgun_shell_gold.mdl");

}

// The practical constructor, manually call this after spawning.
// NOTE: assumes pSeat->m_eViewModel is valid for involving in determining
// origin, angles, velocity
CShellEject
CShellEject::generate(int arg_iShellEjectType){
	CShellEject eShell = spawn(CShellEject);
	
	vector vOrigin;  // tempvar
	
	eShell.iShellEjectType = arg_iShellEjectType;
	
	//setmodel(eShell, "models/shell.mdl");
	shellejectdata_t* mySED = ary_shellEjectData[eShell.iShellEjectType];
	setmodel(eShell, (*mySED).sModelPath);
	
	eShell.solid = SOLID_BBOX;
	eShell.movetype = MOVETYPE_BOUNCE;
	eShell.drawmask = MASK_ENGINE;
	eShell.angles = [pSeat->m_eViewModel.angles[0], pSeat->m_eViewModel.angles[1], 0];
	eShell.velocity = pSeat->m_vecPredictedVelocity;

	makevectors(pSeat->m_eViewModel.angles);
	eShell.velocity += (v_forward * 0);
	eShell.velocity += (v_right * 80);
	eShell.velocity += (v_up * 100);
	
	eShell.avelocity = [0,45,900];
	eShell.think = entity_removeSelf;
	// shells last longer than 2.5 seconds in TS, going for 10 for now
	eShell.nextthink = time + 10.0f;
	setsize(eShell, [0,0,0], [0,0,0]);
	
	// TODO:  I think attachments supply a direction too, fuzzy on the details,
	// player predraw (client/player.qc) definitely has something like that to put the
	// viewmodel laser-start or flashlight sprite glow effect in the right place.
	
	// FreeHL way (forget all the rest if so)
	vOrigin = pSeat->m_eViewModel.origin + (v_forward * 26) + (v_right * 8) + (v_up * -4);
	
	 /*
	 // way #1
	//vOrigin = pSeat->m_eViewModel.origin;
	// way #2: old codebase way?
	//vOrigin = pSeat->m_vecPredictedOrigin + [0, 0, getstatf(STAT_VIEWHEIGHT)];
	
	// way #3
	// "pSeat->m_iVMBones + 1" gets the first attachment, add more to get other
	// attachments, or places on the model that can be helpful to tie into
	// Although this is still making shell ejections happen at the end of the muzzle
	// and the other attachments just go further out?
	vector vOffset = gettaginfo(pSeat->m_eViewModel, pSeat->m_iVMBones + 1);
	printfline("WHAT?! %.2f %.2f %.2f", vOffset[0], vOffset[1], vOffset[2]);
	
	// way #3a
	// assumes a vOrigin provided by earlier
	//vOrigin += (v_forward * vOffset[0]);
	//vOrigin += (v_right * -vOffset[1]);
	//vOrigin += (v_up * vOffset[2]) ;
	
	// way #3b
	// or only be vOffset
	vOrigin = vOffset;
	*/
	setorigin(eShell, vOrigin);
}

void CShellEject::touch(void){
	if(other == world){
		shellejectdata_t* mySED = ary_shellEjectData[iShellEjectType];
		// self? this?  Is there a difference in this context?
		// TODO: should shell-toucch sounds have reduced volume?  Unsure
		Sound_Play(this, CHAN_BODY, (*mySED).sTouchSound);
	}
}
