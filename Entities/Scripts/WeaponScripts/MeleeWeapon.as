// keep this script in cfg script order after scripts where you init corresponding variables and tags
#include "Hitters.as";
#include "Knocked.as";
#include "UtilityWeapons.as";

void onInit(CBlob@ this)
{
    if (!this.exists("attack_delay")) this.set_u8("attack_delay", 30);
	if (!this.exists("damage")) this.set_f32("damage", 1.0f);
	if (!this.exists("knock_time")) this.set_u8("knock_time", 0);
	if (!this.exists("hitter")) this.set_u8("hitter", Hitters::sword);
    if (!this.exists("attack_types_amount")) this.set_u8("attack_types_amount", 1);
	if (!this.exists("attack_arc")) this.set_f32("attack_arc", 30.0f);

    AttachmentPoint@ ap = this.getAttachments().getAttachmentPointByName("PICKUP");
	if (ap !is null)
	{
		ap.SetKeysToTake(key_action1);
	}
}

void onTick(CBlob@ this)
{
    if (this.isAttached() && this.isOnScreen())
	{
		AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");
		CBlob@ holder = point.getOccupied();
		if (holder is null) return;

        u8 attack_delay = this.get_u8("attack_delay");

        f32 next = this.get_u32("next_attack");
        f32 gt = getGameTime();
        f32 current_delay = Maths::Max(-5, next - gt);
        this.set_u8("current_delay", Maths::Max(0, current_delay));

        if (current_delay != -5) return; // compensate time for returning visuals into initial state

        const bool a1 = point.isKeyPressed(key_action1);
		this.set_bool("a1", a1);

		if (getKnocked(holder) <= 0) // do not attack if we have a stun
		{		
			if (a1)
			{
				CSprite@ sprite = this.getSprite();
				if (isClient() && this.exists("swing_sound") && sprite !is null)
				{
					sprite.PlayRandomSound(this.get_string("swing_sound"), 0.5f, 1.0f+XORRandom(21)*0.01f);
				}

				u8 team = holder.getTeamNum();
				
				HitInfo@[] hitInfos;
				if (getMap().getHitInfosFromArc(this.getPosition(), this.hasTag("side_attack") ? this.isFacingLeft()?180:0 : getAimAngle(this, holder), this.get_f32("attack_arc"), 12, this, @hitInfos))
				{
					for (uint i = 0; i < hitInfos.length; i++)
					{
						CBlob@ blob = hitInfos[i].blob;
						if (blob !is null && (this.hasTag("hit_only_flesh") ? blob.hasTag("flesh") : true)
                            && (this.hasTag("hit_allies") ? true : blob.getTeamNum() != this.getTeamNum()))
						{
							SetKnocked(blob, this.get_u8("knock_time"));

							if (isServer())
							{
								holder.server_Hit(blob, blob.getPosition(), Vec2f(), this.get_f32("damage"), this.get_u8("hitter"), true);
							}
						}
					}
				}

				this.set_u32("next_attack", getGameTime() + attack_delay);
                this.set_u8("attack_type", XORRandom(this.get_u8("attack_types_amount")));
			}
		}
	}
}