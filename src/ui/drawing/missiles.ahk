#SingleInstance, Force
SendMode Input
SetWorkingDir, %A_ScriptDir%

drawMissiles(ByRef G, settings, gameMemoryData, imageData, serverScale, scale, padding, Width, Height, scaledWidth, scaledHeight, centerLeftOffset, centerTopOffset) {
    missileOpacity := settings["missileOpacity"]
    physicalMajorColor := missileOpacity . settings["missileColorPhysicalMajor"]
    physicalMinorColor := missileOpacity . settings["missileColorPhysicalMinor"]
    fireMajorColor := missileOpacity . settings["missileFireMajorColor"]
    fireMinorColor := missileOpacity . settings["missileFireMinorColor"]
    iceMajorColor := missileOpacity . settings["missileIceMajorColor"]
    iceMinorColor := missileOpacity . settings["missileIceMinorColor"]
    lightMajorColor := missileOpacity . settings["missileLightMajorColor"]
    lightMinorColor := missileOpacity . settings["missileLightMinorColor"]
    poisonMajorColor := missileOpacity . settings["missilePoisonMajorColor"]
    poisonMinorColor := missileOpacity . settings["missilePoisonMinorColor"]
    magicMajorColor := missileOpacity . settings["missileMagicMajorColor"]
    magicMinorColor := missileOpacity . settings["missileMagicMinorColor"]
    
    penSize:=2
    majorDotSize := settings["missileMajorDotSize"]
    minorDotSize := settings["missileMinorDotSize"]
    if (settings["centerMode"]) {
        penSize := penSize * (scale / 1.2)
        majorDotSize := majorDotSize * (scale / 1.1)
        minorDotSize := minorDotSize * (scale / 1.1)
    }
    
    pPenPhysicalMajor := Gdip_CreatePen(physicalMajorColor, penSize)
    pPenPhysicalMinor := Gdip_CreatePen(physicalMinorColor, penSize)
    pPenFireMajor := Gdip_CreatePen(fireMajorColor, penSize)
    pPenFireMinor := Gdip_CreatePen(fireMajorColor, penSize)
    pPenIceMajor := Gdip_CreatePen(iceMajorColor, penSize)
    pPenIceMinor := Gdip_CreatePen(iceMinorColor, penSize)
    pPenLightMajor := Gdip_CreatePen(lightMajorColor, penSize)
    pPenLightMinor := Gdip_CreatePen(lightMinorColor, penSize)
    pPenPoisonMajor := Gdip_CreatePen(poisonMajorColor, penSize)
    pPenPoisonMinor := Gdip_CreatePen(poisonMinorColor, penSize)
    pPenMagicMajor := Gdip_CreatePen(magicMajorColor, penSize)
    pPenMagicMinor := Gdip_CreatePen(magicMinorColor, penSize)
    
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
                    case "PhysicalMajor": Gdip_DrawEllipse(G, pPenPhysicalMajor, missilex-3, missiley-3, majorDotSize, majorDotSize/2)
                    case "PhysicalMinor": Gdip_DrawEllipse(G, pPenPhysicalMinor, missilex-3, missiley-3, minorDotSize, minorDotSize/2)
                    case "FireMajor": Gdip_DrawEllipse(G, pPenFireMajor, missilex-3, missiley-3, majorDotSize, majorDotSize/2)
                    case "FireMinor": Gdip_DrawEllipse(G, pPenFireMinor, missilex-3, missiley-3, minorDotSize, minorDotSize/2)
                    case "IceMajor": Gdip_DrawEllipse(G, pPenIceMajor, missilex-3, missiley-3, majorDotSize, majorDotSize/2)
                    case "IceMinor": Gdip_DrawEllipse(G, pPenIceMinor, missilex-3, missiley-3, minorDotSize, minorDotSize/2)
                    case "LightMajor": Gdip_DrawEllipse(G, pPenLightMajor, missilex-3, missiley-3, majorDotSize, majorDotSize/2)
                    case "LightMinor": Gdip_DrawEllipse(G, pPenLightMinor, missilex-3, missiley-3, minorDotSize, minorDotSize/2)
                    case "PoisonMajor": Gdip_DrawEllipse(G, pPenPoisonMajor, missilex-3, missiley-3, majorDotSize, majorDotSize/2)
                    case "PoisonMinor": Gdip_DrawEllipse(G, pPenPoisonMinor, missilex-3, missiley-3, minorDotSize, minorDotSize/2)
                    case "MagicMajor": Gdip_DrawEllipse(G, pPenMagicMajor, missilex-3, missiley-3, majorDotSize, majorDotSize/2)
                    case "MagicMinor": Gdip_DrawEllipse(G, pPenMagicMinor, missilex-3, missiley-3, minorDotSize, minorDotSize/2)
                }
            }
            oldMissilex:=missilex
            oldMissiley:=missiley
        }
    }
    
    Gdip_DeletePen(pPenPhysicalMajor)
    Gdip_DeletePen(pPenPhysicalMinor)
    Gdip_DeletePen(pPenFireMajor)
    Gdip_DeletePen(pPenFireMinor)
    Gdip_DeletePen(pPenIceMajor)
    Gdip_DeletePen(pPenIceMinor)
    Gdip_DeletePen(pPenLightMajor)
    Gdip_DeletePen(pPenLightMinor)
    Gdip_DeletePen(pPenPoisonMajor)
    Gdip_DeletePen(pPenPoisonMinor)
    Gdip_DeletePen(pPenMagicMajor)
    Gdip_DeletePen(pPenMagicMinor)
}