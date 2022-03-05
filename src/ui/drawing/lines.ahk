#SingleInstance, Force
SendMode Input
SetWorkingDir, %A_ScriptDir%

drawLines(ByRef unitsLayer, ByRef settings, ByRef gameMemoryData, ByRef imageData, ByRef serverScale, ByRef scale, ByRef padding, ByRef Width, ByRef Height, ByRef scaledWidth, ByRef scaledHeight, ByRef centerLeftOffset, ByRef centerTopOffset, xPosDot, yPosDot) {
    
    ; draw way point line
    if (settings["showWaypointLine"]) {
        ;WriteLog(settings["showWaypointLine"])
        waypointHeader := imageData["waypoint"]
        if (waypointHeader) {
            wparray := StrSplit(waypointHeader, ",")
            , waypointX := (wparray[1] * serverScale) + padding
            , wayPointY := (wparray[2] * serverScale) + padding
            , correctedPos := correctPos(settings, waypointX, wayPointY, (Width/2), (Height/2), scaledWidth, scaledHeight, scale)
            , waypointX := correctedPos["x"] + centerLeftOffset
            , wayPointY := correctedPos["y"] + centerTopOffset
            drawLineWithArrow(unitsLayer, xPosDot+centerLeftOffset, yPosDot+centerTopOffset, waypointX, wayPointY, scale, unitsLayer.pLineWP, unitsLayer.pBrushLineWP)
            ;Gdip_DrawLine(unitsLayer.G, unitsLayer.pLineWP, xPosDot + centerLeftOffset, yPosDot + centerTopOffset, waypointX, wayPointY)
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

                ; only draw the line if it's a 'next' exit
                if (isNextExit(GameMemoryData["levelNo"]) == exitArray[1]) {
                    exitX := (exitArray[3] * serverScale) + padding
                    , exitY := (exitArray[4] * serverScale) + padding
                    , correctedPos := correctPos(settings, exitX, exitY, (Width/2), (Height/2), scaledWidth, scaledHeight, scale)
                    , exitX := correctedPos["x"] + centerLeftOffset
                    , exitY := correctedPos["y"] + centerTopOffset

                    drawLineWithArrow(unitsLayer, xPosDot+centerLeftOffset, yPosDot+centerTopOffset, exitX, exitY, scale, unitsLayer.pLineExit, unitsLayer.pBrushLineExit)
                    ;Gdip_DrawLine(unitsLayer.G, unitsLayer.pLineExit, xPosDot+centerLeftOffset, yPosDot+centerTopOffset, exitX, exitY)
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
            , bossX := (bossArray[2] * serverScale) + padding
            , bossY := (bossArray[3] * serverScale) + padding
            , correctedPos := correctPos(settings, bossX, bossY, (Width/2), (Height/2), scaledWidth, scaledHeight, scale)
            , bossX := correctedPos["x"] + centerLeftOffset
            , bossY := correctedPos["y"] + centerTopOffset
            drawLineWithArrow(unitsLayer, xPosDot+centerLeftOffset, yPosDot+centerTopOffset, bossX, bossY, scale, unitsLayer.pLineBoss, unitsLayer.pBrushLineBoss)
            ;Gdip_DrawLine(unitsLayer.G, unitsLayer.pLineBoss, xPosDot + centerLeftOffset, yPosDot + centerTopOffset, bossX, bossY)
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
                , questX := (questsArray[2] * serverScale) + padding
                , questY := (questsArray[3] * serverScale) + padding
                , correctedPos := correctPos(settings, questX, questY, (Width/2), (Height/2), scaledWidth, scaledHeight, scale)
                , questX := correctedPos["x"] + centerLeftOffset
                , questY := correctedPos["y"] + centerTopOffset
                drawLineWithArrow(unitsLayer, xPosDot+centerLeftOffset, yPosDot+centerTopOffset, questX, questY, scale, unitsLayer.pLineQuest, unitsLayer.pBrushLineQuest)
                ; Gdip_DrawLine(unitsLayer.G, unitsLayer.pLineQuest, xPosDot + centerLeftOffset, yPosDot + centerTopOffset, questX, questY)
            }
        }
    }
}


drawLineWithArrow(ByRef unitsLayer, ByRef xPosDot, ByRef yPosDot, ByRef targetX, ByRef targetY, ByRef scale, ByRef pen, ByRef brush) {
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
            Gdip_FillPolygon(unitsLayer.G, brush, arrowPoints)
            Gdip_DrawLine(unitsLayer.G, pen, newCoords["x"], newCoords["y"], arrowBase["x"], arrowBase["y"])
            ;Gdip_DrawLine(unitsLayer.G, unitsLayer.pLineExit, arrowTip["x"], arrowTip["y"], targetX, targetY)
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
    y2 := y2 * 2
    Angle2 := findAngle(x1, y1, x2, y2)
    newAngle := angle - Angle2
    newPos := getPosFromAngle(x1,y1,distance,newAngle)
    newPos["y"] := newPos["y"] / 2
    return newPos
}


isNextExit(currentLvl) {
    switch currentLvl
    {
        case "2": return "8"
        case "3": return "9"
        case "4": return "10"
        case "6": return "20"
        case "7": return "12"
        case "8": return "2"
        case "9": return "13"
        case "10": return "5"
        case "11": return "15"
        case "12": return "16"
        case "21": return "22"
        case "22": return "23"
        case "23": return "24"
        case "24": return "25"
        case "29": return "30"
        case "30": return "31"
        case "31": return "32"
        case "33": return "34"
        case "34": return "35"
        case "35": return "36"
        case "36": return "37"
        case "41": return "55"
        case "42": return "56"
        case "43": return "62"
        case "44": return "65"
        case "45": return "58"
        case "47": return "48"
        case "48": return "49"
        case "50": return "51"
        case "51": return "52"
        case "52": return "53"
        case "53": return "54"
        case "56": return "57"
        case "57": return "60"
        case "58": return "61"
        case "62": return "63"
        case "63": return "64"
        case "76": return "85"
        case "78": return "88"
        case "83": return "100"
        case "86": return "87"
        case "87": return "90"
        case "88": return "89"
        case "89": return "91"
        case "92": return "93"
        case "100": return "101"
        case "101": return "102"
        case "106": return "107"
        case "113": return "114"
        case "115": return "117"
        case "118": return "120"
        case "122": return "123"
        case "123": return "124"
        case "128": return "129"
        case "129": return "130"
        case "130": return "131"
    }
    return
}
