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
        gameClientArea := getWindowClientArea()
        this.gameWindowX := gameClientArea["X"]
        this.gameWindowY := gameClientArea["Y"]
        this.gameWindowWidth := gameClientArea["W"]
        this.gameWindowHeight := gameClientArea["H"]

        pToken := Gdip_Startup()
        DetectHiddenWindows, On
        this.hbm := CreateDIBSection(this.gameWindowWidth, this.gameWindowHeight)
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
        this.bgBox := Gdip_BrushCreateSolid(0x66000000)

    }

    drawTable(ByRef sessionList, ByRef historyToggle) {
        if (WinActive(gameWindowId) and historyToggle) {
            Gui, SessionTable: Show, NA
        
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
                formattedxp := this.GetNumberFormat(session.getExperienceGained())
                StringTrimRight, formattedxp, formattedxp, 3
                xpgainedList := xpgainedList . formattedxp . "`n"
                gameTimeList := gameTimeList . this.GetDurationFormatEx(session.duration) . "`n"
            }
            
            col2 := this.drawData(col1, headery, fontSize, rowNum, 1 * fontSize)
            col3 := this.drawData(col2, headery, fontSize, playerLevelList, 3 * fontSize)
            col4 := this.drawData(col3, headery, fontSize, playerNameList, 7 * fontSize)
            col5 := this.drawData(col4, headery, fontSize, gameNameList, 7 * fontSize)
            col6 := this.drawData(col5, headery, fontSize, gameTimeList, 6 * fontSize)
            col7 := this.drawData(col6, headery, fontSize, xpgainedList, 2 * fontSize)

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
        } else {
            Gui, SessionTable: Hide
        }
        Gdip_GraphicsClear( this.G )
    }

    drawHeader(textx, texty, fontSize, textStr) {
        Options = x%textx% y%texty% Left vBottom cffffffff r4 s%fontSize% Bold
        shadowtextx := textx + 1
        , shadowtexty := texty + 1
        Options2 = x%shadowtextx% y%shadowtexty% Left vBottom cff000000 r4 s%fontSize% Bold
        
        ;x|y|width|height|chars|lines
        measuredString := Gdip_TextToGraphics(this.G, textStr, Options2, exocetFont)
        ms := StrSplit(measuredString , "|")
        , bgx := ms[1]
        , bgy := ms[2] - 3
        , bgw := ms[3]
        , bgh := ms[4]
        Gdip_FillRectangle(this.G, this.bgBox, bgx, bgy, bgw, bgh)
        Gdip_TextToGraphics(this.G, textStr, Options2, exocetFont)
        Gdip_TextToGraphics(this.G, textStr, Options, exocetFont)
    }

    drawData(textx, texty, fontSize, textList, defaultColumnWidth) {
        Options = x%textx% y%texty% Left vTop cffFFD700 r4 s%fontSize%
        shadowtextx := textx + 1
        , shadowtexty := texty + 1
        Options2 = x%shadowtextx% y%shadowtexty% Left vTop cff000000 r4 s%fontSize%
        ;x|y|width|height|chars|lines
        measuredString := Gdip_TextToGraphics(this.G, textList, Options2, exocetFont)
        ms := StrSplit(measuredString , "|")
        , bgx := ms[1]
        , bgy := ms[2] - 3
        , bgw := ms[3]
        , bgh := ms[4]
        Gdip_FillRectangle(this.G, this.bgBox, bgx, bgy, bgw, bgh)
        drawnArea := Gdip_TextToGraphics(this.G, textList, Options, exocetFont)
        ms := StrSplit(drawnArea , "|")
        minSize := defaultColumnWidth + textx
        textSize := ms[3] + textx + 10
        return textSize > minSize ? textSize : minSize
    }

    hide() {
        Gui, SessionTable: Hide
    }

    delete() {
        SelectObject(this.hdc, this.obm)
        DeleteObject(this.hbm)
        DeleteDC(this.hdc)
        Gui, SessionTable: Destroy
        Gdip_DeleteBrush(this.bgBox)
    }

    GetDurationFormatEx(Duration, Format := "m'm 's's'", LocaleName := "!x-sys-default-locale")
    {
        if (Size := DllCall("GetDurationFormatEx", "str", LocaleName, "uint", 0, "ptr", 0, "int64", Duration * 10000000, "ptr", (Format ? &Format : 0), "ptr", 0, "int", 0)) {
            VarSetCapacity(DurationStr, Size << !!A_IsUnicode, 0)
            if (DllCall("GetDurationFormatEx", "str", LocaleName, "uint", 0, "ptr", 0, "int64", Duration * 10000000, "ptr", (Format ? &Format : 0), "str", DurationStr, "int", Size))
                return DurationStr
        }
        return false
    }
    GetNumberFormat(Value)
    {
        LCID := DllCall("GetThreadLocale", "UInt")
        if (Size := DllCall("GetNumberFormat", "uint", Locale, "uint", 0, "str", Value, "ptr", 0, "ptr", 0, "int", 0)) {
            VarSetCapacity(NumberStr, Size << !!A_IsUnicode, 0)
            if (DllCall("GetNumberFormat", "uint", Locale, "uint", 0, "str", Value, "ptr", 0, "str", NumberStr, "int", Size))
                return NumberStr
        }



        return false
    }
}

