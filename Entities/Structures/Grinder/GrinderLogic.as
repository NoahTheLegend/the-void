#include "GenericButtonCommon.as"
#include "GrinderCommon.as"

const f32 min_spinup_soundspeed = 0.5f;
const f32 max_spinup_soundspeed = 1.0f;
const f32 min_spinup_soundvolume = 0.1f;
const f32 max_spinup_soundvolume = 1.0f;

void onInit(CBlob@ this)
{
	this.set_u16("grinding_time", 0);
	this.set_u16("grinding_quantity", 0);
	this.set_u16("product_quantity", 0);
	this.set_u16("grinding_id", 0);
	this.set_string("resource", "");
	this.set_string("product", "");
	this.set_u16("output_link_id", 0);
	this.set_u16("failure_time", 0);

	this.Tag("update");
	this.addCommandID("sync");
	RequestSync(this);

	if (!isClient()) return;

	CSprite@ sprite = this.getSprite();
	if (sprite is null) return;

	sprite.SetZ(-50.0f);

	this.set_u16("spinup_time", 0);
}

void onTick(CBlob@ this)
{
	u32 grinding_time = this.get_u16("grinding_time");
	if (isServer())
	{
		if (grinding_time == 0) // ready
		{
			// grind target
			u16 grinding_id = this.get_u16("grinding_id");
			if (grinding_id != 0)
			{
				CBlob@ grinding_target = getBlobByNetworkID(grinding_id);
				if (grinding_target !is null)
				{
					string resource = this.get_string("resource");
					string product = this.get_string("product");

					if (this.hasBlob(resource, this.get_u16("grinding_quantity")))
					{
						CBlob@ product_blob = server_CreateBlob(product, this.getTeamNum(), this.getPosition());
						if (product_blob !is null)
						{
							bool takeResource = true;

							u16 product_quantity = this.get_u16("product_quantity");
							product_blob.server_SetQuantity(product_quantity);
							
							u16 output_link_id = this.get_u16("output_link_id");
							CBlob@ storage = getBlobByNetworkID(output_link_id);

							bool try_self = true;
							if (output_link_id != 0 && storage !is null)
							{
								if (storage.server_PutInInventory(product_blob))
								{
									try_self = false;
									takeResource = true;
								}
								else
									takeResource = false;
							}

							if (try_self)
							{
								if (!this.server_PutInInventory(product_blob))
									takeResource = false;
							}

							if (takeResource)
							{
								this.TakeBlob(resource, this.get_u16("grinding_quantity"));
							}
							else // failure
							{
								this.set_u16("failure_time", 90);

								product_blob.Tag("dead");
								product_blob.server_Die();
							}
						}
					}
				}

				this.Tag("update");
				ResetGrindTarget(this);
			}

			// set new if necessary
			if (this.hasTag("update"))
			{
				CBlob@ target = FindNewGrindTarget(this);
				if (target !is null)
				{
					SetNewGrindTarget(this, target);
					Sync(this);

					this.Untag("update");
				}
			}
		}
		else
		{
			this.sub_u16("grinding_time", 1);
		}
	}

	if (this.get_u16("failure_time") > 0) this.sub_u16("failure_time", 1);

	if (!isClient()) return;

	CSprite@ sprite = this.getSprite();
	if (sprite is null) return;

	u16 max_spinup = this.get_u16("max_spinup_time");
	if (grinding_time > 0)
		this.set_u16("spinup_time", Maths::Min(this.get_u16("spinup_time") + 1, max_spinup));
	
	f32 spin_factor = f32(this.get_u16("spinup_time")) / f32(max_spinup);
	sprite.SetEmitSoundPaused(spin_factor == 0);

	sprite.SetEmitSoundSpeed(min_spinup_soundspeed + spin_factor * (max_spinup_soundspeed - min_spinup_soundspeed));
	sprite.SetEmitSoundVolume(min_spinup_soundvolume + spin_factor * (max_spinup_soundvolume - min_spinup_soundvolume));
}

void onRemoveFromInventory(CBlob@ this, CBlob@ blob)
{
	if (!isServer()) return;
	if (blob is null) return;

	if (blob.getNetworkID() == this.get_u16("grinding_id"))
	{
		this.Tag("update");
		ResetGrindTarget(this);
		// could need a sync here maybe
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("sync"))
	{
		bool request = params.read_bool();
		u16 pid = params.read_u16();
		
		if (request && isServer())
		{
			Sync(this, pid);
		}
		else if (!request && isClient())
		{
			this.set_u16("grinding_time", params.read_u16());
			this.set_u16("grinding_quantity", params.read_u16());
			this.set_u16("product_quantity", params.read_u16());
			this.set_u16("grinding_id", params.read_u16());
			this.set_string("resource", params.read_string());
			this.set_string("product", params.read_string());
			this.set_u16("output_link_id", params.read_u16());
			this.set_u16("failure_time", params.read_u16());
		}
	}
}

void Sync(CBlob@ this, u16 pid = 0)
{
	if (!isServer()) return;

	CBitStream params;
	params.write_bool(false);
	params.write_u16(0);
	params.write_u16(this.get_u16("grinding_time"));
	params.write_u16(this.get_u16("grinding_quantity"));
	params.write_u16(this.get_u16("product_quantity"));
	params.write_u16(this.get_u16("grinding_id"));
	params.write_string(this.get_string("resource"));
	params.write_string(this.get_string("product"));
	params.write_u16(this.get_u16("output_link_id"));
	params.write_u16(this.get_u16("failure_time"));

	if (pid != 0)
	{
		CPlayer@ p = getPlayerByNetworkId(pid);
		if (p !is null)
			this.server_SendCommandToPlayer(this.getCommandID("sync"), params, p);
	}

	if (pid == 0)
		this.SendCommand(this.getCommandID("sync"), params);
}

void RequestSync(CBlob@ this)
{
	if (!isClient() || getLocalPlayer() is null) return;

	CBitStream params;
	params.write_bool(true);
	params.write_u16(getLocalPlayer().getNetworkID());
	this.SendCommand(this.getCommandID("sync"), params);
}