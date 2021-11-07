#SingleInstance, Force
#Include %A_ScriptDir%\include\classMemory.ahk
#Include %A_ScriptDir%\include\logging.ahk
SetWorkingDir, %A_ScriptDir%

getPlayerPosition(playerOffset) {
    
    if (_ClassMemory.__Class != "_ClassMemory")
    {
        WriteLog("Missing classMemory.ahk dependency. Quitting")
        ExitApp
    }

    d2r := new _ClassMemory("ahk_exe D2R.exe", "", hProcessCopy) 

    if !isObject(d2r) 
    {
        WriteLog("D2R.exe not found, please make sure game is running first")
        ExitApp
    }

    ;WriteLog("Looking for Level No address at player offset " playerOffset)
    startingAddress := d2r.BaseAddress + playerOffset
    playerUnit := d2r.read(startingAddress, "Int64")

    ; get the level number
    pPath := playerUnit + 0x38
    pathAddress := d2r.read(pPath, "Int64")
    xPosAddress := pathAddress +  0x02
    yPosAddress := pathAddress +  0x06
    xPos := d2r.read(xPosAddress, "UShort")
    yPos := d2r.read(yPosAddress, "UShort")

    if (!xPos) {
        WriteLog("Did not find position at " xPosAddress " using player offset " playerOffset)    
    }
    if (!yPos) {
        WriteLog("Did not find position at " xPosAddress " using player offset " playerOffset)    
    }
    ;WriteLog("XPos " xPos " yPos " yPos)

    positionArray := []
    positionArray[0] := xPos
    positionArray[1] := yPos
    return positionArray
}