
void onInit(CBlob@ this)
{
    this.set_string("inv_name", this.getInventoryName());

    this.getCurrentScript().tickFrequency = 30;
}

void onTick(CBlob@ this)
{
    this.setInventoryName(this.get_string("inv_name") + " (" + this.getQuantity() + ")");
}