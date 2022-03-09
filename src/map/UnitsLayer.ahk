#NoEnv

class UnitsLayer {
    hbm :=
    hdc :=
    obm :=
    G :=
    Width:=
    Height:=

    opacity := 1.0
    padding := 150

    __new(ByRef map, ByRef settings, ByRef imageData, ByRef unitHwnd1, ByRef mapHwnd1, ByRef gameMemoryData, ByRef shrines) {
        this.scaledWidth := map.this.scaledWidth
        this.scaledHeight := map.this.scaledHeight

        if (settings["centerMode"]) {
            WinGetPos, , , gameWidth, gameHeight, %gameWindowId% 
            this.hbm := CreateDIBSection(gameWidth, gameHeight)
        } else {
            this.hbm := CreateDIBSection(this.scaledWidth, this.scaledHeight)
        }
        this.hdc := CreateCompatibleDC()
        this.obm := SelectObject(this.hdc, this.hbm)

        this.G := Gdip_GraphicsFromHDC(this.hdc)
        Gdip_SetSmoothingMode(this.G, 4)
        Gdip_SetInterpolationMode(this.G, 7)
        this.createPens(settings)
        
        StartTime := A_TickCount

        this.Width := map.Width
        , this.Height := map.Height
        , this.scale:= settings["centerModeScale"]
        , this.serverScale := settings["serverScale"]
        , this.opacity:= settings["centerModeopacity"]
        , this.scaledWidth := map.scaledWidth
        , this.scaledHeight := map.scaledHeight
        , this.centerLeftOffset := 0
        , this.centerTopOffset := 0
        , this.mapOffsetX := imageData["mapOffsetX"]
        , this.mapOffsetY := imageData["mapOffsetY"]

    }

