getMapSeedOffset(ByRef d2r) {
    ; map seed
    pattern := d2r.hexStringToPattern("41 8B F9 48 8D 0D ?? ?? ?? ??") 
    patternAddress := d2r.modulePatternScan("D2R.exe", , pattern*)
    offsetAddress := d2r.read(patternAddress + 6, "UInt")
    delta := patternAddress - d2r.BaseAddress
    resultRelativeAddress2 := d2r.BaseAddress + delta + 0xEA + offsetAddress
    offsetBuffer2 := d2r.read(resultRelativeAddress2, "Int64")

    if (!offsetBuffer2) {
        WriteLog("Did not find map seed offset!")
        offsets["mapSeedOffset"] := 0
    }
    if (d2r.read(offsetBuffer2 + 0x110, "Int64")) {
        offsets["mapSeedOffset"] := offsetBuffer2 + 0x840
        mapSeed := d2rprocess.read(offsets["mapSeedOffset"], "UInt")
        WriteLog("Found map seed offset " offsets["mapSeedOffset"] " which gives map seed " mapSeed)
    } else {
        offsets["mapSeedOffset"] := offsetBuffer2 + 0x10C0
        mapSeed := d2rprocess.read(offsets["mapSeedOffset"], "UInt")
        WriteLog("Found map seed offset " offsets["mapSeedOffset"] " which gives map seed " mapSeed)
    }
    return offsets["mapSeedOffset"]
}