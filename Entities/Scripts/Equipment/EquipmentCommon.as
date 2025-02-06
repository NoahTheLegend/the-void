
string getEquipmentType(CBlob@ equipment)
{
	if (equipment.hasTag("head")) return "head";
	else if (equipment.hasTag("torso")) return "torso";
	else if (equipment.hasTag("boots")) return "boots";

	return "nugat";		//haha yes.
}

void addHead(CBlob@ playerblob, string headname)	//Here you need to add head overriding. If you dont need to override head just ignore this part of script.
{
	if (playerblob.get_string("equipment_head") == "")
	{
		if (playerblob.get_u8("override head") != 0) playerblob.set_u8("last head", playerblob.get_u8("override head"));
		else playerblob.set_u8("last head", playerblob.getHeadNum());
	}

	playerblob.Tag(headname);
	playerblob.set_string("reload_script", headname);
	playerblob.AddScript(headname+"_effect.as");

	playerblob.set_string("equipment_head", headname);
	playerblob.Tag("update head");
}

void removeHead(CBlob@ playerblob, string headname)
{
	if (playerblob.getSprite().getSpriteLayer(headname) !is null) playerblob.getSprite().RemoveSpriteLayer(headname);
	if (!playerblob.hasTag(headname)) return;
	playerblob.Untag(headname);
	if (isServer())
	{
		CBlob@ oldeq = server_CreateBlob(headname, playerblob.getTeamNum(), playerblob.getPosition());
		oldeq.set_f32("health", playerblob.get_f32(headname+"_health"));
		playerblob.server_PutInInventory(oldeq);
	}

	playerblob.set_string("equipment_head", "");
	playerblob.RemoveScript(headname+"_effect.as");
	playerblob.Tag("update head");
}

void addTorso(CBlob@ playerblob, string torsoname)			//The same stuff as in head here.
{
	playerblob.Tag(torsoname);
	playerblob.set_string("reload_script", torsoname);
	playerblob.AddScript(torsoname+"_effect.as");
	playerblob.set_string("equipment_torso", torsoname);
}

void removeTorso(CBlob@ playerblob, string torsoname)		//Same stuff with removing again.
{
	if (torsoname == "suicidevest" && playerblob.hasTag("exploding")) return;
	if (playerblob.getSprite().getSpriteLayer(torsoname) !is null)
        playerblob.getSprite().RemoveSpriteLayer(torsoname);

	if (torsoname == "backpack")
	{
		CBlob@ backpackblob = getBlobByNetworkID(playerblob.get_u16("backpack_id"));
		if (backpackblob !is null) backpackblob.server_Die();
	}

	playerblob.Untag(torsoname);
	if (isServer())
	{
		CBlob@ oldeq = server_CreateBlob(torsoname, playerblob.getTeamNum(), playerblob.getPosition());
		if (torsoname == "default") 
			oldeq.set_f32("health", playerblob.get_f32(torsoname+"_health"));
		playerblob.server_PutInInventory(oldeq);
	}
	
	playerblob.set_string("equipment_torso", "");
	playerblob.RemoveScript(torsoname+"_effect.as");
}

void addBoots(CBlob@ playerblob, string bootsname)		//You still reading this?
{
	playerblob.Tag(bootsname);
	playerblob.set_string("reload_script", bootsname);
	playerblob.AddScript(bootsname+"_effect.as");
	playerblob.set_string("equipment_boots", bootsname);
}

void removeBoots(CBlob@ playerblob, string bootsname)		//I think you should already get how this works.
{
	if (!playerblob.hasTag(bootsname)) return;
	if (bootsname == "default")
	{
		RunnerMoveVars@ moveVars;
		if (playerblob.get("moveVars", @moveVars)) moveVars.walkFactor = 1.0f;
	}

	playerblob.Untag(bootsname);
	if (isServer())
	{
		CBlob@ oldeq = server_CreateBlob(bootsname, playerblob.getTeamNum(), playerblob.getPosition());
		if (bootsname == "default")
            oldeq.set_f32("health", playerblob.get_f32(bootsname+"_health"));
		playerblob.server_PutInInventory(oldeq);		
	}
	playerblob.set_string("equipment_boots", "");
	playerblob.RemoveScript(bootsname+"_effect.as");
}