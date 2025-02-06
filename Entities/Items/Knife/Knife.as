#include "Hitters.as";
#include "Knocked.as";

const u8 attack_delay = 15;
const f32 damage = 0.5f;
const u8 knock_time = 5;

const Vec2f hit_pos_forward = Vec2f(0,0); // startpoint;
const Vec2f hit_pos_above = Vec2f(2,-4);

const Vec2f hit_target_forward = Vec2f(-6,2); // endpoint;
const Vec2f hit_target_above = Vec2f(-4,4);

void onInit(CBlob@ this)
{
	this.Tag("ignore fall");

	this.set_u8("attack_delay", attack_delay);
	this.set_f32("damage", damage);
	this.set_u8("knock_time", knock_time);
	this.set_u8("hitter", Hitters::sword);
	this.Tag("hit_only_flesh");
	this.set_u8("attack_types_amount", 2);
	this.set_string("swing_sound", "/swing");

	this.set_f32("rotation_mod", 5);
	this.Tag("sharp");
	this.Tag("tool");
	this.Tag("side_attack"); // hit only left or right
	this.set_f32("attack_arc", 45);

	CSprite@ sprite = this.getSprite();
	if (sprite is null) return;
}

void onTick(CBlob@ this)
{
	CSprite@ sprite = this.getSprite();
	if (sprite is null) return;

	CShape@ shape = this.getShape();
	if (shape is null) return;

	u8 current_delay = this.get_u8("current_delay");
	u8 attack_type = this.get_u8("attack_type");
	Vec2f offset = Vec2f(0, 0);
	f32 time_factor = f32(current_delay) / f32(attack_delay);

	switch (attack_type)
	{
		case 0: // forward
		{
			if (current_delay > 0 && current_delay < attack_delay)
			{
				Vec2f current_offset = Vec2f(hit_target_forward.x * time_factor,
					hit_target_forward.y); 
				offset = current_offset;
			}
			
			break;
		}
		case 1: // from above
		{
			if (current_delay > attack_delay - 3)
			{
				offset = hit_pos_above;
			}
			else if (current_delay > 0)
			{
				Vec2f current_offset = Vec2f(0, -4) + offset + (Vec2f(hit_target_above) * time_factor);
				offset = current_offset;
			}
			
			break;
		}
	}

	sprite.SetOffset(offset);
}

void onRender(CSprite@ sprite) // lock it to fps so it doesnt "shake" inbetween face direction changes
{
	sprite.ResetTransform();
	sprite.ScaleBy(0.85f, 0.75f);

	CBlob@ this = sprite.getBlob();
	if (this is null) return;
	u8 current_delay = this.get_u8("current_delay");
	u8 attack_type = this.get_u8("attack_type");

	AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");
	CBlob@ holder = point.getOccupied();
	if (holder is null) return;

	switch (attack_type)
	{
		case 0: // forward
		{
			if (current_delay == 0)
			{
				this.set_f32("rotation", Maths::Lerp(this.get_f32("rotation"), 45, 0.5f));
				f32 rot = this.get_f32("rotation");

				sprite.RotateBy(holder.isFacingLeft() ? rot : -rot, Vec2f(0,0));
			}
			else this.set_f32("rotation", 0);
			
			break;
		}
		case 1: // from above
		{
			if (current_delay == 0)
			{
				this.set_f32("rotation", Maths::Lerp(this.get_f32("rotation"), 45, 0.5f));
				f32 rot = this.get_f32("rotation");

				sprite.RotateBy(holder.isFacingLeft() ? rot : -rot, Vec2f(0,0));
			}
			else
			{
				this.set_f32("rotation", -35);
				sprite.RotateBy(holder.isFacingLeft() ? -35 : 35, Vec2f(0,0));
			}

			break;
		}
	}
}

