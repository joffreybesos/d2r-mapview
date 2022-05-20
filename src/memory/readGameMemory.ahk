#Include %A_ScriptDir%\memory\readOtherPlayers.ahk
#Include %A_ScriptDir%\memory\readMobs.ahk
#Include %A_ScriptDir%\memory\readItems.ahk
#Include %A_ScriptDir%\memory\readObjects.ahk
#Include %A_ScriptDir%\memory\readMissiles.ahk
#Include %A_ScriptDir%\memory\readUI.ahk
#Include %A_ScriptDir%\memory\readParty.ahk
#Include %A_ScriptDir%\memory\readMapSeed.ahk
#Include %A_ScriptDir%\memory\scanForPlayer.ahk

readGameMemory(ByRef d2rprocess, ByRef settings, ByRef gameMemoryData) {
    global items
    static objects
    static partyList
    hoveredMob := {}
    ;StartTime := A_TickCount
    unitTableOffset := offsets["unitTable"] ;default offset
    playerOffset := scanForPlayer(d2rprocess, playerOffset, unitTableOffset, settings)

    ;WriteLog("Looking for Level No address at player offset " unitTableOffset)
    , playerAddress := d2rprocess.BaseAddress + playerOffset
    , playerUnit := d2rprocess.read(playerAddress, "Int64")
    , unitId := d2rprocess.read(playerUnit + 0x08, "UInt")

    ; get the level number
    , pPath := d2rprocess.read(playerUnit + 0x38, "Int64")
    , pRoom1Address := d2rprocess.read(pPath + 0x20, "Int64")
    , pRoom2Address := d2rprocess.read(pRoom1Address + 0x18, "Int64")
    , pLevelAddress := d2rprocess.read(pRoom2Address + 0x90, "Int64")
    , levelNo := d2rprocess.read(pLevelAddress + 0x1F8, "UInt")
    if (!levelNo) {
        WriteLogDebug("Did not find level num using player offset " playerOffset) 
    }
    ; get the map seed

    ;actAddress := d2rprocess.read(playerUnit + 0x20, "Int64")
    ;mapSeedOld := d2rprocess.read(actAddress + 0x1C, "UInt")
    if (!offsets["mapSeedOffset"]) {
        getMapSeedOffset(d2rprocess)
    }
    mapSeedOffset := offsets["mapSeedOffset"]
    mapSeed := d2rprocess.read(mapSeedOffset, "UInt")

    ; get the difficulty
    actAddress := d2rprocess.read(playerUnit + 0x20, "Int64")
    , aActUnk2 := d2rprocess.read(actAddress + 0x78, "Int64")
    , difficulty := d2rprocess.read(aActUnk2 + 0x830, "UShort")
    if ((difficulty != 0) & (difficulty != 1) & (difficulty != 2)) {
        WriteLogDebug("Did not find difficulty using player offset " unitTableOffset) 
    }

    ; get playername
    playerNameAddress := d2rprocess.read(playerUnit + 0x10, "Int64")
    , playerName := d2rprocess.readString(playerNameAddress, length := 0)
    , pStatsListEx := d2rprocess.read(playerUnit + 0x88, "Int64")
    , statPtr := d2rprocess.read(pStatsListEx + 0x30, "Int64")
    , statCount := d2rprocess.read(pStatsListEx + 0x38, "Int64")
    , d2rprocess.readRaw(statPtr + 0x2, buffer, statCount*8)
    ; get level and experience
    Loop, %statCount%
    {
        offset := (A_Index -1) * 8
        , statEnum := NumGet(&buffer , offset, Type := "UShort")
        , statValue := NumGet(&buffer , offset + 0x2, Type := "UInt")
        if (statEnum == 12) {
            playerLevel := statValue
        }
        if (statEnum == 13) {
            experience := statValue
        }
    }


    hoverAddress := d2rprocess.BaseAddress + offsets["hoverOffset"]
    d2rprocess.readRaw(hoverAddress, hoverBuffer, 12)
    isHovered := NumGet(&hoverBuffer , 0, "UChar")
    if (isHovered) {
        lastHoveredType := NumGet(&hoverBuffer , 0x04, "UInt")
        lastHoveredUnitId := NumGet(&hoverBuffer , 0x08, "UInt")
    }


    ; get party
    if (Mod(ticktock, 3)) {
        ReadParty(d2rprocess, partyList)
    }


    ; get other players
    if (settings["showOtherPlayers"]) {
        ; timeStamp("ReadOtherPlayers")
        ReadOtherPlayers(d2rprocess, unitTableOffset, levelNo, otherPlayerData, partyList)
        ; timeStamp("ReadOtherPlayers")
    }

    ; ; get mobs
    if (settings["showNormalMobs"] or settings["showUniqueMobs"] or settings["showBosses"] or settings["showDeadMobs"]) {
        if (lastHoveredType) {
            ; timeStamp("ReadMobs")
            ReadMobs(d2rprocess, unitTableOffset, lastHoveredUnitId, mobs, hoveredMob)
            ; timeStamp("ReadMobs")
        } else {
            ; timeStamp("ReadMobs")
            ReadMobs(d2rprocess, unitTableOffset, 0, mobs, hoveredMob)
            ; timeStamp("ReadMobs")
        }
    }

    ; missiles
    missiles:=[]
    ; PlayerMissiles
    if (settings["showPlayerMissiles"]){
        ; timeStamp("readMissiles")
        playerMissiles := readMissiles(d2rprocess, unitTableOffset + (6 * 1024))
        missiles.push(playerMissiles)
        ; timeStamp("readMissiles")
    }
    ; EnemyMissiles
    if (settings["showEnemyMissiles"]){
        ; timeStamp("readEnemyMissiles")
        enemyMissiles := readMissiles(d2rprocess, unitTableOffset)
        missiles.push(enemyMissiles)
        ; timeStamp("readEnemyMissiles")
    }

    ; get items
    if (settings["enableItemFilter"]) {
        if (Mod(ticktock, 3)) {
            ; timeStamp("readItems")
            ReadItems(d2rprocess, unitTableOffset, items)
            ; timeStamp("readItems")
        }
    }

    ; get objects
    if (settings["showShrines"] or settings["showPortals"] or settings["showChests"]) {
        if (Mod(ticktock, 6)) {
            ; timeStamp("ReadObjects")
            if (lastHoveredType == 2) {
                ReadObjects(d2rprocess, unitTableOffset, lastHoveredUnitId, levelNo, objects)
            } else {
                ReadObjects(d2rprocess, unitTableOffset, 0, levelNo, objects)
            }
            ; timeStamp("ReadObjects")
        }
    }
    ; timeStamp("readUI")
    menuShown := readUI(d2rprocess)
    ; timeStamp("readUI")

    ; player position
    ; timeStamp("playerposition")
    pathAddress := d2rprocess.read(playerUnit + 0x38, "Int64")
    , xPos := d2rprocess.read(pathAddress + 0x02, "UShort") 
    , yPos := d2rprocess.read(pathAddress + 0x06, "UShort")
    , xPosOffset := d2rprocess.read(pathAddress + 0x00, "UShort") 
    , yPosOffset := d2rprocess.read(pathAddress + 0x04, "UShort")
    , xPosOffset := xPosOffset / 65536 ; get percentage
    , yPosOffset := yPosOffset / 65536 ; get percentage
    , xPos := xPos + xPosOffset
    , yPos := yPos + yPosOffset

    if (!xPos) {
        WriteLog("Did not find player position at player offset " unitTableOffset) 
    }
    ; timeStamp("playerposition")
    
    gameMemoryData := {"pathAddress": pathAddress, "gameName": gameName, "mapSeed": mapSeed, "difficulty": difficulty, "levelNo": levelNo, "xPos": xPos, "yPos": yPos, "mobs": mobs, "missiles": missiles, "otherPlayers": otherPlayerData, "items": items, "objects": objects, "playerName": playerName, "experience": experience, "playerLevel": playerLevel, "menuShown": menuShown, "hoveredMob": hoveredMob, "partyList": partyList, "unitId": unitId}
    ;ElapsedTime := A_TickCount - StartTime
    ;OutputDebug, % ElapsedTime "`n"
    ;ToolTip % "`n`n`n`n" ElapsedTime
}


readMapSeed(ByRef d2r) {
    ; map seed
    pattern := d2r.hexStringToPattern("41 8B F9 48 8D 0D ?? ?? ?? ??") 
    patternAddress := d2r.modulePatternScan("D2R.exe", , pattern*)  
    offsetAddress := d2r.read(patternAddress + 6, "Int") ; 0x00007ff6a12172a6
    delta := patternAddress - d2r.BaseAddress
    seedAddress := d2r.BaseAddress + delta + 0xEA + offsetAddress
    seed := d2r.read(seedAddress, "Int") ; 0x00007ff6a12172a6
    return seed
}