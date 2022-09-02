#SingleInstance, Force
SendMode Input
SetWorkingDir, %A_ScriptDir%
#Include %A_ScriptDir%\ui\drawing\helper.ahk
#Include %A_ScriptDir%\ui\drawing\exits.ahk
#Include %A_ScriptDir%\ui\drawing\items.ahk
#Include %A_ScriptDir%\ui\drawing\lines.ahk
#Include %A_ScriptDir%\ui\drawing\missiles.ahk
#Include %A_ScriptDir%\ui\drawing\mobs.ahk
#Include %A_ScriptDir%\ui\drawing\objects.ahk
#Include %A_ScriptDir%\ui\drawing\otherplayers.ahk

class UnitsGUI {
    unitHwnd :=
    __new(ByRef settings) {
        Gui, Units: -Caption +E0x20 +E0x80000 +E0x00080000 +LastFound +AlwaysOnTop +ToolWindow +OwnDialogs 
        this.unitHwnd := WinExist()
        
        gameWindow := getWindowClientArea()
        this.hbm := CreateDIBSection(gameWindow.W, gameWindow.H)

        this.hdc := CreateCompatibleDC()
        this.obm := SelectObject(this.hdc, this.hbm)

        this.G := Gdip_GraphicsFromHDC(this.hdc)
        Gdip_SetSmoothingMode(this.G, 4)
        Gdip_SetInterpolationMode(this.G, 7)
        this.createPens(settings)
    }

    drawUnitLayer(ByRef settings, ByRef gameMemoryData) {
        ; timeStamp("unitsStart")
        StartTime := A_TickCount
        , Angle := 45
        , opacity := 1.0
        , scale:= settings["centerModeScale"]
        , renderScale := settings["serverScale"]
        , opacity:= settings["centerModeOpacity"]
        
        ; get relative position of player in world
        ; xpos is absolute world pos in game
        ; each map has offset x and y which is absolute world position
        gameWindow := getWindowClientArea()
        playerX := gameMemoryData.xPos
        playerY := gameMemoryData.yPos

        for index, mob in gameMemoryData.mobs
        {
            mobScreenPos := World2Screen(playerX, playerY, mob.x, mob.y, scale)
            Gdip_DrawEllipse(this.G, this.pPenTownNPCCross, mobScreenPos.x, mobScreenPos.y, 15, 15)
        }

        playerScreenPos := World2Screen(playerX, playerY, playerX, playerY, scale)
        
        points := createCross(playerScreenPos.x, playerScreenPos.y, 4.9 * scale)
        Gdip_DrawPolygon(this.G, this.pPenPlayer, points)

        
        Gdip_DrawRectangle(this.G, this.pPenHealth, 0, 0, gameWindow.W, gameWindow.H)
        UpdateLayeredWindow(this.unitHwnd, this.hdc, 0, 0, gameWindow.W, gameWindow.H)
        Gdip_GraphicsClear( this.G )

        ; timeStamp("unitsEnd")
    }

    show() {
        Gui, Units: Show, NA
    }

    hide() {
        Gui, Units: Hide ; hide units
    }

    createPens(ByRef settings) {
        scale := settings["centerModeScale"]
        this.pPenGreen := Gdip_CreatePen(0xff00FF00, 0.8 * scale)
        this.pPenPlayer := Gdip_CreatePen(0xff2087fd, 1 * scale)
        this.pPenOtherPlayer := Gdip_CreatePen(0xff00ff00, 0.8 * scale)
        this.pPenCorpse := Gdip_CreatePen(0xffff00ff, 0.8 * scale)
        this.pPenBlack := Gdip_CreatePen(0xff000000, 0.5 * scale)
        this.pPenHealth := Gdip_CreatePen(0xccdd0000, 0.5 * scale)
        this.pBrushGreen := Gdip_BrushCreateSolid(0xff00FF00)
        this.pBrushPlayer := Gdip_BrushCreateSolid(0xff2087fd)
        this.pBrushOtherPlayer := Gdip_BrushCreateSolid(0xff00FF00)
        this.pBrushCorpse := Gdip_BrushCreateSolid(0xffff00ff)
        this.pBrushDarkGreen := Gdip_BrushCreateSolid(0xff00aa00)
        this.pBrushHealth := Gdip_BrushCreateSolid(0x44dd0000)
        this.pBrushNonHealth := Gdip_BrushCreateSolid(0x44000000)

        ; lines
        this.pLineWP := Gdip_CreatePen(0x55ffFF00, 1.5 * scale)
        this.pLineExit := Gdip_CreatePen(0x55FF00FF, 1.5 * scale)
        this.pLineBoss := Gdip_CreatePen(0x55FF0000, 1.5 * scale)
        this.pLineQuest := Gdip_CreatePen(0x5500FF00, 1.5 * scale)
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
        , townNPCColor := 0xcc . settings["townNPCColor"]
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
        , this.pPenTownNPC := Gdip_CreatePen(townNPCColor, this.normalDotSize * 0.7)
        , this.pPenMercCross := Gdip_CreatePen(mercColor, 0.8* scale)
        , this.pPenTownNPCCross := Gdip_CreatePen(townNPCColor, 0.8 * scale)

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
            this.pPortal := Gdip_CreatePen("0xff" . settings["portalColor"], 2.5 * scale)
            this.pRedPortal := Gdip_CreatePen("0xff" . settings["redPortalColor"], 2.5 * scale)
        } else {
            this.pPortal := Gdip_CreatePen("0xff" . settings["portalColor"], 1.8 * scale)
            this.pRedPortal := Gdip_CreatePen("0xff" . settings["redPortalColor"], 1.8 * scale)
        }

        ; chests
        this.pChest := Gdip_CreatePen(0xcc111111, 1 * scale)
    }

    delete() {
        SelectObject(this.hdc, this.obm)
        DeleteObject(this.hbm)
        DeleteDC(this.hdc)
        Gdip_DeleteGraphics(this.G)

        Gdip_DeleteBrush(this.pBrushGreen) 
        , Gdip_DeleteBrush(this.pBrushDarkGreen) 
        , Gdip_DeletePen(this.pPenGreen)
        , Gdip_DeletePen(this.pPenPlayer)
        , Gdip_DeletePen(this.pPenOtherPlayer)
        , Gdip_DeletePen(this.pPenCorpse)
        , Gdip_DeleteBrush(this.pBrushOtherPlayer)
        , Gdip_DeleteBrush(this.pBrushCorpse)
        , Gdip_DeletePen(this.pPenBlack)
        , Gdip_DeletePen(this.pPenHealth)
        , Gdip_DeleteBrush(this.pBrushPlayer)
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
        , Gdip_DeletePen(this.pPenTownNPC)
        , Gdip_DeletePen(this.pPenMercCross)
        , Gdip_DeletePen(this.pPenTownNPCCross)
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



; player is always middle of screen, calculate relative to that
World2Screen(ByRef playerX, ByRef playerY, ByRef targetx, ByRef targety, scale) {
    ; scale := 27
    scale := scale * 3
    xdiff := targetx - playerX
    ydiff := targety - playerY
    
    gameWindow := getWindowClientArea()
    centerX := (gameWindow.W/2)
    centerY := (gameWindow.H/2)
    angle := 0.785398    ;45 deg
    x := xdiff * cos(angle) - ydiff * sin(angle)
    y := xdiff * sin(angle) + ydiff * cos(angle)
    x := centerX + (x * scale)
    y := centerY + (y * scale * 0.5) - 10
    return { "x": x, "y": y }
}