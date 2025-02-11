const u8 spinup_time_small = 30;
const f32 yield_small = 1.0f;

// min value is quantity 1, max value is max quantity
// the actual time required depends on the quantity relatively to max quantity
const int[][] mat_grind_time_minmax = {
    {15, 75}
};

const string[] mat_grind = {
    "mat_stone"
};

const string[] mat_product = {
    "mat_gold"
};

// output ratio per input
const f32[][]  mat_input_output_ratio = {
    {1, 1}
};

CBlob@ FindNewGrindTarget(CBlob@ this)
{
    CInventory@ inv = this.getInventory();
    if (inv is null) return null;

    for (int i = 0; i < inv.getItemsCount(); i++)
    {
        CBlob@ item = inv.getItem(i);
        if (item is null) continue;

        for (uint i = 0; i < mat_grind.length; i++)
        {
            if (item.getName() == mat_grind[i])
            {
                return item;
            }
        }
    }

    return null;
}

bool SetNewGrindTarget(CBlob@ this, CBlob@ target)
{
    if (target is null) return false;
    string resource = target.getName();

    int grinding_index = mat_grind.find(resource);
    if (grinding_index == -1) return false;

    u16 max_quantity = target.getMaxQuantity();
    u16 current_quantity = target.getQuantity();
    f32 factor = float(current_quantity) / float(max_quantity);
    int min_time = mat_grind_time_minmax[grinding_index][0];
    int max_time = mat_grind_time_minmax[grinding_index][1];
    u16 grind_time = min_time + int((max_time - min_time) * factor);
    this.set_u16("grinding_time", grind_time);
    this.set_u16("grinding_quantity", target.getQuantity());
    this.set_u16("product_quantity", getYield(this, grinding_index) * target.getQuantity());

    this.set_u16("grinding_id", target.getNetworkID());
    this.set_string("resource", resource);
    this.set_string("product", mat_product[grinding_index]);

    return true;
}

void ResetGrindTarget(CBlob@ this)
{
    this.set_u16("grinding_time", 0);
    this.set_u16("grinding_quantity", 0);
    this.set_u16("product_quantity", 0);
    this.set_u16("grinding_id", 0);
    this.set_string("resource", "");
    this.set_string("product", "");
}

f32 getYield(CBlob@ this, int index)
{
    if (index < 0 || index >= mat_input_output_ratio.length) return 0;
    return mat_input_output_ratio[index][1] / mat_input_output_ratio[index][0];
}