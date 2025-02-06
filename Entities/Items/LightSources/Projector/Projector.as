const f32 max_distance = 352.0f;

void onInit(CBlob@ this)
{
	this.SetLight(true);
	this.SetLightRadius(16.0f);
	this.SetLightColor(SColor(255, 255, 230, 180));

	makeLight(this);
}

void makeLight(CBlob@ this)
{
	if (isServer())
	{
		CBlob@ blob = server_CreateBlobNoInit("projector_light");
		if (blob is null) return;

		blob.setPosition(this.getPosition());
		blob.Init();

		blob.set_u16("remote_id", this.getNetworkID());
		this.set_u16("remote_id", blob.getNetworkID());
	}
}

void onTick(CBlob@ this)
{
	this.SetLight(this.isAttached());

	if (isServer())
	{
		if (this.getVelocity() != Vec2f_zero || this.isAttached()) //only tick if moving 
		{
			bool flip = this.isFacingLeft();
			f32 angle = this.getAngleDegrees();
			f32 aim_distance = max_distance;

			AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");
			CBlob@ holder = point.getOccupied();
			if (holder !is null)
			{
				aim_distance = Maths::Abs((holder.getAimPos() - this.getPosition()).Length());
				this.setAngleDegrees(getAimAngle(this, holder));
			}

			Vec2f hitPos;
			Vec2f dir = Vec2f((flip ? -1 : 1), 0.0f).RotateBy(angle);
			Vec2f startPos = this.getPosition();
			Vec2f endPos = startPos + dir * Maths::Min(aim_distance, max_distance);

			HitInfo@[] hitInfos;
			bool mapHit = getMap().rayCastSolid(startPos, endPos, hitPos);
			f32 length = (hitPos - startPos).Length();
			bool blobHit = getMap().getHitInfosFromRay(startPos, angle + (flip ? 180.0f : 0.0f), length, this, @hitInfos);

			CBlob@ light = getBlobByNetworkID(this.get_u16("remote_id"));
			if (light !is null)
			{
				light.setPosition(Vec2f_lerp(light.getPosition(), hitPos, 0.2f));
			}
		}
	}
}

void onThisAddToInventory(CBlob@ this, CBlob@ inventoryBlob)
{
	this.SetLight(false);
	onDie(this);
}

void onThisRemoveFromInventory(CBlob@ this, CBlob@ inventoryBlob)
{
	this.SetLight(true);
	makeLight(this);
}

void onDie(CBlob@ this)
{
	if (!isServer()) return;
	CBlob@ light = getBlobByNetworkID(this.get_u16("remote_id"));
	if (light !is null) light.server_Die();
}

f32 getAimAngle(CBlob@ this, CBlob@ holder)
{
	Vec2f aimvector = holder.getAimPos() - (this.hasTag("place45") /*&& this.hasTag("a1"))*/ ? holder.getInterpolatedPosition() : this.getInterpolatedPosition());
	f32 angle = holder.isFacingLeft() ? -aimvector.Angle() + 180.0f : -aimvector.Angle();
	if (holder.isAttached()) this.SetFacingLeft(holder.isFacingLeft());
	return angle;
}