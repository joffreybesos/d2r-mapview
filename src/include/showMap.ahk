#SingleInstance, Force
SendMode Input
SetWorkingDir, %A_ScriptDir%
#Include %A_ScriptDir%\include\Gdip_All.ahk



ShowMap(sMapUrl, width, height, leftMargin, topMargin, opacity) {
    ; download image
    If !pToken := Gdip_Startup()
    {
        MsgBox "Gdiplus failed to start. Please ensure you have gdiplus on your system"
        ExitApp
    }

    sFile=%a_scriptdir%\currentmap.png
    URLDownloadToFile, %sMapUrl%,%sFile%

    Gui, 1: -Caption +E0x20 +E0x80000 +LastFound +AlwaysOnTop +ToolWindow +OwnDialogs
    Gui, 1: Show, NA

    hwnd1 := WinExist()
    pBitmap := Gdip_CreateBitmapFromFile(sFile)

    If !pBitmap
    {
        WriteLog("Could not load " sMapUrl)
        ExitApp
    }

    Width := Gdip_GetImageWidth(pBitmap), Height := Gdip_GetImageHeight(pBitmap)
    scaledWidth := 1000
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
}