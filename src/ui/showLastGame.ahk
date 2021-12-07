#SingleInstance, Force
SendMode Input
SetWorkingDir, %A_ScriptDir%


ShowGameText(gameName, HelpText1, gameTime, gameWindowId) {
    SetFormat Integer, D
    WinGetPos, , , Width, Height, %gameWindowId%
    
    leftMargin := (Width - 400)
    topMargin := 20

    if (Width) {
        OGdip.Startup()  ; This function initializes GDI+ and must be called first.
        bmp := new OGdip.Bitmap(Width,Height)  ; Create new empty Bitmap with given width and height
        bmp.GetGraphics()                                  ; .G refers to Graphics surface of this Bitmap, it's used to draw things

        if (gameName != "") {
            WhiteBrush:= new OGdip.Brush(0xFFFFFFFF)
            bmp.G.SetBrush(WhiteBrush)
            bmp.G.SetOptions( {textHint:"Antialias"})
            whiteTextFont := new OGdip.Font("Arial", 21)
            textFormat := new OGdip.StringFormat(0)
            bmp.G.DrawString("Previous game name:", whiteTextFont, leftMargin, topMargin, 0, 0, textFormat)

            
            YellowBrush:= new OGdip.Brush(0xffFFFF00)
            bmp.G.SetBrush(YellowBrush)
            bmp.G.SetOptions( {textHint:"Antialias"})
            yellowTextFont := new OGdip.Font("Arial", 38, "Bold")
            textFormat := new OGdip.StringFormat(0)
            bmp.G.DrawString(gameName, yellowTextFont, leftMargin, (topMargin + 25), 0, 0, textFormat)
        }

        if (gameTime > 0) {
            WhiteBrush:= new OGdip.Brush(0xFFFFFFFF)
            bmp.G.SetBrush(WhiteBrush)
            bmp.G.SetOptions( {textHint:"Antialias"})
            whiteTextFont := new OGdip.Font("Arial", 21)
            textFormat := new OGdip.StringFormat(0)
            bmp.G.DrawString("Previous game time:", whiteTextFont, leftMargin, (topMargin + 100), 0, 0, textFormat)

            gameTime := Round(gameTime , 2)
            gameTime := gameTime . "sec"
            YellowBrush:= new OGdip.Brush(0xffFFFF00)
            bmp.G.SetBrush(YellowBrush)
            bmp.G.SetOptions( {textHint:"Antialias"})
            yellowTextFont := new OGdip.Font("Arial", 38, "Bold")
            textFormat := new OGdip.StringFormat(0)
            bmp.G.DrawString(gameTime, yellowTextFont, leftMargin, (topMargin + 120), 0, 0, textFormat)
        }

        bmp.SetToControl(HelpText1)
        if WinActive(gameWindowId) {
            gui, GameInfo: Show, NA
        } else {
            gui, GameInfo: Hide
        }
    } else {
        gui, GameInfo: Hide
    }
    Return
}