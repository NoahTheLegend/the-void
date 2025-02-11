#include "GrinderCommon.as"

void onInit(CBlob@ this)
{
    this.inventoryButtonPos = Vec2f(0, 0);
	this.set_u16("max_spinup_time", spinup_time_small);

    // todo
	//sprite.SetEmitSound("");
	//sprite.SetEmitSoundVolume(1.0f);
	//sprite.SetEmitSoundSpeed(1.0f);
	//sprite.SetEmitSoundPaused(true);
}