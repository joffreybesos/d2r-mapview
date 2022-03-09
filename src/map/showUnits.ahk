#SingleInstance, Force
SendMode Input
SetWorkingDir, %A_ScriptDir%
#Include %A_ScriptDir%\map\drawing\exits.ahk
#Include %A_ScriptDir%\map\drawing\items.ahk
#Include %A_ScriptDir%\map\drawing\lines.ahk
#Include %A_ScriptDir%\map\drawing\missiles.ahk
#Include %A_ScriptDir%\map\drawing\mobs.ahk
#Include %A_ScriptDir%\map\drawing\objects.ahk
#Include %A_ScriptDir%\map\drawing\otherplayers.ahk

ShowUnits(ByRef unitsLayer, ByRef settings, ByRef unitHwnd1, ByRef mapHwnd1, ByRef imageData, ByRef gameMemoryData, ByRef shrines, ByRef uiData) {
    scale:= settings["scale"]
    , leftMargin:= settings["leftMargin"]
    , topMargin:= settings["topMargin"]
    , Width := uiData["sizeWidth"]
    , Height := uiData["sizeHeight"]
    , levelNo:= gameMemoryData["levelNo"]
    , levelScale := imageData["levelScale"]
    , levelxmargin := imageData["levelxmargin"]
    , levelymargin := imageData["levelymargin"]
    , scale := levelScale * scale
    , leftMargin := leftMargin + levelxmargin
    , topMargin := topMargin + levelymargin

    if (settings["centerMode"]) {
        scale:= settings["centerModeScale"]
        , serverScale := settings["serverScale"]
        , opacity:= settings["centerModeOpacity"]
    } else {
        serverScale := 2 
    }
    
    StartTime := A_TickCount
    , Angle := 45
    , opacity := 1.0
    , padding := 150
    , scaledWidth := uiData["scaledWidth"]
    , scaledHeight := uiData["scaledHeight"]
    , rotatedWidth := uiData["rotatedWidth"]
    , rotatedHeight := uiData["rotatedHeight"]
    , centerLeftOffset := 0
    , centerTopOffset := 0
    ; get relative position of player in world
    ; xpos is absolute world pos in game
    ; each map has offset x and y which is absolute world position
    , xPosDot := ((gameMemoryData["xPos"] - imageData["mapOffsetX"]) * serverScale) + padding
    , yPosDot := ((gameMemoryData["yPos"] - imageData["mapOffsetY"]) * serverScale) + padding
    , correctedPos := correctPos(settings, xPosDot, yPosDot, (Width/2), (Height/2), scaledWidth, scaledHeight, scale)
    , xPosDot := correctedPos["x"]
    , yPosDot := correctedPos["y"]

    
    if (settings["centerMode"]) {
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
        , centerLeftOffset := leftMargin + (leftDiff/2)
        , centerTopOffset := topMargin + (topDiff/2)

        ;ToolTip % centerLeftOffset " " centerTopOffset
    }
    
    ;Missiles
    if (settings["showPlayerMissiles"] or settings["showEnemyMissiles"]) {
        drawMissiles(unitsLayer, settings, gameMemoryData, imageData, serverScale, scale, padding, Width, Height, scaledWidth, scaledHeight, centerLeftOffset, centerTopOffset)
    }

    ; draw monsters
    if (settings["showNormalMobs"] or settings["showDeadMobs"] or settings["showUniqueMobs"] or settings["showBosses"]) {
        drawMonsters(unitsLayer, settings, gameMemoryData, imageData, serverScale, scale, padding, Width, Height, scaledWidth, scaledHeight, centerLeftOffset, centerTopOffset)
    }

    ; draw portals
    if (settings["showPortals"] or settings["showChests"] or settings["showShrines"]) {
        drawObjects(unitsLayer, settings, gameMemoryData, imageData, serverScale, scale, padding, Width, Height, scaledWidth, scaledHeight, shrines, centerLeftOffset, centerTopOffset)
    }

    ; draw lines
    if (settings["showWaypointLine"] or settings["showNextExitLine"] or settings["showBossLine"]) {
        drawLines(unitsLayer, settings, gameMemoryData, imageData, serverScale, scale, padding, Width, Height, scaledWidth, scaledHeight, centerLeftOffset, centerTopOffset, xPosDot, yPosDot)
    }

    drawExits(unitsLayer, settings, gameMemoryData, imageData, serverScale, scale, padding, Width, Height, scaledWidth, scaledHeight, centerLeftOffset, centerTopOffset, xPosDot, yPosDot)

    ; draw other players
    if (settings["showOtherPlayers"]) {
        drawPlayers(unitsLayer, settings, gameMemoryData, imageData, serverScale, scale, padding, Width, Height, scaledWidth, scaledHeight, centerLeftOffset, centerTopOffset)
     }

    ; show item alerts
    if (settings["enableItemFilter"]) {
        drawItemAlerts(unitsLayer, settings, gameMemoryData, imageData, serverScale, scale, padding, Width, Height, scaledWidth, scaledHeight, centerLeftOffset, centerTopOffset)
    }

    if (!settings["centerMode"] or settings["showPlayerDotCenter"]) {
        ; draw player
        playerCrossXoffset := (xPosDot)+centerLeftOffset
        playerCrossYoffset := (yPosDot)+centerTopOffset
        if (settings["playerAsCross"]) {
            ; draw a gress cross to represent the player
            points := createCross(playerCrossXoffset, playerCrossYoffset, 5 * scale)
            
            Gdip_DrawPolygon(unitsLayer.G, unitsLayer.pPenGreen, points)
            
        } else {
            ; draw a square dot, but angled along the map Gdip_PathOutline()
            pBrush := Gdip_BrushCreateSolid(0xff00FF00)
            , xscale := 7 * scale
            , yscale := 3.5 * scale
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

    if (settings["centerMode"]) {
        WinGetPos, windowLeftMargin, windowTopMargin , gameWidth, gameHeight, %gameWindowId% 
        leftMargin := (gameWidth/2) - xPosDot + (settings["centerModeXoffset"] /2)
        , topMargin := (gameHeight/2) - yPosDot + (settings["centerModeYoffset"] /2)
        , regionWidth := gameWidth
        , regionHeight := gameHeight
        , regionX := 0 - leftMargin
        , regionY := 0 - topMargin
        if (leftMargin > 0) {
            regionX := windowLeftMargin
            , regionWidth := gameWidth - leftMargin + windowLeftMargin
        }
        if (topMargin > 0) {
            regionY := windowTopMargin
            , regionHeight := gameHeight - topMargin + windowTopMargin
        }
        ;ToolTip % "`n`n`n`n" regionX " " regionY " " regionWidth " " regionHeight
        WinSet, Region, %regionX%-%regionY% W%regionWidth% H%regionHeight%, ahk_id %mapHwnd1%
        ;WinSet, Region, %regionX%-%regionY% W%regionWidth% H%regionHeight%, ahk_id %unitHwnd1%
        UpdateLayeredWindow(unitHwnd1, unitsLayer.hdc, 0, 0, gameWidth, gameHeight)
        Gdip_GraphicsClear( unitsLayer.G )
    } else {
        WinGetPos, windowLeftMargin, windowTopMargin , gameWidth, gameHeight, %gameWindowId% 
        WinMove, ahk_id %mapHwnd1%,, windowLeftMargin+leftMargin, windowTopMargin+topMargin
        WinMove, ahk_id %unitHwnd1%,, windowLeftMargin+leftMargin, windowTopMargin+topMargin
        WinSet, Region, , ahk_id %mapHwnd1%
        WinSet, Region, , ahk_id %unitHwnd1%
        UpdateLayeredWindow(unitHwnd1, unitsLayer.hdc, , , scaledWidth, scaledHeight)
        Gdip_GraphicsClear( unitsLayer.G )
    }

    ElapsedTime := A_TickCount - StartTime
    ;ToolTip % "`n`n`n`n" ElapsedTime
    ;WriteLog("Draw players " ElapsedTime " ms taken")

    
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