#SingleInstance, Force
SendMode Input

SetWorkingDir, %A_ScriptDir%

#Include %A_ScriptDir%\include\Gdip_All.ahk
#Include %A_ScriptDir%\include\Gdip_ResizeBitmap.ahk
#Include %A_ScriptDir%\include\Gdip_RotateBitmap.ahk
#Include %A_ScriptDir%\include\getMapImage.ahk
#Include %A_ScriptDir%\include\getLevelInfo.ahk
StartTime := A_TickCount

Width := 2000
Height := 2000
Gui, 3: -Caption +E0x20 +E0x80000 +LastFound +AlwaysOnTop +ToolWindow +OwnDialogs


hwnd1 := WinExist()
hbm := CreateDIBSection(Width, Height)
hdc := CreateCompatibleDC()
obm := SelectObject(hdc, hbm)
G := Gdip_GraphicsFromHDC(hdc)
Gdip_SetSmoothingMode(G, 4)

pPen := Gdip_CreatePen(0xffffFF00, 5)
Gdip_DrawRectangle(G, pPen, 200, 200, 250, 50)

UpdateLayeredWindow(hwnd1, hdc, 0, 0, Width, Height)
Gdip_DeletePen(pPen)

SelectObject(hdc, obm)
DeleteObject(hbm)
DeleteDC(hdc)
Gdip_DeleteGraphics(G)
Gdip_Shutdown(pToken)
Gui, 3: Show, NA
ElapsedTime := A_TickCount - StartTime
WriteLog("Draw players " ElapsedTime " ms taken")

Esc::
{
	ExitApp
}


