

; drawObjects(ByRef unitsLayer, ByRef settings, ByRef gameMemoryData, ByRef mapImage, ByRef serverScale, ByRef scale, ByRef padding, ByRef Width, ByRef Height, ByRef scaledWidth, ByRef scaledHeight, ByRef shrines, ByRef centerLeftOffset, ByRef centerTopOffset) {
;     if (settings["showPortals"] or settings["showChests"]) {
;         gameObjects := gameMemoryData["objects"]
        
;         for index, object in gameObjects
;         {
;             if (settings["showPortals"]) {
;                 ;WriteLog(object["txtFileNo"] " " object["isRedPortal"])
;                 if (object["isPortal"]) {
;                     objectx := ((object["objectx"] - mapImage["mapOffsetX"]) * serverScale) + padding
;                     , objecty := ((object["objecty"] - mapImage["mapOffsetY"]) * serverScale) + padding
;                     , correctedPos := correctPos(settings, objectx, objecty, (Width/2), (Height/2), scaledWidth, scaledHeight, scale)
;                     , objectx := correctedPos["x"] + centerLeftOffset
;                     , objecty := correctedPos["y"] + centerTopOffset
;                     portalColor := "ff" . settings["portalColor"]
;                     if (object["interactType"] == 1 or object["interactType"] == 40 or object["interactType"] == 75 or object["interactType"] == 103 or object["interactType"] == 109) {
;                         drawFloatingText(unitsLayer, objectx, objecty-(12 * scale), 8 * scale, portalColor, false, true, formalFont, object["ownerName"])
;                     } else {
;                         areaName := getAreaName(object["interactType"])
;                         if (object["ownerName"]) {
;                             areaName := areaName . "`n(" . object["ownerName"] . ")"
;                         }
;                         drawFloatingText(unitsLayer, objectx, objecty-(12 * scale), 8 * scale, portalColor, false, true, formalFont, areaName)
;                     }

;                     ;Gdip_DrawString(unitsLayer.G, text, hFont, hFormat, pBrush2, RectF)
;                     if (settings["centerMode"]) {
;                         Gdip_DrawEllipse(unitsLayer.G, unitsLayer.pPortal, objectx-8, objecty-(10 * scale), 8 * scale, 16 * scale)
;                     } else {
;                         Gdip_DrawEllipse(unitsLayer.G, unitsLayer.pPortal, objectx-8, objecty-(9 * scale), 8 * scale, 16 * scale)
;                     }
;                 }
;                 if (object["isRedPortal"]) {
;                     objectx := ((object["objectx"] - mapImage["mapOffsetX"]) * serverScale) + padding
;                     , objecty := ((object["objecty"] - mapImage["mapOffsetY"]) * serverScale) + padding
;                     , correctedPos := correctPos(settings, objectx, objecty, (Width/2), (Height/2), scaledWidth, scaledHeight, scale)
;                     , objectx := correctedPos["x"] + centerLeftOffset
;                     , objecty := correctedPos["y"] + centerTopOffset
;                     if (settings["centerMode"]) {
;                         ;Gdip_DrawString(unitsLayer.G, text, hFont, hFormat, pBrush2, RectF)
;                         Gdip_DrawEllipse(unitsLayer.G, unitsLayer.pRedPortal, objectx-8, objecty-(10 * scale), 8 * scale, 16 * scale)
;                     } else {
;                         Gdip_DrawEllipse(unitsLayer.G, unitsLayer.pRedPortal, objectx-8, objecty-(9 * scale), 8 * scale, 16 * scale)
;                     }
;                 }
;             }
;             if (settings["showChests"]) {
;                 if (object["isChest"]) {
;                     if (object["mode"] == 0) {
;                         objectx := ((object["objectx"] - mapImage["mapOffsetX"]) * serverScale) + padding
;                         , objecty := ((object["objecty"] - mapImage["mapOffsetY"]) * serverScale) + padding
;                         , correctedPos := correctPos(settings, objectx, objecty, (Width/2), (Height/2), scaledWidth, scaledHeight, scale)
;                         , objectx := correctedPos["x"] + centerLeftOffset
;                         , objecty := correctedPos["y"] + centerTopOffset
;                         if (settings["centerMode"]) {
                            
;                             drawChest(unitsLayer, objectx, objecty, (1 / 4) * scale, object["chestState"])
;                         } else {
;                             drawChest(unitsLayer, objectx, objecty, (1 / 5) * scale, object["chestState"])
;                         }
;                     }
;                 }
;             }
;         }
;     }

;     ; draw Shrines
;     if (settings["showShrines"]) {
;         gameObjects := gameMemoryData["objects"]
;         , shrineColor := "ff" . settings["shrineColor"]
;         , shrineTextSize := (settings["shrineTextSize"] /2) * scale
;         , pBrush := Gdip_BrushCreateSolid("0xff" . settings["shrineColor"])
;         for index, object in gameObjects
;         {
;             if (object["isShrine"]) {
;                 isShrineAlreadySeen := 0
;                 for index, oldShrine in shrines
;                 {
;                     if (oldShrine["objectx"] == object["objectx"] and oldShrine["objecty"] == object["objecty"] and oldShrine["levelNo"] == object["levelNo"]) {
;                         ; already seen
;                         isShrineAlreadySeen := 1
;                     }
;                 }
;                 if (!isShrineAlreadySeen) {
;                     shrines.push(object)
;                 }
;             }
;         }
;         for index, object in shrines
;         {
;             if (object["levelNo"] == gameMemoryData["levelNo"]) {

;                 objectx := ((object["objectx"] - mapImage["mapOffsetX"]) * serverScale) + padding
;                 , objecty := ((object["objecty"] - mapImage["mapOffsetY"]) * serverScale) + padding
;                 , correctedPos := correctPos(settings, objectx, objecty, (Width/2), (Height/2), scaledWidth, scaledHeight, scale)
;                 , objectx := correctedPos["x"] + centerLeftOffset
;                 , objecty := correctedPos["y"] + centerTopOffset
;                 , shrineType := object["shrineType"]
;                 , textx := objectx - 150
;                 , texty := objecty - 110
;                 Options = x%textx% y%texty% Center Bold vBottom c%shrineColor% r8 s%shrineTextSize%
;                 textx := textx + 1
;                 , texty := texty + 1
;                 Options2 = x%textx% y%texty% Center Bold vBottom cff000000 r8 s%shrineTextSize%
;                 Gdip_TextToGraphics(unitsLayer.G,shrineType, Options2, exocetFont, 300, 100)
;                 Gdip_TextToGraphics(unitsLayer.G,shrineType, Options, exocetFont, 300, 100)

;                 xscale := 3 * scale
;                 , yscale := 5 * scale
;                 , x1 := objectx - xscale
;                 , x2 := objectx
;                 , x3 := objectx + xscale
;                 , y1 := objecty - yscale + 1
;                 , y2 := objecty + 1
;                 , y3 := objecty + yscale + 1

;                 points = %x1%,%y2%|%x2%,%y1%|%x3%,%y2%|%x2%,%y3%
;                 Gdip_FillPolygon(unitsLayer.G, pBrush, points)
;                 ;Gdip_DrawRectangle(unitsLayer.G, pPen, objectx+0.5, objecty+2, 2.5, 2)
;             }
;         }
;         Gdip_DeletePen(pPen) 
;     }
; }



