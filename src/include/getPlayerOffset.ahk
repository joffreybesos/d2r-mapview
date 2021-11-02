#SingleInstance, Force
#Include %A_ScriptDir%\include\classMemory.ahk
#Include %A_ScriptDir%\include\logging.ahk
SetWorkingDir, %A_ScriptDir%

checkLastOffset(startingOffset) {
    return getPlayerOffset(startingOffset, 1)
}

scanForPlayerOffset(startingOffset) {
    WriteLogDebug("Scanning for new player offset address, starting default offset " startingOffset)
    return getPlayerOffset(startingOffset, 256)
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

    found := false
    loop, %loops%
    {
        newOffset := HexAdd(startingOffset, (A_Index - 1) * 8)
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
                    WriteLog("SUCCESS: Found player offset: " newOffset ", from " HexToDec(A_Index /8) " attempts, which gives map seed: " mapSeed)
                }
	            newOffset := newOffset + 0 ;convert to dec
                found := true
                return newOffset
            } else {
                WriteLogDebug("Possible player unit: " playerUnit ", from " HexToDec(A_Index/8) " attempts, but no mapSeed " mapSeed ", ignoring...")
            }
        }
    }
    if (!found && loops > 1) {
        WriteLogDebug("Did not find a player offset after " HexToDec(loops/8) " attempts, likely in game menu")
    }
}

HexAdd(x, y) {
	SetFormat, Integer, hex
	l := (((lx := StrLen(x)) > (ly := StrLen(y))) ? lx : ly) - 2
	return Format("0x{:0" Format("{:d}", l) "x}", x + y)
}

HexToDec(Hex) {
    VarSetCapacity(dec, 66, 0)
    , val := DllCall("msvcrt.dll\_wcstoui64", "Str", hex, "UInt", 0, "UInt", 16, "CDECL Int64")
    , DllCall("msvcrt.dll\_i64tow", "Int64", val, "Str", dec, "UInt", 10, "CDECL")
    return dec
}