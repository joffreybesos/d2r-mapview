#NoEnv

class UnitsLayer {
    hbm :=
    hdc :=
    obm :=
    G :=

    __new(ByRef uiData) {
        scaledWidth := uiData["scaledWidth"]
        scaledHeight := uiData["scaledHeight"]

        if (settings["centerMode"]) {
            WinGetPos, , , gameWidth, gameHeight, %gameWindowId% 
            this.hbm := CreateDIBSection(gameWidth, gameHeight)
        } else {
            this.hbm := CreateDIBSection(scaledWidth, scaledHeight)
        }
        this.hdc := CreateCompatibleDC()
        this.obm := SelectObject(this.hdc, this.hbm)

        this.G := Gdip_GraphicsFromHDC(this.hdc)
        Gdip_SetSmoothingMode(this.G, 4)
        Gdip_SetInterpolationMode(this.G, 7)
        this.createPens(settings)
    }

    createPens(ByRef settings) {
        this.pPenGreen := Gdip_CreatePen(0xff00FF00, 2)
        this.pBrushGreen := Gdip_BrushCreateSolid(0xff00FF00)
        this.pBrushDarkGreen := Gdip_BrushCreateSolid(0xff00aa00)
        this.pPenBlack := Gdip_CreatePen(0xff000000, 1)
        this.pPenHealth := Gdip_CreatePen(0xccdd0000, 1)
        this.pBrushHealth := Gdip_BrushCreateSolid(0x44dd0000)
        this.pBrushNonHealth := Gdip_BrushCreateSolid(0x44000000)

        ; lines
        this.pLineWP := Gdip_CreatePen(0x55ffFF00, 3)
        this.pLineExit := Gdip_CreatePen(0x55FF00FF, 3)
        this.pLineBoss := Gdip_CreatePen(0x55FF0000, 3)
        this.pLineQuest := Gdip_CreatePen(0x5500FF00, 3)
        this.pBrushLineWP := Gdip_BrushCreateSolid(0x55ffFF00)
        this.pBrushLineExit := Gdip_BrushCreateSolid(0x55FF00FF)
        this.pBrushLineBoss := Gdip_BrushCreateSolid(0x55FF0000)
        this.pBrushLineQuest := Gdip_BrushCreateSolid(0x5500FF00)

        ; missiles
        missileOpacity := settings["missileOpacity"]
        , physicalMajorColor := missileOpacity . settings["missileColorPhysicalMajor"]
        , physicalMinorColor := missileOpacity . settings["missileColorPhysicalMinor"]
        , fireMajorColor := missileOpacity . settings["missileFireMajorColor"]
        , fireMinorColor := missileOpacity . settings["missileFireMinorColor"]
        , iceMajorColor := missileOpacity . settings["missileIceMajorColor"]
        , iceMinorColor := missileOpacity . settings["missileIceMinorColor"]
        , lightMajorColor := missileOpacity . settings["missileLightMajorColor"]
        , lightMinorColor := missileOpacity . settings["missileLightMinorColor"]
        , poisonMajorColor := missileOpacity . settings["missilePoisonMajorColor"]
        , poisonMinorColor := missileOpacity . settings["missilePoisonMinorColor"]
        , magicMajorColor := missileOpacity . settings["missileMagicMajorColor"]
        , magicMinorColor := missileOpacity . settings["missileMagicMinorColor"]
        , penSize:=2
        , this.majorDotSize := settings["missileMajorDotSize"]
        , this.minorDotSize := settings["missileMinorDotSize"]
        scale := 2 ; TOFIX: Need to include this variable in construtor
        if (settings["centerMode"]) {
            penSize := penSize * (scale / 1.2)
            , this.majorDotSize := this.majorDotSize * (scale / 1.1)
            , this.minorDotSize := this.minorDotSize * (scale / 1.1)
        }

        this.pPenPhysicalMajor := Gdip_CreatePen(physicalMajorColor, penSize)
        , this.pPenPhysicalMinor := Gdip_CreatePen(physicalMinorColor, penSize)
        , this.pPenFireMajor := Gdip_CreatePen(fireMajorColor, penSize)
        , this.pPenFireMinor := Gdip_CreatePen(fireMajorColor, penSize)
        , this.pPenIceMajor := Gdip_CreatePen(iceMajorColor, penSize)
        , this.pPenIceMinor := Gdip_CreatePen(iceMinorColor, penSize)
        , this.pPenLightMajor := Gdip_CreatePen(lightMajorColor, penSize)
        , this.pPenLightMinor := Gdip_CreatePen(lightMinorColor, penSize)
        , this.pPenPoisonMajor := Gdip_CreatePen(poisonMajorColor, penSize)
        , this.pPenPoisonMinor := Gdip_CreatePen(poisonMinorColor, penSize)
        , this.pPenMagicMajor := Gdip_CreatePen(magicMajorColor, penSize)
        , this.pPenMagicMinor := Gdip_CreatePen(magicMinorColor, penSize)

        ; monsters
        normalMobColor := 0xff . settings["normalMobColor"] 
        , uniqueMobColor := 0xff . settings["uniqueMobColor"] 
        , bossColor := 0xff . settings["bossColor"] 
        , deadColor := 0x44 . settings["deadColor"] 
        , mercColor := 0xcc . settings["mercColor"]
        , this.deadDotSize := settings["deadDotSize"] ; 2
        , this.normalDotSize := settings["normalDotSize"] ; 5
        , this.normalImmunitySize := settings["normalImmunitySize"] ; 8
        , this.uniqueDotSize := settings["uniqueDotSize"] ; 8
        , this.uniqueImmunitySize := settings["uniqueImmunitySize"] ; 14
        , this.bossDotSize := settings["bossDotSize"] ; 5

        if (settings["centerMode"]) {
            this.deadDotSize := this.deadDotSize * (scale / 1.2)
            , this.normalDotSize := this.normalDotSize * (scale / 1.2)
            , this.normalImmunitySize := this.normalImmunitySize * (scale / 1.2)
            , this.uniqueDotSize := this.uniqueDotSize * (scale / 1.2)
            , this.uniqueImmunitySize := this.uniqueImmunitySize * (scale / 1.2)
            , this.bossDotSize := this.bossDotSize * (scale / 1.2)
        }

        this.pPenNormal := Gdip_CreatePen(normalMobColor, this.normalDotSize * 0.7)
        , this.pPenUnique := Gdip_CreatePen(uniqueMobColor, this.uniqueDotSize * 0.7)
        , this.pPenBoss := Gdip_CreatePen(bossColor, this.bossDotSize)
        , this.pPenDead := Gdip_CreatePen(deadColor, this.deadDotSize)
        , this.pPenMerc := Gdip_CreatePen(mercColor, this.normalDotSize * 0.7)

        ; immunities
        , physicalImmuneColor := 0xff . settings["physicalImmuneColor"] 
        , magicImmuneColor := 0xff . settings["magicImmuneColor"] 
        , fireImmuneColor := 0xff . settings["fireImmuneColor"] 
        , lightImmuneColor := 0xff . settings["lightImmuneColor"] 
        , coldImmuneColor := 0xff . settings["coldImmuneColor"] 
        , poisonImmuneColor := 0xff . settings["poisonImmuneColor"] 

        , this.pPenPhysical := Gdip_CreatePen(physicalImmuneColor, this.normalDotSize)
        , this.pPenMagic := Gdip_CreatePen(magicImmuneColor, this.normalDotSize)
        , this.pPenFire := Gdip_CreatePen(fireImmuneColor, this.normalDotSize)
        , this.pPenLight := Gdip_CreatePen(lightImmuneColor, this.normalDotSize)
        , this.pPenCold := Gdip_CreatePen(coldImmuneColor, this.normalDotSize)
        , this.pPenPoison := Gdip_CreatePen(poisonImmuneColor, this.normalDotSize)

        ; portals
        if (settings["centerMode"]) {
            this.pPortal := Gdip_CreatePen("0xff" . settings["portalColor"], 5)
            this.pRedPortal := Gdip_CreatePen("0xff" . settings["redPortalColor"], 5)
        } else {
            this.pPortal := Gdip_CreatePen("0xff" . settings["portalColor"], 2.5)
            this.pRedPortal := Gdip_CreatePen("0xff" . settings["redPortalColor"], 2.5)
        }

        ; chests
        this.pChest := Gdip_CreatePen(0xcc111111, 2)
    }

