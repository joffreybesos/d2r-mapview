#NoEnv

class UIAssistLayer {
    hbm :=
    hdc :=
    obm :=
    G :=
    UIAssistLayerHwnd :=

    __new(ByRef settings) {
        Gui, UIAssist: -Caption +E0x20 +E0x80000 +E0x00080000 +LastFound +AlwaysOnTop +ToolWindow +OwnDialogs 
        this.UIAssistLayerHwnd := WinExist()

        this.resistBoxWidth := 40
        this.resistBoxHeight := 30
        this.resistFontSize := 18
        this.maxWidth := this.resistBoxWidth * 6
        this.y := 0
        WinGetPos, , , gameWidth, gameHeight, %gameWindowId% 
        pToken := Gdip_Startup()
        DetectHiddenWindows, On
        this.hbm := CreateDIBSection(this.maxWidth, this.y + this.resistBoxHeight)
        this.hdc := CreateCompatibleDC()
        this.obm := SelectObject(this.hdc, this.hbm)
        this.G := Gdip_GraphicsFromHDC(this.hdc)
        Gdip_SetSmoothingMode(this.G, 4)
        Gdip_SetInterpolationMode(this.G, 7)
        this.createPens(settings)
        this.createBrushes(settings)
        
        Gui, UIAssist: Show, NA
    }

    drawMonsterBar(ByRef mob) {
        if (mob.txtFileNo) {
            SetFormat, integer, D
            WinGetPos, gamewindowx, gamewindowy, gameWidth, gameHeight, %gameWindowId% 
            resistFontSize := this.resistFontSize
            
            resists := mob.immunities
            ;resists := { "physical": 45, "magic": 10, "fire": 45, "light": 120, "cold": 45, "poison": 45 }
            ;OutputDebug, % mob.txtFileNo " " resists["fire"] " " resists["cold"] "`n"

            numResists := (resists["physical"] > 0) + (resists["magic"] > 0) + (resists["fire"] > 0) + (resists["light"] > 0) + (resists["cold"] > 0) + (resists["poison"] > 0)
            startx := (gameWidth / 2) - (this.maxWidth / 2)
            x := 0
            if (resists["physical"]) {
                Gdip_FillRectangle(this.G, this.pBrushPhysical, x, this.y, this.resistBoxWidth, this.resistBoxHeight)
                this.drawResistText(x, this.y, resistFontSize, resists["physical"])
            }
            x := x + this.resistBoxWidth
            if (resists["magic"]) {
                Gdip_FillRectangle(this.G, this.pBrushMagic, x, this.y, this.resistBoxWidth, this.resistBoxHeight)
                this.drawResistText(x, this.y, resistFontSize, resists["magic"])
            }
            x := x + this.resistBoxWidth
            if (resists["fire"]) {
                Gdip_FillRectangle(this.G, this.pBrushFire, x, this.y, this.resistBoxWidth, this.resistBoxHeight)
                this.drawResistText(x, this.y, resistFontSize, resists["fire"])
            }
            x := x + this.resistBoxWidth
            if (resists["light"]) {
            Gdip_FillRectangle(this.G, this.pBrushLight, x, this.y, this.resistBoxWidth, this.resistBoxHeight)
            this.drawResistText(x, this.y, resistFontSize, resists["light"])
            }
            x := x + this.resistBoxWidth
            if (resists["cold"]) {
            Gdip_FillRectangle(this.G, this.pBrushCold, x, this.y, this.resistBoxWidth, this.resistBoxHeight)
            this.drawResistText(x, this.y, resistFontSize, resists["cold"])
            }
            x := x + this.resistBoxWidth
            if (resists["poison"]) {
            Gdip_FillRectangle(this.G, this.pBrushPoison, x, this.y, this.resistBoxWidth, this.resistBoxHeight)
            this.drawResistText(x, this.y, resistFontSize, resists["poison"])
            }
            x := x + this.resistBoxWidth
            
        }
        UpdateLayeredWindow(this.UIAssistLayerHwnd, this.hdc, gamewindowx + startx, gamewindowy, this.maxWidth, this.y + this.resistBoxHeight)
        Gdip_GraphicsClear( this.G )
    }

    drawResistText(x, y, resistFontSize, resistVal) {
        textx := x - (this.resistBoxWidth / 2)
        texty := y + (resistFontSize / 8)
        if (resistVal >= 100) {
            Options = x%textx% y%texty% Center vCenter cffc6b276 r4 s%resistFontSize%
        } else {
            Options = x%textx% y%texty% Center vCenter cccffffff r4 s%resistFontSize%
        }
        textx := textx + 0.8
        texty := texty + 0.8
        Options2 = x%textx% y%texty% Center vCenter cff000000 r8 s%resistFontSize%
        Gdip_TextToGraphics(this.G, resistVal, Options2, diabloFont, this.resistBoxWidth*2, this.resistBoxHeight)
        Gdip_TextToGraphics(this.G, resistVal, Options,  diabloFont, this.resistBoxWidth*2, this.resistBoxHeight)
    }

    createPens(ByRef settings) {
        ; immunities
        physicalImmuneColor := 0xff . settings["physicalImmuneColor"] 
        , magicImmuneColor := 0xff . settings["magicImmuneColor"] 
        , fireImmuneColor := 0xff . settings["fireImmuneColor"] 
        , lightImmuneColor := 0xff . settings["lightImmuneColor"] 
        , coldImmuneColor := 0xff . settings["coldImmuneColor"] 
        , poisonImmuneColor := 0xff . settings["poisonImmuneColor"] 
        , this.pPenPhysical := Gdip_CreatePen(physicalImmuneColor, 1)
        , this.pPenMagic := Gdip_CreatePen(magicImmuneColor, 1)
        , this.pPenFire := Gdip_CreatePen(fireImmuneColor, 1)
        , this.pPenLight := Gdip_CreatePen(lightImmuneColor, 1)
        , this.pPenCold := Gdip_CreatePen(coldImmuneColor, 1)
        , this.pPenPoison := Gdip_CreatePen(poisonImmuneColor, 1)

    }

    createBrushes(ByRef settings) {
        ; immunities
        physicalImmuneColor := 0x55 . settings["physicalImmuneColor"] 
        , magicImmuneColor := 0x55 . settings["magicImmuneColor"] 
        , fireImmuneColor := 0x55 . settings["fireImmuneColor"] 
        , lightImmuneColor := 0x55 . settings["lightImmuneColor"] 
        , coldImmuneColor := 0x55 . settings["coldImmuneColor"] 
        , poisonImmuneColor := 0x55 . settings["poisonImmuneColor"] 
        , this.pBrushPhysical := Gdip_BrushCreateSolid(physicalImmuneColor)
        , this.pBrushMagic := Gdip_BrushCreateSolid(magicImmuneColor)
        , this.pBrushFire := Gdip_BrushCreateSolid(fireImmuneColor)
        , this.pBrushLight := Gdip_BrushCreateSolid(lightImmuneColor)
        , this.pBrushCold := Gdip_BrushCreateSolid(coldImmuneColor)
        , this.pBrushPoison := Gdip_BrushCreateSolid(poisonImmuneColor)

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
        Gui, UIAssist: Destroy
    }
}