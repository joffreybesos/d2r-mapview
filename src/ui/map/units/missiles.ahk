

drawMissiles(ByRef G, ByRef brushes, ByRef settings, ByRef gameMemoryData, ByRef scale, ByRef gameWindow) {
    static oldmobScreenPosx
    static oldmobScreenPosy
    playerX := gameMemoryData.xPos
    playerY := gameMemoryData.yPos
    renderScale := settings["serverScale"]
    
    for index,  missilearray in gameMemoryData["missiles"]
    {   
        for each, missile in missilearray
        {
            mobScreenPos := World2Screen(playerX, playerY, missile.x, missile.y, scale, gameWindow)
            if (oldmobScreenPosx == mobScreenPos.x && oldmobScreenPosy == mobScreenPos.y){
            } else {
                switch (missile["UnitType"]) {
                    case "PhysicalMajor": Gdip_DrawEllipse(G, brushes.pPenPhysicalMajor, mobScreenPos.x-3, mobScreenPos.y-3, brushes.majorDotSize, brushes.majorDotSize/2)
                    case "PhysicalMinor": Gdip_DrawEllipse(G, brushes.pPenPhysicalMinor, mobScreenPos.x-3, mobScreenPos.y-3, brushes.minorDotSize, brushes.minorDotSize/2)
                    case "FireMajor": Gdip_DrawEllipse(G, brushes.pPenFireMajor, mobScreenPos.x-3, mobScreenPos.y-3, brushes.majorDotSize, brushes.majorDotSize/2)
                    case "FireMinor": Gdip_DrawEllipse(G, brushes.pPenFireMinor, mobScreenPos.x-3, mobScreenPos.y-3, brushes.minorDotSize, brushes.minorDotSize/2)
                    case "IceMajor": Gdip_DrawEllipse(G, brushes.pPenIceMajor, mobScreenPos.x-3, mobScreenPos.y-3, brushes.majorDotSize, brushes.majorDotSize/2)
                    case "IceMinor": Gdip_DrawEllipse(G, brushes.pPenIceMinor, mobScreenPos.x-3, mobScreenPos.y-3, brushes.minorDotSize, brushes.minorDotSize/2)
                    case "LightMajor": Gdip_DrawEllipse(G, brushes.pPenLightMajor, mobScreenPos.x-3, mobScreenPos.y-3, brushes.majorDotSize, brushes.majorDotSize/2)
                    case "LightMinor": Gdip_DrawEllipse(G, brushes.pPenLightMinor, mobScreenPos.x-3, mobScreenPos.y-3, brushes.minorDotSize, brushes.minorDotSize/2)
                    case "PoisonMajor": Gdip_DrawEllipse(G, brushes.pPenPoisonMajor, mobScreenPos.x-3, mobScreenPos.y-3, brushes.majorDotSize, brushes.majorDotSize/2)
                    case "PoisonMinor": Gdip_DrawEllipse(G, brushes.pPenPoisonMinor, mobScreenPos.x-3, mobScreenPos.y-3, brushes.minorDotSize, brushes.minorDotSize/2)
                    case "MagicMajor": Gdip_DrawEllipse(G, brushes.pPenMagicMajor, mobScreenPos.x-3, mobScreenPos.y-3, brushes.majorDotSize, brushes.majorDotSize/2)
                    case "MagicMinor": Gdip_DrawEllipse(G, brushes.pPenMagicMinor, mobScreenPos.x-3, mobScreenPos.y-3, brushes.minorDotSize, brushes.minorDotSize/2)
                }
            }
            oldmobScreenPosx:=mobScreenPos.x
            oldmobScreenPosy:=mobScreenPos.y
        }
    }
    

}