#SingleInstance, Force
#Persistent
SendMode Input
SetWorkingDir, %A_ScriptDir%
#Include %A_ScriptDir%\include\logging.ahk
#Include %A_ScriptDir%\memory\scanOffset.ahk
#Include %A_ScriptDir%\memory\readGameMemory.ahk
#Include %A_ScriptDir%\memory\isAutomapShown.ahk
#Include %A_ScriptDir%\ui\image\downloadMapImage.ahk
#Include %A_ScriptDir%\ui\showMap.ahk
#Include %A_ScriptDir%\ui\showText.ahk
#Include %A_ScriptDir%\ui\showPlayer.ahk

if !FileExist(A_Scriptdir . "\settings.ini") {
	MsgBox, , Missing settings, Could not find settings.ini file
	ExitApp
}
lastMap := ""
exitArray := []
WriteLog("*******************************************************")
WriteLog("* Map overlay started *")
WriteLog("*******************************************************")
IniRead, baseUrl, settings.ini, MapHost, baseUrl, ""
IniRead, maxWidth, settings.ini, MapSettings, maxWidth, 2000
IniRead, scale, settings.ini, MapSettings, scale, 1
IniRead, topMargin, settings.ini, MapSettings, topMargin, 50
IniRead, leftMargin, settings.ini, MapSettings, leftMargin, 50
IniRead, opacity, settings.ini, MapSettings, opacity, 0.5
IniRead, startingOffset, settings.ini, Memory, playerOffset
IniRead, uiOffset, settings.ini, Memory, uiOffset
IniRead, readInterval, settings.ini, Memory, readInterval, 1000
IniRead, debug, settings.ini, Logging, debug, false
IniRead, alwaysShowMap, settings.ini, MapSettings, alwaysShowMap, false

WriteLog("Using configuration:")
WriteLog("    baseUrl: " baseUrl)
WriteLog("    Map: maxWidth: " maxWidth ", scale: " scale ", topMargin: " topMargin ", leftMargin: " leftMargin ", opacity: " opacity)
WriteLog("    startingOffset: " startingOffset)
WriteLog("    debug logging: " debug)

playerOffset:=startingOffset
lastlevel:=""
uidata:={}
showMap:=true

SetTimer, GameState, 1000 ; the 1000 here is priority, not sleep
return

GameState:
	; scan for the player offset
	playerOffset := scanOffset(playerOffset, startingOffset)

	if (!playerOffset) {
		Sleep, 5000  ; sleep longer when no offset found, you're likely in menu
	} else {
        readGameMemory(playerOffset, gameMemoryData)
        
        if ((gameMemoryData["difficulty"] > 0 & gameMemoryData["difficulty"] < 3) and (gameMemoryData["levelNo"] > 0 and gameMemoryData["levelNo"] < 137) and gameMemoryData["mapSeed"]) {
            ; if there's a level num then the player is in a map
            if (gameMemoryData["levelNo"] != lastlevel) {
                ; Show loading text
                Gui, 1: Show, NA
                ;Gui, 1: Hide  ; hide map
                ;Gui, 3: Hide  ; hide player dot
                ShowText(maxWidth, leftMargin, topMargin, "Loading map data...`nPlease wait", "22") ; 22 is opacity
                ; Download map
                downloadMapImage(baseUrl, gameMemoryData, mapData)
                Gui, 2: Destroy  ; remove loading text
                ; Show Map
                ShowMap(maxWidth, scale, leftMargin, topMargin, opacity, mapData, gameMemoryData, uiData)
                checkAutomapVisibility(uiOffset, alwaysShowMap)
            }

            ShowPlayer(maxWidth, scale, leftMargin, topMargin, mapData, gameMemoryData, uiData)

            lastlevel := gameMemoryData["levelNo"]
        } else {
            WriteLog("In Menu - no valid difficulty, levelno and mapseed found " gameMemoryData["difficulty"] " " gameMemoryData["levelNo"] " " gameMemoryData["mapSeed"] )
        }
    }
	Sleep, %readInterval% ; this is the pace of updates
return



checkAutomapVisibility(uiOffset, alwaysShowMap) {
    if (isAutomapShown(uiOffset) == true) {
        ;showmap
        WriteLogDebug("Map shown")
        Gui, 1: Show, NA
        Gui, 3: Show, NA
    } else {
        ; hidemap

        if (alwaysShowMap == "false") {
            WriteLogDebug("Hide map")
            Gui, 1: Hide
            Gui, 3: Hide
        }
    }
    return
}


~TAB::
~Space::
{
    checkAutomapVisibility(uiOffset, alwaysShowMap)
    return
}

++::
{
    scale := scale + 0.1
    ShowMap(maxWidth, scale, leftMargin, topMargin, opacity, mapData, gameMemoryData, uiData)
    ShowPlayer(maxWidth, scale, leftMargin, topMargin, mapData, gameMemoryData, uiData)
    IniWrite, %scale%, settings.ini, MapSettings, scale
    return
}

+_::
{
    scale := scale - 0.1
    ShowMap(maxWidth, scale, leftMargin, topMargin, opacity, mapData, gameMemoryData, uiData)
    ShowPlayer(maxWidth, scale, leftMargin, topMargin, mapData, gameMemoryData, uiData)
    IniWrite, %scale%, settings.ini, MapSettings, scale
    return
}

+F10::
{
	WriteLog("Pressed Shift+F10, exiting...")
	ExitApp
}
