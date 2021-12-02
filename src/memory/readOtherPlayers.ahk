#SingleInstance, Force
SendMode Input
SetWorkingDir, %A_ScriptDir%
#Include %A_ScriptDir%\include\classMemory.ahk

ReadOtherPlayers(d2r, startingOffset, playerName, ByRef otherPlayers) {
    otherPlayers := []
    SetFormat Integer, D

    found := false
    loop, 128
    {
        ;WriteLogDebug("Attempt " A_Index " with starting offset " startingOffset)
        newOffset := HexAdd(startingOffset, (A_Index - 1) * 8)
        startingAddress := d2r.BaseAddress + newOffset
        playerUnit := d2r.read(startingAddress, "Int64")
        while (playerUnit > 0) { ; keep following the next pointer
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
                    if (xPos > 0 and yPos > 0) {
                        SetFormat Integer, D
                        ;WriteLog("SUCCESS: Found other player: " name " " newOffset ", at " A_Index " position " xPos " " yPos)
                        otherPlayers.push({ "player": A_Index, "playerName": name, "x": xPos, "y": yPos})
                    }
                }
            }
            playerUnit := d2r.read(playerUnit + 0x150, "Int64")  ; get next player
        }
    }
    SetFormat Integer, D

}