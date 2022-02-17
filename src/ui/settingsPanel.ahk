

CreateSettingsGUI(ByRef settings, ByRef localizedStrings) {
    global
    tabtitles = Info|General|Map Items|Game History|Monsters|Immunities|Item Filter|Hotkeys|Other|Advanced
    s1 := localizedStrings["s1"]
    s2 := localizedStrings["s2"]
    s3 := localizedStrings["s3"]
    s4 := localizedStrings["s4"]
    s5 := localizedStrings["s5"]
    s6 := localizedStrings["s6"]
    s7 := localizedStrings["s7"]
    s8 := localizedStrings["s8"]
    s9 := localizedStrings["s9"]
    s10 := localizedStrings["s10"]
    s11 := localizedStrings["s11"]
    s12 := localizedStrings["s12"]
    s13 := localizedStrings["s13"]
    s14 := localizedStrings["s14"]
    s15 := localizedStrings["s15"]
    s16 := localizedStrings["s16"]
    s17 := localizedStrings["s17"]
    s18 := localizedStrings["s18"]
    s19 := localizedStrings["s19"]
    s20 := localizedStrings["s20"]
    s21 := localizedStrings["s21"]
    s22 := localizedStrings["s22"]
    s23 := localizedStrings["s23"]
    s24 := "Map Items" ;localizedStrings["s24"]
    s25 := localizedStrings["s25"]
    s26 := localizedStrings["s26"]
    s27 := localizedStrings["s27"]
    s28 := localizedStrings["s28"]
    s29 := localizedStrings["s29"]
    s30 := localizedStrings["s30"]
    s31 := localizedStrings["s31"]
    s32 := localizedStrings["s32"]
    s33 := localizedStrings["s33"]
    s34 := localizedStrings["s34"]
    s35 := localizedStrings["s35"]
    t1 := localizedStrings["t1"]
    t2 := localizedStrings["t2"]
    t3 := localizedStrings["t3"]
    t4 := localizedStrings["t4"]
    t5 := localizedStrings["t5"]
    t6 := localizedStrings["t6"]
    t7 := localizedStrings["t7"]
    t8 := localizedStrings["t8"]
    t9 := localizedStrings["t9"]
    t10 := localizedStrings["t10"]
    t11 := localizedStrings["t11"]
    t12 := localizedStrings["t12"]
    t13 := localizedStrings["t13"]
    t14 := localizedStrings["t14"]
    t15 := localizedStrings["t15"]
    t16 := localizedStrings["t16"]
    t17 := localizedStrings["t17"]
    t18 := localizedStrings["t18"]
    t19 := localizedStrings["t19"]
    t20 := localizedStrings["t20"]
    t21 := localizedStrings["t21"]
    t22 := localizedStrings["t22"]
    t23 := localizedStrings["t23"]
    t24 := localizedStrings["t24"]
    t25 := localizedStrings["t25"]
    t26 := localizedStrings["t26"]
    t27 := localizedStrings["t27"]
    t28 := localizedStrings["t28"]
    t29 := localizedStrings["t29"]
    t30 := localizedStrings["t30"]
    t31 := localizedStrings["t31"]
    t32 := localizedStrings["t32"]
    t33 := localizedStrings["t33"]
    t34 := localizedStrings["t34"]
    t35 := localizedStrings["t35"]
    t36 := localizedStrings["t36"]
    t37 := localizedStrings["t37"]
    t38 := localizedStrings["t38"]
    t39 := localizedStrings["t39"]
    t40 := localizedStrings["t40"]
    t41 := localizedStrings["t41"]
    t42 := localizedStrings["t42"]
    t43 := localizedStrings["t43"]
    t44 := localizedStrings["t44"]
    cb1 := localizedStrings["cb1"]
    cb2 := localizedStrings["cb2"]
    cb3 := localizedStrings["cb3"]
    cb4 := localizedStrings["cb4"]
    cb5 := localizedStrings["cb5"]
    cb6 := localizedStrings["cb6"]
    cb7 := localizedStrings["cb7"]
    cb8 := localizedStrings["cb8"]
    cb9 := localizedStrings["cb9"]
    cb10 := localizedStrings["cb10"]
    cb11 := localizedStrings["cb11"]
    cb12 := localizedStrings["cb12"]
    cb13 := localizedStrings["cb13"]
    cb14 := localizedStrings["cb14"]
    cb15 := localizedStrings["cb15"]
    cb16 := localizedStrings["cb16"]
    cb17 := localizedStrings["cb17"]
    cb18 := localizedStrings["cb18"]
    cb19 := localizedStrings["cb19"]
    cb20 := localizedStrings["cb20"]
    cb21 := localizedStrings["cb21"]
    gb1 := localizedStrings["gb1"]
    gb2 := localizedStrings["gb2"]
    gb3 := localizedStrings["gb3"]
    gb4 := localizedStrings["gb4"]
    gb5 := localizedStrings["gb5"]
    gb6 := localizedStrings["gb6"]
    gb7 := localizedStrings["gb7"]
    gb8 := localizedStrings["gb8"]
    gb9 := localizedStrings["gb9"]
    gb10 := localizedStrings["gb10"]
    gb11 := localizedStrings["gb11"]
    uitext := localizedStrings["uitext"]
    ; msgbox % t9

    Gui, Settings:Add, Button, x240 y445 w115 h30 gUpdate vUpdateBtn Disabled, %r1%

    Gui, Settings: Font, S8 CRed,    
    Gui, Settings:Add, Text, x120 y453 w115 h17 +Right vUnsaved Hidden gUpdateFlag, %s2%
    Gui, Settings: Font, S8 CDefault,    
    Gui, Settings: Add, Tab3, x2 y1 w360 h440 vTabList, %tabtitles%

    Gui, Settings: Tab, General
    Gui, Settings: Font, S8 CGray, 
    Gui, Settings: Add, GroupBox, x11 y59 w340 h60 , %s3%
    Gui, Settings: Font, S8 CDefault, 
    Gui, Settings: Add, Edit, x29 y77 w250 h22 vBaseUrl gUpdateFlag
    
    Gui, Settings: Font, S7 CGray, 
    Gui, Settings: Add, Text, x30 y100 w180 h17 , Ex: http://localhost:3002
    Gui, Settings: Font, S8 CGray, 
    Gui, Settings: Add, GroupBox, x11 y129 w340 h140 , %s4%
    Gui, Settings: Font, S8 CDefault, 
    Gui, Settings: Add, Text, x53 y152 w90 h20 , Global %s5%
    Gui, Settings: Add, Edit, x22 y149 w28 h20 vScale gUpdateFlag
    Gui, Settings: Add, Text, x53 y172 w50 h20 , %s6%
    Gui, Settings: Add, Edit, x22 y169 w28 h20 vOpacity gUpdateFlag
    Gui, Settings: Add, Text, x53 y192 w120 h20 , %s7%
    Gui, Settings: Add, Edit, x22 y189 w28 h20 vServerScale gUpdateFlag
    Gui, Settings: Add, Text, x253 y154 w72 h17 , %s8%
    Gui, Settings: Add, Edit, x222 y149 w28 h20 vLeftMargin gUpdateFlag
    Gui, Settings: Add, Text, x253 y174 w74 h17 , %s9%
    Gui, Settings: Add, Edit, x222 y169 w28 h20 vTopMargin gUpdateFlag
    Gui, Settings: Add, Text, x253 y194 w91 h17 , %s10%
    Gui, Settings: Add, Edit, x222 y189 w28 h20 vWallThickness gUpdateFlag
    Gui, Settings: Add, CheckBox, x22 y219 w150 h20 vAlwaysShowMap gUpdateFlag, %s11% ;" settings["alwaysShowMap"]
    Gui, Settings: Add, CheckBox, x22 y239 w180 h20 vHideTown gUpdateFlag, %s12% ;False
    Gui, Settings: Add, CheckBox, x222 y219 w100 h20 vEdges gUpdateFlag, %s13% ;True
    Gui, Settings: Font, S8 CGray, 
    Gui, Settings: Add, GroupBox, x11 y279 w340 h130 , %s14%
    Gui, Settings: Font, S8 CDefault, 
    Gui, Settings: Add, CheckBox, x22 y299 w110 h20 vCenterMode gUpdateFlag, %s15% ;False
    Gui, Settings: Add, CheckBox, x222 y299 w130 h20 vShowPlayerDotCenter gUpdateFlag, %s16% ;True
    Gui, Settings: Add, CheckBox, x222 y319 w130 h20 vplayerAsCross gUpdateFlag, %s17% ;True
    Gui, Settings: Add, Text, x54 y322 w150 h20 , %s18%
    Gui, Settings: Add, Edit, x22 y319 w30 h20 vCenterModeXoffset gUpdateFlag, 0
    Gui, Settings: Add, Text, x54 y342 w180 h20 , %s19%
    Gui, Settings: Add, Edit, x22 y339 w30 h20 vCenterModeYoffset gUpdateFlag, -56
    Gui, Settings: Add, Text, x54 y362 w180 h20 , %s20%
    Gui, Settings: Add, Edit, x22 y359 w30 h20 vCenterModeXUnitoffset gUpdateFlag, 1
    Gui, Settings: Add, Text, x54 y382 w180 h20 , %s21%
    Gui, Settings: Add, Edit, x22 y379 w30 h20 vCenterModeYUnitoffset gUpdateFlag, 16
    Gui, Settings: Add, Text, x253 y342 w40 h20 , %s22%
    Gui, Settings: Add, Edit, x222 y339 w28 h20 vCenterModeScale gUpdateFlag, 1.7
    Gui, Settings: Add, Text, x253 y362 w50 h20 , %s23%
    Gui, Settings: Add, Edit, x222 y359 w28 h20 vCenterModeOpacity gUpdateFlag, 0.7

    Gui, Settings: Tab, Map Items
    Gui, Settings: Font, S8 CGray, 
    Gui, Settings: Add, GroupBox, x11 y59 w340 h70 , %s25%
    Gui, Settings: Font, S8 CDefault, 
    Gui, Settings: Add, CheckBox, x22 y79 w140 h20 vShowPortals gUpdateFlag, %s26% ;True
    Gui, Settings: Add, Text, x215 y82 w130 h20 , %s27%
    Gui, Settings: Add, Edit, x162 y79 w50 h20 vPortalColor gUpdateFlag, 00AAFF
    Gui, Settings: Add, Text, x215 y102 w130 h20 , %s28%
    Gui, Settings: Add, Edit, x162 y99 w50 h20 vRedPortalColor gUpdateFlag, FF0000
    Gui, Settings: Font, S8 CGray, 
    Gui, Settings: Add, GroupBox, x11 y139 w340 h70 , %s29%
    Gui, Settings: Font, S8 CDefault, 
    Gui, Settings: Add, CheckBox, x22 y159 w140 h20 vShowShrines gUpdateFlag, %s30% ;True
    Gui, Settings: Add, Text, x215 y162 w100 h20 , %s31%
    Gui, Settings: Add, Edit, x162 y159 w50 h20 vShrineColor gUpdateFlag, FFD700
    Gui, Settings: Add, Text, x215 y182 w90 h20 , %s32%
    Gui, Settings: Add, Edit, x192 y179 w20 h20 vShrineTextSize gUpdateFlag, 14
    Gui, Settings: Font, S8 CGray, 
    Gui, Settings: Add, GroupBox, x11 y219 w340 h70 , %s33%
    Gui, Settings: Font, S8 CDefault, 
    Gui, Settings: Add, CheckBox, x22 y239 w250 h20 vShowOtherPlayers gUpdateFlag, %s34% ;True
    Gui, Settings: Add, CheckBox, x22 y259 w270 h20 vShowOtherPlayerNames gUpdateFlag, %s35% ;False


    Gui, Settings: Font, S8 CGray, 
    Gui, Settings: Add, GroupBox, x11 y299 w340 h50 ,  %gb1%
    Gui, Settings: Font, S8 CDefault, 
    Gui, Settings: Add, CheckBox, x22 y319 w120 h20 vShowChests gUpdateFlag, %cb1%
    
    
    Gui, Settings: Add, Link, x95 y418 w200 h20 , Click <a href="https://htmlcolorcodes.com">here</a> for a HEX color chart

    Gui, Settings: Tab, Game History
    Gui, Settings: Font, S8 CGray, 
    Gui, Settings: Add, GroupBox, x11 y59 w340 h210 ,  %gb2%
    Gui, Settings: Font, S8 CDefault, 
    Gui, Settings: Add, CheckBox, x22 y79 w270 h20 vshowGameInfo  gUpdateFlag, %cb2%
    Gui, Settings: Add, CheckBox, x22 y99 w270 h20 vshowAllHistory gUpdateFlag, %cb3%
    Gui, Settings: Add, CheckBox, x22 y119 w270 h20 vshowIPtext gUpdateFlag, %cb4%
    Gui, Settings: Add, Text, x85 y152 w150 h20 , %t1%
    Gui, Settings: Add, DropDownList, x22 y149 w60 h80 vtextAlignment gUpdateFlag, LEFT||RIGHT
    Gui, Settings: Add, Text, x85 y172 w150 h20 , %t2%
    Gui, Settings: Add, DropDownList, x22 y169 w60 h80 vtextIPalignment gUpdateFlag, RIGHT||LEFT
    Gui, Settings: Add, Text, x65 y202 w250 h20 , %t3%
    Gui, Settings: Add, Edit, x22 y199 w40 h20 vtextSectionWidth gUpdateFlag, 700
    Gui, Settings: Add, Text, x65 y222 w250 h20 , %t4%
    Gui, Settings: Add, Edit, x22 y219 w40 h20 vtextSize gUpdateFlag, 20
    Gui, Settings: Add, Text, x65 y242 w250 h20 , %t5%
    Gui, Settings: Add, Edit, x22 y239 w40 h20 vtextIPfontSize gUpdateFlag, 18

    Gui, Settings: Tab, Monsters
    Gui, Settings: Font, S8 CGray, 
    Gui, Settings: Add, GroupBox, x11 y59 w340 h250 ,  %gb3%
    Gui, Settings: Font, S8 CDefault, 
    Gui, Settings: Add, CheckBox, x22 y79 w160 h20 vshowNormalMobs gUpdateFlag, %cb5%
    Gui, Settings: Add, CheckBox, x22 y99 w160 h20 vshowUniqueMobs gUpdateFlag, %cb6%
    Gui, Settings: Add, CheckBox, x22 y119 w160 h20 vshowBosses gUpdateFlag, %cb7%
    Gui, Settings: Add, CheckBox, x22 y139 w160 h20 vshowDeadMobs gUpdateFlag, %cb8%
    Gui, Settings: Add, Text, x215 y82 w110 h20 , %t6%
    Gui, Settings: Add, Edit, x182 y79 w30 h20 vnormalDotSize gUpdateFlag, 2.5
    Gui, Settings: Add, Text, x215 y102 w110 h20 , %t7%
    Gui, Settings: Add, Edit, x182 y99 w30 h20 vuniqueDotSize gUpdateFlag, 5
    Gui, Settings: Add, Text, x215 y122 w110 h20 , %t8%
    Gui, Settings: Add, Edit, x182 y119 w30 h20 vbossDotSize gUpdateFlag, 5
    Gui, Settings: Add, Text, x215 y142 w110 h20 , %t9%
    Gui, Settings: Add, Edit, x182 y139 w30 h20 vdeadDotSize gUpdateFlag, 2
    Gui, Settings: Add, Text, x95 y172 w160 h20 , %t10%
    Gui, Settings: Add, Edit, x22 y169 w70 h20 vnormalMobColor gUpdateFlag, FFFFFF
    Gui, Settings: Add, Text, x95 y192 w160 h20 , %t11%
    Gui, Settings: Add, Edit, x22 y189 w70 h20 vuniqueMobColor gUpdateFlag, D4AF37
    Gui, Settings: Add, Text, x95 y212 w160 h20 , %t12%
    Gui, Settings: Add, Edit, x22 y209 w70 h20 vbossColor gUpdateFlag, FF0000
    Gui, Settings: Add, Text, x95 y232 w160 h20 , %t13%
    Gui, Settings: Add, Edit, x22 y229 w70 h20 vdeadColor gUpdateFlag, 000000
    Gui, Settings: Add, Text, x55 y262 w190 h20 , %t14%
    Gui, Settings: Add, Edit, x22 y259 w30 h20 vnormalImmunitySize gUpdateFlag, 4
    Gui, Settings: Add, Text, x55 y282 w190 h20 , %t15%
    Gui, Settings: Add, Edit, x22 y279 w30 h20 vuniqueImmunitySize gUpdateFlag, 11
    Gui, Settings: Add, Link, x95 y418 w200 h20 , Click <a href="https://htmlcolorcodes.com">here</a> for a HEX color chart

    Gui, Settings: Tab, Immunities
    Gui, Settings: Font, S8 CGray, 
    Gui, Settings: Add, GroupBox, x11 y59 w340 h170 ,  %gb4%
    Gui, Settings: Font, S8 CDefault, 
    Gui, Settings: Add, CheckBox, x22 y79 w210 h20 vshowImmunities gUpdateFlag, %cb9%
    Gui, Settings: Add, Text, x95 y102 w140 h20 , %t16%
    Gui, Settings: Add, Edit, x22 y99 w70 h20 vphysicalImmuneColor gUpdateFlag, CD853F
    Gui, Settings: Add, Text, x95 y122 w140 h20 , %t17%
    Gui, Settings: Add, Edit, x22 y119 w70 h20 vmagicImmuneColor gUpdateFlag, FF8800
    Gui, Settings: Add, Text, x95 y142 w140 h20 , %t18%
    Gui, Settings: Add, Edit, x22 y139 w70 h20 vfireImmuneColor gUpdateFlag, FF0000
    Gui, Settings: Add, Text, x95 y162 w140 h20 , %t19%
    Gui, Settings: Add, Edit, x22 y159 w70 h20 vlightImmuneColor gUpdateFlag, FFFF00
    Gui, Settings: Add, Text, x95 y182 w140 h20 , %t20%
    Gui, Settings: Add, Edit, x22 y179 w70 h20 vcoldImmuneColor gUpdateFlag, 0000FF
    Gui, Settings: Add, Text, x95 y202 w140 h20 , %t21%
    Gui, Settings: Add, Edit, x22 y199 w70 h20 vpoisonImmuneColor gUpdateFlag, 32CD32
    Gui, Settings: Add, Link, x95 y418 w200 h20 , Click <a href="https://htmlcolorcodes.com">here</a> for a HEX color chart

    Gui, Settings: Tab, Item Filter
    Gui, Settings: Font, S8 CGray, 
    Gui, Settings: Add, GroupBox, x11 y59 w340 h90 ,  %gb5%
    Gui, Settings: Font, S8 CDefault, 
    Gui, Settings: Add, CheckBox, x22 y79 w270 h20 vEnableItemFilter gUpdateFlag, %cb10%
    Gui, Settings: Add, CheckBox, x22 y99 w270 h20 vallowItemDropSounds gUpdateFlag, %cb11%
    Gui, Settings: Add, CheckBox, x22 y119 w270 h20 vallowTextToSpeech gUpdateFlag, %cb12%
    Gui, Settings: Font, S8 CGray, 
    Gui, Settings: Add, GroupBox, x11 y159 w340 h90 ,  %gb6%
    Gui, Settings: Font, S8 CDefault, 
    Gui, Settings: Add, Text, x55 y200 w200 h20 , %t22%
    Gui, Settings: Add, Edit, x22 y197 w30 h20 vtextToSpeechPitch gUpdateFlag, 1
    Gui, Settings: Add, Text, x55 y180 w200 h20 , %t23%
    Gui, Settings: Add, Edit, x22 y177 w30 h20 vtextToSpeechVolume gUpdateFlag, 50
    Gui, Settings: Add, Text, x55 y220 w200 h20 , %t24%
    Gui, Settings: Add, Edit, x22 y217 w30 h20 vtextToSpeechSpeed gUpdateFlag, 1
    Gui, Settings: Add, Edit, x11 y263 w340 h130 vAlertListText ReadOnly gUpdateFlag, %t44%
    Gui, Settings: Add, Link, x95 y418 w200 h20 , Click <a href="https://github.com/joffreybesos/d2r-mapview/wiki/Item-filter-configuration">here</a> for the wiki on item filter

    Gui, Settings: Tab, Other
    Gui, Settings: Font, S8 CGray, 
    Gui, Settings: Add, GroupBox, x11 y59 w340 h110 ,  %gb7%
    Gui, Settings: Font, S8 CDefault, 
    Gui, Settings: Add, CheckBox, x22 y79 w270 h20 vshowWaypointLine gUpdateFlag, %cb13%
    Gui, Settings: Add, CheckBox, x22 y99 w270 h20 vshowNextExitLine gUpdateFlag, %cb14%
    Gui, Settings: Add, CheckBox, x22 y119 w270 h20 vshowBossLine gUpdateFlag, %cb15%
    Gui, Settings: Add, CheckBox, x22 y139 w270 h20 vshowQuestLine gUpdateFlag, %cb16%
    
    Gui, Settings: Font, S8 CGray, 
    Gui, Settings: Add, GroupBox, x11 y175 w340 h90,  %gb8%
    Gui, Settings: Font, S8 CDefault, 
    Gui, Settings: Add, CheckBox, x22 y215 w110 h20 vshowEnemyMissiles gUpdateFlag, %cb17%
    Gui, Settings: Add, CheckBox, x22 y195 w110 h20 vshowPlayerMissiles gUpdateFlag, %cb18%
    Gui, Settings: Add, Text, x195 y198 w140 h20 , %t25%
    Gui, Settings: Add, Edit, x162 y195 w30 h20 vmissileMajorDotSize gUpdateFlag, 4
    Gui, Settings: Add, Text, x195 y218 w140 h20 , %t26%
    Gui, Settings: Add, Edit, x162 y215 w30 h20 vmissileMinorDotSize gUpdateFlag, 2
    Gui, Settings: Add, Text, x197 y238 w140 h25 , %t27%
    Gui, Settings: Add, Edit, x162 y235 w32 h20 vmissileOpacity gUpdateFlag, 0x77

    Gui, Settings: Tab, Advanced
    Gui, Settings: Font, S8 CGray, 
    Gui, Settings: Add, GroupBox, x11 y59 w340 h200 ,  %gb9%
    Gui, Settings: Font, S8 CDefault, 
    Gui, Settings: Add, Text, x65 y82 w250 h18 , %t28%
    Gui, Settings: Add, Edit, x22 y79 w40 h20 vperformanceMode gUpdateFlag, 50ms
    Gui, Settings: Font, S7 CGray, 
    Gui, Settings: Add, Text, x22 y99 w320 h40 , %t29%

    Gui, Settings: Font, S8 CDefault, 
    Gui, Settings: Add, CheckBox, x22 y128 w250 h20 venablePrefetch gUpdateFlag, %cb19%
    Gui, Settings: Font, S7 CGray, 
    Gui, Settings: Add, Text, x22 y148 w320 h20 , %t30%

    Gui, Settings: Font, S8 CDefault, 
    Gui, Settings: Add, CheckBox, x22 y169 w250 h20 venableD2ML gUpdateFlag, %cb20%
    Gui, Settings: Add, Text, x145 y192 w250 h18 , %t31%
    Gui, Settings: Add, Edit, x22 y189 w120 h20 vwindowTitle gUpdateFlag, D2R:main
    Gui, Settings: Font, S7 CGray, 
    Gui, Settings: Add, Text, x22 y209 w320 h30 , %t32%

    Gui, Settings: Font, S8 CGray, 
    Gui, Settings: Add, GroupBox, x11 y269 w340 h80 ,  %gb10%
    Gui, Settings: Font, S8 CDefault, 
    Gui, Settings: Add, CheckBox, x22 y289 w200 h20 vdebug gUpdateFlag, %cb21%
    Gui, Settings: Font, S7 CGray, 
    Gui, Settings: Add, Text, x22 y309 w320 h30 , %t33%
    Gui, Settings: Font, S8 CDefault,
    
    Gui, Settings: Tab, Hotkeys
    Gui, Settings: Font, S8 CGray, 
    Gui, Settings: Add, GroupBox, x11 y59 w340 h220 ,  %gb11%
    Gui, Settings: Font, S8 CDefault, 
    Gui, Settings: Tab, Hotkeys
    Gui, Settings: Add, Text, x115 y82 w200 h20 , %t34%
    Gui, Settings: Add, Edit, x22 y79 w90 h20 vincreaseMapSizeKey gUpdateFlag, 
    Gui, Settings: Add, Text, x115 y102 w200 h20 , %t35%
    Gui, Settings: Add, Edit, x22 y99 w90 h20 vdecreaseMapSizeKey gUpdateFlag, 
    Gui, Settings: Add, Text, x115 y122 w200 h20 , %t36%
    Gui, Settings: Add, Edit, x22 y119 w90 h20 vmoveMapLeft gUpdateFlag, 
    Gui, Settings: Add, Text, x115 y142 w200 h20 , %t37%
    Gui, Settings: Add, Edit, x22 y139 w90 h20 vmoveMapRight gUpdateFlag, 
    Gui, Settings: Add, Text, x115 y162 w200 h20 , %t38%
    Gui, Settings: Add, Edit, x22 y159 w90 h20 vmoveMapUp gUpdateFlag, 
    Gui, Settings: Add, Text, x115 y182 w200 h20 , %t39%
    Gui, Settings: Add, Edit, x22 y179 w90 h20 vmoveMapDown gUpdateFlag, 
    Gui, Settings: Add, Text, x115 y202 w200 h20 , %t40%
    Gui, Settings: Add, Edit, x22 y199 w90 h20 vhistoryToggleKey gUpdateFlag, 
    Gui, Settings: Add, Text, x115 y222 w200 h20 , %t41%
    Gui, Settings: Add, Edit, x22 y219 w90 h20 valwaysShowKey gUpdateFlag, 
    Gui, Settings: Add, Text, x115 y242 w200 h20 , %t42%
    Gui, Settings: Add, Edit, x22 y239 w90 h20 vswitchMapMode gUpdateFlag, 

    Gui, Settings: Add, Text, x22 y282 w300 h20 , %t43%
    Gui, Settings: Add, Link, x95 y418 w200 h20 , Click <a href="https://www.autohotkey.com/docs/KeyList.htm">here</a> for possible key combos

    Gui, Settings: Tab, Info
    Gui, Settings: Font, S26 CRed,    
    Gui, Settings:Add, Text, x30 y75 w300 h50 +Center, d2r-mapview
    Gui, Settings:Font, S12 CDefault
    
    Gui, Settings:Add, Text, x25 y135 w300 h120 +Center, %uitext%
    
    Gui, Settings:Font, S16 CDefault
    Gui, Settings:Add, Link, x70 y380 w120 h30 +Center, <a href="https://github.com/joffreybesos/d2r-mapview#readme">GitHub</a>
    Gui, Settings:Add, Link, x240 y380 w120 h30 +Center, <a href="https://discord.com/invite/qEgqyVW3uj">Discord</a>

    settingupGUI := true
    ;Gui, Settings: Show, h482 w362, d2r-mapview settings
    tabtitles := StrReplace(tabtitles, settings["lastActiveGUITab"], settings["lastActiveGUITab"] "|")
    GuiControl, Settings:, TabList, % "|" tabtitles
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
    GuiControl, Settings:, playerAsCross, % settings["playerAsCross"]
    GuiControl, Settings:, showOtherPlayers, % settings["showOtherPlayers"]
    GuiControl, Settings:, showOtherPlayerNames, % settings["showOtherPlayerNames"]
    GuiControl, Settings:, showShrines, % settings["showShrines"]
    GuiControl, Settings:, showPortals, % settings["showPortals"]
    GuiControl, Settings:, showChests, % settings["showChests"]

    GuiControl, Settings:, enableItemFilter, % settings["enableItemFilter"]
    GuiControl, Settings:, allowTextToSpeech, % settings["allowTextToSpeech"]
    GuiControl, Settings:, textToSpeechVolume, % settings["textToSpeechVolume"]
    GuiControl, Settings:, textToSpeechPitch, % settings["textToSpeechPitch"]
    GuiControl, Settings:, textToSpeechSpeed, % settings["textToSpeechSpeed"]
    GuiControl, Settings:, allowItemDropSounds, % settings["allowItemDropSounds"]

    GuiControl, Settings:, bossColor, % settings["bossColor"]
    ; GuiControl, Settings:, mercColor, % settings["mercColor"]
    GuiControl, Settings:, deadColor, % settings["deadColor"]
    ; GuiControl, Settings:, showMercs, % settings["showMercs"]

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
    GuiControl, Settings:, enablePrefetch, % settings["enablePrefetch"]
    GuiControl, Settings:, enableD2ML, % settings["enableD2ML"]
    GuiControl, Settings:, windowTitle, % settings["windowTitle"]
    GuiControl, Settings:, debug, % settings["debug"]

    GuiControl, Settings:, showPlayerMissiles, % settings["showPlayerMissiles"]
    GuiControl, Settings:, showEnemyMissiles, % settings["showEnemyMissiles"]
    GuiControl, Settings:, missileOpacity, % settings["missileOpacity"]
    ; GuiControl, Settings:, missileColorPhysicalMajor, % settings["missileColorPhysicalMajor"]
    ; GuiControl, Settings:, missileColorPhysicalMinor, % settings["missileColorPhysicalMinor"]
    ; GuiControl, Settings:, missileFireMajorColor, % settings["missileFireMajorColor"]
    ; GuiControl, Settings:, missileFireMinorColor, % settings["missileFireMinorColor"]
    ; GuiControl, Settings:, missileIceMajorColor, % settings["missileIceMajorColor"]
    ; GuiControl, Settings:, missileIceMinorColor, % settings["missileIceMinorColor"]
    ; GuiControl, Settings:, missileLightMajorColor, % settings["missileLightMajorColor"]
    ; GuiControl, Settings:, missileLightMinorColor, % settings["missileLightMinorColor"]
    ; GuiControl, Settings:, missilePoisonMajorColor, % settings["missilePoisonMajorColor"]
    ; GuiControl, Settings:, missilePoisonMinorColor, % settings["missilePoisonMinorColor"]
    ; GuiControl, Settings:, missileMagicMajorColor, % settings["missileMagicMajorColor"]
    ; GuiControl, Settings:, missileMagicMinorColor, % settings["missileMagicMinorColor"]

    GuiControl, Settings:, missileMajorDotSize, % settings["missileMajorDotSize"]
    GuiControl, Settings:, missileMinorDotSize, % settings["missileMinorDotSize"]
    if (itemAlertList) {
        GuiControl, Settings:, AlertListText, % itemAlertList.toString()
    }
    
    Return

}


