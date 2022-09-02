
checkAutomapVisibility(ByRef d2rprocess, ByRef gameMemoryData, ByRef settings, ByRef mapGuis, ByRef unitsGui) {
    uiOffset:= offsets["uiOffset"]
    , alwaysShowMap:= settings["alwaysShowMap"]
    , hideTown:= settings["hideTown"] 
    , levelNo:= gameMemoryData["levelNo"]
    , isMenuShown:= gameMemoryData["menuShown"]
    if ((levelNo == 1 or levelNo == 40 or levelNo == 75 or levelNo == 103 or levelNo == 109) and hideTown) {
        if (isMapShowing) {
            WriteLogDebug("Hiding town " levelNo " since hideTown is set to true")
        }
        hideMap(false, mapGuis, unitsGui)
    } else if (gameMemoryData["menuShown"] == 1) { ; hide when menu shown
        partyInfoLayer.hide()
        itemCounterLayer.hide()
        buffBarLayer.hide()
        if (isMapShowing) {
            WriteLogDebug("Hiding since UI menu is shown")
        }
        hideMap(false, mapGuis, unitsGui, 1)
    } else if (gameMemoryData["menuShown"] == "RIGHT") {
        itemCounterLayer.hide()
        buffBarLayer.hide()
        if (isMapShowing) {
            WriteLogDebug("Hiding since UI menu is shown")
        }
        hideMap(false, mapGuis, unitsGui, 1)
    } else if not WinActive(gameWindowId) { ; hide when game window not active window
        if (isMapShowing) {
            WriteLogDebug("D2R is not active window, hiding map")
        }
        hideMap(false, mapGuis, unitsGui)
        gameInfoLayer.hide()
        partyInfoLayer.hide()
        itemCounterLayer.hide()
        buffBarLayer.hide()
    } else if (!isAutomapShown(d2rprocess, uiOffset) and !alwaysShowMap) {
        ; hidemap
        hideMap(alwaysShowMap, mapGuis, unitsGui)
    } else {
        unHideMap(mapGuis, unitsGui)
        partyInfoLayer.show()
        itemCounterLayer.show()
        buffBarLayer.show()
    }
    if (!levelNo) {
        partyInfoLayer.hide()
    }
    return
}

hideMap(alwaysShowMap, ByRef mapGuis, ByRef unitsGui, menuShown := 0) {
    if ((alwaysShowMap == false) or menuShown) {
        mapGuis.hide()
        unitsGui.hide()
        if (isMapShowing) {
            WriteLogDebug("Map hidden")
        }
        isMapShowing:= 0
    }
    return
}

unHideMap(ByRef mapGuis, ByRef unitsGui) {
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
        mapGuis.showLast()
        unitsGui.show()
    } else {
        WriteLogDebug("Tried to show map while map loading, ignoring...")
    }
    return
}


MoveMapLeft(ByRef gameMemoryData, ByRef settings, ByRef mapImageList) {
    SetFormat Integer, D
    levelNo := gameMemoryData["levelNo"] + 0
    levelxmargin := mapImageList[levelNo]["levelxmargin"] + 0
    levelymargin := mapImageList[levelNo]["levelymargin"] + 0
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


MoveMapRight(ByRef gameMemoryData, ByRef settings, ByRef mapImageList) {
    SetFormat Integer, D
    levelNo := gameMemoryData["levelNo"] + 0
    levelxmargin := mapImageList[levelNo]["levelxmargin"] + 0
    levelymargin := mapImageList[levelNo]["levelymargin"] + 0
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
}



MoveMapUp(ByRef gameMemoryData, ByRef settings, ByRef mapImageList) {
    SetFormat Integer, D
    levelNo := gameMemoryData["levelNo"] + 0
    levelxmargin := mapImageList[levelNo]["levelxmargin"] + 0
    levelymargin := mapImageList[levelNo]["levelymargin"] + 0
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
}


MoveMapDown(ByRef gameMemoryData, ByRef settings, ByRef mapImageList) {
    SetFormat Integer, D
    levelNo := gameMemoryData["levelNo"] + 0
    levelxmargin := mapImageList[levelNo]["levelxmargin"] + 0
    levelymargin := mapImageList[levelNo]["levelymargin"] + 0
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
}

SwitchMapMode(ByRef settings, ByRef mapImageList, ByRef gameMemoryData, ByRef uiData) {
    settings["centerMode"] := !settings["centerMode"]
    if (settings["centerMode"]) {
        WriteLog("Switched to centered mode")
    } else {
        WriteLog("Turn off centered mode")
    }
    lastlevel := "INVALIDATED"

    mapImageList[gameMemoryData["levelNo"]] := 0
    gameMemoryData  := {}
    uiData := {}
    WinSet, Region, , ahk_id %mapHwnd1%
    WinSet, Region, , ahk_id %unitHwnd1%
    ; Gui, Map: Hide
    ; Gui, Units: Hide
    mapShowing := 0
    GuiControl, Settings:, centerMode, % settings["centerMode"]
    WriteLog("switched map mode")
}

MapSizeIncrease(ByRef settings, ByRef gameMemoryData, byRef mapImageList) {
    SetFormat Integer, D
    levelNo := gameMemoryData["levelNo"] + 0
    levelScale := mapImageList[levelNo]["levelScale"] + 0
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
}

MapSizeDecrease(ByRef settings, ByRef gameMemoryData, byRef mapImageList) {
    SetFormat Integer, D
    levelNo := gameMemoryData["levelNo"] + 0
    levelScale := mapImageList[levelNo]["levelScale"] + 0
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
}

MapAlwaysShow(ByRef settings, ByRef gameMemoryData, ByRef mapGuis, ByRef unitsGui) {
    SetFormat Integer, D
    settings["alwaysShowMap"] := !settings["alwaysShowMap"]
    if (settings["alwaysShowMap"]) {
        unHideMap(mapGuis, unitsGui)
        IniWrite, true, settings.ini, Settings, alwaysShowMap
    } else {
        IniWrite, false, settings.ini, Settings, alwaysShowMap
    }
    GuiControl, Settings:, alwaysShowMap, % settings["alwaysShowMap"]
    WriteLog("alwaysShowMap set to " settings["alwaysShowMap"])
}