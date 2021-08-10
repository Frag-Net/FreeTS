
// for ejected shells to use
class CShellEject{
	// what to use for info.  Saved to a var since this must be known
	// between being spawned and when the event is picked, not going to
	// try and guess how that works knowing FTE
	int iShellEjectType;
	
	void(void) CShellEject;
	static void(void) precache;
	static CShellEject(int arg_iShellEjectType) generate;
	virtual void(void) touch;
};
