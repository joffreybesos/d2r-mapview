#NoEnv

class PartyEquipmentLayer {
    hbm :=
    hdc :=
    obm :=
    G :=
    PartyEquipLayerHwnd :=

    __new(ByRef settings) {
        this.topPadding := 0
        this.leftPadding := 0 
        gameClientArea := getWindowClientArea()
        gameWindowX := gameClientArea["X"]
        gameWindowY := gameClientArea["Y"]
        gameWindowWidth := gameClientArea["W"]
        gameWindowHeight := gameClientArea["H"]

        Gui, PlayerEquipment: -Caption +E0x20 +E0x80000 +E0x00080000 +LastFound +AlwaysOnTop +ToolWindow +OwnDialogs 
        this.PartyEquipLayerHwnd := WinExist()
        
        if ((gameWindowWidth / gameWindowHeight) > 2) { ;if ultrawide
            this.leftMargin := this.leftPadding + ((gameWindowWidth/2) - (1.034 * gameWindowHeight)) + gameWindowX - 3
            this.topMargin := this.topPadding + (gameWindowHeight / 53) + gameWindowY
            this.spacing := gameWindowHeight / 10.59
        } else {
            this.leftMargin := this.leftPadding + ((gameWindowHeight / 46)) + gameWindowX - 2
            this.topMargin := this.topPadding + (gameWindowHeight / 51.5) + gameWindowY
            this.spacing := gameWindowHeight / 10.6
        }

		if (settings["PlayerEquipmentFontSize"]) {
            this.PlayerEquipmentFontSize := settings["PlayerEquipmentFontSize"]
        } else {
            this.PlayerEquipmentFontSize := this.spacing / 11
        }
        
        this.textBoxWidth := 2000
        this.textBoxHeight := gameWindowHeight
        this.xoffset := 0
        this.yoffset := this.spacing * 0.85 ; + gameWindowY

        pToken := Gdip_Startup()
        DetectHiddenWindows, On
        this.hbm := CreateDIBSection(this.textBoxWidth, this.textBoxHeight)
        this.hdc := CreateCompatibleDC()
        this.obm := SelectObject(this.hdc, this.hbm)
        this.G := Gdip_GraphicsFromHDC(this.hdc)
        Gdip_SetSmoothingMode(this.G, 4)
        Gdip_SetInterpolationMode(this.G, 7)
        Gui, PlayerEquipment: Show, NA

        this.pPenBuff := Gdip_CreatePen(0xff00FF00, 2)
    }

    checkHover(mouseX, mouseY) {
        this.showToolTip := 0
        if (mouseX > this.leftMargin and mouseX < (this.leftMargin + this.textBoxWidth)) {
            if (mouseY > this.topMargin and mouseY < (this.topMargin + this.textBoxHeight)) {
            }
        }
        Gdip_DrawRectangle(this.G, this.pPenBuff, 0, 0, this.spacing * 0.6, this.textBoxHeight)
        UpdateLayeredWindow(this.PartyEquipLayerHwnd, this.hdc, this.leftMargin, this.topMargin, this.textBoxWidth, this.textBoxHeight)
        Gdip_GraphicsClear( this.G )
    }

    ; drawInfoText(partyList, playerUnitId) {
    ;     if (WinActive(gameWindowId)) {
    ;         Gui, PlayerEquipment: Show, NA
    ;     } else {
    ;         Gui, PlayerEquipment: Hide
	; 		return
    ;     }
	; 	if (readUI(d2rprocess)) {
    ;         Gui, PlayerEquipment: Hide
	; 		return
    ;     }
	; 	if (settings["showPartyLocations"]) {
	; 		Gui, PlayerEquipment: Show, NA
	; 	} else {
	; 		Gui, PlayerEquipment: Hide
	; 		return
	; 	}
        
    ;     fontSize := this.PlayerEquipmentFontSize

    ;     ; get the current players part id
    ;     for k,v in partyList
    ;     {
    ;         if (playerUnitId == v.unitId) {
    ;             playerPartyId := v.partyId
    ;             break
    ;         }
    ;     }
    ;     ; draw each party member location
    ;     for k,v in partyList
    ;     {
    ;         if (k > 1) { ; don't draw your own
    ;             if (v.partyId == playerPartyId) { ; only if in same party
    ;                 levelName := getAreaName(v.area)
	; 				if (levelName) {
	; 					playerText := v.plevel " - " levelName
	; 				} else {
	; 					playerText := v.plevel
	; 				}
    ;                 this.drawData(this.xoffset, this.yoffset + (this.spacing * (k-1)), fontSize, playerText)
    ;             }
    ;         }
    ;     }
        
    ;     UpdateLayeredWindow(this.PartyEquipLayerHwnd, this.hdc, this.leftMargin, this.topMargin, this.textBoxWidth, this.textBoxHeight)
    ;     Gdip_GraphicsClear( this.G )
    ; }

    ; drawData(textx, texty, fontSize, textList) {
    ;     Options = x%textx% y%texty%  w200 h100 Left vTop cffc6b276 r4 s%fontSize%
    ;     textx := textx + 1
    ;     texty := texty + 1
    ;     Options2 = x%textx% y%texty% w200 h100 Left vTop cdd000000 r4 s%fontSize%
    ;     Gdip_TextToGraphics(this.G, textList, Options2, formalFont)
    ;     Gdip_TextToGraphics(this.G, textList, Options, formalFont)
    ; }

	show() {
        Gui, PlayerEquipment: Show, NA
    }

    hide() {
        Gui, PlayerEquipment: Hide
    }

    delete() {
        SelectObject(this.hdc, this.obm)
        DeleteObject(this.hbm)
        DeleteDC(this.hdc)
        Gui, PlayerEquipment: Destroy
    }

}



