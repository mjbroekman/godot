using Godot;
using System;
using System.Collections.Generic;

public enum TerrainType { PLAINS, WATER, DESERT, MOUNTAIN, BEACH, SHALLOW_WATER, ICE, FOREST }
//                          0,0    0,1     1,0     1,1      2,0      2,1         3,0     3,1

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
			Vector2I tileLocation = new Vector2I((int)terrain/2,(int)terrain%2);
			terrainTextures.Add(terrain, tileLocation);
		}
		GenerateTerrain();	
	}

	public override void _Process(double delta)
	{
	}

	public void GenerateTerrain()
	{
		for (int x = 0; x < width; x++)
		{
			for (int y = 0; y < height; y++)
			{
				// baseLayer has its own map at index 0 with a bunch of different tiles
				baseLayer.SetCell(new Vector2I(x,y), 0, new Vector2I(0,0));
				// borderLayer has its own map at index 0 with only 1 "border" tile at 0,0
				borderLayer.SetCell(new Vector2I(x,y), 0, new Vector2I(0,0));
			}
		}
	}

	// Utility Functions
	public Vector2 MapToLocal(Vector2I coords)
	{
		return baseLayer.MapToLocal(coords);
	}
}
