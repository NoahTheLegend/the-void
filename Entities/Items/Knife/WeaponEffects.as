void onInit(CBlob@ this)
{
    if (!this.exists("rotation_mod")) this.set_f32("rotation_mod", 1.0f);
}

void onTick(CBlob@ this)
{
    CSprite@ sprite = this.getSprite();
    if (sprite is null) return;

    f32 vellen = (this.getOldPosition()-this.getPosition()).Length();
    if (!this.hasScript("KnifeThrow.as") && vellen > 0.1f)
    {
        if (this.isOnGround())
        {
            this.set_f32("angle", 0);
            return;
        }
        else if (this.isAttached())
        {
            this.set_f32("angle", Maths::Lerp(this.get_f32("angle"), 0, 0.5f));
        }
        else 
        {
            f32 mod = this.get_f32("rotation_mod");

            this.add_f32("angle", (this.isFacingLeft()?-vellen:vellen) * mod);
        }

        if (this.get_f32("angle") > 360.0f) this.add_f32("angle", -360);
        else if (this.get_f32("angle") < -360.0f) this.add_f32("angle", 360);

        this.setAngleDegrees(this.get_f32("angle"));
    }
}

void onDetach(CBlob@ this, CBlob@ detached, AttachmentPoint@ ap)
{
    Random@ r = Random(getGameTime());

    if (this.hasTag("sharp"))
    {
        if (r.NextRanged(2) == 0)
        {
            CShape@ shape = this.getShape();
	        ShapeConsts@ consts = shape.getConsts();
            consts.mapCollisions = true;
            shape.SetStatic(false);

            this.AddScript("KnifeThrow.as");
    
            return;
        }
    }

    this.Tag("detached");
}