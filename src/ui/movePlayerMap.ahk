#SingleInstance, Force
SendMode Input
SetWorkingDir, %A_ScriptDir%

global lastLeftMargin := 0
global lastTopMargin := 0

MovePlayerMap(ByRef settings, ByRef d2rprocess, ByRef pathAddress, ByRef imageData, ByRef uiData) {

    ; player position
    d2rprocess.readRaw(pathAddress, pPathBuffer, 16)
    , xPosOffset := NumGet(&pPathBuffer , 0x00, "UShort")
    , xPos := NumGet(&pPathBuffer , 0x02, "UShort")
    , yPosOffset := NumGet(&pPathBuffer , 0x04, "UShort")
    , yPos := NumGet(&pPathBuffer , 0x06, "UShort")
    , xPos := xPos + (xPosOffset / 65536)   ; get percentage
    , yPos := yPos + (yPosOffset / 65536)   ; get percentage

    ; calculate new position
    , padding := settings["padding"]
    , serverScale := settings["serverScale"]
    , scale := settings["centerModeScale"]
    WinGetPos, X, Y, Width, Height, ahk_id %mapHwnd1%

    Width := uiData["sizeWidth"]
    , Height := uiData["sizeHeight"]
    , scaledWidth := uiData["scaledWidth"]
    , scaledHeight := uiData["scaledHeight"]
    ; get relative position of player in world
    ; xpos is absolute world pos in game
    ; each map has offset x and y which is absolute world position
    , xPosDot := ((xPos - imageData["mapOffsetX"]) * serverScale) + padding
    , yPosDot := ((yPos - imageData["mapOffsetY"]) * serverScale) + padding
    , correctedPos := findNewPos(xPosDot, yPosDot, (Width/2), (Height/2), scaledWidth, scaledHeight, scale)
    , xPosDot := correctedPos["x"] 
    , yPosDot := correctedPos["y"] 

    ; ToolTip, % "`n`n`n`" xPosDot " " yPosDot

    WinGetPos, windowLeftMargin, windowTopMargin , gameWidth, gameHeight, %gameWindowId% 
    leftMargin := (gameWidth/2) - xPosDot + (settings["centerModeXoffset"] /2) + windowLeftMargin
    , topMargin := (gameHeight/2) - yPosDot + (settings["centerModeYoffset"] /2) + windowTopMargin
    , regionWidth := gameWidth
    , regionHeight := gameHeight
    , regionX := 0 - leftMargin
    , regionY := 0 - topMargin
    if (leftMargin > 0) {
        regionX := windowLeftMargin
        regionWidth := gameWidth - leftMargin
    }
    if (topMargin > 0) {
        regionY := windowTopMargin
        regionHeight := gameHeight - topMargin
    }

    
    leftDiff :=  lastLeftMargin - leftMargin
    topDiff :=  lastTopMargin - topMargin

    ; when moving by a large amount, just update straight away
    if (leftDiff > 20 or topDiff > 20) {
        leftDiff := 0
        topDiff := 0
    }

    if (lastLeftMargin == 0) {
        leftDiff := 0
        topDiff := 0
    }
    ;ToolTip % "`n`n`n`n`n`n" leftDiff " " topDiff
    ; leftDiff :=  0
    ; topDiff :=  0

    WinGetPos, X1, Y1, , , ahk_id %mapHwnd1%
    WinGetPos, X2, Y2, , , ahk_id %mapHwnd2%
    WinGetPos, X3, Y3, , , ahk_id %mapHwnd3%
    WinGetPos, X4, Y4, , , ahk_id %mapHwnd4%
    WinGetPos, X5, Y5, , , ahk_id %mapHwnd5%
    WinGetPos, X6, Y6, , , ahk_id %mapHwnd6%
    WinGetPos, X7, Y7, , , ahk_id %mapHwnd7%
    WinGetPos, X8, Y8, , , ahk_id %mapHwnd8%
    WinGetPos, X9, Y9, , , ahk_id %mapHwnd9%
    if (ticktock == 6) {
        OutputDebug, % X1 "," Y1 " " X2 "," Y2 " " X3 "," Y3 " " X4 "," Y4 " " X5 "," Y5 " " X6 "," Y6 " " X7 "," Y7 " " X8 "," Y8 " " X9 "," Y9 "`n"
    }

    newX := Round(leftMargin + (leftDiff/2))
    newY := Round(topMargin + (topDiff/2))
    newXdiff := newX - X1
    newYdiff := newY - Y1
    WinMove, ahk_id %mapHwnd1%,, newX, newY
    WinMove, ahk_id %mapHwnd2%,, X2 + newXdiff, Y2 + newYdiff
    WinMove, ahk_id %mapHwnd3%,, X3 + newXdiff, Y3 + newYdiff
    WinMove, ahk_id %mapHwnd4%,, X4 + newXdiff, Y4 + newYdiff
    WinMove, ahk_id %mapHwnd5%,, X5 + newXdiff, Y5 + newYdiff
    WinMove, ahk_id %mapHwnd6%,, X6 + newXdiff, Y6 + newYdiff
    WinMove, ahk_id %mapHwnd7%,, X7 + newXdiff, Y7 + newYdiff
    WinMove, ahk_id %mapHwnd8%,, X8 + newXdiff, Y8 + newYdiff
    WinMove, ahk_id %mapHwnd9%,, X9 + newXdiff, Y9 + newYdiff

    
    ;WinMove, ahk_id %unitHwnd1%,, leftMargin + (leftDiff/2), topMargin + (topDiff/2)
    ;WinMove, ahk_id %unitHwnd1%,, 0, 0
    lastLeftMargin := leftMargin
    lastTopMargin := topMargin

} 