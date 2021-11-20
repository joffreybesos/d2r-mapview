#SingleInstance, Force
SendMode Input
SetWorkingDir, %A_ScriptDir%
#Include %A_ScriptDir%\ui\image\Gdip_ResizeBitmap.ahk
#Include %A_ScriptDir%\ui\image\Gdip_RotateBitmap.ahk

ShowMap(settings, mapData, gameMemoryData, ByRef uiData) {
    mapGuiWidth:= settings["maxWidth"]
    scale:= settings["scale"]
    leftMargin:= settings["leftMargin"]
    topMargin:= settings["topMargin"]
    opacity:= settings["opacity"]
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
    serverScale := 2 
    Angle := 45
    padding := 150

    
    sFile := mapData["sFile"] ; downloaded map image
    ; FileGetSize, sFileSize, %sFile%
    ; WriteLogDebug("Showing map " sFile " " sFileSize)
    If !pToken := Gdip_Startup()
    {
        MsgBox "Gdiplus failed to start. Please ensure you have gdiplus on your system"
        ExitApp
    }
    
    Gui, 1: -Caption +E0x20 +E0x80000 +LastFound +AlwaysOnTop +ToolWindow +OwnDialogs
    hwnd1 := WinExist()
    pBitmap := Gdip_CreateBitmapFromFile(sFile)
    If !pBitmap
    {
        WriteLog("ERROR: Could not load map image " sFile)
        ExitApp
    }
    Width := Gdip_GetImageWidth(pBitmap)
    Height := Gdip_GetImageHeight(pBitmap)
    Gdip_GetRotatedDimensions(Width, Height, Angle, RWidth, RHeight)
    Gdip_GetRotatedTranslation(Width, Height, Angle, xTranslation, yTranslation)
    ; WriteLog("scale: " scale)
    ; WriteLog("RWidth: " RWidth " RHeight: " RHeight)
    
    scaledWidth := (RWidth * scale)
    scaleAdjust := 1 ; need to adjust the scale for oversized maps
    if (scaledWidth > mapGuiWidth) {
        scaleAdjust := mapGuiWidth / (RWidth * scale)
        scaledWidth := mapGuiWidth
        WriteLogDebug("OverSized map, reducing scale to " scale ", maxWidth set to " mapGuiWidth)
    }
    scaledHeight := (RHeight * 0.5) * scale * scaleAdjust
    rotatedWidth := RWidth * scale * scaleAdjust
    rotatedHeight := RHeight * scale * scaleAdjust
    
    
    hbm := CreateDIBSection(rotatedWidth, rotatedHeight)
    hdc := CreateCompatibleDC()
    obm := SelectObject(hdc, hbm)
    Gdip_SetSmoothingMode(G, 4)  
    G := Gdip_GraphicsFromHDC(hdc)
    pBitmap := Gdip_RotateBitmap(pBitmap, Angle) ; rotates bitmap for 45 degrees. Disposes of pBitmap.

    ;WriteLog("scaledWidth: " scaledWidth " scaledHeight: " scaledHeight)
    Gdip_DrawImage(G, pBitmap, 0, 0, scaledWidth, scaledHeight, 0, 0, RWidth, RHeight, opacity)
    UpdateLayeredWindow(hwnd1, hdc, leftMargin, topMargin, rotatedWidth, rotatedHeight)
    SelectObject(hdc, obm)
    DeleteObject(hbm)
    DeleteDC(hdc)
    Gdip_DeleteGraphics(G)
    Gdip_DisposeImage(pBitmap)
    ElapsedTime := A_TickCount - StartTime
    WriteLogDebug("Drew map " ElapsedTime " ms taken")
    uiData := { "scaledWidth": scaledWidth, "scaledHeight": scaledHeight, "sizeWidth": Width, "sizeHeight": Height }
}