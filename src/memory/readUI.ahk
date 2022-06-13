
readUI(ByRef d2rprocess) {
    ; UI offset 0x21F89AA
    base := d2rprocess.BaseAddress + offsets["uiOffset"] - 0xa
    d2rprocess.readRaw(base, buffer, 32)
    invMenu := NumGet(&buffer , 0x01, Type := "UChar")
    charMenu := NumGet(&buffer , 0x02, Type := "UChar")
    skillSelect := NumGet(&buffer , 0x03, Type := "UChar")
    skillMenu := NumGet(&buffer , 0x04, Type := "UChar")
    npcInteract := NumGet(&buffer , 0x08, Type := "UChar")
    quitMenu := NumGet(&buffer , 0x09, Type := "UChar")
    npcShop := NumGet(&buffer , 0x0B, Type := "UChar")
    questsMenu := NumGet(&buffer , 0xE, Type := "UChar")
    waypointMenu := NumGet(&buffer , 0x13, Type := "UChar")
    stash := NumGet(&buffer , 0x18, Type := "UChar")
    partyMenu := NumGet(&buffer , 0x15, Type := "UChar")
    mercMenu := NumGet(&buffer , 0x1E, Type := "UChar")
    loading := NumGet(&buffer , 0x16C, Type := "UChar")

    ;OutputDebug, % "ESC" quitMenu " Q" questsMenu " T" skillMenu " C" charMenu " I" invMenu " O" mercMenu " P" partyMenu " W" waypointMenu
    leftMenu := questsMenu or charMenu or mercMenu or partyMenu or waypointMenu or stash
    rightMenu := skillMenu or invMenu

    UIShown := false
    if (rightMenu or quitMenu) {
        UIShown := "RIGHT"
    }
    if (leftMenu or quitMenu or skillSelect) {
        UIShown := true
    }
    return UIShown
}
