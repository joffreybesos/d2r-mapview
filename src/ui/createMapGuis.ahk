
class MapGuis {
    mapGuis := []
    unitGuis := []
    mapImageList := []
    __new(ByRef settings) {
        Loop, 136 {
            Gui, Map%A_Index%: Destroy
        }
        
        this.mapGuis := []
        this.unitGuis := []
        ; create GUI windows
        
        Loop, 136
        {
            Gui, Map%A_Index%: -Caption +E0x20 +E0x80000 +LastFound +AlwaysOnTop +ToolWindow +OwnDialogs
            thisMapGui := WinExist()
            this.mapGuis[A_Index] := thisMapGui

            Gui, Units%A_Index%: -Caption +E0x20 +E0x80000 +E0x00080000 +LastFound +AlwaysOnTop +ToolWindow +OwnDialogs 
            thisUnitGui := WinExist()
            this.unitsGuis[A_Index] := thisUnitGui
        }
    }


    hide() {
        ; hide maps
        Loop, 136 {
            Gui, Map%A_Index%: Hide ; hide map
            Gui, Units%A_Index%: Hide ; hide units
        }
    }

    downloadMapImages(ByRef mapList, ByRef gameMemoryData) {
        for k, thisLevelNo in mapList
        {
            this.mapImageList[thisLevelNo] := new MapImage(settings, gameMemoryData["mapSeed"], gameMemoryData["difficulty"], thisLevelNo)
        }
    }

    drawMaps(ByRef mapList, ByRef gameMemoryData) {
        this.show(mapList)
        for k, thisLevelNo in mapList {
            ; OutputDebug, % "Drawing map " thisLevelNo "`n"
            this.drawMap(thisLevelNo, gameMemoryData)
        }
        
    }

    show(ByRef mapList) {
        for k, thisLevelNo in mapList
        {
            Gui, Map%thisLevelNo%: Show, NA
            Gui, Units%thisLevelNo%: Show, NA
        }
    }


    getMapClientArea(windowId) {
        VarSetCapacity(RECT, 16, 0)
        DllCall("user32\GetClientRect", Ptr,windowId, Ptr,&RECT)
        DllCall("user32\ClientToScreen", Ptr,windowId, Ptr,&RECT)
        Win_Client_X := NumGet(&RECT, 0, "Int")
        Win_Client_Y := NumGet(&RECT, 4, "Int")
        Win_Client_W := NumGet(&RECT, 8, "Int")
        Win_Client_H := NumGet(&RECT, 12, "Int")
        return { "x": Win_Client_X, "y": Win_Client_Y, "width": Win_Client_W, "height": Win_Client_H }
    }

    drawMap(ByRef levelNo, ByRef gameMemoryData) {
        scale := settings["centerModeScale"]
        renderScale := settings["serverScale"] 
        thisMap := this.mapImageList[levelNo]
        Gdip_Startup()
        ; OutputDebug, % thisMap.sFile "`n"
        pBitmap := Gdip_CreateBitmapFromFile(this.mapImageList[levelNo].sFile)

        rotatedWidth := Gdip_GetImageWidth(pBitmap)
        rotatedHeight := Gdip_GetImageHeight(pBitmap)
        this.mapImageList[levelNo].rotatedWidth := rotatedWidth
        this.mapImageList[levelNo].rotatedHeight := rotatedHeight

        originalWidth := this.mapImageList[levelNo].originalWidth
        originalHeight := this.mapImageList[levelNo].originalHeight

        mapScaledWidth := rotatedWidth * scale
        mapScaledHeight := rotatedHeight * scale
        this.mapImageList[levelNo].mapScaledWidth := mapScaledWidth
        this.mapImageList[levelNo].mapScaledHeight := mapScaledHeight

        hbm := CreateDIBSection(mapScaledWidth, mapScaledHeight)
        hdc := CreateCompatibleDC()
        obm := SelectObject(hdc, hbm)
        Gdip_SetSmoothingMode(G, 4) 
        G := Gdip_GraphicsFromHDC(hdc)
        ; pPen := Gdip_CreatePen(0x44ff0000, 5)
        Gdip_DrawImage(G, pBitmap, 0, 0, mapScaledWidth, mapScaledHeight / 2, 0, 0, rotatedWidth, rotatedHeight, 0.7)
        ; Gdip_DrawRectangle(G, pPen, 0, 0, mapScaledWidth, mapScaledHeight/2)
        ; Gdip_DeletePen(pPen)
        mapGuiHwnd := this.mapGuis[levelNo]
        UpdateLayeredWindow(mapGuiHwnd, hdc, 0, 0, mapScaledWidth, mapScaledHeight)
        playerX := (gameMemoryData["xPos"] - this.mapImageList[levelNo].mapOffsetX) * renderScale
        playerY := (gameMemoryData["yPos"] - this.mapImageList[levelNo].mapOffsetY) * renderScale
        
        ; correctedPos := transformPosition(playerX, playerY, originalWidth / 2, originalHeight / 2, mapScaledWidth, mapScaledHeight, 2)
        correctedPos := findNewPos(playerX, playerY, (originalWidth/2), (originalHeight/2), mapScaledWidth, mapScaledHeight, scale)
        gameWindow := getWindowClientArea()
        mapPosX := ((gameWindow.W / 2) - correctedPos.x + gameWindow.X)
        mapPosY := ((gameWindow.H / 2) - correctedPos.y + gameWindow.Y) + (mapScaledHeight / 4)
        WinMove, ahk_id %mapGuiHwnd%,,mapPosX, mapPosY
        SelectObject(hdc, obm)
        DeleteObject(hbm)
        DeleteDC(hdc)
        
        Gdip_DeleteGraphics(G)
        Gdip_DisposeImage(pBitmap)

    }

