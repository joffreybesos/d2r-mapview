

drawNPCs(ByRef G, ByRef brushes, ByRef settings, ByRef gameMemoryData, ByRef scale, ByRef gameWindow) {
    mobs := gameMemoryData.mobs
    playerX := gameMemoryData.xPos
    playerY := gameMemoryData.yPos
    renderScale := settings["serverScale"]

    ; timeStamp("drawMonsters-showDeadMobs")
    if (settings["showDeadMobs"]) {
        for index, mob in mobs
        {
            if (mob["mode"] == 0 or mob["mode"] == 12) { ; dead
                mobScreenPos := World2Screen(playerX, playerY, mob.x, mob.y, scale, gameWindow)
                Gdip_DrawEllipse(G, brushes.pPenDead, mobScreenPos.x, mobScreenPos.y, brushes.deadDotSize, brushes.deadDotSize/2)
            }
        }
    }
    ; timeStamp("drawMonsters-showDeadMobs")
    
    ; timeStamp("drawMonsters-showNormalMobs")
    if (settings["showNormalMobs"]) {
        for index, mob in mobs
        {
            mobScreenPos := World2Screen(playerX, playerY, mob.x, mob.y, scale, gameWindow)

            if (mob["isUnique"] == 0) {
                if (mob["mode"] != 0 and mob["mode"] != 12) { ; not dead
                    if (settings["showImmunities"]) { ; yeah it says immunities but really it's resistances, bite me
                        immunities := mob["immunities"]
                        noImmunities := (immunities["physical"] >= 100) + (immunities["magic"] >= 100) + (immunities["fire"] >= 100) + (immunities["light"] >= 100) + (immunities["cold"] >= 100) + (immunities["poison"] >= 100)
                        sliceSize := 360 / noImmunities
                        angleDegrees := 90
                        dotAdjust := brushes.normalImmunitySize/2
                        if (immunities["physical"] >= 100) {
                            Gdip_DrawPie(G, brushes.pPenPhysical, mobScreenPos.x-dotAdjust, mobScreenPos.y-dotAdjust, brushes.normalImmunitySize, brushes.normalImmunitySize/2, angleDegrees, sliceSize)
                            angleDegrees := angleDegrees + sliceSize
                        }
                        if (immunities["magic"] >= 100) {
                            Gdip_DrawPie(G, brushes.pPenMagic, mobScreenPos.x-dotAdjust, mobScreenPos.y-dotAdjust, brushes.normalImmunitySize, brushes.normalImmunitySize/2, angleDegrees, sliceSize)
                            angleDegrees := angleDegrees + sliceSize
                        }
                        if (immunities["fire"] >= 100) {
                            Gdip_DrawPie(G, brushes.pPenFire, mobScreenPos.x-dotAdjust, mobScreenPos.y-dotAdjust, brushes.normalImmunitySize, brushes.normalImmunitySize/2, angleDegrees, sliceSize)
                            angleDegrees := angleDegrees + sliceSize
                        }
                        if (immunities["light"] >= 100) {
                            Gdip_DrawPie(G, brushes.pPenLight, mobScreenPos.x-dotAdjust, mobScreenPos.y-dotAdjust, brushes.normalImmunitySize, brushes.normalImmunitySize/2, angleDegrees, sliceSize)
                            angleDegrees := angleDegrees + sliceSize
                        }
                        if (immunities["cold"] >= 100) {
                            Gdip_DrawPie(G, brushes.pPenCold, mobScreenPos.x-dotAdjust, mobScreenPos.y-dotAdjust, brushes.normalImmunitySize, brushes.normalImmunitySize/2, angleDegrees, sliceSize)
                            angleDegrees := angleDegrees + sliceSize
                        }
                        if (immunities["poison"] >= 100) {
                            Gdip_DrawPie(G, brushes.pPenPoison, mobScreenPos.x-dotAdjust, mobScreenPos.y-dotAdjust, brushes.normalImmunitySize, brushes.normalImmunitySize/2,angleDegrees, sliceSize)
                            angleDegrees := angleDegrees + sliceSize
                        }
                    }
                    if (settings["NPCsAsCross"]) {
                        points := createCross(mobScreenPos.x, mobScreenPos.y, 5 * scale)
                        if (mob["isPlayerMinion"] and settings["showMerc"]) {
                            Gdip_DrawPolygon(G, brushes.pPenMercCross, points)
                        } else if (mob["isTownNPC"] and !mob["isPlayerMinion"] and settings["showTownNPCs"]) {
                            fontSize := 11 * scale
                            npcName := mob["isTownNPC"]
                            if (settings["showTownNPCNames"]) {
                                drawFloatingText(G, brushes, mobScreenPos.x, mobScreenPos.y-(9.2 * scale), fontSize, "ffc6b276", true, true, formalFont, localizedStrings[npcName])
                            }
                            Gdip_DrawPolygon(G, brushes.pPenTownNPCCross, points)
                        } else if (!mob["isTownNPC"] and !mob["isPlayerMinion"]) {
                            ;Gdip_DrawPolygon(G, brushes.pPenNormal, points)
                            Gdip_DrawEllipse(G, brushes.pPenNormal, mobScreenPos.x-(brushes.normalDotSize/2), mobScreenPos.y-(brushes.normalDotSize/1.5), brushes.normalDotSize, brushes.normalDotSize/2)
                        }
                    } else {
                        if (mob["isPlayerMinion"] and settings["showMerc"]) {
                            Gdip_DrawEllipse(G, brushes.pPenMerc, mobScreenPos.x-(brushes.normalDotSize/2), mobScreenPos.y-(brushes.normalDotSize/1.5), brushes.normalDotSize, brushes.normalDotSize/2)
                        } else if (mob["isTownNPC"] and !mob["isPlayerMinion"] and settings["showTownNPCs"]) {
                            fontSize := 11 * scale
                            npcName := mob["isTownNPC"]
                            if (settings["showTownNPCNames"]) {
                                drawFloatingText(G, brushes, mobScreenPos.x, mobScreenPos.y-(9.2 * scale), fontSize, "ffc6b276", true, true, formalFont, localizedStrings[npcName])
                            }
                            Gdip_DrawEllipse(G, brushes.pPenTownNPC, mobScreenPos.x-(brushes.normalDotSize/2), mobScreenPos.y-(brushes.normalDotSize/1.5), brushes.normalDotSize, brushes.normalDotSize/2)
                        } else if (!mob["isTownNPC"] and !mob["isPlayerMinion"]) {
                            Gdip_DrawEllipse(G, brushes.pPenNormal, mobScreenPos.x-(brushes.normalDotSize/2), mobScreenPos.y-(brushes.normalDotSize/1.5), brushes.normalDotSize, brushes.normalDotSize/2)
                        }
                    }
                }
            }
        }
    }
    ; timeStamp("drawMonsters-showNormalMobs")

    ; timeStamp("drawMonsters-showUniqueMobs")
    ; having this in a separate loop forces it to be drawn on top
    for index, mob in mobs
    {
        mobScreenPos := World2Screen(playerX, playerY, mob.x, mob.y, scale, gameWindow)
        if (mob["isBoss"]) {
            if (settings["showBosses"]) {
                if (mob["mode"] != 0 and mob["mode"] != 12) {
                    ;WriteLog("Boss: " mob["textTitle"])
                    textx := mobScreenPos.x-(brushes.bossDotSize/2) - 100
                    , texty := mobScreenPos.y-(brushes.bossDotSize/2) - 105
                    , bossTextColor := "ff" . settings["bossColor"] 
                    , bossFontSize := 12 * scale
                    Options = x%textx% y%texty% Center vBottom cffff0000 r8 s%bossFontSize%
                    textx := textx + 2
                    , texty := texty + 2
                    Options2 = x%textx% y%texty% Center vBottom cff000000 r8 s%bossFontSize%
                    
                    ;x|y|width|height|chars|lines
                    measuredString := Gdip_TextToGraphics(G, mob["textTitle"], Options2, exocetFont, 200, 100)
                    , ms := StrSplit(measuredString , "|")
                    , healthbarx := ms[1] - 10
                    , healthbary := ms[2] - 5
                    , healthbarwidth := ms[3] + 17
                    , healthbarheight := ms[4] + 1
                    , healthpc := mob["hp"] / mob["maxhp"]
                    , healthPortion := healthbarwidth * healthpc
                    , nonhealthPortion := healthbarwidth - healthPortion
                    , nonhealthPortionx := healthbarx + healthPortion
                    Gdip_FillRectangle(G, brushes.pBrushNonHealth, nonhealthPortionx, healthbary, nonhealthPortion, healthbarheight)
                    Gdip_FillRectangle(G, brushes.pBrushHealth, healthbarx, healthbary, healthPortion, healthbarheight)
                    Gdip_TextToGraphics(G, mob["textTitle"], Options, exocetFont, 200, 100)
                    Gdip_DrawEllipse(G, brushes.pPenBoss, mobScreenPos.x-(brushes.bossDotSize/2), mobScreenPos.y-(brushes.bossDotSize/2), brushes.bossDotSize, brushes.bossDotSize/2)
                }
            }
        }
        else if (mob["isUnique"]) {
            if (settings["showUniqueMobs"]) {
                if (mob["mode"] != 0 and mob["mode"] != 12) { ; not dead
                    ;WriteLog("Unique: " mob["textTitle"])
                    
                    if (settings["showImmunities"]) {
                        immunities := mob["immunities"]
                        noImmunities := (immunities["physical"] >= 100) + (immunities["magic"] >= 100) + (immunities["fire"] >= 100) + (immunities["light"] >= 100) + (immunities["cold"] >= 100) + (immunities["poison"] >= 100)
                        sliceSize := 360 / noImmunities
                        angleDegrees := 90
                        ;WriteLog(mob["txtFileNo"] " " immunities["fire"] immunities["light"] immunities["cold"] immunities["poison"])
                        ;txtFileNo := mob["txtFileNo"]
                        ;WriteLog("noImmunities: " noImmunities ", txtFileNo: " txtFileNo ", " immunities["physical"] immunities["magic"] immunities["fire"] immunities["light"] immunities["cold"] immunities["poison"])
                        if (immunities["physical"] >= 100) {
                            
                            Gdip_DrawPie(G, brushes.pPenPhysical, mobScreenPos.x-(brushes.uniqueImmunitySize/2), mobScreenPos.y-(brushes.uniqueImmunitySize/2), brushes.uniqueImmunitySize, brushes.uniqueImmunitySize/2, angleDegrees, sliceSize)
                            angleDegrees := angleDegrees + sliceSize
                        }
                        if (immunities["magic"] >= 100) {
                            Gdip_DrawPie(G, brushes.pPenMagic, mobScreenPos.x-(brushes.uniqueImmunitySize/2), mobScreenPos.y-(brushes.uniqueImmunitySize/2), brushes.uniqueImmunitySize, brushes.uniqueImmunitySize/2, angleDegrees, sliceSize)
                            angleDegrees := angleDegrees + sliceSize
                        }
                        if (immunities["fire"] >= 100) {
                            Gdip_DrawPie(G, brushes.pPenFire, mobScreenPos.x-(brushes.uniqueImmunitySize/2), mobScreenPos.y-(brushes.uniqueImmunitySize/2), brushes.uniqueImmunitySize, brushes.uniqueImmunitySize/2, angleDegrees, sliceSize)
                            angleDegrees := angleDegrees + sliceSize
                        }
                        if (immunities["light"] >= 100) {
                            Gdip_DrawPie(G, brushes.pPenLight, mobScreenPos.x-(brushes.uniqueImmunitySize/2), mobScreenPos.y-(brushes.uniqueImmunitySize/2), brushes.uniqueImmunitySize, brushes.uniqueImmunitySize/2, angleDegrees, sliceSize)
                            angleDegrees := angleDegrees + sliceSize
                        }
                        if (immunities["cold"] >= 100) {
                            Gdip_DrawPie(G, brushes.pPenCold, mobScreenPos.x-(brushes.uniqueImmunitySize/2), mobScreenPos.y-(brushes.uniqueImmunitySize/2), brushes.uniqueImmunitySize, brushes.uniqueImmunitySize/2, angleDegrees, sliceSize)
                            angleDegrees := angleDegrees + sliceSize
                        }
                        if (immunities["poison"] >= 100) {
                            Gdip_DrawPie(G, brushes.pPenPoison, mobScreenPos.x-(brushes.uniqueImmunitySize/2), mobScreenPos.y-(brushes.uniqueImmunitySize/2), brushes.uniqueImmunitySize, brushes.uniqueImmunitySize/2, angleDegrees, sliceSize)
                            angleDegrees := angleDegrees + sliceSize
                        }
                    }
                    Gdip_DrawEllipse(G, brushes.pPenUnique, mobScreenPos.x-(brushes.uniqueDotSize/2), mobScreenPos.y-(brushes.uniqueDotSize/1.5), brushes.uniqueDotSize, brushes.uniqueDotSize/2)
                }
            }
        }
    }
    ; timeStamp("drawMonsters-showUniqueMobs")
}
