#SingleInstance, Force
SendMode Input
SetWorkingDir, %A_ScriptDir%

ShowGameText(gameName, hwnd1, gameTime, gameWindowId) {
    WinGetPos, , , Width, Height, %gameWindowId%
    
    Height := 400
    leftMargin := Width - 420
    topMargin := 20
    
    Width := 400
    if (WinExist(gameWindowId)) {
        
        pToken := Gdip_Startup()
        DetectHiddenWindows, On
        hbm := CreateDIBSection(Width, Height)
        hdc := CreateCompatibleDC()
        obm := SelectObject(hdc, hbm)
        G := Gdip_GraphicsFromHDC(hdc)
        Gdip_SetSmoothingMode(G, 4)
        pBrush := Gdip_BrushCreateSolid(0xAA000000)
        Gdip_DeleteBrush(pBrush)
        
        if (gameName) {
            Options = x0 y0 Left vCenter cffffffff r4 s22
            Gdip_TextToGraphics(G, "Previous game name", Options, diabloFont, Width, 50)

            Options = x0 y40 Left vCenter cffFFD700 r4 s24  Bold
            Gdip_TextToGraphics(G, gameName, Options, diabloFont, Width, 50)
            UpdateLayeredWindow(hwnd1, hdc, leftMargin, topMargin, Width, Height)
        }

        SelectObject(hdc, obm)
        DeleteObject(hbm)
        DeleteDC(hdc)
        Gdip_DeleteGraphics(G)
        
        if WinActive(gameWindowId) {
            Gui, GameInfo: Show, NA
        } else {
            gui, GameInfo: Hide
        }
    } else {
        gui, GameInfo: Hide
    }
    Return
}
