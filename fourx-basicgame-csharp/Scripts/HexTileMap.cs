using Godot;
using System;
using System.Collections.Generic;
using System.Linq;

// Order the ENUM values so that they align with the order in the tileset
public enum TerrainType { PLAINS, WATER, DESERT, MOUNTAIN, BEACH, SHALLOW_WATER, ICE, FOREST }
//                          0,0    1,0     0,1     1,1      0,2      1,2         0,3    1,3

public class Hex
{
	public Random rng;
	public readonly Vector2I coordinates;
	private TerrainType tType;
	public bool selected = false;
	public TerrainType terrainType {
		get { return tType; }
		set { tType = value; SetResources(); }
	}

	// Can the hex be owned and, if so, who owns this city
	public bool canBelong;
	public City ownerCity;
	public bool isCityCenter;

	// Resource values
	public int foodValue;
	public int productionValue;
	public bool bonusResource = false;
	public bool bonusFoodResource = false;
	public bool bonusProdResource = false;

	// Movement values
	public int moveCost;

	public Hex(Vector2I coords)
	{
		// Set our coordinates
		this.coordinates = coords;
		// Default to being an unowned hex
		this.ownerCity = null;
		// Default to not being able to belong to a city
		this.canBelong = false;
		// Is this a city center hex
		this.isCityCenter = false;
	}

	// Set the resources for this tile when the terrain type is set
	public void SetResources()
	{
		this.canBelong = false;
		// Populate tiles with food and production and movement costs
		switch (this.terrainType)
		{
			case TerrainType.PLAINS:
				this.foodValue = rng.Next(2,7);
				this.productionValue = rng.Next(1,3);
				this.moveCost = 1;
				break;
			case TerrainType.WATER:
				this.foodValue = rng.Next(1,4);
				this.productionValue = rng.Next(0,2);
				this.moveCost = 1;
				break;
			case TerrainType.SHALLOW_WATER:
				this.foodValue = rng.Next(2,4);
				this.productionValue = rng.Next(0,2);
				this.moveCost = 1;
				break;
			case TerrainType.DESERT:
				this.foodValue = rng.Next(0,1);
				this.productionValue = rng.Next(0,3);
				this.moveCost = 2;
				break;
			case TerrainType.FOREST:
				this.foodValue = rng.Next(2,5);
				this.productionValue = rng.Next(3,6);
				this.moveCost = 2;
				break;
			case TerrainType.BEACH:
				this.foodValue = rng.Next(1,3);
				this.productionValue = rng.Next(0,2);
				this.moveCost = 2;
				break;
			case TerrainType.ICE:
				this.foodValue = rng.Next(0,1);
				this.productionValue = rng.Next(0,1);
				this.moveCost = 2;
				break;
			case TerrainType.MOUNTAIN:
				this.foodValue = rng.Next(0,1);
				this.productionValue = rng.Next(0,1);
				this.moveCost = 3;
				break;
			default:
				this.foodValue = rng.Next(0,1);
				this.productionValue = rng.Next(0,1);
				this.moveCost = 99;
				break;
		}
		
		// If we have a bonusResource, check if it is food or production
		if (this.bonusResource)
		{
			if (rng.NextDouble() > 0.5) {
				this.foodValue += 1;
				bonusFoodResource = true;
			}
			if (rng.NextDouble() > 0.5) {
				this.productionValue += 1;
				bonusProdResource = true;
			}
		}

		if (bonusFoodResource && this.foodValue < 1) this.foodValue = 1;
		if (bonusProdResource && this.productionValue < 1) this.productionValue = 1;

		// If the hex can be productive (in any way), a city can 'own' it as territory
		if (this.foodValue > 0 || this.productionValue > 0) this.canBelong = true;
	}

	public override string ToString()
	{
		string foodText = $"Food: {this.foodValue}";
		string prodText = $"Production: {this.productionValue}";
		if (this.bonusFoodResource) foodText = $"Food: {this.foodValue - 1} (+1)";
		if (this.bonusProdResource) prodText = $"Production: {this.productionValue - 1} (+1)";
		return $"({this.coordinates.X}:{this.coordinates.Y})";
		// return $"Coordinates ({this.coordinates.X}, {this.coordinates.Y}): TerrainType ({this.terrainType}) | {foodText} | {prodText} | {canBelong}";
	}
}

