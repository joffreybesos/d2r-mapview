#SingleInstance, Force
SendMode Input
SetWorkingDir, %A_ScriptDir%

drawItemAlerts(G, settings, gameMemoryData, imageData, serverScale, scale, padding, Width, Height, scaledWidth, scaledHeight, centerLeftOffset, centerTopOffset) {
    ; draw item alerts
    items := gameMemoryData["items"]
    for index, item in items
    {
        alert := itemAlertList.findAlert(item)
        ;WriteLog(item.quality " " item.name " matched alert " alert.name)
        if (alert) {
            itemx := ((item.itemx - imageData["mapOffsetX"]) * serverScale) + padding
            itemy := ((item.itemy - imageData["mapOffsetY"]) * serverScale) + padding
            correctedPos := correctPos(settings, itemx, itemy, (Width/2), (Height/2), scaledWidth, scaledHeight, scale)
            itemx := correctedPos["x"] + centerLeftOffset
            itemy := correctedPos["y"] + centerTopOffset
            if (alert.speak or alert.soundfile) {
                announceItem(settings, item, alert)
            }
            pBrush1 := Gdip_BrushCreateSolid("0xffffffff")
            pBrush2 := Gdip_BrushCreateSolid("0xee" . alert.color)
            pBrush3 := Gdip_BrushCreateSolid("0xdd" . alert.color)
            pBrush4 := Gdip_BrushCreateSolid("0xaa" . alert.color)
            pBrush5 := Gdip_BrushCreateSolid("0x55" . alert.color)
            pBrush6 := Gdip_BrushCreateSolid("0x33" . alert.color)
            textx := itemx - 100
            texty := itemy - 107
            acolor := "cc" . alert.color
            Options = x%textx% y%texty% Center Bold vBottom c%acolor% r8 s18
            textx := textx + 1.5
            texty := texty + 1.5
            Options2 = x%textx% y%texty% Center Bold vBottom cff000000 r8 s18
            Gdip_TextToGraphics(G, item.name, Options2, diabloFont, 200, 100)
            Gdip_TextToGraphics(G, item.name, Options, diabloFont, 200, 100)
            switch (ticktock) {
                case 1: Gdip_FillEllipse(G, pBrush1, itemx-5, itemy-5, 10, 10)
                case 2: Gdip_FillEllipse(G, pBrush2, itemx-6, itemy-6, 12, 12)
                case 3: Gdip_FillEllipse(G, pBrush3, itemx-8, itemy-8, 16, 16)
                case 4: Gdip_FillEllipse(G, pBrush4, itemx-10, itemy-10, 20, 20)
                case 5: Gdip_FillEllipse(G, pBrush5, itemx-14, itemy-14, 28, 28)
                case 6: Gdip_FillEllipse(G, pBrush6, itemx-16, itemy-16, 32, 32)
            }
            Gdip_FillEllipse(G, pBrush2, itemx-2.5, itemy-2.5, 5, 5)
            
            Gdip_DeletePen(pItemPen)
        }
    }
    Gdip_DeletePen(pItemPen2)
}



announceItem(settings, item, alert) {
    if (settings["allowTextToSpeech"] or settings["allowItemDropSounds"]) {
        if (!hasVal(seenItems, item.getHash())) {
            ; seen item for the first time
            WriteLog("ITEMLOG: Found item '" item.quality " " item.name "' matched to alert '" alert.name "'")
            if (settings["allowTextToSpeech"]) {
                volume := settings["textToSpeechVolume"]
                pitch := settings["textToSpeechPitch"]
                speed := settings["textToSpeechSpeed"]
                oSpVoice.Speak("<pitch absmiddle=""" pitch """><rate absspeed=""" speed """><volume level=""" volume """>" item.getTextToSpeech() "</volume></rate></pitch>", 1)
            }
            if (settings["allowItemDropSounds"]) {
                if (alert.soundfile) {
                    soundfile := alert.soundfile
                    SoundPlay, %soundfile%
                }
            }
            seenItems.push(item.getHash())
        }
    }
}
