using Godot;
using System;

public partial class StateMachineState: Node
{
    [Export] public StateMachineState StateMachineNode {get; private set;}

    public override void _Ready()
    {
        SetPhysicsProcess(false);
        SetProcessInput(false);
    }

    public override void _Notification(int what)
    {
        base._Notification(what);

        switch(what){
            case GameConstants.NOTIFICATION_ENTER_STATE:
                EnterState();
                SetPhysicsProcess(true);
                SetProcessInput(true);
                break;

            case GameConstants.NOTIFICATION_EXIT_STATE:
                SetPhysicsProcess(false);
                SetProcessInput(false);
                ExitState();
                break;

            default:
                break;
        }
    }

    protected virtual void EnterState()
    {

    }

    protected virtual void ExitState()
    {

    }
}
