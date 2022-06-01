
ReadStates(ByRef d2rprocess, gameMemoryData, ByRef currentStates) {
    currentStates := []
    playerAddress := d2rprocess.BaseAddress + gameMemoryData["playerOffset"]
    playerPtr := d2rprocess.read(playerAddress, "Int64")
    if (playerPtr) {
        pStatsListEx := d2rprocess.read(playerPtr + 0x88, "Int64")
        stateByte1 := d2rprocess.read(pStatsListEx + 0xAC8, "UInt")
        stateByte2 := d2rprocess.read(pStatsListEx + 0xAC8 + 4, "UInt")
        stateByte3 := d2rprocess.read(pStatsListEx + 0xAC8 + 8, "UInt")
        stateByte4 := d2rprocess.read(pStatsListEx + 0xAC8 + 12, "UInt")
        stateByte5 := d2rprocess.read(pStatsListEx + 0xAC8 + 16, "UInt")
        stateByte6 := d2rprocess.read(pStatsListEx + 0xAC8 + 20, "UInt")

        stats1 := calculateState(stateByte1, -1)
        stats2 := calculateState(stateByte2, 31)
        stats3 := calculateState(stateByte3, 63)
        stats4 := calculateState(stateByte4, 95)
        stats5 := calculateState(stateByte5, 127)
        stats6 := calculateState(stateByte6, 159)
        
        
        for k, stat in stats1
            currentStates.push({ "stateNum": stat, "stateName": getStateName(stat) })
        for k, stat in stats2
            currentStates.push({ "stateNum": stat, "stateName": getStateName(stat) })
        for k, stat in stats3
            currentStates.push({ "stateNum": stat, "stateName": getStateName(stat) })
        for k, stat in stats4
            currentStates.push({ "stateNum": stat, "stateName": getStateName(stat) })
        for k, stat in stats5
            currentStates.push({ "stateNum": stat, "stateName": getStateName(stat) })
        for k, stat in stats6
            currentStates.push({ "stateNum": stat, "stateName": getStateName(stat) })
    }
}

calculateState(stateFlag, offset := 0) {
    flags := []
    if (0x00000001 & stateFlag) {
        flags.push(1 + offset)
    }
    if (0x00000002 & stateFlag) {
        flags.push(2 + offset)
    }
    if (0x00000004 & stateFlag) {
        flags.push(3 + offset)
    }
    if (0x00000008 & stateFlag) {
        flags.push(4 + offset)
    }
    if (0x00000010 & stateFlag) {
        flags.push(5 + offset)
    }
    if (0x00000020 & stateFlag) {
        flags.push(6 + offset)
    }
    if (0x00000040 & stateFlag) {
        flags.push(7 + offset)
    }
    if (0x00000080 & stateFlag) {
        flags.push(8 + offset)
    }
    if (0x00000100 & stateFlag) {
        flags.push(9 + offset)
    }
    if (0x00000200 & stateFlag) {
        flags.push(10 + offset)
    }
    if (0x00000400 & stateFlag) {
        flags.push(11 + offset)
    }
    if (0x00000800 & stateFlag) {
        flags.push(12 + offset)
    }
    if (0x00001000 & stateFlag) {
        flags.push(13 + offset)
    }
    if (0x00002000 & stateFlag) {
        flags.push(14 + offset)
    }
    if (0x00004000 & stateFlag) {
        flags.push(15 + offset)
    }
    if (0x00008000 & stateFlag) {
        flags.push(16 + offset)
    }
    if (0x00010000 & stateFlag) {
        flags.push(17 + offset)
    }
    if (0x00020000 & stateFlag) {
        flags.push(18 + offset)
    }
    if (0x00040000 & stateFlag) {
        flags.push(19 + offset)
    }
    if (0x00080000 & stateFlag) {
        flags.push(20 + offset)
    }
    if (0x00100000 & stateFlag) {
        flags.push(21 + offset)
    }
    if (0x00200000 & stateFlag) {
        flags.push(22 + offset)
    }
    if (0x00400000 & stateFlag) {
        flags.push(23 + offset)
    }
    if (0x00800000 & stateFlag) {
        flags.push(24 + offset)
    }
    if (0x01000000 & stateFlag) {
        flags.push(25 + offset)
    }
    if (0x02000000 & stateFlag) {
        flags.push(26 + offset)
    }
    if (0x04000000 & stateFlag) {
        flags.push(27 + offset)
    }
    if (0x08000000 & stateFlag) {
        flags.push(28 + offset)
    }
    if (0x10000000 & stateFlag) {
        flags.push(29 + offset)
    }
    if (0x20000000 & stateFlag) {
        flags.push(30 + offset)
    }
    if (0x40000000 & stateFlag) {
        flags.push(31 + offset)
    }
    if (0x80000000 & stateFlag) {
        flags.push(32 + offset)
    }
    return flags
    ; sep := ","
    ; for index,param in flags
    ;     str .= sep . (param + offset)
    ; flagsText := SubStr(str, StrLen(sep)+1)
    ; return flagsText
    
}

