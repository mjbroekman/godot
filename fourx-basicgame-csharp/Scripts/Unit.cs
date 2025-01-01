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
    
    public Random unitRNG = new Random();

    public int maxStackSize = 1;

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

    public delegate void SelectedUnitDestroyedEventHandler();
    public event SelectedUnitDestroyedEventHandler SelectedUnitDestroyed;

    // Combat properties
    public int maxHealth = -5;
    public int curHealth = -5;
    public int attackValue = -5;
    public int defenseValue = -5;
    public int curLevel = -5;
    public int xpValue = -5;

    private int expTotal = 0;
    public int totalXP {
        get { return expTotal; }
		set { expTotal = value; if ( totalXP > (curLevel * 5) ) LevelUp(); }
    }
    public int killCount = -5;

    // Movement properties
    public int maxMoves = -5;
    public int curMoves = -5;
    public List<Hex> validMovementHexes;
    public List<Hex> visitedHexes;

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
        uiManager.SetUnitUI(this);
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
        // Clear the UI
        uiManager.HideUIPopups();
    }

    public void DestroyUnit()
    {
        // Disconnect movement signal
        map.RightClickOnMap -= Move;
        uiManager.EndTurn -= this.ProcessTurn;

        // Clean up stuff and remove the Unit UI
        if ( isSelected ) {
            SelectedUnitDestroyed?.Invoke();
            isSelected = false;
        }
        // Remove unit from civ unit list and unit location dictionary
        this.ownerCiv.units.Remove(this);
        unitLocations[map.GetHex(this.unitCoords)].Remove(this);
        // Nuke the unit
        this.QueueFree();
    }

    public List<Hex> CalculateValidAdjacentMovementHexes()
    {
        List<Hex> hexes = new List<Hex>();
        List<Hex> hexes2 = new List<Hex>();

        hexes2.AddRange(map.GetSurroundingHexes(this.unitCoords));

        // Using Linq functions
        hexes2 = hexes2.Where( h => !impassable.Contains(h.terrainType)).ToList();
        hexes2 = hexes2.Where( h => h.moveCost <= curMoves ).ToList();

        // Loop over the remaining hexes and remove the ones that have a unit from my civ
        foreach (Hex h in hexes2) {
            if (unitLocations.ContainsKey(h) && unitLocations[h].Count > 0) {
                if (unitLocations[h][0].ownerCiv == this.ownerCiv) continue;
            }
            hexes.Add(h);
        }

        return hexes;
    }

    public void AddUnitToLocation(Vector2I location)
    {
        if ( unitLocations.ContainsKey(map.GetHex(location))) {
            if ( ! unitLocations[map.GetHex(location)].Contains(this) ) {
                unitLocations[map.GetHex(location)].Add(this);
            }
        } else {
            unitLocations[map.GetHex(location)] = new List<Unit>{this};
        }
    }

    public bool CanMoveToHex(Hex h)
    {
        if (
             ( ! unitLocations.ContainsKey(h) ) || ( unitLocations.ContainsKey(h) && unitLocations[h].Count < this.maxStackSize )
            ) {
                if ( validMovementHexes.Contains(h) ) {
                    return true;
                }
            }
        return false;
    }

    public bool CanMoveToCombat(Hex h)
    {
        if ( unitLocations.ContainsKey(h) && unitLocations[h].Count > 0 ) {
            if ( unitLocations[h][0].ownerCiv != this.ownerCiv ) return true;
        }
        return false;
    }

    public void MoveToHex(Hex h)
    {
        if ( CanMoveToHex(h) ) {
            Unit.unitLocations[map.GetHex(this.unitCoords)].Remove(this);
            this.unitCoords = h.coordinates; // Leverage the setter function
            this.curMoves -= h.moveCost; // Update remaining moves
            AddUnitToLocation(this.unitCoords);
            validMovementHexes = CalculateValidAdjacentMovementHexes();
        } else if ( CanMoveToCombat(h) ) {
            Unit opponent = Unit.unitLocations[h][0];
            GD.Print($"{this} has entered combat against {opponent}!");
            CalculateCombat(this,opponent);
        } else {
            // Nothing to do here? Target hex is occupied by a friendly or not a valid hex
        }
    }

    public void Move(Hex h)
    {
        if (isSelected && curMoves >= h.moveCost) {
            MoveToHex(h);
            EmitSignal(SignalName.UnitClicked, this);
        }
    }

    public void ProcessTurn()
    {
        if ( curMoves == maxMoves && curHealth != maxHealth ) {
            // We didn't move and we are injured, so we should heal
            curHealth += 1;
        }

        curMoves = maxMoves;
        if (this.isSelected) SetDeselected();
    }

    // Debug functions
    public void ShowHexes(List<Hex> hexes)
    {
        GD.Print("Hexes: " + hexes.Count);
        string hexList = "";
        foreach (Hex h in hexes) {
            hexList += h.ToString() + " ";
            if (unitLocations.ContainsKey(h) && unitLocations[h].Count > 0) {
                foreach (Unit u in unitLocations[h]) {
                    // hexList += u.ToString() + " ";
                    GD.Print(u.ToString() + " : " + h.ToString() + unitLocations[h].Count.ToString() );
                }
            }
        }
        GD.Print("Hex List: " + hexList);
    }

    // Override functions
    public override void _Ready()
    {
        unitCollider = GetNode<Area2D>("UnitSprite/Area2D");

        //// UImanager Signals
        // Set up the Unit UI when the unit is clicked
        uiManager = GetNode<UIManager>("/root/Game/UI/UICanvas/UIManager");
        this.UnitClicked += uiManager.SetUnitUI;
        this.SelectedUnitDestroyed += uiManager.HideUIPopups;

        // Connect the UI Endturn signal to our Process Turn
        uiManager.EndTurn += this.ProcessTurn;
        //// End of UImanager signals

        // Map signals
        map = GetNode<HexTileMap>("/root/Game/Environment/HexTileMap");
        this.UnitClicked += map.DeselectCurrentHex;
        map.RightClickOnMap += Move;

        // Calculate the valid hexes
        validMovementHexes = CalculateValidAdjacentMovementHexes();
        visitedHexes = new List<Hex>();

        curLevel = 1;
        totalXP = 0;
    }

    public override string ToString()
    {
        return $"{unitName} ({ownerCiv})";
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

    // Movement, Combat, and Advancement
    public void CalculateCombat(Unit attacker, Unit defender)
    {
        // Defensive values reduce incoming damage before modifiers for attacker or defender
        int defDamage = attacker.attackValue - defender.defenseValue;
        int attDamage = defender.attackValue - attacker.defenseValue;

        // Make sure damage is non-negative so we don't inadvertently heal unit by attacking them
        if ( defDamage < 0 ) defDamage = 0;
        if ( attDamage < 0 ) attDamage = 0;

        // Deal damage
        defender.curHealth -= defDamage;
        // Defensive fighting is less effective, so halve the damage
        attacker.curHealth -= attDamage / 2;
        // The attack used its move to attack
        attacker.curMoves -= 1;

        // XP gain needs to happen before we destroy anything
        // this COULD 'save' a unit from dying if they level up
        if (defender.curHealth <= 0) attacker.totalXP += defender.xpValue;
        if (attacker.curHealth <= 0) defender.totalXP += attacker.xpValue;

        if (defender.curHealth <= 0) defender.DestroyUnit();
        if (attacker.curHealth <= 0) attacker.DestroyUnit();
    }

    public void RandomMove()
    {
        validMovementHexes = CalculateValidAdjacentMovementHexes();

        foreach (Hex v in visitedHexes) validMovementHexes.Remove(v);

        if (validMovementHexes.Count > 0) {
            Hex h = validMovementHexes.ElementAt(unitRNG.Next(validMovementHexes.Count));
            MoveToHex(h);
            if (this is Settler) visitedHexes.Add(h);
        }
        if (visitedHexes.Count > 4 && validMovementHexes.Count > 0) {
            int last = visitedHexes.Count - 1;
            visitedHexes.RemoveAt(last);
        } else if (validMovementHexes.Count == 0 && visitedHexes.Count > 0) {
            int last = visitedHexes.Count - 1;
            visitedHexes.RemoveAt(last);
        }
    }

    public void LevelUp()
    {
        GD.Print($"{this.unitName} leveled up!");
        curLevel += 1;
        curHealth += maxHealth;
        maxHealth += maxHealth;
        this._LevelUp();
    }

    public virtual void _LevelUp() {}
}
