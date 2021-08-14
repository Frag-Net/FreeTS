
	
	
// for ejected shells to use
class CTSShellEject{
	// what to use for info.  Saved to a var since this must be known
	// between being spawned and when the event is picked, not going to
	// try and guess how that works knowing FTE
	int iShellEjectType;
	
	void(void) CTSShellEject;
	static void(void) precache;
	static CTSShellEject(int arg_iShellEjectType) generate;
	static CTSShellEject(int arg_iShellEjectType) generateForViewmodel;
	static CTSShellEject(int arg_iShellEjectType, vector arg_vOrigin, vector arg_vDir) generate2;
	virtual void(void) touch;
};
