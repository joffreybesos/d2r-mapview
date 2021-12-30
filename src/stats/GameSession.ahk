SetWorkingDir, %A_ScriptDir%

class GameSession {
    gameName := ""
    playerName := ""
    startTime := 0
    endTime := 0

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
    }

    getExperienceGained() {
        return this.endingExperience - this.startingExperience
    }

    getDuration() {
        SetFormat Integer, D
        if (this.endTime == 0) {
            return Round((A_TickCount - this.startTime) / 1000.0, 2)
        } else {
            return Round((this.endTime - this.startTime) / 1000.0, 2)
        }
    }

    getEntry() {
        duration := this.getDuration()
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
}