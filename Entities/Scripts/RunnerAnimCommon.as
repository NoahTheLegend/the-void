#include "EmotesCommon.as";

void defaultIdleAnim(CSprite@ this, CBlob@ blob, int direction)
{
    bool has_emote = is_emote(blob, true);
    bool can_idle = this.animation.name.find("idle") != -1;

	if (blob.isKeyPressed(key_down))
	{
		this.SetAnimation("crouch");
	}
    else if (has_emote)
	{
        if (!blob.hasTag("idle"))
        {
            u8 idle_var = Maths::Max(0, int(XORRandom(5))-2); // hacky way, but the simplest to implement randomness for other than first anims
            blob.set_string("idle_anim", "idle"+idle_var);
            blob.Tag("idle");
        }
		this.SetAnimation(blob.get_string("idle_anim"));
	}
	else
	{
        blob.Untag("idle");
        this.SetAnimation("default");
	}
	
}
