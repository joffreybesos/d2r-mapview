#SingleInstance, Force
#Include %A_ScriptDir%\include\Jxon.ahk
#Include %A_ScriptDir%\include\logging.ahk
SendMode Input
SetWorkingDir, %A_ScriptDir%


;getLevelInfo("http://diab.wikiwarsgame.com:8080", "123456", "2", "72")


getLevelInfo(sMapUrl) {
    mapFileName := RegExReplace(sMapUrl, "^.+?map\/.*?")
    mapFileName := StrReplace(mapFileName, "/", "_")
    
    sFile=%A_Temp%\%mapFileName%.json
    if !FileExist(sFile) {
        URLDownloadToFile, %sMapUrl%, %sFile%
    }

    FileRead, Contents, %sFile%
    mapJsonData := Jxon_Load(Contents)
    ; WriteLog(mapJsonData["offset"]["x"])
    ; WriteLog(mapJsonData["offset"]["y"])
    ; WriteLog(mapJsonData["size"]["width"])
    ; WriteLog(mapJsonData["size"]["height"])
    return mapJsonData
}

getExits(mapJsonData) {
    exitArray := []
    
    for k, v in  mapJsonData["objects"] {
        if (v.type = "exit") {
            WriteLogDebug("Found exit on map " v.id " - '" getExitName(v.id) "' at x" v.x " y" v.y)
            exitPosition := []
            exitPosition[0] = v.id
            exitPosition[1] = v.name
            exitPosition[2] = v.x
            exitPosition[3] = v.y
            exitArray.push(exitPosition)
        }
    }
    return exitArray
}

