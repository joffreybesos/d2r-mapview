

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
    distance := getDistanceFromCoords(xPosDot, yPosDot, centerX, centerY) * scale
    newPos := getPosFromAngle((RWidth/2),(RHeight/2),distance,newAngle)
    newPos["y"] := (RHeight/2) + ((RHeight/2) - newPos["y"]) /2
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

isWindowFullScreen(WinID)
{
    ;checks if the specified window is full screen
    ;use WinExist of another means to get the Unique ID (HWND) of the desired window

    if ( !WinID )
        return false

	WinGet style, Style, ahk_id %WinID%
	WinGetPos ,,,winW,winH, %WinID%
	; 0x800000 is WS_BORDER.
	; 0x20000000 is WS_MINIMIZE.
	; no border and not minimized
	Return ((style & 0x20800000) or winH < A_ScreenHeight or winW < A_ScreenWidth) ? false : true
}

getWindowClientArea() {
    WinGet, windowId, ID , %gameWindowId%
    VarSetCapacity(RECT, 16, 0)
    DllCall("user32\GetClientRect", Ptr,windowId, Ptr,&RECT)
    DllCall("user32\ClientToScreen", Ptr,windowId, Ptr,&RECT)
    Win_Client_X := NumGet(&RECT, 0, "Int")
    Win_Client_Y := NumGet(&RECT, 4, "Int")
    Win_Client_W := NumGet(&RECT, 8, "Int")
    Win_Client_H := NumGet(&RECT, 12, "Int")
    return { "X": Win_Client_X, "Y": Win_Client_Y, "W": Win_Client_W, "H": Win_Client_H }
}


b64Encode(string)
{
    VarSetCapacity(bin, StrPut(string, "UTF-8")) && len := StrPut(string, &bin, "UTF-8") - 1 
    if !(DllCall("crypt32\CryptBinaryToString", "ptr", &bin, "uint", len, "uint", 0x1, "ptr", 0, "uint*", size))
        throw Exception("CryptBinaryToString failed", -1)
    VarSetCapacity(buf, size << 1, 0)
    if !(DllCall("crypt32\CryptBinaryToString", "ptr", &bin, "uint", len, "uint", 0x1, "ptr", &buf, "uint*", size))
        throw Exception("CryptBinaryToString failed", -1)
    return StrGet(&buf)
}

b64Decode(string)
{
    if !(DllCall("crypt32\CryptStringToBinary", "ptr", &string, "uint", 0, "uint", 0x1, "ptr", 0, "uint*", size, "ptr", 0, "ptr", 0))
        throw Exception("CryptStringToBinary failed", -1)
    VarSetCapacity(buf, size, 0)
    if !(DllCall("crypt32\CryptStringToBinary", "ptr", &string, "uint", 0, "uint", 0x1, "ptr", &buf, "uint*", size, "ptr", 0, "ptr", 0))
        throw Exception("CryptStringToBinary failed", -1)
    return StrGet(&buf, size, "UTF-8")
}