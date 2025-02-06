f32 getAimAngle(CBlob@ this, CBlob@ holder)
{
	return -(holder.getAimPos() - this.getPosition()).Angle();
}

f32 getAimAngle(CBlob@ this, Vec2f aimpos)
{
	return -(aimpos - this.getPosition()).Angle();
}