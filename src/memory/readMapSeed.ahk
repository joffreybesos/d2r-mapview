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
        WriteLog("Found map seed offset " offsets["mapSeedOffset"])
    } else {
        offsets["mapSeedOffset"] := offsetBuffer2 + 0x10C0
        WriteLog("Found map seed offset " offsets["mapSeedOffset"])
    }

    ; [FieldOffset(0x110)] public uint check; // User feedback that this check worked 100% of the time from the people that tried it out
    ; //[FieldOffset(0x124)] public uint check; // User feedback that this check worked 100% of the time from the people that tried it out
    ; //[FieldOffset(0x830)] public uint check; // User feedback that this check worked most of the time from the people that tried it out

    ; [FieldOffset(0x840)] public uint mapSeed1;
    ; [FieldOffset(0x10C0)] public uint mapSeed2;


    ; var pMapSeedData = processContext.Read<IntPtr>(_pMapSeed);
    ; var mapSeedData = processContext.Read<Structs.MapSeed>(pMapSeedData);

    ; Seed = mapSeedData.check > 0 ? mapSeedData.mapSeed1 : mapSeedData.mapSeed2; // Use this if check offset is 0x110
    ; //Seed = mapSeedData.check > 0 ? mapSeedData.mapSeed2 : mapSeedData.mapSeed1; // Use this if check offset is 0x124
    ; //Seed = mapSeedData.check > 0 ? mapSeedData.mapSeed1 : mapSeedData.mapSeed2; // Use this if check offset is 0x830

    
    return offsets["mapSeedOffset"]
}