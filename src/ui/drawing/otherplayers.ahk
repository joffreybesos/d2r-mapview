#SingleInstance, Force
SendMode Input
SetWorkingDir, %A_ScriptDir%

drawPlayers(ByRef G, settings, gameMemoryData, imageData, serverScale, scale, padding, Width, Height, scaledWidth, scaledHeight, centerLeftOffset, centerTopOffset) {
    otherPlayers := gameMemoryData["otherPlayers"]
        
    pBrush := Gdip_BrushCreateSolid(0xff00aA00)
    for index, player in otherPlayers
    {
        
        if (gameMemoryData["playerName"] != player["playerName"]) {
            ;WriteLog(gameMemoryData["playerName"] " " player["playerName"])
            playerx := ((player["x"] - imageData["mapOffsetX"]) * serverScale) + padding
            playery := ((player["y"] - imageData["mapOffsetY"]) * serverScale) + padding
            correctedPos := correctPos(settings, playerx, playery, (Width/2), (Height/2), scaledWidth, scaledHeight, scale)
            playerx := correctedPos["x"] + centerLeftOffset
            playery := correctedPos["y"] + centerTopOffset
            if (settings["showOtherPlayerNames"]) {
                textx := playerx-2 - 160
                texty := playery-2 - 100
                Options = x%textx% y%texty% Center Bold vBottom cff00AA00 r8 s24
                textx := textx + 1.5
                texty := texty + 1.5
                Options2 = x%textx% y%texty% Center Bold vBottom cff000000 r8 s24
                Gdip_TextToGraphics(G, player["playerName"], Options2, diabloFont, 320, 100)
                Gdip_TextToGraphics(G, player["playerName"], Options, diabloFont, 320, 100)
            }
            ; draw a square dot, but angled along the map Gdip_PathOutline()
            xscale := 5 * scale
            yscale := 2.5 * scale
            x1 := playerx - xscale
            x2 := playerx
            x3 := playerx + xscale
            y1 := playery - yscale
            y2 := playery
            y3 := playery + yscale

            points = %x1%,%y2%|%x2%,%y1%|%x3%,%y2%|%x2%,%y3%
            Gdip_FillPolygon(G, pBrush, points)
            pPen := Gdip_CreatePen(0xff000000, 1)
            Gdip_DrawPolygon(g, pPen, Points)
            Gdip_DeletePen(pPen)
            ;Gdip_DrawRectangle(G, pPen, playerx-3, playery-3, 6, 6)
        }
    }
    Gdip_DeleteBrush(pBrush)
}