
#include 'MaterialCommon.as'

// Use `.Tag('custom quantity')` to
// prevent the quantity from being
// set when initialized

// Remember to set the tag before
// initializing. It's only supposed
// to be set on the server-side. An
// example can be found in Material-
// Common.as

void onInit(CBlob@ this)
{
  this.AddScript("OffscreenThrottle.as");

  if (getNet().isServer())
  {
    this.server_setTeamNum(-1);

    if (this.hasTag('custom quantity'))
    {
      // Remove unused tag
      this.Untag('custom quantity');
    }
    else
    {
      this.server_SetQuantity(this.maxQuantity);
    }
  }

  CShape@ shape = this.getShape();
  if (shape !is null) shape.setDrag(0.0f);
  
  this.Tag('material');
  this.Tag("pushedByDoor");
  
  if (!this.exists("throw scale")) this.set_f32("throw scale", 1.0f);
  this.set_f32("init throw scale", this.get_f32("throw scale"));
  this.set_f32("init_mass", this.getMass());

  this.getShape().getVars().waterDragScale = 12.f;

  if (getNet().isClient())
  {
    // Force inventory icon update
    Material::updateFrame(this);
  }
  Material::updatePhysics(this);

  onQuantityChange(this, this.getQuantity());
}

void onQuantityChange(CBlob@ this, int old)
{
  if (getNet().isServer())
  {
    // Kill 0-materials
    if (this.getQuantity() == 0)
    {
      this.server_Die();
      return;
    }
  }

  if (getNet().isClient())
  {
    Material::updateFrame(this);
  }
  Material::updatePhysics(this);
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
  if (blob.hasTag('solid')) return true;
  if (blob.getShape().isStatic()) return true;

  return false;
}

void onAttach(CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint)
{
  this.setAngleDegrees(0);
  if (this.getShape().isRotationsAllowed())
  {
    this.Tag("reset_rotations");
    this.getShape().SetRotationsAllowed(false);
  }
}

void onDetach(CBlob@ this, CBlob@ detached, AttachmentPoint @attachedPoint)
{
  if (this.hasTag("reset_rotations"))
  {
    this.getShape().SetRotationsAllowed(true);
    this.Untag("reset_rotations");
  }
}

void onThisAddToInventory(CBlob@ this, CBlob@ blob)
{
  Material::updatePhysics(this);
}