getStateName(stateNum) {
    switch (stateNum) {
        case 0: return "STATE_NONE"
        case 1: return "STATE_FREEZE"
        case 2: return "STATE_POISON"
        case 3: return "STATE_RESISTFIRE"
        case 4: return "STATE_RESISTCOLD"
        case 5: return "STATE_RESISTLIGHTNING"
        case 6: return "STATE_RESISTMAGIC"
        case 7: return "STATE_PLAYERBODY"
        case 8: return "STATE_RESISTALL"
        case 9: return "STATE_AMPLIFYDAMAGE"
        case 10: return "STATE_FROZENARMOR"
        case 11: return "STATE_COLD"
        case 12: return "STATE_INFERNO"
        case 13: return "STATE_BLAZE"
        case 14: return "STATE_BONEARMOR"
        case 15: return "STATE_CONCENTRATE"
        case 16: return "STATE_ENCHANT"
        case 17: return "STATE_INNERSIGHT"
        case 18: return "STATE_SKILL_MOVE"
        case 19: return "STATE_WEAKEN"
        case 20: return "STATE_CHILLINGARMOR"
        case 21: return "STATE_STUNNED"
        case 22: return "STATE_SPIDERLAY"
        case 23: return "STATE_DIMVISION"
        case 24: return "STATE_SLOWED"
        case 25: return "STATE_FETISHAURA"
        case 26: return "STATE_SHOUT"
        case 27: return "STATE_TAUNT"
        case 28: return "STATE_CONVICTION"
        case 29: return "STATE_CONVICTED"
        case 30: return "STATE_ENERGYSHIELD"
        case 31: return "STATE_VENOMCLAWS"
        case 32: return "STATE_BATTLEORDERS"
        case 33: return "STATE_MIGHT"
        case 34: return "STATE_PRAYER"
        case 35: return "STATE_HOLYFIRE"
        case 36: return "STATE_THORNS"
        case 37: return "STATE_DEFIANCE"
        case 38: return "STATE_THUNDERSTORM"
        case 39: return "STATE_LIGHTNINGBOLT"
        case 40: return "STATE_BLESSEDAIM"
        case 41: return "STATE_STAMINA"
        case 42: return "STATE_CONCENTRATION"
        case 43: return "STATE_HOLYWIND"
        case 44: return "STATE_HOLYWINDCOLD"
        case 45: return "STATE_CLEANSING"
        case 46: return "STATE_HOLYSHOCK"
        case 47: return "STATE_SANCTUARY"
        case 48: return "STATE_MEDITATION"
        case 49: return "STATE_FANATICISM"
        case 50: return "STATE_REDEMPTION"
        case 51: return "STATE_BATTLECOMMAND"
        case 52: return "STATE_PREVENTHEAL"
        case 53: return "STATE_CONVERSION"
        case 54: return "STATE_UNINTERRUPTABLE"
        case 55: return "STATE_IRONMAIDEN"
        case 56: return "STATE_TERROR"
        case 57: return "STATE_ATTRACT"
        case 58: return "STATE_LIFETAP"
        case 59: return "STATE_CONFUSE"
        case 60: return "STATE_DECREPIFY"
        case 61: return "STATE_LOWERRESIST"
        case 62: return "STATE_OPENWOUNDS"
        case 63: return "STATE_DOPPLEZON"
        case 64: return "STATE_CRITICALSTRIKE"
        case 65: return "STATE_DODGE"
        case 66: return "STATE_AVOID"
        case 67: return "STATE_PENETRATE"
        case 68: return "STATE_EVADE"
        case 69: return "STATE_PIERCE"
        case 70: return "STATE_WARMTH"
        case 71: return "STATE_FIREMASTERY"
        case 72: return "STATE_LIGHTNINGMASTERY"
        case 73: return "STATE_COLDMASTERY"
        case 74: return "STATE_BLADEMASTERY"
        case 75: return "STATE_AXEMASTERY"
        case 76: return "STATE_MACEMASTERY"
        case 77: return "STATE_POLEARMMASTERY"
        case 78: return "STATE_THROWINGMASTERY"
        case 79: return "STATE_SPEARMASTERY"
        case 80: return "STATE_INCREASEDSTAMINA"
        case 81: return "STATE_IRONSKIN"
        case 82: return "STATE_INCREASEDSPEED"
        case 83: return "STATE_NATURALRESISTANCE"
        case 84: return "STATE_FINGERMAGECURSE"
        case 85: return "STATE_NOMANAREGEN"
        case 86: return "STATE_JUSTHIT"
        case 87: return "STATE_SLOWMISSILES"
        case 88: return "STATE_SHIVERARMOR"
        case 89: return "STATE_BATTLECRY"
        case 90: return "STATE_BLUE"
        case 91: return "STATE_RED"
        case 92: return "STATE_DEATH_DELAY"
        case 93: return "STATE_VALKYRIE"
        case 94: return "STATE_FRENZY"
        case 95: return "STATE_BERSERK"
        case 96: return "STATE_REVIVE"
        case 97: return "STATE_ITEMFULLSET"
        case 98: return "STATE_SOURCEUNIT"
        case 99: return "STATE_REDEEMED"
        case 100: return "STATE_HEALTHPOT"
        case 101: return "STATE_HOLYSHIELD"
        case 102: return "STATE_JUST_PORTALED"
        case 103: return "STATE_MONFRENZY"
        case 104: return "STATE_CORPSE_NODRAW"
        case 105: return "STATE_ALIGNMENT"
        case 106: return "STATE_MANAPOT"
        case 107: return "STATE_SHATTER"
        case 108: return "STATE_SYNC_WARPED"
        case 109: return "STATE_CONVERSION_SAVE"
        case 110: return "STATE_PREGNANT"
        case 111: return "STATE_111"
        case 112: return "STATE_RABIES"
        case 113: return "STATE_DEFENSE_CURSE"
        case 114: return "STATE_BLOOD_MANA"
        case 115: return "STATE_BURNING"
        case 116: return "STATE_DRAGONFLIGHT"
        case 117: return "STATE_MAUL"
        case 118: return "STATE_CORPSE_NOSELECT"
        case 119: return "STATE_SHADOWWARRIOR"
        case 120: return "STATE_FERALRAGE"
        case 121: return "STATE_SKILLDELAY"
        case 122: return "STATE_TIGERSTRIKE"
        case 123: return "STATE_COBRASTRIKE"
        case 124: return "STATE_PHOENIXSTRIKE"
        case 125: return "STATE_FISTSOFFIRE"
        case 126: return "STATE_BLADESOFICE"
        case 127: return "STATE_CLAWSOFTHUNDER"
        case 128: return "STATE_SHRINE_ARMOR"
        case 129: return "STATE_SHRINE_COMBAT"
        case 130: return "STATE_SHRINE_RESIST_LIGHTNING"
        case 131: return "STATE_SHRINE_RESIST_FIRE"
        case 132: return "STATE_SHRINE_RESIST_COLD"
        case 133: return "STATE_SHRINE_RESIST_POISON"
        case 134: return "STATE_SHRINE_SKILL"
        case 135: return "STATE_SHRINE_MANA_REGEN"
        case 136: return "STATE_SHRINE_STAMINA"
        case 137: return "STATE_SHRINE_EXPERIENCE"
        case 138: return "STATE_FENRIS_RAGE"
        case 139: return "STATE_WOLF"
        case 140: return "STATE_BEAR"
        case 141: return "STATE_BLOODLUST"
        case 142: return "STATE_CHANGECLASS"
        case 143: return "STATE_ATTACHED"
        case 144: return "STATE_HURRICANE"
        case 145: return "STATE_ARMAGEDDON"
        case 146: return "STATE_INVIS"
        case 147: return "STATE_BARBS"
        case 148: return "STATE_WOLVERINE"
        case 149: return "STATE_OAKSAGE"
        case 150: return "STATE_VINE_BEAST"
        case 151: return "STATE_CYCLONEARMOR"
        case 152: return "STATE_CLAWMASTERY"
        case 153: return "STATE_CLOAK_OF_SHADOWS"
        case 154: return "STATE_RECYCLED"
        case 155: return "STATE_WEAPONBLOCK"
        case 156: return "STATE_CLOAKED"
        case 157: return "STATE_QUICKNESS"
        case 158: return "STATE_BLADESHIELD"
        case 159: return "STATE_FADE"
        case 160: return "STATE_SUMMONRESIST"
        case 161: return "STATE_OAKSAGECONTROL"
        case 162: return "STATE_WOLVERINECONTROL"
        case 163: return "STATE_BARBSCONTROL"
        case 164: return "STATE_DEBUGCONTROL"
        case 165: return "STATE_ITEMSET1"
        case 166: return "STATE_ITEMSET2"
        case 167: return "STATE_ITEMSET3"
        case 168: return "STATE_ITEMSET4"
        case 169: return "STATE_ITEMSET5"
        case 170: return "STATE_ITEMSET6"
        case 171: return "STATE_RUNEWORD"
        case 172: return "STATE_RESTINPEACE"
        case 173: return "STATE_CORPSEEXP"
        case 174: return "STATE_WHIRLWIND"
        case 175: return "STATE_FULLSETGENERIC"
        case 176: return "STATE_MONSTERSET"
        case 177: return "STATE_DELERIUM"
        case 178: return "STATE_ANTIDOTE"
        case 179: return "STATE_THAWING"
        case 180: return "STATE_STAMINAPOT"
        case 181: return "STATE_PASSIVE_RESISTFIRE"
        case 182: return "STATE_PASSIVE_RESISTCOLD"
        case 183: return "STATE_PASSIVE_RESISTLTNG"
        case 184: return "STATE_UBERMINION"
        case 185: return "STATE_COOLDOWN"
        case 186: return "STATE_SHAREDSTASH"
        case 187: return "STATE_HIDEDEAD"
    }
}