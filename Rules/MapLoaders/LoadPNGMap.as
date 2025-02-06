// loads a classic KAG .PNG map
// fileName is "" on client!

#include "BasePNGLoader.as";
#include "MinimapHook.as";

bool LoadMap(CMap@ map, const string& in fileName)
{
	getRules().Tag("loading");
	print("LOADING PNG MAP " + fileName);

	PNGLoader loader();

	MiniMap::Initialise();

	bool load = loader.loadMap(map, fileName);

	if (load)
	{
		MAP_LOAD_CALLBACK@ map_load_func;
		getRules().get("MAP_LOAD_CALLBACK", @map_load_func);
		if (map_load_func is null)
		{
			print("MAP_LOAD_CALLBACK function handle is null\n");
		}
		else
		{
			map_load_func(map.tilemapwidth, map.tilemapheight);
		}
	}
	
	return load;
}