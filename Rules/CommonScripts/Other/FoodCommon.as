
class FoodStats { // make shared later
    string name;    // inventory name
    s16 hunger;     // directly changes hunger and heat generation
    s16 saturation; // changes hunger loss
    s16 thirst;     // changes thirst 
    s8 flavour;     // directly changes sanity
    
    bool raw;
    f32 raw_factor; // from 0 to 1, consumption danger factor
    s16 quality;    // less than 100 is raw, 100 equals perfect, more than 200 is spoiled
    bool spoiled;

    FoodStats(string _name, s16 _hunger, s16 _saturation, s16 _thirst, s16 _flavour, bool _raw, s16 _quality, bool _spoiled)
    {
        name = _name;
        hunger = _hunger;
        saturation = _saturation;
        thirst = _thirst;
        flavour = _flavour;

        raw = _raw;
        quality = _quality;
        spoiled = _spoiled;
    }

    string getQualitySuffix()
    {
        return quality < 50 ? "(dangerously raw)" : quality < 100 ? "(raw)" : quality > 200 ? "(spoiled)" : "";
    }
}

FoodStats getFoodStats(string name, u8 frame)
{
    string invname = "Food";
    s16 hunger = 0;    
    s16 saturation = 0;
    s16 thirst = 0;    
    s8 flavour = 0;

    bool raw = false;
    bool spoiled = false;

    if (name.find("foodcan") != -1) // food cans, smaller ones have twice worse stats
    {
        switch (frame)
        {
            case 0: // poridge
                {invname = "Poridge";               hunger = 500; saturation = 300; thirst = 50;   flavour = 0; break;}
            case 1: // tomatoes
                {invname = "Marinated tomatoes";    hunger = 250; saturation = 100; thirst = -100; flavour = -50; break;}
            case 2: // tuna
                {invname = "Tuna";                  hunger = 350; saturation = 200; thirst = 0;    flavour = 100; break;}
            case 3: // peas
                {invname = "Peas";                  hunger = 250; saturation = 50;  thirst = -50;  flavour = 0; break;}
            case 4: // stew
                {invname = "Stew";                  hunger = 650; saturation = 500; thirst = -200; flavour = 200; break;}
            case 5: // pineapple
                {invname = "Canned pineapple";      hunger = 100; saturation = -50; thirst = 100;  flavour = 250; break;}
        }

        if (name == "foodcansmall")
        {
            hunger /= 2;
            saturation /= 2;
            thirst /= 2;
            flavour /= 2;
        }
    }

    FoodStats stats(invname, hunger, saturation, thirst, flavour, raw, 100, spoiled);
    return stats;
}

/*  f32 rawness_factor = Maths::Clamp(1.0f - quality/100, 0.0f, 1.0f);
    f32 spoiled_factor = Maths::Clamp(1.0f - Maths::Min(quality-100, 0)/100, 0.0f, 1.0f);

    if (raw)
    {
        hunger *= rawness_factor;
        saturation *= rawness_factor;
        thirst *= rawness_factor;
        flavour *= rawness_factor;
    }

    hunger *= spoiled_factor;
    saturation *= spoiled_factor;
    thirst *= spoiled_factor;
    flavour *= spoiled_factor;
*/

void initFoodStats(CBlob@ this)
{
    FoodStats stats = getFoodStats(this.getName(), this.get_u8("type"));
    this.set("FoodStats", stats);
    setFoodName(this, @stats);
}

void setFoodName(CBlob@ this, FoodStats@ stats)
{
    if (stats is null) return;
    this.setInventoryName(stats.name + stats.getQualitySuffix());
}

void emptyCanned(CBlob@ this, CBlob@ caller, u16 callerid)
{
    this.server_SetHealth(1.0f);
    this.setInventoryName("Tin can (trash)");
    this.Tag("trash");

    CBitStream params;
    params.write_bool(true);
    params.write_u16(callerid);
    params.write_string(this.getInventoryName());
    params.write_u8(this.get_u8("type")); // icon frame
    params.write_bool(this.hasTag("canned_food"));
    params.write_bool(this.hasTag("trash")); // trash

    this.SendCommand(this.getCommandID("sync"), params);

    if (caller !is null)
    {
        // todo: restore hunger here
    }
}

void playEatSound(CBlob@ this)
{
    if (!isClient()) return;

    CSprite@ sprite = this.getSprite();
    if (sprite !is null)
    {
        sprite.PlaySound(this.get_string("eat sound"), 1.0f, 0.8f+XORRandom(150)*0.001f);
    }
}