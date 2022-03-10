#Include %A_ScriptDir%\types\Item.ahk

ReadItems(ByRef d2rprocess, startingOffset, ByRef items) {
    ; items
    items := []
    , itemsOffset := startingOffset + (4 * 1024)
    , baseAddress := d2rprocess.BaseAddress + itemsOffset
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
                ;WriteLog(txtFileNo " " itemLoc " " itemType)
                if (itemLoc == 3 or itemLoc == 5) { ; on ground or dropping
                    pUnitData := d2rprocess.read(itemUnit + 0x10, "Int64")

                    ; itemQuality - 5 is set, 7 is unique (6 rare, 4, magic)
                    , itemQuality := d2rprocess.read(pUnitData, "UInt")

                    , pPath := d2rprocess.read(itemUnit + 0x38, "Int64")  
                    , itemx := d2rprocess.read(pPath + 0x10, "UShort")
                    , itemy := d2rprocess.read(pPath + 0x14, "UShort")
                    , pStatsListEx := d2rprocess.read(itemUnit + 0x88, "Int64")
                    , statPtr := d2rprocess.read(pStatsListEx + 0x30, "Int64")
                    , statCount := d2rprocess.read(pStatsListEx + 0x38, "Int64")
                    , d2rprocess.readRaw(statPtr + 0x2, buffer, statCount*8)
                    , numSockets := 0
                    Loop, %statCount%
                    {
                        offset := (A_Index -1) * 8
                        , statEnum := NumGet(&buffer , offset, Type := "UShort")
                        if (statEnum == 194) {
                            statValue := NumGet(&buffer , offset + 0x2, Type := "UInt")
                            numSockets := statValue
                            break
                        }
                    }
                    flags := d2rprocess.read(pUnitData + 0x18, "UInt")
                    , item := new GameItem(txtFileNo, itemQuality)
                    , item.itemLoc := itemLoc
                    , item.itemx := itemx
                    , item.itemy := itemy
                    , item.numSockets := numSockets
                    , item.calculateFlags(flags)
                    ; WriteLog(txtFileNo " " item.toString())
                    , items.push(item)
                }
            }
            itemUnit := d2rprocess.read(itemUnit + 0x150, "Int64")  ; get next item
        }
    } 
    SetFormat Integer, D
}
