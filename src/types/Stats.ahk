
loadStats(ByRef statCount, ByRef statPtr, ByRef statExCount, ByRef statExPtr) {
    SetFormat Integer, D
    statCount := statCount
    d2rprocess.readRaw(statPtr, statBuffer, statCount*10)
    statArray := []
    skillsfound := 0
    Loop, %statCount%
    {
        offset := (A_Index -1) * 8
        , statLayer := NumGet(&statBuffer, offset, Type := "Short")
        , statEnum := NumGet(&statBuffer, offset + 0x2, Type := "UShort")
        , statValue := NumGet(&statBuffer , offset + 0x4, Type := "Int")
        switch (statEnum) {
            case 6: statValue := statValue >> 8   ; life
            case 7: statValue := statValue >> 8   ; maxlife
            case 8: statValue := statValue >> 8   ; mana
            case 9: statValue := statValue >> 8   ; maxmana
            case 10: statValue := statValue >> 8   ; stamina
            case 11: statValue := statValue >> 8   ; maxstamina
            case 216: statValue := statValue >> 8   ; item_hp_perlevel
            case 217: statValue := statValue >> 8   ; item_mana_perlevel
            case 56: statValue := statValue / 25   ; cold length, divided by num frames
            case 59: statValue := statValue / 25   ; poison length
        }
        statName := getStatName(statEnum)
        if (statEnum == 107) {
            skillsfound++
            statName := statName . skillsfound
            
        }
        ;OutputDebug, % statName " " statEnum " " statLayer " " statValue "`n"
        statArray[statName] := { "statLayer": statLayer, "statValue": statValue }
    }
    statExCount := statExCount
    d2rprocess.readRaw(statExPtr, statBuffer, statExCount*10)
    Loop, %statExCount%
    {
        offset := (A_Index -1) * 8
        , statLayer := NumGet(&statBuffer, offset, Type := "Short")
        , statEnum := NumGet(&statBuffer, offset + 0x2, Type := "UShort")
        , statValue := NumGet(&statBuffer , offset + 0x4, Type := "Int")
        switch (statEnum) {
            case 6: statValue := statValue >> 8   ; life
            case 7: statValue := statValue >> 8   ; maxlife
            case 8: statValue := statValue >> 8   ; mana
            case 9: statValue := statValue >> 8   ; maxmana
            case 10: statValue := statValue >> 8   ; stamina
            case 11: statValue := statValue >> 8   ; maxstamina
            case 216: statValue := statValue >> 8   ; item_hp_perlevel
            case 217: statValue := statValue >> 8   ; item_mana_perlevel
            case 56: statValue := Round(statValue / 25, 0)   ; cold length, divided by num frames
            case 59: statValue := Round(statValue / 25, 0)   ; poison length
        }
        statName := getStatName(statEnum)
        if (statEnum == 107) {
            skillsfound++
            statName := statName . skillsfound
            
        }
        ;OutputDebug, % statName " " statEnum " " statLayer " " statValue "`n"
        statOrder := getStatSortPriority(statName) ;"_" statName
        statArray[statName] := { "statLayer": statLayer, "statValue": statValue, "statOrder": statOrder }
    }

    ; turn list of stats into readable format
    statList := formatStats(statArray)
    return statList
}


