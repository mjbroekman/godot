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
    public string cityName;

    // City UI Values
    public int population = 1;
    // Value of _all_ tiles
    public int totalFood;
    public int totalProduction;
    // Values of _worked_ tiles
    public int workedFood;
    public int workedProduction;

    // City Production Priorities
    // // Prioritize Food value for growth
    public bool prioritizeFood = true;
    // // Prioritize Production value for industry
    public bool prioritizeProduction = false;
    // // Prioritize total resources in tile
    public bool prioritizeTotal = false;

    // Scene nodes
    Label label;
    public Sprite2D sprite;

    public override void _Ready()
    {
        sprite = GetNode<Sprite2D>("CityImage");
        label = GetNode<Label>("CityName");
        territory = new List<Hex>();
        borderTilePool = new List<Hex>();
        // Make sure the city is visible above tilemaps (ZIndex: 0)
        ZIndex = 3;
        // Make sure ZIndex is relative to parent objects
        ZAsRelative = true;
    }

    public override void _Process(double delta)
    {
    }

    public void calculateTerritoryResourceTotals()
    {
        workedFood = 0;
        workedProduction = 0;
        totalFood = 0;
        totalProduction = 0;
        int count = 0;
        foreach (Hex h in sortTerritory()) {
            totalFood += h.foodValue;
            totalProduction += h.productionValue;
            if (count < population) {
                workedFood += h.foodValue;
                workedProduction += h.productionValue;
            }
            count++;
        }
    }

    public List<Hex> sortTerritory()
    {
        if (prioritizeFood) return territory.OrderByDescending(x => x.foodValue).ThenByDescending(x => x.productionValue).ToList();
        if (prioritizeProduction) return territory.OrderByDescending(x => x.productionValue).ThenByDescending(x => x.foodValue).ToList();
        if (prioritizeTotal) return territory.OrderByDescending(x => (x.foodValue + x.productionValue)).ToList();
        return territory;
    }

    public void AddTerritory(Hex newTerritoryHex)
    {
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
        // Calculate the resource totals for the city
        calculateTerritoryResourceTotals();
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
        cityName = newName;
        label.Text = newName;
    }

    public void SetIconColor(Color c)
    {
        sprite.Modulate = c;
    }
}
