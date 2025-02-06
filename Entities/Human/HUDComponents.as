// rebuilding this file resets pulse frame array, expectedly, so reinit blob after
const u8 hud_transparency = 160;
const s8 pulse_tick_delay = 2;
const u8 pulse_leading_length = 2; // how many "newest" pixels are gonna be white
const u8 pulse_leading_offset = 5; // offset, because some part is hidden under border

const u16 width = getDriver().getScreenWidth();
const u16 height = getDriver().getScreenHeight();
bool was_press = false;

void InitComponents(CBlob@ this)
{
    this.getCurrentScript().runFlags |= Script::tick_myplayer;
    
    this.set_f32("body_temperature", 0);
    frame_order = array<u8>();
    frame_order_icon = array<u8>();
    for (u8 i = 0; i < pulse_width; i++)
    {
        frame_order.push_back(i);
        frame_order_icon.push_back(0);
    }
    
    next = 0;
}

void UpdateComponents(CBlob@ this)
{

}

void RenderComponents(CSprite@ this)
{
    CBlob@ blob = this.getBlob();
    if (blob is null) return;

    CRules@ rules = getRules();
    if (rules is null) return;

    CControls@ controls = getControls();
    if (controls is null) return;

    Vec2f mpos = controls.getMouseScreenPos();

    DrawTemperature(this, blob, rules, controls, mpos);
    DrawPulse(this, blob, rules, controls, mpos);
}

bool isSlidingAtBottomLeft(bool hidden)
{
    return !(hidden ? Maths::Ceil(bl_hide_offset) == bl_area_width - bl_hidden_area_width : Maths::Floor(bl_hide_offset) == 0);
}

bool bl_hidden = false;
f32 bl_last_hidden_offset = 0;
u8 bl_last_text_alpha = 255;
f32 bl_hide_offset = 0; 

const Vec2f const_t_drawpos = Vec2f(10, height - 180);
const f32 bl_area_width = 145;
const u8 bl_hidden_area_width = 15;

const SColor color_global = SColor(255,100,100,200);
const SColor color_body = SColor(255,215,100,25);

void DrawTemperature(CSprite@ this, CBlob@ blob, CRules@ rules, CControls@ controls, Vec2f mpos)
{   // hardcoded because meh
    bl_hide_offset = Maths::Lerp(bl_last_hidden_offset, bl_hidden ? bl_area_width-bl_hidden_area_width : 0, 0.1f);
    bl_last_hidden_offset = bl_hide_offset;
    if (bl_hide_offset <= 1) bl_hide_offset = Maths::Round(bl_hide_offset);
    Vec2f t_drawpos = Vec2f(const_t_drawpos)-Vec2f(bl_hide_offset, 0);

    // bottom left corner
    Vec2f cdim = Vec2f(bl_area_width-bl_hide_offset, 200); // canvas dimensions
    Vec2f drawpos = Vec2f(-10-bl_hide_offset, height-200);
    Vec2f temperature_text_offset = drawpos+Vec2f(110, 25);
    
    bool hover = mouseHover(mpos, drawpos, Vec2f(cdim.x, height));

    if (controls.isKeyPressed(KEY_LBUTTON) || controls.isKeyPressed(KEY_RBUTTON))
    {
        if (!was_press)
        {
            if (hover) bl_hidden = !bl_hidden;
            was_press = true;
        }
    }
    else was_press = false;

    f32 global_temperature = rules.get_f32("temperature");
    f32 global_temperature_f = (global_temperature * 9.0f/5.0f) + 32.0f;
    f32 gauge_shift = Maths::Abs(global_temperature/75.0f);
    f32 gauge_offset = 25.0f + gauge_shift * 10.0f;

    global_temperature = Maths::Round(global_temperature*100)/100;
    global_temperature_f = Maths::Round(global_temperature_f*100)/100;

    // canvas
    GUI::DrawPane(Vec2f(drawpos.x, height-cdim.y+2), Vec2f(cdim.x, height+15), SColor(hud_transparency,255,255,255));

    // details
    if (cdim.x > 70)
    {
        // global temperature
        GUI::DrawPane(Vec2f(70, height-cdim.y+10), Vec2f(cdim.x-5, height-146), SColor(hud_transparency,255,255,255));
        // body temperature
        GUI::DrawPane(Vec2f(70, height-cdim.y+150), Vec2f(cdim.x-5, height-6), SColor(hud_transparency,255,255,255));
    }
    hover ? GUI::DrawPane(Vec2f(cdim.x-15, height-cdim.y+2), Vec2f(cdim.x, height)) : GUI::DrawSunkenPane(Vec2f(cdim.x-16, height-cdim.y+2), Vec2f(cdim.x+1, height));
    if (bl_hide_offset >= bl_area_width-bl_hidden_area_width-1) return;

    // indicators
    GUI::DrawPane(t_drawpos-Vec2f(10,10), t_drawpos+Vec2f(24,85)*2+Vec2f(10,10), SColor(hud_transparency,255,255,255)); // background
    GUI::DrawIcon("Thermometer.png", 2, Vec2f(24, 85*(1.0f-gauge_shift)), t_drawpos + Vec2f(0, gauge_offset+85*gauge_shift), 1.0f, 0.55f, color_global); // global temperature
    GUI::DrawIcon("Thermometer.png", 1, Vec2f(24, 85), t_drawpos, 1.0f, 1.0f, color_global); // body temperature
    GUI::DrawIcon("Thermometer.png", 0, Vec2f(24, 85), t_drawpos, 1.0f); // icon
    
    // arrows
    s8 rate = blob.get_s8("temperature_rate");
    rate = 0;
    
    u8 arrow_icon = 0;
    SColor color_arrows = SColor(255,100,100,100);
    if (rate != 0)
    {
        arrow_icon = rate < 0 ? Maths::Abs(rate)+3 : rate;
        color_arrows = rate < 0 ? color_global : color_body;
    }
    GUI::DrawIcon("WideArrows.png", arrow_icon, Vec2f(32,48), t_drawpos+Vec2f(58, 34), 1.0f, 1.0f, color_arrows); // global temperature
    
    // text
    if (bl_hide_offset > 1)
    {
        bl_last_text_alpha = 0;
        return;
    }
    u8 text_alpha = Maths::Lerp(bl_last_text_alpha, 255, 0.25f);
    bl_last_text_alpha = text_alpha;

    GUI::SetFont("CascadiaCodePL_12");
    GUI::DrawTextCentered(global_temperature+"°C", temperature_text_offset, SColor(text_alpha,255,255,255));
    GUI::DrawTextCentered(global_temperature_f+"°F", temperature_text_offset+Vec2f(0,12), SColor(text_alpha,255,255,255));
}

