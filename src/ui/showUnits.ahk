#SingleInstance, Force
SendMode Input
SetWorkingDir, %A_ScriptDir%

ShowUnits(G, hdc, settings, unitHwnd1, mapHwnd1, imageData, gameMemoryData, shrines, uiData) {
    scale:= settings["scale"]
    leftMargin:= settings["leftMargin"]
    topMargin:= settings["topMargin"]
    Width := uiData["sizeWidth"]
    Height := uiData["sizeHeight"]
    levelNo:= gameMemoryData["levelNo"]
    levelScale := imageData["levelScale"]
    levelxmargin := imageData["levelxmargin"]
    levelymargin := imageData["levelymargin"]
    scale := levelScale * scale
    leftMargin := leftMargin + levelxmargin
    topMargin := topMargin + levelymargin

    if (settings["centerMode"]) {
        scale:= settings["centerModeScale"]
        serverScale := settings["serverScale"]
        opacity:= settings["centerModeOpacity"]
    } else {
        serverScale := 2 
    }
    
    StartTime := A_TickCount
    Angle := 45
    opacity := 1.0
    padding := 150

    scaledWidth := uiData["scaledWidth"]
    scaledHeight := uiData["scaledHeight"]
    rotatedWidth := uiData["rotatedWidth"]
    rotatedHeight := uiData["rotatedHeight"]

    ; get relative position of player in world
    ; xpos is absolute world pos in game
    ; each map has offset x and y which is absolute world position
    xPosDot := ((gameMemoryData["xPos"] - imageData["mapOffsetX"]) * serverScale) + padding
    yPosDot := ((gameMemoryData["yPos"] - imageData["mapOffsetY"]) * serverScale) + padding
    correctedPos := correctPos(settings, xPosDot, yPosDot, (Width/2), (Height/2), scaledWidth, scaledHeight, scale)
    xPosDot := correctedPos["x"]
    yPosDot := correctedPos["y"]

    
    ;Missiles
    if (settings["showPlayerMissiles"] or settings["showEnemyMissiles"]) {
        missileOpacity := settings["missileOpacity"]
        physicalMajorColor := missileOpacity . settings["missileColorPhysicalMajor"]
        physicalMinorColor := missileOpacity . settings["missileColorPhysicalMinor"]
        fireMajorColor := missileOpacity . settings["missileFireMajorColor"]
        fireMinorColor := missileOpacity . settings["missileFireMinorColor"]
        iceMajorColor := missileOpacity . settings["missileIceMajorColor"]
        iceMinorColor := missileOpacity . settings["missileIceMinorColor"]
        lightMajorColor := missileOpacity . settings["missileLightMajorColor"]
        lightMinorColor := missileOpacity . settings["missileLightMinorColor"]
        poisonMajorColor := missileOpacity . settings["missilePoisonMajorColor"]
        poisonMinorColor := missileOpacity . settings["missilePoisonMinorColor"]
        magicMajorColor := missileOpacity . settings["missileMagicMajorColor"]
        magicMinorColor := missileOpacity . settings["missileMagicMinorColor"]
        

        penSize:=2
        majorDotSize :=settings["missileMajorDotSize"]
        minorDotSize :=settings["missileMinorDotSize"]
        if (settings["centerMode"]) {
            penSize := penSize * (scale / 1.2)
            majorDotSize :=majorDotSize * (scale / 1.2)
            minorDotSize :=minorDotSize * (scale / 1.2)
        }
        
        pPenPhysicalMajor := Gdip_CreatePen(physicalMajorColor, penSize)
        pPenPhysicalMinor := Gdip_CreatePen(physicalMinorColor, penSize)
        pPenFireMajor := Gdip_CreatePen(fireMajorColor, penSize)
        pPenFireMinor := Gdip_CreatePen(fireMajorColor, penSize)
        pPenIceMajor := Gdip_CreatePen(iceMajorColor, penSize)
        pPenIceMinor := Gdip_CreatePen(iceMinorColor, penSize)
        pPenLightMajor := Gdip_CreatePen(lightMajorColor, penSize)
        pPenLightMinor := Gdip_CreatePen(lightMinorColor, penSize)
        pPenPoisonMajor := Gdip_CreatePen(poisonMajorColor, penSize)
        pPenPoisonMinor := Gdip_CreatePen(poisonMinorColor, penSize)
        pPenMagicMajor := Gdip_CreatePen(magicMajorColor, penSize)
        pPenMagicMinor := Gdip_CreatePen(magicMinorColor, penSize)
        
        static oldMissilex
        static oldMissiley
        for index,  missilearray in gameMemoryData["missiles"]
        {   
            for each, missile in missilearray
            {
                missilex := ((missile["x"] - imageData["mapOffsetX"]) * serverScale) + padding
                missiley := ((missile["y"] - imageData["mapOffsetY"]) * serverScale) + padding
                correctedPos := findNewPos(missilex, missiley, (Width/2), (Height/2), scaledWidth, scaledHeight, scale)
                missilex := correctedPos["x"]
                missiley := correctedPos["y"]
                if (oldMissilex = missilex && oldMissiley = missiley){
                } else {
                    switch (missile["UnitType"]){
                        case "PhysicalMajor": Gdip_DrawEllipse(G, pPenPhysicalMajor, missilex-3, missiley-3, majorDotSize, majorDotSize/2)
                        case "PhysicalMinor": Gdip_DrawEllipse(G, pPenPhysicalMinor, missilex-3, missiley-3, minorDotSize, minorDotSize/2)
                        case "FireMajor": Gdip_DrawEllipse(G, pPenFireMajor, missilex-3, missiley-3, majorDotSize, majorDotSize/2)
                        case "FireMinor": Gdip_DrawEllipse(G, pPenFireMinor, missilex-3, missiley-3, minorDotSize, minorDotSize/2)
                        case "IceMajor": Gdip_DrawEllipse(G, pPenIceMajor, missilex-3, missiley-3, majorDotSize, majorDotSize/2)
                        case "IceMinor": Gdip_DrawEllipse(G, pPenIceMinor, missilex-3, missiley-3, minorDotSize, minorDotSize/2)
                        case "LightMajor": Gdip_DrawEllipse(G, pPenLightMajor, missilex-3, missiley-3, majorDotSize, majorDotSize/2)
                        case "LightMinor": Gdip_DrawEllipse(G, pPenLightMinor, missilex-3, missiley-3, minorDotSize, minorDotSize/2)
                        case "PoisonMajor": Gdip_DrawEllipse(G, pPenPoisonMajor, missilex-3, missiley-3, majorDotSize, majorDotSize/2)
                        case "PoisonMinor": Gdip_DrawEllipse(G, pPenPoisonMinor, missilex-3, missiley-3, minorDotSize, minorDotSize/2)
                        case "MagicMajor": Gdip_DrawEllipse(G, pPenMagicMajor, missilex-3, missiley-3, majorDotSize, majorDotSize/2)
                        case "MagicMinor": Gdip_DrawEllipse(G, pPenMagicMinor, missilex-3, missiley-3, minorDotSize, minorDotSize/2)
                    }
                }
                oldMissilex:=missilex
                oldMissiley:=missiley
            }
         }
        
        Gdip_DeletePen(pPenPhysicalMajor)
        Gdip_DeletePen(pPenPhysicalMinor)
        Gdip_DeletePen(pPenFireMajor)
        Gdip_DeletePen(pPenFireMinor)
        Gdip_DeletePen(pPenIceMajor)
        Gdip_DeletePen(pPenIceMinor)
        Gdip_DeletePen(pPenLightMajor)
        Gdip_DeletePen(pPenLightMinor)
        Gdip_DeletePen(pPenPoisonMajor)
        Gdip_DeletePen(pPenPoisonMinor)
        Gdip_DeletePen(pPenMagicMajor)
        Gdip_DeletePen(pPenMagicMinor)
    }

    ; draw portals
    if (settings["showPortals"]) {
        gameObjects := gameMemoryData["objects"]
        portalColor := "ff" . settings["portalColor"]
        portalColor := "ff" . settings["redPortalColor"]
        if (settings["centerMode"]) {
            pPen := Gdip_CreatePen("0xff" . settings["portalColor"], 6)
            pPenRed := Gdip_CreatePen("0xff" . settings["redPortalColor"], 6)
        } else {
            pPen := Gdip_CreatePen("0xff" . settings["portalColor"], 3)
            pPenRed := Gdip_CreatePen("0xff" . settings["redPortalColor"], 3)
        }
        for index, object in gameObjects
        {
            ;WriteLog(object["txtFileNo"] " " object["isRedPortal"])
            if (object["isPortal"]) {
                objectx := ((object["objectx"] - imageData["mapOffsetX"]) * serverScale) + padding
                objecty := ((object["objecty"] - imageData["mapOffsetY"]) * serverScale) + padding
                correctedPos := correctPos(settings, objectx, objecty, (Width/2), (Height/2), scaledWidth, scaledHeight, scale)
                objectx := correctedPos["x"]
                objecty := correctedPos["y"]
                
                ;Gdip_DrawString(G, text, hFont, hFormat, pBrush2, RectF)
                if (settings["centerMode"]) {
                    Gdip_DrawEllipse(G, pPen, objectx-6, objecty-25, 16, 32)
                } else {
                    Gdip_DrawEllipse(G, pPen, objectx-6, objecty-14, 9, 16)
                }
            }
            if (object["isRedPortal"]) {
                objectx := ((object["objectx"] - imageData["mapOffsetX"]) * serverScale) + padding
                objecty := ((object["objecty"] - imageData["mapOffsetY"]) * serverScale) + padding
                correctedPos := correctPos(settings, objectx, objecty, (Width/2), (Height/2), scaledWidth, scaledHeight, scale)
                objectx := correctedPos["x"]
                objecty := correctedPos["y"]
                if (settings["centerMode"]) {
                    ;Gdip_DrawString(G, text, hFont, hFormat, pBrush2, RectF)
                    Gdip_DrawEllipse(G, pPenRed, objectx-6, objecty-25, 16, 32)
                } else {
                    Gdip_DrawEllipse(G, pPenRed, objectx-6, objecty-14, 9, 16)
                }
            }
        }
        Gdip_DeletePen(pPen)    
        Gdip_DeletePen(pPenRed)
    }

    ; draw monsters
    if (settings["showNormalMobs"] or settings["showDeadMobs"] or settings["showUniqueMobs"] or settings["showBosses"]) {
        mobs := gameMemoryData["mobs"]
        normalMobColor := 0xff . settings["normalMobColor"] 
        uniqueMobColor := 0xff . settings["uniqueMobColor"] 
        bossColor := 0xff . settings["bossColor"] 
        deadColor := 0xff . settings["deadColor"] 
        mercColor := 0xcc . settings["mercColor"]
        deadDotSize := settings["deadDotSize"]     ; 2
        normalDotSize := settings["normalDotSize"] ; 5
        normalImmunitySize := settings["normalImmunitySize"]  ; 8
        uniqueDotSize := settings["uniqueDotSize"] ; 8
        uniqueImmunitySize := settings["uniqueImmunitySize"] ; 14
        bossDotSize := settings["bossDotSize"]     ; 5

        if (settings["centerMode"]) {
            deadDotSize := deadDotSize * (scale / 1.2)
            normalDotSize := normalDotSize * (scale / 1.2)
            normalImmunitySize := normalImmunitySize * (scale / 1.2)
            uniqueDotSize := uniqueDotSize * (scale / 1.2)
            uniqueImmunitySize := uniqueImmunitySize * (scale / 1.2)
            bossDotSize := bossDotSize * (scale / 1.2)
        }

        pPenNormal := Gdip_CreatePen(normalMobColor, normalDotSize * 0.7)
        pPenUnique := Gdip_CreatePen(uniqueMobColor, uniqueDotSize * 0.7)
        pPenBoss := Gdip_CreatePen(bossColor, bossDotSize)
        pPenDead := Gdip_CreatePen(deadColor, deadDotSize)
        pPenMerc := Gdip_CreatePen(mercColor, normalDotSize * 0.7)

        physicalImmuneColor := 0xff . settings["physicalImmuneColor"] 
        magicImmuneColor := 0xff . settings["magicImmuneColor"] 
        fireImmuneColor := 0xff . settings["fireImmuneColor"] 
        lightImmuneColor := 0xff . settings["lightImmuneColor"] 
        coldImmuneColor := 0xff . settings["coldImmuneColor"] 
        poisonImmuneColor := 0xff . settings["poisonImmuneColor"] 

        pPenPhysical := Gdip_CreatePen(physicalImmuneColor, normalDotSize)
        pPenMagic := Gdip_CreatePen(magicImmuneColor, normalDotSize)
        pPenFire := Gdip_CreatePen(fireImmuneColor, normalDotSize)
        pPenLight := Gdip_CreatePen(lightImmuneColor, normalDotSize)
        pPenCold := Gdip_CreatePen(coldImmuneColor, normalDotSize)
        pPenPoison := Gdip_CreatePen(poisonImmuneColor, normalDotSize)



        if (settings["showDeadMobs"]) {
            for index, mob in mobs
            {
                if (mob["mode"] == 0 or mob["mode"] == 12) { ; dead
                    mobx := ((mob["x"] - imageData["mapOffsetX"]) * serverScale) + padding
                    moby := ((mob["y"] - imageData["mapOffsetY"]) * serverScale) + padding
                    correctedPos := correctPos(settings, mobx, moby, (Width/2), (Height/2), scaledWidth, scaledHeight, scale)
                    mobx := correctedPos["x"]
                    moby := correctedPos["y"]
                    Gdip_DrawEllipse(G, pPenDead, mobx-(deadDotSize/2), moby-(deadDotSize/2), deadDotSize, deadDotSize/2)
                }
            }
        }
        
        if (settings["showNormalMobs"]) {
            for index, mob in mobs
            {
                mobx := ((mob["x"] - imageData["mapOffsetX"]) * serverScale) + padding
                moby := ((mob["y"] - imageData["mapOffsetY"]) * serverScale) + padding
                correctedPos := correctPos(settings, mobx, moby, (Width/2), (Height/2), scaledWidth, scaledHeight, scale)
                mobx := correctedPos["x"]
                moby := correctedPos["y"]

                ;WriteLog(mobx " " moby)
                if (mob["isUnique"] == 0) {
                    if (mob["mode"] != 0 and mob["mode"] != 12) { ; not dead
                        if (settings["showImmunities"]) {
                            immunities := mob["immunities"]
                            noImmunities := immunities["physical"] + immunities["magic"] + immunities["fire"] + immunities["light"] + immunities["cold"] + immunities["poison"]
                            sliceSize := 360 / noImmunities
                            angleDegrees := 90
                            dotAdjust := normalImmunitySize/2
                            if (immunities["physical"]) {
                                Gdip_DrawPie(G, pPenMagic, mobx-dotAdjust, moby-dotAdjust, normalImmunitySize, normalImmunitySize/2, angleDegrees, sliceSize)
                                angleDegrees := angleDegrees + sliceSize
                            }
                            if (immunities["magic"]) {
                                Gdip_DrawPie(G, pPenMagic, mobx-dotAdjust, moby-dotAdjust, normalImmunitySize, normalImmunitySize/2, angleDegrees, sliceSize)
                                angleDegrees := angleDegrees + sliceSize
                            }
                            if (immunities["fire"]) {
                                Gdip_DrawPie(G, pPenFire, mobx-dotAdjust, moby-dotAdjust, normalImmunitySize, normalImmunitySize/2, angleDegrees, sliceSize)
                                angleDegrees := angleDegrees + sliceSize
                            }
                            if (immunities["light"]) {
                                Gdip_DrawPie(G, pPenLight, mobx-dotAdjust, moby-dotAdjust, normalImmunitySize, normalImmunitySize/2, angleDegrees, sliceSize)
                                angleDegrees := angleDegrees + sliceSize
                            }
                            if (immunities["cold"]) {
                                Gdip_DrawPie(G, pPenCold, mobx-dotAdjust, moby-dotAdjust, normalImmunitySize, normalImmunitySize/2, angleDegrees, sliceSize)
                                angleDegrees := angleDegrees + sliceSize
                            }
                            if (immunities["poison"]) {
                                Gdip_DrawPie(G, pPenPoison, mobx-dotAdjust, moby-dotAdjust, normalImmunitySize, normalImmunitySize/2,angleDegrees, sliceSize)
                                angleDegrees := angleDegrees + sliceSize
                            }
                        }
                        
                        if (!mob["isMerc"]) {
                            Gdip_DrawEllipse(G, pPenNormal, mobx-(normalDotSize/2), moby-(normalDotSize/1.5), normalDotSize, normalDotSize/2)
                        } else if (settings["showMercs"]) {
                            Gdip_DrawEllipse(G, pPenMerc, mobx-(normalDotSize/2), moby-(normalDotSize/1.5), normalDotSize, normalDotSize/2)
                        }
                    }
                    
                }
            }
        }

        ; having this in a separate loop forces it to be drawn on top
        for index, mob in mobs
        {
            
            mobx := ((mob["x"] - imageData["mapOffsetX"]) * serverScale) + padding
            moby := ((mob["y"] - imageData["mapOffsetY"]) * serverScale) + padding
            correctedPos := correctPos(settings, mobx, moby, (Width/2), (Height/2), scaledWidth, scaledHeight, scale)
            mobx := correctedPos["x"]
            moby := correctedPos["y"]
            if (mob["isBoss"]) {
                if (settings["showBosses"]) {
                    if (mob["mode"] != 0 and mob["mode"] != 12) {
                        ;WriteLog("Boss: " mob["textTitle"])
                        textx := mobx-(bossDotSize/2) - 75
                        texty := moby-(bossDotSize/2) - 100
                        bossTextColor := "ff" . settings["bossColor"] 
                        Options = x%textx% y%texty% Center vBottom cffff0000 r8 s24
                        Gdip_TextToGraphics(G, mob["textTitle"], Options, diabloFont, 160, 100)
                        Gdip_DrawEllipse(G, pPenBoss, mobx-(bossDotSize/2), moby-(bossDotSize/2), bossDotSize, bossDotSize/2)
                    }
                }
            }
            else if (mob["isUnique"]) {
                if (settings["showUniqueMobs"]) {
                    if (mob["mode"] != 0 and mob["mode"] != 12) { ; not dead
                        ;WriteLog("Unique: " mob["textTitle"])
                        
                        if (settings["showImmunities"]) {
                            immunities := mob["immunities"]
                            noImmunities := immunities["physical"] + immunities["magic"] + immunities["fire"] + immunities["light"] + immunities["cold"] + immunities["poison"]
                            sliceSize := 360 / noImmunities
                            angleDegrees := 90
                            ;WriteLog(mob["txtFileNo"] " " immunities["fire"] immunities["light"] immunities["cold"] immunities["poison"])
                            ;txtFileNo := mob["txtFileNo"]
                            ;WriteLog("noImmunities: " noImmunities ", txtFileNo: " txtFileNo ", " immunities["physical"] immunities["magic"] immunities["fire"] immunities["light"] immunities["cold"] immunities["poison"])
                            if (immunities["physical"]) {
                                
                                Gdip_DrawPie(G, pPenPhysical, mobx-(uniqueImmunitySize/2), moby-(uniqueImmunitySize/2), uniqueImmunitySize, uniqueImmunitySize/2, angleDegrees, sliceSize)
                                angleDegrees := angleDegrees + sliceSize
                            }
                            if (immunities["magic"]) {
                                Gdip_DrawPie(G, pPenMagic, mobx-(uniqueImmunitySize/2), moby-(uniqueImmunitySize/2), uniqueImmunitySize, uniqueImmunitySize/2, angleDegrees, sliceSize)
                                angleDegrees := angleDegrees + sliceSize
                            }
                            if (immunities["fire"]) {
                                Gdip_DrawPie(G, pPenFire, mobx-(uniqueImmunitySize/2), moby-(uniqueImmunitySize/2), uniqueImmunitySize, uniqueImmunitySize/2, angleDegrees, sliceSize)
                                angleDegrees := angleDegrees + sliceSize
                            }
                            if (immunities["light"]) {
                                Gdip_DrawPie(G, pPenLight, mobx-(uniqueImmunitySize/2), moby-(uniqueImmunitySize/2), uniqueImmunitySize, uniqueImmunitySize/2, angleDegrees, sliceSize)
                                angleDegrees := angleDegrees + sliceSize
                            }
                            if (immunities["cold"]) {
                                Gdip_DrawPie(G, pPenCold, mobx-(uniqueImmunitySize/2), moby-(uniqueImmunitySize/2), uniqueImmunitySize, uniqueImmunitySize/2, angleDegrees, sliceSize)
                                angleDegrees := angleDegrees + sliceSize
                            }
                            if (immunities["poison"]) {
                                Gdip_DrawPie(G, pPenPoison, mobx-(uniqueImmunitySize/2), moby-(uniqueImmunitySize/2), uniqueImmunitySize, uniqueImmunitySize/2, angleDegrees, sliceSize)
                                angleDegrees := angleDegrees + sliceSize
                            }
                        }
                        Gdip_DrawEllipse(G, pPenUnique, mobx-(uniqueDotSize/2), moby-(uniqueDotSize/1.5), uniqueDotSize, uniqueDotSize/2)
                    }
                }
            }
        }
        Gdip_DeletePen(pPenPhysical)
        Gdip_DeletePen(pPenMagic)
        Gdip_DeletePen(pPenFire)
        Gdip_DeletePen(pPenLight)
        Gdip_DeletePen(pPenCold)
        Gdip_DeletePen(pPenPoison)

        Gdip_DeletePen(pPenBoss)
        Gdip_DeletePen(pPenNormal)
        Gdip_DeletePen(pPenUnique)
        Gdip_DeletePen(pPenDead)
        Gdip_DeletePen(pPenMerc)
    }

    ; draw lines
    if (settings["showWaypointLine"] or settings["showNextExitLine"] or settings["showBossLine"]) {
        ; draw way point line
        if (settings["showWaypointLine"]) {
            ;WriteLog(settings["showWaypointLine"])
            waypointHeader := imageData["waypoint"]
            if (waypointHeader) {
                wparray := StrSplit(waypointHeader, ",")
                waypointX := (wparray[1] * serverScale) + padding
                wayPointY := (wparray[2] * serverScale) + padding
                correctedPos := correctPos(settings, waypointX, wayPointY, (Width/2), (Height/2), scaledWidth, scaledHeight, scale)
                waypointX := correctedPos["x"]
                wayPointY := correctedPos["y"]
                pPen := Gdip_CreatePen(0x55ffFF00, 3)
                Gdip_DrawLine(G, pPen, xPosDot, yPosDot, waypointX, wayPointY)
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
                    exitX := correctedPos["x"]
                    exitY := correctedPos["y"]

                    ; only draw the line if it's a 'next' exit
                    if (isNextExit(gameMemoryData["levelNo"]) == exitArray[1]) {
                        pPen := Gdip_CreatePen(0x55FF00FF, 3)
                        Gdip_DrawLine(G, pPen, xPosDot, yPosDot, exitX, exitY)
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
                bossX := correctedPos["x"]
                bossY := correctedPos["y"]

                pPen := Gdip_CreatePen(0x55FF0000, 3)
                Gdip_DrawLine(G, pPen, xPosDot, yPosDot, bossX, bossY)
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
                    questX := correctedPos["x"]
                    questY := correctedPos["y"]

                    pPen := Gdip_CreatePen(0x5500FF00, 3)
                    Gdip_DrawLine(G, pPen, xPosDot, yPosDot, questX, questY)
                    Gdip_DeletePen(pPen)
                }
            }
        }
    }

    ; draw other players
    if (settings["showOtherPlayers"]) {
        otherPlayers := gameMemoryData["otherPlayers"]
        pPen := Gdip_CreatePen(0xff00AA00, 4)
        for index, player in otherPlayers
        {
            
            if (gameMemoryData["playerName"] != player["playerName"]) {
                ;WriteLog(gameMemoryData["playerName"] " " player["playerName"])
                playerx := ((player["x"] - imageData["mapOffsetX"]) * serverScale) + padding
                playery := ((player["y"] - imageData["mapOffsetY"]) * serverScale) + padding
                correctedPos := correctPos(settings, playerx, playery, (Width/2), (Height/2), scaledWidth, scaledHeight, scale)
                playerx := correctedPos["x"]
                playery := correctedPos["y"]
                if (settings["showOtherPlayerNames"]) {
                    textx := playerx-2 - 75
                    texty := playery-2 - 100
                    Options = x%textx% y%texty% Center vBottom cff00AA00 r8 s24
                    Gdip_TextToGraphics(G, player["playerName"], Options, diabloFont, 160, 100)
                }
                Gdip_DrawRectangle(G, pPen, playerx-2, playery-2, 4, 4)
            }
        }
        Gdip_DeletePen(pPen)    
    }

    ; show item alerts
    if (settings["showUniqueAlerts"] or settings["showSetItemAlerts"] or settings["showRuneAlerts"] or settings["showJewelAlerts"] or settings["showCharmAlerts"]) {

        ; draw item alerts
        pItemPen2 := Gdip_CreatePen(0xCCFFFFFF, 8)

        items := gameMemoryData["items"]
        for index, item in items
        {
            itemx := ((item.itemx - imageData["mapOffsetX"]) * serverScale) + padding
            itemy := ((item.itemy - imageData["mapOffsetY"]) * serverScale) + padding
            correctedPos := correctPos(settings, itemx, itemy, (Width/2), (Height/2), scaledWidth, scaledHeight, scale)
            itemx := correctedPos["x"]
            itemy := correctedPos["y"]
            alert := itemAlertList.findAlert(item)
            ;WriteLog(item.quality " " item.name " matched alert " alert.name)
            if (alert) {
                if (alert.speak) {
                    announceItem(settings, item, alert)
                }
                pItemPen := Gdip_CreatePen(alert.color, 12)
                ticktock := uiData["ticktock"]
                if (ticktock) {
                    Gdip_DrawEllipse(G, pItemPen, itemx-2, itemy-2, 12, 12)
                } else {
                    Gdip_DrawEllipse(G, pItemPen2, itemx, itemy, 8, 8)
                }
                Gdip_DeletePen(pItemPen)
            }
        }
        Gdip_DeletePen(pItemPen2)
    }

    ; draw Shrines
    if (settings["showShrines"]) {
        gameObjects := gameMemoryData["objects"]
        shrineColor := "ff" . settings["shrineColor"]
        shrineTextSize := settings["shrineTextSize"]
        pPen := Gdip_CreatePen("0xff" . settings["shrineColor"], 4)
        for index, object in gameObjects
        {
            if (object["isShrine"]) {
                isShrineAlreadySeen := 0
                for index, oldShrine in shrines
                {
                    if (oldShrine["objectx"] == object["objectx"] and oldShrine["objecty"] == object["objecty"] and oldShrine["levelNo"] == object["levelNo"]) {
                        ; already seen
                        isShrineAlreadySeen := 1
                    }
                }
                if (!isShrineAlreadySeen) {
                    shrines.push(object)
                }
            }
        }
        for index, object in shrines
        {
            if (object["levelNo"] == gameMemoryData["levelNo"]) {
                
                objectx := ((object["objectx"] - imageData["mapOffsetX"]) * serverScale) + padding
                objecty := ((object["objecty"] - imageData["mapOffsetY"]) * serverScale) + padding
                correctedPos := correctPos(settings, objectx, objecty, (Width/2), (Height/2), scaledWidth, scaledHeight, scale)
                objectx := correctedPos["x"]
                objecty := correctedPos["y"]
                shrineType := object["shrineType"]
                textx := objectx - 100
                texty := objecty - 107
                Options = x%textx% y%texty% Center vBottom c%shrineColor% r8 s%shrineTextSize%
                Gdip_TextToGraphics(G,shrineType, Options, diabloFont, 200, 100)
                Gdip_DrawRectangle(G, pPen, objectx-2, objecty-2, 2.5, 2)
            }
        }
        Gdip_DeletePen(pPen)    
    }

    if (!settings["centerMode"] or settings["showPlayerDotCenter"]) {
        ; draw player
        pPen := Gdip_CreatePen(0xff00FF00, 6)
        ;WriteLog(xPosDot " " yPosDot " " midW " " midH " " scaledWidth " " scaledHeight " " scale " " newPos["x"] " " newPos["y"])
        Gdip_DrawRectangle(G, pPen, xPosDot-3, (yPosDot)-3 , 6, 6)
        ; Gdip_DrawRectangle(G, pPen, 0, 0, scaledWidth, scaledHeight) ;outline for whole map used for troubleshooting
        Gdip_DeletePen(pPen)
    }

    if (settings["centerMode"]) {
        WinGetPos, windowLeftMargin, windowTopMargin , gameWidth, gameHeight, %gameWindowId% 
        leftMargin := (gameWidth/2) - xPosDot + (settings["centerModeXoffset"] /2)
        topMargin := (gameHeight/2) - yPosDot + (settings["centerModeYoffset"] /2)
        regionWidth := gameWidth
        regionHeight := gameHeight
        regionX := 0 - leftMargin
        regionY := 0 - topMargin
        if (leftMargin > 0) {
            regionX := windowLeftMargin
            regionWidth := gameWidth - leftMargin + windowLeftMargin
        }
        if (topMargin > 0) {
            regionY := windowTopMargin
            regionHeight := gameHeight - topMargin + windowTopMargin
        }
        ;ToolTip % "`n`n`n`n" regionX " " regionY " " regionWidth " " regionHeight
        WinSet, Region, %regionX%-%regionY% W%regionWidth% H%regionHeight%, ahk_id %mapHwnd1%
        WinSet, Region, %regionX%-%regionY% W%regionWidth% H%regionHeight%, ahk_id %unitHwnd1%
        UpdateLayeredWindow(unitHwnd1, hdc, , , scaledWidth, scaledHeight)
        Gdip_GraphicsClear( G )
    } else {
        WinGetPos, windowLeftMargin, windowTopMargin , gameWidth, gameHeight, %gameWindowId% 
        WinMove, ahk_id %mapHwnd1%,, windowLeftMargin+leftMargin, windowTopMargin+topMargin
        WinMove, ahk_id %unitHwnd1%,, windowLeftMargin+leftMargin, windowTopMargin+topMargin
        WinSet, Region, , ahk_id %mapHwnd1%
        WinSet, Region, , ahk_id %unitHwnd1%
        UpdateLayeredWindow(unitHwnd1, hdc, , , scaledWidth, scaledHeight)
        Gdip_GraphicsClear( G )
    }

    ElapsedTime := A_TickCount - StartTime
    ;ToolTip % "`n`n`n`n" ElapsedTime
    ;WriteLog("Draw players " ElapsedTime " ms taken")

    
}