UpdateSettings(ByRef settings, defaultSettings) {

    ; stupid ahk doesn't let me update the array value directly here
    ; so I have to save to a variable and THEN update the settings array
    ; ugh

    ; this just gets all the values of all the gui elements
    GuiControlGet, TabList, ,TabList
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
    GuiControlGet, playerAsCross, ,playerAsCross
    GuiControlGet, showOtherPlayers, ,showOtherPlayers
    GuiControlGet, showOtherPlayerNames, ,showOtherPlayerNames
    GuiControlGet, showShrines, ,showShrines
    GuiControlGet, showPortals, ,showPortals
    GuiControlGet, showChests, ,showChests
    
    GuiControlGet, enableItemFilter, ,enableItemFilter
    GuiControlGet, allowTextToSpeech, ,allowTextToSpeech
    GuiControlGet, textToSpeechVolume, ,textToSpeechVolume
    GuiControlGet, textToSpeechPitch, ,textToSpeechPitch
    GuiControlGet, textToSpeechSpeed, ,textToSpeechSpeed
    GuiControlGet, allowItemDropSounds, ,allowItemDropSounds

    GuiControlGet, normalMobColor, ,normalMobColor
    GuiControlGet, uniqueMobColor, ,uniqueMobColor
    GuiControlGet, bossColor, ,bossColor
    ; GuiControlGet, mercColor, ,mercColor
    GuiControlGet, deadColor, ,deadColor
    ; GuiControlGet, showMercs, ,showMercs
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
    GuiControlGet, portalColor, ,portalColor
    GuiControlGet, redPortalColor, ,redPortalColor
    GuiControlGet, shrineColor, ,shrineColor
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
    GuiControlGet, enablePrefetch, ,enablePrefetch
    GuiControlGet, enableD2ML, ,enableD2ML
    GuiControlGet, windowTitle, ,windowTitle
    GuiControlGet, debug, ,debug
    GuiControlGet, showPlayerMissiles, ,showPlayerMissiles
    GuiControlGet, showEnemyMissiles, ,showEnemyMissiles
    GuiControlGet, missileOpacity, ,missileOpacity
    ; missile colors don't exist in the GUI
    ; GuiControlGet, missileColorPhysicalMajor, ,missileColorPhysicalMajor
    ; GuiControlGet, missileColorPhysicalMinor, ,missileColorPhysicalMinor
    ; GuiControlGet, missileFireMajorColor, ,missileFireMajorColor
    ; GuiControlGet, missileFireMinorColor, ,missileFireMinorColor
    ; GuiControlGet, missileIceMajorColor, ,missileIceMajorColor
    ; GuiControlGet, missileIceMinorColor, ,missileIceMinorColor
    ; GuiControlGet, missileLightMajorColor, ,missileLightMajorColor
    ; GuiControlGet, missileLightMinorColor, ,missileLightMinorColor
    ; GuiControlGet, missilePoisonMajorColor, ,missilePoisonMajorColor
    ; GuiControlGet, missilePoisonMinorColor, ,missilePoisonMinorColor
    ; GuiControlGet, missileMagicMajorColor, ,missileMagicMajorColor
    ; GuiControlGet, missileMagicMinorColor, ,missileMagicMinorColor
    GuiControlGet, missileMajorDotSize, ,missileMajorDotSize
    GuiControlGet, missileMinorDotSize, ,missileMinorDotSize

    WinGetPos, settingsUIX, settingsUIY, , , d2r-mapview settings
    
    settings["settingsUIX"] := settingsUIX
    settings["settingsUIY"] := settingsUIY
    settings["lastActiveGUITab"] := TabList
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
    settings["playerAsCross"] := playerAsCross
    settings["showOtherPlayers"] := showOtherPlayers
    settings["showOtherPlayerNames"] := showOtherPlayerNames
    settings["showShrines"] := showShrines
    settings["showPortals"] := showPortals
    settings["showChests"] := showChests

    settings["enableItemFilter"] := enableItemFilter
    settings["allowTextToSpeech"] := allowTextToSpeech
    settings["textToSpeechVolume"] := textToSpeechVolume
    settings["textToSpeechPitch"] := textToSpeechPitch
    settings["textToSpeechSpeed"] := textToSpeechSpeed
    settings["allowItemDropSounds"] := allowItemDropSounds
    settings["normalMobColor"] := normalMobColor
    settings["uniqueMobColor"] := uniqueMobColor
    settings["bossColor"] := bossColor
    ; settings["mercColor"] := mercColor
    settings["deadColor"] := deadColor
    ; settings["showMercs"] := showMercs

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
    settings["portalColor"] := portalColor
    settings["redPortalColor"] := redPortalColor
    settings["shrineColor"] := shrineColor
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
    settings["enablePrefetch"] := enablePrefetch
    settings["enableD2ML"] := enableD2ML
    settings["windowTitle"] := windowTitle
    settings["debug"] := debug

    settings["showPlayerMissiles"] := showPlayerMissiles
    settings["showEnemyMissiles"] := showEnemyMissiles
    settings["missileOpacity"] := missileOpacity
    ; settings["missileColorPhysicalMajor"] := missileColorPhysicalMajor
    ; settings["missileColorPhysicalMinor"] := missileColorPhysicalMinor
    ; settings["missileFireMajorColor"] := missileFireMajorColor
    ; settings["missileFireMinorColor"] := missileFireMinorColor
    ; settings["missileIceMajorColor"] := missileIceMajorColor
    ; settings["missileIceMinorColor"] := missileIceMinorColor
    ; settings["missileLightMajorColor"] := missileLightMajorColor
    ; settings["missileLightMinorColor"] := missileLightMinorColor
    ; settings["missilePoisonMajorColor"] := missilePoisonMajorColor
    ; settings["missilePoisonMinorColor"] := missilePoisonMinorColor
    ; settings["missileMagicMajorColor"] := missileMagicMajorColor
    ; settings["missileMagicMinorColor"] := missileMagicMinorColor

    settings["missileMajorDotSize"] := missileMajorDotSize
    settings["missileMinorDotSize"] := missileMinorDotSize


    saveSettings(settings, defaultSettings)
    
}


