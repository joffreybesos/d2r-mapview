class MapLayer {
    hbm :=
    hdc :=
    obm :=
    G :=
    MapHwnd :=

    __new(ByRef area) {
        
        gameClientArea := getWindowClientArea()
        gameWindowX := gameClientArea["X"]
        gameWindowY := gameClientArea["Y"]
        gameWindowWidth := gameClientArea["W"]
        gameWindowHeight := gameClientArea["H"]

        Gui, Map: -Caption +E0x20 +E0x80000 +LastFound +AlwaysOnTop +ToolWindow +OwnDialogs
        this.MapHwnd := WinExist()
        Gui, Map: Show, NA
        pToken := Gdip_Startup()
        DetectHiddenWindows, On
        pBitmap := area.bitmap
        bitmapWidth := Gdip_GetImageWidth(pBitmap)
        bitmapHeight := Gdip_GetImageHeight(pBitmap)
        Gdip_GetRotatedDimensions(bitmapWidth, bitmapHeight, 45, rotatedWidth, rotatedHeight)
        pBitmap := Gdip_RotateBitmapAtCenter(pBitmap, 45) ; rotates bitmap for 45 degrees. Disposes of pBitmap.
        this.hbm := CreateDIBSection(rotatedWidth, rotatedHeight)
        this.hdc := CreateCompatibleDC()
        this.obm := SelectObject(this.hdc, this.hbm)
        this.G := Gdip_GraphicsFromHDC(this.hdc)
        ;Gdip_SaveBitmapToFile(pBitmap, "asdfasdf.bmp")
        Gdip_DrawImage(this.G, pBitmap, 0, 0, rotatedWidth, rotatedHeight/2, 0, 0, rotatedWidth, rotatedHeight, 0.7)
        UpdateLayeredWindow(this.MapHwnd, this.hdc, 0, 0, rotatedWidth, rotatedHeight)
        
    }

    drawInfoText(partyList, playerUnitId) {
        if (WinActive(gameWindowId)) {
            Gui, Map: Show, NA
        } else {
            Gui, Map: Hide
        }
        ; if (readUI(d2rprocess)) {
        ;     Gui, Map: Hide
        ; }
        fontSize := this.MapFontSize
        UpdateLayeredWindow(this.MapHwnd, this.hdc, this.leftMargin, this.topMargin, this.textBoxWidth, this.textBoxHeight)
        Gdip_GraphicsClear( this.G )
    }


    hide() {
        Gui, Map: Hide
    }

    delete() {
        SelectObject(this.hdc, this.obm)
        DeleteObject(this.hbm)
        DeleteDC(this.hdc)
        Gui, Map: Destroy
    }

}


