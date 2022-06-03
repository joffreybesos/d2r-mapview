#NoEnv

class BuffBarLayer {
    hbm :=
    hdc :=
    obm :=
    G :=
    buffBarLayerHwnd :=

    __new(ByRef settings) {
        SetFormat Integer, D
        gameClientArea := getWindowClientArea()
        gameWindowX := gameClientArea["X"]
        gameWindowY := gameClientArea["Y"]
        gameWindowWidth := gameClientArea["W"]
        gameWindowHeight := gameClientArea["H"]

        Gui, BuffBar: -Caption +E0x20 +E0x80000 +E0x00080000 +LastFound +AlwaysOnTop +ToolWindow +OwnDialogs 
        this.buffBarLayerHwnd := WinExist()
        this.imageSize := settings["buffBarIconSize"]
        this.buffBarFontSize := this.imageSize / 3 ; settings["buffBarFontSize"]
        this.xoffset := 0
        this.yoffset := this.buffBarFontSize * 1.4
        this.textBoxWidth := this.imageSize * 15  ; 15 icons wide max
        this.textBoxHeight := this.imageSize + this.yoffset

        this.leftMargin := gameWindowX + (gameWindowWidth / 2) - (this.textBoxWidth / 2)
        this.topMargin := gameWindowY + gameWindowHeight - (gameWindowHeight / 4.3) + settings["buffBarVerticalOffset"]

        pToken := Gdip_Startup()
        DetectHiddenWindows, On
        this.hbm := CreateDIBSection(this.textBoxWidth, this.textBoxHeight)
        this.hdc := CreateCompatibleDC()
        this.obm := SelectObject(this.hdc, this.hbm)
        this.G := Gdip_GraphicsFromHDC(this.hdc)
        this.pPenBuff := Gdip_CreatePen(0xff00FF00, 2)
        this.pPenDebuff := Gdip_CreatePen(0xffff0000, 2)
        this.pPenPassive := Gdip_CreatePen(0xffdddddd, 2)
        this.pPenAura := Gdip_CreatePen(0xffffd700, 2)
        this.pBrushExpiring := Gdip_BrushCreateSolid(0x33ff0000)
        this.pBrushBackground := Gdip_BrushCreateSolid(0x55000000)
        this.removedIcons := []
        Gdip_SetSmoothingMode(this.G, 4)
        Gdip_SetInterpolationMode(this.G, 7)
        Gui, BuffBar: Show, NA
    }

    checkHover(mouseX, mouseY) {
        this.showToolTip := 0
        if (mouseX > this.leftMargin and mouseX < (this.leftMargin + this.textBoxWidth)) {
            if (mouseY > this.topMargin and mouseY < (this.topMargin + this.textBoxHeight)) {
                
                iconi := 0
                xoffset := this.textBoxWidth / 2 - ((this.totalicons * this.imageSize) / 2)
                for k, iconName in this.iconsToShow
                {
                    iconx := xoffset + (iconi * this.imageSize)
                    boxx := this.leftMargin + iconx
                    boxy := this.topMargin + this.yoffset
                    if (mouseX > boxx and mouseX < (boxx + this.imageSize)) {
                        if (mouseY > boxy and mouseY < (boxy + this.imageSize)) {
                            ;Gdip_DrawImage(this.G, buffBitmaps[iconName.fileName], iconx, this.yoffset,this.imageSize, this.imageSize)
                            ;Gdip_DrawRectangle(this.G, this.pPenBuff, iconx, this.yoffset, this.imageSize, this.imageSize)
                            ; OutputDebug, % "Hover " iconName.num " " iconName.fileName "`n"
                            this.showToolTip := iconName.num
                            break
                        }
                    }
                    iconi++
                }
            }
        }
    }

