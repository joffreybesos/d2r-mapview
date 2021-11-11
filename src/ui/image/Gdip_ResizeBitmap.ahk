#Include %A_ScriptDir%\include\Gdip_All.ahk

Gdip_ResizeBitmap(pBitmap, PercentOrWH, Dispose=1) { ; returns resized bitmap. By Learning one.
    Gdip_GetImageDimensions(pBitmap, origW, origH)
    if PercentOrWH contains w,h
    {
        RegExMatch(PercentOrWH, "i)w(\d*)", w), RegExMatch(PercentOrWH, "i)h(\d*)", h)
        NewWidth := w1, NewHeight := h1
        NewWidth := (NewWidth = "") ? origW/(origH/NewHeight) : NewWidth
        NewHeight := (NewHeight = "") ? origH/(origW/NewWidth) : NewHeight
    }
    else {
        NewWidth := origW*PercentOrWH/100, NewHeight := origH*PercentOrWH/100
    }
    pBitmap2 := Gdip_CreateBitmap(NewWidth, NewHeight)
    G2 := Gdip_GraphicsFromImage(pBitmap2), Gdip_SetSmoothingMode(G2, 4), Gdip_SetInterpolationMode(G2, 7)
    Gdip_DrawImage(G2, pBitmap, 0, 0, NewWidth, NewHeight)
    Gdip_DeleteGraphics(G2)
    if Dispose
    Gdip_DisposeImage(pBitmap)
    return pBitmap2
} ; http://www.autohotkey.com/community/viewtopic.php?p=477333#p477333


Gdip_SquashBitmap(pBitmap, PercentOrWH, Dispose=1) { ; returns resized bitmap. By Learning one.
    Gdip_GetImageDimensions(pBitmap, origW, origH)
    if PercentOrWH contains w,h
    {
        RegExMatch(PercentOrWH, "i)w(\d*)", w), RegExMatch(PercentOrWH, "i)h(\d*)", h)
        NewWidth := w1, NewHeight := h1
        NewWidth := (NewWidth = "") ? origW/(origH/NewHeight) : NewWidth
        NewHeight := (NewHeight = "") ? origH/(origW/NewWidth) : NewHeight
    }
    else {
        NewWidth := origW*PercentOrWH/100, NewHeight := origH*PercentOrWH/100
    }
    pBitmap2 := Gdip_CreateBitmap(NewWidth, NewHeight)
    G2 := Gdip_GraphicsFromImage(pBitmap2), Gdip_SetSmoothingMode(G2, 4), Gdip_SetInterpolationMode(G2, 7)
    Gdip_DrawImage(G2, pBitmap, 0, 0, NewWidth, NewHeight)
    Gdip_DeleteGraphics(G2)
    if Dispose
    Gdip_DisposeImage(pBitmap)
    return pBitmap2
} ; http://www.autohotkey.com/community/viewtopic.php?p=477333#p477333
