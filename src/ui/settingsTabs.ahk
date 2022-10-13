
OpacitySlide(){
    GuiControlGet, Opac
    GuiControl, , missileOpacity, % Format("0x{:X}", Opac)
    SettingsUpdateFlag()
}

PathSlide(){
    GuiControlGet, PathcolorSlide
    GuiControl, , pathFindingColour, % RGB300(PathcolorSlide)
    SettingsUpdateFlag()
}

Colorslide(){
    Gui, Settings:Default
    lastformat:=A_FormatInteger
    SetFormat, IntegerFast, Hex
    GuiControlGet, SliderRed
    GuiControlGet, SliderGreen
    GuiControlGet, SliderBlue
    
    if StrLen(R:=Strip0x(ConvertD2H(SliderRed))) < 2
        R:=0 R
    if StrLen(G:=Strip0x(ConvertD2H(SliderGreen))) < 2
        G:=0 G
    if StrLen(B:=Strip0x(ConvertD2H(SliderBlue))) < 2
        B:=0 B
    StringUpper, R, R
    StringUpper, G, G
    StringUpper, B, B
    SetFormat, IntegerFast, hex
    if selected:=RadioSelect(Projectilelist()){
        GuiControl % "+Background" R G B , % selected "preview" 

        misslecontrol:="missile" selected "Color"
        OutputDebug, % rcheck:=selected "Rcheck"
        colorRGB:="+c" R G B
        GuiControl % colorRGB , % rcheck
        GuiControl,, % rcheck , % selected

        GuiControl % colorRGB , % misslecontrol
        GuiControl, , % misslecontrol, % R G B
    }
     SetFormat, IntegerFast, % lastformat
    SettingsUpdateFlag()
}

RadioToSliders(){
    GuiControlGet, RBG,, % "missile" RadioSelect(Projectilelist()) "Color"
    GuiControl,, SliderRed , % R:=(R:="0x" SubStr(RBG, 1, 2))+0 
    GuiControl,, SliderGreen , % G:=(G:="0x" SubStr(RBG, 3, 2))+0 
    GuiControl,, SliderBlue , % B:=(B:="0x" SubStr(RBG, 5, 2))+0
    SettingsUpdateFlag()
}



RadioSelect(Rlist){
    lastformat:=A_FormatInteger
    for each,Radio in (Rlist)
    {   
        Selected = %Radio%Rcheck
        GuiControlGet,controlvar,, %Selected%
        if (controlvar)
        {
            SetFormat, integer, D
            Selected:=RegExReplace(Selected,"(.*)Rcheck$","$1")
            SetFormat, integer, % lastformat
            return Selected
        }
    }
}

DiscordLink(){
    run, % "https://discord.com/invite/qEgqyVW3uj"
}
ReadMeLink(){
    run, % "https://github.com/joffreybesos/d2r-mapview#readme"
}

Projectilelist(){
    return ["PhysicalMajor","PhysicalMinor","FireMajor","FireMinor","IceMajor","IceMinor"
    ,"LightMajor","LightMinor","PoisonMajor","PoisonMinor","MagicMajor","MagicMinor"]
}

TabTitles(){
    return "Info|General|Map Items|Game Data|NPCs|Immunities|Item Filter|Hotkeys|Other|Projectiles|Advanced"
}

SettingDefault(setting){
    return (settings[setting]?settings[setting]:defaultSettings[setting])
}

SettingsTabInfo(x,y){
    global
    Gui, Settings:+labelSettings
    Gui, Settings:Default
    Gui, Tab, Info
    local (InfoX:=x) , (InfoY:=y)

    Gui, Add, Picture, % "x" (InfoX-20) " y" 59 " w" 370 " h" 320, % settings.SplashImg
    ;Gui, Add, Text, %  "c" 0xff0000 " x" (SettingsAnchorX+20) " y" (InfoY+=20) " w" 300 " h" 250 " +Center Backgroundtrans", d2r-mapview %version%

    ;Gui, Add, Text, %  "c" UniqueColor " x" (SettingsAnchorX+15) " y" (InfoY+=56) " w" 300 " h" 120 " +Center Backgroundtrans", % localizedStrings["uitext"] ;what is this?
    local locale := settings["locale"]
    local choiceIdx := LocaleToChoice(locale)
    Gui, Add, Button, % "x" (SettingsAnchorX+90) " y" (SettingsAnchorY+311) " h" 23 "Backgroundtrans AltSubmit vRevertDefaults gRevertToDefaults", Default All Settings
    Gui, Add, DropDownList, % "x" (SettingsAnchorX+220) " y" (SettingsAnchorY+311) " h" 180 (" Choose" choiceIdx) "Backgroundtrans AltSubmit  vlocaleIdx gSettingsUpdateFlag", English|中文|Deutsch|español|français|italiano|한국어|polski|español mexicano|日本語|português|Русский|福佬話
    Gui, Font, % "s" SettingsD2RFontSize
    Gui, Add, Link, % " c" 0x00FF00 " x" (SettingsAnchorX) " y" (SettingsAnchorY+339) " w" 100 " h" 30 "  gReadMeLink", <A>Github</A>
    Gui, Add, Link, % "c" 0xff0000 " x" (SettingsAnchorX+130) " y" (SettingsAnchorY+339) " w"100 " h" 30 "  gDiscordLink", <A>v%version%</A>
    Gui, Add, Link, % " c" 0x00FF00 " x" (SettingsAnchorX+260) " y" (SettingsAnchorY+339) " w"100 " h" 30 "  gDiscordLink", <A>Discord</A>
    Gui, Font, % "s" SettingFontsize1
}

