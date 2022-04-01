

ReadParty(ByRef d2rprocess, ByRef partyList) {
    partyList := []
    SetFormat Integer, D
    rosterOffset := offsets["rosterOffset"]
    , baseAddress := d2rprocess.BaseAddress + rosterOffset
    , playerUnit := d2rprocess.read(baseAddress + 0x108, "Int64")
    while (playerUnit > 0) { ; keep following the next pointer
        name := d2rprocess.readString(playerUnit, length := 16)
        unitId := d2rprocess.read(playerUnit + 0x18, "UInt")
        area := d2rprocess.read(playerUnit + 0x2C, "UInt")
        player := { "name": name, "unitId": unitId, "area": area }
        partyList.push(player)
        playerUnit := d2rprocess.read(playerUnit + 0x108, "Int64")  ; get next player
    }
}