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
helpToggle:= true
WriteLog("*******************************************************")
WriteLog("* Map overlay started *")
WriteLog("*******************************************************")
IniRead, baseUrl, settings.ini, MapHost, baseUrl, ""

IniRead, maxWidth, settings.ini, MapSettings, maxWidth, 2000
IniRead, scale, settings.ini, MapSettings, scale, 1
IniRead, topMargin, settings.ini, MapSettings, topMargin, 50
IniRead, leftMargin, settings.ini, MapSettings, leftMargin, 50
IniRead, opacity, settings.ini, MapSettings, opacity, 0.5
IniRead, alwaysShowMap, settings.ini, MapSettings, alwaysShowMap, "false"
IniRead, hideTown, settings.ini, MapSettings, hideTown, "false"

IniRead, showNormalMobs, settings.ini, MapSettings, showNormalMobs, "true"
IniRead, showUniqueMobs, settings.ini, MapSettings, showUniqueMobs, "true"
IniRead, normalMobColor, settings.ini, MapSettings, normalMobColor, "FFFFFF"
IniRead, uniqueMobColor, settings.ini, MapSettings, uniqueMobColor, "D4AF37"

IniRead, startingOffset, settings.ini, Memory, playerOffset
IniRead, uiOffset, settings.ini, Memory, uiOffset
IniRead, readInterval, settings.ini, Memory, readInterval, 1000

IniRead, enableD2ML, settings.ini, MultiLaunch, "false"
IniRead, enableCustomWindowTitle, settings.ini, MultiLaunch, "false"
if (enableCustomWindowTitle == "true") {
    IniRead, windowName, settings.ini, MultiLaunch, windowName
    gameWindowId = %windowName%
}
else if (enableD2ML == "true") {
    IniRead, tokenName, settings.ini, MultiLaunch, tokenName
    gameWindowId = D2R:%tokenName%
} 
else {
    gameWindowId := "ahk_exe D2R.exe"
}


IniRead, debug, settings.ini, Logging, debug, "false"

; Here is a good example of why AHK sucks
hideTown := hideTown = "true" ; convert to bool
alwaysShowMap := alwaysShowMap = "true" ; convert to bool
debug := debug = "true" ; convert to bool
showNormalMobs := showNormalMobs = "true" ; convert to bool
showUniqueMobs := showUniqueMobs = "true" ; convert to bool
global debug := debug
global gameWindowId := gameWindowId
mapConfig := {"showNormalMobs": showNormalMobs, "showUniqueMobs": showUniqueMobs, "normalMobColor": normalMobColor, "uniqueMobColor": uniqueMobColor}

WriteLog("Using configuration:")
WriteLog("    baseUrl: " baseUrl)
WriteLog("    Map: maxWidth: " maxWidth ", scale: " scale ", topMargin: " topMargin ", leftMargin: " leftMargin ", opacity: " opacity)
WriteLog("    hideTown: " hideTown ", alwaysShowMap: " alwaysShowMap)
WriteLog("    showNormalMobs: " showNormalMobs " showUniqueMobs: " showUniqueMobs)
WriteLog("    normalMobColor: " normalMobColor " uniqueMobColor: " uniqueMobColor)
WriteLog("    startingOffset: " startingOffset)
WriteLog("    gameWindowId: " gameWindowId)
WriteLog("    debug logging: " debug)

playerOffset:=startingOffset
lastlevel:=""
uidata:={}

