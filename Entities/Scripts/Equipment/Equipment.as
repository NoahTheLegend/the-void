#include "RunnerCommon.as"
#include "EquipmentCommon.as"
#include "RunnerHead.as"
#include "CustomBlocks.as"

void onInit(CBlob@ this)
{
	this.Tag("equipment support");

	this.addCommandID("equip_head");
	this.addCommandID("equip_torso");
	this.addCommandID("equip_boots");
	this.addCommandID("none");

	this.addCommandID("switch_helmet");
	this.addCommandID("switch_flashlight");
	this.addCommandID("switch_plasmacutter");
	this.addCommandID("sync");
	
	this.set_bool("wear_helmet", true);
	this.set_bool("flashlight_enabled", false);
}

void onCreateInventoryMenu(CBlob@ this, CBlob@ forBlob, CGridMenu@ gridmenu)
{
	if (this.hasTag("dead")) return;
	const string name = this.getName();

	Vec2f MENU_POS_LEFT = gridmenu.getUpperLeftPosition() + Vec2f(-24, 72);
	Vec2f MENU_POS_RIGHT = gridmenu.getUpperLeftPosition() + Vec2f(216, 72);

	CGridMenu@ equipments = CreateGridMenu(MENU_POS_LEFT+Vec2f(0, 0), this, Vec2f(1, 3), "equipment");
	CGridMenu@ extraequipments = CreateGridMenu(MENU_POS_RIGHT+Vec2f(0, 0), this, Vec2f(1, 3), "equipment");

	int HeadFrame = 3;
	int TorsoFrame = 4;
	int BootsFrame = 5;

	string img  = "Equipment.png";
	string himg = "Equipment.png";
	string timg = "Equipment.png";
	string bimg = "Equipment.png";

	if (this.get_string("equipment_head") != "")
	{
		himg = this.get_string("equipment_head")+"_icon.png";
		HeadFrame = 3;
	}
	if (this.get_string("equipment_torso") != "")
	{
		timg = this.get_string("equipment_torso")+"_icon.png";
		TorsoFrame = 4;
	}
	if (this.get_string("equipment_boots") != "")
	{
		bimg = this.get_string("equipment_boots")+"_icon.png";
		BootsFrame = 5;
	}

	int teamnum = this.getTeamNum();
	if (teamnum > 6) teamnum = 7;

	AddIconToken("$headimage$", 	   himg, Vec2f(24, 24), 3, teamnum);
	AddIconToken("$torsoimage$",	   timg, Vec2f(24, 24), 4, teamnum);
	AddIconToken("$bootsimage$",	   bimg, Vec2f(24, 24), 5, teamnum);
	AddIconToken("$decor_headimage$",  img, Vec2f(24, 24), 0, teamnum);
	AddIconToken("$decor_torsoimage$", img, Vec2f(24, 24), 1, teamnum);
	AddIconToken("$decor_bootsimage$", img, Vec2f(24, 24), 2, teamnum);

	if (equipments !is null)
	{
		equipments.SetCaptionEnabled(false);
		equipments.deleteAfterClick = false;

		if (this !is null)
		{
			CBitStream params;
			params.write_u16(this.getNetworkID());

			CGridButton@ head_util = equipments.AddButton("$headimage$", "", this.getCommandID("equip_head"), Vec2f(1, 1), params);
			if (head_util !is null)
			{
				if (this.get_string("equipment_head") != "") head_util.SetHoverText("todo\n");
				else head_util.SetHoverText("Equip head gear\n");
			}

			CGridButton@ torso_util = equipments.AddButton("$torsoimage$", "", this.getCommandID("equip_torso"), Vec2f(1, 1), params);
			if (torso_util !is null)
			{
				if (this.get_string("equipment_torso") != "") torso_util.SetHoverText("todo\n");
				else torso_util.SetHoverText("Equip torso utility\n");
			}

			CGridButton@ boots_util = equipments.AddButton("$bootsimage$", "", this.getCommandID("equip_boots"), Vec2f(1, 1), params);
			if (boots_util !is null)
			{
				if (this.get_string("equipment_boots") != "") boots_util.SetHoverText("todo\n");
				else boots_util.SetHoverText("Equip belt utility\n");
			}
		}
	}
	if (extraequipments !is null)
	{
		extraequipments.SetCaptionEnabled(false);
		extraequipments.deleteAfterClick = false;

		CBitStream params;

		if (this !is null)
		{
			CGridButton@ head = extraequipments.AddButton("$decor_headimage$", "Spacesuit Helmet", this.getCommandID("switch_helmet"), Vec2f(1, 1), params);
			if (head !is null)
			{
				head.SetHoverText("Equip helmet\nconsumes Oxygen\n");
			}

			CGridButton@ torso = extraequipments.AddButton("$decor_torsoimage$", "Flashlight", this.getCommandID("switch_flashlight"), Vec2f(1, 1), params);
			if (torso !is null)
			{
				torso.SetHoverText("Enable flashlight\nConsumes Energy\n");
			}

			CGridButton@ boots = extraequipments.AddButton("$decor_bootsimage$", "Plasma cutter", this.getCommandID("switch_plasmacutter"), Vec2f(1, 1), params);
			if (boots !is null)
			{
				boots.SetHoverText("Pick plasma cutter (debug)\n");
			}
		}
	}
}

