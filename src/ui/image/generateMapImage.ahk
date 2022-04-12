
generateMapImage(ByRef settings, ByRef areas, ByRef mapId, ByRef imageData) {
    renderScale := 2
    if (settings["centerMode"]) {
        renderScale := settings["serverScale"]
    }
    
    sFile := A_Temp . "\" . areas.mapSeed . "_" . areas.difficulty . "_" . mapId ".bmp"

    area := areas.getArea(mapId, renderScale)
    respHeaders := area.getHeaders()
    area.saveImageToFile(sFile)

    IniRead, levelScale, mapconfig.ini, %mapId%, scale, 1.0
    IniRead, levelxmargin, mapconfig.ini, %mapId%, x, 0
    IniRead, levelymargin, mapconfig.ini, %mapId%, y, 0
    
    if (FileExist(sFile)) {
        WriteLog("Downloaded " imageUrl " to " sFile)
        foundFields := 0
        Loop, Parse, respHeaders, `r`n
        {  
            WriteLogDebug("Response Header: " A_LoopField)
            
            field := StrSplit(A_LoopField, ":")
            switch (field[1]) {
                case "lefttrimmed": leftTrimmed := Trim(field[2]), foundFields++
                case "toptrimmed": topTrimmed := Trim(field[2]), foundFields++
                case "offsetx": mapOffsetX := Trim(field[2]), foundFields++
                case "offsety": mapOffsety := Trim(field[2]), foundFields++
                case "mapwidth": mapwidth := Trim(field[2]), foundFields++
                case "mapheight": mapheight := Trim(field[2]), foundFields++
                case "exits": exits := Trim(field[2]), foundFields++
                case "waypoint": waypoint := Trim(field[2]), foundFields++
                case "bosses": bosses := Trim(field[2]), foundFields++
                case "quests": quests := Trim(field[2]), foundFields++
                case "prerotated": prerotated := convertToBool(field[2]), foundFields++
                case "originalwidth": originalwidth := Trim(field[2]), foundFields++
                case "originalheight": originalheight := Trim(field[2]), foundFields++
            }
        }
        if (foundFields < 9) {
            WriteLog("ERROR: Did not find all expected response headers, turn on debug mode to view. Unexpected behaviour may occur")
        }
    }
    
    imageData := { "sFile": sFile, "leftTrimmed" : leftTrimmed, "topTrimmed" : topTrimmed, "levelScale": levelScale, "levelxmargin": levelxmargin, "levelymargin": levelymargin, "mapOffsetX" : mapOffsetX, "mapOffsety" : mapOffsety, "mapwidth" : mapwidth, "mapheight" : mapheight, "exits": exits, "waypoint": waypoint, "bosses": bosses, "quests": quests, "prerotated": prerotated, "originalwidth": originalwidth, "originalheight": originalheight }
} 

