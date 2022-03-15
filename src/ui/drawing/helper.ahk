

drawLineWithArrow(ByRef unitsLayer, ByRef xPosDot, ByRef yPosDot, ByRef targetX, ByRef targetY, ByRef scale, ByRef pen, ByRef brush) {
    newCoords := calculateFixedLength(xPosDot, yPosDot, targetX, targetY, (40 * scale))
    if (newCoords["x"]) {
        if (newCoords["lineLength"] > (80 * scale)) {
            arrowsize := 12 * scale
            , arrowTip := calculateFixedLength(targetX, targetY, xPosDot, yPosDot, (20 * scale))
            ;, arrowTip := calculatePercentage(xPosDot, yPosDot, targetX, targetY, 0.8)
            , arrowleft := calcThirdPoint(arrowTip["x"], arrowTip["y"], targetX, targetY, 60, arrowsize) 
            , arrowright := calcThirdPoint(arrowTip["x"], arrowTip["y"], targetX, targetY, 120, arrowsize) 
            , arrowBase := calculatePercentage(arrowleft["x"], arrowleft["y"], arrowright["x"], arrowright["y"], 0.5)
            , arrowPoints := arrowTip["x"] "," arrowTip["y"] "|"  arrowleft["x"] "," arrowleft["y"] "|" arrowright["x"] "," arrowright["y"]
            Gdip_FillPolygon(unitsLayer.G, brush, arrowPoints)
            Gdip_DrawLine(unitsLayer.G, pen, newCoords["x"], newCoords["y"], arrowBase["x"], arrowBase["y"])
            ;Gdip_DrawLine(unitsLayer.G, unitsLayer.pLineExit, arrowTip["x"], arrowTip["y"], targetX, targetY)
        }
    }
}

calculateFixedLength(ByRef x1,ByRef y1,ByRef x2,ByRef y2, ByRef linegap)
{
    lineLength := Sqrt((Abs(x1 - x2) ** 2) + (Abs(y1 - y2) ** 2))
    newPc := 1 - ((lineLength - linegap) / lineLength)
    ;WriteLog(lineLength " " newPc)
    if (x1 > x2) {
        newx1 := x1 - ((x1 - x2) * newPc)
    } else {
        newx1 := x1 + ((x2 - x1) * newPc)
    }

    if (y1 > y2) {
        newy1 := y1 - ((y1 - y2) * newPc)
    } else {
        newy1 := y1 + ((y2 - y1) * newPc)
    }

    return {"x": newx1, "y": newy1, "lineLength": lineLength }
}

calculatePercentage(ByRef x1,ByRef y1,ByRef x2,ByRef y2, ByRef percentage)
{
    ;newPc := (ticktock * percentage) / 100
    if (x1 > x2) {
        newx1 := x1 - ((x1 - x2) * percentage)
    } else {
        newx1 := x1 + ((x2 - x1) * percentage)
    }

    if (y1 > y2) {
        newy1 := y1 - ((y1 - y2) * percentage)
    } else {
        newy1 := y1 + ((y2 - y1) * percentage)
    }
    return {"x": newx1, "y": newy1 }
} 

calcThirdPoint(x1,y1,x2,y2, ByRef angle, ByRef distance) {
    y1 := y1 * 2
    , y2 := y2 * 2
    , Angle2 := findAngle(x1, y1, x2, y2)
    , newAngle := angle - Angle2
    , newPos := getPosFromAngle(x1,y1,distance,newAngle)
    , newPos["y"] := newPos["y"] / 2
    return newPos
}



drawFloatingText(ByRef unitsLayer, ByRef unitx, ByRef unity, ByRef fontSize, ByRef fontColor, ByRef background, ByRef font, ByRef text) {
    
    textSpaceWidth := StrLen(text) * fontSize
    , textSpaceHeight := 100
    , textx := unitx - textSpaceWidth /2
    , texty := unity-(unitsLayer.normalDotSize/2) - textSpaceHeight
    Options = x%textx% y%texty% Center vBottom c%fontColor% r8 s%fontSize%
    textx := textx + 1
    , texty := texty + 1
    Options2 = x%textx% y%texty% Center vBottom cff000000 r8 s%fontSize%
    

    if (background) {        
        ;x|y|width|height|chars|lines
        measuredString := Gdip_TextToGraphics(unitsLayer.G, text, Options2, font, textSpaceWidth, textSpaceHeight)
        , ms := StrSplit(measuredString , "|")
        , bgx := ms[1] - 5
        , bgy := ms[2] - 2
        , bgw := ms[3] + 8
        , bgh := ms[4] + 0
        Gdip_FillRectangle(unitsLayer.G, unitsLayer.pBrushNonHealth, bgx, bgy, bgw, bgh)
    } else {
        Gdip_TextToGraphics(unitsLayer.G, text, Options2, font, textSpaceWidth, textSpaceHeight)
    }
    Gdip_TextToGraphics(unitsLayer.G, text, Options,  font, textSpaceWidth, textSpaceHeight)
}

