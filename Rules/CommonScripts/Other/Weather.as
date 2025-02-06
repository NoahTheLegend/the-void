#define SERVER_ONLY
#include "WeatherCommon.as"

void onInit(CRules@ this)
{
    this.set_u16("day", 0);
    Reset(this);
}

void onRestart(CRules@ this)
{
    Reset(this);
}

void Reset(CRules@ this)
{
    temp_global = temp_mid + (XORRandom(temp_global_random+1)-temp_global_random/2);
    time_mod = 0;
    period = 0;
    blizzard_strength_factor = 1.0f;
    bias = 0;
    date_coldness = XORRandom(temp_date_deviation_max*10)/10;

    this.set_u16("day", XORRandom(356));
    this.set_f32("temperature", temp_global);
}

f32 time_mod = 0;
f32 blizzard_strength_factor = 1.0f;
f32 bias = 0;
bool newday = false;
f32 date_coldness = 0;

void onTick(CRules@ this)
{
    u32 gt = getGameTime();
    if (period >= gt) return;

    CMap@ map = getMap();
    if (map is null) return;

    f32 t = map.getDayTime();
    if (t == mdt) return;

    // date cycle
    if (t <= 0.5f)
    {
        if (newday)
        {
            this.add_u16("day", 1);
            if (this.get_u16("day") > 356) this.set_u16("day", 0);

            if (XORRandom(100) < temp_date_deviation_chance)
                date_coldness = Maths::Min(temp_date_deviation_max, date_coldness + XORRandom(temp_date_deviation*10)/10);
            else
                date_coldness = Maths::Max(0, date_coldness - XORRandom(temp_date_deviation*10)/10);

            newday = false;
        }
    }
    else newday = true;
    
    // init
    f32 temp_current = temp_global;

    bool m = t < mt; // morning end, stop decreasing temp
    bool e = t > et; // evening start, begin decreasing temp
    bool d = !m && !e; // day
    
    // time factor
	f32 time_factor = d ? (t < mdt ? 1.0f-(t-mt)/(mdt-mt) : (t-mdt)/(et-mdt)) : 1.0f; // the closer time is to midday, the lesser time_mod is
    time_mod = Maths::Clamp(time_factor, 0.0f, 1.0f);

    // other
    f32 rnd = XORRandom(temp_random*100)/100 * time_mod;

    // bias and plateau
    bias = Maths::Abs(temp_bias*time_mod*temp_max);
    bias = Maths::Abs(Maths::Max(0, bias - temp_plateau));

    // blizzard factor
    CBlob@ blizzard = getBlobByName("blizzard");
    if (blizzard !is null)
    {
        blizzard_strength_factor = 1.0f + temp_blizzard_factor * (blizzard.get_f32("level") / blizzard.get_f32("max_level"));
    }

    // calculate new temperature
    if (d) temp_current += (temp_change_amount*blizzard_strength_factor) + time_mod;
    else temp_current -= (temp_change_amount*blizzard_strength_factor) + time_mod;
    temp_current = -1.0f * Maths::Abs(temp_current);
    
    // calculate min-max
    f32 max = blizzard_strength_factor * (((temp_max + rnd) - (d?bias:0)) - date_coldness);
    f32 min = blizzard_strength_factor * ((temp_min - rnd) - date_coldness);

    // assign new step
    period = gt + (temp_change_period + XORRandom(temp_change_period_random))*30;
    temp_global = Maths::Min(max, Maths::Max(min, temp_current));
    this.set_f32("temperature", temp_global);
}

void onRender(CRules@ this)
{
    if (!(isClient() && isServer())) return;
    CMap@ map = getMap();
    if (map is null) return;

    if (getControls() is null) return;
    if (!getControls().isKeyPressed(KEY_LCONTROL)) return;

    Vec2f pos = getControls().getMouseWorldPos()+Vec2f(8, 8);
    GUI::SetFont("menu");
    GUI::DrawText("time mod | time | day: "+time_mod+" | "+map.getDayTime()+" | "+this.get_u16("day")+"\nperiod: "+period+"\nremaining: "+((period-getGameTime())/30)+"\ntemperature: "+temp_global+"\ndate coldness: "+date_coldness+"\nbias: "+bias+"\nblizzard factor: "+blizzard_strength_factor,
        Vec2f(15, 50), SColor(255, 255, 255, 25));
}