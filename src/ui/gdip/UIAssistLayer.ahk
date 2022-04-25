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
        WinGetPos, , , gameWidth, gameHeight, %gameWindowId% 
        this.y := 0
        this.resistBoxWidth := (gameHeight / 50) * 1.2
        this.resistBoxHeight := (gameHeight / 50)
        this.resistFontSize := gameHeight / 85
        this.healthnumbersHeight := (this.resistFontSize) / 2
        this.drawRegionWidth := this.resistBoxWidth * 6
        this.drawRegionHeight := (gameHeight / 14)
        
        pToken := Gdip_Startup()
        DetectHiddenWindows, On
        this.hbm := CreateDIBSection(this.drawRegionWidth, this.drawRegionHeight)
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
            gameClientArea := getWindowClientArea()
            gamewindowx := gameClientArea["X"]
            gamewindowy := gameClientArea["Y"]
            gameWidth := gameClientArea["W"]
            gameHeight := gameClientArea["H"]
            ;WinGetPos, gamewindowx, gamewindowy, gameWidth, gameHeight, %gameWindowId% 
            resistFontSize := this.resistFontSize
            
            resists := mob.immunities
            ;resists := { "physical": 45, "magic": 10, "fire": 45, "light": 120, "cold": 45, "poison": 45 }
            ;OutputDebug, % mob.txtFileNo " " resists["fire"] " " resists["cold"] "`n"

            numResists := (resists["physical"] > 0) + (resists["magic"] > 0) + (resists["fire"] > 0) + (resists["light"] > 0) + (resists["cold"] > 0) + (resists["poison"] > 0)
            startx := (gameWidth / 2) - (this.drawRegionWidth / 2)
            x := 0
            if (resists["physical"]) {
                Gdip_FillRectangle(this.G, this.pBrushPhysical, x, 0, this.resistBoxWidth, this.resistBoxHeight)
                this.drawResistText(x, 0, resistFontSize, resists["physical"])
            }
            x := x + this.resistBoxWidth
            if (resists["magic"]) {
                Gdip_FillRectangle(this.G, this.pBrushMagic, x, 0, this.resistBoxWidth, this.resistBoxHeight)
                this.drawResistText(x, 0, resistFontSize, resists["magic"])
            }
            x := x + this.resistBoxWidth
            if (resists["fire"]) {
                Gdip_FillRectangle(this.G, this.pBrushFire, x, 0, this.resistBoxWidth, this.resistBoxHeight)
                this.drawResistText(x, 0, resistFontSize, resists["fire"])
            }
            x := x + this.resistBoxWidth
            if (resists["light"]) {
                Gdip_FillRectangle(this.G, this.pBrushLight, x, 0, this.resistBoxWidth, this.resistBoxHeight)
                this.drawResistText(x, 0, resistFontSize, resists["light"])
            }
            x := x + this.resistBoxWidth
            if (resists["cold"]) {
                Gdip_FillRectangle(this.G, this.pBrushCold, x, 0, this.resistBoxWidth, this.resistBoxHeight)
                this.drawResistText(x, 0, resistFontSize, resists["cold"])
            }
            x := x + this.resistBoxWidth
            if (resists["poison"]) {
                Gdip_FillRectangle(this.G, this.pBrushPoison, x, 0, this.resistBoxWidth, this.resistBoxHeight)
                this.drawResistText(x, 0, resistFontSize, resists["poison"])
            }
            x := x + this.resistBoxWidth
            healthpc := Round((mob.hp / mob.maxhp) * 100, 0) " %"
            this.drawHealthText(this.resistFontSize * 0.8, "ffc6b276", healthpc) 
        }
        
        UpdateLayeredWindow(this.UIAssistLayerHwnd, this.hdc, gamewindowx + startx, gamewindowy + this.y, this.drawRegionWidth, this.drawRegionHeight)
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
        Gdip_TextToGraphics(this.G, resistVal, Options2, formalFont, this.resistBoxWidth*2, this.resistBoxHeight)
        Gdip_TextToGraphics(this.G, resistVal, Options,  formalFont, this.resistBoxWidth*2, this.resistBoxHeight)
    }

    drawHealthText(fontSize, fontColor, text) {
        textx := 0
        , texty := this.drawRegionHeight - (fontSize) - 3
        ;pPen := Gdip_CreatePen("0xccffffff", 5)
        ;Gdip_DrawRectangle(this.G, pPen, textx, texty, this.drawRegionWidth, this.healthnumbersHeight)
        ;Gdip_DeletePen(pPen)
        Options = x%textx% y%texty% Center vBottom c%fontColor% r8 s%fontSize%
        textx := textx + 1
        , texty := texty + 1
        Options2 = x%textx% y%texty% Center vBottom cff000000 r8 s%fontSize%
        Gdip_TextToGraphics(this.G, text, Options2, formalFont, this.drawRegionWidth, this.healthnumbersHeight)
        Gdip_TextToGraphics(this.G, text, Options,  formalFont, this.drawRegionWidth, this.healthnumbersHeight)
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