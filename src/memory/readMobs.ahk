
ReadMobs(ByRef d2rprocess, startingOffset, ByRef currentHoveringUnitId, ByRef mobs, ByRef hoveredMob) {
    ; monsters
    mobs := []
    hoveredMob := {}
    baseAddress := d2rprocess.BaseAddress + startingOffset + 1024
    d2rprocess.readRaw(baseAddress, unitTableBuffer, 128*8)
    Loop, 128
    {
        offset := (8 * (A_Index - 1))
        , mobUnit := NumGet(&unitTableBuffer , offset, "Int64")
        while (mobUnit > 0) { ; keep following the next pointer
            ;mobType := d2rprocess.read(mobUnit + 0x00, "UInt")
            ;txtFileNo := d2rprocess.read(mobUnit + 0x04, "UInt")
            d2rprocess.readRaw(mobUnit, mobStructData, 144)
            , mobType := NumGet(&mobStructData , 0x00, "UInt")
            , txtFileNo := NumGet(&mobStructData , 0x04, "UInt")
            if (!HideNPC(txtFileNo)) {
                unitId := NumGet(&mobStructData , 0x08, "UInt")
                , mode := NumGet(&mobStructData , 0x0c, "UInt")
                , pUnitData := NumGet(&mobStructData , 0x10, "Int64")
                , pPath := NumGet(&mobStructData , 0x38, "Int64")
                , isUnique := d2rprocess.read(pUnitData + 0x18, "UShort")
                , d2rprocess.readRaw(pPath, pathStructData, 16)
                , monx := NumGet(&pathStructData , 0x02, "UShort")
                , mony := NumGet(&pathStructData , 0x06, "UShort")
                , xPosOffset := NumGet(&pathStructData , 0x00, "UShort")
                , yPosOffset := NumGet(&pathStructData , 0x04, "UShort")
                , xPosOffset := xPosOffset / 65536   ; get percentage
                , yPosOffset := yPosOffset / 65536   ; get percentage
                , monx := monx + xPosOffset
                , mony := mony + yPosOffset
                , isHovered := false

                , isBoss := 0
                , textTitle := getBossName(txtFileNo)
                if (textTitle) {
                    isBoss:= 1
                }
                
                ;get immunities
                pStatsListEx := NumGet(&mobStructData , 0x88, "Int64")
                , statPtr := d2rprocess.read(pStatsListEx + 0x30, "Int64")
                , statCount := d2rprocess.read(pStatsListEx + 0x38, "Int64")
                , isPlayerMinion := 0
                , playerMinion := getPlayerMinion(txtFileNo)
                if (playerMinion) {
                    isPlayerMinion:= 1
                } else {
                    ; is a revive
                    isPlayerMinion := ((d2rprocess.read(pStatsListEx + 0xAC8 + 0xc, "UInt") & 31) == 1)
                }

                isTownNPC := isTownNPC(txtFileNo)
                , hp := 0
                , maxhp := 0
                , immunities := { physical: 0, magic: 0, fire: 0, light: 0, cold: 0, poison: 0 }
                if (!isPlayerMinion) {
                    d2rprocess.readRaw(statPtr + 0x2, buffer, statCount*8)
                    Loop, %statCount%
                    {
                        offset := (A_Index -1) * 8
                        , statEnum := NumGet(&buffer , offset, Type := "UShort")
                        , statValue := NumGet(&buffer , offset + 0x2, Type := "UInt")
                        if (isPlayerMinion) {
                            if (statEnum == 0) {
                                if (statValue == "") {
                                    isPlayerMinion := 0
                                }
                                break
                            }
                        }
                        
                        switch (statEnum) {
                            ; no enums here, just bad practices instead
                            case 36: immunities["physical"] := statValue ;physical immune
                            case 37: immunities["magic"] := statValue    ;magic immune
                            case 39: immunities["fire"] := statValue     ;fire resist
                            case 41: immunities["light"] := statValue    ;light resist
                            case 43: immunities["cold"] := statValue     ;cold resist
                            case 45: immunities["poison"] := statValue   ;poison resist
                        }
                        
                        ;if (isBoss) {
                            if (statEnum == 6) {
                                hp := statValue
                                hp := hp >> 8
                                ; 'hp' will now have correct value
                            }
                            if (statEnum == 7) {
                                maxhp := statValue
                                maxhp := maxhp >> 8
                                ; maxhp is the max hp WITHOUT any item/charm/skill boosts applied!
                            }
                        ;}
                    }
                    if (currentHoveringUnitId) {
                        if (currentHoveringUnitId == unitId) { ; monster currently has mouse hovering
                            isHovered := true
                        }
                    }
                }
                mob := {"txtFileNo": txtFileNo, "mode": mode, "x": monx, "y": mony, "isUnique": isUnique, "isBoss": isBoss, "isPlayerMinion": isPlayerMinion, "textTitle": textTitle, "immunities": immunities, "hp": hp, "maxhp": maxhp, "isTownNPC": isTownNPC, "isHovered": isHovered }
                if (isHovered) {
                    hoveredMob := mob
                }
                mobs.push(mob)
            }
            mobUnit := d2rprocess.read(mobUnit + 0x150, "Int64")  ; get next mob
        }
    } 
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
        case "526": return "Nihlathak"
        case "544": return "Baal"
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

getPlayerMinion(txtFileNo){
    switch (txtFileNo) {
        case "271": return "roguehire"
        case "338": return "act2hire"
        case "359": return "act3hire"
        case "560": return "act5hire1"
        case "561": return "act5hire2"
        case "289": return "ClayGolem"
        case "290": return "BloodGolem"
        case "291": return "IronGolem"
        case "292": return "FireGolem"
        case "363": return "NecroSkeleton"
        case "364": return "NecroMage"
        case "417": return "ShadowWarrior"
        case "418": return "ShadowMaster"
        case "419": return "DruidHawk"
        case "420": return "DruidSpiritWolf"
        case "421": return "DruidFenris"
        case "423": return "HeartOfWolverine"
        case "424": return "OakSage"
        case "428": return "DruidBear"
        case "357": return "Valkyrie"
        case "359": return "IronWolf"
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

isTownNPC(txtFileNo) {
    switch (txtFileNo) {
        case 146: return "DeckardCain"
        case 154: return "Charsi"
        case 147: return "Gheed"
        case 150: return "Kashya"
        case 155: return "Warriv"
        case 148: return "Akara"
        case 244: return "DeckardCain"
        case 210: return "Meshif"
        case 175: return "Warriv"
        case 199: return "Elzix"
        case 198: return "Greiz"
        case 177: return "Drognan"
        case 178: return "Fara"
        case 202: return "Lysander"
        case 176: return "Atma"
        case 200: return "Geglash"
        case 331: return "Kaelan"
        case 245: return "DeckardCain"
        case 264: return "Meshif"
        case 255: return "Ormus"
        case 176: return "Atma"
        case 252: return "Asheara"
        case 254: return "Alkor"
        case 253: return "Hratli"
        case 297: return "Natalya"
        case 246: return "DeckardCain"
        case 251: return "Tyrael"
        case 367: return "Tyrael"
        case 521: return "Tyrael"
        case 257: return "Halbu"
        case 405: return "Jamella"
        case 265: return "DeckardCain"
        case 520: return "DeckardCain"
        case 512: return "Drehya"
        case 527: return "Drehya"
        case 515: return "Qual-Kehk"
        case 513: return "Malah"
        case 511: return "Larzuk"
        case 514: return "Nihlathak Town"
        case 266: return "navi"
        case 408: return "Malachai"
        case 406: return "Izual" 
    }
}

; certain NPCs we don't want to see such as mercs
HideNPC(txtFileNo) {
    switch (txtFileNo) {
        case 149: return 1 ;Chicken
        case 151: return 1 ;Rat
        case 152: return 1 ;Rogue
        case 153: return 1 ;HellMeteor
        case 157: return 1 ;Bird
        case 158: return 1 ;Bird2
        case 159: return 1 ;Bat
        case 195: return 1 ;Act2Male
        case 196: return 1 ;Act2Female
        case 197: return 1 ;Act2Child
        case 179: return 1 ;Cow
        case 185: return 1 ;Camel
        case 203: return 1 ;Act2Guard
        case 204: return 1 ;Act2Vendor
        case 205: return 1 ;Act2Vendor2
        case 227: return 1 ;Maggot
        case 268: return 1 ;Bug
        case 269: return 1 ;Scorpion
        ; case 271: return 1 ;Rogue2
        case 272: return 1 ;Rogue3
        case 283: return 1 ;Larva
        case 293: return 1 ;Familiar
        case 294: return 1 ;Act3Male
        ; case 289: return 1 ;ClayGolem
        ; case 290: return 1 ;BloodGolem
        ; case 291: return 1 ;IronGolem
        ; case 292: return 1 ;FireGolem
        case 296: return 1 ;Act3Female
        case 318: return 1 ;Snake
        case 319: return 1 ;Parrot
        case 320: return 1 ;Fish
        case 321: return 1 ;EvilHole
        case 322: return 1 ;EvilHole2
        case 323: return 1 ;EvilHole3
        case 324: return 1 ;EvilHole4
        case 325: return 1 ;EvilHole5
        case 326: return 1 ;FireboltTrap
        case 327: return 1 ;HorzMissileTrap
        case 328: return 1 ;VertMissileTrap
        case 329: return 1 ;PoisonCloudTrap
        case 330: return 1 ;LightningTrap
        case 332: return 1 ;InvisoSpawner
        ; case 338: return 1 ;Guard
        case 339: return 1 ;MiniSpider
        case 344: return 1 ;BoneWall
        case 351: return 1 ;Hydra
        case 352: return 1 ;Hydra2
        case 353: return 1 ;Hydra3
        case 355: return 1 ;SevenTombs
        ; case 357: return 1 ;Valkyrie
        ; case 359: return 1 ;IronWolf
        ; case 363: return 1 ;NecroSkeleton
        ; case 364: return 1 ;NecroMage
        case 366: return 1 ;CompellingOrb},
        case 370: return 1 ;SpiritMummy
        case 377: return 1 ;Act2Guard4
        case 378: return 1 ;Act2Guard5
        case 392: return 1 ;Window
        case 393: return 1 ;Window2
        case 401: return 1 ;MephistoSpirit
        case 410: return 1 ;WakeOfDestruction
        case 411: return 1 ;ChargedBoltSentry
        case 412: return 1 ;LightningSentry
        case 414: return 1 ;InvisiblePet
        case 415: return 1 ;InfernoSentry
        case 416: return 1 ;DeathSentry
        ; case 417: return 1 ;ShadowWarrior
        ; case 418: return 1 ;ShadowMaster
        ; case 419: return 1 ;DruidHawk
        ; case 420: return 1 ;DruidSpiritWolf
        ; case 421: return 1 ;DruidFenris
        ; case 423: return 1 ;HeartOfWolverine
        ; case 424: return 1 ;OakSage
        ; case 428: return 1 ;DruidBear
        case 543: return 1 ;BaalThrone
        case 567: return 1 ;InjuredBarbarian
        case 568: return 1 ;InjuredBarbarian2
        case 569: return 1 ;InjuredBarbarian3
        case 711: return 1 ;DemonHole
    }
    return 0
}