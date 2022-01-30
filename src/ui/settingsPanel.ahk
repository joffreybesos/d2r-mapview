

CreateSettingsGUI(settings) {
    global
    Gui, Settings:Add, Button, x240 y445 w115 h30 gUpdate, Save && Apply
    Gui, Settings: Add, Tab, x2 y1 w360 h440, Info|General|Map Items|Game History|Monsters|Immunities|Alerts|Hotkeys|Other|Advanced

    Gui, Settings: Tab, General
    Gui, Settings: Font, S8 CGray, 
    Gui, Settings: Add, GroupBox, x11 y59 w340 h60 , Map Server URL
    Gui, Settings: Font, S8 CDefault, 
    Gui, Settings: Add, Edit, x29 y77 w250 h22 vBaseUrl
    
    Gui, Settings: Font, S7 CGray, 
    Gui, Settings: Add, Text, x30 y100 w180 h17 , Ex: http://localhost:3002
    Gui, Settings: Font, S8 CGray, 
    Gui, Settings: Add, GroupBox, x11 y129 w340 h140 , Map Overlay
    Gui, Settings: Font, S8 CDefault, 
    Gui, Settings: Add, Text, x53 y152 w90 h20 , Global scale
    Gui, Settings: Add, Edit, x22 y149 w28 h20 vScale, 1
    Gui, Settings: Add, Text, x53 y172 w50 h20 , Opacity
    Gui, Settings: Add, Edit, x22 y169 w28 h20 vOpacity, 0.5
    Gui, Settings: Add, Text, x53 y192 w120 h20 , Server Render Scale
    Gui, Settings: Add, Edit, x22 y189 w28 h20 vServerScale, 4
    Gui, Settings: Add, Text, x253 y154 w72 h17 , Left Margin
    Gui, Settings: Add, Edit, x222 y149 w28 h20 vLeftMargin, 20
    Gui, Settings: Add, Text, x253 y174 w74 h17 , Top Margin
    Gui, Settings: Add, Edit, x222 y169 w28 h20 vTopMargin, 20
    Gui, Settings: Add, Text, x253 y194 w91 h17 , Wall Thickness
    Gui, Settings: Add, Edit, x222 y189 w28 h20 vWallThickness, 0.5
    Gui, Settings: Add, CheckBox, x22 y219 w130 h20 vAlwaysShowMap, Always Show Map ;False
    Gui, Settings: Add, CheckBox, x22 y239 w130 h20 vHideTown, Hide Map in Town ;False
    Gui, Settings: Add, CheckBox, x222 y219 w100 h20 vEdges, Edges ;True
    Gui, Settings: Font, S8 CGray, 
    Gui, Settings: Add, GroupBox, x11 y279 w340 h130 , Map Center Mode
    Gui, Settings: Font, S8 CDefault, 
    Gui, Settings: Add, CheckBox, x22 y299 w110 h20 vCenterMode, Center Mode ;False
    Gui, Settings: Add, CheckBox, x222 y299 w120 h20 vShowPlayerDotCenter, Show Player Dot ;True
    Gui, Settings: Add, Text, x54 y322 w90 h20 , X Offset (Map)
    Gui, Settings: Add, Edit, x22 y319 w30 h20 vCenterModeXoffset, 0
    Gui, Settings: Add, Text, x54 y342 w90 h20 , Y Offset (Map)
    Gui, Settings: Add, Edit, x22 y339 w30 h20 vCenterModeYoffset, -56
    Gui, Settings: Add, Text, x54 y362 w160 h20 , X Offset (Players/Monsters)
    Gui, Settings: Add, Edit, x22 y359 w30 h20 vCenterModeXUnitoffset, 1
    Gui, Settings: Add, Text, x54 y382 w160 h20 , Y Offset (Players/Monsters)
    Gui, Settings: Add, Edit, x22 y379 w30 h20 vCenterModeYUnitoffset, 16
    Gui, Settings: Add, Text, x253 y322 w40 h20 , Scale
    Gui, Settings: Add, Edit, x222 y319 w28 h20 vCenterModeScale, 1.7
    Gui, Settings: Add, Text, x253 y342 w50 h20 , Opacity
    Gui, Settings: Add, Edit, x222 y339 w28 h20 vCenterModeOpacity, 0.7

    Gui, Settings: Tab, Map Items
    Gui, Settings: Font, S8 CGray, 
    Gui, Settings: Add, GroupBox, x11 y59 w340 h70 , Portals
    Gui, Settings: Font, S8 CDefault, 
    Gui, Settings: Add, CheckBox, x22 y79 w110 h20 vShowPortals, Show Portals ;True
    Gui, Settings: Add, Text, x215 y82 w130 h20 , Town Portal Color
    Gui, Settings: Add, Edit, x162 y79 w50 h20 vPortalColor, 00AAFF
    Gui, Settings: Add, Text, x215 y102 w130 h20 , Red Portal Color
    Gui, Settings: Add, Edit, x162 y99 w50 h20 vRedPortalColor, FF0000
    Gui, Settings: Font, S8 CGray, 
    Gui, Settings: Add, GroupBox, x11 y139 w340 h70 , Shrines
    Gui, Settings: Font, S8 CDefault, 
    Gui, Settings: Add, CheckBox, x22 y159 w100 h20 vShowShrines, Show Shrines ;True
    Gui, Settings: Add, Text, x215 y162 w100 h20 , Shrine Text Color
    Gui, Settings: Add, Edit, x162 y159 w50 h20 vShrineColor, FFD700
    Gui, Settings: Add, Text, x215 y182 w90 h20 , Shrine Text Size
    Gui, Settings: Add, Edit, x192 y179 w20 h20 vShrineTextSize, 14
    Gui, Settings: Font, S8 CGray, 
    Gui, Settings: Add, GroupBox, x11 y219 w340 h70 , Other Players
    Gui, Settings: Font, S8 CDefault, 
    Gui, Settings: Add, CheckBox, x22 y239 w120 h20 vShowOtherPlayers, Show Other Players ;True
    Gui, Settings: Add, CheckBox, x22 y259 w170 h20 vShowOtherPlayerNames, Show names above player dots ;False
    Gui, Settings: Add, Link, x95 y420 w200 h20 , Click <a href="https://htmlcolorcodes.com">here</a> for a HEX color chart

    Gui, Settings: Tab, Game History
    Gui, Settings: Font, S8 CGray, 
    Gui, Settings: Add, GroupBox, x11 y59 w340 h210 , Info
    Gui, Settings: Font, S8 CDefault, 
    Gui, Settings: Add, CheckBox, x22 y79 w170 h20 vshowGameInfo , Show Game History in menu ;True
    Gui, Settings: Add, CheckBox, x22 y99 w170 h20 vshowAllHistory, Show All History (load from CSV) ;False
    Gui, Settings: Add, CheckBox, x22 y119 w170 h20 vshowIPtext, Show Game Server IP in game ;True
    Gui, Settings: Add, Text, x85 y152 w150 h20 , Align Game History
    Gui, Settings: Add, DropDownList, x22 y149 w60 h80 vtextAlignment, LEFT||RIGHT
    Gui, Settings: Add, Text, x85 y172 w150 h20 , Align IP Address
    Gui, Settings: Add, DropDownList, x22 y169 w60 h80 vtextIPalignment, RIGHT||LEFT
    Gui, Settings: Add, Text, x65 y202 w200 h20 , Pixels width of game history
    Gui, Settings: Add, Edit, x22 y199 w40 h20 vtextSectionWidth, 700
    Gui, Settings: Add, Text, x65 y222 w200 h20 , Game History font size
    Gui, Settings: Add, Edit, x22 y219 w40 h20 vtextSize, 20
    Gui, Settings: Add, Text, x65 y242 w200 h20 , IP Address font size
    Gui, Settings: Add, Edit, x22 y239 w40 h20 vtextIPfontSize, 18

    Gui, Settings: Tab, Monsters
    Gui, Settings: Font, S8 CGray, 
    Gui, Settings: Add, GroupBox, x11 y59 w340 h250 , Monsters Dots
    Gui, Settings: Font, S8 CDefault, 
    Gui, Settings: Add, CheckBox, x22 y79 w140 h20 vshowNormalMobs, Show Normal Mobs ;True
    Gui, Settings: Add, CheckBox, x22 y99 w140 h20 vshowUniqueMobs, Show Unique Mobs ;True
    Gui, Settings: Add, CheckBox, x22 y119 w140 h20 vshowBosses, Show Bosses ;True
    Gui, Settings: Add, CheckBox, x22 y139 w140 h20 vshowDeadMobs, Show Dead Mobs ;True
    Gui, Settings: Add, Text, x215 y82 w110 h20 , Dot Size Normal
    Gui, Settings: Add, Edit, x182 y79 w30 h20 vnormalDotSize, 2.5
    Gui, Settings: Add, Text, x215 y102 w110 h20 , Dot Size Unique
    Gui, Settings: Add, Edit, x182 y99 w30 h20 vuniqueDotSize, 5
    Gui, Settings: Add, Text, x215 y122 w110 h20 , Dot Size Bosses
    Gui, Settings: Add, Edit, x182 y119 w30 h20 vbossDotSize, 5
    Gui, Settings: Add, Text, x215 y142 w110 h20 , Dot Size Dead
    Gui, Settings: Add, Edit, x182 y139 w30 h20 vdeadDotSize, 2
    Gui, Settings: Add, Text, x95 y172 w160 h20 , Dot Color Normal Mobs
    Gui, Settings: Add, Edit, x22 y169 w70 h20 vnormalMobColor, FFFFFF
    Gui, Settings: Add, Text, x95 y192 w160 h20 , Dot Color Unique Mobs
    Gui, Settings: Add, Edit, x22 y189 w70 h20 vuniqueMobColor, D4AF37
    Gui, Settings: Add, Text, x95 y212 w160 h20 , Dot Color Boss Mobs
    Gui, Settings: Add, Edit, x22 y209 w70 h20 vbossColor, FF0000
    Gui, Settings: Add, Text, x95 y232 w160 h20 , Dot Color Dead Mobs
    Gui, Settings: Add, Edit, x22 y229 w70 h20 vdeadColor, 000000
    Gui, Settings: Add, Text, x55 y262 w190 h20 , Normal Immunity Circle Size
    Gui, Settings: Add, Edit, x22 y259 w30 h20 vnormalImmunitySize, 4
    Gui, Settings: Add, Text, x55 y282 w190 h20 , Unique Immunity Circle Size
    Gui, Settings: Add, Edit, x22 y279 w30 h20 vuniqueImmunitySize, 11
    Gui, Settings: Add, Link, x95 y420 w200 h20 , Click <a href="https://htmlcolorcodes.com">here</a> for a HEX color chart

    Gui, Settings: Tab, Immunities
    Gui, Settings: Font, S8 CGray, 
    Gui, Settings: Add, GroupBox, x11 y59 w340 h170 , Monsters Immunities
    Gui, Settings: Font, S8 CDefault, 
    Gui, Settings: Add, CheckBox, x22 y79 w210 h20 vshowImmunities, Show monster immunities
    Gui, Settings: Add, Text, x95 y102 w140 h20 , Physical Immune Color
    Gui, Settings: Add, Edit, x22 y99 w70 h20 vphysicalImmuneColor, CD853F
    Gui, Settings: Add, Text, x95 y122 w140 h20 , Magic Immune Color
    Gui, Settings: Add, Edit, x22 y119 w70 h20 vmagicImmuneColor, FF8800
    Gui, Settings: Add, Text, x95 y142 w140 h20 , Fire Immune Color
    Gui, Settings: Add, Edit, x22 y139 w70 h20 vfireImmuneColor, FF0000
    Gui, Settings: Add, Text, x95 y162 w140 h20 , Lightning Immune Color
    Gui, Settings: Add, Edit, x22 y159 w70 h20 vlightImmuneColor, FFFF00
    Gui, Settings: Add, Text, x95 y182 w140 h20 , Cold Immune Color
    Gui, Settings: Add, Edit, x22 y179 w70 h20 vcoldImmuneColor, 0000FF
    Gui, Settings: Add, Text, x95 y202 w140 h20 , Poison Immune Color
    Gui, Settings: Add, Edit, x22 y199 w70 h20 vpoisonImmuneColor, 32CD32
    Gui, Settings: Add, Link, x95 y420 w200 h20 , Click <a href="https://htmlcolorcodes.com">here</a> for a HEX color chart

    Gui, Settings: Tab, Alerts
    Gui, Settings: Font, S8 CGray, 
    Gui, Settings: Add, GroupBox, x11 y59 w340 h170 , Ground Item Alerts
    Gui, Settings: Font, S8 CDefault, 
    Gui, Settings: Add, CheckBox, x22 y79 w100 h20 , Unique Alert ;True
    Gui, Settings: Add, CheckBox, x22 y99 w100 h20 , Set Item Alert ;True
    Gui, Settings: Add, CheckBox, x22 y119 w100 h20 , Rune Alert ;True
    Gui, Settings: Add, CheckBox, x22 y139 w100 h20 , Jewel Alert ;True
    Gui, Settings: Add, CheckBox, x22 y159 w100 h20 , Charm Alert ;True
    Gui, Settings: Add, CheckBox, x22 y179 w100 h20 , Base Item Alert ;True


    Gui, Settings: Tab, Other
    Gui, Settings: Font, S8 CGray, 
    Gui, Settings: Add, GroupBox, x11 y59 w340 h110 , Guide Lines
    Gui, Settings: Font, S8 CDefault, 
    Gui, Settings: Add, CheckBox, x22 y79 w190 h20 vshowWaypointLine, Yellow Line to Nearest Waypoint ;False
    Gui, Settings: Add, CheckBox, x22 y99 w190 h20 vshowNextExitLine, Purple Line to Next Relevant Exit ;True
    Gui, Settings: Add, CheckBox, x22 y119 w190 h20 vshowBossLine, Red Line to Boss in that Level ;True
    Gui, Settings: Add, CheckBox, x22 y139 w260 h20 vshowQuestLine, Green Line to the relevant quest item in that level ;True
    Gui, Settings: Font, S8 CGray, 
    Gui, Settings: Add, GroupBox, x11 y179 w340 h130 , Text to Speech
    Gui, Settings: Font, S8 CDefault, 
    Gui, Settings: Add, CheckBox, x22 y199 w190 h20 vallowTextToSpeech, Item Drop Text-to-Speech ;True
    Gui, Settings: Add, CheckBox, x22 y219 w190 h20 vallowItemDropSounds, Sound Effects in itemfilter.yaml ;True
    Gui, Settings: Add, Text, x55 y262 w170 h20 , Voice Pitch
    Gui, Settings: Add, Edit, x22 y259 w30 h20 vtextToSpeechPitch, 1
    Gui, Settings: Add, Text, x55 y242 w170 h20 , Text-to-Speech Volume (1-100)
    Gui, Settings: Add, Edit, x22 y239 w30 h20 vtextToSpeechVolume, 50
    Gui, Settings: Add, Text, x55 y282 w170 h20 , Speaking Speed
    Gui, Settings: Add, Edit, x22 y279 w30 h20 vtextToSpeechSpeed, 1
    Gui, Settings: Font, S8 CGray, 
    Gui, Settings: Add, GroupBox, x11 y319 w340 h90 , Projectiles
    Gui, Settings: Font, S8 CDefault, 
    Gui, Settings: Add, CheckBox, x22 y359 w110 h20 vshowEnemyMissiles, Enemy Missiles ;True
    Gui, Settings: Add, CheckBox, x22 y339 w110 h20 vshowPlayerMissiles, Player Missiles ;True
    Gui, Settings: Add, Text, x195 y342 w110 h20 , Large Missile Dot Size
    Gui, Settings: Add, Edit, x162 y339 w30 h20 vmissileMajorDotSize, 4
    Gui, Settings: Add, Text, x195 y362 w110 h20 , Small Missile Dot Size
    Gui, Settings: Add, Edit, x162 y359 w30 h20 vmissileMinorDotSize, 2
    Gui, Settings: Add, Text, x197 y382 w140 h20 , Missile Opacity (Hex Value)
    Gui, Settings: Add, Edit, x162 y379 w32 h20 vmissileOpacity, 0x77

    Gui, Settings: Tab, Advanced
    Gui, Settings: Font, S8 CGray, 
    Gui, Settings: Add, GroupBox, x11 y59 w340 h160 , Advanced Settings
    Gui, Settings: Font, S8 CDefault, 
    Gui, Settings: Add, Text, x65 y82 w110 h18 , Performance Mode
    Gui, Settings: Add, Edit, x22 y79 w40 h20 vperformanceMode, 50ms
    Gui, Settings: Font, S7 CGray, 
    Gui, Settings: Add, Text, x22 y99 w320 h20 , Experimental`, set to -1 to max out performance.
    Gui, Settings: Font, S8 CDefault, 
    Gui, Settings: Add, CheckBox, x22 y129 w100 h20 venableD2ML, Enable D2ML ;False
    Gui, Settings: Add, Text, x145 y152 w100 h18 , Window Title
    Gui, Settings: Add, Edit, x22 y149 w120 h20 vwindowTitle, D2R:main
    Gui, Settings: Font, S7 CGray, 
    Gui, Settings: Add, Text, x22 y169 w320 h30 , This is ignored unless Enable D2ML is turned on. It is used for D2R Multi-session
    Gui, Settings: Font, S8 CGray, 
    Gui, Settings: Add, GroupBox, x11 y229 w340 h100 , Debugging
    Gui, Settings: Font, S8 CDefault, 
    Gui, Settings: Add, CheckBox, x22 y249 w60 h20 vdebug, Debug ;False
    Gui, Settings: Font, S7 CGray, 
    Gui, Settings: Add, Text, x22 y269 w320 h30 , Turn this on to increase the level of the logging`, note this will create huge log.txt files. Can be toggled in-game with Shift+F9
    Gui, Settings: Font, S8 CDefault,
    
    Gui, Settings: Tab, Hotkeys
    Gui, Settings: Font, S8 CGray, 
    Gui, Settings: Add, GroupBox, x11 y59 w340 h220 , Shortcut Keys
    Gui, Settings: Font, S8 CDefault, 
    Gui, Settings: Tab, Hotkeys
    Gui, Settings: Add, Text, x85 y82 w250 h20 , Increase Size of Map
    Gui, Settings: Add, Edit, x22 y79 w60 h20 vincreaseMapSizeKey, 
    Gui, Settings: Add, Text, x85 y102 w250 h20 , Decrease Size of Map
    Gui, Settings: Add, Edit, x22 y99 w60 h20 vdecreaseMapSizeKey, 
    Gui, Settings: Add, Text, x85 y122 w250 h20 , Move Map Left
    Gui, Settings: Add, Edit, x22 y119 w60 h20 vmoveMapLeft, 
    Gui, Settings: Add, Text, x85 y142 w250 h20 , Move Map Right
    Gui, Settings: Add, Edit, x22 y139 w60 h20 vmoveMapRight, 
    Gui, Settings: Add, Text, x85 y162 w250 h20 , Move Map Up
    Gui, Settings: Add, Edit, x22 y159 w60 h20 vmoveMapUp, 
    Gui, Settings: Add, Text, x85 y182 w250 h20 , Move Map Down
    Gui, Settings: Add, Edit, x22 y179 w60 h20 vmoveMapDown, 
    Gui, Settings: Add, Text, x85 y202 w250 h20 , Hide Game History in Menu
    Gui, Settings: Add, Edit, x22 y199 w60 h20 vhistoryToggleKey, 
    Gui, Settings: Add, Text, x85 y222 w250 h20 , Always Show Map (Toggle)
    Gui, Settings: Add, Edit, x22 y219 w60 h20 valwaysShowKey, 
    Gui, Settings: Add, Text, x85 y242 w250 h20 , Center Map Mode (Toggle)
    Gui, Settings: Add, Edit, x22 y239 w60 h20 vswitchMapMode, 

    Gui, Settings: Tab, Info
    Gui, Settings: Font, S12 CBlack,
    Gui, Settings: Add, Text, x61 y119 w240 h20 , This is a settings GUI created for    
    Gui, Settings: Font, S12 CRed,    
    Gui, Settings: Add, Text, x121 y139 w120 h30 , d2r-mapview
    Gui, Settings: Font, S9 CDefault,
    Gui, Settings: Add, Text, x86 y189 w190 h20 , For more information about the project
    Gui, Settings: Add, Text, x121 y209 w120 h20 , Check out the link below
    Gui, Settings: Add, Link, x71 y229 w220 h20 , <a href="https://github.com/joffreybesos/d2r-mapview#readme">https://github.com/joffreybesos/d2r-mapview</a>
    Gui, Settings: Add, Text, x96 y269 w170 h20 , Click below to join the community!
    Gui, Settings: Add, Link, x81 y289 w200 h20 , <a href="https://discord.com/invite/qEgqyVW3uj">https://discord.com/invite/qEgqyVW3uj</a>

    

    
    ;Gui, Settings: Show, h482 w362, d2r-mapview settings
    GuiControl, Settings:, baseUrl, % settings["baseUrl"]
    GuiControl, Settings:, scale, % settings["scale"]
    GuiControl, Settings:, leftMargin, % settings["leftMargin"]
    GuiControl, Settings:, topMargin, % settings["topMargin"]
    GuiControl, Settings:, opacity, % settings["opacity"]
    GuiControl, Settings:, alwaysShowMap, % settings["alwaysShowMap"]
    GuiControl, Settings:, hideTown, % settings["hideTown"]
    GuiControl, Settings:, edges, % settings["edges"]
    GuiControl, Settings:, wallThickness, % settings["wallThickness"]
    GuiControl, Settings:, centerMode, % settings["centerMode"]
    GuiControl, Settings:, centerModeScale, % settings["centerModeScale"]
    GuiControl, Settings:, serverScale, % settings["serverScale"]
    GuiControl, Settings:, centerModeOpacity, % settings["centerModeOpacity"]
    GuiControl, Settings:, centerModeXoffset, % settings["centerModeXoffset"]
    GuiControl, Settings:, centerModeYoffset, % settings["centerModeYoffset"]
    GuiControl, Settings:, centerModeXUnitoffset, % settings["centerModeXUnitoffset"]
    GuiControl, Settings:, centerModeYUnitoffset, % settings["centerModeYUnitoffset"]
    GuiControl, Settings:, showGameInfo, % settings["showGameInfo"]
    GuiControl, Settings:, textSectionWidth, % settings["textSectionWidth"]
    GuiControl, Settings:, textSize, % settings["textSize"]
    if (settings["textAlignment"] == "LEFT") {
        GuiControl, Settings:, textAlignment, |LEFT||RIGHT
    } else {
        GuiControl, Settings:, textAlignment, |LEFT|RIGHT||
    }
    GuiControl, Settings:, showAllHistory, % settings["showAllHistory"]
    GuiControl, Settings:, showIPtext, % settings["showIPtext"]
    GuiControl, Settings:, textIPfontSize, % settings["textIPfontSize"]
    if (settings["textIPalignment"] == "LEFT") {
        GuiControl, Settings:, textIPalignment, |LEFT||RIGHT
    } else {
        GuiControl, Settings:, textIPalignment, |LEFT|RIGHT||
    }
    
    GuiControl, Settings:, showNormalMobs, % settings["showNormalMobs"]
    GuiControl, Settings:, showUniqueMobs, % settings["showUniqueMobs"]
    GuiControl, Settings:, showBosses, % settings["showBosses"]
    GuiControl, Settings:, showDeadMobs, % settings["showDeadMobs"]
    GuiControl, Settings:, showImmunities, % settings["showImmunities"]
    GuiControl, Settings:, showPlayerDotCenter, % settings["showPlayerDotCenter"]
    GuiControl, Settings:, showOtherPlayers, % settings["showOtherPlayers"]
    GuiControl, Settings:, showOtherPlayerNames, % settings["showOtherPlayerNames"]
    GuiControl, Settings:, showShrines, % settings["showShrines"]
    GuiControl, Settings:, showPortals, % settings["showPortals"]

    GuiControl, Settings:, allowTextToSpeech, % settings["allowTextToSpeech"]
    GuiControl, Settings:, textToSpeechVolume, % settings["textToSpeechVolume"]
    GuiControl, Settings:, textToSpeechPitch, % settings["textToSpeechPitch"]
    GuiControl, Settings:, textToSpeechSpeed, % settings["textToSpeechSpeed"]
    GuiControl, Settings:, allowItemDropSounds, % settings["allowItemDropSounds"]
    GuiControl, Settings:, showUniqueAlerts, % settings["showUniqueAlerts"]
    GuiControl, Settings:, showSetItemAlerts, % settings["showSetItemAlerts"]
    GuiControl, Settings:, showRuneAlerts, % settings["showRuneAlerts"]
    GuiControl, Settings:, showJewelAlerts, % settings["showJewelAlerts"]
    GuiControl, Settings:, showCharmAlerts, % settings["showCharmAlerts"]
    GuiControl, Settings:, showBaseItems, % settings["showBaseItems"]
    GuiControl, Settings:, normalMobColor, % settings["normalMobColor"]
    GuiControl, Settings:, uniqueMobColor, % settings["uniqueMobColor"]
    GuiControl, Settings:, bossColor, % settings["bossColor"]
    GuiControl, Settings:, mercColor, % settings["mercColor"]
    GuiControl, Settings:, deadColor, % settings["deadColor"]
    GuiControl, Settings:, showMercs, % settings["showMercs"]

    GuiControl, Settings:, normalDotSize, % settings["normalDotSize"]
    GuiControl, Settings:, normalImmunitySize, % settings["normalImmunitySize"]
    GuiControl, Settings:, uniqueDotSize, % settings["uniqueDotSize"]
    GuiControl, Settings:, uniqueImmunitySize, % settings["uniqueImmunitySize"]
    GuiControl, Settings:, deadDotSize, % settings["deadDotSize"]
    GuiControl, Settings:, bossDotSize, % settings["bossDotSize"]
    GuiControl, Settings:, physicalImmuneColor, % settings["physicalImmuneColor"]
    GuiControl, Settings:, magicImmuneColor, % settings["magicImmuneColor"]
    GuiControl, Settings:, fireImmuneColor, % settings["fireImmuneColor"]
    GuiControl, Settings:, lightImmuneColor, % settings["lightImmuneColor"]
    GuiControl, Settings:, coldImmuneColor, % settings["coldImmuneColor"]
    GuiControl, Settings:, poisonImmuneColor, % settings["poisonImmuneColor"]
    GuiControl, Settings:, runeItemColor, % settings["runeItemColor"]
    GuiControl, Settings:, uniqueItemColor, % settings["uniqueItemColor"]
    GuiControl, Settings:, setItemColor, % settings["setItemColor"]
    GuiControl, Settings:, charmItemColor, % settings["charmItemColor"]
    GuiControl, Settings:, jewelItemColor, % settings["jewelItemColor"]
    GuiControl, Settings:, portalColor, % settings["portalColor"]
    GuiControl, Settings:, redPortalColor, % settings["redPortalColor"]
    GuiControl, Settings:, shrineColor, % settings["shrineColor"]
    GuiControl, Settings:, baseItemColor, % settings["baseItemColor"]
    GuiControl, Settings:, shrineTextSize, % settings["shrineTextSize"]
    GuiControl, Settings:, showWaypointLine, % settings["showWaypointLine"]
    GuiControl, Settings:, showNextExitLine, % settings["showNextExitLine"]
    GuiControl, Settings:, showBossLine, % settings["showBossLine"]
    GuiControl, Settings:, showQuestLine, % settings["showQuestLine"]


    GuiControl, Settings:, increaseMapSizeKey, % settings["increaseMapSizeKey"]
    GuiControl, Settings:, decreaseMapSizeKey, % settings["decreaseMapSizeKey"]
    GuiControl, Settings:, alwaysShowKey, % settings["alwaysShowKey"]
    GuiControl, Settings:, moveMapLeft, % settings["moveMapLeft"]
    GuiControl, Settings:, moveMapRight, % settings["moveMapRight"]
    GuiControl, Settings:, moveMapUp, % settings["moveMapUp"]
    GuiControl, Settings:, moveMapDown, % settings["moveMapDown"]
    GuiControl, Settings:, switchMapMode, % settings["switchMapMode"]
    GuiControl, Settings:, historyToggleKey, % settings["historyToggleKey"]
    GuiControl, Settings:, performanceMode, % settings["performanceMode"]
    GuiControl, Settings:, enableD2ML, % settings["enableD2ML"]
    GuiControl, Settings:, windowTitle, % settings["windowTitle"]
    GuiControl, Settings:, debug, % settings["debug"]

    GuiControl, Settings:, showPlayerMissiles, % settings["showPlayerMissiles"]
    GuiControl, Settings:, showEnemyMissiles, % settings["showEnemyMissiles"]
    GuiControl, Settings:, missileOpacity, % settings["missileOpacity"]
    GuiControl, Settings:, missileColorPhysicalMajor, % settings["missileColorPhysicalMajor"]
    GuiControl, Settings:, missileColorPhysicalMinor, % settings["missileColorPhysicalMinor"]
    GuiControl, Settings:, missileFireMajorColor, % settings["missileFireMajorColor"]
    GuiControl, Settings:, missileFireMinorColor, % settings["missileFireMinorColor"]
    GuiControl, Settings:, missileIceMajorColor, % settings["missileIceMajorColor"]
    GuiControl, Settings:, missileIceMinorColor, % settings["missileIceMinorColor"]
    GuiControl, Settings:, missileLightMajorColor, % settings["missileLightMajorColor"]
    GuiControl, Settings:, missileLightMinorColor, % settings["missileLightMinorColor"]
    GuiControl, Settings:, missilePoisonMajorColor, % settings["missilePoisonMajorColor"]
    GuiControl, Settings:, missilePoisonMinorColor, % settings["missilePoisonMinorColor"]
    GuiControl, Settings:, missileMagicMajorColor, % settings["missileMagicMajorColor"]
    GuiControl, Settings:, missileMagicMinorColor, % settings["missileMagicMinorColor"]

    GuiControl, Settings:, missileMajorDotSize, % settings["missileMajorDotSize"]
    GuiControl, Settings:, missileMinorDotSize, % settings["missileMinorDotSize"]
    
    Return

}


