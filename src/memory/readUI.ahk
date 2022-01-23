#SingleInstance, Force
SendMode Input
SetWorkingDir, %A_ScriptDir%


readUI(d2rprocess, gameWindowId, settings, session) {
    if (not WinExist(gameWindowId)) {
        WriteLog(gameWindowId " not found, please make sure game is running")
        if (session) {
            session.saveEntry()
        }
        ExitApp
    }

    ; UI offset 0x21F89AA
    offset := settings["uiOffset"]
    base := d2rprocess.BaseAddress + offset

    d2rprocess.readRaw(base - 0x1, buffer, 1)
    quitMenu := NumGet(&buffer , 0, Type := "UShort")
    d2rprocess.readRaw(base + 0x4, buffer, 1)
    questsMenu := NumGet(&buffer , 0, Type := "UShort")
    d2rprocess.readRaw(base - 0x6, buffer, 1)
    skillMenu := NumGet(&buffer , 0, Type := "UShort")
    d2rprocess.readRaw(base - 0x8, buffer, 1)
    charMenu := NumGet(&buffer , 0, Type := "UShort")
    d2rprocess.readRaw(base - 0x9, buffer, 1)
    invMenu := NumGet(&buffer , 0, Type := "UShort")
    d2rprocess.readRaw(base + 0x14, buffer, 1)
    mercMenu := NumGet(&buffer , 0, Type := "UShort")
    d2rprocess.readRaw(base + 0xb, buffer, 1)
    partyMenu := NumGet(&buffer , 0, Type := "UShort")
    d2rprocess.readRaw(base + 0x9, buffer, 1)
    waypointMenu := NumGet(&buffer , 0, Type := "UShort")

    ;WriteLog("ESC" quitMenu " Q" questsMenu " T" skillMenu " C" charMenu " I" invMenu " O" mercMenu " P" partyMenu " W" waypointMenu)
    return (quitMenu or questsMenu or skillMenu or charMenu or invMenu or mercMenu or partyMenu or waypointMenu)
}
