
{ ;build missile type arrays
    ;otherMissilesArray:=buildUnitList("Ignore")
    ;PhysicalMajorArray:=buildUnitList("PhysicalMajor")
    ;PhysicalMinorArray:=buildUnitList("PhysicalMinor")
    ;FireMajorArray:=buildUnitList("FireMajor")
    ;FireMinorArray:=buildUnitList("FireMinor")
    ;IceMajorArray:=buildUnitList("IceMajor")
    ;IceMinorArray:=buildUnitList("IceMinor")
    ;LightMajorArray:=buildUnitList("LightMajor")
    ;LightMinorArray:=buildUnitList("LightMinor")
    ;PoisonMajorArray:=buildUnitList("PoisonMajor")
    ;PoisonMinorArray:=buildUnitList("PoisonMinor")
    ;MagicMajorArray:=buildUnitList("MagicMajor")
    ;MagicMinorArray:=buildUnitList("MagicMinor")
    ;otherMissilesArray:=buildUnitList("otherMissiles")
}
{ ;build matchlists from arrays and make them available within functions
    if (!FileExist("missiles.ini")){
        FileInstall, missiles-default.ini, missiles.ini, 0
        }
    if (FileExist("missiles.ini")) {    
        global IgnoreMatchlist:=buildMatchList(buildUnitList("Ignore"))
        global PhysicalMajorMatchlist:=buildMatchList(buildUnitList("PhysicalMajor"))
        global PhysicalMinorMatchlist:=buildMatchList(buildUnitList("PhysicalMinor"))
        global FireMajorMatchlist:=buildMatchList(buildUnitList("FireMajor"))
        global FireMinorMatchlist:=buildMatchList(buildUnitList("FireMinor"))
        global IceMajorMatchlist:=buildMatchList(buildUnitList("IceMajor"))
        global IceMinorMatchlist:=buildMatchList(buildUnitList("IceMinor"))
        global LightMajorMatchlist:=buildMatchList(buildUnitList("LightMajor"))
        global LightMinorMatchlist:=buildMatchList(buildUnitList("LightMinor"))
        global PoisonMajorMatchlist:=buildMatchList(buildUnitList("PoisonMajor"))
        global PoisonMinorMatchlist:=buildMatchList(buildUnitList("PoisonMinor"))
        global MagicMajorMatchlist:=buildMatchList(buildUnitList("MagicMajor"))
        global MagicMinorMatchlist:=buildMatchList(buildUnitList("MagicMinor"))
        global otherMissilesMatchlist:=buildMatchList(buildUnitList("otherMissiles"))
    }
}

readUnits(someProcess, startingOffset, Type) {
    ;global settings
    array := []
    switch (Type)    {
        case "mobs": Offset := startingOffset + 1024
        case "objects": Offset := startingOffset + (2 * 1024)
        case "playerMissiles": Offset := 0x21EA4F0 + (3 * 1024) ;memory offset for PlayerMissles
        Case "enemyMissiles": Offset := startingOffset + (3 * 1024)
        case "items": Offset := startingOffset + (4 * 1024)
        ;case "otherPlayers": Offset := 
        default: return 0
    }
    Loop, 128
    {
        newOffset := Offset + (8 * (A_Index - 1))
        arrayAddress := someProcess.BaseAddress + newOffset
        arrayUnit := someProcess.read(arrayAddress, "Int64")
        while (arrayUnit > 0 ) { ; keep following the next pointer
            txtFileNo := someProcess.read(arrayUnit + 0x04, "UInt")
            ;tooltip, % txtFileNo . "", 300, 0, 7
            if (UnitType:=arrayWatchlist(txtFileNo)) {
                if (settings["ShowKnownMissileDebug"]){
                tooltip, % txtFileNo . "", 300, 0, 7
                }
                pPath := someProcess.read(arrayUnit + 0x38, "Int64")
                mode := someProcess.read(arrayUnit + 0x0c, "UInt")
                unitx := someProcess.read(pPath + 0x02, "UShort")
                unity := someProcess.read(pPath + 0x06, "UShort")
                unit := {"txtFileNo": txtFileNo, "x": unitx, "y": unity, "mode": mode, "UnitType": UnitType}
                array.push(unit)
                ;if (UnitType = "unknown"){
                 if (UnitType = "otherMissiles"){
                    if (settings["ShowOtherMissileDebug"])   
                    tooltip, % "ID:" . txtFileNo .  " UnitType: " . UnitType, 0, 0
                    }
           }   
            arrayUnit := someProcess.read(arrayUnit + 0x150, "Int64")  ; get next unit
        }
    } 
    return array
}
arrayWatchlist(ID) {
    if ID in %IgnoreMatchlist%
            return ""
    if ID in %PhysicalMajorMatchlist%
        return "PhysicalMajor"
    if ID in %PhysicalMinorMatchlist%
            return "PhysicalMinor"
    if ID in %FireMajorMatchlist%
            return "FireMajor"
    if ID in %FireMinorMatchlist%
            return "FireMinor"
    if ID in %IceMajorMatchlist%
            return "IceMajor"
    if ID in %IceMinorMatchlist%
            return "IceMinor"
    if ID in %LightMajorMatchlist%
            return "LightMajor"
    if ID in %LightMinorMatchlist%
            return "LightMinor"
    if ID in %PoisonMajorMatchlist%
            return "PoisonMajor"
    if ID in %PoisonMinorMatchlist%
            return "PoisonMinor"
    if ID in %MagicMajorMatchlist%
            return "MagicMajor"
    if ID in %MagicMinorMatchlist%
            return "MagicMinor"
    if ID in %otherMissilesMatchlist%
            return "otherMissiles"
    return ""
}

buildMatchList(Array){ ;create csv matchlist of Missile ID's for each Catagory
    for index, param in Array
        {
        for j, k in param
            {
            if  k is digit 
                {
                if (Matchlist = ""  ){
                        Matchlist:= k
                    } else {
                        Matchlist:=Matchlist . "," . k
                        }
                } 
            }
        }
    return Matchlist
}
buildUnitList(catagory){
    IniRead, %catagory%, missiles.ini, %catagory%
    %catagory%Array:=[]
    loop, parse, %catagory%,`n`r,%A_Space% %A_Tab%
    {
        UnitName:=RegExReplace(a_loopfield, "^(\w.*)=\d{0,3}.*$" , "$1",,-1,1)
        UnitID:=RegExReplace(a_loopfield, "^\w.*=(\d{0,3}).*$" , "$1",,-1,1)
        unitIDNAME:={"ID": UnitID, "name": UnitName}
        %catagory%Array.push(unitIDNAME)
    }
    return %catagory%Array
}