    delete() {
        SelectObject(this.hdc, this.obm)
        DeleteObject(this.hbm)
        DeleteDC(this.hdc)
        Gdip_DeleteGraphics(this.G)

        Gdip_DeleteBrush(this.pBrushGreen) 
        , Gdip_DeleteBrush(this.pBrushDarkGreen) 
        , Gdip_DeletePen(this.pPenGreen)
        , Gdip_DeletePen(this.pPenBlack)
        , Gdip_DeletePen(this.pPenHealth)
        , Gdip_DeleteBrush(this.pBrushHealth) 
        , Gdip_DeleteBrush(this.pBrushNonHealth) 
        , Gdip_DeletePen(this.pLineWP)
        , Gdip_DeletePen(this.pLineExit)
        , Gdip_DeletePen(this.pLineBoss)
        , Gdip_DeletePen(this.pLineQuest)
        , Gdip_DeleteBrush(this.pBrushLineWP)
        , Gdip_DeleteBrush(this.pBrushLineExit)
        , Gdip_DeleteBrush(this.pBrushLineBoss)
        , Gdip_DeleteBrush(this.pBrushLineQuest)
        , Gdip_DeletePen(this.pPenPhysicalMajor)
        , Gdip_DeletePen(this.pPenPhysicalMinor)
        , Gdip_DeletePen(this.pPenFireMajor)
        , Gdip_DeletePen(this.pPenFireMinor)
        , Gdip_DeletePen(this.pPenIceMajor)
        , Gdip_DeletePen(this.pPenIceMinor)
        , Gdip_DeletePen(this.pPenLightMajor)
        , Gdip_DeletePen(this.pPenLightMinor)
        , Gdip_DeletePen(this.pPenPoisonMajor)
        , Gdip_DeletePen(this.pPenPoisonMinor)
        , Gdip_DeletePen(this.pPenMagicMajor)
        , Gdip_DeletePen(this.pPenMagicMinor)
        , Gdip_DeletePen(this.pPenNormal)
        , Gdip_DeletePen(this.pPenUnique)
        , Gdip_DeletePen(this.pPenBoss)
        , Gdip_DeletePen(this.pPenDead)
        , Gdip_DeletePen(this.pPenMerc)
        , Gdip_DeletePen(this.pPenPhysical)
        , Gdip_DeletePen(this.pPenMagic)
        , Gdip_DeletePen(this.pPenFire)
        , Gdip_DeletePen(this.pPenLight)
        , Gdip_DeletePen(this.pPenCold)
        , Gdip_DeletePen(this.pPenPoison)
        , Gdip_DeletePen(this.pPortal)
        , Gdip_DeletePen(this.pRedPortal)
        , Gdip_DeletePen(this.pChest)
    }
}