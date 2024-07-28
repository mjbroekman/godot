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
}

public partial class HexTileMap : Node2D
{
	[Export]
	public int width = 100;

	[Export]
	public int height = 60;

	[Export]
	public float deepWaterLevel = 2.5f;

	[Export]
	public float shallowWaterLevel = 4f;

	[Export]
	public float beachLevel = 0.5f; // How far above the shallow water should the beach extend.

	[Export]
	public float forestPercent = 30f;
	[Export]
	public float desertPercent = 40f;
	[Export]
	public float mountainPercent = 10f;
	[Export]
	public int minIceDepth = 2;
	[Export]
	public int maxIceDepth = 5;

	// This is purely to play around with the noise and find aesthetic values
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

	public void GenerateTerrain()
	{
		float[,] noiseMap = new float[width,height];
		float[,] forestMap = new float[width,height];
		float[,] desertMap = new float[width,height];
		float[,] mountainMap = new float[width,height];

		Random r = new Random();
		int seed = r.Next(100000);
		GD.Print(seed);

		// Base Terrain (water,beach, plains)
		FastNoiseLite baseNoise = new FastNoiseLite();
		// Forest Terrain
		FastNoiseLite forestNoise = new FastNoiseLite();
		// Desert Terrain
		FastNoiseLite desertNoise = new FastNoiseLite();
		// Mountain Terrain
		FastNoiseLite mountainNoise = new FastNoiseLite();

		baseNoise.NoiseType = FastNoiseLite.NoiseTypeEnum.Perlin;
		baseNoise.Seed = seed;
		baseNoise.Frequency = 0.008f;
		baseNoise.FractalType = FastNoiseLite.FractalTypeEnum.Fbm;
		baseNoise.FractalOctaves = 4;
		baseNoise.FractalLacunarity = 2.25f;

		forestNoise.NoiseType = FastNoiseLite.NoiseTypeEnum.Cellular;
		forestNoise.Seed = seed;
		forestNoise.Frequency = 0.006f;
		forestNoise.FractalType = FastNoiseLite.FractalTypeEnum.Ridged;
		forestNoise.FractalOctaves = 5;
		forestNoise.FractalLacunarity = 4f;

		desertNoise.NoiseType = FastNoiseLite.NoiseTypeEnum.SimplexSmooth;
		desertNoise.Seed = seed;
		desertNoise.Frequency = 0.015f;
		desertNoise.FractalType = FastNoiseLite.FractalTypeEnum.Fbm;
		// desestNoise.FractalOctaves = 4;
		desertNoise.FractalLacunarity = 2f;

		mountainNoise.NoiseType = FastNoiseLite.NoiseTypeEnum.Simplex;
		mountainNoise.Seed = seed;
		mountainNoise.Frequency = 0.02f;
		mountainNoise.FractalType = FastNoiseLite.FractalTypeEnum.Ridged;
		mountainNoise.FractalOctaves = 4;
		mountainNoise.FractalLacunarity = 2f;

		float baseNoiseMax = 0f;
		float forestNoiseMax = 0f;
		float desertNoiseMax = 0f;
		float mountainNoiseMax = 0f;

		// Generate noise values
		for (int x = 0; x < width; x++)
		{
			for (int y = 0; y < height; y++)
			{
				// Base terrain
				noiseMap[x,y] = Math.Abs(baseNoise.GetNoise2D(x,y));
				if (noiseMap[x,y] > baseNoiseMax ) baseNoiseMax = noiseMap[x,y];
				// Forest terrain
				forestMap[x,y] = Math.Abs(forestNoise.GetNoise2D(x,y));
				if (forestMap[x,y] > forestNoiseMax ) forestNoiseMax = forestMap[x,y];

				// Desert terrain
				desertMap[x,y] = Math.Abs(desertNoise.GetNoise2D(x,y));
				if (desertMap[x,y] > desertNoiseMax ) desertNoiseMax = desertMap[x,y];

				// Mountain terrain
				mountainMap[x,y] = Math.Abs(desertNoise.GetNoise2D(x,y));
				if (mountainMap[x,y] > mountainNoiseMax ) mountainNoiseMax = mountainMap[x,y];
			}
		}

		// __BASE__ terrain generation (Water, Shallows, Beach, and Plains)
		List<(float Min, float Max, TerrainType Type)> terrainGenValues = new List<(float Min, float Max, TerrainType Type)>
		{
			(0f, baseNoiseMax/10f * deepWaterLevel, TerrainType.WATER),
			(baseNoiseMax/10f * deepWaterLevel, baseNoiseMax/10f * shallowWaterLevel, TerrainType.SHALLOW_WATER),
			(baseNoiseMax/10f * shallowWaterLevel, baseNoiseMax/10f * (shallowWaterLevel + beachLevel), TerrainType.BEACH),
			(baseNoiseMax/10f * (shallowWaterLevel + beachLevel), baseNoiseMax + 0.05f, TerrainType.PLAINS)
		};

		float forestGenValue = forestNoiseMax/100f * ( 100f - forestPercent );
		float desertGenValue = desertNoiseMax/100f * ( 100f- desertPercent );
		float mountainGenValue = mountainNoiseMax/100f * ( 100f - mountainPercent );

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

				if ( noiseValue > (baseNoiseMax/10f * (shallowWaterLevel + beachLevel) ) ) {
					if (forestValue > forestGenValue) {
						h.terrainType = TerrainType.FOREST;
					} else if (desertValue > desertGenValue) {
						h.terrainType = TerrainType.DESERT;
					}
				}

				if ( noiseValue > (baseNoiseMax/10f * (shallowWaterLevel) ) ) {
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
