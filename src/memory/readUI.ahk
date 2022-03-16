
readUI(ByRef d2rprocess, gameWindowId, settings, session) {
    ; UI offset 0x21F89AA
    base := d2rprocess.BaseAddress + offsets["uiOffset"]
    d2rprocess.readRaw(base - 0xA, buffer, 32)
    invMenu := NumGet(&buffer , 0x01, Type := "UChar")
    charMenu := NumGet(&buffer , 0x02, Type := "UChar")
    skillSelect := NumGet(&buffer , 0x03, Type := "UChar")
    skillMenu := NumGet(&buffer , 0x04, Type := "UChar")
    npcInteract := NumGet(&buffer , 0x08, Type := "UChar")
    quitMenu := NumGet(&buffer , 0x09, Type := "UChar")
    npcShop := NumGet(&buffer , 0x0B, Type := "UChar")
    questsMenu := NumGet(&buffer , 0xE, Type := "UChar")
    waypointMenu := NumGet(&buffer , 0x13, Type := "UChar")
    partyMenu := NumGet(&buffer , 0x15, Type := "UChar")
    mercMenu := NumGet(&buffer , 0x1E, Type := "UChar")

    ;OutputDebug, % "ESC" quitMenu " Q" questsMenu " T" skillMenu " C" charMenu " I" invMenu " O" mercMenu " P" partyMenu " W" waypointMenu
    return (quitMenu or questsMenu or skillMenu or charMenu or invMenu or mercMenu or partyMenu or waypointMenu)
}
