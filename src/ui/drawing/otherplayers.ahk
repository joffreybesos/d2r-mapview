
drawPlayers(ByRef unitsLayer, ByRef settings, ByRef gameMemoryData, ByRef imageData, ByRef serverScale, ByRef scale, ByRef padding, ByRef Width, ByRef Height, ByRef scaledWidth, scaledHeight, ByRef centerLeftOffset, ByRef centerTopOffset) {
    otherPlayers := gameMemoryData["otherPlayers"]
    for index, player in otherPlayers
    {
        
        if (gameMemoryData["playerName"] != player["playerName"]) {
            ;WriteLog(unitsLayer.GameMemoryData["playerName"] " " player["playerName"])
            playerx := ((player["x"] - imageData["mapOffsetX"]) * serverScale) + padding
            playery := ((player["y"] - imageData["mapOffsetY"]) * serverScale) + padding
            correctedPos := correctPos(settings, playerx, playery, (Width/2), (Height/2), scaledWidth, scaledHeight, scale)
            playerx := correctedPos["x"] + centerLeftOffset
            playery := correctedPos["y"] + centerTopOffset
            if (settings["showOtherPlayerNames"]) {
                ; textx := playerx-2 - 160
                ; texty := playery-2 - 100
                ; Options = x%textx% y%texty% Center Bold vBottom cff00AA00 r8 s24
                ; textx := textx + 1.5
                ; texty := texty + 1.5
                ; Options2 = x%textx% y%texty% Center Bold vBottom cff000000 r8 s24
                ; Gdip_TextToGraphics(unitsLayer.G, player["playerName"], Options2, exocetFont, 320, 100)
                ; Gdip_TextToGraphics(unitsLayer.G, player["playerName"], Options, exocetFont, 320, 100)

                drawFloatingText(unitsLayer, playerx+1, playery-(9.2 * scale), 11 * scale, "ff00ff00", true, formalFont, player["playerName"])
            }
            
            ; draw player
            if (settings["playerAsCross"]) {
                ; draw a gress cross to represent the player
                points := createCross(playerx, playery, 5 * scale)
                
                Gdip_DrawPolygon(unitsLayer.G, unitsLayer.pPenOtherPlayer, points)
                
            } else {
                ;draw a square dot, but angled along the map Gdip_PathOutline()
                xscale := 5 * scale
                , yscale := 2.5 * scale
                , x1 := playerx - xscale
                , x2 := playerx
                , x3 := playerx + xscale
                , y1 := playery - yscale
                , y2 := playery
                , y3 := playery + yscale

                points = %x1%,%y2%|%x2%,%y1%|%x3%,%y2%|%x2%,%y3%
                Gdip_FillPolygon(unitsLayer.G, unitsLayer.pBrushOtherPlayer, points)
                Gdip_DrawPolygon(unitsLayer.G, unitsLayer.pPenBlack, Points)
            }   
            
            ; dotSize := 15
            ; Gdip_DrawEllipse(unitsLayer.G, unitsLayer.pPenBlack, playerx-(dotSize/2), playery-(dotSize/4), dotSize, dotSize/2)
            ; Gdip_FillEllipse(unitsLayer.G, unitsLayer.pBrushDarkGreen, playerx-(dotSize/2), playery-(dotSize/4), dotSize, dotSize/2)
        }
    }
}