Splash(){
    global
    (pToken?:(pToken:=Gdip_Startup()))
    Gui, Splash:New, -Caption +E0x80000 +LastFound +AlwaysOnTop +ToolWindow +OwnDialogs
    Gui, Splash:Default
    Gui, Show, NA
    OnMessage(0x201, "StartSettings")
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
    scarlet:=0xFF85000F
    White:=0xFFFFFFFF
    Black:=0xFF000000
    pBrush1 := Gdip_BrushCreateSolid(scarlet)
    pBrush := Gdip_BrushCreateSolid(0xFF000000)
    VersionSize:=Gdip_SizeObj(Gdip_TextToGraphics(G,version, "x" (canvasCenterX/1.5) " y" (canvasHeight-38) " c00FFFFFF  s" 36, Font, Width, Height))
    
    Gdip_FillRoundedRectangle(G,pBrush1,(canvasCenterX-VersionSize.centeroffset), canvasHeight-VersionSize.height-2,VersionSize.width-5, VersionSize.height,7)
    Gdip_TextToGraphics(G,version, "x" (canvasCenterX-VersionSize.centeroffset)-2 " y" (canvasHeight-38)-3 " c" Strip0x(Black) " s" 36, Font, Width, Height)
    Gdip_TextToGraphics(G,version, "x" (canvasCenterX-VersionSize.centeroffset) " y" (canvasHeight-38)-5 " c" Strip0x(White) " center s" 36, Font, Width, Height)
    Gdip_DrawImage(G, pBitmap, 0, 0, canvasWidth, canvasHeight, 0, 0, Width, Height)
    UpdateLayeredWindow(hwnd1, hdc, (A_ScreenWidth/2)-(canvasWidth/2), (A_ScreenHeight/2)-(canvasHeight/2), canvasWidth, canvasHeight)
        Gui, Show, NA
    
    SelectObject(hdc, obm)
    DeleteObject(hbm)
    DeleteDC(hdc)
    Gdip_DeleteGraphics(G)
    Gdip_DisposeImage(pBitmap)
    SetTimer, SplashClose, -2000
}
SplashClose(){
    Gui, Splash:Destroy
}