SettingsTabGeneral(x,y){
        global
        Gui, Settings:Default
        Gui, Tab, General
            local (mapserverX:=x),(mapserverY:=y),(mapserverW:=),(mapserverH:=),(mapserverW:=20),(mapserverH:=20)
        Gui, Add, GroupBox, % "c" UniqueColor " x" mapserverX " y" mapserverY " w" 340 " h" 80 , % localizedStrings["s3"] ;mapserver
            Gui, Add, Edit, % "c" EditColor " x" (mapserverX+=18) " y" (mapserverY+=20) " w300 vBaseUrl gSettingsUpdateFlag" , settings.baseUrl
            Gui, Add, Text, %  "c" disabledfont " x" (mapserverX+=1) " y" (mapserverY+=25) " w180" , % "Ex: http://localhost:3002`nhttp://192.168.1.123:3002"

            local (MapPosX:=SettingsAnchorX), (MapPosY:=mapserverY+71), (MapPosW:=0), (MapPosH:=0)
        Gui, Add, GroupBox, % "c" UniqueColor " x" MapPosX " y" MapPosY " w340 h80", % MapPos:="Map Position"
            Gui, Add, DropDownList, % "x" (MapPosX+10) " y" (MapPosY+20) " w" 140 " h" 80 " vmapPosition gSettingsUpdateFlag",
        Gui, Add, Checkbox, % "c" UniqueColor " x" (MapPosX+180) " y" (MapPosY+25) " w" 135 " h" 20 " vAlwaysShowMap gSettingsUpdateFlag", % "Always show map"
        Gui, Add, Checkbox, % "c" UniqueColor " x" (MapPosX+10) " y" (MapPosY+45) " w" 135 " h" 20 " vHideTown gSettingsUpdateFlag", % "Hide town maps"

            local (CenPosX:=SettingsAnchorX), (CenPosY:=MapPosY+85), (CenPosW:=), (CenPosH:=)
        Gui, Add, GroupBox, % "c" UniqueColor " x" CenPosX " y" CenPosY " w" 340 " h" 80, % "Centered position settings"
            local (CenCol4:=(CenCol3:=(CenCol2:=(CenCol1:=CenPosX+10)+50)+115)+50)
        local (CenRow4:=(CenRow3:=(CenRow2:=(CenRow1:=CenPosY+20)+5)+15)+5)
        Gui, Add, Edit, % "c" EditColor " x" CenCol1 " y" CenRow1 " w" 44 " h" 20 " vcenterModeScale gSettingsUpdateFlag"
        Gui, Add, Edit, % "c" EditColor " x" CenCol1 " y" CenRow3 " w" 44 " h" 20 " vcenterModeOpacity gSettingsUpdateFlag"
        Gui, Add, Text, %  "c" UniqueColor " x" CenCol2 " y" CenRow2 " w" 80 " h" 15, % "Centered Scale"
        Gui, Add, Text, %  "c" UniqueColor " x" CenCol2 " y" CenRow4 " w" 80 " h" 15, % "Center Opacity (0-1)"
        Gui, Add, Edit, % "c" EditColor " x" CenCol3 " y" CenRow1 " w" 44 " h" 20 " vcenterModeOffsetX gSettingsUpdateFlag"
        Gui, Add, Edit, % "c" EditColor " x" CenCol3 " y" CenRow3 " w" 44 " h" 20 " vcenterModeOffsetY gSettingsUpdateFlag"
        Gui, Add, Text, %  "c" UniqueColor " x" CenCol4 " y" CenRow2 " w" 80 " h" 15, % "X offset"
        Gui, Add, Text, %  "c" UniqueColor " x" CenCol4 " y" CenRow4 " w" 80 " h" 15, % "Y offset"

            local (CorPosX:=SettingsAnchorX), (CorPosY:=CenRow4)
        Gui, Add, GroupBox, % "c" UniqueColor " x" CorPosX " y" (CorPosY+40) " w" 340 " h" 80, % "Corner position settings"
            local (CorCol4:=(CorCol3:=(CorCol2:=(CorCol1:=CorPosX+10)+50)+115)+50)
        local (CorRow4:=(CorRow3:=(CorRow2:=(CorRow1:=CorPosY+60)+5)+15)+5)
        Gui, Add, Edit, % "c" EditColor " x" CorCol1 " y" CorRow1 " w" 44 " h" 20 " vcornerModeScale gSettingsUpdateFlag"
        Gui, Add, Text, %  "c" UniqueColor " x" CorCol2 " y" CorRow2 " w" 80 " h" 15, % "Corner Scale"
        Gui, Add, Edit, % "c" EditColor " x" CorCol1 " y" CorRow3 " w" 44 " h20 vcornerModeOpacity gSettingsUpdateFlag"
        Gui, Add, Text, %  "c" UniqueColor " x" CorCol2 " y" CorRow4 " w" 80 " h" 15, % "Corner Opacity (0-1)"
        Gui, Add, Edit, % "c" EditColor " x" CorCol3 " y" CorRow1 " w" 44 " h" 20 " vcornerModeOffsetX gSettingsUpdateFlag"
        Gui, Add, Text, %  "c" UniqueColor " x" CorCol4 " y" CorRow2 " w" 80 " h" 15, % "X offset"
        Gui, Add, Edit, % "c" EditColor " x" CorCol3 " y" CorRow3 " w" 44 " h" 20 " vcornerModeOffsetY gSettingsUpdateFlag"
        Gui, Add, Text, %  "c" UniqueColor " x" CorCol4 " y" CorRow4 " w" 80 " h" 15, % "Y offset"
}

SettingsTabMapItems(x,y){
    global
    Gui, Settings:Default
    Gui, Tab, Map Items
    local (MapItemX:=x),(MapItemY:=y)
    local (MapItemCol4:=(MapItemCol3:=(MapItemCol2:=(MapItemCol1:=MapItemX+12)+140)+53)+50)
    local (PortalRow4:=(PortalRow3:=(PortalRow2:=(PortalRow1:=y+20)+5)+15)+5) 
    Gui, Add, GroupBox, % "c" UniqueColor " x" MapItemX " y" MapItemY " w" 340 " h" (PortalsGroupH:=70), % localizedStrings["s25"]
    Gui, Add, Checkbox, % "c" UniqueColor " x" MapItemCol1 " y" PortalRow1 " w" 140 " h" 20 " vShowPortals gSettingsUpdateFlag", % localizedStrings["s26"] ;True
    Gui, Add, Edit, % " c" EditColor " x" (PortalColorx:=MapItemCol2) " y" (PortalColory:=PortalRow1) " w" (PortalColorwidth:=50) " h" 20 " vPortalColor gSettingsUpdateFlag", 00AAFF
    Gui, Add, Text, %  "c"  SettingDefault("PortalColor") " x" (PortalColorx+PortalColorwidth+5) " y" (PortalColory+3) " h" 20, % localizedStrings["s27"]
    Gui, Add, Edit, % "c" EditColor " x" (RPortalColorx:=MapItemCol2) " y" (RedPortalColory:=PortalRow1+20) " w" 50 " h" 20  " vRedPortalColor gSettingsUpdateFlag", FF0000
    Gui, Add, Text, %  "c" SettingDefault("RedPortalColor") " x" (RPortalColorx+PortalColorwidth+5) " y" (RedPortalColory+3) " h" 20, % localizedStrings["s28"]
    local ShrinesY:=(PortalRow1+PortalsGroupH+5)


    Gui, Add, GroupBox, % "c" UniqueColor " x" MapItemX " y" ShrinesY " w" 340 " h" PortalsGroupH , % localizedStrings["s29"]
    Gui, Font, % "s" SettingFontsize1 " C" UniqueColor, 
    local shrinerow2:=(shrinerow1:=ShrinesY+20)+20
    Gui, Add, Checkbox, % "c" UniqueColor " x" MapItemCol1 " y" (shrinerow1) " w" 140 " h" 20 " vShowShrines gSettingsUpdateFlag", % localizedStrings["s30"] ;True
    Gui, Add, Edit, % " c" EditColor " x" MapItemCol2 " y" shrinerow1 " w" 50 " h" 20 " vShrineColor gSettingsUpdateFlag", FFD700
    Gui, Add, Edit, % "c" EditColor " x" MapItemCol2 " y" shrinerow2 " w" 50 " h" 20 " vShrineTextSize gSettingsUpdateFlag", 14
    Gui, Add, Text, %  "c" SettingDefault("ShrineColor") " x" MapItemCol3 " y" (shrinerow2-17) " h" 20 , % localizedStrings["s31"]
    Gui, Add, Text, %  "c" UniqueColor " x" MapItemCol3 " y" (shrinerow2+3) " h" 20 , % localizedStrings["s32"]

    local ChestY:=(ShrinesY+PortalsGroupH+20)
    Gui, Add, GroupBox, % "c" UniqueColor " x" MapItemX " y" ChestY " w" 168 " h" (ChestH:=PortalsGroupH-20) ,  % localizedStrings["gb1"]
    Gui, Add, Checkbox, % "c" UniqueColor " x" MapItemCol1 " y" (ChestY+20) " w" 120 " h" 20 " vShowChests gSettingsUpdateFlag", % localizedStrings["cb1"]

    Gui, Add, GroupBox, % "c" UniqueColor " x" (MapItemCol2+20)" y" ChestY " w" 168 " h" 50 " ", % localizedStrings["gb18"]
    Gui, Add, Edit, % "c" EditColor " x" (MapItemCol2+25) " y" (ChestY+20) " w" 25 " h" 20 " vexitTextSize gSettingsUpdateFlag", 12
    Gui, Add, Text, %  "c" UniqueColor " x" (MapItemCol3) " y" (ChestY+23) " w" 90 " h" 20 " ", % localizedStrings["gb19"]

    local PathfindY:=(ChestY+ChestH+20)
    Gui, Add, GroupBox, % "c" UniqueColor " x" MapItemX " y" PathfindY " w" 340 " h" 70 " ", % "Pathfinding"
    Gui, Add, Checkbox, % "c" UniqueColor " x" MapItemCol1 " y" (PathfindY+20) " w" 120 " h" 20 " vshowPathFinding gSettingsUpdateFlag", % "Show pathfinding"

    Gui, Add, Edit, % "c" EditColor " x" MapItemCol2 " y" (PathfindY+18) " w" 60 " h" 20 " vpathFindingColour gSettingsUpdateFlag"
    Gui, Add, Text, %  "c" SettingDefault("pathFindingColour") " x" (MapItemCol3+10) " y" (PathfindY+20) " w" 90 " h" 20 " ", % "Pathfinding color"
    ;Gui, Add, Slider, % "x" (MapItemCol3+5) " y" (PathfindY+40) " h" 20 " w" 84 " vPathcolorSlide gPathSlide range0-300", 0
}

