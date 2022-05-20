
ReadInvItems(ByRef d2rprocess, startingOffset, ByRef HUDItems) {
    
    HUDItems := { idscrolls : 0, tpscrolls : 0, keys : 0 }

    ; items
    SetFormat Integer, D
    items := []
    , baseAddress := d2rprocess.BaseAddress + startingOffset + (4 * 1024)
    , d2rprocess.readRaw(baseAddress, unitTableBuffer, 128*8)
    Loop, 128
    {
        offset := (8 * (A_Index - 1))
        , itemUnit := NumGet(&unitTableBuffer , offset, "Int64")
        while (itemUnit > 0) { ; keep following the next pointer
            d2rprocess.readRaw(itemUnit, itemStructData, 144)
            , itemType := NumGet(&itemStructData , 0x00, "UInt")
            , txtFileNo := NumGet(&itemStructData , 0x04, "UInt")
            
            if (itemType == 4) { ; item is 4
                ;itemLoc - 0 in inventory, 1 equipped, 2 in belt, 3 on ground, 4 cursor, 5 dropping, 6 socketed
                itemLoc := NumGet(&itemStructData , 0x0C, "UInt")
                if (itemLoc == 0) {
                    if (ItemToTrack(txtFileNo)) {
                        pUnitDataPtr := NumGet(&itemStructData , 0x10, "Int64")
                        d2rprocess.readRaw(pUnitDataPtr, pUnitData, 80)
                        ; check if in vendor store
                        , flags := NumGet(&pUnitData, 0x18, "UInt")
                        if (!(0x00002000 & flags)) {
                            
                            ; get quanitity
                            pStatsListExPtr := NumGet(&itemStructData , 0x88, "Int64")
                            , d2rprocess.readRaw(pStatsListExPtr, pStatsListEx, 144)
                            , statPtr := NumGet(&pStatsListEx , 0x30, "Int64")
                            , statCount := NumGet(&pStatsListEx , 0x38, "Int64")
                            , d2rprocess.readRaw(statPtr + 0x2, statBuffer, statCount*8)
                            
                            ; get quantity
                            , statList := ""
                            , quantity := 1
                            Loop, %statCount%
                            {
                                offset := (A_Index -1) * 8
                                statEnum := NumGet(&statBuffer, offset, Type := "UShort")
                                statValue := NumGet(&statBuffer , offset + 0x2, Type := "UInt")
                                switch (statEnum) {
                                    case 70: quantity := statValue
                                }
                            }
                            ; OutputDebug, % quantity " keys found"
                                ; 543 is key
                            ; 529 is TP scroll
                            ; 530 is ID scroll
                            ; 518 is tome of TP
                            ; 519 is tome of ID
                            if (txtFileNo == 543) {
                                HUDItems.keys := HUDItems.keys + quantity
                            } else if (txtFileNo == 529) {
                                HUDItems.tpscrolls := HUDItems.tpscrolls + quantity
                            } else if (txtFileNo == 530) {
                                HUDItems.idscrolls := HUDItems.idscrolls + quantity
                            } else if (txtFileNo == 518) {
                                HUDItems.tpscrolls := HUDItems.tpscrolls + quantity
                            } else if (txtFileNo == 519) {
                                HUDItems.idscrolls := HUDItems.idscrolls + quantity
                            }
                        }
                    }
                }
            }
            itemUnit := d2rprocess.read(itemUnit + 0x150, "Int64")  ; get next item
        }
    } 
    SetFormat Integer, D
}


ItemToTrack(txtFileNo) {
    ; 543 is key
    ; 529 is TP scroll
    ; 530 is ID scroll
    ; 518 is tome of TP
    ; 519 is tome of ID

    switch (txtFileNo) {
        case 543: return true
        case 529: return true
        case 530: return true
        case 518: return true
        case 519: return true
    }
    return false
}