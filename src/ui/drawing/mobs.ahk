#SingleInstance, Force
SendMode Input
SetWorkingDir, %A_ScriptDir%

drawMonsters(ByRef unitsLayer, settings, gameMemoryData, imageData, serverScale, scale, padding, Width, Height, scaledWidth, scaledHeight, centerLeftOffset, centerTopOffset) {
    mobs := gameMemoryData["mobs"]

    if (settings["showDeadMobs"]) {
        for index, mob in mobs
        {
            if (mob["mode"] == 0 or mob["mode"] == 12) { ; dead
                mobx := ((mob["x"] - imageData["mapOffsetX"]) * serverScale) + padding
                moby := ((mob["y"] - imageData["mapOffsetY"]) * serverScale) + padding
                correctedPos := correctPos(settings, mobx, moby, (Width/2), (Height/2), scaledWidth, scaledHeight, scale)
                mobx := correctedPos["x"] + centerLeftOffset
                moby := correctedPos["y"] + centerTopOffset
                Gdip_DrawEllipse(unitsLayer.G, unitsLayer.pPenDead, mobx-(unitsLayer.deadDotSize/2), moby-(unitsLayer.deadDotSize/2), unitsLayer.deadDotSize, unitsLayer.deadDotSize/2)
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
                        dotAdjust := unitsLayer.normalImmunitySize/2
                        if (immunities["physical"]) {
                            Gdip_DrawPie(unitsLayer.G, unitsLayer.pPenPhysical, mobx-dotAdjust, moby-dotAdjust, unitsLayer.normalImmunitySize, unitsLayer.normalImmunitySize/2, angleDegrees, sliceSize)
                            angleDegrees := angleDegrees + sliceSize
                        }
                        if (immunities["magic"]) {
                            Gdip_DrawPie(unitsLayer.G, unitsLayer.pPenMagic, mobx-dotAdjust, moby-dotAdjust, unitsLayer.normalImmunitySize, unitsLayer.normalImmunitySize/2, angleDegrees, sliceSize)
                            angleDegrees := angleDegrees + sliceSize
                        }
                        if (immunities["fire"]) {
                            Gdip_DrawPie(unitsLayer.G, unitsLayer.pPenFire, mobx-dotAdjust, moby-dotAdjust, unitsLayer.normalImmunitySize, unitsLayer.normalImmunitySize/2, angleDegrees, sliceSize)
                            angleDegrees := angleDegrees + sliceSize
                        }
                        if (immunities["light"]) {
                            Gdip_DrawPie(unitsLayer.G, unitsLayer.pPenLight, mobx-dotAdjust, moby-dotAdjust, unitsLayer.normalImmunitySize, unitsLayer.normalImmunitySize/2, angleDegrees, sliceSize)
                            angleDegrees := angleDegrees + sliceSize
                        }
                        if (immunities["cold"]) {
                            Gdip_DrawPie(unitsLayer.G, unitsLayer.pPenCold, mobx-dotAdjust, moby-dotAdjust, unitsLayer.normalImmunitySize, unitsLayer.normalImmunitySize/2, angleDegrees, sliceSize)
                            angleDegrees := angleDegrees + sliceSize
                        }
                        if (immunities["poison"]) {
                            Gdip_DrawPie(unitsLayer.G, unitsLayer.pPenPoison, mobx-dotAdjust, moby-dotAdjust, unitsLayer.normalImmunitySize, unitsLayer.normalImmunitySize/2,angleDegrees, sliceSize)
                            angleDegrees := angleDegrees + sliceSize
                        }
                    }
                    
                    if (!mob["isMerc"]) {
                        Gdip_DrawEllipse(unitsLayer.G, unitsLayer.pPenNormal, mobx-(unitsLayer.normalDotSize/2), moby-(unitsLayer.normalDotSize/1.5), unitsLayer.normalDotSize, unitsLayer.normalDotSize/2)
                    } else if (settings["showMercs"]) {
                        Gdip_DrawEllipse(unitsLayer.G, unitsLayer.pPenMerc, mobx-(unitsLayer.normalDotSize/2), moby-(unitsLayer.normalDotSize/1.5), unitsLayer.normalDotSize, unitsLayer.normalDotSize/2)
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
                    textx := mobx-(unitsLayer.bossDotSize/2) - 100
                    , texty := moby-(unitsLayer.bossDotSize/2) - 105
                    , bossTextColor := "ff" . settings["bossColor"] 
                    Options = x%textx% y%texty% Center vBottom cffff0000 r8 s24
                    textx := textx + 2
                    , texty := texty + 2
                    Options2 = x%textx% y%texty% Center vBottom cff000000 r8 s24
                    
                    ;x|y|width|height|chars|lines
                    measuredString := Gdip_TextToGraphics(unitsLayer.G, mob["textTitle"], Options2, diabloFont, 200, 100)
                    , ms := StrSplit(measuredString , "|")
                    , healthbarx := ms[1] - 10
                    , healthbary := ms[2] - 5
                    , healthbarwidth := ms[3] + 17
                    , healthbarheight := ms[4] + 1
                    , healthpc := mob["hp"] / mob["maxhp"]
                    , healthPortion := healthbarwidth * healthpc
                    , nonhealthPortion := healthbarwidth - healthPortion
                    , nonhealthPortionx := healthbarx + healthPortion
                    Gdip_FillRectangle(unitsLayer.G, unitsLayer.pBrushNonHealth, nonhealthPortionx, healthbary, nonhealthPortion, healthbarheight)
                    Gdip_FillRectangle(unitsLayer.G, unitsLayer.pBrushHealth, healthbarx, healthbary, healthPortion, healthbarheight)
                    Gdip_TextToGraphics(unitsLayer.G, mob["textTitle"], Options, diabloFont, 200, 100)
                    Gdip_DrawEllipse(unitsLayer.G, unitsLayer.pPenBoss, mobx-(unitsLayer.bossDotSize/2), moby-(unitsLayer.bossDotSize/2), unitsLayer.bossDotSize, unitsLayer.bossDotSize/2)
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
                            
                            Gdip_DrawPie(unitsLayer.G, unitsLayer.pPenPhysical, mobx-(unitsLayer.uniqueImmunitySize/2), moby-(unitsLayer.uniqueImmunitySize/2), unitsLayer.uniqueImmunitySize, unitsLayer.uniqueImmunitySize/2, angleDegrees, sliceSize)
                            angleDegrees := angleDegrees + sliceSize
                        }
                        if (immunities["magic"]) {
                            Gdip_DrawPie(unitsLayer.G, unitsLayer.pPenMagic, mobx-(unitsLayer.uniqueImmunitySize/2), moby-(unitsLayer.uniqueImmunitySize/2), unitsLayer.uniqueImmunitySize, unitsLayer.uniqueImmunitySize/2, angleDegrees, sliceSize)
                            angleDegrees := angleDegrees + sliceSize
                        }
                        if (immunities["fire"]) {
                            Gdip_DrawPie(unitsLayer.G, unitsLayer.pPenFire, mobx-(unitsLayer.uniqueImmunitySize/2), moby-(unitsLayer.uniqueImmunitySize/2), unitsLayer.uniqueImmunitySize, unitsLayer.uniqueImmunitySize/2, angleDegrees, sliceSize)
                            angleDegrees := angleDegrees + sliceSize
                        }
                        if (immunities["light"]) {
                            Gdip_DrawPie(unitsLayer.G, unitsLayer.pPenLight, mobx-(unitsLayer.uniqueImmunitySize/2), moby-(unitsLayer.uniqueImmunitySize/2), unitsLayer.uniqueImmunitySize, unitsLayer.uniqueImmunitySize/2, angleDegrees, sliceSize)
                            angleDegrees := angleDegrees + sliceSize
                        }
                        if (immunities["cold"]) {
                            Gdip_DrawPie(unitsLayer.G, unitsLayer.pPenCold, mobx-(unitsLayer.uniqueImmunitySize/2), moby-(unitsLayer.uniqueImmunitySize/2), unitsLayer.uniqueImmunitySize, unitsLayer.uniqueImmunitySize/2, angleDegrees, sliceSize)
                            angleDegrees := angleDegrees + sliceSize
                        }
                        if (immunities["poison"]) {
                            Gdip_DrawPie(unitsLayer.G, unitsLayer.pPenPoison, mobx-(unitsLayer.uniqueImmunitySize/2), moby-(unitsLayer.uniqueImmunitySize/2), unitsLayer.uniqueImmunitySize, unitsLayer.uniqueImmunitySize/2, angleDegrees, sliceSize)
                            angleDegrees := angleDegrees + sliceSize
                        }
                    }
                    Gdip_DrawEllipse(unitsLayer.G, unitsLayer.pPenUnique, mobx-(unitsLayer.uniqueDotSize/2), moby-(unitsLayer.uniqueDotSize/1.5), unitsLayer.uniqueDotSize, unitsLayer.uniqueDotSize/2)
                }
            }
        }
    }

}