SettingsTabGameData(x,y){
    global
    Gui, Settings:Default
    Gui, Tab, Game Data
    {   ; Game History
            local (HistoryX:=x) , (HistoryY:=y)
        Gui, Add, GroupBox, % "c" UniqueColor " x" (HistoryX) " y" (HistoryY) " w" 340 " h" 115 " ",  % localizedStrings["gb2"]
        Gui, Add, Checkbox, % "c" UniqueColor " x" (HistoryX+12) " y" (HistoryY+20) " w" 270 " h" 20 " vshowGameHistory  gSettingsUpdateFlag", % localizedStrings["cb2"]
        Gui, Add, Checkbox, % "c" UniqueColor " x" (HistoryX+12) " y" (HistoryY+40) " w" 270 " h" 20 " vshowAllHistory gSettingsUpdateFlag", % localizedStrings["cb3"]
        Gui, Add, Text, %  "c" UniqueColor " x"  (HistoryX+75) " y" (HistoryY+63) " w" 150 " h" 20 " ", % localizedStrings["t1"]
        Gui, Add, DropDownList, % "x" (HistoryX+12) " y" (HistoryY+60) " w" 60 " h" 80 " vhistoryTextAlignment gSettingsUpdateFlag", LEFT||RIGHT
        Gui, Add, Text, %  "c" UniqueColor " x" (HistoryX+55) " y" (HistoryY+90) " w" 250 " h" 20 " ", % localizedStrings["t4"]
        Gui, Add, Edit, % "c" EditColor " x" (HistoryX+12) " y" (HistoryY+86) " w" 40 " h" 20 " vhistoryTextSize gSettingsUpdateFlag", 20
    }
    {   ; Game info
        local (gameinfoX:=x) , (gameinfoY:=179)
        Gui, Add, GroupBox, % "c" UniqueColor " x" (gameinfoX) " y" (gameinfoY) " w" 340 " h" 95 " ", % localizedStrings["gb20"] ;y179
        Gui, Add, Checkbox, % "c" UniqueColor " x" (gameinfoX+=12) " y" (gameinfoY+22) " w" 200 " h" 20 " vshowGameInfo gSettingsUpdateFlag", % localizedStrings["cb4"]
        

        Gui, Add, DropDownList, % "x" gameinfoX " y" (gameinfoY+43) " w" 60 " h" 80 " vgameInfoAlignment gSettingsUpdateFlag", RIGHT||LEFT ;y219
        Gui, Add, Text, %  "c" UniqueColor " x"  (gameinfoX+63) " y" (gameinfoY+45) " w" 150 " h" 20 " ", % localizedStrings["t2"]

        Gui, Add, Checkbox, % "c" UniqueColor " x" (gameinfoX+215) " y" (gameinfoY+43) " w" 84 " h" 20 " vshowNumPlayers gSettingsUpdateFlag", % "Player count"
        

        Gui, Add, Edit, % "c" EditColor " x" gameinfoX " y" (gameinfoY+69) " w" 40 " h" 20 " vgameInfoFontSize gSettingsUpdateFlag", 18
        Gui, Add, Text, %  "c" UniqueColor " x" (gameinfoX+43) " y" (gameinfoY+72) " w" 250 " h" 20 " ", % localizedStrings["t5"]
        
    }
    {   ; PLayer Location
        local (PLayersLocX:=x) , (PLayersLocY:=279)
        Gui, Add, GroupBox, % "c" UniqueColor " x" (PLayersLocX) " y" PLayersLocY " w" 340 " h" 55 " ",  % localizedStrings["gb21"] ; PLayer Location
        Gui, Add, Checkbox, % "c" UniqueColor " x" (PLayersLocX+12) " y" (PLayersLocY+20) " w" 190 " h" 20 " vshowPartyLocations gSettingsUpdateFlag",  % localizedStrings["gb22"]
        Gui, Add, Edit, % "c" EditColor " x" (PLayersLocX+212) " y" (PLayersLocY+20) " w" 40 " h" 20 " vpartyInfoFontSize gSettingsUpdateFlag", 0
        Gui, Add, Text, %  "c" UniqueColor " x" (PLayersLocX+255) " y" (PLayersLocY+23) " w" 70 " h" 20 " ", % localizedStrings["gb27"] ; font size
    }
    {   ; Mouse over resist and health
            local ( MouseoverX:=x) , (MouseoverY:=340)
        Gui, Add, GroupBox, % "c" UniqueColor " x" MouseoverX " y" (MouseoverY) " w" 340 " h" 80 " ",  % localizedStrings["gb26"]
        Gui, Add, Checkbox, % "c" UniqueColor " x" (MouseoverX+12) " y" (MouseoverY+20) " w" 190 " h" 20 " vshowResists gSettingsUpdateFlag",  % localizedStrings["gb25"]
        Gui, Add, Text, %  "c" UniqueColor " x" (MouseoverX+255) " y" (MouseoverY+23) " w" 50 " h" 20 " ", % localizedStrings["gb27"]
        Gui, Add, Edit, % "c" EditColor " x" (MouseoverX+212) " y" (MouseoverY+20) " w" 40 " h" 20 " vresistFontSize gSettingsUpdateFlag", 0
        Gui, Add, Checkbox, % "c" UniqueColor " x" (MouseoverX+12) " y" (MouseoverY+40) " w" 190 " h" 20 " vshowHealthPc gSettingsUpdateFlag",  % localizedStrings["gb24"]
        Gui, Add, Text, %  "c" UniqueColor " x" (MouseoverX+255) " y" (MouseoverY+43) " w" 50 " h" 20 " ", % localizedStrings["gb27"]
        Gui, Add, Edit, % "c" EditColor " x" (MouseoverX+212) " y" (MouseoverY+40) " w" 40 " h" 20 " vhealthFontSize gSettingsUpdateFlag", 0
    }
}

