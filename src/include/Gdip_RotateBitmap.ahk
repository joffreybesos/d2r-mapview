#SingleInstance, Force
SendMode Input
SetWorkingDir, %A_ScriptDir%
;===Functions===========================================================================
#Include %A_WorkingDir%\include\Gdip_All.ahk

 ; by Tic www.autohotkey.com/community/viewtopic.php?f=2&t=32238

Gdip_RotateBitmap(pBitmap, Angle, Dispose=1) { ; returns rotated bitmap. By Learning one.
    Gdip_GetImageDimensions(pBitmap, Width, Height)
    Gdip_GetRotatedDimensions(Width, Height, Angle, RWidth, RHeight)
    Gdip_GetRotatedTranslation(Width, Height, Angle, xTranslation, yTranslation)

    pBitmap2 := Gdip_CreateBitmap(RWidth, RHeight)
    G2 := Gdip_GraphicsFromImage(pBitmap2), Gdip_SetSmoothingMode(G2, 4), Gdip_SetInterpolationMode(G2, 7)
    Gdip_TranslateWorldTransform(G2, xTranslation, yTranslation)
    Gdip_RotateWorldTransform(G2, Angle)
    Gdip_DrawImage(G2, pBitmap, 0, 0, Width, Height)

    Gdip_ResetWorldTransform(G2)
    Gdip_DeleteGraphics(G2)
    if Dispose
    Gdip_DisposeImage(pBitmap)
    return pBitmap2
    } ; http://www.autohotkey.com/community/viewtopic.php?p=477333#p477333
    /*
    ;Examples:
    pRotatedBitmap := Gdip_RotateBitmap(pBitmap, 45) ; rotates bitmap for 45 degrees. Disposes of pBitmap.
    pRotatedBitmap := Gdip_RotateBitmap(pBitmap, 77) ; rotates bitmap for 77 degrees. Disposes of pBitmap.
    pRotatedBitmap := Gdip_RotateBitmap(pBitmap, -22, 0) ; rotates bitmap for -22 degrees. Does not dispose of pBitmap.
    */

    SetBitmap2Pic(pBitmap,ControlID,GuiNum=1) { ; sets pBitmap to picture control (which must have 0xE option and should have BackgroundTrans option). By Learning one.
    GuiControlGet, hControl, %GuiNum%:hwnd, %ControlID%
    hBitmap := Gdip_CreateHBITMAPFromBitmap(pBitmap), SetImage(hControl, hBitmap), DeleteObject(hBitmap) 
    GuiControl, %GuiNum%:MoveDraw, %ControlID% ; repaints the region of the GUI window occupied by the control
}