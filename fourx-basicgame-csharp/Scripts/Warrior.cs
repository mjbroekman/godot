using Godot;
using System;
using System.Linq;
using System.Collections.Generic;

public partial class Warrior : Unit
{
    public Warrior()
    {
        unitName = "Warrior";
        maxHealth = 3;
        curHealth = 3;

        maxMoves = 1;
        curMoves = 1;

        productionRequired = 50;
    }

    public override void _Ready()
    {
        base._Ready();
    }
}
