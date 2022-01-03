#SingleInstance, Force
#Persistent
SendMode Input
SetWinDelay, 0
SetWorkingDir, %A_ScriptDir%
#Include %A_ScriptDir%\include\logging.ahk
#Include %A_ScriptDir%\memory\initMemory.ahk
#Include %A_ScriptDir%\memory\scanForPlayer.ahk
#Include %A_ScriptDir%\memory\readGameMemory.ahk
#Include %A_ScriptDir%\memory\isAutomapShown.ahk
#Include %A_ScriptDir%\memory\readLastGameName.ahk
#Include %A_ScriptDir%\memory\readIPAddress.ahk
#Include %A_ScriptDir%\memory\patternScan.ahk
#Include %A_ScriptDir%\ui\image\downloadMapImage.ahk
#Include %A_ScriptDir%\ui\image\clearCache.ahk
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

expectedVersion := "2.4.1"

if !FileExist(A_Scriptdir . "\settings.ini") {
    MsgBox, , Missing settings, Could not find settings.ini file
    ExitApp
}

IniRead, version, settings.ini, VersionControl, version, ""
if (version != expectedVersion) {
    MsgBox, , Mismatched settings version, Your settings.ini is not the expected version %expectedVersion%`nIn future please update executable AND settings.ini`nPress OK to continue anyway   
}

lastMap := ""
exitArray := []
helpToggle:= true
WriteLog("*******************************************************************")
WriteLog("* Map overlay started https://github.com/joffreybesos/d2r-mapview *")
WriteLog("*******************************************************************")
WriteLog("Version: " expectedVersion)
WriteLog("Please report issues in #support on discord: https://discord.gg/qEgqyVW3uj")
WriteLog("This map hack may not work on Windows 11")

ClearCache(A_Temp)
readSettings(settings.ini, settings)

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

switchMapModeKey := settings["switchMapMode"]
Hotkey, IfWinActive, ahk_exe D2R.exe
Hotkey, %switchMapModeKey%, SwitchMapMode

alwaysShowKey := settings["alwaysShowKey"]
Hotkey, IfWinActive, ahk_exe D2R.exe
Hotkey, %alwaysShowKey%, MapAlwaysShow

increaseMapSizeKey := settings["increaseMapSizeKey"]
Hotkey, IfWinActive, ahk_exe D2R.exe
Hotkey, %increaseMapSizeKey%, MapSizeIncrease

decreaseMapSizeKey := settings["decreaseMapSizeKey"]
Hotkey, IfWinActive, ahk_exe D2R.exe
Hotkey, %decreaseMapSizeKey%, MapSizeDecrease

moveMapLeftKey := settings["moveMapLeft"]
moveMapRightKey := settings["moveMapRight"]
moveMapUpKey := settings["moveMapUp"]
moveMapDownKey := settings["moveMapDown"]

Hotkey, IfWinActive, ahk_exe D2R.exe
Hotkey, %moveMapLeftKey%, MoveMapLeft
Hotkey, IfWinActive, ahk_exe D2R.exe
Hotkey, %moveMapRightKey%, MoveMapRight
Hotkey, IfWinActive, ahk_exe D2R.exe
Hotkey, %moveMapUpKey%, MoveMapUp
Hotkey, IfWinActive, ahk_exe D2R.exe
Hotkey, %moveMapDownKey%, MoveMapDown

; initialise memory reading
d2rprocess := initMemory(gameWindowId)
patternScan(d2rprocess, settings)
playerOffset := settings["playerOffset"]
startingOffset := settings["playerOffset"]
uiOffset := settings["uiOffset"]

; create GUI windows
Gui, IPaddress: -Caption +E0x20 +E0x80000 +E0x00080000 +LastFound +AlwaysOnTop +ToolWindow +OwnDialogs +HwndipHwnd1

Gui, GameInfo: -Caption +E0x20 +E0x80000 +LastFound +AlwaysOnTop +ToolWindow +OwnDialogs
gamenameHwnd1 := WinExist()

