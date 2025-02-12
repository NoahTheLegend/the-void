
f32 opacity_factor = 0.0f;
f32 opacity_factor_with_random = 0.0f;

uint max_hover_time = 30;
uint hover_time = 0;
uint hover_time_target = 0; // for lerp
f32 lerp_factor = 0.25f;

uint fluctuation_frequency = 5;
u8 fluctuation_type = 0; // 0 is direct random, 1 is Maths::Sin(), 2 is Maths::Sin(Maths::ATan())
f32 max_fluctuation = 0.1f;
f32 current_random = 0.0f;

bool isHoldingAlt()
{
    if (!isClient()) return false;
    
    CControls@ controls = getControls();
    if (controls is null) return false;

    return controls.isKeyPressed(KEY_LMENU) || controls.isKeyPressed(KEY_RMENU);
}

bool isMouseOnBlob(CBlob@ blob, CBlob@ target)
{
    if (blob is null) return false;
    if (!blob.isMyPlayer()) return false;
    if (target is null) return false;

    CControls@ controls = getControls();
    if (controls is null) return false;

    Vec2f mousePos = getDriver().getWorldPosFromScreenPos(controls.getInterpMouseScreenPos());
    Vec2f targetPos = target.getPosition();

    CShape@ shape = target.getShape();
    if (shape is null) return false;

    Vec2f tl_shape = Vec2f_zero;
    Vec2f br_shape = Vec2f_zero;
    shape.getBoundingRect(tl_shape, br_shape);

    return mousePos.x >= tl_shape.x && mousePos.x <= br_shape.x && mousePos.y >= tl_shape.y && mousePos.y <= br_shape.y;
}

void setOpacity(bool hover)
{
    // set _opacity_factor as the difference between hover_time and max_hover time using Maths::Lerp
    // if getGameTime() % fluctuation_frequency == 0, use Maths::Lerp to fluctuate _opacity_factor to +- 1.0f * max_fluctuation

    if (hover && hover_time_target > 0) hover_time_target--;
    else if (!hover && hover_time_target < max_hover_time) hover_time_target++;

    if (getGameTime() % fluctuation_frequency == 0)
    {
        f32 fluctuation = 0.0f;
        switch (fluctuation_type)
        {
            case 0:
                fluctuation = XORRandom(max_fluctuation * 100) * 0.01f;
                break;
            case 1:
                fluctuation = Maths::Sin(getGameTime() * 0.1f);
                break;
            case 2:
                fluctuation = Maths::Sin(Maths::ATan(getGameTime() * 0.1f));
                break;
        }

        current_random = fluctuation;
    }

    uint hover_time_rnd = Maths::Lerp(hover_time, Maths::Max(0, hover_time_target - current_random), lerp_factor);
    opacity_factor_with_random = 1.0f - (f32(hover_time_rnd) / f32(max_hover_time));

    hover_time = Maths::Lerp(hover_time, Maths::Max(0, hover_time_target), lerp_factor);
    opacity_factor = 1.0f - (f32(hover_time) / f32(max_hover_time));
}