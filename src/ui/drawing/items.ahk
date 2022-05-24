
drawItemAlerts(ByRef unitsLayer, ByRef settings, ByRef gameMemoryData, ByRef imageData, ByRef serverScale, ByRef scale, ByRef padding, ByRef Width, ByRef Height, ByRef scaledWidth, ByRef scaledHeight, ByRef centerLeftOffset, ByRef centerTopOffset) {
    ; draw item alerts
    SetFormat Integer, D
    items := gameMemoryData["items"]
    for index, item in items
    {
        alert := itemAlertList.findAlert(item)
        if (alert) {
            itemx := ((item.itemx - imageData["mapOffsetX"]) * serverScale) + padding
            , itemy := ((item.itemy - imageData["mapOffsetY"]) * serverScale) + padding
            , correctedPos := correctPos(settings, itemx, itemy, (Width/2), (Height/2), scaledWidth, scaledHeight, scale)
            , itemx := correctedPos["x"] + centerLeftOffset
            , itemy := correctedPos["y"] + centerTopOffset
            
            pBrush1 := Gdip_BrushCreateSolid("0xffffffff")
            , pBrush2 := Gdip_BrushCreateSolid("0xee" . alert.color)
            , pBrush3 := Gdip_BrushCreateSolid("0xdd" . alert.color)
            , pBrush4 := Gdip_BrushCreateSolid("0xaa" . alert.color)
            , pBrush5 := Gdip_BrushCreateSolid("0x55" . alert.color)
            , pBrush6 := Gdip_BrushCreateSolid("0x33" . alert.color)
            , fontSize := settings["itemFontSize"] * scale
            , itemText := item.localizedName
            , itemLogText := item.localizedName
            if (item.inStore) {
                itemLogText := "(Vendor) " itemLogText
            }
            if (item.prefixName) {
                itemText := item.prefixName "`n" itemText
                , itemLogText := item.prefixName " " itemLogText
            }
            if (item.numSockets > 0) {
                SetFormat Integer, D
                itemText := itemText " [" item.numSockets "]"
                , itemLogText := itemLogText " [" item.numSockets "]"
            }
            if (item.identified and !item.inStore) {
                itemLogText := itemLogText " (Identified)" 
            }
            if (item.ethereal) {
                itemText := "Eth. " itemText
                , itemLogText := "(Ethereal) " itemLogText
            }
            acolor := "cc" . alert.color    
            item.itemLogText := itemLogText
            item.alertColor := "ff" . alert.color    
            if (alert.speak or alert.soundfile) {
                announceItem(settings, item, alert)
            }
            if (itemLoc != 2) { ; if not in store
                drawFloatingText(unitsLayer, itemx, itemy, fontSize, acolor, true, exocetFont, itemText)
                switch (ticktock) {
                    case 1: Gdip_FillEllipse(unitsLayer.G, pBrush1, itemx-5, itemy-5, 10, 10)
                    case 2: Gdip_FillEllipse(unitsLayer.G, pBrush2, itemx-6, itemy-6, 12, 12)
                    case 3: Gdip_FillEllipse(unitsLayer.G, pBrush3, itemx-8, itemy-8, 16, 16)
                    case 4: Gdip_FillEllipse(unitsLayer.G, pBrush4, itemx-10, itemy-10, 20, 20)
                    case 5: Gdip_FillEllipse(unitsLayer.G, pBrush5, itemx-14, itemy-14, 28, 28)
                    case 6: Gdip_FillEllipse(unitsLayer.G, pBrush6, itemx-16, itemy-16, 32, 32)
                }
                Gdip_FillEllipse(unitsLayer.G, pBrush2, itemx-2.5, itemy-2.5, 5, 5)
                Gdip_DeletePen(pItemPen)
            }
        }
    }
    Gdip_DeletePen(pItemPen2)
}


announceItem(settings, item, alert) {
    
    if (!seenItems[item.getHash()]) {
        if (!item.isQuestItem(item.txtFileNo)) {
            ; seen item for the first time
            WriteLog("ITEMLOG: Found item '" item.getTextToSpeech() "' at '" item.itemx ", " item.itemy "' matched to alert '" alert.name "'")
            if (settings["allowTextToSpeech"]) {
                SetFormat Integer, D
                volume := Round(settings["textToSpeechVolume"] + 0)
                pitch := Round(settings["textToSpeechPitch"] + 0)
                speed := Round(settings["textToSpeechSpeed"] + 0)
                try {
                    speech := "<pitch absmiddle=""" pitch """><rate absspeed=""" speed """><volume level=""" volume """>" item.getTextToSpeech() "</volume></rate></pitch>"
                    oSpVoice.Speak(speech, 1)
                } catch e {
                    WriteLog("Error with text to speech, try changing voice " speech)   
                    WriteLog(e.message)
                }
            }
            if (settings["allowItemDropSounds"]) {
                if (alert.soundfile) {
                    soundfile := alert.soundfile
                    SoundPlay, %soundfile%
                }
            }
            item.loadStats()
            item.foundTime := A_Now
            seenItems[item.getHash()] := item
            itemLogItems[A_Now . item.getHash()] := item.Clone()
            itemLogLayer.drawItemLog()
        }
    }
    
}
