#SingleInstance, Force
#Persistent
#NoEnv
#MaxHotkeysPerInterval 99000000
#HotkeyInterval 99000000
#KeyHistory 0
; if not A_IsAdmin
; 	Run *RunAs "%A_ScriptFullPath%" 
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
SetTitleMatchMode, 2
#Include %A_ScriptDir%\include\classMemory.ahk
#Include %A_ScriptDir%\include\logging.ahk
#Include %A_ScriptDir%\include\Yaml.ahk
#Include %A_ScriptDir%\include\JSON.ahk
#Include %A_ScriptDir%\include\Gdip_All.ahk
#Include %A_ScriptDir%\itemfilter\AlertList.ahk
#Include %A_ScriptDir%\itemfilter\ItemAlert.ahk
#Include %A_ScriptDir%\types\Areas.ahk
#Include %A_ScriptDir%\types\Stats.ahk
#Include %A_ScriptDir%\types\Skills.ahk
#Include %A_ScriptDir%\types\MapImage.ahk
#Include %A_ScriptDir%\memory\initMemory.ahk
#Include %A_ScriptDir%\memory\readGameMemory.ahk
#Include %A_ScriptDir%\memory\isAutomapShown.ahk
#Include %A_ScriptDir%\memory\readLastGameName.ahk
#Include %A_ScriptDir%\memory\readIPAddress.ahk
#Include %A_ScriptDir%\memory\patternScan.ahk
#Include %A_ScriptDir%\memory\IsInGame.ahk
#Include %A_ScriptDir%\memory\readInvItems.ahk
#Include %A_ScriptDir%\memory\readStates.ahk
#Include %A_ScriptDir%\memory\readVendorItems.ahk
#Include %A_ScriptDir%\ui\image\clearCache.ahk
#Include %A_ScriptDir%\ui\image\loadBitmaps.ahk
#Include %A_ScriptDir%\ui\image\loadBuffIcons.ahk
#Include %A_ScriptDir%\ui\map\MapGUIs.ahk
#Include %A_ScriptDir%\ui\map\UnitsGUI.ahk
#Include %A_ScriptDir%\ui\showText.ahk
#Include %A_ScriptDir%\ui\showHelp.ahk
#Include %A_ScriptDir%\stats\GameSession.ahk
#Include %A_ScriptDir%\stats\readSessionFile.ahk
#Include %A_ScriptDir%\localization.ahk
#Include %A_ScriptDir%\init\hotkeys.ahk
#Include %A_ScriptDir%\init\readSettings.ahk
#Include %A_ScriptDir%\init\serverHealthCheck.ahk
#Include %A_ScriptDir%\init\updateCheck.ahk
#Include %A_ScriptDir%\ui\settingsPanel.ahk
#Include %A_ScriptDir%\ui\gdip\SessionTableLayer.ahk
#Include %A_ScriptDir%\ui\gdip\GameInfoLayer.ahk
#Include %A_ScriptDir%\ui\gdip\PartyInfoLayer.ahk
#Include %A_ScriptDir%\ui\gdip\UIAssistLayer.ahk
#Include %A_ScriptDir%\ui\gdip\ItemLogLayer.ahk
#Include %A_ScriptDir%\ui\gdip\ItemCounterLayer.ahk
#Include %A_ScriptDir%\ui\gdip\BuffBarLayer.ahk
#Include %A_ScriptDir%\mapFunctions.ahk

;Add right click menu in tray
Menu, Tray, NoStandard ; to remove default menu
Menu, Tray, Tip, d2r-mapview
Menu, Tray, Add, Settings, ShowSettings
Menu, Tray, Add
Menu, Tray, Add, Reload, Reload
Menu, Tray, Add
Menu, Tray, Add, Exit, ExitMH

global version := "3.0.0"

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
global lastlevel:=""
lastSeed:=""
session :=
lastPlayerLevel:=
lastPlayerExperience:=
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
global redrawMap := 1
global offsets := []
global hudBitmaps := loadBitmaps()
global buffBitmaps := loadBuffIcons()


CreateSettingsGUI(settings, localizedStrings)
settingupGUI := false

SetupHotKeys(gameWindowId, settings)

