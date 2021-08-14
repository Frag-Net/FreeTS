
void
CTSShellEject::CTSShellEject(void){
}

void
CTSShellEject::precache(void)
{
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
	
	// whoops, forgot looping through the struct and precaching that way would've worked,
	// but keeping individual precaches if just for some comments.
	// Also - could do it the getmodleindex way and record ID's, but don't see a benefit
	// to that.
	/*
	for(i = 0; i < SHELLEJECT_ID::LAST_ID; i++){
		ary_shellEjectData[i].iModelPrecacheID = (int)getmodelindex(ary_shellEjectData[i].sModelPath);
	}
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

CTSShellEject
CTSShellEject::generate(int arg_iShellEjectType){
	CTSShellEject eShell = spawn(CTSShellEject);
	
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
	
	return eShell;
}

// TODO!  Take akimbochoice as well.
// That will mean not returning what is generated, which will be fine, that was never used
// anyway.  Because this might generate two for dual-fire akimbo
// The practical constructor, manually call this after spawning.
// NOTE: assumes pSeat->m_eViewModel is valid for involving in determining
// origin, angles, velocity
CTSShellEject
CTSShellEject::generateForViewmodel(int arg_iShellEjectType)
{
	// give me an origin!
	CTSShellEject eShell = CTSShellEject::generate(arg_iShellEjectType);
	
	vector vOrigin;
	
	// FreeHL way (forget all the rest if so)
	//vOrigin = pSeat->m_eViewModel.origin + (v_forward * 26) + (v_right * 8) + (v_up * -4);
	
	
	 /*
	 // way #1
	//vOrigin = pSeat->m_eViewModel.origin;
	// way #2: old codebase way?
	//vOrigin = pSeat->m_vecPredictedOrigin + [0, 0, getstatf(STAT_VIEWHEIGHT)];
	
	// way #3
	// "pSeat->m_iVMBones + 1" gets the 2nd attachment (#1, counting starting at 0),
	// add more to get other attachments, or places on the model that can be helpful
	// to tie into.  Why the example I got a long time ago started at the 2nd attachment,
	// no idea
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
	
	// way #4 (grabs how player predraw, client/player.qc, gets a direction for pushing some effects
	// relatively forward/backwards/sideways from 2 attachment positions):
	vector gunpos;
	vector gunpos_tempEnd;
	vector dirGun;
	vector angGun;
	
	
	gunpos = gettaginfo(pSeat->m_eViewModel, pSeat->m_iVMBones + 0i);
	gunpos_tempEnd = gettaginfo(pSeat->m_eViewModel, pSeat->m_iVMBones + 3i);
	dirGun = normalize(gunpos_tempEnd - gunpos);
	angGun = vectoangles(dirGun);
	makevectors(angGun);
	
	//TODO: No idea what consistent formula would put shell ejections across the right place
	// of all weapons.  Might just have to be a piece of weapondata for what relative forward, up,
	// and right multiples to apply to relative vectors here.  Or maybe only the multiple on v_forward
	// is necessary, would have to check the attachment points of everything
	// ALSO, TODO: Check for being akimbo and per weapon.  oh dear... we need a paramter for what
	// weapon, left or right to use then (LEFT always a default, even if non-akimbo is ok too),
	// see weapons for that AKIMBOCHOICE thing
	vOrigin = gunpos;
	vOrigin += v_forward * -3.5;
	vOrigin += v_up * -0.02;
	vOrigin += v_right * 0.00;
	
	
	setorigin(eShell, vOrigin);
	
	return eShell;
}

// TODO.  For playermodels as seen in thirdperson (local one) or looking at other players
// that called for shell ejecting.
CTSShellEject
CTSShellEject::generate2(int arg_iShellEjectType, vector arg_vOrigin, vector arg_vDir){
	
	return NULL;
}


void
CTSShellEject::touch(void)
{
	if(other == world){
		shellejectdata_t* mySED = ary_shellEjectData[iShellEjectType];
		// self? this?  Is there a difference in this context?
		// TODO: should shell-touch sounds have reduced volume?  Unsure
		Sound_Play(this, CHAN_BODY, mySED->sTouchSound);
	}
}
