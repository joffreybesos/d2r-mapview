#Include %A_ScriptDir%\Gdip_All.ahk

Text:= "Loading"
Width:= 1000
Height:= 600
pToken := Gdip_Startup()
Options = x0 y0 Center vCenter c22ffffff r4 s20
Font = Arial

DetectHiddenWindows, On
Gui, 2: -Caption +E0x20 +E0x80000 +LastFound +OwnDialogs +Owner +AlwaysOnTop
Gui, 2: Show, NA
hwnd1 := WinExist()
hbm := CreateDIBSection(Width, Height)
hdc := CreateCompatibleDC()
obm := SelectObject(hdc, hbm)
G := Gdip_GraphicsFromHDC(hdc)
Gdip_SetSmoothingMode(G, 4)
pBrush := Gdip_BrushCreateSolid(0xAA000000)
Gdip_DeleteBrush(pBrush)
Gdip_TextToGraphics(G, Text, Options, Font, Width, Height)
UpdateLayeredWindow(hwnd1, hdc, 0, 0, Width, Height)
SelectObject(hdc, obm)
DeleteObject(hbm)
DeleteDC(hdc)
Gdip_DeleteGraphics(G)

Return
