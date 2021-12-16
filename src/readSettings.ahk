#SingleInstance, Force
SendMode Input
SetWorkingDir, %A_ScriptDir%

readSettings(settingsFile, ByRef settings) {
    FileInstall, mapconfig-default.ini, mapconfig.ini , 0
    FileInstall, exocetblizzardot-medium.otf, exocetblizzardot-medium.otf , 1

    IniRead, baseUrl, settings.ini, MapHost, baseUrl, ""

    IniRead, maxWidth, settings.ini, MapSettings, maxWidth, 2000
    IniRead, scale, settings.ini, MapSettings, scale, 1.0
    IniRead, topMargin, settings.ini, MapSettings, topMargin, 50
    IniRead, leftMargin, settings.ini, MapSettings, leftMargin, 50
    IniRead, opacity, settings.ini, MapSettings, opacity, 0.5
    IniRead, alwaysShowMap, settings.ini, MapSettings, alwaysShowMap, "false"
    IniRead, hideTown, settings.ini, MapSettings, hideTown, "false"
    IniRead, edges, settings.ini, MapSettings, edges, "true"
    IniRead, wallThickness, settings.ini, MapSettings, wallThickness, 1

    IniRead, centerMode, settings.ini, MapSettings, centerMode, "false"
    IniRead, centerModeScale, settings.ini, MapSettings, centerModeScale, 3.5
    IniRead, serverScale, settings.ini, MapSettings, serverScale, 5
    IniRead, centerModeOpacity, settings.ini, MapSettings, centerModeOpacity, 0.3
    IniRead, centerModeXoffset, settings.ini, MapSettings, centerModeXoffset, 0
    IniRead, centerModeYoffset, settings.ini, MapSettings, centerModeYoffset, -10

    IniRead, showGameInfo, settings.ini, GameInfo, showGameInfo, "true"

    ; units
    IniRead, showNormalMobs, settings.ini, Units, showNormalMobs, "true"
    IniRead, showUniqueMobs, settings.ini, Units, showUniqueMobs, "true"
    IniRead, showBosses, settings.ini, Units, showBosses, "true"
    IniRead, showDeadMobs, settings.ini, Units, showDeadMobs, "true"
    IniRead, showImmunities, settings.ini, Units, showImmunities, "true"
    IniRead, showOtherPlayers, settings.ini, Units, showOtherPlayers, "true"
    IniRead, showItems, settings.ini, Units, showItems, "true"
    IniRead, showShrines, settings.ini, Units, showShrines, "true"
    IniRead, showPortals, settings.ini, Units, showPortals, "true"
    
    ; colours
    IniRead, normalMobColor, settings.ini, Visuals, normalMobColor, "FFFFFF"
    IniRead, uniqueMobColor, settings.ini, Visuals, uniqueMobColor, "D4AF37"
    IniRead, bossColor, settings.ini, Visuals, bossColor, "FF0000"
    IniRead, deadColor, settings.ini, Visuals, deadColor, "000000"

    IniRead, normalDotSize, settings.ini, Visuals, normalDotSize, 2.5
    IniRead, normalImmunitySize, settings.ini, Visuals, normalImmunitySize, 4
    IniRead, uniqueDotSize, settings.ini, Visuals, uniqueDotSize, 5
    IniRead, uniqueImmunitySize, settings.ini, Visuals, uniqueImmunitySize, 11
    IniRead, deadDotSize, settings.ini, Visuals, deadDotSize, 2
    IniRead, bossDotSize, settings.ini, Visuals, bossDotSize, 5

    ; immunities
    IniRead, physicalImmuneColor, settings.ini, Visuals, physicalImmuneColor, "CD853f"
    IniRead, magicImmuneColor, settings.ini, Visuals, magicImmuneColor, "ff8800"
    IniRead, fireImmuneColor, settings.ini, Visuals, fireImmuneColor, "FF0000"
    IniRead, lightImmuneColor, settings.ini, Visuals, lightImmuneColor, "FFFF00"
    IniRead, coldImmuneColor, settings.ini, Visuals, coldImmuneColor, "0000FF"
    IniRead, poisonImmuneColor, settings.ini, Visuals, poisonImmuneColor, "32CD32"
    
    ; items
    IniRead, runeItemColor, settings.ini, Visuals, runeItemColor, "FFa700"
    IniRead, uniqueItemColor, settings.ini, Visuals, uniqueItemColor, "BBA45B"
    IniRead, setItemColor, settings.ini, Visuals, setItemColor, "00FC00"

    IniRead, portalColor, settings.ini, Visuals, portalColor, "FFD700"
    IniRead, redPortalColor, settings.ini, Visuals, redPortalColor, "FF0000"
    IniRead, shrineColor, settings.ini, Visuals, shrineColor, "FFD700"
    IniRead, shrineTextSize, settings.ini, Visuals, shrineTextSize, "14"

    ; lines
    IniRead, showWaypointLine, settings.ini, Lines, showWaypointLine, "false"
    IniRead, showNextExitLine, settings.ini, Lines, showNextExitLine, "true"
    IniRead, showBossLine, settings.ini, Lines, showBossLine, "true"

    ; hot keys
    IniRead, increaseMapSizeKey, settings.ini, Hotkeys, increaseMapSizeKey, NumpadAdd
    IniRead, decreaseMapSizeKey, settings.ini, Hotkeys, decreaseMapSizeKey, NumpadSub
    IniRead, alwaysShowKey, settings.ini, Hotkeys, alwaysShowKey, NumpadMult
    IniRead, moveMapLeft, settings.ini, Hotkeys, moveMapLeft, #Left
    IniRead, moveMapRight, settings.ini, Hotkeys, moveMapRight, #Right
    IniRead, moveMapUp, settings.ini, Hotkeys, moveMapUp, #Up
    IniRead, moveMapDown, settings.ini, Hotkeys, moveMapDown, #Down
    IniRead, switchMapMode, settings.ini, Hotkeys, switchMapMode, /

    ; other
    IniRead, performanceMode, settings.ini, Other, performanceMode, 0

    ; multi session
    IniRead, enableD2ML, settings.ini, MultiLaunch, enableD2ML
    if (enableD2ML == "true") {
        IniRead, gameWindowId, settings.ini, MultiLaunch, windowTitle
    } else {
        gameWindowId := "ahk_exe D2R.exe"  ;default to normal window id
    }
    IniRead, debug, settings.ini, Logging, debug, "false"

    ; Here is a good example of why AHK sucks
    hideTown := hideTown = "true" ; convert to bool
    alwaysShowMap := alwaysShowMap = "true" ; convert to bool
    edges := edges = "true" ; convert to bool
    centerMode := centerMode = "true" ; convert to bool
    showNormalMobs := showNormalMobs = "true" ; convert to bool
    showUniqueMobs := showUniqueMobs = "true" ; convert to bool
    showOtherPlayers := showOtherPlayers = "true"
    showWaypointLine := showWaypointLine = "true" ; convert to bool
    showNextExitLine := showNextExitLine = "true" ; convert to bool
    showBossLine := showBossLine = "true" ; convert to bool
    showDeadMobs := showDeadMobs = "true"
    showImmunities := showImmunities = "true"
    showGameInfo := showGameInfo = "true"
    showItems := showItems = "true"
    showShrines := showShrines = "true"
    showPortals := showPortals = "true"

    ; AHK also doesn't let you declare an array a more sensible way
    settings := {}
    settings.Insert("baseUrl", baseUrl)
    settings.Insert("maxWidth", maxWidth)
    settings.Insert("scale", scale)
    settings.Insert("leftMargin", leftMargin)
    settings.Insert("topMargin", topMargin)
    settings.Insert("opacity", opacity)
    settings.Insert("alwaysShowMap", alwaysShowMap)
    settings.Insert("hideTown", hideTown)
    settings.Insert("edges", edges)
    settings.Insert("wallThickness", wallThickness)
    settings.Insert("centerMode", centerMode)
    settings.Insert("centerModeScale", centerModeScale)
    settings.Insert("serverScale", serverScale)
    settings.Insert("centerModeOpacity", centerModeOpacity)
    settings.Insert("centerModeXoffset", centerModeXoffset)
    settings.Insert("centerModeYoffset", centerModeYoffset)

    settings.Insert("showNormalMobs", showNormalMobs)
    settings.Insert("showUniqueMobs", showUniqueMobs)
    settings.Insert("showBosses", showBosses)
    settings.Insert("showDeadMobs", showDeadMobs)
    settings.Insert("showOtherPlayers", showOtherPlayers)
    settings.Insert("showItems", showItems)
    settings.Insert("showShrines", showShrines)
    settings.Insert("showPortals", showPortals)

    settings.Insert("normalMobColor", normalMobColor)
    settings.Insert("uniqueMobColor", uniqueMobColor)
    settings.Insert("bossColor", bossColor)
    settings.Insert("deadColor", deadColor)

    settings.Insert("normalDotSize", normalDotSize)
    settings.Insert("normalImmunitySize", normalImmunitySize)
    settings.Insert("uniqueDotSize", uniqueDotSize)
    settings.Insert("uniqueImmunitySize", uniqueImmunitySize)
    settings.Insert("deadDotSize", deadDotSize)
    settings.Insert("bossDotSize", bossDotSize)

    settings.Insert("physicalImmuneColor", physicalImmuneColor)
    settings.Insert("magicImmuneColor", magicImmuneColor)
    settings.Insert("fireImmuneColor", fireImmuneColor)
    settings.Insert("lightImmuneColor", lightImmuneColor)
    settings.Insert("coldImmuneColor", coldImmuneColor)
    settings.Insert("poisonImmuneColor", poisonImmuneColor)
    settings.Insert("runeItemColor", runeItemColor)
    settings.Insert("uniqueItemColor", uniqueItemColor)
    settings.Insert("setItemColor", setItemColor)
    settings.Insert("redPortalColor", redPortalColor)
    settings.Insert("portalColor", portalColor)
    settings.Insert("shrineColor", shrineColor)
    settings.Insert("shrineTextSize", shrineTextSize)

    settings.Insert("showImmunities", showImmunities)
    settings.Insert("showWaypointLine", showWaypointLine)
    settings.Insert("showNextExitLine", showNextExitLine)
    settings.Insert("showBossLine", showBossLine)
    settings.Insert("increaseMapSizeKey", increaseMapSizeKey)
    settings.Insert("decreaseMapSizeKey", decreaseMapSizeKey)
    settings.Insert("alwaysShowKey", alwaysShowKey)
    settings.Insert("switchMapMode", switchMapMode)

    settings.Insert("moveMapLeft", moveMapLeft)
    settings.Insert("moveMapRight", moveMapRight)
    settings.Insert("moveMapUp", moveMapUp)
    settings.Insert("moveMapDown", moveMapDown)
    settings.Insert("showGameInfo", showGameInfo)  
    settings.Insert("performanceMode", performanceMode)
    settings.Insert("enableD2ML", enableD2ML)
    settings.Insert("gameWindowId", gameWindowId)
    settings.Insert("debug", debug)

    WriteLog("Using configuration:")
    WriteLog("- baseUrl: " baseUrl)
    WriteLog("- Map: global scale: " scale ", global top margin: " topMargin ", global left margin: " leftMargin ", opacity: " opacity)
    WriteLog("- performanceMode: " performanceMode)
    WriteLog("- hideTown: " hideTown ", alwaysShowMap: " alwaysShowMap)
    WriteLog("- gameWindowId: " gameWindowId)
    WriteLog("- debug logging: " debug)
    if FileExist(A_Scriptdir . "\mapconfig.ini") {
        WriteLog("Found existing mapconfig.ini")
    }
    WriteLog("Starting d2r-mapview...")

}