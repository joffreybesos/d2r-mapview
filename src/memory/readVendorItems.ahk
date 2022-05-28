

ReadVendorItems(ByRef d2rprocess, startingOffset, ByRef levelNo, ByRef vendorItems) {
    ; items
    vendorItems := []
    SetFormat Integer, D
    if (levelNo == 1 or levelNo == 40 or levelNo == 75 or levelNo == 103 or levelNo == 109) { ; only in town
        baseAddress := d2rprocess.BaseAddress + startingOffset + (4 * 1024)
        , d2rprocess.readRaw(baseAddress, unitTableBuffer, 128*8)
        Loop, 128
        {
            offset := (8 * (A_Index - 1))
            , itemUnit := NumGet(&unitTableBuffer , offset, "Int64")
            while (itemUnit > 0) { ; keep following the next pointer
                d2rprocess.readRaw(itemUnit, itemStructData, 144)
                , itemType := NumGet(&itemStructData , 0x00, "UInt")
                , txtFileNo := NumGet(&itemStructData , 0x04, "UInt")
                , name := getItemBaseName(txtFileNo)
                if (itemType == 4) { ; item is 4
                    if (txtFileNo < 508) {  ; ignore scrolls/potions etc
                        ;itemLoc - 0 in inventory, 1 equipped, 2 in belt, 3 on ground, 4 cursor, 5 dropping, 6 socketed
                        itemLoc := NumGet(&itemStructData , 0x0C, "UInt")
                        if (itemLoc == 3 or itemLoc == 5 or itemLoc == 0) { ; on ground, dropping or vendor
                            pUnitDataPtr := NumGet(&itemStructData , 0x10, "Int64")
                            ; invPage := d2rprocess.read(pUnitDataPtr + 0x55, "UChar")
                            d2rprocess.readRaw(pUnitDataPtr, pUnitData, 144)
                            , flags := NumGet(&pUnitData, 0x18, "UInt")
                            if (itemLoc == 0 and (0x00002000 & flags)) {
                                itemQuality := NumGet(&pUnitData, 0x00, "UInt")
                                , dwOwnerId := NumGet(&pUnitData, 0x0C, "UInt")
                                , uniqueOrSetId := NumGet(&pUnitData, 0x34, "UInt")
                                , pPathPtr := NumGet(&itemStructData , 0x38, "Int64")
                                , d2rprocess.readRaw(pPathPtr, pPath, 144)
                                , itemx := NumGet(&pPath , 0x10, "UShort")
                                , itemy := NumGet(&pPath , 0x14, "UShort")
                                , pStatsListExPtr := NumGet(&itemStructData , 0x88, "Int64")
                                d2rprocess.readRaw(pStatsListExPtr, pStatsListEx, 144)
                                , statPtr := NumGet(&pStatsListEx , 0x30, "Int64")
                                , statCount := NumGet(&pStatsListEx , 0x38, "Int64")
                                , statExPtr := NumGet(&pStatsListEx , 0x80, "Int64")
                                , statExCount := NumGet(&pStatsListEx , 0x88, "Int64")
                                , item := new GameItem(txtFileNo, itemQuality, uniqueOrSetId)
                                , item.name := name
                                , item.itemLoc := itemLoc
                                , item.itemx := itemx
                                , item.itemy := itemy
                                , item.inStore := true
                                , item.statPtr := statPtr
                                , item.statCount := statCount
                                , item.statExPtr := statExPtr
                                , item.statExCount := statExCount
                                , item.calculateFlags(flags)
                                , vendorItems.push(item)
                            }
                        }
                    }
                }
                itemUnit := d2rprocess.read(itemUnit + 0x150, "Int64")  ; get next item
            }
        } 
    }
    SetFormat Integer, D
}
