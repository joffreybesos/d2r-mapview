#SingleInstance, Force
SendMode Input
SetWorkingDir, %A_ScriptDir%

drawLines(G, settings, gameMemoryData, imageData, serverScale, scale, padding, Width, Height, scaledWidth, scaledHeight, centerLeftOffset, centerTopOffset, xPosDot, yPosDot) {
    ; draw way point line
    if (settings["showWaypointLine"]) {
        ;WriteLog(settings["showWaypointLine"])
        waypointHeader := imageData["waypoint"]
        if (waypointHeader) {
            wparray := StrSplit(waypointHeader, ",")
            waypointX := (wparray[1] * serverScale) + padding
            wayPointY := (wparray[2] * serverScale) + padding
            correctedPos := correctPos(settings, waypointX, wayPointY, (Width/2), (Height/2), scaledWidth, scaledHeight, scale)
            waypointX := correctedPos["x"] + centerLeftOffset
            wayPointY := correctedPos["y"] + 
            newCoords := calculateFixedLength(xPosDot+centerLeftOffset, yPosDot+centerTopOffset, waypointX, wayPointY, (10 * scale))
            if (newCoords["x1"]) {
                if (newCoords["lineLength"] > (50 * scale)) {
                    pPen := Gdip_CreatePen(0x55ffFF00, 3)
                    Gdip_DrawLine(G, pPen, newCoords["x1"], newCoords["y1"], waypointX, wayPointY)
                    Gdip_DeletePen(pPen)
                }
            }
        }
    }

    ; ;draw exit lines
    if (settings["showNextExitLine"]) {
        exitsHeader := imageData["exits"]
        if (exitsHeader) {
            Loop, parse, exitsHeader, `|
            {
                exitArray := StrSplit(A_LoopField, ",")
                ;exitArray[1] ; id of exit
                ;exitArray[2] ; name of exit
                exitX := (exitArray[3] * serverScale) + padding
                exitY := (exitArray[4] * serverScale) + padding
                correctedPos := correctPos(settings, exitX, exitY, (Width/2), (Height/2), scaledWidth, scaledHeight, scale)
                exitX := correctedPos["x"] + centerLeftOffset
                exitY := correctedPos["y"] + centerTopOffset

                ;WriteLog(xPosDot+centerLeftOffset " " yPosDot+centerTopOffset " " exitX " " exitY " " newCoords["x1"] " " newCoords["y1"])

                ; only draw the line if it's a 'next' exit
                if (isNextExit(gameMemoryData["levelNo"]) == exitArray[1]) {
                    newCoords := calculateFixedLength(xPosDot+centerLeftOffset, yPosDot+centerTopOffset, exitX, exitY, (10 * scale))
                    if (newCoords["x1"]) {
                        ;WriteLog(xPosDot+centerLeftOffset " " yPosDot+centerTopOffset " " exitX " " exitY " " newCoords["x1"] " " newCoords["y1"] " " newCoords["x2"] " " newCoords["y2"])
                        
                        if (newCoords["lineLength"] > (50 * scale)) {
                            pPen := Gdip_CreatePen(0x55FF00FF, 3)
                            Gdip_DrawLine(G, pPen, newCoords["x1"], newCoords["y1"], exitX, exitY)
                            Gdip_DeletePen(pPen)
                        }
                    }
                }
            }
        }
    }

    ; ;draw boss lines
    if (settings["showBossLine"]) {
        bossHeader := imageData["bosses"]
        if (bossHeader) {
            bossArray := StrSplit(bossHeader, ",")
            ;bossArray[1] ; name of boss
            bossX := (bossArray[2] * serverScale) + padding
            bossY := (bossArray[3] * serverScale) + padding
            correctedPos := correctPos(settings, bossX, bossY, (Width/2), (Height/2), scaledWidth, scaledHeight, scale)
            bossX := correctedPos["x"] + centerLeftOffset
            bossY := correctedPos["y"] + centerTopOffset
            newCoords := calculateFixedLength(xPosDot+centerLeftOffset, yPosDot+centerTopOffset, bossX, bossY, (10 * scale))
            if (newCoords["x1"]) {
                ;WriteLog(xPosDot+centerLeftOffset " " yPosDot+centerTopOffset " " exitX " " exitY " " newCoords["x1"] " " newCoords["y1"] " " newCoords["x2"] " " newCoords["y2"])
                
                if (newCoords["lineLength"] > (50 * scale)) {
                    pPen := Gdip_CreatePen(0x55FF0000, 3)
                    Gdip_DrawLine(G, pPen, newCoords["x1"], newCoords["y1"], bossX, bossY)
                    Gdip_DeletePen(pPen)
                }
            }
        }
    }

    ; ;draw quest lines
    if (settings["showQuestLine"]) {
        
        questsHeader := imageData["quests"]
        
        if (questsHeader) {
            Loop, parse, questsHeader, `|
            {
                questsArray := StrSplit(A_LoopField, ",")
                ;questsArray[1] ; name of quest
                questX := (questsArray[2] * serverScale) + padding
                questY := (questsArray[3] * serverScale) + padding
                correctedPos := correctPos(settings, questX, questY, (Width/2), (Height/2), scaledWidth, scaledHeight, scale)
                questX := correctedPos["x"] + centerLeftOffset
                questY := correctedPos["y"] + centerTopOffset
                newCoords := calculateFixedLength(xPosDot+centerLeftOffset, yPosDot+centerTopOffset, questX, questY, (10 * scale))
                if (newCoords["x1"]) {
                    ;WriteLog(xPosDot+centerLeftOffset " " yPosDot+centerTopOffset " " exitX " " exitY " " newCoords["x1"] " " newCoords["y1"] " " newCoords["x2"] " " newCoords["y2"])
                    
                    if (newCoords["lineLength"] > (50 * scale)) {
                        pPen := Gdip_CreatePen(0x5500FF00, 3)
                        Gdip_DrawLine(G, pPen, newCoords["x1"], newCoords["y1"], questX, questY)
                        Gdip_DeletePen(pPen)
                    }
                }
            }
        }
    }
}

calculateFixedLength(x1,y1,x2,y2, linegap)
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
    
    return {"x1": newx1, "y1": newy1, "lineLength": lineLength }
}

calculatePercentage(x1,y1,x2,y2, percentage)
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
    return {"x1": newx1, "y1": newy1 }
}