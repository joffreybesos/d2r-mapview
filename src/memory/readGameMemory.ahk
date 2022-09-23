#Include %A_ScriptDir%\memory\readOtherPlayers.ahk
#Include %A_ScriptDir%\memory\readMobs.ahk
#Include %A_ScriptDir%\memory\readItems.ahk
#Include %A_ScriptDir%\memory\readObjects.ahk
#Include %A_ScriptDir%\memory\readMissiles.ahk
#Include %A_ScriptDir%\memory\readUI.ahk
#Include %A_ScriptDir%\memory\readParty.ahk
#Include %A_ScriptDir%\memory\scanForPlayer.ahk


global lastdwInitSeedHash1
global lastdwInitSeedHash2
global lastdwEndSeedHash1
global xorkey
global playerLevel 
global experience
readGameMemory(ByRef d2rprocess, ByRef settings, ByRef gameMemoryData) {
    static items
    static objects
    static partyList
    static mapSeed
    hoveredMob := {}
    ;StartTime := A_TickCount
    unitTableOffset := offsets["unitTable"] ;default offset
    playerPointer := scanForPlayer(d2rprocess, unitTableOffset)

    ;WriteLog("Looking for Level No address at player offset " unitTableOffset)
    playerUnit := playerPointer
    , unitId := d2rprocess.read(playerUnit + 0x08, "UInt")

    ; get the level number
    , pPath := d2rprocess.read(playerUnit + 0x38, "Int64")
    , pRoom1Address := d2rprocess.read(pPath + 0x20, "Int64")
    , pRoom2Address := d2rprocess.read(pRoom1Address + 0x18, "Int64")
    , pLevelAddress := d2rprocess.read(pRoom2Address + 0x90, "Int64")
    , levelNo := d2rprocess.read(pLevelAddress + 0x1F8, "UInt")

    ; get playername
    , playerNameAddress := d2rprocess.read(playerUnit + 0x10, "Int64")
    , playerName := d2rprocess.readString(playerNameAddress, length := 0)

    ; get the map seed
    , actAddress := d2rprocess.read(playerUnit + 0x20, "Int64")  
    , actMiscAddress := d2rprocess.read(actAddress + 0x78, "Int64")   ;0x0000023a64ed4780 ;2449824630656

    dwInitSeedHash1 := d2rprocess.read(actMiscAddress + 0x840, "UInt") 
    dwInitSeedHash2 := d2rprocess.read(actMiscAddress + 0x844, "UInt") 
    dwEndSeedHash1 := d2rprocess.read(actMiscAddress + 0x868, "UInt") 

    if (dwInitSeedHash1 != lastdwInitSeedHash1 or dwInitSeedHash2 != lastdwInitSeedHash2 or mapSeed == 0) {
        mapSeed := calculateMapSeed(dwInitSeedHash1, dwInitSeedHash2, dwEndSeedHash1)
        lastdwInitSeedHash1 := dwInitSeedHash1
        lastdwInitSeedHash2 := dwInitSeedHash2
    }
    ;mapSeed := d2rprocess.read(actMiscAddress + 0x840, "UInt") 


    ; get the difficulty
    aActUnk2 := d2rprocess.read(actAddress + 0x78, "Int64")
    , difficulty := d2rprocess.read(aActUnk2 + 0x830, "UShort")
    
    if (Mod(ticktock, 6)) {
        pStatsListEx := d2rprocess.read(playerUnit + 0x88, "Int64")
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
        ReadParty(d2rprocess, partyList, unitId)
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
    
    gameMemoryData := {"playerPointer": playerPointer, "pathAddress": pathAddress, "gameName": gameName, "mapSeed": mapSeed, "difficulty": difficulty, "levelNo": levelNo, "xPos": xPos, "yPos": yPos, "mobs": mobs, "missiles": missiles, "otherPlayers": otherPlayerData, "items": items, "objects": objects, "playerName": playerName, "experience": experience, "playerLevel": playerLevel, "menuShown": menuShown, "hoveredMob": hoveredMob, "partyList": partyList, "unitId": unitId}
    ;ElapsedTime := A_TickCount - StartTime
    ;OutputDebug, % ElapsedTime "`n"
    ;ToolTip % "`n`n`n`n" ElapsedTime
}


calculateMapSeed(InitSeedHash1, InitSeedHash2, EndSeedHash1) {
	WriteLog("Calculating new map seed from " InitSeedHash1 " " InitSeedHash2 " " EndSeedHash1)
	mapSeed := DllCall("rustdecrypt.dll\get_seed", "UInt", InitSeedHash1, "UInt", InitSeedHash2, "UInt", EndSeedHash1, "UInt")
	WriteLog("Found mapSeed '" mapSeed "'")
    if (!mapSeed) {
        WriteLog("ERRROR: YOU HAVE AN ERROR DEECRYPTING THE MAP SEED, YOUR MAPS WILL EITHER NOT APPEAR OR NOT LINE UP")
    }
	return mapSeed
}