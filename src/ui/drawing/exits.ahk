#SingleInstance, Force
SendMode Input
SetWorkingDir, %A_ScriptDir%

drawExits(ByRef unitsLayer, settings, gameMemoryData, imageData, serverScale, scale, padding, Width, Height, scaledWidth, scaledHeight, centerLeftOffset, centerTopOffset, xPosDot, yPosDot) {

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
    exitTextSize := 15 * scale
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

            exitName := localizedStrings[exitArray[2]]
            ,exitX := (exitArray[3] * serverScale) + padding
            ,exitY := (exitArray[4] * serverScale) + padding
            ,correctedPos := correctPos(settings, exitX, exitY, (Width/2), (Height/2), scaledWidth, scaledHeight, scale)
            exitX := correctedPos["x"] + centerLeftOffset
            ,exitY := correctedPos["y"] + centerTopOffset
            ,textx := exitX - 400
            ,texty := exitY - 110
            Options = x%textx% y%texty% Center Bold vBottom c%exitTextColor% r8 s%exitTextSize%
            textx := textx + 2
            ,texty := texty + 2
            Options2 = x%textx% y%texty% Center Bold vBottom cff000000 r8 s%exitTextSize%
            Gdip_TextToGraphics(unitsLayer.G, exitName, Options2, diabloFont, 800, 100)
            Gdip_TextToGraphics(unitsLayer.G, exitName, Options, diabloFont, 800, 100)
        }
    }
}