    drawFloatingText(textx, ByRef texty, ByRef text) {
        fontSize := this.buffBarFontSize
        textSpaceWidth := StrLen(text) * this.buffBarFontSize
        , textSpaceHeight := 100
        textx := textx - textSpaceWidth / 2
        , texty := texty
        Options = x%textx% y%texty% Center vTop cffffffff r8 s%fontSize%
        textx := textx + 1
        , texty := texty + 1
        Options2 = x%textx% y%texty% Center vTop cff000000 r8 s%fontSize%
        
        ;x|y|width|height|chars|lines
        measuredString := Gdip_TextToGraphics(this.G, text, Options2, exocetFont, textSpaceWidth, textSpaceHeight)
        ms := StrSplit(measuredString , "|")
        , bgx := ms[1] - 6
        , bgy := ms[2] - 3
        , bgw := ms[3] + 9
        , bgh := ms[4] + 0
        Gdip_FillRectangle(this.G, this.pBrushBackground, bgx, bgy, bgw, bgh)
        Gdip_TextToGraphics(this.G, text, Options, exocetFont, textSpaceWidth, textSpaceHeight)
        return measuredString
    }

    drawBuffBar(ByRef currentStates, ByRef buffBitmaps) {
        if (!settings["buffBarEnabled"]) {
            this.hide()
            return
        }
        if (readUI(d2rprocess)) {
            this.hide()
            return
        }
        if (WinActive(gameWindowId)) {
            this.show()
        } else {
            this.hide()
            return
        }
        
        fontSize := this.BuffBarFontSize
        this.iconsToShow := []
        this.totalicons := 0
        for k, state in currentStates
        {
            thisIcon := getStateIcon(state.stateNum)
            if (thisIcon) {
                ;OutputDebug % this.iconsToShow[state.stateNum].showToolTip
                this.iconsToShow[state.stateNum] := { "fileName": thisIcon, "num": state.stateNum, "active": true, "timestamp": A_TickCount }
                this.lastIcons[state.stateNum] := 0
                this.removedIcons[state.stateNum] := 0
                this.totalicons++
            }
        }
        for k, removedIcon in this.lastIcons {
            if (removedIcon) {
                removedIcon.active := false
                this.removedIcons[removedIcon.num] := removedIcon
                ;OutputDebug, % "Missing buff icon " removedIcon.fileName "`n"
            }
        }
        for k, expiredIcon in this.removedIcons
        {
            if (expiredIcon) {
                if (A_TickCount - expiredIcon.timeStamp < 5000) {
                    this.iconsToShow[expiredIcon.num] := expiredIcon
                    this.totalicons++
                    ; OutputDebug, % "Expiring icon " expiredIcon.num " " expiredIcon.filename "`n"
                } else {    
                    this.removedIcons[expiredIcon.stateNum] := 0
                    ;OutputDebug, % "Expired icon " expiredIcon.num " " expiredIcon.filename "`n"
                }
            }
        }
        

        xoffset := this.textBoxWidth / 2 - ((this.totalicons * this.imageSize) / 2)
        iconi := 0
        for k, iconName in this.iconsToShow
        {
            iconx := xoffset + (iconi * this.imageSize)
            Gdip_DrawImage(this.G, buffBitmaps[iconName.fileName], iconx, this.yoffset,this.imageSize, this.imageSize)
            if (iconName.active) {
                Gdip_DrawRectangle(this.G, this.getBuffColor(iconName.num), iconx, this.yoffset, this.imageSize-1, this.imageSize-1)
            } else {
                if (Mod(ticktock, 2)) {
                    Gdip_FillRectangle(this.G, this.pBrushExpiring, iconx, this.yoffset, this.imageSize, this.imageSize-1)
                }
            }
            if (this.showToolTip == iconName.num) {
                this.drawFloatingText(iconx + (this.imageSize /2), 4, localizedStrings["buff" . iconName.num])
            }
            iconi++
        }
        this.lastIcons := this.iconsToShow.Clone()
        
        ; Gdip_DrawRectangle(this.G, this.pPenBuff, 0, 0, this.textBoxWidth, this.textBoxHeight)
        UpdateLayeredWindow(this.buffBarLayerHwnd, this.hdc, this.leftMargin, this.topMargin, this.textBoxWidth, this.textBoxHeight)
        Gdip_GraphicsClear( this.G )
    }

