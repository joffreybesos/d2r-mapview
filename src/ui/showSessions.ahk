#SingleInstance, Force

SetWorkingDir, %A_ScriptDir%
#Include %A_ScriptDir%\include\Gdip_All.ahk
#Include %A_ScriptDir%\stats\GameSession.ahk

ShowHistoryText(hwnd1, gameWindowId, sessionList, position = "RIGHT", textBoxWidth = 800, fontSize = 26) {
    WinGetPos, , , Width, Height, %gameWindowId%
    if (position == "RIGHT") {
        leftMargin := Width - textBoxWidth
    } else if (position = "LEFT") {
        leftMargin := 20
    } else {
        leftMargin := Width - textBoxWidth
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

        col1 := 0
        col2 := textBoxWidth * 0.4
        col3 := textBoxWidth * 0.75
        Options = x%col1% y0 Left vCenter cffffffff r4 s%fontSize% Bold
        Gdip_TextToGraphics(G, "Character", Options, diabloFont, Width, 50)
        Options = x%col2% y0 Left vCenter cffffffff r4 s%fontSize% Bold
        Gdip_TextToGraphics(G, "Game Name", Options, diabloFont, Width, 50)
        Options = x%col3% y0 Left vCenter cffffffff r4 s%fontSize% Bold
        Gdip_TextToGraphics(G, "Duration", Options, diabloFont, Width, 50)

        ; lists is in reverse order
        max := sessionList.length()
        playerNameList :=
        Loop %max%
        {
            session := sessionList[(max-A_Index+1)]
            playerNameList := playerNameList . session.playerName . "`n"
        }
        gameNameList :=
        Loop %max%
        {
            session := sessionList[(max-A_Index+1)]
            gameNameList := gameNameList . session.gameName . "`n"
        }
        gameTimeList :=
        Loop %max%
        {
            session := sessionList[(max-A_Index+1)]
            gameTime := session.getDuration()
            gameTime := Round(gameTime, 1) . " sec"
            gameTimeList := gameTimeList . gameTime . "`n"
        }
        
        Options = x%col1% y40 Left vTop cffFFD700 r4 s%fontSize%
        Gdip_TextToGraphics(G, playerNameList, Options, diabloFont, Width, Height)
        Options = x%col2% y40 Left vTop cffFFD700 r4 s%fontSize%
        Gdip_TextToGraphics(G, gameNameList, Options, diabloFont, Width, Height)
        Options = x%col3% y40 Left vTop cffFFD700 r4 s%fontSize%
        Gdip_TextToGraphics(G, gameTimeList, Options, diabloFont, Width/2, Height)

        
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
}

