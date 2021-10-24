#SingleInstance, Force
#Include %A_ScriptDir%\include\classMemory.ahk
#Include %A_ScriptDir%\include\logging.ahk
SetWorkingDir, %A_ScriptDir%

getMapSeedAddress(playerOffset) {
    
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

    ;WriteLog("Looking for Map Seed address at player offset " playerOffset)
    startingAddress := d2r.BaseAddress + playerOffset
    playerUnit := d2r.read(startingAddress, "Int64")

    ; get the map seed
    pAct := playerUnit + 0x20
    actAddress := d2r.read(pAct, "Int64")
    mapSeedAddress := actAddress + 0x14
    mapSeed := d2r.read(mapSeedAddress, "UInt")
    if (!mapSeed) {
        WriteLog("Did not find map seed at address " mapSeedAddress " using player offset " playerOffset)    
        ExitApp
    }
    ;WriteLog("Found seed " mapSeed " at address " mapSeedAddress)
    
    return mapSeedAddress
}