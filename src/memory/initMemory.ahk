
initMemory(gameWindowId) {
    if (_ClassMemory.__Class != "_ClassMemory")
    {
        WriteLog("Missing classMemory.ahk dependency. Quitting")
        ExitApp
    }

    d2rprocess := new _ClassMemory(gameWindowId, "", hProcessCopy, 2) 

     if !isObject(d2rprocess) 
    {
        WriteLog(gameWindowId " not found, please make sure game is running, try running MH as admin if still having issues")
        errornogame := localizedStrings["errormsg10"]
        Msgbox, 48, d2r-mapview %version%, %errormsg10%`n`n%errormsg11%`n%errormsg12%`n`n%errormsg3%
        ExitApp
    }
    WriteLog("Initalised memory")
    return d2rprocess
}