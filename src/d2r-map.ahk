#SingleInstance, Force
#Persistent
SendMode Input
SetWinDelay, 0
SetWorkingDir, %A_ScriptDir%
#Include %A_ScriptDir%\include\logging.ahk
#Include %A_ScriptDir%\include\Yaml.ahk
#Include %A_ScriptDir%\itemfilter\AlertList.ahk
#Include %A_ScriptDir%\itemfilter\ItemAlert.ahk
#Include %A_ScriptDir%\memory\initMemory.ahk
#Include %A_ScriptDir%\memory\scanForPlayer.ahk
#Include %A_ScriptDir%\memory\readGameMemory.ahk
#Include %A_ScriptDir%\memory\isAutomapShown.ahk
#Include %A_ScriptDir%\memory\readLastGameName.ahk
#Include %A_ScriptDir%\memory\readIPAddress.ahk
#Include %A_ScriptDir%\memory\patternScan.ahk
#Include %A_ScriptDir%\ui\image\downloadMapImage.ahk
#Include %A_ScriptDir%\ui\image\clearCache.ahk
#Include %A_ScriptDir%\ui\image\prefetchMaps.ahk
#Include %A_ScriptDir%\ui\showMap.ahk
#Include %A_ScriptDir%\ui\showText.ahk
#Include %A_ScriptDir%\ui\showHelp.ahk
#Include %A_ScriptDir%\ui\showIP.ahk
#Include %A_ScriptDir%\ui\showUnits.ahk
#Include %A_ScriptDir%\ui\showSessions.ahk
#Include %A_ScriptDir%\ui\movePlayerMap.ahk
#Include %A_ScriptDir%\stats\GameSession.ahk
#Include %A_ScriptDir%\stats\readSessionFile.ahk
#Include %A_ScriptDir%\readSettings.ahk
#Include %A_ScriptDir%\ui\settingsPanel.ahk

expectedVersion := "2.5.7"


if !FileExist(A_Scriptdir . "\settings.ini") {
    MsgBox, , Missing settings, Could not find settings.ini file
    ExitApp
}

lastMap := ""
exitArray := []
helpToggle:= true
historyToggle := true
WriteLog("*******************************************************************")
WriteLog("* Map overlay started https://github.com/joffreybesos/d2r-mapview *")
WriteLog("*******************************************************************")
WriteLog("Version: " expectedVersion)
WriteLog("Please report issues in #support on discord: https://discord.gg/qEgqyVW3uj")
ClearCache(A_Temp)
global settings
global defaultSettings
readSettings("settings.ini", settings)


lastlevel:=""
lastSeed:=""
session :=
lastPlayerLevel:=
lastPlayerExperience:=
uidata:={}
performanceMode := settings["performanceMode"]
if (performanceMode != 0) {
    SetBatchLines, %performanceMode%
}

global isMapShowing:=1
global debug := settings["debug"]
global gameWindowId := settings["gameWindowId"]
global gameStartTime:=0
global diabloFont := (A_ScriptDir . "\exocetblizzardot-medium.otf")
global mapLoading := 0
global seenItems := []
global oSpVoice := ComObjCreate("SAPI.SpVoice")
global itemAlertList := new AlertList("itemfilter.yaml")
global centerLeftOffset := 0
global centerTopOffset := 0
global redrawMap := 1

CreateSettingsGUI(settings)

switchMapModeKey := settings["switchMapMode"]
Hotkey, IfWinActive, % gameWindowId
Hotkey, %switchMapModeKey%, SwitchMapMode

historyToggleKey := settings["historyToggleKey"]
Hotkey, IfWinActive, % gameWindowId
Hotkey, %historyToggleKey%, HistoryToggle

alwaysShowKey := settings["alwaysShowKey"]
Hotkey, IfWinActive, % gameWindowId
Hotkey, %alwaysShowKey%, MapAlwaysShow

increaseMapSizeKey := settings["increaseMapSizeKey"]
Hotkey, IfWinActive, % gameWindowId
Hotkey, %increaseMapSizeKey%, MapSizeIncrease

decreaseMapSizeKey := settings["decreaseMapSizeKey"]
Hotkey, IfWinActive, % gameWindowId
Hotkey, %decreaseMapSizeKey%, MapSizeDecrease

moveMapLeftKey := settings["moveMapLeft"]
moveMapRightKey := settings["moveMapRight"]
moveMapUpKey := settings["moveMapUp"]
moveMapDownKey := settings["moveMapDown"]

