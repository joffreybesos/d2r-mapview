
initMemory(gameWindowId) {
    if (_ClassMemory.__Class != "_ClassMemory")
    {
        WriteLog("Missing classMemory.ahk dependency. Quitting")
        ExitApp
    }

    d2rprocess := new _ClassMemory(gameWindowId, "", hProcessCopy) 

    if !isObject(d2rprocess) 
    {
        WriteLog(gameWindowId " not found, please make sure game is running")
        ExitApp
    }
    WriteLog("Initalised memory")
    return d2rprocess
}