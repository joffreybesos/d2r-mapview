
ReadInvItems(ByRef d2rprocess, startingOffset, ByRef HUDItems, ByRef unitId) {
    
    HUDItems := { idscrolls : 0, tpscrolls : 0, keys : 0 }

    ; items
    SetFormat Integer, D
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
            
            if (itemType == 4) { ; item is 4
                ;itemLoc - 0 in inventory, 1 equipped, 2 in belt, 3 on ground, 4 cursor, 5 dropping, 6 socketed
                itemLoc := NumGet(&itemStructData , 0x0C, "UInt")
                if (itemLoc == 0) {
                    if (ItemToTrack(txtFileNo)) {
                        pUnitDataPtr := NumGet(&itemStructData , 0x10, "Int64")
                        d2rprocess.readRaw(pUnitDataPtr, pUnitData, 80)
                        ; check if in vendor store
                        , dwOwnerId := NumGet(&pUnitData, 0x0C, "UInt")
                        , flags := NumGet(&pUnitData, 0x18, "UInt")
                        ;, invPage := NumGet(&pUnitData, 0x55, "UChar")
                        invPage := d2rprocess.read(pUnitDataPtr + 0x55, "UChar")
                        , itemQuality := NumGet(&pUnitData, 0x00, "UInt")
                        , uniqueOrSetId := NumGet(&pUnitData, 0x34, "UInt")
                        , flags := NumGet(&pUnitData, 0x18, "UInt")
                        ; , pPathPtr := NumGet(&itemStructData , 0x38, "Int64")
                        ; , d2rprocess.readRaw(pPathPtr, pPath, 144)
                        ; , itemx := NumGet(&pPath , 0x10, "UShort")
                        ; , itemy := NumGet(&pPath , 0x14, "UShort")
                        flagText := getFlags(flags)
                        if (unitId == dwOwnerId and invPage == 0) {
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
                                    ; OutputDebug, % txtFileNo " " statEnum " " statValue
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


getFlags(flags) {
    flagsList := []
    SetFormat Integer, H
    hexFlags := flags + 0
    SetFormat Integer, D

    if (0x00000001 & flags) {  ; IFLAG_TARGET
        flagsList.push("IN PERSONAL STASH") 
    }
    if (0x00000002 & flags) {  ; IFLAG_TARGET
        flagsList.push("IFLAG_TARGET") 
    }
    if (0x00000004 & flags) {  ; IFLAG_TARGETING
        flagsList.push("IFLAG_TARGETING") 
    }
    if (0x00000008 & flags) {  ; IFLAG_TARGET
        flagsList.push("IFLAG_TARGET") 
    }
    if (0x00000010 & flags) { ; IFLAG_IDENTIFIED
        flagsList.push("IFLAG_IDENTIFIED") 
    }
    if (0x00000020 & flags) {  ; IFLAG_QUANTITY
        flagsList.push("IFLAG_QUANTITY") 
    }
    if (0x00000040 & flags) {  ; IFLAG_SWITCHIN
        flagsList.push("IFLAG_SWITCHIN") 
    }
    if (0x00000080 & flags) {  ; IFLAG_SWITCHOUT
        flagsList.push("IFLAG_SWITCHOUT") 
    }
    if (0x00000100 & flags) {  ; IFLAG_BROKEN
        flagsList.push("IFLAG_BROKEN") 
    }
    if (0x00000200 & flags) {  ; IFLAG_REPAIRED
        flagsList.push("IFLAG_REPAIRED") 
    }
    if (0x00000400 & flags) {  ; IFLAG_UNK1
        flagsList.push("IFLAG_UNK1") 
    }
    if (0x00000800 & flags) {  ; IFLAG_SOCKETED
        flagsList.push("IFLAG_SOCKETED") 
    }
    if (0x00001000 & flags) {  ; IFLAG_NOSELL
        flagsList.push("IFLAG_NOSELL") 
    }
    if (0x00002000 & flags) {  ; IFLAG_INSTORE
        flagsList.push("IFLAG_INSTORE") 
    }
    if (0x00004000 & flags) {  ; IFLAG_NOEQUIP
        flagsList.push("IFLAG_NOEQUIP") 
    }
    if (0x00008000 & flags) {  ; IFLAG_NAMED
        flagsList.push("IFLAG_NAMED")
    } 
    if (0x00010000 & flags) {  ; IFLAG_ISEAR
        flagsList.push("IFLAG_ISEAR") 
    }
    if (0x00020000 & flags) { ; IFLAG_STARTITEM
        flagsList.push("IFLAG_STARTITEM") 
    }  
    if (0x00040000 & flags) { ; IFLAG_STARTITEM
        flagsList.push("0x00040000") 
    }  
    if (0x00080000 & flags)  { ; IFLAG_INIT
        flagsList.push("IFLAG_INIT") 
    }
    if (0x00100000 & flags) { ; IFLAG_ETHEREAL
        flagsList.push("0x00100000") 
    }
    if (0x00200000 & flags) { ; IFLAG_ETHEREAL
        flagsList.push("0x00200000") 
    }
    if (0x00400000 & flags) { ; IFLAG_ETHEREAL
        flagsList.push("0x00400000") 
    }
    if (0x00800000 & flags) { ; IFLAG_ETHEREAL
        flagsList.push("0x00800000") 
    }
    if (0x01000000 & flags) { ; IFLAG_PERSONALIZED
        flagsList.push("IFLAG_PERSONALIZED") 
    }
    if (0x02000000 & flags) { ; IFLAG_LOWQUALITY
        flagsList.push("IFLAG_LOWQUALITY") 
    }
    if (0x04000000 & flags) { ; IFLAG_RUNEWORD
        flagsList.push("IFLAG_RUNEWORD") 
    }
    if (0x08000000 & flags) { ; IFLAG_ITEM
        flagsList.push("IFLAG_ITEM") 
    }

    
    if (0x10000000 & flags) { ; IFLAG_ITEM
        flagsList.push("0x10000000") 
    }
    if (0x20000000 & flags) { ; IFLAG_ITEM
        flagsList.push("0x20000000") 
    }
    if (0x40000000 & flags) { ; IFLAG_ITEM
        flagsList.push("0x40000000") 
    }
    if (0x80000000 & flags) { ; IFLAG_ITEM
        flagsList.push("0x80000000") 
    }

    sep := ","
    for index,param in flagsList
        str .= sep . param
    flagsText := SubStr(str, StrLen(sep)+1)
    return flagsList
}