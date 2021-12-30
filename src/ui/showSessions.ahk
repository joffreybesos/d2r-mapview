#SingleInstance, Force

SetWorkingDir, %A_ScriptDir%
#Include %A_ScriptDir%\include\Gdip_All.ahk
#Include %A_ScriptDir%\stats\GameSession.ahk

ShowHistoryText(hwnd1, gameWindowId, sessionList, position = "RIGHT", textBoxWidth = 800, fontSize = 26) {
    WinGetPos, , , Width, Height, %gameWindowId%
    StringLower, position, %position%
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
        col2 := textBoxWidth * 0.06
        col3 := textBoxWidth * 0.31
        col4 := textBoxWidth * 0.61
        col5 := textBoxWidth * 0.79
        Options = x%col1% y0 Left vCenter cffffffff r4 s%fontSize% Bold
        Gdip_TextToGraphics(G, "L", Options, diabloFont, Width, 50)
        Options = x%col2% y0 Left vCenter cffffffff r4 s%fontSize% Bold
        Gdip_TextToGraphics(G, "Character", Options, diabloFont, Width, 50)
        Options = x%col3% y0 Left vCenter cffffffff r4 s%fontSize% Bold
        Gdip_TextToGraphics(G, "Game Name", Options, diabloFont, Width, 50)
        Options = x%col4% y0 Left vCenter cffffffff r4 s%fontSize% Bold
        Gdip_TextToGraphics(G, "Duration", Options, diabloFont, Width, 50)
        Options = x%col5% y0 Left vCenter cffffffff r4 s%fontSize% Bold
        Gdip_TextToGraphics(G, "+XP", Options, diabloFont, Width, 50)

        ; lists is in reverse order
        max := sessionList.length()
        playerLevelList :=
        playerNameList :=
        gameNameList :=
        gameTimeList :=
        xpgainedList :=
        Loop %max%
        {
            session := sessionList[(max-A_Index+1)]
            playerLevelList := playerLevelList . session.endingPlayerLevel . "`n"
            playerNameList := playerNameList . session.playerName . "`n"
            gameNameList := gameNameList . session.gameName . "`n"
            xpgainedList := xpgainedList . session.getExperienceGained() . "`n"
            gameTime := session.getDuration()
            gameTime := Round(gameTime, 1) . " sec"
            gameTimeList := gameTimeList . gameTime . "`n"
            
        }
        
        Options = x%col1% y40 Left vTop cffFFD700 r4 s%fontSize%
        Gdip_TextToGraphics(G, playerLevelList, Options, diabloFont, Width, Height)
        Options = x%col2% y40 Left vTop cffFFD700 r4 s%fontSize%
        Gdip_TextToGraphics(G, playerNameList, Options, diabloFont, Width, Height)
        Options = x%col3% y40 Left vTop cffFFD700 r4 s%fontSize%
        Gdip_TextToGraphics(G, gameNameList, Options, diabloFont, Width, Height)
        Options = x%col4% y40 Left vTop cffFFD700 r4 s%fontSize%
        Gdip_TextToGraphics(G, gameTimeList, Options, diabloFont, Width/2, Height)
        Options = x%col5% y40 Left vTop cffFFD700 r4 s%fontSize%
        Gdip_TextToGraphics(G, xpgainedList, Options, diabloFont, Width/2, Height)

        
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

