
	
	
// for ejected shells to use
class CTSShellEject{
	// what to use for info.  Saved to a var since this must be known
	// between being spawned and when the event is picked, not going to
	// try and guess how that works knowing FTE
	int iShellEjectType;
	
	void(void) CTSShellEject;
	static void(void) precache;
	
	static CTSShellEject(int arg_iShellEjectType) generate;
	static void(int arg_iShellEjectType, int arg_akimboChoice) generateForViewModelAkimbo;
	static CTSShellEject(int arg_iShellEjectType, int arg_attachment1, int arg_attachment2) generateForViewModel_attachments;
	
	static CTSShellEject(int arg_iShellEjectType, vector arg_vOrigin, vector arg_vDir) generate2;
	
	virtual void(void) touch;
};
