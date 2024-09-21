using Godot;
using System;

public partial class Camera : Camera2D
{
	[Export]
	public int velocity = 25;

	[Export]
	public float zoom_speed = 0.05f;

	[Export]
	public float min_zoom = 0.2f;

	[Export]
	public float max_zoom = 4f;

	bool mouseWheelScrollingUp = false;
	bool mouseWheelScrollingDown = false;

	// Map boundaries
	float leftBound, rightBound, topBound, bottomBound;

	// Map Reference
	HexTileMap map;

	// Called when the node enters the scene tree for the first time.
	public override void _Ready()
	{
		map = GetNode<HexTileMap>("../HexTileMap");

		leftBound = ToGlobal(map.MapToLocal(new Vector2I(0,0))).X + 500;
		rightBound = ToGlobal(map.MapToLocal(new Vector2I(map.width,0))).X - 500;
		topBound = ToGlobal(map.MapToLocal(new Vector2I(0,0))).Y + 100;
		bottomBound = ToGlobal(map.MapToLocal(new Vector2I(0,map.height))).Y - 100;
	}

	// Called every frame. 'delta' is the elapsed time since the previous frame.
	public override void _PhysicsProcess(double delta)
	{
		moveCamera();
		zoomCamera();
	}

	public void moveCamera()
	{
		Vector2 move_direction = new Vector2(0,0);
		Vector2 my_position = this.Position;
	
		// Right / Left
		if (Input.IsActionPressed("map_right") && this.Position.X < rightBound)
			move_direction.X = velocity;
		else if (Input.IsActionPressed("map_left") && this.Position.X > leftBound)
			move_direction.X = -velocity;

		// Up / down
		if (Input.IsActionPressed("map_up") && this.Position.Y > topBound)
			move_direction.Y = -velocity;
		else if (Input.IsActionPressed("map_down") && this.Position.Y < bottomBound)
			move_direction.Y = velocity;

		my_position += move_direction;

		// Check to make sure that our velocity didn't push us outside of the boundaries
		if (my_position.X < leftBound)
			my_position.X = leftBound;
		if (my_position.X > rightBound)
			my_position.X = rightBound;
		if (my_position.Y < topBound)
			my_position.Y = topBound;
		if (my_position.Y > bottomBound)
			my_position.Y = bottomBound;

		this.Position = my_position;
	}

	public void zoomCamera()
	{
		// Keyboard Zoom controls
		if (Input.IsActionJustReleased("mouse_zoom_in"))
			mouseWheelScrollingUp = true;

		if (!Input.IsActionJustReleased("mouse_zoom_in"))
			mouseWheelScrollingUp = false;

		if (Input.IsActionJustReleased("mouse_zoom_out"))
			mouseWheelScrollingDown = true;

		if (!Input.IsActionJustReleased("mouse_zoom_out"))
			mouseWheelScrollingDown = false;

		if (Input.IsActionPressed("map_zoom_in") || mouseWheelScrollingUp)
			this.Zoom += new Vector2(zoom_speed, zoom_speed);

		if (Input.IsActionPressed("map_zoom_out") || mouseWheelScrollingDown)
			this.Zoom += new Vector2(-zoom_speed,-zoom_speed);

		if ( this.Zoom.X > max_zoom )
			this.Zoom = new Vector2(max_zoom,max_zoom);
		if ( this.Zoom.X < min_zoom )
			this.Zoom = new Vector2(min_zoom,min_zoom);
	}
}
