

IsInGame(ByRef d2rprocess, ByRef startingOffset) {
    SetFormat Integer, D
    baseAddress := d2rprocess.BaseAddress + startingOffset
    , d2rprocess.readRaw(baseAddress, unitTableBuffer, 128*8)
    loop, 128
    {
        ;WriteLogDebug("Attempt " A_Index " with starting offset " startingOffset)
        offset := (8 * (A_Index - 1))
        , playerUnit := NumGet(&unitTableBuffer , offset, "Int64")
        while (playerUnit > 0) { ; keep following the next pointer
            unitId := d2rprocess.read(playerUnit + 0x08, "UInt")
            , pathAddress := d2rprocess.read(playerUnit + 0x38, "Int64")
            , xPos := d2rprocess.read(pathAddress + 0x02, "UShort")
            , yPos := d2rprocess.read(pathAddress + 0x06, "UShort")
            if (unitId and xPos > 1 and yPos > 1) {
                return true
            }
            
            playerUnit := d2rprocess.read(playerUnit + 0x150, "Int64")  ; get next player
        }
    }
    return false
}