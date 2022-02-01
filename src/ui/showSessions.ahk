#SingleInstance, Force

SetWorkingDir, %A_ScriptDir%
#Include %A_ScriptDir%\include\Gdip_All.ahk
#Include %A_ScriptDir%\stats\GameSession.ahk

ShowHistoryText(hwnd1, gameWindowId, sessionList, historyToggle, position = "RIGHT", textBoxWidth = 800, fontSize = 26) {
    WinGetPos, , , Width, Height, %gameWindowId%
    StringLower, position, position
    if (position == "right") {
        leftMargin := Width - textBoxWidth
    } else if (position = "left") {
        leftMargin := 20
    } else {
        leftMargin := Width - textBoxWidth
    }
    topMargin := 20
    if (WinExist(gameWindowId) and historyToggle) {
        
        pToken := Gdip_Startup()
        DetectHiddenWindows, On
        hbm := CreateDIBSection(Width, Height)
        hdc := CreateCompatibleDC()
        obm := SelectObject(hdc, hbm)
        G := Gdip_GraphicsFromHDC(hdc)
        Gdip_SetSmoothingMode(G, 4)
        Gdip_SetInterpolationMode(G, 7)

        col1 := 0
        col2 := textBoxWidth * 0.06
        col3 := textBoxWidth * 0.31
        col4 := textBoxWidth * 0.61
        col5 := textBoxWidth * 0.79

        drawHeader(G, col1, 0, Width, fontSize, "L")
        drawHeader(G, col2, 0, Width, fontSize, "Character")
        drawHeader(G, col3, 0, Width, fontSize, "Game Name")
        drawHeader(G, col4, 0, Width, fontSize, "Duration")
        drawHeader(G, col5, 0, Width, fontSize, "+XP")

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
            gameTime := session.duration . "s"
            gameTimeList := gameTimeList . gameTime . "`n"
        }
        drawData(G, col1, 40, Width, Height, fontSize, playerLevelList)
        drawData(G, col2, 40, Width, Height, fontSize, playerNameList)
        drawData(G, col3, 40, Width, Height, fontSize, gameNameList)
        drawData(G, col4, 40, Width/2, Height, fontSize, gameTimeList)
        drawData(G, col5, 40, Width/2, Height, fontSize, xpgainedList)

        
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

drawHeader(G, textx, texty, Width, fontSize, textStr) {
    Options = x%textx% y%texty% Left vCenter cffffffff r4 s%fontSize% Bold
    textx := textx + 2
    texty := texty + 2
    Options2 = x%textx% y%texty% Left vCenter cff000000 r4 s%fontSize% Bold
    Gdip_TextToGraphics(G, textStr, Options2, diabloFont, Width, 50)
    Gdip_TextToGraphics(G, textStr, Options, diabloFont, Width, 50)
}

drawData(G, textx, texty, Width, Height, fontSize, textList) {
    Options = x%textx% y%texty% Left vTop cffFFD700 r4 s%fontSize% Bold
    textx := textx + 2
    texty := texty + 2
    Options2 = x%textx% y%texty% Left vTop cff000000 r4 s%fontSize% Bold
    Gdip_TextToGraphics(G, textList, Options2, diabloFont, Width, Height)
    Gdip_TextToGraphics(G, textList, Options, diabloFont, Width, Height)
}