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
    public Dictionary<int,List<Hex>> borderTileRangePool;

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

    // Valued of food/production required for growth
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

    // Units
    public List<Unit> unitBuildQueue;
    public Unit currentUnitBuild;
    public int unitBuildTracker = 0;

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
        unitBuildQueue = new List<Unit>();
    }

    public void ProcessTurn()
    {
        storedFood += workedFood;
        // storedProduction += workedProduction;
        int requiredFood = requiredFoodForGrowth();
        // GD.Print($"{cityName} needs {requiredFood} food to grow.  We have {storedFood} available.");
        List<int> distances = borderTileRangePool.Keys.ToList();
        distances.Sort();
        // GD.Print($"{cityName} border pool:");
        // foreach (int dist in distances) {
        //     GD.Print($" @ {dist} : " + string.Join(", ", borderTileRangePool[dist]));
        // }

        if (storedFood >= requiredFood)
        {
            population++;
            storedFood -= requiredFood;

            calculateTerritoryResourceTotals();

            // Grow territory
            AddRandomNewTile();
        }

        ProcessUnitBuildQueue();
    }

    public void AddRandomNewTile()
    {
        if (borderTilePool.Count > 0) {
            Random r = new Random();
            List<int> borderDistance = new List<int>(borderTileRangePool.Keys);
            borderDistance.Sort();
            List<Hex> closeNeighbors = borderTileRangePool[borderDistance[0]];
            int index = r.Next(closeNeighbors.Count);
            Hex newTerritory = closeNeighbors[index];
            this.AddTerritory(newTerritory);
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

    public void AddUnitToBuildQueue(Unit u)
    {
        unitBuildQueue.Add(u);
    }

    public void SpawnUnit(Unit u)
    {
        Unit unitToSpawn = (Unit) Unit.unitSceneResources[u.GetType()].Instantiate();
        unitToSpawn.Position = map.MapToLocal(this.centerCoords);
        unitToSpawn.SetCiv(this.civ);
        unitToSpawn.unitCoords = this.centerCoords;
        unitToSpawn.ZAsRelative = true;
        unitToSpawn.ZIndex = 5;
        map.AddChild(unitToSpawn);
    }

    public void ProcessUnitBuildQueue()
    {
        if (unitBuildQueue.Count > 0) {
            if ( currentUnitBuild == null ) {
                currentUnitBuild = unitBuildQueue[0];
            }

            // Add worked production to the unit build
            unitBuildTracker += workedProduction;

            if ( unitBuildTracker >= currentUnitBuild.productionRequired ) {
                // If we are building a settler, but our city only has 1 population, don't complete the build
                if ( currentUnitBuild.GetType() == typeof(Settler) && population < 2 ) return;

                // If we have more than one item in the queue, move worked production to the next item
                if ( unitBuildQueue.Count > 1 ) {
                    unitBuildTracker -= currentUnitBuild.productionRequired;
                } else {
                    // if there is nothing else in the queue, we just wasted leftover production
                    unitBuildTracker = 0;
                }

                // If we successfully built a Settler, reduce population by 1
                if ( currentUnitBuild.GetType() == typeof(Settler) ) population--;

                // Spawn the newly completed unit
                SpawnUnit(currentUnitBuild);

                // Remove the thing we just spawned.
                unitBuildQueue.RemoveAt(0);
            }
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

        AddValidTilesToBorderPool(newTerritoryHex);

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

    public void AddValidTilesToBorderPool(Hex h)
    {
        List<Hex> neighbors = map.GetSurroundingHexes(h);
        // neighbors = neighbors.Except(territory).ToList();

        foreach (Hex n in neighbors) {
            if (IsValidTerritoryTile(n)) borderTilePool.Add(n);
            invalidTiles[n] = this;
        }

        // Remove duplicate hexes from border
        borderTilePool = borderTilePool.Distinct().ToList();
        // Remove territory from border
        borderTilePool = borderTilePool.Except(territory).ToList();

        borderTileRangePool = new Dictionary<int,List<Hex>>();
        foreach (Hex b in borderTilePool) {
            Vector2I borderCoords = b.coordinates;
            int tileDistance = (int)borderCoords.DistanceTo(cityCenterCoords);
            if (! borderTileRangePool.ContainsKey(tileDistance)) {
                borderTileRangePool[tileDistance] = new List<Hex>();
            }
            borderTileRangePool[tileDistance].Add(b);
        }
    }

    public bool IsValidTerritoryTile(Hex h)
    {
        // See if the tile can even belong to a city
        if (! h.canBelong) return false;

        // See if the tile already belongs to another city/civ
        if (h.ownerCity != null && h.ownerCity.civ != null) return false;

        // See if the tile is part of the invalidTiles collection
        // if (invalidTiles.ContainsKey(h) && invalidTiles[h] != this) return false;
        if (invalidTiles.ContainsKey(h)) return false;

        return true;
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
