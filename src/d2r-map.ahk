#SingleInstance, Force
#Include %A_ScriptDir%\include\getPlayerOffset.ahk
#Include %A_ScriptDir%\include\getMapUrl.ahk
#Include %A_ScriptDir%\include\getLevelNo.ahk
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

SetTimer, UpdateCycle, 1000
return

UpdateCycle:
	; scan for the player offset
	playerOffset := checkLastOffset(playerOffset)
	if (!playerOffset) {
		playerOffset := scanForPlayerOffset(startingOffset)
	}
	if (playerOffset) {
		pSeedAddress := getMapSeedAddress(playerOffset)
		if (pSeedAddress) {
			pLevelNoAddress := getLevelNoAddress(playerOffset)
			sMapUrl := getD2RMapUrl(baseUrl, pSeedAddress, pLevelNoAddress)
			if (InStr(lastMap, sMapUrl)) { ; if map not changed then don't update
			} else {
				WriteLog("Fetching map from " sMapUrl)
				lastMap := sMapUrl
				ShowMap(sMapUrl, width, height, leftMargin, topMargin, opacity)
			}
		} else {
			WriteLog("Found playerOffset" playerOffset ", but not map seed address")
			Sleep, 2000
		}
	} else {
		Sleep, 5000  ; sleep longer when no offset found, this means you're in menu
	}
	Sleep, 1000
return

+F4::ExitApp  ; shift+f4 to exit app


