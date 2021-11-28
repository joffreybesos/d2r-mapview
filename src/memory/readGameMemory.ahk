#SingleInstance, Force
#Include %A_ScriptDir%\include\classMemory.ahk
#Include %A_ScriptDir%\include\logging.ahk
SetWorkingDir, %A_ScriptDir%

readGameMemory(playerOffset, startingOffset, ByRef gameMemoryData) {

    if (_ClassMemory.__Class != "_ClassMemory")
    {
        WriteLog("Missing classMemory.ahk dependency. Quitting")
        ExitApp
    }

    d2r := new _ClassMemory(gameWindowId, "", hProcessCopy) 

    if !isObject(d2r) 
    {
        WriteLog(gameWindowId " not found, please make sure game is running")
        WriteTimedLog()
        ExitApp
    }

    ;WriteLog("Looking for Level No address at player offset " playerOffset)
    startingAddress := d2r.BaseAddress + playerOffset
    playerUnit := d2r.read(startingAddress, "Int64")

    ; get the level number
    pPathAddress := playerUnit + 0x38
    pPath := d2r.read(pPathAddress, "Int64")
    pRoom1 := pPath + 0x20
    pRoom1Address := d2r.read(pRoom1, "Int64")
    pRoom2 := pRoom1Address + 0x18
    pRoom2Address := d2r.read(pRoom2, "Int64")
    pLevel := pRoom2Address + 0x90
    pLevelAddress := d2r.read(pLevel, "Int64")
    dwLevelNo := pLevelAddress + 0x1F8
    levelNo := d2r.read(dwLevelNo, "UInt")
    if (!levelNo) {
        WriteLog("Did not find level num at address " dwLevelNo " using player offset " playerOffset) 
    }

    ; get the map seed
    startingAddress := d2r.BaseAddress + playerOffset
    playerUnit := d2r.read(startingAddress, "Int64")

    ; get the map seed
    pAct := playerUnit + 0x20
    actAddress := d2r.read(pAct, "Int64")

    if (actAddress) {
        mapSeedAddress := actAddress + 0x14
        if (mapSeedAddress) {
            mapSeed := d2r.read(mapSeedAddress, "UInt")
            ;WriteLogDebug("Found seed " mapSeed " at address " mapSeedAddress)
        } else {
            WriteLogDebug("Did not find seed " mapSeed " at address " mapSeedAddress)
        }
    }

    ; get the level number
    actAddress := d2r.read(pAct, "Int64")
    pActUnk1 := actAddress + 0x70
    aActUnk2 := d2r.read(pActUnk1, "Int64")
    aDifficulty := aActUnk2 + 0x830
    difficulty := d2r.read(aDifficulty, "UShort")

    if ((difficulty != 0) & (difficulty != 1) & (difficulty != 2)) {
        WriteLog("Did not find " difficulty " difficulty at " aDifficulty " using player offset " playerOffset) 
    }

    ; player position
    pPath := playerUnit + 0x38
    pathAddress := d2r.read(pPath, "Int64")
    xPosAddress := pathAddress + 0x02
    yPosAddress := pathAddress + 0x06
    xPos := d2r.read(xPosAddress, "UShort")
    yPos := d2r.read(yPosAddress, "UShort")

    if (!xPos) {
        WriteLog("Did not find position at " xPosAddress " using player offset " playerOffset) 
    }
    if (!yPos) {
        WriteLog("Did not find position at " xPosAddress " using player offset " playerOffset) 
    }
    ;WriteLog("XPos " xPos " yPos " yPos)
    ;WriteLog("Map Seed " mapSeed)

    ; monsters
    mobs := []
    monstersOffset := 0x20AF660 + 1024
    Loop, 128
    {

        newOffset := monstersOffset + (8 * (A_Index - 1))
        mobAddress := d2r.BaseAddress + newOffset
        while (mobAddress > 0) { ; keep following the next pointer
            mobUnit := d2r.read(mobAddress, "Int64")

            if (mobUnit) {
                mobType := d2r.read(mobUnit + 0x00, "UInt")
                txtFileNo := d2r.read(mobUnit + 0x04, "UInt")
                if (!HideNPC(txtFileNo)) {
                    unitId := d2r.read(mobUnit + 0x08, "UInt")
                    mode := d2r.read(mobUnit + 0x0c, "UInt")
                    pUnitData := d2r.read(mobUnit + 0x10, "Int64")
                    pPath := d2r.read(mobUnit + 0x38, "Int64")
                
                    isUnique := d2r.read(pUnitData + 0x18, "UShort")
                    monx := d2r.read(pPath + 0x02, "UShort")
                    mony := d2r.read(pPath + 0x06, "UShort")
                    isBoss := 0
                    textTitle := getBossName(txtFileNo)
                    if (textTitle) {
                        isBoss:= 1
                    }

                    ;get immunities
                    pStatsListEx := d2r.read(mobUnit + 0x88, "Int64")
                    ownerType := d2r.read(pStatsListEx + 0x08, "UInt")
                    ownerId := d2r.read(pStatsListEx + 0x0C, "UInt")

                    statPtr := d2r.read(pStatsListEx + 0x30, "Int64")
                    statCount := d2r.read(pStatsListEx + 0x38, "Int64")

                    immunities := { physical: 0, magic: 0, fire: 0, light: 0, cold: 0, poison: 0 }
                    Loop, %statCount%
                    {
                        offset := (A_Index -1) * 8
                        ;statParam := d2r.read(statPtr + offset, "UShort")
                        statEnum := d2r.read(statPtr + 0x2 + offset, "UShort")
                        statValue := d2r.read(statPtr + 0x4 + offset, "UInt")
                        if (statValue >= 100) {
                            switch (statEnum) {
                                ; no enums here, just bad practices instead
                                case 36: immunities["physical"] := 1 ;physical immune
                                case 37: immunities["magic"] := 1    ;magic immune
                                case 39: immunities["fire"] := 1     ;fire resist
                                case 41: immunities["light"] := 1    ;light resist
                                case 43: immunities["cold"] := 1     ;cold resist
                                case 45: immunities["poison"] := 1   ;poison resist
                            }
                        }
                    }
                    mob := {"txtFileNo": txtFileNo, "mode": mode, "x": monx, "y": mony, "isUnique": isUnique, "isBoss": isBoss, "textTitle": textTitle, "immunities": immunities }
                    mobs.push(mob)
                }
                
                mobAddress := d2r.read(mobUnit + 0x150, "Int64")  ; get next mob
            } else {
                mobAddress := 0
            }
        }
    } 
    gameMemoryData := {"mapSeed": mapSeed, "difficulty": difficulty, "levelNo": levelNo, "xPos": xPos, "yPos": yPos, "mobs": mobs }
}

