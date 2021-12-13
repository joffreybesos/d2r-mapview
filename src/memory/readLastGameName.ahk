#SingleInstance, Force
SendMode Input
SetWorkingDir, %A_ScriptDir%


readLastGameName(d2rprocess, gameWindowId, settings) {
    if (not WinExist(gameWindowId)) {
        WriteLog(gameWindowId " not found, please make sure game is running")
        WriteTimedLog()
        ExitApp
    }
    gameNameOffset := settings["gameDataOffset"] - 0x188
    gameNameAddress := d2rprocess.BaseAddress + gameNameOffset
    gameName := d2rprocess.readString(gameNameAddress, length := 0)
    return gameName
}