Gui, Map: -Caption +E0x20 +E0x80000 +LastFound +AlwaysOnTop +ToolWindow +OwnDialogs
mapHwnd1 := WinExist()

Gui, Units: -Caption +E0x20 +E0x80000 +E0x00080000 +LastFound +AlwaysOnTop +ToolWindow +OwnDialogs 
unitHwnd1 := WinExist()

sessionList := []
offsetAttempts := 6
ticktock := 0
While 1 {
    ; scan for the player offset
    playerOffset := scanForPlayer(d2rprocess, playerOffset, startingOffset, settings)

    if (!playerOffset) {
        if (offsetAttempts == 1) {
            gameEndTime := A_TickCount
        }
        offsetAttempts += 1
        if (offsetAttempts > 5) {
            hideMap(false)
            lastlevel:=
            if (session) {
                session.setEndTime(gameEndTime)
                session.endingPlayerLevel := lastPlayerLevel
                session.endingExperience := lastPlayerExperience
                if (!session.isLogged) {
                    SetFormat Integer, D
                    session.saveEntryToFile()
                }
            }
            if (settings["showGameInfo"]) {
                SetFormat Integer, D
                if (!sessionList.MaxIndex()) {
                    sessionList := readSessionFile("GameSessionLog.csv")
                }
                ShowHistoryText(gamenameHwnd1, gameWindowId, sessionList, settings["textAlignment"], settings["textSectionWidth"], settings["textSize"])
            }
            offsetAttempts := 6
        }
        Sleep, 500 ; sleep when no offset found, you're likely in menu
    } else {
        offsetAttempts := 0
        Gui, GameInfo: Hide  ; hide the last game info
        readGameMemory(d2rprocess, settings, playerOffset, gameMemoryData)
        if (gameMemoryData["experience"]) {
            lastPlayerLevel:= gameMemoryData["playerLevel"]
            lastPlayerExperience:=gameMemoryData["experience"]
        }

        if ((gameMemoryData["difficulty"] > 0 & gameMemoryData["difficulty"] < 3) and (gameMemoryData["levelNo"] > 0 and gameMemoryData["levelNo"] < 137) and gameMemoryData["mapSeed"]) {
            if (gameMemoryData["mapSeed"] != lastSeed) {
                gameStartTime := A_TickCount    
                currentGameName := readLastGameName(d2rprocess, gameWindowId, settings, session)
                
                session := new GameSession(currentGameName, A_TickCount, gameMemoryData["playerName"])
                session.startingPlayerLevel := gameMemoryData["playerLevel"]
                session.startingExperience := gameMemoryData["experience"]
                lastSeed := gameMemoryData["mapSeed"]
                sessionList := []
                if (settings["showIPtext"]) {
                    ipAddress := readIPAddress(d2rprocess, gameWindowId, settings, session)
                    ShowIPText(ipHwnd1, gameWindowId, ipAddress, settings["textIPalignment"], settings["textIPfontSize"])
                }
            }

            ; if there's a level num then the player is in a map
            if (gameMemoryData["levelNo"] != lastlevel) { ; only redraw map when it changes
                
                ; Show loading text
                ;Gui, Map: Show, NA
                Gui, Map: Hide ; hide map
                Gui, Units: Hide ; hide player dot
                ShowText(settings, "Loading map data...`nPlease wait`nPress Ctrl+H for help", "44") ; 22 is opacity
                ; Download map
                downloadMapImage(settings, gameMemoryData, imageData)
                Gui, LoadingText: Destroy ; remove loading text
                ; Show Map
                if (lastlevel == "") {
                    Gui, Map: Show, NA
                    Gui, Units: Show, NA
                }
                ShowMap(settings, mapHwnd1, imageData, gameMemoryData, uiData)
            }
            ; update player layer on each loop
            uiData["ticktock"] := ticktock
            ; update player layer on each loop
            ShowUnits(settings, unitHwnd1, imageData, gameMemoryData, uiData)
            ;ShowUnits(settings, unitHwnd1, imageData, gameMemoryData, uiData)
            if (settings["centerMode"]) {
                MovePlayerMap(settings, mapHwnd1, unitHwnd1, gameMemoryData, imageData, uiData)
            }
            checkAutomapVisibility(d2rprocess, settings, gameMemoryData["levelNo"])

            lastlevel := gameMemoryData["levelNo"]
        } else {
            WriteLog("In Menu - no valid difficulty, levelno, or mapseed found '" gameMemoryData["difficulty"] "' '" gameMemoryData["levelNo"] "' '" gameMemoryData["mapSeed"] "'")
            hideMap(false)
            lastlevel:=
        }
    }
    if (not WinExist(gameWindowId)) {
        WriteLog(gameWindowId " not found, please make sure game is running")
        session.saveEntry()
        ExitApp
    }
    ticktock := not ticktock
}

