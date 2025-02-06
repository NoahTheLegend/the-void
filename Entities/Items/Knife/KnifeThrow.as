#include "Hitters.as";
#include "KnockedCommon.as";
#include "DoorCommon.as";
#include "CustomBlocks.as";

const f32 fastSpeed = 8.0f;

void onTick(CBlob@ this)
{
	if (this.hasTag("removescript"))
	{
		RemoveScript(this);
		return;
	}

	CShape@ shape = this.getShape();
	ShapeConsts@ consts = shape.getConsts();
    consts.mapCollisions = false;
    consts.bullet = true;
	consts.net_threshold_multiplier = 0.5f;

	f32 angle;
	bool processSticking = true;

	//if (!this.hasTag("collided")) // falls through ground sometimes, kag
	{
		angle = shape.vellen < 0.5f ? this.get_f32("old_rot") : (this.getOldPosition()-this.getPosition()).Angle();
        this.set_f32("old_rot", angle);
        if (!this.isFacingLeft()) angle += 180;
		Pierce(this);
		this.setAngleDegrees(-angle);

		if (shape.vellen > 0.1f)
		{
			if (shape.vellen > 13.5f)
			{
				shape.SetGravityScale(0.1f);
			}
			else
			{
				shape.SetGravityScale(Maths::Min(1.0f, 1.0f / (shape.vellen * 0.1f)));
			}

			processSticking = false;
		}
	}

	// sticking
	if (processSticking)
	{	
		shape.getConsts().collidable = false;
		
		angle = Maths::get360DegreesFrom256(this.get_u8("rot"));
		shape.SetStatic(true);
	}
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	//anything to always hit
	if (specialHit(blob))
	{
		return true;
	}

	bool check = blob.getName() == "bridge" || (blob.getName() == "keg"
        && !blob.isAttached() && this.hasTag("fire source"));

	if (!check)
	{
		CShape@ shape = blob.getShape();
		check = (shape.isStatic() && !shape.getConsts().platform);
	}

	if (check)
	{
		if (this.getShape().isStatic() ||
			this.hasTag("collided") ||
			blob.hasTag("dead") ||
			blob.hasTag("ignore_arrow"))
                return false;
		else return true;
	}

	return false;
}

bool specialHit(CBlob@ blob)
{
	string bname = blob.getName();
	return (bname == "fishy" && blob.hasTag("dead") || bname == "food"
		|| bname == "steak" || bname == "grain");
}

void Pierce(CBlob @this, CBlob@ blob = null)
{
	Vec2f end;
	CMap@ map = getMap();
	Vec2f position = blob is null ? this.getPosition() : blob.getPosition();

	if (map.rayCastSolidNoBlobs(this.getShape().getVars().oldpos, position, end))
	{
		DoHitMap(this, end, this.getOldVelocity(), 0.1f, Hitters::arrow, blob);
	}
}

void DoHitMap(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, u8 customData, CBlob@ blob = null)
{
	f32 radius = this.getRadius();
	f32 angle = velocity.Angle();
	this.set_u8("rot", Maths::get256DegreesFrom360(angle));

	Vec2f norm = velocity;
	norm.Normalize();
	norm *= (1.25f * radius);
	Vec2f lock = worldPoint - norm;

	if (isServer())
        this.set_Vec2f("hitWorldPoint", worldPoint);

	this.Sync("rot", true);

	this.setVelocity(Vec2f(0, 0));
	this.setPosition(lock);
	this.Tag("collided");
}

void onAttach(CBlob@ this, CBlob@ attached, AttachmentPoint@ ap)
{
	this.Tag("removescript");
}

void onDetach(CBlob@ this, CBlob@ detached, AttachmentPoint@ ap)
{
	CShape@ shape = this.getShape();
	shape.getConsts().mapCollisions = true;

	if (shape.isOverlappingTileSolid(true))
		this.setAngleDegrees(0);
}

void RemoveScript(CBlob@ this)
{
	this.set_Vec2f("hitWorldPoint", Vec2f_zero);
    this.Untag("removescript");
	this.Untag("collided");

	CShape@ shape = this.getShape();
	ShapeConsts@ consts = shape.getConsts();
	consts.mapCollisions = true;
	shape.SetStatic(false);

    this.RemoveScript("KnifeThrow.as");
}