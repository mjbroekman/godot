using Godot;
using System;

public partial class CityUI : Panel
{
    Label cityName, popLabel, foodLabel, prodLabel;
    
    // City data
    City city;

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
        foodLabel.Text = "Food: " + this.city.workedFood + " (Total: " + this.city.totalFood + " )";
        prodLabel.Text = "Production: " + this.city.workedProduction + " (Total: " + this.city.totalProduction + " )";
    }

    public override void _Process(double delta)
    {

    }
}