isNextExit(currentLvl) {
    switch currentLvl
    {
        case "2": return "8"
        case "3": return "9"
        case "4": return "10"
        case "6": return "20"
        case "7": return "16"
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
        case "118": return "119"
        case "122": return "123"
        case "123": return "124"
        case "128": return "129"
        case "129": return "130"
        case "130": return "131"
    }
    return
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
    distance := getDistanceFromCoords(xPosDot, yPosDot, centerX, centerY) * scale
    newPos := getPosFromAngle((RWidth/2),(RHeight/2),distance,newAngle)
    newPos["y"] := (RHeight/2) + ((RHeight/2) - newPos["y"]) /2
    return newPos
}


findAngle(xPosDot, yPosDot, midW, midH) {
    Pi := 4 * ATan(1)
    Conversion := -180 / Pi  ; Radians to deg.
    Angle2 := DllCall("msvcrt.dll\atan2", "Double", yPosDot-midH, "Double", xPosDot-midW, "CDECL Double") * Conversion
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


announceItem(settings, item, alert) {
    if (settings["allowTextToSpeech"] or settings["allowItemDropSounds"]) {
        if (!hasVal(seenItems, item.getHash())) {
            ; seen item for the first time
            if (settings["allowTextToSpeech"]) {
                volume := settings["textToSpeechVolume"]
                pitch := settings["textToSpeechPitch"]
                speed := settings["textToSpeechSpeed"]
                oSpVoice.Speak("<pitch absmiddle=""" pitch """><rate absspeed=""" speed """><volume level=""" volume """>" item.getTextToSpeech() "</volume></rate></pitch>", 1)
            }
            if (settings["allowItemDropSounds"]) {
                if (alert.soundfile) {
                    soundfile := alert.soundfile
                    SoundPlay, %soundfile%
                }
            }
            seenItems.push(item.getHash())
        }
    }
}

hasVal(haystack, needle) {
	for index, value in haystack
		if (value = needle)
			return index
	if !IsObject(haystack)
		throw Exception("Bad haystack!", -1, haystack)
	return 0
}