checkAutomapVisibility(d2rprocess, settings, levelNo) {
    uiOffset:= settings["uiOffset"]
    alwaysShowMap:= settings["alwaysShowMap"]
    hideTown:= settings["hideTown"]
    ;WriteLogDebug("Checking visibility, hideTown: " hideTown " alwaysShowMap: " alwaysShowMap)
    if ((levelNo == 1 or levelNo == 40 or levelNo == 75 or levelNo == 103 or levelNo == 109) and hideTown) {
        if (isMapShowing) {
            WriteLogDebug("Hiding town " levelNo " since hideTown is set to true")
        }
        hideMap(false)
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

hideMap(alwaysShowMap) {
    if (alwaysShowMap == false) {
        Gui, Map: Hide
        Gui, Units: Hide
        Gui, IPaddress: Hide
        if (isMapShowing) {
            WriteLogDebug("Map hidden")
        }
        isMapShowing:= 0
    }
}

unHideMap() {
    ;showmap
    if (!isMapShowing) {
        WriteLogDebug("Map shown")
    }
    isMapShowing:= 1
    Gui, Map: Show, NA
    Gui, Units: Show, NA
    Gui, IPaddress: Show, NA
}


+F10::
{
    WriteLog("Pressed Shift+F10, exiting...")
    session.saveEntry()
    ExitApp
}


MapAlwaysShow:
{
    settings["alwaysShowMap"] := !settings["alwaysShowMap"]
    checkAutomapVisibility(d2rprocess, settings, gameMemoryData["levelNo"])
    if (settings["alwaysShowMap"]) {
        unHideMap()
        IniWrite, true, settings.ini, MapSettings, alwaysShowMap
    } else {
        IniWrite, false, settings.ini, MapSettings, alwaysShowMap
    }
    WriteLog("alwaysShowMap set to " settings["alwaysShowMap"])
    return
}

MapSizeIncrease:
{
    levelNo := gameMemoryData["levelNo"]
    levelScale := imageData["levelScale"]
    if (levelNo and levelScale and not settings["centerMode"]) {
        levelScale := levelScale + 0.05
        IniWrite, %levelScale%, mapconfig.ini, %levelNo%, scale
        imageData["levelScale"] := levelScale
        ShowMap(settings, mapHwnd1, imageData, gameMemoryData, uiData)
        WriteLog("Increased level " levelNo " scale by 0.05 to " levelScale)
    }
    if (levelNo and settings["centerMode"]) {
        centerModeScale := settings["centerModeScale"]
        centerModeScale := centerModeScale + 0.05
        IniWrite, %centerModeScale%, settings.ini, MapSettings, centerModeScale
        settings["centerModeScale"] := centerModeScale
        ShowMap(settings, mapHwnd1, imageData, gameMemoryData, uiData)
        WriteLog("Increased centerModeScale global setting by 0.05 to " levelScale)
    }
    return
}

MapSizeDecrease:
{
    levelNo := gameMemoryData["levelNo"]
    levelScale := imageData["levelScale"]
    if (levelNo and levelScale and not settings["centerMode"]) {
        levelScale := levelScale - 0.05
        IniWrite, %levelScale%, mapconfig.ini, %levelNo%, scale
        imageData["levelScale"] := levelScale
        ShowMap(settings, mapHwnd1, imageData, gameMemoryData, uiData)
        
        WriteLog("Decreased level " levelNo " scale by 0.05 to " levelScale)
    }
    if (levelNo and settings["centerMode"]) {
        centerModeScale := settings["centerModeScale"]
        centerModeScale := centerModeScale - 0.05
        IniWrite, %centerModeScale%, settings.ini, MapSettings, centerModeScale
        settings["centerModeScale"] := centerModeScale
        ShowMap(settings, mapHwnd1, imageData, gameMemoryData, uiData)
        WriteLog("Decreased centerModeScale global setting by 0.05 to " levelScale)
    }
    return
}
    
#IfWinActive, ahk_exe D2R.exe
    SwitchMapMode:
    {
        settings["centerMode"] := !settings["centerMode"]
        lastlevel := "INVALIDATED"

        imageData := {}
        gameMemoryData  := {}
        uiData := {}
        Gui, Map: Hide
        Gui, Units: Hide

        return
    }
    MoveMapLeft:
    {
        levelNo := gameMemoryData["levelNo"]
        levelxmargin := imageData["levelxmargin"]
        levelymargin := imageData["levelymargin"]
        if (levelNo and not settings["centerMode"]) {
            levelxmargin := levelxmargin - 25
            IniWrite, %levelxmargin%, mapconfig.ini, %levelNo%, x
            imageData["levelxmargin"] := levelxmargin
            ShowMap(settings, mapHwnd1, imageData, gameMemoryData, uiData)
            
        }
        return
    }
    MoveMapRight:
    {
        levelNo := gameMemoryData["levelNo"]
        levelxmargin := imageData["levelxmargin"]
        levelymargin := imageData["levelymargin"]
        if (levelNo and not settings["centerMode"]) {
            levelxmargin := levelxmargin + 25
            IniWrite, %levelxmargin%, mapconfig.ini, %levelNo%, x
            imageData["levelxmargin"] := levelxmargin
            ShowMap(settings, mapHwnd1, imageData, gameMemoryData, uiData)
        }
        return
    }
    MoveMapUp:
    {
        levelNo := gameMemoryData["levelNo"]
        levelxmargin := imageData["levelxmargin"]
        levelymargin := imageData["levelymargin"]
        if (levelNo and not settings["centerMode"]) {
            levelymargin := levelymargin - 25
            IniWrite, %levelymargin%, mapconfig.ini, %levelNo%, y
            imageData["levelymargin"] := levelymargin
            ShowMap(settings, mapHwnd1, imageData, gameMemoryData, uiData)
        }
        return
    }
    MoveMapDown:
    {
        levelNo := gameMemoryData["levelNo"]
        levelxmargin := imageData["levelxmargin"]
        levelymargin := imageData["levelymargin"]
        if (levelNo and not settings["centerMode"]) {
            levelymargin := levelymargin + 25
            IniWrite, %levelymargin%, mapconfig.ini, %levelNo%, y
            imageData["levelymargin"] := levelymargin
            ShowMap(settings, mapHwnd1, imageData, gameMemoryData, uiData)
            ;ShowUnits(settings, unitHwnd1, imageData, gameMemoryData, uiData)
        }
        return
    }
    ^H::
    {
        if (helpToggle) {
            ShowHelpText(settings, 400, 200)
            WriteLogDebug("Show Help")
        } else {
            Gui, HelpText: Hide
            WriteLogDebug("Hide Help")
        }
        helpToggle := !helpToggle
        return
    }
    ~TAB::
    ~Space::
    {
        checkAutomapVisibility(d2rprocess, settings, gameMemoryData["levelNo"])
        return
    }
    ~Esc::
    {
        Gui, HelpText: Hide
        helpToggle := 1
    }
return

