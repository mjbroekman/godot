using Godot;
using System;

public partial class StateMachine : Node {
    [Export] private bool enableDebugging;
    [Export] private Node currentState;
    [Export] private Node[] states;

    public override void _Ready()
    {
        currentState.Notification(GameConstants.NOTIFICATION_ENTER_STATE);
    }

    public void SwitchState<T>()
    {
        Node newState = states.Where((state) => state is T).FirstOrDefault();

        if (newState == null) {
            GD.PrintError("Entering a null state!");
            return;
        }
        if (currentState is T){
            return;
        }

        currentState.Notification(GameConstants.NOTIFICATION_EXIT_STATE);
        currentState = newState;
        if ( enableDebugging ) {
            GD.Print($"Entered state {currentState.Name}");
        }
        currentState.Notification(GameConstants.NOTIFICATION_ENTER_STATE);
    }
}