Hotkey, IfWinActive, % gameWindowId
Hotkey, %moveMapLeftKey%, MoveMapLeft
Hotkey, IfWinActive, % gameWindowId
Hotkey, %moveMapRightKey%, MoveMapRight
Hotkey, IfWinActive, % gameWindowId
Hotkey, %moveMapUpKey%, MoveMapUp
Hotkey, IfWinActive, % gameWindowId
Hotkey, %moveMapDownKey%, MoveMapDown

if (not WinExist(gameWindowId)) {
    WriteLog(gameWindowId " not found, please make sure game is running, try running in admin if still having issues")
    Msgbox, 48, d2r-mapview, Did not find D2R game window`nGame must be started before running this program`n`nOtherwise check for errors in log.txt`nAlso try running both D2R and this program as admin`n`nExiting....
    ExitApp
}

; initialise memory reading
d2rprocess := initMemory(gameWindowId)
patternScan(d2rprocess, settings)
playerOffset := settings["playerOffset"]
startingOffset := settings["playerOffset"]
uiOffset := settings["uiOffset"]

pToken := Gdip_Startup()

; create GUI windows
Gui, IPaddress: -Caption +E0x20 +E0x80000 +E0x00080000 +LastFound +AlwaysOnTop +ToolWindow +OwnDialogs +HwndipHwnd1

Gui, GameInfo: -Caption +E0x20 +E0x80000 +LastFound +AlwaysOnTop +ToolWindow +OwnDialogs
global gamenameHwnd1 := WinExist()

Gui, Map: -Caption +E0x20 +E0x80000 +LastFound +AlwaysOnTop +ToolWindow +OwnDialogs
global mapHwnd1 := WinExist()

Gui, Units: -Caption +E0x20 +E0x80000 +E0x00080000 +LastFound +AlwaysOnTop +ToolWindow +OwnDialogs 
global unitHwnd1 := WinExist()

sessionList := []
offsetAttempts := 6
settingupGUI := false