drawSuperChest(ByRef unitsLayer, ByRef objectx, ByRef objecty, ByRef chestscale) {
    
    chestxoffset := objectx - 10
    , chestyoffset := objecty - 10
    , x1 := 10 * chestscale + chestxoffset
    , y1 := 19 * chestscale + chestyoffset
    , x2 := 40 * chestscale + chestxoffset
    , y2 := 12 * chestscale + chestyoffset
    , x3 := 50 * chestscale + chestxoffset
    , y3 := 28 * chestscale + chestyoffset
    , x4 := 19 * chestscale + chestxoffset
    , y4 := 34 * chestscale + chestyoffset
    , x5 := 4 * chestscale + chestxoffset
    , y5 := 25 * chestscale + chestyoffset
    , x6 := 35 * chestscale + chestxoffset
    , x7 := 17 * chestscale + chestxoffset
    , y7 := 32 * chestscale + chestyoffset
    , x8 := 4 * chestscale + chestxoffset
    , y8 := 18 * chestscale + chestyoffset
    , x9 := 16 * chestscale + chestxoffset
    , y9 := 35 * chestscale + chestyoffset
    , x10:= 15 * chestscale + chestxoffset
    , y11:= 13 * chestscale + chestyoffset
    , y12:= 30 * chestscale + chestyoffset
    , y13:= 31 * chestscale + chestyoffset
    , y15:= 24 * chestscale + chestyoffset
    , y16:= 40 * chestscale + chestyoffset
    , y17:= 49 * chestscale + chestyoffset
    , y18:= 38 * chestscale + chestyoffset
    , y19:= 21 * chestscale + chestyoffset
    , piewidth := 15 * chestscale
    , pieheight := 30 * chestscale
    backpoints = %x1%,%y1%|%x2%,%y2%|%x3%,%y3%|%x4%,%y4%|%x5%,%y5%|%x1%,%y19%

    Gdip_DrawPie(unitsLayer.G, unitsLayer.pPenSuperChest, x6, y2, piewidth, pieheight, 180, 180)
    Gdip_FillPolygon(unitsLayer.G, unitsLayer.pBrushSuperChest, backpoints)
    Gdip_FillPie(unitsLayer.G, unitsLayer.pBrushSuperChest, x8, y8, piewidth, pieheight, 180, 180) ;15,30
    Gdip_FillPie(unitsLayer.G, unitsLayer.pBrushSuperChest, x6, y11, piewidth, pieheight, 180, 180) ;17,31
    points = %x5%,%y15%|%x5%,%y16%|%x4%,%y17%|%x4%,%y4%|%x4%,%y17%|%x3%,%y18%|%x3%,%y15%|%x4%,%y4%|%x5%,%y5%
    Gdip_DrawPie(unitsLayer.G, unitsLayer.pPenSuperChest, x8, y8, piewidth, pieheight, 180, 180)
    Gdip_FillPolygon(unitsLayer.G, unitsLayer.pBrushSuperChest, points)
    Gdip_DrawPolygon(unitsLayer.G, unitsLayer.pPenSuperChest, Points)
    Gdip_DrawLine(unitsLayer.G, unitsLayer.pPenSuperChest, x1, y1, x2, y2)
    
}


