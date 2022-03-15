#NoEnv

class WelcomeSplash {
    hbm :=
    hdc :=
    obm :=
    G :=
    WelcomeLayerHwnd :=

    __new(ByRef settings) {
        Gui, Welcome: -Caption +E0x20 +E0x80000 +E0x00080000 +LastFound +AlwaysOnTop +ToolWindow +OwnDialogs 
        this.WelcomeLayerHwnd := WinExist()
        
        this.welcomeFontSize := 18
        this.maxWidth := 500
        this.maxHeight := 200
        
        

        pToken := Gdip_Startup()
        DetectHiddenWindows, On
        this.hbm := CreateDIBSection(this.maxWidth, this.maxHeight)
        this.hdc := CreateCompatibleDC()
        this.obm := SelectObject(this.hdc, this.hbm)
        this.G := Gdip_GraphicsFromHDC(this.hdc)
        Gdip_SetSmoothingMode(this.G, 4)
        Gdip_SetInterpolationMode(this.G, 7)
        this.createPens(settings)
        this.createBrushes(settings)
        
        Gui, Welcome: Show, NA
    }


    drawWelcomeText() {
        WinGetPos, , , gameWidth, gameHeight, %gameWindowId% 
        textx := (gameWidth /2)
        texty := 200
        welcomeText := "D2R-MapView`nPress Ctrl+O for settings`nPress Ctrl+H for help"
        
        drawFloatingText(this, textx, texty, this.welcomeFontSize, "ffc6b276", true, exocetFont, welcomeText)
    }

    delete() {
        SelectObject(this.hdc, this.obm)
        DeleteObject(this.hbm)
        DeleteDC(this.hdc)
        Gdip_DeleteGraphics(this.G)
        Gui, Welcome: Destroy
    }
}