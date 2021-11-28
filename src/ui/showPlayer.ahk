#SingleInstance, Force
SendMode Input
SetWorkingDir, %A_ScriptDir%
#Include %A_ScriptDir%\ui\image\Gdip_ResizeBitmap.ahk
#Include %A_ScriptDir%\ui\image\Gdip_RotateBitmap.ahk

ShowPlayer(settings, mapData, gameMemoryData, uiData) {
    StartTime := A_TickCount

    mapGuiWidth:= settings["maxWidth"]
    scale:= settings["scale"]
    leftMargin:= settings["leftMargin"]
    topMargin:= settings["topMargin"]

    ; WriteLog("maxWidth := " maxWidth)
    ; WriteLog("leftMargin := " leftMargin)
    ; WriteLog("topMargin := " topMargin)
    ; WriteLog(mapData["sFile"])
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

    ; get relative position of player in world
    ; xpos is absolute world pos in game
    ; each map has offset x and y which is absolute world position
    xPosDot := ((gameMemoryData["xPos"] - mapData["mapOffsetX"]) * serverScale) + padding
    yPosDot := ((gameMemoryData["yPos"] - mapData["mapOffsetY"]) * serverScale) + padding
    sFile := mapData["sFile"] ; downloaded map image
    Width := uiData["sizeWidth"]
    Height := uiData["sizeHeight"]

    If !pToken := Gdip_Startup()
    {
        MsgBox "Gdiplus failed to start. Please ensure you have gdiplus on your system"
        ExitApp
    }

    Gui, Units: -Caption +E0x20 +E0x80000 +LastFound +AlwaysOnTop +ToolWindow +OwnDialogs
    hwnd1 := WinExist()

    pBitmap := Gdip_CreateBitmap(Width, Height)
    If !pBitmap
    {
        WriteLog("ERROR: Could not load map image " sFile)
        ExitApp
    }

    Gdip_GetRotatedDimensions(Width, Height, Angle, RWidth, RHeight)
    Gdip_GetRotatedTranslation(Width, Height, Angle, xTranslation, yTranslation)

    scaledWidth := (RWidth * scale)
    scaleAdjust := 1 ; need to adjust the scale for oversized maps
    if (scaledWidth > mapGuiWidth) {
        scaleAdjust := mapGuiWidth / (RWidth * scale)
        scaledWidth := mapGuiWidth
        ;WriteLogDebug("OverSized map, reducing scale to " scale ", maxWidth set to " mapGuiWidth)
    }
    scaledHeight := (RHeight * 0.5) * scale * scaleAdjust
    rotatedWidth := RWidth * scale * scaleAdjust
    rotatedHeight := RHeight * scale * scaleAdjust

    hbm := CreateDIBSection(rotatedWidth, rotatedHeight)
    hdc := CreateCompatibleDC()
    obm := SelectObject(hdc, hbm)
    G := Gdip_GraphicsFromImage(pBitmap)

    ; draw monsters
    mobs := gameMemoryData["mobs"]
    normalMobColor := 0xff . settings["normalMobColor"] 
    uniqueMobColor := 0xff . settings["uniqueMobColor"] 
    bossColor := 0xff . settings["bossColor"] 
    pPenNormal := Gdip_CreatePen(normalMobColor, 3)
    pPenUnique := Gdip_CreatePen(uniqueMobColor, 5)
    pPenBoss := Gdip_CreatePen(bossColor, 6)
    pPenDead := Gdip_CreatePen(0xff000000, 2)


    pPenPhysical := Gdip_CreatePen(0xffCD853f, 4)
    pPenMagic := Gdip_CreatePen(0xffff8800, 4)
    pPenFire := Gdip_CreatePen(0xffFF0000, 4)
    pPenLight := Gdip_CreatePen(0xffFFFF00, 4)
    pPenCold := Gdip_CreatePen(0xff0000FF, 4)
    pPenPoison := Gdip_CreatePen(0xFF32CD32, 4)

    if (settings["showDeadMobs"]) {
        for index, mob in mobs
        {
            if (mob["mode"] == 0 or mob["mode"] == 12) { ; dead
                mobx := ((mob["x"] - mapData["mapOffsetX"]) * serverScale) + padding
                moby := ((mob["y"] - mapData["mapOffsetY"]) * serverScale) + padding
                Gdip_DrawEllipse(G, pPenDead, mobx-1, moby-1, 2, 2)
            }
        }
    }
    
    if (settings["showNormalMobs"]) {
        for index, mob in mobs
        {
            if (mob["isUnique"] == 0) {
                if (mob["mode"] != 0 and mob["mode"] != 12) { ; not dead
                    mobx := ((mob["x"] - mapData["mapOffsetX"]) * serverScale) + padding
                    moby := ((mob["y"] - mapData["mapOffsetY"]) * serverScale) + padding
                    if (settings["showImmunities"]) {
                        immunities := mob["immunities"]
                        noImmunities := immunities["physical"] + immunities["magic"] + immunities["fire"] + immunities["light"] + immunities["cold"] + immunities["poison"]
                        sliceSize := 360 / noImmunities
                        angleDegrees := 35
                        dotSize := 4
                        if (immunities["physical"]) {
                            Gdip_DrawPie(G, pPenMagic, mobx-2, moby-2, dotSize, dotSize, angleDegrees, sliceSize)
                            angleDegrees := angleDegrees + sliceSize
                        }
                        if (immunities["magic"]) {
                            Gdip_DrawPie(G, pPenMagic, mobx-2, moby-2, dotSize, dotSize, angleDegrees, sliceSize)
                            angleDegrees := angleDegrees + sliceSize
                        }
                        if (immunities["fire"]) {
                            Gdip_DrawPie(G, pPenFire, mobx-2, moby-2, dotSize, dotSize, angleDegrees, sliceSize)
                            angleDegrees := angleDegrees + sliceSize
                        }
                        if (immunities["light"]) {
                            Gdip_DrawPie(G, pPenLight, mobx-2, moby-2, dotSize, dotSize, angleDegrees, sliceSize)
                            angleDegrees := angleDegrees + sliceSize
                        }
                        if (immunities["cold"]) {
                            Gdip_DrawPie(G, pPenCold, mobx-2, moby-2, dotSize, dotSize, angleDegrees, sliceSize)
                            angleDegrees := angleDegrees + sliceSize
                        }
                        if (immunities["poison"]) {
                            Gdip_DrawPie(G, pPenPoison, mobx-2, moby-2, dotSize, dotSize,angleDegrees, sliceSize)
                            angleDegrees := angleDegrees + sliceSize
                        }
                    }
                    Gdip_DrawEllipse(G, pPenNormal, mobx-1, moby-1, 2.5, 2.5)

                }
                
            }
        }
    }

    ; having this in a separate loop forces it to be drawn on top
    for index, mob in mobs
    {
        if (mob["isBoss"]) {
            if (settings["showBosses"]) {
                if (mob["mode"] != 0 and mob["mode"] != 12) {
                    ;WriteLog("Boss: " mob["textTitle"])
                    mobx := ((mob["x"] - mapData["mapOffsetX"]) * serverScale) + padding
                    moby := ((mob["y"] - mapData["mapOffsetY"]) * serverScale) + padding
                    Gdip_DrawEllipse(G, pPenBoss, mobx-3, moby-3, 6, 6)
                }
            }
        }
        else if (mob["isUnique"]) {
            if (settings["showUniqueMobs"]) {
                if (mob["mode"] != 0 and mob["mode"] != 12) { ; not dead
                    ;WriteLog("Unique: " mob["textTitle"])
                    mobx := ((mob["x"] - mapData["mapOffsetX"]) * serverScale) + padding
                    moby := ((mob["y"] - mapData["mapOffsetY"]) * serverScale) + padding
                    if (settings["showImmunities"]) {
                        immunities := mob["immunities"]
                        noImmunities := immunities["physical"] + immunities["magic"] + immunities["fire"] + immunities["light"] + immunities["cold"] + immunities["poison"]
                        sliceSize := 360 / noImmunities
                        angleDegrees := 40
                        dotSize := 10
                        ;WriteLog(mob["txtFileNo"] " " immunities["fire"] immunities["light"] immunities["cold"] immunities["poison"])
                        txtFileNo := mob["txtFileNo"]
                        ;WriteLog("noImmunities: " noImmunities ", txtFileNo: " txtFileNo ", " immunities["physical"] immunities["magic"] immunities["fire"] immunities["light"] immunities["cold"] immunities["poison"])
                        if (immunities["physical"]) {
                            Gdip_DrawPie(G, pPenPhysical, mobx-5, moby-5, dotSize, dotSize, angleDegrees, sliceSize)
                            angleDegrees := angleDegrees + sliceSize
                        }
                        if (immunities["magic"]) {
                            Gdip_DrawPie(G, pPenMagic, mobx-5, moby-5, dotSize, dotSize, angleDegrees, sliceSize)
                            angleDegrees := angleDegrees + sliceSize
                        }
                        if (immunities["fire"]) {
                            Gdip_DrawPie(G, pPenFire, mobx-5, moby-5, dotSize, dotSize, angleDegrees, sliceSize)
                            angleDegrees := angleDegrees + sliceSize
                        }
                        if (immunities["light"]) {
                            Gdip_DrawPie(G, pPenLight, mobx-5, moby-5, dotSize, dotSize, angleDegrees, sliceSize)
                            angleDegrees := angleDegrees + sliceSize
                        }
                        if (immunities["cold"]) {
                            Gdip_DrawPie(G, pPenCold, mobx-5, moby-5, dotSize, dotSize, angleDegrees, sliceSize)
                            angleDegrees := angleDegrees + sliceSize
                        }
                        if (immunities["poison"]) {
                            Gdip_DrawPie(G, pPenPoison, mobx-2, moby-2, dotSize, dotSize, angleDegrees, sliceSize)
                            angleDegrees := angleDegrees + sliceSize
                        }
                    }
                    Gdip_DrawEllipse(G, pPenUnique, mobx-3, moby-3, 5, 5)
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

                ; only draw the line if it's a 'next' exit
                if (isNextExit(gameMemoryData["levelNo"]) == exitArray[1]) {
                    pPen := Gdip_CreatePen(0x55FF00FF, 3)
                    Gdip_DrawLine(G, pPen, xPosDot, yPosDot, exitX, exitY)
                    Gdip_DeletePen(pPen)
                }
            }
        }
    }

    ; draw player
    pPen := Gdip_CreatePen(0xff00FF00, 6)
    Gdip_DrawRectangle(G, pPen, xPosDot-2, yPosDot-2, 6, 6)
    ;Gdip_DrawRectangle(G, pPen, 0, 0, Width, Height) ;outline for whole map used for troubleshooting
    Gdip_DeletePen(pPen)

    G2 := Gdip_GraphicsFromHDC(hdc)
    pBitmap := Gdip_RotateBitmap(pBitmap, Angle) ; rotates bitmap for 45 degrees. Disposes of pBitmap.

    Gdip_DrawImage(G2, pBitmap, 0, 0, scaledWidth, scaledHeight, 0, 0, RWidth, RHeight, opacity)
    UpdateLayeredWindow(hwnd1, hdc, leftMargin, topMargin, rotatedWidth, rotatedHeight)

    ElapsedTime := A_TickCount - StartTime
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