#Include %A_ScriptDir%\include\logging.ahk
SetWorkingDir, %A_ScriptDir%

ShowMap(sMapUrl, width, height, opacity) {
    ; download image
    sFile=%a_scriptdir%\currentmap.png
    URLDownloadToFile, %sMapUrl%,%sFile%

    color = FFFFFF ; White
    Gui, Map:New
    Gui, Add, Picture, x0 y0 w%width% h%height%, %sFile%
    Gui, Color, %color%
    Gui +E0x20 +LastFound +AlwaysOnTop -Caption +ToolWindow
    Winset, TransColor, %color% %opacity%
    Gui, Show, x100 y100, NoActivate
}