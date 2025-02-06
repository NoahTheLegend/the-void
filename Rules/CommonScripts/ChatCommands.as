// Simple chat processing example.
// If the player sends a command, the server does what the command says.
// You can also modify the chat message before it is sent to clients by modifying text_out
// By the way, in case you couldn't tell, "mat" stands for "material(s)"

#include "MakeSeed.as";
#include "MakeCrate.as";
#include "MakeScroll.as";

const bool chatCommandCooldown = false; // enable if you want cooldown on your server
const uint chatCommandDelay = 3 * 30; // Cooldown in seconds
const string[] blacklistedItems = {
	"hall",         // grief
	"shark",        // grief spam
	"bison",        // grief spam
	"necromancer",  // annoying/grief
	"greg",         // annoying/grief
	"ctf_flag",     // sound spam
	"flag_base"     // sound spam + bedrock grief
};

void onInit(CRules@ this)
{
	this.addCommandID("SendChatMessage");
	this.addCommandID("teleport");
}

bool onServerProcessChat(CRules@ this, const string& in text_in, string& out text_out, CPlayer@ player)
{
	if (player is null)
		return true;

	CBlob@ blob = player.getBlob(); // now, when the code references "blob," it means the player who called the command

	if (blob is null || text_in.substr(0, 1) != "!") // dont continue if its not a command
	{
		return true;
	}

	const Vec2f pos = blob.getPosition(); // grab player position (x, y)
	const int team = blob.getTeamNum(); // grab player team number (for i.e. making all flags you spawn be your team's flags)
	const bool isMod = player.isMod();
	const string gamemode = this.gamemode_name;
	bool wasCommandSuccessful = true; // assume command is successful 
	string errorMessage = ""; // so errors can be printed out of wasCommandSuccessful is false
	SColor errorColor = SColor(255,255,0,0); // ^

	if (!isMod && this.hasScript("Survival_Rules.as") || chatCommandCooldown) // chat command cooldown timer
	{
		uint lastChatTime = 0;
		if (blob.exists("chat_last_sent"))
		{
			lastChatTime = blob.get_u16("chat_last_sent");
			if (getGameTime() < lastChatTime)
			{
				return true;
			}
		}
	}

	
	// commands that don't rely on sv_test being on (sv_test = 1)

	if (isMod)
	{
		if (text_in == "!can")
		{
			CBlob@ b = server_CreateBlobNoInit("foodcan");
			b.setPosition(blob.getPosition());

			b.set_u8("type", XORRandom(6));

			b.Init();
		}
		else if (text_in == "!bot")
		{
			AddBot("Henry");
			return true;
		}
		else if (text_in == "!debug")
		{
			CBlob@[] all;
			getBlobs(@all);

			for (u32 i = 0; i < all.length; i++)
			{
				CBlob@ blob = all[i];
				print("[" + blob.getName() + " " + blob.getNetworkID() + "] ");
			}
		}
		else if (text_in == "!endgame")
		{
			this.SetCurrentState(GAME_OVER); //go to map vote
			return true;
		}
		else if (text_in == "!startgame")
		{
			this.SetCurrentState(GAME);
			return true;
		}
	}

	// spawning things

	// these all require sv_test - no spawning without it
	// some also require the player to have mod status (!spawnwater)

	if (sv_test || isMod)
	{
		if (text_in == "!tree") // pine tree (seed)
		{
			server_MakeSeed(pos, "tree_pine", 600, 1, 16);
		}
		else if (text_in == "!weather")
		{
			CBlob@[] blobs1;
			getBlobsByName('blizzard', @blobs1);
			for (int i = 0; i < blobs1.length; i++) if (blobs1[i] !is null) blobs1[i].server_Die();
		}
		else if (text_in == "!btree") // bushy tree (seed)
		{
			server_MakeSeed(pos, "tree_bushy", 400, 2, 16);
		}
		else if (text_in == "!allarrows") // 30 normal arrows, 2 water arrows, 2 fire arrows, 1 bomb arrow (full inventory for archer)
		{
			server_CreateBlob('mat_arrows', -1, pos);
			server_CreateBlob('mat_waterarrows', -1, pos);
			server_CreateBlob('mat_firearrows', -1, pos);
			server_CreateBlob('mat_bombarrows', -1, pos);
		}
		else if (text_in == "!arrows") // 3 mats of 30 arrows (90 arrows)
		{
			for (int i = 0; i < 3; i++)
			{
				server_CreateBlob('mat_arrows', -1, pos);
			}
		}
		else if (text_in == "!allbombs") // 2 normal bombs, 1 water bomb
		{
			for (int i = 0; i < 2; i++)
			{
				server_CreateBlob('mat_bombs', -1, pos);
			}
			server_CreateBlob('mat_waterbombs', -1, pos);
		}
		else if (text_in == "!bombs") // 3 (unlit) bomb mats
		{
			for (int i = 0; i < 3; i++)
			{
				server_CreateBlob('mat_bombs', -1, pos);
			}
		}
		else if (text_in == "!spawnwater" && player.isMod())
		{
			getMap().server_setFloodWaterWorldspace(pos, true);
		}
		/*else if (text_in == "!drink") // removes 1 water tile roughly at the player's x, y, coordinates (I notice that it favors the bottom left of the player's sprite)
		{
			getMap().server_setFloodWaterWorldspace(pos, false);
		}*/
		else if (text_in == "!seed")
		{
			// crash prevention?
		}
		else if (text_in == "!crate")
		{
			client_AddToChat("usage: !crate BLOBNAME [DESCRIPTION]", SColor(255, 255, 0, 0)); //e.g., !crate shark Your Little Darling
			server_MakeCrate("", "", 0, team, Vec2f(pos.x, pos.y - 30.0f));
		}
		else if (text_in == "!coins") // adds 100 coins to the player's coins
		{
			player.server_setCoins(player.getCoins() + 100);
		}
		else if (text_in == "!coinoverload") // + 10000 coins
		{
			player.server_setCoins(player.getCoins() + 10000);
		}
		else if (text_in == "!fishyschool") // spawns 12 fishies
		{
			for (int i = 0; i < 12; i++)
			{
				server_CreateBlob('fishy', -1, pos);
			}
		}
		else if (text_in == "!chickenflock") // spawns 12 chickens
		{
			for (int i = 0; i < 12; i++)
			{
				server_CreateBlob('chicken', -1, pos);
			}
		}
		else if (text_in == "!allmats") // 500 wood, 500 stone, 50 gold
		{
			//wood
			CBlob@ wood = server_CreateBlob('mat_wood', -1, pos);
			wood.server_SetQuantity(500); // so I don't have to repeat the server_CreateBlob line again
			//stone
			CBlob@ stone = server_CreateBlob('mat_stone', -1, pos);
			stone.server_SetQuantity(500);
			//gold
			server_CreateBlob('mat_gold', -1, pos);
		}
		else if (text_in == "!woodstone") // 250 wood, 500 stone
		{
			server_CreateBlob('mat_wood', -1, pos);

			for (int i = 0; i < 2; i++)
			{
				server_CreateBlob('mat_stone', -1, pos);
			}
		}
		else if (text_in == "!stonewood") // 500 wood, 250 stone
		{
			server_CreateBlob('mat_stone', -1, pos);

			for (int i = 0; i < 2; i++)
			{
				server_CreateBlob('mat_wood', -1, pos);
			}
		}
		else if (text_in == "!wood") // 250 wood
		{
			server_CreateBlob('mat_wood', -1, pos);
		}
		else if (text_in == "!stones" || text_in == "!stone") // 250 stone
		{
			server_CreateBlob('mat_stone', -1, pos);
		}
		else if (text_in == "!gold") // 200 gold
		{
			server_CreateBlob('mat_gold', -1, pos);
		}
		// removed/commented out since this can easily be abused...
		/*else if (text_in == "!sharkpit") // spawns 5 sharks, perfect for making shark pits
		{
			for (int i = 0; i < 5; i++)
			{
				CBlob@ b = server_CreateBlob('shark', -1, pos);
			}
		}
		else if (text_in == "!bisonherd") // spawns 5 bisons
		{
			for (int i = 0; i < 5; i++)
			{
				CBlob@ b = server_CreateBlob('bison', -1, pos);
			}
		}*/
		else
		{
			string[]@ tokens = text_in.split(" ");

			if (tokens.length > 1)
			{
				//(see above for crate parsing example)
				if (tokens[0] == "!crate")
				{
					string item = tokens[1];

					if (!isMod && isBlacklisted(item))
					{
						wasCommandSuccessful = false;
						errorMessage = "blob is currently blacklisted";
					}
					else
					{
						int frame = item == "catapult" ? 1 : 0;
						string description = tokens.length > 2 ? tokens[2] : item;
						server_MakeCrate(item, description, frame, -1, Vec2f(pos.x, pos.y));
					}
				}
				else if (tokens[0]=="!time") 
				{
					if (tokens.length != 2) return false;
					getMap().SetDayTime(parseFloat(tokens[1]));
					return false;
				}
				// eg. !team 2
				else if (tokens[0] == "!team")
				{
					// Picks team color from the TeamPalette.png (0 is blue, 1 is red, and so forth - if it runs out of colors, it uses the grey "neutral" color)
					int team = parseInt(tokens[1]);
					blob.server_setTeamNum(team);
					// We should consider if this should change the player team as well, or not.
				}
				else if (tokens[0] == "!scroll")
				{
					string s = tokens[1];
					for (uint i = 2; i < tokens.length; i++)
					{
						s += " " + tokens[i];
					}
					server_MakePredefinedScroll(pos, s);
				}
				else if (tokens[0] == "!coins")
				{
					int money = parseInt(tokens[1]);
					player.server_setCoins(money);
				}
				else if (tokens[0]=="!class")
				{
					if (tokens.length!=2) return false;
					CBlob@ newBlob = server_CreateBlob(tokens[1],blob.getTeamNum(),blob.getPosition());
					if (newBlob !is null)
					{
						CInventory@ inv = blob.getInventory();
						if (inv !is null)
						{
							blob.MoveInventoryTo(newBlob);
						}
						newBlob.server_SetPlayer(player);
						blob.server_Die();
					}
				}
				else if (tokens[0]=="!leavebody")
				{
					if (tokens.length!=2) return false;
					CBlob@ newBlob = server_CreateBlob(tokens[1],blob.getTeamNum(),blob.getPosition());
					if (newBlob !is null)
					{
						CInventory@ inv = blob.getInventory();
						if (inv !is null)
						{
							blob.MoveInventoryTo(newBlob);
						}
						newBlob.server_SetPlayer(player);
						//blob.server_Die();
					}
				}
				else if ((tokens[0]=="!tp"))
				{
					if (tokens.length != 2) return false;

					CPlayer@ tpPlayer =	GetPlayer(tokens[1]);
					CBlob@ tpBlob =	tokens.length == 2 ? blob : tpPlayer !is null ? tpPlayer.getBlob() : blob;
					CPlayer@ tpDest = GetPlayer(tokens.length == 2 ? tokens[1] : tokens[2]);

					if (tpBlob !is null && tpDest !is null)
					{
						CBlob@ destBlob = tpDest.getBlob();
						if (destBlob !is null)
						{
							CBitStream params;
							params.write_u16(tpBlob.getNetworkID());
							params.write_u16(destBlob.getNetworkID());
							this.SendCommand(this.getCommandID("teleport"), params);
						}
					}
					return false;
				}
				else if (tokens[0]=="!tphere")
				{
					if (tokens.length!=2) return false;
					CPlayer@ tpPlayer=		GetPlayer(tokens[1]);
					if (tpPlayer !is null)
					{
						CBlob@ tpBlob = tpPlayer.getBlob();
						if (tpBlob !is null)
						{
							CBitStream params;
							params.write_u16(tpBlob.getNetworkID());
							params.write_u16(blob.getNetworkID());
							getRules().SendCommand(this.getCommandID("teleport"),params);
						}
					}
				}
			}
			else
			{
				string name = text_in.substr(1, text_in.size());
				if (!isMod && isBlacklisted(name))
				{
					wasCommandSuccessful = false;
					errorMessage = "blob is currently blacklisted";
				}
				else
				{
					CBlob@ newBlob = server_CreateBlob(name, team, Vec2f(0, -5) + pos); // currently any blob made will come back with a valid pointer

					if (newBlob !is null)
					{
						if (newBlob.getName() != name)  // invalid blobs will have 'broken' names
						{
							wasCommandSuccessful = false;
							errorMessage = "blob " + text_in + " not found";
						}
					}
				}
			}
		}
	}

	if (wasCommandSuccessful)
	{
		blob.set_u16("chat_last_sent", getGameTime() + chatCommandDelay);
	}
	else if(errorMessage != "") // send error message to client
	{
		CBitStream params;
		params.write_string(errorMessage);

		// List is reverse so we can read it correctly into SColor when reading
		params.write_u8(errorColor.getBlue());
		params.write_u8(errorColor.getGreen());
		params.write_u8(errorColor.getRed());
		params.write_u8(errorColor.getAlpha());

		this.SendCommand(this.getCommandID("SendChatMessage"), params, player);
	}

	return true;
}

