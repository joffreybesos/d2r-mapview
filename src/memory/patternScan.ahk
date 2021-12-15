#SingleInstance, Force
SendMode Input
SetWorkingDir, %A_ScriptDir%


PatternScan(d2r, ByRef settings) {
    SetFormat, Integer, Hex
    ; unit table
    pattern := d2r.hexStringToPattern("48 8D ?? ?? ?? ?? ?? 8B D1")
    patternAddress := d2r.modulePatternScan("D2R.exe", , pattern*)
    offsetBuffer := d2r.read(patternAddress + 3, "Int")
    playerOffset := ((patternAddress - d2r.BaseAddress) + 7 + offsetBuffer)
    settings["playerOffset"] := playerOffset
    WriteLog("Scanned and found unitTable offset: " playerOffset)
    
    ; ui
    pattern := d2r.hexStringToPattern("40 84 ed 0f 94 05")
    patternAddress := d2r.modulePatternScan("D2R.exe", , pattern*)
    offsetBuffer := d2r.read(patternAddress + 6, "Int")
    uiOffset := ((patternAddress - d2r.BaseAddress) + 10 + offsetBuffer)
    settings["uiOffset"] := uiOffset
    WriteLog("Scanned and found UI offset: " uiOffset)

    ; expansion
    pattern := d2r.hexStringToPattern("C7 05 ?? ?? ?? ?? ?? ?? ?? ?? 48 85 C0 0F 84 ?? ?? ?? ?? 83 78 5C ?? 0F 84 ?? ?? ?? ?? 33 D2 41")   ;unit table offset
    patternAddress := d2r.modulePatternScan("D2R.exe", , pattern*)
    offsetBuffer := d2r.read(patternAddress - 4, "Int")
    expOffset := ((patternAddress - d2r.BaseAddress) + offsetBuffer)
    settings["expOffset"] := expOffset
    WriteLog("Scanned and found expansion offset: " expOffset)

    ; game data (IP and name)
    pattern := d2r.hexStringToPattern("E8 ?? ?? ?? ?? 48 8D 0D ?? ?? ?? ?? 44 88 2D ?? ?? ?? ??")
    patternAddress := d2r.modulePatternScan("D2R.exe", , pattern*)
    offsetBuffer := d2r.read(patternAddress + 8, "Int")
    gameDataOffset := ((patternAddress - d2r.BaseAddress) + 7 - 256 + 5 + offsetBuffer)
    settings["gameDataOffset"] := gameDataOffset
    WriteLog("Scanned and found game data offset: " gameDataOffset)

    ; menu visibility    
    pattern := d2r.hexStringToPattern("8B 05 ?? ?? ?? ?? 89 44 24 20 74 07") 
    patternAddress := d2r.modulePatternScan("D2R.exe", , pattern*)
    offsetBuffer := d2r.read(patternAddress + 2, "Int")
    menuOffset := ((patternAddress - d2r.BaseAddress) + 6 + offsetBuffer)
    settings["menuOffset"] := menuOffset
    WriteLog("Scanned and found menu offset: " menuOffset)
}