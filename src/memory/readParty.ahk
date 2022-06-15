

ReadParty(ByRef d2rprocess, ByRef partyList, ByRef playerUnitId) {
    partyList := []
    SetFormat Integer, D
    rosterOffset := offsets["rosterOffset"]
    , baseAddress := d2rprocess.BaseAddress + rosterOffset
    , partyStruct := d2rprocess.read(baseAddress, "Int64")
    while (partyStruct > 0) { ; keep following the next pointer
        name := d2rprocess.readString(partyStruct, length := 16)
        , unitId := d2rprocess.read(partyStruct + 0x48, "UInt")
        , area := d2rprocess.read(partyStruct + 0x5C, "UInt")
        , plevel := d2rprocess.read(partyStruct + 0x58, "UShort")
        , partyId := d2rprocess.read(partyStruct + 0x5A, "UShort")
        , xPos := d2rprocess.read(partyStruct + 0x60, "UInt")
        , yPos := d2rprocess.read(partyStruct + 0x64, "UInt")
        , hostilePtr := d2rprocess.read(partyStruct + 0x70, "Int64")
        , isHostileToPlayer := false
        ; while (hostilePtr) {
        ;     hostileUnitId := d2rprocess.read(hostilePtr, "UInt")
        ;     hostileFlag := d2rprocess.read(hostilePtr + 0x04, "UInt")
        ;     hostilePtr := d2rprocess.read(hostilePtr + 0x08, "Int64")
        ;     if (playerUnitId == hostileUnitId) {
        ;         if (hostileFlag > 0) {
        ;             isHostileToPlayer := true
        ;         }
        ;     }
        ; }
        player := { "name": name, "unitId": unitId, "area": area, "partyId": partyId, "plevel": plevel, "xPos": xPos, "yPos": yPos, "isHostileToPlayer": isHostileToPlayer }
        partyList.push(player)
        partyStruct := d2rprocess.read(partyStruct + 0x148, "Int64")  ; get next player
    }
}