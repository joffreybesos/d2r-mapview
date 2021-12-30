#SingleInstance, Force

#Include %A_ScriptDir%\stats\GameSession.ahk

readSessionFile(historyFile) {
    sessionList := []
    Loop, read, %historyFile%
    {
        if (A_Index > 1) {
            Loop, parse, A_LoopReadLine, CSV
            {
                switch (A_Index) {
                  case 2: playerName := A_LoopField  
                  case 3: gameName := A_LoopField
                  case 4: duration := A_LoopField
                  case 5: startingPlayerLevel := A_LoopField
                  case 6: endingPlayerLevel := A_LoopField
                  case 7: startingExperience := A_LoopField
                  case 8: endingExperience := A_LoopField
                }

                
            }
            session := new GameSession(gameName, A_TickCount, playerName)
            session.duration := duration
            session.startingPlayerLevel := startingPlayerLevel
            session.endingPlayerLevel := endingPlayerLevel
            session.startingExperience := startingExperience
            session.endingExperience := endingExperience
            sessionList.push(session)
        }
        if (A_Index > 50)
            break
    }
    return sessionList
}