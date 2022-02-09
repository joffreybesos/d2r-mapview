SetWorkingDir, %A_ScriptDir%

class GameSession {
    gameName := ""
    playerName := ""
    startTime := 0
    endTime := 0
    duration := ""

    startingPlayerLevel :=
    endingPlayerLevel :=
    startingExperience :=
    endingExperience :=

    isLogged := false
    __new(gameName, startTime, playerName) {
        this.gameName := gameName
        this.startTime := startTime
        this.playerName := playerName
    }

    setEndTime(endTime) {
        this.endTime := endTime
        if (this.startTime == 0) {
            this.duration := ""
        } else if (this.endTime == 0) {
            this.duration :=  Round((A_TickCount - this.startTime) / 1000.0, 2)
        } else {
            this.duration :=  Round((this.endTime - this.startTime) / 1000.0, 2)
        }
    }

    getExperienceGained() {
        return this.endingExperience - this.startingExperience
    }

    getEntry() {
        duration := this.duration
        expgained := this.getExperienceGained()
        FormatTime, vDate,, yyyy-MM-dd HH-mm-ss ;24-hour
        entry := vDate "," this.playerName "," this.gameName "," duration "," this.startingPlayerLevel "," this.endingPlayerLevel "," this.startingExperience "," this.endingExperience "," expgained
        return entry
    }

