using Godot;
using System;
using System.Collections.Generic;

public class Civilization
{
    // Civilization ID number for reference
    public int id;

    // Civilization name
    public string name;

    // List of controlled cities
    public List<City> cities;

    // Color of civilization on  the map
    public Color territoryColor;

    // The ID of the alt color tile
    public int territoryColorAltTileId;

    // Is this the player civilization?
    public bool playerCiv;

    public Civilization()
    {
        cities = new List<City>();
    }

    public override string ToString()
    {
        return $"{name} - {id} - {playerCiv.ToString()} - {territoryColor.ToString()}";
    }

    public void SetRandomColor()
    {
        Random r = new Random();
        this.territoryColor = new Color(r.Next(255)/255.0f,r.Next(255)/255.0f,r.Next(255)/255.0f);
    }
}
