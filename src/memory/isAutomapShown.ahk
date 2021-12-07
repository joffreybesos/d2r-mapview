#SingleInstance, Force
#Include %A_ScriptDir%\include\classMemory.ahk
#Include %A_ScriptDir%\include\logging.ahk
SetWorkingDir, %A_ScriptDir%

isAutomapShown(d2rprocess, uiOffset) {

    ;WriteLog("Looking for Level No address at player offset " playerOffset)
    startingAddress := d2rprocess.BaseAddress + uiOffset
    isMapShown := d2rprocess.read(startingAddress, "UShort")
    ;WriteLog(isMapShown " " uiOffset " " startingAddress)
    if (isMapShown == 1) {
        return true
    } else {
        return false ; if it failed to be read return true anyway
    }
}