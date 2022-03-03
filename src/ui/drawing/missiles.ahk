#SingleInstance, Force
SendMode Input
SetWorkingDir, %A_ScriptDir%

drawMissiles(ByRef unitsLayer, settings, gameMemoryData, imageData, serverScale, scale, padding, Width, Height, scaledWidth, scaledHeight, centerLeftOffset, centerTopOffset) {
    static oldMissilex
    static oldMissiley
    
    for index,  missilearray in gameMemoryData["missiles"]
    {   
        for each, missile in missilearray
        {
            missilex := ((missile["x"] - imageData["mapOffsetX"]) * serverScale) + padding
            missiley := ((missile["y"] - imageData["mapOffsetY"]) * serverScale) + padding
            correctedPos := correctPos(settings, missilex, missiley, (Width/2), (Height/2), scaledWidth, scaledHeight, scale)
            missilex := correctedPos["x"] + centerLeftOffset
            missiley := correctedPos["y"] + centerTopOffset
            if (oldMissilex = missilex && oldMissiley = missiley){
            } else {
                switch (missile["UnitType"]) {
                    case "PhysicalMajor": Gdip_DrawEllipse(unitsLayer.G, unitsLayer.pPenPhysicalMajor, missilex-3, missiley-3, unitsLayer.majorDotSize, unitsLayer.majorDotSize/2)
                    case "PhysicalMinor": Gdip_DrawEllipse(unitsLayer.G, unitsLayer.pPenPhysicalMinor, missilex-3, missiley-3, unitsLayer.minorDotSize, unitsLayer.minorDotSize/2)
                    case "FireMajor": Gdip_DrawEllipse(unitsLayer.G, unitsLayer.pPenFireMajor, missilex-3, missiley-3, unitsLayer.majorDotSize, unitsLayer.majorDotSize/2)
                    case "FireMinor": Gdip_DrawEllipse(unitsLayer.G, unitsLayer.pPenFireMinor, missilex-3, missiley-3, unitsLayer.minorDotSize, unitsLayer.minorDotSize/2)
                    case "IceMajor": Gdip_DrawEllipse(unitsLayer.G, unitsLayer.pPenIceMajor, missilex-3, missiley-3, unitsLayer.majorDotSize, unitsLayer.majorDotSize/2)
                    case "IceMinor": Gdip_DrawEllipse(unitsLayer.G, unitsLayer.pPenIceMinor, missilex-3, missiley-3, unitsLayer.minorDotSize, unitsLayer.minorDotSize/2)
                    case "LightMajor": Gdip_DrawEllipse(unitsLayer.G, unitsLayer.pPenLightMajor, missilex-3, missiley-3, unitsLayer.majorDotSize, unitsLayer.majorDotSize/2)
                    case "LightMinor": Gdip_DrawEllipse(unitsLayer.G, unitsLayer.pPenLightMinor, missilex-3, missiley-3, unitsLayer.minorDotSize, unitsLayer.minorDotSize/2)
                    case "PoisonMajor": Gdip_DrawEllipse(unitsLayer.G, unitsLayer.pPenPoisonMajor, missilex-3, missiley-3, unitsLayer.majorDotSize, unitsLayer.majorDotSize/2)
                    case "PoisonMinor": Gdip_DrawEllipse(unitsLayer.G, unitsLayer.pPenPoisonMinor, missilex-3, missiley-3, unitsLayer.minorDotSize, unitsLayer.minorDotSize/2)
                    case "MagicMajor": Gdip_DrawEllipse(unitsLayer.G, unitsLayer.pPenMagicMajor, missilex-3, missiley-3, unitsLayer.majorDotSize, unitsLayer.majorDotSize/2)
                    case "MagicMinor": Gdip_DrawEllipse(unitsLayer.G, unitsLayer.pPenMagicMinor, missilex-3, missiley-3, unitsLayer.minorDotSize, unitsLayer.minorDotSize/2)
                }
            }
            oldMissilex:=missilex
            oldMissiley:=missiley
        }
    }
    

}