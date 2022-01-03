#SingleInstance, Force
SendMode Input
SetWinDelay, 0
SetBatchLines, -1
SetWorkingDir, %A_ScriptDir%
#Include %A_ScriptDir%\include\logging.ahk
#Include %A_ScriptDir%\memory\initMemory.ahk
#Include %A_ScriptDir%\memory\scanForPlayer.ahk
#Include %A_ScriptDir%\memory\patternScan.ahk
#Include %A_ScriptDir%\readSettings.ahk

readSettings(settings.ini, settings)
; performanceMode := settings["performanceMode"]
; if (performanceMode != 0) {
;     SetBatchLines, %performanceMode%
; }
global debug := settings["debug"]
global gameWindowId := settings["gameWindowId"]

; initialise memory reading
d2rprocess := initMemory(gameWindowId)
patternScan(d2rprocess, settings)
playerOffset := settings["playerOffset"]
startingOffset := settings["playerOffset"]
uiOffset := settings["uiOffset"]

; scan for the player offset
playerOffset := scanForPlayer(d2rprocess, playerOffset, startingOffset, settings)
mapData := []
uiData := []

mapData["mapOffsetX"] := 3480
mapData["mapOffsetY"] := 4360
uiData["scaledWidth"] := 5851.730333
uiData["scaledHeight"] := 2925.867712
uiData["sizeWidth"] := 1905
uiData["sizeHeight"] := 4180
mapHwnd1 := 0x210c9c
unitHwnd1 := 0x4f0ac4


While 1 {
    readGameMemory(d2rprocess, settings, playerOffset, gameMemoryData)
    ;WriteLog(gameMemoryData["xPos"] " " gameMemoryData["yPos"])
    MovePlayerMap(settings, mapHwnd1, unitHwnd1, gameMemoryData, mapData, uiData)
    ;sleep, 100
}

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
    ; WriteLog(gameMemoryData["xPos"] " " gameMemoryData["yPos"] " " mapData["mapOffsetX"] " " mapData["mapOffsetY"] " " Width " " Height " " scaledWidth " " scaledHeight)
    
    correctedPos := findNewPos(xPosDot, yPosDot, (Width/2), (Height/2), scaledWidth, scaledHeight, scale)

    xPosDot := correctedPos["x"] 
    yPosDot := correctedPos["y"] 
    ;WriteLog(xPosDot " " yPosDot " " leftMargin " " topMargin " " scaledWidth " " scaledHeight " " gameMemoryData["xPos"] " " gameMemoryData["yPos"])

    leftMargin := (A_ScreenWidth/2) - xPosDot + settings["centerModeXoffset"]
    topMargin := (A_ScreenHeight/2) - yPosDot + settings["centerModeYoffset"]
    
    lastLeftMargin := X
    lastTopMargin := Y

    ; leftMarginDiff := (X - leftMargin) / 3
    ; topMarginDiff := (Y - topMargin) / 3
    ; leftMargin := leftMargin + leftMarginDiff
    ; topMargin := topMargin + topMarginDiff
    WinMove, ahk_id %mapHwnd1%,, leftMargin, topMargin
    ;WinMove, ahk_id %unitHwnd1%,, leftMargin, topMargin
} 



; converting to cartesian to polar and back again sucks
; I wish my matrix transformations worked
findNewPos(xPosDot, yPosDot, centerX, centerY, RWidth, RHeight, scale) {
    newAngle := findAngle(xPosDot, yPosDot, centerX, centerY) + 45
    distance := getDistanceFromCoords(xPosDot, yPosDot, centerX, centerY) * scale
    newPos := getPosFromAngle((RWidth/2),(RHeight/2),distance,newAngle)
    newPos["y"] := (RHeight/2) + ((RHeight/2) - newPos["y"]) /2
    return newPos
}


findAngle(xPosDot, yPosDot, midW, midH) {
    Pi := 4 * ATan(1)
    Conversion := -180 / Pi  ; Radians to deg.
    Angle2 := DllCall("msvcrt.dll\atan2", "Double", yPosDot-midH, "Double", xPosDot-midW, "CDECL Double") * Conversion
    if (Angle2 < 0)
        Angle2 += 360
    return Angle2
}

getDistanceFromCoords(x2,y2,x1,y1){
    return sqrt((y2-y1)**2+(x2-x1)**2)
}

getPosFromAngle(x1,y1,len,ang){
	ang:=(ang-90) * 0.0174532925
	return {"x": x1+len*cos(ang),"y": y1+len*sin(ang)}
}

readGameMemory(d2rprocess, settings, playerOffset, ByRef gameMemoryData) {
    StartTime := A_TickCount
    startingOffset := settings["playerOffset"]  ;default offset
    
    ;WriteLog("Looking for Level No address at player offset " playerOffset)
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

    gameMemoryData := {"xPos": xPos, "yPos": yPos } 
}

Esc::
ExitApp
return