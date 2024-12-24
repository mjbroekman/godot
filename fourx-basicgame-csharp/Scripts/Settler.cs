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

        maxHealth = 1;
        curHealth = 1;

        maxMoves = 2;
        curMoves = 2;

        productionRequired = 100;
    }

    public override void _Ready()
    {
        base._Ready();
    }
}
