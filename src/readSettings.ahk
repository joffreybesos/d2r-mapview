#SingleInstance, Force
SendMode Input
SetWorkingDir, %A_ScriptDir%

readSettings(settingsFile, ByRef settings) {
    FileInstall, mapconfig-default.ini, mapconfig.ini , 0
    FileInstall, exocetblizzardot-medium.otf, exocetblizzardot-medium.otf , 1

    ; these are the default values
    settings := []
    settings["scale"] := "1.000000"
    settings["leftMargin"] := "20"
    settings["topMargin"] := "20"
    settings["opacity"] := "0.6"
    settings["alwaysShowMap"] := 0
    settings["hideTown"] := 0
    settings["edges"] := 1
    settings["wallThickness"] := "0.5"
    settings["centerMode"] := 0
    settings["centerModeScale"] := "2.262"
    settings["serverScale"] := "3"
    settings["centerModeOpacity"] := "0.7"
    settings["centerModeXoffset"] := "0"
    settings["centerModeYoffset"] := "-28"
    settings["showGameInfo"] := 1
    settings["textSectionWidth"] := "700"
    settings["textSize"] := "20"
    settings["textAlignment"] := "LEFT"
    settings["showAllHistory"] := 0
    settings["showIPtext"] := 1
    settings["textIPfontSize"] := "18"
    settings["textIPalignment"] := "LEFT"
    settings["showNormalMobs"] := 1
    settings["showUniqueMobs"] := 1
    settings["showBosses"] := 1
    settings["showDeadMobs"] := 1
    settings["showImmunities"] := 1
    settings["showOtherPlayers"] := 1
    settings["showOtherPlayerNames"] := 0
    settings["showShrines"] := 1
    settings["showPortals"] := 1
    settings["showUniqueAlerts"] := 1
    settings["showSetItemAlerts"] := 1
    settings["showRuneAlerts"] := 1
    settings["showJewelAlerts"] := 1
    settings["showCharmAlerts"] := 1
    settings["normalMobColor"] := "FFFFFF"
    settings["uniqueMobColor"] := "D4AF37"
    settings["bossColor"] := "FF0000"
    settings["mercColor"] := "00FFFF"
    settings["deadColor"] := "000000"
    settings["showMercs"] := 0
    settings["showPlayerMissiles"] := 1
    settings["showEnemyMissiles"] := 1
    settings["normalDotSize"] := "5"
    settings["normalImmunitySize"] := "8"
    settings["uniqueDotSize"] := "8"
    settings["uniqueImmunitySize"] := "14"
    settings["deadDotSize"] := "2"
    settings["bossDotSize"] := "5"
    settings["physicalImmuneColor"] := "CD853f"
    settings["magicImmuneColor"] := "ff8800"
    settings["fireImmuneColor"] := "FF0000"
    settings["lightImmuneColor"] := "FFFF00"
    settings["coldImmuneColor"] := "0000FF"
    settings["poisonImmuneColor"] := "32CD32"
    settings["runeItemColor"] := "FFa700"
    settings["uniqueItemColor"] := "BBA45B"
    settings["setItemColor"] := "00FC00"
    settings["charmItemColor"] := "6D6DFF"
    settings["jewelItemColor"] := "6D6DFF"
    settings["showGems"] := 0
    settings["portalColor"] := "00AAFF"
    settings["redPortalColor"] := "FF0000"
    settings["shrineColor"] := "FFD700"
    settings["shrineTextSize"] := "20"
    settings["showWaypointLine"] := 0
    settings["showNextExitLine"] := 1
    settings["showBossLine"] := 1
    settings["showQuestLine"] := 1
    settings["increaseMapSizeKey"] := "NumpadAdd"
    settings["decreaseMapSizeKey"] := "NumpadSub"
    settings["alwaysShowKey"] := "NumpadMult"
    settings["moveMapLeft"] := "#Left"
    settings["moveMapRight"] := "#Right"
    settings["moveMapUp"] := "#Up"
    settings["moveMapDown"] := "#Down"
    settings["switchMapMode"] := "/"
    settings["historyToggleKey"] := "^g"
    settings["performanceMode"] := "0"
    settings["enableD2ML"] := 0
    settings["windowTitle"] := "D2R:main"
    settings["debug"] := 0
    
    settings["showOtherMissileDebug"] := 1
    settings["physicalMajorColor"] := "FFC2C2"
    settings["physicalMinorColor"] := "C99D9D"
    settings["fireMajorColor"] := "FF0000"
    settings["fireMinorColor"] := "C20000"
    settings["iceMajorColor"] := "00D0FF"
    settings["iceMinorColor"] := "00D0FF"
    settings["lightMajorColor"] := "FFFF00"
    settings["lightMinorColor"] := "A3A300"
    settings["poisonMajorColor"] := "00FF00"
    settings["poisonMinorColor"] := "009C00"
    settings["magicMajorColor"] := "FF7300"
    settings["magicMinorColor"] := "B35000"
    settings["otherMissilesColor"] := "FF00FF"
    settings["unknownMissilesColor"] := "FF00FF"
    settings["missileMajorDotSize"] := "6"
    settings["missileMinorDotSize"] := "3"

    ; read from the ini file and overwrite any of the above values
    IniRead, sectionNames, %settingsFile%
    Loop, Parse, sectionNames , `n
    {
        
        thisSection := A_LoopField
        IniRead, OutputVarSection, %settingsFile%, %thisSection%
        Loop, Parse, OutputVarSection , `n
        {
            valArr := StrSplit(A_LoopField,"=")
            valArr[1]
            if (valArr[2] == "true") {
                valArr[2] := true
            }
            if (valArr[2] == "false") {
                valArr[2] := false
            }
            settings[valArr[1]] := valArr[2]
        }
    }
    if (settings["enableD2ML"]) {
        gameWindowId := settings["windowTitle"]
    } else {
        gameWindowId := "ahk_exe D2R.exe"  ;default to normal window id
    }
    settings["gameWindowId"] := gameWindowId

    WriteLog("Using configuration:")
    WriteLog("- baseUrl: " settings["baseUrl"])
    WriteLog("- performanceMode: " settings["performanceMode"])
    WriteLog("- gameWindowId: " settings["gameWindowId"])
    WriteLog("- debug logging: " settings["debug"])
    if FileExist(A_Scriptdir . "\mapconfig.ini") {
        WriteLog("Found existing mapconfig.ini")
    }
    WriteLog("Starting d2r-mapview...")

}