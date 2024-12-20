using Godot;
using System;

public partial class UnitUI : Panel
{
    TextureRect unitImage;
    Label unitType, moves, health;
    Unit myUnit;
    VBoxContainer actionBox;

    public ovveride void _Ready()
    {
        unitImage = GetNode<TextTextureRect>("VBoxContainer/TextureRect");
        unitType = GetNode<Label>("VBoxContainer/UnitTypeLabel");
        health = GetNode<Label>("VBoxContainer/HealthLabel");
        moves = GetNode<Label>("VBoxContainer/MovesLabel");
        actionBox = GetNode<VBoxContainer>("VBoxContainer/ActionsBox");
    }

    public void SetUnit(Unit u)
    {
        myUnit = u;

        Refresh();
    }

    public void Refresh()
    {

    }
}
