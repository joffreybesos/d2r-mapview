#SingleInstance, Force

SetWorkingDir, %A_ScriptDir%
#Include %A_ScriptDir%\include\Gdip_All.ahk

ShowIPText(hwnd1, gameWindowId, ipaddress, position = "LEFT", fontSize = 26) {
    
    WinGetPos, , , Width, Height, %gameWindowId%
    StringUpper, position, position
    textBoxWidth := 200
    topMargin := 20
    if (position == "RIGHT") {
        leftMargin := Width - textBoxWidth - 20
        align = "Right"
        topMargin := 130
    } else if (position == "LEFT") {
        leftMargin := 20
        align = "Left"
    } else {
        leftMargin := 20
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

        Options = x0 y0 %align% vTop cffAAAAAA r4 s%fontSize% Bold
        
        Gdip_TextToGraphics(G, ipaddress, Options, diablofont, textBoxWidth, 50)
        ;msgbox % leftMargin " " topMargin " " position " " textBoxWidth
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

