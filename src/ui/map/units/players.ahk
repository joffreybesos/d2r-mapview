
drawPlayers(ByRef G, ByRef brushes, ByRef settings, ByRef gameMemoryData) {
    playerX := gameMemoryData.xPos
    playerY := gameMemoryData.yPos
    renderScale := settings["serverScale"]
    scale := settings["centerModeScale"]

    ; draw yourself
    gameWindow := getMapDrawingArea()
    centerX := (gameWindow.W/2) ;+ gameWindow.X
    centerY := (gameWindow.H/2) - (5 * scale) ;+ gameWindow.Y
    points := createCross(centerX, centerY, 4.9 * scale)
    Gdip_DrawPolygon(G, brushes.pPenPlayer, points)

    ; draw other players
    otherPlayers := gameMemoryData["otherPlayers"]
    for index, player in otherPlayers
    {
        
        if (gameMemoryData["playerName"] != player["playerName"] or player["isCorpse"]) {
            ;WriteLog(GameMemoryData["playerName"] " " player["playerName"])
            playerScreenPos := World2Screen(playerX, playerY, player.x, player.y, scale)
            
            if (settings["showOtherPlayerNames"]) {
                if (player["isCorpse"]) {
                    drawFloatingText(G, brushes, playerScreenPos.x+1, playerScreenPos.y-(9.2 * scale), 11 * scale, "ffff00ff", true, true, formalFont, player["playerName"])
                } else {
                    drawFloatingText(G, brushes, playerScreenPos.x+1, playerScreenPos.y-(9.2 * scale), 11 * scale, "ff00ff00", true, true,formalFont, player["playerName"])
                }
            }

            ; draw a gress cross to represent the player
            points := createCross(playerScreenPos.x, playerScreenPos.y, 5 * scale)
            if (player["isCorpse"]) {
                Gdip_DrawPolygon(G, brushes.pPenCorpse, points)
            } else {
                Gdip_DrawPolygon(G, brushes.pPenOtherPlayer, points)
            }
        }
    }
}