    saveEntryToFile() {
        if (!this.isLogged) { ; only log it once
            entry := this.getEntry()
            if (!FileExist("GameSessionLog.csv")) {
                headerRow := "Timestamp,PlayerName,GameName,Duration,PlayerLevelStart,PlayerLevelEnd,StartingExperience,EndingExperience,ExperienceGained"
                FileAppend, %headerRow%`n, GameSessionLog.csv
            }
            FileAppend, %entry%`n, GameSessionLog.csv
            this.isLogged := true
        }
    }

    getPreciseLevel() {
        if (this.endingPlayerLevel) {
            levelDetails := getLevelExp(this.endingPlayerLevel)
            pcProgress := (this.endingExperience - levelDetails.basexp) / levelDetails.xpdiff
            newLevel := Round(this.endingPlayerLevel + pcProgress, 2)
            return newLevel
        }
        return ""
    }
}

getLevelExp(pLevel) {
    switch (pLevel) {
        case 1: return { "basexp": 0, "next": 500, "xpdiff": 500}
        case 2: return { "basexp": 500, "next": 1500, "xpdiff": 1000}
        case 3: return { "basexp": 1500, "next": 3750, "xpdiff": 2250}
        case 4: return { "basexp": 3750, "next": 7875, "xpdiff": 4125}
        case 5: return { "basexp": 7875, "next": 14175, "xpdiff": 6300}
        case 6: return { "basexp": 14175, "next": 22680, "xpdiff": 8505}
        case 7: return { "basexp": 22680, "next": 32886, "xpdiff": 10206}
        case 8: return { "basexp": 32886, "next": 44396, "xpdiff": 11510}
        case 9: return { "basexp": 44396, "next": 57715, "xpdiff": 13319}
        case 10: return { "basexp": 57715, "next": 72144, "xpdiff": 14429}
        case 11: return { "basexp": 72144, "next": 90180, "xpdiff": 18036}
        case 12: return { "basexp": 90180, "next": 112725, "xpdiff": 22545}
        case 13: return { "basexp": 112725, "next": 140906, "xpdiff": 28181}
        case 14: return { "basexp": 140906, "next": 176132, "xpdiff": 35226}
        case 15: return { "basexp": 176132, "next": 220165, "xpdiff": 44033}
        case 16: return { "basexp": 220165, "next": 275207, "xpdiff": 55042}
        case 17: return { "basexp": 275207, "next": 344008, "xpdiff": 68801}
        case 18: return { "basexp": 344008, "next": 430010, "xpdiff": 86002}
        case 19: return { "basexp": 430010, "next": 537513, "xpdiff": 107503}
        case 20: return { "basexp": 537513, "next": 671891, "xpdiff": 134378}
        case 21: return { "basexp": 671891, "next": 839864, "xpdiff": 167973}
        case 22: return { "basexp": 839864, "next": 1049830, "xpdiff": 209966}
        case 23: return { "basexp": 1049830, "next": 1312287, "xpdiff": 262457}
        case 24: return { "basexp": 1312287, "next": 1640359, "xpdiff": 328072}
        case 25: return { "basexp": 1640359, "next": 2050449, "xpdiff": 410090}
        case 26: return { "basexp": 2050449, "next": 2563061, "xpdiff": 512612}
        case 27: return { "basexp": 2563061, "next": 3203826, "xpdiff": 640765}
        case 28: return { "basexp": 3203826, "next": 3902260, "xpdiff": 698434}
        case 29: return { "basexp": 3902260, "next": 4663553, "xpdiff": 761293}
        case 30: return { "basexp": 4663553, "next": 5493363, "xpdiff": 829810}
        case 31: return { "basexp": 5493363, "next": 6397855, "xpdiff": 904492}
        case 32: return { "basexp": 6397855, "next": 7383752, "xpdiff": 985897}
        case 33: return { "basexp": 7383752, "next": 8458379, "xpdiff": 1074627}
        case 34: return { "basexp": 8458379, "next": 9629723, "xpdiff": 1171344}
        case 35: return { "basexp": 9629723, "next": 10906488, "xpdiff": 1276765}
        case 36: return { "basexp": 10906488, "next": 12298162, "xpdiff": 1391674}
        case 37: return { "basexp": 12298162, "next": 13815086, "xpdiff": 1516924}
        case 38: return { "basexp": 13815086, "next": 15468534, "xpdiff": 1653448}
        case 39: return { "basexp": 15468534, "next": 17270791, "xpdiff": 1802257}
        case 40: return { "basexp": 17270791, "next": 19235252, "xpdiff": 1964461}
        case 41: return { "basexp": 19235252, "next": 21376515, "xpdiff": 2141263}
        case 42: return { "basexp": 21376515, "next": 23710491, "xpdiff": 2333976}
        case 43: return { "basexp": 23710491, "next": 26254525, "xpdiff": 2544034}
        case 44: return { "basexp": 26254525, "next": 29027522, "xpdiff": 2772997}
        case 45: return { "basexp": 29027522, "next": 32050088, "xpdiff": 3022566}
        case 46: return { "basexp": 32050088, "next": 35344686, "xpdiff": 3294598}
        case 47: return { "basexp": 35344686, "next": 38935798, "xpdiff": 3591112}
        case 48: return { "basexp": 38935798, "next": 42850109, "xpdiff": 3914311}
        case 49: return { "basexp": 42850109, "next": 47116709, "xpdiff": 4266600}
        case 50: return { "basexp": 47116709, "next": 51767302, "xpdiff": 4650593}
        case 51: return { "basexp": 51767302, "next": 56836449, "xpdiff": 5069147}
        case 52: return { "basexp": 56836449, "next": 62361819, "xpdiff": 5525370}
        case 53: return { "basexp": 62361819, "next": 68384473, "xpdiff": 6022654}
        case 54: return { "basexp": 68384473, "next": 74949165, "xpdiff": 6564692}
        case 55: return { "basexp": 74949165, "next": 82104680, "xpdiff": 7155515}
        case 56: return { "basexp": 82104680, "next": 89904191, "xpdiff": 7799511}
        case 57: return { "basexp": 89904191, "next": 98405658, "xpdiff": 8501467}
        case 58: return { "basexp": 98405658, "next": 107672256, "xpdiff": 9266598}
        case 59: return { "basexp": 107672256, "next": 117772849, "xpdiff": 10100593}
        case 60: return { "basexp": 117772849, "next": 128782495, "xpdiff": 11009646}
        case 61: return { "basexp": 128782495, "next": 140783010, "xpdiff": 12000515}
        case 62: return { "basexp": 140783010, "next": 153863570, "xpdiff": 13080560}
        case 63: return { "basexp": 153863570, "next": 168121381, "xpdiff": 14257811}
        case 64: return { "basexp": 168121381, "next": 183662396, "xpdiff": 15541015}
        case 65: return { "basexp": 183662396, "next": 200602101, "xpdiff": 16939705}
        case 66: return { "basexp": 200602101, "next": 219066380, "xpdiff": 18464279}
        case 67: return { "basexp": 219066380, "next": 239192444, "xpdiff": 20126064}
        case 68: return { "basexp": 239192444, "next": 261129853, "xpdiff": 21937409}
        case 69: return { "basexp": 261129853, "next": 285041630, "xpdiff": 23911777}
        case 70: return { "basexp": 285041630, "next": 311105466, "xpdiff": 26063836}
        case 71: return { "basexp": 311105466, "next": 339515048, "xpdiff": 28409582}
        case 72: return { "basexp": 339515048, "next": 370481492, "xpdiff": 30966444}
        case 73: return { "basexp": 370481492, "next": 404234916, "xpdiff": 33753424}
        case 74: return { "basexp": 404234916, "next": 441026148, "xpdiff": 36791232}
        case 75: return { "basexp": 441026148, "next": 481128591, "xpdiff": 40102443}
        case 76: return { "basexp": 481128591, "next": 524840254, "xpdiff": 43711663}
        case 77: return { "basexp": 524840254, "next": 572485967, "xpdiff": 47645713}
        case 78: return { "basexp": 572485967, "next": 624419793, "xpdiff": 51933826}
        case 79: return { "basexp": 624419793, "next": 681027665, "xpdiff": 56607872}
        case 80: return { "basexp": 681027665, "next": 742730244, "xpdiff": 61702579}
        case 81: return { "basexp": 742730244, "next": 809986056, "xpdiff": 67255812}
        case 82: return { "basexp": 809986056, "next": 883294891, "xpdiff": 73308835}
        case 83: return { "basexp": 883294891, "next": 963201521, "xpdiff": 79906630}
        case 84: return { "basexp": 963201521, "next": 1050299747, "xpdiff": 87098226}
        case 85: return { "basexp": 1050299747, "next": 1145236814, "xpdiff": 94937067}
        case 86: return { "basexp": 1145236814, "next": 1248718217, "xpdiff": 103481403}
        case 87: return { "basexp": 1248718217, "next": 1361512946, "xpdiff": 112794729}
        case 88: return { "basexp": 1361512946, "next": 1484459201, "xpdiff": 122946255}
        case 89: return { "basexp": 1484459201, "next": 1618470619, "xpdiff": 134011418}
        case 90: return { "basexp": 1618470619, "next": 1764543065, "xpdiff": 146072446}
        case 91: return { "basexp": 1764543065, "next": 1923762030, "xpdiff": 159218965}
        case 92: return { "basexp": 1923762030, "next": 2097310703, "xpdiff": 173548673}
        case 93: return { "basexp": 2097310703, "next": 2286478756, "xpdiff": 189168053}
        case 94: return { "basexp": 2286478756, "next": 2492671933, "xpdiff": 206193177}
        case 95: return { "basexp": 2492671933, "next": 2717422497, "xpdiff": 224750564}
        case 96: return { "basexp": 2717422497, "next": 2962400612, "xpdiff": 244978115}
        case 97: return { "basexp": 2962400612, "next": 3229426756, "xpdiff": 267026144}
        case 98: return { "basexp": 3229426756, "next": 3520485254, "xpdiff": 291058498}
        case 99: return { "basexp": 3520485254, "next": 3837739017, "xpdiff": 317253763}
    }
}