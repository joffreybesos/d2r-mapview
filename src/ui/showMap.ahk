#SingleInstance, Force
SendMode Input
SetWorkingDir, %A_ScriptDir%

ShowMap(ByRef settings, ByRef mapHwnd1, ByRef mapImage, ByRef gameMemoryData, ByRef uiData) {
    
    scale:= settings["scale"]
    leftMargin:= settings["leftMargin"]
    topMargin:= settings["topMargin"]
    opacity:= settings["opacity"]
    levelNo:= gameMemoryData["levelNo"]
    
    levelScale := mapImage["levelScale"]
    levelxmargin := mapImage["levelxmargin"]
    levelymargin := mapImage["levelymargin"]
    scale := levelScale * scale
    leftMargin := leftMargin + levelxmargin
    topMargin := topMargin + levelymargin

    if (settings["centerMode"]) {
        scale:= settings["centerModeScale"]
        serverScale := settings["serverScale"]
        opacity:= settings["centerModeOpacity"]
    } else {
        serverScale := 2 
    }

    StartTime := A_TickCount
    Angle := 45
    padding := settings["padding"]
    If !pToken := Gdip_Startup()
    {
        MsgBox "Gdiplus failed to start. Please ensure you have gdiplus on your system"
        ExitApp
    }
    
    pBitmap := Gdip_CreateBitmapFromFile(mapImage.sFile)
    If !pBitmap
    {
        WriteLog("ERROR: Could not load map image " mapImage.sFile)
        ExitApp
    }
    
    Width := Gdip_GetImageWidth(pBitmap)
    Height := Gdip_GetImageHeight(pBitmap)

    if (mapImage["prerotated"]) {
        RWidth := Width
        RHeight := Height
        Width := mapImage["originalWidth"]
        Height := mapImage["originalHeight"]
    } else {
        Gdip_GetRotatedDimensions(Width, Height, Angle, RWidth, RHeight)
    }

    scaledWidth := (RWidth * scale)
    scaledHeight := (RHeight * 0.5) * scale
    rotatedWidth := RWidth * scale
    rotatedHeight := RHeight * scale

    hbm := CreateDIBSection(rotatedWidth, rotatedHeight)
    hdc := CreateCompatibleDC()
    obm := SelectObject(hdc, hbm)
    Gdip_SetSmoothingMode(G, 4) 
    G := Gdip_GraphicsFromHDC(hdc)
    
    if (!mapImage["prerotated"]) {
        pBitmap := Gdip_RotateBitmapAtCenter(pBitmap, Angle) ; rotates bitmap for 45 degrees. Disposes of pBitmap.
    }

    if (settings["centerMode"]) {
        ; get relative position of player in world
        ; xpos is absolute world pos in game
        ; each map has offset x and y which is absolute world position
        xPosDot := ((gameMemoryData["xPos"] - mapImage["mapOffsetX"]) * serverScale) + padding
        yPosDot := ((gameMemoryData["yPos"] - mapImage["mapOffsetY"]) * serverScale) + padding

        correctedPos := findNewPos(xPosDot, yPosDot, (Width/2), (Height/2), scaledWidth, scaledHeight, scale)
        xPosDot := correctedPos["x"]
        yPosDot := correctedPos["y"]

        Gdip_DrawImage(G, pBitmap, 0, 0, scaledWidth, scaledHeight, 0, 0, RWidth, RHeight, opacity)
        WinGetPos, windowLeftMargin, windowTopMargin , gameWidth, gameHeight, %gameWindowId% 
        leftMargin := (gameWidth/2) - xPosDot + (settings["centerModeXoffset"] /2) + windowLeftMargin
        , topMargin := (gameHeight/2) - yPosDot + (settings["centerModeYoffset"] /2) + windowTopMargin

        UpdateLayeredWindow(mapHwnd1, hdc, 0, 0, scaledWidth, scaledHeight)
        WinMove, ahk_id %mapHwnd1%,, leftMargin, topMargin
        ; win move is now handled in movePlayerMap.ahk
    } else {
        Gdip_DrawImage(G, pBitmap, 0, 0, scaledWidth, scaledHeight, 0, 0, RWidth, RHeight, opacity)
        UpdateLayeredWindow(mapHwnd1, hdc, , , scaledWidth, scaledHeight)
        WinGetPos, windowLeftMargin, windowTopMargin , gameWidth, gameHeight, %gameWindowId% 
        WinMove, ahk_id %mapHwnd1%,, windowLeftMargin+leftMargin, windowTopMargin+topMargin
        WinMove, ahk_id %unitHwnd1%,, windowLeftMargin+leftMargin, windowTopMargin+topMargin
    }

    SelectObject(hdc, obm)
    DeleteObject(hbm)
    DeleteDC(hdc)
    
    Gdip_DeleteGraphics(G)
    Gdip_DisposeImage(pBitmap)
    ElapsedTime := A_TickCount - StartTime
    ; WriteLogDebug("Drew map " ElapsedTime " ms taken")
    uiData := { "scaledWidth": scaledWidth, "scaledHeight": scaledHeight, "sizeWidth": Width, "sizeHeight": Height, "rotatedWidth": rotatedWidth, "rotatedHeight": rotatedHeight }
}