getExitName(id) {
    Switch id
    {
        Case 1: return "Rogue Encampment"
        Case 2: return "Blood Moor"
        Case 3: return "Cold Plains"
        Case 4: return "Stony Field"
        Case 5: return "Dark Wood"
        Case 6: return "Black Marsh"
        Case 7: return "Tamoe Highland"
        Case 8: return "Den of Evil"
        Case 9: return "Cave Level 1"
        Case 10: return "Underground Passage Level 1"
        Case 11: return "Hole Level 1"
        Case 12: return "Pit Level 1"
        Case 13: return "Cave Level 2"
        Case 14: return "Underground Passage Level 2"
        Case 15: return "Hole Level 2"
        Case 16: return "Pit Level 2"
        Case 17: return "Burial Grounds"
        Case 18: return "Crypt"
        Case 19: return "Mausoleum"
        Case 20: return "Forgotten Tower"
        Case 21: return "Tower Cellar Level 1"
        Case 22: return "Tower Cellar Level 2"
        Case 23: return "Tower Cellar Level 3"
        Case 24: return "Tower Cellar Level 4"
        Case 25: return "Tower Cellar Level 5"
        Case 26: return "Monastery Gate"
        Case 27: return "Outer Cloister"
        Case 28: return "Barracks"
        Case 29: return "Jail Level 1"
        Case 30: return "Jail Level 2"
        Case 31: return "Jail Level 3"
        Case 32: return "Inner Cloister"
        Case 33: return "Cathedral"
        Case 34: return "Catacombs Level 1"
        Case 35: return "Catacombs Level 2"
        Case 36: return "Catacombs Level 3"
        Case 37: return "Catacombs Level 4"
        Case 38: return "Tristram"
        Case 39: return "Moo Moo Farm"
        Case 40: return "Lut Gholein"
        Case 41: return "Rocky Waste"
        Case 42: return "Dry Hills"
        Case 43: return "Far Oasis"
        Case 44: return "Lost City"
        Case 45: return "Valley of Snakes"
        Case 46: return "Canyon of the Magi"
        Case 47: return "Sewers Level 1"
        Case 48: return "Sewers Level 2"
        Case 49: return "Sewers Level 3"
        Case 50: return "Harem Level 1"
        Case 51: return "Harem Level 2"
        Case 52: return "Palace Cellar Level 1 "
        Case 53: return "Palace Cellar Level 2"
        Case 54: return "Palace Cellar Level 3"
        Case 55: return "Stony Tomb Level 1"
        Case 56: return "Halls of the Dead Level 1"
        Case 57: return "Halls of the Dead Level 2"
        Case 58: return "Claw Viper Temple Level 1"
        Case 59: return "Stony Tomb Level 2"
        Case 60: return "Halls of the Dead Level 3"
        Case 61: return "Claw Viper Temple Level 2"
        Case 62: return "Maggot Lair Level 1"
        Case 63: return "Maggot Lair Level 2"
        Case 64: return "Maggot Lair Level 3"
        Case 65: return "Ancient Tunnels"
        Case 66: return "Tal Rasha's Tomb"
        Case 67: return "Tal Rasha's Tomb"
        Case 68: return "Tal Rasha's Tomb"
        Case 69: return "Tal Rasha's Tomb"
        Case 70: return "Tal Rasha's Tomb"
        Case 71: return "Tal Rasha's Tomb"
        Case 72: return "Tal Rasha's Tomb"
        Case 73: return "Duriel's Lair"
        Case 74: return "Arcane Sanctuary"
        Case 75: return "Kurast Docktown"
        Case 76: return "Spider Forest"
        Case 77: return "Great Marsh"
        Case 78: return "Flayer Jungle"
        Case 79: return "Lower Kurast"
        Case 80: return "Kurast Bazaar"
        Case 81: return "Upper Kurast"
        Case 82: return "Kurast Causeway"
        Case 83: return "Travincal"
        Case 84: return "Spider Cave"
        Case 85: return "Spider Cavern"
        Case 86: return "Swampy Pit Level 1"
        Case 87: return "Swampy Pit Level 2"
        Case 88: return "Flayer Dungeon Level 1"
        Case 89: return "Flayer Dungeon Level 2"
        Case 90: return "Swampy Pit Level 3"
        Case 91: return "Flayer Dungeon Level 3"
        Case 92: return "Sewers Level 1"
        Case 93: return "Sewers Level 2"
        Case 94: return "Ruined Temple"
        Case 95: return "Disused Fane"
        Case 96: return "Forgotten Reliquary"
        Case 97: return "Forgotten Temple"
        Case 98: return "Ruined Fane"
        Case 99: return "Disused Reliquary"
        Case 100: return "Durance of Hate Level 1"
        Case 101: return "Durance of Hate Level 2"
        Case 102: return "Durance of Hate Level 3"
        Case 103: return "The Pandemonium Fortress"
        Case 104: return "Outer Steppes"
        Case 105: return "Plains of Despair"
        Case 106: return "City of the Damned"
        Case 107: return "River of Flame"
        Case 108: return "Chaos Sanctum"
        Case 109: return "Harrogath"
        Case 110: return "Bloody Foothills"
        Case 111: return "Rigid Highlands"
        Case 112: return "Arreat Plateau"
        Case 113: return "Crystalized Cavern Level 1"
        Case 114: return "Cellar of Pity"
        Case 115: return "Crystalized Cavern Level 2"
        Case 116: return "Echo Chamber"
        Case 117: return "Tundra Wastelands"
        Case 118: return "Glacial Caves Level 1"
        Case 119: return "Glacial Caves Level 2"
        Case 120: return "Rocky Summit"
        Case 121: return "Nihlathaks Temple"
        Case 122: return "Halls of Anguish"
        Case 123: return "Halls of Death's Calling"
        Case 124: return "Halls of Vaught"
        Case 125: return "Hell1"
        Case 126: return "Hell2"
        Case 127: return "Hell3"
        Case 128: return "The Worldstone Keep Level 1"
        Case 129: return "The Worldstone Keep Level 2"
        Case 130: return "The Worldstone Keep Level 3"
        Case 131: return "Throne of Destruction"
        Case 132: return "The Worldstone Chamber"
        Case 133: return "Pandemonium Run 1"
        Case 134: return "Pandemonium Run 2"
        Case 135: return "Pandemonium Run 3"
        Case 136: return "Tristram"
    }
}