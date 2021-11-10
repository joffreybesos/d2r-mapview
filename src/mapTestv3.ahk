#Strict [On]
#Warnings [On]
#SingleInstance, Force
SendMode Input

SetWorkingDir, %A_ScriptDir%

#Include %A_ScriptDir%\include\Gdip_All.ahk
#Include %A_ScriptDir%\include\Gdip_ResizeBitmap.ahk
#Include %A_ScriptDir%\include\Gdip_RotateBitmap.ahk
#Include %A_ScriptDir%\include\getLevelInfo.ahk

playerPositionArray := []
playerPositionArray[0] := 14620
playerPositionArray[1] := 5690

imageUrl := "http://diab.wikiwarsgame.com:8080/v1/map/114773561/2/111/image?flat=true&trim=true"

sFile=%A_Temp%\currentmap.png
FileDelete, %sFile%

; download file
try {

    whr := ComObjCreate("WinHttp.WinHttpRequest.5.1")
    whr.Open("GET", imageUrl, true)
    whr.Send()
    WriteLog("Downloading " imageUrl)
    whr.WaitForResponse()
    fileContents := whr.ResponseBody
    respHeaders := whr.GetAllResponseHeaders
    leftTrimmed := whr.getResponseHeader("lefttrimmed")
    topTrimmed := whr.getResponseHeader("toptrimmed")
    mapOffsetX := whr.getResponseHeader("offsetx")
    mapOffsety := whr.getResponseHeader("offsety")
    mapwidth := whr.getResponseHeader("mapwidth")
    mapheight := whr.getResponseHeader("mapheight")
    vStream := whr.ResponseStream
    if (ComObjType(vStream) = 0xD) {      ;VT_UNKNOWN = 0xD
        pIStream := ComObjQuery(vStream, "{0000000c-0000-0000-C000-000000000046}")	;defined in ObjIdl.h

        oFile := FileOpen( sFile, "w")
        Loop {	
            VarSetCapacity(Buffer, 8192)
            hResult := DllCall(NumGet(NumGet(pIStream + 0) + 3 * A_PtrSize)	; IStream::Read 
                , "ptr", pIStream	
                , "ptr", &Buffer			;pv [out] A pointer to the buffer which the stream data is read into.
                , "uint", 8192			;cb [in] The number of bytes of data to read from the stream object.
                , "ptr*", cbRead)		;pcbRead [out] A pointer to a ULONG variable that receives the actual number of bytes read from the stream object. 
            oFile.RawWrite(&Buffer, cbRead)
        } Until (cbRead = 0)
        ObjRelease(pIStream) 
        oFile.Close() 			
    }

} catch e {
    WriteLog(e.message)
    WriteLog("ERROR: Failed to download image from " imageUrl)
}

scale := 2
Angle = 45
leftMargin := 50
topMargin := 50
mapWidth := 1000
;WriteLog("mapOffsetX " mapOffsetX " mapOffsetY " mapOffsetY " mapWidth " mapWidth)


opacity := 0.5

; current position of player in world
xPosDot := ((playerPositionArray[0] - mapOffsetX) * scale)
yPosDot := ((playerPositionArray[1] - mapOffsetY) * scale)
;WriteLog("X playerpos " xPosDot " Y playerpos " yPosDot)


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

StartTime := A_TickCount
If !pBitmap
{
    WriteLog("Could not load " sFile)
    ExitApp
}




Width := Gdip_GetImageWidth(pBitmap)
Height := Gdip_GetImageHeight(pBitmap)
; scaledWidth := mapWidth
; scaledHeight := (scaledWidth / Width) * Height
; scaledHeight *= 0.5


; Gdip_GetRotatedDimensions(Width, Height, Angle, RWidth, RHeight)
; Gdip_GetRotatedTranslation(Width, Height, Angle, xTranslation, yTranslation)

hbm := CreateDIBSection(Width, Height)
hdc := CreateCompatibleDC()
obm := SelectObject(hdc, hbm)
;G := Gdip_GraphicsFromHDC(hdc)
; G := Gdip_GraphicsFromImage(pBitmap)

;Gdip_SetInterpolationMode(G, 7)
Gdip_SetSmoothingMode(G, 4)  

; ;draw player dot
; pPen := Gdip_CreatePen(0xff00FF00, 5)
; Gdip_DrawRectangle(G, pPen, xPosDot, yPosDot, 5, 5)
; Gdip_DrawRectangle(G, pPen, 0, 0, Width, Height) ;outline
; Gdip_DeletePen(pPen)

; pBrush := Gdip_BrushCreateHatch(0xff00FFFF, 0xffFFFF00, 31)
; Gdip_FillRectangle(G, pBrush, xPosDot+60, yPosDot, 50, 50)
; Gdip_DeleteBrush(pBrush)

