using Godot;
using System;
using System.Collections.Generic;
using System.Linq;

public enum GrowthType { LINEAR, FACTORIAL, EXPONENTIAL }
public partial class City : Node2D
{
    [ExportCategory("Growth Mechanics")]
    // Amount of food needed to increase population
    [Export(PropertyHint.Range, "5,25,1,or_greater,or_less")]
    public int foodPerNewPop = 10;

    // Increase in food for new population
    [Export(PropertyHint.Range, "0,1,0.01,or_greater,or_less")]
    public float foodMultiplier = 0.5f;

    // Which growth algorithm should we use
    //// Linear      => foodPerNewPop * (newPop * foodMultipler)
    //// Exponential => foodPerNewPop + prevPop^(newPop * foodMultipler)
    //// Factorial   => foodPerNewPop + (curPop! * foodMultiplier)
    [Export(PropertyHint.Enum,"Linear,Exponential,Factorial")]
    public GrowthType foodAlgo = GrowthType.LINEAR;

    // dictionary of tiles that belong to other cities
    // shared between all cities (static var)
    public static Dictionary<Hex,City> invalidTiles = new Dictionary<Hex, City>();

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

    // Valued of accrued food/production available for growth
    public int storedFood;
    public int storedProduction;

    // Valued of accrued food/production available for growth
    public int requiredFood;
    public int requiredProduction;

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
        // Make sure the city is visible above tilemaps (ZIndex: 0)
        ZIndex = 3;
        // Make sure ZIndex is relative to parent objects
        ZAsRelative = true;
        // variable setup
        sprite = GetNode<Sprite2D>("CityImage");
        label = GetNode<Label>("CityName");
        territory = new List<Hex>();
        borderTilePool = new List<Hex>();
    }

    public void ProcessTurn()
    {
        storedFood += workedFood;
        storedProduction += workedProduction;
        requiredFood = requiredFoodForGrowth();
        if (storedFood >= requiredFood)
        {
            population++;
            storedFood -= requiredFood;

            // Grow territory
        }
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
            GD.Print("ERROR: Attempt to AddTerritory from null map");
            return;
        }

        if (newTerritoryHex == null) {
            GD.Print("ERROR: Attempt to add a NULL hex");
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
        if (territory.Contains(newTerritoryHex)) return;

        // Return if the hex being added is already part of another territory
        // // Need some other mechanic to switch ownerCity.
        // // This could be some kind of 'influence pressure' (not implemented)
        // // This could be combat between units
        // // This could be outright purchase between civilizations
        if (newTerritoryHex.ownerCity != null) {
            GD.Print($"{newTerritoryHex} already belongs to another city.");
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

    public int requiredFoodForGrowth()
    {
        switch (this.foodAlgo)
        {
            case GrowthType.LINEAR:
                return growLinear();
            case GrowthType.EXPONENTIAL:
                return growExponential();
            case GrowthType.FACTORIAL:
                return growFactorial();
            default:
                return foodPerNewPop;
        }
    }

    public int growLinear()
    {
        // Pop n -> n+1 = int(foodPerNewPop * (n+1 * foodMultipler))
        // Example (10 fPNP, 0.5 fM):
        //   Pop 1 -> 2 = int(10 * (2 * 0.5)) = 10 * (2 * 0.5) = int(10 *   1) = 10
        //   Pop 2 -> 3 = int(10 * (3 * 0.5)) = 10 * (3 * 0.5) = int(10 * 1.5) = 15
        //   Pop 3 -> 4 = int(10 * (4 * 0.5)) = 10 * (4 * 0.5) = int(10 *   2) = 20
        //   Pop 4 -> 5 = int(10 * (5 * 0.5)) = 10 * (5 * 0.5) = int(10 * 2.5) = 25
        //   Pop 5 -> 6 = int(10 * (6 * 0.5)) = 10 * (6 * 0.5) = int(10 *   3) = 30
        float popGrowth = (float)(population + 1) * foodMultiplier;
        return foodPerNewPop * (int)popGrowth;
    }

    public int growExponential()
    {
        // Pop n -> n+1 = int(foodPerNewPop + (n-1)^((n+1) * foodMultipler))
        // Example (10 fPNP, 0.5 fM):
        //   Pop 1 -> 2 = int(10 + ((1-1)^(2 * 0.5))) = 10 + (0^1) = int(10 + 0) = 10
        //   Pop 2 -> 3 = int(10 + ((2-1)^(3 * 0.5))) = 10 + (1^1.5) = int(10 + 1) = 11
        //   Pop 3 -> 4 = int(10 + ((3-1)^(4 * 0.5))) = 10 + (2^2) = int(10 + 4) = 14
        //   Pop 4 -> 5 = int(10 + ((4-1)^(5 * 0.5))) = 10 + (3^2.5) = int(10 + 15.58) = 25
        //   Pop 5 -> 6 = int(10 + ((5-1)^(6 * 0.5))) = 10 + (4^3) = int(10 + 64) = 74
        int prevPop = population - 1;
        float popPower = (float)(population + 1) * foodMultiplier;
        return foodPerNewPop + (int)MathF.Pow((float)prevPop,popPower);
    }

    public int growFactorial()
    {
        // Pop n -> n+1 = int(foodPerNewPop + (n! * foodMultiplier))
        // Example (10 fPNP, 0.5 fM):
        //   Pop 1 -> 2 = int(10 + (1! * 0.5)) = 10 + (1 * 0.5) = int(10 + 0.5) = 10
        //   Pop 2 -> 3 = int(10 + (2! * 0.5)) = 10 + (2 * 0.5) = int(10 + 1) = 11
        //   Pop 3 -> 4 = int(10 + (3! * 0.5)) = 10 + (6 * 0.5) = int(10 + 3) = 13
        //   Pop 4 -> 5 = int(10 + (4! * 0.5)) = 10 + (24 * 0.5) = int(10 + 12) = 22
        //   Pop 5 -> 6 = int(10 + (5! * 0.5)) = 10 + (120 * 0.5) = int(10 + 60) = 70
        int fac = population;
        for (int i = fac - 1; i > 0; i--) {
            fac *= i;
        }
        return (int)(foodPerNewPop + (int)((float)fac * foodMultiplier));
    }
}
