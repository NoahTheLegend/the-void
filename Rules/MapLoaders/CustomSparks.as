void customSparks(Vec2f pos, int amount, Vec2f gravity, SColor col)
{
	if (!getNet().isClient())
		return;

	for (int i = 0; i < amount; i++)
    {
        Vec2f vel(XORRandom(16) * 0.1f * 1.0f + 0.5f, 0);
        vel.RotateBy(XORRandom(360) * 360.0f);

        CParticle@ p = ParticlePixelUnlimited(pos, vel, col, true);
        if(p is null) return; //bail if we stop getting particles

    	p.fastcollision = true;
		p.gravity = gravity;
        p.timeout = 15 + XORRandom(16);
        p.scale = 0.5f + XORRandom(51)*0.01f;
        p.damping = 0.95f;
    }
}

Vec2f rnd_vel(f32 max_x, f32 max_y, f32 level)
{
    max_x *= level;
    max_y *= level;
    return Vec2f((XORRandom(max_x*2)-max_x) / level, (XORRandom(max_y*2)-max_y) / level);
}