getBossName(txtFileNo) {
    switch (txtFileNo) {
        case "156": return "Andariel"
        case "211": return "Duriel"
        case "229": return "Radament"
        case "242": return "Mephisto"
        case "243": return "Diablo"
        case "250": return "Summoner"
        case "256": return "Izual"
        case "267": return "Bloodraven"
        case "333": return "Diabloclone"
        case "365": return "Griswold"
        case "526": return "Nihlathakboss"
        case "544": return "Baalcrab"
        case "570": return "Baalclone"
        case "704": return "Uber Mephisto"
        case "705": return "Uber Diablo"
        case "706": return "Uber Izual"
        case "707": return "Uber Andariel"
        case "708": return "Uber Duriel"
        case "709": return "Uber Baal"
    }
    return ""
}

getSuperUniqueName(txtFileNo) {
    switch (txtFileNo) {
        case "0": return "Bonebreak"
        case "5": return "Corpsefire"
        case "11": return "Pitspawn Fouldog"
        case "20": return "Rakanishu"
        case "24": return "Treehead WoodFist"
        case "31": return "Fire Eye"
        case "45": return "The Countess"
        case "47": return "Sarina the Battlemaid"
        case "62": return "Baal Subject 1"
        case "66": return "Flamespike the Crawler"
        case "75": return "Fangskin"
        case "83": return "Bloodwitch the Wild"
        case "92": return "Beetleburst"
        case "97": return "Leatherarm"
        case "103": return "Ancient Kaa the Soulless"
        case "105": return "Baal Subject 2"
        case "120": return "The Tormentor"
        case "125": return "Web Mage the Burning"
        case "129": return "Stormtree"
        case "138": return "Icehawk Riftwing"
        case "160": return "Coldcrow"
        case "276": return "Boneash"
        case "281": return "Witch Doctor Endugu"
        case "284": return "Coldworm the Burrower"
        case "299": return "Taintbreeder"
        case "306": return "Grand Vizier of Chaos"
        case "308": return "Riftwraith the Cannibal"
        case "312": return "Lord De Seis"
        ; case "345": return "Council Member"
        ; case "346": return "Council Member"
        ; case "347": return "Council Member"
        case "362": return "Winged Death"
        case "402": return "The Smith"
        case "409": return "The Feature Creep"
        case "437": return "Bonesaw Breaker"
        case "440": return "Pindleskin"
        case "443": return "Threash Socket"
        case "449": return "Frozenstein"
        case "453": return "Megaflow Rectifier"
        case "472": return "Anodized Elite"
        case "475": return "Vinvear Molech"
        case "479": return "Siege Boss"
        case "481": return "Sharp Tooth Sayer"
        case "494": return "Dac Farren"
        case "496": return "Magma Torquer"
        case "501": return "Snapchip Shatter"
        case "508": return "Axe Dweller"
        case "529": return "Eyeback Unleashed"
        case "533": return "Blaze Ripper"
        case "540": return "Ancient Barbarian 1"
        case "541": return "Ancient Barbarian 2"
        case "542": return "Ancient Barbarian 3"
        case "557": return "Baal Subject 3"
        case "558": return "Baal Subject 4"
        case "571": return "Baal Subject 5"
        case "735": return "The Cow King"
        case "736": return "Dark Elder"
    }
    return ""
}

; certain NPCs we don't want to see such as mercs
HideNPC(txtFileNo) {
    switch (txtFileNo) {
        case 149: return 1
        case 151: return 1
        case 152: return 1
        case 153: return 1
        case 157: return 1
        case 158: return 1
        case 159: return 1
        case 195: return 1
        case 196: return 1
        case 197: return 1
        case 179: return 1
        case 185: return 1
        case 203: return 1
        case 204: return 1
        case 205: return 1
        case 268: return 1
        case 269: return 1
        case 271: return 1
        case 272: return 1
        case 293: return 1
        case 294: return 1
        case 289: return 1
        case 290: return 1
        case 291: return 1
        case 292: return 1
        case 296: return 1
        case 318: return 1
        case 319: return 1
        case 320: return 1
        case 321: return 1
        case 322: return 1
        case 323: return 1
        case 324: return 1
        case 325: return 1
        case 332: return 1
        case 338: return 1
        case 339: return 1
        case 344: return 1
        case 355: return 1
        case 359: return 1
        case 363: return 1
        case 364: return 1
        case 370: return 1
        case 377: return 1
        case 378: return 1
        case 392: return 1
        case 393: return 1
        case 401: return 1
        case 411: return 1
        case 412: return 1
        case 414: return 1
        case 415: return 1
        case 416: return 1
        case 711: return 1
    }
    return 0
}