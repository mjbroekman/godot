using Godot;
using System;

public partial class UnitUI : Panel
{
    TextureRect unitImage;
    Label unitType, moves, health, exp;
    Unit myUnit;
    VBoxContainer actionBox;

    public override void _Ready()
    {
        unitImage = GetNode<TextureRect>("VBoxContainer/TextureRect");
        unitType = GetNode<Label>("VBoxContainer/UnitTypeLabel");
        exp = GetNode<Label>("VBoxContainer/ExpLabel");
        health = GetNode<Label>("VBoxContainer/HealthLabel");
        moves = GetNode<Label>("VBoxContainer/MovesLabel");
        actionBox = GetNode<VBoxContainer>("VBoxContainer/ActionsBox");
    }

    public void SetUnitUI(Unit u)
    {
        this.myUnit = u;

        if ( this.myUnit.GetType() == typeof(Settler) ) {
            Button foundCityButton = new Button();
            foundCityButton.Text = "Found City";
            actionBox.AddChild(foundCityButton);

            Settler settler = this.myUnit as Settler;
            foundCityButton.Pressed += settler.FoundCity;
        }

        RefreshUnitUI();
    }

    public void RefreshUnitUI()
    {
        unitImage.Texture = Unit.unitImages[myUnit.GetType()];
        unitType.Text = $"Unit: {myUnit.unitName}";
        moves.Text = $"Moves Remaining: {myUnit.curMoves} / {myUnit.maxMoves}";
        health.Text = $"Hit Points: {myUnit.curHealth} / {myUnit.maxHealth}";
        exp.Text = $"Exp: {myUnit.totalXP} / {((myUnit.curLevel + 1) * 5)}";
    }
}
