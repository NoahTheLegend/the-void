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
	this.set_u16("max_grinding_time", 0);
	this.set_u16("grinding_quantity", 0);
	this.set_u16("product_quantity", 0);
	this.set_u16("grinding_id", 0);
	this.set_string("resource", "");
	this.set_string("product", "");
	this.set_u16("output_link_id", 0);
	this.set_u16("failure_time", 0);
	this.set_u16("input_icon_id", -1);
	this.set_u16("output_icon_id", -1);

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
	f32 progress = 0;
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
					int grinding_quantity = this.get_u16("grinding_quantity");
					int product_quantity = this.get_u16("product_quantity");
					int output_link_id = this.get_u16("output_link_id");
					string resource = this.get_string("resource");
					string product = this.get_string("product");

					CBlob@ storage = getBlobByNetworkID(output_link_id);
					while (product_quantity > 0)
					{
						bool takeResource = true;

						CBlob@ product_blob = server_CreateBlob(product, this.getTeamNum(), this.getPosition());
						product_blob.server_SetQuantity(Maths::Min(product_quantity, product_blob.getMaxQuantity()));
						
						u16 resource_to_take = 1;
						int resource_idx = mat_grind.find(resource);

						if (resource_idx != -1)
							resource_to_take = Maths::Ceil(mat_input_output_ratio[resource_idx][0]) * product_blob.getQuantity();
						
						product_quantity -= product_blob.getQuantity();
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
						else
						{
							grinding_quantity -= resource_to_take;
							this.TakeBlob(resource, resource_to_take);
						}
					}
				}

				this.Tag("update");
				ResetGrindTarget(this);
				Sync(this);
			}

			// set new if necessary
			if (this.hasTag("update"))
			{
				ResetGrindTarget(this);

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
			progress = f32(grinding_time) / f32(this.get_u16("max_grinding_time"));
			this.sub_u16("grinding_time", 1);
		}
	}
	this.set_f32("progress", progress);

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
	f32 sprite_time = spin_factor == 0 ? 0 : ((1.0f - spin_factor) * 5) + 4;
	if (sprite.animation.time != sprite_time) sprite.animation.time = sprite_time;

	sprite.SetEmitSoundPaused(spin_factor == 0);
	sprite.SetEmitSoundVolume((min_spinup_soundvolume + spin_factor * (max_spinup_soundvolume - min_spinup_soundvolume)) * getSoundFallOff(this, 64, 128.0f));
	sprite.SetEmitSoundSpeed(min_spinup_soundspeed + spin_factor * (max_spinup_soundspeed - min_spinup_soundspeed));
	
	if (!this.isOnScreen()) return;
 	bool alt = isHoldingAlt();

	bool hover = alt && isMouseOnBlob(getLocalPlayerBlob(), this);
	this.set_bool("hover", hover);
	setOpacity(this, hover);

	this.set_bool("render", this.get_f32("opacity_factor") * 255 > 0);
}

Vec2f tooltip_size = Vec2f(60, 30);
void onRender(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	if (blob is null) return;
	if (!blob.get_bool("render")) return;

	CCamera@ camera = getCamera();
	if (camera is null) return;

	Vec2f blobpos = blob.getInterpolatedPosition();
	Vec2f offset = Vec2f(0, -blob.getHeight() / 2 - 8);

	Vec2f blobpos2d = getDriver().getScreenPosFromWorldPos(blobpos);
	Vec2f pos2d = getDriver().getScreenPosFromWorldPos(blobpos + offset);
	f32 zoom = camera.targetDistance;

	Vec2f tl = pos2d - Vec2f(tooltip_size) * zoom / 2;
	Vec2f br = pos2d + Vec2f(tooltip_size) * zoom / 2;

	f32 opacity_factor = blob.get_f32("opacity_factor");
	f32 opacity_factor_with_random = blob.get_f32("opacity_factor_with_random");
	f32 gui_alpha = opacity_factor * 255;
	f32 rnd_alpha = opacity_factor_with_random * 255;
	
	SColor col_hologram = _col_hologram;
	col_hologram.setAlpha(rnd_alpha * 0.5f);
	SColor col_hologram_border = _col_hologram_border;
	col_hologram_border.setAlpha(gui_alpha * 0.5f);
	SColor col_hologram_cone = _col_hologram_cone;
	col_hologram_cone.setAlpha(rnd_alpha);
	SColor col_hologram_progress = _col_hologram_progress;
	col_hologram_progress.setAlpha(rnd_alpha * 0.625f);

	drawRectangle(tl, br, col_hologram, 1, 4, col_hologram_border);

	u16 input_icon_id = blob.get_u16("input_icon_id");
	u16 output_icon_id = blob.get_u16("output_icon_id");

	if (input_icon_id > 0 && output_icon_id > 0)
	{
		Vec2f pos_input = tl + Vec2f(4, 2) * zoom;
		Vec2f pos_output = tl + Vec2f(tooltip_size.x - 26, 2) * zoom;

		GUI::DrawIcon("Materials.png", input_icon_id, Vec2f(16, 16), pos_input, zoom * 0.75f, SColor(gui_alpha * 0.66f,155,155,255));
		GUI::DrawIcon("Materials.png", output_icon_id, Vec2f(16, 16), pos_output, zoom * 0.75f, SColor(gui_alpha * 0.66f,155,155,255));
		
		f32 progress = 1.0f - blob.get_f32("progress");
		drawProgressBarAroundRectangle(tl, tooltip_size * zoom, progress, 2 * zoom, col_hologram_progress);
	}
	drawInterruptor(tl, br, Vec2f(tooltip_size.x, 3.5f), SColor(gui_alpha*0.1f,0,0,0), zoom, 0.5f, 0); // moving line

	f32 angle = 90 * opacity_factor;
	drawCone(blobpos2d, br - Vec2f(br.x - tl.x, 0) / 2, angle, col_hologram_cone);
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
			this.set_u16("max_grinding_time", params.read_u16());
			this.set_u16("grinding_quantity", params.read_u16());
			this.set_u16("product_quantity", params.read_u16());
			this.set_u16("grinding_id", params.read_u16());
			this.set_string("resource", params.read_string());
			this.set_string("product", params.read_string());
			this.set_u16("output_link_id", params.read_u16());
			this.set_u16("failure_time", params.read_u16());
			this.set_u16("input_icon_id", params.read_u16());
			this.set_u16("output_icon_id", params.read_u16());
			this.set_u8("clip_time", params.read_u8());
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