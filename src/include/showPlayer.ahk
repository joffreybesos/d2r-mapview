#SingleInstance, Force
SendMode Input
SetWorkingDir, %A_ScriptDir%
#Include %A_ScriptDir%\include\Gdip_All.ahk
#Include %A_ScriptDir%\include\showText.ahk
#Include %A_ScriptDir%\include\Gdip_ResizeBitmap.ahk
#Include %A_ScriptDir%\include\Gdip_RotateBitmap.ahk

ShowPlayer(sFile, configuredWidth, leftMargin, topMargin, opacity, mapJsonData, playerPositionArray) {
    ; download image
    If !pToken := Gdip_Startup()
    {
        MsgBox "Gdiplus failed to start. Please ensure you have gdiplus on your system"
        ExitApp
    }
    ; hide the map if in town
    mapid := mapJsonData["id"]
    if (mapid == 1 or mapid == 40 or mapid == 75 or mapid == 103 or mapid == 109) {
        ;WriteLogDebug("At town mapid " mapid ", hiding map")
    } else {
        StartTime := A_TickCount
        
        scale := 2
        padding := 150
        Angle = 45
        mapOffsetX := mapJsonData["offset"]["x"]
        mapOffsetY := mapJsonData["offset"]["y"]
        mapWidth := (mapJsonData["size"]["width"] * scale) + (padding * 2)

        ; current position of player in world
        xPosDot := ((playerPositionArray[0] - mapOffsetX) * scale) + padding
        yPosDot := ((playerPositionArray[1] - mapOffsetY) * scale) + padding
        WriteLog("X playerpos " playerPositionArray[0] " " xPosDot " Y playerpos " playerPositionArray[1] " " yPosDot)

        Width := 1000, Height := 1000
        scaledWidth := mapWidth
        scaledHeight := (scaledWidth / Width) * Height
        scaledHeight *= 0.66
        
        Gui, 3: -Caption +E0x20 +E0x80000 +LastFound +AlwaysOnTop +ToolWindow +OwnDialogs
        Gui, 3: Show, NA
        
        hwnd1 := WinExist()
        hbm := CreateDIBSection(Width, Height)
        hdc := CreateCompatibleDC()
        obm := SelectObject(hdc, hbm)
        G := Gdip_GraphicsFromHDC(hdc)
        Gdip_SetSmoothingMode(G, 4)
        pPen := Gdip_CreatePen(0xff00FF00, 5)
        Gdip_DrawRectangle(G, pPen, xPosDot, yPosDot, 5, 5)
        
        UpdateLayeredWindow(hwnd1, hdc, leftMargin, topMargin, Width, Height)
        Gdip_DeletePen(pPen)
        SelectObject(hdc, obm)
        DeleteObject(hbm)
        DeleteDC(hdc)
        Gdip_DeleteGraphics(G)
        Gdip_Shutdown(pToken)

        
    

        ; ; Gdip_GetRotatedDimensions(Width, Height, Angle, RWidth, RHeight)
        ; ; Gdip_GetRotatedTranslation(Width, Height, Angle, xTranslation, yTranslation)

        ; hbm := CreateDIBSection(Width, Height)
        ; hdc := CreateCompatibleDC()
        ; obm := SelectObject(hdc, hbm)
        ; G := Gdip_GraphicsFromHDC(hdc)
        
        ; Gdip_SetInterpolationMode(G, 7)
        ; ;Gdip_SetSmoothingMode(G, 4)

        ; ;draw player dot
        ; pPen := Gdip_CreatePen(0xff00FF00, 5)
        ; Gdip_DrawRectangle(G, pPen, 500, 500, 50, 50)
        ; Gdip_DeletePen(pPen)

        ; ; pRotatedBitmap := Gdip_RotateBitmap(pBitmap, Angle) ; rotates bitmap for 45 degrees. Disposes of pBitmap.
        ; ; newSize := "w1000 h" scaledHeight
        ; ; pResizedBitmap  := Gdip_ResizeBitmap(pRotatedBitmap, newSize)

        ; ; newWidth := Gdip_GetImageWidth(pResizedBitmap), newHeight := Gdip_GetImageHeight(pResizedBitmap)

        ; ; draw the actual map
        ; ; Gdip_DrawImage(G, pBitmap, 0, 0, scaledWidth, scaledHeight, 0, 0, Width, Height, opacity)
        ; ; UpdateLayeredWindow(hwnd1, hdc, leftMargin, topMargin, scaledWidth, scaledHeight)
        
        ; UpdateLayeredWindow(hwnd1, hdc, leftMargin, topMargin, newWidth, newHeight)

        ; ;Gdip_SaveBitmapToFile(pResizedBitmap, "testfile.png")
        ; SelectObject(hdc, obm)
        ; DeleteObject(hbm)
        ; DeleteDC(hdc)
        ; Gdip_DeleteGraphics(G)



        
        ElapsedTime := A_TickCount - StartTime
        WriteLog("Draw players " ElapsedTime " ms taken")
    }
}