UpdateSettings(ByRef settings) {

    GuiControlGet, baseUrl, ,baseUrl
    GuiControlGet, scale, ,scale
    GuiControlGet, leftMargin, ,leftMargin
    GuiControlGet, topMargin, ,topMargin
    GuiControlGet, opacity, ,opacity
    GuiControlGet, alwaysShowMap, ,alwaysShowMap
    GuiControlGet, hideTown, ,hideTown
    GuiControlGet, edges, ,edges
    GuiControlGet, wallThickness, ,wallThickness
    GuiControlGet, centerMode, ,centerMode
    GuiControlGet, centerModeScale, ,centerModeScale
    GuiControlGet, serverScale, ,serverScale
    GuiControlGet, centerModeOpacity, ,centerModeOpacity
    GuiControlGet, centerModeXoffset, ,centerModeXoffset
    GuiControlGet, centerModeYoffset, ,centerModeYoffset
    GuiControlGet, centerModeXUnitoffset, ,centerModeXUnitoffset
    GuiControlGet, centerModeYUnitoffset, ,centerModeYUnitoffset
    GuiControlGet, showGameInfo, ,showGameInfo
    GuiControlGet, textSectionWidth, ,textSectionWidth
    GuiControlGet, textSize, ,textSize
    GuiControlGet, textAlignment, ,textAlignment
    GuiControlGet, showAllHistory, ,showAllHistory
    GuiControlGet, showIPtext, ,showIPtext
    GuiControlGet, textIPfontSize, ,textIPfontSize
    GuiControlGet, textIPalignment, ,textIPalignment
    GuiControlGet, showNormalMobs, ,showNormalMobs
    GuiControlGet, showUniqueMobs, ,showUniqueMobs
    GuiControlGet, showBosses, ,showBosses
    GuiControlGet, showDeadMobs, ,showDeadMobs
    GuiControlGet, showImmunities, ,showImmunities
    GuiControlGet, showPlayerDotCenter, ,showPlayerDotCenter
    GuiControlGet, showOtherPlayers, ,showOtherPlayers
    GuiControlGet, showOtherPlayerNames, ,showOtherPlayerNames
    GuiControlGet, showShrines, ,showShrines
    GuiControlGet, showPortals, ,showPortals
    GuiControlGet, allowTextToSpeech, ,allowTextToSpeech
    GuiControlGet, textToSpeechVolume, ,textToSpeechVolume
    GuiControlGet, textToSpeechPitch, ,textToSpeechPitch
    GuiControlGet, textToSpeechSpeed, ,textToSpeechSpeed
    GuiControlGet, allowItemDropSounds, ,allowItemDropSounds
    GuiControlGet, showUniqueAlerts, ,showUniqueAlerts
    GuiControlGet, showSetItemAlerts, ,showSetItemAlerts
    GuiControlGet, showRuneAlerts, ,showRuneAlerts
    GuiControlGet, showJewelAlerts, ,showJewelAlerts
    GuiControlGet, showCharmAlerts, ,showCharmAlerts
    GuiControlGet, showBaseItems, ,showBaseItems
    GuiControlGet, normalMobColor, ,normalMobColor
    GuiControlGet, uniqueMobColor, ,uniqueMobColor
    GuiControlGet, bossColor, ,bossColor
    GuiControlGet, mercColor, ,mercColor
    GuiControlGet, deadColor, ,deadColor
    GuiControlGet, showMercs, ,showMercs
    GuiControlGet, normalDotSize, ,normalDotSize
    GuiControlGet, normalImmunitySize, ,normalImmunitySize
    GuiControlGet, uniqueDotSize, ,uniqueDotSize
    GuiControlGet, uniqueImmunitySize, ,uniqueImmunitySize
    GuiControlGet, deadDotSize, ,deadDotSize
    GuiControlGet, bossDotSize, ,bossDotSize
    GuiControlGet, physicalImmuneColor, ,physicalImmuneColor
    GuiControlGet, magicImmuneColor, ,magicImmuneColor
    GuiControlGet, fireImmuneColor, ,fireImmuneColor
    GuiControlGet, lightImmuneColor, ,lightImmuneColor
    GuiControlGet, coldImmuneColor, ,coldImmuneColor
    GuiControlGet, poisonImmuneColor, ,poisonImmuneColor
    GuiControlGet, runeItemColor, ,runeItemColor
    GuiControlGet, uniqueItemColor, ,uniqueItemColor
    GuiControlGet, setItemColor, ,setItemColor
    GuiControlGet, charmItemColor, ,charmItemColor
    GuiControlGet, jewelItemColor, ,jewelItemColor
    GuiControlGet, portalColor, ,portalColor
    GuiControlGet, redPortalColor, ,redPortalColor
    GuiControlGet, shrineColor, ,shrineColor
    GuiControlGet, baseItemColor, ,baseItemColor
    GuiControlGet, shrineTextSize, ,shrineTextSize
    GuiControlGet, showWaypointLine, ,showWaypointLine
    GuiControlGet, showNextExitLine, ,showNextExitLine
    GuiControlGet, showBossLine, ,showBossLine
    GuiControlGet, showQuestLine, ,showQuestLine
    GuiControlGet, increaseMapSizeKey, ,increaseMapSizeKey
    GuiControlGet, decreaseMapSizeKey, ,decreaseMapSizeKey
    GuiControlGet, alwaysShowKey, ,alwaysShowKey
    GuiControlGet, moveMapLeft, ,moveMapLeft
    GuiControlGet, moveMapRight, ,moveMapRight
    GuiControlGet, moveMapUp, ,moveMapUp
    GuiControlGet, moveMapDown, ,moveMapDown
    GuiControlGet, switchMapMode, ,switchMapMode
    GuiControlGet, historyToggleKey, ,historyToggleKey
    GuiControlGet, performanceMode, ,performanceMode
    GuiControlGet, enableD2ML, ,enableD2ML
    GuiControlGet, windowTitle, ,windowTitle
    GuiControlGet, debug, ,debug
    GuiControlGet, showPlayerMissiles, ,showPlayerMissiles
    GuiControlGet, showEnemyMissiles, ,showEnemyMissiles
    GuiControlGet, missileOpacity, ,missileOpacity
    GuiControlGet, missileColorPhysicalMajor, ,missileColorPhysicalMajor
    GuiControlGet, missileColorPhysicalMinor, ,missileColorPhysicalMinor
    GuiControlGet, missileFireMajorColor, ,missileFireMajorColor
    GuiControlGet, missileFireMinorColor, ,missileFireMinorColor
    GuiControlGet, missileIceMajorColor, ,missileIceMajorColor
    GuiControlGet, missileIceMinorColor, ,missileIceMinorColor
    GuiControlGet, missileLightMajorColor, ,missileLightMajorColor
    GuiControlGet, missileLightMinorColor, ,missileLightMinorColor
    GuiControlGet, missilePoisonMajorColor, ,missilePoisonMajorColor
    GuiControlGet, missilePoisonMinorColor, ,missilePoisonMinorColor
    GuiControlGet, missileMagicMajorColor, ,missileMagicMajorColor
    GuiControlGet, missileMagicMinorColor, ,missileMagicMinorColor
    GuiControlGet, missileMajorDotSize, ,missileMajorDotSize
    GuiControlGet, missileMinorDotSize, ,missileMinorDotSize
    settings["baseUrl"] := baseUrl
    settings["scale"] := scale
    settings["leftMargin"] := leftMargin
    settings["topMargin"] := topMargin
    settings["opacity"] := opacity
    settings["alwaysShowMap"] := alwaysShowMap
    settings["hideTown"] := hideTown
    settings["edges"] := edges
    settings["wallThickness"] := wallThickness
    settings["centerMode"] := centerMode
    settings["centerModeScale"] := centerModeScale
    settings["serverScale"] := serverScale
    settings["centerModeOpacity"] := centerModeOpacity
    settings["centerModeXoffset"] := centerModeXoffset
    settings["centerModeYoffset"] := centerModeYoffset
    settings["centerModeXUnitoffset"] := centerModeXUnitoffset
    settings["centerModeYUnitoffset"] := centerModeYUnitoffset
    settings["showGameInfo"] := showGameInfo
    settings["textSectionWidth"] := textSectionWidth
    settings["textSize"] := textSize
    settings["textAlignment"] := textAlignment
    settings["showAllHistory"] := showAllHistory
    settings["showIPtext"] := showIPtext
    settings["textIPfontSize"] := textIPfontSize
    settings["textIPalignment"] := textIPalignment
    settings["showNormalMobs"] := showNormalMobs
    settings["showUniqueMobs"] := showUniqueMobs
    settings["showBosses"] := showBosses
    settings["showDeadMobs"] := showDeadMobs
    settings["showImmunities"] := showImmunities
    settings["showPlayerDotCenter"] := showPlayerDotCenter
    settings["showOtherPlayers"] := showOtherPlayers
    settings["showOtherPlayerNames"] := showOtherPlayerNames
    settings["showShrines"] := showShrines
    settings["showPortals"] := showPortals

    settings["allowTextToSpeech"] := allowTextToSpeech
    settings["textToSpeechVolume"] := textToSpeechVolume
    settings["textToSpeechPitch"] := textToSpeechPitch
    settings["textToSpeechSpeed"] := textToSpeechSpeed
    settings["allowItemDropSounds"] := allowItemDropSounds
    settings["showUniqueAlerts"] := showUniqueAlerts
    settings["showSetItemAlerts"] := showSetItemAlerts
    settings["showRuneAlerts"] := showRuneAlerts
    settings["showJewelAlerts"] := showJewelAlerts
    settings["showCharmAlerts"] := showCharmAlerts
    settings["showBaseItems"] := showBaseItems
    settings["normalMobColor"] := normalMobColor
    settings["uniqueMobColor"] := uniqueMobColor
    settings["bossColor"] := bossColor
    settings["mercColor"] := mercColor
    settings["deadColor"] := deadColor
    settings["showMercs"] := showMercs

    settings["normalDotSize"] := normalDotSize
    settings["normalImmunitySize"] := normalImmunitySize
    settings["uniqueDotSize"] := uniqueDotSize
    settings["uniqueImmunitySize"] := uniqueImmunitySize
    settings["deadDotSize"] := deadDotSize
    settings["bossDotSize"] := bossDotSize
    settings["physicalImmuneColor"] := physicalImmuneColor
    settings["magicImmuneColor"] := magicImmuneColor
    settings["fireImmuneColor"] := fireImmuneColor
    settings["lightImmuneColor"] := lightImmuneColor
    settings["coldImmuneColor"] := coldImmuneColor
    settings["poisonImmuneColor"] := poisonImmuneColor
    settings["runeItemColor"] := runeItemColor
    settings["uniqueItemColor"] := uniqueItemColor
    settings["setItemColor"] := setItemColor
    settings["charmItemColor"] := charmItemColor
    settings["jewelItemColor"] := jewelItemColor
    settings["portalColor"] := portalColor
    settings["redPortalColor"] := redPortalColor
    settings["shrineColor"] := shrineColor
    settings["baseItemColor"] := baseItemColor
    settings["shrineTextSize"] := shrineTextSize
    settings["showWaypointLine"] := showWaypointLine
    settings["showNextExitLine"] := showNextExitLine
    settings["showBossLine"] := showBossLine
    settings["showQuestLine"] := showQuestLine


    settings["increaseMapSizeKey"] := increaseMapSizeKey
    settings["decreaseMapSizeKey"] := decreaseMapSizeKey
    settings["alwaysShowKey"] := alwaysShowKey
    settings["moveMapLeft"] := moveMapLeft
    settings["moveMapRight"] := moveMapRight
    settings["moveMapUp"] := moveMapUp
    settings["moveMapDown"] := moveMapDown
    settings["switchMapMode"] := switchMapMode
    settings["historyToggleKey"] := historyToggleKey
    settings["performanceMode"] := performanceMode
    settings["enableD2ML"] := enableD2ML
    settings["windowTitle"] := windowTitle
    settings["debug"] := debug

    settings["showPlayerMissiles"] := showPlayerMissiles
    settings["showEnemyMissiles"] := showEnemyMissiles
    settings["missileOpacity"] := missileOpacity
    settings["missileColorPhysicalMajor"] := missileColorPhysicalMajor
    settings["missileColorPhysicalMinor"] := missileColorPhysicalMinor
    settings["missileFireMajorColor"] := missileFireMajorColor
    settings["missileFireMinorColor"] := missileFireMinorColor
    settings["missileIceMajorColor"] := missileIceMajorColor
    settings["missileIceMinorColor"] := missileIceMinorColor
    settings["missileLightMajorColor"] := missileLightMajorColor
    settings["missileLightMinorColor"] := missileLightMinorColor
    settings["missilePoisonMajorColor"] := missilePoisonMajorColor
    settings["missilePoisonMinorColor"] := missilePoisonMinorColor
    settings["missileMagicMajorColor"] := missileMagicMajorColor
    settings["missileMagicMinorColor"] := missileMagicMinorColor

    settings["missileMajorDotSize"] := missileMajorDotSize
    settings["missileMinorDotSize"] := missileMinorDotSize
    
    
}

