#NoEnv

class GameInfoLayer {
    hbm :=
    hdc :=
    obm :=
    G :=
    GameInfoLayerHwnd :=

    __new(ByRef settings) {
        this.gameInfoSize := settings["gameInfoFontSize"]
        gameInfoAlignment := settings["gameInfoAlignment"]
        StringUpper, gameInfoAlignment, gameInfoAlignment
        this.gameInfoAlignment := gameInfoAlignment
        this.topPadding := 20
        height := this.topPadding
        if (settings["showGameInfo"]) {
            height := height + 80
        }
        if (settings["showFPS"]) {
            height := height + 20
        }
        

        Gui, GameInfo: -Caption +E0x20 +E0x80000 +E0x00080000 +LastFound +AlwaysOnTop +ToolWindow +OwnDialogs 
        this.GameInfoLayerHwnd := WinExist()
        this.y := 20
        WinGetPos, gameWindowX, gameWindowY, gameWindowWidth, gameWindowHeight, %gameWindowId% 
        this.gameWindowX := gameWindowX
        this.gameWindowY := gameWindowY
        this.textBoxWidth := 200
        this.textBoxHeight := height

        pToken := Gdip_Startup()
        DetectHiddenWindows, On
        this.hbm := CreateDIBSection(this.textBoxWidth, this.textBoxHeight)
        this.hdc := CreateCompatibleDC()
        this.obm := SelectObject(this.hdc, this.hbm)
        this.G := Gdip_GraphicsFromHDC(this.hdc)
        Gdip_SetSmoothingMode(this.G, 4)
        Gdip_SetInterpolationMode(this.G, 7)
        Gui, GameInfo: Show, NA
    }

    updateAreaLevel(levelNo, difficulty) {
        areaLevels := getAreaLevel(levelNo)
        this.areaLevel := areaLevels["" difficulty ""]
    }

    updateExpLevel(levelNo, difficulty, clvl) {
        if (this.areaLevel) {
            if (clvl < 25) {
                leveldiff := this.areaLevel - clvl
                experiencePenalty := 0
                switch (leveldiff) {
                    case 6:  experiencePenalty := 19
                    case 7:  experiencePenalty := 38
                    case 8:  experiencePenalty := 57
                    case 9:  experiencePenalty := 76
                    case 10:  experiencePenalty := 95
                    case -6:  experiencePenalty := 19
                    case -7:  experiencePenalty := 38
                    case -8:  experiencePenalty := 57
                    case -9:  experiencePenalty := 76
                    case -10:  experiencePenalty := 95
                }
                if (levelDiff > 10)
                    experiencePenalty := 95
                if (levelDiff < -10)
                    experiencePenalty := 95

            } else if (clvl > 25 and clvl < 70) {
                leveldiff := clvl - this.areaLevel
                experiencePenalty := 0
                switch (leveldiff) {
                    case 6:  experiencePenalty := 19
                    case 7:  experiencePenalty := 38
                    case 8:  experiencePenalty := 57
                    case 9:  experiencePenalty := 76
                    case 10:  experiencePenalty := 95
                }
                if (levelDiff > 10)
                    experiencePenalty := 95
            } else if (clvl > 70) {
                experiencePenalty := 0
            }
            this.experiencePenalty := experiencePenalty
        } else {
            this.experiencePenalty := 0
        }
    }

    drawInfoText(ByRef currentFPS) {
        if (WinActive(gameWindowId)) {
            Gui, GameInfo: Show, NA
        } else {
            Gui, GameInfo: Hide
        }
        fontSize := this.gameInfoSize
        textList := ""
        if (settings["showGameInfo"]) {
            textList := "D2R-MAPVIEW`n"
            ; only show this text for the first 10 seconds from startup
            if (!hideStartupText) {
                if (A_TickCount - ScriptStartTime < 10000) {
                    textList := textList "Ctrl+O for options`n"
                    textList := textList "Ctrl+H for help`n"
                } else {
                    height := height - 40
                    hideStartupText := true
                }
            }
            if (this.areaLevel) {
                textList := textList "Area Level: " this.areaLevel "`n"
            }
            if (this.experiencePenalty > 0) {
                textList := textList "XP penalty: " this.experiencePenalty "% `n"
            }
        }
        if (settings["showFPS"]) {
            textList := textLIst "FPS " currentFPS
        }
        if (textList) {
            this.drawData(5, this.topPadding, fontSize, textList)
            leftMargin := this.gameWindowX
            if (this.gameInfoAlignment == "RIGHT") {
                leftMargin :=  this.gameWindowWidth - this.textBoxWidth + this.gameWindowX - 5
            }
            UpdateLayeredWindow(this.GameInfoLayerHwnd, this.hdc, leftMargin, this.gameWindowY, this.textBoxWidth, this.textBoxHeight)
        }
        Gdip_GraphicsClear( this.G )
    }