SettingsTabNPCs(x,y){
    global
    Gui, Settings:Default
    Gui, Tab, NPCs
    {   ; Monster dots
            local ( MonDotX:=x) , (MonDotY:=y) ;; GroupboxX:=10, GroupboxY:=59
        Gui, Add, GroupBox, % "c" UniqueColor " x" MonDotX " y" MonDotY " w" 340 " h" 165 " ",  % localizedStrings["gb3"]
            Gui, Add, Checkbox, % "c" UniqueColor " x" (MonDotX+12) " y" (MonDotY+20) " w" 150 " h" 20 " vshowNormalMobs gSettingsUpdateFlag", % localizedStrings["cb5"]
        Gui, Add, Checkbox, % "c" UniqueColor " x" (MonDotX+12) " y" (MonDotY+40) " w" 150 " h" 20 " vshowUniqueMobs gSettingsUpdateFlag", % localizedStrings["cb6"]
        Gui, Add, Checkbox, % "c" UniqueColor " x" (MonDotX+12) " y" (MonDotY+60) " w" 150 " h" 20 " vshowBosses gSettingsUpdateFlag", % localizedStrings["cb7"]
        Gui, Add, Checkbox, % "c" UniqueColor " x" (MonDotX+12) " y" (MonDotY+80) " w" 150 " h" 20 " vshowDeadMobs gSettingsUpdateFlag", % localizedStrings["cb8"]
        Gui, Add, Text, %  "c" UniqueColor " x" (MonDotX+195) " y" (MonDotY+23) " w" 30 " h" 20 " ", % "Size"
        Gui, Add, Edit, % "c" EditColor " x" (MonDotX+162) " y" (MonDotY+20) " w" 30 " h" 20 " vnormalDotSize gSettingsUpdateFlag", 2.5
        Gui, Add, Text, %  "c" UniqueColor " x" (MonDotX+195) " y" (MonDotY+43) " w" 30 " h" 20 " ", % "Size"
        Gui, Add, Edit, % "c" EditColor " x" (MonDotX+162) " y" (MonDotY+40) " w" 30 " h" 20 " vuniqueDotSize gSettingsUpdateFlag", 5
        Gui, Add, Text, %  "c" UniqueColor " x" (MonDotX+195) " y" (MonDotY+63) " w" 30 " h" 20 " ", % "Size"
        Gui, Add, Edit, % "c" EditColor " x" (MonDotX+162) " y" (MonDotY+60) " w" 30 " h" 20 " vbossDotSize gSettingsUpdateFlag", 5
        Gui, Add, Text, %  "c" UniqueColor " x" (MonDotX+195) " y" (MonDotY-59)+142 " w" 30 " h" 20 " ", % "Size"
        Gui, Add, Edit, % "c" EditColor " x" (MonDotX+162) " y" (MonDotY+80) " w" 30 " h" 20 " vdeadDotSize gSettingsUpdateFlag", 2

        Gui, Add, Text, %  "c" SettingDefault("normalMobColor") " x" (MonDotX+287) " y" (MonDotY+23) " w" 50 " h" 20 " ", % "Colour"
        Gui, Add, Edit, % "c" EditColor " x" (MonDotX+235) " y" (MonDotY+20) " w" 50 " h" 20 " vnormalMobColor gSettingsUpdateFlag", FFFFFF
        Gui, Add, Text, %  "c" SettingDefault("uniqueMobColor") " x" (MonDotX+287) " y" (MonDotY+43) " w" 50 " h" 20 " ", % "Colour"
        Gui, Add, Edit, % "c" EditColor " x" (MonDotX+235) " y" (MonDotY+40) " w" 50 " h" 20 " vuniqueMobColor gSettingsUpdateFlag", D4AF37
        Gui, Add, Text, %  "c" SettingDefault("bossColor") " x" (MonDotX+287) " y" (MonDotY+63) " w" 50 " h" 20 " ", % "Colour"
        Gui, Add, Edit, % "c" EditColor " x" (MonDotX+235) " y" (MonDotY+60) " w" 50 " h" 20 " vbossColor gSettingsUpdateFlag", FF0000
        Gui, Add, Text, %  "c" SettingDefault("deadColor") " x" (MonDotX+287) " y" (MonDotY+83) " w" 50 " h" 20 " backgroundFFFFFF", % "Colour"
        Gui, Add, Edit, % "c" EditColor " x" (MonDotX+235) " y" (MonDotY+80) " w" 50 " h" 20 " vdeadColor gSettingsUpdateFlag", 000000

        Gui, Add, Text, %  "c" UniqueColor " x" (MonDotX+45) " y" (MonDotY+113) " w" 190 " h" 20 " ", % localizedStrings["t14"]
        Gui, Add, Edit, % "c" EditColor " x" (MonDotX+12) " y" (MonDotY+110) " w" 30 " h" 20 " vnormalImmunitySize gSettingsUpdateFlag", 4
        Gui, Add, Text, %  "c" UniqueColor " x" (MonDotX+45) " y" (MonDotY+133) " w" 190 " h" 20 " ", % localizedStrings["t15"]
        Gui, Add, Edit, % "c" EditColor " x" (MonDotX+12) " y" (MonDotY+130) " w" 30 " h" 20 " vuniqueImmunitySize gSettingsUpdateFlag", 11
    }
    {   ; Friendly NPCs
            local (FriendlyNPCsX:=x), (FriendlyNPCsY:=209)
        Gui, Add, GroupBox, % "c" UniqueColor " x" FriendlyNPCsX " y" (FriendlyNPCsY+20) " w" 340 " h" 130 " ",  % localizedStrings["gb12"]
            Gui, Add, Checkbox, % "c" UniqueColor " x" (FriendlyNPCsX+12) " y" (FriendlyNPCsY+40) " w" 250 " h" 20 " vShowOtherPlayers gSettingsUpdateFlag", % localizedStrings["s34"] ;True
        Gui, Add, Checkbox, % "c" UniqueColor " x" (FriendlyNPCsX+12) " y" (FriendlyNPCsY+60) " w" 270 " h" 20 " vShowOtherPlayerNames gSettingsUpdateFlag", % localizedStrings["s35"] ;False

        Gui, Add, Checkbox, % "c" UniqueColor " x" (FriendlyNPCsX+12) " y" (FriendlyNPCsY+80) " w" 160 " h" 20 " vshowMerc gSettingsUpdateFlag", % localizedStrings["gb13"]
        Gui, Add, Checkbox, % "c" UniqueColor " x" (FriendlyNPCsX+12) " y" (FriendlyNPCsY+100) " w" 160 " h" 20 " vshowTownNPCs gSettingsUpdateFlag", % localizedStrings["gb14"]
        Gui, Add, Checkbox, % "c" UniqueColor " x" (FriendlyNPCsX+12) " y" (FriendlyNPCsY+120) " w" 160 " h" 20 " vNPCsAsCross gSettingsUpdateFlag", % localizedStrings["gb15"] 

        Gui, Add, Text, %  "c" SettingDefault("mercColor") " x" (FriendlyNPCsX+245) " y" (FriendlyNPCsY+82) " w" 90 " h" 20 " ", % localizedStrings["gb16"]
        Gui, Add, Edit, % "c" EditColor " x" (FriendlyNPCsX+172) " y" (FriendlyNPCsY+79) " w" 70 " h" 20 " vmercColor gSettingsUpdateFlag", % SettingDefault("mercColor")

        Gui, Add, Text, %  "c" SettingDefault("townNPCColor") " x" (FriendlyNPCsX+245) " y" (FriendlyNPCsY+102) " w" 90 " h" 20 " ", % localizedStrings["gb17"]
        Gui, Add, Edit, % "c" EditColor " x" (FriendlyNPCsX+172) " y" (FriendlyNPCsY+100) " w" 70 " h" 20 " vtownNPCColor gSettingsUpdateFlag", % SettingDefault("townNPCColor")  ;250 settings["townNPCColor"]
        
        Gui, Add, Checkbox, % "c" UniqueColor " x" (FriendlyNPCsX+172) " y" (FriendlyNPCsY+120) " w" 160 " h" 20 " vshowTownNPCNames gSettingsUpdateFlag", % localizedStrings["gb23"]
    }
}

