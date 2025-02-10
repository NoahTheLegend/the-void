
void onInit(CBlob@ this)
{
  if (getNet().isServer())
  {
    this.set_u8("decay step", 14);
  }

  this.maxQuantity = 200;

  this.getCurrentScript().runFlags |= Script::remove_after_this;
  this.getShape().SetRotationsAllowed(true);
}
