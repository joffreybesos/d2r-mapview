#SingleInstance, Force
SendMode Input
SetWorkingDir, %A_ScriptDir%

drawExits(ByRef unitsLayer, ByRef settings, ByRef gameMemoryData, ByRef imageData, ByRef serverScale, ByRef scale, ByRef padding, ByRef Width, ByRef Height, ByRef scaledWidth, ByRef scaledHeight, ByRef centerLeftOffset, ByRef centerTopOffset, xPosDot, yPosDot) {

    ; ;draw exit lines
    exitList := imageData["exits"]
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
    exitTextColor := "ffffffff"
    exitTextColorShadow := hexOpacity . "000000"
    exitTextSize := settings["exitTextSize"] * scale
    if (exitList) {
        for k, exitLabel in exitList
        {
            if (gameMemoryData["levelNo"] == exitLabel.levelNo) {
                exitX := ((exitLabel.x - imageData["mapOffsetX"]) * serverScale) + padding
                , exitY := ((exitLabel.y - imageData["mapOffsetY"]) * serverScale) + padding
                , correctedPos := correctPos(settings, exitX, exitY, (Width/2), (Height/2), scaledWidth, scaledHeight, scale)
                , exitX := correctedPos["x"] + centerLeftOffset
                , exitY := correctedPos["y"] + centerTopOffset
                drawFloatingText(unitsLayer, exitX, exitY-10, exitTextSize, exitTextColor, false, exocetFont, exitLabel.name)
            }
        }
    }
}