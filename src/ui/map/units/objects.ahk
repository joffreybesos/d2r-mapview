

drawObjects(ByRef G, ByRef brushes, ByRef settings, ByRef gameMemoryData, ByRef scale) {
    playerX := gameMemoryData.xPos
    playerY := gameMemoryData.yPos
    renderScale := settings["serverScale"]

    if (settings["showPortals"] or settings["showChests"]) {
        gameObjects := gameMemoryData["objects"]
        
        for index, object in gameObjects
        {
            if (settings["showPortals"]) {
                ;WriteLog(object["txtFileNo"] " " object["isRedPortal"])
                if (object["isPortal"]) {
                    objectScreenPos := World2Screen(playerX, playerY, object.x, object.y, scale)
                    
                    portalColor := "ff" . settings["portalColor"]
                    if (object["interactType"] == 1 or object["interactType"] == 40 or object["interactType"] == 75 or object["interactType"] == 103 or object["interactType"] == 109) {
                        drawFloatingText(G, brushes, objectScreenPos.x, objectScreenPos.y-(12 * scale), 8 * scale, portalColor, false, true, formalFont, object["ownerName"])
                    } else {
                        areaName := getAreaName(object["interactType"])
                        if (object["ownerName"]) {
                            areaName := areaName . "`n(" . object["ownerName"] . ")"
                        }
                        drawFloatingText(G, brushes, objectScreenPos.x, objectScreenPos.y-(12 * scale), 8 * scale, portalColor, false, true, formalFont, areaName)
                    }

                    ;Gdip_DrawString(G, text, hFont, hFormat, pBrush2, RectF)
                    if (settings["centerMode"]) {
                        Gdip_DrawEllipse(G, brushes.pPortal, objectScreenPos.x-8, objectScreenPos.y-(10 * scale), 8 * scale, 16 * scale)
                    } else {
                        Gdip_DrawEllipse(G, brushes.pPortal, objectScreenPos.x-8, objectScreenPos.y-(9 * scale), 8 * scale, 16 * scale)
                    }
                }
                if (object["isRedPortal"]) {
                    objectScreenPos := World2Screen(playerX, playerY, object.x, object.y, scale)
                    if (settings["centerMode"]) {
                        ;Gdip_DrawString(G, text, hFont, hFormat, pBrush2, RectF)
                        Gdip_DrawEllipse(G, brushes.pRedPortal, objectScreenPos.x-8, objectScreenPos.y-(10 * scale), 8 * scale, 16 * scale)
                    } else {
                        Gdip_DrawEllipse(G, brushes.pRedPortal, objectScreenPos.x-8, objectScreenPos.y-(9 * scale), 8 * scale, 16 * scale)
                    }
                }
            }
            if (settings["showChests"]) {
                if (object["isChest"]) {
                    if (object["mode"] == 0) {
                        objectScreenPos := World2Screen(playerX, playerY, object.x, object.y, scale)
                        if (settings["centerMode"]) {
                            
                            drawChest(G, brushes, objectScreenPos.x, objectScreenPos.y, (1 / 4) * scale, object["chestState"])
                        } else {
                            drawChest(G, brushes, objectScreenPos.x, objectScreenPos.y, (1 / 5) * scale, object["chestState"])
                        }
                    }
                }
            }
        }
    }

    ; draw Shrines
    if (settings["showShrines"]) {
        gameObjects := gameMemoryData["objects"]
        , shrineColor := "ff" . settings["shrineColor"]
        , shrineTextSize := (settings["shrineTextSize"] /2) * scale
        , pBrush := Gdip_BrushCreateSolid("0xff" . settings["shrineColor"])
        for index, object in gameObjects
        {
            if (object["isShrine"]) {
                isShrineAlreadySeen := 0
                for index, oldShrine in shrines
                {
                    if (oldShrine["x"] == object["x"] and oldShrine["y"] == object["y"] and oldShrine["levelNo"] == object["levelNo"]) {
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

                objectScreenPos := World2Screen(playerX, playerY, object.x, object.y, scale)
                , shrineType := object["shrineType"]
                , textx := objectScreenPos.x - 150
                , texty := objectScreenPos.y - 110
                Options = x%textx% y%texty% Center Bold vBottom c%shrineColor% r8 s%shrineTextSize%
                textx := textx + 1
                , texty := texty + 1
                Options2 = x%textx% y%texty% Center Bold vBottom cff000000 r8 s%shrineTextSize%
                Gdip_TextToGraphics(G, shrineType, Options2, exocetFont, 300, 100)
                Gdip_TextToGraphics(G, shrineType, Options, exocetFont, 300, 100)

                xscale := 3 * scale
                , yscale := 5 * scale
                , x1 := objectScreenPos.x - xscale
                , x2 := objectScreenPos.x
                , x3 := objectScreenPos.x + xscale
                , y1 := objectScreenPos.y - yscale + 1
                , y2 := objectScreenPos.y + 1
                , y3 := objectScreenPos.y + yscale + 1

                points = %x1%,%y2%|%x2%,%y1%|%x3%,%y2%|%x2%,%y3%
                Gdip_FillPolygon(G, pBrush, points)
                ;Gdip_DrawRectangle(G, pPen, objectScreenPos.x+0.5, objectScreenPos.y+2, 2.5, 2)
            }
        }
        Gdip_DeletePen(pPen) 
    }
}