formatStats(statArray) {
    statList := []
    for statName, statVal in statArray {
        switch (statName) {
            case "strength":
                if ((statArray["strength"].statValue == statArray["vitality"].statValue) and (statArray["energy"].statValue == statArray["dexterity"].statValue) and (statArray["strength"].statValue == statArray["dexterity"].statValue)) {
                    statList[statArray["strength"].statOrder] := Format("+{1} to all Attributes", statArray["strength"].statValue)
                } else {
                    if (statArray["strength"].statValue > 0) {
                        statList[statArray["strength"].statOrder] := Format("+{1} to Strength", statArray["strength"].statValue)
                    }
                }
            case "energy": 
                if not ((statArray["strength"].statValue == statArray["vitality"].statValue) and (statArray["energy"].statValue == statArray["dexterity"].statValue) and (statArray["strength"].statValue == statArray["dexterity"].statValue)) {
                    if (statArray["energy"].statValue > 0) {
                        statList[statArray["energy"].statOrder] := Format("+{1} to Energy", statArray["energy"].statValue)
                    }
                }
            case "dexterity":
                if not ((statArray["strength"].statValue == statArray["vitality"].statValue) and (statArray["energy"].statValue == statArray["dexterity"].statValue) and (statArray["strength"].statValue == statArray["dexterity"].statValue)) {
                    if (statArray["dexterity"].statValue > 0) {
                        statList[statArray["dexterity"].statOrder] := Format("+{1} to Dexterity", statArray["dexterity"].statValue)
                    }
                }
            case "vitality": 
                if not ((statArray["strength"].statValue == statArray["vitality"].statValue) and (statArray["energy"].statValue == statArray["dexterity"].statValue) and (statArray["strength"].statValue == statArray["dexterity"].statValue)) {
                    if (statArray["vitality"].statValue > 0) {
                        statList[statArray["vitality"].statOrder] := Format("+{1} to Vitality", statArray["vitality"].statValue)
                    }
                }
            case "maxhp": statList[statArray["maxhp"].statOrder]:= Format("+{1} to Life", statArray["maxhp"].statValue)
            case "maxmana": statList[statArray["maxmana"].statOrder]:= Format("+{1} to Mana", statArray["maxmana"].statValue)
            case "maxstamina": statList[statArray["maxstamina"].statOrder]:= Format("+{1} Maximum Stamina", statArray["maxstamina"].statValue)
            case "item_armor_percent": statList[statArray["item_armor_percent"].statOrder]:= Format("+{1}% Enhanced Defense", statArray["item_armor_percent"].statValue)
            case "tohit": statList[statArray["tohit"].statOrder]:= Format("+{1} to Attack Rating", statArray["tohit"].statValue)
            case "toblock": statList[statArray["toblock"].statOrder]:= Format("{1}% Increased Chance of Blocking", statArray["toblock"].statValue)
            ;case "mindamage": := Format("Adds {1}-{2} Damage", statArray["mindamage"].statValue)
            case "manarecoverybonus": statList[statArray["manarecoverybonus"].statOrder]:= Format("Regenerate Mana {1}%", statArray["manarecoverybonus"].statValue)
            case "staminarecoverybonus": statList[statArray["staminarecoverybonus"].statOrder]:= Format("Heal Stamina Plus {1}%", statArray["staminarecoverybonus"].statValue)
            case "armorclass": statList[statArray["armorclass"].statOrder]:= Format("{1} Defense", statArray["armorclass"].statValue)
            case "armorclass_vs_missile": statList[statArray["armorclass_vs_missile"].statOrder]:= Format("+{1} Defense vs. Missile", statArray["armorclass_vs_missile"].statValue)
            case "armorclass_vs_hth": statList[statArray["armorclass_vs_hth"].statOrder]:= Format("+{1} Defense vs. Melee", statArray["armorclass_vs_hth"].statValue)
            case "normal_damage_reduction": statList[statArray["normal_damage_reduction"].statOrder]:= Format("Damage Reduced by {1}", statArray["normal_damage_reduction"].statValue)
            case "magic_damage_reduction": statList[statArray["magic_damage_reduction"].statOrder]:= Format("Magic Damage Reduced by {1}", statArray["magic_damage_reduction"].statValue)
            case "damageresist": statList[statArray["damageresist"].statOrder]:= Format("Damage Reduced by {1}%", statArray["damageresist"].statValue)
            case "magicresist": statList[statArray["magicresist"].statOrder]:= Format("Magic Resist +{1}%", statArray["magicresist"].statValue)
            case "maxmagicresist": statList[statArray["maxmagicresist"].statOrder]:= Format("+{1}% to Maximum Magic Resist", statArray["maxmagicresist"].statValue)
            case "fireresist":
                if ((statArray["lightresist"].statValue == statArray["poisonresist"].statValue) and (statArray["coldresist"].statValue == statArray["fireresist"].statValue) and (statArray["lightresist"].statValue == statArray["fireresist"].statValue)) {
                    statList[statArray["fireresist"].statOrder]:= Format("All Resistances +{1}", statArray["fireresist"].statValue)
                } else {
                    statList[statArray["fireresist"].statOrder]:= Format("Fire Resist +{1}%", statArray["fireresist"].statValue)
                }
            case "maxfireresist": statList[statArray["maxfireresist"].statOrder]:= Format("+{1}% to Maximum Fire Resist", statArray["maxfireresist"].statValue)
            case "lightresist": 
                if not ((statArray["lightresist"].statValue == statArray["poisonresist"].statValue) and (statArray["coldresist"].statValue == statArray["fireresist"].statValue) and (statArray["lightresist"].statValue == statArray["fireresist"].statValue)) {
                    statList[statArray["lightresist"].statOrder]:= Format("Lightning Resist +{1}%", statArray["lightresist"].statValue)
                }
            case "maxlightresist": statList[statArray["maxlightresist"].statOrder]:= Format("+{1}% to Maximum Lightning Resist", statArray["maxlightresist"].statValue)
            case "coldresist": 
                if not ((statArray["lightresist"].statValue == statArray["poisonresist"].statValue) and (statArray["coldresist"].statValue == statArray["fireresist"].statValue) and (statArray["lightresist"].statValue == statArray["fireresist"].statValue)) {
                    statList[statArray["coldresist"].statOrder]:= Format("Cold Resist +{1}%", statArray["coldresist"].statValue)
                }
            case "maxcoldresist": statList[statArray["maxcoldresist"].statOrder]:= Format("+{1}% to Maximum Cold Resist", statArray["maxcoldresist"].statValue)
            case "poisonresist": 
                if not ((statArray["lightresist"].statValue == statArray["poisonresist"].statValue) and (statArray["coldresist"].statValue == statArray["fireresist"].statValue) and (statArray["lightresist"].statValue == statArray["fireresist"].statValue)) {
                    statList[statArray["poisonresist"].statOrder]:= Format("Poison Resist +{1}%", statArray["poisonresist"].statValue)
                }
            case "maxpoisonresist": statList[statArray["maxpoisonresist"].statOrder]:= Format("+{1}% to Maximum Poison Resist", statArray["maxpoisonresist"].statValue)
            case "firemindam": 
                if (statArray["firemindam"].statValue and statArray["firemaxdam"].statValue) {
                    statList[statArray["firemindam"].statOrder]:= Format("Adds {1}-{2} Fire Damage", statArray["firemindam"].statValue, statArray["firemaxdam"].statValue)
                } else {
                    statList[statArray["firemindam"].statOrder]:= Format("+{1} to Minimum Fire Damage", statArray["firemindam"].statValue)
                }
            
            case "firemaxdam": 
                if not (statArray["firemindam"].statValue and statArray["firemaxdam"].statValue) {
                    statList[statArray["firemaxdam"].statOrder]:= Format("+{1} to Maximum Fire Damage", statArray["firemaxdam"].statValue)
                }
            case "lightmindam": 
                if (statArray["lightmindam"].statValue and statArray["lightmaxdam"].statValue) {
                    statList[statArray["lightmindam"].statOrder]:= Format("Adds {1}-{2} Lightning Damage", statArray["lightmindam"].statValue, statArray["lightmaxdam"].statValue)
                } else {
                    statList[statArray["lightmindam"].statOrder]:= Format("+{1} to Minimum Lightning Damage", statArray["lightmindam"].statValue)
                }
            case "lightmaxdam": 
                if not (statArray["lightmindam"].statValue and statArray["lightmaxdam"].statValue) {
                    statList[statArray["lightmaxdam"].statOrder]:= Format("+{1} to Maximum Lightning Damage", statArray["lightmaxdam"].statValue)
                }
            ;case "magicmindam": := Format("Adds {1}-{2} Magic Damage", statArray["magicmindam"].statValue)
            case "coldmindam": 
                if (statArray["coldmindam"].statValue and statArray["coldmaxdam"].statValue) {
                    statList[statArray["coldmindam"].statOrder]:= Format("Adds {1}-{2} Cold Damage", statArray["coldmindam"].statValue, statArray["coldmaxdam"].statValue)
                } else {
                    statList[statArray["coldmindam"].statOrder]:= Format("+{1} to Minimum Cold Damage", statArray["coldmindam"].statValue)
                }
            case "coldmaxdam": 
                if not (statArray["coldmindam"].statValue and statArray["coldmaxdam"].statValue) {
                    statList[statArray["coldmaxdam"].statOrder]:= Format("+{1} to Maximum Cold Damage", statArray["coldmaxdam"].statValue)
                }
            case "poisonmindam": 
                if (statArray["poisonmindam"].statValue and statArray["poisonmaxdam"].statValue) {
                    ; this is an ugly hack which should bring shame to me and my family
                    mindmg := Floor(statArray["poisonmindam"].statValue / (10.2 /  statArray["poisonlength"].statValue)) 
                    maxdmg := Floor(statArray["poisonmindam"].statValue / (10.2 /  statArray["poisonlength"].statValue))
                    if (statArray["poisonmindam"].statValue == statArray["poisonmaxdam"].statValue) {
                        statList[statArray["poisonmindam"].statOrder]:= Format("+{1} Poison Damage Over {2} Seconds",mindmg, statArray["poisonlength"].statValue)
                    } else {
                        statList[statArray["poisonmindam"].statOrder]:= Format("Adds {1}-{2} Poison Damage Over {3} Seconds", mindmg, maxdmg, Abs(statArray["poisonlength"].statValue / 3))
                    }
                } else {
                    statList[statArray["poisonmindam"].statOrder]:= Format("+{1} to Minimum Poison Damage", statArray["poisonmindam"].statValue)
                }
            case "poisonmaxdam": 
                if not (statArray["poisonmindam"].statValue and statArray["poisonmaxdam"].statValue) {
                    statList[statArray["poisonmaxdam"].statOrder]:= Format("+{1} to Maximum Poison Damage", statArray["poisonmaxdam"].statValue)
                }
            case "lifedrainmindam": statList[statArray["lifedrainmindam"].statOrder]:= Format("{1}% Life stolen per hit", statArray["lifedrainmindam"].statValue)
            case "manadrainmindam": statList[statArray["manadrainmindam"].statOrder]:= Format("{1}% Mana stolen per hit", statArray["manadrainmindam"].statValue)
            ; case "maxdurability": statList[statArray["poisonmaxdam"].statOrder]:= Format("Durability: {1} of {1}", statArray["durability"].statValue, statArray["maxdurability"].statValue)
            case "hpregen": statList[statArray["hpregen"].statOrder]:= Format("Replenish Life +{1}", statArray["hpregen"].statValue)
            case "item_maxdurability_percent": statList[statArray["item_maxdurability_percent"].statOrder]:= Format("Increase Maximum Durability {1}%", statArray["item_maxdurability_percent"].statValue)
            case "item_maxhp_percent": statList[statArray["item_maxhp_percent"].statOrder]:= Format("Increase Maximum Life {1}%", statArray["item_maxhp_percent"].statValue)
            case "item_maxmana_percent": statList[statArray["item_maxmana_percent"].statOrder]:= Format("Increase Maximum Mana {1}%", statArray["item_maxmana_percent"].statValue)
            case "item_attackertakesdamage": statList[statArray["item_attackertakesdamage"].statOrder]:= Format("Attacker Takes Damage of {1}", statArray["item_attackertakesdamage"].statValue)
            case "item_goldbonus": statList[statArray["item_goldbonus"].statOrder]:= Format("{1}% Extra Gold from Monsters", statArray["item_goldbonus"].statValue)
            case "item_magicbonus": statList[statArray["item_magicbonus"].statOrder]:= Format("{1}% Better Chance of Getting Magic Items", statArray["item_magicbonus"].statValue)
            case "item_knockback": statList[statArray["item_knockback"].statOrder]:= "Knockback"
            case "item_addclassskills": ; + to class skils
                switch (statArray["item_addclassskills"].statLayer) {
                    case 0: statList[statArray["item_addclassskills"].statOrder]:= Format("+{1} to Amazon Skill Levels", statArray["item_addclassskills"].statValue)
                    case 1: statList[statArray["item_addclassskills"].statOrder]:= Format("+{1} to Sorceress Skill Levels", statArray["item_addclassskills"].statValue)
                    case 2: statList[statArray["item_addclassskills"].statOrder]:= Format("+{1} to Necromancer Skill Levels", statArray["item_addclassskills"].statValue)
                    case 3: statList[statArray["item_addclassskills"].statOrder]:= Format("+{1} to Paladin Skill Levels", statArray["item_addclassskills"].statValue)
                    case 4: statList[statArray["item_addclassskills"].statOrder]:= Format("+{1} to Barbarian Skill Levels", statArray["item_addclassskills"].statValue)
                    case 5: statList[statArray["item_addclassskills"].statOrder]:= Format("+{1} to Druid Skill Levels", statArray["item_addclassskills"].statValue)
                    case 6: statList[statArray["item_addclassskills"].statOrder]:= Format("+{1} to Assassin Skill Levels", statArray["item_addclassskills"].statValue)
                }
            case "item_addexperience": statList[statArray["item_addexperience"].statOrder]:= Format("+{1}% to Experience Gained", statArray["item_addexperience"].statValue)
            case "item_healafterkill": statList[statArray["item_healafterkill"].statOrder]:= Format("+{1} Life after each Kill", statArray["item_healafterkill"].statValue)
            case "item_reducedprices": statList[statArray["item_reducedprices"].statOrder]:= Format("Reduces all Vendor Prices {1}%", statArray["item_reducedprices"].statValue)
            case "item_lightradius": statList[statArray["item_lightradius"].statOrder]:= statArray["item_lightradius"].statValue > 0 ? Format("+{1} to Light Radius", statArray["item_lightradius"].statValue) : Format("{1} to Light Radius", statArray["item_lightradius"].statValue)
            case "item_req_percent": statList[statArray["item_req_percent"].statOrder]:= Format("Requirements {1}%", statArray["item_req_percent"].statValue)
            case "item_levelreq": statList[statArray["item_levelreq"].statOrder]:= Format("Required Level: {1}", statArray["item_levelreq"].statValue)
            case "item_fasterattackrate": statList[statArray["item_fasterattackrate"].statOrder]:= Format("+{1}% Increased Attack Speed", statArray["item_fasterattackrate"].statValue)
            case "item_fastermovevelocity": statList[statArray["item_fastermovevelocity"].statOrder]:= Format("+{1}% Faster Run/Walk", statArray["item_fastermovevelocity"].statValue)
            case "item_nonclassskill1": 
                statList[statArray["item_nonclassskill1"].statOrder]:= Format("+{1} to {2}", statArray["item_nonclassskill1"].statValue, getSkillName(statArray["item_nonclassskill1"].statLayer))
            case "item_nonclassskill2": 
                statList[statArray["item_nonclassskill2"].statOrder]:= Format("+{1} to {2}", statArray["item_nonclassskill2"].statValue, getSkillName(statArray["item_nonclassskill2"].statLayer))
            case "item_nonclassskill3": 
                statList[statArray["item_nonclassskill3"].statOrder]:= Format("+{1} to {2}", statArray["item_nonclassskill3"].statValue, getSkillName(statArray["item_nonclassskill3"].statLayer))
            case "item_nonclassskill4": 
                statList[statArray["item_nonclassskill4"].statOrder]:= Format("+{1} to {2}", statArray["item_nonclassskill4"].statValue, getSkillName(statArray["item_nonclassskill4"].statLayer))
            case "item_nonclassskill5": 
                statList[statArray["item_nonclassskill5"].statOrder]:= Format("+{1} to {2}", statArray["item_nonclassskill5"].statValue, getSkillName(statArray["item_nonclassskill5"].statLayer))
            case "item_fastergethitrate": statList[statArray["item_fastergethitrate"].statOrder]:= Format("+{1}% Faster Hit Recovery", statArray["item_fastergethitrate"].statValue)
            case "item_fasterblockrate": statList[statArray["item_fasterblockrate"].statOrder]:= Format("+{1}% Faster Block Rate", statArray["item_fasterblockrate"].statValue)
            case "item_fastercastrate": statList[statArray["item_fastercastrate"].statOrder]:= Format("+{1}% Faster Cast Rate", statArray["item_fastercastrate"].statValue)
            case "item_singleskill1": 
                statList[statArray["item_singleskill1"].statOrder]:= Format("+{1} to {2} ({3} only)", statArray["item_singleskill1"].statValue, getSkillName(statArray["item_singleskill1"].statLayer), getSkillClass(statArray["item_singleskill1"].statLayer))
            case "item_singleskill2": 
                statList[statArray["item_singleskill2"].statOrder]:= Format("+{1} to {2} ({3} only)", statArray["item_singleskill2"].statValue, getSkillName(statArray["item_singleskill2"].statLayer), getSkillClass(statArray["item_singleskill2"].statLayer))
            case "item_singleskill3": 
                statList[statArray["item_singleskill3"].statOrder]:= Format("+{1} to {2} ({3} only)", statArray["item_singleskill3"].statValue, getSkillName(statArray["item_singleskill3"].statLayer), getSkillClass(statArray["item_singleskill3"].statLayer))
            case "item_singleskill4": 
                statList[statArray["item_singleskill4"].statOrder]:= Format("+{1} to {2} ({3} only)", statArray["item_singleskill4"].statValue, getSkillName(statArray["item_singleskill4"].statLayer), getSkillClass(statArray["item_singleskill4"].statLayer))
            case "item_singleskill5": 
                statList[statArray["item_singleskill5"].statOrder]:= Format("+{1} to {2} ({3} only)", statArray["item_singleskill5"].statValue, getSkillName(statArray["item_singleskill5"].statLayer), getSkillClass(statArray["item_singleskill5"].statLayer))
            case "item_restinpeace": statList[statArray["item_restinpeace"].statOrder]:= "Slain Monsters Rest in Peace"
            case "item_poisonlengthresist": statList[statArray["item_poisonlengthresist"].statOrder]:= Format("Poison Length Reduced by {1}%", statArray["item_poisonlengthresist"].statValue)
            case "item_normaldamage": statList[statArray["item_normaldamage"].statOrder]:= Format("Damage +{1}", statArray["item_normaldamage"].statValue)
            case "item_howl": statList[statArray["item_howl"].statOrder]:= Format("Hit Causes Monster to Flee {1}%", Round(statArray["item_howl"].statValue) / 1.28)
            case "item_stupidity": statList[statArray["item_stupidity"].statOrder]:= Format("Hit Blinds Target +{1}", statArray["item_stupidity"].statValue)
            case "item_damagetomana": statList[statArray["item_damagetomana"].statOrder]:= Format("{1}% Damage Taken Goes To Mana", statArray["item_damagetomana"].statValue)
            case "item_ignoretargetac": statList[statArray["item_ignoretargetac"].statOrder]:= Format("Ignore Target's Defense", statArray["item_ignoretargetac"].statValue)
            case "item_fractionaltargetac": statList[statArray["item_fractionaltargetac"].statOrder]:= Format("-{1}% Target Defense", statArray["item_fractionaltargetac"].statValue)
            case "item_preventheal": statList[statArray["item_preventheal"].statOrder]:= Format("Prevent Monster Heal", statArray["item_preventheal"].statValue)
            case "item_halffreezeduration": statList[statArray["item_halffreezeduration"].statOrder]:= Format("Half Freeze Duration", statArray["item_halffreezeduration"].statValue)
            case "item_tohit_percent": statList[statArray["item_tohit_percent"].statOrder]:= Format("{1}% Bonus to Attack Rating", statArray["item_tohit_percent"].statValue)
            case "item_damagetargetac": statList[statArray["item_damagetargetac"].statOrder]:= Format("-{1} to Monster Defense Per Hit", statArray["item_damagetargetac"].statValue)
            case "item_demondamage_percent": statList[statArray["item_demondamage_percent"].statOrder]:= Format("+{1}% Damage to Demons", statArray["item_demondamage_percent"].statValue)
            case "item_undeaddamage_percent": statList[statArray["item_undeaddamage_percent"].statOrder]:= Format("+{1}% Damage to Undead", statArray["item_undeaddamage_percent"].statValue)
            case "item_demon_tohit": statList[statArray["item_demon_tohit"].statOrder]:= Format("+{1} to Attack Rating against Demons", statArray["item_demon_tohit"].statValue)
            case "item_undead_tohit": statList[statArray["item_undead_tohit"].statOrder]:= Format("+{1} to Attack Rating against Undead", statArray["item_undead_tohit"].statValue)
            case "item_elemskill": statList[statArray["item_elemskill"].statOrder]:= Format("+{1} to Fire Skills", statArray["item_elemskill"].statValue)
            case "item_allskills": statList[statArray["item_allskills"].statOrder]:= Format("+{1} to All Skills", statArray["item_allskills"].statValue)
            case "item_attackertakeslightdamage": statList[statArray["item_attackertakeslightdamage"].statOrder]:= Format("Attacker Takes Lightning Damage of {1}", statArray["item_attackertakeslightdamage"].statValue)
            case "item_freeze": statList[statArray["item_freeze"].statOrder]:= Format("Freezes Target +{1}", statArray["item_freeze"].statValue)
            case "item_openwounds": statList[statArray["item_openwounds"].statOrder]:= Format("{1}% Chance of Open Wounds", statArray["item_openwounds"].statValue)
            case "item_crushingblow": statList[statArray["item_crushingblow"].statOrder]:= Format("{1}% Chance of Crushing Blow", statArray["item_crushingblow"].statValue)
            case "item_kickdamage": statList[statArray["item_kickdamage"].statOrder]:= Format("+{1} Kick Damage", statArray["item_kickdamage"].statValue)
            case "item_manaafterkill": statList[statArray["item_manaafterkill"].statOrder]:= Format("+{1} to Mana after each Kill", statArray["item_manaafterkill"].statValue)
            case "item_healafterdemonkill": statList[statArray["item_healafterdemonkill"].statOrder]:= Format("+{1} Life after each Demon Kill", statArray["item_healafterdemonkill"].statValue)
            case "item_deadlystrike": statList[statArray["item_deadlystrike"].statOrder]:= Format("{1}% Deadly Strike", statArray["item_deadlystrike"].statValue)
            case "item_absorbfire_percent": statList[statArray["item_absorbfire_percent"].statOrder]:= Format("+{1} Fire Absorb", statArray["item_absorbfire_percent"].statValue)
            case "item_absorbfire": statList[statArray["item_absorbfire"].statOrder]:= Format("Fire Absorb {1}%", statArray["item_absorbfire"].statValue)
            case "item_absorblight_percent": statList[statArray["item_absorblight_percent"].statOrder]:= Format("+{1} Lightning Absorb", statArray["item_absorblight_percent"].statValue)
            case "item_absorblight": statList[statArray["item_absorblight"].statOrder]:= Format("Lightning Absorb {1}%", statArray["item_absorblight"].statValue)
            case "item_absorbmagic_percent": statList[statArray["item_absorbmagic_percent"].statOrder]:= Format("+{1} Magic Absorb", statArray["item_absorbmagic_percent"].statValue)
            case "item_absorbmagic": statList[statArray["item_absorbmagic"].statOrder]:= Format("Magic Absorb {1}%", statArray["item_absorbmagic"].statValue)
            case "item_absorbcold_percent": statList[statArray["item_absorbcold_percent"].statOrder]:= Format("+{1} Cold Absorb", statArray["item_absorbcold_percent"].statValue)
            case "item_absorbcold": statList[statArray["item_absorbcold"].statOrder]:= Format("Cold Absorb {1}%", statArray["item_absorbcold"].statValue)
            case "item_slow": statList[statArray["item_slow"].statOrder]:= Format("Slows Target by {1}%", statArray["item_slow"].statValue)
            case "item_aura": statList[statArray["item_aura"].statOrder]:= Format("Level {1} {2} Aura When Equipped", statArray["item_aura"].statValue, getSkillName(statArray["item_aura"].statLayer))
            case "item_cannotbefrozen": statList[statArray["item_cannotbefrozen"].statOrder]:= Format("Cannot Be Frozen")
            case "item_staminadrainpct": statList[statArray["item_staminadrainpct"].statOrder]:= Format("{1}% Slower Stamina Drain", statArray["item_staminadrainpct"].statValue)
            ;case "item_reanimate": := Format("Reanimate As: [Returned].statValue", statArray["item_reanimate"].statValue)
            case "item_pierce": statList[statArray["item_pierce"].statOrder]:= Format("Piercing Attack")
            case "item_magicarrow": statList[statArray["item_magicarrow"].statOrder]:= Format("Fires Magic Arrows")
            case "item_explosivearrow": statList[statArray["item_explosivearrow"].statOrder]:= Format("Fires Explosive Arrows or Bolts")
            case "item_addskill_tab": statList[statArray["item_addskill_tab"].statOrder]:= Format("+{1} to {2} Skills", statArray["item_addskill_tab"].statValue, getSkillTree(statArray["item_addskill_tab"].statLayer))
            case "item_numsockets": statList[statArray["item_numsockets"].statOrder]:= Format("Socketed ({1})", statArray["item_numsockets"].statValue)
            case "item_skillonattack":
                skillId := statArray["item_skillonattack"].statLayer >> 6
                level := Mod(statArray["item_skillonattack"].statLayer, (1 << 6))
                maxCharges := statArray["item_skillonattack"].statValue >> 8
                charges := Mod(statArray["item_skillonattack"].statValue, (1 << 8))
                statList[statArray["item_skillonattack"].statOrder]:= Format("{1}% Chance to cast level {2} {3} on attack", statArray["item_skillonattack"].statValue, level, getSkillName(skillId))
            case "item_skillonkill":
                skillId := statArray["item_skillonkill"].statLayer >> 6
                level := Mod(statArray["item_skillonkill"].statLayer, (1 << 6))
                maxCharges := statArray["item_skillonkill"].statValue >> 8
                charges := Mod(statArray["item_skillonkill"].statValue, (1 << 8))
                statList[statArray["item_skillonkill"].statOrder]:= Format("{1}% Chance to cast level {2} {3} when you Kill an Enemy", statArray["item_skillonkill"].statValue, level, getSkillName(skillId))
            case "item_skillondeath":
                skillId := statArray["item_skillondeath"].statLayer >> 6
                level := Mod(statArray["item_skillondeath"].statLayer, (1 << 6))
                maxCharges := statArray["item_skillondeath"].statValue >> 8
                charges := Mod(statArray["item_skillondeath"].statValue, (1 << 8))
                statList[statArray["item_skillondeath"].statOrder]:= Format("{1}% Chance to cast level {2} {3} when you Die", statArray["item_skillondeath"].statValue, level, getSkillName(skillId))
            case "item_skillonhit": 
                skillId := statArray["item_skillonhit"].statLayer >> 6
                level := Mod(statArray["item_skillonhit"].statLayer, (1 << 6))
                maxCharges := statArray["item_skillonhit"].statValue >> 8
                charges := Mod(statArray["item_skillonhit"].statValue, (1 << 8))
                statList[statArray["item_skillonhit"].statOrder]:= Format("{1}% Chance to cast level {2} {3} on striking", statArray["item_skillonhit"].statValue, level, getSkillName(skillId))
            case "item_skillonlevelup": 
                skillId := statArray["item_skillonlevelup"].statLayer >> 6
                level := Mod(statArray["item_skillonlevelup"].statLayer, (1 << 6))
                maxCharges := statArray["item_skillonlevelup"].statValue >> 8
                charges := Mod(statArray["item_skillonlevelup"].statValue, (1 << 8))
                statList[statArray["item_skillonlevelup"].statOrder]:= Format("{1}% Chance to cast level {2} {3} when you Level-Up", statArray["item_skillonlevelup"].statValue, level, getSkillName(skillId))
            case "item_skillongethit":
                skillId := statArray["item_skillongethit"].statLayer >> 6
                level := Mod(statArray["item_skillongethit"].statLayer, (1 << 6))
                maxCharges := statArray["item_skillongethit"].statValue >> 8
                charges := Mod(statArray["item_skillongethit"].statValue, (1 << 8))
                statList[statArray["item_skillongethit"].statOrder]:= Format("{1}% Chance to cast level {2} {3} when struck", statArray["item_skillongethit"].statValue, level, getSkillName(skillId))
            case "item_charged_skill": 
                skillId := statArray["item_charged_skill"].statLayer >> 6
                level := Mod(statArray["item_charged_skill"].statLayer, (1 << 6))
                maxCharges := statArray["item_charged_skill"].statValue >> 8
                charges := Mod(statArray["item_charged_skill"].statValue, (1 << 8))
                statList[statArray["item_charged_skill"].statOrder]:= Format("Level {1} {2} ({3}/{4} Charges)", level, getSkillName(skillId), charges, maxCharges)
            case "item_armor_perlevel": statList[statArray["item_armor_perlevel"].statOrder]:= Format("+{1} Defense (Based on Character Level)", Round((statArray["item_armor_perlevel"].statValue / 8) * playerLevel))
            case "item_armorpercent_perlevel": statList[statArray["item_armorpercent_perlevel"].statOrder]:= Format("+{1}% Enhanced Defense (Based on Character Level)", Round((statArray["item_armorpercent_perlevel"].statValue / 8) * playerLevel))
            case "item_hp_perlevel": statList[statArray["item_hp_perlevel"].statOrder]:= Format("+{1} to Life (Based on Character Level)", Round((statArray["item_hp_perlevel"].statValue / 8) * playerLevel))
            case "item_mana_perlevel": statList[statArray["item_mana_perlevel"].statOrder]:= Format("+{1} to Mana (Based on Character Level)", Round((statArray["item_mana_perlevel"].statValue / 8) * playerLevel))
            case "item_maxdamage_perlevel": statList[statArray["item_maxdamage_perlevel"].statOrder]:= Format("+{1} to Maximum Damage (Based on Character Level)", Round((statArray["item_maxdamage_perlevel"].statValue / 8) * playerLevel))
            case "item_maxdamage_percent_perlevel": statList[statArray["item_maxdamage_percent_perlevel"].statOrder]:= Format("+{1}% Enhanced Maximum Damage (Based on Character Level)", Round((statArray["item_maxdamage_percent_perlevel"].statValue / 8) * playerLevel))
            case "maxdamage": 
            if not (statArray["mindamage"].statValue and statArray["maxdamage"].statValue) {
                statList[statArray["maxdamage"].statOrder]:= Format("+{1} to Maximum Damage", statArray["maxdamage"].statValue)
            }
            case "item_strength_perlevel": statList[statArray["item_strength_perlevel"].statOrder]:= Format("+{1} to Strength (Based on Character Level)", Round((statArray["item_strength_perlevel"].statValue / 8) * playerLevel))
            case "item_dexterity_perlevel": statList[statArray["item_dexterity_perlevel"].statOrder]:= Format("+{1} to Dexterity (Based on Character Level)", Round((statArray["item_dexterity_perlevel"].statValue / 8) * playerLevel))
            case "item_vitality_perlevel": statList[statArray["item_vitality_perlevel"].statOrder]:= Format("+{1} to Vitality (Based on Character Level)", Round((statArray["item_vitality_perlevel"].statValue / 8) * playerLevel))
            case "item_tohit_perlevel": statList[statArray["item_tohit_perlevel"].statOrder]:= Format("+{1} to Attack Rating (Based on Character Level)", Round((statArray["item_tohit_perlevel"].statValue / 8) * playerLevel))
            case "item_tohitpercent_perlevel": statList[statArray["item_tohitpercent_perlevel"].statOrder]:= Format("{1}% Bonus to Attack Rating (Based on Character Level)", Round((statArray["item_tohitpercent_perlevel"].statValue / 8) * playerLevel))
            case "item_resist_cold_perlevel": statList[statArray["item_resist_cold_perlevel"].statOrder]:= Format("Cold Resist +{1}% (Based on Character Level)", Round((statArray["item_resist_cold_perlevel"].statValue / 8) * playerLevel))
            case "item_resist_fire_perlevel": statList[statArray["item_resist_fire_perlevel"].statOrder]:= Format("Fire Resist +{1}% (Based on Character Level)", Round((statArray["item_resist_fire_perlevel"].statValue / 8) * playerLevel))
            case "item_resist_ltng_perlevel": statList[statArray["item_resist_ltng_perlevel"].statOrder]:= Format("Lightning Resist +{1}% (Based on Character Level)", Round((statArray["item_resist_ltng_perlevel"].statValue / 8) * playerLevel))
            case "item_resist_pois_perlevel": statList[statArray["item_resist_pois_perlevel"].statOrder]:= Format("Poison Resist +{1}% (Based on Character Level)", Round((statArray["item_resist_pois_perlevel"].statValue / 8) * playerLevel))
            case "item_absorb_cold_perlevel": statList[statArray["item_absorb_cold_perlevel"].statOrder]:= Format("Absorbs Cold Damage (Based on Character Level)", Round((statArray["item_absorb_cold_perlevel"].statValue / 8) * playerLevel))
            case "item_absorb_fire_perlevel": statList[statArray["item_absorb_fire_perlevel"].statOrder]:= Format("Absorbs Fire Damage (Based on Character Level)", Round((statArray["item_absorb_fire_perlevel"].statValue / 8) * playerLevel))
            case "item_thorns_perlevel": statList[statArray["item_thorns_perlevel"].statOrder]:= Format("Attacker Takes Damage of {1} (Based on Character Level)", Round((statArray["item_thorns_perlevel"].statValue / 8) * playerLevel))
            case "item_find_gold_perlevel": statList[statArray["item_find_gold_perlevel"].statOrder]:= Format("{1}% Extra Gold from Monsters (Based on Character Level)", Round((statArray["item_find_gold_perlevel"].statValue / 8) * playerLevel))
            case "item_find_magic_perlevel": statList[statArray["item_find_magic_perlevel"].statOrder]:= Format("{1}% Better Chance of Getting Magic Items (Based on Character Level)", Round((statArray["item_find_magic_perlevel"].statValue / 8) * playerLevel))
            case "item_regenstamina_perlevel": statList[statArray["item_regenstamina_perlevel"].statOrder]:= Format("Heal Stamina Plus {1}% (Based on Character Level)", Round((statArray["item_regenstamina_perlevel"].statValue / 8) * playerLevel))
            case "item_stamina_perlevel": statList[statArray["item_stamina_perlevel"].statOrder]:= Format("+{1} Maximum Stamina (Based on Character Level)", Round((statArray["item_stamina_perlevel"].statValue / 8) * playerLevel))
            case "item_damage_demon_perlevel": statList[statArray["item_damage_demon_perlevel"].statOrder]:= Format("+{1}% Damage to Demons (Based on Character Level)", Round((statArray["item_damage_demon_perlevel"].statValue / 8) * playerLevel))
            case "item_damage_undead_perlevel": statList[statArray["item_damage_undead_perlevel"].statOrder]:= Format("+{1}% Damage to Undead (Based on Character Level)", Round((statArray["item_damage_undead_perlevel"].statValue / 8) * playerLevel))
            case "item_tohit_demon_perlevel": statList[statArray["item_tohit_demon_perlevel"].statOrder]:= Format("+{1} to Attack Rating against Demons (Based on Character Level)", Round((statArray["item_tohit_demon_perlevel"].statValue / 8) * playerLevel))
            case "item_tohit_undead_perlevel": statList[statArray["item_tohit_undead_perlevel"].statOrder]:= Format("+{1} to Attack Rating against Undead (Based on Character Level)", Round((statArray["item_tohit_undead_perlevel"].statValue / 2) * playerLevel))
            case "item_deadlystrike_perlevel": statList[statArray["item_deadlystrike_perlevel"].statOrder]:= Format("{1}% Deadly Strike (Based on Character Level)", Round(statArray["item_deadlystrike_perlevel"].statValue) / 0.8)
            case "item_replenish_durability": statList[statArray["item_replenish_durability"].statOrder]:= Format("Repairs 1 durability in {1} seconds", Round(100 / statArray["item_replenish_durability"].statValue))
            case "item_replenish_quantity": statList[statArray["item_replenish_quantity"].statOrder]:= Format("Replenishes quantity", statArray["item_replenish_quantity"].statValue)
            case "item_extra_stack": statList[statArray["item_extra_stack"].statOrder]:= "Increased Stack Size"
            case "passive_fire_mastery": statList[statArray["passive_fire_mastery"].statOrder]:= Format("+{1}% to Fire Skill Damage", statArray["passive_fire_mastery"].statValue)
            case "passive_ltng_mastery": statList[statArray["passive_ltng_mastery"].statOrder]:= Format("+{1}% to Lightning Skill Damage", statArray["passive_ltng_mastery"].statValue)
            case "passive_cold_mastery": statList[statArray["passive_cold_mastery"].statOrder]:= Format("+{1}% to Cold Skill Damage", statArray["passive_cold_mastery"].statValue)
            case "passive_pois_mastery": statList[statArray["passive_pois_mastery"].statOrder]:= Format("+{1}% to Poison Skill Damage", statArray["passive_pois_mastery"].statValue)
            case "passive_fire_pierce": statList[statArray["passive_fire_pierce"].statOrder]:= Format("-{1}% to Enemy Fire Resistance", statArray["passive_fire_pierce"].statValue)
            case "passive_ltng_pierce": statList[statArray["passive_ltng_pierce"].statOrder]:= Format("-{1}% to Enemy Lightning Resistance", statArray["passive_ltng_pierce"].statValue)
            case "passive_cold_pierce": statList[statArray["passive_cold_pierce"].statOrder]:= Format("-{1}% to Enemy Cold Resistance", statArray["passive_cold_pierce"].statValue)
            case "passive_pois_pierce": statList[statArray["passive_pois_pierce"].statOrder]:= Format("-{1}% to Enemy Poison Resistance", statArray["passive_pois_pierce"].statValue)

        }
    }
    return statList
}

