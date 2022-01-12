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
    ; show automap 0x00
    ; item text +0x2
    ; quit menu -0x01
    ; quests -0x05
    ; skill tree -0x0a
    ; show char -0x0c
    ; show inv -0x0d
    ; merc loadout +0x10
    ; party +0x07
    offset := settings["uiOffset"]
    base := d2rprocess.BaseAddress + offset

    quitMenu := d2rprocess.read(base - 0x2, "UShort")
    questsMenu := d2rprocess.read(base + 0x4, "UShort")
    skillMenu := d2rprocess.read(base - 0x6, "UShort")
    charMenu := d2rprocess.read(base - 0x8, "UShort")
    invMenu := d2rprocess.read(base - 0x9, "UShort")
    mercMenu := d2rprocess.read(base + 0x14, "UShort")
    partyMenu := d2rprocess.read(base + 0xb, "UShort")
    ; waypointMenu := d2rprocess.read(base + 0x9, "UShort")

    ; WriteLog("ESC" quitMenu " Q" questsMenu " S" skillMenu " C" charMenu " I" invMenu " O" mercMenu " P" partyMenu)
    return (quitMenu or questsMenu or skillMenu or charMenu or invMenu or mercMenu or partyMenu or waypointMenu)
}
