using Godot;
using System;

public partial class CityUI : Panel
{
    Label cityName, popLabel, foodLabel, prodLabel;
    
    // City data
    City city = null;

    public override void _Ready()
    {
        cityName = GetNode<Label>("CityUIVBox/CityName");
        popLabel = GetNode<Label>("CityUIVBox/DataMarginContainer/DataVBox/Population");
        foodLabel = GetNode<Label>("CityUIVBox/DataMarginContainer/DataVBox/Food");
        prodLabel = GetNode<Label>("CityUIVBox/DataMarginContainer/DataVBox/Production");
    }

    public void SetCityUI(City city)
    {
        this.city = city;

        RefreshUI();

        ConnectUnitBuildSignals(this.city);
    }

    public void ConnectUnitBuildSignals(City city)
    {
        VBoxContainer buttonBox  = GetNode<VBoxContainer>("CityUIVBox/DataMarginContainer/DataVBox/BuildScrollContainer/BuildButtons");

        // Use a loop to iterate over the available units
        UnitBuildButton settlerButton = buttonBox.GetNode<UnitBuildButton>("SettlerBuildButton");
        settlerButton.unit_ref = new Settler();

        UnitBuildButton warriorButton = buttonBox.GetNode<UnitBuildButton>("WarriorBuildButton");
        warriorButton.unit_ref = new Warrior();

        // buttons are always "pressed"... no "released" signal
        settlerButton.OnPressed += city.AddUnitToBuildQueue;
        // we need an overload version of RefreshUI that takes a unit to handle this
        settlerButton.OnPressed += this.RefreshUI;

        // buttons are always "pressed"... no "released" signal
        warriorButton.OnPressed += city.AddUnitToBuildQueue;
        // we need an overload version of RefreshUI that takes a unit to handle this
        warriorButton.OnPressed += this.RefreshUI;
    }

    public void PopulateUnitQueueUI(City city)
    {
        VBoxContainer queue = GetNode<VBoxContainer>("CityUIVBox/DataMarginContainer/DataVBox/QueueScrollContainer/QueueButtons");

        foreach (Node n in queue.GetChildren()) {
            queue.RemoveChild(n);
            n.QueueFree();
        }

        for (int i = 0; i < city.unitBuildQueue.Count; i++) {
            Unit u = city.unitBuildQueue[i];
            // Skip a unit if (for whatever reason), the required production is less than zero
            // Maybe the dev forgot to set the productionRequired for the unit
            if ( u.productionRequired < 1 ) continue;
            if ( i == 0 ) {
                // unit is being built
                queue.AddChild(new Label() {
                    Text = $"{u.unitName} {city.unitBuildTracker}/{u.productionRequired} prod",
                });
            } else {
                queue.AddChild(new Label() {
                    Text = $"{u.unitName} {u.productionRequired} prod",
                });
            }
        }
    }

    public void RefreshUI()
    {
        cityName.Text = this.city.cityName;
        popLabel.Text = "Population: " + this.city.population;
        foodLabel.Text = "Food\n" +
                            "    Worked: " + this.city.workedFood + "\n" +
                            "    Stored: " + this.city.storedFood + "\n" +
                            "    In Territory: " + this.city.totalFood + "\n";
        prodLabel.Text = "Production\n" +
                            "    Worked: " + this.city.workedProduction + "\n" +
                            "    Stored: " + this.city.storedProduction + "\n" +
                            "    In Territory: " + this.city.totalProduction + "\n";

        PopulateUnitQueueUI(this.city);
    }

    // overload to accept a Unit node and still perform the RefreshUI() functions
    public void RefreshUI(Unit u)
    {
        RefreshUI();
    }

    public City GetCity()
    {
        return city;
    }

    public override void _Process(double delta)
    {

    }
}
