

ReadOtherPlayers(ByRef d2rprocess, startingOffset, ByRef otherPlayers, ByRef partyList) {
    otherPlayers := []
    SetFormat Integer, D

    found := false
    , baseAddress := d2rprocess.BaseAddress + startingOffset
    , d2rprocess.readRaw(baseAddress, unitTableBuffer, 128*8)
    loop, 128
    {
        ;WriteLogDebug("Attempt " A_Index " with starting offset " startingOffset)
        offset := (8 * (A_Index - 1))
        , playerUnit := NumGet(&unitTableBuffer , offset, "Int64")
        while (playerUnit > 0) { ; keep following the next pointer
            pInventory := playerUnit + 0x90
            , inventory := d2rprocess.read(pInventory, "Int64")
            if (inventory) {
                unitId := d2rprocess.read(playerUnit + 0x08, "UInt")
                , pathAddress := d2rprocess.read(playerUnit + 0x38, "Int64")
                , xPos := d2rprocess.read(pathAddress + 0x02, "UShort")
                , yPos := d2rprocess.read(pathAddress + 0x06, "UShort")
                , xPosOffset := d2rprocess.read(pathAddress + 0x00, "UShort") 
                , yPosOffset := d2rprocess.read(pathAddress + 0x04, "UShort")
                , xPosOffset := xPosOffset / 65536   ; get percentage
                , yPosOffset := yPosOffset / 65536   ; get percentage
                , xPos := xPos + xPosOffset
                , yPos := yPos + yPosOffset
                , playerNameAddress := d2rprocess.read(playerUnit + 0x10, "Int64")
                , playerName := d2rprocess.readString(playerNameAddress, length := 0)
                isCorpse := d2rprocess.read(playerUnit + 0x1A6, "UChar") == "1" ? true : false
                if (xPos > 1 and yPos > 1) {
                    SetFormat Integer, D
                    otherPlayers.push({ "player": A_Index, "unitId": unitId, "playerName": playerName, "isCorpse": isCorpse, "x": xPos, "y": yPos})
                }
            }
            playerUnit := d2rprocess.read(playerUnit + 0x150, "Int64")  ; get next player
        }
    }
    for k, partyPlayer in partyList
    {
        found := false
        for j, unitPlayer in otherPlayers
        {
            if (partyPlayer.unitId == unitPlayer.unitId) {
                found := true
            }
        }
        if (!found) {
            otherPlayers.push({ "player": A_Index, "unitId": unitId, "playerName": partyPlayer.name, "isCorpse": 0, "x": partyPlayer.xPos, "y": partyPlayer.yPos})
        }
    }
    SetFormat Integer, D

}