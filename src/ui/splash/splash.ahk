Splash(text:="",time:=1000,onclickcmd:="",opacity=1){
    global
    (pToken?:(pToken:=Gdip_Startup()))
    Gui, Splash:New, -Caption +E0x80000 +LastFound +AlwaysOnTop +ToolWindow +OwnDialogs
    Gui, Splash:Default
    Gui, Show, NA
    OnMessage(0x201, onclickcmd?onclickcmd:"SplashClose")
    Gui, hide
    local hwnd1:= WinExist()
    local pBitmap := Gdip_CreateBitmapFromFile(splashimg:="splashrc2.png")
    if !pBitmap
        exit
    local Width := Gdip_GetImageWidth(pBitmap), Height := Gdip_GetImageHeight(pBitmap)
    local (canvasWidth:=Width//2) , (canvasHeight:=Height//2) , (canvasCenterX:=canvasWidth/2) , (canvasCenterY:=canvasHeight/2)
    local hbm := CreateDIBSection(canvasWidth, canvasHeight)
    local hdc := CreateCompatibleDC()
    local obm := SelectObject(hdc, hbm)
    local G := Gdip_GraphicsFromHDC(hdc)
    if (FileExist(exoFont:=(A_ScriptDir . "\exocetblizzardot-medium.otf"))){
        Font:=exoFont
    } else if !Gdip_FontFamilyCreate(Font){
        Outputdebug,  Font error!, The font you have specified does not exist on the system
        Exit
    } else {
        exoFont := "ExocetBlizzardMixedCapsOTMedium"
    }
    Gdip_SetInterpolationMode(G, 7)
    
    local scarlet:=ARGB(0x85,0x00,0x0F,ConvertD2H(opacity*255))
    local White:=ARGB(0xFF,0xFF,0xFF,ConvertD2H(opacity*255))
    local Black:=ARGB(0x00,0x00,0x00,ConvertD2H(opacity*255))

    local pBrush1 := Gdip_BrushCreateSolid(scarlet)
    local pBrush := Gdip_BrushCreateSolid(0xFF000000)
    if (text = ""){
        text:=version
    }
    local fontsize:=36
    textSize:=Gdip_SizeObj(Gdip_TextToGraphics(G,text, "x" (canvasCenterX/1.5) " y" (canvasHeight-38) " c00FFFFFF  s" fontsize, Font, Width, Height))
    ;opacity:=0.20
    Gdip_FillRoundedRectangle(G,pBrush1,(canvasCenterX-textSize.centeroffset), canvasHeight-textSize.height-2,textSize.width-5, textSize.height,7)
    Gdip_DrawImage(G, pBitmap, 0, 0, canvasWidth, canvasHeight, 0, 0, Width, Height, opacity)
    Gdip_TextToGraphics(G,text, "x" (canvasCenterX-textSize.centeroffset)-2 " y" (canvasHeight-38)-3 " c" Strip0x(Black) " s" fontsize, Font, Width, Height)
    Gdip_TextToGraphics(G,text, "x" (canvasCenterX-textSize.centeroffset) " y" (canvasHeight-38)-5 " c" Strip0x(White) " center s" fontsize, Font, Width, Height)
    UpdateLayeredWindow(hwnd1, hdc, (A_ScreenWidth/2)-(canvasWidth/2), (A_ScreenHeight/2)-(canvasHeight/2), canvasWidth, canvasHeight)
        Gui, Show, NA
    
    SelectObject(hdc, obm)
    DeleteObject(hbm)
    DeleteDC(hdc)
    Gdip_DeleteGraphics(G)
    Gdip_DisposeImage(pBitmap)
    if time !=0
    {
        OutputDebug, % time
        SetTimer, SplashClose, % time

    }
}
SplashClose(){
    Gui, Splash:Destroy
}