public partial class HexTileMap : Node2D
{
	[ExportCategory("Map Size")]
	// Map width
	[Export(PropertyHint.Range, "30,300,1,or_greater,or_less")]
	public int width = 100;
	// Map height
	[Export(PropertyHint.Range, "30,300,1,or_greater,or_less")]
	public int height = 60;
	// Chance of bonus resource
	[Export(PropertyHint.Range, "0,1,0.0001,or_greater,or_less")]
	public float bonusChance = 0.01f;
	// Minimum distance between cities
	[Export(PropertyHint.Range,"2,15,1,or_greater,or_less")]
	public int minCityRange = 3;
	// Minimum starting distance between cities
	[Export(PropertyHint.Range,"5,20,1,or_greater,or_less")]
	public int minCityStart = 5;
	// Number of starting AI civilizations
	[Export(PropertyHint.Range,"3,10,1,or_greater,or_less")]
	public int startingCivs = 6;
	// Player civilization color (set in inspector for now; can be through menu)
	[Export]
	public Color PLAYER_COLOR = new Color(0,0,0);

	[ExportCategory("Water Levels")]
	public float deepWaterLevel = 25f;
	[Export]
	public float shallowWaterLevel = 40f;
	[Export]
	public float beachLevel = 5f; // How far above the shallow water should the beach extend.

	[ExportCategory("Land Frequency")]
	[Export]
	public float forestPercent = 30f;
	[Export]
	public float desertPercent = 40f;
	[Export]
	public float mountainPercent = 10f;

	[ExportCategory("Polar Cap Size")]
	[Export]
	public int minIceDepth = 2;
	[Export]
	public int maxIceDepth = 5;

	[ExportCategory("Noise Maps")]
	[Export]
	FastNoiseLite noiseBase;
	[Export]
	FastNoiseLite noiseForest;
	[Export]
	FastNoiseLite noiseDesert;
	[Export]
	FastNoiseLite noiseMountain;

    // The ever-useful random number generator
	Random rng;

	// Map data
	TileMapLayer baseLayer, civColorLayer, borderLayer, overlayLayer;

	// Base City Color Atlas Source
	TileSetAtlasSource terrainAtlas;

	// The tile coordinates of the civColorBase
	public Vector2I civColorBase = new Vector2I(0,3);

	Hex selectedHex = null;
	Dictionary<Vector2I, Hex> mapData = new Dictionary<Vector2I, Hex>();
	Dictionary<TerrainType, Vector2I> terrainTextures = new Dictionary<TerrainType, Vector2I>();

	// Effects
	PackedScene bonusEffect;
	Node effectsNode;

	// Cities and Civilizations
	PackedScene cityScene;
	Node citiesNode;

	// Signals
	// // Signal receivers
	UIManager uiManager;

	// // C# Events
	public delegate void SendHexDataEventHandler(Hex h);
	public event SendHexDataEventHandler SendHexData;

	public delegate void RightClickOnMapEventHandler(Hex h);
	public event RightClickOnMapEventHandler RightClickOnMap;

	// // Godot Signals
	[Signal]
	public delegate void ClickOffMapEventHandler();

	[Signal]
	public delegate void DeselectHexEventHandler();

	[Signal]
	public delegate void SendCityUIInfoEventHandler(City c);
	
	// Gameplay data
	public Dictionary<Vector2I, City> cities;
	public List<Civilization> civs;

