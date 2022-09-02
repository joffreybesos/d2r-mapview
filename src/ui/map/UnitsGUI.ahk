; #Include %A_ScriptDir%\ui\drawing\helper.ahk
; #Include %A_ScriptDir%\ui\drawing\exits.ahk
; #Include %A_ScriptDir%\ui\drawing\items.ahk
; #Include %A_ScriptDir%\ui\drawing\lines.ahk
; #Include %A_ScriptDir%\ui\drawing\missiles.ahk
; #Include %A_ScriptDir%\ui\drawing\mobs.ahk
; #Include %A_ScriptDir%\ui\drawing\objects.ahk
; #Include %A_ScriptDir%\ui\drawing\otherplayers.ahk

#Include %A_ScriptDir%\ui\map\Drawing.ahk
#Include %A_ScriptDir%\ui\map\units\npcs.ahk
#Include %A_ScriptDir%\ui\map\units\objects.ahk
#Include %A_ScriptDir%\ui\map\units\exits.ahk
#Include %A_ScriptDir%\ui\map\units\lines.ahk
#Include %A_ScriptDir%\ui\map\units\items.ahk
#Include %A_ScriptDir%\ui\map\units\missiles.ahk
#Include %A_ScriptDir%\ui\map\units\players.ahk

class UnitsGUI {
    unitHwnd :=
    brushes :=

    __new(ByRef settings) {
        Gui, Units: -Caption +E0x20 +E0x80000 +E0x00080000 +LastFound +AlwaysOnTop +ToolWindow +OwnDialogs 
        this.unitHwnd := WinExist()
        
        gameWindow := getWindowClientArea()
        this.hbm := CreateDIBSection(gameWindow.W, gameWindow.H)

        this.hdc := CreateCompatibleDC()
        this.obm := SelectObject(this.hdc, this.hbm)

        this.G := Gdip_GraphicsFromHDC(this.hdc)
        Gdip_SetSmoothingMode(this.G, 4)
        Gdip_SetInterpolationMode(this.G, 7)
        this.brushes := new Brushes(settings)
    }

    drawUnitLayer(ByRef settings, ByRef gameMemoryData, ByRef mapImage) {
        ; timeStamp("unitsStart")
        StartTime := A_TickCount
        , Angle := 45
        , opacity := 1.0
        , scale:= settings["centerModeScale"]
        , renderScale := settings["serverScale"]
        , opacity:= settings["centerModeOpacity"]
        
        ; get relative position of player in world
        ; xpos is absolute world pos in game
        ; each map has offset x and y which is absolute world position
        gameWindow := getWindowClientArea()
        playerX := gameMemoryData.xPos
        playerY := gameMemoryData.yPos

        drawNPCs(this.G, this.brushes, settings, gameMemoryData)
        drawObjects(this.G, this.brushes, settings, gameMemoryData)
        drawExits(this.G, this.brushes, settings, gameMemoryData, mapImage)
        drawLines(this.G, this.brushes, settings, gameMemoryData, mapImage)
        drawItemAlerts(this.G, this.brushes, settings, gameMemoryData)
        drawMissiles(this.G, this.brushes, settings, gameMemoryData)
        drawPlayers(this.G, this.brushes, settings, gameMemoryData)
        
        Gdip_DrawRectangle(this.G, this.brushes.pPenHealth, 0, 0, gameWindow.W, gameWindow.H)
        UpdateLayeredWindow(this.unitHwnd, this.hdc, 0, 0, gameWindow.W, gameWindow.H)
        Gdip_GraphicsClear( this.G )

        ; timeStamp("unitsEnd")
    }

    show() {
        Gui, Units: Show, NA
    }

    hide() {
        Gui, Units: Hide ; hide units
    }

}



; player is always middle of screen, calculate relative to that
World2Screen(ByRef playerX, ByRef playerY, ByRef targetx, ByRef targety, scale) {
    ; scale := 27
    scale := scale * 3
    xdiff := targetx - playerX
    ydiff := targety - playerY
    
    gameWindow := getWindowClientArea()
    centerX := (gameWindow.W/2)
    centerY := (gameWindow.H/2)
    angle := 0.785398    ;45 deg
    x := xdiff * cos(angle) - ydiff * sin(angle)
    y := xdiff * sin(angle) + ydiff * cos(angle)
    x := centerX + (x * scale)
    y := centerY + (y * scale * 0.5) - 10
    return { "x": x, "y": y }
}