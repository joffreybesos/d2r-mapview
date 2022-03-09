#Include %A_ScriptDir%\memory\readOtherPlayers.ahk
#Include %A_ScriptDir%\memory\readMobs.ahk
#Include %A_ScriptDir%\memory\readItems.ahk
#Include %A_ScriptDir%\memory\readObjects.ahk
#Include %A_ScriptDir%\memory\readMissiles.ahk
#Include %A_ScriptDir%\memory\readUI.ahk

readGameMemory(ByRef d2rprocess, ByRef settings, playerOffset, ByRef gameMemoryData) {
    static items
    static objects
    StartTime := A_TickCount
    startingOffset := offsets["playerOffset"]  ;default offset
    
    ;WriteLog("Looking for Level No address at player offset " playerOffset)
    , startingAddress := d2rprocess.BaseAddress + playerOffset
    , playerUnit := d2rprocess.read(startingAddress, "Int64")

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
    actAddress := d2rprocess.read(playerUnit + 0x20, "Int64")
    , mapSeed := d2rprocess.read(actAddress + 0x14, "UInt")

    ; get the difficulty
    , actAddress := d2rprocess.read(playerUnit + 0x20, "Int64")
    , aActUnk2 := d2rprocess.read(actAddress + 0x70, "Int64")
    , difficulty := d2rprocess.read(aActUnk2 + 0x830, "UShort")
    if ((difficulty != 0) & (difficulty != 1) & (difficulty != 2)) {
        WriteLogDebug("Did not find difficulty using player offset " playerOffset) 
    }

    ; get playername
    playerNameAddress := d2rprocess.read(playerUnit + 0x10, "Int64")
    , playerName := d2rprocess.readString(playerNameAddress, length := 0)
    , pStatsListEx := d2rprocess.read(playerUnit + 0x88, "Int64")
    , statPtr := d2rprocess.read(pStatsListEx + 0x30, "Int64")
    , statCount := d2rprocess.read(pStatsListEx + 0x38, "Int64")

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
        if (statEnum > 13)
            break
    }

    ; get other players
    if (settings["showOtherPlayers"]) {
        ReadOtherPlayers(d2rprocess, startingOffset, otherPlayerData)
    }

    ; ; get mobs
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
    if (settings["enableItemFilter"]) {
        if (Mod(ticktock, 3)) {
            ReadItems(d2rprocess, startingOffset, items)
        }
    }

    ; get objects
    if (settings["showShrines"] or settings["showPortals"] or settings["showChests"]) {
        if (Mod(ticktock, 6)) {
            ReadObjects(d2rprocess, startingOffset, levelNo, objects)
        }
    }

    menuShown := readUI(d2rprocess, gameWindowId, settings, session)

    ; player position
    pathAddress := d2rprocess.read(playerUnit + 0x38, "Int64")
    , xPos := d2rprocess.read(pathAddress + 0x02, "UShort") 
    , yPos := d2rprocess.read(pathAddress + 0x06, "UShort")
    , xPosOffset := d2rprocess.read(pathAddress + 0x00, "UShort") 
    , yPosOffset := d2rprocess.read(pathAddress + 0x04, "UShort")
    , xPosOffset := xPosOffset / 65536   ; get percentage
    , yPosOffset := yPosOffset / 65536   ; get percentage
    , xPos := xPos + xPosOffset
    , yPos := yPos + yPosOffset

    if (!xPos) {
        WriteLog("Did not find player position at player offset " playerOffset) 
    }
    gameMemoryData := {"gameName": gameName, "mapSeed": mapSeed, "difficulty": difficulty, "levelNo": levelNo, "xPos": xPos, "yPos": yPos, "mobs": mobs, "missiles": missiles, "otherPlayers": otherPlayerData, "items": items, "objects": objects, "playerName": playerName, "experience": experience, "playerLevel": playerLevel, "menuShown": menuShown }
    ElapsedTime := A_TickCount - StartTime
    ;OutputDebug, % ElapsedTime "`n"
    ;ToolTip % "`n`n`n`n" ElapsedTime
}
