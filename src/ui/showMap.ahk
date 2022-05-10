#SingleInstance, Force
SendMode Input
SetWorkingDir, %A_ScriptDir%

ShowMap(settings, mapHwnd1, imageData, gameMemoryData, ByRef uiData) {
    
    scale:= settings["scale"]
    leftMargin:= settings["leftMargin"]
    topMargin:= settings["topMargin"]
    opacity:= settings["opacity"]
    sFile := imageData["sFile"] ; downloaded map image
    levelNo:= gameMemoryData["levelNo"]
    levelScale := imageData["levelScale"]
    levelxmargin := imageData["levelxmargin"]
    levelymargin := imageData["levelymargin"]
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

    ; WriteLog("maxGuiWidth := " maxGuiWidth)
    ; WriteLog("scale := " scale)
    ; WriteLog("leftMargin := " leftMargin)
    ; WriteLog("topMargin := " topMargin)
    ; WriteLog("opacity := " opacity)
    ; WriteLog(imageData["sFile"])
    ; WriteLog(imageData["leftTrimmed"])
    ; WriteLog(imageData["topTrimmed"])
    ; WriteLog(imageData["mapOffsetX"])
    ; WriteLog(imageData["mapOffsety"])
    ; WriteLog(imageData["mapwidth"])
    ; WriteLog(imageData["mapheight"])
    ; WriteLog(imageData["prerotated"])

    ; WriteLog(gameMemoryData["xPos"])
    ; WriteLog(gameMemoryData["yPos"])

    StartTime := A_TickCount
    Angle := 45
    padding := settings["padding"]
    If !pToken := Gdip_Startup()
    {
        MsgBox "Gdiplus failed to start. Please ensure you have gdiplus on your system"
        ExitApp
    }

    pBitmap := Gdip_CreateBitmapFromFile(sFile)
    If !pBitmap
    {
        WriteLog("ERROR: Could not load map image " sFile)
        ExitApp
    }
    Width := Gdip_GetImageWidth(pBitmap)
    Height := Gdip_GetImageHeight(pBitmap)

    if (imageData["prerotated"]) {
        RWidth := Width
        RHeight := Height
        Width := imageData["originalWidth"]
        Height := imageData["originalHeight"]
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
    ;Gdip_SetSmoothingMode(G, 4) 
    G := Gdip_GraphicsFromHDC(hdc)
    
    if (!imageData["prerotated"]) {
        pBitmap := Gdip_RotateBitmapAtCenter(pBitmap, Angle, 0, 0) ; rotates bitmap for 45 degrees. Disposes of pBitmap.
    }

    ; asdf := A_TickCount - StartTime
    ; OutputDebug, % asdf "`n"

    if (settings["centerMode"]) {
        ; get relative position of player in world
        ; xpos is absolute world pos in game
        ; each map has offset x and y which is absolute world position
        xPosDot := ((gameMemoryData["xPos"] - imageData["mapOffsetX"]) * serverScale) + padding
        yPosDot := ((gameMemoryData["yPos"] - imageData["mapOffsetY"]) * serverScale) + padding

        correctedPos := findNewPos(xPosDot, yPosDot, (Width/2), (Height/2), scaledWidth, scaledHeight, scale)
        xPosDot := correctedPos["x"]
        yPosDot := correctedPos["y"]
        Gdip_SetBitmapTransColor(pBitmap, 0x000000)

        Gdip_DrawImage(G, pBitmap, 0, 0, scaledWidth, scaledHeight, 0, 0, RWidth, RHeight, opacity)

        UpdateLayeredWindow(mapHwnd1, hdc, 0, 0, scaledWidth, scaledHeight)
        ; win move is now handled in movePlayerMap.ahk
    } else {
        Gdip_DrawImage(G, pBitmap, 0, 0, scaledWidth, scaledHeight, 0, 0, RWidth, RHeight, opacity)
        UpdateLayeredWindow(mapHwnd1, hdc, , , scaledWidth, scaledHeight)
        WinGetPos, windowLeftMargin, windowTopMargin , gameWidth, gameHeight, %gameWindowId% 
        WinMove, ahk_id %mapHwnd1%,, windowLeftMargin+leftMargin, windowTopMargin+topMargin
        WinMove, ahk_id %unitHwnd1%,, windowLeftMargin+leftMargin, windowTopMargin+topMargin
    }

    ; WriteLog(scaledWidth " " scaledHeight " " RWidth " " RHeight " " xPosDot " " yPosDot)
    ; seed := gameMemoryData["mapSeed"]
    ; sOutput := A_ScriptDir "\" seed "_" levelNo ".png"
    ; Gdip_SaveBitmapToFile(pBitmap, sOutput)
    ; WriteLog(Width " " He ight " " RWidth " " RHeight " " scale)

    SelectObject(hdc, obm)
    DeleteObject(hbm)
    DeleteDC(hdc)
    Gdip_DeleteGraphics(G)
    ;Gdip_DisposeImage(pBitmap)
    ElapsedTime := A_TickCount - StartTime
    ; WriteLogDebug("Drew map " ElapsedTime " ms taken")
    uiData := { "scaledWidth": scaledWidth, "scaledHeight": scaledHeight, "sizeWidth": Width, "sizeHeight": Height, "rotatedWidth": rotatedWidth, "rotatedHeight": rotatedHeight }
}