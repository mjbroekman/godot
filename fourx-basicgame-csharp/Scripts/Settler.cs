using Godot;
using System;
using System.Linq;
using System.Collections.Generic;

public partial class Settler : Unit
{
    // Settlers are hardy folk and can pass over mountains and ice, but not water...
    public new HashSet<TerrainType> impassable = new HashSet<TerrainType>
    {
        TerrainType.WATER,
        TerrainType.SHALLOW_WATER,
    };

    public Settler()
    {
        unitName = "Settler";

        maxHealth = 3;
        curHealth = 3;
        attackValue = 1;
        defenseValue = 0;

        curLevel = 1;
        xpValue = curLevel;
        totalXP = 0;
        killCount = 0;

        maxMoves = 2;
        curMoves = 2;

        productionRequired = 100;
    }

    public override void _Ready()
    {
        base._Ready();
    }

    public bool IsValidCityHex(Hex h)
    {
        if ( ! City.invalidTiles.ContainsKey(h) && h.ownerCity is null ||
             ( ! ( h.ownerCity is null ) && h.ownerCity.civ is null ) ) {
            return true;
        }
        return false;
    }

    public void FoundCity()
    {
        if ( map.IsValidLocation(this.unitCoords, map.minCityRange, new List<Vector2I>(map.cities.Keys)) ) {
            Hex thisHex = map.GetHex(this.unitCoords) as Hex;
            if ( IsValidCityHex(thisHex ) ) {
                bool valid = true;

                // Count the number of valid hexes surrounding the theoretical new city center
                int validCount = 0;
                foreach (Hex h in map.GetSurroundingHexes(this.unitCoords)) {
                    if ( IsValidCityHex(h) ) {
                        validCount += 1;
                    }
                }

                // If less than half of the surrounding hexes are valid, don't allow a city to be founded
                if ( validCount < 3 ) valid = false;

                if ( valid ) {
                    map.CreateCity(this.ownerCiv, this.unitCoords, $"Settled City {this.ownerCiv.cities.Count}" );

                    this.DestroyUnit();
                }
            }
        }
    }

    public override void _LevelUp()
    {
        GD.Print("Settler Levelup initiated!");
        maxMoves += 1;
        xpValue = curLevel;
        defenseValue += 1;
    }
}
