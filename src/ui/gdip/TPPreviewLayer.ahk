#NoEnv

class TPPreviewLayer {
    hbm :=
    hdc :=
    obm :=
    G :=
    TPPreviewLayerHwnd :=

    __new(ByRef settings) {
        Gui, TPPreview: -Caption +E0x20 +E0x80000 +E0x00080000 +LastFound +AlwaysOnTop +ToolWindow +OwnDialogs 

        this.TPPreviewLayerHwnd := WinExist()
        gameClientArea := getWindowClientArea()
        this.gameWindowX := gameClientArea["X"]
        this.gameWindowY := gameClientArea["Y"]
        this.gameWindowWidth := gameClientArea["W"]
        this.gameWindowHeight := gameClientArea["H"]

        this.getMousePos()
        
        this.mapBoxWidth := ( this.gameWindowHeight / 3)
        this.mapBoxHeight := ( this.gameWindowHeight / 4)
        
        pToken := Gdip_Startup()
        DetectHiddenWindows, On
        this.hbm := CreateDIBSection(this.mapBoxWidth, this.mapBoxHeight)
        this.hdc := CreateCompatibleDC()
        this.obm := SelectObject(this.hdc, this.hbm)
        this.G := Gdip_GraphicsFromHDC(this.hdc)
        Gdip_SetSmoothingMode(this.G, 4)
        Gdip_SetInterpolationMode(this.G, 7)
        this.createPens(settings)
        
        Gui, TPPreview: Show, NA
    }

    getMousePos() {
        MouseGetPos , mouseX, mouseY
        this.mouseX := mouseX
        this.mouseY := mouseY
    }

    drawMapPreview(ByRef partyList, ByRef mapSeed, ByRef difficulty, ByRef destMap, ByRef destX, ByRef destY) {
        Gui, TPPreview: Show, NA
        
        if (!this.mapPreviewImages[destMap]) {
            this.mapPreviewImages[destMap] := new MapImage(settings, mapSeed, difficulty, destMap)
        }
        ;if (portal.isHovered) {
        this.getMousePos()
        Gdip_FillRectangle(this.G, this.brushBG, 0, 0, this.mapBoxWidth, this.mapBoxHeight)
        ;Gdip_DrawRectangle(this.G, this.pPenPlayer, 50, 50, 10, 10)
        UpdateLayeredWindow(this.TPPreviewLayerHwnd, this.hdc, this.mouseX - this.mapBoxWidth - 40, this.mouseY - this.mapBoxHeight - 40, this.mapBoxWidth, this.mapBoxHeight)
        Gdip_GraphicsClear( this.G )
        ;}
    }


    createPens(ByRef settings) {
        this.pPenPlayer := Gdip_CreatePen(0xff2087fd, 1 * scale)
        this.pPenOtherPlayer := Gdip_CreatePen(0xff00ff00, 0.8 * scale)

        this.pBrushPlayer := Gdip_BrushCreateSolid(0xff2087fd)
        this.pBrushOtherPlayer := Gdip_BrushCreateSolid(0xff00FF00)

        this.brushBG := Gdip_BrushCreateSolid(0xdd222222)

        this.pPortal := Gdip_CreatePen("0xff" . settings["portalColor"], 1.3 * scale)
        this.pRedPortal := Gdip_CreatePen("0xff" . settings["redPortalColor"], 1.3 * scale)

    }

    hide() {
        Gui, TPPreview: Hide
    }

    delete() {
        SelectObject(this.hdc, this.obm)
        DeleteObject(this.hbm)
        DeleteDC(this.hdc)
        Gdip_DeleteGraphics(this.G)
        , Gdip_DeletePen(this.pPenPhysical)
        , Gdip_DeletePen(this.pPenMagic)
        , Gdip_DeletePen(this.pPenFire)
        , Gdip_DeletePen(this.pPenLight)
        , Gdip_DeletePen(this.pPenCold)
        , Gdip_DeletePen(this.pPenPoison)
        Gui, TPPreview: Destroy
    }
}