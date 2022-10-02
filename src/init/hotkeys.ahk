
SetupHotKeys() {
    switchMapModeKey := settings["switchMapMode"]
    if (switchMapModeKey) {
        Hotkey, IfWinActive, % gameWindowId
        Hotkey, ~%switchMapModeKey%, SwitchMapMode
    }
    historyToggleKey := settings["historyToggleKey"]
    if (historyToggleKey) {
        Hotkey, IfWinActive, % gameWindowId
        Hotkey, ~%historyToggleKey%, HistoryToggle
    }

    alwaysShowKey := settings["alwaysShowKey"]
    if (alwaysShowKey) {
        Hotkey, IfWinActive, % gameWindowId
        Hotkey, ~%alwaysShowKey%, MapAlwaysShow
    }

    increaseMapSizeKey := settings["increaseMapSizeKey"]
    if (increaseMapSizeKey) {
        Hotkey, IfWinActive, % gameWindowId
        Hotkey, ~%increaseMapSizeKey%, MapSizeIncrease
    }

    decreaseMapSizeKey := settings["decreaseMapSizeKey"]
    if (decreaseMapSizeKey) {
        Hotkey, IfWinActive, % gameWindowId
        Hotkey, ~%decreaseMapSizeKey%, MapSizeDecrease
    }

    moveMapLeftKey := settings["moveMapLeft"]
    if (moveMapLeftKey) {
        Hotkey, IfWinActive, % gameWindowId
        Hotkey, ~%moveMapLeftKey%, hkMoveMapLeft
    }

    moveMapRightKey := settings["moveMapRight"]
    if (moveMapLeftKey) {
        Hotkey, IfWinActive, % gameWindowId
        Hotkey, ~%moveMapRightKey%, hkMoveMapRight
    }
    moveMapUpKey := settings["moveMapUp"]
    if (moveMapLeftKey) {
        Hotkey, IfWinActive, % gameWindowId
        Hotkey, ~%moveMapUpKey%, hkMoveMapUp
    }
    moveMapDownKey := settings["moveMapDown"]
    if (moveMapLeftKey) {
        Hotkey, IfWinActive, % gameWindowId
        Hotkey, ~%moveMapDownKey%, hkMoveMapDown
    }
}

HistoryToggle(){
    global
    historyToggle := !historyToggle
    ; settings["showGameInfo"] := historyToggle
    ; IniWrite, %historyToggle%, settings.ini, Settings, showGameInfo
}

hkMoveMapLeft(){
    MoveMapLeft(settings)
    mapGuis.setScale(settings)
    unitsGui.setScale(settings)
    mapGuis.setOffsetPosition(settings)
    unitsGui.setOffsetPosition(settings)
    return
}

hkMoveMapRight(){
    MoveMapRight(settings)
    mapGuis.setScale(settings)
    unitsGui.setScale(settings)
    mapGuis.setOffsetPosition(settings)
    unitsGui.setOffsetPosition(settings)
    return
}

hkMoveMapUp(){
    MoveMapUp(settings)
    mapGuis.setScale(settings)
    unitsGui.setScale(settings)
    mapGuis.setOffsetPosition(settings)
    unitsGui.setOffsetPosition(settings)
    return
}

hkMoveMapDown(){
    MoveMapDown(settings)
    mapGuis.setScale(settings)
    unitsGui.setScale(settings)
    mapGuis.setOffsetPosition(settings)
    unitsGui.setOffsetPosition(settings)
    return
}

debug(){
    WriteLog("Debug mode set to " debug)
    debug := !debug
}

Help(ThisHotkey){
    static helpToggle:= False
    if (!(ThisHotkey ~= "Esc") and helpToggle := !helpToggle ) {
        ShowHelpText(settings)
        WriteLog("Show Help")
    } else {
        helpToggle := False
        Gui, HelpText: Hide
        WriteLog("Hide Help")
    }
    
    return
}

ExitMH(ThisHotkey=""){
    if ThisHotkey ~= "F10"
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
}

Reload(){
    WriteLog("Reloading script!")
    Reload
}


if false {
MapAlwaysShow:
{
    MapAlwaysShow(settings, gameMemoryData, mapGuis, unitsGui)
    return
}

MapSizeIncrease:
{
    MapSizeIncrease(settings, gameMemoryData)
    mapGuis.setScale(settings)
    unitsGui.setScale(settings)
    mapGuis.setOffsetPosition(settings)
    unitsGui.setOffsetPosition(settings)
    return
}

MapSizeDecrease:
{
    MapSizeDecrease(settings, gameMemoryData)
    mapGuis.setScale(settings)
    unitsGui.setScale(settings)
    mapGuis.setOffsetPosition(settings)
    unitsGui.setOffsetPosition(settings)
    return
}

SwitchMapMode:
{
    SwitchMapMode(settings, mapImageList, gameMemoryData, uiData)
    mapGuis.setScale(settings)
    unitsGui.setScale(settings)
    mapGuis.setOffsetPosition(settings)
    unitsGui.setOffsetPosition(settings)
    return
}

}