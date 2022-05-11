#Include %A_ScriptDir%\types\Area.ahk

class Areas {
    mapSeed := 0
    difficulty := 0
    json :=             ; parsed JSON fro ALL areas

    __new(ByRef mapSeed, ByRef difficulty) {
        this.mapSeed := mapSeed
        this.difficulty := difficulty
		this.cacheFolder := A_Temp
        generateAllMapData(mapSeed, difficulty, this.cacheFolder)
    }

	getArea(ByRef mapId, renderScale := 2) {
		thisArea := new Area(this.mapSeed, this.difficulty, mapId, this.cacheFolder)
		thisArea.setImage(this.stitchMapsPadding(mapId, 75, renderScale))
		return thisArea
	}

    stitchMapsPadding(ByRef mapId, padding := 75, renderScale := 2) {
        areasToStitch := []
        areaNosToStitch := this.getStitchedMaps(mapId)
        for k, extMapId in areaNosToStitch
        {
			thisArea := new Area(this.mapSeed, this.difficulty, extMapId, this.cacheFolder)
            if (extMapId == mapId) {
                stitchedDimensions := { "x": (thisArea.json.offset.x), "y": (thisArea.json.offset.y), "width": (thisArea.json.size.width), "height": (thisArea.json.size.height) }
            }
            areasToStitch.push(thisArea)
        }

        pToken := Gdip_Startup()
        stitchedWidth := (stitchedDimensions.width + padding) * renderScale
        stitchedHeight := (stitchedDimensions.height + padding) * renderScale
        pBitmap := Gdip_CreateBitmap(stitchedWidth, stitchedHeight)
        hbm := CreateDIBSection(stitchedWidth, stitchedHeight)
        hdc := CreateCompatibleDC()
        obm := SelectObject(hdc, hbm)
        Gdip_SetSmoothingMode(G, 4) 
        G := Gdip_GraphicsFromImage(pBitmap)
        ;pBitmap := Gdip_RotateBitmapAtCenter(pBitmap, 45) ; rotates bitmap for 45 degrees. Disposes of pBitmap.
        for k, thisArea in areasToStitch
        {
            x := thisArea.json.offset.x - stitchedDimensions.x + (padding /2)
            y := thisArea.json.offset.y - stitchedDimensions.y + (padding /2)
            Gdip_DrawImage(G, thisArea.rawBitmap, x * renderScale, y * renderScale, thisArea.bmpWidth * renderScale, thisArea.bmpHeight * renderScale)
        }

        SelectObject(hdc, obm)
        DeleteObject(hbm)
        DeleteDC(hdc)
        Gdip_DeleteGraphics(G)
		return pBitmap
    }


    getStitchedMaps(ByRef mapId) {
        switch (mapId) {
			;// act 1
			case 1: return [1,2,3,4,17]
			case 2: return [1,2,3,4,17]
			case 3: return [1,2,3,4,17]
			case 4: return [1,2,3,4,17]
			case 17: return [1,2,3,4,17]
			case 5: return [5,6,7,26,27,28]
			case 6: return [5,6,7,26,27,28]
			case 7: return [5,6,7,26,27,28]
			case 26: return [5,6,7,26,27,28]
			case 27: return [5,6,7,26,27,28]
			case 28: return [5,6,7,26,27,28]
			case 32: return [32,33]
			case 33: return [32,33]

			;// act 2
			case 40: return [40,41,42,43,44,45]
			case 41: return [40,41,42,43,44,45]
			case 42: return [40,41,42,43,44,45]
			case 43: return [40,41,42,43,44,45]
			case 44: return [40,41,42,43,44,45]
			case 45: return [40,41,42,43,44,45]

			;// act 3
			case 75: return [75,76,77,78,79,80,81,82,83]
			case 76: return [75,76,77,78,79,80,81,82,83]
			case 77: return [75,76,77,78,79,80,81,82,83]
			case 78: return [75,76,77,78,79,80,81,82,83]
			case 79: return [75,76,77,78,79,80,81,82,83]
			case 80: return [75,76,77,78,79,80,81,82,83]
			case 81: return [75,76,77,78,79,80,81,82,83]
			case 82: return [75,76,77,78,79,80,81,82,83]
			case 83: return [75,76,77,78,79,80,81,82,83]

			;//act 4
			case 103: return [103,104,105,106]
			case 104: return [103,104,105,106]
			case 105: return [103,104,105,106]
			case 106: return [103,104,105,106]
			case 107: return [107,108]
			case 108: return [107,108]

			;//act 5
			case 109: return [109,110,111,112]
			case 110: return [109,110,111,112]
			case 111: return [109,110,111,112]
			case 112: return [109,110,111,112]
		}
		return [mapId]

    }

}