bool onClientProcessChat(CRules@ this, const string& in text_in, string& out text_out, CPlayer@ player)
{
	CBlob@ local = getLocalPlayerBlob();
	CBlob@ pb = player.getBlob();

	// dead players can talk
	bool sender_dead = pb is null || pb.hasTag("dead");
	bool in_range = local !is null && pb !is null && inProximity(local, pb);

	// dead players can see the chat
	if (in_range || local is null)
	{
		bool add_to_chat = false;

		for (u8 i = 0; i < getPlayersCount(); i++)
		{
			CPlayer@ p = getPlayer(i);
			if (p is null) continue;

			CBlob@ b = p.getBlob();
			if (b is null || b is local) continue;

			if (inProximity(b, local))
			{
				add_to_chat = true;
				break;
			}
		}

		if (add_to_chat)
		{
			string formatted_name = "["+player.getClantag()+" "+player.getCharacterName()+"] ";
			client_AddToChat(formatted_name + textIn, SColor(255,0,0,0));

			if (!sender_dead && inProximity(local, pb)) pb.Chat(textIn);
			return false;
		}
		else
		{
			client_AddToChat("Nobody saw your message.", SColor(255,255,0,0));
		}
	}

	return true;
}

void onCommand(CRules@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("teleport"))
	{
		u16 tpBlobId, destBlobId;

		if (!params.saferead_u16(tpBlobId)) return;
		if (!params.saferead_u16(destBlobId)) return;

		CBlob@ tpBlob =	getBlobByNetworkID(tpBlobId);
		CBlob@ destBlob = getBlobByNetworkID(destBlobId);

		if (tpBlob !is null && destBlob !is null)
		{
			if (isClient())
			{
				ShakeScreen(64,32,tpBlob.getPosition());
				ParticleZombieLightning(tpBlob.getPosition());
			}

			tpBlob.setPosition(destBlob.getPosition());

			if (isClient())
			{
				ShakeScreen(64,32,destBlob.getPosition());
				ParticleZombieLightning(destBlob.getPosition());
			}
		}
	}
	else if (cmd == this.getCommandID("SendChatMessage"))
	{
		string errorMessage = params.read_string();
		SColor col = SColor(params.read_u8(), params.read_u8(), params.read_u8(), params.read_u8());
		client_AddToChat(errorMessage, col);
	}
}

bool isBlacklisted(string name)
{
	return blacklistedItems.find(name) != -1;
}

CPlayer@ GetPlayer(string username)
{
	username=			username.toLower();
	int playersAmount=	getPlayerCount();
	for (int i=0;i<playersAmount;i++)
	{
		CPlayer@ player=getPlayer(i);
		string playerName = player.getUsername().toLower();
		if (playerName==username || (username.size()>=3 && playerName.findFirst(username,0)==0)) return player;
	}
	return null;
}