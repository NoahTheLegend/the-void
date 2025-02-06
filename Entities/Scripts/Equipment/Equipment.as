#include "RunnerCommon.as"
#include "EquipmentCommon.as"
#include "RunnerHead.as"

// Made by GoldenGuy 

void onInit(CBlob@ this)
{
	this.Tag("equipment support");

	this.addCommandID("equip_head");
	this.addCommandID("equip_torso");
	this.addCommandID("equip_boots");
	this.addCommandID("none");

	this.addCommandID("switch_hood");
	this.addCommandID("sync");
	
	this.set_bool("wear_hood", false);
}

void onCreateInventoryMenu(CBlob@ this, CBlob@ forBlob, CGridMenu@ gridmenu)
{
	if (this.hasTag("dead")) return;
	const string name = this.getName();

	Vec2f MENU_POS = gridmenu.getUpperLeftPosition() + Vec2f(-96, 72);

	CGridMenu@ equipments = CreateGridMenu(MENU_POS+Vec2f(48, 0), this, Vec2f(1, 3), "equipment");
	CGridMenu@ extraequipments = CreateGridMenu(MENU_POS+Vec2f(0, 0), this, Vec2f(1, 3), "equipment");

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
				if (this.get_string("equipment_head") != "") head_util.SetHoverText("Unequip head gear\n");
				else head_util.SetHoverText("Equip head gear\n");
			}

			CGridButton@ torso_util = equipments.AddButton("$torsoimage$", "", this.getCommandID("equip_torso"), Vec2f(1, 1), params);
			if (torso_util !is null)
			{
				if (this.get_string("equipment_torso") != "") torso_util.SetHoverText("Unequip torso utility\n");
				else torso_util.SetHoverText("Equip torso utility\n");
			}

			CGridButton@ boots_util = equipments.AddButton("$bootsimage$", "", this.getCommandID("equip_boots"), Vec2f(1, 1), params);
			if (boots_util !is null)
			{
				if (this.get_string("equipment_boots") != "") boots_util.SetHoverText("Unequip boots utility\n");
				else boots_util.SetHoverText("Equip boots utility\n");
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
			CGridButton@ head = extraequipments.AddButton("$decor_headimage$", "", this.getCommandID("switch_hood"), Vec2f(1, 1), params);
			if (head !is null)
			{
				head.SetHoverText("Hood\n");
			}

			CGridButton@ torso = extraequipments.AddButton("$decor_torsoimage$", "", this.getCommandID("none"), Vec2f(1, 1), params);
			if (torso !is null)
			{
				torso.SetHoverText("Snow suit\n");
			}

			CGridButton@ boots = extraequipments.AddButton("$decor_bootsimage$", "", this.getCommandID("none"), Vec2f(1, 1), params);
			if (boots !is null)
			{
				boots.SetHoverText("Warm boots\n");
			}
		}
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream@ params)
{
	if (cmd == this.getCommandID("equip_head") || cmd == this.getCommandID("equip_torso") || cmd == this.getCommandID("equip_boots"))
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
	else if (cmd == this.getCommandID("switch_hood"))
	{
		bool wearing_hood = this.get_bool("wear_hood");
		this.set_bool("wear_hood", !wearing_hood);

		if (this.isMyPlayer() && this.getSprite() !is null)
			this.getSprite().PlaySound("CycleInventory.ogg", 1.0f, 1.1f);
	}
}

void onDie(CBlob@ this)
{
    if (isServer())
	{
		string headname = this.get_string("equipment_head");
		string torsoname = this.get_string("equipment_torso");
		string bootsname = this.get_string("equipment_boots");

		//if (headname != "")
		//{
		//	server_CreateBlob(headname, this.getTeamNum(), this.getPosition());
		//}
		//if (torsoname != "")
		//{
		//	server_CreateBlob(torsoname, this.getTeamNum(), this.getPosition());
		//}
		//if (bootsname != "")
		//{
		//	server_CreateBlob(bootsname, this.getTeamNum(), this.getPosition());
		//}
	}
}
