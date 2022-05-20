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

        gameClientArea := getWindowClientArea()
        gameWindowX := gameClientArea["X"]
        gameWindowY := gameClientArea["Y"]
        gameWindowWidth := gameClientArea["W"]
        gameWindowHeight := gameClientArea["H"]

        this.topPadding := 10

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
        
        this.gameWindowX := gameWindowX
        this.gameWindowY := gameWindowY
        this.gameWindowWidth := gameWindowWidth
        this.gameWindowHeight := gameWindowHeight
        this.textBoxWidth := 250
        this.textBoxHeight := height

        this.topMargin := gameWindowY
        if ((gameWindowWidth / gameWindowHeight) > 2) { ;if ultrawide
            this.leftMargin := gameWindowX
            if (this.gameInfoAlignment == "RIGHT") {
                this.leftMargin :=  (this.gameWindowWidth - this.textBoxWidth) + this.gameWindowX - 5
            }
        } else {
            this.leftMargin := gameWindowX + (gameWindowHeight / 10)
            if (this.gameInfoAlignment == "RIGHT") {
                this.leftMargin :=  (this.gameWindowWidth - this.textBoxWidth) + this.gameWindowX - 5
                this.topMargin := this.topMargin + (this.gameWindowHeight / 10)
            }
        }

        
        

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

    updateSessionStart(startTime) {
        this.startTime := startTime
        this.hideStartupText := false
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
            textList := "D2R-Mapview " version "`n"
            ; only show this text for the first 10 seconds from startup
            if (!this.hideStartupText) {
                if (A_TickCount - this.startTime < 10000) {
                    textList := textList "Ctrl+O for options`n"
                    textList := textList "Ctrl+H for help`n"
                } else {
                    this.hideStartupText := true
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
            
            UpdateLayeredWindow(this.GameInfoLayerHwnd, this.hdc, this.leftMargin, this.topMargin, this.textBoxWidth, this.textBoxHeight)
        }
        Gdip_GraphicsClear( this.G )
    }


    drawData(textx, texty, fontSize, textList) {
        if (this.gameInfoAlignment == "RIGHT") {
            Options = x%textx% y%texty% Left vTop cffc6b276 r4 s%fontSize%
            textx := textx + 1
            texty := texty + 1
            Options2 = x%textx% y%texty% Left vTop cff000000 r4 s%fontSize%
        } else {
            Options = x%textx% y%texty% Left vTop cffc6b276 r4 s%fontSize%
            textx := textx + 1
            texty := texty + 1
            Options2 = x%textx% y%texty% Left vTop cff000000 r4 s%fontSize%
        }
        
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
        case 2: return { "0": 1, "1": 36, "2": 67}     ; Blood Moor
        case 3: return { "0": 2, "1": 36, "2": 68}     ; Cold Plains
        case 4: return { "0": 4, "1": 37, "2": 68}     ; Stony Field
        case 5: return { "0": 5, "1": 38, "2": 68}     ; Dark Wood
        case 6: return { "0": 6, "1": 38, "2": 69}     ; Black Marsh
        case 7: return { "0": 8, "1": 39, "2": 69}     ; Tamoe Highland
        case 8: return { "0": 1, "1": 36, "2": 79}     ; Den of Evil
        case 9: return { "0": 2, "1": 36, "2": 77}     ; Cave Level 1
        case 10: return { "0": 4, "1": 37, "2": 69}     ; Underground Passage Level 1
        case 11: return { "0": 5, "1": 38, "2": 80}     ; Hole Level 1
        case 12: return { "0": 7, "1": 39, "2": 85}     ; Pit Level 1
        case 13: return { "0": 2, "1": 37, "2": 78}     ; Cave Level 2
        case 14: return { "0": 4, "1": 38, "2": 85}     ; Underground Passage Level 2
        case 15: return { "0": 5, "1": 39, "2": 81}     ; Hole Level 2
        case 16: return { "0": 7, "1": 40, "2": 85}     ; Pit Level 2
        case 17: return { "0": 3, "1": 36, "2": 80}     ; Burial Grounds
        case 18: return { "0": 3, "1": 37, "2": 83}     ; Crypt
        case 19: return { "0": 3, "1": 37, "2": 85}     ; Mausoleum
        ; Forgotten Tower
        case 21: return { "0": 7, "1": 38, "2": 75}     ; Tower Cellar Level 1
        case 22: return { "0": 7, "1": 39, "2": 76}     ; Tower Cellar Level 2
        case 23: return { "0": 7, "1": 40, "2": 77}     ; Tower Cellar Level 3
        case 24: return { "0": 7, "1": 41, "2": 78}     ; Tower Cellar Level 4
        case 25: return { "0": 7, "1": 42, "2": 79}     ; Tower Cellar Level 5
        case 26: return { "0": 8, "1": 40, "2": 70}     ; Monastery Gate
        case 27: return { "0": 9, "1": 40, "2": 70}     ; Outer Cloister
        case 28: return { "0": 9, "1": 40, "2": 70}     ; Barracks
        case 29: return { "0": 10, "1": 41, "2": 71}     ; Jail Level 1
        case 30: return { "0": 10, "1": 41, "2": 71}     ; Jail Level 2
        case 31: return { "0": 10, "1": 41, "2": 71}     ; Jail Level 3
        case 32: return { "0": 10, "1": 41, "2": 72}     ; Inner Cloister
        case 33: return { "0": 11, "1": 42, "2": 72}     ; Cathedral
        case 34: return { "0": 11, "1": 42, "2": 72}     ; Catacombs Level 1
        case 35: return { "0": 11, "1": 42, "2": 73}     ; Catacombs Level 2
        case 36: return { "0": 12, "1": 43, "2": 73}     ; Catacombs Level 3
        case 37: return { "0": 12, "1": 43, "2": 73}     ; Catacombs Level 4
        case 38: return { "0": 6, "1": 39, "2": 76}      ; Tristram
        case 39: return { "0": 28, "1": 64, "2": 81}     ; Moo Moo Farm
        case 41: return { "0": 14, "1": 43, "2": 75}     ; Rocky Waste
        case 42: return { "0": 15, "1": 44, "2": 76}     ; Dry Hills
        case 43: return { "0": 16, "q1": 45, "2": 76}    ; Far Oasis
        case 44: return { "0": 17, "1": 46, "2": 77}     ; Lost City
        case 45: return { "0": 18, "1": 46, "2": 77}     ; Valley of Snakes
        case 46: return { "0": 16, "1": 48, "2": 79}     ; Canyon of the Magi
        case 47: return { "0": 13, "1": 43, "2": 74}     ; Sewers Level 1
        case 48: return { "0": 13, "1": 43, "2": 74}     ; Sewers Level 2
        case 49: return { "0": 14, "1": 44, "2": 75}     ; Sewers Level 3
        case 50: return { "0": 13, "1": 47, "2": 78}     ; Harem Level 1
        ; Harem Level 2
        case 52: return { "0": 13, "1": 47, "2": 78}     ; Palace Cellar Level 1
        case 53: return { "0": 13, "1": 47, "2": 78}     ; Palace Cellar Level 2
        case 54: return { "0": 13, "1": 48, "2": 78}     ; Palace Cellar Level 3
        case 55: return { "0": 12, "1": 44, "2": 85}     ; Stony Tomb Level 1
        case 56: return { "0": 12, "1": 44, "2": 79}     ; Halls of the Dead Level 1
        case 57: return { "0": 13, "1": 45, "2": 81}     ; Halls of the Dead Level 2
        case 58: return { "0": 14, "1": 47, "2": 82}     ; Claw Viper Temple Level 1
        case 59: return { "0": 12, "1": 44, "2": 85}     ; Stony Tomb Level 2
        case 60: return { "0": 13, "1": 45, "2": 82}     ; Halls of the Dead Level 3
        case 61: return { "0": 14, "1": 47, "2": 83}     ; Claw Viper Temple Level 2
        case 62: return { "0": 17, "1": 45, "2": 84}     ; Maggot Lair Level 1
        case 63: return { "0": 17, "1": 45, "2": 84}     ; Maggot Lair Level 2
        case 64: return { "0": 17, "1": 46, "2": 85}     ; Maggot Lair Level 3
        case 65: return { "0": 17, "1": 46, "2": 85}     ; Ancient Tunnels
        case 66: return { "0": 17, "1": 49, "2": 80}     ; Tal Rasha's Tomb #1
        case 67: return { "0": 17, "1": 49, "2": 80}     ; Tal Rasha's Tomb #2
        case 68: return { "0": 17, "1": 49, "2": 80}     ; Tal Rasha's Tomb #3
        case 69: return { "0": 17, "1": 49, "2": 80}     ; Tal Rasha's Tomb #4
        case 70: return { "0": 17, "1": 49, "2": 80}     ; Tal Rasha's Tomb #5
        case 71: return { "0": 17, "1": 49, "2": 80}     ; Tal Rasha's Tomb #6
        case 72: return { "0": 17, "1": 49, "2": 80}     ; Tal Rasha's Tomb #7
        case 73: return { "0": 17, "1": 49, "2": 80}     ; Duriel's Lair
        case 74: return { "0": 14, "1": 48, "2": 79}     ; Arcane Sanctuary
        ; Kurast Docktown
        case 76: return { "0": 21, "1": 49, "2": 79}     ; Spider Forest
        case 77: return { "0": 21, "1": 50, "2": 80}     ; Great Marsh
        case 78: return { "0": 22, "1": 50, "2": 80}     ; Flayer Jungle
        case 79: return { "0": 22, "1": 52, "2": 80}     ; Lower Kurast
        case 80: return { "0": 22, "1": 52, "2": 81}     ; Kurast Bazaar
        case 81: return { "0": 23, "1": 52, "2": 81}     ; Upper Kurast
        case 82: return { "0": 24, "1": 53, "2": 81}     ; Kurast Causeway
        case 83: return { "0": 24, "1": 54, "2": 82}     ; Travincal
        case 84: return { "0": 21, "1": 50, "2": 85}     ; Arachnid Lair
        case 85: return { "0": 21, "1": 50, "2": 79}     ; Spider Cavern
        case 86: return { "0": 21, "1": 51, "2": 85}     ; Swampy Pit Level 1
        case 87: return { "0": 21, "1": 51, "2": 85}     ; Swampy Pit Level 2
        case 88: return { "0": 22, "1": 51, "2": 81}     ; Flayer Dungeon Level 1
        case 89: return { "0": 22, "1": 51, "2": 82}     ; Flayer Dungeon Level 2
        case 90: return { "0": 21, "1": 51, "2": 85}     ; Swampy Pit Level 3
        case 91: return { "0": 22, "1": 51, "2": 83}     ; Flayer Dungeon Level 3
        case 92: return { "0": 23, "1": 52, "2": 85}     ; Sewers Level 1
        case 93: return { "0": 24, "1": 53, "2": 85}     ; Sewers Level 2
        case 94: return { "0": 23, "1": 53, "2": 85}     ; Ruined Temple
        case 95: return { "0": 23, "1": 53, "2": 85}     ; Disused Fane
        case 96: return { "0": 23, "1": 53, "2": 85}     ; Forgotten Reliquary
        case 97: return { "0": 24, "1": 54, "2": 85}     ; Forgotten Temple
        case 98: return { "0": 24, "1": 54, "2": 85}     ; Ruined Fane
        case 99: return { "0": 24, "1": 54, "2": 85}     ; Disused Reliquary
        case 100: return { "0": 25, "1": 55, "2": 83}     ; Durance of Hate Level 1
        case 101: return { "0": 25, "1": 55, "2": 83}     ; Durance of Hate Level 2
        case 102: return { "0": 25, "1": 55, "2": 83}     ; Durance of Hate Level 3
        ; Pandemonium Fortress
        case 104: return { "0": 26, "1": 56, "2": 82}     ; Outer Steppes
        case 105: return { "0": 26, "1": 56, "2": 83}     ; Plains of Despair
        case 106: return { "0": 27, "1": 57, "2": 84}     ; City of the Damned
        case 107: return { "0": 27, "1": 57, "2": 85}     ; River of Flame
        case 108: return { "0": 28, "1": 58, "2": 85}     ; Chaos Sanctuary
        ; Harrogath
        case 110: return { "0": 24, "1": 58, "2": 80}     ; Bloody Foothills
        case 111: return { "0": 25, "1": 59, "2": 81}     ; Frigid Highlands
        case 112: return { "0": 26, "1": 60, "2": 81}     ; Arreat Plateau
        case 113: return { "0": 29, "1": 61, "2": 82}     ; Crystalline Passage
        case 114: return { "0": 29, "1": 61, "2": 83}     ; Frozen River
        case 115: return { "0": 29, "1": 61, "2": 83}     ; Glacial Trail
        case 116: return { "0": 29, "1": 61, "2": 85}     ; Drifter Cavern
        case 117: return { "0": 27, "1": 60, "2": 81}     ; Frozen Tundra
        case 118: return { "0": 29, "1": 62, "2": 82}     ; Ancients' Way
        case 119: return { "0": 29, "1": 62, "2": 85}     ; Icy Cellar
        case 120: return { "0": 37, "1": 68, "2": 87}     ; Arreat Summit
        case 121: return { "0": 32, "1": 63, "2": 83}     ; Nihlathaks Temple
        case 122: return { "0": 33, "1": 63, "2": 83}     ; Halls of Anguish
        case 123: return { "0": 34, "1": 64, "2": 84}     ; Halls of Death's Calling
        case 124: return { "0": 36, "1": 64, "2": 84}     ; Halls of Vaught
        case 125: return { "0": 39, "1": 60, "2": 85}     ; Abaddon
        case 126: return { "0": 39, "1": 61, "2": 85}     ; Pit of Acheron
        case 127: return { "0": 39, "1": 62, "2": 85}     ; Infernal Pit
        case 128: return { "0": 39, "1": 65, "2": 85}     ; Worldstone Keep Level 1
        case 129: return { "0": 40, "1": 65, "2": 85}     ; Worldstone Keep Level 2
        case 130: return { "0": 42, "1": 66, "2": 85}     ; Worldstone Keep Level 3
        case 131: return { "0": 43, "1": 66, "2": 85}     ; Throne of Destruction
        case 132: return { "0": 43, "1": 66, "2": 85}     ; Worldstone Chamber
    }
}