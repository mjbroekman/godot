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

    public bool isSelected = false;

    // Combat properties
    public int maxHealth = -5;
    public int curHealth = -5;

    // Movement properties
    public int maxMoves = -5;
    public int curMoves = -5;

    // Scene / node references
    public Area2D unitCollider;

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

    public void SetSelected()
    {
        isSelected = true;
        Sprite2D sprite = GetNode<Sprite2D>("UnitSprite");
        Color c = new Color(sprite.Modulate);
        if (sprite.Modulate == ownerCiv.territoryColor) {
            c.V = c.V - 0.25f; // Reduce 'Value' by 0.25.
            sprite.Modulate = c;
        }
    }

    public void SetDeselected()
    {
        isSelected = false;
        // Simply reset the color to the civilization color
        GetNode<Sprite2D>("UnitSprite").Modulate = ownerCiv.territoryColor;
    }

    // Override functions
    public override void _Ready()
    {
        unitCollider = GetNode<Area2D>("UnitSprite/Area2D");
    }

    public override string ToString()
    {
        return $"{unitName}";
    }

    public override void _UnhandledInput(InputEvent @event)
    {
        if (@event is InputEventMouseButton mouse && mouse.ButtonMask == MouseButtonMask.Left) {
            // Left mouse click
            var spaceState = GetWorld2D().DirectSpaceState; // needed to deal with colliders
            var point = new PhysicsPointQueryParameters2D(); // get the point that represents the mouse pointer
            point.CollideWithAreas = true;
            point.Position = GetGlobalMousePosition();
            var result = spaceState.IntersectPoint(point);
            if (result.Count > 0 && (Area2D) result[0]["collider"] == unitCollider) {
                // we are intersecting _some_ collider
                SetSelected();
                GetViewport().SetInputAsHandled();
            } else {
                SetDeselected();
            }
        }
    }
}