global ticktock := 0
While 1 {
    ; scan for the player offset
    playerOffset := scanForPlayer(d2rprocess, playerOffset, startingOffset, settings)

    if (!playerOffset) {
        if (offsetAttempts == 1) {
            gameEndTime := A_TickCount
        }
        offsetAttempts += 1
        if (offsetAttempts > 25) {
            hideMap(false)
            lastlevel:=
            if (session) {
                session.setEndTime(gameEndTime)
                session.endingPlayerLevel := lastPlayerLevel
                session.endingExperience := lastPlayerExperience
                if (!session.isLogged) {
                    SetFormat Integer, D
                    session.saveEntryToFile()
                    sessionList.push(session)
                }
                session :=
            }
            if (settings["showGameInfo"]) {
                SetFormat Integer, D
                if (settings["showAllHistory"]) {
                    if (!sessionList.MaxIndex()) {
                        sessionList := readSessionFile("GameSessionLog.csv")
                    }
                }
                ShowHistoryText(gamenameHwnd1, gameWindowId, sessionList, historyToggle, settings["textAlignment"], settings["textSectionWidth"], settings["textSize"])
            }
            offsetAttempts := 26
            WriteLogDebug("Offset attempts " offsetAttempts)
        }
        Sleep, 100 ; sleep when no offset found, you're likely in menu
    } else {
        offsetAttempts := 0
        Gui, GameInfo: Hide  ; hide the last game info
        readGameMemory(d2rprocess, settings, playerOffset, gameMemoryData)
        if (gameMemoryData["experience"]) {
            lastPlayerLevel:= gameMemoryData["playerLevel"]
            lastPlayerExperience:=gameMemoryData["experience"]
        }

        if ((gameMemoryData["difficulty"] == "0" or gameMemoryData["difficulty"] == "1" or gameMemoryData["difficulty"] == "2") and (gameMemoryData["levelNo"] > 0 and gameMemoryData["levelNo"] < 137) and gameMemoryData["mapSeed"]) {
            if (gameMemoryData["mapSeed"] != lastSeed) {
                gameStartTime := A_TickCount    
                currentGameName := readLastGameName(d2rprocess, gameWindowId, settings, session)

                if (session) {
                    session.setEndTime(gameEndTime)
                    session.endingPlayerLevel := lastPlayerLevel
                    session.endingExperience := lastPlayerExperience
                    if (!session.isLogged) {
                        SetFormat Integer, D
                        session.saveEntryToFile()
                        sessionList.push(session)
                    }
                }
                
                session := new GameSession(currentGameName, A_TickCount, gameMemoryData["playerName"])
                session.startingPlayerLevel := gameMemoryData["playerLevel"]
                session.startingExperience := gameMemoryData["experience"]
                lastSeed := gameMemoryData["mapSeed"]
                if (settings["showIPtext"]) {
                    ipAddress := readIPAddress(d2rprocess, gameWindowId, settings, session)
                    ShowIPText(ipHwnd1, gameWindowId, ipAddress, settings["textIPalignment"], settings["textIPfontSize"])
                }
                shrines := []
                seenItems := []
            }

            ; if there's a level num then the player is in a map
            if (gameMemoryData["levelNo"] != lastlevel) { ; only redraw map when it changes
                ; Show loading text
                ;Gui, Map: Show, NA
                mapLoading := 1
                Gui, Map: Hide ; hide map
                Gui, Units: Hide ; hide player dot
                ShowText(settings, "Loading map data...`nPlease wait`nPress Ctrl+H for help`nPress Ctrl+O for settings", "44") ; 22 is opacity
                ; Download map
                downloadMapImage(settings, gameMemoryData, imageData)

                ; Show Map
                if (lastlevel == "") {
                    Gui, Map: Show, NA
                    Gui, Units: Show, NA
                }
                
                
                prefetchMaps(settings, gameMemoryData)
                mapLoading := 0
                Gui, LoadingText: Destroy ; remove loading text
                redrawMap := 1
            }
            if (redrawMap) {
                WriteLogDebug("Redrawing map")
                levelNo := gameMemoryData["levelNo"]
                IniRead, levelScale, mapconfig.ini, %levelNo%, scale, 1.0
                IniRead, levelxmargin, mapconfig.ini, %levelNo%, x, 0
                IniRead, levelymargin, mapconfig.ini, %levelNo%, y, 0
                imageData["levelScale"] := levelScale
                imageData["levelxmargin"] := levelxmargin
                imageData["levelymargin"] := levelymargin
                ShowMap(settings, mapHwnd1, imageData, gameMemoryData, uiData)

                scaledWidth := uiData["scaledWidth"]
                scaledHeight := uiData["scaledHeight"]

                SelectObject(hdc, obm)
                DeleteObject(hbm)
                DeleteDC(hdc)
                Gdip_DeleteGraphics(G)
                if (settings["centerMode"]) {
                    WinGetPos, ,  , gameWidth, gameHeight, %gameWindowId% 
                    hbm := CreateDIBSection(gameWidth, gameHeight)
                } else {
                    hbm := CreateDIBSection(scaledWidth, scaledHeight)
                }
                hdc := CreateCompatibleDC()
                obm := SelectObject(hdc, hbm)
                
                G := Gdip_GraphicsFromHDC(hdc)
                Gdip_SetSmoothingMode(G, 4)
                Gdip_SetInterpolationMode(G, 7)
                redrawMap := 0
            }
            
            ShowUnits(G, hdc, settings, unitHwnd1, mapHwnd1, imageData, gameMemoryData, shrines, uiData)

            if (settings["centerMode"]) {
                MovePlayerMap(settings, d2rprocess, playerOffset, mapHwnd1, unitHwnd1, imageData, uiData)
            }
            checkAutomapVisibility(d2rprocess, settings, gameMemoryData)

            lastlevel := gameMemoryData["levelNo"]
        } else {
            WriteLog("In Menu - no valid difficulty, levelno, or mapseed found '" gameMemoryData["difficulty"] "' '" gameMemoryData["levelNo"] "' '" gameMemoryData["mapSeed"] "'")
            hideMap(false)
            lastlevel:=
        }
    }
    if (not WinExist(gameWindowId)) {
        WriteLog(gameWindowId " not found, please make sure game is running, try running in admin if still having issues")
        session.saveEntry()
        ExitApp
    }
    ticktock := ticktock + 1
    if (ticktock > 6)
        ticktock := 0
}

