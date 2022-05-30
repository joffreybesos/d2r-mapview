#SingleInstance, Force
#Persistent
#NoEnv
#MaxHotkeysPerInterval 99000000
#HotkeyInterval 99000000
#KeyHistory 0
ListLines Off
Process, Priority, , A
SetBatchLines, -1
SetKeyDelay, -1, -1
SetMouseDelay, -1
SetDefaultMouseSpeed, 0
SetWinDelay, -1
SetControlDelay, -1
SendMode Input
SetWorkingDir, %A_ScriptDir%
#Include %A_ScriptDir%\include\classMemory.ahk
#Include %A_ScriptDir%\include\logging.ahk
#Include %A_ScriptDir%\include\Yaml.ahk
#Include %A_ScriptDir%\include\JSON.ahk
#Include %A_ScriptDir%\include\Gdip_All.ahk
#Include %A_ScriptDir%\itemfilter\AlertList.ahk
#Include %A_ScriptDir%\itemfilter\ItemAlert.ahk
#Include %A_ScriptDir%\types\Stats.ahk
#Include %A_ScriptDir%\types\Skills.ahk
#Include %A_ScriptDir%\memory\initMemory.ahk
#Include %A_ScriptDir%\memory\scanForPlayer.ahk
#Include %A_ScriptDir%\memory\readGameMemory.ahk
#Include %A_ScriptDir%\memory\isAutomapShown.ahk
#Include %A_ScriptDir%\memory\readLastGameName.ahk
#Include %A_ScriptDir%\memory\readIPAddress.ahk
#Include %A_ScriptDir%\memory\patternScan.ahk
#Include %A_ScriptDir%\memory\IsInGame.ahk
#Include %A_ScriptDir%\memory\readInvItems.ahk
#Include %A_ScriptDir%\memory\readStates.ahk
#Include %A_ScriptDir%\memory\readVendorItems.ahk
#Include %A_ScriptDir%\ui\image\downloadMapImage.ahk
#Include %A_ScriptDir%\ui\image\clearCache.ahk
#Include %A_ScriptDir%\ui\image\prefetchMaps.ahk
#Include %A_ScriptDir%\ui\image\loadBitmaps.ahk
#Include %A_ScriptDir%\ui\image\loadBuffIcons.ahk
#Include %A_ScriptDir%\ui\showMap.ahk
#Include %A_ScriptDir%\ui\showText.ahk
#Include %A_ScriptDir%\ui\showHelp.ahk
#Include %A_ScriptDir%\ui\showUnits.ahk
#Include %A_ScriptDir%\ui\movePlayerMap.ahk
#Include %A_ScriptDir%\stats\GameSession.ahk
#Include %A_ScriptDir%\stats\readSessionFile.ahk
#Include %A_ScriptDir%\localization.ahk
#Include %A_ScriptDir%\init\hotkeys.ahk
#Include %A_ScriptDir%\init\readSettings.ahk
#Include %A_ScriptDir%\init\serverHealthCheck.ahk
#Include %A_ScriptDir%\init\updateCheck.ahk
#Include %A_ScriptDir%\ui\settingsPanel.ahk
#Include %A_ScriptDir%\ui\gdip\unitsLayer.ahk
#Include %A_ScriptDir%\ui\gdip\SessionTableLayer.ahk
#Include %A_ScriptDir%\ui\gdip\GameInfoLayer.ahk
#Include %A_ScriptDir%\ui\gdip\PartyInfoLayer.ahk
#Include %A_ScriptDir%\ui\gdip\UnitsLayer.ahk
#Include %A_ScriptDir%\ui\gdip\UIAssistLayer.ahk
#Include %A_ScriptDir%\ui\gdip\ItemLogLayer.ahk
#Include %A_ScriptDir%\ui\gdip\ItemCounterLayer.ahk
#Include %A_ScriptDir%\ui\gdip\BuffBarLayer.ahk

;Add right click menu in tray
Menu, Tray, NoStandard ; to remove default menu
Menu, Tray, Tip, d2r-mapview
Menu, Tray, Add, Settings, ShowSettings
Menu, Tray, Add
Menu, Tray, Add, Reload, Reload
Menu, Tray, Add
Menu, Tray, Add, Exit, ExitMH

global version := "2.9.6"

WriteLog("*******************************************************************")
WriteLog("* Map overlay started https://github.com/joffreybesos/d2r-mapview *")
WriteLog("*******************************************************************")
WriteLog("Version: " version)
WriteLog("Working folder: " A_ScriptDir)
WriteLog("Please report issues in #support on discord: https://discord.gg/qEgqyVW3uj")
ClearCache(A_Temp)
global settings
global defaultSettings
readSettings("settings.ini", settings)
global localizedStrings := LoadLocalization(settings)
CheckForUpdates()
checkServer(settings)
lastMap := ""
exitArray := []
helpToggle:= true
historyToggle := true
lastlevel:=""
lastSeed:=""
session :=
lastPlayerLevel:=
lastPlayerExperience:=
uidata:={}
sessionList := []
offsetAttempts := 2

