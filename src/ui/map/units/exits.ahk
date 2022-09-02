#SingleInstance, Force
SendMode Input
SetWorkingDir, %A_ScriptDir%

drawExits(ByRef G, ByRef brushes, ByRef settings, ByRef gameMemoryData, ByRef mapImage) {
    playerX := gameMemoryData.xPos
    playerY := gameMemoryData.yPos
    renderScale := settings["serverScale"]
    scale := settings["centerModeScale"]

    ; ;draw exit lines
    exitsHeader := mapImage["exits"]

    hexOpacity := Round(settings["centerModeOpacity"] * 255)
    SetFormat, integer, hex
    hexOpacity += 0
    StringTrimLeft, hexOpacity, hexOpacity, 2
    
    exitTextColor := "ffffffff"
    exitTextColorShadow := hexOpacity . "000000"
    exitTextSize := settings["exitTextSize"] * scale
    if (exitsHeader) {
        Loop, parse, exitsHeader, `|
        {
            exitArray := StrSplit(A_LoopField, ",")
            ;exitArray[1] ; id of exit
            ;exitArray[2] ; name of exit
            if (exitArray[2] == "Halls of Pain") {
                exitArray[2] := "Halls of Death's Calling"
            }
            if (exitArray[2] == "Arachnid Cave") {
                exitArray[2] := "Arachnid Lair"
            }
            if (exitArray[2] == "Ancient Summit") {
                exitArray[2] := "Arreat Summit"
            }
            if (exitArray[2] == "The Ancients Way") {
                exitArray[2] := "Ancients' Way"
            }
            if (exitArray[2] == "The Drifter Cavern") {
                exitArray[2] := "Echo Chamber"
            }
            SetFormat Integer, D
            areaLvls := getAreaLevel(exitArray[1])
            , difficulty := gameMemoryData["difficulty"]
            , areaLvl := ""
            if (areaLvls["" difficulty ""]) {
                areaLvl := areaLvls["" difficulty ""]
                areaLvl := " (" areaLvl ")"
            }
            exitName := localizedStrings[exitArray[2]] . areaLvl
            , exitX := exitArray[3] + mapImage.mapOffsetX
            , exitY := exitArray[4] + mapImage.mapOffsetY
            exitScreenPos := World2Screen(playerX, playerY, exitX, exitY, scale)
            
            drawFloatingText(G, brushes, exitScreenPos.x, exitScreenPos.y-10, exitTextSize, exitTextColor, false, true, exocetFont, exitName, true)
        }
    }
}