	public override void _Ready()
	{
		// Initialize the RNG
		rng = new Random();

		// Find all of our nodes
		// TileMapLayers
		baseLayer = GetNode<TileMapLayer>("BaseLayer");
		borderLayer = GetNode<TileMapLayer>("HexBorderLayer");
		civColorLayer = GetNode<TileMapLayer>("CivColorLayer");
		overlayLayer = GetNode<TileMapLayer>("SelectionOverlayLayer");

		// Tile Set Atlas
		this.terrainAtlas = civColorLayer.TileSet.GetSource(0) as TileSetAtlasSource;

		// Signal Managers
		uiManager = GetNode<UIManager>("/root/Game/UI/UICanvas/UIManager");

		// Effects animation
		effectsNode = GetNode<Node>("/root/Game/Effects");
		bonusEffect = ResourceLoader.Load<PackedScene>("res://Effects/special_resource_fx.tscn");

		// City scenes
		citiesNode = GetNode<Node>("/root/Game/Cities");
		cityScene = ResourceLoader.Load<PackedScene>("res://Scenes/City.tscn");

		// Initialize map data
		foreach (TerrainType terrain in Enum.GetValues<TerrainType>())
		{
			// Convert the ENUM value to the tile location since we have a simple 2 column tile set
			Vector2I tileLocation = new Vector2I((int)terrain%2,(int)terrain/2);
			terrainTextures.Add(terrain, tileLocation);
		}

		GenerateTerrain();

		// Set up city and civ lists
		civs = new List<Civilization>();
		cities = new Dictionary<Vector2I, City>();

		List<Vector2I> civStarts = GenerateCivStartingLocations(startingCivs + 1);

		// Generate player civilization
		Civilization playerCiv = CreatePlayerCiv(civStarts[0]);
		civStarts.RemoveAt(0);

		// Generate AI civilizations
		GenerateAICivs(civStarts);

		// Generate player civilization

		// Connect UI Signals (C# Events)
		//  Needed because 'Hex' is a raw C# class that doesn't extend from a Godot type
		//  This means that the Godot signal system doesn't recognize the 'Hex' type as
		//  a valid type.
		this.SendHexData += uiManager.SetUI;
		uiManager.EndTurn += ProcessTurn;
	}

	public Civilization CreatePlayerCiv(Vector2I start)
	{
		Civilization playerCiv = new Civilization();
		playerCiv.id = 0; // Player civ is 0; all others are greater than 0
		playerCiv.playerCiv = true;
		playerCiv.territoryColor = new Color(PLAYER_COLOR);

		int id = terrainAtlas.CreateAlternativeTile(civColorBase);
		terrainAtlas.GetTileData(civColorBase, id).Modulate = playerCiv.territoryColor;
		playerCiv.territoryColorAltTileId = id;
		civs.Add(playerCiv);

		CreateCity(playerCiv,start,"Player City");

		return playerCiv;
	}

	public void GenerateAICivs(List<Vector2I> civStarts)
	{
		for (int i = 0; i < civStarts.Count; i++) {
			Civilization currentCiv = new Civilization {
				id = i + 1,
				playerCiv = false,
				name = "AI Civilization " + (i + 1)
			};

			// Assign random color
			currentCiv.SetRandomColor();

			// Create alternative tile for civ
			int id = terrainAtlas.CreateAlternativeTile(civColorBase);
			terrainAtlas.GetTileData(civColorBase, id).Modulate = currentCiv.territoryColor;

			// Store the alt tile id in the civilization object
			currentCiv.territoryColorAltTileId = id;

			// Create starting city
			CreateCity(currentCiv, civStarts[i], "City " + civStarts[i].X);
			civs.Add(currentCiv);
		}
	}

	public void _SetupNoiseMaps()
	{
		noiseBase.NoiseType = FastNoiseLite.NoiseTypeEnum.Perlin;
		noiseBase.Frequency = 0.008f;
		noiseBase.FractalType = FastNoiseLite.FractalTypeEnum.Fbm;
		noiseBase.FractalOctaves = 4;
		noiseBase.FractalLacunarity = 2.25f;

		noiseForest.NoiseType = FastNoiseLite.NoiseTypeEnum.Cellular;
		noiseForest.Frequency = 0.006f;
		noiseForest.FractalType = FastNoiseLite.FractalTypeEnum.Ridged;
		noiseForest.FractalOctaves = 5;
		noiseForest.FractalLacunarity = 4f;

		noiseDesert.NoiseType = FastNoiseLite.NoiseTypeEnum.SimplexSmooth;
		noiseDesert.Frequency = 0.015f;
		noiseDesert.FractalType = FastNoiseLite.FractalTypeEnum.Fbm;
		noiseDesert.FractalOctaves = 4;
		noiseDesert.FractalLacunarity = 2f;

		noiseMountain.NoiseType = FastNoiseLite.NoiseTypeEnum.Simplex;
		noiseMountain.Frequency = 0.02f;
		noiseMountain.FractalType = FastNoiseLite.FractalTypeEnum.Ridged;
		noiseMountain.FractalOctaves = 4;
		noiseMountain.FractalLacunarity = 2f;
	}

