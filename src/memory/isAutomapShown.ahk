#SingleInstance, Force
#Include %A_ScriptDir%\include\classMemory.ahk
#Include %A_ScriptDir%\include\logging.ahk
SetWorkingDir, %A_ScriptDir%

isAutomapShown(uiOffset) {

    if (_ClassMemory.__Class != "_ClassMemory")
    {
        WriteLog("Missing classMemory.ahk dependency. Quitting")
        ExitApp
    }

    d2r := new _ClassMemory(gameWindowId, "", hProcessCopy) 

    if !isObject(d2r) 
    {
        WriteLog(gameWindowId " not found, please make sure game is running first")
        ExitApp
    }

    ;WriteLog("Looking for Level No address at player offset " playerOffset)
    startingAddress := d2r.BaseAddress + uiOffset
    isMapShown := d2r.read(startingAddress, "UShort")
    ;WriteLog(isMapShown " " uiOffset " " startingAddress)
    if (isMapShown == 1) {
        return true
    } else {
        return false ; if it failed to be read return true anyway
    }
}