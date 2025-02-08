
const int idle_time = 30 * 1;

void defaultIdleAnim(CSprite@ this, CBlob@ blob, int direction)
{
    if (blob.hasTag("dead")) return;
    string idle_anim = blob.get_string("idle_anim");
    if (this.animation.name != idle_anim) idle_anim = "";

    bool set_afk_animation = false;
    f32 vellen = blob.getShape().vellen;

    const bool up = blob.isKeyPressed(key_up);
    const bool down = blob.isKeyPressed(key_down);
    const bool left = blob.isKeyPressed(key_left);
    const bool right = blob.isKeyPressed(key_right);
    const bool action1 = blob.isKeyPressed(key_action1);
    const bool action2 = blob.isKeyPressed(key_action2);

    bool has_gravity = false; // todo
    bool on_ground = blob.isOnGround();

    if (!up && !down && !left && !right && !action1 && !action2 && has_gravity && on_ground)
    {
        if (idle_anim == "")
        {
            if (blob.get_u32("idle_cooldown") < idle_time)
            {
                blob.add_u32("idle_cooldown", 1);
            }
            else
            {
                blob.set_u32("idle_cooldown", 0);
                set_afk_animation = true;
            }
        }
    }
    else
    {
        blob.set_u32("idle_cooldown", 0);
        idle_anim = "";
    }
    //if (getGameTime() % 30 == 0) printf("idle_anim: " + idle_anim + " " + blob.get_u32("idle_cooldown"));

    if (blob.isKeyPressed(key_down))
    {
        this.SetAnimation("crouch");
    }
    else if (set_afk_animation && vellen <= 0.01f && idle_anim == "" && has_gravity && on_ground)
    {
        if (!blob.hasTag("idle"))
        {
            u8 idle_var = Maths::Max(0, int(XORRandom(2) + 1)); // hacky way, but the simplest to implement randomness for other than first anims
            idle_anim = "idle" + idle_var;
            blob.set_string("idle_anim", idle_anim);
            blob.Tag("idle");
        }

        //printf("SET idle_anim: " + idle_anim + " " + blob.get_u32("idle_cooldown"));

        this.SetAnimation(idle_anim);
    }
    else if (idle_anim != "")
    {
        this.SetAnimation(idle_anim);
    }
    else
    {
        blob.Untag("idle");
        this.SetAnimation("default");
    }

    blob.set_string("idle_anim", idle_anim);
}