void onTick(CBlob@ this)
{
	if (isServer())
	{
		if ((getGameTime() + this.getNetworkID()) % 90 == 0 || this.hasTag("require_update"))
		{
			CBitStream params;
			params.write_bool(this.get_bool("wear_helmet"));
			params.write_bool(this.get_bool("flashlight_enabled"));
			this.SendCommand(this.getCommandID("sync"), params);

			this.Untag("require_update");
		}

		if (!this.isAttached())
		{
			bool flip = this.isFacingLeft();
			f32 angle = getAimAngle(this);
			f32 aim_distance = Maths::Abs((this.getAimPos() - this.getPosition()).Length());

			Vec2f hitPos;
			Vec2f dir = Vec2f(1, 0).RotateBy(angle);
			Vec2f startPos = this.getPosition();
			Vec2f endPos = startPos + dir * aim_distance;

			HitInfo@[] hitInfos;
			bool mapHit = getMap().rayCastSolid(startPos, endPos, hitPos);
			f32 length = (hitPos - startPos).Length();
			bool blobHit = getMap().getHitInfosFromRay(startPos, angle, length, this, @hitInfos);
			
			int exceed = 25;
			int tries = 0;

			while (mapHit && tries < exceed)
			{
				tries++;

				Tile tile = getMap().getTile(hitPos);
				if (isTileGlass(tile.type))
				{
					Vec2f newStartPos = hitPos + dir * 8.0f;
					mapHit = getMap().rayCastSolid(newStartPos, endPos, hitPos);
				}
				else
				{
					break;
				}
			}

			Vec2f finalPos = mapHit ? hitPos : endPos;
			if (mapHit && (hitPos - startPos).Length() < aim_distance)
			{
				finalPos = hitPos;
			}

			CBlob@ light = makeLight(this, this.get_bool("flashlight_enabled"));
			if (light !is null)
			{
				light.setPosition(Vec2f_lerp(light.getPosition(), finalPos, 0.33f));
			}
		}
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream@ params)
{
	if (cmd == this.getCommandID("sync"))
	{
		if (!isClient()) return;

		bool wearing_helmet;
		bool flashlight_enabled;
		if (!params.saferead_bool(wearing_helmet)) return;
		if (!params.saferead_bool(flashlight_enabled)) return;

		this.set_bool("wear_helmet", wearing_helmet);
		this.set_bool("flashlight_enabled", flashlight_enabled);
	}
	else if (cmd == this.getCommandID("switch_helmet"))
	{
		if (isServer())
		{
			bool wearing_helmet = this.get_bool("wear_helmet");
			this.set_bool("wear_helmet", !wearing_helmet);
			this.Tag("require_update");
		}

		if (this.isMyPlayer() && this.getSprite() !is null)
			this.getSprite().PlaySound("CycleInventory.ogg", 1.0f, 1.1f);
	}
	else if (cmd == this.getCommandID("switch_flashlight"))
	{
		if (isServer())
		{
			bool flashlight_enabled = this.get_bool("flashlight_enabled");
			this.set_bool("flashlight_enabled", !flashlight_enabled);
			this.Tag("require_update");
		}
	}
	else if (cmd == this.getCommandID("switch_plasmacutter"))
	{
		CBlob@ carried = this.getCarriedBlob();
		bool can_put_carried_to_inventory = false;
		if (isServer())
		{
			bool spawn_new_cutter = false;
			if (carried !is null)
			{
				can_put_carried_to_inventory = carried.canBePutInInventory(this);
				if (carried.getName() == "plasmacutter") carried.server_Die();
				else
				{
					if (can_put_carried_to_inventory) this.server_PutInInventory(carried);
					spawn_new_cutter = true;
				}
			}
			else spawn_new_cutter = true;

			if (spawn_new_cutter)
			{
				CBlob@ new_cutter = server_CreateBlob("plasmacutter", this.getTeamNum(), this.getPosition());
				if (new_cutter !is null)
				{
					this.server_AttachTo(new_cutter, "PICKUP");
				}
			}
		}
	}
	else if (cmd == this.getCommandID("equip_head") || cmd == this.getCommandID("equip_torso") || cmd == this.getCommandID("equip_boots"))
	{
		if (getGameTime() < this.get_u32("equipment_delay")) return;
		this.set_u32("equipment_delay", getGameTime()+5);

		u16 callerID;
		if (!params.saferead_u16(callerID)) return;
		CBlob@ caller = getBlobByNetworkID(callerID);
		if (caller is null) return;
		if (caller.get_string("equipment_torso") != "" && cmd == this.getCommandID("equip_torso"))
			removeTorso(caller, caller.get_string("equipment_torso"));
		else if (caller.get_string("equipment_boots") != "" && cmd == this.getCommandID("equip_boots"))
			removeBoots(caller, caller.get_string("equipment_boots"));
		else if (caller.get_string("equipment_head") != "" && cmd == this.getCommandID("equip_head"))
			removeHead(caller, caller.get_string("equipment_head"));

		CBlob@ item = caller.getCarriedBlob();
		if (item !is null)
		{
			string eqName = item.getName();
			if (getEquipmentType(item) == "head" && cmd == this.getCommandID("equip_head"))
			{
				addHead(caller, eqName);
				if (eqName == "default") 
					caller.set_f32(eqName+"_health", item.get_f32("health"));

				if (item.getQuantity() <= 1) item.server_Die();
				else item.server_SetQuantity(Maths::Max(item.getQuantity() - 1, 0));
			}
			else if (getEquipmentType(item) == "torso" && cmd == this.getCommandID("equip_torso") && eqName != "backpack")
			{
				addTorso(caller, eqName);
				if (eqName == "default")
					caller.set_f32(eqName+"_health", item.get_f32("health"));
				item.server_Die();
			}
			else if (getEquipmentType(item) == "boots" && cmd == this.getCommandID("equip_boots"))
			{
				addBoots(caller, eqName);
				if (eqName == "combatboots" || eqName == "carbonboots" || eqName == "wilmetboots") caller.set_f32(eqName+"_health", item.get_f32("health"));
				item.server_Die();
			}
			else if (caller.getSprite() !is null && caller.isMyPlayer()) caller.getSprite().PlaySound("NoAmmo.ogg", 1.0f);
		}

		caller.ClearMenus();
	}
}

void onDie(CBlob@ this)
{
    if (isServer())
	{
		string headname = this.get_string("equipment_head");
		string torsoname = this.get_string("equipment_torso");
		string bootsname = this.get_string("equipment_boots");

		removeLight(this);
	}
}

void removeLight(CBlob@ this)
{
	if (isServer())
	{
		CBlob@ light = getBlobByNetworkID(this.get_u16("remote_id_flashlight"));
		if (light !is null) light.server_Die();
	}
}

void onAttach(CBlob@ this, CBlob@ attached, AttachmentPoint@ attachedPoint)
{
	removeLight(this);
}

CBlob@ makeLight(CBlob@ this, bool enabled)
{
	if (isServer())
	{
		CBlob@ light = getBlobByNetworkID(this.get_u16("remote_id_flashlight"));
		if (light !is null)
		{
			if (enabled) return light; // we already have light, do nothing
			else light.server_Die(); // turn off

			return null;
		}

		if (!enabled) return null;

		CBlob@ blob = server_CreateBlobNoInit("flashlight_light");
		if (blob is null) return null;

		blob.setPosition(this.getPosition());
		blob.Init();

		blob.set_u16("remote_id_flashlight", this.getNetworkID());
		this.set_u16("remote_id_flashlight", blob.getNetworkID());

		return light;
	}

	return null;
}

f32 getAimAngle(CBlob@ this)
{
	Vec2f aimvector = this.getAimPos() - this.getInterpolatedPosition();
	f32 angle = this.isFacingLeft() ? -aimvector.Angle() : -aimvector.Angle();

	return angle;
}