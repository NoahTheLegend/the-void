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

	if (b is null) return;
	f32 alpha_mod = 0.33f;

	f32 hpfactor = 255.0f - (b.getHealth() / b.getInitialHealth()) * 255.0f;
	u8 alpha = Maths::Clamp(hpfactor*alpha_mod, 0, 255);

	SColor col = SColor(alpha, 255, 55, 55);
	GUI::DrawIcon("VinjeteLight.png", 0, Vec2f(560, 368), Vec2f(0, 0), (getScreenWidth()*0.5f)/560, (getScreenHeight()*0.5f)/368, col);
}