	// public override void _Process(double delta)
	// {
	// }

	// Handle input that is not handled by other UI elements
	public override void _UnhandledInput(InputEvent @event)
	{
		if (@event is InputEventMouseButton mouse) {
			// Swapping comparison order... first check map boundaries, then check button so we
			//  aren't duplicating code for other button click actions...
			// Original: check mouse button -> check coords
			// New: check coords -> check mouse button
			//
			// GetGlobalMousePosition => Gets the mouse position in the _global canvas_ space
			//   Example: Vector2 global_pos = GetGlobalMousePosition();
			//            GD.Print($"Global Mouse Position = {global_pos.X}, {global_pos.Y}");
			// 
			// ToLocal => Converts coordinates to coordinates local to the node _we are calling it from_ (in this case, the HexTileMap node)
			//            This is needed in case the tilemap is not positioned beginning at 0,0... aka, it's good practice
			//   Example: Vector2 local_pos = ToLocal(global_pos);
			//            GD.Print($"HexTileMap Local Position = {local_pos.X}, {local_pos.Y}");
			//
			// baseLayer.LocalToMap => Converts _NODE local_ coordinates to _MAP LAYER_ coordinates (based on the map layer used).
			Vector2I mapCoords = baseLayer.LocalToMap(ToLocal(GetGlobalMousePosition()));
			// Make sure we are within the map boundaries before referencing the mapData
			// if ((mapCoords.X >= 0) && (mapCoords.X < width)) {
			// 	if ((mapCoords.Y >= 0) &&( mapCoords.Y < height))
			// 	{
			// 		GD.Print(mapData[mapCoords]);
			// 	}
			// }
			// Simply return if the click is outside the map boundaries.
			// Do it this way to avoid excessive nesting.
			if (!HexInBounds(mapCoords)) {
				if (mouse.ButtonMask == MouseButtonMask.Left) {
					ToggleHexSelection(selectedHex);
					selectedHex = null;
					EmitSignal(SignalName.ClickOffMap);
				}
				return;
			}
			// Only trigger on mouse button _press_ and only for the left mouse button
			// Without the IsPressed, this will trigger on press AND release of a mouse button
			// Without the ButtonIndex check, this will trigger on any button OR mouse wheel scroll
			// Original Method:  if (mouse.IsPressed() && (int)mouse.ButtonIndex == 1) {
			// New method: use mouse.ButtonMask and MouseButtonMask.<mask>
			if (mouse.ButtonMask == MouseButtonMask.Left) {
				if (selectedHex == null) {
					ToggleHexSelection(mapData[mapCoords]);
				} else if ( selectedHex != mapData[mapCoords]) {
					ToggleHexSelection(selectedHex);
					ToggleHexSelection(mapData[mapCoords]);
				} else {
					ToggleHexSelection(selectedHex);
					EmitSignal(SignalName.DeselectHex);
				}

				if (selectedHex != null)
				{
					SendHexData?.Invoke(selectedHex);
				}
			}
			if (mouse.ButtonMask == MouseButtonMask.Right) {
				RightClickOnMap?.Invoke(mapData[mapCoords]);
			}
		}
	}

	public void ToggleHexSelection(Hex targetHex)
	{
		if (targetHex == null) return;

		Vector2I coords = targetHex.coordinates;
		if (targetHex.selected) {
			// Set layer to -1 to remove the texture
			overlayLayer.SetCell(coords, -1);
			targetHex.selected = false;
			selectedHex = null;
		} else {
			overlayLayer.SetCell(coords, 0, new Vector2I(0,1));
			selectedHex = targetHex;
			targetHex.selected = true;
		}
	}

