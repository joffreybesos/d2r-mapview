
class Map {


    padding := 150
    scaledWidth := 
    scaledHeight := 
    Width := 
    Height := 

    __new(ByRef imageData, ByRef gameMemoryData, ByRef settings, ByRef mapHwnd1) {
        
        this.sFile := imageData["sFile"] ; downloaded map image
        this.levelNo:= gameMemoryData["levelNo"]
        this.scale:= settings["centerModeScale"]
        this.serverScale := settings["serverScale"]
        this.opacity:= settings["centerModeOpacity"]

        this.pToken := Gdip_Startup()
        pBitmap := Gdip_CreateBitmapFromFile(this.sFile)
        RWidth := Gdip_GetImageWidth(pBitmap)
        RHeight := Gdip_GetImageHeight(pBitmap)
        this.Width := imageData["originalWidth"]
        this.Height := imageData["originalHeight"]
        this.scaledWidth := RWidth * this.scale
        this.scaledHeight := RHeight * this.scale
        
        ; OutputDebug, % this.sFile " " this.Width " " this.Height " " this.scaledWidth " " this.scaledHeight "b " this.serverScale

        hbm := CreateDIBSection(this.scaledWidth, this.scaledHeight)
        hdc := CreateCompatibleDC()
        obm := SelectObject(hdc, hbm)
        Gdip_SetSmoothingMode(G, 4) 
        G := Gdip_GraphicsFromHDC(hdc)
        
        ; get relative position of player in world
        ; xpos is absolute world pos in game
        ; each map has offset x and y which is absolute world position
        xPosDot := ((gameMemoryData["xPos"] - imageData["mapOffsetX"]) * this.serverScale) + this.padding
        yPosDot := ((gameMemoryData["yPos"] - imageData["mapOffsetY"]) * this.serverScale) + this.padding

        correctedPos := findNewPos(xPosDot, yPosDot, (this.Width/2), (this.Height/2), this.scaledWidth, this.scaledHeight / 2, this.scale)
        xPosDot := correctedPos["x"]
        yPosDot := correctedPos["y"]

        Gdip_DrawImage(G, pBitmap, 0, 0, this.scaledWidth, this.scaledHeight / 2, 0, 0, RWidth, RHeight, this.opacity)

        UpdateLayeredWindow(mapHwnd1, hdc, 0, 0, this.scaledWidth, this.scaledHeight / 2)
        ; win move is now handled in movePlayerMap.ahk
        
        ; seed := gameMemoryData["mapSeed"]
        ; sOutput := A_ScriptDir "\" seed "_" levelNo ".png"
        ; Gdip_SaveBitmapToFile(pBitmap, sOutput)

        SelectObject(hdc, obm)
        DeleteObject(hbm)
        DeleteDC(hdc)
        Gdip_DeleteGraphics(G)
        Gdip_DisposeImage(pBitmap)

    }
}