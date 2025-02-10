#include "HumanCommon.as"
#include "Requirements.as"
#include "RunnerAnimCommon.as"
#include "RunnerCommon.as"
#include "KnockedCommon.as"
#include "PixelOffsets.as"
#include "RunnerTextures.as"
#include "Accolades.as"

void onInit(CSprite@ this)
{
	LoadSprites(this);
	this.SetZ(0.0f);

	CBlob@ blob = this.getBlob();
	if (blob is null) return;
	blob.set_string("idle_anim", "");
	blob.set_u32("idle_cooldown", 0);
}

void onPlayerInfoChanged(CSprite@ this)
{
	LoadSprites(this);
}

void LoadSprites(CSprite@ this)
{
	ensureCorrectRunnerTexture(this, "human", "Human");
	//ensureCorrectRunnerTexture(this, "human", "HumanMars");
}

void onTick(CSprite@ this)
{
	// store some vars for ease and speed
	CBlob@ blob = this.getBlob();

	if (blob.hasTag("dead"))
	{
		if (blob.isAttached())
		{
			this.SetAnimation("deadattached");
		}
		else
		{
			this.SetAnimation("dead");
			Vec2f vel = blob.getVelocity();

			if (vel.y < -1.0f)
			{
				this.SetFrameIndex(0);
			}
			else if (vel.y > 1.0f)
			{
				this.SetFrameIndex(2);
			}
			else
			{
				this.SetFrameIndex(1);
			}
		}
		return;
	}
	// animations

	bool knocked = isKnocked(blob);
	const bool action2 = blob.isKeyPressed(key_action2);
	const bool action1 = blob.isKeyPressed(key_action1);

	{
		const bool left = blob.isKeyPressed(key_left);
		const bool right = blob.isKeyPressed(key_right);
		const bool up = blob.isKeyPressed(key_up);
		const bool down = blob.isKeyPressed(key_down);
		const bool moving = left || right || up || down;
		const bool inair = (!blob.isOnGround() && !blob.isOnLadder());
		const bool onladder = blob.isOnLadder();
		Vec2f pos = blob.getPosition();
		bool has_gravity = false; // todo
		const bool fl = blob.isFacingLeft();

		RunnerMoveVars@ moveVars;
		if (!blob.get("moveVars", @moveVars))
		{
			return;
		}

		if (knocked)
		{
			if (inair)
			{
				this.SetAnimation("knocked_air");
			}
			else
			{
				this.SetAnimation("knocked");
			}
		}
		else if (blob.hasTag("seated"))
		{
			this.SetAnimation("crouch");
		}
		else if (inair || !has_gravity)
		{
			RunnerMoveVars@ moveVars;
			if (!blob.get("moveVars", @moveVars))
			{
				return;
			}
			Vec2f vel = blob.getVelocity();
			if (vel.y < -0.0f && moveVars.walljumped)
			{
				this.SetAnimation("run");
			}
			else if (has_gravity)
			{
				this.SetAnimation("fall");

				this.animation.timer = 0;
				bool inwater = blob.isInWater();

				if (vel.y < -1.5 * (inwater ? 0.7 : 1))
				{
					this.animation.frame = 0;
				}
				else if (vel.y > 1.5 * (inwater ? 0.7 : 1))
				{
					this.animation.frame = 2;
				}
				else
				{
					this.animation.frame = 1;
				}
			}
			else
			{
				this.SetAnimation("fly");

				// left right up down
				int seed = getGameTime() + blob.getNetworkID();
				u8 t = 8;
				f32 min_vel = 0.35f;
				f32 max_vel = 1.5f;
				if (onladder)
				{
					min_vel = 0.05f;
					max_vel = 0.5f;
				}

				bool fl = blob.isFacingLeft();
				int frame = 7;

				// backwards left
				if (fl && vel.x > min_vel) frame = vel.x > max_vel ? 2 : 3;
				// forward left
				else if (fl && vel.x < -min_vel) frame = vel.x < -max_vel ? 5 : 4;
				// backwards right
				else if (!fl && vel.x < -min_vel) frame = vel.x < -max_vel ? 2 : 3;
				// forward right
				else if (!fl && vel.x > min_vel) frame = vel.x > max_vel ? 5 : 4;
				// up
				else if (vel.y < -min_vel) frame = 0;
				// down
				else if (vel.y > min_vel) frame = 1;
				else frame = seed % (t*2) >= t ? 6 : 7;

				const int sound_rate = 2;
				if (moving && frame < 6 && seed % sound_rate == 0)
				{
					playSoundInProximity(blob, "SteamHiss", 0.75f, 1.5f, true);

					Vec2f ppos = blob.getInterpolatedPosition() + blob.getVelocity() + Vec2f(fl ? 6 : -6, 0);
					Vec2f pvel = Vec2f_zero;
					Vec2f offset = Vec2f_zero;

					bool particle_secondary = false;
					Vec2f pvel_s = Vec2f_zero;
					Vec2f offset_s = Vec2f_zero;

					switch (frame)
					{
						case 0: // up
							offset = Vec2f(0, 4);
							pvel = Vec2f(0, 1);
							break;
						case 1: // down
							offset = Vec2f(fl ? 0.8f : -0.8f, -8);
							pvel = Vec2f(0, -1);
							break;
						case 2: // backwards
						case 3:
							offset = Vec2f(fl ? -4 : 4, -3);
							pvel = Vec2f(fl ? -1 : 1, 0);

							if (up && !down)
							{
								particle_secondary = true;
								offset_s = Vec2f(fl ? -1.5f : 1.5f, 3);
								pvel_s = Vec2f(fl ? 1 : -1, 1);
							}
							else if (down && !up)
							{
								particle_secondary = true;
								offset_s = Vec2f(fl ? 3 : -3, -4);
								pvel_s = Vec2f(fl ? 1 : -1, 0);
							}

							break;
						case 4: // forward
						case 5:
							offset = Vec2f(fl ? -3 : 3, -4);
							pvel = Vec2f(fl ? 1 : -1, 0);

							if (up && !down)
							{
								particle_secondary = true;
								offset_s = Vec2f(fl ? -3 : 3, 4);
								pvel_s = Vec2f(fl ? -0.5f : 0.5f, 1);
							}
							else if (down && !up)
							{
								particle_secondary = true;
								offset_s = Vec2f(fl ? -5 : 5, -5);
								pvel_s = Vec2f(fl ? -0.5f : 0.5f, -1);
							}
							break;
						default:
							pvel = Vec2f(0, 0);
							break;
					}

					CParticle@ p = ParticleAnimated("MediumSteam", ppos + offset, pvel, XORRandom(360), 0.4f, 2, 0.0f, false);
					if (p !is null)
					{
						p.Z = -1;
						p.collides = true;
						p.fastcollision = false;
						p.growth = -0.1f;
						p.timeout = 10;
						p.gravity = Vec2f_zero;
						p.deadeffect = -1;
						p.setRenderStyle(RenderStyle::additive);
					}

					if (particle_secondary)
					{
						CParticle@ p_s = ParticleAnimated("MediumSteam", ppos + offset_s, pvel_s, XORRandom(360), 0.25f, 2, 0.0f, false);
						if (p_s !is null)
						{
							p_s.Z = -1;
							p_s.collides = true;
							p_s.fastcollision = false;
							p_s.growth = -0.1f;
							p.timeout = 10;
							p_s.gravity = Vec2f_zero;
							p_s.deadeffect = -1;
							p_s.setRenderStyle(RenderStyle::additive);
						}
					}
				}

				this.animation.frame = frame;
			}
		}
		else if (has_gravity && ((left || right) ||
		         (onladder && (up || down))))
		{
			this.SetAnimation("run");
		}
		else
		{
			defaultIdleAnim(this, blob, 0);
		}
	}

	if (knocked)
	{
		blob.Tag("dead head");
	}
	else if (blob.isInFlames())
	{
		blob.Tag("attack head");
		blob.Untag("dead head");
	}
	else
	{
		blob.Untag("attack head");
		blob.Untag("dead head");
	}
}

