#SingleInstance, Force
#Include ..\..\src\stats\GameSession.ahk

session := new GameSession("GameName", A_TickCount, "PlayerName")
sleep 1000
session.setEndTime(A_TickCount)
session.saveEntry()
session.saveEntry()