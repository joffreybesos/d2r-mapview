#NoEnv

class PartyInfoLayer {
    hbm :=
    hdc :=
    obm :=
    G :=
    PartyInfoLayerHwnd :=

    __new(ByRef settings) {
        ;this.partyInfoFontSize := settings["PartyInfoFontSize"]
        this.partyInfoFontSize := 14
        this.topPadding := 0
        if (!isWindowFullScreen(gameWindowId)) {
            this.topPadding :=  this.topPadding + 31
        }
        Gui, PartyInfo: -Caption +E0x20 +E0x80000 +E0x00080000 +LastFound +AlwaysOnTop +ToolWindow +OwnDialogs 
        this.PartyInfoLayerHwnd := WinExist()
        WinGetPos, gameWindowX, gameWindowY, gameWindowWidth, gameWindowHeight, %gameWindowId% 
        if ((gameWindowWidth / gameWindowHeight) > 2) {
            ; ultrawide
            this.leftMargin := (gameWindowWidth/2) - (1.034 * gameWindowHeight) - 3
            this.topMargin := this.topPadding + (gameWindowHeight / 53)
            this.spacing := gameWindowHeight / 10.6
        } else {
            this.leftMargin := (gameWindowHeight / 46) - 3
            this.topMargin := this.topPadding + (gameWindowHeight / 51.5)
            this.spacing := gameWindowHeight / 10.6
        }
        
        this.textBoxWidth := 300
        this.textBoxHeight := 900

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

    drawInfoText() {
        if (WinActive(gameWindowId)) {
            Gui, PartyInfo: Show, NA
        } else {
            Gui, PartyInfo: Hide
        }
        fontSize := this.partyInfoFontSize
        textList := "Underground Passage Level 2"
        
        
        this.drawData(0, this.topPadding, fontSize, textList)
        this.drawData(0, this.topPadding + this.spacing, fontSize, textList)
        this.drawData(0, this.topPadding + (this.spacing * 2), fontSize, textList)
        this.drawData(0, this.topPadding + (this.spacing * 3), fontSize, textList)
        this.drawData(0, this.topPadding + (this.spacing * 4), fontSize, textList)
        this.drawData(0, this.topPadding + (this.spacing * 5), fontSize, textList)
        UpdateLayeredWindow(this.PartyInfoLayerHwnd, this.hdc, this.leftMargin, this.topMargin, this.textBoxWidth, this.textBoxHeight)
        
        Gdip_GraphicsClear( this.G )
    }

    drawData(textx, texty, fontSize, textList) {
        Options = x%textx% y%texty% Left vTop cff00dd00 r4 s%fontSize%
        textx := textx + 1
        texty := texty + 1
        Options2 = x%textx% y%texty% Left vTop cff000000 r4 s%fontSize%
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
