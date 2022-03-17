#SingleInstance, Force
SendMode Input
SetWorkingDir, %A_ScriptDir%

drawExits(ByRef unitsLayer, ByRef settings, ByRef gameMemoryData, ByRef imageData, ByRef serverScale, ByRef scale, ByRef padding, ByRef Width, ByRef Height, ByRef scaledWidth, ByRef scaledHeight, ByRef centerLeftOffset, ByRef centerTopOffset, xPosDot, yPosDot) {

    ; ;draw exit lines
    exitsHeader := imageData["exits"]
    if (!settings["centerMode"]) {
        hexOpacity := Round(settings["opacity"] * 255)
        SetFormat, integer, hex
        hexOpacity += 0
        StringTrimLeft, hexOpacity, hexOpacity, 2

    } else {
        hexOpacity := Round(settings["centerModeOpacity"] * 255)
        SetFormat, integer, hex
        hexOpacity += 0
        StringTrimLeft, hexOpacity, hexOpacity, 2
    }
    exitTextColor := hexOpacity . "ffffff"
    exitTextColorShadow := hexOpacity . "000000"
    exitTextSize := settings["exitTextSize"] * scale
    if (exitsHeader) {
        Loop, parse, exitsHeader, `|
        {
            exitArray := StrSplit(A_LoopField, ",")
            ;exitArray[1] ; id of exit
            ;exitArray[2] ; name of exit
            if (exitArray[2] == "Ancient Summit") {
                exitArray[2] := "Arreat Summit"
            }
            if (exitArray[2] == "The Ancients Way") {
                exitArray[2] := "Ancients' Way"
            }
            if (exitArray[2] == "The Drifter Cavern") {
                exitArray[2] := "Echo Chamber"
            }

            exitName := localizedStrings[exitArray[2]]
            ,exitX := (exitArray[3] * serverScale) + padding
            ,exitY := (exitArray[4] * serverScale) + padding
            ,correctedPos := correctPos(settings, exitX, exitY, (Width/2), (Height/2), scaledWidth, scaledHeight, scale)
            ,exitX := correctedPos["x"] + centerLeftOffset
            ,exitY := correctedPos["y"] + centerTopOffset
            drawFloatingText(unitsLayer, exitX, exitY-10, exitTextSize, exitTextColor, false, exocetFont, exitName)
        }
    }
}