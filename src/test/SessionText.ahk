#SingleInstance, Force

#Include ..\include\Gdip_All.ahk
#Include ..\..\src\stats\GameSession.ahk
global diabloFont = "Arial"

sessionList := []
session1 := new GameSession("GameName1", A_TickCount, "PlayerName1")
session2 := new GameSession("GameName2", A_TickCount, "PlayerName2")
session3 := new GameSession("GameName2", A_TickCount, "PlayerName3")
session4 := new GameSession("GameName2", A_TickCount, "PlayerName4")
session5 := new GameSession("GameName2", A_TickCount, "PlayerName5")
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

ShowHistoryText(gamenameHwnd1, gameWindowId, sessionList)

ShowHistoryText(hwnd1, gameWindowId, sessionList) {
    
    ; WinGetPos, , , Width, Height, %gameWindowId%
    Width := A_ScreenWidth
    Height := A_ScreenHeight
    
    leftMargin := Width - 800
    topMargin := 20
    ; if (WinExist(gameWindowId)) {
        
        pToken := Gdip_Startup()
        DetectHiddenWindows, On
        hbm := CreateDIBSection(Width, Height)
        hdc := CreateCompatibleDC()
        obm := SelectObject(hdc, hbm)
        G := Gdip_GraphicsFromHDC(hdc)
        Gdip_SetSmoothingMode(G, 4)
        pBrush := Gdip_BrushCreateSolid(0xAA000000)
        Gdip_DeleteBrush(pBrush)

        col1 := 0
        col2 := 300
        col3 := 600

        Options = x%col1% y0 Left vCenter cffffffff r4 s26 Bold
        Gdip_TextToGraphics(G, "Game Name", Options, diabloFont, Width, 50)
        Options = x%col2% y0 Left vCenter cffffffff r4 s26 Bold
        Gdip_TextToGraphics(G, "Character", Options, diabloFont, Width, 50)
        Options = x%col3% y0 Left vCenter cffffffff r4 s26 Bold
        Gdip_TextToGraphics(G, "Duration", Options, diabloFont, Width, 50)

        y := 40
        for index, session in sessionList
        {
        
            gameName := session.gameName
            playerName := session.playerName
            gameTime := session.getDuration()

            Options = x%col1% y%y% Left vCenter cffFFD700 r4 s24
            Gdip_TextToGraphics(G, gameName, Options, diabloFont, Width, 50)

            Options = x%col2% y%y% Left vCenter cffFFD700 r4 s24
            Gdip_TextToGraphics(G, playerName, Options, diabloFont, Width, 50)

            gameTime := Round(gameTime, 1) . " sec"
            Options = x%col3% y%y% Left vCenter cffFFD700 r4 s24
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