void DrawCursorAt(Vec2f position, string& in filename)
{
	position = getMap().getAlignedWorldPos(position);
	if (position == Vec2f_zero) return;
	position = getDriver().getScreenPosFromWorldPos(position - Vec2f(1, 1));
	GUI::DrawIcon(filename, position, getCamera().targetDistance * getDriver().getResolutionScaleFactor());
}

// render cursors

const string cursorTexture = "Entities/Characters/Sprites/TileCursor.png";

void onRender(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	if (!blob.isMyPlayer())
	{
		return;
	}
	if (getHUD().hasButtons())
	{
		return;
	}

	// draw tile cursor

	if (blob.isKeyPressed(key_action1))
	{
		HitData@ hitdata;
		blob.get("hitdata", @hitdata);
		CBlob@ hitBlob = hitdata.blobID > 0 ? getBlobByNetworkID(hitdata.blobID) : null;

		if (hitBlob !is null) // blob hit
		{
			if (!hitBlob.hasTag("flesh"))
			{
				hitBlob.RenderForHUD(RenderStyle::outline);

				// hacky fix for shitty z-buffer issue
				// the sprite layers go out of order while hitting with this fix,
				// but its better than the entire blob glowing brighter than the sun
				if (v_postprocess)
				{
					hitBlob.RenderForHUD(RenderStyle::normal);
				}
			}
		}
		else// map hit
		{
			DrawCursorAt(hitdata.tilepos, cursorTexture);
		}
	}
}

void onGib(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	Vec2f pos = blob.getPosition();
	Vec2f vel = blob.getVelocity();
	vel.y -= 3.0f;
	f32 hp = Maths::Min(Maths::Abs(blob.getHealth()), 2.0f) + 1.0;
	const u8 team = blob.getTeamNum();
	CParticle@ Body     = makeGibParticle("HumanGibs.png", pos, vel + getRandomVelocity(90, hp , 80), 0, 0, Vec2f(16, 16), 2.0f, 20, "/BodyGibFall", team);
	CParticle@ Arm1     = makeGibParticle("HumanGibs.png", pos, vel + getRandomVelocity(90, hp - 0.2 , 80), 1, 0, Vec2f(16, 16), 2.0f, 20, "/BodyGibFall", team);
	CParticle@ Arm2     = makeGibParticle("HumanGibs.png", pos, vel + getRandomVelocity(90, hp - 0.2 , 80), 1, 0, Vec2f(16, 16), 2.0f, 20, "/BodyGibFall", team);
	CParticle@ Shield   = makeGibParticle("HumanGibs.png", pos, vel + getRandomVelocity(90, hp , 80), 2, 0, Vec2f(16, 16), 2.0f, 0, "Sounds/material_drop.ogg", team);
	CParticle@ Sword    = makeGibParticle("HumanGibs.png", pos, vel + getRandomVelocity(90, hp + 1 , 80), 3, 0, Vec2f(16, 16), 2.0f, 0, "Sounds/material_drop.ogg", team);
}
