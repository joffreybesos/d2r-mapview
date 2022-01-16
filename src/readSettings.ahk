#SingleInstance, Force
SendMode Input
SetWorkingDir, %A_ScriptDir%

readSettings(settingsFile, ByRef settingsArray) {
    FileInstall, mapconfig-default.ini, mapconfig.ini , 0
    FileInstall, exocetblizzardot-medium.otf, exocetblizzardot-medium.otf , 1

    ; these are the default values
    settingsArray := []
    settingsArray["scale"] := "1.000000"
    settingsArray["leftMargin"] := "20"
    settingsArray["topMargin"] := "20"
    settingsArray["opacity"] := "0.6"
    settingsArray["alwaysShowMap"] := 0
    settingsArray["hideTown"] := 0
    settingsArray["edges"] := 1
    settingsArray["wallThickness"] := "0.5"
    settingsArray["centerMode"] := 0
    settingsArray["centerModeScale"] := "2.262"
    settingsArray["serverScale"] := "3"
    settingsArray["centerModeOpacity"] := "0.7"
    settingsArray["centerModeXoffset"] := "0"
    settingsArray["centerModeYoffset"] := "-28"
    settingsArray["showGameInfo"] := 1
    settingsArray["textSectionWidth"] := "700"
    settingsArray["textSize"] := "20"
    settingsArray["textAlignment"] := "LEFT"
    settingsArray["showAllHistory"] := 0
    settingsArray["showIPtext"] := 1
    settingsArray["textIPfontSize"] := "18"
    settingsArray["textIPalignment"] := "LEFT"
    settingsArray["showNormalMobs"] := 1
    settingsArray["showUniqueMobs"] := 1
    settingsArray["showBosses"] := 1
    settingsArray["showDeadMobs"] := 1
    settingsArray["showImmunities"] := 1
    settingsArray["showOtherPlayers"] := 1
    settingsArray["showOtherPlayerNames"] := 0
    settingsArray["showShrines"] := 1
    settingsArray["showPortals"] := 1
    settingsArray["showUniqueAlerts"] := 1
    settingsArray["showSetItemAlerts"] := 1
    settingsArray["showRuneAlerts"] := 1
    settingsArray["showJewelAlerts"] := 1
    settingsArray["showCharmAlerts"] := 1
    settingsArray["normalMobColor"] := "FFFFFF"
    settingsArray["uniqueMobColor"] := "D4AF37"
    settingsArray["bossColor"] := "FF0000"
    settingsArray["mercColor"] := "00FFFF"
    settingsArray["deadColor"] := "000000"
    settingsArray["showMercs"] := 0
    settingsArray["showPlayerMissiles"] := 0
    settingsArray["showEnemyMissiles"] := 0
    settingsArray["normalDotSize"] := "5"
    settingsArray["normalImmunitySize"] := "8"
    settingsArray["uniqueDotSize"] := "8"
    settingsArray["uniqueImmunitySize"] := "14"
    settingsArray["deadDotSize"] := "2"
    settingsArray["bossDotSize"] := "5"
    settingsArray["physicalImmuneColor"] := "CD853f"
    settingsArray["magicImmuneColor"] := "ff8800"
    settingsArray["fireImmuneColor"] := "FF0000"
    settingsArray["lightImmuneColor"] := "FFFF00"
    settingsArray["coldImmuneColor"] := "0000FF"
    settingsArray["poisonImmuneColor"] := "32CD32"
    settingsArray["runeItemColor"] := "FFa700"
    settingsArray["uniqueItemColor"] := "BBA45B"
    settingsArray["setItemColor"] := "00FC00"
    settingsArray["charmItemColor"] := "6D6DFF"
    settingsArray["jewelItemColor"] := "6D6DFF"
    settingsArray["showGems"] := 0
    settingsArray["portalColor"] := "00AAFF"
    settingsArray["redPortalColor"] := "FF0000"
    settingsArray["shrineColor"] := "FFD700"
    settingsArray["shrineTextSize"] := "20"
    settingsArray["showWaypointLine"] := 0
    settingsArray["showNextExitLine"] := 0
    settingsArray["showBossLine"] := 0
    settingsArray["showQuestLine"] := 0
    settingsArray["increaseMapSizeKey"] := "NumpadAdd"
    settingsArray["decreaseMapSizeKey"] := "NumpadSub"
    settingsArray["alwaysShowKey"] := "NumpadMult"
    settingsArray["moveMapLeft"] := "#Left"
    settingsArray["moveMapRight"] := "#Right"
    settingsArray["moveMapUp"] := "#Up"
    settingsArray["moveMapDown"] := "#Down"
    settingsArray["switchMapMode"] := "/"
    settingsArray["historyToggleKey"] := "^g"
    settingsArray["performanceMode"] := "0"
    settingsArray["enableD2ML"] := 0
    settingsArray["windowTitle"] := "D2R:main"
    settingsArray["debug"] := 0
    settingsArray["ShowKnownMissileDebug"] := 1
    settingsArray["ShowOtherMissileDebugs"] := 1
    settingsArray["PhysicalMajorColor"] := "FFC2C2"
    settingsArray["PhysicalMinorColor"] := "C99D9D"
    settingsArray["FireMajorColor"] := "FF0000"
    settingsArray["FireMinorColor"] := "C20000"
    settingsArray["IceMajorColor"] := "00D0FF"
    settingsArray["IceMinorColor"] := "00D0FF"
    settingsArray["LightMajorColor"] := "FFFF00"
    settingsArray["LightMinorColor"] := "A3A300"
    settingsArray["PoisonMajorColor"] := "00FF00"
    settingsArray["PoisonMinorColor"] := "009C00"
    settingsArray["MagicMajorColor"] := "FF7300"
    settingsArray["MagicMinorColor"] := "B35000"
    settingsArray["otherMissilesColor"] := "FF00FF"
    settingsArray["unknownMissilesColor"] := "FF00FF"
    settingsArray["MissileMajor"] := "6"
    settingsArray["MissileMinor"] := "3"

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
            settingsArray[valArr[1]] := valArr[2]
        }
    }
    if (settingsArray["enableD2ML"]) {
        gameWindowId := settingsArray["windowTitle"]
    } else {
        gameWindowId := "ahk_exe D2R.exe"  ;default to normal window id
    }
    settingsArray["gameWindowId"] := gameWindowId

    WriteLog("Using configuration:")
    WriteLog("- baseUrl: " settingsArray["baseUrl"])
    WriteLog("- performanceMode: " settingsArray["performanceMode"])
    WriteLog("- gameWindowId: " settingsArray["gameWindowId"])
    WriteLog("- debug logging: " settingsArray["debug"])
    if FileExist(A_Scriptdir . "\mapconfig.ini") {
        WriteLog("Found existing mapconfig.ini")
    }
    WriteLog("Starting d2r-mapview...")

}