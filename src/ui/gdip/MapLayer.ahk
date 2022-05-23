#NoEnv

class MapLayer {
    hbm :=
    hdc :=
    obm :=
    G :=
    MapLayerHwnd :=

    __new(ByRef settings, ByRef gameMemoryData) {
        SetFormat Integer, D
        gameClientArea := getWindowClientArea()
        gameWindowX := gameClientArea["X"]
        gameWindowY := gameClientArea["Y"]
        gameWindowWidth := gameClientArea["W"]
        gameWindowHeight := gameClientArea["H"]
        downloadMapImage(settings, gameMemoryData, imageData, 0)
        this.imageData := imageData

        Gui, Map: -Caption +E0x20 +E0x80000 +LastFound +AlwaysOnTop +ToolWindow +OwnDialogs 
        this.MapLayerHwnd := WinExist()
        Gui, Map: Show, NA

        
        levelNo := gameMemoryData["levelNo"]
        IniRead, levelScale, mapconfig.ini, %levelNo%, scale, 1.0
        IniRead, levelxmargin, mapconfig.ini, %levelNo%, x, 0
        IniRead, levelymargin, mapconfig.ini, %levelNo%, y, 0
        this.imageData["levelScale"] := levelScale
        this.imageData["levelxmargin"] := levelxmargin
        this.imageData["levelymargin"] := levelymargin
        this.scale:= settings["scale"]
        this.leftMargin:= settings["leftMargin"]
        this.topMargin:= settings["topMargin"]
        this.opacity:= settings["opacity"]
        this.sFile := imageData["sFile"] ; downloaded map image
        this.levelNo:= gameMemoryData["levelNo"]
        this.levelScale := imageData["levelScale"]
        this.levelxmargin := imageData["levelxmargin"]
        this.levelymargin := imageData["levelymargin"]
        this.scale := this.levelScale * this.scale
        this.leftMargin := this.leftMargin + this.levelxmargin
        this.topMargin := this.topMargin + this.levelymargin
        if (settings["centerMode"]) {
            this.scale:= settings["centerModeScale"]
            this.serverScale := settings["serverScale"]
            this.opacity:= settings["centerModeOpacity"]
        } else {
            this.serverScale := 2 
        }
        this.padding := settings["padding"]

        Gdip_Startup()
        DetectHiddenWindows, On
        this.Angle := 45
        this.pBitmap := Gdip_CreateBitmapFromFile(this.sFile)
        this.Width := Gdip_GetImageWidth(this.pBitmap)
        this.Height := Gdip_GetImageHeight(this.pBitmap)

        if (imageData["prerotated"]) {
            this.RWidth := this.Width
            this.RHeight := this.Height
            this.Width := imageData["originalWidth"]
            this.Height := imageData["originalHeight"]
        } else {
            Gdip_GetRotatedDimensions(this.Width, this.Height, this.Angle, this.RWidth, this.RHeight)
        }

        this.scaledWidth := (this.RWidth * this.scale)
        this.scaledHeight := (this.RHeight * 0.5) * this.scale
        this.rotatedWidth := this.RWidth * this.scale
        this.rotatedHeight := this.RHeight * this.scale

        this.hbm := CreateDIBSection(this.rotatedWidth, this.rotatedHeight)
        this.hdc := CreateCompatibleDC()
        this.obm := SelectObject(this.hdc, this.hbm)
        Gdip_SetSmoothingMode(this.G, 4) 
        this.G := Gdip_GraphicsFromHDC(this.hdc)
        
        if (!imageData["prerotated"]) {
            this.pBitmap := Gdip_RotateBitmapAtCenter(this.pBitmap, this.Angle) ; rotates bitmap for 45 degrees. Disposes of pBitmap.
        }

        mapHwnd1 := this.MapLayerHwnd

        if (settings["centerMode"]) {
            ; get relative position of player in world
            ; xpos is absolute world pos in game
            ; each map has offset x and y which is absolute world position
            xPosDot := ((gameMemoryData["xPos"] - imageData["mapOffsetX"]) * this.serverScale) + this.padding
            yPosDot := ((gameMemoryData["yPos"] - imageData["mapOffsetY"]) * this.serverScale) + this.padding

            correctedPos := findNewPos(xPosDot, yPosDot, (this.Width/2), (this.Height/2), this.scaledWidth, this.scaledHeight, this.scale)
            xPosDot := correctedPos["x"]
            yPosDot := correctedPos["y"]

            Gdip_DrawImage(this.G, this.pBitmap, 0, 0, this.scaledWidth, this.scaledHeight, 0, 0, this.RWidth, this.RHeight, this.opacity)
            ;WinGetPos, gameWindowX, gameWindowY , gameWindowWidth, gameWindowHeight, %gameWindowId% 
            this.leftMargin := (gameWindowWidth/2) - xPosDot + (settings["centerModeXoffset"] /2) + gameWindowX
            this.topMargin := (gameWindowHeight/2) - yPosDot + (settings["centerModeYoffset"] /2) + gameWindowY
            ; pPen := Gdip_CreatePen(0xff00FF00, 5)
            ; Gdip_DrawRectangle(this.G, pPen, 0, 0, this.rotatedWidth, this.rotatedHeight)
            UpdateLayeredWindow(mapHwnd1, this.hdc, 0, 0, this.scaledWidth, this.scaledHeight)
            WinMove, ahk_id %mapHwnd1%,, this.leftMargin, this.topMargin
            ; win move is now handled in movePlayerMap.ahk
        } else {
            Gdip_DrawImage(this.G, this.pBitmap, 0, 0, this.scaledWidth, this.scaledHeight, 0, 0, this.RWidth, this.RHeight, this.opacity)
            UpdateLayeredWindow(mapHwnd1, this.hdc, , , this.scaledWidth, this.scaledHeight)
            ;WinGetPos, gameWindowX, gameWindowY , gameWindowWidth, gameWindowHeight, %gameWindowId% 
            WinMove, ahk_id %mapHwnd1%,, gameWindowX+this.leftMargin, gameWindowY+this.topMargin
            WinMove, ahk_id %unitHwnd1%,, gameWindowX+this.leftMargin, gameWindowY+this.topMargin
        }

    }

    show() {
        Gui, Map: Show, NA
    }

    hide() {
        Gui, Map: Hide
    }

    delete() {
        SelectObject(this.hdc, this.obm)
        DeleteObject(this.hbm)
        DeleteDC(this.hdc)
        Gui, Map: Destroy
    }
}
