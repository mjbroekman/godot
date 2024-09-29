using Godot;
using System;

public partial class UIManager : Node2D
{
    PackedScene terrainUIScene;

    TerrainTileUI terrainUI;

    public override void _Ready()
    {
        terrainUIScene = ResourceLoader.Load<PackedScene>("res://Scenes/TerrainTileUI.tscn");
    }

    public void SetTerrainUI(Hex hexObj)
    {
        if (terrainUI is not null) terrainUI.QueueFree();

        terrainUI = terrainUIScene.Instantiate() as TerrainTileUI;

        AddChild(terrainUI);

        terrainUI.SetHex(hexObj);
    }

    public void HideAllPopups()
    {
        ClearTerrainUI();
    }

    public void ClearTerrainUI()
    {
        terrainUI.QueueFree();
        terrainUI = null;
    }
}
