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
#Include %A_ScriptDir%\ui\showHelp.ahk
#Include %A_ScriptDir%\ui\showPlayer.ahk
#Include %A_ScriptDir%\readSettings.ahk

if !FileExist(A_Scriptdir . "\settings.ini") {
    MsgBox, , Missing settings, Could not find settings.ini file
    ExitApp
}
lastMap := ""
exitArray := []
helpToggle:= true
WriteLog("*******************************************************************")
WriteLog("* Map overlay started https://github.com/joffreybesos/d2r-mapview *")
WriteLog("*******************************************************************")
WriteLog("Please report bugs on discord: https://discord.gg/qEgqyVW3uj")
WriteLog("This map hack may not work on Windows 11")

readSettings(settings.ini, settings)

playerOffset := settings["playerOffset"]
startingOffset := settings["playerOffset"]
readInterval := settings["readInterval"]
lastlevel:=""
uidata:={}

global debug := settings["debug"]
global gameWindowId := settings["gameWindowId"]

While 1 {
    ; scan for the player offset
    playerOffset := scanOffset(playerOffset, startingOffset)

    if (!playerOffset) {
        Sleep, 5000 ; sleep longer when no offset found, you're likely in menu
    } else {
        readGameMemory(playerOffset, playerOffset, gameMemoryData)

        if ((gameMemoryData["difficulty"] > 0 & gameMemoryData["difficulty"] < 3) and (gameMemoryData["levelNo"] > 0 and gameMemoryData["levelNo"] < 137) and gameMemoryData["mapSeed"]) {
            ; if there's a level num then the player is in a map
            if (gameMemoryData["levelNo"] != lastlevel) { ; only redraw map when it changes
                ; Show loading text
                ;Gui, Map: Show, NA
                Gui, Map: Hide ; hide map
                Gui, Units: Hide ; hide player dot
                ShowText(settings, "Loading map data...`nPlease wait`nPress Ctrl+H for help", "22") ; 22 is opacity
                ; Download map
                downloadMapImage(settings["baseUrl"], gameMemoryData, mapData)
                Gui, LoadingText: Destroy ; remove loading text
                ; Show Map
                if (lastlevel == "") {
                    Gui, Map: Show, NA
                    Gui, Units: Show, NA
                }
                ;Gui, Map: Show, NA
                ;Gui, Units: Show, NA
                ShowMap(settings, mapData, gameMemoryData, uiData)
                ;checkAutomapVisibility(settings, gameMemoryData["levelNo"])
            }
            ; update player layer on each loop
            ShowPlayer(settings, mapData, gameMemoryData, uiData)
            checkAutomapVisibility(settings, gameMemoryData["levelNo"])

            lastlevel := gameMemoryData["levelNo"]
        } else {
            WriteLog("In Menu - no valid difficulty, levelno and mapseed found " gameMemoryData["difficulty"] " " gameMemoryData["levelNo"] " " gameMemoryData["mapSeed"] )
            hideMap(settings["alwaysShowMap"])
        }
    }
    Sleep, %readInterval% ; this is the pace of updates
}

checkAutomapVisibility(settings, levelNo) {
    uiOffset:= settings["uiOffset"]
    alwaysShowMap:= settings["alwaysShowMap"]
    hideTown:= settings["hideTown"]
    ;WriteLogDebug("Checking visibility, hideTown: " hideTown " alwaysShowMap: " alwaysShowMap)
    if ((levelNo == 1 or levelNo == 40 or levelNo == 75 or levelNo == 103 or levelNo == 109) and hideTown) {
        ;WriteLogDebug("Hiding town " levelNo " since hideTown is set to true")
        hideMap(false)
    } else if not WinActive(gameWindowId) {
        ;WriteLogDebug("D2R is not active window, hiding map")
        hideMap(false)
    } else if (!isAutomapShown(uiOffset) and !alwaysShowMap) {
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
        Gui, Map: Hide
        Gui, Units: Hide
    }
}

unHideMap() {
    ;showmap
    WriteLogDebug("Map shown")
    Gui, Map: Show, NA
    Gui, Units: Show, NA
}

~TAB::
~Space::
    {
        checkAutomapVisibility(settings, gameMemoryData["levelNo"])
        return
    }

+F10::
    {
        WriteLog("Pressed Shift+F10, exiting...")
        ExitApp
    }

#IfWinActive ahk_exe D2R.exe
    ~NumpadMult::
    {
        settings["alwaysShowMap"] := !settings["alwaysShowMap"]
        checkAutomapVisibility(settings, gameMemoryData["levelNo"])
        if (settings["alwaysShowMap"]) {
            unHideMap()
            IniWrite, true, settings.ini, MapSettings, alwaysShowMap
        } else {
            IniWrite, false, settings.ini, MapSettings, alwaysShowMap
        }
        WriteLog("alwaysShowMap set to " settings["alwaysShowMap"])
        return
    }

    ~NumpadAdd::
    {
        settings["scale"] := settings["scale"] + 0.1
        if (settings["scale"] > 5.0) {
            WriteLog("Scale is larger than max scale of 5: " settings["scale"])
            settings["scale"] := 5.0
        }
        ShowMap(settings, mapData, gameMemoryData, uiData)
        ShowPlayer(settings, mapData, gameMemoryData, uiData)
        scale := settings["scale"]
        IniWrite, %scale%, settings.ini, MapSettings, scale
        WriteLog("Increased scaled by 0.1 to " scale)
        return
    }

    ~NumpadSub::
    {
        settings["scale"] := settings["scale"] - 0.1
        if (settings["scale"] < 0.2) {
            WriteLog("Scale is lower than minimum scale 0.2: " settings["scale"])
            settings["scale"] := 0.2
        }
        ShowMap(settings, mapData, gameMemoryData, uiData)
        ShowPlayer(settings, mapData, gameMemoryData, uiData)
        IniWrite, %scale%, settings.ini, MapSettings, scale
        WriteLog("Decreased scaled by 0.1 to " scale)
        return
    }

    ^H::
    {
        if (helpToggle) {
            ShowHelpText(settings["maxWidth"], 400, 200)
        } else {
            Gui, HelpText: Hide
        }
        helpToggle := !helpToggle
        return
    }
return