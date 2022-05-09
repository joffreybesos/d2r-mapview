
readLastGameName(ByRef d2rprocess, ByRef gameWindowId, ByRef offsets, ByRef session) {
    if (not WinExist(gameWindowId)) {
        WriteLog(gameWindowId " not found, please make sure game is running")
        if (session) {
            session.saveEntry()
        }
        ExitApp
    }
    gameNameOffset := offsets["gameDataOffset"] + 0x40
    gameNameAddress := d2rprocess.BaseAddress + gameNameOffset
    gameName := d2rprocess.readString(gameNameAddress, length := 0)
    return gameName
}
