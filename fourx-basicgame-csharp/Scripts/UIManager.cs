using Godot;
using System;

public partial class UIManager : Node2D
{
    PackedScene terrainUIScene;
    PackedScene cityUIScene;

    TerrainTileUI terrainUI = null;
    CityUI cityUI = null;
    GeneralUI generalUI;

    [Signal]
    public delegate void EndTurnEventHandler();



    public override void _Ready()
    {
        terrainUIScene = ResourceLoader.Load<PackedScene>("res://Scenes/TerrainTileUI.tscn");
        cityUIScene = ResourceLoader.Load<PackedScene>("res://Scenes/cityUI.tscn");

        generalUI = GetNode<Panel>("GeneralUI") as GeneralUI;

        // End turn button
        Button endTurnButton = generalUI.GetNode<Button>("EndTurnButton");
        endTurnButton.Pressed += SignalEndTurn;
    }

    // Connector between button and signal
    public void SignalEndTurn()
    {
        EmitSignal(SignalName.EndTurn);
        generalUI.IncrementTurnCounter();
    }

    public void SetTerrainUI(Hex hexObj)
    {
        HideUIPopups();

        terrainUI = terrainUIScene.Instantiate() as TerrainTileUI;
        AddChild(terrainUI);
        terrainUI.SetHex(hexObj);
    }

    public void SetCityUI(City c)
    {
        HideUIPopups();

        cityUI = cityUIScene.Instantiate() as CityUI;
        AddChild(cityUI);
        cityUI.SetCityUI(c);
    }

    public void HideAllPopups()
    {
        HideUIPopups();
    }

    public void HideUIPopups()
    {
        ClearTerrainUI();
        ClearCityUI();
    }

    public void ClearTerrainUI()
    {
        if (terrainUI is not null) {
            terrainUI.QueueFree();
            terrainUI = null;
        }
    }

    public void ClearCityUI()
    {
        if (cityUI is not null) {
            cityUI.QueueFree();
            cityUI = null;
        }
    }
}
