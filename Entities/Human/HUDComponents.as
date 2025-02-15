const u8 hud_transparency = 160;
const s8 pulse_tick_delay = 2;
const u8 pulse_leading_length = 2; // how many of the "newest" pixels are white
const u8 pulse_leading_offset = 5; // offset, because some part is hidden under frame border

const u16 width = getDriver().getScreenWidth();
const u16 height = getDriver().getScreenHeight();
bool was_press = false;

const SColor color_global = SColor(255,100,100,200);
const SColor color_body = SColor(255,215,100,25);

const Vec2f const_drawpos = Vec2f(0, height - 96);
u8[] frame_order = {};
u8[] frame_order_icon = {};

const u8 pulse_width = 32;
const u8 pulse_height = 16;
const Vec2f pulse_offset = Vec2f(16, 12);
u32 next = 0;
u8 pulse_icon = 0;
Vec2f actual_pulse_pos;

void InitComponents(CBlob@ this)
{
    this.getCurrentScript().runFlags |= Script::tick_myplayer;
    
    frame_order = array<u8>();
    frame_order_icon = array<u8>();
    for (u8 i = 0; i < pulse_width; i++)
    {
        frame_order.push_back(i);
        frame_order_icon.push_back(0);
    }
    
    next = 0;
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
    DrawHUD(this, blob, rules, controls, mpos);
}

void DrawHUD(CSprite@ this, CBlob@ blob, CRules@ rules, CControls@ controls, Vec2f mpos)
{
    u32 gt = getGameTime();
    Vec2f drawpos = Vec2f(const_drawpos);

    DrawPulse(this, blob, rules, controls, mpos, drawpos + Vec2f(4,29.5f));

    u8 icon = (pulse_icon > 2 ? Maths::Floor(gt/30)%2 : 0);
    GUI::DrawIcon("HUDWidget.png", icon, Vec2f(112, 48), drawpos, 1.0f);
}

void DrawPulse(CSprite@ this, CBlob@ blob, CRules@ rules, CControls@ controls, Vec2f mpos, Vec2f drawpos)
{
    u32 gt = getGameTime();
   
    if (frame_order.size() > 0)
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
            actual_pulse_pos = drawpos;
        }
        else
        {
            actual_pulse_pos = actual_pulse_pos-Vec2f(1.0f/pulse_tick_delay, 0);
        }
    }
    for (u8 i = 0; i < frame_order.size(); i++)
    {
        bool new = i > frame_order.size() - pulse_leading_length-pulse_leading_offset;
        u16 actual_pulse_icon = (new ? frame_order_icon[i]+5 : frame_order_icon[i]) * pulse_width;
        GUI::DrawIcon("Pulse.png", actual_pulse_icon + frame_order[i], Vec2f(1, pulse_height), actual_pulse_pos+Vec2f(i*2,0)+pulse_offset, 1.0f, 1.0f, SColor(hud_transparency,255,255,255));
    }
}