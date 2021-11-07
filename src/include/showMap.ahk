#SingleInstance, Force
SendMode Input
SetWorkingDir, %A_ScriptDir%
#Include %A_ScriptDir%\include\Gdip_All.ahk
#Include %A_ScriptDir%\include\showText.ahk

ShowMap(sMapUrl, configuredWidth, leftMargin, topMargin, opacity) {
    ; download image
    If !pToken := Gdip_Startup()
    {
        MsgBox "Gdiplus failed to start. Please ensure you have gdiplus on your system"
        ExitApp
    }

    Gui, 1: Destroy
    sFile=%a_scriptdir%\currentmap.png
    
    ShowText(configuredWidth, leftMargin, topMargin, "Loading map data...`nPlease wait", "22")
    FileDelete, %sFile%
    URLDownloadToFile, %sMapUrl%, %sFile%

    Gui, 2: Hide

    ; hide the map if in town
    StringSplit, ua, sMapUrl, "/"
    if (ua8 == 1 or ua8 == 40 or ua8 == 75 or ua8 == 103 or ua8 == 109) {
    } else {

        Gui, 1: -Caption +E0x20 +E0x80000 +LastFound +AlwaysOnTop +ToolWindow +OwnDialogs
        hwnd1 := WinExist()
        pBitmap := Gdip_CreateBitmapFromFile(sFile)

        If !pBitmap
        {
            ShowText(configuredWidth, leftMargin, topMargin, "FAILED LOADING MAP!`nCheck log.txt`n`nExiting...", "ff")
            WriteLog("Could not load " sMapUrl)
            Sleep, 5000
            ExitApp
        }

        Width := Gdip_GetImageWidth(pBitmap), Height := Gdip_GetImageHeight(pBitmap)
        scaledWidth := configuredWidth
        scaledHeight := (scaledWidth / Width) * Height

        hbm := CreateDIBSection(scaledWidth, scaledHeight)
        hdc := CreateCompatibleDC()
        obm := SelectObject(hdc, hbm)
        G := Gdip_GraphicsFromHDC(hdc)
        Gdip_SetInterpolationMode(G, 7)

        ; Gdip_DrawImage(pGraphics, pBitmap, dx, dy, dw, dh, sx, sy, sw, sh, Matrix)
        ; d is for destination and s is for source.
        Gdip_DrawImage(G, pBitmap, 0, 0, scaledWidth, scaledHeight, 0, 0, Width, Height, opacity)

        UpdateLayeredWindow(hwnd1, hdc, leftMargin, topMargin, scaledWidth, scaledHeight)

        SelectObject(hdc, obm)
        DeleteObject(hbm)
        DeleteDC(hdc)
        Gdip_DeleteGraphics(G)
        Gdip_DisposeImage(pBitmap)
        Gui, 1: Show, NA
    }
}