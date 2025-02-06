#include "StatusCommon.as";

void onInit(CBlob@ this)
{
    StatusEffect@[] statuses = status_collection;
    this.set("StatusEffects", @statuses);
}

// test later