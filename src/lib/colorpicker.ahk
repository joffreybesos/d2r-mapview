colorpicker(){
    global 
    Gui, ColorPicker:Default
    Gui, -MinimizeBox
    local progressX:=0
    local progressY:=5
    local progressS:=50
    glable:="gColorPickerUpdate"
    Gui, Add, Progress, % "x" progressX " y"progressY " w" progressS " h" progressS " +C0xFF0000 vProg", 100
    Gui, Add, Edit, % "x" (progressX+=progressS)  " y" (progressY) " w" 70 " h20 vHex " glable, 0xFFFF0000
    Gui, Font, s9
    local buttony:=progressY
    Gui, Add, Button, % "x" progressX " y" (buttony+=20) " w" 70 " h" 15, CopyRGB
    Gui, Add, Button, % "x" progressX " y" (buttony+=15 )" w" 70 " h" 15, CopyAlpha
    ;Gui, Add, Button, % "x" 165 " y" buttony " w75 h23", Close
    rgbtX:=13 , rgbty:=buttony+25
    Gui, Font, s12
    Gui, Add, Text, % "x" rgbtX " y" rgbty " w20 h20 Center", R
    Gui, Font, s9
    Gui, Add, Edit, % "x" rgbtX " y" (rgbty+25) " w25 h20 +Number Center ReadOnly vR " glable, 255
    Gui, Font, s12
    Gui, Add, Text, % "x" (rgbtX+=25) " y" rgbty " w25 h25 Center", G
    Gui, Font, s9
    Gui, Add, Edit, % "x" rgbtX " y" (rgbty+25) " w25 h20 +Number Center ReadOnly vG " glable, 0
    Gui, Font, s12
    Gui, Add, Text, % "x" (rgbtX+=25) " y" rgbty " w25 h25 Center", B
    Gui, Font, s9
    Gui, Add, Edit, % "x" rgbtX " y" (rgbty+25) " w25 h20 +Number Center ReadOnly vB " glable, 0
    Gui, Font, s12
    Gui, Add, Text, % "x" (rgbtX+=25) " y"rgbty " w25 h25 Center", A
    Gui, Font, s9
    Gui, Add, Edit, % "x" rgbtX " y" (rgbty+25) " w25 h20 +Number Center ReadOnly vA " glable, 255
    local sliderh:=150
    local sliderw:=25
    local sliderx:=10
    local slidery:=rgbty+50
    options:=" TickInterval1 +Vertical +0x20 +0x200 +Vertical +Invert +Center +Range0-255 -Tabstop AltSubmit " glable
    Gui, Add, Slider, % "x" sliderx " y" slidery " w" sliderw " h" sliderh options " vRS", 255
    Gui, Add, Slider, % "x" (sliderx+=sliderw) " y" slidery " w" sliderw " h" sliderh options " vGS", 0
    Gui, Add, Slider, % "x" (sliderx+=sliderw) " y" slidery " w" sliderw " h" sliderh options " vBS", 0
    Gui, Add, Slider, % "x" (sliderx+=sliderw) " y" slidery " w" sliderw " h" sliderh options " vAS", 255
    Gui, Show,, % "Color Picker"

}

ColorPickerGuiEscape(){
    ColorPickerGuiClose()
}
ColorPickerGuiClose(){
    Gui, ColorPicker:Destroy
}
ColorPickerButtonClose(){
    ColorPickerGuiClose()
}
ColorPickerUpdate(){
    GuiControlGet, RS
    GuiControlGet, GS
    GuiControlGet, BS
    GuiControlGet, AS

    GuiControlGet, R
    GuiControlGet, G
    GuiControlGet, B
    GuiControlGet, A
    GuiControlGet, Hex
    GuiControlGet, Prog

	ColorPickerSet("R", RS)
	ColorPickerSet("G", GS)
	ColorPickerSet("B", BS)
	ColorPickerSet("A", AS)
	ColorPickerSet("RS", R, "+Range0-255")
	ColorPickerSet("GS", G, "+Range0-255")
	ColorPickerSet("BS", B, "+Range0-255")
	ColorPickerSet("AS", A, "+Range1-255")
	ColorPickerSet("Hex", ARGB(R, G, B, A))
	ColorPickerSet("Prog",, "+C" ARGB(R, G, B))
}

ColorPickerButtonCopyRGB(){
    GuiControlGet, Hex
    return Clipboard:=SubStr(Hex, 5)
}
ColorPickerButtonCopyAlpha(){
    GuiControlGet, R
    GuiControlGet, G
    GuiControlGet, B
    GuiControlGet, A
    return clipboard:=SubStr(ARGB(R, G, B, A), 1 , 4)
}

ARGB(R, G, B, A := 00) {
    lastformat:=A_FormatInteger
	SetFormat, Integer, Hex
    ARGB:=(A << 24) | (R << 16) | (G << 8) | B
    setformat, integer, % lastformat
	Return ARGB
}

ColorPickerSet(Control, Data := "", AddOpt := "") {
	GuiControl, %AddOpt%, %Control%, % Data
    return !ErrorLevel
}
RGB300(Val_0_300){
    ; aa 0-300 for full hue
    Max := 255
    a2 := 0
    a3 := 0
    n := Round(max/50,0)
    if (aa:=Val_0_300) between 1 and 50
    {
    a1 := Color300(max)
    ab := aa*n
    a2 := Color300(ab)
    a3 := Color300(0)
    }
    if aa between 51 and 100
    {
    a2 := Color300(max)
    ab := (max-aa)*n
    a1 := Color300(ab)
    a3 := Color300(0)
    }
    if aa between 101 and 150
    {
    a2 := Color300(max)
    ab := (aa-100)*n
    a3 := Color300(ab)
    a1 := Color300(0)
    }
    if aa between 151 and 200
    {
    a3 := Color300(max)
    ab := (max-(aa-150))*n
    a2 := Color300(ab)
    a1 := Color300(0)
    }
    if aa between 201 and 250
    {
    a3 := Color300(max)
    ab := (aa-200)*n
    a1 := Color300(ab)
    a2 := Color300(0)
    }
    if aa between 251 and 300
    {
    a1 := Color300(max)
    ab := (max-(aa-250))*n
    a3 := Color300(ab)
    a2 := Color300(0)
    }
    return a1 a2 a3
}
Color300(N) { 					; Function borrowed from Wicked (http://www.autohotkey.com/forum/viewtopic.php?t=57368&postdays=0&postorder=asc&start=0)
   SetFormat, Integer, Hex 
   N += 0 
   SetFormat, Integer, D 
   StringTrimLeft, N, N, 2 
   If(StrLen(N) < 2) 
      N = 0%N%
   Return N 
}