#SingleInstance, Force
SendMode Input
SetWorkingDir, %A_ScriptDir%

ReadObjects(d2rprocess, startingOffset, ByRef gameObjects) {
    ; items
    gameObjects := []
    objectOffset := startingOffset + (2 * 1024)
    Loop, 256
    {
        newOffset := objectOffset + (8 * (A_Index - 1))
        itemAddress := d2rprocess.BaseAddress + newOffset
        objectUnit := d2rprocess.read(itemAddress, "Int64")
        
        while (objectUnit > 0) { ; keep following the next pointer
            itemType := d2rprocess.read(objectUnit + 0x00, "UInt") ; item is 4
            
            if (itemType == 2) {  ; 2 == object
                txtFileNo := d2rprocess.read(objectUnit + 0x04, "UInt")
                isPortal := isPortal(txtFileNo)
                isShrine := isShrine(txtFileNo)
                isRedPortal := isRedPortal(txtFileNo)
                if (isPortal or isShrine or isRedPortal) {
                    
                    pUnitData := d2rprocess.read(objectUnit + 0x10, "Int64")

                    pObjectTxt := d2rprocess.read(pUnitData, "Int64")
                    sObjectTxt := d2rprocess.readString(pObjectTxt, 16)
                    interactType := d2rprocess.read(pUnitData + 0x08, "UShort")
                    shrineFlag := d2rprocess.read(pUnitData + 0x09, "UShort")
                    shrineTxt := d2rprocess.readString(pUnitData + 0x0c, 16)
                    name := getObjectName(txtFileNo)

                    pPath := d2rprocess.read(objectUnit + 0x38, "Int64")  
                    objectx := d2rprocess.read(pPath + 0x10, "UShort")
                    objecty := d2rprocess.read(pPath + 0x14, "UShort")

                    if (isShrine) {
                        shrineType := shrineType(interactType)
                    }

                    gameObject := {"txtFileNo": txtFileNo, "name": name, "isPortal": isPortal, "isRedPortal": isRedPortal, "isShrine": isShrine, "shrineType": shrineType, "objectx": objectx, "objecty": objecty }
                    ;WriteLog("txtFileNo: " txtFileNo ", name: " name ", isPortal: " isPortal ", isShrine: " isShrine ", objectx: " objectx ", objecty: " objecty)
                    gameObjects.push(gameObject)
                }
                
            }
            objectUnit := d2rprocess.read(objectUnit + 0x150, "Int64")  ; get next item
        }
    } 
    SetFormat Integer, D
}


