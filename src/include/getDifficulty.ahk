#SingleInstance, Force
#Include %A_ScriptDir%\include\classMemory.ahk
#Include %A_ScriptDir%\include\logging.ahk
SetWorkingDir, %A_ScriptDir%

getDifficultyAddress(playerOffset) {
    
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
    pAct := playerUnit + 0x20
    actAddress := d2r.read(pAct, "Int64")
    pActUnk1 := actAddress +  0x70
    aActUnk2 := d2r.read(pActUnk1, "Int64")
    aDifficulty := aActUnk2 + 0x830
    difficulty := d2r.read(aDifficulty, "UShort")

    if (!difficulty) {
        WriteLog("Did not find difficulty at " aDifficulty " using player offset " playerOffset)    
    }
    return aDifficulty
}