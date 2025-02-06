
//Survival gamemode logic script

#define SERVER_ONLY

const u16 day_speed = 20; // the bigger the value, the slower it is going
const u16 night_speed = 80;

#include "CTF_Structs.as";
#include "RulesCore.as";
#include "RespawnSystem.as";
//simple config function - edit the variables below to change the basics

void Config(SurvivalCore@ this)
{
	string configstr = "survival_vars.cfg";
	if (getRules().exists("survivalconfig"))
	{
		configstr = getRules().get_string("survivalconfig");
	}
	ConfigFile cfg = ConfigFile(configstr);

	//how long for the game to play out?

	this.gameDuration = 0;
	getRules().set_bool("no timer", true);

	//spawn after death time
	this.spawnTime = getTicksASecond() * 10;
}

void onTick(CRules@ this)
{
	CMap@ map = getMap();
	if (map is null) return;

	CheckForRespawn(this);

	if (this.hasTag("loading")) this.Untag("loading");

	//if (isClient() && isServer()) return;
	f32 daytime = map.getDayTime();
	this.daycycle_speed = daytime > 0.05f && daytime < 0.95f ? day_speed : night_speed;
}

void CheckForRespawn(CRules@ this)
{
	CMap@ map = getMap();
	if (map is null) return;

	f32 t = Maths::Round(map.getDayTime()*100)*0.1f;
	//printf(""+t);
	if (t == 1)
	{
		RulesCore@ core;
		this.get("core", @core);
		if (core !is null && core.respawns !is null)
		{
			for (u8 i = 0; i < getPlayersCount(); i++)
			{
				CPlayer@ p = getPlayer(i);
				if (p is null || p.getBlob() !is null) continue;
				core.respawns.AddPlayerToSpawn(p);
			}
		}
	}
}

//Survival spawn system

const s32 spawnspam_limit_time = 10;

shared class SurvivalSpawns : RespawnSystem
{
	SurvivalCore@ Survival_core;

	bool force;
	s32 limit;

	void SetCore(RulesCore@ _core)
	{
		RespawnSystem::SetCore(_core);
		@Survival_core = cast < SurvivalCore@ > (core);

		limit = spawnspam_limit_time;
	}

	void Update()
	{
		for (uint team_num = 0; team_num < Survival_core.teams.length; ++team_num)
		{
			CTFTeamInfo@ team = cast < CTFTeamInfo@ > (Survival_core.teams[team_num]);

			for (uint i = 0; i < team.spawns.length; i++)
			{
				CTFPlayerInfo@ info = cast < CTFPlayerInfo@ > (team.spawns[i]);

				UpdateSpawnTime(info, i);

				DoSpawnPlayer(info);
			}
		}
	}

	void UpdateSpawnTime(CTFPlayerInfo@ info, int i)
	{
		if (info !is null)
		{
			u8 spawn_property = 255;

			if (info.can_spawn_time > 0)
			{
				info.can_spawn_time--;
				spawn_property = u8(Maths::Min(250, (info.can_spawn_time / 30)));
			}

			string propname = "Survival spawn time " + info.username;

			Survival_core.rules.set_u8(propname, spawn_property);
			Survival_core.rules.SyncToPlayer(propname, getPlayerByUsername(info.username));
		}
	}

	bool SetMaterials(CBlob@ blob,  const string &in name, const int quantity)
	{
		CInventory@ inv = blob.getInventory();

		//already got them?
		if (inv.isInInventory(name, quantity))
			return false;

		//otherwise...
		inv.server_RemoveItems(name, quantity); //shred any old ones

		CBlob@ mat = server_CreateBlobNoInit(name);

		if (mat !is null)
		{
			mat.Tag('custom quantity');
			mat.Init();

			mat.server_SetQuantity(quantity);

			if (not blob.server_PutInInventory(mat))
			{
				mat.setPosition(blob.getPosition());
			}
		}

		return true;
	}

	void DoSpawnPlayer(PlayerInfo@ p_info)
	{
		if (canSpawnPlayer(p_info))
		{
			//limit how many spawn per second
			if (limit > 0)
			{
				limit--;
				return;
			}
			else
			{
				limit = spawnspam_limit_time;
			}

			CPlayer@ player = getPlayerByUsername(p_info.username); // is still connected?

			if (player is null)
			{
				RemovePlayerFromSpawn(p_info);
				return;
			}
			if (player.getTeamNum() != int(p_info.team))
			{
				player.server_setTeamNum(p_info.team);
			}

			// remove previous players blob
			if (player.getBlob() !is null)
			{
				CBlob @blob = player.getBlob();
				blob.server_SetPlayer(null);
				blob.server_Die();
			}

			if (p_info.blob_name == "") // if user is new
			{
				p_info.blob_name = "human"; //hard-set the respawn blob
			}
			CBlob@ playerBlob = SpawnPlayerIntoWorld(getSpawnLocation(p_info), p_info);

			if (playerBlob !is null)
			{
				p_info.spawnsCount++;
				RemovePlayerFromSpawn(player);

				// spawn resources
				SetMaterials(playerBlob, "mat_wood", 100);
				SetMaterials(playerBlob, "mat_stone", 100);
			}
		}
	}

	bool canSpawnPlayer(PlayerInfo@ p_info)
	{
		CTFPlayerInfo@ info = cast < CTFPlayerInfo@ > (p_info);

		if (info is null) { warn("Survival LOGIC: Couldn't get player info ( in bool canSpawnPlayer(PlayerInfo@ p_info) ) "); return false; }

		return true;
		/*
		if (force) { return true; }

		return info.can_spawn_time <= 0;*/
	}

	Vec2f getSpawnLocation(PlayerInfo@ p_info)
	{
		CBlob@[] spawns;
		getBlobsByTag("spawn", @spawns);

		CBlob@ b = spawns[XORRandom(spawns.length)];
		if (b !is null)
			return b.getPosition();

		return Vec2f(0, 0);
	}

	void RemovePlayerFromSpawn(CPlayer@ player)
	{
		RemovePlayerFromSpawn(core.getInfoFromPlayer(player));
	}

	void RemovePlayerFromSpawn(PlayerInfo@ p_info)
	{
		CTFPlayerInfo@ info = cast < CTFPlayerInfo@ > (p_info);

		if (info is null) { warn("Survival LOGIC: Couldn't get player info ( in void RemovePlayerFromSpawn(PlayerInfo@ p_info) )"); return; }

		string propname = "Survival spawn time " + info.username;

		for (uint i = 0; i < Survival_core.teams.length; i++)
		{
			CTFTeamInfo@ team = cast < CTFTeamInfo@ > (Survival_core.teams[i]);
			int pos = team.spawns.find(info);

			if (pos != -1)
			{
				team.spawns.erase(pos);
				break;
			}
		}

		Survival_core.rules.set_u8(propname, 255);   //not respawning
		Survival_core.rules.SyncToPlayer(propname, getPlayerByUsername(info.username));

		info.can_spawn_time = 0;
	}

	void AddPlayerToSpawn(CPlayer@ player)
	{
		s32 tickspawndelay = s32(Survival_core.spawnTime);

		CTFPlayerInfo@ info = cast < CTFPlayerInfo@ > (core.getInfoFromPlayer(player));

		if (info is null) { warn("Survival LOGIC: Couldn't get player info  ( in void AddPlayerToSpawn(CPlayer@ player) )"); return; }

		RemovePlayerFromSpawn(player);
		if (player.getTeamNum() == core.rules.getSpectatorTeamNum())
			return;

//		print("ADD SPAWN FOR " + player.getUsername());

		if (info.team < Survival_core.teams.length)
		{
			CTFTeamInfo@ team = cast < CTFTeamInfo@ > (Survival_core.teams[info.team]);

			info.can_spawn_time = tickspawndelay;

			info.spawn_point = player.getSpawnPoint();
			team.spawns.push_back(info);
		}
		else
		{
			error("PLAYER TEAM NOT SET CORRECTLY!");
		}
	}

	bool isSpawning(CPlayer@ player)
	{
		CTFPlayerInfo@ info = cast < CTFPlayerInfo@ > (core.getInfoFromPlayer(player));
		for (uint i = 0; i < Survival_core.teams.length; i++)
		{
			CTFTeamInfo@ team = cast < CTFTeamInfo@ > (Survival_core.teams[i]);
			int pos = team.spawns.find(info);

			if (pos != -1)
			{
				return true;
			}
		}
		return false;
	}

};

