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
        WinGetPos, gameWindowX, gameWindowY, gameWindowWidth, gameWindowHeight, %gameWindowId% 
        this.gameWindowX := gameWindowX
        this.gameWindowY := gameWindowY
        this.gameWindowWidth := gameWindowWidth
        this.gameWindowHeight := gameWindowHeight

        pToken := Gdip_Startup()
        DetectHiddenWindows, On
        this.hbm := CreateDIBSection(gameWindowWidth, gameWindowHeight)
        this.hdc := CreateCompatibleDC()
        this.obm := SelectObject(this.hdc, this.hbm)
        this.G := Gdip_GraphicsFromHDC(this.hdc)
        Gdip_SetSmoothingMode(this.G, 4)
        Gdip_SetInterpolationMode(this.G, 7)
        Gui, SessionTable: Show, NA
        
        this.historyTextSize := settings["historyTextSize"]
        historyTextAlignment := settings["historyTextAlignment"]
        StringUpper, historyTextAlignment, historyTextAlignment
        this.historyTextAlignment := historyTextAlignment

    }

    drawTable(ByRef sessionList, ByRef historyToggle) {
        if (WinActive(gameWindowId) and historyToggle) {
            Gui, SessionTable: Show, NA
        } else {
            Gui, SessionTable: Hide
        }
        fontSize := this.historyTextSize
        headery := 40
        datay := 15
        col1 := 5

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
            rowNum := rowNum "" A_Index "`n"
            playerLevelList := playerLevelList . session.getPreciseLevel() . "`n"
            playerNameList := playerNameList . session.playerName . "`n"
            gameNameList := gameNameList . session.gameName . "`n"
            xpgainedList := xpgainedList . session.getExperienceGained() . "`n"
            gameTimeList := gameTimeList . this.GetDurationFormatEx(session.duration) . "`n"
        }
        
        col2 := this.drawData(col1, headery, fontSize, rowNum, 2 * fontSize)
        col3 := this.drawData(col2, headery, fontSize, playerLevelList, 3 * fontSize)
        col4 := this.drawData(col3, headery, fontSize, playerNameList, 9 * fontSize)
        col5 := this.drawData(col4, headery, fontSize, gameNameList, 9 * fontSize)
        col6 := this.drawData(col5, headery, fontSize, gameTimeList, 8 * fontSize)
        col7 := this.drawData(col6, headery, fontSize, xpgainedList, 3 * fontSize)

        this.drawHeader(col1, datay, fontSize, "#")
        this.drawHeader(col2, datay, fontSize, "Lvl")
        this.drawHeader(col3, datay, fontSize, "Character")
        this.drawHeader(col4, datay, fontSize, "Game Name")
        this.drawHeader(col5, datay, fontSize, "Duration")
        this.drawHeader(col6, datay, fontSize, "+XP")

        leftMargin := this.gameWindowX
        if (this.historyTextAlignment == "RIGHT") {
            leftMargin :=  this.gameWindowWidth - col7 +  this.gameWindowX - 5
        }
        UpdateLayeredWindow(this.SessionTableLayerHwnd, this.hdc, leftMargin, this.gameWindowY, this.gameWindowWidth, this.gameWindowHeight)
    }

    drawHeader(textx, texty, fontSize, textStr) {
        Options = x%textx% y%texty% Left vBottom cffffffff r4 s%fontSize% Bold
        textx := textx + 1
        texty := texty + 1
        Options2 = x%textx% y%texty% Left vBottom cff000000 r4 s%fontSize% Bold
        Gdip_TextToGraphics(this.G, textStr, Options2, formalFont)
        Gdip_TextToGraphics(this.G, textStr, Options, formalFont)
    }

    drawData(textx, texty, fontSize, textList, defaultColumnWidth) {
        Options = x%textx% y%texty% Left vTop cffFFD700 r4 s%fontSize%
        Options = x%textx% y%texty% Left vTop cffFFD700 r4 s%fontSize%
        textx := textx + 1
        texty := texty + 1
        Options2 = x%textx% y%texty% Left vTop cff000000 r4 s%fontSize%
        Gdip_TextToGraphics(this.G, textList, Options2, formalFont)
        drawnArea := Gdip_TextToGraphics(this.G, textList, Options, formalFont)
        ms := StrSplit(drawnArea , "|")
        return ms[3] > 0.0 ? ms[3] + textx + 5 : defaultColumnWidth + textx
        
    }

    hide() {
        Gui, SessionTable: Hide
    }

    delete() {
        SelectObject(this.hdc, this.obm)
        DeleteObject(this.hbm)
        DeleteDC(this.hdc)
        Gui, SessionTable: Destroy
    }

    GetDurationFormatEx(Duration, Format := "m' m 's' s'", LocaleName := "!x-sys-default-locale")
    {
        if (Size := DllCall("GetDurationFormatEx", "str", LocaleName, "uint", 0, "ptr", 0, "int64", Duration * 10000000, "ptr", (Format ? &Format : 0), "ptr", 0, "int", 0)) {
            VarSetCapacity(DurationStr, Size << !!A_IsUnicode, 0)
            if (DllCall("GetDurationFormatEx", "str", LocaleName, "uint", 0, "ptr", 0, "int64", Duration * 10000000, "ptr", (Format ? &Format : 0), "str", DurationStr, "int", Size))
                return DurationStr
        }
        return false
    }
}