	// Specific call signature to all the Unit class to call it while sending a unit over
	public void DeselectCurrentHex(Unit u = null)
	{
		if ( selectedHex == null ) return;
		overlayLayer.SetCell(selectedHex.coordinates, -1);
		selectedHex = null;
	}

	public List<Vector2I> GenerateCivStartingLocations(int numLocations)
	{
		List<Vector2I> locations = new List<Vector2I>();

		List<Vector2I> startTiles = new List<Vector2I>();

		for (int x = 0; x < width; x++)
		{
			for (int y = 0; y < height; y++)
			{
				if (
					 mapData[new Vector2I(x, y)].terrainType == TerrainType.PLAINS ||
					 mapData[new Vector2I(x, y)].terrainType == TerrainType.FOREST
					) {
					startTiles.Add(new Vector2I(x, y));
				}
			}
		}

		for (int x = 0; x < numLocations; x++) {
			Vector2I coord = new Vector2I();
			bool valid = false;
			int loopCount = 0;

			while( !valid && loopCount < 10000)
			{
				coord = startTiles[rng.Next(startTiles.Count)];
				valid = IsValidLocation( coord, minCityStart, locations);
				loopCount++;
			}

			// Remove the tile from the plains tile list
			startTiles.Remove(coord);
			// Remove surrounding tiles from the list to shrink the plains list faster
			foreach (Hex h in GetSurroundingHexes(coord) ) {
				foreach (Hex j in GetSurroundingHexes(h) ) {
					foreach (Hex k in GetSurroundingHexes(j) ) {
						startTiles.Remove(k.coordinates);
					}
					startTiles.Remove(j.coordinates);
				}
				startTiles.Remove(coord);
			}

			if (startTiles.Count < 1) {
				GD.Print($"Ran out of potential starting locations");
				break;
			}

			if ( valid ) {
				GD.Print($"Found good location {coord.X},{coord.Y}");
				locations.Add(coord);
			}
		}
		return locations;
	}

	public bool IsValidLocation(Vector2I coord, int minDistance, List<Vector2I> locations)
	{
		// Return false if we are too close to the edge of the map
		if ( coord.X < 3 || coord.X > (width - 3) ) return false;
		if ( coord.Y < 3 || coord.Y > (height - 3) ) return false;

		// Check existing locations and return false if we are too close to another city
		foreach (Vector2I loc in locations){
			if (coord.DistanceTo(loc) < minDistance) return false;
		}
		return true;
	}

	// Function to create a single city
	public void CreateCity(Civilization civ, Vector2I coords, string name)
	{
		// GD.Print($"Spawning city {name} for {civ.name} at {coords.X} {coords.Y}");
		City newCity = cityScene.Instantiate() as City;
		// Pass a reference to the tilemap to the city
		newCity.map = this;
		// Add the city to the civilization and v.v.
		civ.cities.Add(newCity);
		newCity.civ = civ;
		// Add city to the scene tree
		citiesNode.AddChild(newCity);
		// Set coordinates (map tile + world coordinates; city center)
		newCity.cityCenterCoords = coords;
		Vector2 mapCoords = MapToGlobal(coords); 
		newCity.Position = mapCoords;
		// GD.Print($"{mapCoords} = {newCity.Position} = {newCity.GlobalPosition}");
		// GD.Print($"{newCity.sprite.Position} : {newCity.ZIndex} : {newCity.ZAsRelative}");
		mapData[coords].isCityCenter = true;
		// Set the city name (string + Label in scene)
		newCity.SetCityName(name);
		// Set color of the city to the civ color
		newCity.SetIconColor(civ.territoryColor);
		// Add starting territory to the city
		// // Add the city center hex to the city territy
		newCity.AddTerritory(mapData[coords]);
		// // Add the surrounding territory
		List<Hex> surrounding = GetSurroundingHexes(coords);
		// // need to avoid territorial conflicts with neighboring cities
		foreach (Hex sH in surrounding) {
			if (sH.ownerCity == null) newCity.AddTerritory(sH);
		}
		// Add city to map city list
		cities[coords] = newCity;
		// Paint the map
		UpdateCivTerritoryMap(civ);
	}

