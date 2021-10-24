#Include %A_ScriptDir%\include\classMemory.ahk
#Include %A_ScriptDir%\include\logging.ahk

getD2RMapUrl(baseUrl, pSeedAddress, pLevelNoAddress) {
    
    if (_ClassMemory.__Class != "_ClassMemory")
    {
        WriteLog("Missing classMemory.ahk dependency. Quitting")
        ExitApp
    }

    d2r := new _ClassMemory("ahk_exe D2R.exe", "", hProcessCopy) 

    if !isObject(d2r) 
    {
        WriteLog("D2R.exe not found, please make sure game is running first")
        ExitApp
    }

    mapSeed := d2r.read(pSeedAddress, "UInt")
    levelNo := d2r.read(pLevelNoAddress, "UInt")
    ;WriteLog("Got " mapSeed " from address " pSeedAddress " and " levelNo " from " pLevelNoAddress)
    
    url := ""
    if (mapSeed) {
        url := baseUrl . "/v1/map/" . mapSeed . "/2/" . levelNo . "/image"  
    }
    return url
}