isShrine(txtFileNo) {
    switch (txtFileNo) {
        case 2: return 1 ;DeerShrine
        case 77: return 1 ;ShrineAltar
        case 81: return 1 ;ForestAltar
        case 83: return 1 ;HornShrine
        case 85: return 1 ;BullShrine
        case 86: return 1 ;SteleShrine
        case 93: return 1 ;InnerHellManaShrine1
        case 96: return 1 ;InnerHellHealthShrine1
        case 97: return 1 ;InnerHellMagicShrine1
        case 109: return 1 ;PalaceShrine
        case 116: return 1 ;SnakeWomanShrine
        case 120: return 1 ;ShrineHealthDungeon
        case 123: return 1 ;InnerHellMagicShrine2
        case 124: return 1 ;InnerHellMagicShrine3
        case 133: return 1 ;ShrineMagicArcaneSanctuary1
        case 134: return 1 ;DesertShrine00
        case 135: return 1 ;DesertShrine01
        case 136: return 1 ;DesertShrine02
        case 149: return 1 ;TaintedSunShrine
        case 150: return 1 ;DesertShrine03
        case 151: return 1 ;DesertShrine04
        case 164: return 1 ;ManaWell1
        case 165: return 1 ;ManaWell2
        case 166: return 1 ;ManaWell3
        case 167: return 1 ;ManaWell4
        case 168: return 1 ;ManaWell5
        case 172: return 1 ;ShrineHealth
        case 173: return 1 ;ShrineMana
        case 184: return 1 ;JungleShrine2
        case 190: return 1 ;JungleShrine3
        case 191: return 1 ;JungleShrine4
        case 197: return 1 ;JungleShrine5
        case 199: return 1 ;MephistoShrine1
        case 200: return 1 ;MephistoShrine2
        case 201: return 1 ;MephistoShrine3
        case 202: return 1 ;MephistoShrine4
        case 206: return 1 ;MephistoShrine5
        case 226: return 1 ;HellShrine1
        case 231: return 1 ;OuterShrineHell2
        case 232: return 1 ;OuterShrineHell3
        case 249: return 1 ;HellManaWell1
        case 260: return 1 ;HolyShrineAct1
        case 262: return 1 ;Act1CathedralShrine
        case 263: return 1 ;Act1JailShrine
        case 264: return 1 ;Act1JailHealthShrine
        case 265: return 1 ;Act1JailManaShrine
        case 275: return 1 ;HealthShrineCavesAct1
        case 276: return 1 ;ManaShrineCavesAct1
        case 277: return 1 ;MagicShrinesCavesAct1
        case 278: return 1 ;ShrineManaDungeon
        case 279: return 1 ;ShrineMagicSewer
        case 280: return 1 ;ShrineHealthSewer
        case 281: return 1 ;ShrineManaSewer
        case 282: return 1 ;ShrineMagicSewer2
        case 299: return 1 ;HaremShrine1
        case 300: return 1 ;HaremShrine2
        case 301: return 1 ;MaggotShrineHealth
        case 302: return 1 ;MaggotShrineMana
        case 303: return 1 ;ShrineMagicArcaneSanctuary2
        case 319: return 1 ;ShrineArcaneHealth
        case 320: return 1 ;ShrineArcaneMana
        case 325: return 1 ;ShrineMagicSewer3
        case 343: return 1 ;ShrineManaKurast
        case 344: return 1 ;ShrineHealthKurast
        case 361: return 1 ;DungeonShrineMagic
        case 414: return 1 ;ShrineWildernessExp1
        case 415: return 1 ;ShrineWildernessExp2
        case 421: return 1 ;ShrineAltarExp
        case 422: return 1 ;ShrineManaExp
        case 423: return 1 ;ShrineHealthExp
        case 427: return 1 ;ShrineWildernessExp3
        case 428: return 1 ;ShrineWildernessExp4
        case 464: return 1 ;ShrineHealthIceCave
        case 465: return 1 ;ShrineManaIceCave
        case 472: return 1 ;ShrineMagicIceCave
        case 479: return 1 ;ShrineMagicIceCave2
        case 483: return 1 ;ShrineBaal1
        case 484: return 1 ;ShrineBaal2
        case 488: return 1 ;ShrineBaalMagic
        case 491: return 1 ;ShrineBaalMana
        case 492: return 1 ;ShrineBaalHealth
        case 495: return 1 ;ShrineMagicSnow1
        case 497: return 1 ;ShrineMagicSnow2
        case 499: return 1 ;ShrineBallMagic2
        case 503: return 1 ;ShrineBaalMagic3
        case 509: return 1 ;ShrineTempleMagic1
        case 512: return 1 ;ShrineTempleMagic2
        case 520: return 1 ;ShrineTempleMagic3
        case 521: return 1 ;ShrineTempleHealth
        case 522: return 1 ;ShrineTempleMana
        case 574: return 1 ;DesertShrineArmor
        case 575: return 1 ;DesertShrineCombat
        case 576: return 1 ;DesertShrineResist
        case 577: return 1 ;DesertShrineSkill
        case 578: return 1 ;DesertShrineRecharge
        case 579: return 1 ;DesertShrineStamina
   }
   return 0
}

isPortal(txtFileNo) {
    switch (txtFileNo) {
        case 59:  return 1 ;townPortal
        case 100: return 1 ;DurielsLairPortal
        case 563: return 1 ;BaalsPortal
    }
    return 0
}

isRedPortal(txtFileNo) {
    switch (txtFileNo) {
        case 60:  return 1 ;PermanentTownPortal
        case 565: return 1 ;LastPortal
        case 566: return 1 ;LastLastPortal
        case 569: return 1 ;BaalsPortal2
        case 298: return 1 ;ArcaneSanctuaryPortal
        case 377: return 1 ;GuildPortal
    }
    return 0
}


