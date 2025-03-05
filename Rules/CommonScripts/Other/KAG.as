#include "Default/DefaultGUI.as"
#include "Default/DefaultLoaders.as"
#include "PrecacheTextures.as"
#include "EmotesCommon.as"
#include "CustomBlocks.as"
#include "GameplayEvents.as"

void onInit(CRules@ this)
{
	getNet().legacy_cmd = true;
	LoadDefaultMapLoaders();
	LoadDefaultGUI();
	SetupGameplayEvents(this);

	if (isServer())
	{
		getSecurity().reloadSecurity();
	}

	particles_gravity.y = 0.0f;
	sv_visiblity_scale = 1.25f;
	cc_halign = 2;
	cc_valign = 2;

	s_effects = false;

	sv_max_localplayers = 1;

	PrecacheTextures();

	//smooth shader
	Driver@ driver = getDriver();

	driver.AddShader("hq2x", 1.0f);
	driver.SetShader("hq2x", true);

	//reset var if you came from another gamemode that edits it
	SetGridMenusSize(24,2.0f,32);

	//also restart stuff
	onRestart(this);
}	

bool need_sky_check = true;
void onRestart(CRules@ this)
{
	//map borders
	CMap@ map = getMap();
	if (map !is null)
	{
		map.SetBorderFadeWidth(24.0f);
		map.SetBorderColourTop(SColor(0xff000000));
		map.SetBorderColourLeft(SColor(0xff000000));
		map.SetBorderColourRight(SColor(0xff000000));
		map.SetBorderColourBottom(SColor(0xff000000));

		//do it first tick so the map is definitely there
		//(it is on server, but not on client unfortunately)
		need_sky_check = true;

		if (!map.hasScript("RoomDetector.as"))
			 map.AddScript("RoomDetector.as");
	}
}


void onTick(CRules@ this)
{
	sv_gravity = 0; // 9.81f
	
	//TODO: figure out a way to optimise so we don't need to keep running this hook
	if (need_sky_check)
	{
		need_sky_check = false;
		CMap@ map = getMap();
		//find out if there's any solid tiles in top row
		// if not - semitransparent sky
		// if yes - totally solid, looks buggy with "floating" tiles
		bool has_solid_tiles = false;
		for(int i = 0; i < map.tilemapwidth; i++) {
			if(isSolid(map, map.getTile(i).type)) {
				has_solid_tiles = true;
				break;
			}
		}
		map.SetBorderColourTop(SColor(has_solid_tiles ? 0xff000000 : 0x80000000));
	}
}

//chat stuff!

void onEnterChat(CRules @this)
{
	if (getChatChannel() != 0) return; //no dots for team chat

	CBlob@ localblob = getLocalPlayerBlob();
	if (localblob !is null)
		set_emote(localblob, "dots", 100000);
}

void onExitChat(CRules @this)
{
	CBlob@ localblob = getLocalPlayerBlob();
	if (localblob !is null)
		set_emote(localblob, "off");
}

void onBlobCreated(CRules@ this, CBlob@ blob)
{
	if (blob is null) return;

	blob.SetMapEdgeFlags(CBlob::map_collide_none | CBlob::map_collide_nodeath);
	blob.AddScript("TeleportAtEdges.as");
}

string debug_shader_name = "lens";
bool load_debug_shader = false;

void onRender(CRules@ this)
{
	if (!isClient()) return;

	if (!load_debug_shader && getLocalPlayer() !is null)
	{
		Driver@ driver = getDriver();

		driver.AddShader(debug_shader_name, 2.0f);
		driver.SetShader(debug_shader_name, true);

		load_debug_shader = true;
		return;
	}
	
	if (load_debug_shader)
	{
		Driver@ driver = getDriver();
		if (!driver.ShaderState())
		{
			driver.ForceStartShaders();
		}
	}
}