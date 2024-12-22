using Godot;
using System;
using System.Collections.Generic;

public partial class Unit : Node2D
{
    // Static lookup dictionaries
    public static Dictionary<Type, PackedScene> unitSceneResources;
    public static Dictionary<Type, Texture2D> unitImages;

    // Basic properties: name, cost, owner, position
    public string unitName = "DEFAULT";

    public int productionRequired = -5;

    public Civilization ownerCiv = null;
    
    public Vector2I unitCoords = new Vector2I();

    // Combat properties
    public int maxHealth = -5;
    public int curHealth = -5;

    // Movement properties
    public int maxMoves = -5;
    public int curMoves = -5;

    // Static functions for initializing lookups
    public static void LoadUnitScenes()
    {
        unitSceneResources = new Dictionary<Type, PackedScene> {
            { typeof(Settler), ResourceLoader.Load<PackedScene>("res://Scenes/Units/Settler.tscn") },
            { typeof(Warrior), ResourceLoader.Load<PackedScene>("res://Scenes/Units/Warrior.tscn") }
        };
    }

    public static void LoadUnitImages()
    {
        unitImages = new Dictionary<Type, Texture2D> {
            { typeof(Settler), ResourceLoader.Load<Texture2D>("res://Textures/Units/settler_image.png") },
            { typeof(Warrior), ResourceLoader.Load<Texture2D>("res://Textures/Units/warrior_image.jpg") }
        };
    }

    // Single-call loader
    public static void LoadResources()
    {
        LoadUnitScenes();
        LoadUnitImages();
    }
    //
    // End of static functions

    public void SetCiv(Civilization civ)
    {
        this.ownerCiv = civ;
        GetNode<Sprite2D>("UnitSprite").Modulate = civ.territoryColor;
        this.ownerCiv.units.Add(this);
    }

    public override string ToString()
    {
        return $"{unitName}";
    }

}
