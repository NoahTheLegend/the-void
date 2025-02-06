// Runner Movement

#include "RunnerCommon.as"

void onInit(CMovement@ this)
{
	RunnerMoveVars moveVars;
	//walking vars
	moveVars.walkSpeed = 2.3f;
	moveVars.walkSpeedInAir = 2.0f;
	moveVars.walkFactor = 1.0f;
	moveVars.walkLadderSpeed.Set(0.15f, 0.25f);
	//jumping vars
	moveVars.jumpMaxVel = 2.5f;
	moveVars.jumpStart = 0.75f;
	moveVars.jumpMid = 0.55f;
	moveVars.jumpEnd = 0.4f;
	moveVars.jumpFactor = 1.0f;
	moveVars.jumpCount = 0;
	moveVars.canVault = true;
	//swimming
	moveVars.swimspeed = 1.0;
	moveVars.swimforce = 40;
	moveVars.swimEdgeScale = 2.0f;
	//the overall scale of movement
	moveVars.overallScale = 1.0f;
	//stopping forces
	moveVars.stoppingForce = 0.8f; //function of mass
	moveVars.stoppingForceAir = 0.1f; //function of mass
	moveVars.stoppingFactor = 1.0f;
	//wallrun
	moveVars.walljumped = false;
	moveVars.walljumped_side = Walljump::NONE;
	moveVars.wallclimbing = false;
	moveVars.wallsliding = false;
	//custom
	moveVars.wallrun_length = 2;
	moveVars.wallrun_factor = 1.3f;
	moveVars.stoppingForceAirFactor = 1.0f;
	//other
	this.getBlob().set("moveVars", moveVars);
	this.getBlob().getShape().getVars().waterDragScale = 60.0f;
	this.getBlob().getShape().getConsts().collideWhenAttached = true;
}
