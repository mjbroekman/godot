using Godot;
using System;
using System.Collections.Generic;
using System.Linq;

public partial class City : Node2D
{
    // Main map
    public HexTileMap map;

    // Keep track of the city center coordinations
    private Vector2I centerCoords;
    public Vector2I cityCenterCoords {
		get { return centerCoords; }
		set { centerCoords = value; AddTerritory(value); }
	}

    // Track the territy that is "part of" the city
    public List<Hex> territory;

    // Track the tiles we can expand into
    public List<Hex> borderTilePool;

    // Owner civilization
    public Civilization civ;

    // City name
    public string name;

    // Scene nodes
    Label label;
    public Sprite2D sprite;

    public override void _Ready()
    {
        sprite = GetNode<Sprite2D>("CityImage");
        label = GetNode<Label>("CityName");
        territory = new List<Hex>();
        borderTilePool = new List<Hex>();
    }

    public override void _Process(double delta)
    {
    }

    public void AddTerritory(Hex newTerritoryHex){
        if (map == null) {
            GD.Print("Attempt to AddTerritory from null map");
            return;
        }

        if (newTerritoryHex == null) {
            GD.Print("Attempt to add a NULL hex");
            return;
        }

        // A city can be founded on a non-productive hex, but otherwise can't join territory
        if (! newTerritoryHex.canBelong ) {
            if (newTerritoryHex != map.GetHex(this.cityCenterCoords)) {
                GD.Print($"{newTerritoryHex} can not belong to any city");
                return;
            }
        }

        // Return if the hex being added is already part of our territory
        if (territory.Contains(newTerritoryHex)) {
            return;
        }

        territory.Add(newTerritoryHex);
        newTerritoryHex.ownerCity = this;
        // Add surrounding tiles to the border tile pool
        borderTilePool.AddRange(map.GetSurroundingHexes(newTerritoryHex));
        // Remove duplicate hexes from border
        borderTilePool = borderTilePool.Distinct().ToList();
        // Remove territory from border
        borderTilePool = borderTilePool.Except(territory).ToList();
    }

    // Override to add a hex by coordinates
    public void AddTerritory(Vector2I newTerritoryCoords)
    {
        if (map == null) {
            GD.Print("Attempt to AddTerritory from null map");
            return;
        }
        AddTerritory(map.GetHex(newTerritoryCoords));
    }

    // Override to add a list of Hexes
    public void AddTerritory(List<Hex> newTerritory)
    {
        if (map == null) {
            GD.Print("Attempt to AddTerritory from null map");
            return;
        }
        foreach (Hex newHex in newTerritory) {
            AddTerritory(newHex);
        }
    }

    public void SetCityName(string newName)
    {
        name = newName;
        label.Text = newName;
    }

    public void SetIconColor(Color c)
    {
        sprite.Modulate = c;
    }
}
