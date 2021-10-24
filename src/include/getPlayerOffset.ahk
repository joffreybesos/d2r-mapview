#SingleInstance, Force
#Include %A_ScriptDir%\include\classMemory.ahk
#Include %A_ScriptDir%\include\logging.ahk
SetWorkingDir, %A_ScriptDir%

checkLastOffset(startingOffset) {
    return getPlayerOffset(startingOffset, 1)
}

scanForPlayerOffset(startingOffset) {
    return getPlayerOffset(startingOffset, 1000)
}


getPlayerOffset(startingOffset, loops) {
    
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

    ;WriteLog("Looking for player offset address, starting with offset " startingOffset)

    loop, %loops%
    {
        newOffset := HexAdd(startingOffset, A_Index - 1)
        startingAddress := d2r.BaseAddress + newOffset
        playerUnit := d2r.read(startingAddress, "Int64")
        if (playerUnit) {
            pAct := playerUnit + 0x20
            actAddress := d2r.read(pAct, "Int64")
            mapSeedAddress := actAddress + 0x14
            mapSeed := d2r.read(mapSeedAddress, "UInt")
            if (StrLen(mapSeed) > 7) {
                SetFormat Integer, D
                if (A_Index > 1) {
                    WriteLog("Found player offset: " newOffset ", from " A_Index " attempts, which gives map seed: " mapSeed)
                }
	            newOffset := newOffset + 0
                return newOffset
            }
        }
    }
}

HexAdd(x, y){
	SetFormat, Integer, hex
	l := (((lx := StrLen(x)) > (ly := StrLen(y))) ? lx : ly) - 2
	return Format("0x{:0" Format("{:d}", l) "x}", x + y)
}