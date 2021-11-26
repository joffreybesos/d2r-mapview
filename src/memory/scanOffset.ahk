#SingleInstance, Force
#Include %A_ScriptDir%\include\classMemory.ahk
#Include %A_ScriptDir%\include\logging.ahk
SetWorkingDir, %A_ScriptDir%

scanOffset(lastOffset, startingOffset, uiOffset) {
    ; check the one that previously worked, it's likely not checkLastOffset()
    playerOffset := checkLastOffset(lastOffset, uiOffset)
    if (playerOffset) {
        ;WriteLogDebug("Using last offset " playerOffset " " lastOffset)
        return playerOffset
    }
    ; if the last offset doesn't seem valid anymore then you're in the menu or a new game
    return scanForPlayerOffset(startingOffset, uiOffset)
}

checkLastOffset(startingOffset, uiOffset) {
    return getPlayerOffset(startingOffset, 1, uiOffset)
}

scanForPlayerOffset(startingOffset, uiOffset) {
    ;WriteLogDebug("Scanning for new player offset address, starting default offset " startingOffset)
    return getPlayerOffset(startingOffset, 128, uiOffset)
}

getPlayerOffset(startingOffset, loops, uiOffset) {

    if (_ClassMemory.__Class != "_ClassMemory")
    {
        WriteLog("Missing classMemory.ahk dependency. Quitting")
        ExitApp
    }

    d2r := new _ClassMemory(gameWindowId, "", hProcessCopy) 

    if !isObject(d2r) 
    {
        WriteLog(gameWindowId " not found, please make sure game is running first")
        WriteTimedLog()
        ExitApp
    }
    expOffset := uiOffset + 0x13

    found := false
    loop, %loops%
    {
        ;WriteLogDebug("Attempt " A_Index " with starting offset " startingOffset)
        newOffset := HexAdd(startingOffset, (A_Index - 1) * 8)
        startingAddress := d2r.BaseAddress + newOffset
        playerUnit := d2r.read(startingAddress, "Int64")
        if (playerUnit) {
            pInventory := playerUnit + 0x90
            inventory := d2r.read(pInventory, "Int64")
            if (inventory) {
                
                expChar := d2r.read(d2r.BaseAddress + expOffset, "UShort")
                basecheck := (d2r.read(inventory + 0x30, "UShort")) != 1
                if (expChar) {
                    basecheck := (d2r.read(inventory + 0x70, "UShort")) != 0
                }
                
                if (basecheck) {
                    pAct := playerUnit + 0x20
                    actAddress := d2r.read(pAct, "Int64")
                    mapSeedAddress := actAddress + 0x14
                    mapSeed := d2r.read(mapSeedAddress, "UInt")

                    pPath := playerUnit + 0x38
                    pathAddress := d2r.read(pPath, "Int64")
                    xPos := d2r.read(pathAddress + 0x02, "UShort")
                    yPos := d2r.read(pathAddress + 0x06, "UShort")

                    pUnitData := playerUnit + 0x10
                    playerNameAddress := d2r.read(pUnitData, "Int64")
                    name :=
                    Loop, 16
                    {
                        name := name . Chr(d2r.read(playerNameAddress + (A_Index -1), "UChar"))
                    }
                    if (xPos > 0 and yPos > 0 and StrLen(mapSeed) > 6) {
                        SetFormat Integer, D
                        if (A_Index > 1) {
                            WriteLog("SUCCESS: Found player " name " offset: " newOffset ", from " A_Index " attempts, which gives map seed: " mapSeed)
                        }
                        newOffset := newOffset + 0 ;convert to decimal
                        found := true
                        return newOffset
                    } else {
                        WriteLogDebug("Found possible player " name " offset: " newOffset ", from " A_Index " attempts, which gives map seed: " mapSeed)
                    }
                }
            }
        }
    }
    if (!found && loops > 1) {
        WriteLogDebug("Did not find a player offset after " loops "(128) attempts, likely in game menu. If you are seeing this incorrectly, try starting a new game.")
    }
}

; yes, you really have to do this in AHK to add two hex values reliably
HexAdd(x, y) {
    SetFormat, Integer, hex
    l := (((lx := StrLen(x)) > (ly := StrLen(y))) ? lx : ly) - 2
    return Format("0x{:0" Format("{:d}", l) "x}", x + y)
}

