using Godot;
using System;
using System.Collections.Generic;

public partial class HighlightLayer : TileMapLayer
{
    int width;
    int height;

    List<Hex> currentHighlight;

    City currentCityHighlight = null;

    public void SetupHighlightLayer(int wid, int hig)
    {
        this.width = wid;
        this.height = hig;
        this.currentHighlight = new List<Hex>();

        for (int x = 0; x < this.width; x++) {
            for (int y = 0; y < this.height; y++) {
                SetCell(new Vector2I(x, y), 0, new Vector2I(0,3));
            }
        }
        Visible = false;
    }

    public void SetHighlightLayerForCity(City c)
    {
        ResetHighlightLayer();

        currentCityHighlight = c;
        foreach (Hex h in c.territory) {
            currentHighlight.Add(h);
            SetCell(h.coordinates, -1);
        }

        foreach (Hex h in c.borderTilePool) {
            currentHighlight.Add(h);
            SetCell(h.coordinates, -1);
        }
        Visible = true;
    }

    public void RefreshHighlight() {
        City tmp = currentCityHighlight;
        ResetHighlightLayer();
        if (tmp != null) SetHighlightLayerForCity(tmp);
    }

    public void ResetHighlightLayer()
    {
        foreach (Hex hex in currentHighlight) {
            SetCell(hex.coordinates, 0, new Vector2I(0,3));
        }
        Visible = false;
        currentCityHighlight = null;
    }
}
