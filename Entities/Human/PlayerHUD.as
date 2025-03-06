
//human HUD

#include "ActorHUDStartPos.as";
#include "HUDComponents.as";

const string iconsFilename = "HumanIcons.png";
const int slotsSize = 6;

const string[] font_names = {
     "Sakana_8",
     "Sakana_10",
     "Sakana_12",
     "Sakana_14",
     "Sakana_18",
     "Terminus_8",
     "Terminus_10",
     "Terminus_12",
     "Terminus_14",
     "Terminus_18"
};

void onInit(CSprite@ this)
{
	this.getCurrentScript().runFlags |= Script::tick_myplayer;
	this.getCurrentScript().removeIfTag = "dead";

	CBlob@ blob = this.getBlob();
	if (blob is null) return;

	blob.set_u8("gui_HUD_slots_width", slotsSize);
	blob.set_u8("current_alpha", 255);
	InitComponents(blob);

	for (u8 i = 0; i < font_names.length; i++)
	{
		string[] parts = font_names[i].split("_");
		if (parts.length == 2)
		{
			string full_font_name = font_names[i];
			string font_name = parts[0];
			string font_size = parts[1];
			
			if (!GUI::isFontLoaded(font_name))
			{
				string font_path = CFileMatcher(full_font_name + ".ttf").getFirst();
				GUI::LoadFont(full_font_name, font_path, parseInt(font_size), true);
			}
		}
	}
}

void onTick(CBlob@ this)
{
	getHUD().HideCursor();
	UpdatePulse(this);
}

void onAttach(CBlob@ this, CBlob@ attached, AttachmentPoint@ ap)
{
	if (attached !is null)
	{
		if (attached.hasTag("sharp")) this.Tag("carrying_sharp");
		else if (attached.hasTag("weapon")) this.Tag("carrying_weapon");
	}
}

void onDetach(CBlob@ this, CBlob@ detached, AttachmentPoint@ ap)
{
	if (detached !is null)
	{
		if (detached.hasTag("sharp")) this.Untag("carrying_sharp");
		else if (detached.hasTag("weapon")) this.Untag("carrying_weapon");
	}
}

void onRender(CSprite@ this)
{
	if (g_videorecording)
		return;
		
	CBlob@ blob = getLocalPlayerBlob();
	if (blob is null) return;

	RenderComponents(this);
}

bool mouseHover(Vec2f mpos, Vec2f tl, Vec2f br)
{
	return (mpos.x >= tl.x && mpos.x <= br.x
			&& mpos.y >= tl.y && mpos.y <= br.y);
}