    drawData(textx, texty, fontSize, textList) {
        Options = x%textx% y%texty% Left vTop cffc6b276 r4 s%fontSize%
        textx := textx + 1
        texty := texty + 1
        Options2 = x%textx% y%texty% Left vTop cff000000 r4 s%fontSize%
        Gdip_TextToGraphics(this.G, textList, Options2, exocetFont)
        Gdip_TextToGraphics(this.G, textList, Options, exocetFont)
    }

    hide() {
        Gui, GameInfo: Hide
    }

    delete() {
        SelectObject(this.hdc, this.obm)
        DeleteObject(this.hbm)
        DeleteDC(this.hdc)
        Gui, GameInfo: Destroy
    }

}

getAreaLevel(levelNo) {
    switch (levelNo) {
        case 2: return { "0": 1, "1": 36, "2": 67}
        case 3: return { "0": 2, "1": 36, "2": 68}
        case 4: return { "0": 4, "1": 37, "2": 68}
        case 5: return { "0": 5, "1": 38, "2": 68}
        case 6: return { "0": 6, "1": 38, "2": 69}
        case 7: return { "0": 8, "1": 39, "2": 69}
        case 8: return { "0": 1, "1": 36, "2": 79}
        case 9: return { "0": 2, "1": 36, "2": 77}
        case 10: return { "0": 4, "1": 37, "2": 69}
        case 11: return { "0": 5, "1": 38, "2": 80}
        case 12: return { "0": 7, "1": 39, "2": 85}
        case 13: return { "0": 2, "1": 37, "2": 78}
        case 14: return { "0": 4, "1": 38, "2": 83}
        case 15: return { "0": 5, "1": 39, "2": 81}
        case 16: return { "0": 7, "1": 40, "2": 85}
        case 17: return { "0": 3, "1": 36, "2": 80}
        case 18: return { "0": 3, "1": 37, "2": 83}
        case 19: return { "0": 3, "1": 37, "2": 85}
        case 21: return { "0": 7, "1": 38, "2": 75}
        case 22: return { "0": 7, "1": 39, "2": 76}
        case 23: return { "0": 7, "1": 40, "2": 77}
        case 24: return { "0": 7, "1": 41, "2": 78}
        case 25: return { "0": 7, "1": 42, "2": 79}
        case 26: return { "0": 8, "1": 40, "2": 70}
        case 27: return { "0": 9, "1": 40, "2": 70}
        case 28: return { "0": 9, "1": 40, "2": 70}
        case 29: return { "0": 10, "1": 41, "2": 71}
        case 30: return { "0": 10, "1": 41, "2": 71}
        case 31: return { "0": 10, "1": 41, "2": 71}
        case 32: return { "0": 10, "1": 41, "2": 72}
        case 33: return { "0": 11, "1": 42, "2": 72}
        case 34: return { "0": 11, "1": 42, "2": 72}
        case 35: return { "0": 11, "1": 42, "2": 73}
        case 36: return { "0": 12, "1": 43, "2": 73}
        case 37: return { "0": 12, "1": 43, "2": 73}
        case 38: return { "0": 6, "1": 39, "2": 76}
        case 39: return { "0": 28, "1": 64, "2": 81}
        case 41: return { "0": 14, "1": 43, "2": 75}
        case 42: return { "0": 15, "1": 44, "2": 76}
        case 43: return { "0": 16, "q1": 45, "2": 76}
        case 44: return { "0": 17, "1": 46, "2": 77}
        case 45: return { "0": 18, "1": 46, "2": 77}
        case 46: return { "0": 16, "1": 48, "2": 79}
        case 47: return { "0": 13, "1": 43, "2": 74}
        case 48: return { "0": 13, "1": 43, "2": 74}
        case 49: return { "0": 14, "1": 44, "2": 75}
        case 50: return { "0": 13, "1": 47, "2": 78}
        case 52: return { "0": 13, "1": 47, "2": 78}
        case 53: return { "0": 13, "1": 47, "2": 78}
        case 54: return { "0": 13, "1": 48, "2": 78}
        case 55: return { "0": 12, "1": 44, "2": 78}
        case 56: return { "0": 12, "1": 44, "2": 79}
        case 57: return { "0": 13, "1": 45, "2": 81}
        case 58: return { "0": 14, "1": 47, "2": 82}
        case 59: return { "0": 12, "1": 44, "2": 79}
        case 60: return { "0": 13, "1": 45, "2": 82}
        case 61: return { "0": 14, "1": 47, "2": 83}
        case 62: return { "0": 17, "1": 45, "2": 84}
        case 63: return { "0": 17, "1": 45, "2": 84}
        case 64: return { "0": 17, "1": 46, "2": 85}
        case 65: return { "0": 17, "1": 46, "2": 85}
        case 66: return { "0": 17, "1": 49, "2": 80}
        case 67: return { "0": 17, "1": 49, "2": 80}
        case 68: return { "0": 17, "1": 49, "2": 80}
        case 69: return { "0": 17, "1": 49, "2": 80}
        case 70: return { "0": 17, "1": 49, "2": 80}
        case 71: return { "0": 17, "1": 49, "2": 80}
        case 72: return { "0": 17, "1": 49, "2": 80}
        case 73: return { "0": 17, "1": 49, "2": 80}
        case 74: return { "0": 14, "1": 48, "2": 79}
        case 76: return { "0": 21, "1": 49, "2": 79}
        case 77: return { "0": 21, "1": 50, "2": 80}
        case 78: return { "0": 22, "1": 50, "2": 80}
        case 79: return { "0": 22, "1": 52, "2": 80}
        case 80: return { "0": 22, "1": 52, "2": 81}
        case 81: return { "0": 23, "1": 52, "2": 81}
        case 82: return { "0": 24, "1": 53, "2": 81}
        case 83: return { "0": 24, "1": 54, "2": 82}
        case 84: return { "0": 21, "1": 50, "2": 79}
        case 85: return { "0": 21, "1": 50, "2": 79}
        case 86: return { "0": 21, "1": 51, "2": 80}
        case 87: return { "0": 21, "1": 51, "2": 81}
        case 88: return { "0": 22, "1": 51, "2": 81}
        case 89: return { "0": 22, "1": 51, "2": 82}
        case 90: return { "0": 21, "1": 51, "2": 82}
        case 91: return { "0": 22, "1": 51, "2": 83}
        case 92: return { "0": 23, "1": 52, "2": 84}
        case 93: return { "0": 24, "1": 53, "2": 85}
        case 94: return { "0": 23, "1": 53, "2": 84}
        case 95: return { "0": 23, "1": 53, "2": 84}
        case 96: return { "0": 23, "1": 53, "2": 84}
        case 97: return { "0": 24, "1": 54, "2": 85}
        case 98: return { "0": 24, "1": 54, "2": 85}
        case 99: return { "0": 24, "1": 54, "2": 85}
        case 100: return { "0": 25, "1": 55, "2": 83}
        case 101: return { "0": 25, "1": 55, "2": 83}
        case 102: return { "0": 25, "1": 55, "2": 83}
        case 104: return { "0": 26, "1": 56, "2": 82}
        case 105: return { "0": 26, "1": 56, "2": 83}
        case 106: return { "0": 27, "1": 57, "2": 84}
        case 107: return { "0": 27, "1": 57, "2": 85}
        case 108: return { "0": 28, "1": 58, "2": 85}
        case 110: return { "0": 24, "1": 58, "2": 80}
        case 111: return { "0": 25, "1": 59, "2": 81}
        case 112: return { "0": 26, "1": 60, "2": 81}
        case 113: return { "0": 29, "1": 61, "2": 82}
        case 114: return { "0": 29, "1": 61, "2": 83}
        case 115: return { "0": 29, "1": 61, "2": 83}
        case 116: return { "0": 29, "1": 61, "2": 84}
        case 117: return { "0": 27, "1": 60, "2": 81}
        case 118: return { "0": 29, "1": 62, "2": 82}
        case 119: return { "0": 29, "1": 62, "2": 83}
        case 120: return { "0": 37, "1": 68, "2": 87}
        case 121: return { "0": 32, "1": 63, "2": 83}
        case 122: return { "0": 33, "1": 63, "2": 83}
        case 123: return { "0": 34, "1": 64, "2": 84}
        case 124: return { "0": 36, "1": 64, "2": 84}
        case 125: return { "0": 39, "1": 60, "2": 81}
        case 126: return { "0": 39, "1": 61, "2": 82}
        case 127: return { "0": 39, "1": 62, "2": 83}
        case 128: return { "0": 39, "1": 65, "2": 85}
        case 129: return { "0": 40, "1": 65, "2": 85}
        case 130: return { "0": 42, "1": 66, "2": 85}
        case 131: return { "0": 43, "1": 66, "2": 85}
        case 132: return { "0": 43, "1": 66, "2": 85}
    }
}