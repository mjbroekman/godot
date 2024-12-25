using Godot;
using System;
using System.Linq;
using System.Collections.Generic;

public partial class Unit : Node2D
{
    // Static lookup variables
    public static Dictionary<Type, PackedScene> unitSceneResources;
    public static Dictionary<Type, Texture2D> unitImages;
    public static Dictionary<Hex, List<Unit>> unitLocations;

    // Basic properties: name, cost, owner, position
    public string unitName = "DEFAULT";

    public int productionRequired = -5;

    public Civilization ownerCiv = null;
    
    private Vector2I uCoords = new Vector2I();
    public Vector2I unitCoords {
        get { return uCoords; }
		set { uCoords = value; SetPosition(value); }
    }

    public bool isSelected = false;

    // Impassable Terrains - Default land unit set
    public HashSet<TerrainType> impassable = new HashSet<TerrainType>
    {
        TerrainType.WATER,
        TerrainType.SHALLOW_WATER,
        TerrainType.ICE,
        TerrainType.MOUNTAIN,
    };

    // Signals
    [Signal]
    public delegate void UnitClickedEventHandler(Unit u);

    // Combat properties
    public int maxHealth = -5;
    public int curHealth = -5;

    // Movement properties
    public int maxMoves = -5;
    public int curMoves = -5;
    public List<Hex> validMovementHexes;

    // Scene / node references
    public Area2D unitCollider;
    public UIManager uiManager;
    public HexTileMap map;

    // Static functions for initializing lookups
    //

    // Load the unit scenes from the filesystem
    public static void LoadUnitScenes()
    {
        unitSceneResources = new Dictionary<Type, PackedScene> {
            { typeof(Settler), ResourceLoader.Load<PackedScene>("res://Scenes/Units/Settler.tscn") },
            { typeof(Warrior), ResourceLoader.Load<PackedScene>("res://Scenes/Units/Warrior.tscn") }
        };
    }

    // Load the images from the filesystem
    public static void LoadUnitImages()
    {
        unitImages = new Dictionary<Type, Texture2D> {
            { typeof(Settler), ResourceLoader.Load<Texture2D>("res://Textures/Units/settler_image.png") },
            { typeof(Warrior), ResourceLoader.Load<Texture2D>("res://Textures/Units/warrior_image.jpg") }
        };
    }

    // Initialize the Unit Locations dictionary
    public static void InitUnitLocations()
    {
        unitLocations = new Dictionary<Hex, List<Unit>>();
    }

    // Single-call loader
    public static void LoadResources()
    {
        LoadUnitScenes();
        LoadUnitImages();
        InitUnitLocations();
    }
    //
    // End of static functions

    // Setter for unitCoords... set the Position properties as well as add unit to unitLocation dictionary
    public void SetPosition(Vector2I newCoords)
    {
        this.Position = map.MapToLocal(newCoords);
        AddUnitToLocation(newCoords);
    }

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
        validMovementHexes = CalculateValidAdjacentMovementHexes();
    }

    public void SetDeselected()
    {
        isSelected = false;
        // Simply reset the color to the civilization color
        GetNode<Sprite2D>("UnitSprite").Modulate = ownerCiv.territoryColor;
        validMovementHexes.Clear();
    }

    public List<Hex> CalculateValidAdjacentMovementHexes()
    {
        List<Hex> hexes = new List<Hex>();

        hexes.AddRange(map.GetSurroundingHexes(this.unitCoords));
        hexes.Where( h => !impassable.Contains(h.terrainType)).ToList();
        hexes.Where( h => h.moveCost <= curMoves ).ToList();
        return hexes;
    }

    public void AddUnitToLocation(Vector2I location)
    {
        if ( unitLocations.ContainsKey(map.GetHex(location))) {
            unitLocations[map.GetHex(location)].Add(this);
        } else {
            unitLocations[map.GetHex(location)] = new List<Unit>{this};
        }
    }

    public bool CanMoveToHex(Hex h)
    {
        if ( ! unitLocations.ContainsKey(h)) return true;
        if ( (unitLocations.ContainsKey(h) && unitLocations[h].Count == 0) ) return true;
        if ( validMovementHexes.Contains(h) ) return true;
        return false;
    }

    public void MoveToHex(Hex h)
    {
        if (CanMoveToHex(h)) {
            unitLocations[map.GetHex(this.unitCoords)].Remove(this);
            this.unitCoords = h.coordinates; // Leverage the setter function
        }
    }

    public void Move(Hex h)
    {
        if (isSelected && curMoves >= h.moveCost && CanMoveToHex(h)) {
            EmitSignal(SignalName.UnitClicked, this);
        }
    }

    // Override functions
    public override void _Ready()
    {
        unitCollider = GetNode<Area2D>("UnitSprite/Area2D");
        uiManager = GetNode<UIManager>("/root/Game/UI/UICanvas/UIManager");
        this.UnitClicked += uiManager.SetUnitUI;
        map = GetNode<HexTileMap>("/root/Game/Environment/HexTileMap");
        this.UnitClicked += map.DeselectCurrentHex;
        validMovementHexes = CalculateValidAdjacentMovementHexes();
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
                EmitSignal(SignalName.UnitClicked, this);
                GetViewport().SetInputAsHandled();
            } else {
                SetDeselected();
            }
        }
    }
}
