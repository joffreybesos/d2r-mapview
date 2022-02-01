#SingleInstance, Force

#Include ..\include\Gdip_All.ahk
#Include ..\..\src\stats\GameSession.ahk
; global diabloFont = "Arial"
global diabloFont := (A_ScriptDir . "\exocetblizzardot-medium.otf")

sessionList := []
session1 := new GameSession("GameName1", A_TickCount, "PlayerName1")
session2 := new GameSession("GameName2", A_TickCount, "PlayerName2")
session3 := new GameSession("GameName3", A_TickCount, "PlayerName3")
session4 := new GameSession("GameName4", A_TickCount, "PlayerName4")
session5 := new GameSession("GameName5", A_TickCount, "PlayerName5")
sleep 10
session1.setEndTime(A_TickCount)
session2.setEndTime(A_TickCount)
session3.setEndTime(A_TickCount)
session4.setEndTime(A_TickCount)
session5.setEndTime(A_TickCount)
sessionList.push(session1)
sessionList.push(session2)
sessionList.push(session3)
sessionList.push(session4)
sessionList.push(session5)
Gui, GameInfo: -Caption +E0x20 +E0x80000 +LastFound +AlwaysOnTop +ToolWindow +OwnDialogs
Gui, GameInfo: Show, NA
gamenameHwnd1 := WinExist()

ShowHistoryText(gamenameHwnd1, gameWindowId, sessionList, "RIGHT", 800, 30)

ShowHistoryText(hwnd1, gameWindowId, sessionList, position = "RIGHT", textBoxWidth = 800, fontSize = 26) {
    
    ; WinGetPos, , , Width, Height, %gameWindowId%
    Width := A_ScreenWidth
    Height := A_ScreenHeight
    
    if (position == "RIGHT") {
        leftMargin := Width - textBoxWidth
    } else if (position = "LEFT") {
        leftMargin := 20
    } else {
        leftMargin := 20
    }
    topMargin := 20
    ; if (WinExist(gameWindowId)) {
        
        pToken := Gdip_Startup()
        DetectHiddenWindows, On
        hbm := CreateDIBSection(Width, Height)
        hdc := CreateCompatibleDC()
        obm := SelectObject(hdc, hbm)
        G := Gdip_GraphicsFromHDC(hdc)
        Gdip_SetSmoothingMode(G, 4)
        Gdip_SetInterpolationMode(G, 7)
        pBrush := Gdip_BrushCreateSolid(0xAA000000)
        Gdip_DeleteBrush(pBrush)

        col1 := 0
        col2 := textBoxWidth * 0.4
        col3 := textBoxWidth * 0.78

        Options = x%col1% y0 Left vCenter cffffffff r4 s%fontSize% Bold
        Gdip_TextToGraphics(G, "Game Name", Options, diabloFont, Width, 50)
        Options = x%col2% y0 Left vCenter cffffffff r4 s%fontSize% Bold
        Gdip_TextToGraphics(G, "Character", Options, diabloFont, Width, 50)
        Options = x%col3% y0 Left vCenter cffffffff r4 s%fontSize% Bold
        Gdip_TextToGraphics(G, "Duration", Options, diabloFont, Width, 50)

        y := 40
        ; lists is in reverse order
        max := sessionList.length()
        Loop %max%
        {
            session := sessionList[(max-A_Index+1)]
            gameName := session.gameName
            playerName := session.playerName
            gameTime := session.duration

            Options = x%col1% y%y% Left vCenter cffFFD700 r4 s%fontSize%
            Gdip_TextToGraphics(G, gameName, Options, diabloFont, Width, 50)

            Options = x%col2% y%y% Left vCenter cffFFD700 r4 s%fontSize%
            Gdip_TextToGraphics(G, playerName, Options, diabloFont, Width, 50)

            gameTime := Round(gameTime, 1) . " sec"
            Options = x%col3% y%y% Left vCenter cffFFD700 r4 s%fontSize%
            Gdip_TextToGraphics(G, gameTime, Options, diabloFont, Width/2, 50)
            y += 40
            
        }
        UpdateLayeredWindow(hwnd1, hdc, leftMargin, topMargin, Width, Height)
        SelectObject(hdc, obm)
        DeleteObject(hbm)
        DeleteDC(hdc)
        Gdip_DeleteGraphics(G)
        
        ; if WinActive(gameWindowId) {
            Gui, GameInfo: Show, NA
        ; } else {
        ;     gui, GameInfo: Hide
        ; }
    ; } else {
    ;     gui, GameInfo: Hide
    ; }
    Return
}

Return

Esc::
ExitApp
return