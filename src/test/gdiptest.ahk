; gdi+ ahk tutorial 3 written by tic (Tariq Porter)
; Requires Gdip.ahk either in your Lib folder as standard library or using #Include
;
; Tutorial to take make a gui from an existing image on disk
; For the example we will use png as it can handle transparencies. The image will also be halved in size

#SingleInstance Force
#NoEnv
SetBatchLines -1

; Uncomment if Gdip.ahk is not in your standard library
#Include Gdip_All.ahk

; Start gdi+
If !pToken := Gdip_Startup()
{
	MsgBox "Gdiplus failed to start. Please ensure you have gdiplus on your system"
	ExitApp
}
OnExit("ExitFunc")

; Create a layered window (+E0x80000 : must be used for UpdateLayeredWindow to work!) that is always on top (+AlwaysOnTop), has no taskbar entry or caption
Gui, Map: -Caption +E0x80000 +LastFound +AlwaysOnTop +ToolWindow +OwnDialogs
Gui, Map: Show, NA

hwnd1 := WinExist()
pBitmap := Gdip_CreateBitmapFromFile("currentmap.png")

; Check to ensure we actually got a bitmap from the file, in case the file was corrupt or some other error occured
If !pBitmap
{
	MsgBox "Could not load 'currentmap.png'"
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
Gdip_DrawImage(G, pBitmap, 0, 0, scaledWidth, scaledHeight, 0, 0, Width, Height, 0.6)

UpdateLayeredWindow(hwnd1, hdc, 0, 0, scaledWidth, scaledHeight)

SelectObject(hdc, obm)
DeleteObject(hbm)
DeleteDC(hdc)
Gdip_DeleteGraphics(G)
Gdip_DisposeImage(pBitmap)
Return

;#######################################################################

ExitFunc(ExitReason, ExitCode) {
   global
   Gdip_Shutdown(pToken)
}

~Esc::
   ExitApp
Return