const u8 spinup_time_small = 15;
const f32 yield_small = 1.0f;
const u8 clip_time = 10;

// min value is quantity 1, max value is max quantity
// the actual time required depends on the quantity relatively to max quantity
const int[][] mat_grind_time_minmax = {
    {30, 300}
};

const string[] mat_grind = {
    "mat_stone"
};

const string[] mat_product = {
    "mat_gold"
};

// output ratio per input
const f32[][]  mat_input_output_ratio = {
    {4, 1}
};

const u16[][] mat_frames = {
    {24, 26}
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
            if (item.getName() == mat_grind[i] && item.getQuantity() >= mat_input_output_ratio[i][0])
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

    f32 yield = getYield(this, grinding_index);
    u16 required_quantity = Maths::Ceil(mat_input_output_ratio[grinding_index][0]);
    if (target.getQuantity() < required_quantity) return false;

    u16 grindable_quantity = (target.getQuantity() / required_quantity) * required_quantity;
    if (grindable_quantity < required_quantity) return false;

    u16 max_quantity = target.getMaxQuantity();
    u16 current_quantity = target.getQuantity();
    int min_time = mat_grind_time_minmax[grinding_index][0];
    int max_time = mat_grind_time_minmax[grinding_index][1];
    u16 grind_time = min_time + (max_time - min_time) * (grindable_quantity - required_quantity) / (max_quantity - required_quantity);
    this.set_u16("grinding_time", grind_time);
    this.set_u16("max_grinding_time", grind_time);
    this.set_u16("grinding_quantity", grindable_quantity);
    this.set_u16("product_quantity", Maths::Ceil(grindable_quantity * yield));
    this.set_u16("input_icon_id", mat_frames[grinding_index][0]);
    this.set_u16("output_icon_id", mat_frames[grinding_index][1]);
    this.set_u8("clip_time", clip_time);

    this.set_u16("grinding_id", target.getNetworkID());
    this.set_string("resource", resource);
    this.set_string("product", mat_product[grinding_index]);

    if (isServer())
    {
        CBitStream params;
        this.SendCommand(this.getCommandID("take_item_fx"), params);
    }

    return true;
}

void ResetGrindTarget(CBlob@ this)
{
    this.set_u16("grinding_time", 0);
    this.set_u16("max_grinding_time", 0);
    this.set_u16("grinding_quantity", 0);
    this.set_u16("product_quantity", 0);
    this.set_u16("grinding_id", 0);
    this.set_string("resource", "");
    this.set_string("product", "");
    this.set_u16("input_icon_id", 0);
    this.set_u16("output_icon_id", 0);
}

f32 getYield(CBlob@ this, int index)
{
    if (index < 0 || index >= mat_input_output_ratio.length) return 0;
    return mat_input_output_ratio[index][1] / mat_input_output_ratio[index][0];
}

void Sync(CBlob@ this, u16 pid = 0)
{
	if (!isServer()) return;

	CBitStream params;
	params.write_bool(false);
	params.write_u16(0);
	params.write_u16(this.get_u16("grinding_time"));
    params.write_u16(this.get_u16("max_grinding_time"));
	params.write_u16(this.get_u16("grinding_quantity"));
	params.write_u16(this.get_u16("product_quantity"));
	params.write_u16(this.get_u16("grinding_id"));
	params.write_string(this.get_string("resource"));
	params.write_string(this.get_string("product"));
	params.write_u16(this.get_u16("output_link_id"));
	params.write_u16(this.get_u16("failure_time"));
	params.write_u16(this.get_u16("input_icon_id"));
	params.write_u16(this.get_u16("output_icon_id"));
    params.write_u8(this.get_u8("clip_time"));

	if (pid != 0)
	{
		CPlayer@ p = getPlayerByNetworkId(pid);
		if (p !is null)
			this.server_SendCommandToPlayer(this.getCommandID("sync"), params, p);
	}

	if (pid == 0)
		this.SendCommand(this.getCommandID("sync"), params);
}

void RequestSync(CBlob@ this)
{
	if (!isClient() || getLocalPlayer() is null) return;

	CBitStream params;
	params.write_bool(true);
	params.write_u16(getLocalPlayer().getNetworkID());
	this.SendCommand(this.getCommandID("sync"), params);
}