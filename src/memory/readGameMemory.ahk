#SingleInstance, Force
#Include %A_ScriptDir%\include\classMemory.ahk
#Include %A_ScriptDir%\include\logging.ahk
SetWorkingDir, %A_ScriptDir%

readGameMemory(playerOffset, startingOffset, ByRef gameMemoryData) {
    
    if (_ClassMemory.__Class != "_ClassMemory")
    {
        WriteLog("Missing classMemory.ahk dependency. Quitting")
        ExitApp
    }

    d2r := new _ClassMemory(gameWindowId, "", hProcessCopy) 

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


    ; monsters
    mobs := []
    monstersOffset := 0x20AF660 + 1024
    Loop, 128
    {
    
        newOffset := monstersOffset + (8 * (A_Index - 1))
        mobAddress := d2r.BaseAddress + newOffset
        mobUnit := d2r.read(mobAddress, "Int64")
        
        if (mobUnit) {
            mobType := d2r.read(mobUnit + 0x00, "UInt")
            txtFileNo := d2r.read(mobUnit + 0x04, "UInt")
            unitId :=  d2r.read(mobUnit + 0x08, "UInt")
            mode := d2r.read(mobUnit + 0x0c, "UInt")
            pUnitData :=  d2r.read(mobUnit + 0x10, "Int64")
            pPath :=  d2r.read(mobUnit + 0x38, "Int64")
            if (mode != 0 && mode != 12) {
                isUnique :=  d2r.read(pUnitData + 0x18, "UShort")
                monx :=  d2r.read(pPath + 0x02, "UShort")
                mony :=  d2r.read(pPath + 0x06, "UShort")
                mob := {"txtFileNo": txtFileNo, "x": monx, "y": mony, "isUnique": isUnique }
                mobs.push(mob)
            }
        }
    }   
    gameMemoryData := {"mapSeed": mapSeed, "difficulty": difficulty, "levelNo": levelNo, "xPos": xPos, "yPos": yPos, "mobs": mobs }
}