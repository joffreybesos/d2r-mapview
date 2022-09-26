class GameItem {

    txtFileNo := 0
    itemCode := ""

    qualityNo := 0
    name := ""
    localizedName := ""
    prefixName := ""
    itemLoc := 0
    quality := ""
    itemx := 0
    itemy := 0
    isSocketed := false 
    numSockets := 0
    statCount := 0
    statBuffer := 
    statList := ""
    
    inStore := false
    identified := false
    ethereal := false

    __new(txtFileNo, qualityNo, uniqueOrSetId := 0) {
        this.txtFileNo := txtFileNo
        this.qualityNo := qualityNo
        this.uniqueOrSetId := uniqueOrSetId
        this.name := getItemBaseName(txtFileNo)
        this.setQuality(qualityNo)
        
        this.localizedName := this.getLocalizedName(txtFileNo)
        
        if (this.quality == "Set") {
            
            itemCode := this.getItemCode(txtFileNo)
            if (this.uniqueOrSetId) {
                setname := this.setNameFromId(uniqueOrSetId)
            } else {
                setname := this.getSetItemName(itemCode)
            }
            if (setname) {
                this.prefixName := setname
            }
            
        } else if (this.quality == "Unique") {
            itemCode := this.getItemCode(txtFileNo)
            if (this.uniqueOrSetId) {
                uniquename := this.uniqueNameFromId(uniqueOrSetId)
            } else {  
                uniquename := this.getUniqueItemName(itemCode)
            }
            if (uniqueName) {
                this.prefixName := uniqueName
            }
        }
    }

    isGem() {
        if ((this.txtFileNo >= 557 and this.txtFileNo <= 586) or (this.txtFileNo >= 597 and this.txtFileNo <= 601)) {
            return true
        }
        return false
    }

    isRune() {
        if (this.txtFileNo >= 629 and this.txtFileNo <= 642) {
            return true
        }
        return false
    }

    getHash() {
        return this.txtFileNo "-" this.itemx "-" this.itemy
    }

    getTextToSpeech() {
        quality := this.getLocalizedQuality(this.qualityNo)
        if (this.qualityNo == 2)
            quality := ""

        if (this.ethereal) {
            quality := quality " " localizedStrings["quality10"]
        }
        itemName := this.prefixName " " this.localizedName
        sockets := ""
        if (this.numSockets > 0) {
            sockets := this.getLocalizedSockets(this.numSockets)
        }
        
        speechString := quality " " itemName " " sockets
        return speechString
    }

    getNumSockets() {
        if (this.isSocketed and this.numSockets == 0) {
            this.numSockets := this.getSocketsFromStats()
        }
        return this.numSockets
    }

    loadStats() {
        this.statList := loadStats(this.statCount, this.statPtr, this.statExCount, this.statExPtr)
    }

    ; using separate function for numsockets for performance
    getSocketsFromStats() {
        SetFormat Integer, D
        statCount := this.statCount
        d2rprocess.readRaw(this.statPtr, statBuffer, statCount*10)
        Loop, %statCount%
        {
            offset := (A_Index -1) * 8
            , statLayer := NumGet(&statBuffer, offset, Type := "Short")
            , statEnum := NumGet(&statBuffer, offset + 0x2, Type := "UShort")
            , statValue := NumGet(&statBuffer , offset + 0x4, Type := "Int")
            switch (statEnum) {
                case 194: return statValue
            }
        }
        statExCount := this.statExCount
        d2rprocess.readRaw(this.statExPtr, statBuffer, statExCount*10)
        Loop, %statExCount%
        {
            offset := (A_Index -1) * 8
            , statLayer := NumGet(&statBuffer, offset, Type := "Short")
            , statEnum := NumGet(&statBuffer, offset + 0x2, Type := "UShort")
            , statValue := NumGet(&statBuffer , offset + 0x4, Type := "Int")
            switch (statEnum) {
                case 194: return statValue
            }
        }
    }

    toString() {
        return "txtFileNo: " this.txtFileNo ", name: " this.name ", itemLoc: " this.itemLoc ", quality: " this.quality ", isRune: " this.isRune() ", id: " this.identified ", eth: " this.ethereal ", itemx: " this.itemx ", itemy: " this.itemy
    }

    

    calculateFlags(flags) {
        flagsList := []
        SetFormat Integer, H
        hexFlags := flags + 0
        SetFormat Integer, D

        ; if (0x00000002 & flags) {  ; IFLAG_TARGET
        ;     ; flagsList.push("IFLAG_TARGET") 
        ; }
        ; if (0x00000004 & flags) {  ; IFLAG_TARGETING
        ;     ; flagsList.push("IFLAG_TARGETING") 
        ; }
        ; if (0x00000008 & flags) {  ; IFLAG_TARGET
        ;     ; flagsList.push("IFLAG_TARGET") 
        ; }
        if (0x00000010 & flags) { ; IFLAG_IDENTIFIED
            this.identified := true
        }
        ; if (0x00000020 & flags) {  ; IFLAG_QUANTITY
        ;     ; flagsList.push("IFLAG_QUANTITY") 
        ; }
        ; if (0x00000040 & flags) {  ; IFLAG_SWITCHIN
        ;     ; flagsList.push("IFLAG_SWITCHIN") 
        ; }
        ; if (0x00000080 & flags) {  ; IFLAG_SWITCHOUT
        ;     ; flagsList.push("IFLAG_SWITCHOUT") 
        ; }
        ; if (0x00000100 & flags) {  ; IFLAG_BROKEN
        ;     ; flagsList.push("IFLAG_BROKEN") 
        ; }
        ; if (0x00000200 & flags) {  ; IFLAG_REPAIRED
        ;     ; flagsList.push("IFLAG_REPAIRED") 
        ; }
        ; if (0x00000400 & flags) {  ; IFLAG_UNK1
        ;     ; flagsList.push("IFLAG_UNK1") 
        ; }
        if (0x00000800 & flags) {  ; IFLAG_SOCKETED
            this.isSocketed := true
        }
        ;     ; flagsList.push("IFLAG_SOCKETED") 
        ; }
        ; if (0x00001000 & flags) {  ; IFLAG_NOSELL
        ;     ; flagsList.push("IFLAG_NOSELL") 
        ; }
        if (0x00002000 & flags) {  ; IFLAG_INSTORE
            ;this.inStore := true
        }
        ; if (0x00004000 & flags) {  ; IFLAG_NOEQUIP
        ;     ; flagsList.push("IFLAG_NOEQUIP") 
        ; }
        ; if (0x00008000 & flags) {  ; IFLAG_NAMED
        ;     ; flagsList.push("IFLAG_NAMED")
        ; } 
        ; if (0x00010000 & flags) {  ; IFLAG_ISEAR
        ;     ; flagsList.push("IFLAG_ISEAR") 
        ; }
        ; ; if (0x00020000 & flags) { ; IFLAG_STARTITEM
        ; ;     flagsList.push("IFLAG_STARTITEM") 
        ; }  
        ; if (0x00080000 & flags)  { ; IFLAG_INIT
        ;     ; flagsList.push("IFLAG_INIT") 
        ; }
        if (0x00400000 & flags) { ; IFLAG_ETHEREAL
            this.ethereal := true 
        }
        ; if (0x01000000 & flags) { ; IFLAG_PERSONALIZED
        ;     ; flagsList.push("IFLAG_PERSONALIZED") 
        ; }
        ; if (0x02000000 & flags) { ; IFLAG_LOWQUALITY
        ;     ; flagsList.push("IFLAG_LOWQUALITY") 
        ; }
        ; if (0x04000000 & flags) { ; IFLAG_RUNEWORD
        ;     this.runeword := true
        ; }
        ; if (0x08000000 & flags) { ; IFLAG_ITEM
        ;     ; flagsList.push("IFLAG_ITEM") 
        ; }

        ; sep := ","
        ; for index,param in flagsList
        ;     str .= sep . param
        ; flagsText := SubStr(str, StrLen(sep)+1)
        ; return flagsText
    }

    setQuality(qualityNo) {
        switch (qualityNo) {
            case 1: this.quality := "Inferior"
            case 2: this.quality := "Normal"
            case 3: this.quality := "Superior"
            case 4: this.quality := "Magic"
            case 5: this.quality := "Set"
            case 6: this.quality := "Rare"
            case 7: this.quality := "Unique"
            case 8: this.quality := "Crafted"
            case 9: this.quality := "Tempered"
            default: this.quality := ""
        }
    }

    getLocalizedQuality(qualityNo) {
        qualityStrName := "quality" qualityNo
        return localizedStrings[qualityStrName]
    }
    getLocalizedSockets(socketNum) {
        socketStrName := "sockets" socketNum
        return localizedStrings[socketStrName]
    } 

    setNamefromId(uniqueOrSetId) {
        switch (uniqueOrSetId) {
            case 0: return localizedStrings["Civerb's Ward"]
            case 1: return localizedStrings["Civerb's Icon"]
            case 2: return localizedStrings["Civerb's Cudgel"]
            case 3: return localizedStrings["Hsarus' Iron Heel"]
            case 4: return localizedStrings["Hsarus' Iron Fist"]
            case 5: return localizedStrings["Hsarus' Iron Stay"]
            case 6: return localizedStrings["Cleglaw's Tooth"]
            case 7: return localizedStrings["Cleglaw's Claw"]
            case 8: return localizedStrings["Cleglaw's Pincers"]
            case 9: return localizedStrings["Iratha's Collar"]
            case 10: return localizedStrings["Iratha's Cuff"]
            case 11: return localizedStrings["Iratha's Coil"]
            case 12: return localizedStrings["Iratha's Cord"]
            case 13: return localizedStrings["Isenhart's Lightbrand"]
            case 14: return localizedStrings["Isenhart's Parry"]
            case 15: return localizedStrings["Isenhart's Case"]
            case 16: return localizedStrings["Isenhart's Horns"]
            case 17: return localizedStrings["Vidala's Barb"]
            case 18: return localizedStrings["Vidala's Fetlock"]
            case 19: return localizedStrings["Vidala's Ambush"]
            case 20: return localizedStrings["Vidala's Snare"]
            case 21: return localizedStrings["Milabrega's Orb"]
            case 22: return localizedStrings["Milabrega's Rod"]
            case 23: return localizedStrings["Milabrega's Diadem"]
            case 24: return localizedStrings["Milabrega's Robe"]
            case 25: return localizedStrings["Cathan's Rule"]
            case 26: return localizedStrings["Cathan's Mesh"]
            case 27: return localizedStrings["Cathan's Visage"]
            case 28: return localizedStrings["Cathan's Sigil"]
            case 29: return localizedStrings["Cathan's Seal"]
            case 30: return localizedStrings["Tancred's Crowbill"]
            case 31: return localizedStrings["Tancred's Spine"]
            case 32: return localizedStrings["Tancred's Hobnails"]
            case 33: return localizedStrings["Tancred's Weird"]
            case 34: return localizedStrings["Tancred's Skull"]
            case 35: return localizedStrings["Sigon's Gage"]
            case 36: return localizedStrings["Sigon's Visor"]
            case 37: return localizedStrings["Sigon's Shelter"]
            case 38: return localizedStrings["Sigon's Sabot"]
            case 39: return localizedStrings["Sigon's Wrap"]
            case 40: return localizedStrings["Sigon's Guard"]
            case 41: return localizedStrings["Infernal Cranium"]
            case 42: return localizedStrings["Infernal Torch"]
            case 43: return localizedStrings["Infernal Sign"]
            case 44: return localizedStrings["Berserker's Headgear"]
            case 45: return localizedStrings["Berserker's Hauberk"]
            case 46: return localizedStrings["Berserker's Hatchet"]
            case 47: return localizedStrings["Death's Hand"]
            case 48: return localizedStrings["Death's Guard"]
            case 49: return localizedStrings["Death's Touch"]
            case 50: return localizedStrings["Angelic Sickle"]
            case 51: return localizedStrings["Angelic Mantle"]
            case 52: return localizedStrings["Angelic Halo"]
            case 53: return localizedStrings["Angelic Wings"]
            case 54: return localizedStrings["Arctic Horn"]
            case 55: return localizedStrings["Arctic Furs"]
            case 56: return localizedStrings["Arctic Binding"]
            case 57: return localizedStrings["Arctic Mitts"]
            case 58: return localizedStrings["Arcanna's Sign"]
            case 59: return localizedStrings["Arcanna's Deathwand"]
            case 60: return localizedStrings["Arcanna's Head"]
            case 61: return localizedStrings["Arcanna's Flesh"]
            case 62: return localizedStrings["Natalya's Totem"]
            case 63: return localizedStrings["Natalya's Mark"]
            case 64: return localizedStrings["Natalya's Shadow"]
            case 65: return localizedStrings["Natalya's Soul"]
            case 66: return localizedStrings["Aldur's Stony Gaze"]
            case 67: return localizedStrings["Aldur's Deception"]
            case 68: return localizedStrings["Aldur's Gauntlet"]
            case 69: return localizedStrings["Aldur's Advance"]
            case 70: return localizedStrings["Immortal King's Will"]
            case 71: return localizedStrings["Immortal King's Soul Cage"]
            case 72: return localizedStrings["Immortal King's Detail"]
            case 73: return localizedStrings["Immortal King's Forge"]
            case 74: return localizedStrings["Immortal King's Pillar"]
            case 75: return localizedStrings["Immortal King's Stone Crusher"]
            case 76: return localizedStrings["Tal Rasha's Fire-Spun Cloth"]
            case 77: return localizedStrings["Tal Rasha's Adjudication"]
            case 78: return localizedStrings["Tal Rasha's Lidless Eye"]
            case 79: return localizedStrings["Tal Rasha's Howling Wind"]
            case 80: return localizedStrings["Tal Rasha's Horadric Crest"]
            case 81: return localizedStrings["Griswold's Valor"]
            case 82: return localizedStrings["Griswold's Heart"]
            case 83: return localizedStrings["Griswolds's Redemption"]
            case 84: return localizedStrings["Griswold's Honor"]
            case 85: return localizedStrings["Trang-Oul's Guise"]
            case 86: return localizedStrings["Trang-Oul's Scales"]
            case 87: return localizedStrings["Trang-Oul's Wing"]
            case 88: return localizedStrings["Trang-Oul's Claws"]
            case 89: return localizedStrings["Trang-Oul's Girth"]
            case 90: return localizedStrings["M'avina's True Sight"]
            case 91: return localizedStrings["M'avina's Embrace"]
            case 92: return localizedStrings["M'avina's Icy Clutch"]
            case 93: return localizedStrings["M'avina's Tenet"]
            case 94: return localizedStrings["M'avina's Caster"]
            case 95: return localizedStrings["Telling of Beads"]
            case 96: return localizedStrings["Laying of Hands"]
            case 97: return localizedStrings["Rite of Passage"]
            case 98: return localizedStrings["Spiritual Custodian"]
            case 99: return localizedStrings["Credendum"]
            case 100: return localizedStrings["Dangoon's Teaching"]
            case 101: return localizedStrings["Heaven's Taebaek"]
            case 102: return localizedStrings["Haemosu's Adament"]
            case 103: return localizedStrings["Ondal's Almighty"]
            case 104: return localizedStrings["Guillaume's Face"]
            case 105: return localizedStrings["Wilhelm's Pride"]
            case 106: return localizedStrings["Magnus' Skin"]
            case 107: return localizedStrings["Wihtstan's Guard"]
            case 108: return localizedStrings["Hwanin's Splendor"]
            case 109: return localizedStrings["Hwanin's Refuge"]
            case 110: return localizedStrings["Hwanin's Seal"]
            case 111: return localizedStrings["Hwanin's Justice"]
            case 112: return localizedStrings["Sazabi's Cobalt Redeemer"]
            case 113: return localizedStrings["Sazabi's Ghost Liberator"]
            case 114: return localizedStrings["Sazabi's Mental Sheath"]
            case 115: return localizedStrings["Bul-Kathos' Sacred Charge"]
            case 116: return localizedStrings["Bul-Kathos' Tribal Guardian"]
            case 117: return localizedStrings["Cow King's Horns"]
            case 118: return localizedStrings["Cow King's Hide"]
            case 119: return localizedStrings["Cow King's Hoofs"]
            case 120: return localizedStrings["Naj's Puzzler"]
            case 121: return localizedStrings["Naj's Light Plate"]
            case 122: return localizedStrings["Naj's Circlet"]
            case 123: return localizedStrings["McAuley's Paragon"]
            case 124: return localizedStrings["McAuley's Riprap"]
            case 125: return localizedStrings["McAuley's Taboo"]
            case 126: return localizedStrings["McAuley's Superstition"]
        }
    }

    uniqueNamefromId(uniqueOrSetId) {
        switch (uniqueOrSetId) {
            case 0: return localizedStrings["The Gnasher"]
            case 1: return localizedStrings["Deathspade"]
            case 2: return localizedStrings["Bladebone"]
            case 3: return localizedStrings["Mindrend"]
            case 4: return localizedStrings["Rakescar"]
            case 5: return localizedStrings["Fechmars Axe"]
            case 6: return localizedStrings["Goreshovel"]
            case 7: return localizedStrings["The Chieftan"]
            case 8: return localizedStrings["Brainhew"]
            case 9: return localizedStrings["The Humongous"]
            case 10: return localizedStrings["Iros Torch"]
            case 11: return localizedStrings["Maelstromwrath"]
            case 12: return localizedStrings["Gravenspine"]
            case 13: return localizedStrings["Umes Lament"]
            case 14: return localizedStrings["Felloak"]
            case 15: return localizedStrings["Knell Striker"]
            case 16: return localizedStrings["Rusthandle"]
            case 17: return localizedStrings["Stormeye"]
            case 18: return localizedStrings["Stoutnail"]
            case 19: return localizedStrings["Crushflange"]
            case 20: return localizedStrings["Bloodrise"]
            case 21: return localizedStrings["The Generals Tan Do Li Ga"]
            case 22: return localizedStrings["Ironstone"]
            case 23: return localizedStrings["Bonesob"]
            case 24: return localizedStrings["Steeldriver"]
            case 25: return localizedStrings["Rixots Keen"]
            case 26: return localizedStrings["Blood Crescent"]
            case 27: return localizedStrings["Krintizs Skewer"]
            case 28: return localizedStrings["Gleamscythe"]
            case 29: return localizedStrings["Azurewrath"]
            case 30: return localizedStrings["Griswolds Edge"]
            case 31: return localizedStrings["Hellplague"]
            case 32: return localizedStrings["Culwens Point"]
            case 33: return localizedStrings["Shadowfang"]
            case 34: return localizedStrings["Soulflay"]
            case 35: return localizedStrings["Kinemils Awl"]
            case 36: return localizedStrings["Blacktongue"]
            case 37: return localizedStrings["Ripsaw"]
            case 38: return localizedStrings["The Patriarch"]
            case 39: return localizedStrings["Gull"]
            case 40: return localizedStrings["The Diggler"]
            case 41: return localizedStrings["The Jade Tan Do"]
            case 42: return localizedStrings["Irices Shard"]
            case 43: return localizedStrings["The Dragon Chang"]
            case 44: return localizedStrings["Razortine"]
            case 45: return localizedStrings["Bloodthief"]
            case 46: return localizedStrings["Lance of Yaggai"]
            case 47: return localizedStrings["The Tannr Gorerod"]
            case 48: return localizedStrings["Dimoaks Hew"]
            case 49: return localizedStrings["Steelgoad"]
            case 50: return localizedStrings["Soul Harvest"]
            case 51: return localizedStrings["The Battlebranch"]
            case 52: return localizedStrings["Woestave"]
            case 53: return localizedStrings["The Grim Reaper"]
            case 54: return localizedStrings["Bane Ash"]
            case 55: return localizedStrings["Serpent Lord"]
            case 56: return localizedStrings["Lazarus Spire"]
            case 57: return localizedStrings["The Salamander"]
            case 58: return localizedStrings["The Iron Jang Bong"]
            case 59: return localizedStrings["Pluckeye"]
            case 60: return localizedStrings["Witherstring"]
            case 61: return localizedStrings["Rimeraven"]
            case 62: return localizedStrings["Piercerib"]
            case 63: return localizedStrings["Pullspite"]
            case 64: return localizedStrings["Wizendraw"]
            case 65: return localizedStrings["Hellclap"]
            case 66: return localizedStrings["Blastbark"]
            case 67: return localizedStrings["Leadcrow"]
            case 68: return localizedStrings["Ichorsting"]
            case 69: return localizedStrings["Hellcast"]
            case 70: return localizedStrings["Doomspittle"]
            case 71: return localizedStrings["War Bonnet"]
            case 72: return localizedStrings["Tarnhelm"]
            case 73: return localizedStrings["Coif of Glory"]
            case 74: return localizedStrings["Duskdeep"]
            case 75: return localizedStrings["Wormskull"]
            case 76: return localizedStrings["Howltusk"]
            case 77: return localizedStrings["Undead Crown"]
            case 78: return localizedStrings["The Face of Horror"]
            case 79: return localizedStrings["Greyform"]
            case 80: return localizedStrings["Blinkbats Form"]
            case 81: return localizedStrings["The Centurion"]
            case 82: return localizedStrings["Twitchthroe"]
            case 83: return localizedStrings["Darkglow"]
            case 84: return localizedStrings["Hawkmail"]
            case 85: return localizedStrings["Sparking Mail"]
            case 86: return localizedStrings["Venomsward"]
            case 87: return localizedStrings["Iceblink"]
            case 88: return localizedStrings["Boneflesh"]
            case 89: return localizedStrings["Rockfleece"]
            case 90: return localizedStrings["Rattlecage"]
            case 91: return localizedStrings["Goldskin"]
            case 92: return localizedStrings["Victors Silk"]
            case 93: return localizedStrings["Heavenly Garb"]
            case 94: return localizedStrings["Pelta Lunata"]
            case 95: return localizedStrings["Umbral Disk"]
            case 96: return localizedStrings["Stormguild"]
            case 97: return localizedStrings["Wall of the Eyeless"]
            case 98: return localizedStrings["Swordback Hold"]
            case 99: return localizedStrings["Steelclash"]
            case 100: return localizedStrings["Bverrit Keep"]
            case 101: return localizedStrings["The Ward"]
            case 102: return localizedStrings["The Hand of Broc"]
            case 103: return localizedStrings["Bloodfist"]
            case 104: return localizedStrings["Chance Guards"]
            case 105: return localizedStrings["Magefist"]
            case 106: return localizedStrings["Frostburn"]
            case 107: return localizedStrings["Hotspur"]
            case 108: return localizedStrings["Gorefoot"]
            case 109: return localizedStrings["Treads of Cthon"]
            case 110: return localizedStrings["Goblin Toe"]
            case 111: return localizedStrings["Tearhaunch"]
            case 112: return localizedStrings["Lenyms Cord"]
            case 113: return localizedStrings["Snakecord"]
            case 114: return localizedStrings["Nightsmoke"]
            case 115: return localizedStrings["Goldwrap"]
            case 116: return localizedStrings["Bladebuckle"]
            case 117: return localizedStrings["Nokozan Relic"]
            case 118: return localizedStrings["The Eye of Etlich"]
            case 119: return localizedStrings["The Mahim-Oak Curio"]
            case 120: return localizedStrings["Nagelring"]
            case 121: return localizedStrings["Manald Heal"]
            case 122: return localizedStrings["The Stone of Jordan"]
            case 123: return localizedStrings["Amulet of the Viper"]
            case 124: return localizedStrings["Staff of Kings"]
            case 125: return localizedStrings["Horadric Staff"]
            case 126: return localizedStrings["Hell Forge Hammer"]
            case 127: return localizedStrings["KhalimFlail"]
            case 128: return localizedStrings["SuperKhalimFlail"]
            case 129: return localizedStrings["Coldkill"]
            case 130: return localizedStrings["Butcher's Pupil"]
            case 131: return localizedStrings["Islestrike"]
            case 132: return localizedStrings["Pompe's Wrath"]
            case 133: return localizedStrings["Guardian Naga"]
            case 134: return localizedStrings["Warlord's Trust"]
            case 135: return localizedStrings["Spellsteel"]
            case 136: return localizedStrings["Stormrider"]
            case 137: return localizedStrings["Boneslayer Blade"]
            case 138: return localizedStrings["The Minataur"]
            case 139: return localizedStrings["Suicide Branch"]
            case 140: return localizedStrings["Carin Shard"]
            case 141: return localizedStrings["Arm of King Leoric"]
            case 142: return localizedStrings["Blackhand Key"]
            case 143: return localizedStrings["Dark Clan Crusher"]
            case 144: return localizedStrings["Zakarum's Hand"]
            case 145: return localizedStrings["The Fetid Sprinkler"]
            case 146: return localizedStrings["Hand of Blessed Light"]
            case 147: return localizedStrings["Fleshrender"]
            case 148: return localizedStrings["Sureshrill Frost"]
            case 149: return localizedStrings["Moonfall"]
            case 150: return localizedStrings["Baezil's Vortex"]
            case 151: return localizedStrings["Earthshaker"]
            case 152: return localizedStrings["Bloodtree Stump"]
            case 153: return localizedStrings["The Gavel of Pain"]
            case 154: return localizedStrings["Bloodletter"]
            case 155: return localizedStrings["Coldsteel Eye"]
            case 156: return localizedStrings["Hexfire"]
            case 157: return localizedStrings["Blade of Ali Baba"]
            case 158: return localizedStrings["Ginther's Rift"]
            case 159: return localizedStrings["Headstriker"]
            case 160: return localizedStrings["Plague Bearer"]
            case 161: return localizedStrings["The Atlantian"]
            case 162: return localizedStrings["Crainte Vomir"]
            case 163: return localizedStrings["Bing Sz Wang"]
            case 164: return localizedStrings["The Vile Husk"]
            case 165: return localizedStrings["Cloudcrack"]
            case 166: return localizedStrings["Todesfaelle Flamme"]
            case 167: return localizedStrings["Swordguard"]
            case 168: return localizedStrings["Spineripper"]
            case 169: return localizedStrings["Heart Carver"]
            case 170: return localizedStrings["Blackbog's Sharp"]
            case 171: return localizedStrings["Stormspike"]
            case 172: return localizedStrings["The Impaler"]
            case 173: return localizedStrings["Kelpie Snare"]
            case 174: return localizedStrings["Soulfeast Tine"]
            case 175: return localizedStrings["Hone Sundan"]
            case 176: return localizedStrings["Spire of Honor"]
            case 177: return localizedStrings["The Meat Scraper"]
            case 178: return localizedStrings["Blackleach Blade"]
            case 179: return localizedStrings["Athena's Wrath"]
            case 180: return localizedStrings["Pierre Tombale Couant"]
            case 181: return localizedStrings["Husoldal Evo"]
            case 182: return localizedStrings["Grim's Burning Dead"]
            case 183: return localizedStrings["Razorswitch"]
            case 184: return localizedStrings["Ribcracker"]
            case 185: return localizedStrings["Chromatic Ire"]
            case 186: return localizedStrings["Warpspear"]
            case 187: return localizedStrings["Skullcollector"]
            case 188: return localizedStrings["Skystrike"]
            case 189: return localizedStrings["Riphook"]
            case 190: return localizedStrings["Kuko Shakaku"]
            case 191: return localizedStrings["Endlesshail"]
            case 192: return localizedStrings["Whichwild String"]
            case 193: return localizedStrings["Cliffkiller"]
            case 194: return localizedStrings["Magewrath"]
            case 195: return localizedStrings["Godstrike Arch"]
            case 196: return localizedStrings["Langer Briser"]
            case 197: return localizedStrings["Pus Spiter"]
            case 198: return localizedStrings["Buriza-Do Kyanon"]
            case 199: return localizedStrings["Demon Machine"]
            case 201: return localizedStrings["Peasent Crown"]
            case 202: return localizedStrings["Rockstopper"]
            case 203: return localizedStrings["Stealskull"]
            case 204: return localizedStrings["Darksight Helm"]
            case 205: return localizedStrings["Valkiry Wing"]
            case 206: return localizedStrings["Crown of Thieves"]
            case 207: return localizedStrings["Blackhorn's Face"]
            case 208: return localizedStrings["Vampiregaze"]
            case 209: return localizedStrings["The Spirit Shroud"]
            case 210: return localizedStrings["Skin of the Vipermagi"]
            case 211: return localizedStrings["Skin of the Flayerd One"]
            case 212: return localizedStrings["Ironpelt"]
            case 213: return localizedStrings["Spiritforge"]
            case 214: return localizedStrings["Crow Caw"]
            case 215: return localizedStrings["Shaftstop"]
            case 216: return localizedStrings["Duriel's Shell"]
            case 217: return localizedStrings["Skullder's Ire"]
            case 218: return localizedStrings["Guardian Angel"]
            case 219: return localizedStrings["Toothrow"]
            case 220: return localizedStrings["Atma's Wail"]
            case 221: return localizedStrings["Black Hades"]
            case 222: return localizedStrings["Corpsemourn"]
            case 223: return localizedStrings["Que-Hegan's Wisdon"]
            case 224: return localizedStrings["Visceratuant"]
            case 225: return localizedStrings["Mosers Blessed Circle"]
            case 226: return localizedStrings["Stormchaser"]
            case 227: return localizedStrings["Tiamat's Rebuke"]
            case 228: return localizedStrings["Kerke's Sanctuary"]
            case 229: return localizedStrings["Radimant's Sphere"]
            case 230: return localizedStrings["Lidless Wall"]
            case 231: return localizedStrings["Lance Guard"]
            case 232: return localizedStrings["Venom Grip"]
            case 233: return localizedStrings["Gravepalm"]
            case 234: return localizedStrings["Ghoulhide"]
            case 235: return localizedStrings["Lavagout"]
            case 236: return localizedStrings["Hellmouth"]
            case 237: return localizedStrings["Infernostride"]
            case 238: return localizedStrings["Waterwalk"]
            case 239: return localizedStrings["Silkweave"]
            case 240: return localizedStrings["Wartraveler"]
            case 241: return localizedStrings["Gorerider"]
            case 242: return localizedStrings["String of Ears"]
            case 243: return localizedStrings["Razortail"]
            case 244: return localizedStrings["Gloomstrap"]
            case 245: return localizedStrings["Snowclash"]
            case 246: return localizedStrings["Thudergod's Vigor"]
            case 248: return localizedStrings["Harlequin Crest"]
            case 249: return localizedStrings["Veil of Steel"]
            case 250: return localizedStrings["The Gladiator's Bane"]
            case 251: return localizedStrings["Arkaine's Valor"]
            case 252: return localizedStrings["Blackoak Shield"]
            case 253: return localizedStrings["Stormshield"]
            case 254: return localizedStrings["Hellslayer"]
            case 255: return localizedStrings["Messerschmidt's Reaver"]
            case 256: return localizedStrings["Baranar's Star"]
            case 257: return localizedStrings["Schaefer's Hammer"]
            case 258: return localizedStrings["The Cranium Basher"]
            case 259: return localizedStrings["Lightsabre"]
            case 260: return localizedStrings["Doombringer"]
            case 261: return localizedStrings["The Grandfather"]
            case 262: return localizedStrings["Wizardspike"]
            case 263: return localizedStrings["Constricting Ring"]
            case 264: return localizedStrings["Stormspire"]
            case 265: return localizedStrings["Eaglehorn"]
            case 266: return localizedStrings["Windforce"]
            case 268: return localizedStrings["Bul Katho's Wedding Band"]
            case 269: return localizedStrings["The Cat's Eye"]
            case 270: return localizedStrings["The Rising Sun"]
            case 271: return localizedStrings["Crescent Moon"]
            case 272: return localizedStrings["Mara's Kaleidoscope"]
            case 273: return localizedStrings["Atma's Scarab"]
            case 274: return localizedStrings["Dwarf Star"]
            case 275: return localizedStrings["Raven Frost"]
            case 276: return localizedStrings["Highlord's Wrath"]
            case 277: return localizedStrings["Saracen's Chance"]
            case 279: return localizedStrings["Arreat's Face"]
            case 280: return localizedStrings["Homunculus"]
            case 281: return localizedStrings["Titan's Revenge"]
            case 282: return localizedStrings["Lycander's Aim"]
            case 283: return localizedStrings["Lycander's Flank"]
            case 284: return localizedStrings["The Oculus"]
            case 285: return localizedStrings["Herald of Zakarum"]
            case 286: return localizedStrings["Cutthroat1"]
            case 287: return localizedStrings["Jalal's Mane"]
            case 288: return localizedStrings["The Scalper"]
            case 289: return localizedStrings["Bloodmoon"]
            case 290: return localizedStrings["Djinnslayer"]
            case 291: return localizedStrings["Deathbit"]
            case 292: return localizedStrings["Warshrike"]
            case 293: return localizedStrings["Gutsiphon"]
            case 294: return localizedStrings["Razoredge"]
            case 295: return localizedStrings["Gore Ripper"]
            case 296: return localizedStrings["Demonlimb"]
            case 297: return localizedStrings["Steelshade"]
            case 298: return localizedStrings["Tomb Reaver"]
            case 299: return localizedStrings["Deaths's Web"]
            case 300: return localizedStrings["Nature's Peace"]
            case 301: return localizedStrings["Azurewrath"]
            case 302: return localizedStrings["Seraph's Hymn"]
            case 303: return localizedStrings["Zakarum's Salvation"]
            case 304: return localizedStrings["Fleshripper"]
            case 305: return localizedStrings["Odium"]
            case 306: return localizedStrings["Horizon's Tornado"]
            case 307: return localizedStrings["Stone Crusher"]
            case 308: return localizedStrings["Jadetalon"]
            case 309: return localizedStrings["Shadowdancer"]
            case 310: return localizedStrings["Cerebus"]
            case 311: return localizedStrings["Tyrael's Might"]
            case 312: return localizedStrings["Souldrain"]
            case 313: return localizedStrings["Runemaster"]
            case 314: return localizedStrings["Deathcleaver"]
            case 315: return localizedStrings["Executioner's Justice"]
            case 316: return localizedStrings["Stoneraven"]
            case 317: return localizedStrings["Leviathan"]
            case 318: return localizedStrings["Larzuk's Champion"]
            case 319: return localizedStrings["Wisp"]
            case 320: return localizedStrings["Gargoyle's Bite"]
            case 321: return localizedStrings["Lacerator"]
            case 322: return localizedStrings["Mang Song's Lesson"]
            case 323: return localizedStrings["Viperfork"]
            case 324: return localizedStrings["Ethereal Edge"]
            case 325: return localizedStrings["Demonhorn's Edge"]
            case 326: return localizedStrings["The Reaper's Toll"]
            case 327: return localizedStrings["Spiritkeeper"]
            case 328: return localizedStrings["Hellrack"]
            case 329: return localizedStrings["Alma Negra"]
            case 330: return localizedStrings["Darkforge Spawn"]
            case 331: return localizedStrings["Widowmaker"]
            case 332: return localizedStrings["Bloodraven's Charge"]
            case 333: return localizedStrings["Ghostflame"]
            case 334: return localizedStrings["Shadowkiller"]
            case 335: return localizedStrings["Gimmershred"]
            case 336: return localizedStrings["Griffon's Eye"]
            case 337: return localizedStrings["Windhammer"]
            case 338: return localizedStrings["Thunderstroke"]
            case 339: return localizedStrings["Giantmaimer"]
            case 340: return localizedStrings["Demon's Arch"]
            case 341: return localizedStrings["Boneflame"]
            case 342: return localizedStrings["Steelpillar"]
            case 343: return localizedStrings["Nightwing's Veil"]
            case 344: return localizedStrings["Crown of Ages"]
            case 345: return localizedStrings["Andariel's Visage"]
            case 346: return localizedStrings["Darkfear"]
            case 347: return localizedStrings["Dragonscale"]
            case 348: return localizedStrings["Steel Carapice"]
            case 349: return localizedStrings["Medusa's Gaze"]
            case 350: return localizedStrings["Ravenlore"]
            case 351: return localizedStrings["Boneshade"]
            case 352: return localizedStrings["Nethercrow"]
            case 353: return localizedStrings["Flamebellow"]
            case 354: return localizedStrings["Fathom"]
            case 355: return localizedStrings["Wolfhowl"]
            case 356: return localizedStrings["Spirit Ward"]
            case 357: return localizedStrings["Kira's Guardian"]
            case 358: return localizedStrings["Ormus' Robes"]
            case 359: return localizedStrings["Gheed's Fortune"]
            case 360: return localizedStrings["Stormlash"]
            case 361: return localizedStrings["Halaberd's Reign"]
            case 362: return localizedStrings["Warriv's Warder"]
            case 363: return localizedStrings["Spike Thorn"]
            case 364: return localizedStrings["Dracul's Grasp"]
            case 365: return localizedStrings["Frostwind"]
            case 366: return localizedStrings["Templar's Might"]
            case 367: return localizedStrings["Eschuta's temper"]
            case 368: return localizedStrings["Firelizard's Talons"]
            case 369: return localizedStrings["Sandstorm Trek"]
            case 370: return localizedStrings["Marrowwalk"]
            case 371: return localizedStrings["Heaven's Light"]
            case 372: return localizedStrings["Merman's Speed"]
            case 373: return localizedStrings["Arachnid Mesh"]
            case 374: return localizedStrings["Nosferatu's Coil"]
            case 375: return localizedStrings["Metalgrid"]
            case 376: return localizedStrings["Verdugo's Hearty Cord"]
            case 377: return localizedStrings["Sigurd's Staunch"]
            case 378: return localizedStrings["Carrion Wind"]
            case 379: return localizedStrings["Giantskull"]
            case 380: return localizedStrings["Ironward"]
            case 381: return localizedStrings["Annihilus"]
            case 382: return localizedStrings["Arioc's Needle"]
            case 383: return localizedStrings["Cranebeak"]
            case 384: return localizedStrings["Nord's Tenderizer"]
            case 385: return localizedStrings["Earthshifter"]
            case 386: return localizedStrings["Wraithflight"]
            case 387: return localizedStrings["Bonehew"]
            case 388: return localizedStrings["Ondal's Wisdom"]
            case 389: return localizedStrings["The Reedeemer"]
            case 390: return localizedStrings["Headhunter's Glory"]
            case 391: return localizedStrings["Steelrend"]
            case 392: return localizedStrings["Rainbow Facet"]
            case 393: return localizedStrings["Rainbow Facet"]
            case 394: return localizedStrings["Rainbow Facet"]
            case 395: return localizedStrings["Rainbow Facet"]
            case 396: return localizedStrings["Rainbow Facet"]
            case 397: return localizedStrings["Rainbow Facet"]
            case 398: return localizedStrings["Rainbow Facet"]
            case 399: return localizedStrings["Rainbow Facet"]
            case 400: return localizedStrings["Hellfire Torch"]
            case 401: return localizedStrings["Cold Rupture"]
            case 402: return localizedStrings["Flame Rift"]
            case 403: return localizedStrings["Crack of the Heavens"]
            case 404: return localizedStrings["Rotting Fissure"]
            case 405: return localizedStrings["Bone Break"]
            case 406: return localizedStrings["Black Cleft"]
        }
    }

    getLocalizedName(txtFileNo) {
        switch (txtFileNo) {
            case 0: return localizedStrings["hax"]
            case 1: return localizedStrings["axe"]
            case 2: return localizedStrings["2ax"]
            case 3: return localizedStrings["mpi"]
            case 4: return localizedStrings["wax"]
            case 5: return localizedStrings["lax"]
            case 6: return localizedStrings["bax"]
            case 7: return localizedStrings["btx"]
            case 8: return localizedStrings["gax"]
            case 9: return localizedStrings["gix"]
            case 10: return localizedStrings["wnd"]
            case 11: return localizedStrings["ywn"]
            case 12: return localizedStrings["bwn"]
            case 13: return localizedStrings["gwn"]
            case 14: return localizedStrings["clb"]
            case 15: return localizedStrings["scp"]
            case 16: return localizedStrings["gsc"]
            case 17: return localizedStrings["wsp"]
            case 18: return localizedStrings["spc"]
            case 19: return localizedStrings["mac"]
            case 20: return localizedStrings["mst"]
            case 21: return localizedStrings["fla"]
            case 22: return localizedStrings["whm"]
            case 23: return localizedStrings["mau"]
            case 24: return localizedStrings["gma"]
            case 25: return localizedStrings["ssd"]
            case 26: return localizedStrings["scm"]
            case 27: return localizedStrings["sbr"]
            case 28: return localizedStrings["flc"]
            case 29: return localizedStrings["crs"]
            case 30: return localizedStrings["bsd"]
            case 31: return localizedStrings["lsd"]
            case 32: return localizedStrings["wsd"]
            case 33: return localizedStrings["2hs"]
            case 34: return localizedStrings["clm"]
            case 35: return localizedStrings["gis"]
            case 36: return localizedStrings["bsw"]
            case 37: return localizedStrings["flb"]
            case 38: return localizedStrings["gsd"]
            case 39: return localizedStrings["dgr"]
            case 40: return localizedStrings["dir"]
            case 41: return localizedStrings["kri"]
            case 42: return localizedStrings["bld"]
            case 43: return localizedStrings["tkf"]
            case 44: return localizedStrings["tax"]
            case 45: return localizedStrings["bkf"]
            case 46: return localizedStrings["bal"]
            case 47: return localizedStrings["jav"]
            case 48: return localizedStrings["pil"]
            case 49: return localizedStrings["ssp"]
            case 50: return localizedStrings["glv"]
            case 51: return localizedStrings["tsp"]
            case 52: return localizedStrings["spr"]
            case 53: return localizedStrings["tri"]
            case 54: return localizedStrings["brn"]
            case 55: return localizedStrings["spt"]
            case 56: return localizedStrings["pik"]
            case 57: return localizedStrings["bar"]
            case 58: return localizedStrings["vou"]
            case 59: return localizedStrings["scy"]
            case 60: return localizedStrings["pax"]
            case 61: return localizedStrings["hal"]
            case 62: return localizedStrings["wsc"]
            case 63: return localizedStrings["sst"]
            case 64: return localizedStrings["lst"]
            case 65: return localizedStrings["cst"]
            case 66: return localizedStrings["bst"]
            case 67: return localizedStrings["wst"]
            case 68: return localizedStrings["sbw"]
            case 69: return localizedStrings["hbw"]
            case 70: return localizedStrings["lbw"]
            case 71: return localizedStrings["cbw"]
            case 72: return localizedStrings["sbb"]
            case 73: return localizedStrings["lbb"]
            case 74: return localizedStrings["swb"]
            case 75: return localizedStrings["lwb"]
            case 76: return localizedStrings["lxb"]
            case 77: return localizedStrings["mxb"]
            case 78: return localizedStrings["hxb"]
            case 79: return localizedStrings["rxb"]
            case 80: return localizedStrings["gps"]
            case 81: return localizedStrings["ops"]
            case 82: return localizedStrings["gpm"]
            case 83: return localizedStrings["opm"]
            case 84: return localizedStrings["gpl"]
            case 85: return localizedStrings["opl"]
            case 86: return localizedStrings["d33"]
            case 87: return localizedStrings["g33"]
            case 88: return localizedStrings["leg"]
            case 89: return localizedStrings["hdm"]
            case 90: return localizedStrings["hfh"]
            case 91: return localizedStrings["hst"]
            case 92: return localizedStrings["msf"]
            case 93: return localizedStrings["9ha"]
            case 94: return localizedStrings["9ax"]
            case 95: return localizedStrings["92a"]
            case 96: return localizedStrings["9mp"]
            case 97: return localizedStrings["9wa"]
            case 98: return localizedStrings["9la"]
            case 99: return localizedStrings["9ba"]
            case 100: return localizedStrings["9bt"]
            case 101: return localizedStrings["9ga"]
            case 102: return localizedStrings["9gi"]
            case 103: return localizedStrings["9wn"]
            case 104: return localizedStrings["9yw"]
            case 105: return localizedStrings["9bw"]
            case 106: return localizedStrings["9gw"]
            case 107: return localizedStrings["9cl"]
            case 108: return localizedStrings["9sc"]
            case 109: return localizedStrings["9qs"]
            case 110: return localizedStrings["9ws"]
            case 111: return localizedStrings["9sp"]
            case 112: return localizedStrings["9ma"]
            case 113: return localizedStrings["9mt"]
            case 114: return localizedStrings["9fl"]
            case 115: return localizedStrings["9wh"]
            case 116: return localizedStrings["9m9"]
            case 117: return localizedStrings["9gm"]
            case 118: return localizedStrings["9ss"]
            case 119: return localizedStrings["9sm"]
            case 120: return localizedStrings["9sb"]
            case 121: return localizedStrings["9fc"]
            case 122: return localizedStrings["9cr"]
            case 123: return localizedStrings["9bs"]
            case 124: return localizedStrings["9ls"]
            case 125: return localizedStrings["9wd"]
            case 126: return localizedStrings["92h"]
            case 127: return localizedStrings["9cm"]
            case 128: return localizedStrings["9gs"]
            case 129: return localizedStrings["9b9"]
            case 130: return localizedStrings["9fb"]
            case 131: return localizedStrings["9gd"]
            case 132: return localizedStrings["9dg"]
            case 133: return localizedStrings["9di"]
            case 134: return localizedStrings["9kr"]
            case 135: return localizedStrings["9bl"]
            case 136: return localizedStrings["9tk"]
            case 137: return localizedStrings["9ta"]
            case 138: return localizedStrings["9bk"]
            case 139: return localizedStrings["9b8"]
            case 140: return localizedStrings["9ja"]
            case 141: return localizedStrings["9pi"]
            case 142: return localizedStrings["9s9"]
            case 143: return localizedStrings["9gl"]
            case 144: return localizedStrings["9ts"]
            case 145: return localizedStrings["9sr"]
            case 146: return localizedStrings["9tr"]
            case 147: return localizedStrings["9br"]
            case 148: return localizedStrings["9st"]
            case 149: return localizedStrings["9p9"]
            case 150: return localizedStrings["9b7"]
            case 151: return localizedStrings["9vo"]
            case 152: return localizedStrings["9s8"]
            case 153: return localizedStrings["9pa"]
            case 154: return localizedStrings["9h9"]
            case 155: return localizedStrings["9wc"]
            case 156: return localizedStrings["8ss"]
            case 157: return localizedStrings["8ls"]
            case 158: return localizedStrings["8cs"]
            case 159: return localizedStrings["8bs"]
            case 160: return localizedStrings["8ws"]
            case 161: return localizedStrings["8sb"]
            case 162: return localizedStrings["8hb"]
            case 163: return localizedStrings["8lb"]
            case 164: return localizedStrings["8cb"]
            case 165: return localizedStrings["8s8"]
            case 166: return localizedStrings["8l8"]
            case 167: return localizedStrings["8sw"]
            case 168: return localizedStrings["8lw"]
            case 169: return localizedStrings["8lx"]
            case 170: return localizedStrings["8mx"]
            case 171: return localizedStrings["8hx"]
            case 172: return localizedStrings["8rx"]
            case 173: return localizedStrings["qf1"]
            case 174: return localizedStrings["qf2"]
            case 175: return localizedStrings["ktr"]
            case 176: return localizedStrings["wrb"]
            case 177: return localizedStrings["axf"]
            case 178: return localizedStrings["ces"]
            case 179: return localizedStrings["clw"]
            case 180: return localizedStrings["btl"]
            case 181: return localizedStrings["skr"]
            case 182: return localizedStrings["9ar"]
            case 183: return localizedStrings["9wb"]
            case 184: return localizedStrings["9xf"]
            case 185: return localizedStrings["9cs"]
            case 186: return localizedStrings["9lw"]
            case 187: return localizedStrings["9tw"]
            case 188: return localizedStrings["9qr"]
            case 189: return localizedStrings["7ar"]
            case 190: return localizedStrings["7wb"]
            case 191: return localizedStrings["7xf"]
            case 192: return localizedStrings["7cs"]
            case 193: return localizedStrings["7lw"]
            case 194: return localizedStrings["7tw"]
            case 195: return localizedStrings["7qr"]
            case 196: return localizedStrings["7ha"]
            case 197: return localizedStrings["7ax"]
            case 198: return localizedStrings["72a"]
            case 199: return localizedStrings["7mp"]
            case 200: return localizedStrings["7wa"]
            case 201: return localizedStrings["7la"]
            case 202: return localizedStrings["7ba"]
            case 203: return localizedStrings["7bt"]
            case 204: return localizedStrings["7ga"]
            case 205: return localizedStrings["7gi"]
            case 206: return localizedStrings["7wn"]
            case 207: return localizedStrings["7yw"]
            case 208: return localizedStrings["7bw"]
            case 209: return localizedStrings["7gw"]
            case 210: return localizedStrings["7cl"]
            case 211: return localizedStrings["7sc"]
            case 212: return localizedStrings["7qs"]
            case 213: return localizedStrings["7ws"]
            case 214: return localizedStrings["7sp"]
            case 215: return localizedStrings["7ma"]
            case 216: return localizedStrings["7mt"]
            case 217: return localizedStrings["7fl"]
            case 218: return localizedStrings["7wh"]
            case 219: return localizedStrings["7m7"]
            case 220: return localizedStrings["7gm"]
            case 221: return localizedStrings["7ss"]
            case 222: return localizedStrings["7sm"]
            case 223: return localizedStrings["7sb"]
            case 224: return localizedStrings["7fc"]
            case 225: return localizedStrings["7cr"]
            case 226: return localizedStrings["7bs"]
            case 227: return localizedStrings["7ls"]
            case 228: return localizedStrings["7wd"]
            case 229: return localizedStrings["72h"]
            case 230: return localizedStrings["7cm"]
            case 231: return localizedStrings["7gs"]
            case 232: return localizedStrings["7b7"]
            case 233: return localizedStrings["7fb"]
            case 234: return localizedStrings["7gd"]
            case 235: return localizedStrings["7dg"]
            case 236: return localizedStrings["7di"]
            case 237: return localizedStrings["7kr"]
            case 238: return localizedStrings["7bl"]
            case 239: return localizedStrings["7tk"]
            case 240: return localizedStrings["7ta"]
            case 241: return localizedStrings["7bk"]
            case 242: return localizedStrings["7b8"]
            case 243: return localizedStrings["7ja"]
            case 244: return localizedStrings["7pi"]
            case 245: return localizedStrings["7s7"]
            case 246: return localizedStrings["7gl"]
            case 247: return localizedStrings["7ts"]
            case 248: return localizedStrings["7sr"]
            case 249: return localizedStrings["7tr"]
            case 250: return localizedStrings["7br"]
            case 251: return localizedStrings["7st"]
            case 252: return localizedStrings["7p7"]
            case 253: return localizedStrings["7o7"]
            case 254: return localizedStrings["7vo"]
            case 255: return localizedStrings["7s8"]
            case 256: return localizedStrings["7pa"]
            case 257: return localizedStrings["7h7"]
            case 258: return localizedStrings["7wc"]
            case 259: return localizedStrings["6ss"]
            case 260: return localizedStrings["6ls"]
            case 261: return localizedStrings["6cs"]
            case 262: return localizedStrings["6bs"]
            case 263: return localizedStrings["6ws"]
            case 264: return localizedStrings["6sb"]
            case 265: return localizedStrings["6hb"]
            case 266: return localizedStrings["6lb"]
            case 267: return localizedStrings["6cb"]
            case 268: return localizedStrings["6s7"]
            case 269: return localizedStrings["6l7"]
            case 270: return localizedStrings["6sw"]
            case 271: return localizedStrings["6lw"]
            case 272: return localizedStrings["6lx"]
            case 273: return localizedStrings["6mx"]
            case 274: return localizedStrings["6hx"]
            case 275: return localizedStrings["6rx"]
            case 276: return localizedStrings["ob1"]
            case 277: return localizedStrings["ob2"]
            case 278: return localizedStrings["ob3"]
            case 279: return localizedStrings["ob4"]
            case 280: return localizedStrings["ob5"]
            case 281: return localizedStrings["am1"]
            case 282: return localizedStrings["am2"]
            case 283: return localizedStrings["am3"]
            case 284: return localizedStrings["am4"]
            case 285: return localizedStrings["am5"]
            case 286: return localizedStrings["ob6"]
            case 287: return localizedStrings["ob7"]
            case 288: return localizedStrings["ob8"]
            case 289: return localizedStrings["ob9"]
            case 290: return localizedStrings["oba"]
            case 291: return localizedStrings["am6"]
            case 292: return localizedStrings["am7"]
            case 293: return localizedStrings["am8"]
            case 294: return localizedStrings["am9"]
            case 295: return localizedStrings["ama"]
            case 296: return localizedStrings["obb"]
            case 297: return localizedStrings["obc"]
            case 298: return localizedStrings["obd"]
            case 299: return localizedStrings["obe"]
            case 300: return localizedStrings["obf"]
            case 301: return localizedStrings["amb"]
            case 302: return localizedStrings["amc"]
            case 303: return localizedStrings["amd"]
            case 304: return localizedStrings["ame"]
            case 305: return localizedStrings["amf"]
            case 306: return localizedStrings["cap"]
            case 307: return localizedStrings["skp"]
            case 308: return localizedStrings["hlm"]
            case 309: return localizedStrings["fhl"]
            case 310: return localizedStrings["ghm"]
            case 311: return localizedStrings["crn"]
            case 312: return localizedStrings["msk"]
            case 313: return localizedStrings["qui"]
            case 314: return localizedStrings["lea"]
            case 315: return localizedStrings["hla"]
            case 316: return localizedStrings["stu"]
            case 317: return localizedStrings["rng"]
            case 318: return localizedStrings["scl"]
            case 319: return localizedStrings["chn"]
            case 320: return localizedStrings["brs"]
            case 321: return localizedStrings["spl"]
            case 322: return localizedStrings["plt"]
            case 323: return localizedStrings["fld"]
            case 324: return localizedStrings["gth"]
            case 325: return localizedStrings["ful"]
            case 326: return localizedStrings["aar"]
            case 327: return localizedStrings["ltp"]
            case 328: return localizedStrings["buc"]
            case 329: return localizedStrings["sml"]
            case 330: return localizedStrings["lrg"]
            case 331: return localizedStrings["kit"]
            case 332: return localizedStrings["tow"]
            case 333: return localizedStrings["gts"]
            case 334: return localizedStrings["lgl"]
            case 335: return localizedStrings["vgl"]
            case 336: return localizedStrings["mgl"]
            case 337: return localizedStrings["tgl"]
            case 338: return localizedStrings["hgl"]
            case 339: return localizedStrings["lbt"]
            case 340: return localizedStrings["vbt"]
            case 341: return localizedStrings["mbt"]
            case 342: return localizedStrings["tbt"]
            case 343: return localizedStrings["hbt"]
            case 344: return localizedStrings["lbl"]
            case 345: return localizedStrings["vbl"]
            case 346: return localizedStrings["mbl"]
            case 347: return localizedStrings["tbl"]
            case 348: return localizedStrings["hbl"]
            case 349: return localizedStrings["bhm"]
            case 350: return localizedStrings["bsh"]
            case 351: return localizedStrings["spk"]
            case 352: return localizedStrings["xap"]
            case 353: return localizedStrings["xkp"]
            case 354: return localizedStrings["xlm"]
            case 355: return localizedStrings["xhl"]
            case 356: return localizedStrings["xhm"]
            case 357: return localizedStrings["xrn"]
            case 358: return localizedStrings["xsk"]
            case 359: return localizedStrings["xui"]
            case 360: return localizedStrings["xea"]
            case 361: return localizedStrings["xla"]
            case 362: return localizedStrings["xtu"]
            case 363: return localizedStrings["xng"]
            case 364: return localizedStrings["xcl"]
            case 365: return localizedStrings["xhn"]
            case 366: return localizedStrings["xrs"]
            case 367: return localizedStrings["xpl"]
            case 368: return localizedStrings["xlt"]
            case 369: return localizedStrings["xld"]
            case 370: return localizedStrings["xth"]
            case 371: return localizedStrings["xul"]
            case 372: return localizedStrings["xar"]
            case 373: return localizedStrings["xtp"]
            case 374: return localizedStrings["xuc"]
            case 375: return localizedStrings["xml"]
            case 376: return localizedStrings["xrg"]
            case 377: return localizedStrings["xit"]
            case 378: return localizedStrings["xow"]
            case 379: return localizedStrings["xts"]
            case 380: return localizedStrings["xlg"]
            case 381: return localizedStrings["xvg"]
            case 382: return localizedStrings["xmg"]
            case 383: return localizedStrings["xtg"]
            case 384: return localizedStrings["xhg"]
            case 385: return localizedStrings["xlb"]
            case 386: return localizedStrings["xvb"]
            case 387: return localizedStrings["xmb"]
            case 388: return localizedStrings["xtb"]
            case 389: return localizedStrings["xhb"]
            case 390: return localizedStrings["zlb"]
            case 391: return localizedStrings["zvb"]
            case 392: return localizedStrings["zmb"]
            case 393: return localizedStrings["ztb"]
            case 394: return localizedStrings["zhb"]
            case 395: return localizedStrings["xh9"]
            case 396: return localizedStrings["xsh"]
            case 397: return localizedStrings["xpk"]
            case 398: return localizedStrings["dr1"]
            case 399: return localizedStrings["dr2"]
            case 400: return localizedStrings["dr3"]
            case 401: return localizedStrings["dr4"]
            case 402: return localizedStrings["dr5"]
            case 403: return localizedStrings["ba1"]
            case 404: return localizedStrings["ba2"]
            case 405: return localizedStrings["ba3"]
            case 406: return localizedStrings["ba4"]
            case 407: return localizedStrings["ba5"]
            case 408: return localizedStrings["pa1"]
            case 409: return localizedStrings["pa2"]
            case 410: return localizedStrings["pa3"]
            case 411: return localizedStrings["pa4"]
            case 412: return localizedStrings["pa5"]
            case 413: return localizedStrings["ne1"]
            case 414: return localizedStrings["ne2"]
            case 415: return localizedStrings["ne3"]
            case 416: return localizedStrings["ne4"]
            case 417: return localizedStrings["ne5"]
            case 418: return localizedStrings["ci0"]
            case 419: return localizedStrings["ci1"]
            case 420: return localizedStrings["ci2"]
            case 421: return localizedStrings["ci3"]
            case 422: return localizedStrings["uap"]
            case 423: return localizedStrings["ukp"]
            case 424: return localizedStrings["ulm"]
            case 425: return localizedStrings["uhl"]
            case 426: return localizedStrings["uhm"]
            case 427: return localizedStrings["urn"]
            case 428: return localizedStrings["usk"]
            case 429: return localizedStrings["uui"]
            case 430: return localizedStrings["uea"]
            case 431: return localizedStrings["ula"]
            case 432: return localizedStrings["utu"]
            case 433: return localizedStrings["ung"]
            case 434: return localizedStrings["ucl"]
            case 435: return localizedStrings["uhn"]
            case 436: return localizedStrings["urs"]
            case 437: return localizedStrings["upl"]
            case 438: return localizedStrings["ult"]
            case 439: return localizedStrings["uld"]
            case 440: return localizedStrings["uth"]
            case 441: return localizedStrings["uul"]
            case 442: return localizedStrings["uar"]
            case 443: return localizedStrings["utp"]
            case 444: return localizedStrings["uuc"]
            case 445: return localizedStrings["uml"]
            case 446: return localizedStrings["urg"]
            case 447: return localizedStrings["uit"]
            case 448: return localizedStrings["uow"]
            case 449: return localizedStrings["uts"]
            case 450: return localizedStrings["ulg"]
            case 451: return localizedStrings["uvg"]
            case 452: return localizedStrings["umg"]
            case 453: return localizedStrings["utg"]
            case 454: return localizedStrings["uhg"]
            case 455: return localizedStrings["ulb"]
            case 456: return localizedStrings["uvb"]
            case 457: return localizedStrings["umb"]
            case 458: return localizedStrings["utb"]
            case 459: return localizedStrings["uhb"]
            case 460: return localizedStrings["ulc"]
            case 461: return localizedStrings["uvc"]
            case 462: return localizedStrings["umc"]
            case 463: return localizedStrings["utc"]
            case 464: return localizedStrings["uhc"]
            case 465: return localizedStrings["uh9"]
            case 466: return localizedStrings["ush"]
            case 467: return localizedStrings["upk"]
            case 468: return localizedStrings["dr6"]
            case 469: return localizedStrings["dr7"]
            case 470: return localizedStrings["dr8"]
            case 471: return localizedStrings["dr9"]
            case 472: return localizedStrings["dra"]
            case 473: return localizedStrings["ba6"]
            case 474: return localizedStrings["ba7"]
            case 475: return localizedStrings["ba8"]
            case 476: return localizedStrings["ba9"]
            case 477: return localizedStrings["baa"]
            case 478: return localizedStrings["pa6"]
            case 479: return localizedStrings["pa7"]
            case 480: return localizedStrings["pa8"]
            case 481: return localizedStrings["pa9"]
            case 482: return localizedStrings["paa"]
            case 483: return localizedStrings["ne6"]
            case 484: return localizedStrings["ne7"]
            case 485: return localizedStrings["ne8"]
            case 486: return localizedStrings["ne9"]
            case 487: return localizedStrings["nea"]
            case 488: return localizedStrings["drb"]
            case 489: return localizedStrings["drc"]
            case 490: return localizedStrings["drd"]
            case 491: return localizedStrings["dre"]
            case 492: return localizedStrings["drf"]
            case 493: return localizedStrings["bab"]
            case 494: return localizedStrings["bac"]
            case 495: return localizedStrings["bad"]
            case 496: return localizedStrings["bae"]
            case 497: return localizedStrings["baf"]
            case 498: return localizedStrings["pab"]
            case 499: return localizedStrings["pac"]
            case 500: return localizedStrings["pad"]
            case 501: return localizedStrings["pae"]
            case 502: return localizedStrings["paf"]
            case 503: return localizedStrings["neb"]
            case 504: return localizedStrings["neg"]
            case 505: return localizedStrings["ned"]
            case 506: return localizedStrings["nee"]
            case 507: return localizedStrings["nef"]
            case 508: return localizedStrings["elx"]
            case 509: return localizedStrings["hpo"]
            case 510: return localizedStrings["mpo"]
            case 511: return localizedStrings["hpf"]
            case 512: return localizedStrings["mpf"]
            case 513: return localizedStrings["vps"]
            case 514: return localizedStrings["yps"]
            case 515: return localizedStrings["rvs"]
            case 516: return localizedStrings["rvl"]
            case 517: return localizedStrings["wms"]
            case 518: return localizedStrings["tbk"]
            case 519: return localizedStrings["ibk"]
            case 520: return localizedStrings["amu"]
            case 521: return localizedStrings["vip"]
            case 522: return localizedStrings["rin"]
            case 523: return localizedStrings["gld"]
            case 524: return localizedStrings["bks"]
            case 525: return localizedStrings["bkd"]
            case 526: return localizedStrings["aqv"]
            case 527: return localizedStrings["tch"]
            case 528: return localizedStrings["cqv"]
            case 529: return localizedStrings["tsc"]
            case 530: return localizedStrings["isc"]
            case 531: return localizedStrings["hrt"]
            case 532: return localizedStrings["brz"]
            case 533: return localizedStrings["jaw"]
            case 534: return localizedStrings["eyz"]
            case 535: return localizedStrings["hrn"]
            case 536: return localizedStrings["tal"]
            case 537: return localizedStrings["flg"]
            case 538: return localizedStrings["fng"]
            case 539: return localizedStrings["qll"]
            case 540: return localizedStrings["sol"]
            case 541: return localizedStrings["scz"]
            case 542: return localizedStrings["spe"]
            case 543: return localizedStrings["key"]
            case 544: return localizedStrings["luv"]
            case 545: return localizedStrings["xyz"]
            case 546: return localizedStrings["j34"]
            case 547: return localizedStrings["g34"]
            case 548: return localizedStrings["bbb"]
            case 549: return localizedStrings["box"]
            case 550: return localizedStrings["tr1"]
            case 551: return localizedStrings["mss"]
            case 552: return localizedStrings["ass"]
            case 553: return localizedStrings["qey"]
            case 554: return localizedStrings["qhr"]
            case 555: return localizedStrings["qbr"]
            case 556: return localizedStrings["ear"]
            case 557: return localizedStrings["gcv"]
            case 558: return localizedStrings["gfv"]
            case 559: return localizedStrings["gsv"]
            case 560: return localizedStrings["gzv"]
            case 561: return localizedStrings["gpv"]
            case 562: return localizedStrings["gcy"]
            case 563: return localizedStrings["gfy"]
            case 564: return localizedStrings["gsy"]
            case 565: return localizedStrings["gly"]
            case 566: return localizedStrings["gpy"]
            case 567: return localizedStrings["gcb"]
            case 568: return localizedStrings["gfb"]
            case 569: return localizedStrings["gsb"]
            case 570: return localizedStrings["glb"]
            case 571: return localizedStrings["gpb"]
            case 572: return localizedStrings["gcg"]
            case 573: return localizedStrings["gfg"]
            case 574: return localizedStrings["gsg"]
            case 575: return localizedStrings["glg"]
            case 576: return localizedStrings["gpg"]
            case 577: return localizedStrings["gcr"]
            case 578: return localizedStrings["gfr"]
            case 579: return localizedStrings["gsr"]
            case 580: return localizedStrings["glr"]
            case 581: return localizedStrings["gpr"]
            case 582: return localizedStrings["gcw"]
            case 583: return localizedStrings["gfw"]
            case 584: return localizedStrings["gsw"]
            case 585: return localizedStrings["glw"]
            case 586: return localizedStrings["gpw"]
            case 587: return localizedStrings["hp1"]
            case 588: return localizedStrings["hp2"]
            case 589: return localizedStrings["hp3"]
            case 590: return localizedStrings["hp4"]
            case 591: return localizedStrings["hp5"]
            case 592: return localizedStrings["mp1"]
            case 593: return localizedStrings["mp2"]
            case 594: return localizedStrings["mp3"]
            case 595: return localizedStrings["mp4"]
            case 596: return localizedStrings["mp5"]
            case 597: return localizedStrings["skc"]
            case 598: return localizedStrings["skf"]
            case 599: return localizedStrings["sku"]
            case 600: return localizedStrings["skl"]
            case 601: return localizedStrings["skz"]
            case 602: return localizedStrings["hrb"]
            case 603: return localizedStrings["cm1"]
            case 604: return localizedStrings["cm2"]
            case 605: return localizedStrings["cm3"]
            case 606: return localizedStrings["rps"]
            case 607: return localizedStrings["rpl"]
            case 608: return localizedStrings["bps"]
            case 609: return localizedStrings["bpl"]
            case 610: return localizedStrings["r01"]
            case 611: return localizedStrings["r02"]
            case 612: return localizedStrings["r03"]
            case 613: return localizedStrings["r04"]
            case 614: return localizedStrings["r05"]
            case 615: return localizedStrings["r06"]
            case 616: return localizedStrings["r07"]
            case 617: return localizedStrings["r08"]
            case 618: return localizedStrings["r09"]
            case 619: return localizedStrings["r10"]
            case 620: return localizedStrings["r11"]
            case 621: return localizedStrings["r12"]
            case 622: return localizedStrings["r13"]
            case 623: return localizedStrings["r14"]
            case 624: return localizedStrings["r15"]
            case 625: return localizedStrings["r16"]
            case 626: return localizedStrings["r17"]
            case 627: return localizedStrings["r18"]
            case 628: return localizedStrings["r19"]
            case 629: return localizedStrings["r20"]
            case 630: return localizedStrings["r21"]
            case 631: return localizedStrings["r22"]
            case 632: return localizedStrings["r23"]
            case 633: return localizedStrings["r24"]
            case 634: return localizedStrings["r25"]
            case 635: return localizedStrings["r26"]
            case 636: return localizedStrings["r27"]
            case 637: return localizedStrings["r28"]
            case 638: return localizedStrings["r29"]
            case 639: return localizedStrings["r30"]
            case 640: return localizedStrings["r31"]
            case 641: return localizedStrings["r32"]
            case 642: return localizedStrings["r33"]
            case 643: return localizedStrings["jew"]
            case 644: return localizedStrings["ice"]
            case 645: return localizedStrings["0sc"]
            case 646: return localizedStrings["tr2"]
            case 647: return localizedStrings["pk1"]
            case 648: return localizedStrings["pk2"]
            case 649: return localizedStrings["pk3"]
            case 650: return localizedStrings["dhn"]
            case 651: return localizedStrings["bey"]
            case 652: return localizedStrings["mbr"]
            case 653: return localizedStrings["toa"]
            case 654: return localizedStrings["tes"]
            case 655: return localizedStrings["ceh"]
            case 656: return localizedStrings["bet"]
            case 657: return localizedStrings["fed"]
            case 658: return localizedStrings["std"]
        }
    }

    getItemCode(txtFileNo) {
        switch (txtFileNo) {
            case 0: return "hax"
            case 1: return "axe"
            case 2: return "2ax"
            case 3: return "mpi"
            case 4: return "wax"
            case 5: return "lax"
            case 6: return "bax"
            case 7: return "btx"
            case 8: return "gax"
            case 9: return "gix"
            case 10: return "wnd"
            case 11: return "ywn"
            case 12: return "bwn"
            case 13: return "gwn"
            case 14: return "clb"
            case 15: return "scp"
            case 16: return "gsc"
            case 17: return "wsp"
            case 18: return "spc"
            case 19: return "mac"
            case 20: return "mst"
            case 21: return "fla"
            case 22: return "whm"
            case 23: return "mau"
            case 24: return "gma"
            case 25: return "ssd"
            case 26: return "scm"
            case 27: return "sbr"
            case 28: return "flc"
            case 29: return "crs"
            case 30: return "bsd"
            case 31: return "lsd"
            case 32: return "wsd"
            case 33: return "2hs"
            case 34: return "clm"
            case 35: return "gis"
            case 36: return "bsw"
            case 37: return "flb"
            case 38: return "gsd"
            case 39: return "dgr"
            case 40: return "dir"
            case 41: return "kri"
            case 42: return "bld"
            case 43: return "tkf"
            case 44: return "tax"
            case 45: return "bkf"
            case 46: return "bal"
            case 47: return "jav"
            case 48: return "pil"
            case 49: return "ssp"
            case 50: return "glv"
            case 51: return "tsp"
            case 52: return "spr"
            case 53: return "tri"
            case 54: return "brn"
            case 55: return "spt"
            case 56: return "pik"
            case 57: return "bar"
            case 58: return "vou"
            case 59: return "scy"
            case 60: return "pax"
            case 61: return "hal"
            case 62: return "wsc"
            case 63: return "sst"
            case 64: return "lst"
            case 65: return "cst"
            case 66: return "bst"
            case 67: return "wst"
            case 68: return "sbw"
            case 69: return "hbw"
            case 70: return "lbw"
            case 71: return "cbw"
            case 72: return "sbb"
            case 73: return "lbb"
            case 74: return "swb"
            case 75: return "lwb"
            case 76: return "lxb"
            case 77: return "mxb"
            case 78: return "hxb"
            case 79: return "rxb"
            case 80: return "gps"
            case 81: return "ops"
            case 82: return "gpm"
            case 83: return "opm"
            case 84: return "gpl"
            case 85: return "opl"
            case 86: return "d33"
            case 87: return "g33"
            case 88: return "leg"
            case 89: return "hdm"
            case 90: return "hfh"
            case 91: return "hst"
            case 92: return "msf"
            case 93: return "9ha"
            case 94: return "9ax"
            case 95: return "92a"
            case 96: return "9mp"
            case 97: return "9wa"
            case 98: return "9la"
            case 99: return "9ba"
            case 100: return "9bt"
            case 101: return "9ga"
            case 102: return "9gi"
            case 103: return "9wn"
            case 104: return "9yw"
            case 105: return "9bw"
            case 106: return "9gw"
            case 107: return "9cl"
            case 108: return "9sc"
            case 109: return "9qs"
            case 110: return "9ws"
            case 111: return "9sp"
            case 112: return "9ma"
            case 113: return "9mt"
            case 114: return "9fl"
            case 115: return "9wh"
            case 116: return "9m9"
            case 117: return "9gm"
            case 118: return "9ss"
            case 119: return "9sm"
            case 120: return "9sb"
            case 121: return "9fc"
            case 122: return "9cr"
            case 123: return "9bs"
            case 124: return "9ls"
            case 125: return "9wd"
            case 126: return "92h"
            case 127: return "9cm"
            case 128: return "9gs"
            case 129: return "9b9"
            case 130: return "9fb"
            case 131: return "9gd"
            case 132: return "9dg"
            case 133: return "9di"
            case 134: return "9kr"
            case 135: return "9bl"
            case 136: return "9tk"
            case 137: return "9ta"
            case 138: return "9bk"
            case 139: return "9b8"
            case 140: return "9ja"
            case 141: return "9pi"
            case 142: return "9s9"
            case 143: return "9gl"
            case 144: return "9ts"
            case 145: return "9sr"
            case 146: return "9tr"
            case 147: return "9br"
            case 148: return "9st"
            case 149: return "9p9"
            case 150: return "9b7"
            case 151: return "9vo"
            case 152: return "9s8"
            case 153: return "9pa"
            case 154: return "9h9"
            case 155: return "9wc"
            case 156: return "8ss"
            case 157: return "8ls"
            case 158: return "8cs"
            case 159: return "8bs"
            case 160: return "8ws"
            case 161: return "8sb"
            case 162: return "8hb"
            case 163: return "8lb"
            case 164: return "8cb"
            case 165: return "8s8"
            case 166: return "8l8"
            case 167: return "8sw"
            case 168: return "8lw"
            case 169: return "8lx"
            case 170: return "8mx"
            case 171: return "8hx"
            case 172: return "8rx"
            case 173: return "qf1"
            case 174: return "qf2"
            case 175: return "ktr"
            case 176: return "wrb"
            case 177: return "axf"
            case 178: return "ces"
            case 179: return "clw"
            case 180: return "btl"
            case 181: return "skr"
            case 182: return "9ar"
            case 183: return "9wb"
            case 184: return "9xf"
            case 185: return "9cs"
            case 186: return "9lw"
            case 187: return "9tw"
            case 188: return "9qr"
            case 189: return "7ar"
            case 190: return "7wb"
            case 191: return "7xf"
            case 192: return "7cs"
            case 193: return "7lw"
            case 194: return "7tw"
            case 195: return "7qr"
            case 196: return "7ha"
            case 197: return "7ax"
            case 198: return "72a"
            case 199: return "7mp"
            case 200: return "7wa"
            case 201: return "7la"
            case 202: return "7ba"
            case 203: return "7bt"
            case 204: return "7ga"
            case 205: return "7gi"
            case 206: return "7wn"
            case 207: return "7yw"
            case 208: return "7bw"
            case 209: return "7gw"
            case 210: return "7cl"
            case 211: return "7sc"
            case 212: return "7qs"
            case 213: return "7ws"
            case 214: return "7sp"
            case 215: return "7ma"
            case 216: return "7mt"
            case 217: return "7fl"
            case 218: return "7wh"
            case 219: return "7m7"
            case 220: return "7gm"
            case 221: return "7ss"
            case 222: return "7sm"
            case 223: return "7sb"
            case 224: return "7fc"
            case 225: return "7cr"
            case 226: return "7bs"
            case 227: return "7ls"
            case 228: return "7wd"
            case 229: return "72h"
            case 230: return "7cm"
            case 231: return "7gs"
            case 232: return "7b7"
            case 233: return "7fb"
            case 234: return "7gd"
            case 235: return "7dg"
            case 236: return "7di"
            case 237: return "7kr"
            case 238: return "7bl"
            case 239: return "7tk"
            case 240: return "7ta"
            case 241: return "7bk"
            case 242: return "7b8"
            case 243: return "7ja"
            case 244: return "7pi"
            case 245: return "7s7"
            case 246: return "7gl"
            case 247: return "7ts"
            case 248: return "7sr"
            case 249: return "7tr"
            case 250: return "7br"
            case 251: return "7st"
            case 252: return "7p7"
            case 253: return "7o7"
            case 254: return "7vo"
            case 255: return "7s8"
            case 256: return "7pa"
            case 257: return "7h7"
            case 258: return "7wc"
            case 259: return "6ss"
            case 260: return "6ls"
            case 261: return "6cs"
            case 262: return "6bs"
            case 263: return "6ws"
            case 264: return "6sb"
            case 265: return "6hb"
            case 266: return "6lb"
            case 267: return "6cb"
            case 268: return "6s7"
            case 269: return "6l7"
            case 270: return "6sw"
            case 271: return "6lw"
            case 272: return "6lx"
            case 273: return "6mx"
            case 274: return "6hx"
            case 275: return "6rx"
            case 276: return "ob1"
            case 277: return "ob2"
            case 278: return "ob3"
            case 279: return "ob4"
            case 280: return "ob5"
            case 281: return "am1"
            case 282: return "am2"
            case 283: return "am3"
            case 284: return "am4"
            case 285: return "am5"
            case 286: return "ob6"
            case 287: return "ob7"
            case 288: return "ob8"
            case 289: return "ob9"
            case 290: return "oba"
            case 291: return "am6"
            case 292: return "am7"
            case 293: return "am8"
            case 294: return "am9"
            case 295: return "ama"
            case 296: return "obb"
            case 297: return "obc"
            case 298: return "obd"
            case 299: return "obe"
            case 300: return "obf"
            case 301: return "amb"
            case 302: return "amc"
            case 303: return "amd"
            case 304: return "ame"
            case 305: return "amf"
            case 306: return "cap"
            case 307: return "skp"
            case 308: return "hlm"
            case 309: return "fhl"
            case 310: return "ghm"
            case 311: return "crn"
            case 312: return "msk"
            case 313: return "qui"
            case 314: return "lea"
            case 315: return "hla"
            case 316: return "stu"
            case 317: return "rng"
            case 318: return "scl"
            case 319: return "chn"
            case 320: return "brs"
            case 321: return "spl"
            case 322: return "plt"
            case 323: return "fld"
            case 324: return "gth"
            case 325: return "ful"
            case 326: return "aar"
            case 327: return "ltp"
            case 328: return "buc"
            case 329: return "sml"
            case 330: return "lrg"
            case 331: return "kit"
            case 332: return "tow"
            case 333: return "gts"
            case 334: return "lgl"
            case 335: return "vgl"
            case 336: return "mgl"
            case 337: return "tgl"
            case 338: return "hgl"
            case 339: return "lbt"
            case 340: return "vbt"
            case 341: return "mbt"
            case 342: return "tbt"
            case 343: return "hbt"
            case 344: return "lbl"
            case 345: return "vbl"
            case 346: return "mbl"
            case 347: return "tbl"
            case 348: return "hbl"
            case 349: return "bhm"
            case 350: return "bsh"
            case 351: return "spk"
            case 352: return "xap"
            case 353: return "xkp"
            case 354: return "xlm"
            case 355: return "xhl"
            case 356: return "xhm"
            case 357: return "xrn"
            case 358: return "xsk"
            case 359: return "xui"
            case 360: return "xea"
            case 361: return "xla"
            case 362: return "xtu"
            case 363: return "xng"
            case 364: return "xcl"
            case 365: return "xhn"
            case 366: return "xrs"
            case 367: return "xpl"
            case 368: return "xlt"
            case 369: return "xld"
            case 370: return "xth"
            case 371: return "xul"
            case 372: return "xar"
            case 373: return "xtp"
            case 374: return "xuc"
            case 375: return "xml"
            case 376: return "xrg"
            case 377: return "xit"
            case 378: return "xow"
            case 379: return "xts"
            case 380: return "xlg"
            case 381: return "xvg"
            case 382: return "xmg"
            case 383: return "xtg"
            case 384: return "xhg"
            case 385: return "xlb"
            case 386: return "xvb"
            case 387: return "xmb"
            case 388: return "xtb"
            case 389: return "xhb"
            case 390: return "zlb"
            case 391: return "zvb"
            case 392: return "zmb"
            case 393: return "ztb"
            case 394: return "zhb"
            case 395: return "xh9"
            case 396: return "xsh"
            case 397: return "xpk"
            case 398: return "dr1"
            case 399: return "dr2"
            case 400: return "dr3"
            case 401: return "dr4"
            case 402: return "dr5"
            case 403: return "ba1"
            case 404: return "ba2"
            case 405: return "ba3"
            case 406: return "ba4"
            case 407: return "ba5"
            case 408: return "pa1"
            case 409: return "pa2"
            case 410: return "pa3"
            case 411: return "pa4"
            case 412: return "pa5"
            case 413: return "ne1"
            case 414: return "ne2"
            case 415: return "ne3"
            case 416: return "ne4"
            case 417: return "ne5"
            case 418: return "ci0"
            case 419: return "ci1"
            case 420: return "ci2"
            case 421: return "ci3"
            case 422: return "uap"
            case 423: return "ukp"
            case 424: return "ulm"
            case 425: return "uhl"
            case 426: return "uhm"
            case 427: return "urn"
            case 428: return "usk"
            case 429: return "uui"
            case 430: return "uea"
            case 431: return "ula"
            case 432: return "utu"
            case 433: return "ung"
            case 434: return "ucl"
            case 435: return "uhn"
            case 436: return "urs"
            case 437: return "upl"
            case 438: return "ult"
            case 439: return "uld"
            case 440: return "uth"
            case 441: return "uul"
            case 442: return "uar"
            case 443: return "utp"
            case 444: return "uuc"
            case 445: return "uml"
            case 446: return "urg"
            case 447: return "uit"
            case 448: return "uow"
            case 449: return "uts"
            case 450: return "ulg"
            case 451: return "uvg"
            case 452: return "umg"
            case 453: return "utg"
            case 454: return "uhg"
            case 455: return "ulb"
            case 456: return "uvb"
            case 457: return "umb"
            case 458: return "utb"
            case 459: return "uhb"
            case 460: return "ulc"
            case 461: return "uvc"
            case 462: return "umc"
            case 463: return "utc"
            case 464: return "uhc"
            case 465: return "uh9"
            case 466: return "ush"
            case 467: return "upk"
            case 468: return "dr6"
            case 469: return "dr7"
            case 470: return "dr8"
            case 471: return "dr9"
            case 472: return "dra"
            case 473: return "ba6"
            case 474: return "ba7"
            case 475: return "ba8"
            case 476: return "ba9"
            case 477: return "baa"
            case 478: return "pa6"
            case 479: return "pa7"
            case 480: return "pa8"
            case 481: return "pa9"
            case 482: return "paa"
            case 483: return "ne6"
            case 484: return "ne7"
            case 485: return "ne8"
            case 486: return "ne9"
            case 487: return "nea"
            case 488: return "drb"
            case 489: return "drc"
            case 490: return "drd"
            case 491: return "dre"
            case 492: return "drf"
            case 493: return "bab"
            case 494: return "bac"
            case 495: return "bad"
            case 496: return "bae"
            case 497: return "baf"
            case 498: return "pab"
            case 499: return "pac"
            case 500: return "pad"
            case 501: return "pae"
            case 502: return "paf"
            case 503: return "neb"
            case 504: return "neg"
            case 505: return "ned"
            case 506: return "nee"
            case 507: return "nef"
            case 508: return "elx"
            case 509: return "hpo"
            case 510: return "mpo"
            case 511: return "hpf"
            case 512: return "mpf"
            case 513: return "vps"
            case 514: return "yps"
            case 515: return "rvs"
            case 516: return "rvl"
            case 517: return "wms"
            case 518: return "tbk"
            case 519: return "ibk"
            case 520: return "amu"
            case 521: return "vip"
            case 522: return "rin"
            case 523: return "gld"
            case 524: return "bks"
            case 525: return "bkd"
            case 526: return "aqv"
            case 527: return "tch"
            case 528: return "cqv"
            case 529: return "tsc"
            case 530: return "isc"
            case 531: return "hrt"
            case 532: return "brz"
            case 533: return "jaw"
            case 534: return "eyz"
            case 535: return "hrn"
            case 536: return "tal"
            case 537: return "flg"
            case 538: return "fng"
            case 539: return "qll"
            case 540: return "sol"
            case 541: return "scz"
            case 542: return "spe"
            case 543: return "key"
            case 544: return "luv"
            case 545: return "xyz"
            case 546: return "j34"
            case 547: return "g34"
            case 548: return "bbb"
            case 549: return "box"
            case 550: return "tr1"
            case 551: return "mss"
            case 552: return "ass"
            case 553: return "qey"
            case 554: return "qhr"
            case 555: return "qbr"
            case 556: return "ear"
            case 557: return "gcv"
            case 558: return "gfv"
            case 559: return "gsv"
            case 560: return "gzv"
            case 561: return "gpv"
            case 562: return "gcy"
            case 563: return "gfy"
            case 564: return "gsy"
            case 565: return "gly"
            case 566: return "gpy"
            case 567: return "gcb"
            case 568: return "gfb"
            case 569: return "gsb"
            case 570: return "glb"
            case 571: return "gpb"
            case 572: return "gcg"
            case 573: return "gfg"
            case 574: return "gsg"
            case 575: return "glg"
            case 576: return "gpg"
            case 577: return "gcr"
            case 578: return "gfr"
            case 579: return "gsr"
            case 580: return "glr"
            case 581: return "gpr"
            case 582: return "gcw"
            case 583: return "gfw"
            case 584: return "gsw"
            case 585: return "glw"
            case 586: return "gpw"
            case 587: return "hp1"
            case 588: return "hp2"
            case 589: return "hp3"
            case 590: return "hp4"
            case 591: return "hp5"
            case 592: return "mp1"
            case 593: return "mp2"
            case 594: return "mp3"
            case 595: return "mp4"
            case 596: return "mp5"
            case 597: return "skc"
            case 598: return "skf"
            case 599: return "sku"
            case 600: return "skl"
            case 601: return "skz"
            case 602: return "hrb"
            case 603: return "cm1"
            case 604: return "cm2"
            case 605: return "cm3"
            case 606: return "rps"
            case 607: return "rpl"
            case 608: return "bps"
            case 609: return "bpl"
            case 610: return "r01"
            case 611: return "r02"
            case 612: return "r03"
            case 613: return "r04"
            case 614: return "r05"
            case 615: return "r06"
            case 616: return "r07"
            case 617: return "r08"
            case 618: return "r09"
            case 619: return "r10"
            case 620: return "r11"
            case 621: return "r12"
            case 622: return "r13"
            case 623: return "r14"
            case 624: return "r15"
            case 625: return "r16"
            case 626: return "r17"
            case 627: return "r18"
            case 628: return "r19"
            case 629: return "r20"
            case 630: return "r21"
            case 631: return "r22"
            case 632: return "r23"
            case 633: return "r24"
            case 634: return "r25"
            case 635: return "r26"
            case 636: return "r27"
            case 637: return "r28"
            case 638: return "r29"
            case 639: return "r30"
            case 640: return "r31"
            case 641: return "r32"
            case 642: return "r33"
            case 643: return "jew"
            case 644: return "ice"
            case 645: return "0sc"
            case 646: return "tr2"
            case 647: return "pk1"
            case 648: return "pk2"
            case 649: return "pk3"
            case 650: return "dhn"
            case 651: return "bey"
            case 652: return "mbr"
            case 653: return "toa"
            case 654: return "tes"
            case 655: return "ceh"
            case 656: return "bet"
            case 657: return "fed"
            case 658: return "std"
        }
    }

    getSetItemName(itemCode) {
        switch (itemCode) {
            case "lrg": return localizedStrings["Civerb's Ward"]
            case "gsc": return localizedStrings["Civerb's Cudgel"]
            case "mbt": return localizedStrings["Hsarus' Iron Heel"]
            case "buc": return localizedStrings["Hsarus' Iron Fist"]
            case "lsd": return localizedStrings["Cleglaw's Tooth"]
            case "sml": return localizedStrings["Cleglaw's Claw"]
            case "mgl": return localizedStrings["Cleglaw's Pincers"]
            case "bsd": return localizedStrings["Isenhart's Lightbrand"]
            case "gts": return localizedStrings["Isenhart's Parry"]
            case "brs": return localizedStrings["Isenhart's Case"]
            case "fhl": return localizedStrings["Isenhart's Horns"]
            case "lbb": return localizedStrings["Vidala's Barb"]
            case "tbt": return localizedStrings["Vidala's Fetlock"]
            case "lea": return localizedStrings["Vidala's Ambush"]
            case "kit": return localizedStrings["Milabrega's Orb"]
            case "wsp": return localizedStrings["Milabrega's Rod"]
            case "aar": return localizedStrings["Milabrega's Robe"]
            case "bst": return localizedStrings["Cathan's Rule"]
            case "chn": return localizedStrings["Cathan's Mesh"]
            case "msk": return localizedStrings["Cathan's Visage"]
            case "mpi": return localizedStrings["Tancred's Crowbill"]
            case "ful": return localizedStrings["Tancred's Spine"]
            case "lbt": return localizedStrings["Tancred's Hobnails"]
            case "bhm": return localizedStrings["Tancred's Skull"]
            case "hgl": return localizedStrings["Sigon's Gage"]
            case "ghm": return localizedStrings["Sigon's Visor"]
            case "gth": return localizedStrings["Sigon's Shelter"]
            case "hbt": return localizedStrings["Sigon's Sabot"]
            case "hbl": return localizedStrings["Sigon's Wrap"]
            case "tow": return localizedStrings["Sigon's Guard"]
            case "gwn": return localizedStrings["Infernal Torch"]
            case "hlm": return localizedStrings["Berserker's Headgear"]
            case "spl": return localizedStrings["Berserker's Hauberk"]
            case "2ax": return localizedStrings["Berserker's Hatchet"]
            case "lgl": return localizedStrings["Death's Hand"]
            case "lbl": return localizedStrings["Death's Guard"]
            case "wsd": return localizedStrings["Death's Touch"]
            case "sbr": return localizedStrings["Angelic Sickle"]
            case "rng": return localizedStrings["Angelic Mantle"]
            case "swb": return localizedStrings["Arctic Horn"]
            case "qui": return localizedStrings["Arctic Furs"]
            case "vbl": return localizedStrings["Arctic Binding"]
            case "wst": return localizedStrings["Arcanna's Deathwand"]
            case "skp": return localizedStrings["Arcanna's Head"]
            case "ltp": return localizedStrings["Arcanna's Flesh"]
            case "xh9": return localizedStrings["Natalya's Totem"]
            case "7qr": return localizedStrings["Natalya's Mark"]
            case "ucl": return localizedStrings["Natalya's Shadow"]
            case "xmb": return localizedStrings["Natalya's Soul"]
            case "dr8": return localizedStrings["Aldur's Stony Gaze"]
            case "uul": return localizedStrings["Aldur's Deception"]
            case "9mt": return localizedStrings["Aldur's Gauntlet"]
            case "xtb": return localizedStrings["Aldur's Advance"]
            case "ba5": return localizedStrings["Immortal King's Will"]
            case "uar": return localizedStrings["Immortal King's Soul Cage"]
            case "zhb": return localizedStrings["Immortal King's Detail"]
            case "xhg": return localizedStrings["Immortal King's Forge"]
            case "xhb": return localizedStrings["Immortal King's Pillar"]
            case "7m7": return localizedStrings["Immortal King's Stone Crusher"]
            case "zmb": return localizedStrings["Tal Rasha's Fire-Spun Cloth"]
            case "oba": return localizedStrings["Tal Rasha's Lidless Eye"]
            case "uth": return localizedStrings["Tal Rasha's Howling Wind"]
            case "xsk": return localizedStrings["Tal Rasha's Horadric Crest"]
            case "urn": return localizedStrings["Griswold's Valor"]
            case "xar": return localizedStrings["Griswold's Heart"]
            case "7ws": return localizedStrings["Griswolds's Redemption"]
            case "paf": return localizedStrings["Griswold's Honor"]
            case "uh9": return localizedStrings["Trang-Oul's Guise"]
            case "xul": return localizedStrings["Trang-Oul's Scales"]
            case "ne9": return localizedStrings["Trang-Oul's Wing"]
            case "xmg": return localizedStrings["Trang-Oul's Claws"]
            case "utc": return localizedStrings["Trang-Oul's Girth"]
            case "ci3": return localizedStrings["M'avina's True Sight"]
            case "uld": return localizedStrings["M'avina's Embrace"]
            case "xtg": return localizedStrings["M'avina's Icy Clutch"]
            case "zvb": return localizedStrings["M'avina's Tenet"]
            case "amc": return localizedStrings["M'avina's Caster"]
            case "ulg": return localizedStrings["Laying of Hands"]
            case "xlb": return localizedStrings["Rite of Passage"]
            case "uui": return localizedStrings["Spiritual Custodian"]
            case "umc": return localizedStrings["Credendum"]
            case "7ma": return localizedStrings["Dangoon's Teaching"]
            case "uts": return localizedStrings["Heaven's Taebaek"]
            case "xrs": return localizedStrings["Haemosu's Adament"]
            case "uhm": return localizedStrings["Ondal's Almighty"]
            case "xhm": return localizedStrings["Guillaume's Face"]
            case "ztb": return localizedStrings["Wilhelm's Pride"]
            case "xvg": return localizedStrings["Magnus' Skin"]
            case "xml": return localizedStrings["Wihtstan's Guard"]
            case "xrn": return localizedStrings["Hwanin's Splendor"]
            case "xcl": return localizedStrings["Hwanin's Refuge"]
            case "9vo": return localizedStrings["Hwanin's Justice"]
            case "7ls": return localizedStrings["Sazabi's Cobalt Redeemer"]
            case "upl": return localizedStrings["Sazabi's Ghost Liberator"]
            case "xhl": return localizedStrings["Sazabi's Mental Sheath"]
            case "7gd": return localizedStrings["Bul-Kathos' Sacred Charge"]
            case "7wd": return localizedStrings["Bul-Kathos' Tribal Guardian"]
            case "xap": return localizedStrings["Cow King's Horns"]
            case "stu": return localizedStrings["Cow King's Hide"]
            case "6cs": return localizedStrings["Naj's Puzzler"]
            case "ult": return localizedStrings["Naj's Light Plate"]
            case "ci0": return localizedStrings["Naj's Circlet"]
            case "vgl": return localizedStrings["McAuley's Taboo"]
            case "bwn": return localizedStrings["McAuley's Superstition"]
        }
    }

    getUniqueItemName(itemCode) {
        switch (itemCode) {
            case "hax": return localizedStrings["The Gnasher"]
            case "axe": return localizedStrings["Deathspade"]
            case "2ax": return localizedStrings["Bladebone"]
            case "mpi": return localizedStrings["Mindrend"]
            case "wax": return localizedStrings["Rakescar"]
            case "lax": return localizedStrings["Fechmars Axe"]
            case "bax": return localizedStrings["Goreshovel"]
            case "btx": return localizedStrings["The Chieftan"]
            case "gax": return localizedStrings["Brainhew"]
            case "gix": return localizedStrings["The Humongous"]
            case "wnd": return localizedStrings["Iros Torch"]
            case "ywn": return localizedStrings["Maelstromwrath"]
            case "bwn": return localizedStrings["Gravenspine"]
            case "gwn": return localizedStrings["Umes Lament"]
            case "clb": return localizedStrings["Felloak"]
            case "scp": return localizedStrings["Knell Striker"]
            case "gsc": return localizedStrings["Rusthandle"]
            case "wsp": return localizedStrings["Stormeye"]
            case "spc": return localizedStrings["Stoutnail"]
            case "mac": return localizedStrings["Crushflange"]
            case "mst": return localizedStrings["Bloodrise"]
            case "fla": return localizedStrings["The Generals Tan Do Li Ga"]
            case "whm": return localizedStrings["Ironstone"]
            case "mau": return localizedStrings["Bonesob"]
            case "gma": return localizedStrings["Steeldriver"]
            case "ssd": return localizedStrings["Rixots Keen"]
            case "scm": return localizedStrings["Blood Crescent"]
            case "sbr": return localizedStrings["Krintizs Skewer"]
            case "flc": return localizedStrings["Gleamscythe"]
            case "crs": return localizedStrings["Azurewrath"]
            case "bsd": return localizedStrings["Griswolds Edge"]
            case "lsd": return localizedStrings["Hellplague"]
            case "wsd": return localizedStrings["Culwens Point"]
            case "2hs": return localizedStrings["Shadowfang"]
            case "clm": return localizedStrings["Soulflay"]
            case "gis": return localizedStrings["Kinemils Awl"]
            case "bsw": return localizedStrings["Blacktongue"]
            case "flb": return localizedStrings["Ripsaw"]
            case "gsd": return localizedStrings["The Patriarch"]
            case "dgr": return localizedStrings["Gull"]
            case "dir": return localizedStrings["The Diggler"]
            case "kri": return localizedStrings["The Jade Tan Do"]
            case "bld": return localizedStrings["Irices Shard"]
            case "spr": return localizedStrings["The Dragon Chang"]
            case "tri": return localizedStrings["Razortine"]
            case "brn": return localizedStrings["Bloodthief"]
            case "spt": return localizedStrings["Lance of Yaggai"]
            case "pik": return localizedStrings["The Tannr Gorerod"]
            case "bar": return localizedStrings["Dimoaks Hew"]
            case "vou": return localizedStrings["Steelgoad"]
            case "scy": return localizedStrings["Soul Harvest"]
            case "pax": return localizedStrings["The Battlebranch"]
            case "hal": return localizedStrings["Woestave"]
            case "wsc": return localizedStrings["The Grim Reaper"]
            case "sst": return localizedStrings["Bane Ash"]
            case "lst": return localizedStrings["Serpent Lord"]
            case "cst": return localizedStrings["Lazarus Spire"]
            case "bst": return localizedStrings["The Salamander"]
            case "wst": return localizedStrings["The Iron Jang Bong"]
            case "sbw": return localizedStrings["Pluckeye"]
            case "hbw": return localizedStrings["Witherstring"]
            case "lbw": return localizedStrings["Rimeraven"]
            case "cbw": return localizedStrings["Piercerib"]
            case "sbb": return localizedStrings["Pullspite"]
            case "lbb": return localizedStrings["Wizendraw"]
            case "swb": return localizedStrings["Hellclap"]
            case "lwb": return localizedStrings["Blastbark"]
            case "lxb": return localizedStrings["Leadcrow"]
            case "mxb": return localizedStrings["Ichorsting"]
            case "hxb": return localizedStrings["Hellcast"]
            case "rxb": return localizedStrings["Doomspittle"]
            case "cap": return localizedStrings["Biggin's Bonnet"]
            case "skp": return localizedStrings["Tarnhelm"]
            case "hlm": return localizedStrings["Coif of Glory"]
            case "fhl": return localizedStrings["Duskdeep"]
            case "bhm": return localizedStrings["Wormskull"]
            case "ghm": return localizedStrings["Howltusk"]
            case "crn": return localizedStrings["Undead Crown"]
            case "msk": return localizedStrings["The Face of Horror"]
            case "qui": return localizedStrings["Greyform"]
            case "lea": return localizedStrings["Blinkbats Form"]
            case "hla": return localizedStrings["The Centurion"]
            case "stu": return localizedStrings["Twitchthroe"]
            case "rng": return localizedStrings["Darkglow"]
            case "scl": return localizedStrings["Hawkmail"]
            case "chn": return localizedStrings["Sparking Mail"]
            case "brs": return localizedStrings["Venomsward"]
            case "spl": return localizedStrings["Iceblink"]
            case "plt": return localizedStrings["Boneflesh"]
            case "fld": return localizedStrings["Rockfleece"]
            case "gth": return localizedStrings["Rattlecage"]
            case "ful": return localizedStrings["Goldskin"]
            case "aar": return localizedStrings["Victors Silk"]
            case "ltp": return localizedStrings["Heavenly Garb"]
            case "buc": return localizedStrings["Pelta Lunata"]
            case "sml": return localizedStrings["Umbral Disk"]
            case "lrg": return localizedStrings["Stormguild"]
            case "bsh": return localizedStrings["Wall of the Eyeless"]
            case "spk": return localizedStrings["Swordback Hold"]
            case "kit": return localizedStrings["Steelclash"]
            case "tow": return localizedStrings["Bverrit Keep"]
            case "gts": return localizedStrings["The Ward"]
            case "lgl": return localizedStrings["The Hand of Broc"]
            case "vgl": return localizedStrings["Bloodfist"]
            case "mgl": return localizedStrings["Chance Guards"]
            case "tgl": return localizedStrings["Magefist"]
            case "hgl": return localizedStrings["Frostburn"]
            case "lbt": return localizedStrings["Hotspur"]
            case "vbt": return localizedStrings["Gorefoot"]
            case "mbt": return localizedStrings["Treads of Cthon"]
            case "tbt": return localizedStrings["Goblin Toe"]
            case "hbt": return localizedStrings["Tearhaunch"]
            case "lbl": return localizedStrings["Lenyms Cord"]
            case "vbl": return localizedStrings["Snakecord"]
            case "mbl": return localizedStrings["Nightsmoke"]
            case "tbl": return localizedStrings["Goldwrap"]
            case "hbl": return localizedStrings["Bladebuckle"]
            case "vip": return localizedStrings["Amulet of the Viper"]
            case "msf": return localizedStrings["Staff of Kings"]
            case "hst": return localizedStrings["Horadric Staff"]
            case "hfh": return localizedStrings["Hell Forge Hammer"]
            case "qf1": return localizedStrings["KhalimFlail"]
            case "qf2": return localizedStrings["SuperKhalimFlail"]
            case "9ha": return localizedStrings["Coldkill"]
            case "9ax": return localizedStrings["Butcher's Pupil"]
            case "92a": return localizedStrings["Islestrike"]
            case "9mp": return localizedStrings["Pompe's Wrath"]
            case "9wa": return localizedStrings["Guardian Naga"]
            case "9la": return localizedStrings["Warlord's Trust"]
            case "9ba": return localizedStrings["Spellsteel"]
            case "9bt": return localizedStrings["Stormrider"]
            case "9ga": return localizedStrings["Boneslayer Blade"]
            case "9gi": return localizedStrings["The Minataur"]
            case "9wn": return localizedStrings["Suicide Branch"]
            case "9yw": return localizedStrings["Carin Shard"]
            case "9bw": return localizedStrings["Arm of King Leoric"]
            case "9gw": return localizedStrings["Blackhand Key"]
            case "9cl": return localizedStrings["Dark Clan Crusher"]
            case "9sc": return localizedStrings["Zakarum's Hand"]
            case "9qs": return localizedStrings["The Fetid Sprinkler"]
            case "9ws": return localizedStrings["Hand of Blessed Light"]
            case "9sp": return localizedStrings["Fleshrender"]
            case "9ma": return localizedStrings["Sureshrill Frost"]
            case "9mt": return localizedStrings["Moonfall"]
            case "9fl": return localizedStrings["Baezil's Vortex"]
            case "9wh": return localizedStrings["Earthshaker"]
            case "9m9": return localizedStrings["Bloodtree Stump"]
            case "9gm": return localizedStrings["The Gavel of Pain"]
            case "9ss": return localizedStrings["Bloodletter"]
            case "9sm": return localizedStrings["Coldsteel Eye"]
            case "9sb": return localizedStrings["Hexfire"]
            case "9fc": return localizedStrings["Blade of Ali Baba"]
            case "9cr": return localizedStrings["Ginther's Rift"]
            case "9bs": return localizedStrings["Headstriker"]
            case "9ls": return localizedStrings["Plague Bearer"]
            case "9wd": return localizedStrings["The Atlantian"]
            case "92h": return localizedStrings["Crainte Vomir"]
            case "9cm": return localizedStrings["Bing Sz Wang"]
            case "9gs": return localizedStrings["The Vile Husk"]
            case "9b9": return localizedStrings["Cloudcrack"]
            case "9fb": return localizedStrings["Todesfaelle Flamme"]
            case "9gd": return localizedStrings["Swordguard"]
            case "9dg": return localizedStrings["Spineripper"]
            case "9di": return localizedStrings["Heart Carver"]
            case "9kr": return localizedStrings["Blackbog's Sharp"]
            case "9bl": return localizedStrings["Stormspike"]
            case "9sr": return localizedStrings["The Impaler"]
            case "9tr": return localizedStrings["Kelpie Snare"]
            case "9br": return localizedStrings["Soulfeast Tine"]
            case "9st": return localizedStrings["Hone Sundan"]
            case "9p9": return localizedStrings["Spire of Honor"]
            case "9b7": return localizedStrings["The Meat Scraper"]
            case "9vo": return localizedStrings["Blackleach Blade"]
            case "9s8": return localizedStrings["Athena's Wrath"]
            case "9pa": return localizedStrings["Pierre Tombale Couant"]
            case "9h9": return localizedStrings["Husoldal Evo"]
            case "9wc": return localizedStrings["Grim's Burning Dead"]
            case "8ss": return localizedStrings["Razorswitch"]
            case "8ls": return localizedStrings["Ribcracker"]
            case "8cs": return localizedStrings["Chromatic Ire"]
            case "8bs": return localizedStrings["Warpspear"]
            case "8ws": return localizedStrings["Skullcollector"]
            case "8sb": return localizedStrings["Skystrike"]
            case "8hb": return localizedStrings["Riphook"]
            case "8lb": return localizedStrings["Kuko Shakaku"]
            case "8cb": return localizedStrings["Endlesshail"]
            case "8s8": return localizedStrings["Whichwild String"]
            case "8l8": return localizedStrings["Cliffkiller"]
            case "8sw": return localizedStrings["Magewrath"]
            case "8lw": return localizedStrings["Godstrike Arch"]
            case "8lx": return localizedStrings["Langer Briser"]
            case "8mx": return localizedStrings["Pus Spiter"]
            case "8hx": return localizedStrings["Buriza-Do Kyanon"]
            case "8rx": return localizedStrings["Demon Machine"]
            case "xap": return localizedStrings["Peasent Crown"]
            case "xkp": return localizedStrings["Rockstopper"]
            case "xlm": return localizedStrings["Stealskull"]
            case "xhl": return localizedStrings["Darksight Helm"]
            case "xhm": return localizedStrings["Valkiry Wing"]
            case "xrn": return localizedStrings["Crown of Thieves"]
            case "xsk": return localizedStrings["Blackhorn's Face"]
            case "xh9": return localizedStrings["Vampiregaze"]
            case "xui": return localizedStrings["The Spirit Shroud"]
            case "xea": return localizedStrings["Skin of the Vipermagi"]
            case "xla": return localizedStrings["Skin of the Flayerd One"]
            case "xtu": return localizedStrings["Ironpelt"]
            case "xng": return localizedStrings["Spiritforge"]
            case "xcl": return localizedStrings["Crow Caw"]
            case "xhn": return localizedStrings["Shaftstop"]
            case "xrs": return localizedStrings["Duriel's Shell"]
            case "xpl": return localizedStrings["Skullder's Ire"]
            case "xlt": return localizedStrings["Guardian Angel"]
            case "xld": return localizedStrings["Toothrow"]
            case "xth": return localizedStrings["Atma's Wail"]
            case "xul": return localizedStrings["Black Hades"]
            case "xar": return localizedStrings["Corpsemourn"]
            case "xtp": return localizedStrings["Que-Hegan's Wisdon"]
            case "xuc": return localizedStrings["Visceratuant"]
            case "xml": return localizedStrings["Mosers Blessed Circle"]
            case "xrg": return localizedStrings["Stormchaser"]
            case "xit": return localizedStrings["Tiamat's Rebuke"]
            case "xow": return localizedStrings["Kerke's Sanctuary"]
            case "xts": return localizedStrings["Radimant's Sphere"]
            case "xsh": return localizedStrings["Lidless Wall"]
            case "xpk": return localizedStrings["Lance Guard"]
            case "xlg": return localizedStrings["Venom Grip"]
            case "xvg": return localizedStrings["Gravepalm"]
            case "xmg": return localizedStrings["Ghoulhide"]
            case "xtg": return localizedStrings["Lavagout"]
            case "xhg": return localizedStrings["Hellmouth"]
            case "xlb": return localizedStrings["Infernostride"]
            case "xvb": return localizedStrings["Waterwalk"]
            case "xmb": return localizedStrings["Silkweave"]
            case "xtb": return localizedStrings["Wartraveler"]
            case "xhb": return localizedStrings["Gorerider"]
            case "zlb": return localizedStrings["String of Ears"]
            case "zvb": return localizedStrings["Razortail"]
            case "zmb": return localizedStrings["Gloomstrap"]
            case "ztb": return localizedStrings["Snowclash"]
            case "zhb": return localizedStrings["Thudergod's Vigor"]
            case "uap": return localizedStrings["Harlequin Crest"]
            case "utu": return localizedStrings["The Gladiator's Bane"]
            case "upl": return localizedStrings["Arkaine's Valor"]
            case "uml": return localizedStrings["Blackoak Shield"]
            case "uit": return localizedStrings["Stormshield"]
            case "7bt": return localizedStrings["Hellslayer"]
            case "7ga": return localizedStrings["Messerschmidt's Reaver"]
            case "7mt": return localizedStrings["Baranar's Star"]
            case "7b7": return localizedStrings["Doombringer"]
            case "7gd": return localizedStrings["The Grandfather"]
            case "7dg": return localizedStrings["Wizardspike"]
            case "7wc": return localizedStrings["Stormspire"]
            case "6l7": return localizedStrings["Eaglehorn"]
            case "6lw": return localizedStrings["Windforce"]
            case "baa": return localizedStrings["Arreat's Face"]
            case "nea": return localizedStrings["Homunculus"]
            case "ama": return localizedStrings["Titan's Revenge"]
            case "am7": return localizedStrings["Lycander's Aim"]
            case "am9": return localizedStrings["Lycander's Flank"]
            case "oba": return localizedStrings["The Oculus"]
            case "pa9": return localizedStrings["Herald of Zakarum"]
            case "9tw": return localizedStrings["Cutthroat1"]
            case "dra": return localizedStrings["Jalal's Mane"]
            case "9ta": return localizedStrings["The Scalper"]
            case "7sb": return localizedStrings["Bloodmoon"]
            case "7sm": return localizedStrings["Djinnslayer"]
            case "9tk": return localizedStrings["Deathbit"]
            case "7bk": return localizedStrings["Warshrike"]
            case "6rx": return localizedStrings["Gutsiphon"]
            case "7ha": return localizedStrings["Razoredge"]
            case "7sp": return localizedStrings["Demonlimb"]
            case "7pa": return localizedStrings["Tomb Reaver"]
            case "7gw": return localizedStrings["Deaths's Web"]
            case "7kr": return localizedStrings["Fleshripper"]
            case "7wb": return localizedStrings["Jadetalon"]
            case "uhb": return localizedStrings["Shadowdancer"]
            case "drb": return localizedStrings["Cerebus"]
            case "umg": return localizedStrings["Souldrain"]
            case "72a": return localizedStrings["Runemaster"]
            case "7wa": return localizedStrings["Deathcleaver"]
            case "7gi": return localizedStrings["Executioner's Justice"]
            case "amd": return localizedStrings["Stoneraven"]
            case "uld": return localizedStrings["Leviathan"]
            case "7ts": return localizedStrings["Gargoyle's Bite"]
            case "7b8": return localizedStrings["Lacerator"]
            case "6ws": return localizedStrings["Mang Song's Lesson"]
            case "7br": return localizedStrings["Viperfork"]
            case "7ba": return localizedStrings["Ethereal Edge"]
            case "bad": return localizedStrings["Demonhorn's Edge"]
            case "7s8": return localizedStrings["The Reaper's Toll"]
            case "drd": return localizedStrings["Spiritkeeper"]
            case "6hx": return localizedStrings["Hellrack"]
            case "pac": return localizedStrings["Alma Negra"]
            case "nef": return localizedStrings["Darkforge Spawn"]
            case "6sw": return localizedStrings["Widowmaker"]
            case "amb": return localizedStrings["Bloodraven's Charge"]
            case "7bl": return localizedStrings["Ghostflame"]
            case "7cs": return localizedStrings["Shadowkiller"]
            case "7ta": return localizedStrings["Gimmershred"]
            case "ci3": return localizedStrings["Griffon's Eye"]
            case "7m7": return localizedStrings["Windhammer"]
            case "amf": return localizedStrings["Thunderstroke"]
            case "7s7": return localizedStrings["Demon's Arch"]
            case "nee": return localizedStrings["Boneflame"]
            case "7p7": return localizedStrings["Steelpillar"]
            case "urn": return localizedStrings["Crown of Ages"]
            case "usk": return localizedStrings["Andariel's Visage"]
            case "pae": return localizedStrings["Dragonscale"]
            case "uul": return localizedStrings["Steel Carapice"]
            case "uow": return localizedStrings["Medusa's Gaze"]
            case "dre": return localizedStrings["Ravenlore"]
            case "7bw": return localizedStrings["Boneshade"]
            case "7gs": return localizedStrings["Flamebellow"]
            case "obf": return localizedStrings["Fathom"]
            case "bac": return localizedStrings["Wolfhowl"]
            case "uts": return localizedStrings["Spirit Ward"]
            case "ci2": return localizedStrings["Kira's Guardian"]
            case "uui": return localizedStrings["Ormus' Robes"]
            case "cm3": return localizedStrings["Gheed's Fortune"]
            case "bae": return localizedStrings["Halaberd's Reign"]
            case "upk": return localizedStrings["Spike Thorn"]
            case "uvg": return localizedStrings["Dracul's Grasp"]
            case "7ls": return localizedStrings["Frostwind"]
            case "obc": return localizedStrings["Eschuta's temper"]
            case "7lw": return localizedStrings["Firelizard's Talons"]
            case "uvb": return localizedStrings["Sandstorm Trek"]
            case "umb": return localizedStrings["Marrowwalk"]
            case "ulc": return localizedStrings["Arachnid Mesh"]
            case "uvc": return localizedStrings["Nosferatu's Coil"]
            case "umc": return localizedStrings["Verdugo's Hearty Cord"]
            case "uh9": return localizedStrings["Giantskull"]
            case "7ws": return localizedStrings["Ironward"]
            case "cm1": return localizedStrings["Annihilus"]
            case "7sr": return localizedStrings["Arioc's Needle"]
            case "7mp": return localizedStrings["Cranebeak"]
            case "7cl": return localizedStrings["Nord's Tenderizer"]
            case "7gl": return localizedStrings["Wraithflight"]
            case "7o7": return localizedStrings["Bonehew"]
            case "6cs": return localizedStrings["Ondal's Wisdom"]
            case "ush": return localizedStrings["Headhunter's Glory"]
            case "uhg": return localizedStrings["Steelrend"]
            case "jew": return localizedStrings["Rainbow Facet"]
            case "cm2": return localizedStrings["Hellfire Torch"]
        }
    }

    isQuestItem(txtFileNo) {
        switch (txtFileNo) {
            case 87: return 1 ; "The Gidbinn" 
            case 88: return 1 ; "Wirt's Leg" 
            case 89: return 1 ; "Horadric Malus" 
            case 90: return 1 ; "Hellforge Hammer" 
            case 91: return 1 ; "Horadric Staff" 
            case 92: return 1 ; "Staff of Kings"
            case 173: return 1 ; "Khalim's Flail"
            case 521: return 1 ; "Amulet of the Viper" 
            case 553: return 1 ; "Khalim's Eye" 
            case 554: return 1 ; "Khalim's Heart" 
            case 555: return 1 ; "Khalim's Brain" 
            case 524: return 1 ; "Scroll of Inifuss" 
            case 549: return 1 ; "Horadric Cube" 
            case 550: return 1 ; "Horadric Scroll" 
            case 551: return 1 ; "Mephisto's Soulstone" 
            case 552: return 1 ; "Book of Skill" 
            case 553: return 1 ; "Khalim's Eye" 
            case 554: return 1 ; "Khalim's Heart" 
            case 555: return 1 ; "Khalim's Brain" 
        }
    }
}


