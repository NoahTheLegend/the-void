
#include "StatusCommon.as"

const int sw = getDriver().getScreenWidth();
const int sh = getDriver().getScreenHeight();

void onRender(CSprite@ this)
{
    CBlob@ blob = this.getBlob();
    if (blob is null) return;
    
    StatusEffect@[]@ stats;
    if (!blob.get("StatusEffects", @stats)) return;
}