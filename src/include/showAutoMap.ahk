#SingleInstance, Force
SendMode Input
SetWorkingDir, %A_ScriptDir%
#Include %A_ScriptDir%\include\Gdip_All.ahk
#Include %A_ScriptDir%\include\showText.ahk
#Include %A_ScriptDir%\include\Gdip_ResizeBitmap.ahk
#Include %A_ScriptDir%\include\Gdip_RotateBitmap.ahk

ShowAutoMap(mapData, configuredWidth, leftMargin, topMargin, opacity, playerPositionArray) {
    WriteLog(mapData["sFile"])
    If !pToken := Gdip_Startup()
    {
        MsgBox "Gdiplus failed to start. Please ensure you have gdiplus on your system"
        ExitApp
    }

    ; hide the map if in town
    ;StringSplit, ua, sMapUrl, "/"
    ;if (ua8 == 1 or ua8 == 40 or ua8 == 75 or ua8 == 103 or ua8 == 109) {
    if (1 ==2 ) {
        WriteLogDebug("At town mapid " mapid ", hiding map")
    } else {
        Gui, 1: -Caption +E0x20 +E0x80000 +LastFound +AlwaysOnTop +ToolWindow +OwnDialogs
        hwnd1 := WinExist()
        pBitmap := Gdip_CreateBitmapFromFile(mapData["sFile"])

        If !pBitmap
        {
            ShowText(configuredWidth, leftMargin, topMargin, "FAILED LOADING MAP!`nCheck log.txt`n`nExiting...", "ff")
            WriteLog("Could not load " sMapUrl)
            Sleep, 5000
            ExitApp
        }

        scale := 2
        padding := 150
        Angle = 45
        mapOffsetX := mapJsonData["offset"]["x"]
        mapOffsetY := mapJsonData["offset"]["y"]
        mapWidth := (mapJsonData["size"]["width"] * scale) + (padding * 2)

        ; current position of player in world
        xPosDot := ((playerPositionArray[0] - mapOffsetX) * scale) + padding
        yPosDot := ((playerPositionArray[1] - mapOffsetY) * scale) + padding
        ;WriteLog("X playerpos " playerPositionArray[0] " " xPosDot " Y playerpos " playerPositionArray[1] " " yPosDot)
       

        Width := Gdip_GetImageWidth(pBitmap), Height := Gdip_GetImageHeight(pBitmap)
        scaledWidth := mapWidth
        scaledHeight := (scaledWidth / Width) * Height
        scaledHeight *= 0.66

        Gdip_GetRotatedDimensions(Width, Height, Angle, RWidth, RHeight)
        Gdip_GetRotatedTranslation(Width, Height, Angle, xTranslation, yTranslation)

        hbm := CreateDIBSection(RWidth, RHeight)
        hdc := CreateCompatibleDC()
        obm := SelectObject(hdc, hbm)
        ;G := Gdip_GraphicsFromHDC(hdc)
        G := Gdip_GraphicsFromImage(pBitmap)
        ;Gdip_SetInterpolationMode(G, 7)
        Gdip_SetSmoothingMode(G, 4)

        ;draw player dot
        pPen := Gdip_CreatePen(0xff00FF00, 5)
        Gdip_DrawRectangle(G, pPen, xPosDot, yPosDot, 5, 5)
        Gdip_DeletePen(pPen)
        G := Gdip_GraphicsFromHDC(hdc)

        pRotatedBitmap := Gdip_RotateBitmap(pBitmap, Angle) ; rotates bitmap for 45 degrees. Disposes of pBitmap.
        newSize := "w1000 h" scaledHeight
        pResizedBitmap  := Gdip_ResizeBitmap(pRotatedBitmap, newSize)

        newWidth := Gdip_GetImageWidth(pResizedBitmap), newHeight := Gdip_GetImageHeight(pResizedBitmap)

        ; draw the actual map
        ; Gdip_DrawImage(G, pBitmap, 0, 0, scaledWidth, scaledHeight, 0, 0, Width, Height, opacity)
        ; UpdateLayeredWindow(hwnd1, hdc, leftMargin, topMargin, scaledWidth, scaledHeight)
        Gdip_DrawImage(G, pResizedBitmap, 0, 0, newWidth, newHeight, 0, 0, Width, Height, opacity)
        UpdateLayeredWindow(hwnd1, hdc, leftMargin, topMargin, newWidth, newHeight)

        ;Gdip_SaveBitmapToFile(pResizedBitmap, "testfile.png")
        SelectObject(hdc, obm)
        DeleteObject(hbm)
        DeleteDC(hdc)
        Gdip_DeleteGraphics(G)
        Gdip_DisposeImage(pResizedBitmap)
        Gdip_DisposeImage(pRotatedBitmap)
        Gdip_DisposeImage(pBitmap)
        Gui, 1: Show, NA
    }
}