drawChest(ByRef unitsLayer, ByRef objectx, ByRef objecty, ByRef chestscale, ByRef state) {
    if (state == "trap") {
        pBrush := Gdip_BrushCreateSolid(0xccff0000)
    } else if (state == "locked") {
        pBrush := Gdip_BrushCreateSolid(0xccffff00)
    } else {
        pBrush := Gdip_BrushCreateSolid(0xcc542a00)
    }
    chestxoffset := objectx - 10
    , chestyoffset := objecty - 10
    , x1 := 10 * chestscale + chestxoffset
    , y1 := 19 * chestscale + chestyoffset
    , x2 := 40 * chestscale + chestxoffset
    , y2 := 12 * chestscale + chestyoffset
    , x3 := 50 * chestscale + chestxoffset
    , y3 := 28 * chestscale + chestyoffset
    , x4 := 19 * chestscale + chestxoffset
    , y4 := 34 * chestscale + chestyoffset
    , x5 := 4 * chestscale + chestxoffset
    , y5 := 25 * chestscale + chestyoffset
    , x6 := 35 * chestscale + chestxoffset
    , x7 := 17 * chestscale + chestxoffset
    , y7 := 32 * chestscale + chestyoffset
    , x8 := 4 * chestscale + chestxoffset
    , y8 := 18 * chestscale + chestyoffset
    , x9 := 16 * chestscale + chestxoffset
    , y9 := 35 * chestscale + chestyoffset
    , x10:= 15 * chestscale + chestxoffset
    , y11:= 13 * chestscale + chestyoffset
    , y12:= 30 * chestscale + chestyoffset
    , y13:= 31 * chestscale + chestyoffset
    , y15:= 24 * chestscale + chestyoffset
    , y16:= 40 * chestscale + chestyoffset
    , y17:= 49 * chestscale + chestyoffset
    , y18:= 38 * chestscale + chestyoffset
    , y19:= 21 * chestscale + chestyoffset
    , piewidth := 15 * chestscale
    , pieheight := 30 * chestscale
    backpoints = %x1%,%y1%|%x2%,%y2%|%x3%,%y3%|%x4%,%y4%|%x5%,%y5%|%x1%,%y19%

    Gdip_DrawPie(unitsLayer.G, unitsLayer.pChest, x6, y2, piewidth, pieheight, 180, 180)
    Gdip_FillPolygon(unitsLayer.G, pBrush, backpoints)
    Gdip_FillPie(unitsLayer.G, pBrush, x8, y8, piewidth, pieheight, 180, 180) ;15,30
    Gdip_FillPie(unitsLayer.G, pBrush, x6, y11, piewidth, pieheight, 180, 180) ;17,31
    points = %x5%,%y15%|%x5%,%y16%|%x4%,%y17%|%x4%,%y4%|%x4%,%y17%|%x3%,%y18%|%x3%,%y15%|%x4%,%y4%|%x5%,%y5%
    Gdip_DrawPie(unitsLayer.G, unitsLayer.pChest, x8, y8, piewidth, pieheight, 180, 180)
    Gdip_FillPolygon(unitsLayer.G, pBrush, points)
    Gdip_DrawPolygon(unitsLayer.G, unitsLayer.pChest, Points)
    Gdip_DrawLine(unitsLayer.G, unitsLayer.pChest, x1, y1, x2, y2)
    Gdip_DeleteBrush(pBrush)
}


correctPos(settings, xPosDot, yPosDot, centerX, centerY, RWidth, RHeight, scale) {
    correctedPos := findNewPos(xPosDot, yPosDot, centerX, centerY, RWidth, RHeight, scale)
    if (settings["centerMode"]) {
        correctedPos["x"] := correctedPos["x"] + settings["centerModeXUnitoffset"]
        correctedPos["y"] := correctedPos["y"] + settings["centerModeYUnitoffset"]
    }
    return correctedPos
}

; converting to cartesian to polar and back again sucks
; I wish my matrix transformations worked
findNewPos(xPosDot, yPosDot, centerX, centerY, RWidth, RHeight, scale) {
    newAngle := findAngle(xPosDot, yPosDot, centerX, centerY) + 45
    , distance := getDistanceFromCoords(xPosDot, yPosDot, centerX, centerY) * scale
    , newPos := getPosFromAngle((RWidth/2),(RHeight/2),distance,newAngle)
    , newPos["y"] := (RHeight/2) + ((RHeight/2) - newPos["y"]) /2
    return newPos
}


findAngle(xPosDot, yPosDot, midW, midH) {
    Pi := 4 * ATan(1)
    , Conversion := -180 / Pi  ; Radians to deg.
    , Angle2 := DllCall("msvcrt.dll\atan2", "Double", yPosDot-midH, "Double", xPosDot-midW, "CDECL Double") * Conversion
    if (Angle2 < 0)
        Angle2 += 360
    return Angle2
}

getDistanceFromCoords(x2,y2,x1,y1){
    return sqrt((y2-y1)**2+(x2-x1)**2)
}

getPosFromAngle(x1,y1,len,ang){
	ang:=(ang-90) * 0.0174532925
	return {"x": x1+len*cos(ang),"y": y1+len*sin(ang)}
}


hasVal(haystack, needle) {
	for index, value in haystack
		if (value == needle)
			return index
	return 0
}


createCross(ByRef playerCrossXoffset, ByRef playerCrossYoffset, ByRef scale) {
    xscale := scale
    , yscale := scale / 2
    , x1 := playerCrossXoffset - xscale - xscale
    , x2 := playerCrossXoffset - xscale
    , x3 := playerCrossXoffset
    , x4 := playerCrossXoffset + xscale
    , x5 := playerCrossXoffset + xscale + xscale
    , y1 := playerCrossYoffset - yscale - yscale
    , y2 := playerCrossYoffset - yscale
    , y3 := playerCrossYoffset
    , y4 := playerCrossYoffset + yscale
    , y5 := playerCrossYoffset + yscale + yscale
    points = %x1%,%y2%|%x2%,%y3%|%x1%,%y4%|%x2%,%y5%|%x3%,%y4%|%x4%,%y5%|%x5%,%y4%|%x4%,%y3%|%x5%,%y2%|%x4%,%y1%|%x3%,%y2%|%x2%,%y1%
    return points
}