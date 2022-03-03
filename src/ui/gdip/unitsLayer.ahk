#NoEnv

class UnitsLayer {
    hbm :=
    hdc :=
    obm :=
    G :=

    __new(ByRef uiData) {
        scaledWidth := uiData["scaledWidth"]
        scaledHeight := uiData["scaledHeight"]

        if (settings["centerMode"]) {
            WinGetPos, ,  , gameWidth, gameHeight, %gameWindowId% 
            this.hbm := CreateDIBSection(gameWidth, gameHeight)
        } else {
            this.hbm := CreateDIBSection(scaledWidth, scaledHeight)
        }
        this.hdc := CreateCompatibleDC()
        this.obm := SelectObject(this.hdc, this.hbm)
        
        this.G := Gdip_GraphicsFromHDC(this.hdc)
        Gdip_SetSmoothingMode(this.G, 4)
        Gdip_SetInterpolationMode(this.G, 7)
    }


    delete() {
        SelectObject(this.hdc, this.obm)
        DeleteObject(this.hbm)
        DeleteDC(this.hdc)
        Gdip_DeleteGraphics(this.G)
    }
}