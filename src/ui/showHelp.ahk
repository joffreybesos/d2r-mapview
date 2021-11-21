#SingleInstance, Force
SendMode Input
SetWorkingDir, %A_ScriptDir%

ShowHelpText(Width, leftMargin, topMargin) {
    pToken := Gdip_Startup()
    Height = 500
    Text = 
    (
d2r-mapview

- Ctrl+H to toggle this help
- TAB to show/hide map
- Numpad* to permanently show map
- Numpad+ to increase map size
- Numpad- to decrease map size
- Shift+F10 to exit d2r-mapview

Configuration options here:
https://github.com/joffreybesos/d2r-mapview#configure

See log.txt for troubleshooting.

Please report scams on the discord, link found on Github.
    )

    Options = x0 y0 Left vCenter cFFffffff r4 s20
    Font = Arial
    DetectHiddenWindows, On
    Gui, HelpText: -Caption +E0x20 +E0x80000 +LastFound +OwnDialogs +Owner +AlwaysOnTop
    Gui, HelpText: Show, NA
    hwnd1 := WinExist()
    hbm := CreateDIBSection(Width, Height)
    hdc := CreateCompatibleDC()
    obm := SelectObject(hdc, hbm)
    G := Gdip_GraphicsFromHDC(hdc)
    Gdip_SetSmoothingMode(G, 4)
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