    Update(ByRef gameMemoryData, ByRef settings) {

        ; get relative position of player in world
        ; xpos is absolute world pos in game
        ; each map has offset x and y which is absolute world position
        xPosDot := ((gameMemoryData["xPos"] - this.mapOffsetX) * this.serverScale) + this.padding
        , yPosDot := ((gameMemoryData["yPos"] - this.mapOffsetY) * this.serverScale) + this.padding
        , correctedPos := correctPos(ByrRef settings, xPosDot, yPosDot, (this.Width/2), (this.Height/2), this.scaledWidth, this.scaledHeight, this.scale)
        , xPosDot := correctedPos["x"]
        , yPosDot := correctedPos["y"]
        ; OutputDebug, % this.mapOffsetX " " this.mapOffsetY " " gameMemoryData["xPos"] " " gameMemoryData["yPos"] "`n"
        
        WinGetPos, windowLeftMargin, windowTopMargin , gameWidth, gameHeight, %gameWindowId% 
        leftMargin := (gameWidth/2) - xPosDot + (settings["centerModeXoffset"] /2) + windowLeftMargin
        , topMargin := (gameHeight/2) - yPosDot + (settings["centerModeYoffset"] /2) + windowTopMargin
        , regionWidth := gameWidth
        , regionHeight := gameHeight
        , regionX := 0 - leftMargin
        , regionY := 0 - topMargin
        if (leftMargin > 0) {
            regionX := windowLeftMargin
            , regionWidth := gameWidth - leftMargin
        }
        if (topMargin > 0) {
            regionY := windowTopMargin
            , regionHeight := gameHeight - topMargin
        }

        leftDiff :=  lastLeftMargin - leftMargin
        , topDiff :=  lastTopMargin - topMargin
        ; leftDiff := 0
        ; topDiff :=  0
        , this.centerLeftOffset := leftMargin + (leftDiff/2)
        , this.centerTopOffset := topMargin + (topDiff/2)

        
        ; ;Missiles
        ; if (settings["showPlayerMissiles"] or settings["showEnemyMissiles"]) {
        ;     drawMissiles(unitsLayer, settings, gameMemoryData, imageData, this.serverScale, this.scale, padding, this.Width, this.Height, this.scaledWidth, this.scaledHeight, this.centerLeftOffset, this.centerTopOffset)
        ; }

        ; ; draw monsters
        ; if (settings["showNormalMobs"] or settings["showDeadMobs"] or settings["showUniqueMobs"] or settings["showBosses"]) {
        ;     drawMonsters(unitsLayer, settings, gameMemoryData, imageData, this.serverScale, this.scale, padding, this.Width, this.Height, this.scaledWidth, this.scaledHeight, this.centerLeftOffset, this.centerTopOffset)
        ; }

        ; ; draw portals
        ; if (settings["showPortals"] or settings["showChests"] or settings["showShrines"]) {
        ;     drawObjects(unitsLayer, settings, gameMemoryData, imageData, this.serverScale, this.scale, padding, this.Width, this.Height, this.scaledWidth, this.scaledHeight, shrines, this.centerLeftOffset, this.centerTopOffset)
        ; }

        ; ; draw lines
        ; if (settings["showWaypointLine"] or settings["showNextExitLine"] or settings["showBossLine"]) {
        ;     drawLines(unitsLayer, settings, gameMemoryData, imageData, this.serverScale, this.scale, padding, this.Width, this.Height, this.scaledWidth, this.scaledHeight, this.centerLeftOffset, this.centerTopOffset, xPosDot, yPosDot)
        ; }

        ; drawExits(unitsLayer, settings, gameMemoryData, imageData, this.serverScale, this.scale, padding, this.Width, this.Height, this.scaledWidth, this.scaledHeight, this.centerLeftOffset, this.centerTopOffset, xPosDot, yPosDot)

        ; ; draw other players
        ; if (settings["showOtherPlayers"]) {
        ;     drawPlayers(unitsLayer, settings, gameMemoryData, imageData, this.serverScale, this.scale, padding, this.Width, this.Height, this.scaledWidth, this.scaledHeight, this.centerLeftOffset, this.centerTopOffset)
        ; }

        ; ; show item alerts
        ; if (settings["enableItemFilter"]) {
        ;     drawItemAlerts(unitsLayer, settings, gameMemoryData, imageData, this.serverScale, this.scale, padding, this.Width, this.Height, this.scaledWidth, this.scaledHeight, this.centerLeftOffset, this.centerTopOffset)
        ; }

        if (!settings["centerMode"] or settings["showPlayerDotCenter"]) {
            ; draw player
            playerCrossXoffset := (xPosDot) + this.centerLeftOffset
            playerCrossYoffset := (yPosDot) + this.centerTopOffset
            if (settings["playerAsCross"]) {
                ; draw a gress cross to represent the player
                points := createCross(playerCrossXoffset, playerCrossYoffset, 5 * this.scale)
                
                Gdip_DrawPolygon(unitsLayer.G, unitsLayer.pPenGreen, points)
                
            } else {
                ; draw a square dot, but angled along the map Gdip_PathOutline()
                pBrush := Gdip_BrushCreateSolid(0xff00FF00)
                , xscale := 7 * this.scale
                , yscale := 3.5 * this.scale
                , x1 := playerCrossXoffset - xscale
                , x2 := playerCrossXoffset
                , x3 := playerCrossXoffset + xscale
                , y1 := playerCrossYoffset - yscale
                , y2 := playerCrossYoffset
                , y3 := playerCrossYoffset + yscale

                points = %x1%,%y2%|%x2%,%y1%|%x3%,%y2%|%x2%,%y3%
                Gdip_FillPolygon(unitsLayer.G, unitsLayer.pBrushGreen, points)    
                ; Gdip_DrawEllipse(unitsLayer.G, unitsLayer.pPenBlack, playerCrossXoffset-(dotSize/2), playerCrossYoffset-(dotSize/4), dotSize, dotSize/2)
                ; Gdip_FillEllipse(unitsLayer.G, unitsLayer.pBrushGreen, playerCrossXoffset-(dotSize/2), playerCrossYoffset-(dotSize/4), dotSize, dotSize/2)
                
            }       
        }

        ; if (settings["centerMode"]) {
        ; WinGetPos, windowLeftMargin, windowTopMargin , gameWidth, gameHeight, %gameWindowId% 
        ; leftMargin := (gameWidth/2) - xPosDot + (settings["centerModeXoffset"] /2)
        ; , topMargin := (gameHeight/2) - yPosDot + (settings["centerModeYoffset"] /2)
        ; , regionWidth := gameWidth
        ; , regionHeight := gameHeight
        ; , regionX := 0 - leftMargin
        ; , regionY := 0 - topMargin
        ; if (leftMargin > 0) {
        ;     regionX := windowLeftMargin
        ;     , regionWidth := gameWidth - leftMargin + windowLeftMargin
        ; }
        ; if (topMargin > 0) {
        ;     regionY := windowTopMargin
        ;     , regionHeight := gameHeight - topMargin + windowTopMargin
        ; }
        ;ToolTip % "`n`n`n`n" regionX " " regionY " " regionWidth " " regionHeight
        ;WinSet, Region, %regionX%-%regionY% W%regionWidth% H%regionHeight%, ahk_id %mapHwnd1%
        ;WinSet, Region, %regionX%-%regionY% W%regionWidth% H%regionHeight%, ahk_id %unitHwnd1%
        UpdateLayeredWindow(unitHwnd1, unitsLayer.hdc, 0, 0, gameWidth, gameHeight)
        Gdip_GraphicsClear( unitsLayer.G )
        ; } else {
        ;     WinGetPos, windowLeftMargin, windowTopMargin , gameWidth, gameHeight, %gameWindowId% 
        ;     WinMove, ahk_id %mapHwnd1%,, windowLeftMargin+leftMargin, windowTopMargin+topMargin
        ;     WinMove, ahk_id %unitHwnd1%,, windowLeftMargin+leftMargin, windowTopMargin+topMargin
        ;     WinSet, Region, , ahk_id %mapHwnd1%
        ;     WinSet, Region, , ahk_id %unitHwnd1%
        ;     UpdateLayeredWindow(unitHwnd1, unitsLayer.hdc, , , this.scaledWidth, this.scaledHeight)
        ;     Gdip_GraphicsClear( unitsLayer.G )
        ; }

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
        missilethis.opacity := settings["missilethis.opacity"]
        , physicalMajorColor := missilethis.opacity . settings["missileColorPhysicalMajor"]
        , physicalMinorColor := missilethis.opacity . settings["missileColorPhysicalMinor"]
        , fireMajorColor := missilethis.opacity . settings["missileFireMajorColor"]
        , fireMinorColor := missilethis.opacity . settings["missileFireMinorColor"]
        , iceMajorColor := missilethis.opacity . settings["missileIceMajorColor"]
        , iceMinorColor := missilethis.opacity . settings["missileIceMinorColor"]
        , lightMajorColor := missilethis.opacity . settings["missileLightMajorColor"]
        , lightMinorColor := missilethis.opacity . settings["missileLightMinorColor"]
        , poisonMajorColor := missilethis.opacity . settings["missilePoisonMajorColor"]
        , poisonMinorColor := missilethis.opacity . settings["missilePoisonMinorColor"]
        , magicMajorColor := missilethis.opacity . settings["missileMagicMajorColor"]
        , magicMinorColor := missilethis.opacity . settings["missileMagicMinorColor"]
        , penSize:=2
        , this.majorDotSize := settings["missileMajorDotSize"]
        , this.minorDotSize := settings["missileMinorDotSize"]
        ;scale := 2 ; TOFIX: Need to include this variable in construtor
        if (settings["centerMode"]) {
            penSize := penSize * (this.scale / 1.2)
            , this.majorDotSize := this.majorDotSize * (this.scale / 1.1)
            , this.minorDotSize := this.minorDotSize * (this.scale / 1.1)
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
            this.deadDotSize := this.deadDotSize * (this.scale / 1.2)
            , this.normalDotSize := this.normalDotSize * (this.scale / 1.2)
            , this.normalImmunitySize := this.normalImmunitySize * (this.scale / 1.2)
            , this.uniqueDotSize := this.uniqueDotSize * (this.scale / 1.2)
            , this.uniqueImmunitySize := this.uniqueImmunitySize * (this.scale / 1.2)
            , this.bossDotSize := this.bossDotSize * (this.scale / 1.2)
        }

        this.pPenNormal := Gdip_CreatePen(normalMobColor, this.normalDotSize * 0.7)
        , this.pPenUnique := Gdip_CreatePen(uniqueMobColor, this.uniqueDotSize * 0.7)
        , this.pPenBoss := Gdip_CreatePen(bossColor, this.bossDotSize)
        , this.pPenDead := Gdip_CreatePen(deadColor, this.deadDotSize)
        , this.pPenMerc := Gdip_CreatePen(mercColor, this.normalDotSize * 0.7)
        , this.pPenTownNPC := Gdip_CreatePen(townNPCColor, this.normalDotSize * 0.7)
        , this.pPenMercCross := Gdip_CreatePen(mercColor, 2)
        , this.pPenTownNPCCross := Gdip_CreatePen(townNPCColor, 2)

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





correctPos(settings, xPosDot, yPosDot, centerX, centerY, RWidth, RHeight, scale) {
    correctedPos := findNewPos(xPosDot, yPosDot, centerX, centerY, RWidth, RHeight, scale)
    if (settings["centerMode"]) {
        correctedPos["x"] := correctedPos["x"] + settings["centerModeXUnitoffset"]
        correctedPos["y"] := correctedPos["y"] + settings["centerModeYUnitoffset"]
    }
    return correctedPos
}

; converting to cartesian to polar and back again sucks
; I wish my matrix transformations worked
findNewPos(xPosDot, yPosDot, centerX, centerY, RWidth, RHeight, scale) {
    newAngle := findAngle(xPosDot, yPosDot, centerX, centerY) + 45
    , distance := getDistanceFromCoords(xPosDot, yPosDot, centerX, centerY) * scale
    , newPos := getPosFromAngle((RWidth/2),(RHeight/2),distance,newAngle)
    , newPos["y"] := (RHeight/2) + ((RHeight/2) - newPos["y"]) /2
    return newPos
}


findAngle(xPosDot, yPosDot, midW, midH) {
    Pi := 4 * ATan(1)
    , Conversion := -180 / Pi  ; Radians to deg.
    , Angle2 := DllCall("msvcrt.dll\atan2", "Double", yPosDot-midH, "Double", xPosDot-midW, "CDECL Double") * Conversion
    if (Angle2 < 0)
        Angle2 += 360
    return Angle2
}

getDistanceFromCoords(x2,y2,x1,y1){
    return sqrt((y2-y1)**2+(x2-x1)**2)
}

getPosFromAngle(x1,y1,len,ang){
	ang:=(ang-90) * 0.0174532925
	return {"x": x1+len*cos(ang),"y": y1+len*sin(ang)}
}


hasVal(haystack, needle) {
	for index, value in haystack
		if (value == needle)
			return index
	return 0
}


createCross(ByRef playerCrossXoffset, ByRef playerCrossYoffset, ByRef scale) {
    xscale := scale
    , yscale := scale / 2
    , x1 := playerCrossXoffset - xscale - xscale
    , x2 := playerCrossXoffset - xscale
    , x3 := playerCrossXoffset
    , x4 := playerCrossXoffset + xscale
    , x5 := playerCrossXoffset + xscale + xscale
    , y1 := playerCrossYoffset - yscale - yscale
    , y2 := playerCrossYoffset - yscale
    , y3 := playerCrossYoffset
    , y4 := playerCrossYoffset + yscale
    , y5 := playerCrossYoffset + yscale + yscale
    points = %x1%,%y2%|%x2%,%y3%|%x1%,%y4%|%x2%,%y5%|%x3%,%y4%|%x4%,%y5%|%x5%,%y4%|%x4%,%y3%|%x5%,%y2%|%x4%,%y1%|%x3%,%y2%|%x2%,%y1%
    return points
}