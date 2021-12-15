#SingleInstance, Force
SendMode Input
SetWorkingDir, %A_ScriptDir%


MovePlayerMap(settings, mapHwnd1, gameMemoryData, mapData, uiData) {
    padding := 150
    serverScale := 5
    scale := 1.36
    WinGetPos, X, Y, Width, Height, ahk_id %mapHwnd1%

    scaledWidth := uiData["scaledWidth"]
    scaledHeight := uiData["scaledHeight"]
    ; get relative position of player in world
    ; xpos is absolute world pos in game
    ; each map has offset x and y which is absolute world position
    xPosDot := ((gameMemoryData["xPos"] - mapData["mapOffsetX"]) * serverScale) + padding
    yPosDot := ((gameMemoryData["yPos"] - mapData["mapOffsetY"]) * serverScale) + padding
    
    correctedPos := findNewPos(xPosDot, yPosDot, (Width/2), (Height/2), scaledWidth, scaledHeight, scale)
    xPosDot := correctedPos["x"]
    yPosDot := correctedPos["y"]
    
    leftMargin := (A_ScreenWidth/2) - xPosDot
    topMargin := (A_ScreenHeight/2) - yPosDot
    ;WriteLog(xPosDot " " yPosDot " " leftMargin " " topMargin)
    WinMove, ahk_id %mapHwnd1%,, leftMargin, topMargin
}