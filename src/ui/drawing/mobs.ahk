#SingleInstance, Force
SendMode Input
SetWorkingDir, %A_ScriptDir%

drawMonsters(G, settings, gameMemoryData, imageData, serverScale, scale, padding, Width, Height, scaledWidth, scaledHeight, centerLeftOffset, centerTopOffset) {
    mobs := gameMemoryData["mobs"]
    normalMobColor := 0xff . settings["normalMobColor"] 
    uniqueMobColor := 0xff . settings["uniqueMobColor"] 
    bossColor := 0xff . settings["bossColor"] 
    deadColor := 0x44 . settings["deadColor"] 
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
                mobx := correctedPos["x"] + centerLeftOffset
                moby := correctedPos["y"] + centerTopOffset
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
            mobx := correctedPos["x"] + centerLeftOffset
            moby := correctedPos["y"] + centerTopOffset

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
        mobx := correctedPos["x"] + centerLeftOffset
        moby := correctedPos["y"] + centerTopOffset
        if (mob["isBoss"]) {
            if (settings["showBosses"]) {
                if (mob["mode"] != 0 and mob["mode"] != 12) {
                    ;WriteLog("Boss: " mob["textTitle"])
                    textx := mobx-(bossDotSize/2) - 75
                    texty := moby-(bossDotSize/2) - 100
                    bossTextColor := "ff" . settings["bossColor"] 
                    Options = x%textx% y%texty% Center vBottom cffff0000 r8 s24
                    textx := textx + 2
                    texty := texty + 2
                    Options2 = x%textx% y%texty% Center vBottom cff000000 r8 s24
                    Gdip_TextToGraphics(G, mob["textTitle"], Options2, diabloFont, 160, 100)
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