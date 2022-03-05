
readLastGameName(ByRef d2rprocess, ByRef gameWindowId, ByRef settings, session) {
    if (not WinExist(gameWindowId)) {
        WriteLog(gameWindowId " not found, please make sure game is running")
        if (session) {
            session.saveEntry()
        }
        ExitApp
    }
    gameNameOffset := settings["gameDataOffset"] + 0x48
    gameNameAddress := d2rprocess.BaseAddress + gameNameOffset
    gameName := d2rprocess.readString(gameNameAddress, length := 0)
    return gameName
}
