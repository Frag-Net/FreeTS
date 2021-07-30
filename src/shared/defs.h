

enum TS_GameMode{
	DEATHMATCH,
	TEAM_DEATHMATCH,
	TEAM_PLAY
};


enum TS_Team{
	TEAM_NONE = -1,
	TEAM_1 = 0,
	TEAM_2 = 1,
	TEAM_3 = 2,
	TEAM_4 = 3
};

#ifdef SSQC
	//server CVar
	var float autocvar_weaponstay = 60;  //default originally 15
#endif


// for convenience and clarity, see fteextensions.qc for the rest of the SOUNDFLAG choices
#define SOUNDFLAG_NONE 0

// Can use SOUNDFLAG_PLAYER_SHARED in most places meant to play sounds client & serverside.
// UNICAST stops the sound from playing for the client who called it since that client
// played it themselves already, after all they sent the message to the server to begin with.
// Some other flags too.  To avoid UNICAST, use SOUNDFLAG_COMMON instead.
#ifdef CLIENT
	#define SOUNDFLAG_PLAYER_SHARED (SOUNDFLAG_NOSPACIALISE | SOUNDFLAG_FOLLOW)
	#define SOUNDFLAG_PLAYER_COMMON (SOUNDFLAG_NOSPACIALISE | SOUNDFLAG_FOLLOW)
#else //SERVER
	#define SOUNDFLAG_PLAYER_SHARED (SOUNDFLAG_FOLLOW | SOUNDFLAG_UNICAST)
	#define SOUNDFLAG_PLAYER_COMMON (SOUNDFLAG_FOLLOW)
#endif



// OLD WAY!  Blah, forgot about this, just use the new names above.
// Pretty simple way to handle the server not having the "NOSPACIALISE" flag.
// Sounds that depend on being played very neatly clientside really just need to...
// be played clientside though (send an event from the server to play it there).
// Really SOUNDFLAG_CUSTOMCLIENT -> SOUNDFLAG_PLAYER_COMMON .
#ifdef CSQC
#define SOUNDFLAG_CUSTOMCLIENT SOUNDFLAG_FOLLOW | SOUNDFLAG_NOSPACIALISE
#else
#define SOUNDFLAG_CUSTOMCLIENT SOUNDFLAG_FOLLOW
#endif
	


// ???
//#pragma target FTE
//#pragma flag enable lo	//enable short-circuiting



//TAGGG
//FLAG. Rename of the same value used by FL_SEMI_TOGGLED, since that name isn't used in The Specialists
//now.  It will instead tell whether this is the first time firing since a release or not.
// One for secondary added too. hope that's a good idea
// ...unfortunately using these for flag values might've been a bad idea.
// Even in the old version, "1<<21" was already used for something else.
// They've been offset in the new version (base FreeCS by the way).
// So these will just be player bool's instead.
//#define FL_PRIMARY_FIRE_FIRST_FRAME		(1<<20)
//#define FL_SECONDARY_FIRE_FIRST_FRAME	(1<<21)



// MODERN FREECS STATS (in case they're needed for the sake of being
// an extensive gamemod, but seeing as FreeHL has none of these, I doubt
// that)
/*
	STAT_MONEY = 34,
	STAT_PROGRESS,
	STAT_GAMETIME,
	STAT_GAMESTATE
*/


// Why 34?  See the fteextensions.qc (built-in / engine-provided things),
// looks like #33 is reserved.  FreeCS still complies with this so trusting that.
#define STAT_BUILTIN_SEPARATOR 34


//TAGGG - Still need to remove some irrelevant ones like BUYZONE,, ESCAPEZONE, WON_T, etc.
// Also starting at stat 34?  Feel some constant would be more comfortable for that, might not be an option though.
enum { 
	STAT_BUYZONE = STAT_BUILTIN_SEPARATOR,
	
	STAT_MONEY,
	STAT_FLAGS,
	
	STAT_PROGRESS,
	STAT_TEAM,
	STAT_GAMETIME,
	STAT_GAMESTATE,
	/*
	STAT_WON_T,
	STAT_WON_CT,
	*/

	//TAGGG - NEW
	//TAGGG - INCLUSION.  just to show up in searches, new stuff though
	STAT_RULE_MONEYALLOWED,
	STAT_RULE_MAXWEIGHTSLOTS

};

enum {
	GAME_INACTIVE,
	GAME_COMMENCING,
	GAME_FREEZE,
	GAME_ACTIVE,
	GAME_END, 
	GAME_OVER
};


var float autocvar_movemodmulti = 1;


//float Game_GetFriction(entity eTarget);
//float Game_GetMaxSpeed( entity eTarget );


// Prototype for weapons_common.qc method(s)!
// For things here to be aware of these earlier
void Weapons_Draw(void);
void Weapons_Holster(void);


