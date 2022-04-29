

PatternScan(ByRef d2r, ByRef offsets) {
    SetFormat, Integer, Hex
    ; unit table
    pattern := d2r.hexStringToPattern("48 8D 0D ?? ?? ?? ?? 48 C1 E0 0A 48 03 C1 C3 CC")
    patternAddress := d2r.modulePatternScan("D2R.exe", , pattern*)
    offsetBuffer := d2r.read(patternAddress + 3, "Int")
    playerOffset := ((patternAddress - d2r.BaseAddress) + 7 + offsetBuffer)
    offsets["playerOffset"] := playerOffset
    WriteLog("Scanned and found unitTable offset: " playerOffset)
    
    ; ui
    pattern := d2r.hexStringToPattern("40 84 ed 0f 94 05")
    patternAddress := d2r.modulePatternScan("D2R.exe", , pattern*)
    offsetBuffer := d2r.read(patternAddress + 6, "Int")
    uiOffset := ((patternAddress - d2r.BaseAddress) + 10 + offsetBuffer)
    offsets["uiOffset"] := uiOffset
    WriteLog("Scanned and found UI offset: " uiOffset)

    ; expansion
    pattern := d2r.hexStringToPattern("48 8B 05 ?? ?? ?? ?? 48 8B D9 F3 0F 10 50 ??")
    patternAddress := d2r.modulePatternScan("D2R.exe", , pattern*)
    offsetBuffer := d2r.read(patternAddress + 3, "Int")
    expOffset := ((patternAddress - d2r.BaseAddress) + 7 + offsetBuffer)
    offsets["expOffset"] := expOffset
    WriteLog("Scanned and found expansion offset: " expOffset)

    ; game data (IP and name) 
    pattern := d2r.hexStringToPattern("44 88 25 ?? ?? ?? ?? 66 44 89 25 ?? ?? ?? ??")
    patternAddress := d2r.modulePatternScan("D2R.exe", , pattern*)
    offsetBuffer := d2r.read(patternAddress + 0x3, "Int")
    gameDataOffset := ((patternAddress - d2r.BaseAddress) - 0x121 + offsetBuffer)
    offsets["gameDataOffset"] := gameDataOffset
    WriteLog("Scanned and found game data offset: " gameDataOffset)

    ; menu visibility    
    pattern := d2r.hexStringToPattern("8B 05 ?? ?? ?? ?? 89 44 24 20 74 07") 
    patternAddress := d2r.modulePatternScan("D2R.exe", , pattern*)
    offsetBuffer := d2r.read(patternAddress + 2, "Int")
    menuOffset := ((patternAddress - d2r.BaseAddress) + 6 + offsetBuffer)
    offsets["menuOffset"] := menuOffset
    WriteLog("Scanned and found menu offset: " menuOffset)

    ; last hover object
    pattern := d2r.hexStringToPattern("C6 84 C2 ?? ?? ?? ?? ?? 48 8B 74 24 ??") 
    patternAddress := d2r.modulePatternScan("D2R.exe", , pattern*)
    hoverOffset := d2r.read(patternAddress + 3, "Int") - 1
    offsets["hoverOffset"] := hoverOffset
    WriteLog("Scanned and found hover offset: " hoverOffset)

    ; roster
    pattern := d2r.hexStringToPattern("02 45 33 D2 4D 8B") 
    patternAddress := d2r.modulePatternScan("D2R.exe", , pattern*)
    offsetBuffer := d2r.read(patternAddress - 3, "Int")
    rosterOffset := ((patternAddress - d2r.BaseAddress) + 1 + offsetBuffer)
    offsets["rosterOffset"] := rosterOffset
    WriteLog("Scanned and found roster offset: " rosterOffset)

}

