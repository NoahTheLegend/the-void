
//human HUD

#include "ActorHUDStartPos.as";
#include "HUDComponents.as";

const string iconsFilename = "HumanIcons.png";
const int slotsSize = 6;

const u8[] font_sizes = {14,18,12,10,13};
const string[] font_names = {"RockwellMT", "RockwellMT-Bold", "CascadiaCodePL", "CascadiaCodePL", "CascadiaCodePL-Bold"};

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
		if (!GUI::isFontLoaded(font_names[i]+"_"+font_sizes[i]))
		{
			string font = CFileMatcher(font_names[i]+".ttf").getFirst();
			GUI::LoadFont(font_names[i]+"_"+font_sizes[i], font, font_sizes[i], true);
		}
	}
}

void onTick(CBlob@ this)
{
	getHUD().HideCursor();
	UpdateComponents(this);
}

void onAttach(CBlob@ this, CBlob@ attached, AttachmentPoint@ ap)
{
	if (attached !is null)
	{
		if (attached.hasTag("sharp")) this.Tag("carrying_sharp");
		else if (attached.hasTag("pickaxe")) this.Tag("carrying_pickaxe");
		else if (attached.hasTag("axe")) this.Tag("carrying_axe");
	}
}

void onDetach(CBlob@ this, CBlob@ detached, AttachmentPoint@ ap)
{
	if (detached !is null)
	{
		if (detached.hasTag("sharp")) this.Untag("carrying_sharp");
		else if (detached.hasTag("pickaxe")) this.Untag("carrying_pickaxe");
		else if (detached.hasTag("axe")) this.Untag("carrying_axe");
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