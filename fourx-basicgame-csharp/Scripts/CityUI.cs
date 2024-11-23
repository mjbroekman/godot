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
    }

    public City GetCity()
    {
        return city;
    }

    public override void _Process(double delta)
    {

    }
}
