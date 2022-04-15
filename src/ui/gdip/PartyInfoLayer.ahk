#NoEnv

class PartyInfoLayer {
    hbm :=
    hdc :=
    obm :=
    G :=
    PartyInfoLayerHwnd :=

    __new(ByRef settings) {
        this.topPadding := 0
        this.leftPadding := 0 
        gameClientArea := getWindowClientArea()
        gameWindowX := gameClientArea["X"]
        gameWindowY := gameClientArea["Y"]
        gameWindowWidth := gameClientArea["W"]
        gameWindowHeight := gameClientArea["H"]

        Gui, PartyInfo: -Caption +E0x20 +E0x80000 +E0x00080000 +LastFound +AlwaysOnTop +ToolWindow +OwnDialogs 
        this.PartyInfoLayerHwnd := WinExist()
        
        if ((gameWindowWidth / gameWindowHeight) > 2) { ;if ultrawide
            this.leftMargin := this.leftPadding + ((gameWindowWidth/2) - (1.034 * gameWindowHeight)) + gameWindowX - 3
            this.topMargin := this.topPadding + (gameWindowHeight / 53) + gameWindowY
            this.spacing := gameWindowHeight / 10.59
        } else {
            this.leftMargin := this.leftPadding + ((gameWindowHeight / 46)) + gameWindowX - 2
            this.topMargin := this.topPadding + (gameWindowHeight / 51.5) + gameWindowY
            this.spacing := gameWindowHeight / 10.6
        }
        this.partyInfoFontSize := this.spacing / 11
        
        this.textBoxWidth := 200
        this.textBoxHeight := gameWindowHeight
        this.xoffset := 0
        this.yoffset := this.spacing * 0.85 ; + gameWindowY

        pToken := Gdip_Startup()
        DetectHiddenWindows, On
        this.hbm := CreateDIBSection(this.textBoxWidth, this.textBoxHeight)
        this.hdc := CreateCompatibleDC()
        this.obm := SelectObject(this.hdc, this.hbm)
        this.G := Gdip_GraphicsFromHDC(this.hdc)
        Gdip_SetSmoothingMode(this.G, 4)
        Gdip_SetInterpolationMode(this.G, 7)
        Gui, PartyInfo: Show, NA
    }

    drawInfoText(partyList, playerUnitId) {
        if (WinActive(gameWindowId)) {
            Gui, PartyInfo: Show, NA
        } else {
            Gui, PartyInfo: Hide
        }
        if (readUI(d2rprocess)) {
            Gui, PartyInfo: Hide
        }
        fontSize := this.partyInfoFontSize

        ; get the current players part id
        for k,v in partyList
        {
            if (playerUnitId == v.unitId) {
                playerPartyId := v.partyId
                break
            }
        }
        ; draw each party member location
        for k,v in partyList
        {
            if (k > 1) { ; don't draw your own
                if (v.partyId == playerPartyId) { ; only if in same party
                    levelName := getAreaName(v.area)
					if (levelName) {
						playerText := v.plevel " - " levelName
					} else {
						playerText := v.plevel
					}
                    this.drawData(this.xoffset, this.yoffset + (this.spacing * (k-1)), fontSize, playerText)
                }
            }
        }
        
        UpdateLayeredWindow(this.PartyInfoLayerHwnd, this.hdc, this.leftMargin, this.topMargin, this.textBoxWidth, this.textBoxHeight)
        Gdip_GraphicsClear( this.G )
    }

    drawData(textx, texty, fontSize, textList) {
        Options = x%textx% y%texty%  w200 h100 Left vTop cffc6b276 r4 s%fontSize%
        textx := textx + 1
        texty := texty + 1
        Options2 = x%textx% y%texty% w200 h100 Left vTop cdd000000 r4 s%fontSize%
        Gdip_TextToGraphics(this.G, textList, Options2, formalFont)
        Gdip_TextToGraphics(this.G, textList, Options, formalFont)
    }

    hide() {
        Gui, PartyInfo: Hide
    }

    delete() {
        SelectObject(this.hdc, this.obm)
        DeleteObject(this.hbm)
        DeleteDC(this.hdc)
        Gui, PartyInfo: Destroy
    }

}



