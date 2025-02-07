// Music Engine

// by blav

#define CLIENT_ONLY

const u32 min_minutes_delay = 5;
const u32 minutes_delay_rnd = 5;

void onInit(CBlob@ this)
{
	CMixer@ mixer = getMixer();
	if (mixer is null)
		return;

	this.set_bool("initialized game", false);

    setNextMusicTime(this);
    if (XORRandom(3) == 0) this.set_u32("next_music", XORRandom(60 * 30 * 1)); // randomly set first music within first minute

    this.set_u32("last_music_duration", 0);
}

void onTick(CBlob@ this)
{
	CMixer@ mixer = getMixer();
	if (mixer is null)
		return;

	if (s_gamemusic && s_musicvolume > 0.0f)
	{
		if (!this.get_bool("initialized game"))
		{
			AddGameMusic(this, mixer);
		}

		GameMusicLogic(this, mixer);
	}
	else
	{
		mixer.FadeOutAll(0.0f, 1.0f);
	}
}

//sound references with tag
void AddGameMusic(CBlob@ this, CMixer@ mixer)
{
	if (mixer is null)
		return;

	this.set_bool("initialized game", true);
	mixer.ResetMixer();

	mixer.AddTrack("the-void/Music/Tracks/Ambient.ogg",   				world_ambient);
	mixer.AddTrack("the-void/Music/Tracks/Stellar_ambient.ogg", 		world_ambient);
	mixer.AddTrack("the-void/Music/Tracks/Void_ambient_scary.ogg", 		world_ambient);
    mixer.AddTrack("the-void/Music/Tracks/FTL_Peace_0.ogg", 			world_ambient);
    mixer.AddTrack("the-void/Music/Tracks/FTL_Peace_1.ogg", 			world_ambient);
    mixer.AddTrack("the-void/Music/Tracks/FTL_Peace_2.ogg", 			world_ambient);
    mixer.AddTrack("the-void/Music/Tracks/FTL_Peace_3.ogg", 			world_ambient);

	mixer.AddTrack("the-void/Music/Tracks/Battle.ogg",  				world_battle);

	mixer.AddTrack("the-void/Music/Tracks/FTL_Scary_1.ogg", 			world_tension);
    mixer.AddTrack("the-void/Music/Tracks/FTL_Scary_2.ogg", 			world_tension);
    mixer.AddTrack("the-void/Music/Tracks/FTL_Scary_3.ogg", 			world_tension);
			
    mixer.AddTrack("the-void/Music/Tracks/FTL_Scary_0.ogg", 			world_timer);
}

uint timer = 0;
void GameMusicLogic(CBlob@ this, CMixer@ mixer)
{
	timer++;
	if (mixer is null)
		return;

	CRules @rules = getRules();
	u32 gameEndTime = rules.get_u32("game_end_time");
	
	if ((gameEndTime - getGameTime())/30 == 70)
	{
		mixer.FadeOutAll(0.0f, 5.0f+getRandomFadeOut(5));
	}

	int type = world_ambient;
	int score_battle = 0;
	int score_tension = 0;
	// calculate the scores here
	if (score_battle != 0 || score_tension != 0)
		type = score_battle > score_tension ? world_battle : world_tension;

	if (mixer.getPlayingCount() == 0 && getGameTime() > this.get_u32("next_music"))
	{
		mixer.FadeInRandom(type, 5.0f+getRandomFadeOut(5));
        setNextMusicTime(this);
	}

    if (mixer.getPlayingCount() != 0) this.add_u32("last_music_duration", 1);
    else if (this.get_u32("last_music_duration") > 0)
    {
        onMusicEnd(this);
        this.set_u32("last_music_duration", 0);
    }
}

void onMusicEnd(CBlob@ this)
{
    // reduce delay if the track was short
    int time_playing = this.get_u32("last_music_duration");
    if (sv_test) print("Music ended; Was playing "+time_playing+" that is "+(time_playing/30)+" seconds");
    
    int delay_reduce_threshold = 60 * 30 * 3;
    if (time_playing < delay_reduce_threshold)
    {
		int reduce_time = delay_reduce_threshold - time_playing;
        setNextMusicTime(this, reduce_time);
        if (sv_test) print("Reduced delay by "+reduce_time);
    }
}

void setNextMusicTime(CBlob@ this, int delay = 0)
{
    this.set_u32("next_music", getGameTime() + delay + getMusicDelay());
}

uint getMusicDelay()
{
    return 60 * 30 * min_minutes_delay + XORRandom(60 * 30 * minutes_delay_rnd);
}

f32 getRandomFadeOut(f32 max)
{
    return XORRandom(100) * max / 100.0f;
}

enum GameMusicTags
{
	world_ambient,
	world_battle, // fighting the bugs
	world_tension, // the ship sustained a lot of damage \ is out of electricity
	world_bugs_ambient,
	world_bugs_battle,
	world_timer,
};