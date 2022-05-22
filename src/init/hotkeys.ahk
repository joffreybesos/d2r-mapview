
SetupHotKeys(ByRef gameWindowId, ByRef settings) {
    switchMapModeKey := settings["switchMapMode"]
    if (switchMapModeKey) {
        Hotkey, IfWinActive, % gameWindowId
        Hotkey, %switchMapModeKey%, SwitchMapMode
    }
    historyToggleKey := settings["historyToggleKey"]
    if (historyToggleKey) {
        Hotkey, IfWinActive, % gameWindowId
        Hotkey, %historyToggleKey%, HistoryToggle
    }

    alwaysShowKey := settings["alwaysShowKey"]
    if (alwaysShowKey) {
        Hotkey, IfWinActive, % gameWindowId
        Hotkey, %alwaysShowKey%, MapAlwaysShow
    }

    increaseMapSizeKey := settings["increaseMapSizeKey"]
    if (increaseMapSizeKey) {
        Hotkey, IfWinActive, % gameWindowId
        Hotkey, %increaseMapSizeKey%, MapSizeIncrease
    }

    decreaseMapSizeKey := settings["decreaseMapSizeKey"]
    if (decreaseMapSizeKey) {
        Hotkey, IfWinActive, % gameWindowId
        Hotkey, %decreaseMapSizeKey%, MapSizeDecrease
    }

    moveMapLeftKey := settings["moveMapLeft"]
    if (moveMapLeftKey) {
        Hotkey, IfWinActive, % gameWindowId
        Hotkey, %moveMapLeftKey%, MoveMapLeft
    }

    moveMapRightKey := settings["moveMapRight"]
    if (moveMapLeftKey) {
        Hotkey, IfWinActive, % gameWindowId
        Hotkey, %moveMapRightKey%, MoveMapRight
    }
    moveMapUpKey := settings["moveMapUp"]
    if (moveMapLeftKey) {
        Hotkey, IfWinActive, % gameWindowId
        Hotkey, %moveMapUpKey%, MoveMapUp
    }
    moveMapDownKey := settings["moveMapDown"]
    if (moveMapLeftKey) {
        Hotkey, IfWinActive, % gameWindowId
        Hotkey, %moveMapDownKey%, MoveMapDown
    }
}