performanceMode := settings["performanceMode"]
if (performanceMode != 0) {
    SetBatchLines, %performanceMode%
}

global sp := A_ScriptFullPath
global isMapShowing:=1
global debug := settings["debug"]
global gameWindowId := settings["gameWindowId"]
global gameStartTime:=0
global exocetFont := (A_ScriptDir . "\exocetblizzardot-medium.otf")
global formalFont := (A_ScriptDir . "\formal436bt-regular.otf")
global mapLoading := 0
global seenItems := []
global itemLogItems := []
global vendorItems := []
global oSpVoice := ComObjCreate("SAPI.SpVoice")
global itemAlertList := new AlertList("itemfilter.yaml")
global centerLeftOffset := 0
global centerTopOffset := 0
global redrawMap := 1
global offsets := []
global hudBitmaps := loadBitmaps()
global buffBitmaps := loadBuffIcons()

CreateSettingsGUI(settings, localizedStrings)
settingupGUI := false

SetupHotKeys(gameWindowId, settings)

; check that game is running
if (not WinExist(gameWindowId)) {
    errormsg3 := localizedStrings["errormsg3"]
    errormsg10:= localizedStrings["errormsg10"]
    errormsg11 := localizedStrings["errormsg11"]
    errormsg12 := localizedStrings["errormsg12"]
    WriteLog(gameWindowId " not found, please make sure game is running, try running MH as admin if still having issues")
    Msgbox, 48, d2r-mapview %version%, %errormsg10%`n`n%errormsg11%`n%errormsg12%`n`n%errormsg3%
    ExitApp
}

; initialise memory reading
global d2rprocess := initMemory(gameWindowId)
patternScan(d2rprocess, offsets)

uiOffset := offsets["uiOffset"]
Gdip_Startup()

; create GUI windows
Gui, Map: -Caption +E0x20 +E0x80000 +LastFound +AlwaysOnTop +ToolWindow +OwnDialogs
global mapHwnd1 := WinExist()

Gui, Units: -Caption +E0x20 +E0x80000 +E0x00080000 +LastFound +AlwaysOnTop +ToolWindow +OwnDialogs 
global unitHwnd1 := WinExist()


; performance counters
global ticktock := 0
maxfps := settings["fpscap"]
tickCount := 0
ticksPerFrame := 1000 / maxfps
frameCount := 0
fpsTimer := A_TickCount
currentFPS := 0

; ui layers
historyText := new SessionTableLayer(settings)
gameInfoLayer := new GameInfoLayer(settings)
partyInfoLayer := new PartyInfoLayer(settings)
itemLogLayer := new ItemLogLayer(settings)
itemCounterLayer := new ItemCounterLayer(settings)
uiAssistLayer := new UIAssistLayer(settings)
buffBarLayer := new BuffBarLayer(settings)

; main loop
While 1 {
    frameStart:=A_TickCount
    ; scan for the player offset
    isInGame := IsInGame(d2rprocess, offsets["unitTable"])
    if (!isInGame) {
        if (offsetAttempts == 1) {
            gameEndTime := A_TickCount
        }
        offsetAttempts += 1
        if (offsetAttempts > 25) {
            hideMap(false)
            lastlevel:=
            items := []
            shrines := []
            seenItems := []
            itemLogItems := []
            vendorItems := []
            newGame := 1
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
                historyText.drawTable(sessionList, historyToggle)
            }
            gameInfoLayer.hide()
            partyInfoLayer.hide()
            itemLogLayer.hide()
            itemCounterLayer.hide()
            buffBarLayer.hide()
            offsetAttempts := 26
            WriteLogDebug("Offset attempts " offsetAttempts)
        }
        Sleep, 80 ; sleep when no offset found, you're likely in menu
    } else {
        offsetAttempts := 0
        ; timeStamp("readGameMemory")
        readGameMemory(d2rprocess, settings, gameMemoryData)
        ; timeStamp("readGameMemory")

        if (gameMemoryData["experience"]) {
            lastPlayerLevel:= gameMemoryData["playerLevel"]
            lastPlayerExperience:=gameMemoryData["experience"]
        }
        if (!levelNo) {
            partyInfoLayer.hide()
        }

        if ((gameMemoryData["difficulty"] == "0" or gameMemoryData["difficulty"] == "1" or gameMemoryData["difficulty"] == "2") and (gameMemoryData["levelNo"] > 0 and gameMemoryData["levelNo"] < 137) and gameMemoryData["mapSeed"]) {
            if (gameMemoryData["mapSeed"] != lastSeed or newGame) {
                gameStartTime := A_TickCount    
                currentGameName := readLastGameName(d2rprocess, gameWindowId, offsets, session)

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
                ;ipAddress := readIPAddress(d2rprocess, gameWindowId, offsets, session)
                shrines := []
                items := []
                seenItems := []
                itemLogItems := []
                gameInfoLayer.updateSessionStart(session.startTime)
                ;gameInfoLayer.drawInfoText(currentFPS)
                newGame := 0
                
            }
            historyText.hide()
            historyToggle := true

            ; if there's a level num then the player is in a map
            if (gameMemoryData["levelNo"] != lastlevel) { ; only redraw map when it changes
                ; Show loading text
                ;Gui, Map: Show, NA
                mapLoading := 1
                Gui, Map: Hide ; hide map
                Gui, Units: Hide ; hide player dot
                ShowText(settings, "Loading map data...`nPlease wait`nPress Ctrl+H for help`nPress Ctrl+O for settings", "44") ; 44 is opacity
                ; Download map
                downloadMapImage(settings, gameMemoryData, imageData, 0)

                ; Show Map
                if (lastlevel == "") {
                    Gui, Map: Show, NA
                    Gui, Units: Show, NA
                }
                
                if (settings["enablePrefetch"]) {
                    prefetchMaps(settings, gameMemoryData)
                }
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

                unitsLayer.delete()
                unitsLayer := new UnitsLayer(uiData)
                
                gameInfoLayer.updateAreaLevel(levelNo, gameMemoryData["difficulty"])
                gameInfoLayer.updateExpLevel(levelNo, gameMemoryData["difficulty"], gameMemoryData["playerLevel"])
                
                
                redrawMap := 0
            }
            ; timeStamp("ShowUnits")
            ShowUnits(unitsLayer, settings, unitHwnd1, mapHwnd1, imageData, gameMemoryData, shrines, uiData)
            ; timeStamp("ShowUnits")
            uiAssistLayer.drawMonsterBar(gameMemoryData["hoveredMob"])

            if (settings["centerMode"] and gameMemoryData["pathAddress"]) {
                MovePlayerMap(settings, d2rprocess, gameMemoryData["pathAddress"], mapHwnd1, unitHwnd1, imageData, uiData)
            }
            if (Mod(ticktock, 6)) {
                checkAutomapVisibility(d2rprocess, gameMemoryData)
            }
            
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

    frameDuration:=A_TickCount-frameStart
    , frameCount++
    
    if ((A_TickCount-fpsTimer) >= 1000) {
        SetFormat Integer, D
        frameCount += 0
        , currentFPS := frameCount / (((A_TickCount-fpsTimer) / 1000))
        , currentFPS := Round(currentFPS, 1)
        , frameCount := 0
        , fpsTimer := A_TickCount
        if (isInGame) {
            readInvItems(d2rprocess, offsets["unitTable"], HUDItems, gameMemoryData["unitId"])
            readStates(d2rprocess, gameMemoryData, currentStates)
            buffBarLayer.drawBuffBar(currentStates, buffBitmaps)
            itemCounterLayer.drawItemCounter(HUDItems)
            gameInfoLayer.drawInfoText(currentFPS)
            partyInfoLayer.drawInfoText(gameMemoryData["partyList"], gameMemoryData["unitId"])

            if (settings["includeVendorItems"]) {
                ReadVendorItems(d2rprocess, unitTableOffset, levelNo, vendorItems)
                if (vendorItems.length() > 0) {
                    for k, vitem in vendorItems {
                        gameMemoryData["items"].push(vitem)
                    }
                }
            }
            itemLogLayer.drawItemLog()
        }
    }
    if (frameDuration < ticksPerFrame) {
        Sleep, ticksPerFrame - frameDuration
    }
}

