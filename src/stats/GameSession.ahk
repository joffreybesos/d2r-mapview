class GameSession {
    gameName := ""
    playerName := ""
    startTime := 0
    endTime := 0
    isLogged := false
    __new(gameName, startTime, playerName) {
        this.gameName := gameName
        this.startTime := startTime
        this.playerName := playerName
    }

    setEndTime(endTime) {
        this.endTime := endTime
    }

    getDuration() {
        if (this.endTime == 0) {
            return Round((A_TickCount - this.startTime) / 1000.0, 2)
        } else {
            return Round((this.endTime - this.startTime) / 1000.0, 2)
        }
    }

    saveEntry() {
        if (!this.isLogged) { ; only log it once
            duration := this.getDuration()
            entry := this.playerName "," this.gameName "," duration
            FileAppend, %entry%`n, gameSessionLog.csv
            this.isLogged := true
        }
    }
}