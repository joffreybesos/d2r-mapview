#Include %A_ScriptDir%\memory\readOtherPlayers.ahk
#Include %A_ScriptDir%\memory\readMobs.ahk
#Include %A_ScriptDir%\memory\readItems.ahk
#Include %A_ScriptDir%\memory\readObjects.ahk
#Include %A_ScriptDir%\memory\readMissiles.ahk
#Include %A_ScriptDir%\memory\readUI.ahk

readGameMemory(d2rprocess, settings, playerOffset, ByRef gameMemoryData) {
    StartTime := A_TickCount
    startingOffset := settings["playerOffset"]  ;default offset
    
    ;WriteLog("Looking for Level No address at player offset " playerOffset)
    startingAddress := d2rprocess.BaseAddress + playerOffset
    playerUnit := d2rprocess.read(startingAddress, "Int64")
    if (!playerUnit) {
        WriteLogDebug("Could not read playerunit from memory")
    }

    ; get the level number
    pPathAddress := playerUnit + 0x38
    pPath := d2rprocess.read(pPathAddress, "Int64")
    pRoom1 := pPath + 0x20
    pRoom1Address := d2rprocess.read(pRoom1, "Int64")
    pRoom2 := pRoom1Address + 0x18
    pRoom2Address := d2rprocess.read(pRoom2, "Int64")
    pLevel := pRoom2Address + 0x90
    pLevelAddress := d2rprocess.read(pLevel, "Int64")
    dwLevelNo := pLevelAddress + 0x1F8
    levelNo := d2rprocess.read(dwLevelNo, "UInt")
    if (!levelNo) {
        WriteLogDebug("Did not find level num using player offset " playerOffset) 
    }
    

    ; get the map seed
    startingAddress := d2rprocess.BaseAddress + playerOffset
    playerUnit := d2rprocess.read(startingAddress, "Int64")

    ; get the map seed
    pAct := playerUnit + 0x20
    actAddress := d2rprocess.read(pAct, "Int64")

    if (actAddress) {
        mapSeedAddress := actAddress + 0x14
        if (mapSeedAddress) {
            mapSeed := d2rprocess.read(mapSeedAddress, "UInt")
            ;WriteLogDebug("Found seed " mapSeed " at address " mapSeedAddress)
        } else {
            WriteLogDebug("Did not find map seed at address " mapSeedAddress)
        }
    }

    ; get the level number
    actAddress := d2rprocess.read(pAct, "Int64")
    pActUnk1 := actAddress + 0x70
    aActUnk2 := d2rprocess.read(pActUnk1, "Int64")
    aDifficulty := aActUnk2 + 0x830
    difficulty := d2rprocess.read(aDifficulty, "UShort")

    if ((difficulty != 0) & (difficulty != 1) & (difficulty != 2)) {
        WriteLogDebug("Did not find difficulty using player offset " playerOffset) 
    }

    ; get playername
    pUnitData := playerUnit + 0x10
    playerNameAddress := d2rprocess.read(pUnitData, "Int64")
    playerName := d2rprocess.readString(playerNameAddress, length := 0)
    
    pStatsListEx := d2rprocess.read(playerUnit + 0x88, "Int64")
    statPtr := d2rprocess.read(pStatsListEx + 0x30, "Int64")
    statCount := d2rprocess.read(pStatsListEx + 0x38, "Int64")

    ; get level and experience
    Loop, %statCount%
    {
        statOffset := (A_Index-1) * 8
        statEnum := d2rprocess.read(statPtr + 0x2 + statOffset, "UShort")
        if (statEnum == 12) {
            playerLevel := d2rprocess.read(statPtr + 0x4 + statOffset, "UInt")
        }
        if (statEnum == 13) {
            experience := d2rprocess.read(statPtr + 0x4 + statOffset, "UInt")
        }
        if (statEnum == 6) {
            hp := d2rprocess.read(statPtr + 0x4 + statOffset, "UInt")
            hp := hp >> 8
            ; 'hp' will now have correct value
        }
        if (statEnum == 7) {
            maxhp := d2rprocess.read(statPtr + 0x4 + statOffset, "UInt")
            maxhp := maxhp >> 8
            ; maxhp is the max hp WITHOUT any item/charm/skill boosts applied!
        }
    }

    ; get other players
    if (settings["showOtherPlayers"]) {
        ReadOtherPlayers(d2rprocess, startingOffset, otherPlayerData)
    }

    ; get mobs
    if (settings["showNormalMobs"] or settings["showUniqueMobs"] or settings["showBosses"] or settings["showDeadMobs"]) {
        ReadMobs(d2rprocess, startingOffset, mobs)
    }

    ; missiles
    missiles:=[]
    ; PlayerMissiles
    if (settings["showPlayerMissiles"]){
        playerMissiles := readMissiles(d2rprocess, startingOffset + (6 * 1024))
        missiles.push(playerMissiles)
    }
    ; EnemyMissiles
    if (settings["showEnemyMissiles"]){
        enemyMissiles := readMissiles(d2rprocess, startingOffset)
        missiles.push(enemyMissiles)
    }

    ; get items
    if (settings["showUniqueAlerts"] or settings["showSetItemAlerts"] or settings["showRuneAlerts"] or settings["showJewelAlerts"] or settings["showCharmAlerts"] or settings["showBaseItems"]) {
        ReadItems(d2rprocess, startingOffset, items)
    }

     ; get items
    if (settings["showShrines"] or settings["showPortals"]) {
        ReadObjects(d2rprocess, startingOffset, levelNo, objects)
    }

    menuShown := readUI(d2rprocess, gameWindowId, settings, session)

    ; player position
    pPath := playerUnit + 0x38
    pathAddress := d2rprocess.read(pPath, "Int64")
    xPos := d2rprocess.read(pathAddress + 0x02, "UShort") 
    yPos := d2rprocess.read(pathAddress + 0x06, "UShort")
    xPosOffset := d2rprocess.read(pathAddress + 0x00, "UShort") 
    yPosOffset := d2rprocess.read(pathAddress + 0x04, "UShort")
    xPosOffset := xPosOffset / 65535   ; get percentage
    yPosOffset := yPosOffset / 65535   ; get percentage

    xPos := xPos + xPosOffset
    yPos := yPos + yPosOffset

    if (!xPos) {
        WriteLog("Did not find player position at player offset " playerOffset) 
    }
    gameMemoryData := {"gameName": gameName, "mapSeed": mapSeed, "difficulty": difficulty, "levelNo": levelNo, "xPos": xPos, "yPos": yPos, "mobs": mobs, "missiles": missiles, "otherPlayers": otherPlayerData, "items": items, "objects": objects, "playerName": playerName, "experience": experience, "playerLevel": playerLevel, "menuShown": menuShown }
    ElapsedTime := A_TickCount - StartTime
    ;ToolTip % "`n`n`n`n" ElapsedTime
}
