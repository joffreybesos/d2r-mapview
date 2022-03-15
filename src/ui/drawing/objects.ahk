

drawObjects(ByRef unitsLayer, ByRef settings, ByRef gameMemoryData, ByRef imageData, ByRef serverScale, ByRef scale, ByRef padding, ByRef Width, ByRef Height, ByRef scaledWidth, ByRef scaledHeight, ByRef shrines, ByRef centerLeftOffset, ByRef centerTopOffset, ByRef presetData) {
    if (settings["showPortals"] or settings["showChests"]) {
        gameObjects := gameMemoryData["objects"]
        presetChests := presetData["presetChests"]
        
        for index, object in gameObjects
        {
            if (settings["showPortals"]) {
                ;WriteLog(object["txtFileNo"] " " object["isRedPortal"])
                if (object["isPortal"]) {
                    objectx := ((object["objectx"] - imageData["mapOffsetX"]) * serverScale) + padding
                    , objecty := ((object["objecty"] - imageData["mapOffsetY"]) * serverScale) + padding
                    , correctedPos := correctPos(settings, objectx, objecty, (Width/2), (Height/2), scaledWidth, scaledHeight, scale)
                    , objectx := correctedPos["x"] + centerLeftOffset
                    , objecty := correctedPos["y"] + centerTopOffset

                    ;Gdip_DrawString(unitsLayer.G, text, hFont, hFormat, pBrush2, RectF)
                    if (settings["centerMode"]) {
                        Gdip_DrawEllipse(unitsLayer.G, unitsLayer.pPortal, objectx-8, objecty-25, 16, 32)
                    } else {
                        Gdip_DrawEllipse(unitsLayer.G, unitsLayer.pPortal, objectx-8, objecty-14, 9, 16)
                    }
                }
                if (object["isRedPortal"]) {
                    objectx := ((object["objectx"] - imageData["mapOffsetX"]) * serverScale) + padding
                    , objecty := ((object["objecty"] - imageData["mapOffsetY"]) * serverScale) + padding
                    , correctedPos := correctPos(settings, objectx, objecty, (Width/2), (Height/2), scaledWidth, scaledHeight, scale)
                    , objectx := correctedPos["x"] + centerLeftOffset
                    , objecty := correctedPos["y"] + centerTopOffset
                    if (settings["centerMode"]) {
                        ;Gdip_DrawString(unitsLayer.G, text, hFont, hFormat, pBrush2, RectF)
                        Gdip_DrawEllipse(unitsLayer.G, unitsLayer.pRedPortal, objectx-8, objecty-25, 16, 32)
                    } else {
                        Gdip_DrawEllipse(unitsLayer.G, unitsLayer.pRedPortal, objectx-8, objecty-14, 9, 16)
                    }
                }
            }
            if (settings["showChests"]) {
                if (object["isChest"]) {
                    presetIndex := object["objectx"] "-" object["objecty"]
                    if (mode != 0) {
                        presetChests[presetIndex] := 0
                    } else {
                        if (presetChests[presetIndex]) {
                            objectx := ((object["objectx"] - imageData["mapOffsetX"]) * serverScale) + padding
                            , objecty := ((object["objecty"] - imageData["mapOffsetY"]) * serverScale) + padding
                            , correctedPos := correctPos(settings, objectx, objecty, (Width/2), (Height/2), scaledWidth, scaledHeight, scale)
                            , objectx := correctedPos["x"] + centerLeftOffset
                            , objecty := correctedPos["y"] + centerTopOffset
                            drawSuperChest(unitsLayer, objectx, objecty, 0.4 * scale)
                        }
                    }
                    if (object["mode"] == 0) {
                        objectx := ((object["objectx"] - imageData["mapOffsetX"]) * serverScale) + padding
                        , objecty := ((object["objecty"] - imageData["mapOffsetY"]) * serverScale) + padding
                        , correctedPos := correctPos(settings, objectx, objecty, (Width/2), (Height/2), scaledWidth, scaledHeight, scale)
                        , objectx := correctedPos["x"] + centerLeftOffset
                        , objecty := correctedPos["y"] + centerTopOffset
                        if (presetChests[presetIndex]) {
                            ;drawSuperChest(unitsLayer, objectx, objecty, 0.4 * scale)
                        } else {
                            drawChest(unitsLayer, objectx, objecty, 0.25 * scale, object["chestState"])
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
        , shrineTextSize := settings["shrineTextSize"]
        , pBrush := Gdip_BrushCreateSolid("0xff" . settings["shrineColor"])
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
                , objecty := ((object["objecty"] - imageData["mapOffsetY"]) * serverScale) + padding
                , correctedPos := correctPos(settings, objectx, objecty, (Width/2), (Height/2), scaledWidth, scaledHeight, scale)
                , objectx := correctedPos["x"] + centerLeftOffset
                , objecty := correctedPos["y"] + centerTopOffset
                , shrineType := object["shrineType"]
                , textx := objectx - 150
                , texty := objecty - 110
                Options = x%textx% y%texty% Center Bold vBottom c%shrineColor% r8 s%shrineTextSize%
                textx := textx + 2
                , texty := texty + 2
                Options2 = x%textx% y%texty% Center Bold vBottom cff000000 r8 s%shrineTextSize%
                Gdip_TextToGraphics(unitsLayer.G,shrineType, Options2, exocetFont, 300, 100)
                Gdip_TextToGraphics(unitsLayer.G,shrineType, Options, exocetFont, 300, 100)

                xscale := 3 * scale
                , yscale := 5 * scale
                , x1 := objectx - xscale
                , x2 := objectx
                , x3 := objectx + xscale
                , y1 := objecty - yscale + 1
                , y2 := objecty + 1
                , y3 := objecty + yscale + 1

                points = %x1%,%y2%|%x2%,%y1%|%x3%,%y2%|%x2%,%y3%
                Gdip_FillPolygon(unitsLayer.G, pBrush, points)
                ;Gdip_DrawRectangle(unitsLayer.G, pPen, objectx+0.5, objecty+2, 2.5, 2)
            }
        }
        Gdip_DeletePen(pPen) 
    }
}



