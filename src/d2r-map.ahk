#SingleInstance, Force
#Persistent
SendMode Input
SetWorkingDir, %A_ScriptDir%
#Include %A_ScriptDir%\include\logging.ahk
#Include %A_ScriptDir%\memory\scanOffset.ahk
#Include %A_ScriptDir%\memory\readGameMemory.ahk
#Include %A_ScriptDir%\ui\image\downloadMapImage.ahk
#Include %A_ScriptDir%\ui\showMap.ahk
#Include %A_ScriptDir%\ui\showText.ahk
#Include %A_ScriptDir%\ui\showPlayer.ahk

if !FileExist(A_Scriptdir . "\settings.ini") {
	MsgBox, , Missing settings, Could not find settings.ini file
	ExitApp
}
lastMap := ""
exitArray := []
WriteLog("*******************************************************")
WriteLog("* Map overlay started *")
WriteLog("*******************************************************")
IniRead, baseUrl, settings.ini, MapHost, baseUrl, ""
IniRead, width, settings.ini, MapSettings, width, 1000
IniRead, topMargin, settings.ini, MapSettings, topMargin, 50
IniRead, leftMargin, settings.ini, MapSettings, leftMargin, 50
IniRead, opacity, settings.ini, MapSettings, opacity, 0.5
IniRead, startingOffset, settings.ini, Memory, playerOffset
IniRead, readInterval, settings.ini, Memory, readInterval, 1000
IniRead, debug, settings.ini, Logging, debug, false
IniRead, hideTown, settings.ini, MapSettings, hideTown, true

WriteLog("Using configuration:")
WriteLog("    baseUrl: " baseUrl)
WriteLog("    Map: width: " width ", topMargin: " topMargin ", leftMargin: " leftMargin ", opacity: " opacity)
WriteLog("    startingOffset: " startingOffset)
WriteLog("    hideTown: " hideTown)
WriteLog("    debug logging: " debug)

playerOffset:=startingOffset
lastlevel:=""
uidata:={}

SetTimer, GameState, 1000 ; the 1000 here is priority, not sleep
return

GameState:
	; scan for the player offset
	playerOffset := scanOffset(playerOffset, startingOffset)

	if (!playerOffset) {
		Sleep, 5000  ; sleep longer when no offset found, you're likely in menu
	} else {
        readGameMemory(playerOffset, gameMemoryData)
        if (gameMemoryData["levelNo"]) {
            ; if there's a level num then the player is in a map
            if (gameMemoryData["levelNo"] != lastlevel) {
                ; Show loading text
                Gui, 1: Hide
                Gui, 3: Hide
                ShowText(width, leftMargin, topMargin, "Loading map data...`nPlease wait", "22") ; 22 is opacity
                ; Download map
                downloadMapImage(baseUrl, gameMemoryData, mapData)
                Gui, 2: Destroy
                ; Show Map
                ShowMap(width, leftMargin, topMargin, mapData, gameMemoryData, uiData)
            }
            
            ShowPlayer(width, leftMargin, topMargin, mapData, gameMemoryData, uiData)

            lastlevel := gameMemoryData["levelNo"]
        } else {
            WriteLog("In Menu " gameMemoryData["levelNo"])
        }
    }
	Sleep, %readInterval% ; set a pacing of 1 second
return

+F10::
{
	WriteLog("Pressed Shift+F10, exiting...")
	ExitApp
}
