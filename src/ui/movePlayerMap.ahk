#SingleInstance, Force
SendMode Input
SetWorkingDir, %A_ScriptDir%


MovePlayerMap(settings, mapHwnd1, unitHwnd1, gameMemoryData, mapData, uiData) {
    padding := 150
    serverScale := settings["serverScale"]
    scale := settings["centerModeScale"]
    WinGetPos, X, Y, Width, Height, ahk_id %mapHwnd1%

    Width := uiData["sizeWidth"]
    Height := uiData["sizeHeight"]
    scaledWidth := uiData["scaledWidth"]
    scaledHeight := uiData["scaledHeight"]
    ; get relative position of player in world
    ; xpos is absolute world pos in game
    ; each map has offset x and y which is absolute world position
    xPosDot := ((gameMemoryData["xPos"] - mapData["mapOffsetX"]) * serverScale) + padding
    yPosDot := ((gameMemoryData["yPos"] - mapData["mapOffsetY"]) * serverScale) + padding
    
    correctedPos := findNewPos(xPosDot, yPosDot, (Width/2), (Height/2), scaledWidth, scaledHeight, scale)
    xPosDot := correctedPos["x"] ; + 228  ; TOFIX
    yPosDot := correctedPos["y"] ;+ 215  ; TOFIX
    
    leftMargin := (A_ScreenWidth/2) - xPosDot
    topMargin := (A_ScreenHeight/2) - yPosDot -20
    ; leftMargin := 0
    ; topMargin := 0
    ;WriteLog(xPosDot " " yPosDot " " leftMargin " " topMargin " " scaledWidth " " scaledHeight)
    WinMove, ahk_id %mapHwnd1%,, leftMargin, topMargin
    WinMove, ahk_id %unitHwnd1%,, leftMargin, topMargin
}