SettingsTabImmunes(x,y){
    global
    Gui, Settings:Default
    Gui, Tab, Immunities
    {   ; Monster Immunities
        local (ImmunX:=x) , (ImmunY:=y)
        Gui, Add, GroupBox, % "c" UniqueColor " x" ImmunX " y" y " w" 340 " h" 170 " ",  % localizedStrings["gb4"]
        Gui, Add, Checkbox, % "c" UniqueColor " x" (ImmunX+10) " y" (ImmunY+20) " w" 210 " h" 20 " vshowImmunities gSettingsUpdateFlag", % localizedStrings["cb9"]
        Gui, Add, Text, %  "c" settings.physicalImmuneColor " x" (ImmunX+85) " y" (ImmunY+43) " w" 140 " h" 20 " ", % localizedStrings["t16"]
        Gui, Add, Edit, % "c" EditColor " x" (ImmunX+12) " y" ImmunY+40 " w" 70 " h" 20 " vphysicalImmuneColor gSettingsUpdateFlag", % settings.physicalImmuneColor
        Gui, Add, Text, %  "c" settings.magicImmuneColor " x" (ImmunX+85) " y" (ImmunY+63) " w" 140 " h" 20 " ", % localizedStrings["t17"]
        Gui, Add, Edit, % "c" EditColor " x" (ImmunX+12) " y" (ImmunY+60)  " w" 70 " h" 20 " vmagicImmuneColor gSettingsUpdateFlag", % settings.magicImmuneColor
        Gui, Add, Text, %  "c" settings.fireImmuneColor " x" (ImmunX+85) " y" (ImmunY+83) " w" 140 " h" 20 " ", % localizedStrings["t18"]
        Gui, Add, Edit, % "c" EditColor " x" (ImmunX+12) " y" ImmunY+80 " w" 70 " h" 20 " vfireImmuneColor gSettingsUpdateFlag", % settings.fireImmuneColor
        Gui, Add, Text, %  "c" settings.lightImmuneColor " x" (ImmunX+85) " y" (ImmunY+103) " w" 140 " h" 20 " ", % localizedStrings["t19"]
        Gui, Add, Edit, % "c" EditColor " x" (ImmunX+12) " y" (ImmunY+100) " w" 70 " h" 20 " vlightImmuneColor gSettingsUpdateFlag", % settings.lightImmuneColor
        Gui, Add, Text, %  "c" settings.coldImmuneColor " x" (ImmunX+85) " y" (ImmunY+123) " w" 140 " h" 20 " ", % localizedStrings["t20"]
        Gui, Add, Edit, % "c" EditColor " x" (ImmunX+12) " y" (ImmunY+120) " w" 70 " h" 20 " vcoldImmuneColor gSettingsUpdateFlag", % settings.coldImmuneColor
        Gui, Add, Text, %  "c" settings.poisonImmuneColor " x" (ImmunX+85) " y" (ImmunY+143) " w" 140 " h" 20 " ", % localizedStrings["t21"]
        Gui, Add, Edit, % "c" EditColor " x" (ImmunX+12) " y" (ImmunY+140) " w" 70 " h" 20 " vpoisonImmuneColor gSettingsUpdateFlag", % settings.poisonImmuneColor
    }
}

SettingsTabItemFilter(x,y){
    global
    Gui, Settings:Default
    Gui, Tab, Item Filter
    local (ItemFilterX:=x) , (ItemFilterY:=y)
    Gui, Add, GroupBox, % "c" UniqueColor " x" x " y" y " w" 340 " h" 180 " ",  % localizedStrings["gb5"]
    Gui, Add, Checkbox, % "c" UniqueColor " x" (ItemFilterX+12) " y" (ItemFilterY+20) " w" 200 " h" 20 " vEnableItemFilter gSettingsUpdateFlag", % localizedStrings["cb10"]
    Gui, Add, Checkbox, % "c" UniqueColor " x" (ItemFilterX+12) " y" (ItemFilterY+40) " w" 200 " h" 20 " vallowItemDropSounds gSettingsUpdateFlag", % localizedStrings["cb11"]
    Gui, Add, Checkbox, % "c" UniqueColor " x" (ItemFilterX+12) " y" (ItemFilterY+60) " w" 200 " h" 20 " vshowItemStats gSettingsUpdateFlag", % "Show item stats"
    
    Gui, Add, Checkbox, % "c" UniqueColor " x" (ItemFilterX+12) " y" (ItemFilterY+80) " w" 200 " h" 20 " vitemLogEnabled gSettingsUpdateFlag", % "Show item log"

    Gui, Add, Checkbox, % "c" UniqueColor " x" (ItemFilterX+12) " y" (ItemFilterY+100) " w" 200 " h" 20 " vincludeVendorItems gSettingsUpdateFlag", % "Include vendor items"

    Gui, Add, Edit, % "c" EditColor " x" (ItemFilterX+12) " y" (ItemFilterY+123) " w" 20 " h" 20 " vitemFontSize gSettingsUpdateFlag", 12
    Gui, Add, Text, %  "c" UniqueColor " x" (ItemFilterX+35) " y" 185 " w" 80 " h" 20, % localizedStrings["cb23"]
    Gui, Add, Edit, % "c" EditColor " x" (ItemFilterX+12) " y" (ItemFilterY+147) " w" 20 " h" 20 " vitemLogFontSize gSettingsUpdateFlag", % 18
    Gui, Add, Text, %  "c" UniqueColor " x" (ItemFilterX+35) " y" (ItemFilterY+150) " w" 80 " h" 20, % "Log font size"

    local (TTSX:=x) ,  (TTSY:=ItemFilterY+200)
    Gui, Add, GroupBox, % "c" UniqueColor " x" (TTSX) " y" (TTSY) " w" 340 " h" 135 " ",  % localizedStrings["gb6"]
    Gui, Add, Checkbox, % "c" UniqueColor " x" (TTSX+12) " y" (TTSY+18) " w" 200 " h" 20 " vallowTextToSpeech gSettingsUpdateFlag", % localizedStrings["cb12"]
    Gui, Add, Text, %  "c" UniqueColor " x" (TTSX+43) " y" (TTSY+41) " w" 200 " h" 20, % localizedStrings["t23"]
    Gui, Add, Edit, % "c" EditColor " x" (TTSX+12) " y" (TTSY+38) " w" 30 " h" 20 " vtextToSpeechVolume gSettingsUpdateFlag", 50
    Gui, Add, Text, %  "c" UniqueColor " x" (TTSX+43) " y" (TTSY+61) " w" 200 " h" 20, % localizedStrings["t22"]
    Gui, Add, Edit, % "c" EditColor " x" (TTSX+12) " y" (TTSY+58) " w" 30 " h" 20 " vtextToSpeechPitch gSettingsUpdateFlag", 1
    Gui, Add, Text, %  "c" UniqueColor " x" (TTSX+43) " y" (TTSY+81) " w" 200 " h" 20, % localizedStrings["t24"]
    Gui, Add, Edit, % "c" EditColor " x" (TTSX+12) " y" (TTSY+78) " w" 30 " h" 20 " vtextToSpeechSpeed gSettingsUpdateFlag", 1
    
    voiceList := GetVoiceList()
    chosenVoice := settings["chosenVoice"]
    oSPVoice.Voice := oSPVoice.GetVoices().Item(chosenVoice-1)
    Gui, Add, DropDownList, % "x" (TTSX+12) " y" (ItemFilterY+304) " w" 200 " h" 90 " vChosenVoice Choose" chosenVoice " ReadOnly AltSubmit gSettingsUpdateFlag", % voiceList

    Gui, Add, Link, % "x" (ItemFilterY+85) " y" (ItemFilterY+359) " w" 200 " h" 20 " ", Click <a href="https://github.com/joffreybesos/d2r-mapview/wiki/Item-filter-configuration">here</a> for the wiki on item filter
}

