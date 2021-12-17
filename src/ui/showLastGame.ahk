#SingleInstance, Force
SendMode Input
SetWorkingDir, %A_ScriptDir%

ShowGameText(gameName, hwnd1, gameTime, gameWindowId) {
    WinGetPos, , , Width, Height, %gameWindowId%
    
    Height := 400
    leftMargin := Width - 420
    topMargin := 20
    
    Width := 400
    if (WinExist(gameWindowId)) {
        
        pToken := Gdip_Startup()

         
        DetectHiddenWindows, On
        hbm := CreateDIBSection(Width, Height)
        hdc := CreateCompatibleDC()
        obm := SelectObject(hdc, hbm)
        G := Gdip_GraphicsFromHDC(hdc)
        Gdip_SetSmoothingMode(G, 4)
        pBrush := Gdip_BrushCreateSolid(0xAA000000)
        Gdip_DeleteBrush(pBrush)
        
        if (gameName) {
            Options = x0 y0 Left vCenter cffffffff r4 s22
            Gdip_TextToGraphics(G, "Previous game name", Options, diabloFont, Width, 50)

            Options = x0 y40 Left vCenter cffFFD700 r4 s24  Bold
            Gdip_TextToGraphics(G, gameName, Options, diabloFont, Width, 50)

            if (gameTime) {
                gameTime := Round(gameTime, 1) . " sec"
                Options = x270 y40 Left vCenter cffFFD700 r4 s24
                Gdip_TextToGraphics(G, gameTime, Options, diabloFont, Width/2, 50)
            }
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
    Return
}

; ShowGameText(gameName, HelpText1, gameTime, gameWindowId) {
;     SetFormat Integer, D
;     ;WinGetPos, , , Width, Height, %gameWindowId%
    
;     leftMargin := 0
;     topMargin := 20

;     if (WinExist(gameWindowId)) {
;         OGdip.Startup()  ; This function initializes GDI+ and must be called first.
;         bmp := new OGdip.Bitmap(400,400)  ; Create new empty Bitmap with given width and height
;         bmp.GetGraphics()                                  ; .G refers to Graphics surface of this Bitmap, it's used to draw things

;         if (gameName != "") {
;             WhiteBrush:= new OGdip.Brush(0xFFFFFFFF)
;             bmp.G.SetBrush(WhiteBrush)
;             bmp.G.SetOptions( {textHint:"Antialias"})
;             whiteTextFont := new OGdip.Font("Arial", 21)
;             textFormat := new OGdip.StringFormat(0)
;             bmp.G.DrawString("Previous game name:", whiteTextFont, leftMargin, topMargin, 0, 0, textFormat)

            
;             YellowBrush:= new OGdip.Brush(0xffFFFF00)
;             bmp.G.SetBrush(YellowBrush)
;             bmp.G.SetOptions( {textHint:"Antialias"})
;             yellowTextFont := new OGdip.Font("Arial", 38, "Bold")
;             textFormat := new OGdip.StringFormat(0)
;             bmp.G.DrawString(gameName, yellowTextFont, leftMargin, (topMargin + 25), 0, 0, textFormat)
;         }

;         if (gameTime > 0) {
;             WhiteBrush:= new OGdip.Brush(0xFFFFFFFF)
;             bmp.G.SetBrush(WhiteBrush)
;             bmp.G.SetOptions( {textHint:"Antialias"})
;             whiteTextFont := new OGdip.Font("Arial", 21)
;             textFormat := new OGdip.StringFormat(0)
;             bmp.G.DrawString("Previous game time:", whiteTextFont, leftMargin, (topMargin + 100), 0, 0, textFormat)

;             gameTime := Round(gameTime , 2)
;             gameTime := gameTime . "sec"
;             YellowBrush:= new OGdip.Brush(0xffFFFF00)
;             bmp.G.SetBrush(YellowBrush)
;             bmp.G.SetOptions( {textHint:"Antialias"})
;             yellowTextFont := new OGdip.Font("Arial", 38, "Bold")
;             textFormat := new OGdip.StringFormat(0)
;             bmp.G.DrawString(gameTime, yellowTextFont, leftMargin, (topMargin + 120), 0, 0, textFormat)
;         }

;         bmp.SetToControl(HelpText1)
;         if WinActive(gameWindowId) {
;             WinGetPos, , , Width, Height, %gameWindowId%
;             gameInfoLeftMargin := (Width - 400)
;             Gui, GameInfo: Color,000000
;             WinSet,Transcolor, 000000 255
;             Gui, GameInfo: Show, w400 h400 x%gameInfoLeftMargin% y0 NA
;         } else {
;             gui, GameInfo: Hide
;         }
;     } else {
;         gui, GameInfo: Hide
;     }
;     Return
; ; }