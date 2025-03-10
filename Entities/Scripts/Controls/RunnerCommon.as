// Runner Common

shared class RunnerMoveVars
{
	//walking vars
	f32 walkSpeed;  //target vel
	f32 walkSpeedInAir;
	f32 walkFactor;
	f32 menuDamp;

	//ladder
	Vec2f walkLadderSpeed;

	//jumping vars
	f32 jumpMaxVel;
	f32 jumpStart;
	f32 jumpMid;
	f32 jumpEnd;
	f32 jumpFactor;
	s32 jumpCount; //internal counter
	s32 fallCount; //internal counter only moving down

	//swimming vars
	f32 swimspeed;
	f32 swimforce;
	f32 swimEdgeScale;

	//vaulting vars
	bool canVault;

	//scale the entire movement
	f32 overallScale;

	//force applied while... stopping
	f32 stoppingForce;
	f32 stoppingForceAir;
	f32 stoppingFactor;
	f32 stoppingForceAirFactor;

	// moved from tags...
	bool walljumped;
	s32 walljumped_side;
	int wallrun_count;
	bool wallclimbing;
	bool wallsliding;

    int wallrun_length;
    f32 wallrun_factor;
};

namespace Walljump
{
	enum WalljumpSide
	{
		NONE,
		LEFT,
		JUMPED_LEFT,
		RIGHT,
		JUMPED_RIGHT,
		BOTH
	};
}
