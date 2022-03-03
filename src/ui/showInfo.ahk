
ShowInfoText(hwnd1, gameWindowId, ipaddress, currentFPS, position = "LEFT", fontSize = 26) {
    
    WinGetPos, winx, winy, Width, Height, %gameWindowId%
    StringUpper, position, position
    textBoxWidth := 200
    topMargin := 40 + winy
    if (position == "RIGHT") {
        leftMargin := Width - textBoxWidth - 20 + winx
        align = "Right"
        topMargin := 160 + winy
    } else if (position == "LEFT") {
        leftMargin := 20 + winx
        align = "Left"
    } else {
        leftMargin := 20 + winx
        align = "Left"
    }
    
    if (WinExist(gameWindowId)) {
        if (!WinExist(hwnd1)) {
            Gui, IPaddress: -Caption +LastFound +AlwaysOnTop +ToolWindow +OwnDialogs +Hwndhwnd1
        }
        Gui, IPaddress: Show, NA
        pToken := Gdip_Startup()
        DetectHiddenWindows, On
        hbm := CreateDIBSection(textBoxWidth, 50)
        hdc := CreateCompatibleDC()
        obm := SelectObject(hdc, hbm)
        G := Gdip_GraphicsFromHDC(hdc)
        Gdip_SetSmoothingMode(G, 4)
        Gdip_SetInterpolationMode(G, 7)

        Options = x0 y0 %align% vTop cffc6b276 r4 s%fontSize%
        Options2 = x0 y20 %align% vTop cffc6b276 r4 s%fontSize%
        
        if (settings["showIPtext"]) {
            Gdip_TextToGraphics(G, ipaddress, Options, diablofont, textBoxWidth, 50)
        }
        if (settings["showFPS"]) {
            currentFPS := currentFPS " FPS"
            Gdip_TextToGraphics(G, currentFPS, Options2, diablofont, textBoxWidth, 50)
        }
        UpdateLayeredWindow(hwnd1, hdc, leftMargin, topMargin, textBoxWidth, 50)
        SelectObject(hdc, obm)
        DeleteObject(hbm)
        DeleteDC(hdc)
        Gdip_DeleteGraphics(G)
        
        if WinActive(gameWindowId) {
            Gui, IPaddress: Show, NA
        } else {
            gui, IPaddress: Hide
        }
    } else {
        gui, IPaddress: Destroy
    }
}

