
class Brushes {
    __new(ByRef settings) {
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




drawFloatingText(ByRef G, ByRef brushes, ByRef unitx, ByRef unity, ByRef fontSize, ByRef fontColor, ByRef background, ByRef forceNoWrap, ByRef font, ByRef text) {
    
    textSpaceWidth := StrLen(text) * fontSize
    , textSpaceHeight := 100
    , textx := unitx - textSpaceWidth /2
    , texty := unity-(brushes.normalDotSize/2) - textSpaceHeight
    if (forceNoWrap) {
        NoWrap := "NoWrap"
    } else {
        NoWrap := ""
    }
    Options = x%textx% y%texty% Center vBottom %NoWrap% c%fontColor% r8 s%fontSize%
    textx := textx + 1
    , texty := texty + 1
    Options2 = x%textx% y%texty% Center vBottom %NoWrap% cff000000 r8 s%fontSize%
    
    ;x|y|width|height|chars|lines
    measuredString := Gdip_TextToGraphics(G, text, Options2, font, textSpaceWidth, textSpaceHeight)
    if (background) {        
        ms := StrSplit(measuredString , "|")
        , bgx := ms[1] - 5
        , bgy := ms[2] - 2
        , bgw := ms[3] + 8
        , bgh := ms[4] + 0
        Gdip_FillRectangle(G, brushes.pBrushNonHealth, bgx, bgy, bgw, bgh)
    }
    Gdip_TextToGraphics(G, text, Options,  font, textSpaceWidth, textSpaceHeight)
    return measuredString
}


drawChest(ByRef G, ByRef brushes, ByRef objectx, ByRef objecty, ByRef chestscale, ByRef state) {
    if (state == "trap") {
        pBrush := Gdip_BrushCreateSolid(0xccff0000)
    } else if (state == "locked") {
        pBrush := Gdip_BrushCreateSolid(0xccffff00)
    } else {
        pBrush := Gdip_BrushCreateSolid(0xcc542a00)
    }
    chestxoffset := objectx - 10
    , chestyoffset := objecty - 10
    , x1 := 10 * chestscale + chestxoffset
    , y1 := 19 * chestscale + chestyoffset
    , x2 := 40 * chestscale + chestxoffset
    , y2 := 12 * chestscale + chestyoffset
    , x3 := 50 * chestscale + chestxoffset
    , y3 := 28 * chestscale + chestyoffset
    , x4 := 19 * chestscale + chestxoffset
    , y4 := 34 * chestscale + chestyoffset
    , x5 := 4 * chestscale + chestxoffset
    , y5 := 25 * chestscale + chestyoffset
    , x6 := 35 * chestscale + chestxoffset
    , x7 := 17 * chestscale + chestxoffset
    , y7 := 32 * chestscale + chestyoffset
    , x8 := 4 * chestscale + chestxoffset
    , y8 := 18 * chestscale + chestyoffset
    , x9 := 16 * chestscale + chestxoffset
    , y9 := 35 * chestscale + chestyoffset
    , x10:= 15 * chestscale + chestxoffset
    , y11:= 13 * chestscale + chestyoffset
    , y12:= 30 * chestscale + chestyoffset
    , y13:= 31 * chestscale + chestyoffset
    , y15:= 24 * chestscale + chestyoffset
    , y16:= 40 * chestscale + chestyoffset
    , y17:= 49 * chestscale + chestyoffset
    , y18:= 38 * chestscale + chestyoffset
    , y19:= 21 * chestscale + chestyoffset
    , piewidth := 15 * chestscale
    , pieheight := 30 * chestscale
    backpoints = %x1%,%y1%|%x2%,%y2%|%x3%,%y3%|%x4%,%y4%|%x5%,%y5%|%x1%,%y19%

    Gdip_DrawPie(G, brushes.pChest, x6, y2, piewidth, pieheight, 180, 180)
    Gdip_FillPolygon(G, pBrush, backpoints)
    Gdip_FillPie(G, pBrush, x8, y8, piewidth, pieheight, 180, 180) ;15,30
    Gdip_FillPie(G, pBrush, x6, y11, piewidth, pieheight, 180, 180) ;17,31
    points = %x5%,%y15%|%x5%,%y16%|%x4%,%y17%|%x4%,%y4%|%x4%,%y17%|%x3%,%y18%|%x3%,%y15%|%x4%,%y4%|%x5%,%y5%
    Gdip_DrawPie(G, brushes.pChest, x8, y8, piewidth, pieheight, 180, 180)
    Gdip_FillPolygon(G, pBrush, points)
    Gdip_DrawPolygon(G, brushes.pChest, Points)
    Gdip_DrawLine(G, brushes.pChest, x1, y1, x2, y2)
    Gdip_DeleteBrush(pBrush)
}


drawLineWithArrow(ByRef G, ByRef brushes, ByRef xPosDot, ByRef yPosDot, ByRef targetX, ByRef targetY, ByRef scale, ByRef pen, ByRef brush) {
    newCoords := calculateFixedLength(xPosDot, yPosDot, targetX, targetY, (40 * scale))
    if (newCoords["x"]) {
        if (newCoords["lineLength"] > (80 * scale)) {
            arrowsize := 12 * scale
            , arrowTip := calculateFixedLength(targetX, targetY, xPosDot, yPosDot, (20 * scale))
            ;, arrowTip := calculatePercentage(xPosDot, yPosDot, targetX, targetY, 0.8)
            , arrowleft := calcThirdPoint(arrowTip["x"], arrowTip["y"], targetX, targetY, 60, arrowsize) 
            , arrowright := calcThirdPoint(arrowTip["x"], arrowTip["y"], targetX, targetY, 120, arrowsize) 
            , arrowBase := calculatePercentage(arrowleft["x"], arrowleft["y"], arrowright["x"], arrowright["y"], 0.5)
            , arrowPoints := arrowTip["x"] "," arrowTip["y"] "|"  arrowleft["x"] "," arrowleft["y"] "|" arrowright["x"] "," arrowright["y"]
            Gdip_FillPolygon(G, brush, arrowPoints)
            Gdip_DrawLine(G, pen, newCoords["x"], newCoords["y"], arrowBase["x"], arrowBase["y"])
            ;Gdip_DrawLine(G, unitsLayer.pLineExit, arrowTip["x"], arrowTip["y"], targetX, targetY)
        }
    }
}

calculateFixedLength(ByRef x1,ByRef y1,ByRef x2,ByRef y2, ByRef linegap)
{
    lineLength := Sqrt((Abs(x1 - x2) ** 2) + (Abs(y1 - y2) ** 2))
    newPc := 1 - ((lineLength - linegap) / lineLength)
    ;WriteLog(lineLength " " newPc)
    if (x1 > x2) {
        newx1 := x1 - ((x1 - x2) * newPc)
    } else {
        newx1 := x1 + ((x2 - x1) * newPc)
    }

    if (y1 > y2) {
        newy1 := y1 - ((y1 - y2) * newPc)
    } else {
        newy1 := y1 + ((y2 - y1) * newPc)
    }

    return {"x": newx1, "y": newy1, "lineLength": lineLength }
}

calculatePercentage(ByRef x1,ByRef y1,ByRef x2,ByRef y2, ByRef percentage)
{
    ;newPc := (ticktock * percentage) / 100
    if (x1 > x2) {
        newx1 := x1 - ((x1 - x2) * percentage)
    } else {
        newx1 := x1 + ((x2 - x1) * percentage)
    }

    if (y1 > y2) {
        newy1 := y1 - ((y1 - y2) * percentage)
    } else {
        newy1 := y1 + ((y2 - y1) * percentage)
    }
    return {"x": newx1, "y": newy1 }
} 

calcThirdPoint(x1,y1,x2,y2, ByRef angle, ByRef distance) {
    y1 := y1 * 2
    , y2 := y2 * 2
    , Angle2 := findAngle(x1, y1, x2, y2)
    , newAngle := angle - Angle2
    , newPos := getPosFromAngle(x1,y1,distance,newAngle)
    , newPos["y"] := newPos["y"] / 2
    return newPos
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
