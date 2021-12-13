#SingleInstance, Force
SendMode Input
SetWorkingDir, %A_ScriptDir%

ShowPlayer(settings, unitHwnd1, mapData, gameMemoryData, uiData) {
    StartTime := A_TickCount

    mapGuiWidth:= settings["maxWidth"]
    scale:= settings["scale"]
    leftMargin:= settings["leftMargin"]
    topMargin:= settings["topMargin"]
    Width := uiData["sizeWidth"]
    Height := uiData["sizeHeight"]
    levelNo:= gameMemoryData["levelNo"]
    IniRead, levelScale, mapconfig.ini, %levelNo%, scale, 1.0
    scale := levelScale * scale
    IniRead, levelxmargin, mapconfig.ini, %levelNo%, x, 0
    IniRead, levelymargin, mapconfig.ini, %levelNo%, y, 0
    leftMargin := leftMargin + levelxmargin
    topMargin := topMargin + levelymargin
    ; WriteLog("maxWidth := " maxWidth)
    ; WriteLog("leftMargin := " leftMargin)
    ; WriteLog("topMargin := " topMargin)
    ; WriteLog(mapData["leftTrimmed"])
    ; WriteLog(mapData["topTrimmed"])
    ; WriteLog(mapData["mapOffsetX"])
    ; WriteLog(mapData["mapOffsety"])
    ; WriteLog(mapData["mapwidth"])
    ; WriteLog(mapData["mapheight"])

    serverScale := 2 
    Angle := 45
    opacity := 0.9
    padding := 150

    If !pToken := Gdip_Startup()
    {
        MsgBox "Gdiplus failed to start. Please ensure you have gdiplus on your system"
        ExitApp
    }
    pBitmap := Gdip_CreateBitmap(Width, Height)
    If !pBitmap
    {
        WriteLog("ERROR: Could not create bitmap to show players/mobs")
        ExitApp
    }

    Gdip_GetRotatedDimensions(Width, Height, Angle, RWidth, RHeight)
    Gdip_GetRotatedTranslation(Width, Height, Angle, xTranslation, yTranslation)

    scaledWidth := (RWidth * scale)
    scaledHeight := (RHeight * 0.5) * scale
    rotatedWidth := RWidth * scale
    rotatedHeight := RHeight * scale

    ; get relative position of player in world
    ; xpos is absolute world pos in game
    ; each map has offset x and y which is absolute world position
    xPosDot := ((gameMemoryData["xPos"] - mapData["mapOffsetX"]) * serverScale) + padding
    yPosDot := ((gameMemoryData["yPos"] - mapData["mapOffsetY"]) * serverScale) + padding
    correctedPos := findNewPos(xPosDot, yPosDot, (Width/2), (Height/2), scaledWidth, scaledHeight, scale)
    xPosDot := correctedPos["x"]
    yPosDot := correctedPos["y"]


    hbm := CreateDIBSection(rotatedWidth, rotatedHeight)
    hdc := CreateCompatibleDC()
    obm := SelectObject(hdc, hbm)
    ;G := Gdip_GraphicsFromImage(pBitmap)
    
    G := Gdip_GraphicsFromHDC(hdc)
    Gdip_SetInterpolationMode(G, 7)
    Gdip_SetSmoothingMode(G, 6)


    ; draw monsters
    mobs := gameMemoryData["mobs"]
    normalMobColor := 0xff . settings["normalMobColor"] 
    uniqueMobColor := 0xff . settings["uniqueMobColor"] 
    bossColor := 0xff . settings["bossColor"] 
    deadColor := 0xff . settings["deadColor"] 

    pPenNormal := Gdip_CreatePen(normalMobColor, 3)
    pPenUnique := Gdip_CreatePen(uniqueMobColor, 5)
    pPenBoss := Gdip_CreatePen(bossColor, 6)
    pPenDead := Gdip_CreatePen(deadColor, 2)

    physicalImmuneColor := 0xff . settings["physicalImmuneColor"] 
    magicImmuneColor := 0xff . settings["magicImmuneColor"] 
    fireImmuneColor := 0xff . settings["fireImmuneColor"] 
    lightImmuneColor := 0xff . settings["lightImmuneColor"] 
    coldImmuneColor := 0xff . settings["coldImmuneColor"] 
    poisonImmuneColor := 0xff . settings["poisonImmuneColor"] 

    pPenPhysical := Gdip_CreatePen(physicalImmuneColor, 4)
    pPenMagic := Gdip_CreatePen(magicImmuneColor, 4)
    pPenFire := Gdip_CreatePen(fireImmuneColor, 4)
    pPenLight := Gdip_CreatePen(lightImmuneColor, 4)
    pPenCold := Gdip_CreatePen(coldImmuneColor, 4)
    pPenPoison := Gdip_CreatePen(poisonImmuneColor, 4)

    if (settings["showDeadMobs"]) {
        for index, mob in mobs
        {
            if (mob["mode"] == 0 or mob["mode"] == 12) { ; dead
                mobx := ((mob["x"] - mapData["mapOffsetX"]) * serverScale) + padding
                moby := ((mob["y"] - mapData["mapOffsetY"]) * serverScale) + padding
                correctedPos := findNewPos(mobx, moby, (Width/2), (Height/2), scaledWidth, scaledHeight, scale)
                mobx := correctedPos["x"]
                moby := correctedPos["y"]
                Gdip_DrawEllipse(G, pPenDead, mobx-1, moby-1, 2, 2/2)
            }
        }
    }
    
    if (settings["showNormalMobs"]) {
        for index, mob in mobs
        {
            mobx := ((mob["x"] - mapData["mapOffsetX"]) * serverScale) + padding
            moby := ((mob["y"] - mapData["mapOffsetY"]) * serverScale) + padding
            correctedPos := findNewPos(mobx, moby, (Width/2), (Height/2), scaledWidth, scaledHeight, scale)
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
                        dotSize := 4
                        dotAdjust := 1.2
                        if (immunities["physical"]) {
                            Gdip_DrawPie(G, pPenMagic, mobx-dotAdjust, moby-dotAdjust, dotSize, dotSize/2, angleDegrees, sliceSize)
                            angleDegrees := angleDegrees + sliceSize
                        }
                        if (immunities["magic"]) {
                            Gdip_DrawPie(G, pPenMagic, mobx-dotAdjust, moby-dotAdjust, dotSize, dotSize/2, angleDegrees, sliceSize)
                            angleDegrees := angleDegrees + sliceSize
                        }
                        if (immunities["fire"]) {
                            Gdip_DrawPie(G, pPenFire, mobx-dotAdjust, moby-dotAdjust, dotSize, dotSize/2, angleDegrees, sliceSize)
                            angleDegrees := angleDegrees + sliceSize
                        }
                        if (immunities["light"]) {
                            Gdip_DrawPie(G, pPenLight, mobx-dotAdjust, moby-dotAdjust, dotSize, dotSize/2, angleDegrees, sliceSize)
                            angleDegrees := angleDegrees + sliceSize
                        }
                        if (immunities["cold"]) {
                            Gdip_DrawPie(G, pPenCold, mobx-dotAdjust, moby-dotAdjust, dotSize, dotSize/2, angleDegrees, sliceSize)
                            angleDegrees := angleDegrees + sliceSize
                        }
                        if (immunities["poison"]) {
                            Gdip_DrawPie(G, pPenPoison, mobx-dotAdjust, moby-dotAdjust, dotSize, dotSize/2,angleDegrees, sliceSize)
                            angleDegrees := angleDegrees + sliceSize
                        }
                    }
                    
                    Gdip_DrawEllipse(G, pPenNormal, mobx-1, moby-1, 2.5, 2.5/2)

                }
                
            }
        }
    }

    ; having this in a separate loop forces it to be drawn on top
    for index, mob in mobs
    {
        
        mobx := ((mob["x"] - mapData["mapOffsetX"]) * serverScale) + padding
        moby := ((mob["y"] - mapData["mapOffsetY"]) * serverScale) + padding
        correctedPos := findNewPos(mobx, moby, (Width/2), (Height/2), scaledWidth, scaledHeight, scale)
        mobx := correctedPos["x"]
        moby := correctedPos["y"]
        if (mob["isBoss"]) {
            if (settings["showBosses"]) {
                if (mob["mode"] != 0 and mob["mode"] != 12) {
                    ;WriteLog("Boss: " mob["textTitle"])
                    Gdip_DrawEllipse(G, pPenBoss, mobx-3, moby-3, 6, 6/2)
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
                        dotSize := 11
                        dotAdjust := 5
                        ;WriteLog(mob["txtFileNo"] " " immunities["fire"] immunities["light"] immunities["cold"] immunities["poison"])
                        txtFileNo := mob["txtFileNo"]
                        ;WriteLog("noImmunities: " noImmunities ", txtFileNo: " txtFileNo ", " immunities["physical"] immunities["magic"] immunities["fire"] immunities["light"] immunities["cold"] immunities["poison"])
                        if (immunities["physical"]) {
                            
                            Gdip_DrawPie(G, pPenPhysical, mobx-dotAdjust, moby-dotAdjust, dotSize, dotSize/2, angleDegrees, sliceSize)
                            angleDegrees := angleDegrees + sliceSize
                        }
                        if (immunities["magic"]) {
                            Gdip_DrawPie(G, pPenMagic, mobx-dotAdjust, moby-dotAdjust, dotSize, dotSize/2, angleDegrees, sliceSize)
                            angleDegrees := angleDegrees + sliceSize
                        }
                        if (immunities["fire"]) {
                            Gdip_DrawPie(G, pPenFire, mobx-dotAdjust, moby-dotAdjust, dotSize, dotSize/2, angleDegrees, sliceSize)
                            angleDegrees := angleDegrees + sliceSize
                        }
                        if (immunities["light"]) {
                            Gdip_DrawPie(G, pPenLight, mobx-dotAdjust, moby-dotAdjust, dotSize, dotSize/2, angleDegrees, sliceSize)
                            angleDegrees := angleDegrees + sliceSize
                        }
                        if (immunities["cold"]) {
                            Gdip_DrawPie(G, pPenCold, mobx-dotAdjust, moby-dotAdjust, dotSize, dotSize/2, angleDegrees, sliceSize)
                            angleDegrees := angleDegrees + sliceSize
                        }
                        if (immunities["poison"]) {
                            Gdip_DrawPie(G, pPenPoison, mobx-dotAdjust, moby-dotAdjust, dotSize, dotSize/2, angleDegrees, sliceSize)
                            angleDegrees := angleDegrees + sliceSize
                        }
                    }
                    Gdip_DrawEllipse(G, pPenUnique, mobx-3, moby-3, 5, 5/2)
                }
            }
        }
    }
    
    Gdip_DeletePen(pPenBoss)
    Gdip_DeletePen(pPenNormal)
    Gdip_DeletePen(pPenUnique)
    Gdip_DeletePen(pPenDead)
    
    Gdip_DeletePen(pPenPhysical)
    Gdip_DeletePen(pPenMagic)
    Gdip_DeletePen(pPenFire)
    Gdip_DeletePen(pPenLight)
    Gdip_DeletePen(pPenCold)
    Gdip_DeletePen(pPenPoison)

    
    ; draw way point line
    if (settings["showWaypointLine"]) {
        ;WriteLog(settings["showWaypointLine"])
        waypointHeader := mapData["waypoint"]
        if (waypointHeader) {
            wparray := StrSplit(waypointHeader, ",")
            waypointX := (wparray[1] * serverScale) + padding
            wayPointY := (wparray[2] * serverScale) + padding
            correctedPos := findNewPos(waypointX, wayPointY, (Width/2), (Height/2), scaledWidth, scaledHeight, scale)
            waypointX := correctedPos["x"]
            wayPointY := correctedPos["y"]
            pPen := Gdip_CreatePen(0x55ffFF00, 3)
            Gdip_DrawLine(G, pPen, xPosDot, yPosDot, waypointX, wayPointY)
            Gdip_DeletePen(pPen)
        }
    }

    ; ;draw exit lines
    if (settings["showNextExitLine"]) {
        exitsHeader := mapData["exits"]
        if (exitsHeader) {
            Loop, parse, exitsHeader, `|
            {
                exitArray := StrSplit(A_LoopField, ",")
                ;exitArray[1] ; id of exit
                ;exitArray[2] ; name of exit
                exitX := (exitArray[3] * serverScale) + padding
                exitY := (exitArray[4] * serverScale) + padding
                correctedPos := findNewPos(exitX, exitY, (Width/2), (Height/2), scaledWidth, scaledHeight, scale)
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
        bossHeader := mapData["bosses"]
        if (bossHeader) {
            bossArray := StrSplit(bossHeader, ",")
            ;bossArray[1] ; name of boss
            bossX := (bossArray[2] * serverScale) + padding
            bossY := (bossArray[3] * serverScale) + padding
            correctedPos := findNewPos(bossX, bossY, (Width/2), (Height/2), scaledWidth, scaledHeight, scale)
            bossX := correctedPos["x"]
            bossY := correctedPos["y"]

            ; only draw the line if it's a 'next' exit
            pPen := Gdip_CreatePen(0xFFFF0000, 3)
            Gdip_DrawLine(G, pPen, xPosDot, yPosDot, bossX, bossY)
            Gdip_DeletePen(pPen)
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
                playerx := ((player["x"] - mapData["mapOffsetX"]) * serverScale) + padding
                playery := ((player["y"] - mapData["mapOffsetY"]) * serverScale) + padding
                correctedPos := findNewPos(playerx, playery, (Width/2), (Height/2), scaledWidth, scaledHeight, scale)
                playerx := correctedPos["x"]
                playery := correctedPos["y"]

                Gdip_DrawRectangle(G, pPen, playerx-2, playery-2, 4, 4)
            }
        }
        Gdip_DeletePen(pPen)    
    }

    ; draw items
    ;runeColor := 0xff . settings["runeColor"] 
    runeColor := 0xcc . settings["runeItemColor"] 
    uniqueColor := 0xcc . settings["uniqueItemColor"] 
    setColor := 0xcc . settings["setItemColor"] 
    pPenRune := Gdip_CreatePen(runeColor, 12)
    pPenRune2 := Gdip_CreatePen(0xccffffff, 8)
    pPenUnique := Gdip_CreatePen(uniqueColor, 12)
    pPenUnique2 := Gdip_CreatePen(0xccffffff, 8)
    pPenSetItem := Gdip_CreatePen(setColor, 12)
    pPenSetItem2 := Gdip_CreatePen(0xccffffff, 8)
    ; show items
    if (settings["showItems"]) {
        items := gameMemoryData["items"]
        for index, item in items
        {
            itemx := ((item["itemx"] - mapData["mapOffsetX"]) * serverScale) + padding
            itemy := ((item["itemy"] - mapData["mapOffsetY"]) * serverScale) + padding
            correctedPos := findNewPos(itemx, itemy, (Width/2), (Height/2), scaledWidth, scaledHeight, scale)
            itemx := correctedPos["x"]
            itemy := correctedPos["y"]
            if (item["isRune"] == 1) { ; rune
                ticktock := uiData["ticktock"]
                if (ticktock) {
                    Gdip_DrawEllipse(G, pPenRune, itemx-2, itemy-1, 12, 12/2)
                } else {
                    Gdip_DrawEllipse(G, pPenRune2, itemx, itemy, 8, 8/2)
                }
            }

            if (item["itemQuality"] == 7) { ; unique
                ticktock := uiData["ticktock"]
                if (ticktock) {
                    Gdip_DrawEllipse(G, pPenUnique, itemx-2, itemy-1, 12, 12/2)
                } else {
                    Gdip_DrawEllipse(G, pPenUnique2, itemx, itemy, 8, 8/2)
                }
            }

            if (item["itemQuality"] == 5) { ; set
                ticktock := uiData["ticktock"]
                if (ticktock) {
                    Gdip_DrawEllipse(G, pPenSetItem, itemx-2, itemy-1, 12, 12/2)
                } else {
                    Gdip_DrawEllipse(G, pPenSetItem2, itemx, itemy, 8, 8/2)
                }
            }
        }
    }
    Gdip_DeletePen(pPenRune)
    Gdip_DeletePen(pPenRune2)
    Gdip_DeletePen(pPenUnique)
    Gdip_DeletePen(pPenUnique2)
    Gdip_DeletePen(pPenSetItem)
    Gdip_DeletePen(pPenSetItem2)

    ; draw player
    pPen := Gdip_CreatePen(0xff00FF00, 6)
    ;correctedPos := findNewPos(xPosDot, yPosDot, (Width/2), (Height/2), scaledWidth, scaledHeight, scale)
    ;WriteLog(xPosDot " " yPosDot " " midW " " midH " " scaledWidth " " scaledHeight " " scale " " newPos["x"] " " newPos["y"])
    Gdip_DrawRectangle(G, pPen, xPosDot-3, (yPosDot)-2 , 6, 6)
    ; Gdip_DrawRectangle(G, pPen, 0, 0, scaledWidth, scaledHeight) ;outline for whole map used for troubleshooting
    Gdip_DeletePen(pPen)

    Gdip_DrawImage(G, pBitmap, 0, 0, scaledWidth, scaledHeight, 0, 0, RWidth, RHeight, opacity)
    UpdateLayeredWindow(unitHwnd1, hdc, leftMargin, topMargin, rotatedWidth, rotatedHeight)

    ElapsedTime := A_TickCount - StartTime
    ;ToolTip % "`n`n`n`n" ElapsedTime
    ;WriteLog("Draw players " ElapsedTime " ms taken")
    
    SelectObject(hdc, obm)
    DeleteObject(hbm)
    DeleteDC(hdc)
    Gdip_DeleteGraphics(G)
    Gdip_DeleteGraphics(G2)
    Gdip_DisposeImage(pBitmap)
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
        case "113": return "112"
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