    drawData(textx, texty, fontSize, alertColor, itemText) {
        Options = x%textx% y%texty% Left vBottom NoWrap c%alertColor% r4 s%fontSize%
        textx := textx + 1
        texty := texty + 1
        Options2 = x%textx% y%texty% Left vBottom NoWrap cdd000000 r4 s%fontSize%
        Gdip_TextToGraphics(this.G, itemText, Options2, exocetFont)
        Gdip_TextToGraphics(this.G, itemText, Options, exocetFont) 
    }

    show() {
        this.visible := true
        Gui, BuffBar: Show, NA
    }

    hide() {
        this.visible := false
        Gui, BuffBar: Hide
    }

    delete() {
        SelectObject(this.hdc, this.obm)
        DeleteObject(this.hbm)
        DeleteDC(this.hdc)
        Gui, BuffBar: Destroy
    }

    getBuffColor(stateNum) {
        switch (stateNum) {
            case 2: return this.pPenDebuff   ;STATE_POISON
            case 9: return this.pPenDebuff   ;STATE_AMPLIFYDAMAGE
            case 11: return this.pPenDebuff   ;STATE_COLD
            case 19: return this.pPenDebuff   ;STATE_WEAKEN
            case 23: return this.pPenDebuff   ;STATE_DIMVISION
            case 24: return this.pPenDebuff   ;STATE_SLOWED
            case 28: return this.pPenDebuff   ;STATE_CONVICTION
            case 29: return this.pPenDebuff   ;STATE_CONVICTED
            case 53: return this.pPenDebuff   ;STATE_CONVERSION
            case 55: return this.pPenDebuff   ;STATE_IRONMAIDEN
            case 56: return this.pPenDebuff   ;STATE_TERROR
            case 57: return this.pPenDebuff   ;STATE_ATTRACT
            case 58: return this.pPenDebuff   ;STATE_LIFETAP
            case 59: return this.pPenDebuff   ;STATE_CONFUSE
            case 60: return this.pPenDebuff   ;STATE_DECREPIFY
            case 61: return this.pPenDebuff   ;STATE_LOWERRESIST
            case 113: return this.pPenDebuff   ;STATE_DEFENSE_CURSE
            case 114: return this.pPenDebuff   ;STATE_BLOOD_MANA
            case 10: return this.pPenBuff   ;STATE_FROZENARMOR
            case 12: return this.pPenBuff   ;STATE_INFERNO
            case 13: return this.pPenBuff   ;STATE_BLAZE
            case 14: return this.pPenBuff   ;STATE_BONEARMOR
            case 16: return this.pPenBuff   ;STATE_ENCHANT
            case 17: return this.pPenBuff   ;STATE_INNERSIGHT
            case 20: return this.pPenBuff   ;STATE_CHILLINGARMOR
            case 26: return this.pPenBuff   ;STATE_SHOUT
            case 30: return this.pPenBuff   ;STATE_ENERGYSHIELD
            case 31: return this.pPenBuff   ;STATE_VENOMCLAWS
            case 32: return this.pPenBuff   ;STATE_BATTLEORDERS
            case 38: return this.pPenBuff   ;STATE_THUNDERSTORM
            case 51: return this.pPenBuff   ;STATE_BATTLECOMMAND
            case 87: return this.pPenBuff   ;STATE_SLOWMISSILES
            case 88: return this.pPenBuff   ;STATE_SHIVERARMOR
            case 93: return this.pPenBuff   ;STATE_VALKYRIE
            case 94: return this.pPenBuff   ;STATE_FRENZY
            case 95: return this.pPenBuff   ;STATE_BERSERK
            case 101: return this.pPenBuff   ;STATE_HOLYSHIELD
            case 119: return this.pPenBuff   ;STATE_SHADOWWARRIOR
            case 120: return this.pPenBuff   ;STATE_FERALRAGE
            case 139: return this.pPenBuff   ;STATE_WOLF
            case 140: return this.pPenBuff   ;STATE_BEAR
            case 144: return this.pPenBuff   ;STATE_HURRICANE
            case 145: return this.pPenBuff   ;STATE_ARMAGEDDON
            case 151: return this.pPenBuff   ;STATE_CYCLONEARMOR
            case 153: return this.pPenBuff   ;STATE_CLOAK_OF_SHADOWS
            case 156: return this.pPenBuff   ;STATE_CLOAKED
            case 157: return this.pPenBuff   ;STATE_QUICKNESS
            case 158: return this.pPenBuff   ;STATE_BLADESHIELD
            case 159: return this.pPenBuff   ;STATE_FADE
            case 147: return this.pPenAura   ;STATE_BARBS
            case 40: return this.pPenAura   ;STATE_BLESSEDAIM
            case 45: return this.pPenAura   ;STATE_CLEANSING
            case 42: return this.pPenAura   ;STATE_CONCENTRATION
            case 28: return this.pPenAura   ;STATE_CONVICTION
            case 37: return this.pPenAura   ;STATE_DEFIANCE
            case 49: return this.pPenAura   ;STATE_FANATICISM
            case 35: return this.pPenAura   ;STATE_HOLYFIRE
            case 46: return this.pPenAura   ;STATE_HOLYSHOCK
            case 43: return this.pPenAura   ;STATE_HOLYWIND
            case 48: return this.pPenAura   ;STATE_MEDITATION
            case 33: return this.pPenAura   ;STATE_MIGHT
            case 149: return this.pPenAura   ;STATE_OAKSAGE
            case 34: return this.pPenAura   ;STATE_PRAYER
            case 50: return this.pPenAura   ;STATE_REDEMPTION
            case 4: return this.pPenAura   ;STATE_RESISTCOLD
            case 3: return this.pPenAura   ;STATE_RESISTFIRE
            case 5: return this.pPenAura   ;STATE_RESISTLIGHTNING
            case 8: return this.pPenAura   ;STATE_RESISTALL
            case 47: return this.pPenAura   ;STATE_SANCTUARY
            case 41: return this.pPenAura   ;STATE_STAMINA
            case 36: return this.pPenAura   ;STATE_THORNS
            case 41: return this.pPenAura   ;STATE_STAMINA
            case 148: return this.pPenAura   ;STATE_WOLVERINE
            case 64: return this.pPenPassive   ;STATE_CRITICALSTRIKE
            case 65: return this.pPenPassive   ;STATE_DODGE
            case 66: return this.pPenPassive   ;STATE_AVOID
            case 67: return this.pPenPassive   ;STATE_PENETRATE
            case 68: return this.pPenPassive   ;STATE_EVADE
            case 69: return this.pPenPassive   ;STATE_PIERCE
            case 70: return this.pPenPassive   ;STATE_WARMTH
            case 71: return this.pPenPassive   ;STATE_FIREMASTERY
            case 72: return this.pPenPassive   ;STATE_LIGHTNINGMASTERY
            case 73: return this.pPenPassive   ;STATE_COLDMASTERY
            case 74: return this.pPenPassive   ;STATE_BLADEMASTERY
            case 75: return this.pPenPassive   ;STATE_AXEMASTERY
            case 76: return this.pPenPassive   ;STATE_MACEMASTERY
            case 77: return this.pPenPassive   ;STATE_POLEARMMASTERY
            case 78: return this.pPenPassive   ;STATE_THROWINGMASTERY
            case 79: return this.pPenPassive   ;STATE_SPEARMASTERY
            case 80: return this.pPenPassive   ;STATE_INCREASEDSTAMINA
            case 81: return this.pPenPassive   ;STATE_IRONSKIN
            case 82: return this.pPenPassive   ;STATE_INCREASEDSPEED
            case 83: return this.pPenPassive   ;STATE_NATURALRESISTANCE
            case 122: return this.pPenPassive   ;STATE_TIGERSTRIKE
            case 123: return this.pPenPassive   ;STATE_COBRASTRIKE
            case 124: return this.pPenPassive   ;STATE_PHOENIXSTRIKE
            case 125: return this.pPenPassive   ;STATE_FISTSOFFIRE
            case 126: return this.pPenPassive   ;STATE_BLADESOFICE
            case 127: return this.pPenPassive   ;STATE_CLAWSOFTHUNDER
            case 138: return this.pPenPassive   ;STATE_FENRIS_RAGE
            case 152: return this.pPenPassive   ;STATE_CLAWMASTERY
            case 155: return this.pPenPassive   ;STATE_WEAPONBLOCK
        }
    }
}


