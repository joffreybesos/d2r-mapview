#SingleInstance, Force
#Include %A_ScriptDir%\include\classMemory.ahk
#Include %A_ScriptDir%\include\logging.ahk
SetWorkingDir, %A_ScriptDir%

readGameMemory(playerOffset, ByRef gameMemoryData) {
    
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
    }

    ; get the map seed
    startingAddress := d2r.BaseAddress + playerOffset
    playerUnit := d2r.read(startingAddress, "Int64")

    ; get the map seed
    pAct := playerUnit + 0x20
    actAddress := d2r.read(pAct, "Int64")
    
    if (actAddress) {
        mapSeedAddress := actAddress + 0x14
        if (mapSeedAddress) {
            mapSeed := d2r.read(mapSeedAddress, "UInt")
            ;WriteLogDebug("Found seed " mapSeed " at address " mapSeedAddress)
        } else {
            WriteLogDebug("Did not find seed " mapSeed " at address " mapSeedAddress)
        }
    }

    ; get the level number
    actAddress := d2r.read(pAct, "Int64")
    pActUnk1 := actAddress +  0x70
    aActUnk2 := d2r.read(pActUnk1, "Int64")
    aDifficulty := aActUnk2 + 0x830
    difficulty := d2r.read(aDifficulty, "UShort")

    if ((difficulty != 0) & (difficulty != 1) & (difficulty != 2)) {
        WriteLog("Did not find " difficulty " difficulty at " aDifficulty " using player offset " playerOffset)    
    }

    ; player position
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
    ;WriteLog("Map Seed " mapSeed)
    gameMemoryData := {"mapSeed": mapSeed, "difficulty": difficulty, "levelNo": levelNo, "xPos": xPos, "yPos": yPos }
}