; check that game is running
if (not WinExist(gameWindowId)) {
    errornogame := localizedStrings["errormsg10"]
    WriteLog(gameWindowId " not found, please make sure game is running, try running MH as admin if still having issues")
    Msgbox, 48, d2r-mapview %version%, %errormsg10%`n`n%errormsg11%`n%errormsg12%`n`n%errormsg3%
    ExitApp
}

; initialise memory reading
global d2rprocess := initMemory(gameWindowId)
patternScan(d2rprocess, offsets)
Gdip_Startup()



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
mapGuis := new MapGUIs(settings)
unitsGui := new UnitsGUI(settings)
                
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
            hideMap(false, mapGuis, unitsGui)
            lastlevel:=
            items := []
            shrines := []
            seenItems := []
            itemLogItems := []
            vendorItems := []
            buffBarLayer.removedIcons := []
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
        timeStamp("readGameMemory")
        readGameMemory(d2rprocess, settings, gameMemoryData)
        timeStamp("readGameMemory")

        if (gameMemoryData["experience"]) {
            lastPlayerLevel:= gameMemoryData["playerLevel"]
            lastPlayerExperience:=gameMemoryData["experience"]
        }
        if (!levelNo) {
            partyInfoLayer.hide()
        }

        if ((gameMemoryData["difficulty"] == "0" or gameMemoryData["difficulty"] == "1" or gameMemoryData["difficulty"] == "2") and (gameMemoryData["levelNo"] > 0 and gameMemoryData["levelNo"] < 137) and gameMemoryData["mapSeed"]) {
            mapList := getStitchedMaps(gameMemoryData["levelNo"])
            if (gameMemoryData["mapSeed"] != lastSeed or newGame) {

                ; new game so reset all the map guis
                mapGuis := new MapGuis(settings)

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

                global shrines := []
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
            levelNo := gameMemoryData["levelNo"]
            if (mapList[1] != lastlevel) { ; only redraw map when it changes
                ; Show loading text
                mapLoading := 1
                mapGuis.hide()
                unitsGui.hide()
                
                ShowText(settings, "Loading map data...`nPlease wait`nPress Ctrl+H for help`nPress Ctrl+O for settings", "44") ; 44 is opacity
                ; Show Map
                mapGuis.downloadMapImages(mapList, gameMemoryData)
                
                mapLoading := 0
                Gui, LoadingText: Destroy ; remove loading text
                
                redrawMap := 1
            }
            if (redrawMap) {
                WriteLogDebug("Redrawing map")
                mapGuis.drawMaps(mapList, gameMemoryData)
                unitsGui.show()
                gameInfoLayer.updateAreaLevel(levelNo, gameMemoryData["difficulty"])
                gameInfoLayer.updateExpLevel(levelNo, gameMemoryData["difficulty"], gameMemoryData["playerLevel"])
                redrawMap := 0
            }
            ; timeStamp("ShowUnits")
            unitsGui.drawUnitLayer(settings, gameMemoryData, mapGuis.mapImageList[levelNo])
            ; timeStamp("ShowUnits")
            uiAssistLayer.drawMonsterBar(gameMemoryData["hoveredMob"])
            ; timeStamp("updateMapPositions")
            mapGuis.updateMapPositions(mapList, settings, d2rprocess, gameMemoryData)
            ; timeStamp("updateMapPositions")

            if (Mod(ticktock, 6)) {
                checkAutomapVisibility(d2rprocess, gameMemoryData, settings, mapGuis, unitsGui)
                CoordMode,Mouse,Screen
                MouseGetPos, mouseX, mouseY
                buffBarLayer.checkHover(mouseX, mouseY)
                if (buffBarLayer.removedIcons.Length() > 0) {
                    buffBarLayer.drawBuffBar(currentStates, buffBitmaps)
                }
            }
            if (HUDItems.tpscrolls < 5) {
                itemCounterLayer.drawItemCounter(HUDItems)
            }
            lastlevel := mapList[1]
        } else {
            WriteLog("In Menu - no valid difficulty, levelno, or mapseed found '" gameMemoryData["difficulty"] "' '" gameMemoryData["levelNo"] "' '" gameMemoryData["mapSeed"] "'")
            ; hideMap(false)
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
            gameInfoLayer.drawInfoText(currentFPS, gameMemoryData)
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


+F10::Gosub, ExitMH

MapAlwaysShow:
{
    MapAlwaysShow(settings, gameMemoryData, mapGuis, unitsGui)
    return
}

MapSizeIncrease:
{
    MapSizeIncrease(settings, gameMemoryData)
    mapGuis.setScale(settings)
    mapGuis.setOffsetPosition(settings)
    unitsGui.setScale(settings)
    return
}

MapSizeDecrease:
{
    MapSizeDecrease(settings, gameMemoryData)
    mapGuis.setScale(settings)
    mapGuis.setOffsetPosition(settings)
    unitsGui.setScale(settings)
    return
}

SwitchMapMode:
{
    SwitchMapMode(settings, mapImageList, gameMemoryData, uiData)
    mapGuis.setScale(settings)
    mapGuis.setOffsetPosition(settings)
    unitsGui.setScale(settings)
    return
}

MoveMapLeft:
{
    MoveMapLeft(settings)
    mapGuis.setOffsetPosition(settings)
    return
}
MoveMapRight:
{
    MoveMapRight(settings)
    mapGuis.setOffsetPosition(settings)
    return
}
MoveMapUp:
{
    MoveMapUp(settings)
    mapGuis.setOffsetPosition(settings)
    return
}
MoveMapDown:
{
    MoveMapDown(settings)
    mapGuis.setOffsetPosition(settings)
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
            OutputDebug, % thisName " " Round(averageVal / count / 1000.0, 2) "ms, last measurement " Round(perf2["duration"] / 1000.0, 2) "ms `n"
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
    lastlevel := "INVALIDATED"
    gameMemoryData := {}
    mapList.hide()
    mapShowing := 0
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