SettingsTabHotkeys(x,y){
    global
    Gui, Settings:Default
    Gui, Tab, Hotkeys
    local (hotkeyX:=x) , (hotkeyY:=y) , hotkeytexty:=95 , checkboxy:=hotkeytexty-3
    Gui, Add, GroupBox, % "c" UniqueColor " x" hotkeyX " y" hotkeyY " w" 340 " h" 220 " ",  % localizedStrings["gb11"]
    local ishotkey:="Edit"
    local hotkeycheckboxoptions:="gSettingsUpdateFlag " (ishotkey~="hotkey"?"enabled":"disabled") " c" UniqueColor  " x" (hotkeyX+10) " w" 20 " h" 20 " y" 
    local hotkeyinputoptions:="gSettingsUpdateFlag" " c" 0x000000   " x" (hotkeyx+30) " w" 90 " h" 20 " y"
    local hotkeytextoptions:="x" (hotkeyx+130) " w" 200 " h" 20 " y" 


    Gui, Add, Text, %  "c" UniqueColor " x" (hotkeyX+10) " w200 h20 y" hotkeytexty-20, % (ishotkey == "Hotkey")?"checkbox to use Windows key as modifier":""
    Gui, Add, Text, % hotkeytextoptions hotkeytexty, % localizedStrings["t34"]
    if ishotkey~="hotkey"
        Gui, Add, checkbox, % hotkeycheckboxoptions checkboxy " vWinincreaseMapSizeKey", 
        Gui, Add, % ishotkey, % hotkeyinputoptions checkboxy " vincreaseMapSizeKey",
        Gui, Add, Text, % hotkeytextoptions (hotkeytexty+20), % localizedStrings["t35"]
    if ishotkey~="hotkey"
        Gui, Add, checkbox, % hotkeycheckboxoptions (checkboxy+20) " vWdecreaseMapSizeKey", 
        Gui, Add, % ishotkey, % hotkeyinputoptions (checkboxy+20) " vdecreaseMapSizeKey",
        Gui, Add, Text, % hotkeytextoptions  (hotkeytexty+40), % localizedStrings["t36"]
    if ishotkey~="hotkey"
        Gui, Add, checkbox, % hotkeycheckboxoptions (checkboxy+40) " vWinmoveMapLeft", 
        Gui, Add, % ishotkey, % hotkeyinputoptions (checkboxy+40) " vmoveMapLeft",
        Gui, Add, Text, % hotkeytextoptions (hotkeytexty+60), % localizedStrings["t37"]
    if ishotkey~="hotkey"
        Gui, Add, checkbox, % hotkeycheckboxoptions (checkboxy+60) " vWinmoveMapRight", 
        Gui, Add, % ishotkey, % hotkeyinputoptions (checkboxy+60) " vmoveMapRight", 
        Gui, Add, Text, % hotkeytextoptions (hotkeytexty+80), % localizedStrings["t38"]
    if ishotkey~="hotkey"
        Gui, Add, checkbox, % hotkeycheckboxoptions (checkboxy+80) " vWinmoveMapUp",
        Gui, Add, % ishotkey, % hotkeyinputoptions (checkboxy+80) " vmoveMapUp", 
        Gui, Add, Text, % hotkeytextoptions (hotkeytexty+100), % localizedStrings["t39"]
    if ishotkey~="hotkey"
        Gui, Add, checkbox, % hotkeycheckboxoptions (checkboxy+100) " vWinmoveMapDown",
        Gui, Add, % ishotkey, % hotkeyinputoptions (checkboxy+100) " vmoveMapDown", 
        Gui, Add, Text, % hotkeytextoptions (hotkeytexty+120), % localizedStrings["t40"]
    if ishotkey~="hotkey"
        Gui, Add, checkbox, % hotkeycheckboxoptions (checkboxy+120) " vWinhistoryToggleKey",
        Gui, Add, % ishotkey, % hotkeyinputoptions (checkboxy+120) " vhistoryToggleKey", 
        Gui, Add, Text, % hotkeytextoptions (hotkeytexty+140), % localizedStrings["t41"]
    if ishotkey~="hotkey"
        Gui, Add, checkbox, % hotkeycheckboxoptions (checkboxy+140) " vWinalwaysShowKey",
        Gui, Add, % ishotkey, % hotkeyinputoptions (checkboxy+140) " valwaysShowKey", 
        Gui, Add, Text, % hotkeytextoptions (hotkeytexty+160), % localizedStrings["t42"]
    if ishotkey~="hotkey"
        Gui, Add, checkbox, % hotkeycheckboxoptions (checkboxy+160) " vWinswitchMapMode",
        Gui, Add, % ishotkey, % hotkeyinputoptions (checkboxy+160) " vswitchMapMode", 

    
    Gui, Add, Link, % "x" (hotkeyx+85) " y" (hotkeyY+359) " w" 200 " h" 20 " ", Click <a href="https://www.autohotkey.com/docs/KeyList.htm">here</a> for possible key combos
}

SettingsTabOther(x,y){
    global
    Gui, Settings:Default
    Gui, Tab, Other
    local (otherX:=x) , (otherY:=y)
    Gui, Add, GroupBox, % "c" UniqueColor " x" otherX " y" otherY " w" 340 " h" 110 " ",  % localizedStrings["gb7"]
    Gui, Add, Checkbox, % "c" UniqueColor " x" (otherX+12) " y" (otherY+20) " w" 270 " h" 20 " vshowWaypointLine gSettingsUpdateFlag", % localizedStrings["cb13"]
    Gui, Add, Checkbox, % "c" UniqueColor " x" (otherX+12) " y" (otherY+40) " w" 270 " h" 20 " vshowNextExitLine gSettingsUpdateFlag", % localizedStrings["cb14"]
    Gui, Add, Checkbox, % "c" UniqueColor " x" (otherX+12) " y" (otherY+60) " w" 270 " h" 20 " vshowBossLine gSettingsUpdateFlag", % localizedStrings["cb15"]
    Gui, Add, Checkbox, % "c" UniqueColor " x" (otherX+12) " y" (otherY+80) " w" 270 " h" 20 " vshowQuestLine gSettingsUpdateFlag", % localizedStrings["cb16"]

    local (HudX:=x) , (HudY:=y)
    Gui, Add, GroupBox, % "c" UniqueColor " x" x " y" (HudY+=120) " w" 340 " h" 130 " ",  % "HUD" 
    Gui, Add, Checkbox, % "c" UniqueColor " x" (HudX+12) " y" (HudY+20) " w" 270 " h" 20 " vitemCounterEnabled gSettingsUpdateFlag", % localizedStrings["gb29"]
    Gui, Add, Text, %  "c" UniqueColor " x" (HudX+45) " y" (HudY+46) " w" 200 " h" 20, % localizedStrings["gb30"]
    Gui, Add, Edit, % "c" EditColor " x" (HudX+12) " y" (HudY+43) " w" 30 " h" 20 " vitemCounterSize gSettingsUpdateFlag", 75
    Gui, Add, Checkbox, % "c" UniqueColor " x" (HudX+12) " y" (HudY+63) " w" 270 " h" 20 " vbuffBarEnabled gSettingsUpdateFlag", % localizedStrings["gb31"]
    Gui, Add, Text, %  "c" UniqueColor " x" (HudX+45) " y" (HudY+86) " w" 200 " h" 20, % localizedStrings["gb32"]
    Gui, Add, Edit, % "c" EditColor " x" (HudX+12) " y" (HudY+83) " w" 30 " h" 20 " vbuffBarIconSize gSettingsUpdateFlag", 75
    Gui, Add, Text, %  "c" UniqueColor " x" (HudX+45) " y" (HudY+106) " w" 200 " h" 20, % localizedStrings["gb33"]
    Gui, Add, Edit, % "c" EditColor " x" (HudX+12) " y" (HudY+103) " w" 30 " h" 20 " vbuffBarVerticalOffset gSettingsUpdateFlag", 0    

    local (SplashConfgiX:=x) , (SplashConfgiY:=HudY+120)
    Gui, Add, GroupBox, % "c" UniqueColor " x" (SplashConfgiX) " y" (HudY+=130) " w" 340 " h" 120 " ",  % "Splash" 
    Gui, Add, Checkbox, % "c" UniqueColor " x" (SplashConfgiX+=10) " y" (HudY+20) " w" 270 " h" 20 " vStartSplash gSettingsUpdateFlag", % "Start Splash"
    Gui, Add, Checkbox, % "c" UniqueColor " x" (SplashConfgiX) " y" (HudY+40) " w" 270 " h" 20 " vLoadingSplash gSettingsUpdateFlag", % "Loading Splash"
}