saveSettings(settings, defaultSettings) {
    writeIniVar("settingsUIX", settings, defaultsettings)
    writeIniVar("settingsUIY", settings, defaultsettings)
    writeIniVar("lastActiveGUITab", settings, defaultsettings)
    writeIniVar("locale", settings, defaultsettings)
    writeIniVar("baseUrl", settings, defaultsettings)
    writeIniVar("scale", settings, defaultsettings)
    writeIniVar("leftMargin", settings, defaultsettings)
    writeIniVar("topMargin", settings, defaultsettings)
    writeIniVar("opacity", settings, defaultsettings)
    writeIniVar("alwaysShowMap", settings, defaultsettings)
    writeIniVar("hideTown", settings, defaultsettings)
    writeIniVar("edges", settings, defaultsettings)
    writeIniVar("wallThickness", settings, defaultsettings)
    writeIniVar("centerMode", settings, defaultsettings)
    writeIniVar("centerModeScale", settings, defaultsettings)
    writeIniVar("serverScale", settings, defaultsettings)
    writeIniVar("centerModeOpacity", settings, defaultsettings)
    writeIniVar("centerModeXoffset", settings, defaultsettings)
    writeIniVar("centerModeYoffset", settings, defaultsettings)
    writeIniVar("centerModeXUnitoffset", settings, defaultsettings)
    writeIniVar("centerModeYUnitoffset", settings, defaultsettings)
    writeIniVar("showGameInfo", settings, defaultsettings)
    writeIniVar("textSectionWidth", settings, defaultsettings)
    writeIniVar("textSize", settings, defaultsettings)
    writeIniVar("textAlignment", settings, defaultsettings)
    writeIniVar("showAllHistory", settings, defaultsettings)
    writeIniVar("showIPtext", settings, defaultsettings)
    writeIniVar("textIPfontSize", settings, defaultsettings)
    writeIniVar("textIPalignment", settings, defaultsettings)
    writeIniVar("showNormalMobs", settings, defaultsettings)
    writeIniVar("showUniqueMobs", settings, defaultsettings)
    writeIniVar("showBosses", settings, defaultsettings)
    writeIniVar("showDeadMobs", settings, defaultsettings)
    writeIniVar("showImmunities", settings, defaultsettings)
    writeIniVar("showPlayerDotCenter", settings, defaultsettings)
    writeIniVar("playerAsCross", settings, defaultsettings)
    writeIniVar("showOtherPlayers", settings, defaultsettings)
    writeIniVar("showOtherPlayerNames", settings, defaultsettings)
    writeIniVar("showShrines", settings, defaultsettings)
    writeIniVar("showPortals", settings, defaultsettings)

    writeIniVar("allowTextToSpeech", settings, defaultsettings)
    writeIniVar("textToSpeechVolume", settings, defaultsettings)
    writeIniVar("textToSpeechPitch", settings, defaultsettings)
    writeIniVar("textToSpeechSpeed", settings, defaultsettings)
    writeIniVar("allowItemDropSounds", settings, defaultsettings)
    writeIniVar("showUniqueAlerts", settings, defaultsettings)
    writeIniVar("showSetItemAlerts", settings, defaultsettings)
    writeIniVar("showRuneAlerts", settings, defaultsettings)
    writeIniVar("showJewelAlerts", settings, defaultsettings)
    writeIniVar("showCharmAlerts", settings, defaultsettings)
    writeIniVar("showBaseItems", settings, defaultsettings)
    writeIniVar("normalMobColor", settings, defaultsettings)
    writeIniVar("uniqueMobColor", settings, defaultsettings)
    writeIniVar("bossColor", settings, defaultsettings)
    ; writeIniVar("mercColor", settings, defaultsettings)
    writeIniVar("deadColor", settings, defaultsettings)
    ; writeIniVar("showMercs", settings, defaultsettings)

    writeIniVar("normalDotSize", settings, defaultsettings)
    writeIniVar("normalImmunitySize", settings, defaultsettings)
    writeIniVar("uniqueDotSize", settings, defaultsettings)
    writeIniVar("uniqueImmunitySize", settings, defaultsettings)
    writeIniVar("deadDotSize", settings, defaultsettings)
    writeIniVar("bossDotSize", settings, defaultsettings)
    writeIniVar("physicalImmuneColor", settings, defaultsettings)
    writeIniVar("magicImmuneColor", settings, defaultsettings)
    writeIniVar("fireImmuneColor", settings, defaultsettings)
    writeIniVar("lightImmuneColor", settings, defaultsettings)
    writeIniVar("coldImmuneColor", settings, defaultsettings)
    writeIniVar("poisonImmuneColor", settings, defaultsettings)
    writeIniVar("runeItemColor", settings, defaultsettings)
    writeIniVar("uniqueItemColor", settings, defaultsettings)
    writeIniVar("setItemColor", settings, defaultsettings)
    writeIniVar("charmItemColor", settings, defaultsettings)
    writeIniVar("jewelItemColor", settings, defaultsettings)
    writeIniVar("portalColor", settings, defaultsettings)
    writeIniVar("redPortalColor", settings, defaultsettings)
    writeIniVar("shrineColor", settings, defaultsettings)
    writeIniVar("baseItemColor", settings, defaultsettings)
    writeIniVar("shrineTextSize", settings, defaultsettings)
    writeIniVar("showWaypointLine", settings, defaultsettings)
    writeIniVar("showNextExitLine", settings, defaultsettings)
    writeIniVar("showBossLine", settings, defaultsettings)
    writeIniVar("showQuestLine", settings, defaultsettings)


    writeIniVar("increaseMapSizeKey", settings, defaultsettings)
    writeIniVar("decreaseMapSizeKey", settings, defaultsettings)
    writeIniVar("alwaysShowKey", settings, defaultsettings)
    writeIniVar("moveMapLeft", settings, defaultsettings)
    writeIniVar("moveMapRight", settings, defaultsettings)
    writeIniVar("moveMapUp", settings, defaultsettings)
    writeIniVar("moveMapDown", settings, defaultsettings)
    writeIniVar("switchMapMode", settings, defaultsettings)
    writeIniVar("historyToggleKey", settings, defaultsettings)
    writeIniVar("enablePrefetch", settings, defaultsettings)
    writeIniVar("performanceMode", settings, defaultsettings)
    writeIniVar("enableD2ML", settings, defaultsettings)
    writeIniVar("windowTitle", settings, defaultsettings)
    writeIniVar("debug", settings, defaultsettings)

    writeIniVar("showPlayerMissiles", settings, defaultsettings)
    writeIniVar("showEnemyMissiles", settings, defaultsettings)
    writeIniVar("missileOpacity", settings, defaultsettings)
    writeIniVar("missileColorPhysicalMajor", settings, defaultsettings)
    writeIniVar("missileColorPhysicalMinor", settings, defaultsettings)
    ; writeIniVar("missileFireMajorColor", settings, defaultsettings)
    ; writeIniVar("missileFireMinorColor", settings, defaultsettings)
    ; writeIniVar("missileIceMajorColor", settings, defaultsettings)
    ; writeIniVar("missileIceMinorColor", settings, defaultsettings)
    ; writeIniVar("missileLightMajorColor", settings, defaultsettings)
    ; writeIniVar("missileLightMinorColor", settings, defaultsettings)
    ; writeIniVar("missilePoisonMajorColor", settings, defaultsettings)
    ; writeIniVar("missilePoisonMinorColor", settings, defaultsettings)
    ; writeIniVar("missileMagicMajorColor", settings, defaultsettings)
    ; writeIniVar("missileMagicMinorColor", settings, defaultsettings)

    writeIniVar("missileMajorDotSize", settings, defaultsettings)
    writeIniVar("missileMinorDotSize", settings, defaultsettings)
}

writeIniVar(valname, settings, defaultsettings) {
    if (settings[valname] != defaultsettings[valname]) {
        ;WriteLog("Updating setting '" valname "' with " settings[valname])
        IniWrite, % settings[valname], settings.ini, Settings, %valname%
    } else {
        IniDelete, settings.ini, Settings , %valname%
    }
}