const Vec2f const_p_drawpos = Vec2f(const_t_drawpos)+Vec2f(135,115);
u8[] frame_order = {};
u8[] frame_order_icon = {};

const u8 pulse_width = 32;
const u8 pulse_height = 16;
const u8 widget_width = 23;
const Vec2f pulse_offset = Vec2f(16, 12);
u32 next = 0;
u8 pulse_icon = 0;
Vec2f actual_pulse_pos;

void DrawPulse(CSprite@ this, CBlob@ blob, CRules@ rules, CControls@ controls, Vec2f mpos)
{
    Vec2f p_drawpos = Vec2f(const_p_drawpos)-Vec2f(bl_hide_offset, 0);
    u32 gt = getGameTime();
    bool sliding = isSlidingAtBottomLeft(bl_hidden);
    if (sliding)
        actual_pulse_pos = p_drawpos;

    if (frame_order.size() > 0 || sliding)
    {
        if (next <= gt)
        {
            f32 hp = blob.getHealth();
            f32 inithp = blob.getInitialHealth();

            f32 hp_factor = hp/inithp;
            pulse_icon = hp_factor < 0.25f ? 3 : hp_factor < 0.5f ? 2 : hp_factor < 0.75f ? 1 : 0; // todo: make blue line as well

            //if (!sliding)
            {
                u8 latest = frame_order[frame_order.size()-1];
                frame_order.removeAt(0);
                frame_order.push_back(latest == pulse_width-1 ? 0 : latest+1);

                frame_order_icon.removeAt(0);
                frame_order_icon.push_back(pulse_icon);

                next = gt+pulse_tick_delay-(pulse_icon==3||pulse_icon==2?1:0);
            }
            actual_pulse_pos = p_drawpos;
        }
        else
        {
            actual_pulse_pos = actual_pulse_pos-Vec2f(1.0f/pulse_tick_delay, 0);
        }
    }
    for (u8 i = 0; i < frame_order.size(); i++)
    { // draw icon by one column
        bool new = i > frame_order.size() - pulse_leading_length-pulse_leading_offset;
        u16 actual_pulse_icon = (new ? frame_order_icon[i]+5 : frame_order_icon[i]) * pulse_width;
        GUI::DrawIcon("Pulse.png", actual_pulse_icon + frame_order[i], Vec2f(1, pulse_height), actual_pulse_pos+Vec2f(i*2,0)+pulse_offset, 1.0f, 1.0f, SColor(hud_transparency,255,255,255));
    }
    GUI::DrawIcon("PulseWidget.png", (pulse_icon > 2 ? Maths::Floor(gt/30)%2 : 0), Vec2f(48, 32), p_drawpos, 1.0f); // canvas icon
    //if (isClient() && isServer()) GUI::DrawText(""+blob.getHealth(), p_drawpos - Vec2f(-8, 16), SColor(255,255,255,255));
}