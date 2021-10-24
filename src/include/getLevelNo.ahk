#SingleInstance, Force
#Include %A_ScriptDir%\include\classMemory.ahk
#Include %A_ScriptDir%\include\logging.ahk
SetWorkingDir, %A_ScriptDir%

getLevelNoAddress(playerOffset) {
    
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
    pPathAddress := playerUnit + 0x38
    pPath := d2r.read(pPathAddress, "Int64")
    pRoom1 := pPath + 0x20
    pRoom1Address := d2r.read(pRoom1, "Int64")
    pRoom2 := pRoom1Address + 0x18
    pRoom2Address := d2r.read(pRoom2, "Int64")
    pLevel := pRoom2Address + 0x90
    pLevelAddress := d2r.read(pLevel, "Int64")
    dwLevelNo := pLevelAddress + 0x1F8
    levelNo := d2r.read(dwLevelNo, "UInt")
    if (!levelNo) {
        WriteLog("Did not find level num at address " dwLevelNo " using player offset " playerOffset)    
        ExitApp
    }
    ;WriteLog("Found level num " levelNo " at address " dwLevelNo)
    
    return dwLevelNo
}