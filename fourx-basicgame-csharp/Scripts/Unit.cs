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

    public static void LoadUnitScenes()
    {
        unitSceneResources = new Dictionary<Type, PackedScene> {
            { typeof(Settler), ResourceLoader.Load<PackedScene>("res://Scenes/Units/Settler.tscn") },
            { typeof(Warrior), ResourceLoader.Load<PackedScene>("res://Scenes/Units/Warrior.tscn") }
        };
    }

    public void SetCiv(Civilization civ)
    {
        this.ownerCiv = civ;
        GetNode<Sprite2D>("UnitSprite").Modulate = civ.territoryColor;
        this.ownerCiv.units.Add(this);
    }
}
