#include "UtilityChecks.as"

void initHoverVars(CBlob@ blob)
{
    blob.set_f32("max_hover_time", 30.0f);
    blob.set_f32("lerp_factor", 0.25f);
    blob.set_u8("fluctuation_frequency", 0);
    blob.set_u8("fluctuation_type", 0);
    blob.set_f32("max_fluctuation", 0.0f);
    blob.set_f32("hover_time", 30.0f);
    blob.set_f32("hover_time_target", 30.0f);
    blob.set_f32("hover_time_rnd", 0.0f);
    blob.set_f32("hover_time_target_rnd", 0.0f);
    blob.set_f32("current_random", 0.0f);
    blob.set_f32("opacity_factor", 1.0f);
    blob.set_f32("opacity_factor_with_random", 1.0f);
}

void setMaxHover(CBlob@ blob, f32 max_hover, f32 lerp)
{
    blob.set_f32("max_hover_time", max_hover);
    blob.set_f32("lerp_factor", lerp);

    blob.set_f32("hover_time", max_hover);
    blob.set_f32("hover_time_target", max_hover);
    blob.set_f32("hover_time_rnd", max_hover);
    blob.set_f32("hover_time_target_rnd", max_hover);
}

void setFluctuation(CBlob@ blob, u8 freq, u8 type, f32 fluctuation_max)
{
    blob.set_u8("fluctuation_frequency", freq);
    blob.set_u8("fluctuation_type", type);
    blob.set_f32("max_fluctuation", fluctuation_max);
}

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
    if (!inProximity(blob, target)) return false;

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

bool isMouseInBox(CBlob@ blob, Vec2f tl, Vec2f br)
{
    if (blob is null) return false;
    if (!blob.isMyPlayer()) return false;

    CControls@ controls = getControls();
    if (controls is null) return false;

    Vec2f mousePos = getDriver().getWorldPosFromScreenPos(controls.getInterpMouseScreenPos());

    return mousePos.x >= tl.x && mousePos.x <= br.x && mousePos.y >= tl.y && mousePos.y <= br.y;
}

bool isMouseInScreenBox(CBlob@ blob, Vec2f tl, Vec2f br)
{
    if (blob is null) return false;
    if (!blob.isMyPlayer()) return false;

    CControls@ controls = getControls();
    if (controls is null) return false;

    Vec2f mousePos = controls.getInterpMouseScreenPos();

    return mousePos.x >= tl.x && mousePos.x <= br.x && mousePos.y >= tl.y && mousePos.y <= br.y;
}

void setOpacity(CBlob@ blob, bool hover)
{
    f32 max_hover_time = blob.get_f32("max_hover_time");
    f32 lerp_factor = blob.get_f32("lerp_factor");
    u8 fluctuation_frequency = blob.get_u8("fluctuation_frequency");
    u8 fluctuation_type = blob.get_u8("fluctuation_type");
    f32 max_fluctuation = blob.get_f32("max_fluctuation");

    f32 hover_time = blob.get_f32("hover_time");
    f32 hover_time_target = blob.get_f32("hover_time_target");
    f32 hover_time_rnd = blob.get_f32("hover_time_rnd");
    f32 hover_time_target_rnd = blob.get_f32("hover_time_target_rnd");
    f32 current_random = blob.get_f32("current_random");
    f32 opacity_factor = blob.get_f32("opacity_factor");
    f32 opacity_factor_with_random = blob.get_f32("opacity_factor_with_random");

    if (hover)
    {
        hover_time_target = Maths::Max(0, hover_time_target - 1);
        hover_time_target_rnd = Maths::Max(0, hover_time_target_rnd - 1);
    }
    else
    {
        hover_time_target = Maths::Min(max_hover_time, hover_time_target + 1);
        hover_time_target_rnd = Maths::Min(max_hover_time, hover_time_target_rnd + 1);
    }

    if (getGameTime() % fluctuation_frequency == 0)
    {
        switch (fluctuation_type)
        {
            case 1:
                current_random = XORRandom(max_fluctuation * 100 * opacity_factor) * 0.01f;
                break;
            default:
                current_random = 0.0f;
                break;
        }
    }

    hover_time_rnd = Maths::Lerp(hover_time_rnd, hover_time_target_rnd + current_random * max_hover_time, lerp_factor);
    hover_time_rnd = Maths::Clamp(hover_time_rnd, 0.0f, max_hover_time);
    opacity_factor_with_random = 1.0f - (hover_time_rnd / max_hover_time);

    hover_time = Maths::Lerp(hover_time, hover_time_target, lerp_factor);
    opacity_factor = 1.0f - (hover_time / max_hover_time);

    blob.set_f32("hover_time", hover_time);
    blob.set_f32("hover_time_target", hover_time_target);
    blob.set_f32("hover_time_rnd", hover_time_rnd);
    blob.set_f32("hover_time_target_rnd", hover_time_target_rnd);
    blob.set_f32("current_random", current_random);
    blob.set_f32("opacity_factor", opacity_factor);
    blob.set_f32("opacity_factor_with_random", opacity_factor_with_random);
}
