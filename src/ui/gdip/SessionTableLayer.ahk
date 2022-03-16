#NoEnv

class SessionTableLayer {
    hbm :=
    hdc :=
    obm :=
    G :=
    SessionTableLayerHwnd :=

    __new(ByRef settings) {
        Gui, SessionTable: -Caption +E0x20 +E0x80000 +E0x00080000 +LastFound +AlwaysOnTop +ToolWindow +OwnDialogs 
        this.SessionTableLayerHwnd := WinExist()
        this.y := 20
        WinGetPos, , , gameWidth, gameHeight, %gameWindowId% 
        this.drawBoxWidth := 400
        this.drawBoxHeight := gameHeight
        pToken := Gdip_Startup()
        DetectHiddenWindows, On
        this.hbm := CreateDIBSection(this.drawBoxWidth, this.drawBoxHeight)
        this.hdc := CreateCompatibleDC()
        this.obm := SelectObject(this.hdc, this.hbm)
        this.G := Gdip_GraphicsFromHDC(this.hdc)
        Gdip_SetSmoothingMode(this.G, 4)
        Gdip_SetInterpolationMode(this.G, 7)
        Gui, SessionTable: Show, NA
    }

    drawTable(ByRef sessionList) {
        col1 := 0
        col2 := textBoxWidth * 0.11
        col3 := textBoxWidth * 0.33
        col4 := textBoxWidth * 0.63
        col5 := textBoxWidth * 0.81

        this.drawHeader(col1, 0, fontSize, "L")
        this.drawHeader(col2, 0, fontSize, "Character")
        this.drawHeader(col3, 0, fontSize, "Game Name")
        this.drawHeader(col4, 0, fontSize, "Duration")
        this.drawHeader(col5, 0, fontSize, "+XP")

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
            playerLevelList := playerLevelList . session.getPreciseLevel() . "`n"
            playerNameList := playerNameList . session.playerName . "`n"
            gameNameList := gameNameList . session.gameName . "`n"
            xpgainedList := xpgainedList . session.getExperienceGained() . "`n"
            gameTime := session.duration . "s"
            gameTimeList := gameTimeList . gameTime . "`n"
        }
        this.drawData(G, col1, 40, fontSize, playerLevelList)
        this.drawData(G, col2, 40, fontSize, playerNameList)
        this.drawData(G, col3, 40, fontSize, gameNameList)
        this.drawData(G, col4, 40, fontSize, gameTimeList)
        this.drawData(G, col5, 40, fontSize, xpgainedList)

        UpdateLayeredWindow(this.SessionTableLayerHwnd, this.hdc, 0, 0, this.drawBoxWidth, this.drawBoxHeight)
    }

    
    drawHeader(textx, texty,fontSize, textStr) {
        Options = x%textx% y%texty% Left vCenter cffffffff r4 s%fontSize% Bold
        textx := textx + 2
        texty := texty + 2
        Options2 = x%textx% y%texty% Left vCenter cff000000 r4 s%fontSize% Bold
        Gdip_TextToGraphics(this.G, textStr, Options2, exocetFont, this.drawBoxWidth, 50)
        Gdip_TextToGraphics(this.G, textStr, Options, exocetFont, this.drawBoxWidth, 50)
    }

    drawData(textx, texty, fontSize, textList) {
        Options = x%textx% y%texty% Left vTop cffFFD700 r4 s%fontSize% Bold
        textx := textx + 2
        texty := texty + 2
        Options2 = x%textx% y%texty% Left vTop cff000000 r4 s%fontSize% Bold
        Gdip_TextToGraphics(this.G, textList, Options2, exocetFont, this.drawBoxWidth, this.drawBoxHeight)
        Gdip_TextToGraphics(this.G, textList, Options, exocetFont, this.drawBoxWidth, this.drawBoxHeight)
    }

    delete() {
        SelectObject(this.hdc, this.obm)
        DeleteObject(this.hbm)
        DeleteDC(this.hdc)
        Gui, SessionTable: Destroy
    }
}