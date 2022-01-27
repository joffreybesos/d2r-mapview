class AlertList {
    alerts := []  ; list of Alerts

    __new(yamlFile) {
        
        yamlObj := Yaml(yamlFile, isfile:=1) ;isfile is set to 1 by default

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

            if (yamlAlert.soundeffect) {
                alert.soundfile := yamlAlert.soundeffect
            }
            if (yamlAlert.color) {
                alert.color := "0xCC" Trim(yamlAlert.color)
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
        for index, alert in this.alerts
        {
            ; check quality
            foundQuality := true
            
            if (alert.hasQualities) {
                ;WriteLog(item.quality " " item.name)
                
                foundQuality := false
                for index, checkqual in alert.qualities
                {
                    if (item.quality == checkqual) {
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
