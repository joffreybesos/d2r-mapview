#SingleInstance, Force
SendMode Input
SetWorkingDir, %A_ScriptDir%
#Include %A_ScriptDir%\ui\image\Gdip_ResizeBitmap.ahk
#Include %A_ScriptDir%\ui\image\Gdip_RotateBitmap.ahk
#Include %A_ScriptDir%\include\logging.ahk

mapData := { "sFile": "C:\Users\mjg99\AppData\Local\Temp\1253559933_2_5.png", "leftTrimmed" : 0, "topTrimmed" : 0, "mapOffsetX" : 14520, "mapOffsety" : 5410, "mapwidth" : 400, "mapheight" : 400 }
gameMemoryData := { "xPos": 14661, "yPos": 5751 }

ShowMap(1000, 50, 50, mapData, gameMemoryData)

ShowMap(mapGuiWidth, leftMargin, topMargin, mapData, gameMemoryData) {
    WriteLog("mapGuiWidth := " mapGuiWidth)
    WriteLog("leftMargin := " leftMargin)
    WriteLog("topMargin := " topMargin)

    WriteLog(mapData["sFile"])
    WriteLog(mapData["leftTrimmed"])
    WriteLog(mapData["topTrimmed"])
    WriteLog(mapData["mapOffsetX"])
    WriteLog(mapData["mapOffsety"])
    WriteLog(mapData["mapwidth"])
    WriteLog(mapData["mapheight"])

    WriteLog(gameMemoryData["xPos"])
    WriteLog(gameMemoryData["yPos"])

    StartTime := A_TickCount
    scale := 2 
    Angle := 45
    opacity := 0.9
    padding := 150

    ; get relative position of player in world
    ; xpos is absolute world pos in game
    ; each map has offset x and y which is absolute world position
    xPosDot := ((gameMemoryData["xPos"] - mapData["mapOffsetX"]) * scale) + 150
    yPosDot := ((gameMemoryData["yPos"] - mapData["mapOffsetY"]) * scale) + 150
    ; WriteLog("xPos raw " gameMemoryData["xPos"] " yPos raw " gameMemoryData["yPos"])
    ; WriteLog("xPosDot " xPosDot " yPosDot " yPosDot)
    ; WriteLog("xPosDot no trim " ((gameMemoryData["xPos"] - mapData["mapOffsetX"]) * scale) " yPosDot no trim " ((gameMemoryData["yPos"] - mapData["mapOffsetY"]) * scale))
    ; WriteLog("leftTrimmed: " mapData["leftTrimmed"] " topTrimmed: " mapData["topTrimmed"] )
    ; WriteLog("leftTrimmed: " mapDatca["leftTrimmed"] " topTrimmed: " mapData["topTrimmed"] )
    
    ;WriteLog("X playerpos " xPosDot " Y playerpos " yPosDot)
    
    sFile := mapData["sFile"] ; downloaded map image
    ; FileGetSize, sFileSize, %sFile%
    ; WriteLogDebug("Showing map " sFile " " sFileSize)
   

    If !pToken := Gdip_Startup()
    {
        MsgBox "Gdiplus failed to start. Please ensure you have gdiplus on your system"
        ExitApp
    }
    Width := 902
    Height := 900
    
    
    Gui, 1: -Caption +E0x20 +E0x80000 +LastFound +AlwaysOnTop +ToolWindow +OwnDialogs
    Gui, 1: Show, NA
    hwnd1 := WinExist()
    ; pBitmap := Gdip_CreateBitmapFromFile(sFile)
    pBitmap := Gdip_CreateBitmap(Width, Height)
    If !pBitmap
    {
        WriteLog("ERROR: Could not load map image " sFile)
        ExitApp
    }
    
    ; Width := Gdip_GetImageWidth(pBitmap)
    ; Height := Gdip_GetImageHeight(pBitmap)

   
    ; scaledWidth := mapGuiWidth
    ; scaledHeight := (scaledWidth / Width) * Height
    ; scaledHeight *= 0.5
    Gdip_GetRotatedDimensions(Width, Height, Angle, RWidth, RHeight)
    Gdip_GetRotatedTranslation(Width, Height, Angle, xTranslation, yTranslation)
    hbm := CreateDIBSection(RWidth, RHeight)
    hdc := CreateCompatibleDC()
    obm := SelectObject(hdc, hbm)
    Gdip_SetSmoothingMode(G, 4)  
    G := Gdip_GraphicsFromImage(pBitmap)
    ElapsedTime := A_TickCount - StartTime
    WriteLog("Create Bitmap " ElapsedTime " ms taken")
    ; ;draw player dot
    pPen := Gdip_CreatePen(0xff00FF00, 10)
    Gdip_DrawRectangle(G, pPen, xPosDot, yPosDot, 50, 50)
    ;Gdip_DrawRectangle(G, pPen, 0, 0, Width, Height) ;outline
    Gdip_DeletePen(pPen)
    WriteLog("After drawing " ElapsedTime " ms taken")

    ; pBrush := Gdip_BrushCreateHatch(0xff00FFFF, 0xffFFFF00, 31)
    ; Gdip_FillRectangle(G, pBrush, xPosDot, yPosDot, 50, 50)
    ; Gdip_DeleteBrush(pBrush)

    G := Gdip_GraphicsFromHDC(hdc)
    pBitmap := Gdip_RotateBitmap(pBitmap, Angle) ; rotates bitmap for 45 degrees. Disposes of pBitmap.
    ElapsedTime := A_TickCount - StartTime
    WriteLog("Rotate " ElapsedTime " ms taken")
    

    
    
    ; newSize := "w" scaledWidth " h" scaledHeight
    ;pResizedBitmap  := Gdip_ResizeBitmap(pRotatedBitmap, newSize)

    ; newWidth := Gdip_GetImageWidth(pBitmap) 
    ; newHeight := Gdip_GetImageHeight(pBitmap)
    ; WriteLog("Width: " Width " Height: " Height)
    ; WriteLog("RWidth: " RWidth " RHeight: " RHeight)
    ; WriteLog("newWidth: " newWidth " newHeight: " newHeight)
    ; WriteLog("xTranslation: " xTranslation " yTranslation: " yTranslation)

    scaledWidth := RWidth
    scaledHeight := RHeight * 0.5
    ; WriteLog("scaledWidth: " scaledWidth " scaledHeight: " scaledHeight)
    if (scaledWidth > mapGuiWidth) {
        ratio := RWidth / mapGuiWidth
        scaledWidth := mapGuiWidth
        scaledHeight := (scaledHeight / ratio)
    }
    ; WriteLog("scaledWidth: " scaledWidth " scaledHeight: " scaledHeight)
    Gdip_DrawImage(G, pBitmap, 0, 0, scaledWidth, scaledHeight, 0, 0, RWidth, RHeight, opacity)
    UpdateLayeredWindow(hwnd1, hdc, leftMargin, topMargin, RWidth, RHeight)
    
    
    Gui, 1: Show, NA
    ElapsedTime := A_TickCount - StartTime
    WriteLog("Draw players " ElapsedTime " ms taken")
    SelectObject(hdc, obm)
    DeleteObject(hbm)
    DeleteDC(hdc)s
    Gdip_DeleteGraphics(G)
    Gdip_DisposeImage(pBitmap)
    
    
    uiData := { "scaledWidth": scaledWidth, "scaledHeight": scaledHeight, "sizeWidth": Width, "sizeHeight": Height }
}

Esc::
{
	WriteLog("Pressed Shift+F10, exiting...")
	ExitApp
}
