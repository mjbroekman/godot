using Godot;
using System;
using System.Linq;
using System.Collections.Generic;

public partial class Warrior : Unit
{
    public Warrior()
    {
        unitName = "Warrior";

        maxHealth = 5;
        curHealth = 5;
        attackValue = 2;

        curLevel = 1;
        xpValue = curLevel * 2;
        totalXP = 0;
        killCount = 0;

        maxMoves = 1;
        curMoves = 1;

        productionRequired = 50;
    }

    public override void _Ready()
    {
        base._Ready();
    }

    public override void _LevelUp()
    {
        GD.Print("Warrior Levelup initiated!");
        attackValue += 2;
        xpValue = curLevel * 2;
    }
}