getStatName(statEnum) {
    switch (statEnum) {
        case 0: return "strength"
        case 1: return "energy"
        case 2: return "dexterity"
        case 3: return "vitality"
        case 4: return "statpts"
        case 5: return "newskills"
        case 6: return "hitpoints"
        case 7: return "maxhp"
        case 8: return "mana"
        case 9: return "maxmana"
        case 10: return "stamina"
        case 11: return "maxstamina"
        case 12: return "level"
        case 13: return "experience"
        case 14: return "gold"
        case 15: return "goldbank"
        case 16: return "item_armor_percent"
        case 17: return "item_maxdamage_percent"
        case 18: return "item_mindamage_percent"
        case 19: return "tohit"
        case 20: return "toblock"
        case 21: return "mindamage"
        case 22: return "maxdamage"
        case 23: return "secondary_mindamage"
        case 24: return "secondary_maxdamage"
        case 25: return "damagepercent"
        case 26: return "manarecovery"
        case 27: return "manarecoverybonus"
        case 28: return "staminarecoverybonus"
        case 29: return "lastexp"
        case 30: return "nextexp"
        case 31: return "armorclass"
        case 32: return "armorclass_vs_missile"
        case 33: return "armorclass_vs_hth"
        case 34: return "normal_damage_reduction"
        case 35: return "magic_damage_reduction"
        case 36: return "damageresist"
        case 37: return "magicresist"
        case 38: return "maxmagicresist"
        case 39: return "fireresist"
        case 40: return "maxfireresist"
        case 41: return "lightresist"
        case 42: return "maxlightresist"
        case 43: return "coldresist"
        case 44: return "maxcoldresist"
        case 45: return "poisonresist"
        case 46: return "maxpoisonresist"
        case 47: return "damageaura"
        case 48: return "firemindam"
        case 49: return "firemaxdam"
        case 50: return "lightmindam"
        case 51: return "lightmaxdam"
        case 52: return "magicmindam"
        case 53: return "magicmaxdam"
        case 54: return "coldmindam"
        case 55: return "coldmaxdam"
        case 56: return "coldlength"
        case 57: return "poisonmindam"
        case 58: return "poisonmaxdam"
        case 59: return "poisonlength"
        case 60: return "lifedrainmindam"
        case 61: return "lifedrainmaxdam"
        case 62: return "manadrainmindam"
        case 63: return "manadrainmaxdam"
        case 64: return "stamdrainmindam"
        case 65: return "stamdrainmaxdam"
        case 66: return "stunlength"
        case 67: return "velocitypercent"
        case 68: return "attackrate"
        case 69: return "other_animrate"
        case 70: return "quantity"
        case 71: return "value"
        case 72: return "durability"
        case 73: return "maxdurability"
        case 74: return "hpregen"
        case 75: return "item_maxdurability_percent"
        case 76: return "item_maxhp_percent"
        case 77: return "item_maxmana_percent"
        case 78: return "item_attackertakesdamage"
        case 79: return "item_goldbonus"
        case 80: return "item_magicbonus"
        case 81: return "item_knockback"
        case 82: return "item_timeduration"
        case 83: return "item_addclassskills"
        case 84: return "unsentparam1"
        case 85: return "item_addexperience"
        case 86: return "item_healafterkill"
        case 87: return "item_reducedprices"
        case 88: return "item_doubleherbduration"
        case 89: return "item_lightradius"
        case 90: return "item_lightcolor"
        case 91: return "item_req_percent"
        case 92: return "item_levelreq"
        case 93: return "item_fasterattackrate"
        case 94: return "item_levelreqpct"
        case 95: return "lastblockframe"
        case 96: return "item_fastermovevelocity"
        case 97: return "item_nonclassskill"
        case 98: return "state"
        case 99: return "item_fastergethitrate"
        case 100: return "monster_playercount"
        case 101: return "skill_poison_override_length"
        case 102: return "item_fasterblockrate"
        case 103: return "skill_bypass_undead"
        case 104: return "skill_bypass_demons"
        case 105: return "item_fastercastrate"
        case 106: return "skill_bypass_beasts"
        case 107: return "item_singleskill"
        case 108: return "item_restinpeace"
        case 109: return "curse_resistance"
        case 110: return "item_poisonlengthresist"
        case 111: return "item_normaldamage"
        case 112: return "item_howl"
        case 113: return "item_stupidity"
        case 114: return "item_damagetomana"
        case 115: return "item_ignoretargetac"
        case 116: return "item_fractionaltargetac"
        case 117: return "item_preventheal"
        case 118: return "item_halffreezeduration"
        case 119: return "item_tohit_percent"
        case 120: return "item_damagetargetac"
        case 121: return "item_demondamage_percent"
        case 122: return "item_undeaddamage_percent"
        case 123: return "item_demon_tohit"
        case 124: return "item_undead_tohit"
        case 125: return "item_throwable"
        case 126: return "item_elemskill"
        case 127: return "item_allskills"
        case 128: return "item_attackertakeslightdamage"
        case 129: return "ironmaiden_level"
        case 130: return "lifetap_level"
        case 131: return "thorns_percent"
        case 132: return "bonearmor"
        case 133: return "bonearmormax"
        case 134: return "item_freeze"
        case 135: return "item_openwounds"
        case 136: return "item_crushingblow"
        case 137: return "item_kickdamage"
        case 138: return "item_manaafterkill"
        case 139: return "item_healafterdemonkill"
        case 140: return "item_extrablood"
        case 141: return "item_deadlystrike"
        case 142: return "item_absorbfire_percent"
        case 143: return "item_absorbfire"
        case 144: return "item_absorblight_percent"
        case 145: return "item_absorblight"
        case 146: return "item_absorbmagic_percent"
        case 147: return "item_absorbmagic"
        case 148: return "item_absorbcold_percent"
        case 149: return "item_absorbcold"
        case 150: return "item_slow"
        case 151: return "item_aura"
        case 152: return "item_indesctructible"
        case 153: return "item_cannotbefrozen"
        case 154: return "item_staminadrainpct"
        case 155: return "item_reanimate"
        case 156: return "item_pierce"
        case 157: return "item_magicarrow"
        case 158: return "item_explosivearrow"
        case 159: return "item_throw_mindamage"
        case 160: return "item_throw_maxdamage"
        case 161: return "skill_handofathena"
        case 162: return "skill_staminapercent"
        case 163: return "skill_passive_staminapercent"
        case 164: return "skill_concentration"
        case 165: return "skill_enchant"
        case 166: return "skill_pierce"
        case 167: return "skill_conviction"
        case 168: return "skill_chillingarmor"
        case 169: return "skill_frenzy"
        case 170: return "skill_decrepify"
        case 171: return "skill_armor_percent"
        case 172: return "alignment"
        case 173: return "target0"
        case 174: return "target1"
        case 175: return "goldlost"
        case 176: return "conversion_level"
        case 177: return "conversion_maxhp"
        case 178: return "unit_dooverlay"
        case 179: return "attack_vs_montype"
        case 180: return "damage_vs_montype"
        case 181: return "fade"
        case 182: return "armor_override_percent"
        case 183: return "unused183"
        case 184: return "unused184"
        case 185: return "unused185"
        case 186: return "unused186"
        case 187: return "unused187"
        case 188: return "item_addskill_tab"
        case 189: return "unused189"
        case 190: return "unused190"
        case 191: return "unused191"
        case 192: return "unused192"
        case 193: return "unused193"
        case 194: return "item_numsockets"
        case 195: return "item_skillonattack"
        case 196: return "item_skillonkill"
        case 197: return "item_skillondeath"
        case 198: return "item_skillonhit"
        case 199: return "item_skillonlevelup"
        case 200: return "unused200"
        case 201: return "item_skillongethit"
        case 202: return "unused202"
        case 203: return "unused203"
        case 204: return "item_charged_skill"
        case 205: return "unused205"
        case 206: return "unused206"
        case 207: return "unused207"
        case 208: return "unused208"
        case 209: return "unused209"
        case 210: return "unused210"
        case 211: return "unused211"
        case 213: return "passive_mastery_gethit_rate"
        case 213: return "passive_mastery_attack_speed"
        case 214: return "item_armor_perlevel"
        case 215: return "item_armorpercent_perlevel"
        case 216: return "item_hp_perlevel"
        case 217: return "item_mana_perlevel"
        case 218: return "item_maxdamage_perlevel"
        case 219: return "item_maxdamage_percent_perlevel"
        case 220: return "item_strength_perlevel"
        case 221: return "item_dexterity_perlevel"
        case 222: return "item_energy_perlevel"
        case 223: return "item_vitality_perlevel"
        case 224: return "item_tohit_perlevel"
        case 225: return "item_tohitpercent_perlevel"
        case 226: return "item_cold_damagemax_perlevel"
        case 227: return "item_fire_damagemax_perlevel"
        case 228: return "item_ltng_damagemax_perlevel"
        case 229: return "item_pois_damagemax_perlevel"
        case 230: return "item_resist_cold_perlevel"
        case 231: return "item_resist_fire_perlevel"
        case 232: return "item_resist_ltng_perlevel"
        case 233: return "item_resist_pois_perlevel"
        case 234: return "item_absorb_cold_perlevel"
        case 235: return "item_absorb_fire_perlevel"
        case 236: return "item_absorb_ltng_perlevel"
        case 237: return "item_absorb_pois_perlevel"
        case 238: return "item_thorns_perlevel"
        case 239: return "item_find_gold_perlevel"
        case 240: return "item_find_magic_perlevel"
        case 241: return "item_regenstamina_perlevel"
        case 242: return "item_stamina_perlevel"
        case 243: return "item_damage_demon_perlevel"
        case 244: return "item_damage_undead_perlevel"
        case 245: return "item_tohit_demon_perlevel"
        case 246: return "item_tohit_undead_perlevel"
        case 247: return "item_crushingblow_perlevel"
        case 248: return "item_openwounds_perlevel"
        case 249: return "item_kick_damage_perlevel"
        case 250: return "item_deadlystrike_perlevel"
        case 251: return "item_find_gems_perlevel"
        case 252: return "item_replenish_durability"
        case 253: return "item_replenish_quantity"
        case 254: return "item_extra_stack"
        case 255: return "item_find_item"
        case 256: return "item_slash_damage"
        case 257: return "item_slash_damage_percent"
        case 258: return "item_crush_damage"
        case 259: return "item_crush_damage_percent"
        case 260: return "item_thrust_damage"
        case 261: return "item_thrust_damage_percent"
        case 262: return "item_absorb_slash"
        case 263: return "item_absorb_crush"
        case 264: return "item_absorb_thrust"
        case 265: return "item_absorb_slash_percent"
        case 266: return "item_absorb_crush_percent"
        case 267: return "item_absorb_thrust_percent"
        case 268: return "item_armor_bytime"
        case 269: return "item_armorpercent_bytime"
        case 270: return "item_hp_bytime"
        case 271: return "item_mana_bytime"
        case 272: return "item_maxdamage_bytime"
        case 273: return "item_maxdamage_percent_bytime"
        case 274: return "item_strength_bytime"
        case 275: return "item_dexterity_bytime"
        case 276: return "item_energy_bytime"
        case 277: return "item_vitality_bytime"
        case 278: return "item_tohit_bytime"
        case 279: return "item_tohitpercent_bytime"
        case 280: return "item_cold_damagemax_bytime"
        case 281: return "item_fire_damagemax_bytime"
        case 282: return "item_ltng_damagemax_bytime"
        case 283: return "item_pois_damagemax_bytime"
        case 284: return "item_resist_cold_bytime"
        case 285: return "item_resist_fire_bytime"
        case 286: return "item_resist_ltng_bytime"
        case 287: return "item_resist_pois_bytime"
        case 288: return "item_absorb_cold_bytime"
        case 289: return "item_absorb_fire_bytime"
        case 290: return "item_absorb_ltng_bytime"
        case 291: return "item_absorb_pois_bytime"
        case 292: return "item_find_gold_bytime"
        case 293: return "item_find_magic_bytime"
        case 294: return "item_regenstamina_bytime"
        case 295: return "item_stamina_bytime"
        case 296: return "item_damage_demon_bytime"
        case 297: return "item_damage_undead_bytime"
        case 298: return "item_tohit_demon_bytime"
        case 299: return "item_tohit_undead_bytime"
        case 300: return "item_crushingblow_bytime"
        case 301: return "item_openwounds_bytime"
        case 302: return "item_kick_damage_bytime"
        case 303: return "item_deadlystrike_bytime"
        case 304: return "item_find_gems_bytime"
        case 305: return "item_pierce_cold"
        case 306: return "item_pierce_fire"
        case 307: return "item_pierce_ltng"
        case 308: return "item_pierce_pois"
        case 309: return "item_damage_vs_monster"
        case 310: return "item_damage_percent_vs_monster"
        case 311: return "item_tohit_vs_monster"
        case 312: return "item_tohit_percent_vs_monster"
        case 313: return "item_ac_vs_monster"
        case 314: return "item_ac_percent_vs_monster"
        case 315: return "firelength"
        case 316: return "burningmin"
        case 317: return "burningmax"
        case 318: return "progressive_damage"
        case 319: return "progressive_steal"
        case 320: return "progressive_other"
        case 321: return "progressive_fire"
        case 322: return "progressive_cold"
        case 323: return "progressive_lightning"
        case 324: return "item_extra_charges"
        case 325: return "progressive_tohit"
        case 326: return "poison_count"
        case 327: return "damage_framerate"
        case 328: return "pierce_idx"
        case 329: return "passive_fire_mastery"
        case 330: return "passive_ltng_mastery"
        case 331: return "passive_cold_mastery"
        case 332: return "passive_pois_mastery"
        case 333: return "passive_fire_pierce"
        case 334: return "passive_ltng_pierce"
        case 335: return "passive_cold_pierce"
        case 336: return "passive_pois_pierce"
        case 337: return "passive_critical_strike"
        case 338: return "passive_dodge"
        case 339: return "passive_avoid"
        case 340: return "passive_evade"
        case 341: return "passive_warmth"
        case 342: return "passive_mastery_melee_th"
        case 343: return "passive_mastery_melee_dmg"
        case 344: return "passive_mastery_melee_crit"
        case 345: return "passive_mastery_throw_th"
        case 346: return "passive_mastery_throw_dmg"
        case 347: return "passive_mastery_throw_crit"
        case 348: return "passive_weaponblock"
        case 349: return "passive_summon_resist"
        case 350: return "modifierlist_skill"
        case 351: return "modifierlist_level"
        case 352: return "last_sent_hp_pct"
        case 353: return "source_unit_type"
        case 354: return "source_unit_id"
        case 355: return "shortparam1"
        case 356: return "questitemdifficulty"
        case 357: return "passive_mag_mastery"
        case 358: return "passive_mag_pierce"
        case 359: return "skill_cooldown"
        case 360: return "skill_missile_damage_scale"
    }
    return statEnum
}

