#SingleInstance, Force

; #Include ..\include\Gdip_All.ahk
#Include ..\..\src\stats\GameSession.ahk

ShowHistoryText(hwnd1, gameWindowId, sessionList, position = "RIGHT", textBoxWidth = 800, fontSize = 26) {
    
    ; WinGetPos, , , Width, Height, %gameWindowId%
    Width := A_ScreenWidth
    Height := A_ScreenHeight
    
    if (position == "RIGHT") {
        leftMargin := Width - textBoxWidth
    } else if (position = "LEFT") {
        leftMargin := 20
    } else {
        leftMargin := 20
    }
    topMargin := 20
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

        col1 := 0
        col2 := textBoxWidth * 0.4
        col3 := textBoxWidth * 0.78

        Options = x%col1% y0 Left vCenter cffffffff r4 s%fontSize% Bold
        Gdip_TextToGraphics(G, "Game Name", Options, diabloFont, Width, 50)
        Options = x%col2% y0 Left vCenter cffffffff r4 s%fontSize% Bold
        Gdip_TextToGraphics(G, "Character", Options, diabloFont, Width, 50)
        Options = x%col3% y0 Left vCenter cffffffff r4 s%fontSize% Bold
        Gdip_TextToGraphics(G, "Duration", Options, diabloFont, Width, 50)

        y := 40
        ; lists is in reverse order
        max := sessionList.length()
        Loop %max%
        {
            session := sessionList[(max-A_Index+1)]
            gameName := session.gameName
            playerName := session.playerName
            gameTime := session.getDuration()

            Options = x%col1% y%y% Left vCenter cffFFD700 r4 s%fontSize%
            Gdip_TextToGraphics(G, gameName, Options, diabloFont, Width, 50)

            Options = x%col2% y%y% Left vCenter cffFFD700 r4 s%fontSize%
            Gdip_TextToGraphics(G, playerName, Options, diabloFont, Width, 50)

            gameTime := Round(gameTime, 1) . " sec"
            Options = x%col3% y%y% Left vCenter cffFFD700 r4 s%fontSize%
            Gdip_TextToGraphics(G, gameTime, Options, diabloFont, Width/2, 50)
            y += 40
            
        }
        UpdateLayeredWindow(hwnd1, hdc, leftMargin, topMargin, Width, Height)
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

Return
