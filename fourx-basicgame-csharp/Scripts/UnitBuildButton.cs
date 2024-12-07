using Godot;
using System;

public partial class UnitBuildButton : Button
{
    public Unit unit_ref;

    [Signal]
    public delegate void OnPressedEventHandler(Unit unit_ref);

    public override void _Ready()
    {
        Pressed += SendUnitData;
    }

    public void SendUnitData()
    {
        EmitSignal(SignalName.OnPressed, unit_ref);
    }
}
