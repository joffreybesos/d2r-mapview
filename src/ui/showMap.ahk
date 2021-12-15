#SingleInstance, Force
SendMode Input
SetWorkingDir, %A_ScriptDir%

ShowMap(settings, mapHwnd1, mapData, gameMemoryData, ByRef uiData) {
    mapGuiWidth:= settings["maxWidth"]
    scale:= settings["scale"]
    leftMargin:= settings["leftMargin"]
    topMargin:= settings["topMargin"]
    opacity:= settings["opacity"]
    sFile := mapData["sFile"] ; downloaded map image
    levelNo:= gameMemoryData["levelNo"]
    IniRead, levelScale, mapconfig.ini, %levelNo%, scale, 1.0
    scale := levelScale * scale
    scale := 1.36
    IniRead, levelxmargin, mapconfig.ini, %levelNo%, x, 0
    IniRead, levelymargin, mapconfig.ini, %levelNo%, y, 0
    leftMargin := leftMargin + levelxmargin
    topMargin := topMargin + levelymargin

    ; WriteLog("maxGuiWidth := " maxGuiWidth)
    ; WriteLog("scale := " scale)
    ; WriteLog("leftMargin := " leftMargin)
    ; WriteLog("topMargin := " topMargin)
    ; WriteLog("opacity := " opacity)
    ; WriteLog(mapData["sFile"])
    ; WriteLog(mapData["leftTrimmed"])
    ; WriteLog(mapData["topTrimmed"])
    ; WriteLog(mapData["mapOffsetX"])
    ; WriteLog(mapData["mapOffsety"])
    ; WriteLog(mapData["mapwidth"])
    ; WriteLog(mapData["mapheight"])

    ; WriteLog(gameMemoryData["xPos"])
    ; WriteLog(gameMemoryData["yPos"])

    StartTime := A_TickCount
    serverScale := 5
    Angle := 45
    padding := 150
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
    Gdip_GetRotatedDimensions(Width, Height, Angle, RWidth, RHeight)

    scaledWidth := (RWidth * scale)
    scaledHeight := (RHeight * 0.5) * scale
    rotatedWidth := RWidth * scale
    rotatedHeight := RHeight * scale

    ; get relative position of player in world
    ; xpos is absolute world pos in game
    ; each map has offset x and y which is absolute world position
    xPosDot := ((gameMemoryData["xPos"] - mapData["mapOffsetX"]) * serverScale) + padding
    yPosDot := ((gameMemoryData["yPos"] - mapData["mapOffsetY"]) * serverScale) + padding
    correctedPos := findNewPos(xPosDot, yPosDot, (Width/2), (Height/2), scaledWidth, scaledHeight, scale)
    xPosDot := correctedPos["x"]
    yPosDot := correctedPos["y"]

    hbm := CreateDIBSection(rotatedWidth, rotatedHeight)
    hdc := CreateCompatibleDC()
    obm := SelectObject(hdc, hbm)
    Gdip_SetSmoothingMode(G, 4) 
    G := Gdip_GraphicsFromHDC(hdc)
    pBitmap := Gdip_RotateBitmapAtCenter(pBitmap, Angle) ; rotates bitmap for 45 degrees. Disposes of pBitmap.

      ; draw player
    pPen := Gdip_CreatePen(0xff00FFFF, 6)
    Gdip_DrawRectangle(G, pPen, xPosDot-3, (yPosDot/2)-2 , 6, 6)
    ; Gdip_DrawRectangle(G, pPen, 0, 0, scaledWidth, scaledHeight) ;outline for whole map used for troubleshooting
    Gdip_DeletePen(pPen)

    Gdip_DrawImage(G, pBitmap, 0, 0, scaledWidth, scaledHeight) ;, 0, 0, RWidth, RHeight, opacity)

    
    leftMargin := (A_ScreenWidth/2) - xPosDot
    topMargin := (A_ScreenHeight/2) - yPosDot - 10
    UpdateLayeredWindow(mapHwnd1, hdc, leftMargin, topMargin, scaledWidth, scaledHeight)
    SelectObject(hdc, obm)
    DeleteObject(hbm)
    DeleteDC(hdc)
    Gdip_DeleteGraphics(G)
    Gdip_DisposeImage(pBitmap)
    ElapsedTime := A_TickCount - StartTime
    ;WriteLogDebug("Drew map " ElapsedTime " ms taken")
    uiData := { "scaledWidth": scaledWidth, "scaledHeight": scaledHeight, "sizeWidth": Width, "sizeHeight": Height }
}
