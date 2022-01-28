class GameItem {

    txtFileNo := 0
    qualityNo := 0
    name := ""
    itemLoc := 0
    quality := ""
    itemx := 0
    itemy := 0 
    numSockets := 0
    identified := false
    ethereal := false

    __new(txtFileNo, qualityNo) {
        this.txtFileNo := txtFileNo
        this.qualityNo := qualityNo
        this.setItemName(txtFileNo)
        this.setQuality(qualityNo)
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
        quality := this.quality
        itemName := this.name
        if (quality == "Normal")
            quality := ""

        sockets := ""
        if (this.numSockets > 0) {
            sockets := this.numSockets " sockets"
        }
        switch (itemName) {
            case "Tiara": itemName := "tee-aaruh"
            case "Shael Rune": itemName := "Shayel Rune"
            case "Ko Rune": itemName := "kohh Rune"
            case "Gul Rune": itemName := "Gull Rune"
            case "Amn Rune": itemName := "Amm Rune"
        }
        speechString := quality " " itemName " " sockets
        return speechString
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
        if (0x00000010 & flags) {  ; IFLAG_IDENTIFIED
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
        ; if (0x00000800 & flags) {  ; IFLAG_SOCKETED
        ;     this.socketed := true
        ;     ; flagsList.push("IFLAG_SOCKETED") 
        ; }
        ; if (0x00001000 & flags) {  ; IFLAG_NOSELL
        ;     ; flagsList.push("IFLAG_NOSELL") 
        ; }
        ; if (0x00002000 & flags) {  ; IFLAG_INSTORE
        ;     ; flagsList.push("IFLAG_INSTORE") 
        ; }
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
    
    setItemName(txtFileNo) {
        switch (txtFileNo) {
            case 0: this.name := "Hand Axe" 
            case 1: this.name := "Axe" 
            case 2: this.name := "Double Axe" 
            case 3: this.name := "Military Pick" 
            case 4: this.name := "War Axe" 
            case 5: this.name := "Large Axe" 
            case 6: this.name := "Broad Axe" 
            case 7: this.name := "Battle Axe" 
            case 8: this.name := "Great Axe" 
            case 9: this.name := "Giant Axe" 
            case 10: this.name := "Wand" 
            case 11: this.name := "Yew Wand" 
            case 12: this.name := "Bone Wand" 
            case 13: this.name := "Grim Wand" 
            case 14: this.name := "Club" 
            case 15: this.name := "Scepter" 
            case 16: this.name := "Grand Scepter" 
            case 17: this.name := "War Scepter" 
            case 18: this.name := "Spiked Club" 
            case 19: this.name := "Mace" 
            case 20: this.name := "Morning Star" 
            case 21: this.name := "Flail" 
            case 22: this.name := "War Hammer" 
            case 23: this.name := "Maul" 
            case 24: this.name := "Great Maul" 
            case 25: this.name := "Short Sword" 
            case 26: this.name := "Scimitar" 
            case 27: this.name := "Saber" 
            case 28: this.name := "Falchion" 
            case 29: this.name := "Crystal Sword" 
            case 30: this.name := "Broad Sword" 
            case 31: this.name := "Long Sword" 
            case 32: this.name := "War Sword" 
            case 33: this.name := "Two-Handed Sword" 
            case 34: this.name := "Claymore" 
            case 35: this.name := "Giant Sword" 
            case 36: this.name := "Bastard Sword" 
            case 37: this.name := "Flamberge" 
            case 38: this.name := "Great Sword" 
            case 39: this.name := "Dagger" 
            case 40: this.name := "Dirk" 
            case 41: this.name := "Kriss" 
            case 42: this.name := "Blade" 
            case 43: this.name := "Throwing Knife" 
            case 44: this.name := "Throwing Axe" 
            case 45: this.name := "Balanced Knife" 
            case 46: this.name := "Balanced Axe" 
            case 47: this.name := "Javelin" 
            case 48: this.name := "Pilum" 
            case 49: this.name := "Short Spear" 
            case 50: this.name := "Glaive" 
            case 51: this.name := "Throwing Spear" 
            case 52: this.name := "Spear" 
            case 53: this.name := "Trident" 
            case 54: this.name := "Brandistock" 
            case 55: this.name := "Spetum" 
            case 56: this.name := "Pike" 
            case 57: this.name := "Bardiche" 
            case 58: this.name := "Voulge" 
            case 59: this.name := "Scythe" 
            case 60: this.name := "Poleaxe" 
            case 61: this.name := "Halberd" 
            case 62: this.name := "War Scythe" 
            case 63: this.name := "Short Staff" 
            case 64: this.name := "Long Staff" 
            case 65: this.name := "Gnarled Staff" 
            case 66: this.name := "Battle Staff" 
            case 67: this.name := "War Staff" 
            case 68: this.name := "Short Bow" 
            case 69: this.name := "Hunter's Bow" 
            case 70: this.name := "Long Bow" 
            case 71: this.name := "Composite Bow" 
            case 72: this.name := "Short Battle Bow" 
            case 73: this.name := "Long Battle Bow" 
            case 74: this.name := "Short War Bow" 
            case 75: this.name := "Long War Bow" 
            case 76: this.name := "Light Crossbow" 
            case 77: this.name := "Crossbow" 
            case 78: this.name := "Heavy Crossbow" 
            case 79: this.name := "Repeating Crossbow" 
            case 80: this.name := "Rancid Gas Potion" 
            case 81: this.name := "Oil Potion" 
            case 82: this.name := "Choking Gas Potion" 
            case 83: this.name := "Exploding Potion" 
            case 84: this.name := "Strangling Gas Potion" 
            case 85: this.name := "Fulminating Potion" 
            case 86: this.name := "Decoy Gidbinn" 
            case 87: this.name := "The Gidbinn" 
            case 88: this.name := "Wirt's Leg" 
            case 89: this.name := "Horadric Malus" 
            case 90: this.name := "Hellforge Hammer" 
            case 91: this.name := "Horadric Staff" 
            case 92: this.name := "Staff of Kings" 
            case 93: this.name := "Hatchet" 
            case 94: this.name := "Cleaver" 
            case 95: this.name := "Twin Axe" 
            case 96: this.name := "Crowbill" 
            case 97: this.name := "Naga" 
            case 98: this.name := "Military Axe" 
            case 99: this.name := "Bearded Axe" 
            case 100: this.name := "Tabar" 
            case 101: this.name := "Gothic Axe" 
            case 102: this.name := "Ancient Axe" 
            case 103: this.name := "Burnt Wand" 
            case 104: this.name := "Petrified Wand" 
            case 105: this.name := "Tomb Wand" 
            case 106: this.name := "Grave Wand" 
            case 107: this.name := "Cudgel" 
            case 108: this.name := "Rune Scepter" 
            case 109: this.name := "Holy Water Sprinkler" 
            case 110: this.name := "Divine Scepter" 
            case 111: this.name := "Barbed Club" 
            case 112: this.name := "Flanged Mace" 
            case 113: this.name := "Jagged Star" 
            case 114: this.name := "Knout" 
            case 115: this.name := "Battle Hammer" 
            case 116: this.name := "War Club" 
            case 117: this.name := "Martel de Fer" 
            case 118: this.name := "Gladius" 
            case 119: this.name := "Cutlass" 
            case 120: this.name := "Shamshir" 
            case 121: this.name := "Tulwar" 
            case 122: this.name := "Dimensional Blade" 
            case 123: this.name := "Battle Sword" 
            case 124: this.name := "Rune Sword" 
            case 125: this.name := "Ancient Sword" 
            case 126: this.name := "Espandon" 
            case 127: this.name := "Dacian Falx" 
            case 128: this.name := "Tusk Sword" 
            case 129: this.name := "Gothic Sword" 
            case 130: this.name := "Zweihander" 
            case 131: this.name := "Executioner Sword" 
            case 132: this.name := "Poignard" 
            case 133: this.name := "Rondel" 
            case 134: this.name := "Cinquedeas" 
            case 135: this.name := "Stilleto" 
            case 136: this.name := "Battle Dart" 
            case 137: this.name := "Francisca" 
            case 138: this.name := "War Dart" 
            case 139: this.name := "Hurlbat" 
            case 140: this.name := "War Javelin" 
            case 141: this.name := "Great Pilum" 
            case 142: this.name := "Simbilan" 
            case 143: this.name := "Spiculum" 
            case 144: this.name := "Harpoon" 
            case 145: this.name := "War Spear" 
            case 146: this.name := "Fuscina" 
            case 147: this.name := "War Fork" 
            case 148: this.name := "Yari" 
            case 149: this.name := "Lance" 
            case 150: this.name := "Lochaber Axe" 
            case 151: this.name := "Bill" 
            case 152: this.name := "Battle Scythe" 
            case 153: this.name := "Partizan" 
            case 154: this.name := "Bec-de-Corbin" 
            case 155: this.name := "Grim Scythe" 
            case 156: this.name := "Jo Staff" 
            case 157: this.name := "Quarterstaff" 
            case 158: this.name := "Cedar Staff" 
            case 159: this.name := "Gothic Staff" 
            case 160: this.name := "Rune Staff" 
            case 161: this.name := "Edge Bow" 
            case 162: this.name := "Razor Bow" 
            case 163: this.name := "Cedar Bow" 
            case 164: this.name := "Double Bow" 
            case 165: this.name := "Short Siege Bow" 
            case 166: this.name := "Long Siege Bow" 
            case 167: this.name := "Rune Bow" 
            case 168: this.name := "Gothic Bow" 
            case 169: this.name := "Arbalest" 
            case 170: this.name := "Siege Crossbow" 
            case 171: this.name := "Ballista" 
            case 172: this.name := "Chu-Ko-Nu" 
            case 173: this.name := "Khalim's Flail" 
            case 174: this.name := "Khalim's Will" 
            case 175: this.name := "Katar" 
            case 176: this.name := "Wrist Blade" 
            case 177: this.name := "Hatchet Hands" 
            case 178: this.name := "Cestus" 
            case 179: this.name := "Claws" 
            case 180: this.name := "Blade Talons" 
            case 181: this.name := "Scissors Katar" 
            case 182: this.name := "Quhab" 
            case 183: this.name := "Wrist Spike" 
            case 184: this.name := "Fascia" 
            case 185: this.name := "Hand Scythe" 
            case 186: this.name := "Greater Claws" 
            case 187: this.name := "Greater Talons" 
            case 188: this.name := "Scissors Quhab" 
            case 189: this.name := "Suwayyah" 
            case 190: this.name := "Wrist Sword" 
            case 191: this.name := "War Fist" 
            case 192: this.name := "Battle Cestus" 
            case 193: this.name := "Feral Claws" 
            case 194: this.name := "Runic Talons" 
            case 195: this.name := "Scissors Suwayyah" 
            case 196: this.name := "Tomahawk" 
            case 197: this.name := "Small Crescent" 
            case 198: this.name := "Ettin Axe" 
            case 199: this.name := "War Spike" 
            case 200: this.name := "Berserker Axe" 
            case 201: this.name := "Feral Axe" 
            case 202: this.name := "Silver-edged Axe" 
            case 203: this.name := "Decapitator" 
            case 204: this.name := "Champion Axe" 
            case 205: this.name := "Glorious Axe" 
            case 206: this.name := "Polished Wand" 
            case 207: this.name := "Ghost Wand" 
            case 208: this.name := "Lich Wand" 
            case 209: this.name := "Unearthed Wand" 
            case 210: this.name := "Truncheon" 
            case 211: this.name := "Mighty Scepter" 
            case 212: this.name := "Seraph Rod" 
            case 213: this.name := "Caduceus" 
            case 214: this.name := "Tyrant Club" 
            case 215: this.name := "Reinforced Mace" 
            case 216: this.name := "Devil Star" 
            case 217: this.name := "Scourge" 
            case 218: this.name := "Legendary Mallet" 
            case 219: this.name := "Ogre Maul" 
            case 220: this.name := "Thunder Maul" 
            case 221: this.name := "Falcata" 
            case 222: this.name := "Ataghan" 
            case 223: this.name := "Elegant Blade" 
            case 224: this.name := "Hydra Edge" 
            case 225: this.name := "Phase Blade" 
            case 226: this.name := "Conquest Sword" 
            case 227: this.name := "Cryptic Sword" 
            case 228: this.name := "Mythical Sword" 
            case 229: this.name := "Legend Sword" 
            case 230: this.name := "Highland Blade" 
            case 231: this.name := "Balrog Blade" 
            case 232: this.name := "Champion Sword" 
            case 233: this.name := "Colossal Sword" 
            case 234: this.name := "Colossus Blade" 
            case 235: this.name := "Bone Knife" 
            case 236: this.name := "Mithral Point" 
            case 237: this.name := "Fanged Knife" 
            case 238: this.name := "Legend Spike" 
            case 239: this.name := "Flying Knife" 
            case 240: this.name := "Flying Axe" 
            case 241: this.name := "Winged Knife" 
            case 242: this.name := "Winged Axe" 
            case 243: this.name := "Hyperion Javelin" 
            case 244: this.name := "Stygian Pilum" 
            case 245: this.name := "Balrog Spear" 
            case 246: this.name := "Ghost Glaive" 
            case 247: this.name := "Winged Harpoon" 
            case 248: this.name := "Hyperion Spear" 
            case 249: this.name := "Stygian Pike" 
            case 250: this.name := "Mancatcher" 
            case 251: this.name := "Ghost Spear" 
            case 252: this.name := "War Pike" 
            case 253: this.name := "Ogre Axe" 
            case 254: this.name := "Colossus Voulge" 
            case 255: this.name := "Thresher" 
            case 256: this.name := "Cryptic Axe" 
            case 257: this.name := "Great Poleaxe" 
            case 258: this.name := "Giant Thresher" 
            case 259: this.name := "Walking Stick" 
            case 260: this.name := "Stalagmite" 
            case 261: this.name := "Elder Staff" 
            case 262: this.name := "Shillelagh" 
            case 263: this.name := "Archon Staff" 
            case 264: this.name := "Spider Bow" 
            case 265: this.name := "Blade Bow" 
            case 266: this.name := "Shadow Bow" 
            case 267: this.name := "Great Bow" 
            case 268: this.name := "Diamond Bow" 
            case 269: this.name := "Crusader Bow" 
            case 270: this.name := "Ward Bow" 
            case 271: this.name := "Hydra Bow" 
            case 272: this.name := "Pellet Bow" 
            case 273: this.name := "Gorgon Crossbow" 
            case 274: this.name := "Colossus Crossbow" 
            case 275: this.name := "Demon Crossbow" 
            case 276: this.name := "Eagle Orb" 
            case 277: this.name := "Sacred Globe" 
            case 278: this.name := "Smoked Sphere" 
            case 279: this.name := "Clasped Orb" 
            case 280: this.name := "Jared's Stone" 
            case 281: this.name := "Stag Bow" 
            case 282: this.name := "Reflex Bow" 
            case 283: this.name := "Maiden Spear" 
            case 284: this.name := "Maiden Pike" 
            case 285: this.name := "Maiden Javelin" 
            case 286: this.name := "Glowing Orb" 
            case 287: this.name := "Crystalline Globe" 
            case 288: this.name := "Cloudy Sphere" 
            case 289: this.name := "Sparkling Ball" 
            case 290: this.name := "Swirling Crystal" 
            case 291: this.name := "Ashwood Bow" 
            case 292: this.name := "Ceremonial Bow" 
            case 293: this.name := "Ceremonial Spear" 
            case 294: this.name := "Ceremonial Pike" 
            case 295: this.name := "Ceremonial Javelin" 
            case 296: this.name := "Heavenly Stone" 
            case 297: this.name := "Eldritch Orb" 
            case 298: this.name := "Demon Heart" 
            case 299: this.name := "Vortex Orb" 
            case 300: this.name := "Dimensional Shard" 
            case 301: this.name := "Matriarchal Bow" 
            case 302: this.name := "Grand Matron Bow" 
            case 303: this.name := "Matriarchal Spear" 
            case 304: this.name := "Matriarchal Pike" 
            case 305: this.name := "Matriarchal Javelin" 
            case 306: this.name := "Cap" 
            case 307: this.name := "Skull Cap" 
            case 308: this.name := "Helm" 
            case 309: this.name := "Full Helm" 
            case 310: this.name := "Great Helm" 
            case 311: this.name := "Crown" 
            case 312: this.name := "Mask" 
            case 313: this.name := "Quilted Armor" 
            case 314: this.name := "Leather Armor" 
            case 315: this.name := "Hard Leather Armor" 
            case 316: this.name := "Studded Leather" 
            case 317: this.name := "Ring Mail" 
            case 318: this.name := "Scale Mail" 
            case 319: this.name := "Chain Mail" 
            case 320: this.name := "Breast Plate" 
            case 321: this.name := "Splint Mail" 
            case 322: this.name := "Plate Mail" 
            case 323: this.name := "Field Plate" 
            case 324: this.name := "Gothic Plate" 
            case 325: this.name := "Full Plate Mail" 
            case 326: this.name := "Ancient Armor" 
            case 327: this.name := "Light Plate" 
            case 328: this.name := "Buckler" 
            case 329: this.name := "Small Shield" 
            case 330: this.name := "Large Shield" 
            case 331: this.name := "Kite Shield" 
            case 332: this.name := "Tower Shield" 
            case 333: this.name := "Gothic Shield" 
            case 334: this.name := "Leather Gloves" 
            case 335: this.name := "Heavy Gloves" 
            case 336: this.name := "Chain Gloves" 
            case 337: this.name := "Light Gauntlets" 
            case 338: this.name := "Gauntlets" 
            case 339: this.name := "Boots" 
            case 340: this.name := "Heavy Boots" 
            case 341: this.name := "Chain Boots" 
            case 342: this.name := "Light Plated Boots" 
            case 343: this.name := "Greaves" 
            case 344: this.name := "Sash" 
            case 345: this.name := "Light Belt" 
            case 346: this.name := "Belt" 
            case 347: this.name := "Heavy Belt" 
            case 348: this.name := "Plated Belt" 
            case 349: this.name := "Bone Helm" 
            case 350: this.name := "Bone Shield" 
            case 351: this.name := "Spiked Shield" 
            case 352: this.name := "War Hat" 
            case 353: this.name := "Sallet" 
            case 354: this.name := "Casque" 
            case 355: this.name := "Basinet" 
            case 356: this.name := "Winged Helm" 
            case 357: this.name := "Grand Crown" 
            case 358: this.name := "Death Mask" 
            case 359: this.name := "Ghost Armor" 
            case 360: this.name := "Serpentskin Armor" 
            case 361: this.name := "Demonhide Armor" 
            case 362: this.name := "Trellised Armor" 
            case 363: this.name := "Linked Mail" 
            case 364: this.name := "Tigulated Mail" 
            case 365: this.name := "Mesh Armor" 
            case 366: this.name := "Cuirass" 
            case 367: this.name := "Russet Armor" 
            case 368: this.name := "Templar Coat" 
            case 369: this.name := "Sharktooth Armor" 
            case 370: this.name := "Embossed Plate" 
            case 371: this.name := "Chaos Armor" 
            case 372: this.name := "Ornate Armor" 
            case 373: this.name := "Mage Plate" 
            case 374: this.name := "Defender" 
            case 375: this.name := "Round Shield" 
            case 376: this.name := "Scutum" 
            case 377: this.name := "Dragon Shield" 
            case 378: this.name := "Pavise" 
            case 379: this.name := "Ancient Shield" 
            case 380: this.name := "Demonhide Gloves" 
            case 381: this.name := "Sharkskin Gloves" 
            case 382: this.name := "Heavy Bracers" 
            case 383: this.name := "Battle Gauntlets" 
            case 384: this.name := "War Gauntlets" 
            case 385: this.name := "Demonhide Boots" 
            case 386: this.name := "Sharkskin Boots" 
            case 387: this.name := "Mesh Boots" 
            case 388: this.name := "Battle Boots" 
            case 389: this.name := "War Boots" 
            case 390: this.name := "Demonhide Sash" 
            case 391: this.name := "Sharkskin Belt" 
            case 392: this.name := "Mesh Belt" 
            case 393: this.name := "Battle Belt" 
            case 394: this.name := "War Belt" 
            case 395: this.name := "Grim Helm" 
            case 396: this.name := "Grim Shield" 
            case 397: this.name := "Barbed Shield" 
            case 398: this.name := "Wolf Head" 
            case 399: this.name := "Hawk Helm" 
            case 400: this.name := "Antlers" 
            case 401: this.name := "Falcon Mask" 
            case 402: this.name := "Spirit Mask" 
            case 403: this.name := "Jawbone Cap" 
            case 404: this.name := "Fanged Helm" 
            case 405: this.name := "Horned Helm" 
            case 406: this.name := "Assault Helmet" 
            case 407: this.name := "Avenger Guard" 
            case 408: this.name := "Targe" 
            case 409: this.name := "Rondache" 
            case 410: this.name := "Heraldic Shield" 
            case 411: this.name := "Aerin Shield" 
            case 412: this.name := "Crown Shield" 
            case 413: this.name := "Preserved Head" 
            case 414: this.name := "Zombie Head" 
            case 415: this.name := "Unraveller Head" 
            case 416: this.name := "Gargoyle Head" 
            case 417: this.name := "Demon Head" 
            case 418: this.name := "Circlet" 
            case 419: this.name := "Coronet" 
            case 420: this.name := "Tiara" 
            case 421: this.name := "Diadem" 
            case 422: this.name := "Shako" 
            case 423: this.name := "Hydraskull" 
            case 424: this.name := "Armet" 
            case 425: this.name := "Giant Conch" 
            case 426: this.name := "Spired Helm" 
            case 427: this.name := "Corona" 
            case 428: this.name := "Demonhead" 
            case 429: this.name := "Dusk Shroud" 
            case 430: this.name := "Wyrmhide" 
            case 431: this.name := "Scarab Husk" 
            case 432: this.name := "Wire Fleece" 
            case 433: this.name := "Diamond Mail" 
            case 434: this.name := "Loricated Mail" 
            case 435: this.name := "Boneweave" 
            case 436: this.name := "Great Hauberk" 
            case 437: this.name := "Balrog Skin" 
            case 438: this.name := "Hellforge Plate" 
            case 439: this.name := "Kraken Shell" 
            case 440: this.name := "Lacquered Plate" 
            case 441: this.name := "Shadow Plate" 
            case 442: this.name := "Sacred Armor" 
            case 443: this.name := "Archon Plate" 
            case 444: this.name := "Heater" 
            case 445: this.name := "Luna" 
            case 446: this.name := "Hyperion" 
            case 447: this.name := "Monarch" 
            case 448: this.name := "Aegis" 
            case 449: this.name := "Ward" 
            case 450: this.name := "Bramble Mitts" 
            case 451: this.name := "Vampirebone Gloves" 
            case 452: this.name := "Vambraces" 
            case 453: this.name := "Crusader Gauntlets" 
            case 454: this.name := "Ogre Gauntlets" 
            case 455: this.name := "Wyrmhide Boots" 
            case 456: this.name := "Scarabshell Boots" 
            case 457: this.name := "Boneweave Boots" 
            case 458: this.name := "Mirrored Boots" 
            case 459: this.name := "Myrmidon Greaves" 
            case 460: this.name := "Spiderweb Sash" 
            case 461: this.name := "Vampirefang Belt" 
            case 462: this.name := "Mithril Coil" 
            case 463: this.name := "Troll Belt" 
            case 464: this.name := "Colossus Girdle" 
            case 465: this.name := "Bone Visage" 
            case 466: this.name := "Troll Nest" 
            case 467: this.name := "Blade Barrier" 
            case 468: this.name := "Alpha Helm" 
            case 469: this.name := "Griffon Headress" 
            case 470: this.name := "Hunter's Guise" 
            case 471: this.name := "Sacred Feathers" 
            case 472: this.name := "Totemic Mask" 
            case 473: this.name := "Jawbone Visor" 
            case 474: this.name := "Lion Helm" 
            case 475: this.name := "Rage Mask" 
            case 476: this.name := "Savage Helmet" 
            case 477: this.name := "Slayer Guard" 
            case 478: this.name := "Akaran Targe" 
            case 479: this.name := "Akaran Rondache" 
            case 480: this.name := "Protector Shield" 
            case 481: this.name := "Gilded Shield" 
            case 482: this.name := "Royal Shield" 
            case 483: this.name := "Mummified Trophy" 
            case 484: this.name := "Fetish Trophy" 
            case 485: this.name := "Sexton Trophy" 
            case 486: this.name := "Cantor Trophy" 
            case 487: this.name := "Heirophant Trophy" 
            case 488: this.name := "Blood Spirit" 
            case 489: this.name := "Sun Spirit" 
            case 490: this.name := "Earth Spirit" 
            case 491: this.name := "Sky Spirit" 
            case 492: this.name := "Dream Spirit" 
            case 493: this.name := "Carnage Helm" 
            case 494: this.name := "Fury Visor" 
            case 495: this.name := "Destroyer Helm" 
            case 496: this.name := "Conqueror Crown" 
            case 497: this.name := "Guardian Crown" 
            case 498: this.name := "Sacred Targe" 
            case 499: this.name := "Sacred Rondache" 
            case 500: this.name := "Ancient Shield" 
            case 501: this.name := "Zakarum Shield" 
            case 502: this.name := "Vortex Shield" 
            case 503: this.name := "Minion Skull" 
            case 504: this.name := "Hellspawn Skull" 
            case 505: this.name := "Overseer Skull" 
            case 506: this.name := "Succubus Skull" 
            case 507: this.name := "Bloodlord Skull" 
            case 508: this.name := "Elixir" 
            case 509: this.name := "Healing Potion" 
            case 510: this.name := "Mana Potion" 
            case 511: this.name := "Full Healing Potion" 
            case 512: this.name := "Full Mana Potion" 
            case 513: this.name := "Stamina Potion" 
            case 514: this.name := "Antidote Potion" 
            case 515: this.name := "Rejuvenation Potion" 
            case 516: this.name := "Full Rejuvenation Potion" 
            case 517: this.name := "Thawing Potion" 
            case 518: this.name := "Tome of Town Portal" 
            case 519: this.name := "Tome of Identify" 
            case 520: this.name := "Amulet" 
            case 521: this.name := "Amulet of the Viper" 
            case 522: this.name := "Ring" 
            case 523: this.name := "Gold" 
            case 524: this.name := "Scroll of Inifuss" 
            case 525: this.name := "Key to the Cairn Stones" 
            case 526: this.name := "Arrows" 
            case 527: this.name := "Torch" 
            case 528: this.name := "Bolts" 
            case 529: this.name := "Scroll of Town Portal" 
            case 530: this.name := "Scroll of Identify" 
            case 531: this.name := "Heart" 
            case 532: this.name := "Brain" 
            case 533: this.name := "Jawbone" 
            case 534: this.name := "Eye" 
            case 535: this.name := "Horn" 
            case 536: this.name := "Tail" 
            case 537: this.name := "Flag" 
            case 538: this.name := "Fang" 
            case 539: this.name := "Quill" 
            case 540: this.name := "Soul" 
            case 541: this.name := "Scalp" 
            case 542: this.name := "Spleen" 
            case 543: this.name := "Key" 
            case 544: this.name := "The Black Tower Key" 
            case 545: this.name := "Potion of Life" 
            case 546: this.name := "A Jade Figurine" 
            case 547: this.name := "The Golden Bird" 
            case 548: this.name := "Lam Esen's Tome" 
            case 549: this.name := "Horadric Cube" 
            case 550: this.name := "Horadric Scroll" 
            case 551: this.name := "Mephisto's Soulstone" 
            case 552: this.name := "Book of Skill" 
            case 553: this.name := "Khalim's Eye" 
            case 554: this.name := "Khalim's Heart" 
            case 555: this.name := "Khalim's Brain" 
            case 556: this.name := "Ear" 
            case 557: this.name := "Chipped Amethyst" 
            case 558: this.name := "Flawed Amethyst" 
            case 559: this.name := "Amethyst" 
            case 560: this.name := "Flawless Amethyst" 
            case 561: this.name := "Perfect Amethyst" 
            case 562: this.name := "Chipped Topaz" 
            case 563: this.name := "Flawed Topaz" 
            case 564: this.name := "Topaz" 
            case 565: this.name := "Flawless Topaz" 
            case 566: this.name := "Perfect Topaz" 
            case 567: this.name := "Chipped Sapphire" 
            case 568: this.name := "Flawed Sapphire" 
            case 569: this.name := "Sapphire" 
            case 570: this.name := "Flawless Sapphire" 
            case 571: this.name := "Perfect Sapphire" 
            case 572: this.name := "Chipped Emerald" 
            case 573: this.name := "Flawed Emerald" 
            case 574: this.name := "Emerald" 
            case 575: this.name := "Flawless Emerald" 
            case 576: this.name := "Perfect Emerald" 
            case 577: this.name := "Chipped Ruby" 
            case 578: this.name := "Flawed Ruby" 
            case 579: this.name := "Ruby" 
            case 580: this.name := "Flawless Ruby" 
            case 581: this.name := "Perfect Ruby" 
            case 582: this.name := "Chipped Diamond" 
            case 583: this.name := "Flawed Diamond" 
            case 584: this.name := "Diamond" 
            case 585: this.name := "Flawless Diamond" 
            case 586: this.name := "Perfect Diamond" 
            case 587: this.name := "Minor Healing Potion" 
            case 588: this.name := "Light Healing Potion" 
            case 589: this.name := "Healing Potion" 
            case 590: this.name := "Greater Healing Potion" 
            case 591: this.name := "Super Healing Potion" 
            case 592: this.name := "Minor Mana Potion" 
            case 593: this.name := "Light Mana Potion" 
            case 594: this.name := "Mana Potion" 
            case 595: this.name := "Greater Mana Potion" 
            case 596: this.name := "Super Mana Potion" 
            case 597: this.name := "Chipped Skull" 
            case 598: this.name := "Flawed Skull" 
            case 599: this.name := "Skull" 
            case 600: this.name := "Flawless Skull" 
            case 601: this.name := "Perfect Skull" 
            case 602: this.name := "Herb" 
            case 603: this.name := "Small Charm" 
            case 604: this.name := "Large Charm" 
            case 605: this.name := "Grand Charm" 
            case 606: this.name := "Small Red Potion" 
            case 607: this.name := "Large Red Potion" 
            case 608: this.name := "Small Blue Potion" 
            case 609: this.name := "Large Blue Potion" 
            case 610: this.name := "El Rune" 
            case 611: this.name := "Eld Rune" 
            case 612: this.name := "Tir Rune" 
            case 613: this.name := "Nef Rune" 
            case 614: this.name := "Eth Rune" 
            case 615: this.name := "Ith Rune" 
            case 616: this.name := "Tal Rune" 
            case 617: this.name := "Ral Rune" 
            case 618: this.name := "Ort Rune" 
            case 619: this.name := "Thul Rune" 
            case 620: this.name := "Amn Rune" 
            case 621: this.name := "Sol Rune" 
            case 622: this.name := "Shael Rune" 
            case 623: this.name := "Dol Rune" 
            case 624: this.name := "Hel Rune" 
            case 625: this.name := "Io Rune" 
            case 626: this.name := "Lum Rune" 
            case 627: this.name := "Ko Rune" 
            case 628: this.name := "Fal Rune" 
            case 629: this.name := "Lem Rune" 
            case 630: this.name := "Pul Rune" 
            case 631: this.name := "Um Rune" 
            case 632: this.name := "Mal Rune" 
            case 633: this.name := "Ist Rune" 
            case 634: this.name := "Gul Rune" 
            case 635: this.name := "Vex Rune" 
            case 636: this.name := "Ohm Rune" 
            case 637: this.name := "Lo Rune" 
            case 638: this.name := "Sur Rune" 
            case 639: this.name := "Ber Rune" 
            case 640: this.name := "Jah Rune" 
            case 641: this.name := "Cham Rune" 
            case 642: this.name := "Zod Rune" 
            case 643: this.name := "Jewel" 
            case 644: this.name := "Malah's Potion" 
            case 645: this.name := "Scroll of Knowledge" 
            case 646: this.name := "Scroll of Resistance" 
            case 647: this.name := "Key of Terror" 
            case 648: this.name := "Key of Hate" 
            case 649: this.name := "Key of Destruction" 
            case 650: this.name := "Diablo's Horn" 
            case 651: this.name := "Baal's Eye" 
            case 652: this.name := "Mephisto's Brain" 
            case 653: this.name := "Token of Absolution" 
            case 654: this.name := "Twisted Essence of Suffering" 
            case 655: this.name := "Charged Essense of Hatred" 
            case 656: this.name := "Burning Essence of Terror" 
            case 657: this.name := "Festering Essence of Destruction" 
            case 658: this.name := "Standard of Heroes"
            default: this.name := ""
        }
        
    }
}



; isBaseItem(itemName, numSockets, itemQuality) {
;     if (itemQuality == 2 or itemQuality == 3) { ; normal or superior
;         switch (numSockets " " itemName) {
;             ;armour
;             case "4 Archon Plate": return 1
;             case "3 Mage Plate": return 1
;             case "4 Dusk Shroud": return 1
;             case "3 Wyrmhide": return 1
;             case "4 Wyrmhide": return 1
;             ;weapons
;             case "3 Phase Blade": return 1
;             case "4 Phase Blade": return 1
;             case "5 Phase Blade": return 1
;             case "3 Crystal Sword": return 1
;             case "4 Crystal Sword": return 1
;             case "5 Crystal Sword": return 1
;             case "4 Flail": return 1
;             case "5 Flail": return 1
;             case "4 Long Sword": return 1
;             ; helms
;             case "3 Bone Visage": return 1
;             case "3 Circlet": return 1
;             case "3 Diadem": return 1
;             case "3 Coronet": return 1
;             ;shields
;             case "4 Monarch": return 1
;             case "3 Akaran Targe": return 1
;             case "3 Akaran Rondache": return 1
;             case "3 Sacred Targe": return 1
;             case "3 Sacred Rondache": return 1
;             case "3 Targe": return 1
;             case "3 Rondache": return 1
;             case "3 Heraldic Shield": return 1
;             case "4 Heraldic Shield": return 1
;             case "3 Aerin Shield": return 1
;             ; merc bases
;             case "4 Giant Thresher": return 1
;             case "4 Thresher": return 1
;             case "4 Colossus Voulge": return 1
;         }
;     }
;     return 0
; }

