#SingleInstance, Force
SendMode Input
SetWorkingDir, %A_ScriptDir%

readSettings(settingsFile, ByRef SettingsArray) {
    SettingsArray := {}

    ; multi session
    IniRead, enableD2ML,% settingsFile, MultiLaunch, enableD2ML
    SettingsArray.Insert("enableD2ML", enableD2ML)
    if (enableD2ML == "true") {
        IniRead, gameWindowId,% settingsFile, MultiLaunch, windowTitle
    } else {
        gameWindowId := "ahk_exe D2R.exe"  ;default to normal window id
    }
    SettingsArray.Insert("gameWindowId", gameWindowId)

    FileInstall, mapconfig-default.ini, mapconfig.ini , 0
    FileInstall, exocetblizzardot-medium.otf, exocetblizzardot-medium.otf , 1
    FileInstall, missiles-default.ini, missiles.ini , 0

    IniRead, baseUrl,% settingsFile, MapHost, baseUrl, ""

    IniRead, maxWidth,% settingsFile, MapSettings, maxWidth, 2000
    IniRead, scale,% settingsFile, MapSettings, scale, 1.0
    IniRead, topMargin,% settingsFile, MapSettings, topMargin, 50
    IniRead, leftMargin,% settingsFile, MapSettings, leftMargin, 50
    
    IniRead, opacity,% settingsFile, MapSettings, opacity, 0.5
    IniRead, alwaysShowMap,% settingsFile, MapSettings, alwaysShowMap, "false"
    IniRead, hideTown,% settingsFile, MapSettings, hideTown, "false"
    IniRead, edges,% settingsFile, MapSettings, edges, "true"
    IniRead, wallThickness,% settingsFile, MapSettings, wallThickness, 1

    IniRead, showGameInfo,% settingsFile, GameInfo, showGameInfo, "true"

    ; units
    IniRead, showNormalMobs,% settingsFile, Units, showNormalMobs, "true"
    IniRead, showUniqueMobs,% settingsFile, Units, showUniqueMobs, "true"
    IniRead, showBosses,% settingsFile, Units, showBosses, "true"
    IniRead, showDeadMobs,% settingsFile, Units, showDeadMobs, "true"
    IniRead, showImmunities,% settingsFile, Units, showImmunities, "true"
    IniRead, showOtherPlayers,% settingsFile, Units, showOtherPlayers, "true"
    IniRead, showOtherPlayerNames,% settingsFile, Units, showOtherPlayerNames, "true"
    IniRead, showShrines,% settingsFile, Units, showShrines, "true"
    IniRead, showPortals,% settingsFile, Units, showPortals, "true"
    IniRead, showMercs,% settingsFile, Units, showMercs, "true"
    IniRead, showPlayerMissiles,% settingsFile, Units, showPlayerMissiles, "false"
    IniRead, showEnemyMissiles,% settingsFile, Units, showEnemyMissiles, "false"
    IniRead, ShowOtherMissileDebug,% settingsFile, Units, ShowOtherMissileDebug, "false"
    IniRead, ShowKnownMissileDebug,% settingsFile, Units, ShowKnownMissileDebug, "false"
    
    ; items
    IniRead, showUniqueAlerts,% settingsFile, Units, showUniqueAlerts, "true"
    IniRead, showSetItemAlerts,% settingsFile, Units, showSetItemAlerts, "true"
    IniRead, showRuneAlerts,% settingsFile, Units, showRuneAlerts, "true"
    IniRead, showJewelAlerts,% settingsFile, Units, showJewelAlerts, "true"
    IniRead, showCharmAlerts,% settingsFile, Units, showCharmAlerts, "true"
    
    ; colours
    IniRead, normalMobColor,% settingsFile, Visuals, normalMobColor, "FFFFFF"
    IniRead, uniqueMobColor,% settingsFile, Visuals, uniqueMobColor, "D4AF37"
    IniRead, bossColor,% settingsFile, Visuals, bossColor, "FF0000"
    IniRead, deadColor,% settingsFile, Visuals, deadColor, "000000"

    IniRead, mercColor,% settingsFile, Visuals, mercColor, "00FFFF"
    IniRead, PhysicalMajorColor,% settingsFile, Visuals, PhysicalMajorColor, "FFC2C2"
    IniRead, PhysicalMinorColor,% settingsFile, Visuals, PhysicalMinorColor, "C99D9D"
    IniRead, FireMajorColor,% settingsFile, Visuals, FireMajorColor, "FF0000"
    IniRead, FireMinorColor,% settingsFile, Visuals, FireMinorColor, "C20000"
    IniRead, IceMajorColor,% settingsFile, Visuals, IceMajorColor, "00D0FF"
    IniRead, IceMinorColor,% settingsFile, Visuals, IceMinorColor, "0098BA"
    IniRead, LightMajorColor,% settingsFile, Visuals, LightMajorColor, "FFFF00"
    IniRead, LightMinorColor,% settingsFile, Visuals, LightMinorColor, "A3A300"
    IniRead, PoisonMajorColor,% settingsFile, Visuals, PoisonMajorColor, "00FF00"
    IniRead, PoisonMinorColor,% settingsFile, Visuals, PoisonMinorColor, "009C00"
    IniRead, MagicMajorColor,% settingsFile, Visuals, MagicMajorColor, "FF7300"
    IniRead, MagicMinorColor,% settingsFile, Visuals, MagicMinorColor, "B35000"
    IniRead, otherMissilesColor,% settingsFile, Visuals, otherMissilesColor, "9500FF"
    IniRead, unknownMissilesColor,% settingsFile, Visuals, unknownMissilesColor, "FF00FF"
    IniRead, defaultMissleColor,% settingsFile, Visuals, defaultMissleColor, "FF00FF"

    IniRead, normalDotSize,% settingsFile, Visuals, normalDotSize, 2.5
    IniRead, normalImmunitySize,% settingsFile, Visuals, normalImmunitySize, 4
    IniRead, uniqueDotSize,% settingsFile, Visuals, uniqueDotSize, 5
    IniRead, uniqueImmunitySize,% settingsFile, Visuals, uniqueImmunitySize, 11
    IniRead, deadDotSize,% settingsFile, Visuals, deadDotSize, 2
    IniRead, bossDotSize,% settingsFile, Visuals, bossDotSize, 5
    IniRead, MissileMajor,% settingsFile, Visuals, MissileMajor, 6
    IniRead, MissileMinor,% settingsFile, Visuals, MissileMinor, 3

    ; immunities
    IniRead, physicalImmuneColor,% settingsFile, Visuals, physicalImmuneColor, "CD853f"
    IniRead, magicImmuneColor,% settingsFile, Visuals, magicImmuneColor, "ff8800"
    IniRead, fireImmuneColor,% settingsFile, Visuals, fireImmuneColor, "FF0000"
    IniRead, lightImmuneColor,% settingsFile, Visuals, lightImmuneColor, "FFFF00"
    IniRead, coldImmuneColor,% settingsFile, Visuals, coldImmuneColor, "0000FF"
    IniRead, poisonImmuneColor,% settingsFile, Visuals, poisonImmuneColor, "32CD32"
    
    ; items
    IniRead, runeItemColor,% settingsFile, Visuals, runeItemColor, "FFa700"
    IniRead, uniqueItemColor,% settingsFile, Visuals, uniqueItemColor, "BBA45B"
    IniRead, setItemColor,% settingsFile, Visuals, setItemColor, "00FC00"
    IniRead, charmItemColor,% settingsFile, Visuals, charmItemColor, "FFa700"
    IniRead, jewelItemColor,% settingsFile, Visuals, jewelItemColor, "FFa700"

    IniRead, portalColor,% settingsFile, Visuals, portalColor, "FFD700"
    IniRead, redPortalColor,% settingsFile, Visuals, redPortalColor, "FF0000"
    IniRead, shrineColor,% settingsFile, Visuals, shrineColor, "FFD700"
    IniRead, shrineTextSize,% settingsFile, Visuals, shrineTextSize, "14"

    ; lines
    IniRead, showWaypointLine,% settingsFile, Lines, showWaypointLine, "false"
    IniRead, showNextExitLine,% settingsFile, Lines, showNextExitLine, "true"
    IniRead, showBossLine,% settingsFile, Lines, showBossLine, "true"

    ; hot keys
    IniRead, increaseMapSizeKey,% settingsFile, Hotkeys, increaseMapSizeKey, NumpadAdd
    IniRead, decreaseMapSizeKey,% settingsFile, Hotkeys, decreaseMapSizeKey, NumpadSub
    IniRead, alwaysShowKey,% settingsFile, Hotkeys, alwaysShowKey, NumpadMult

    IniRead, moveMapLeft,% settingsFile, Hotkeys, moveMapLeft, #Left
    IniRead, moveMapRight,% settingsFile, Hotkeys, moveMapRight, #Right
    IniRead, moveMapUp,% settingsFile, Hotkeys, moveMapUp, #Up
    IniRead, moveMapDown,% settingsFile, Hotkeys, moveMapDown, #Down

    ; other
    IniRead, performanceMode,% settingsFile, Other, performanceMode, 0

    
    IniRead, debug,% settingsFile, Logging, debug, "false"

    ; Here is a good example of why AHK sucks
    hideTown := hideTown = "true" ; convert to bool
    alwaysShowMap := alwaysShowMap = "true" ; convert to bool
    edges := edges = "true" ; convert to bool
    showNormalMobs := showNormalMobs = "true" ; convert to bool
    showUniqueMobs := showUniqueMobs = "true" ; convert to bool
    showOtherPlayers := showOtherPlayers = "true"
    showWaypointLine := showWaypointLine = "true" ; convert to bool
    showNextExitLine := showNextExitLine = "true" ; convert to bool
    showBossLine := showBossLine = "true" ; convert to bool
    showDeadMobs := showDeadMobs = "true"
    showImmunities := showImmunities = "true"
    showGameInfo := showGameInfo = "true"
    showUniqueAlerts := showUniqueAlerts = "true"
    showSetItemAlerts := showSetItemAlerts = "true"
    showRuneAlerts := showRuneAlerts = "true"
    showJewelAlerts := showJewelAlerts = "true"
    showCharmAlerts := showCharmAlerts = "true"
    showOtherPlayerNames := showOtherPlayerNames = "true"

    showShrines := showShrines = "true"
    showPortals := showPortals = "true"

    showMercs := showMercs = "true"
    showPlayerMissiles := showPlayerMissiles = "true"
    showEnemyMissiles := showEnemyMissiles = "true"
    ShowOtherMissileDebug := ShowOtherMissileDebug = "true"
    ShowKnownMissileDebug := ShowKnownMissileDebug = "true"

    ; AHK also doesn't let you declare an SettingsArray a more sensible way
    
    SettingsArray.Insert("baseUrl", baseUrl)
    SettingsArray.Insert("maxWidth", maxWidth)
    SettingsArray.Insert("scale", scale)
    SettingsArray.Insert("leftMarginControl", leftMargin)
    SettingsArray.Insert("topMarginControl", topMargin)
    SettingsArray.Insert("leftMargin", leftMargin)
    SettingsArray.Insert("topMargin", topMargin)
    SettingsArray.Insert("opacity", opacity)
    SettingsArray.Insert("alwaysShowMap", alwaysShowMap)
    SettingsArray.Insert("hideTown", hideTown)
    SettingsArray.Insert("edges", edges)
    SettingsArray.Insert("wallThickness", wallThickness)
    SettingsArray.Insert("showNormalMobs", showNormalMobs)
    SettingsArray.Insert("showUniqueMobs", showUniqueMobs)
    SettingsArray.Insert("showBosses", showBosses)
    SettingsArray.Insert("showDeadMobs", showDeadMobs)
    SettingsArray.Insert("showOtherPlayers", showOtherPlayers)
    SettingsArray.Insert("showOtherPlayerNames", showOtherPlayerNames)
    SettingsArray.Insert("showShrines", showShrines)
    SettingsArray.Insert("showPortals", showPortals)

    SettingsArray.Insert("showMercs", showMercs)
    SettingsArray.Insert("showMissiles", showMissiles)
    SettingsArray.Insert("showPlayerMissiles", showPlayerMissiles)
    SettingsArray.Insert("showEnemyMissiles", showEnemyMissiles)
    SettingsArray.Insert("ShowOtherMissileDebug", ShowOtherMissileDebug)
    SettingsArray.Insert("ShowKnownMissileDebug", ShowKnownMissileDebug)

    SettingsArray.Insert("showUniqueAlerts", showUniqueAlerts)
    SettingsArray.Insert("showSetItemAlerts", showSetItemAlerts)
    SettingsArray.Insert("showRuneAlerts", showRuneAlerts)
    SettingsArray.Insert("showJewelAlerts", showJewelAlerts)
    SettingsArray.Insert("showCharmAlerts", showCharmAlerts)

    SettingsArray.Insert("normalMobColor", normalMobColor)
    SettingsArray.Insert("uniqueMobColor", uniqueMobColor)
    SettingsArray.Insert("bossColor", bossColor)
    SettingsArray.Insert("deadColor", deadColor)

    SettingsArray.Insert("mercColor", mercColor)
    SettingsArray.Insert("PhysicalMajorColor", PhysicalMajorColor)
    SettingsArray.Insert("PhysicalMinorColor", PhysicalMinorColor)
    SettingsArray.Insert("FireMajorColor", FireMajorColor)
    SettingsArray.Insert("FireMinorColor", FireMinorColor)
    SettingsArray.Insert("IceMajorColor", IceMajorColor)
    SettingsArray.Insert("IceMinorColor", IceMinorColor)
    SettingsArray.Insert("LightMajorColor", LightMajorColor)
    SettingsArray.Insert("LightMinorColor", LightMinorColor)
    SettingsArray.Insert("PoisonMajorColor", PoisonMajorColor)
    SettingsArray.Insert("PoisonMinorColor", PoisonMinorColor)
    SettingsArray.Insert("MagicMajorColor", MagicMajorColor)
    SettingsArray.Insert("MagicMinorColor", MagicMinorColor)
    SettingsArray.Insert("otherMissilesColor", otherMissilesColor)
    SettingsArray.Insert("unknownMissileColor", unknownMissileColor)
    SettingsArray.Insert("defaultMissleColor", defaultMissleColor)

    SettingsArray.Insert("normalDotSize", normalDotSize)
    SettingsArray.Insert("normalImmunitySize", normalImmunitySize)
    SettingsArray.Insert("uniqueDotSize", uniqueDotSize)
    SettingsArray.Insert("uniqueImmunitySize", uniqueImmunitySize)
    SettingsArray.Insert("deadDotSize", deadDotSize)
    SettingsArray.Insert("bossDotSize", bossDotSize)
    SettingsArray.Insert("MissileMajor", MissileMajor)
    SettingsArray.Insert("MissileMinor", MissileMinor)

    SettingsArray.Insert("physicalImmuneColor", physicalImmuneColor)
    SettingsArray.Insert("magicImmuneColor", magicImmuneColor)
    SettingsArray.Insert("fireImmuneColor", fireImmuneColor)
    SettingsArray.Insert("lightImmuneColor", lightImmuneColor)
    SettingsArray.Insert("coldImmuneColor", coldImmuneColor)
    SettingsArray.Insert("poisonImmuneColor", poisonImmuneColor)
    SettingsArray.Insert("runeItemColor", runeItemColor)
    SettingsArray.Insert("uniqueItemColor", uniqueItemColor)
    SettingsArray.Insert("setItemColor", setItemColor)
    SettingsArray.Insert("charmItemColor", charmItemColor)
    SettingsArray.Insert("jewelItemColor", jewelItemColor)
    SettingsArray.Insert("redPortalColor", redPortalColor)
    SettingsArray.Insert("portalColor", portalColor)
    SettingsArray.Insert("shrineColor", shrineColor)
    SettingsArray.Insert("shrineTextSize", shrineTextSize)

    SettingsArray.Insert("showImmunities", showImmunities)
    SettingsArray.Insert("showWaypointLine", showWaypointLine)
    SettingsArray.Insert("showNextExitLine", showNextExitLine)
    SettingsArray.Insert("showBossLine", showBossLine)
    SettingsArray.Insert("increaseMapSizeKey", increaseMapSizeKey)
    SettingsArray.Insert("decreaseMapSizeKey", decreaseMapSizeKey)
    SettingsArray.Insert("alwaysShowKey", alwaysShowKey)

    SettingsArray.Insert("moveMapLeft", moveMapLeft)
    SettingsArray.Insert("moveMapRight", moveMapRight)
    SettingsArray.Insert("moveMapUp", moveMapUp)
    SettingsArray.Insert("moveMapDown", moveMapDown)
    SettingsArray.Insert("showGameInfo", showGameInfo)  
    SettingsArray.Insert("performanceMode", performanceMode)
    
    SettingsArray.Insert("debug", debug)

    WriteLog("Using configuration:")
    WriteLog("- baseUrl: " baseUrl)
    WriteLog("- Map: global scale: " scale ", global top margin: " topMargin ", global left margin: " leftMargin ", opacity: " opacity)
    WriteLog("- hideTown: " hideTown ", alwaysShowMap: " alwaysShowMap)
    WriteLog("- gameWindowId: " gameWindowId)
    WriteLog("- debug logging: " debug)
    if FileExist(A_Scriptdir . "\mapconfig.ini") {
        WriteLog("Found existing mapconfig.ini")
    }
    WriteLog("Starting d2r-mapview...")

}