#include "CTF_Structs.as";

void onInit(CRules@ this)
{
	
}

void onRender(CRules@ this)
{
	if (g_videorecording)
		return;

	CPlayer@ p = getLocalPlayer();

	if (p is null || !p.isMyPlayer()) { return; }

	string propname = "Survival spawn time " + p.getUsername();
	CBlob@ b = p.getBlob();
	if (b !is null && this.exists(propname))
	{
		u8 spawn = this.get_u8(propname);

		if (spawn != 255)
		{
			GUI::SetFont("menu");
			GUI::DrawText(getTranslatedString("Respawning in: {SEC}").replace("{SEC}", "" + spawn), Vec2f(getScreenWidth() / 2 - 70, getScreenHeight() / 3 + Maths::Sin(getGameTime() / 3.0f) * 5.0f), SColor(255, 255, 255, 55));
		}
	}
	
	//f32 blizzard_mod = 0.0f;
	//CBlob@ blizzard = getBlobByName("blizzard");
	//if (blizzard !is null) blizzard_mod = blizzard.get_f32("level");

	SColor col = SColor(20, 155, 200, 255);
	GUI::DrawIcon("VinjeteLight.png", 0, Vec2f(560, 368), Vec2f(0, 0), (getScreenWidth()*0.5f)/560, (getScreenHeight()*0.5f)/368, col);
}
