using Godot;
using System;

public partial class UnitUI : Panel
{
    TextureRect unitImage;
    Label unitType, moves, health;
    Unit myUnit;
    VBoxContainer actionBox;

    public override void _Ready()
    {
        unitImage = GetNode<TextureRect>("VBoxContainer/TextureRect");
        unitType = GetNode<Label>("VBoxContainer/UnitTypeLabel");
        health = GetNode<Label>("VBoxContainer/HealthLabel");
        moves = GetNode<Label>("VBoxContainer/MovesLabel");
        actionBox = GetNode<VBoxContainer>("VBoxContainer/ActionsBox");
    }

    public void SetUnitUI(Unit u)
    {
        myUnit = u;

        Refresh();
    }

    public void Refresh()
    {
        unitImage.Texture = Unit.unitImages[myUnit.GetType()];
        unitType.Text = $"Unit: {myUnit.unitName}";
        moves.Text = $"{myUnit.curMoves} / {myUnit.maxMoves}";
        health.Text = $"{myUnit.curHealth} / {myUnit.maxHealth}";
    }
}