getStatSortPriority(stat) {
    switch (stat) {
        case "item_armor_bytime": return 0
        case "item_armorpercent_bytime": return 1
        case "item_hp_bytime": return 2
        case "item_mana_bytime": return 3
        case "item_maxdamage_bytime": return 4
        case "item_maxdamage_percent_bytime": return 5
        case "item_strength_bytime": return 6
        case "item_dexterity_bytime": return 7
        case "item_energy_bytime": return 8
        case "item_vitality_bytime": return 9
        case "item_tohit_bytime": return 10
        case "item_tohitpercent_bytime": return 11
        case "item_cold_damagemax_bytime": return 12
        case "item_fire_damagemax_bytime": return 13
        case "item_ltng_damagemax_bytime": return 14
        case "item_pois_damagemax_bytime": return 15
        case "item_pois_damagemax_bytime": return 16
        case "item_resist_fire_bytime": return 17
        case "item_resist_ltng_bytime": return 18
        case "item_resist_pois_bytime": return 19
        case "item_absorb_cold_bytime": return 20
        case "item_absorb_fire_bytime": return 21
        case "item_absorb_ltng_bytime": return 22
        case "item_find_gold_bytime": return 23
        case "item_find_magic_bytime": return 24
        case "item_regenstamina_bytime": return 25
        case "item_stamina_bytime": return 26
        case "item_damage_demon_bytime": return 27
        case "item_damage_undead_bytime": return 28
        case "item_tohit_demon_bytime": return 29
        case "item_tohit_undead_bytime": return 30
        case "item_crushingblow_bytime": return 31
        case "item_openwounds_bytime": return 32
        case "item_kick_damage_bytime": return 33
        case "item_deadlystrike_bytime": return 34
        case "item_indesctructible": return 35
        case "item_skillonattack": return 36
        case "item_skillonkill": return 37
        case "item_skillondeath": return 38
        case "item_skillonhit": return 39
        case "item_skillonlevelup": return 40
        case "item_skillongethit": return 41
        case "item_aura": return 42
        case "item_allskills": return 43
        case "item_elemskill": return 44
        case "item_addskill_tab": return 45
        case "item_addclassskills": return 46
        case "item_fastermovevelocity": return 47
        case "item_fasterattackrate": return 48
        case "item_fastercastrate": return 49
        case "item_fastergethitrate": return 50
        case "item_fasterblockrate": return 51
        case "toblock": return 52
        case "item_explosivearrow": return 53
        case "item_pierce": return 54
        case "item_magicarrow": return 55
        case "item_mindamage_percent": return 56
        case "item_maxdamage_percent": return 57
        case "item_maxdamage_percent_perlevel": return 58
        case "mindamage": return 59
        case "maxdamage": return 60
        case "item_maxdamage_perlevel": return 61
        case "secondary_mindamage": return 62
        case "secondary_maxdamage": return 63
        case "item_normaldamage": return 64
        case "item_kickdamage": return 65
        case "item_kick_damage_perlevel": return 66
        case "item_ignoretargetac": return 67
        case "item_fractionaltargetac": return 68
        case "item_tohit_percent": return 69
        case "item_tohitpercent_perlevel": return 70
        case "tohit": return 71
        case "item_tohit_perlevel": return 72
        case "item_demondamage_percent": return 73
        case "item_damage_demon_perlevel": return 74
        case "item_demon_tohit": return 75
        case "item_tohit_demon_perlevel": return 76
        case "item_undeaddamage_percent": return 77
        case "attack_vs_montype": return 78
        case "item_damage_undead_perlevel": return 79
        case "item_undead_tohit": return 80
        case "damage_vs_montype": return 81
        case "item_tohit_undead_perlevel": return 82
        case "magicmindam": return 83
        case "magicmaxdam": return 84
        case "firemindam": return 85
        case "firemaxdam": return 86
        case "item_fire_damagemax_perlevel": return 87
        case "lightmindam": return 88
        case "lightmaxdam": return 89
        case "item_ltng_damagemax_perlevel": return 90
        case "coldmindam": return 91
        case "coldmaxdam": return 92
        case "item_cold_damagemax_perlevel": return 93
        case "poisonmindam": return 94
        case "poisonmaxdam": return 95
        case "item_pois_damagemax_perlevel": return 96
        case "manadrainmindam": return 97
        case "lifedrainmindam": return 98
        case "item_pierce_cold": return 99
        case "item_pierce_fire": return 100
        case "item_pierce_ltng": return 101
        case "item_pierce_pois": return 102
        case "passive_fire_mastery": return 103
        case "passive_ltng_mastery": return 104
        case "passive_cold_mastery": return 105
        case "passive_pois_mastery": return 106
        case "passive_fire_pierce": return 107
        case "passive_ltng_pierce": return 108
        case "passive_cold_pierce": return 109
        case "passive_pois_pierce": return 110
        case "item_crushingblow": return 111
        case "item_crushingblow_perlevel": return 112
        case "item_deadlystrike": return 113
        case "item_deadlystrike_perlevel": return 114
        case "item_openwounds": return 115
        case "item_openwounds_perlevel": return 116
        case "item_nonclassskill": return 117
        case "item_singleskill1": return 118
        case "item_singleskill2": return 119
        case "item_singleskill3": return 120
        case "item_singleskill4": return 121
        case "item_singleskill5": return 122
        case "item_restinpeace": return 123
        case "item_preventheal": return 124
        case "item_stupidity": return 125
        case "item_howl": return 126
        case "item_freeze": return 127
        case "item_slow": return 128
        case "item_knockback": return 129
        case "item_damagetargetac": return 130
        case "item_armor_percent": return 131
        case "item_armorpercent_perlevel": return 132
        case "item_armor_perlevel": return 133
        case "armorclass": return 134
        case "armorclass_vs_hth": return 135
        case "armorclass_vs_missile": return 136
        case "strength": return 137
        case "item_strength_perlevel": return 138
        case "dexterity": return 139
        case "item_dexterity_perlevel": return 140
        case "vitality": return 141
        case "item_vitality_perlevel": return 142
        case "energy": return 143
        case "item_energy_perlevel": return 144
        case "maxhp": return 145
        case "item_maxhp_percent": return 146
        case "item_hp_perlevel": return 147
        case "hpregen": return 148
        case "maxmana": return 149
        case "item_maxmana_percent": return 150
        case "item_mana_perlevel": return 151
        case "manarecoverybonus": return 152
        case "maxstamina": return 153
        case "item_stamina_perlevel": return 154
        case "item_staminadrainpct": return 155
        case "staminarecoverybonus": return 156
        case "item_regenstamina_perlevel": return 157
        case "maxmagicresist": return 158
        case "maxpoisonresist": return 159
        case "maxcoldresist": return 160
        case "maxlightresist": return 161
        case "maxfireresist": return 162
        case "magicresist": return 163
        case "coldresist": return 164
        case "item_resist_cold_perlevel": return 165
        case "lightresist": return 166
        case "item_resist_ltng_perlevel": return 167
        case "fireresist": return 168
        case "item_resist_fire_perlevel": return 169
        case "poisonresist": return 170
        case "item_absorbmagic": return 171
        case "item_resist_pois_perlevel": return 172
        case "item_absorb_cold_perlevel": return 173
        case "item_absorbcold": return 174
        case "item_absorb_ltng_perlevel": return 175
        case "item_absorblight": return 176
        case "item_absorb_fire_perlevel": return 177
        case "item_absorbfire": return 178
        case "item_absorbmagic_percent": return 179
        case "item_absorbcold_percent": return 180
        case "item_absorblight_percent": return 181
        case "item_absorbfire_percent": return 182
        case "normal_damage_reduction": return 183
        case "damageresist": return 184
        case "magic_damage_reduction": return 185
        case "item_cannotbefrozen": return 186
        case "item_halffreezeduration": return 187
        case "item_poisonlengthresist": return 188
        case "item_reanimate": return 189
        case "item_healafterkill": return 190
        case "item_manaafterkill": return 191
        case "item_healafterdemonkill": return 192
        case "item_attackertakeslightdamage": return 193
        case "item_attackertakesdamage": return 194
        case "item_thorns_perlevel": return 195
        case "item_addexperience": return 196
        case "item_damagetomana": return 197
        case "item_goldbonus": return 198
        case "item_find_gold_perlevel": return 199
        case "item_magicbonus": return 200
        case "item_reducedprices": return 201
        case "item_find_magic_perlevel": return 202
        case "item_lightradius": return 203
        case "item_throwable": return 204
        case "item_extra_stack": return 205
        case "item_maxdurability_percent": return 206
        case "item_replenish_quantity": return 207
        case "item_charged_skill": return 208
        case "item_replenish_durability": return 209
        case "item_req_percent": return 210

    }
}