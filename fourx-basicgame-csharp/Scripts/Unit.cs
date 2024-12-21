using Godot;
using System;
using System.Collections.Generic;

public partial class Unit : Node2D
{
    // Unit name
    public string unitName = "DEFAULT";

    public int productionRequired = -5;

    public Civilization ownerCiv = null;
    
    public static Dictionary<Type, PackedScene> unitSceneResources;
    public static Dictionary<Type, Texture2D> unitImages;

    public Vector2I unitCoords = new Vector2I();

    public int maxHealth = -5;
    public int curHealth = -5;

    public int maxMoves = -5;
    public int curMoves = -5;

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

    public static void LoadResources()
    {
        LoadUnitScenes();
        LoadUnitImages();
    }

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
