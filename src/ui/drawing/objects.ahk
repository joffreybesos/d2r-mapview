#SingleInstance, Force
SendMode Input
SetWorkingDir, %A_ScriptDir%

drawObjects(ByRef G, settings, gameMemoryData, imageData, serverScale, scale, padding, Width, Height, scaledWidth, scaledHeight, shrines, centerLeftOffset, centerTopOffset) {
    if (settings["showPortals"] or settings["showChests"]) {
        gameObjects := gameMemoryData["objects"]
        , portalColor := "ff" . settings["portalColor"]
        , portalColor := "ff" . settings["redPortalColor"]
        if (settings["centerMode"]) {
            pPen := Gdip_CreatePen("0xff" . settings["portalColor"], 5)
            pPenRed := Gdip_CreatePen("0xff" . settings["redPortalColor"], 5)
        } else {
            pPen := Gdip_CreatePen("0xff" . settings["portalColor"], 2.5)
            pPenRed := Gdip_CreatePen("0xff" . settings["redPortalColor"], 2.5)
        }
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
                    
                    ;Gdip_DrawString(G, text, hFont, hFormat, pBrush2, RectF)
                    if (settings["centerMode"]) {
                        Gdip_DrawEllipse(G, pPen, objectx-8, objecty-25, 16, 32)
                    } else {
                        Gdip_DrawEllipse(G, pPen, objectx-8, objecty-14, 9, 16)
                    }
                }
                if (object["isRedPortal"]) {
                    objectx := ((object["objectx"] - imageData["mapOffsetX"]) * serverScale) + padding
                    , objecty := ((object["objecty"] - imageData["mapOffsetY"]) * serverScale) + padding
                    , correctedPos := correctPos(settings, objectx, objecty, (Width/2), (Height/2), scaledWidth, scaledHeight, scale)
                    , objectx := correctedPos["x"] + centerLeftOffset
                    , objecty := correctedPos["y"] + centerTopOffset
                    if (settings["centerMode"]) {
                        ;Gdip_DrawString(G, text, hFont, hFormat, pBrush2, RectF)
                        Gdip_DrawEllipse(G, pPenRed, objectx-8, objecty-25, 16, 32)
                    } else {
                        Gdip_DrawEllipse(G, pPenRed, objectx-8, objecty-14, 9, 16)
                    }
                }
            }
            if (settings["showChests"]) {
                if (object["isChest"]) {
                    if (object["mode"] == 0) {
                        objectx := ((object["objectx"] - imageData["mapOffsetX"]) * serverScale) + padding
                        , objecty := ((object["objecty"] - imageData["mapOffsetY"]) * serverScale) + padding
                        , correctedPos := correctPos(settings, objectx, objecty, (Width/2), (Height/2), scaledWidth, scaledHeight, scale)
                        , objectx := correctedPos["x"] + centerLeftOffset
                        , objecty := correctedPos["y"] + centerTopOffset
                        if (settings["centerMode"]) {
                            drawChest(G, objectx, objecty, 0.5, object["chestState"])
                        } else {
                            drawChest(G, objectx, objecty, 0.3, object["chestState"])
                        }
                    }
                }
            }
        }
        Gdip_DeletePen(pPen)    
        Gdip_DeletePen(pPenRed)
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
                Gdip_TextToGraphics(G,shrineType, Options2, diabloFont, 300, 100)
                Gdip_TextToGraphics(G,shrineType, Options, diabloFont, 300, 100)

                xscale := 3 * scale
                , yscale := 5 * scale
                , x1 := objectx - xscale
                , x2 := objectx
                , x3 := objectx + xscale
                , y1 := objecty - yscale + 1
                , y2 := objecty + 1
                , y3 := objecty + yscale + 1

                points = %x1%,%y2%|%x2%,%y1%|%x3%,%y2%|%x2%,%y3%
                Gdip_FillPolygon(G, pBrush, points)
                ;Gdip_DrawRectangle(G, pPen, objectx+0.5, objecty+2, 2.5, 2)
            }
        }
        Gdip_DeletePen(pPen)    
    }
}




drawChest(G, objectx, objecty, chestscale, state) {
    if (state == "trap") {
        pBrush := Gdip_BrushCreateSolid(0xccff0000)
    } else if (state == "locked") {
        pBrush := Gdip_BrushCreateSolid(0xccffff00)
    } else {
        pBrush := Gdip_BrushCreateSolid(0xcc542a00)
    }
    pPen := Gdip_CreatePen(0xcc111111, 2)

    chestxoffset := objectx - 10
    chestyoffset := objecty - 10
    x1 := 10 * chestscale + chestxoffset
    y1 := 19 * chestscale + chestyoffset
    x2 := 40 * chestscale + chestxoffset
    y2 := 12 * chestscale + chestyoffset
    x3 := 50 * chestscale + chestxoffset
    y3 := 28 * chestscale + chestyoffset
    x4 := 19 * chestscale + chestxoffset
    y4 := 34 * chestscale + chestyoffset
    x5 := 4 * chestscale + chestxoffset
    y5 := 25 * chestscale + chestyoffset
    x6 := 35 * chestscale + chestxoffset
    x7 := 17 * chestscale + chestxoffset
    y7 := 32 * chestscale + chestyoffset
    x8 := 4 * chestscale + chestxoffset
    y8 := 18 * chestscale + chestyoffset
    x9 := 16 * chestscale + chestxoffset
    y9 := 35 * chestscale + chestyoffset
    x10:= 15 * chestscale + chestxoffset
    y11:= 13 * chestscale + chestyoffset
    y12:= 30 * chestscale + chestyoffset
    y13:= 31 * chestscale + chestyoffset
    y15:= 24 * chestscale + chestyoffset
    y16:= 40 * chestscale + chestyoffset
    y17:= 49 * chestscale + chestyoffset
    y18:= 38 * chestscale + chestyoffset
    y19:= 21 * chestscale + chestyoffset

    piewidth := 15 * chestscale
    pieheight := 30 * chestscale
    backpoints = %x1%,%y1%|%x2%,%y2%|%x3%,%y3%|%x4%,%y4%|%x5%,%y5%|%x1%,%y19%
    Gdip_DrawPie(G, pPen, x6, y2, piewidth, pieheight, 180, 180)
    Gdip_FillPolygon(G, pBrush, backpoints)
    Gdip_FillPie(G, pBrush, x8, y8, piewidth, pieheight, 180, 180)  ;15,30
    Gdip_FillPie(G, pBrush, x6, y11, piewidth, pieheight, 180, 180)        ;17,31
    points = %x5%,%y15%|%x5%,%y16%|%x4%,%y17%|%x4%,%y4%|%x4%,%y17%|%x3%,%y18%|%x3%,%y15%|%x4%,%y4%|%x5%,%y5%
    Gdip_DrawPie(G, pPen, x8, y8, piewidth, pieheight, 180, 180)
    Gdip_FillPolygon(G, pBrush, points)
    Gdip_DrawPolygon(g, pPen, Points)
    Gdip_DrawLine(G, pPen, x1, y1, x2, y2)
}