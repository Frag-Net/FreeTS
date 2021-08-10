
class TSGrenadeProjectile{
	void(void) TSGrenadeProjectile;
	static void(void) precache;
	static TSGrenadeProjectile(player arg_player, vector arg_vOrigin, vector arg_vThrowDir, vector arg_vPlayerForward, int arg_weaponTypeID) generate;
	virtual void(void) touch;
};
	
void TSGrenadeProjectile_Explode(void);
