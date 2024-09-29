using Godot;
using System;
using System.Collections.Generic;

public partial class TerrainTileUI : Panel
{
    public static Dictionary<TerrainType, string> terrainTypeStrings = new Dictionary<TerrainType, string>
    {
        { TerrainType.PLAINS, "Plains" },
        { TerrainType.BEACH, "Beach" },
        { TerrainType.WATER, "Deep Water" },
        { TerrainType.DESERT, "Desert" },
        { TerrainType.MOUNTAIN, "Mountains" },
        { TerrainType.SHALLOW_WATER, "Shallow Water" },
        { TerrainType.ICE, "Ice" },
        { TerrainType.FOREST, "Forest" }
    };

    public static Dictionary<TerrainType, Texture2D> terrainTextures = new();
    
    public static void LoadTerrainTextures()
    {
        terrainTextures = new Dictionary<TerrainType, Texture2D>{
            { TerrainType.PLAINS, ResourceLoader.Load("res://Textures/Terrain/plains.jpg") as Texture2D },
            { TerrainType.BEACH, ResourceLoader.Load("res://Textures/Terrain/beach.jpg") as Texture2D },
            { TerrainType.WATER, ResourceLoader.Load("res://Textures/Terrain/ocean.jpg") as Texture2D },
            { TerrainType.DESERT, ResourceLoader.Load("res://Textures/Terrain/desert.jpg") as Texture2D },
            { TerrainType.MOUNTAIN, ResourceLoader.Load("res://Textures/Terrain/mountain.jpg") as Texture2D },
            { TerrainType.SHALLOW_WATER, ResourceLoader.Load("res://Textures/Terrain/shallow.jpg") as Texture2D },
            { TerrainType.ICE, ResourceLoader.Load("res://Textures/Terrain/ice.jpg") as Texture2D },
            { TerrainType.FOREST, ResourceLoader.Load("res://Textures/Terrain/forest.jpg") as Texture2D }
        };
    }

    Hex hexObj = null;
    // UI Components
    TextureRect terrainImage;
    Label terrainLabel, foodLabel, prodLabel;

    public override void _Ready()
    {
        terrainImage = GetNode<TextureRect>("TerrainUIBox/TerrainImage");
        terrainLabel = GetNode<Label>("TerrainUIBox/TerrainLabel");
        foodLabel = GetNode<Label>("TerrainUIBox/FoodLabel");
        prodLabel = GetNode<Label>("TerrainUIBox/ProductionLabel");
    }

    public void SetHex(Hex hex)
    {
        // Save the hex
        this.hexObj = hex;
        // Set label text
        foodLabel.Text = $"Food: {hex.foodValue}";
        prodLabel.Text = $"Production: {hex.productionValue}";
        terrainLabel.Text = $"Terrain: {terrainTypeStrings[hex.terrainType]} ({hex.coordinates.X}, {hex.coordinates.Y})";
        terrainImage.Texture = terrainTextures[hex.terrainType];
    }
}
