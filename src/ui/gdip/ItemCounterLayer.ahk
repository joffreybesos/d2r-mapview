#NoEnv

class ItemCounterLayer {
    hbm :=
    hdc :=
    obm :=
    G :=
    ItemCounterLayerHwnd :=

    __new(ByRef settings) {
        SetFormat Integer, D
        gameClientArea := getWindowClientArea()
        gameWindowX := gameClientArea["X"]
        gameWindowY := gameClientArea["Y"]
        gameWindowWidth := gameClientArea["W"]
        gameWindowHeight := gameClientArea["H"]

        Gui, ItemCounter: -Caption +E0x20 +E0x80000 +E0x00080000 +LastFound +AlwaysOnTop +ToolWindow +OwnDialogs 
        this.ItemCounterLayerHwnd := WinExist()
        this.imageSize := settings["itemCounterSize"]
        this.textBoxWidth := this.imageSize
        this.textBoxHeight := this.imageSize * 3 ; 3 images high

        this.leftMargin := gameWindowX + gameWindowWidth - this.textBoxWidth - 5
        this.topMargin := gameWindowY + (gameWindowHeight / 2) - (this.textBoxHeight / 2)
        this.itemCounterFontSize := this.imageSize / 3 ; settings["ItemCounterFontSize"]
        this.xoffset := 0
        this.yoffset := 0

        pToken := Gdip_Startup()
        DetectHiddenWindows, On
        this.hbm := CreateDIBSection(this.textBoxWidth, this.textBoxHeight)
        this.hdc := CreateCompatibleDC()
        this.obm := SelectObject(this.hdc, this.hbm)
        this.G := Gdip_GraphicsFromHDC(this.hdc)
        Gdip_SetSmoothingMode(this.G, 4)
        Gdip_SetInterpolationMode(this.G, 7)
        Gui, ItemCounter: Show, NA
    }

    drawItemCounter(ByRef HUDItems) {
        if (!settings["itemCounterEnabled"]) {
            this.hide()
            return
        }
        if (readUI(d2rprocess)) {
            this.hide()
            return
        }
        if (WinActive(gameWindowId)) {
            this.show()
        } else {
            this.hide()
            return
        }
        
        fontSize := this.itemCounterFontSize

        ; pPen := Gdip_CreatePen(0xff00FF00, 2)
        ; Gdip_DrawRectangle(this.G, pPen, 0, 0, this.textBoxWidth, this.textBoxHeight)
        Gdip_DrawImage(this.G, hudBitmaps["pBitmapTP"], this.xoffset + this.textBoxWidth - this.imageSize, 0, this.imageSize, this.imageSize,,,,,0.7)
        Gdip_DrawImage(this.G, hudBitmaps["pBitmapID"], this.xoffset + this.textBoxWidth - this.imageSize, this.imageSize, this.imageSize, this.imageSize,,,,,0.7)
        Gdip_DrawImage(this.G, hudBitmaps["pBitmapKey"], this.xoffset + this.textBoxWidth - this.imageSize, this.imageSize * 2,this.imageSize, this.imageSize,,,,,0.7)
        tpcolor := this.getColor(HUDItems.tpscrolls)
        idcolor := this.getColor(HUDItems.idscrolls)
        keycolor := this.getColor(HUDItems.keys)
        this.drawData(this.xoffset + this.textBoxWidth - this.imageSize, this.yoffset + (this.imageSize * 1) - fontSize- 3, fontSize, tpcolor, HUDItems.tpscrolls)
        this.drawData(this.xoffset + this.textBoxWidth - this.imageSize, this.yoffset + (this.imageSize * 2) - fontSize- 3, fontSize, idcolor, HUDItems.idscrolls)
        this.drawData(this.xoffset + this.textBoxWidth - this.imageSize, this.yoffset + (this.imageSize * 3) - fontSize- 3, fontSize, keycolor, HUDItems.keys)

        UpdateLayeredWindow(this.ItemCounterLayerHwnd, this.hdc, this.leftMargin, this.topMargin, this.textBoxWidth, this.textBoxHeight)
        Gdip_GraphicsClear( this.G )
    }

    drawData(textx, texty, fontSize, alertColor, itemText) {
        Options = x%textx% y%texty% Left vBottom NoWrap c%alertColor% r4 s%fontSize%
        textx := textx + 1
        texty := texty + 1
        Options2 = x%textx% y%texty% Left vBottom NoWrap cdd000000 r4 s%fontSize%
        Gdip_TextToGraphics(this.G, itemText, Options2, exocetFont)
        Gdip_TextToGraphics(this.G, itemText, Options, exocetFont) 
    }

    getColor(amount) {
        acolor := "ddFFD700" ; gold
        if (amount == 0) {
            acolor := "ddff0000" ; red
        } else if (amount < 5) {
            acolor := "ddFFA500" ; orange
        }
        return acolor
    }

    show() {
        this.visible := true
        Gui, ItemCounter: Show, NA
    }

    hide() {
        this.visible := false
        Gui, ItemCounter: Hide
    }

    delete() {
        SelectObject(this.hdc, this.obm)
        DeleteObject(this.hbm)
        DeleteDC(this.hdc)
        Gui, ItemCounter: Destroy
    }
}
