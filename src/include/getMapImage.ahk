#SingleInstance, Force
SendMode Input
SetWorkingDir, %A_ScriptDir%
#Include %A_ScriptDir%\include\Gdip_All.ahk
#Include %A_ScriptDir%\include\showText.ahk
#Include %A_ScriptDir%\include\logging.ahk

getMapImage(sMapUrl) {
    ; download image
    If !pToken := Gdip_Startup()
    {
        MsgBox "Gdiplus failed to start. Please ensure you have gdiplus on your system"
        ExitApp
    }

    Gui, 1: Destroy
    sFile=%a_scriptdir%\currentmap.png
    
    ShowText(configuredWidth, leftMargin, topMargin, "Loading map data...`nPlease wait", "22")
    FileDelete, %sFile%
    URLDownloadToFile, %sMapUrl%, %sFile%
    WriteLog("Downloading " sMapUrl)


    Gui, 2: Hide
    return sFile
}  