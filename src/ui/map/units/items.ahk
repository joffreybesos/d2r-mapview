
drawItemAlerts(ByRef G, ByRef brushes, ByRef settings, ByRef gameMemoryData, ByRef scale, ByRef gameWindow) {
    ; draw item alerts
    SetFormat Integer, D
    playerX := gameMemoryData.xPos
    playerY := gameMemoryData.yPos
    renderScale := settings["serverScale"]
    
    items := gameMemoryData["items"]
    for index, item in items
    {
        alert := itemAlertList.findAlert(item)
        if (alert) {
            itemScreenPos := World2Screen(playerX, playerY, item.x, item.y, scale, gameWindow)
            
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
            if (item.identified and !item.inStore and item.txtFileNo < 508) {
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
                drawFloatingText(G, brushes, itemScreenPos.x, itemScreenPos.y, fontSize, acolor, true, false, exocetFont, itemText)
                switch (ticktock) {
                    case 1: Gdip_FillEllipse(G, pBrush1, itemScreenPos.x-5, itemScreenPos.y-5, 10, 10)
                    case 2: Gdip_FillEllipse(G, pBrush2, itemScreenPos.x-6, itemScreenPos.y-6, 12, 12)
                    case 3: Gdip_FillEllipse(G, pBrush3, itemScreenPos.x-8, itemScreenPos.y-8, 16, 16)
                    case 4: Gdip_FillEllipse(G, pBrush4, itemScreenPos.x-10, itemScreenPos.y-10, 20, 20)
                    case 5: Gdip_FillEllipse(G, pBrush5, itemScreenPos.x-14, itemScreenPos.y-14, 28, 28)
                    case 6: Gdip_FillEllipse(G, pBrush6, itemScreenPos.x-16, itemScreenPos.y-16, 32, 32)
                }
                Gdip_FillEllipse(G, pBrush2, itemScreenPos.x-2.5, itemScreenPos.y-2.5, 5, 5)
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
            WriteLog("ITEMLOG: Found item '" item.getTextToSpeech() "' at '" item.x ", " item.y "' matched to alert '" alert.name "' " item.getHash())
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
