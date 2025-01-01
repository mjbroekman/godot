using Godot;
using System;

public partial class UIManager : Node2D
{
    PackedScene terrainUIScene;
    PackedScene cityUIScene;
    PackedScene unitUIScene;

    TerrainTileUI terrainUI = null;
    CityUI cityUI = null;
    UnitUI unitUI = null;
    GeneralUI generalUI;

    [Signal]
    public delegate void EndTurnEventHandler();



    public override void _Ready()
    {
        terrainUIScene = ResourceLoader.Load<PackedScene>("res://Scenes/UserInterfaces/TerrainTileUI.tscn");
        cityUIScene = ResourceLoader.Load<PackedScene>("res://Scenes/UserInterfaces/cityUI.tscn");
        unitUIScene = ResourceLoader.Load<PackedScene>("res://Scenes/UserInterfaces/unitUI.tscn");

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

    public void SetUI(Hex hexObj) {
        HideUIPopups();
        if ( hexObj.isCityCenter ) {
            SetCityUI( hexObj.ownerCity);
        } else {
            SetTerrainUI(hexObj);
        }
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

    public void SetUnitUI(Unit u)
    {
        HideUIPopups();
        unitUI = unitUIScene.Instantiate() as UnitUI;
        AddChild(unitUI);
        if ( u != null ) unitUI.SetUnitUI(u);
        if ( u is null ) HideAllPopups();
    }

    public void HideAllPopups()
    {
        HideUIPopups();
    }

    public void HideUIPopups()
    {
        ClearTerrainUI();
        ClearCityUI();
        ClearUnitUI();
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

    public void ClearUnitUI()
    {
        if (unitUI is not null) {
            unitUI.QueueFree();
            unitUI = null;
        }
    }

    public void RefreshUI()
    {
        if (cityUI is not null) cityUI.RefreshUI();
        if (unitUI is not null) unitUI.RefreshUnitUI();
    }
}