shared class SurvivalCore : RulesCore
{
	s32 warmUpTime;
	s32 gameDuration;
	s32 spawnTime;

	SurvivalSpawns@ Survival_spawns;

	SurvivalCore() {}

	SurvivalCore(CRules@ _rules, RespawnSystem@ _respawns)
	{
		super(_rules, _respawns);
	}

	void Setup(CRules@ _rules = null, RespawnSystem@ _respawns = null)
	{
		RulesCore::Setup(_rules, _respawns);
		@Survival_spawns = cast < SurvivalSpawns@ > (_respawns);
		server_CreateBlob("Entities/Meta/WARMusic.cfg");
	}

	void Update()
	{

		if (rules.isGameOver()) { return; }

		RulesCore::Update(); //update respawns
		CheckTeamWon();

	}

	//team stuff

	void AddTeam(CTeam@ team)
	{
		CTFTeamInfo t(teams.length, team.getName());
		teams.push_back(t);
	}

	void AddPlayer(CPlayer@ player, u8 team = 0, string default_config = "")
	{
		CTFPlayerInfo p(player.getUsername(), 0, "human");
		players.push_back(p);
		ChangeTeamPlayerCount(p.team, 1);
	}

	//void onPlayerDie(CPlayer@ victim, CPlayer@ killer, u8 customData)
	//{
	//	if (!rules.isMatchRunning()) { return; }
//
	//	if (victim !is null)
	//	{
	//		if (killer !is null && killer.getTeamNum() != victim.getTeamNum())
	//		{
	//			addKill(killer.getTeamNum());
	//		}
	//	}
	//}

	//checks
	void CheckTeamWon()
	{
		if (!rules.isMatchRunning()) { return; }
		//can you win Survival? :)
	}

	void addKill(int team)
	{
		if (team >= 0 && team < int(teams.length))
		{
			CTFTeamInfo@ team_info = cast < CTFTeamInfo@ > (teams[team]);
		}
	}

};

//pass stuff to the core from each of the hooks

void onInit(CRules@ this)
{
	Reset(this);
}

void onRestart(CRules@ this)
{
	Reset(this);
}

void Reset(CRules@ this)
{
	printf("Restarting rules script: " + getCurrentScriptName());
	SurvivalSpawns spawns();
	SurvivalCore core(this, spawns);
	Config(core);

	this.SetCurrentState(GAME);
	this.SetGlobalMessage("");

	this.set("core", @core);
	this.set("start_gametime", getGameTime() + core.warmUpTime);
	this.set_u32("game_end_time", getGameTime() + core.gameDuration); //for TimeToEnd.as
}