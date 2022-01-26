#Include ItemAlert.ahk

class AlertList {
    colors := []
    soundfiles := []
    alerts := []  ; list of Alerts

    __new(yamlFile) {
        
        yamlObj := Yaml(yamlFile, isfile:=1) ;isfile is set to 1 by default

        ; load sounds
        sounds := yamlObj.sounds.Dump(2)
        Loop, Parse, sounds, `n
        {
            sound := StrReplace(A_LoopField, "- ", "")
            sound := StrReplace(sound, """", "")
            this.soundfiles.Push(sound)
        }

        ; load colors
        colors := yamlObj.colors.Dump(2)
        Loop, Parse, colors, `n
        {
            color := StrReplace(A_LoopField, "- ", "")
            color := StrReplace(color, """", "")
            this.colors.Push(color)   
        }

        ; load alerts
        numAlerts := yamlObj.enabledAlerts.()
        Loop, %numAlerts%
        {
            yamlAlert := yamlObj.Alerts[yamlObj.enabledAlerts.(A_Index)]
            alert := new ItemAlert()
            alert.name := yamlObj.enabledAlerts.(A_Index)

            qualities := yamlAlert.quality.Dump(3)
            numQualities := yamlAlert.quality.()
            if (numQualities > 0) {
                Loop, Parse, qualities, `n
                {
                    quality := StrReplace(A_LoopField, "- ", "")
                    quality := StrReplace(quality, """", "")
                    alert.qualities.Push(quality)   
                }
                alert.hasQualities := true
            }

            numItems := yamlAlert.items.()
            if (numItems > 0) {
                items := yamlAlert.items.Dump(3)
                Loop, Parse, items, `n
                {
                    item := StrReplace(A_LoopField, "- ", "")
                    item := StrReplace(item, """", "")
                    alert.items.Push(item)   
                }
                alert.hasItems := true
            }

            if (yamlAlert.sound) {
                alert.sound := yamlAlert.sound
            }
            if (yamlAlert.color) {
                alert.color := yamlAlert.color
            }
            if (yamlAlert.speak) {
                if (yamlAlert.speak == "true" or yamlAlert.speak == true) {
                    alert.speak := true
                }
                if (yamlAlert.speak == "false" or yamlAlert.speak == false) {
                    alert.speak := false
                }
            }
            this.alerts.Push(alert)
        }
    }

    findAlert(item) {

        ; item.name
        ; item.quality
        ; item.numSockets
        item.name := Trim(item.name)
        qualityName := getQuality(item.itemQuality)
        for index, alert in this.alerts
        {
            ; check quality
            foundQuality := true
            
            if (alert.hasQualities) {
                
                foundQuality := false
                for index, qual in alert.qualities
                {
                    if (qualityName == qual) {
                        ; matched quality
                        foundQuality := true
                    }
                }
            }

            ; check item name
            foundItemName := true
            if (alert.hasItems) {
                foundItemName := false
                for index, it in alert.items
                {
                    itarr := StrSplit(it , ",")
                    ;msgbox % itarr[1] " " item.name
                    if (item.name == itarr[1]) {
                        ; matched item
                        
                        if (itarr[2]) { ; if sockets are defined
                            if (itarr[2] == item.numSockets) {
                                foundItemName := true
                            }
                        } else {
                            foundItemName := true
                        }
                    }
                }
            }
            if (foundItemName && foundQuality) {
                ;msgbox % qualityName " " item.name " matched " alert.name
                return alert
            }
        }
        return ""
    }
}

getQuality(qualityNo) {
    switch (qualityNo) {
        case 1: return "Inferior"
        case 2: return "Normal"
        case 3: return "Superior"
        case 4: return "Magic"
        case 5: return "Set"
        case 6: return "Rare"
        case 7: return "Unique"
        case 8: return "Crafted"
        case 9: return "Tempered"
    }
    return ""
}

