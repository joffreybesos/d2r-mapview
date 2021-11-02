#SingleInstance, Force
#Include %A_ScriptDir%\include\getPlayerOffset.ahk
#Include %A_ScriptDir%\include\getMapUrl.ahk
#Include %A_ScriptDir%\include\getLevelNo.ahk
#Include %A_ScriptDir%\include\getDifficulty.ahk
#Include %A_ScriptDir%\include\getMapSeed.ahk
#Include %A_ScriptDir%\include\showMap.ahk
#Include %A_ScriptDir%\include\logging.ahk

lastMap := ""

WriteLog("*******************************************************")
WriteLog("* Map overlay started *")
WriteLog("*******************************************************")
IniRead, baseUrl, settings.ini, MapHost, baseUrl
IniRead, width, settings.ini, MapSettings, width
IniRead, height, settings.ini, MapSettings, height
IniRead, topMargin, settings.ini, MapSettings, topMargin
IniRead, leftMargin, settings.ini, MapSettings, leftMargin
IniRead, opacity, settings.ini, MapSettings, opacity
IniRead, startingOffset, settings.ini, Memory, playerOffset

playerOffset:=startingOffset

SetTimer, UpdateCycle, 1000 ; the 1000 here is priority, not sleep
return

UpdateCycle:
	; scan for the player offset
	playerOffset := checkLastOffset(playerOffset)
	if (!playerOffset) {
		Sleep, 1000
		playerOffset := scanForPlayerOffset(startingOffset)
	}
	if (playerOffset) {
		pSeedAddress := getMapSeedAddress(playerOffset)
		if (pSeedAddress) {
			pDifficultyAddress := getDifficultyAddress(playerOffset)
			pLevelNoAddress := getLevelNoAddress(playerOffset)
			if (pLevelNoAddress) {
				sMapUrl := getD2RMapUrl(baseUrl, pSeedAddress, pDifficultyAddress, pLevelNoAddress)
				if (InStr(lastMap, sMapUrl)) { ; if map not changed then don't update
				} else {
					WriteLog("Fetching map from " sMapUrl)
					lastMap := sMapUrl
					ShowMap(sMapUrl, width, height, leftMargin, topMargin, opacity)
				}
			}
		} else {
			WriteLog("Found playerOffset" playerOffset ", but not map seed address")
			Gui, 1: Hide
			playerOffset := startingOffset ; reset the offset to default
			Sleep, 1000
		}
	} else {
		playerOffset := startingOffset ; reset the offset to default
		Gui, 1: Hide
		Sleep, 3000  ; sleep longer when no offset found, you're likely in menu
	}
	Sleep, 1000 ; set a pacing of 1 second
return

+F10::
{
	WriteLog("Pressed Shift+F10, exiting...")
	ExitApp
}