checkAutomapVisibility(d2rprocess, settings, gameMemoryData) {
    uiOffset:= settings["uiOffset"]
    alwaysShowMap:= settings["alwaysShowMap"]
    hideTown:= settings["hideTown"]
    levelNo:= gameMemoryData["levelNo"]
    isMenuShown:= gameMemoryData["menuShown"]
    ;WriteLogDebug("Checking visibility, hideTown: " hideTown " alwaysShowMap: " alwaysShowMap)
    if ((levelNo == 1 or levelNo == 40 or levelNo == 75 or levelNo == 103 or levelNo == 109) and hideTown) {
        if (isMapShowing) {
            WriteLogDebug("Hiding town " levelNo " since hideTown is set to true")
        }
        hideMap(false)
    } else if gameMemoryData["menuShown"] {
        if (isMapShowing) {
            WriteLogDebug("Hiding since UI menu is shown")
        }
        hideMap(false, 1)
    } else if not WinActive(gameWindowId) {
        if (isMapShowing) {
            WriteLogDebug("D2R is not active window, hiding map")
        }
        hideMap(false)
    } else if (!isAutomapShown(d2rprocess, uiOffset) and !alwaysShowMap) {
        ; hidemap
        hideMap(alwaysShowMap)
    } else {
        unHideMap()
    } 
    return
}

hideMap(alwaysShowMap, menuShown := 0) {
    if ((alwaysShowMap == false) or menuShown) {
        Gui, Map: Hide
        Gui, Units: Hide
        Gui, IPaddress: Hide
        if (isMapShowing) {
            WriteLogDebug("Map hidden")
        }
        isMapShowing:= 0
    }
    return
}

unHideMap() {
    ;showmap
    if (!isMapShowing) {
        WriteLogDebug("Map shown")
    }
    isMapShowing:= 1
    if (!mapLoading) {
        Gui, Map: Show, NA
        Gui, Units: Show, NA
        Gui, IPaddress: Show, NA
    } else {
        WriteLogDebug("Tried to show map while map loading, ignoring...")
    }
    return
}


+F10::
{
    WriteLog("Pressed Shift+F10, exiting...")
    session.saveEntry()
    ExitApp
}
return

MapAlwaysShow:
{
    SetFormat Integer, D
    settings["alwaysShowMap"] := !settings["alwaysShowMap"]
    checkAutomapVisibility(d2rprocess, settings, gameMemoryData)
    if (settings["alwaysShowMap"]) {
        unHideMap()
        IniWrite, true, settings.ini, Settings, alwaysShowMap
    } else {
        IniWrite, false, settings.ini, Settings, alwaysShowMap
    }
    GuiControl, Settings:, alwaysShowMap, % settings["alwaysShowMap"]
    WriteLog("alwaysShowMap set to " settings["alwaysShowMap"])
    return
}

MapSizeIncrease:
{
    SetFormat Integer, D
    levelNo := gameMemoryData["levelNo"] + 0
    levelScale := imageData["levelScale"] + 0
    if (levelNo and levelScale and not settings["centerMode"]) {
        levelScale := levelScale + 0.05
        IniWrite, %levelScale%, mapconfig.ini, %levelNo%, scale
        redrawMap := 1
        WriteLog("Increased level " levelNo " scale by 0.05 to " levelScale)
    }
    if (levelNo and settings["centerMode"]) {
        centerModeScale := settings["centerModeScale"]
        centerModeScale := centerModeScale + 0.05
        IniWrite, %centerModeScale%, settings.ini, Settings, centerModeScale
        settings["centerModeScale"] := centerModeScale
        redrawMap := 1
        WriteLog("Increased centerModeScale global setting by 0.05 to " levelScale)
    }
    return
}

MapSizeDecrease:
{
    SetFormat Integer, D
    levelNo := gameMemoryData["levelNo"] + 0
    levelScale := imageData["levelScale"] + 0
    if (levelNo and levelScale and not settings["centerMode"]) {
        levelScale := levelScale - 0.05
        IniWrite, %levelScale%, mapconfig.ini, %levelNo%, scale
        redrawMap := 1
        WriteLog("Decreased level " levelNo " scale by 0.05 to " levelScale)
    }
    if (levelNo and settings["centerMode"]) {
        centerModeScale := settings["centerModeScale"]
        centerModeScale := centerModeScale - 0.05
        IniWrite, %centerModeScale%, settings.ini, Settings, centerModeScale
        settings["centerModeScale"] := centerModeScale
        redrawMap := 1
        WriteLog("Decreased centerModeScale global setting by 0.05 to " levelScale)
    }
    return
}
    
