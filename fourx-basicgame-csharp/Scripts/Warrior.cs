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
        defenseValue = 0;

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
        this.attackValue += 2;
        this.defenseValue += 1;
        this.maxMoves = ( ( this.curLevel / 5 ) > this.maxMoves ) ? ( this.curLevel / 5 ) : this.maxMoves;
        this.xpValue = this.curLevel * 2;
    }
}
