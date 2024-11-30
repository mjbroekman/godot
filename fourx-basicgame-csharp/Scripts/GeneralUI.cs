using Godot;
using System;

public partial class GeneralUI : Panel
{
    int turns = 0;
    Label turnLabel;

    public override void _Ready()
    {
        turnLabel = GetNode<Label>("TurnLabel");
        turnLabel.Text = "Turn: " + turns;
    }

    public void IncrementTurnCounter()
    {
        turns += 1;
        turnLabel.Text = "Turn: " + turns;
    }
}
