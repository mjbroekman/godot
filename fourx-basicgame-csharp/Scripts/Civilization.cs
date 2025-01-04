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

    // List of units
    public List<Unit> units;

    // Color of civilization on  the map
    public Color territoryColor;

    // The ID of the alt color tile
    public int territoryColorAltTileId;

    // Is this the player civilization?
    public bool playerCiv;

    // Private random number generator
    private Random civRNG = new Random();

    // Max Units
    public int maxUnitsPerCity = 3;
    public int maxUnits;

    public Civilization()
    {
        cities = new List<City>();
        units = new List<Unit>();
        maxUnits = 3;
    }

    public double GetNextCivDouble()
    {
        return civRNG.NextDouble();
    }

    public double GetNextCivInt32()
    {
        return civRNG.Next();
    }

    public double GetNextCivInt64()
    {
        return civRNG.NextInt64();
    }

    public override string ToString()
    {
        return $"{name} - {id}";
    }

    public void SetRandomColor()
    {
        Random r = new Random();
        this.territoryColor = new Color(r.Next(255)/255.0f,r.Next(255)/255.0f,r.Next(255)/255.0f);
    }

    public void ProcessTurn()
    {
        List<City> tempCities = cities;
        foreach (City c in tempCities) {
            c.ProcessTurn();
        }

        if ( ! playerCiv ) {
            List<City> tempBotCities = cities;
            foreach (City c in tempBotCities) {
                int chance = civRNG.Next(30);

                if ( chance > 27 ) {
                    c.AddUnitToBuildQueue(new Warrior());
                }
                if ( chance > 28 ) {
                    c.AddUnitToBuildQueue(new Settler());
                }
            }

            // Move units randomly
            List<Settler> citiesToFound = new List<Settler>();
            List<Unit> tempBotUnits = units;
            foreach (Unit u in tempBotUnits) {
                if ( u.curHealth == u.maxHealth) {
                    u.RandomMove();
                } else {
                    if ( civRNG.Next(5) > u.maxHealth ) u.RandomMove();
                }
                if (u is Settler && civRNG.Next(10) > 8) {
                    Settler s = u as Settler;
                    citiesToFound.Add(s);
                }
            }
            for (int i = 0; i < citiesToFound.Count; i++) {
                citiesToFound[i].FoundCity();
            }
        }

        maxUnits = this.cities.Count * this.maxUnitsPerCity;
    }
}
