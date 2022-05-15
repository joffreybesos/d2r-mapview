

ReadParty(ByRef d2rprocess, ByRef partyList) {
    partyList := []
    SetFormat Integer, D
    rosterOffset := offsets["rosterOffset"]
    , baseAddress := d2rprocess.BaseAddress + rosterOffset
    , playerUnit := d2rprocess.read(baseAddress, "Int64")
    while (playerUnit > 0) { ; keep following the next pointer
        name := d2rprocess.readString(playerUnit, length := 16)
        , unitId := d2rprocess.read(playerUnit + 0x48, "UInt")
        , area := d2rprocess.read(playerUnit + 0x5C, "UInt")
        , plevel := d2rprocess.read(playerUnit + 0x58, "UShort")
        , partyId := d2rprocess.read(playerUnit + 0x5A, "UShort")
        , xPos := d2rprocess.read(playerUnit + 0x60, "UInt")
        , yPos := d2rprocess.read(playerUnit + 0x64, "UInt")
        player := { "name": name, "unitId": unitId, "area": area, "partyId": partyId, "plevel": plevel, "xPos": xPos, "yPos": yPos }
        partyList.push(player)
        playerUnit := d2rprocess.read(playerUnit + 0x148, "Int64")  ; get next player
    }
}