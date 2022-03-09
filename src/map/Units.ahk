#Include %A_ScriptDir%\map\drawing\exits.ahk
#Include %A_ScriptDir%\map\drawing\items.ahk
#Include %A_ScriptDir%\map\drawing\lines.ahk
#Include %A_ScriptDir%\map\drawing\missiles.ahk
#Include %A_ScriptDir%\map\drawing\mobs.ahk
#Include %A_ScriptDir%\map\drawing\objects.ahk
#Include %A_ScriptDir%\map\drawing\otherplayers.ahk

class Units {

    __new() {
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
    
}


