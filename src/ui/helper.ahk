
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

getMapDrawingArea() {
    WinGet, windowId, ID , %gameWindowId%
    VarSetCapacity(RECT, 16, 0)
    DllCall("user32\GetClientRect", Ptr,windowId, Ptr,&RECT)
    DllCall("user32\ClientToScreen", Ptr,windowId, Ptr,&RECT)
    Win_Client_X := NumGet(&RECT, 0, "Int")
    Win_Client_Y := NumGet(&RECT, 4, "Int")
    Win_Client_W := NumGet(&RECT, 8, "Int")
    Win_Client_H := NumGet(&RECT, 12, "Int")
    

    if (settings["mapPosition"] == "TOP_RIGHT") {
        if ((Win_Client_W / Win_Client_H) > 2) {  ; ultra wide
            Y := Win_Client_Y + (Win_Client_H / 28)
            X := Win_Client_X - (Win_Client_H / 7.85)
        } else {
            Y := Win_Client_Y + (Win_Client_H / 26)
            X := Win_Client_X
        }
        return { "X": X + (Win_Client_W * 0.6666), "Y": Y, "W": Win_Client_W / 3, "H": Win_Client_H / 3, "CenterX": Win_Client_W / 3 / 2, "CenterY": Win_Client_H / 3 / 2 }
    } else if (settings["mapPosition"] == "TOP_LEFT") {
        if ((Win_Client_W / Win_Client_H) > 2) {  ; ultra wide
            Y := Win_Client_Y + (Win_Client_H / 28)
            X := Win_Client_X + (Win_Client_H / 7.85)
        } else {
            Y := Win_Client_Y + (Win_Client_H / 22)
            X := Win_Client_X
        }
        return { "X": X, "Y": Y, "W": Win_Client_W / 3, "H": Win_Client_H / 3, "CenterX": Win_Client_W / 3 / 2, "CenterY": Win_Client_H / 3 / 2 }
    } else {
        return { "X": Win_Client_X, "Y": Win_Client_Y, "W": Win_Client_W, "H": Win_Client_H, "CenterX": Win_Client_W / 2, "CenterY": Win_Client_H / 2 }
    }
    
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



ConvertD2H(var=255){
    lastformat:=A_FormatInteger
    SetFormat, IntegerFast, hex
    var:=((Var += 0) += 0) ""
    SetFormat, IntegerFast, % lastformat  
    return var
}

Strip0x(covered){
    return RegExReplace(covered, "0x(.*)","$1")
}

ARGB(R, G, B, A=00){
    lastformat:=A_FormatInteger
	SetFormat, Integer, Hex
    ARGB:=(A << 24) | (R << 16) | (G << 8) | B
    setformat, integer, % lastformat
	Return ARGB
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

Color300(N){ 					; Function borrowed from Wicked (http://www.autohotkey.com/forum/viewtopic.php?t=57368&postdays=0&postorder=asc&start=0)
   SetFormat, Integer, Hex 
   N += 0 
   SetFormat, Integer, D 
   StringTrimLeft, N, N, 2 
   If (StrLen(N) < 2) 
      N = 0%N%
   Return N 
}

Gdip_SizeObj(array,offsetratio=4){
    TextSA:=StrSplit(array, "|")
    x:=TextSA.1
    y:=TextSA.2
    width:=TextSA.3
    height:=TextSA.4
    chars:=TextSA.5
    lines:=TextSA.6
    center:=TextSA.3/2
    charwidth:=width/chars
    centeroffset:=((co:=((charwidth/offsetratio) * chars))?co:0)
    obj:= {"x":x,"y":y,"width":width,"height":height,"chars":chars,"lines":lines,"center":center,"charwidth":charwidth,"centeroffset":centeroffset}
    return obj
}