checkAutomapVisibility(ByRef d2rprocess, ByRef gameMemoryData) {
    uiOffset:= offsets["uiOffset"]
    , alwaysShowMap:= settings["alwaysShowMap"]
    , hideTown:= settings["hideTown"] 
    , levelNo:= gameMemoryData["levelNo"]
    , isMenuShown:= gameMemoryData["menuShown"]
    if ((levelNo == 1 or levelNo == 40 or levelNo == 75 or levelNo == 103 or levelNo == 109) and hideTown) {
        if (isMapShowing) {
            WriteLogDebug("Hiding town " levelNo " since hideTown is set to true")
        }
        hideMap(false)
    } else if gameMemoryData["menuShown"] {
        partyInfoLayer.hide()
        itemCounterLayer.hide()
        buffBarLayer.hide()
        if (isMapShowing) {
            WriteLogDebug("Hiding since UI menu is shown")
        }
        hideMap(false, 1)
    } else if not WinActive(gameWindowId) {
        if (isMapShowing) {
            WriteLogDebug("D2R is not active window, hiding map")
        }
        hideMap(false)
        gameInfoLayer.hide()
        partyInfoLayer.hide()
        itemCounterLayer.hide()
        buffBarLayer.hide()
    } else if (!isAutomapShown(d2rprocess, uiOffset) and !alwaysShowMap) {
        ; hidemap
        hideMap(alwaysShowMap)
    } else {
        unHideMap()
    }
    if (!levelNo) {
        partyInfoLayer.hide()
    }
    return
}