getObjectName(txtFileNo) {
    switch (txtFileNo) {
        case 1: return "Casket5"
        case 2: return "Shrine"
        case 3: return "Casket6"
        case 4: return "LargeUrn1"
        case 5: return "LargeChestRight"
        case 6: return "LargeChestLeft"
        case 7: return "Barrel"
        case 8: return "TowerTome"
        case 9: return "Urn2"
        case 10: return "Bench"
        case 11: return "BarrelExploding"
        case 12: return "RogueFountain"
        case 13: return "DoorGateLeft"
        case 14: return "DoorGateRight"
        case 15: return "DoorWoodenLeft"
        case 16: return "DoorWoodenRight"
        case 17: return "CairnStoneAlpha"
        case 18: return "CairnStoneBeta"
        case 19: return "CairnStoneGamma"
        case 20: return "CairnStoneDelta"
        case 21: return "CairnStoneLambda"
        case 22: return "CairnStoneTheta"
        case 23: return "DoorCourtyardLeft"
        case 24: return "DoorCourtyardRight"
        case 25: return "DoorCathedralDouble"
        case 26: return "CainGibbet"
        case 27: return "DoorMonasteryDoubleRight"
        case 28: return "HoleAnim"
        case 29: return "Brazier"
        case 30: return "InifussTree"
        case 31: return "Fountain"
        case 32: return "Crucifix"
        case 33: return "Candles1"
        case 34: return "Candles2"
        case 35: return "Standard1"
        case 36: return "Standard2"
        case 37: return "Torch1Tiki"
        case 38: return "Torch2Wall"
        case 39: return "RogueBonfire"
        case 40: return "River1"
        case 41: return "River2"
        case 42: return "River3"
        case 43: return "River4"
        case 44: return "River5"
        case 45: return "AmbientSoundGenerator"
        case 46: return "Crate"
        case 47: return "AndarielDoor"
        case 48: return "RogueTorch1"
        case 49: return "RogueTorch2"
        case 50: return "CasketR"
        case 51: return "CasketL"
        case 52: return "Urn3"
        case 53: return "Casket"
        case 54: return "RogueCorpse1"
        case 55: return "RogueCorpse2"
        case 56: return "RogueCorpseRolling"
        case 57: return "CorpseOnStick1"
        case 58: return "CorpseOnStick2"
        case 59: return "TownPortal"
        case 60: return "PermanentTownPortal"
        case 61: return "InvisibleObject"
        case 62: return "DoorCathedralLeft"
        case 63: return "DoorCathedralRight"
        case 64: return "DoorWoodenLeft2"
        case 65: return "InvisibleRiverSound1"
        case 66: return "InvisibleRiverSound2"
        case 67: return "Ripple1"
        case 68: return "Ripple2"
        case 69: return "Ripple3"
        case 70: return "Ripple4"
        case 71: return "ForestNightSound1"
        case 72: return "ForestNightSound2"
        case 73: return "YetiDung"
        case 74: return "TrappDoor"
        case 75: return "DoorByAct2Dock"
        case 76: return "SewerDrip"
        case 77: return "HealthOrama"
        case 78: return "InvisibleTownSound"
        case 79: return "Casket3"
        case 80: return "Obelisk"
        case 81: return "ForestAltar"
        case 82: return "BubblingPoolOfBlood"
        case 83: return "HornShrine"
        case 84: return "HealingWell"
        case 85: return "BullHealthShrine"
        case 86: return "SteleDesertMagicShrine"
        case 87: return "TombLargeChestL"
        case 88: return "TombLargeChestR"
        case 89: return "Sarcophagus"
        case 90: return "DesertObelisk"
        case 91: return "TombDoorLeft"
        case 92: return "TombDoorRight"
        case 93: return "InnerHellManaShrine"
        case 94: return "LargeUrn4"
        case 95: return "LargeUrn5"
        case 96: return "InnerHellHealthShrine"
        case 97: return "InnerHellShrine"
        case 98: return "TombDoorLeft2"
        case 99: return "TombDoorRight2"
        case 100: return "DurielsLairPortal"
        case 101: return "Brazier3"
        case 102: return "FloorBrazier"
        case 103: return "Flies"
        case 104: return "ArmorStandRight"
        case 105: return "ArmorStandLeft"
        case 106: return "WeaponRackRight"
        case 107: return "WeaponRackLeft"
        case 108: return "Malus"
        case 109: return "PalaceHealthShrine"
        case 110: return "Drinker"
        case 111: return "Fountain1"
        case 112: return "Gesturer"
        case 113: return "DesertFountain"
        case 114: return "Turner"
        case 115: return "Fountain3"
        case 116: return "SnakeWomanShrine"
        case 117: return "JungleTorch"
        case 118: return "Fountain4"
        case 119: return "WaypointPortal"
        case 120: return "DungeonHealthShrine"
        case 121: return "JerhynPlaceHolder1"
        case 122: return "JerhynPlaceHolder2"
        case 123: return "InnerHellShrine2"
        case 124: return "InnerHellShrine3"
        case 125: return "InnerHellHiddenStash"
        case 126: return "InnerHellSkullPile"
        case 127: return "InnerHellHiddenStash2"
        case 128: return "InnerHellHiddenStash3"
        case 129: return "SecretDoor1"
        case 130: return "Act1WildernessWell"
        case 131: return "VileDogAfterglow"
        case 132: return "CathedralWell"
        case 133: return "ArcaneSanctuaryShrine"
        case 134: return "DesertShrine2"
        case 135: return "DesertShrine3"
        case 136: return "DesertShrine1"
        case 137: return "DesertWell"
        case 138: return "CaveWell"
        case 139: return "Act1LargeChestRight"
        case 140: return "Act1TallChestRight"
        case 141: return "Act1MediumChestRight"
        case 142: return "DesertJug1"
        case 143: return "DesertJug2"
        case 144: return "Act1LargeChest1"
        case 145: return "InnerHellWaypoint"
        case 146: return "Act2MediumChestRight"
        case 147: return "Act2LargeChestRight"
        case 148: return "Act2LargeChestLeft"
        case 149: return "TaintedSunAltar"
        case 150: return "DesertShrine5"
        case 151: return "DesertShrine4"
        case 152: return "HoradricOrifice"
        case 153: return "TyraelsDoor"
        case 154: return "GuardCorpse"
        case 155: return "HiddenStashRock"
        case 156: return "Act2Waypoint"
        case 157: return "Act1WildernessWaypoint"
        case 158: return "SkeletonCorpseIsAnOxymoron"
        case 159: return "HiddenStashRockB"
        case 160: return "SmallFire"
        case 161: return "MediumFire"
        case 162: return "LargeFire"
        case 163: return "Act1CliffHidingSpot"
        case 164: return "ManaWell1"
        case 165: return "ManaWell2"
        case 166: return "ManaWell3"
        case 167: return "ManaWell4"
        case 168: return "ManaWell5"
        case 169: return "HollowLog"
        case 170: return "JungleHealWell"
        case 171: return "SkeletonCorpseIsStillAnOxymoron"
        case 172: return "DesertHealthShrine"
        case 173: return "ManaWell7"
        case 174: return "LooseRock"
        case 175: return "LooseBoulder"
        case 176: return "MediumChestLeft"
        case 177: return "LargeChestLeft2"
        case 178: return "GuardCorpseOnAStick"
        case 179: return "Bookshelf1"
        case 180: return "Bookshelf2"
        case 181: return "JungleChest"
        case 182: return "TombCoffin"
        case 183: return "JungleMediumChestLeft"
        case 184: return "JungleShrine2"
        case 185: return "JungleStashObject1"
        case 186: return "JungleStashObject2"
        case 187: return "JungleStashObject3"
        case 188: return "JungleStashObject4"
        case 189: return "DummyCainPortal"
        case 190: return "JungleShrine3"
        case 191: return "JungleShrine4"
        case 192: return "TeleportationPad1"
        case 193: return "LamEsensTome"
        case 194: return "StairsL"
        case 195: return "StairsR"
        case 196: return "FloorTrap"
        case 197: return "JungleShrine5"
        case 198: return "TallChestLeft"
        case 199: return "MephistoShrine1"
        case 200: return "MephistoShrine2"
        case 201: return "MephistoShrine3"
        case 202: return "MephistoManaShrine"
        case 203: return "MephistoLair"
        case 204: return "StashBox"
        case 205: return "StashAltar"
        case 206: return "MafistoHealthShrine"
        case 207: return "Act3WaterRocks"
        case 208: return "Basket1"
        case 209: return "Basket2"
        case 210: return "Act3WaterLogs"
        case 211: return "Act3WaterRocksGirl"
        case 212: return "Act3WaterBubbles"
        case 213: return "Act3WaterLogsX"
        case 214: return "Act3WaterRocksB"
        case 215: return "Act3WaterRocksGirlC"
        case 216: return "Act3WaterRocksY"
        case 217: return "Act3WaterLogsZ"
        case 218: return "WebCoveredTree1"
        case 219: return "WebCoveredTree2"
        case 220: return "WebCoveredTree3"
        case 221: return "WebCoveredTree4"
        case 222: return "Pillar"
        case 223: return "Cocoon"
        case 224: return "Cocoon2"
        case 225: return "SkullPileH1"
        case 226: return "OuterHellShrine"
        case 227: return "Act3WaterRocksGirlW"
        case 228: return "Act3BigLog"
        case 229: return "SlimeDoor1"
        case 230: return "SlimeDoor2"
        case 231: return "OuterHellShrine2"
        case 232: return "OuterHellShrine3"
        case 233: return "PillarH2"
        case 234: return "Act3BigLogC"
        case 235: return "Act3BigLogD"
        case 236: return "HellHealthShrine"
        case 237: return "Act3TownWaypoint"
        case 238: return "WaypointH"
        case 239: return "BurningBodyTown"
        case 240: return "Gchest1L"
        case 241: return "Gchest2R"
        case 242: return "Gchest3R"
        case 243: return "GLchest3L"
        case 244: return "SewersRatNest"
        case 245: return "BurningBodyTown2"
        case 246: return "SewersRatNest2"
        case 247: return "Act1BedBed1"
        case 248: return "Act1BedBed2"
        case 249: return "HellManaShrine"
        case 250: return "ExplodingCow"
        case 251: return "GidbinnAltar"
        case 252: return "GidbinnAltarDecoy"
        case 253: return "DiabloRightLight"
        case 254: return "DiabloLeftLight"
        case 255: return "DiabloStartPoint"
        case 256: return "Act1CabinStool"
        case 257: return "Act1CabinWood"
        case 258: return "Act1CabinWood2"
        case 259: return "HellSkeletonSpawnNW"
        case 260: return "Act1HolyShrine"
        case 261: return "TombsFloorTrapSpikes"
        case 262: return "Act1CathedralShrine"
        case 263: return "Act1JailShrine1"
        case 264: return "Act1JailShrine2"
        case 265: return "Act1JailShrine3"
        case 266: return "MaggotLairGooPile"
        case 267: return "Bank"
        case 268: return "WirtCorpse"
        case 269: return "GoldPlaceHolder"
        case 270: return "GuardCorpse2"
        case 271: return "DeadVillager1"
        case 272: return "DeadVillager2"
        case 273: return "DummyFlameNoDamage"
        case 274: return "TinyPixelShapedThingie"
        case 275: return "CavesHealthShrine"
        case 276: return "CavesManaShrine"
        case 277: return "CaveMagicShrine"
        case 278: return "Act3DungeonManaShrine"
        case 279: return "Act3SewersMagicShrine1"
        case 280: return "Act3SewersHealthWell"
        case 281: return "Act3SewersManaWell"
        case 282: return "Act3SewersMagicShrine2"
        case 283: return "Act2BrazierCeller"
        case 284: return "Act2TombAnubisCoffin"
        case 285: return "Act2Brazier"
        case 286: return "Act2BrazierTall"
        case 287: return "Act2BrazierSmall"
        case 288: return "Act2CellerWaypoint"
        case 289: return "HarumBedBed"
        case 290: return "IronGrateDoorLeft"
        case 291: return "IronGrateDoorRight"
        case 292: return "WoodenGrateDoorLeft"
        case 293: return "WoodenGrateDoorRight"
        case 294: return "WoodenDoorLeft"
        case 295: return "WoodenDoorRight"
        case 296: return "TombsWallTorchLeft"
        case 297: return "TombsWallTorchRight"
        case 298: return "ArcaneSanctuaryPortal"
        case 299: return "Act2HaramMagicShrine1"
        case 300: return "Act2HaramMagicShrine2"
        case 301: return "MaggotHealthWell"
        case 302: return "MaggotManaWell"
        case 303: return "ArcaneSanctuaryMagicShrine"
        case 304: return "TeleportationPad2"
        case 305: return "TeleportationPad3"
        case 306: return "TeleportationPad4"
        case 307: return "DummyArcaneThing1"
        case 308: return "DummyArcaneThing2"
        case 309: return "DummyArcaneThing3"
        case 310: return "DummyArcaneThing4"
        case 311: return "DummyArcaneThing5"
        case 312: return "DummyArcaneThing6"
        case 313: return "DummyArcaneThing7"
        case 314: return "HaremDeadGuard1"
        case 315: return "HaremDeadGuard2"
        case 316: return "HaremDeadGuard3"
        case 317: return "HaremDeadGuard4"
        case 318: return "HaremEunuchBlocker"
        case 319: return "ArcaneHealthWell"
        case 320: return "ArcaneManaWell"
        case 321: return "TestData2"
        case 322: return "Act2TombWell"
        case 323: return "Act2SewerWaypoint"
        case 324: return "Act3TravincalWaypoint"
        case 325: return "Act3SewerMagicShrine"
        case 326: return "Act3SewerDeadBody"
        case 327: return "Act3SewerTorch"
        case 328: return "Act3KurastTorch"
        case 329: return "MafistoLargeChestLeft"
        case 330: return "MafistoLargeChestRight"
        case 331: return "MafistoMediumChestLeft"
        case 332: return "MafistoMediumChestRight"
        case 333: return "SpiderLairLargeChestLeft"
        case 334: return "SpiderLairTallChestLeft"
        case 335: return "SpiderLairMediumChestRight"
        case 336: return "SpiderLairTallChestRight"
        case 337: return "SteegStone"
        case 338: return "GuildVault"
        case 339: return "TrophyCase"
        case 340: return "MessageBoard"
        case 341: return "MephistoBridge"
        case 342: return "HellGate"
        case 343: return "Act3KurastManaWell"
        case 344: return "Act3KurastHealthWell"
        case 345: return "HellFire1"
        case 346: return "HellFire2"
        case 347: return "HellFire3"
        case 348: return "HellLava1"
        case 349: return "HellLava2"
        case 350: return "HellLava3"
        case 351: return "HellLightSource1"
        case 352: return "HellLightSource2"
        case 353: return "HellLightSource3"
        case 354: return "HoradricCubeChest"
        case 355: return "HoradricScrollChest"
        case 356: return "StaffOfKingsChest"
        case 357: return "YetAnotherTome"
        case 358: return "HellBrazier1"
        case 359: return "HellBrazier2"
        case 360: return "DungeonRockPile"
        case 361: return "Act3DungeonMagicShrine"
        case 362: return "Act3DungeonBasket"
        case 363: return "OuterHellHungSkeleton"
        case 364: return "GuyForDungeon"
        case 365: return "Act3DungeonCasket"
        case 366: return "Act3SewerStairs"
        case 367: return "Act3SewerStairsToLevel3"
        case 368: return "DarkWandererStartPosition"
        case 369: return "TrappedSoulPlaceHolder"
        case 370: return "Act3TownTorch"
        case 371: return "LargeChestR"
        case 372: return "InnerHellBoneChest"
        case 373: return "HellSkeletonSpawnNE"
        case 374: return "Act3WaterFog"
        case 375: return "DummyNotUsed"
        case 376: return "HellForge"
        case 377: return "GuildPortal"
        case 378: return "HratliStartPosition"
        case 379: return "HratliEndPosition"
        case 380: return "BurningTrappedSoul1"
        case 381: return "BurningTrappedSoul2"
        case 382: return "NatalyaStartPosition"
        case 383: return "StuckedTrappedSoul1"
        case 384: return "StuckedTrappedSoul2"
        case 385: return "CainStartPosition"
        case 386: return "StairSR"
        case 387: return "ArcaneLargeChestLeft"
        case 388: return "ArcaneCasket"
        case 389: return "ArcaneLargeChestRight"
        case 390: return "ArcaneSmallChestLeft"
        case 391: return "ArcaneSmallChestRight"
        case 392: return "DiabloSeal1"
        case 393: return "DiabloSeal2"
        case 394: return "DiabloSeal3"
        case 395: return "DiabloSeal4"
        case 396: return "DiabloSeal5"
        case 397: return "SparklyChest"
        case 398: return "PandamoniumFortressWaypoint"
        case 399: return "InnerHellFissure"
        case 400: return "HellMesaBrazier"
        case 401: return "Smoke"
        case 402: return "ValleyWaypoint"
        case 403: return "HellBrazier3"
        case 404: return "CompellingOrb"
        case 405: return "KhalimChest1"
        case 406: return "KhalimChest2"
        case 407: return "KhalimChest3"
        case 408: return "SiegeMachineControl"
        case 409: return "PotOTorch"
        case 410: return "PyoxFirePit"
        case 413: return "ExpansionChestRight"
        case 414: return "ExpansionWildernessShrine1"
        case 415: return "ExpansionWildernessShrine2"
        case 416: return "ExpansionHiddenStash"
        case 417: return "ExpansionWildernessFlag"
        case 418: return "ExpansionWildernessBarrel"
        case 419: return "ExpansionSiegeBarrel"
        case 420: return "ExpansionWoodChestLeft"
        case 421: return "ExpansionWildernessShrine3"
        case 422: return "ExpansionManaShrine"
        case 423: return "ExpansionHealthShrine"
        case 424: return "BurialChestLeft"
        case 425: return "BurialChestRight"
        case 426: return "ExpansionWell"
        case 427: return "ExpansionWildernessShrine4"
        case 428: return "ExpansionWildernessShrine5"
        case 429: return "ExpansionWaypoint"
        case 430: return "ExpansionChestLeft"
        case 431: return "ExpansionWoodChestRight"
        case 432: return "ExpansionSmallChestLeft"
        case 433: return "ExpansionSmallChestRight"
        case 434: return "ExpansionTorch1"
        case 435: return "ExpansionCampFire"
        case 436: return "ExpansionTownTorch"
        case 437: return "ExpansionTorch2"
        case 438: return "ExpansionBurningBodies"
        case 439: return "ExpansionBurningPit"
        case 440: return "ExpansionTribalFlag"
        case 441: return "ExpansionTownFlag"
        case 442: return "ExpansionChandelier"
        case 443: return "ExpansionJar1"
        case 444: return "ExpansionJar2"
        case 445: return "ExpansionJar3"
        case 446: return "ExpansionSwingingHeads"
        case 447: return "ExpansionWildernessPole"
        case 448: return "AnimatedSkullAndRockPile"
        case 449: return "ExpansionTownGate"
        case 450: return "SkullAndRockPile"
        case 451: return "SiegeHellGate"
        case 452: return "EnemyCampBanner1"
        case 453: return "EnemyCampBanner2"
        case 454: return "ExpansionExplodingChest"
        case 455: return "ExpansionSpecialChest"
        case 456: return "ExpansionDeathPole"
        case 457: return "ExpansionDeathPoleLeft"
        case 458: return "TempleAltar"
        case 459: return "DrehyaTownStartPosition"
        case 460: return "DrehyaWildernessStartPosition"
        case 461: return "NihlathakTownStartPosition"
        case 462: return "NihlathakWildernessStartPosition"
        case 463: return "IceCaveHiddenStash"
        case 464: return "IceCaveHealthShrine"
        case 465: return "IceCaveManaShrine"
        case 466: return "IceCaveEvilUrn"
        case 467: return "IceCaveJar1"
        case 468: return "IceCaveJar2"
        case 469: return "IceCaveJar3"
        case 470: return "IceCaveJar4"
        case 471: return "IceCaveJar5"
        case 472: return "IceCaveMagicShrine"
        case 473: return "CagedWussie"
        case 474: return "AncientStatue3"
        case 475: return "AncientStatue1"
        case 476: return "AncientStatue2"
        case 477: return "DeadBarbarian"
        case 478: return "ClientSmoke"
        case 479: return "IceCaveMagicShrine2"
        case 480: return "IceCaveTorch1"
        case 481: return "IceCaveTorch2"
        case 482: return "ExpansionTikiTorch"
        case 483: return "WorldstoneManaShrine"
        case 484: return "WorldstoneHealthShrine"
        case 485: return "WorldstoneTomb1"
        case 486: return "WorldstoneTomb2"
        case 487: return "WorldstoneTomb3"
        case 488: return "WorldstoneMagicShrine"
        case 489: return "WorldstoneTorch1"
        case 490: return "WorldstoneTorch2"
        case 491: return "ExpansionSnowyManaShrine1"
        case 492: return "ExpansionSnowyHealthShrine"
        case 493: return "ExpansionSnowyWell"
        case 494: return "WorldstoneWaypoint"
        case 495: return "ExpansionSnowyMagicShrine2"
        case 496: return "ExpansionWildernessWaypoint"
        case 497: return "ExpansionSnowyMagicShrine3"
        case 498: return "WorldstoneWell"
        case 499: return "WorldstoneMagicShrine2"
        case 500: return "ExpansionSnowyObject1"
        case 501: return "ExpansionSnowyWoodChestLeft"
        case 502: return "ExpansionSnowyWoodChestRight"
        case 503: return "WorldstoneMagicShrine3"
        case 504: return "ExpansionSnowyWoodChest2Left"
        case 505: return "ExpansionSnowyWoodChest2Right"
        case 506: return "SnowySwingingHeads"
        case 507: return "SnowyDebris"
        case 508: return "PenBreakableDoor"
        case 509: return "ExpansionTempleMagicShrine1"
        case 510: return "ExpansionSnowyPoleMR"
        case 511: return "IceCaveWaypoint"
        case 512: return "ExpansionTempleMagicShrine2"
        case 513: return "ExpansionTempleWell"
        case 514: return "ExpansionTempleTorch1"
        case 515: return "ExpansionTempleTorch2"
        case 516: return "ExpansionTempleObject1"
        case 517: return "ExpansionTempleObject2"
        case 518: return "WorldstoneMrBox"
        case 519: return "IceCaveWell"
        case 520: return "ExpansionTempleMagicShrine"
        case 521: return "ExpansionTempleHealthShrine"
        case 522: return "ExpansionTempleManaShrine"
        case 523: return "BlacksmithForge"
        case 524: return "WorldstoneTomb1Left"
        case 525: return "WorldstoneTomb2Left"
        case 526: return "WorldstoneTomb3Left"
        case 527: return "IceCaveBubblesU"
        case 528: return "IceCaveBubblesS"
        case 529: return "RedBaalsLairTomb1"
        case 530: return "RedBaalsLairTomb1Left"
        case 531: return "RedBaalsLairTomb2"
        case 532: return "RedBaalsLairTomb2Left"
        case 533: return "RedBaalsLairTomb3"
        case 534: return "RedBaalsLairTomb3Left"
        case 535: return "RedBaalsLairMrBox"
        case 536: return "RedBaalsLairTorch1"
        case 537: return "RedBaalsLairTorch2"
        case 538: return "CandlesTemple"
        case 539: return "TempleWaypoint"
        case 540: return "ExpansionDeadPerson1"
        case 541: return "TempleGroundTomb"
        case 542: return "LarzukGreeting"
        case 543: return "LarzukStandard"
        case 544: return "TempleGroundTombLeft"
        case 545: return "ExpansionDeadPerson2"
        case 546: return "AncientsAltar"
        case 547: return "ArreatSummitDoorToWorldstone"
        case 548: return "ExpansionWeaponRackRight"
        case 549: return "ExpansionWeaponRackLeft"
        case 550: return "ExpansionArmorStandRight"
        case 551: return "ExpansionArmorStandLeft"
        case 552: return "ArreatsSummitTorch2"
        case 553: return "ExpansionFuneralSpire"
        case 554: return "ExpansionBurningLogs"
        case 555: return "IceCaveSteam"
        case 556: return "ExpansionDeadPerson3"
        case 557: return "BaalsLair"
        case 558: return "FrozenAnya"
        case 559: return "BBQBunny"
        case 560: return "BaalTorchBig"
        case 561: return "InvisibleAncient"
        case 562: return "InvisibleBase"
        case 563: return "BaalsPortal"
        case 564: return "ArreatSummitDoor"
        case 565: return "LastPortal"
        case 566: return "LastLastPortal"
        case 567: return "ZooTestData"
        case 568: return "KeeperTestData"
        case 569: return "BaalsPortal2"
        case 570: return "FirePlaceGuy"
        case 571: return "DoorBlocker1"
        case 572: return "DoorBlocker2"
        case 580: return "GoodChest"
        case 581: return "NotSoGoodChest"
    }
    return ""
}

shrineType(interactType) {
    switch (interactType) {
        case 1: return "Refill"
        case 2: return "Health"
        case 3: return "Mana"
        case 4: return "HPXChange"
        case 5: return "ManaXChange"
        case 6: return "Armor"
        case 7: return "Combat"
        case 8: return "ResistFire"
        case 9: return "ResistCold"
        case 10: return "ResistLight"
        case 11: return "ResistPoison"
        case 12: return "Skill"
        case 13: return "ManaRegen"
        case 14: return "Stamina"
        case 15: return "Experience"
        case 16: return "Shrine"
        case 17: return "Portal"
        case 18: return "Gem"
        case 19: return "Fire"
        case 20: return "Monster"
        case 21: return "Explosive"
        case 22: return "Poison"
    }
    return ""
}