While 1 {
	; scan for the player offset
	playerOffset := scanOffset(playerOffset, startingOffset)

	if (!playerOffset) {
		Sleep, 5000  ; sleep longer when no offset found, you're likely in menu
	} else {
        readGameMemory(playerOffset, startingOffset, gameMemoryData)
        
        if ((gameMemoryData["difficulty"] > 0 & gameMemoryData["difficulty"] < 3) and (gameMemoryData["levelNo"] > 0 and gameMemoryData["levelNo"] < 137) and gameMemoryData["mapSeed"]) {
            ; if there's a level num then the player is in a map
            if (gameMemoryData["levelNo"] != lastlevel) {
                ; Show loading text
                ;Gui, 1: Show, NA
                Gui, 1: Hide  ; hide map
                Gui, 3: Hide  ; hide player dot
                ShowText(maxWidth, leftMargin, topMargin, "Loading map data...`nPlease wait`nPress Ctrl+H for help", "22") ; 22 is opacity
                ; Download map
                downloadMapImage(baseUrl, gameMemoryData, mapData)
                Gui, 2: Destroy  ; remove loading text
                ; Show Map
                if (lastlevel == "") {
                    Gui, 1: Show, NA
                }
                ;Gui, 1: Show, NA
                ;Gui, 3: Show, NA
                ShowMap(maxWidth, scale, leftMargin, topMargin, opacity, mapData, gameMemoryData, uiData)
                checkAutomapVisibility(uiOffset, alwaysShowMap, hideTown, gameMemoryData["levelNo"])
            }

            ShowPlayer(maxWidth, scale, leftMargin, topMargin, mapConfig, mapData, gameMemoryData, uiData)
            checkAutomapVisibility(uiOffset, alwaysShowMap, hideTown, gameMemoryData["levelNo"])

            lastlevel := gameMemoryData["levelNo"]
        } else {
            WriteLog("In Menu - no valid difficulty, levelno and mapseed found " gameMemoryData["difficulty"] " " gameMemoryData["levelNo"] " " gameMemoryData["mapSeed"] )
            hideMap(alwaysShowMap)
        }
    }
	Sleep, %readInterval% ; this is the pace of updates
}



checkAutomapVisibility(uiOffset, alwaysShowMap, hideTown, levelNo) {
    ;WriteLogDebug("Checking visibility, hideTown: " hideTown " alwaysShowMap: " alwaysShowMap)
    if ((levelNo == 1 or levelNo == 40 or levelNo == 75 or levelNo == 103 or levelNo == 109) and hideTown==true) {
        ;WriteLogDebug("Hiding town " levelNo " since hideTown is set to true")
        hideMap(false)
    } else if not WinActive(gameWindowId) {
        ;WriteLogDebug("D2R is not active window, hiding map")
        hideMap(alwaysShowMap)
    } else if (isAutomapShown(uiOffset) == false) {
        ; hidemap
        hideMap(alwaysShowMap)
    } else {
        unHideMap()
    } 
    return
}

hideMap(alwaysShowMap) {
    if (alwaysShowMap == false) {
        ;WriteLogDebug("Hide map, alwaysShowMap was set to false")
        Gui, 1: Hide
        Gui, 3: Hide
    }
}

unHideMap() {
    ;showmap
    ;WriteLogDebug("Map shown")
    Gui, 1: Show, NA
    Gui, 3: Show, NA
}

~TAB::
~Space::
{
    checkAutomapVisibility(uiOffset, alwaysShowMap, hideTown, gameMemoryData["levelNo"])
    return
}

+F10::
{
    WriteLog("Pressed Shift+F10, exiting...")
    ExitApp
}

#IfWinActive ahk_exe D2R.exe
~NumpadAdd::
{
    scale := scale + 0.1
    ShowMap(maxWidth, scale, leftMargin, topMargin, opacity, mapData, gameMemoryData, uiData)
    ShowPlayer(maxWidth, scale, leftMargin, topMargin, mapConfig, mapData, gameMemoryData, uiData)
    IniWrite, %scale%, settings.ini, MapSettings, scale
    return
}

~NumpadSub::
{
    scale := scale - 0.1
    ShowMap(maxWidth, scale, leftMargin, topMargin, opacity, mapData, gameMemoryData, uiData)
    ShowPlayer(maxWidth, scale, leftMargin, topMargin, mapConfig, mapData, gameMemoryData, uiData)
    IniWrite, %scale%, settings.ini, MapSettings, scale
    return
}

^H::
{
    if (helpToggle) {
        ShowHelpText(maxWidth, 400, 200)
    } else {
        Gui, 5: Hide
    }
    helpToggle := !helpToggle
    return
}
return