    updateMapPositions(ByRef mapList, ByRef settings, ByRef d2rprocess, ByRef gameMemoryData) {
        for k, thisLevelNo in mapList {
            this.updateMapPosition(settings, d2rprocess, gameMemoryData, thisLevelNo)
        }
    }

    updateMapPosition(ByRef settings, ByRef d2rprocess, ByRef gameMemoryData, ByRef levelNo) {
        scale := settings["centerModeScale"]
        renderScale := settings["serverScale"] 
        ; player position
        pathAddress = gameMemoryData["pathAddress"]
        d2rprocess.readRaw(pathAddress, pPathBuffer, 16)
        , xPosOffset := NumGet(&pPathBuffer , 0x00, "UShort")
        , xPos := NumGet(&pPathBuffer , 0x02, "UShort")
        , yPosOffset := NumGet(&pPathBuffer , 0x04, "UShort")
        , yPos := NumGet(&pPathBuffer , 0x06, "UShort")
        , xPos := xPos + (xPosOffset / 65535)   ; get percentage
        , yPos := yPos + (yPosOffset / 65535)   ; get percentage
        rotatedWidth := this.mapImageList[levelNo].rotatedWidth
        rotatedHeight := this.mapImageList[levelNo].rotatedHeight
        originalWidth := this.mapImageList[levelNo].originalWidth
        originalHeight := this.mapImageList[levelNo].originalHeight
        mapScaledWidth := this.mapImageList[levelNo].mapScaledWidth
        mapScaledHeight := this.mapImageList[levelNo].mapScaledHeight

        ; calculate new position
        playerX := (gameMemoryData["xPos"] - this.mapImageList[levelNo].mapOffsetX) * renderScale
        playerY := (gameMemoryData["yPos"] - this.mapImageList[levelNo].mapOffsetY) * renderScale
        correctedPos := findNewPos(playerX, playerY, (originalWidth/2), (originalHeight/2), mapScaledWidth, mapScaledHeight, scale)
        ; correctedPos := transformPosition(playerX, playerY, originalWidth / 2, originalHeight / 2, mapScaledWidth, mapScaledHeight, scale)
        gameWindow := getWindowClientArea()
        mapPosX := ((gameWindow.W / 2) - correctedPos.x + gameWindow.X)
        mapPosY := ((gameWindow.H / 2) - correctedPos.y + gameWindow.Y) + (mapScaledHeight / 4)
        mapGuiHwnd := this.mapGuis[levelNo]
        WinMove, ahk_id %mapGuiHwnd%,,mapPosX, mapPosY
    }
}

; transformPosition(ByRef playerx, ByRef playery, ByRef centrex, ByRef centrey, ByRef mapScaledWidth, ByRef mapScaledHeight, ByRef scale) {
;     xdiff := playerx - centrex
;     , ydiff := playery - centrey
;     , angle := 0.785398    ;45 deg
;     , x := xdiff * cos(angle) - ydiff * sin(angle)
;     , y := xdiff * sin(angle) + ydiff * cos(angle)
;     , newx := mapScaledWidth / 2 + (x * scale)
;     , newy := ((mapScaledHeight / 2) + (y * scale))
;     return { x: newx, y: newy }
; }

