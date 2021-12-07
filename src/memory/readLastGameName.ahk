#SingleInstance, Force
SendMode Input
SetWorkingDir, %A_ScriptDir%


readLastGameName(d2rprocess, gameWindowId, settings) {
    gameNameOffset := settings["gameNameOffset"]
    gameNameAddress := d2rprocess.BaseAddress + gameNameOffset
    gameName := d2rprocess.readString(gameNameAddress, length := 0)
    return gameName
}