SettingsTabProjectiles(x,y){
    global
    Gui, Settings:Default
    Gui, Tab, Projectiles
    local (mY4 := (mY3:=(mY2:=(mY1:=y)+(rowh:=20))+rowh)+rowh) , (mX4 := (mX3:=(mX2:=(mX1:=x+10)+cboxW:=40)+(tW:=100))+cboxW)
    local fontwidth:=140 , eboxwidth:=32
    Gui, Add, GroupBox, % "c" UniqueColor " x" (mX1-10) " y" (mY1-16) " w" 340 " h" 400,  % localizedStrings["gb8"]
    Gui, Add, Checkbox, % "c" UniqueColor " x" mX1 "  y" mY1 " w110 h" rowh " vshowPlayerMissiles gSettingsUpdateFlag", % localizedStrings["cb18"]
    Gui, Add, Checkbox, % "c" UniqueColor " x" mX1 "  y" mY2 " w110 h" rowh " vshowEnemyMissiles gSettingsUpdateFlag", % localizedStrings["cb17"]
    Gui, Add, Slider, % "x" mX1 " y" mY3 " h" rowh " vOpac tooltip gOpacitySlide range1-255", % (settings.missileOpacity+0)
    local projectileEditOption:=" gSettingsUpdateFlag center x" mX3 " w" eboxwidth " h" rowh " y"
    Gui, Add, Edit, % " c" EditColor projectileEditOption mY1 " vmissileMajorDotSize"
    Gui, Add, Edit, % " c" EditColor projectileEditOption mY2 " vmissileMinorDotSize" 
    Gui, Add, Edit, % " c" EditColor projectileEditOption mY3 " vmissileOpacity"

    Gui, Add, Text, %  "c" UniqueColor " x" mX4 " y" mY1 " w" fontwidth " h" rowh, % localizedStrings["t25"]
    Gui, Add, Text, %  "c" UniqueColor " x" mX4 " y" mY2 " w" fontwidth " h" rowh, % localizedStrings["t26"]
    Gui, Add, Text, %  "c" UniqueColor " x" mX4 " y" mY3 " w" fontwidth " h" rowh, % localizedStrings["t27"]
    
    local each, mtype
    for each,mtype in (Projectilelist())
    {
        local mY:=(mY4+each*rowh+5)
        Gui, Add, Progress, % "x" 20 " y" mY " w20 h20 cWhite v" mtype "preview Background" settings["missile" mtype "Color"]
        Gui, Add,Edit, % "c" settings["missile" mtype "Color"] " x" mX2-30 " y" mY " w" (eboxwidth+50) " h" rowh " vmissile" mtype "Color gSettingsUpdateFlag center"
    }
    ; we do this seperately and consecutively to force the radio to be "together" without additional code
    for each,mtype in (Projectilelist())
        Gui, Add, radio, % " c" settings["missile" mtype "Color"] " x" mX3-47 " y" (mY4+7+(each*20)) " v" mtype "Rcheck gRadioToSliders", % mtype
    ;RGB sliders
    local (slide), (sliders:=["Red","Green","Blue"]) ,( slidex:=mX3) , (slideH:=250)
    local (slidey:=mY4+10), slidetexty:=slidey+250
    for each,slide in sliders
    {
        Gui, Add, Slider, % "x" (slidex+=30) " y" slidey " h" slideH " w" 50 " vSlider" slide " gColorslide c0x000000 vertical Invert AltSubmit Range0-255 TickInterval" 1, 119
        local Channel:=SubStr(slide, 1 , 1)
        Gui, Add, Text, %  "c" UniqueColor " x" (slidex+=15) " y" slidetexty " vch" Channel, % Channel
    }
}

SettingsTabAdvanced(x,y){
    global
    Gui, Settings:Default
    Gui, Tab, Advanced
    local (AdvancedX:=x) , (AdvancedY:=y)
    Gui, Add, GroupBox, % "c" UniqueColor " x" AdvancedX " y" AdvancedY " w" 340 " h" 220 " ",  % localizedStrings["gb9"]
    Gui, Add, Text, %  "c" DetailFontColor " x" (AdvancedX+10) " y" (AdvancedY+20) " w" 100 " h" 20 " r2", % localizedStrings["t28"]
    Gui, Add, Edit, % "c" EditColor " x" (AdvancedX+10) " y" (AdvancedY+40) " w" 40 " h" 20 " vperformanceMode gSettingsUpdateFlag", 50ms
    Gui, Add, Text, %  "c" DetailFontColor " x" (AdvancedX+60) " y" (AdvancedY+40) " w" 250 " h" 40 " ", % localizedStrings["t29"]

    Gui, Add, Text, %  "c" UniqueColor " x" (AdvancedX+10) " y" (AdvancedY+109) " w" 250 " h" 20 " ", % localizedStrings["t30"] ;168

    Gui, Add, Checkbox, % "c" UniqueColor " x" (AdvancedX+10) " y" (AdvancedY+69) " w" 150 " h" 20 " vshowFPS gSettingsUpdateFlag", % localizedStrings["cb22"] ;128
    Gui, Add, Text, %  "c" UniqueColor " x" (AdvancedX+240) " y" (AdvancedY+71) " w" 75 " h" 18 " ", % localizedStrings["gb28"] ;fpscap
    Gui, Add, Edit, % "c" EditColor " x" (AdvancedX+197) " y" (AdvancedY+68) " w" 40 " h" 20 " vfpscap gSettingsUpdateFlag", 60 ;FPSedit

    Gui, Add, Checkbox, % "c" UniqueColor " x" (AdvancedX+10) " y" (AdvancedY+130) " w" 150 " h" 20 " venableD2ML gSettingsUpdateFlag", % localizedStrings["cb20"] ;189
    Gui, Add, Text, %  "c" UniqueColor " x" (AdvancedX+135) " y" (AdvancedY+153) " w" 200 " h" 18 " ", % localizedStrings["t31"]
    Gui, Add, Edit, % "c" EditColor " x" (AdvancedX+10) " y" (AdvancedY+150) " w" 120 " h" 20 " vwindowTitle gSettingsUpdateFlag", D2R:main
    Gui, Add, Text, %  "c" DetailFontColor " x" (AdvancedX+10) " y" (AdvancedY+170) " w" 300 " h" 30, % localizedStrings["t32"]

    Gui, Add, GroupBox, % "c" UniqueColor " x" AdvancedX " y" (AdvancedY+230) " w" 340 " h" 80,  % localizedStrings["gb10"] ;289
    Gui, Add, Checkbox, % "c" UniqueColor " x" (AdvancedX+10) " y" (AdvancedY+250) " w" 200 " h" 20 " vdebug gSettingsUpdateFlag", % localizedStrings["cb21"]
    Gui, Add, Text, %  "c" DetailFontColor " x" (AdvancedX+10) " y" (AdvancedY+270) " w" 320 " h" 30, % localizedStrings["t33"]

    Gui, Add, GroupBox, % "c" UniqueColor " x" AdvancedX " y" (AdvancedY+310) " w" 340 " h" 60,  % "Settings"
    Gui, Add, Checkbox, % "c" UniqueColor " x" (AdvancedX+10) " y" (AdvancedY+325) " w" 150 " h" 20 " vCustomSettings gSettingsUpdateFlag", Custom Settings colors
    Gui, Add, Checkbox, % "c" UniqueColor " x" (AdvancedX+160) " y" (AdvancedY+325) " w" 175 " h" 20 " vInvertedColors gSettingsUpdateFlag", Invert Colors (requires restart)
    Gui, Add, Edit, % "c" EditColor " x" (AdvancedX+10) " y" (AdvancedY+345) " w" 60 " h" 20 " vWindowColor gSettingsUpdateFlag", % settings["WindowColor"]
    Gui, Add, Text, %  "c" UniqueColor " x" (AdvancedX+70) " y" (AdvancedY+348) " w" 75 " h" 18 " ", Window Color

    Gui, Add, Edit, % "c" EditColor " x" (AdvancedX+140) " y" (AdvancedY+345) " w" 60 " h" 20 " vFontColor gSettingsUpdateFlag", % settings["FontColor"]
    Gui, Add, Text, %  "c" UniqueColor " x" (AdvancedX+200) " y" (AdvancedY+348) " w" 75 " h" 18 " ", Font Color
    
}

