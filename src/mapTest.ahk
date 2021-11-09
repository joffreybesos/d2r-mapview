#SingleInstance, Force
SendMode Input

SetWorkingDir, %A_ScriptDir%

#Include %A_ScriptDir%\include\Gdip_All.ahk
#Include %A_ScriptDir%\include\Gdip_ResizeBitmap.ahk
#Include %A_ScriptDir%\include\Gdip_RotateBitmap.ahk
#Include %A_ScriptDir%\include\getMapImage.ahk
#Include %A_ScriptDir%\include\getLevelInfo.ahk

playerPositionArray := []

playerPositionArray[0] := 14620
playerPositionArray[1] := 5690

sMapUrl := "http://diab.wikiwarsgame.com:8080/v1/map/905399348/2/5"
imageUrl := sMapUrl "/image?flat=true"

sFile=%A_Temp%\currentmap.png
FileDelete, %sFile%
URLDownloadToFile, %imageUrl%, %sFile%
WriteLog("Downloading " imageUrl)

mapFileName := RegExReplace(sMapUrl, "^.+?map\/.*?")
mapFileName := StrReplace(mapFileName, "/", "_")
jsonFile=%A_Temp%\%mapFileName%.json
if !FileExist(jsonFile) {
    URLDownloadToFile, %sMapUrl%, %jsonFile%
}
FileRead, Contents, %jsonFile%
mapJsonData := Jxon_Load(Contents)


configuredWidth := 1000
configuredWidth := 1000
opacity := 0.5
leftMargin := 50
topMargin := 50

; download image
If !pToken := Gdip_Startup()
{
    MsgBox "Gdiplus failed to start. Please ensure you have gdiplus on your system"
    ExitApp
}

Gui, 1: -Caption +E0x20 +E0x80000 +LastFound +AlwaysOnTop +ToolWindow +OwnDialogs
Gui, 1: Show, NA
hwnd1 := WinExist()
pBitmap := Gdip_CreateBitmapFromFile(sFile)


If !pBitmap
{
    WriteLog("Could not load " sFile)
    ExitApp
}

scale := 2
padding := 150
Angle = 45
mapOffsetX := mapJsonData["offset"]["x"]
mapOffsetY := mapJsonData["offset"]["y"]
mapWidth := (mapJsonData["size"]["width"] * scale) + (padding * 2)
;WriteLog("mapOffsetX " mapOffsetX " mapOffsetY " mapOffsetY " mapWidth " mapWidth)

; current position of player in world
xPosDot := ((playerPositionArray[0] - mapOffsetX) * scale) + padding
yPosDot := ((playerPositionArray[1] - mapOffsetY) * scale) + padding
;WriteLog("X playerpos " xPosDot " Y playerpos " yPosDot)

Width := Gdip_GetImageWidth(pBitmap), Height := Gdip_GetImageHeight(pBitmap)
scaledWidth := mapWidth
scaledHeight := (scaledWidth / Width) * Height
scaledHeight *= 0.66


Gdip_GetRotatedDimensions(Width, Height, Angle, RWidth, RHeight)
Gdip_GetRotatedTranslation(Width, Height, Angle, xTranslation, yTranslation)

hbm := CreateDIBSection(RWidth, RHeight)
hdc := CreateCompatibleDC()
obm := SelectObject(hdc, hbm)
;G := Gdip_GraphicsFromHDC(hdc)
G := Gdip_GraphicsFromImage(pBitmap)

;Gdip_SetInterpolationMode(G, 7)
Gdip_SetSmoothingMode(G, 4)

;draw player dot
pPen := Gdip_CreatePen(0xff00FF00, 5)
Gdip_DrawRectangle(G, pPen, xPosDot, yPosDot, 5, 5)
Gdip_DeletePen(pPen)

pBrush := Gdip_BrushCreateHatch(0xff00FFFF, 0xffFFFF00, 31)
Gdip_FillRectangle(G, pBrush, xPosDot+60, yPosDot, 50, 50)
Gdip_DeleteBrush(pBrush)

G := Gdip_GraphicsFromHDC(hdc)


pRotatedBitmap := Gdip_RotateBitmap(pBitmap, Angle) ; rotates bitmap for 45 degrees. Disposes of pBitmap.
newSize := "w1000 h" scaledHeight
pResizedBitmap  := Gdip_ResizeBitmap(pRotatedBitmap, newSize)

newWidth := Gdip_GetImageWidth(pResizedBitmap), newHeight := Gdip_GetImageHeight(pResizedBitmap)
WriteLog(RWidth " " RHeight " " Width " " Height)
; draw the actual map
Gdip_DrawImage(G, pResizedBitmap, 0, 0, newWidth, newHeight, 0, 0, Width, Height, opacity)



UpdateLayeredWindow(hwnd1, hdc, leftMargin, topMargin, newWidth, newHeight)
;Gdip_SaveBitmapToFile(pResizedBitmap, "testfile.png")
SelectObject(hdc, obm)
DeleteObject(hbm)
DeleteDC(hdc)
Gdip_DeleteGraphics(G)
Gdip_DisposeImage(pBitmap)





Esc::
{
	ExitApp
}


