#SingleInstance, Force
SendMode Input
SetWorkingDir, %A_ScriptDir%

ShowGameText(gameName, hwnd1, gameWindowId, position = "RIGHT", textBoxWidth = 800, fontSize = 26) {
    WinGetPos, , , Width, Height, %gameWindowId%
    if (position == "RIGHT") {
        leftMargin := Width - textBoxWidth
        textAlign := "Left"
    } else if (position = "LEFT") {
        leftMargin := 20
        textAlign := "Left"
    } else {
        leftMargin := Width - textBoxWidth
        textAlign := "Left"
    }
    topMargin := 20
    if (WinExist(gameWindowId)) {
        
        pToken := Gdip_Startup()
        DetectHiddenWindows, On
        hbm := CreateDIBSection(Width, Height)
        hdc := CreateCompatibleDC()
        obm := SelectObject(hdc, hbm)
        G := Gdip_GraphicsFromHDC(hdc)
        Gdip_SetSmoothingMode(G, 4)
        
        if (gameName) {
            Options = x0 y0 %textAlign% vCenter cffffffff r4 s%fontSize%
            Gdip_TextToGraphics(G, "Previous game name", Options, diabloFont, Width, 50)

            Options = x0 y40 %textAlign% vCenter cffFFD700 r4 s%fontSize%
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
}
