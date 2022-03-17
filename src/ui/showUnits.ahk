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

ShowUnits(ByRef unitsLayer, ByRef settings, ByRef unitHwnd1, ByRef mapHwnd1, ByRef imageData, ByRef gameMemoryData, ByRef shrines, ByRef uiData) {
    ; timeStamp("unitsStart")
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
    WinGetPos, windowLeftMargin, windowTopMargin , gameWidth, gameHeight, %gameWindowId% 
    
    if (settings["centerMode"]) {
        
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
    ; timeStamp("unitsStart")
    
    ;Missiles
    if (settings["showPlayerMissiles"] or settings["showEnemyMissiles"]) {
        ; timeStamp("drawMissiles")
        drawMissiles(unitsLayer, settings, gameMemoryData, imageData, serverScale, scale, padding, Width, Height, scaledWidth, scaledHeight, centerLeftOffset, centerTopOffset)
        ; timeStamp("drawMissiles")
    }

    ; draw monsters
    if (settings["showNormalMobs"] or settings["showDeadMobs"] or settings["showUniqueMobs"] or settings["showBosses"]) {
        ; timeStamp("drawMonsters")
        drawMonsters(unitsLayer, settings, gameMemoryData, imageData, serverScale, scale, padding, Width, Height, scaledWidth, scaledHeight, centerLeftOffset, centerTopOffset)
        ; timeStamp("drawMonsters")
    }

    ; draw portals
    if (settings["showPortals"] or settings["showChests"] or settings["showShrines"]) {
        ; timeStamp("drawObjects")
        drawObjects(unitsLayer, settings, gameMemoryData, imageData, serverScale, scale, padding, Width, Height, scaledWidth, scaledHeight, shrines, centerLeftOffset, centerTopOffset)
        ; timeStamp("drawObjects")
    }

    ; draw lines
    if (settings["showWaypointLine"] or settings["showNextExitLine"] or settings["showBossLine"]) {
        ; timeStamp("drawLines")
        drawLines(unitsLayer, settings, gameMemoryData, imageData, serverScale, scale, padding, Width, Height, scaledWidth, scaledHeight, centerLeftOffset, centerTopOffset, xPosDot, yPosDot)
        ; timeStamp("drawLines")
    }

    ; timeStamp("drawExits")
    drawExits(unitsLayer, settings, gameMemoryData, imageData, serverScale, scale, padding, Width, Height, scaledWidth, scaledHeight, centerLeftOffset, centerTopOffset, xPosDot, yPosDot)
    ; timeStamp("drawExits")

    ; draw other players
    if (settings["showOtherPlayers"]) {
        ; timeStamp("drawPlayers")
        drawPlayers(unitsLayer, settings, gameMemoryData, imageData, serverScale, scale, padding, Width, Height, scaledWidth, scaledHeight, centerLeftOffset, centerTopOffset)
        ; timeStamp("drawPlayers")
     }

    ; show item alerts
    if (settings["enableItemFilter"]) {
        ; timeStamp("drawItemAlerts")
        drawItemAlerts(unitsLayer, settings, gameMemoryData, imageData, serverScale, scale, padding, Width, Height, scaledWidth, scaledHeight, centerLeftOffset, centerTopOffset)
        ; timeStamp("drawItemAlerts")
    }

    ; timeStamp("drawPlayer")
    if (!settings["centerMode"] or settings["showPlayerDotCenter"]) {
        ; draw player
        playerCrossXoffset := (xPosDot)+centerLeftOffset
        playerCrossYoffset := (yPosDot)+centerTopOffset
        if (settings["playerAsCross"]) {
            ; draw a gress cross to represent the player
            points := createCross(playerCrossXoffset, playerCrossYoffset, 4.9 * scale)
            Gdip_DrawPolygon(unitsLayer.G, unitsLayer.pPenPlayer, points)
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
            Gdip_FillPolygon(unitsLayer.G, unitsLayer.pBrushPlayer, points)    
            ; dotSize := 23
            ; Gdip_DrawEllipse(unitsLayer.G, unitsLayer.pPenBlack, playerCrossXoffset-(dotSize/2), playerCrossYoffset-(dotSize/4), dotSize, dotSize/2)
            ; Gdip_FillEllipse(unitsLayer.G, unitsLayer.pBrushPlayer, playerCrossXoffset-(dotSize/2), playerCrossYoffset-(dotSize/4), dotSize, dotSize/2)
        }       
    }
    ; timeStamp("drawPlayer")
    ; timeStamp("unitsEnd")
    if (settings["centerMode"]) {
        
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
    ; timeStamp("unitsEnd")
}

