#SingleInstance, Force
SendMode Input
SetWorkingDir, %A_ScriptDir%

ShowLastGame(settings, lastGameDuration) {


    if (_ClassMemory.__Class != "_ClassMemory")
    {
        WriteLog("Missing classMemory.ahk dependency. Quitting")
        ExitApp
    }

    d2r := new _ClassMemory(gameWindowId, "", hProcessCopy) 

    if !isObject(d2r) 
    {
        WriteLog(gameWindowId " not found, please make sure game is running")
        WriteTimedLog()
        ExitApp
    }
    
    gameNameOffset := settings["gameNameOffset"]
    gameNameAddress := d2r.BaseAddress + gameNameOffset
    gameName :=
    Loop, 16
    {
        gameName := gameName . Chr(d2r.read(gameNameAddress + (A_Index -1), "UChar"))
    }
    ShowGameText(gameName, lastGameDuration, gameWindowId)
}


ShowGameText(gameName, gameTime, gameWindowId) {
    SetFormat Integer, D
    WinGetPos, , , W, H, %gameWindowId%
    
    leftMargin := (W - 400)
    topMargin := 20

    if (W) {
        OGdip.Startup()  ; This function initializes GDI+ and must be called first.
        Width := W
        Height := H

        Gui, GameInfo: -Caption +E0x20 +LastFound +AlwaysOnTop +ToolWindow +OwnDialogs
        gui, GameInfo: add, Picture, w%Width% h%Height% x0 y0 hwndHelpText1
        Gui, GameInfo: +E0x02000000 +E0x00080000 ; WS_EX_COMPOSITED & WS_EX_LAYERED => Double Buffer

        ; make transparent
        Gui, GameInfo: Color,000000
        WinSet,Transcolor, 000000 255

        bmp := new OGdip.Bitmap(Width,Height)  ; Create new empty Bitmap with given width and height
        bmp.GetGraphics()                                  ; .G refers to Graphics surface of this Bitmap, it's used to draw things
        Gui, GameInfo: +LastFound

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