	// Update territory information for a civilization
	public void UpdateCivTerritoryMap(Civilization civ)
	{
		foreach (City c in civ.cities) {
			foreach (Hex h in c.territory) {
				civColorLayer.SetCell(h.coordinates, 0, civColorBase, civ.territoryColorAltTileId);
			}
		}
	}

	public void GenerateTerrain()
	{
		// Set up the noise maps
		_SetupNoiseMaps();

		float[,] noiseMap = new float[width,height];
		float[,] forestMap = new float[width,height];
		float[,] desertMap = new float[width,height];
		float[,] mountainMap = new float[width,height];

		Random r = new Random();
		int seed = r.Next(100000);
		GD.Print("Game seed: " + seed);

		noiseBase.Seed = seed;
		noiseForest.Seed = seed;
		noiseDesert.Seed = seed;
		noiseMountain.Seed = seed;

		float noiseBaseMax = 0f;
		float noiseForestMax = 0f;
		float noiseDesertMax = 0f;
		float noiseMountainMax = 0f;

		// Generate noise values
		for (int x = 0; x < width; x++)
		{
			for (int y = 0; y < height; y++)
			{
				// Base terrain
				noiseMap[x,y] = Math.Abs(noiseBase.GetNoise2D(x,y));
				if (noiseMap[x,y] > noiseBaseMax ) noiseBaseMax = noiseMap[x,y];
				// Forest terrain
				forestMap[x,y] = Math.Abs(noiseForest.GetNoise2D(x,y));
				if (forestMap[x,y] > noiseForestMax ) noiseForestMax = forestMap[x,y];

				// Desert terrain
				desertMap[x,y] = Math.Abs(noiseDesert.GetNoise2D(x,y));
				if (desertMap[x,y] > noiseDesertMax ) noiseDesertMax = desertMap[x,y];

				// Mountain terrain
				mountainMap[x,y] = Math.Abs(noiseDesert.GetNoise2D(x,y));
				if (mountainMap[x,y] > noiseMountainMax ) noiseMountainMax = mountainMap[x,y];
			}
		}

		float terrainThreshold = noiseBaseMax/100f;
		float forestThreshold = noiseForestMax/100f;
		float desertThreshold = noiseDesertMax/100f;
		float mountainThreshold = noiseMountainMax/100f;

		// __BASE__ terrain generation (Water, Shallows, Beach, and Plains)
		List<(float Min, float Max, TerrainType Type)> terrainGenValues = new List<(float Min, float Max, TerrainType Type)>
		{
			(0f, terrainThreshold * deepWaterLevel, TerrainType.WATER),
			(terrainThreshold * deepWaterLevel, terrainThreshold * shallowWaterLevel, TerrainType.SHALLOW_WATER),
			(terrainThreshold * shallowWaterLevel, terrainThreshold * (shallowWaterLevel + beachLevel), TerrainType.BEACH),
			(terrainThreshold * (shallowWaterLevel + beachLevel), noiseBaseMax + 0.05f, TerrainType.PLAINS)
		};

		// These are more simple overrides of the terrain based on their own noise map.
		// There is no need to go through the mess of making a tuple-list like with the base terrain
		float forestGenValue = forestThreshold * ( 100f - forestPercent );
		float desertGenValue = desertThreshold * ( 100f - desertPercent );
		float mountainGenValue = mountainThreshold * ( 100f - mountainPercent );

		for (int x = 0; x < width; x++)
		{
			for (int y = 0; y < height; y++)
			{
				Hex h = new Hex(new Vector2I(x,y));
				h.rng = rng;
				float noiseValue = noiseMap[x,y];
				float forestValue = forestMap[x,y];
				float desertValue = desertMap[x,y];
				float mountainValue = mountainMap[x,y];

				// Are we a specifal resource tile
				if ( rng.NextDouble() <= bonusChance ) {
					h.bonusResource = true;
				}

				h.terrainType = terrainGenValues.First(range => noiseValue >= range.Min && noiseValue < range.Max).Type;

				if ( noiseValue > (terrainThreshold * (shallowWaterLevel + beachLevel) ) ) {
					if (forestValue > forestGenValue) {
						h.terrainType = TerrainType.FOREST;
					} else if (desertValue > desertGenValue) {
						h.terrainType = TerrainType.DESERT;
					}
				}

				if ( noiseValue > (terrainThreshold * (shallowWaterLevel) ) ) {
					if ( mountainValue > mountainGenValue ) {
						h.terrainType = TerrainType.MOUNTAIN;
					}
				}

				// Add the hex to the map data
				mapData[new Vector2I(x,y)] = h;

				// baseLayer has its own map at index 0 with a bunch of different tiles
				baseLayer.SetCell(new Vector2I(x,y), 0, terrainTextures[h.terrainType]);

				// borderLayer has its own map at index 0 with only 1 "border" tile at 0,0
				borderLayer.SetCell(new Vector2I(x,y), 0, new Vector2I(0,0));

				// Generate bonus resources
				if ( h.bonusFoodResource || h.bonusProdResource ) {
					Vector2 bonusCoords = MapToGlobal(new Vector2I(x,y));
					CpuParticles2D effect = bonusEffect.Instantiate() as CpuParticles2D;
					effectsNode.AddChild(effect);
					effect.Position = bonusCoords;
				}
			}
		}

		int mapBottom = height - 1;
		for (int x = 0; x < width; x++)
		{
			for (int y = 0; y < minIceDepth; y++)
			{
				Hex hn = mapData[new Vector2I(x,y)];
				hn.terrainType = TerrainType.ICE;
				baseLayer.SetCell(new Vector2I(x,y), 0, terrainTextures[hn.terrainType]);
				Hex hs = mapData[new Vector2I(x,(mapBottom - y))];
				hs.terrainType = TerrainType.ICE;
				baseLayer.SetCell(new Vector2I(x,(mapBottom - y)), 0, terrainTextures[hs.terrainType]);
			}

			for (int y = 0; y < r.Next(maxIceDepth) + 1; y++)
			{
				Hex hn = mapData[new Vector2I(x,y)];
				if ( hn.terrainType != TerrainType.MOUNTAIN) hn.terrainType = TerrainType.ICE;
				baseLayer.SetCell(new Vector2I(x,y), 0, terrainTextures[hn.terrainType]);
			}

			for (int y = mapBottom; y > (mapBottom - r.Next(maxIceDepth) - 1); y--)
			{
				Hex hs = mapData[new Vector2I(x,y)];
				if ( hs.terrainType != TerrainType.MOUNTAIN) hs.terrainType = TerrainType.ICE;
				baseLayer.SetCell(new Vector2I(x,y), 0, terrainTextures[hs.terrainType]);
			}
		}
	}

