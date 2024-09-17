using Godot;
using System;
using System.Collections.Generic;
using System.Linq;

// Order the ENUM values so that they align with the order in the tileset
public enum TerrainType { PLAINS, WATER, DESERT, MOUNTAIN, BEACH, SHALLOW_WATER, ICE, FOREST }
//                          0,0    1,0     0,1     1,1      0,2      1,2         0,3    1,3

public class Hex
{
	public readonly Vector2I coordinates;
	public TerrainType terrainType;

	public Hex(Vector2I coords)
	{
		this.coordinates = coords;
	}

	public override string ToString()
	{
		return $"Coordinates ({this.coordinates.X}, {this.coordinates.Y}): TerrainType ({this.terrainType})";
	}
}

public partial class HexTileMap : Node2D
{
	[ExportCategory("Map Size")]
	[Export]
	public int width = 100;
	[Export]
	public int height = 60;
	[Export]

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

	// Map data
	TileMapLayer baseLayer, borderLayer, overlayLayer;

	Dictionary<Vector2I, Hex> mapData = new Dictionary<Vector2I, Hex>();
	Dictionary<TerrainType, Vector2I> terrainTextures = new Dictionary<TerrainType, Vector2I>();

	public override void _Ready()
	{
		baseLayer = GetNode<TileMapLayer>("BaseLayer");
		borderLayer = GetNode<TileMapLayer>("HexBorderLayer");
		overlayLayer = GetNode<TileMapLayer>("SelectionOverlayLayer");

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

		// Initialize map data
		foreach (TerrainType terrain in Enum.GetValues<TerrainType>())
		{
			// Convert the ENUM value to the tile location since we have a simple 2 column tile set
			Vector2I tileLocation = new Vector2I((int)terrain%2,(int)terrain/2);
			terrainTextures.Add(terrain, tileLocation);
			// GD.Print(terrain , (int)terrain%2,(int)terrain/2);
		}
		GenerateTerrain();	
	}

	public override void _Process(double delta)
	{
	}

	// Handle input that is not handled by other UI elements
	public override void _UnhandledInput(InputEvent @event)
	{
		if (@event is InputEventMouseButton mouse) {
			// Only trigger on mouse button _press_ and only for the left mouse button
			// Without the IsPressed, this will trigger on press AND release of a mouse button
			// Without the ButtonIndex check, this will trigger on any button OR mouse wheel scroll
			if (mouse.IsPressed() && (int)mouse.ButtonIndex == 1) {
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
				if ((mapCoords.X >= 0) && (mapCoords.X < width)) {
					if ((mapCoords.Y >= 0) &&( mapCoords.Y < height))
					{
						GD.Print(mapData[mapCoords]);
					}
				}
			}
		}
	}

	public void GenerateTerrain()
	{
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
				float noiseValue = noiseMap[x,y];
				float forestValue = forestMap[x,y];
				float desertValue = desertMap[x,y];
				float mountainValue = mountainMap[x,y];

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
	public Vector2 MapToLocal(Vector2I coords)
	{
		return baseLayer.MapToLocal(coords);
	}
}