getItemBaseName(txtFileNo) {
    switch (txtFileNo) {
        case 0: return "Hand Axe" 
        case 1: return "Axe" 
        case 2: return "Double Axe" 
        case 3: return "Military Pick" 
        case 4: return "War Axe" 
        case 5: return "Large Axe" 
        case 6: return "Broad Axe" 
        case 7: return "Battle Axe" 
        case 8: return "Great Axe" 
        case 9: return "Giant Axe" 
        case 10: return "Wand" 
        case 11: return "Yew Wand" 
        case 12: return "Bone Wand" 
        case 13: return "Grim Wand" 
        case 14: return "Club" 
        case 15: return "Scepter" 
        case 16: return "Grand Scepter" 
        case 17: return "War Scepter" 
        case 18: return "Spiked Club" 
        case 19: return "Mace" 
        case 20: return "Morning Star" 
        case 21: return "Flail" 
        case 22: return "War Hammer" 
        case 23: return "Maul" 
        case 24: return "Great Maul" 
        case 25: return "Short Sword" 
        case 26: return "Scimitar" 
        case 27: return "Saber" 
        case 28: return "Falchion" 
        case 29: return "Crystal Sword" 
        case 30: return "Broad Sword" 
        case 31: return "Long Sword" 
        case 32: return "War Sword" 
        case 33: return "Two-Handed Sword" 
        case 34: return "Claymore" 
        case 35: return "Giant Sword" 
        case 36: return "Bastard Sword" 
        case 37: return "Flamberge" 
        case 38: return "Great Sword" 
        case 39: return "Dagger" 
        case 40: return "Dirk" 
        case 41: return "Kriss" 
        case 42: return "Blade" 
        case 43: return "Throwing Knife" 
        case 44: return "Throwing Axe" 
        case 45: return "Balanced Knife" 
        case 46: return "Balanced Axe" 
        case 47: return "Javelin" 
        case 48: return "Pilum" 
        case 49: return "Short Spear" 
        case 50: return "Glaive" 
        case 51: return "Throwing Spear" 
        case 52: return "Spear" 
        case 53: return "Trident" 
        case 54: return "Brandistock" 
        case 55: return "Spetum" 
        case 56: return "Pike" 
        case 57: return "Bardiche" 
        case 58: return "Voulge" 
        case 59: return "Scythe" 
        case 60: return "Poleaxe" 
        case 61: return "Halberd" 
        case 62: return "War Scythe" 
        case 63: return "Short Staff" 
        case 64: return "Long Staff" 
        case 65: return "Gnarled Staff" 
        case 66: return "Battle Staff" 
        case 67: return "War Staff" 
        case 68: return "Short Bow" 
        case 69: return "Hunter's Bow" 
        case 70: return "Long Bow" 
        case 71: return "Composite Bow" 
        case 72: return "Short Battle Bow" 
        case 73: return "Long Battle Bow" 
        case 74: return "Short War Bow" 
        case 75: return "Long War Bow" 
        case 76: return "Light Crossbow" 
        case 77: return "Crossbow" 
        case 78: return "Heavy Crossbow" 
        case 79: return "Repeating Crossbow" 
        case 80: return "Rancid Gas Potion" 
        case 81: return "Oil Potion" 
        case 82: return "Choking Gas Potion" 
        case 83: return "Exploding Potion" 
        case 84: return "Strangling Gas Potion" 
        case 85: return "Fulminating Potion" 
        case 86: return "Decoy Gidbinn" 
        case 87: return "The Gidbinn" 
        case 88: return "Wirt's Leg" 
        case 89: return "Horadric Malus" 
        case 90: return "Hellforge Hammer" 
        case 91: return "Horadric Staff" 
        case 92: return "Staff of Kings" 
        case 93: return "Hatchet" 
        case 94: return "Cleaver" 
        case 95: return "Twin Axe" 
        case 96: return "Crowbill" 
        case 97: return "Naga" 
        case 98: return "Military Axe" 
        case 99: return "Bearded Axe" 
        case 100: return "Tabar" 
        case 101: return "Gothic Axe" 
        case 102: return "Ancient Axe" 
        case 103: return "Burnt Wand" 
        case 104: return "Petrified Wand" 
        case 105: return "Tomb Wand" 
        case 106: return "Grave Wand" 
        case 107: return "Cudgel" 
        case 108: return "Rune Scepter" 
        case 109: return "Holy Water Sprinkler" 
        case 110: return "Divine Scepter" 
        case 111: return "Barbed Club" 
        case 112: return "Flanged Mace" 
        case 113: return "Jagged Star" 
        case 114: return "Knout" 
        case 115: return "Battle Hammer" 
        case 116: return "War Club" 
        case 117: return "Martel de Fer" 
        case 118: return "Gladius" 
        case 119: return "Cutlass" 
        case 120: return "Shamshir" 
        case 121: return "Tulwar" 
        case 122: return "Dimensional Blade" 
        case 123: return "Battle Sword" 
        case 124: return "Rune Sword" 
        case 125: return "Ancient Sword" 
        case 126: return "Espandon" 
        case 127: return "Dacian Falx" 
        case 128: return "Tusk Sword" 
        case 129: return "Gothic Sword" 
        case 130: return "Zweihander" 
        case 131: return "Executioner Sword" 
        case 132: return "Poignard" 
        case 133: return "Rondel" 
        case 134: return "Cinquedeas" 
        case 135: return "Stilleto" 
        case 136: return "Battle Dart" 
        case 137: return "Francisca" 
        case 138: return "War Dart" 
        case 139: return "Hurlbat" 
        case 140: return "War Javelin" 
        case 141: return "Great Pilum" 
        case 142: return "Simbilan" 
        case 143: return "Spiculum" 
        case 144: return "Harpoon" 
        case 145: return "War Spear" 
        case 146: return "Fuscina" 
        case 147: return "War Fork" 
        case 148: return "Yari" 
        case 149: return "Lance" 
        case 150: return "Lochaber Axe" 
        case 151: return "Bill" 
        case 152: return "Battle Scythe" 
        case 153: return "Partizan" 
        case 154: return "Bec-de-Corbin" 
        case 155: return "Grim Scythe" 
        case 156: return "Jo Staff" 
        case 157: return "Quarterstaff" 
        case 158: return "Cedar Staff" 
        case 159: return "Gothic Staff" 
        case 160: return "Rune Staff" 
        case 161: return "Edge Bow" 
        case 162: return "Razor Bow" 
        case 163: return "Cedar Bow" 
        case 164: return "Double Bow" 
        case 165: return "Short Siege Bow" 
        case 166: return "Long Siege Bow" 
        case 167: return "Rune Bow" 
        case 168: return "Gothic Bow" 
        case 169: return "Arbalest" 
        case 170: return "Siege Crossbow" 
        case 171: return "Ballista" 
        case 172: return "Chu-Ko-Nu" 
        case 173: return "Khalim's Flail" 
        case 174: return "Khalim's Will" 
        case 175: return "Katar" 
        case 176: return "Wrist Blade" 
        case 177: return "Hatchet Hands" 
        case 178: return "Cestus" 
        case 179: return "Claws" 
        case 180: return "Blade Talons" 
        case 181: return "Scissors Katar" 
        case 182: return "Quhab" 
        case 183: return "Wrist Spike" 
        case 184: return "Fascia" 
        case 185: return "Hand Scythe" 
        case 186: return "Greater Claws" 
        case 187: return "Greater Talons" 
        case 188: return "Scissors Quhab" 
        case 189: return "Suwayyah" 
        case 190: return "Wrist Sword" 
        case 191: return "War Fist" 
        case 192: return "Battle Cestus" 
        case 193: return "Feral Claws" 
        case 194: return "Runic Talons" 
        case 195: return "Scissors Suwayyah" 
        case 196: return "Tomahawk" 
        case 197: return "Small Crescent" 
        case 198: return "Ettin Axe" 
        case 199: return "War Spike" 
        case 200: return "Berserker Axe" 
        case 201: return "Feral Axe" 
        case 202: return "Silver-edged Axe" 
        case 203: return "Decapitator" 
        case 204: return "Champion Axe" 
        case 205: return "Glorious Axe" 
        case 206: return "Polished Wand" 
        case 207: return "Ghost Wand" 
        case 208: return "Lich Wand" 
        case 209: return "Unearthed Wand" 
        case 210: return "Truncheon" 
        case 211: return "Mighty Scepter" 
        case 212: return "Seraph Rod" 
        case 213: return "Caduceus" 
        case 214: return "Tyrant Club" 
        case 215: return "Reinforced Mace" 
        case 216: return "Devil Star" 
        case 217: return "Scourge" 
        case 218: return "Legendary Mallet" 
        case 219: return "Ogre Maul" 
        case 220: return "Thunder Maul" 
        case 221: return "Falcata" 
        case 222: return "Ataghan" 
        case 223: return "Elegant Blade" 
        case 224: return "Hydra Edge" 
        case 225: return "Phase Blade" 
        case 226: return "Conquest Sword" 
        case 227: return "Cryptic Sword" 
        case 228: return "Mythical Sword" 
        case 229: return "Legend Sword" 
        case 230: return "Highland Blade" 
        case 231: return "Balrog Blade" 
        case 232: return "Champion Sword" 
        case 233: return "Colossal Sword" 
        case 234: return "Colossus Blade" 
        case 235: return "Bone Knife" 
        case 236: return "Mithral Point" 
        case 237: return "Fanged Knife" 
        case 238: return "Legend Spike" 
        case 239: return "Flying Knife" 
        case 240: return "Flying Axe" 
        case 241: return "Winged Knife" 
        case 242: return "Winged Axe" 
        case 243: return "Hyperion Javelin" 
        case 244: return "Stygian Pilum" 
        case 245: return "Balrog Spear" 
        case 246: return "Ghost Glaive" 
        case 247: return "Winged Harpoon" 
        case 248: return "Hyperion Spear" 
        case 249: return "Stygian Pike" 
        case 250: return "Mancatcher" 
        case 251: return "Ghost Spear" 
        case 252: return "War Pike" 
        case 253: return "Ogre Axe" 
        case 254: return "Colossus Voulge" 
        case 255: return "Thresher" 
        case 256: return "Cryptic Axe" 
        case 257: return "Great Poleaxe" 
        case 258: return "Giant Thresher" 
        case 259: return "Walking Stick" 
        case 260: return "Stalagmite" 
        case 261: return "Elder Staff" 
        case 262: return "Shillelagh" 
        case 263: return "Archon Staff" 
        case 264: return "Spider Bow" 
        case 265: return "Blade Bow" 
        case 266: return "Shadow Bow" 
        case 267: return "Great Bow" 
        case 268: return "Diamond Bow" 
        case 269: return "Crusader Bow" 
        case 270: return "Ward Bow" 
        case 271: return "Hydra Bow" 
        case 272: return "Pellet Bow" 
        case 273: return "Gorgon Crossbow" 
        case 274: return "Colossus Crossbow" 
        case 275: return "Demon Crossbow" 
        case 276: return "Eagle Orb" 
        case 277: return "Sacred Globe" 
        case 278: return "Smoked Sphere" 
        case 279: return "Clasped Orb" 
        case 280: return "Jared's Stone" 
        case 281: return "Stag Bow" 
        case 282: return "Reflex Bow" 
        case 283: return "Maiden Spear" 
        case 284: return "Maiden Pike" 
        case 285: return "Maiden Javelin" 
        case 286: return "Glowing Orb" 
        case 287: return "Crystalline Globe" 
        case 288: return "Cloudy Sphere" 
        case 289: return "Sparkling Ball" 
        case 290: return "Swirling Crystal" 
        case 291: return "Ashwood Bow" 
        case 292: return "Ceremonial Bow" 
        case 293: return "Ceremonial Spear" 
        case 294: return "Ceremonial Pike" 
        case 295: return "Ceremonial Javelin" 
        case 296: return "Heavenly Stone" 
        case 297: return "Eldritch Orb" 
        case 298: return "Demon Heart" 
        case 299: return "Vortex Orb" 
        case 300: return "Dimensional Shard" 
        case 301: return "Matriarchal Bow" 
        case 302: return "Grand Matron Bow" 
        case 303: return "Matriarchal Spear" 
        case 304: return "Matriarchal Pike" 
        case 305: return "Matriarchal Javelin" 
        case 306: return "Cap" 
        case 307: return "Skull Cap" 
        case 308: return "Helm" 
        case 309: return "Full Helm" 
        case 310: return "Great Helm" 
        case 311: return "Crown" 
        case 312: return "Mask" 
        case 313: return "Quilted Armor" 
        case 314: return "Leather Armor" 
        case 315: return "Hard Leather Armor" 
        case 316: return "Studded Leather" 
        case 317: return "Ring Mail" 
        case 318: return "Scale Mail" 
        case 319: return "Chain Mail" 
        case 320: return "Breast Plate" 
        case 321: return "Splint Mail" 
        case 322: return "Plate Mail" 
        case 323: return "Field Plate" 
        case 324: return "Gothic Plate" 
        case 325: return "Full Plate Mail" 
        case 326: return "Ancient Armor" 
        case 327: return "Light Plate" 
        case 328: return "Buckler" 
        case 329: return "Small Shield" 
        case 330: return "Large Shield" 
        case 331: return "Kite Shield" 
        case 332: return "Tower Shield" 
        case 333: return "Gothic Shield" 
        case 334: return "Leather Gloves" 
        case 335: return "Heavy Gloves" 
        case 336: return "Chain Gloves" 
        case 337: return "Light Gauntlets" 
        case 338: return "Gauntlets" 
        case 339: return "Boots" 
        case 340: return "Heavy Boots" 
        case 341: return "Chain Boots" 
        case 342: return "Light Plated Boots" 
        case 343: return "Greaves" 
        case 344: return "Sash" 
        case 345: return "Light Belt" 
        case 346: return "Belt" 
        case 347: return "Heavy Belt" 
        case 348: return "Plated Belt" 
        case 349: return "Bone Helm" 
        case 350: return "Bone Shield" 
        case 351: return "Spiked Shield" 
        case 352: return "War Hat" 
        case 353: return "Sallet" 
        case 354: return "Casque" 
        case 355: return "Basinet" 
        case 356: return "Winged Helm" 
        case 357: return "Grand Crown" 
        case 358: return "Death Mask" 
        case 359: return "Ghost Armor" 
        case 360: return "Serpentskin Armor" 
        case 361: return "Demonhide Armor" 
        case 362: return "Trellised Armor" 
        case 363: return "Linked Mail" 
        case 364: return "Tigulated Mail" 
        case 365: return "Mesh Armor" 
        case 366: return "Cuirass" 
        case 367: return "Russet Armor" 
        case 368: return "Templar Coat" 
        case 369: return "Sharktooth Armor" 
        case 370: return "Embossed Plate" 
        case 371: return "Chaos Armor" 
        case 372: return "Ornate Armor" 
        case 373: return "Mage Plate" 
        case 374: return "Defender" 
        case 375: return "Round Shield" 
        case 376: return "Scutum" 
        case 377: return "Dragon Shield" 
        case 378: return "Pavise" 
        case 379: return "Ancient Shield" 
        case 380: return "Demonhide Gloves" 
        case 381: return "Sharkskin Gloves" 
        case 382: return "Heavy Bracers" 
        case 383: return "Battle Gauntlets" 
        case 384: return "War Gauntlets" 
        case 385: return "Demonhide Boots" 
        case 386: return "Sharkskin Boots" 
        case 387: return "Mesh Boots" 
        case 388: return "Battle Boots" 
        case 389: return "War Boots" 
        case 390: return "Demonhide Sash" 
        case 391: return "Sharkskin Belt" 
        case 392: return "Mesh Belt" 
        case 393: return "Battle Belt" 
        case 394: return "War Belt" 
        case 395: return "Grim Helm" 
        case 396: return "Grim Shield" 
        case 397: return "Barbed Shield" 
        case 398: return "Wolf Head" 
        case 399: return "Hawk Helm" 
        case 400: return "Antlers" 
        case 401: return "Falcon Mask" 
        case 402: return "Spirit Mask" 
        case 403: return "Jawbone Cap" 
        case 404: return "Fanged Helm" 
        case 405: return "Horned Helm" 
        case 406: return "Assault Helmet" 
        case 407: return "Avenger Guard" 
        case 408: return "Targe" 
        case 409: return "Rondache" 
        case 410: return "Heraldic Shield" 
        case 411: return "Aerin Shield" 
        case 412: return "Crown Shield" 
        case 413: return "Preserved Head" 
        case 414: return "Zombie Head" 
        case 415: return "Unraveller Head" 
        case 416: return "Gargoyle Head" 
        case 417: return "Demon Head" 
        case 418: return "Circlet" 
        case 419: return "Coronet" 
        case 420: return "Tiara" 
        case 421: return "Diadem" 
        case 422: return "Shako" 
        case 423: return "Hydraskull" 
        case 424: return "Armet" 
        case 425: return "Giant Conch" 
        case 426: return "Spired Helm" 
        case 427: return "Corona" 
        case 428: return "Demonhead" 
        case 429: return "Dusk Shroud" 
        case 430: return "Wyrmhide" 
        case 431: return "Scarab Husk" 
        case 432: return "Wire Fleece" 
        case 433: return "Diamond Mail" 
        case 434: return "Loricated Mail" 
        case 435: return "Boneweave" 
        case 436: return "Great Hauberk" 
        case 437: return "Balrog Skin" 
        case 438: return "Hellforge Plate" 
        case 439: return "Kraken Shell" 
        case 440: return "Lacquered Plate" 
        case 441: return "Shadow Plate" 
        case 442: return "Sacred Armor" 
        case 443: return "Archon Plate" 
        case 444: return "Heater" 
        case 445: return "Luna" 
        case 446: return "Hyperion" 
        case 447: return "Monarch" 
        case 448: return "Aegis" 
        case 449: return "Ward" 
        case 450: return "Bramble Mitts" 
        case 451: return "Vampirebone Gloves" 
        case 452: return "Vambraces" 
        case 453: return "Crusader Gauntlets" 
        case 454: return "Ogre Gauntlets" 
        case 455: return "Wyrmhide Boots" 
        case 456: return "Scarabshell Boots" 
        case 457: return "Boneweave Boots" 
        case 458: return "Mirrored Boots" 
        case 459: return "Myrmidon Greaves" 
        case 460: return "Spiderweb Sash" 
        case 461: return "Vampirefang Belt" 
        case 462: return "Mithril Coil" 
        case 463: return "Troll Belt" 
        case 464: return "Colossus Girdle" 
        case 465: return "Bone Visage" 
        case 466: return "Troll Nest" 
        case 467: return "Blade Barrier" 
        case 468: return "Alpha Helm" 
        case 469: return "Griffon Headress" 
        case 470: return "Hunter's Guise" 
        case 471: return "Sacred Feathers" 
        case 472: return "Totemic Mask" 
        case 473: return "Jawbone Visor" 
        case 474: return "Lion Helm" 
        case 475: return "Rage Mask" 
        case 476: return "Savage Helmet" 
        case 477: return "Slayer Guard" 
        case 478: return "Akaran Targe" 
        case 479: return "Akaran Rondache" 
        case 480: return "Protector Shield" 
        case 481: return "Gilded Shield" 
        case 482: return "Royal Shield" 
        case 483: return "Mummified Trophy" 
        case 484: return "Fetish Trophy" 
        case 485: return "Sexton Trophy" 
        case 486: return "Cantor Trophy" 
        case 487: return "Heirophant Trophy" 
        case 488: return "Blood Spirit" 
        case 489: return "Sun Spirit" 
        case 490: return "Earth Spirit" 
        case 491: return "Sky Spirit" 
        case 492: return "Dream Spirit" 
        case 493: return "Carnage Helm" 
        case 494: return "Fury Visor" 
        case 495: return "Destroyer Helm" 
        case 496: return "Conqueror Crown" 
        case 497: return "Guardian Crown" 
        case 498: return "Sacred Targe" 
        case 499: return "Sacred Rondache" 
        case 500: return "Kurast Shield" 
        case 501: return "Zakarum Shield" 
        case 502: return "Vortex Shield" 
        case 503: return "Minion Skull" 
        case 504: return "Hellspawn Skull" 
        case 505: return "Overseer Skull" 
        case 506: return "Succubus Skull" 
        case 507: return "Bloodlord Skull" 
        case 508: return "Elixir" 
        case 509: return "Healing Potion" 
        case 510: return "Mana Potion" 
        case 511: return "Full Healing Potion" 
        case 512: return "Full Mana Potion" 
        case 513: return "Stamina Potion" 
        case 514: return "Antidote Potion" 
        case 515: return "Rejuvenation Potion" 
        case 516: return "Full Rejuvenation Potion" 
        case 517: return "Thawing Potion" 
        case 518: return "Tome of Town Portal" 
        case 519: return "Tome of Identify" 
        case 520: return "Amulet" 
        case 521: return "Amulet of the Viper" 
        case 522: return "Ring" 
        case 523: return "Gold" 
        case 524: return "Scroll of Inifuss" 
        case 525: return "Key to the Cairn Stones" 
        case 526: return "Arrows" 
        case 527: return "Torch" 
        case 528: return "Bolts" 
        case 529: return "Scroll of Town Portal" 
        case 530: return "Scroll of Identify" 
        case 531: return "Heart" 
        case 532: return "Brain" 
        case 533: return "Jawbone" 
        case 534: return "Eye" 
        case 535: return "Horn" 
        case 536: return "Tail" 
        case 537: return "Flag" 
        case 538: return "Fang" 
        case 539: return "Quill" 
        case 540: return "Soul" 
        case 541: return "Scalp" 
        case 542: return "Spleen" 
        case 543: return "Key" 
        case 544: return "The Black Tower Key" 
        case 545: return "Potion of Life" 
        case 546: return "A Jade Figurine" 
        case 547: return "The Golden Bird" 
        case 548: return "Lam Esen's Tome" 
        case 549: return "Horadric Cube" 
        case 550: return "Horadric Scroll" 
        case 551: return "Mephisto's Soulstone" 
        case 552: return "Book of Skill" 
        case 553: return "Khalim's Eye" 
        case 554: return "Khalim's Heart" 
        case 555: return "Khalim's Brain" 
        case 556: return "Ear" 
        case 557: return "Chipped Amethyst" 
        case 558: return "Flawed Amethyst" 
        case 559: return "Amethyst" 
        case 560: return "Flawless Amethyst" 
        case 561: return "Perfect Amethyst" 
        case 562: return "Chipped Topaz" 
        case 563: return "Flawed Topaz" 
        case 564: return "Topaz" 
        case 565: return "Flawless Topaz" 
        case 566: return "Perfect Topaz" 
        case 567: return "Chipped Sapphire" 
        case 568: return "Flawed Sapphire" 
        case 569: return "Sapphire" 
        case 570: return "Flawless Sapphire" 
        case 571: return "Perfect Sapphire" 
        case 572: return "Chipped Emerald" 
        case 573: return "Flawed Emerald" 
        case 574: return "Emerald" 
        case 575: return "Flawless Emerald" 
        case 576: return "Perfect Emerald" 
        case 577: return "Chipped Ruby" 
        case 578: return "Flawed Ruby" 
        case 579: return "Ruby" 
        case 580: return "Flawless Ruby" 
        case 581: return "Perfect Ruby" 
        case 582: return "Chipped Diamond" 
        case 583: return "Flawed Diamond" 
        case 584: return "Diamond" 
        case 585: return "Flawless Diamond" 
        case 586: return "Perfect Diamond" 
        case 587: return "Minor Healing Potion" 
        case 588: return "Light Healing Potion" 
        case 589: return "Healing Potion" 
        case 590: return "Greater Healing Potion" 
        case 591: return "Super Healing Potion" 
        case 592: return "Minor Mana Potion" 
        case 593: return "Light Mana Potion" 
        case 594: return "Mana Potion" 
        case 595: return "Greater Mana Potion" 
        case 596: return "Super Mana Potion" 
        case 597: return "Chipped Skull" 
        case 598: return "Flawed Skull" 
        case 599: return "Skull" 
        case 600: return "Flawless Skull" 
        case 601: return "Perfect Skull" 
        case 602: return "Herb" 
        case 603: return "Small Charm" 
        case 604: return "Large Charm" 
        case 605: return "Grand Charm" 
        case 606: return "Small Red Potion" 
        case 607: return "Large Red Potion" 
        case 608: return "Small Blue Potion" 
        case 609: return "Large Blue Potion" 
        case 610: return "El Rune" 
        case 611: return "Eld Rune" 
        case 612: return "Tir Rune" 
        case 613: return "Nef Rune" 
        case 614: return "Eth Rune" 
        case 615: return "Ith Rune" 
        case 616: return "Tal Rune" 
        case 617: return "Ral Rune" 
        case 618: return "Ort Rune" 
        case 619: return "Thul Rune" 
        case 620: return "Amn Rune" 
        case 621: return "Sol Rune" 
        case 622: return "Shael Rune" 
        case 623: return "Dol Rune" 
        case 624: return "Hel Rune" 
        case 625: return "Io Rune" 
        case 626: return "Lum Rune" 
        case 627: return "Ko Rune" 
        case 628: return "Fal Rune" 
        case 629: return "Lem Rune" 
        case 630: return "Pul Rune" 
        case 631: return "Um Rune" 
        case 632: return "Mal Rune" 
        case 633: return "Ist Rune" 
        case 634: return "Gul Rune" 
        case 635: return "Vex Rune" 
        case 636: return "Ohm Rune" 
        case 637: return "Lo Rune" 
        case 638: return "Sur Rune" 
        case 639: return "Ber Rune" 
        case 640: return "Jah Rune" 
        case 641: return "Cham Rune" 
        case 642: return "Zod Rune" 
        case 643: return "Jewel" 
        case 644: return "Malah's Potion" 
        case 645: return "Scroll of Knowledge" 
        case 646: return "Scroll of Resistance" 
        case 647: return "Key of Terror" 
        case 648: return "Key of Hate" 
        case 649: return "Key of Destruction" 
        case 650: return "Diablo's Horn" 
        case 651: return "Baal's Eye" 
        case 652: return "Mephisto's Brain" 
        case 653: return "Token of Absolution" 
        case 654: return "Twisted Essence of Suffering" 
        case 655: return "Charged Essense of Hatred" 
        case 656: return "Burning Essence of Terror" 
        case 657: return "Festering Essence of Destruction" 
        case 658: return "Standard of Heroes"
        default: return ""
    }
}