#include "GenericButtonCommon.as"
#include "GrinderCommon.as"
#include "UtilityChecks.as"
#include "HoverUtils.as"
#include "ToolTipUtils.as"

const f32 min_spinup_soundspeed = 0.5f;
const f32 max_spinup_soundspeed = 1.0f;
const f32 min_spinup_soundvolume = 0.1f;
const f32 max_spinup_soundvolume = 1.0f;

void onReload(CBlob@ this)
{
	onInit(this);
}

void onInit(CBlob@ this)
{
	initHoverVars(this);
	setMaxHover(this, 5, 0.5f);
	setFluctuation(this, 5, 1, 0.25f);

	this.set_u16("grinding_time", 0);
	this.set_u16("grinding_quantity", 0);
	this.set_u16("product_quantity", 0);
	this.set_u16("grinding_id", 0);
	this.set_string("resource", "");
	this.set_string("product", "");
	this.set_u16("output_link_id", 0);
	this.set_u16("failure_time", 0);

	this.set_bool("hover", false);
	this.set_bool("render", false);

	this.Tag("update");
	this.addCommandID("take_item_fx");
	this.addCommandID("sync");
	RequestSync(this);

	if (!isClient()) return;

	this.set_u16("spinup_time", 0);

	CSprite@ sprite = this.getSprite();
	if (sprite is null) return;

	sprite.SetZ(-49.0f);
	sprite.SetRelativeZ(-49.0f);
}

void onTick(CBlob@ this)
{
	u32 grinding_time = this.get_u16("grinding_time");
	if (isServer())
	{
		if (grinding_time == 0 && !this.hasTag("idle")) // ready
		{
			// grind target
			u16 grinding_id = this.get_u16("grinding_id");
			if (grinding_id != 0)
			{
				CBlob@ grinding_target = getBlobByNetworkID(grinding_id);
				if (grinding_target !is null)
				{
					u16 grinding_quantity = this.get_u16("grinding_quantity");
					u16 product_quantity = this.get_u16("product_quantity");
					u16 output_link_id = this.get_u16("output_link_id");
					string resource = this.get_string("resource");
					string product = this.get_string("product");

					if (this.hasBlob(resource, grinding_quantity)) // Check if there's enough resource
					{
						CBlob@ storage = getBlobByNetworkID(output_link_id);

						bool takeResource = true;
						u16 total_products_created = 0;

						//while (product_quantity > 0 && this.hasBlob(resource, grinding_quantity))
						{
							//f32 yield = getYield(this, mat_grind.find(resource));
							//u16 resource_per_product = Maths::Ceil(grinding_quantity * yield);
							//this.TakeBlob(resource, resource_per_product);
//
							//CBlob@ product_blob = server_CreateBlob(product, this.getTeamNum(), this.getPosition());
							//if (product_blob is null) break;
//
							//u16 quantity_to_set = Maths::Min(product_blob.getMaxQuantity(), product_quantity);
							//product_blob.server_SetQuantity(quantity_to_set);
							//product_quantity -= quantity_to_set;
							//total_products_created++;

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

							if (!takeResource)
							{
								this.Tag("idle");
								this.set_u16("failure_time", 90);

								product_blob.Tag("dead");
								product_blob.server_Die();
								break;
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
		else if (grinding_time > 0) // grinding
		{
			this.sub_u16("grinding_time", 1);
		}
	}

	if (this.get_u16("failure_time") > 0) this.sub_u16("failure_time", 1);
	if (!isClient()) return;

	CSprite@ sprite = this.getSprite();
	if (sprite is null) return;

	u16 max_spinup = this.get_u16("max_spinup_time");
	u16 spinup = this.get_u16("spinup_time");
	
	if (grinding_time > 0 && spinup < max_spinup)
		spinup++;
	else if (grinding_time == 0 && spinup > 0)
		spinup--;
	this.set_u16("spinup_time", spinup);

	f32 spin_factor = f32(this.get_u16("spinup_time")) / f32(max_spinup);
	sprite.SetEmitSoundPaused(spin_factor == 0);

	sprite.SetEmitSoundSpeed(min_spinup_soundspeed + spin_factor * (max_spinup_soundspeed - min_spinup_soundspeed));
	sprite.SetEmitSoundVolume(min_spinup_soundvolume + spin_factor * (max_spinup_soundvolume - min_spinup_soundvolume));
	
	if (!this.isOnScreen()) return;

 	bool alt = isHoldingAlt();
	bool hover = alt && isMouseOnBlob(getLocalPlayerBlob(), this);
	this.set_bool("hover", hover);
	setOpacity(this, hover);

	this.set_bool("render", this.get_f32("opacity_factor") != 0);
}

Vec2f tooltip_size = Vec2f(75, 35);

void onRender(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	if (blob is null) return;
	if (!blob.get_bool("render")) return;

	CCamera@ camera = getCamera();
	if (camera is null) return;

	Vec2f blobpos = blob.getInterpolatedPosition();
	Vec2f offset = Vec2f(0, -blob.getHeight() / 2 - 8);

	Vec2f pos2d = getDriver().getScreenPosFromWorldPos(blobpos + offset);
	f32 zoom = camera.targetDistance;

	Vec2f tl = pos2d - Vec2f(tooltip_size) * zoom / 2;
	Vec2f br = pos2d + Vec2f(tooltip_size) * zoom / 2;

	f32 gui_alpha = blob.get_f32("opacity_factor") * 255;
	f32 rnd_alpha = blob.get_f32("opacity_factor_with_random") * 255;

	drawRectangle(tl, br, SColor(rnd_alpha, 255, 255, 255), 1, 2, SColor(rnd_alpha, 25, 25, 40));
}

void onAddToInventory(CBlob@ this, CBlob@ blob)
{
	this.Untag("idle");
}

void onRemoveFromInventory(CBlob@ this, CBlob@ blob)
{
	this.Untag("idle");

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
	else if (cmd == this.getCommandID("take_item_fx"))
	{
		if (!isClient()) return;

		CSprite@ sprite = this.getSprite();
		if (sprite is null) return;

		playSoundInProximity(this, "GateClose", 1.0f, 1.0f, true);
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