G := Gdip_GraphicsFromHDC(hdc)
; pRotatedBitmap := Gdip_RotateBitmap(pBitmap, Angle) ; rotates bitmap for 45 degrees. Disposes of pBitmap.
; newSize := "w1000 h" scaledHeight
; pResizedBitmap  := Gdip_ResizeBitmap(pRotatedBitmap, newSize)

; newWidth := Gdip_GetImageWidth(pBitmap) 
; newHeight := Gdip_GetImageHeight(pBitmap)
WriteLog("RWidth: " RWidth " RHeight: " RHeight)
WriteLog("Width: " Width " Height: " Height)
WriteLog("newWidth: " newWidth " newHeight: " newHeight)
WriteLog("xTranslation: " xTranslation " yTranslation: " yTranslation)

Gdip_DrawImage(G, pBitmap, 0, 0, Width, Height, 0, 0, Width, Height, opacity)
UpdateLayeredWindow(hwnd1, hdc, leftMargin, topMargin, Width, Height)
;Gdip_SaveBitmapToFile(pResizedBitmap, "testfile.png")
SelectObject(hdc, obm)
DeleteObject(hbm)
DeleteDC(hdc)
Gdip_DeleteGraphics(G)
Gdip_DisposeImage(pBitmap)
ElapsedTime := A_TickCount - StartTime
WriteLog("Draw players " ElapsedTime " ms taken")





Gui, 1: -Caption +E0x20 +E0x80000 +LastFound +AlwaysOnTop +ToolWindow +OwnDialogs
Gui, 1: Show, NA
hwnd1 := WinExist()
pBitmap := Gdip_CreateBitmapFromFile(sFile)

StartTime := A_TickCount
If !pBitmap
{
    WriteLog("Could not load " sFile)
    ExitApp
}




; Width := Gdip_GetImageWidth(pBitmap)
; Height := Gdip_GetImageHeight(pBitmap)
; scaledWidth := mapWidth
; scaledHeight := (scaledWidth / Width) * Height
; scaledHeight *= 0.5


; Gdip_GetRotatedDimensions(Width, Height, Angle, RWidth, RHeight)
; Gdip_GetRotatedTranslation(Width, Height, Angle, xTranslation, yTranslation)

; hbm := CreateDIBSection(RWidth, RHeight)
; hdc := CreateCompatibleDC()
; obm := SelectObject(hdc, hbm)
; ;G := Gdip_GraphicsFromHDC(hdc)
; ; G := Gdip_GraphicsFromImage(pBitmap)

; ;Gdip_SetInterpolationMode(G, 7)
; Gdip_SetSmoothingMode(G, 4)  

; ; ;draw player dot
; ; pPen := Gdip_CreatePen(0xff00FF00, 5)
; ; Gdip_DrawRectangle(G, pPen, xPosDot, yPosDot, 5, 5)
; ; Gdip_DrawRectangle(G, pPen, 0, 0, Width, Height) ;outline
; ; Gdip_DeletePen(pPen)

; ; pBrush := Gdip_BrushCreateHatch(0xff00FFFF, 0xffFFFF00, 31)
; ; Gdip_FillRectangle(G, pBrush, xPosDot+60, yPosDot, 50, 50)
; ; Gdip_DeleteBrush(pBrush)

; G := Gdip_GraphicsFromHDC(hdc)
; pRotatedBitmap := Gdip_RotateBitmap(pBitmap, Angle) ; rotates bitmap for 45 degrees. Disposes of pBitmap.
; newSize := "w1000 h" scaledHeight
; pResizedBitmap  := Gdip_ResizeBitmap(pRotatedBitmap, newSize)

; newWidth := Gdip_GetImageWidth(pResizedBitmap) 
; newHeight := Gdip_GetImageHeight(pResizedBitmap)
; WriteLog("RWidth: " RWidth " RHeight: " RHeight)
; WriteLog("Width: " Width " Height: " Height)
; WriteLog("newWidth: " newWidth " newHeight: " newHeight)
; WriteLog("xTranslation: " xTranslation " yTranslation: " yTranslation)

; Gdip_DrawImage(G, pResizedBitmap, 0, 0, RWidth, RHeight, 0, 0, RWidth, RHeight, opacity)
; UpdateLayeredWindow(hwnd1, hdc, leftMargin, topMargin, newWidth, newHeight)
; ;Gdip_SaveBitmapToFile(pResizedBitmap, "testfile.png")
; SelectObject(hdc, obm)
; DeleteObject(hbm)
; DeleteDC(hdc)
; Gdip_DeleteGraphics(G)
; Gdip_DisposeImage(pBitmap)
; ElapsedTime := A_TickCount - StartTime
; WriteLog("Draw players " ElapsedTime " ms taken")






Esc::
{
	ExitApp
}


