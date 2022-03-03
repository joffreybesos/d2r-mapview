#SingleInstance, Force
SendMode Input
SetWorkingDir, %A_ScriptDir%

drawLines(ByRef G, settings, gameMemoryData, imageData, serverScale, scale, padding, Width, Height, scaledWidth, scaledHeight, centerLeftOffset, centerTopOffset, xPosDot, yPosDot) {
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
            wayPointY := correctedPos["y"] + centerTopOffset
            pPen := Gdip_CreatePen(0x55ffFF00, 3)
            Gdip_DrawLine(G, pPen, xPosDot + centerLeftOffset, yPosDot + centerTopOffset, waypointX, wayPointY)
            Gdip_DeletePen(pPen)
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

                ; only draw the line if it's a 'next' exit
                if (isNextExit(gameMemoryData["levelNo"]) == exitArray[1]) {
                    pPen := Gdip_CreatePen(0x55FF00FF, 3)
                    Gdip_DrawLine(G, pPen, xPosDot+centerLeftOffset, yPosDot+centerTopOffset, exitX, exitY)
                    Gdip_DeletePen(pPen)
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

            pPen := Gdip_CreatePen(0x55FF0000, 3)
            Gdip_DrawLine(G, pPen, xPosDot + centerLeftOffset, yPosDot + centerTopOffset, bossX, bossY)
            Gdip_DeletePen(pPen)
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

                pPen := Gdip_CreatePen(0x5500FF00, 3)
                Gdip_DrawLine(G, pPen, xPosDot + centerLeftOffset, yPosDot + centerTopOffset, questX, questY)
                Gdip_DeletePen(pPen)
            }
        }
    }
}