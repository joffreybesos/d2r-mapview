#SingleInstance, Force
SendMode Input
SetWorkingDir, %A_ScriptDir%

drawLines(ByRef unitsLayer, ByRef settings, ByRef gameMemoryData, ByRef imageData, ByRef serverScale, ByRef scale, ByRef padding, ByRef Width, ByRef Height, ByRef scaledWidth, ByRef scaledHeight, ByRef centerLeftOffset, ByRef centerTopOffset, xPosDot, yPosDot) {
    
    ; draw way point line
    if (settings["showWaypointLine"]) {
        ;WriteLog(settings["showWaypointLine"])
        if (gameMemoryData["levelNo"] != 1 and gameMemoryData["levelNo"] != 40 and gameMemoryData["levelNo"] != 75 and gameMemoryData["levelNo"] != 103 and gameMemoryData["levelNo"] != 109) { ; not in town
            wpList := imageData["waypoint"]
            if (wpList) {
                for k, wp in wpList
                {
                    if (gameMemoryData["levelNo"] == wp.levelNo) {
                        waypointX := ((wp.x - imageData["mapOffsetX"]) * serverScale) + padding
                        , wayPointY := ((wp.y - imageData["mapOffsetY"]) * serverScale) + padding
                        , correctedPos := correctPos(settings, waypointX, wayPointY, (Width/2), (Height/2), scaledWidth, scaledHeight, scale)
                        , waypointX := correctedPos["x"] + centerLeftOffset
                        , wayPointY := correctedPos["y"] + centerTopOffset
                        drawLineWithArrow(unitsLayer, xPosDot+centerLeftOffset, yPosDot+centerTopOffset, waypointX, wayPointY, scale, unitsLayer.pLineWP, unitsLayer.pBrushLineWP)
                        ;Gdip_DrawLine(unitsLayer.G, unitsLayer.pLineWP, xPosDot + centerLeftOffset, yPosDot + centerTopOffset, waypointX, wayPointY)
                    }
                }
            }
        }
    }

    ; ;draw exit lines
    if (settings["showNextExitLine"]) {
        exitList := imageData["exits"]
        if (exitList) {
            for k, exitLabel in exitList
            {
                ; only draw the line if it's a 'next' exit
                if (gameMemoryData["levelNo"] == exitLabel.levelNo) {
                    if (isNextExit(gameMemoryData["levelNo"]) == exitLabel.id) {
                        exitX := ((exitLabel.x - imageData["mapOffsetX"]) * serverScale) + padding
                        , exitY := ((exitLabel.y - imageData["mapOffsetY"]) * serverScale) + padding
                        , correctedPos := correctPos(settings, exitX, exitY, (Width/2), (Height/2), scaledWidth, scaledHeight, scale)
                        , exitX := correctedPos["x"] + centerLeftOffset
                        , exitY := correctedPos["y"] + centerTopOffset

                        drawLineWithArrow(unitsLayer, xPosDot+centerLeftOffset, yPosDot+centerTopOffset, exitX, exitY, scale, unitsLayer.pLineExit, unitsLayer.pBrushLineExit)
                        ;Gdip_DrawLine(unitsLayer.G, unitsLayer.pLineExit, xPosDot+centerLeftOffset, yPosDot+centerTopOffset, exitX, exitY)
                    }
                }
            }
        }
    }

    ; ;draw boss lines
    if (settings["showBossLine"]) {
        bossList := imageData["bosses"]
        if (bossList) {
            for k, boss in bossList
            {
                ;bossArray[1] ; name of boss
                if (gameMemoryData["levelNo"] == boss.levelNo) {
                    bossX := ((boss.x - imageData["mapOffsetX"]) * serverScale) + padding
                    , bossY := ((boss.y - imageData["mapOffsetY"]) * serverScale) + padding
                    , correctedPos := correctPos(settings, bossX, bossY, (Width/2), (Height/2), scaledWidth, scaledHeight, scale)
                    , bossX := correctedPos["x"] + centerLeftOffset
                    , bossY := correctedPos["y"] + centerTopOffset
                    drawLineWithArrow(unitsLayer, xPosDot+centerLeftOffset, yPosDot+centerTopOffset, bossX, bossY, scale, unitsLayer.pLineBoss, unitsLayer.pBrushLineBoss)
                    ;Gdip_DrawLine(unitsLayer.G, unitsLayer.pLineBoss, xPosDot + centerLeftOffset, yPosDot + centerTopOffset, bossX, bossY)
                }
            }
        }
    }

    ; ;draw quest lines
    if (settings["showQuestLine"]) {
        
        questsList := imageData["quests"]
        if (questsList) {
            for k, quest in questsList
            {
                if (gameMemoryData["levelNo"] == quest.level) {
                    questX := ((quest.x - imageData["mapOffsetX"]) * serverScale) + padding
                    , questY := ((quest.y - imageData["mapOffsetY"]) * serverScale) + padding
                    , correctedPos := correctPos(settings, questX, questY, (Width/2), (Height/2), scaledWidth, scaledHeight, scale)
                    , questX := correctedPos["x"] + centerLeftOffset
                    , questY := correctedPos["y"] + centerTopOffset
                    drawLineWithArrow(unitsLayer, xPosDot+centerLeftOffset, yPosDot+centerTopOffset, questX, questY, scale, unitsLayer.pLineQuest, unitsLayer.pBrushLineQuest)
                    ; Gdip_DrawLine(unitsLayer.G, unitsLayer.pLineQuest, xPosDot + centerLeftOffset, yPosDot + centerTopOffset, questX, questY)
                }
            }
        }
    }
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
        case "44": return "58"
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
