#Include %A_ScriptDir%\ui\map\Drawing.ahk
#Include %A_ScriptDir%\ui\map\units\npcs.ahk
#Include %A_ScriptDir%\ui\map\units\objects.ahk
#Include %A_ScriptDir%\ui\map\units\exits.ahk
#Include %A_ScriptDir%\ui\map\units\lines.ahk
#Include %A_ScriptDir%\ui\map\units\items.ahk
#Include %A_ScriptDir%\ui\map\units\missiles.ahk
#Include %A_ScriptDir%\ui\map\units\players.ahk
#Include %A_ScriptDir%\ui\helper.ahk

class UnitsGUI {
    unitHwnd :=
    brushes :=

    __new(ByRef settings) {
        Gui, Units: -Caption +E0x20 +E0x80000 +E0x00080000 +LastFound +AlwaysOnTop +ToolWindow +OwnDialogs 
        this.unitHwnd := WinExist()
        this.createDrawingSection(settings)
        this.brushes := new Brushes(settings)
    }

    createDrawingSection(ByRef settings) {
        gameWindow := getMapDrawingArea()
        this.hbm := CreateDIBSection(gameWindow.W, gameWindow.H)

        this.hdc := CreateCompatibleDC()
        this.obm := SelectObject(this.hdc, this.hbm)

        this.G := Gdip_GraphicsFromHDC(this.hdc)
        Gdip_SetSmoothingMode(this.G, 4)
        Gdip_SetInterpolationMode(this.G, 7)

        this.setScale(settings)
        this.setOffsetPosition(settings)
    }

    setScale(ByRef settings) {
        if (settings["mapPosition"] == "TOP_LEFT") {
            this.scale := settings["cornerModeScale"]
        } else if (settings["mapPosition"] == "TOP_RIGHT") {
            this.scale := settings["cornerModeScale"]
        } else {
            this.scale := settings["centerModeScale"]
        }
    }

    setOffsetPosition(ByRef settings) {
        if (settings["mapPosition"] == "TOP_LEFT") {
            this.offsetX := settings["cornerModeOffsetX"]
            this.offsetY := settings["cornerModeOffsetY"]
        } else if (settings["mapPosition"] == "TOP_RIGHT") {
            this.offsetX := settings["cornerModeOffsetX"]
            this.offsetY := settings["cornerModeOffsetY"]
        } else {
            this.offsetX := settings["centerModeOffsetX"]
            this.offsetY := settings["centerModeOffsetY"]
        }
    }

    drawUnitLayer(ByRef settings, ByRef gameMemoryData, ByRef mapImage) {
        ; get relative position of player in world
        ; xpos is absolute world pos in game
        ; each map has offset x and y which is absolute world position
        gameWindow := getMapDrawingArea()
        
        drawNPCs(this.G, this.brushes, settings, gameMemoryData, this.scale, gameWindow)
        drawObjects(this.G, this.brushes, settings, gameMemoryData, this.scale, gameWindow)
        drawExits(this.G, this.brushes, settings, gameMemoryData, this.scale, gameWindow, mapImage)
        drawLines(this.G, this.brushes, settings, gameMemoryData, this.scale, gameWindow, mapImage)
        drawItemAlerts(this.G, this.brushes, settings, gameMemoryData, this.scale, gameWindow)
        drawMissiles(this.G, this.brushes, settings, gameMemoryData, this.scale, gameWindow)
        drawPlayers(this.G, this.brushes, settings, gameMemoryData, this.scale, gameWindow)
        
        ; Gdip_DrawRectangle(this.G, this.brushes.pPenHealth, this.offsetX, this.offsetY, gameWindow.W-1, gameWindow.H-1)
        UpdateLayeredWindow(this.unitHwnd, this.hdc, gameWindow.X + this.offsetX, gameWindow.Y + this.offsetY, gameWindow.W, gameWindow.H)
        Gdip_GraphicsClear( this.G )
    }

    show() {
        Gui, Units: Show, NA
    }

    hide() {
        Gui, Units: Hide ; hide units
    }
}



; player is always middle of screen, calculate relative to that
World2Screen(ByRef playerX, ByRef playerY, ByRef targetx, ByRef targety, scale, ByRef gameWindow) {
    ; scale := 27
    renderScale := settings["serverScale"]
    scale := scale * renderScale
    xdiff := targetx - playerX
    ydiff := targety - playerY
    
    angle := 0.785398    ;45 deg
    x := xdiff * cos(angle) - ydiff * sin(angle)
    y := xdiff * sin(angle) + ydiff * cos(angle)
    x := gameWindow.CenterX + (x * scale)
    y := gameWindow.CenterY + (y * scale * 0.5) - 10
    return { "x": x, "y": y }
}