getStateIcon(stateNum) {
    switch (stateNum) {
        case 2: return "Poison"   ;STATE_POISON
        case 3: return "ResistFire"   ;STATE_RESISTFIRE
        case 4: return "ResistCold"   ;STATE_RESISTCOLD
        case 5: return "ResistLightning"   ;STATE_RESISTLIGHTNING
        case 9: return "AmplifyDamage"   ;STATE_AMPLIFYDAMAGE
        case 10: return "FrozenArmor"   ;STATE_FROZENARMOR
        case 11: return "Cold"   ;STATE_COLD
        case 12: return "Inferno"   ;STATE_INFERNO
        case 13: return "Blaze"   ;STATE_BLAZE
        case 14: return "BoneArmor"   ;STATE_BONEARMOR
        case 16: return "Enchant"   ;STATE_ENCHANT
        case 17: return "InnerSight"   ;STATE_INNERSIGHT
        case 19: return "Weaken"   ;STATE_WEAKEN
        case 20: return "ChillingArmor"   ;STATE_CHILLINGARMOR
        case 23: return "DimVision"   ;STATE_DIMVISION
        case 24: return "Slowed"   ;STATE_SLOWED
        case 26: return "Shout"   ;STATE_SHOUT
        case 28: return "Conviction"   ;STATE_CONVICTION
        case 28: return "CriticalStrike"   ;STATE_CONVICTION
        case 29: return "Convicted"   ;STATE_CONVICTED
        case 30: return "EnergyShield"   ;STATE_ENERGYSHIELD
        case 31: return "VenomClaws"   ;STATE_VENOMCLAWS
        case 32: return "BattleOrders"   ;STATE_BATTLEORDERS
        case 33: return "Might"   ;STATE_MIGHT
        case 34: return "Prayer"   ;STATE_PRAYER
        case 35: return "HolyFire"   ;STATE_HOLYFIRE
        case 36: return "Thorns"   ;STATE_THORNS
        case 37: return "Defiance"   ;STATE_DEFIANCE
        case 38: return "ThunderStorm"   ;STATE_THUNDERSTORM
        case 40: return "BlessedAim"   ;STATE_BLESSEDAIM
        case 41: return "Stamina"   ;STATE_STAMINA
        case 42: return "Concentration"   ;STATE_CONCENTRATION
        case 43: return "HolyWind"   ;STATE_HOLYWIND
        case 45: return "Cleansing"   ;STATE_CLEANSING
        case 46: return "HolyShock"   ;STATE_HOLYSHOCK
        case 47: return "Sanctuary"   ;STATE_SANCTUARY
        case 48: return "Meditation"   ;STATE_MEDITATION
        case 49: return "Fanaticism"   ;STATE_FANATICISM
        case 50: return "Redemption"   ;STATE_REDEMPTION
        case 51: return "BattleCommand"   ;STATE_BATTLECOMMAND
        case 53: return "Conversion"   ;STATE_CONVERSION
        case 55: return "IronMaiden"   ;STATE_IRONMAIDEN
        case 56: return "Terror"   ;STATE_TERROR
        case 57: return "Attract"   ;STATE_ATTRACT
        case 58: return "LifeTap"   ;STATE_LIFETAP
        case 59: return "Confuse"   ;STATE_CONFUSE
        case 60: return "Decrepify"   ;STATE_DECREPIFY
        case 61: return "LowerResist"   ;STATE_LOWERRESIST
        ;case 64: return "CycloneArmor"   ;STATE_CRITICALSTRIKE
        ;case 65: return "Dodge"   ;STATE_DODGE
        ;case 66: return "Avoid"   ;STATE_AVOID
        ;case 67: return "Penetrate"   ;STATE_PENETRATE
        ;case 68: return "Evade"   ;STATE_EVADE
        ;case 69: return "Pierce"   ;STATE_PIERCE
        ;case 70: return "Warmth"   ;STATE_WARMTH
        ;case 71: return "FireMastery"   ;STATE_FIREMASTERY
        ;case 72: return "LightningMastery"   ;STATE_LIGHTNINGMASTERY
        ;case 73: return "ColdMastery"   ;STATE_COLDMASTERY
        ;case 74: return "BladeMastery"   ;STATE_BLADEMASTERY
        ;case 75: return "AxeMastery"   ;STATE_AXEMASTERY
        ;case 76: return "MaceMastery"   ;STATE_MACEMASTERY
        ;case 77: return "PolearmMastery"   ;STATE_POLEARMMASTERY
        ;case 78: return "ThrowingMastery"   ;STATE_THROWINGMASTERY
        ;case 79: return "SpearMastery"   ;STATE_SPEARMASTERY
        ;case 80: return "IncreasedStamina"   ;STATE_INCREASEDSTAMINA
        ;case 81: return "IronSkin"   ;STATE_IRONSKIN
        ;case 82: return "IncreasedSpeed"   ;STATE_INCREASEDSPEED
        ;case 83: return "NaturalResistance"   ;STATE_NATURALRESISTANCE
        case 87: return "SlowMissiles"   ;STATE_SLOWMISSILES
        case 88: return "ShiverArmor"   ;STATE_SHIVERARMOR
        case 93: return "Valkyrie"   ;STATE_VALKYRIE
        case 94: return "Frenzy"   ;STATE_FRENZY
        case 95: return "Berserk"   ;STATE_BERSERK
        case 101: return "HolyShield"   ;STATE_HOLYSHIELD
        case 113: return "DefenseCurse"   ;STATE_DEFENSE_CURSE
        case 114: return "BloodMana"   ;STATE_BLOOD_MANA
        case 119: return "ShadowMaster"   ;STATE_SHADOWWARRIOR
        case 120: return "FeralRage"   ;STATE_FERALRAGE
        ;case 122: return "TigerStrike"   ;STATE_TIGERSTRIKE
        ;case 123: return "CobraStrike"   ;STATE_COBRASTRIKE
        ;case 124: return "PhoenixStrike"   ;STATE_PHOENIXSTRIKE
        ;case 125: return "FistsOfFire"   ;STATE_FISTSOFFIRE
        ;case 126: return "BladesOfIce"   ;STATE_BLADESOFICE
        ;case 127: return "ClawsOfThunder"   ;STATE_CLAWSOFTHUNDER
        ;case 138: return "FenrisRage"   ;STATE_FENRIS_RAGE
        case 139: return "Wolf"   ;STATE_WOLF
        case 140: return "Bear"   ;STATE_BEAR
        case 144: return "Hurricane"   ;STATE_HURRICANE
        case 145: return "Armageddon"   ;STATE_ARMAGEDDON
        case 147: return "Barbs"   ;STATE_BARBS
        case 148: return "Wolverine"   ;STATE_WOLVERINE
        case 149: return "OakSage"   ;STATE_OAKSAGE
        case 151: return "Decoy"   ;STATE_CYCLONEARMOR
        case 152: return "ClawMastery"   ;STATE_CLAWMASTERY
        case 153: return "CloakofShadows"   ;STATE_CLOAK_OF_SHADOWS
        ;case 155: return "WeaponBlock"   ;STATE_WEAPONBLOCK
        case 156: return "Cloaked"   ;STATE_CLOAKED
        case 157: return "Quickness"   ;STATE_QUICKNESS
        case 158: return "BladeShield"   ;STATE_BLADESHIELD
        case 159: return "Fade"   ;STATE_FADE
    }
}


