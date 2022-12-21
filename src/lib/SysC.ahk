class SySC {
        static COLOR_SCROLLBAR := 0  ; Scroll bar gray area.Windows 10 or greater: This value is not supported.
        static COLOR_DESKTOP := 1  ; Desktop.Windows 10 or greater: This value is not supported.
        static COLOR_BACKGROUND := 1  ; Desktop.Windows 10 or greater: This value is not supported.
        static COLOR_ACTIVECAPTION := 2  ; Active window title bar.The associated foreground color is COLOR_CAPTIONTEXT.
                                            ;Specifies the left side color in the color gradient of an active window's title bar if the gradient effect is enabled.
                                            ;Windows 10 or greater: This value is not supported.
        static COLOR_INACTIVECAPTION := 3  ; Inactive window caption.The associated foreground color is COLOR_INACTIVECAPTIONTEXT.
                                            ;Specifies the left side color in the color gradient of an inactive window's title bar if the gradient effect is enabled.
                                            ;Windows 10 or greater: This value is not supported.
        static COLOR_MENU := 4  ; Menu background. The associated foreground color is COLOR_MENUTEXT.Windows 10 or greater: This value is not supported.
        static COLOR_WINDOW := 5  ; Window background. The associated foreground colors are COLOR_WINDOWTEXT and COLOR_HOTLITE.
        static COLOR_WINDOWFRAME := 6  ; Window frame.Windows 10 or greater: This value is not supported.
        static COLOR_MENUTEXT := 7  ; Text in menus. The associated background color is COLOR_MENU.Windows 10 or greater: This value is not supported.
        static COLOR_WINDOWTEXT := 8 ; Text in windows. The associated background color is COLOR_WINDOW.
        static COLOR_CAPTIONTEXT := 9  ; Text in caption, size box, and scroll bar arrow box. The associated background color is COLOR_ACTIVECAPTION.Windows 10 or greater: This value is not supported.
        static COLOR_ACTIVEBORDER := 10  ; Active window border.Windows 10 or greater: This value is not supported.
        static COLOR_INACTIVEBORDER := 11  ; Inactive window border.Windows 10 or greater: This value is not supported.
        static COLOR_APPWORKSPACE := 12  ; Background color of multiple document interface (MDI) applications.Windows 10 or greater: This value is not supported.
        static COLOR_HIGHLIGHT := 13  ; Item(s) selected in a control. The associated foreground color is COLOR_HIGHLIGHTTEXT.
        static COLOR_HIGHLIGHTTEXT := 14  ; Text of item(s) selected in a control. The associated background color is COLOR_HIGHLIGHT.
        static COLOR_BTNFACE := 15  ; Face color for three-dimensional display elements and for dialog box backgrounds. The associated foreground color is COLOR_BTNTEXT.Windows 10 or greater: This value is not supported.
        static COLOR_3DFACE := 15  ; Face color for three-dimensional display elements and for dialog box backgrounds.
        static COLOR_BTNSHADOW := 16  ; Shadow color for three-dimensional display elements (for edges facing away from the light source).Windows 10 or greater: This value is not supported.
        static COLOR_3DSHADOW := 16  ; Shadow color for three-dimensional display elements (for edges facing away from the light source).Windows 10 or greater: This value is not supported.
        static COLOR_GRAYTEXT := 17  ; Grayed (disabled) text. This color is set to 0 if the current display driver does not support a solid gray color.
        static COLOR_BTNTEXT := 18  ; Text on push buttons. The associated background color is COLOR_BTNFACE.
        static COLOR_3DHIGHLIGHT := 20  ; Highlight color for three-dimensional display elements (for edges facing the light source.)Windows 10 or greater: This value is not supported.
        static COLOR_BTNHIGHLIGHT := 20  ; Highlight color for three-dimensional display elements (for edges facing the light source.)Windows 10 or greater: This value is not supported.
        static COLOR_BTNHILIGHT := 20  ; Highlight color for three-dimensional display elements (for edges facing the light source.)Windows 10 or greater: This value is not supported.
        static COLOR_INACTIVECAPTIONTEXT := 19  ; Color of text in an inactive caption. The associated background color is COLOR_INACTIVECAPTION.Windows 10 or greater: This value is not supported.
        static COLOR_3DHILIGHT := 20  ; Highlight color for three-dimensional display elements (for edges facing the light source.)Windows 10 or greater: This value is not supported.
        static COLOR_3DDKSHADOW := 21  ; Dark shadow for three-dimensional display elements.Windows 10 or greater: This value is not supported.
        static COLOR_3DLIGHT := 22  ; Light color for three-dimensional display elements (for edges facing the light source.)Windows 10 or greater: This value is not supported.
        static COLOR_INFOTEXT := 23  ; Text color for tooltip controls. The associated background color is COLOR_INFOBK.Windows 10 or greater: This value is not supported.
        static COLOR_INFOBK := 24  ; Background color for tooltip controls. The associated foreground color is COLOR_INFOTEXT.Windows 10 or greater: This value is not supported.
        static COLOR_HOTLIGHT := 26  ; Color for a hyperlink or hot-tracked item. The associated background color is COLOR_WINDOW.
        static COLOR_GRADIENTACTIVECAPTION := 27  ; Right side color in the color gradient of an active window's title bar. COLOR_ACTIVECAPTION specifies the left side color. Use SPI_GETGRADIENTCAPTIONS with the SystemParametersInfo function to determine whether the gradient effect is enabled.Windows 10 or greater: This value is not supported.
        static COLOR_GRADIENTINACTIVECAPTION := 28  ; Right side color in the color gradient of an inactive window's title bar. COLOR_INACTIVECAPTION specifies the left side color.Windows 10 or greater: This value is not supported.
        static COLOR_MENUHILIGHT := 29  ; The color used to highlight menu items when the menu appears as a flat menu (see SystemParametersInfo). The highlighted menu item is outlined with COLOR_HIGHLIGHT.Windows 2000, Windows 10 or greater:  This value is not supported.
        static COLOR_MENUBAR := 30  ; The background color for the menu bar when menus appear as flat menus (see SystemParametersInfo). However, COLOR_MENU continues to specify the background color of the menu popup.Windows 2000, Windows 10 or greater:  This value is not supported.
    ;
    GetColor(n){
	    Return  this.BGRtoRGB(DllCall("User32.dll\GetSysColor", "Int", n, "UInt"))
	}
    BGRtoRGB(BGR){
        return Format("0x{:06X}", (BGR & 255) << 16 | (BGR & 65280) | (BGR >> 16))
    }
    Invert(SX = 0x0011aa){
        lastformat:= A_FormatInteger
        SetFormat, Integer, Hex
        SX ^= 0xffffff
        SetFormat, Integer, % lastformat
        return SX
    }
    list(){
        for i,o in this 
            ((IsFunc(o)=0 and not i == "__Class")?info.=((IsFunc(o)=3) ? (" func: "): prop:=" property: ") i  (IsFunc(o)=0?" = "o:"") IsFunc(o) "`n":"")
        return info
    }
    demo(){
        Gui, -Caption +LastFound 
        Gui, Color, 0x808080
        Gui, Font, s6
        props:=[]
        for i,o in this
            ((i ~="^COLOR_")?(props.push(i)):)
        loop, % count:=props.count()
            Gui, Add, text, % "x" (((count/2) >= A_Index)?0:250) " y" (((count/2) >= A_Index)?0+((A_Index-1)*20):100+(((A_Index-count/2)-6)*20)) " c" (color:=this.GetColor(this[props[A_Index]]) ), % props[A_Index] "=" this[props[A_Index]] "=" color "`n"
        Gui, show, autosize
    }
}  