;colorpicker
showColorPicker(){
     local static ShowPicker := false
     local static PickerBuilt := false
    if !(PickerBuilt){
        colorpicker()
        PickerBuilt:=True
    }
    ; open the settings window and a given position
    if (ShowPicker:=!ShowPicker){
        Gui, ColorPicker:Show,, % "RGB"
    } else {
        Gui, ColorPicker:hide
    }

}

colorpicker(){
    global 
    Gui, ColorPicker:Default
    Gui, ColorPicker:-MinimizeBox +AlwaysOnTop
    local progressX:=0
    local progressY:=5
    local progressS:=50
    glable:="gColorPickerUpdate"
    Gui, ColorPicker:Add, Progress, % "x" progressX " y"progressY " w" progressS " h" progressS " +C0xFF0000 vProg", 100
    Gui, ColorPicker:Add, Edit, % "x" (progressX+=progressS)  " y" (progressY) " w" 70 " h20 vHex " glable, 0xFFFF0000
    Gui, ColorPicker:Font, s9
    local buttony:=progressY
    Gui, ColorPicker:Add, Button, % "x" progressX " y" (buttony+=20) " w" 70 " h" 15, CopyRGB
    Gui, ColorPicker:Add, Button, % "x" progressX " y" (buttony+=15 )" w" 70 " h" 15, CopyAlpha
    ;Gui, ColorPicker:Add, Button, % "x" 165 " y" buttony " w75 h23", Close
    rgbtX:=13 , rgbty:=buttony+25
    Gui, ColorPicker:Font, s12
    Gui, ColorPicker:Add, Text, % "x" rgbtX " y" rgbty " w20 h20 Center", R
    Gui, ColorPicker:Font, s9
    Gui, ColorPicker:Add, Edit, % "x" rgbtX " y" (rgbty+25) " w25 h20 +Number Center ReadOnly vR " glable, 255
    Gui, ColorPicker:Font, s12
    Gui, ColorPicker:Add, Text, % "x" (rgbtX+=25) " y" rgbty " w25 h25 Center", G
    Gui, ColorPicker:Font, s9
    Gui, ColorPicker:Add, Edit, % "x" rgbtX " y" (rgbty+25) " w25 h20 +Number Center ReadOnly vG " glable, 0
    Gui, ColorPicker:Font, s12
    Gui, ColorPicker:Add, Text, % "x" (rgbtX+=25) " y" rgbty " w25 h25 Center", B
    Gui, ColorPicker:Font, s9
    Gui, ColorPicker:Add, Edit, % "x" rgbtX " y" (rgbty+25) " w25 h20 +Number Center ReadOnly vB " glable, 0
    Gui, ColorPicker:Font, s12
    Gui, ColorPicker:Add, Text, % "x" (rgbtX+=25) " y"rgbty " w25 h25 Center", A
    Gui, ColorPicker:Font, s9
    Gui, ColorPicker:Add, Edit, % "x" rgbtX " y" (rgbty+25) " w25 h20 +Number Center ReadOnly vA " glable, 255
    local sliderh:=150
    local sliderw:=25
    local sliderx:=10
    local slidery:=rgbty+50
    options:=" TickInterval1 +Vertical +0x20 +0x200 +Vertical +Invert +Center +Range0-255 -Tabstop AltSubmit " glable
    Gui, ColorPicker:Add, Slider, % "x" sliderx " y" slidery " w" sliderw " h" sliderh options " vRS", 255
    Gui, ColorPicker:Add, Slider, % "x" (sliderx+=sliderw) " y" slidery " w" sliderw " h" sliderh options " vGS", 0
    Gui, ColorPicker:Add, Slider, % "x" (sliderx+=sliderw) " y" slidery " w" sliderw " h" sliderh options " vBS", 0
    Gui, ColorPicker:Add, Slider, % "x" (sliderx+=sliderw) " y" slidery " w" sliderw " h" sliderh options " vAS", 255
    

}

ColorPickerGuiEscape(){
    ColorPickerGuiClose()
}

ColorPickerGuiClose(){
    showColorPicker()
}

ColorPickerUpdate(){
    GuiControlGet, RS
    GuiControlGet, GS
    GuiControlGet, BS
    GuiControlGet, AS

    GuiControlGet, R
    GuiControlGet, G
    GuiControlGet, B
    GuiControlGet, A
    GuiControlGet, Hex
    GuiControlGet, Prog

	ColorPickerSet("R", RS)
	ColorPickerSet("G", GS)
	ColorPickerSet("B", BS)
	ColorPickerSet("A", AS)
	ColorPickerSet("RS", R, "+Range0-255")
	ColorPickerSet("GS", G, "+Range0-255")
	ColorPickerSet("BS", B, "+Range0-255")
	ColorPickerSet("AS", A, "+Range1-255")
	ColorPickerSet("Hex", ARGB(R, G, B, A))
	ColorPickerSet("Prog",, "+C" ARGB(R, G, B))
}

ColorPickerButtonCopyRGB(){
    GuiControlGet, Hex
    return Clipboard:=SubStr(Hex, 5)
}

ColorPickerButtonCopyAlpha(){
    GuiControlGet, R
    GuiControlGet, G
    GuiControlGet, B
    GuiControlGet, A
    return clipboard:=SubStr(ARGB(R, G, B, A), 1 , 4)
}

ColorPickerSet(Control, Data := "", AddOpt := "") {
	GuiControl, %AddOpt%, %Control%, % Data
    return !ErrorLevel
}
