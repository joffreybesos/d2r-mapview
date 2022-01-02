#SingleInstance, Force
SendMode Input
SetWorkingDir, %A_ScriptDir%


readIPAddress(d2rprocess, gameWindowId, settings, session) {
    if (not WinExist(gameWindowId)) {
        WriteLog(gameWindowId " not found, please make sure game is running")
        if (session) {
            session.saveEntry()
        }
        ExitApp
    }
    ipOffset := settings["gameDataOffset"] + 0x1D0
    ipAddressAddress := d2rprocess.BaseAddress + ipOffset
    ipAddress := d2rprocess.readString(ipAddressAddress, length := 0)
    return ipAddress
}
