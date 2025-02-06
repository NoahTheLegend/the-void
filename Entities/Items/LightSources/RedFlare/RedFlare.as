#include "ParticleSparks.as";

const u16 duration = 60 * 30;
const f32 radius = 128.0f;

void onInit(CBlob@ this)
{
	this.Tag("ignore fall");
	this.getShape().SetRotationsAllowed(true);

	this.addCommandID("sync");

	if (isClient())
	{
		CBitStream params;
		params.write_bool(false);
		params.write_u16(getLocalPlayer().getNetworkID());
		this.SendCommand(this.getCommandID("sync"), params);
	}

	this.getCurrentScript().tickFrequency = 3;
}

void onTick(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	if (!blob.hasTag("activated")) return;

	s32 timer = blob.get_s32("timer") - getGameTime();
	if (!blob.hasTag("extinguished"))
	{
		blob.SetLight(true);
		blob.SetLightRadius((radius+XORRandom(16)) * (Maths::Max(0,timer)/(getGameTime()+duration))+16.0f);
		blob.SetLightColor(SColor(255, 200+XORRandom(55), 25, 25));
	}
	else blob.SetLight(false);

	if (timer < 0)
	{
		if (this.animation.name != "end") this.PlaySound("ExtinguishFire.ogg", 1.0f, 0.85f);
		this.SetAnimation("end");
		this.SetEmitSoundPaused(true);
		return;
	}
	else
	{
		this.SetEmitSoundSpeed(1.0f+XORRandom(51)*0.001f);
		this.SetAnimation("activate");
	}
}

void onTick(CBlob@ this)
{
	if (!this.hasTag("activated") || this.hasTag("extinguished")) return;

	s32 timer = this.get_s32("timer") - getGameTime();
	if (timer < 0)
	{
		this.server_SetTimeToDie(15.0f);
		this.setInventoryName("Red Flare (extinguished)");
		this.Tag("extinguished");
	}

	if (isClient())
	{
		MakeParticle(this, Vec2f(0, 0.5f - XORRandom(11)*0.1f), "RedFlareFire"+XORRandom(2));
		MakeParticle(this, Vec2f(0, 0.1f - XORRandom(5)*0.1f), "RedFlareGas");
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("activate"))
	{
		this.Tag("activated");
		this.set_s32("timer", getGameTime() + duration);

		if (isClient())
		{
			CSprite@ sprite = this.getSprite();
			if (sprite !is null)
			{
				sprite.SetEmitSound("FlareLoop.ogg");
				sprite.SetEmitSoundVolume(0.66f);
				sprite.SetEmitSoundPaused(false);

				sprite.PlaySound("FlareStart.ogg", 1.5f, 0.9f);
			}
		}
	}
	else if (cmd == this.getCommandID("sync"))
	{
		bool truesync = params.read_bool();
		u16 ply_id = params.read_u16();
		
		CPlayer@ ply = getPlayerByNetworkId(ply_id);
		if (!truesync && isServer() && ply !is null) // init
		{
			if (this.hasTag("activated"))
			{
				CBitStream nextparams;
				nextparams.write_bool(true);
				nextparams.write_u16(ply_id);
				nextparams.write_s32(this.get_s32("timer"));
				this.server_SendCommandToPlayer(this.getCommandID("sync"), nextparams, ply);
			}
		}
		if (truesync && isClient())
		{
			s32 timer = params.read_s32();
			this.set_s32("timer", timer);

			CSprite@ sprite = this.getSprite();
			if (sprite !is null)
			{
				sprite.SetEmitSound("FlareLoop.ogg");
				sprite.SetEmitSoundVolume(0.66f);
				sprite.SetEmitSoundPaused(false);
			}
		}
	}
}

void MakeParticle(CBlob@ this, const Vec2f vel, const string filename = "SmallSteam")
{
	if (!isClient()) return;

	Vec2f offset = Vec2f(0, -8).RotateBy(this.getAngleDegrees());
	CParticle@ p = ParticleAnimated(filename, this.getPosition() + offset, vel, float(XORRandom(360)), 1.0f, 2 + XORRandom(3), -0.1f, false);
	if (p !is null)
	{
		p.deadeffect = -1;
		p.timeout = 30;
		p.collides = true;
		p.diesoncollide = false;
		p.diesonanimate = false;
		p.windaffect = 5.0f;
		p.setRenderStyle(RenderStyle::additive);
	}
}

bool canBePutInInventory(CBlob@ this, CBlob@ inventoryBlob)
{
	return !this.hasTag("activated");
}

void onAttach(CBlob@ this, CBlob@ attached, AttachmentPoint@ ap)
{
	this.setAngleDegrees(0);
	this.getShape().SetRotationsAllowed(false);
}

void onDetach(CBlob@ this, CBlob@ detached, AttachmentPoint@ ap)
{
	this.getShape().SetRotationsAllowed(true);
}