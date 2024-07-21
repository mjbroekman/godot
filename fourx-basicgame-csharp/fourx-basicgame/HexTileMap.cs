using Godot;
using System;

public partial class HexTileMap : Node2D
{
	[Export]
	public int width = 100;

	[Export]
	public int height = 60;

	TileMapLayer baseLayer, borderLayer, overlayLayer;

	// Called when the node enters the scene tree for the first time.
	public override void _Ready()
	{
		baseLayer = GetNode<TileMapLayer>("BaseLayer");
		borderLayer = GetNode<TileMapLayer>("HexBorderLayer");
		overlayLayer = GetNode<TileMapLayer>("SelectionOverlayLayer");

		GenerateTerrain();	
	}

	// Called every frame. 'delta' is the elapsed time since the previous frame.
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

	public Vector2 MapToLocal(Vector2I coords)
	{
		return baseLayer.MapToLocal(coords);
	}
}
