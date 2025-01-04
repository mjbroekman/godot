using Godot;
using System;

public partial class MainMenu : Node2D
{
    public void Quit()
    {
        GetTree().Quit();
    }

    public void Start()
    {
        Game g = ResourceLoader.Load<PackedScene>("res://Scenes/Game.tscn").Instantiate() as Game;
        HexTileMap map = g.GetNode<HexTileMap>("Environment/HexTileMap");

        map.width = (int)this.GetNode<SpinBox>("VBoxContainer/MapSizeContainer/WidthBox").Value;
        map.height = (int)this.GetNode<SpinBox>("VBoxContainer/MapSizeContainer/HeightBox").Value;

        map.startingCivs = (int)this.GetNode<SpinBox>("VBoxContainer/CivContainer/CivCountBox").Value;
        map.PLAYER_COLOR = this.GetNode<ColorPickerButton>("VBoxContainer/PlayerContainer/PlayerColor").Color;

        GetNode("/root/MainMenu").QueueFree();
        GetTree().Root.AddChild(g);
    }
}
