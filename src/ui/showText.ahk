#Include %A_ScriptDir%\include\Gdip_All.ahk

ShowText(settings, Text, opacity) {
    
    leftMargin:=settings["leftMargin"]
    topMargin:= settings["topMargin"]

    pToken := Gdip_Startup()

    Width:= 1000
    Height = 500
    Options = x0 y0 Center vCenter c%opacity%ffffff r4 s20
    Font = Arial

    DetectHiddenWindows, On
    Gui, LoadingText: -Caption +E0x20 +E0x80000 +LastFound +OwnDialogs +Owner +AlwaysOnTop
    Gui, LoadingText: Show, NA
    hwnd1 := WinExist()
    hbm := CreateDIBSection(Width, Height)
    hdc := CreateCompatibleDC()
    obm := SelectObject(hdc, hbm)
    G := Gdip_GraphicsFromHDC(hdc)
    Gdip_SetSmoothingMode(G, 4)
    Gdip_SetInterpolationMode(G, 7)
    pBrush := Gdip_BrushCreateSolid(0xAA000000)
    Gdip_DeleteBrush(pBrush)
    Gdip_TextToGraphics(G, Text, Options, Font, Width, Height)
    UpdateLayeredWindow(hwnd1, hdc, leftMargin, topMargin, Width, Height)
    SelectObject(hdc, obm)
    DeleteObject(hbm)
    DeleteDC(hdc)
    Gdip_DeleteGraphics(G)

    Return
}