hideMap(alwaysShowMap, menuShown := 0) {
    if ((alwaysShowMap == false) or menuShown) {
        Gui, Map: Hide
        Gui, Units: Hide
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
    itemCounterLayer.show()
    itemLogLayer.show()
    partyInfoLayer.show()
    buffBarLayer.show()
    if (!mapLoading) {
        Gui, Map: Show, NA
        Gui, Units: Show, NA
    } else {
        WriteLogDebug("Tried to show map while map loading, ignoring...")
    }
    return
}


+F10::Gosub, ExitMH

MapAlwaysShow:
{
    SetFormat Integer, D
    settings["alwaysShowMap"] := !settings["alwaysShowMap"]
    checkAutomapVisibility(d2rprocess, gameMemoryData)
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
    } else if (levelNo and settings["centerMode"]) {
        centerModeXoffset := settings["centerModeXoffset"] - 3
        IniWrite, %centerModeXoffset%, settings.ini, Settings, centerModeXoffset
        settings["centerModeXoffset"] := centerModeXoffset
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
    } else if (levelNo and settings["centerMode"]) {
        centerModeXoffset := settings["centerModeXoffset"] + 3
        IniWrite, %centerModeXoffset%, settings.ini, Settings, centerModeXoffset
        settings["centerModeXoffset"] := centerModeXoffset
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
    } else if (levelNo and settings["centerMode"]) {
        centerModeYoffset := settings["centerModeYoffset"] - 3
        IniWrite, %centerModeYoffset%, settings.ini, Settings, centerModeYoffset
        settings["centerModeYoffset"] := centerModeYoffset
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
    } else if (levelNo and settings["centerMode"]) {
        centerModeYoffset := settings["centerModeYoffset"] + 3
        IniWrite, %centerModeYoffset%, settings.ini, Settings, centerModeYoffset
        settings["centerModeYoffset"] := centerModeYoffset
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

#IfWinActive ahk_exe D2R.exe
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
    WriteLogDebug("TAB or Space pressed, map visibility being checked")
    checkAutomapVisibility(d2rprocess, gameMemoryData)
    return
}
~Esc::
{
    Gui, HelpText: Hide
    helpToggle := 1
    return
}

~+F11::
{
    WriteLog("Reloading script!")
    Reload
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
    Gosub, ShowSettings
    return
}


ExitMH:
{
    WriteLog("Pressed Shift+F10, exiting...")
    session.saveEntry()

    ; performance stats
    alreadyseenperf := []
    for k, perf in perfdata
    {
        
        thisName := perf["name"]
        if (!HasVal(alreadyseenperf, thisName)) {
            averageVal := 0
            count := 0
            for k, perf2 in perfdata
            {
                thisName2 := perf2["name"]
                if (thisName2 == thisName) {
                    averageVal := averageVal + perf2["duration"]
                    ++count
                }
            }
            OutputDebug, % thisName " " Round(averageVal / count / 1000.0, 2) "ms `n"
            alreadyseenperf.Push(thisName)
        }
    }
    ExitApp
    return
}

; open the settings window and a given position
ShowSettings:
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

; update settings (triggered when clicking save settings)`
Update:
{
    WriteLog("Applying new settings...")
    cmode := settings["centerMode"]
    UpdateSettings(settings, defaultSettings)
    historyText.delete()
    historyText := new SessionTableLayer(settings)
    gameInfoLayer.delete()
    gameInfoLayer := new GameInfoLayer(settings)
    partyInfoLayer.delete()
    partyInfoLayer := new PartyInfoLayer(settings)
    uiAssistLayer.delete()
    uiAssistLayer := new UIAssistLayer(settings)
    itemLogLayer.delete()
    itemLogLayer := new ItemLogLayer(settings)
    itemCounterLayer.delete()
    itemCounterLayer := new ItemCounterLayer(settings)
    buffBarLayer.delete()
    buffBarLayer := new BuffBarLayer(settings)
    SetupHotKeys(gameWindowId, settings)
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
        GuiControl, Show, Unsaved6
        GuiControl, Enable, UpdateBtn
    }
    return
}

Reload:
{
    Reload
    return
}