getAreaName(areaNum) {
    switch (areaNum) {
        case 1: return localizedStrings["Rogue Encampment"]
		case 2: return localizedStrings["Blood Moor"]
		case 3: return localizedStrings["Cold Plains"]
		case 4: return localizedStrings["Stony Field"]
		case 5: return localizedStrings["Dark Wood"]
		case 6: return localizedStrings["Black Marsh"]
		case 7: return localizedStrings["Tamoe Highland"]
		case 8: return localizedStrings["Den of Evil"]
		case 9: return localizedStrings["Cave Level 1"]
		case 10: return localizedStrings["Underground Passage Level 1"]
		case 11: return localizedStrings["Hole Level 1"]
		case 12: return localizedStrings["Pit Level 1"]
		case 13: return localizedStrings["Cave Level 2"]
		case 14: return localizedStrings["Underground Passage Level 2"]
		case 15: return localizedStrings["Hole Level 2"]
		case 16: return localizedStrings["Pit Level 2"]
		case 17: return localizedStrings["Burial Grounds"]
		case 18: return localizedStrings["Crypt"]
		case 19: return localizedStrings["Mausoleum"]
		case 20: return localizedStrings["Forgotten Tower"]
		case 21: return localizedStrings["Tower Cellar Level 1"]
		case 22: return localizedStrings["Tower Cellar Level 2"]
		case 23: return localizedStrings["Tower Cellar Level 3"]
		case 24: return localizedStrings["Tower Cellar Level 4"]
		case 25: return localizedStrings["Tower Cellar Level 5"]
		case 26: return localizedStrings["Monastery Gate"]
		case 27: return localizedStrings["Outer Cloister"]
		case 28: return localizedStrings["Barracks"]
		case 29: return localizedStrings["Jail Level 1"]
		case 30: return localizedStrings["Jail Level 2"]
		case 31: return localizedStrings["Jail Level 3"]
		case 32: return localizedStrings["Inner Cloister"]
		case 33: return localizedStrings["Cathedral"]
		case 34: return localizedStrings["Catacombs Level 1"]
		case 35: return localizedStrings["Catacombs Level 2"]
		case 36: return localizedStrings["Catacombs Level 3"]
		case 37: return localizedStrings["Catacombs Level 4"]
		case 38: return localizedStrings["Tristram"]
		case 39: return localizedStrings["Moo Moo Farm"]
		case 40: return localizedStrings["Lut Gholein"]
		case 41: return localizedStrings["Rocky Waste"]
		case 42: return localizedStrings["Dry Hills"]
		case 43: return localizedStrings["Far Oasis"]
		case 44: return localizedStrings["Lost City"]
		case 45: return localizedStrings["Valley of Snakes"]
		case 46: return localizedStrings["Canyon of the Magi"]
		case 47: return localizedStrings["Sewers Level 1"]
		case 48: return localizedStrings["Sewers Level 2"]
		case 49: return localizedStrings["Sewers Level 3"]
		case 50: return localizedStrings["Harem Level 1"]
		case 51: return localizedStrings["Harem Level 2"]
		case 52: return localizedStrings["Palace Cellar Level 1"]
		case 53: return localizedStrings["Palace Cellar Level 2"]
		case 54: return localizedStrings["Palace Cellar Level 3"]
		case 55: return localizedStrings["Stony Tomb Level 1"]
		case 56: return localizedStrings["Halls of the Dead Level 1"]
		case 57: return localizedStrings["Halls of the Dead Level 2"]
		case 58: return localizedStrings["Claw Viper Temple Level 1"]
		case 59: return localizedStrings["Stony Tomb Level 2"]
		case 60: return localizedStrings["Halls of the Dead Level 3"]
		case 61: return localizedStrings["Claw Viper Temple Level 2"]
		case 62: return localizedStrings["Maggot Lair Level 1"]
		case 63: return localizedStrings["Maggot Lair Level 2"]
		case 64: return localizedStrings["Maggot Lair Level 3"]
		case 65: return localizedStrings["Ancient Tunnels"]
		case 66: return localizedStrings["Tal Rasha's Tomb #1"]
		case 67: return localizedStrings["Tal Rasha's Tomb #2"]
		case 68: return localizedStrings["Tal Rasha's Tomb #3"]
		case 69: return localizedStrings["Tal Rasha's Tomb #4"]
		case 70: return localizedStrings["Tal Rasha's Tomb #5"]
		case 71: return localizedStrings["Tal Rasha's Tomb #6"]
		case 72: return localizedStrings["Tal Rasha's Tomb #7"]
		case 73: return localizedStrings["Duriel's Lair"]
		case 74: return localizedStrings["Arcane Sanctuary"]
		case 75: return localizedStrings["Kurast Docktown"]
		case 76: return localizedStrings["Spider Forest"]
		case 77: return localizedStrings["Great Marsh"]
		case 78: return localizedStrings["Flayer Jungle"]
		case 79: return localizedStrings["Lower Kurast"]
		case 80: return localizedStrings["Kurast Bazaar"]
		case 81: return localizedStrings["Upper Kurast"]
		case 82: return localizedStrings["Kurast Causeway"]
		case 83: return localizedStrings["Travincal"]
		case 84: return localizedStrings["Arachnid Lair"]
		case 85: return localizedStrings["Spider Cavern"]
		case 86: return localizedStrings["Swampy Pit Level 1"]
		case 87: return localizedStrings["Swampy Pit Level 2"]
		case 88: return localizedStrings["Flayer Dungeon Level 1"]
		case 89: return localizedStrings["Flayer Dungeon Level 2"]
		case 90: return localizedStrings["Swampy Pit Level 3"]
		case 91: return localizedStrings["Flayer Dungeon Level 3"]
		case 92: return localizedStrings["Sewers Level 1"]
		case 93: return localizedStrings["Sewers Level 2"]
		case 94: return localizedStrings["Ruined Temple"]
		case 95: return localizedStrings["Disused Fane"]
		case 96: return localizedStrings["Forgotten Reliquary"]
		case 97: return localizedStrings["Forgotten Temple"]
		case 98: return localizedStrings["Ruined Fane"]
		case 99: return localizedStrings["Disused Reliquary"]
		case 100: return localizedStrings["Durance of Hate Level 1"]
		case 101: return localizedStrings["Durance of Hate Level 2"]
		case 102: return localizedStrings["Durance of Hate Level 3"]
		case 103: return localizedStrings["Pandemonium Fortress"]
		case 104: return localizedStrings["Outer Steppes"]
		case 105: return localizedStrings["Plains of Despair"]
		case 106: return localizedStrings["City of the Damned"]
		case 107: return localizedStrings["River of Flame"]
		case 108: return localizedStrings["Chaos Sanctuary"]
		case 109: return localizedStrings["Harrogath"]
		case 110: return localizedStrings["Bloody Foothills"]
		case 111: return localizedStrings["Frigid Highlands"]
		case 112: return localizedStrings["Arreat Plateau"]
		case 113: return localizedStrings["Crystalline Passage"]
		case 114: return localizedStrings["Frozen River"]
		case 115: return localizedStrings["Glacial Trail"]
		case 116: return localizedStrings["Drifter Cavern"]
		case 117: return localizedStrings["Frozen Tundra"]
		case 118: return localizedStrings["Ancients' Way"]
		case 119: return localizedStrings["Icy Cellar"]
		case 120: return localizedStrings["Arreat Summit"]
		case 121: return localizedStrings["Nihlathaks Temple"]
		case 122: return localizedStrings["Halls of Anguish"]
		case 123: return localizedStrings["Halls of Death's Calling"]
		case 124: return localizedStrings["Halls of Vaught"]
		case 125: return localizedStrings["Abaddon"]
		case 126: return localizedStrings["Pit of Acheron"]
		case 127: return localizedStrings["Infernal Pit"]
		case 128: return localizedStrings["Worldstone Keep Level 1"]
		case 129: return localizedStrings["Worldstone Keep Level 2"]
		case 130: return localizedStrings["Worldstone Keep Level 3"]
		case 131: return localizedStrings["Throne of Destruction"]
		case 132: return localizedStrings["Worldstone Chamber"]
		case 133: return localizedStrings["Pandemonium Run 1"]
		case 134: return localizedStrings["Pandemonium Run 2"]
		case 135: return localizedStrings["Pandemonium Run 3"]
		case 136: return localizedStrings["Tristram"]
    }
}