SwitchMapMode:
{
    settings["centerMode"] := !settings["centerMode"]
    if (settings["centerMode"]) {
        WriteLog("Switched to centered mode")
    } else {
        WriteLog("Turn off centered mode")
    }
    lastlevel := "INVALIDATED"

    imageData := {}
    gameMemoryData  := {}
    uiData := {}
    WinSet, Region, , ahk_id %mapHwnd1%
    WinSet, Region, , ahk_id %unitHwnd1%
    Gui, Map: Hide
    Gui, Units: Hide
    mapShowing := 0
    GuiControl, Settings:, centerMode, % settings["centerMode"]
    return
}

MoveMapLeft:
{
    SetFormat Integer, D
    levelNo := gameMemoryData["levelNo"] + 0
    levelxmargin := imageData["levelxmargin"] + 0
    levelymargin := imageData["levelymargin"] + 0
    if (levelNo and not settings["centerMode"]) {
        levelxmargin := levelxmargin - 25
        IniWrite, %levelxmargin%, mapconfig.ini, %levelNo%, x
        redrawMap := 1
    }
    return
}
MoveMapRight:
{
    SetFormat Integer, D
    levelNo := gameMemoryData["levelNo"] + 0
    levelxmargin := imageData["levelxmargin"] + 0
    levelymargin := imageData["levelymargin"] + 0
    if (levelNo and not settings["centerMode"]) {
        levelxmargin := levelxmargin + 25
        IniWrite, %levelxmargin%, mapconfig.ini, %levelNo%, x
        redrawMap := 1
    }
    return
}
MoveMapUp:
{
    SetFormat Integer, D
    levelNo := gameMemoryData["levelNo"] + 0
    levelxmargin := imageData["levelxmargin"] + 0
    levelymargin := imageData["levelymargin"] + 0
    if (levelNo and not settings["centerMode"]) {
        levelymargin := levelymargin - 25
        IniWrite, %levelymargin%, mapconfig.ini, %levelNo%, y
        redrawMap := 1
    }
    return
}
MoveMapDown:
{
    SetFormat Integer, D
    levelNo := gameMemoryData["levelNo"] + 0
    levelxmargin := imageData["levelxmargin"] + 0
    levelymargin := imageData["levelymargin"] + 0
    if (levelNo and not settings["centerMode"]) {
        levelymargin := levelymargin + 25
        IniWrite, %levelymargin%, mapconfig.ini, %levelNo%, y
        redrawMap := 1
    }
    return
}
HistoryToggle:
{
    historyToggle := !historyToggle
    ; settings["showGameInfo"] := historyToggle
    ; IniWrite, %historyToggle%, settings.ini, Settings, showGameInfo
    return
}
^H::
{
    if (helpToggle) {
        ShowHelpText(settings)
        WriteLog("Show Help")
    } else {
        Gui, HelpText: Hide
        WriteLog("Hide Help")
    }
    helpToggle := !helpToggle
    return
}
~TAB::
~Space::
{
    WriteLogDebug("TAB or Space pressed")
    checkAutomapVisibility(d2rprocess, settings, gameMemoryData)
    return
}
~Esc::
{
    Gui, HelpText: Hide
    helpToggle := 1
    return
}
~+F9::
{
    WriteLog("Debug mode set to " debug)
    debug := !debug
    return
}

^O::
{
    uix := settings["settingsUIX"]
    uiy := settings["settingsUIY"]
    if (!uix)
        uix := 100
    if (!uiy)
        uiy := 100
    Gui, Settings: Show, x%uix% y%uiy% h482 w362, d2r-mapview settings
    return
}

Update:
{
    WriteLog("Applying new settings...")
    cmode := settings["centerMode"]
    UpdateSettings(settings, defaultSettings)
    if (cmode != settings["centerMode"]) { ; if centermode changed
        lastlevel := "INVALIDATED"
        imageData := {}
        gameMemoryData  := {}
        uiData := {}
        WinSet, Region, , ahk_id %mapHwnd1%
        WinSet, Region, , ahk_id %unitHwnd1%
        Gui, Map: Hide
        Gui, Units: Hide
        mapShowing := 0
    }
    GuiControl, Hide, Unsaved
    GuiControl, Disable, UpdateBtn
    redrawMap := 1
    return
}

UpdateFlag:
{
    if (!settingupGUI) {
        GuiControl, Show, Unsaved
        GuiControl, Enable, UpdateBtn
    }
    return
}