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
        this.itemCounterFontSize := this.imageSize / 2 ; settings["ItemCounterFontSize"]
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
            Gui, ItemCounter: Hide
            return
        }
        if (WinActive(gameWindowId)) {
            Gui, ItemCounter: Show, NA
        } else {
            Gui, ItemCounter: Hide
            return
        }
        if (readUI(d2rprocess)) {
            Gui, ItemCounter: Hide
            return
        }
        fontSize := this.itemCounterFontSize

        ; pPen := Gdip_CreatePen(0xff00FF00, 2)
        ; Gdip_DrawRectangle(this.G, pPen, 0, 0, this.textBoxWidth, this.textBoxHeight)
        Gdip_DrawImage(this.G, hudBitmaps["pBitmapTP"], this.xoffset + this.textBoxWidth - this.imageSize, 0, this.imageSize, this.imageSize,,,,,0.7)
        Gdip_DrawImage(this.G, hudBitmaps["pBitmapID"], this.xoffset + this.textBoxWidth - this.imageSize, this.imageSize, this.imageSize, this.imageSize,,,,,0.7)
        Gdip_DrawImage(this.G, hudBitmaps["pBitmapKey"], this.xoffset + this.textBoxWidth - this.imageSize, this.imageSize * 2,this.imageSize, this.imageSize,,,,,0.7)
        tpcolor := "ddFFD700"
        idcolor := "ddFFD700"
        keycolor := "ddFFD700"
        if (HUDItems.tpscrolls == 0) {
            tpcolor := "ddff0000"
        }
        if (HUDItems.idscrolls == 0) {
            idcolor := "ddff0000"
        }

        if (HUDItems.keys == 0) {
            keycolor := "ddff0000"
        }
        this.drawData(this.xoffset + this.textBoxWidth - fontSize, this.yoffset + (fontSize / 2), fontSize, tpcolor, HUDItems.tpscrolls)
        this.drawData(this.xoffset + this.textBoxWidth - fontSize, this.yoffset + this.imageSize + (fontSize / 2), fontSize, idcolor, HUDItems.idscrolls)
        this.drawData(this.xoffset + this.textBoxWidth - fontSize, this.yoffset + this.imageSize + this.imageSize + (fontSize / 2), fontSize, keycolor, HUDItems.keys)

        UpdateLayeredWindow(this.ItemCounterLayerHwnd, this.hdc, this.leftMargin, this.topMargin, this.textBoxWidth, this.textBoxHeight)
        Gdip_GraphicsClear( this.G )
    }

    drawData(textx, texty, fontSize, alertColor, itemText) {
        Options = x%textx% y%texty% Center vCenter NoWrap c%alertColor% r4 s%fontSize%
        textx := textx + 1
        texty := texty + 1
        Options2 = x%textx% y%texty% Center vCenter NoWrap cdd000000 r4 s%fontSize%
        Gdip_TextToGraphics(this.G, itemText, Options2, exocetFont)
        Gdip_TextToGraphics(this.G, itemText, Options, exocetFont) 
    }

    hide() {
        Gui, ItemCounter: Hide
    }

    delete() {
        SelectObject(this.hdc, this.obm)
        DeleteObject(this.hbm)
        DeleteDC(this.hdc)
        Gui, ItemCounter: Destroy
    }
}
