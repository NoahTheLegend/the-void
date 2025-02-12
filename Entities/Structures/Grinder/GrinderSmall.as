#include "GrinderCommon.as"
#include "HoverUtils"

void onInit(CBlob@ this)
{
    this.inventoryButtonPos = Vec2f(0, 0);
	this.set_u16("max_spinup_time", spinup_time_small);
	
	if (!isClient()) return;
	
	CSprite@ sprite = this.getSprite();
	if (sprite is null) return;

	sprite.SetEmitSound("GrinderSmallLoop.ogg");
	sprite.SetEmitSoundVolume(1.0f);
	sprite.SetEmitSoundSpeed(1.0f);
	sprite.SetEmitSoundPaused(true);
}