	// Utility Functions
	public void ProcessTurn()
	{
		GD.Print("Turn Ended. Processing cities.");
		foreach (Civilization c in civs) {
			c.ProcessTurn();
			UpdateCivTerritoryMap(c);
		}

		// Refresh the UI if it is open
		uiManager.RefreshUI();

		// Update other UIs?
	}

	public Hex GetHex(Vector2I coords)
	{
		return mapData[coords];
	}

	public Vector2 MapToLocal(Vector2I coords)
	{
		return baseLayer.MapToLocal(coords);
	}

	public Vector2 MapToGlobal(Vector2I coords)
	{
		return ToGlobal(MapToLocal(coords));
	}

	public List<Hex> GetSurroundingHexes(Vector2I coords)
	{
		List<Hex> hexes = new List<Hex>();
		foreach (Vector2I coord in baseLayer.GetSurroundingCells(coords)) {
			if (HexInBounds(coord)) hexes.Add(mapData[coord]);
		}
		return hexes;
	}

	public List<Hex> GetSurroundingHexes(Hex center)
	{
		return GetSurroundingHexes(center.coordinates);
	}

	public bool HexInBounds(Vector2I coords)
	{
		if (coords.X < 0 || coords.X >= width ||
			coords.Y < 0 || coords.Y >= height) return false;
		return true;
	}
}
