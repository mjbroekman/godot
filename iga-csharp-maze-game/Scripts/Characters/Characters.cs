using System;
using Godot;

public abstract partial class Characters: CharacterBody2D
{
    [Export] public StateMachine myStateMachine { get; private set; }

    [ExportGroup("Sprite")]
    [Export] public Sprite2D mySprite { get; private set; }
    [Export] public AnimationPlayer myAnimPlayer { get; private set; }

    [ExportGroup("Colliders")]
    [Export] public CollisionShape2D myCollider { get; private set; }
    [Export] public Area2D myHurtBoxArea { get; private set; }
    [Export] public Area2D myHitBoxArea { get; private set; }

    public Vector2 direction = new(x=0);
    public void Flip()
    {
        bool isNotMovingHorizontally = direction.X == 0;
        if (isNotMovingHorizontally)
        {
            return;
        }

        bool isMovingLeft = direction.X < 0;
        mySprite.FlipH = isMovingLeft;
    }

}