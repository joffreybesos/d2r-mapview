#SingleInstance, Force
SendMode Input
SetWorkingDir, %A_ScriptDir%

MovePlayerMap(settings, d2rprocess, playerOffset, mapHwnd1, unitHwnd1, imageData, uiData) {
    
    ; read from memory
    startingAddress := d2rprocess.BaseAddress + playerOffset
    playerUnit := d2rprocess.read(startingAddress, "Int64")
    if (!playerUnit) {
        WriteLogDebug("Could not read playerunit from memory")
    }
    ; player position
    pPath := playerUnit + 0x38
    pathAddress := d2rprocess.read(pPath, "Int64")
    xPosAddress := pathAddress + 0x02
    yPosAddress := pathAddress + 0x06
    xPos := d2rprocess.read(xPosAddress, "UShort") 
    yPos := d2rprocess.read(yPosAddress, "UShort")

    ; calculate new position
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
    xPosDot := ((xPos - imageData["mapOffsetX"]) * serverScale) + padding
    yPosDot := ((yPos - imageData["mapOffsetY"]) * serverScale) + padding
    correctedPos := findNewPos(xPosDot, yPosDot, (Width/2), (Height/2), scaledWidth, scaledHeight, scale)
    xPosDot := correctedPos["x"] 
    yPosDot := correctedPos["y"] 

    leftMargin := (A_ScreenWidth/2) - xPosDot + settings["centerModeXoffset"]
    topMargin := (A_ScreenHeight/2) - yPosDot + settings["centerModeYoffset"]
    ; WriteLog(xPosDot " " yPosDot " " leftMargin " " topMargin " " scaledWidth " " scaledHeight)
    
    regionWidth := A_ScreenWidth
    regionHeight := A_ScreenHeight
    regionX := 0 - leftMargin
    regionY := 0 - topMargin
    if (leftMargin > 0) {
        regionX := 0
        regionWidth := A_ScreenWidth - leftMargin
    }
    if (topMargin > 0) {
        regionY := 0
        regionHeight := A_ScreenHeight - topMargin
    }
    WinMove, ahk_id %mapHwnd1%,, leftMargin, topMargin
    WinMove, ahk_id %unitHwnd1%,, leftMargin, topMargin
    
    ; ToolTip % "`n`n`n" leftMargin " " topMargin " " regionWidth " " regionHeight
    ;WinSet, Region, %regionX%-%regionY% W%regionWidth% H%regionHeight%, ahk_id %mapHwnd1%
    
} 