//throwing common functionality.

void client_SendThrowOrActivateCommand(CBlob@ this)
{
	CBlob @carried = this.getCarriedBlob();
	if (this.isMyPlayer())
	{
		CBitStream params;
		params.write_Vec2f(this.getPosition());
		params.write_Vec2f(this.getAimPos() - this.getPosition());
		params.write_Vec2f(this.getVelocity());
		this.SendCommand(this.getCommandID("activate/throw"), params);
	}
}

void client_SendThrowOrActivateCommandBomb(CBlob@ this, u8 bombtype)
{
    if (this.isMyPlayer())
    {
        CBitStream params;
        params.write_Vec2f(this.getPosition());
        params.write_Vec2f(this.getAimPos() - this.getPosition());
        params.write_Vec2f(this.getVelocity());
        params.write_u8(bombtype);
        this.SendCommand(this.getCommandID("activate/throw bomb"), params);
    }
}

void client_SendThrowCommand(CBlob@ this)
{
	CBlob @carried = this.getCarriedBlob();
	if (carried !is null && this.isMyPlayer())
	{
		CBitStream params;
		params.write_Vec2f(this.getPosition());
		params.write_Vec2f(this.getAimPos() - this.getPosition());
		params.write_Vec2f(this.getVelocity());
		this.SendCommand(this.getCommandID("throw"), params);
	}
}

void server_ActivateCommand(CBlob@ this, CBlob@ blob)
{
	if (blob !is null && getNet().isServer())
	{
		blob.SendCommand(blob.getCommandID("activate"));
		blob.Tag("activated");
	}
}

bool ActivateBlob(CBlob@ this, CBlob@ blob, Vec2f pos, Vec2f vector, Vec2f vel)
{
	bool shouldthrow = true;
	bool done = false;

	if (!blob.hasTag("activated") || blob.hasTag("dont deactivate"))
	{
		string carriedname = blob.getName();
		string[]@ names;

		if (this.get("names to activate", @names))
		{
			for (uint step = 0; step < names.length; ++step)
			{
				if (names[step] == carriedname)
				{
					//if compatible
					if (isServer() && blob.hasTag("activatable"))
					{
						blob.SendCommand(blob.getCommandID("activate"));
					}

					blob.Tag("activated");//just in case
					shouldthrow = false;
					this.Tag(blob.getName() + " done activate");

					// move ouit of inventory if its the case
					if (blob.isInInventory())
					{
						this.server_Pickup(blob);
					}
					done = true;
				}
			}
		}
	}

	//throw it if it's already lit or we cant light it
	if (isServer() && !blob.hasTag("custom throw") && shouldthrow && this.getCarriedBlob() is blob)
	{
		DoThrow(this, blob, pos, vector, vel);
		done = true;
	}

	return done;
}

const f32 DEFAULT_THROW_VEL = 6.0f;
const f32 DEFAULT_THROW_VEL_SELF = 1.0f;

void DoThrow(CBlob@ this, CBlob@ carried, Vec2f pos, Vec2f vector, Vec2f selfVelocity)
{
	f32 ourvelscale = 0.0f;

	if (this.get_bool("throw uses ourvel"))
	{
		ourvelscale = this.get_f32("throw ourvel scale");
	}

	if (carried !is null)
	{
		Vec2f vel = getThrowVelocity(this, carried, vector, selfVelocity, ourvelscale);

		if (carried.hasTag("medium weight"))
		{
			vel *= 0.6f;
		}
		else if (carried.hasTag("heavy weight"))
		{
			vel *= 0.3f;
		}

		if (carried.server_DetachFrom(this))
		{
			carried.setVelocity(vel);

			CShape@ carriedShape = carried.getShape();
			if (carriedShape !is null)
			{
				carriedShape.checkCollisionsAgain = true;
				carriedShape.ResolveInsideMapCollision();
			}
		}
	}
}

// delayed, rewrite teleport 
Vec2f getThrowVelocity(CBlob@ this, CBlob@ carried, Vec2f vector, Vec2f selfVelocity, f32 this_vel_affect = 0.1f)
{
	bool has_gravity = false; // todo

	Vec2f vel = vector;
	f32 len = vel.Normalize();
	
	// Calculate throw velocity without considering mass ratio
	f32 throwVelCarried = DEFAULT_THROW_VEL;
	
	vel *= throwVelCarried;
	if (carried.exists("throw scale")) vel *= carried.get_f32("throw scale");
	vel += selfVelocity * this_vel_affect; // blob velocity

	f32 closeDist = this.getRadius() + 64.0f;
	if (len < closeDist)
	{
		vel *= len / closeDist;
	}
	
	// todo
	// Vec2f oppositeForce = getOppositeForce(this, vector, massThis, massCarried, selfVelocity, this_vel_affect);
	// CBitStream params;
	// params.write_Vec2f(oppositeForce);
	// this.SendCommand(this.getCommandID("add_velocity_to_blob"), params);
	
	return vel;
}

Vec2f getOppositeForce(CBlob@ this, Vec2f vector, f32 massThis, f32 massCarried, Vec2f selfVelocity, f32 this_vel_affect)
{
	f32 massRatio = massCarried / massThis;
	f32 maxForce = Maths::Min(DEFAULT_THROW_VEL_SELF, DEFAULT_THROW_VEL_SELF * massRatio);
	f32 throwVelThis = DEFAULT_THROW_VEL_SELF * (massCarried / (massThis + massCarried));
	if (throwVelThis > maxForce)
	{
		throwVelThis = maxForce;
	}
	
	Vec2f oppositeForce = -vector * throwVelThis;
	oppositeForce *= this.get_f32("throw scale");
	oppositeForce += selfVelocity * this_vel_affect; // blob velocity
	
	return oppositeForce;
}