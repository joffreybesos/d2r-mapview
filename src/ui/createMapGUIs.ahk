createmapGUIS(ByRef mapGuis) {
    Loop, 136 {
        Gui, Map%A_Index%: Destroy
    }
    
    mapGuis := []
    ; create GUI windows
    
    Loop, 136
    {
        Gui, Map%A_Index%: -Caption +E0x20 +E0x80000 +LastFound +AlwaysOnTop +ToolWindow +OwnDialogs
        thisMapGui := WinExist()
        mapGuis[A_Index] := thisMapGui
    }
}

hideMapGUIS(ByRef mapGuis) {
    ; hide maps
    Loop, 136 {
        Gui, Map%A_Index%: Hide ; hide map
    }
}

showMapGUIs(ByRef mapGuis, ByRef maplist) {
    for k, thisLevelNo in mapList
    {
        Gui, Map%thisLevelNo%: Show, NA
    }
}


getMapClientArea(windowId) {
    VarSetCapacity(RECT, 16, 0)
    DllCall("user32\GetClientRect", Ptr,windowId, Ptr,&RECT)
    DllCall("user32\ClientToScreen", Ptr,windowId, Ptr,&RECT)
    Win_Client_X := NumGet(&RECT, 0, "Int")
    Win_Client_Y := NumGet(&RECT, 4, "Int")
    Win_Client_W := NumGet(&RECT, 8, "Int")
    Win_Client_H := NumGet(&RECT, 12, "Int")
    return { "x": Win_Client_X, "y": Win_Client_Y, "width": Win_Client_W, "height": Win_Client_H }
}