using Godot;
using System;

public partial class Settler : Unit
{
    public Settler()
    {
        unitName = "Settler";

        maxHealth = 1;
        curHealth = 1;

        maxMoves = 2;
        curMoves = 2;

        productionRequired = 100;
    }
}
