#Include %A_ScriptDir%\types\Item.ahk

ReadItems(ByRef d2rprocess, startingOffset, ByRef items) {
    ; items
    items := []
    , baseAddress := d2rprocess.BaseAddress + startingOffset + (4 * 1024)
    , d2rprocess.readRaw(baseAddress, unitTableBuffer, 128*8)
    Loop, 128
    {
        offset := (8 * (A_Index - 1))
        , itemUnit := NumGet(&unitTableBuffer , offset, "Int64")
        while (itemUnit > 0) { ; keep following the next pointer
            itemType := d2rprocess.read(itemUnit + 0x00, "UInt")
            if (itemType == 4) { ; item is 4
                txtFileNo := d2rprocess.read(itemUnit + 0x04, "UInt")
                
                ;itemLoc - 0 in inventory, 1 equipped, 2 in belt, 3 on ground, 4 cursor, 5 dropping, 6 socketed
                , itemLoc := d2rprocess.read(itemUnit + 0x0C, "UInt")
                if (itemLoc == 3 or itemLoc == 5) { ; on ground or dropping
                    pUnitData := d2rprocess.read(itemUnit + 0x10, "Int64")
                    , itemQuality := d2rprocess.read(pUnitData, "UInt")
                    , uniqueOrSetId := d2rprocess.read(pUnitData + 0x34, "UInt")
                    , pPath := d2rprocess.read(itemUnit + 0x38, "Int64")  
                    , itemx := d2rprocess.read(pPath + 0x10, "UShort")
                    , itemy := d2rprocess.read(pPath + 0x14, "UShort")
                    , pStatsListEx := d2rprocess.read(itemUnit + 0x88, "Int64")
                    , statPtr := d2rprocess.read(pStatsListEx + 0x30, "Int64")
                    , statCount := d2rprocess.read(pStatsListEx + 0x38, "Int64")
                    , statExPtr := d2rprocess.read(pStatsListEx + 0x80, "Int64")
                    , statExCount := d2rprocess.read(pStatsListEx + 0x88, "Int64")
                    , flags := d2rprocess.read(pUnitData + 0x18, "UInt")
                    , item := new GameItem(txtFileNo, itemQuality, uniqueOrSetId)
                    , item.itemLoc := itemLoc
                    , item.itemx := itemx
                    , item.itemy := itemy
                    , item.statPtr := statPtr
                    , item.statCount := statCount
                    , item.statExPtr := statExPtr
                    , item.statExCount := statExCount
                    , item.calculateFlags(flags)
                    , items.push(item)
                }
            }
            itemUnit := d2rprocess.read(itemUnit + 0x150, "Int64")  ; get next item
        }
    } 
    SetFormat Integer, D
}
