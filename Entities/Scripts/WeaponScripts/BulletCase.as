//////////////////////////////////////////////////////
//
//  BulletCase.as - Vamist
//
//  Makes particle cases when you fire
//
//  Known bug: Sound doesnt play if particle doesnt fall
//             one or more tiles
//
//  Known bug: All particles will go static in the same angle
//             after falling on the ground

void ParticleBullet(Vec2f CurrentPos, Vec2f Velo)
{
	CParticle@ p = ParticlePixel(CurrentPos, getRandomVelocity(-Velo.Angle(), 3.0f, 40.0f), SColor(255, 244, 220, 66), true);
	if (p !is null)
	{
		p.fastcollision = true;
		p.bounce = 0.4f;
		p.alivetime = 120;
		p.gravity = Vec2f_zero;
#ifndef STAGING
		p.lighting = true;
		p.lighting_delay = 0;
		p.lighting_force_original_color = true;
#endif
	}
}

void ParticleFromBullet(const string particlePic, const Vec2f pos, const f32 angle)
{
	CParticle@ p = ParticleAnimated(particlePic, pos, Vec2f(5, 0), angle, 1.0f, 1, 0.0f, true);
	if (p !is null)
	{
		p.bounce = 0.5;
		p.damping = 0.5;
		p.mass = 200;
		p.fastcollision = true;
#ifndef STAGING
		p.lighting_delay = 0;
		p.lighting_force_original_color = true;
#endif
	}
}

void ParticleBulletHit(const string particlePic, Vec2f pos, f32 angle = 0.0f)
{
	CParticle@ p = ParticleAnimated(particlePic, pos + Vec2f(0,-6).RotateBy(angle), Vec2f(0, 0), angle, 0.7f, 3, 0.0f, false);
	if (p !is null)
	{
		p.gravity = Vec2f_zero;
		p.deadeffect = 0;
		p.width = 8;
		p.height = 8;
	}
}
