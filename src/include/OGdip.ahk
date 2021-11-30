; OGdip v3.0.3
; Written by @mcl
; Many thanks to all members of AHK community, especially:
; @GeekDude, @iseahound, @justme, @mikeyww, @neogna2, @robodesign, @Rseding91, @SKAN, @tic,
; and, of course, @lexicos.


; OGdip class
; ===========
; 
; Main class, wrapper and container for all other classes and functions.
; Class hierarchy:
; 
;   OGdip
;   - Enum
;   - Image
;     • Bitmap
;     • Metafile
;     - CachedBitmap
;     - Effect
;       • <Effect sub-classes>
;   - ImageAttributes
;   - Font
;   - FontFamily
;   - StringFormat
;   - Graphics
;   - Pen
;     - CustomCap
;     - ArrowCap
;   - Brush
;     • SolidBrush
;     • HatchBrush
;     • TextureBrush
;     • LinearBrush
;     • PathBrush
;   - Region
;   - Matrix
; 
; Methods:
;   .Startup()
;   .Shutdown()
; 
; Service functions:
;   ._GuidToString( ptrGuid )
;   ._StringToGuid( strGuid, &ptrGuid )
;   ._MemToStream( &varBuffer, dataSize )
;   ._StreamToMem( streamPtr, &varBuffer [, releaseStream] )
;   ._FileToStream( filename [, access] )
;   ._Base64ToBinary( &strBase64, &varBuffer)
;   ._BinaryToBase64( dataPtr, dataSize [, &strBase64] )
; 
; Color functions:
;   .RGB( R, G, B [, A] )
;   .HSL( H, S, L [, A] )
;   .ToHSL( argb )
;   .MixRGB( argb1, argb2 )
;   .BGRtoRGB( abgr )
;   .GetColor( key )
; 
; Other functions:
;   .ChooseColor( [initColor] )
;   .ChooseFont( [initFont] )
;   .GetInstalledFontFamilies()
;   .Screenshot( [source, args*] )


Class OGdip {
	Static autoGraphics := True  ; Automatically init Graphics when Image/Bitmap is created.
	
	Static token     := 0
	Static dllHandle := 0
	
	
	; Loads and initializes GDI+ library.
	; This function is required to be called first.
	
	Startup() {
		Local
		
		If (this.token != 0)
			Return
		
		If (this.dllHandle == 0)
			this.dllHandle := DllCall("LoadLibrary", "Str", "GdiPlus.dll", "Ptr")
		
		pToken := 0
		
		VarSetCapacity(structInput, 16, 0)  ; GdiplusStartupInput
		NumPut(1, structInput, 0, "UInt")   ; .GdiplusVersion = 1
		
		DllCall("GdiPlus\GdiplusStartup"
		, "UInt*",  pToken
		, "Ptr"  , &structInput
		, "Ptr"  ,  0)
		
		this.token := pToken
	}
	
	
	Shutdown() {
		If (this.token != 0) {
			DllCall("GdiPlus\GdiplusShutdown", "UInt*", this.token)
			this.token := 0
		}
		
		If (this.dllHandle != 0) {
			DllCall("FreeLibrary", "Ptr", this.dllHandle)
			this.dllHandle := 0
		}
	}
	
	
	; Service functions
	; =================
	;   ._GuidToString( ptrGuid )
	;   ._StringToGuid( strGuid, &ptrGuid )
	;   
	;   ._MemToStream( &varBuffer, dataSize )
	;   ._StreamToMem( streamPtr, &varBuffer [, releaseStream] )
	;   ._FileToStream( filename [, access] )
	;   
	;   ._Base64ToBinary( &strBase64, &varBuffer)
	;   ._BinaryToBase64( dataPtr, dataSize [, &strBase64] )
	
	
	; Converts 16-bytes binary GUID to a GUID-string.
	; Returns string in "{xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx}" format.
	
	_GuidToString( ptrGuid ) {
		Local
		; 80 = (38 chars + null-terminator + aesthetic byte) * 2 bytes per WChar
		VarSetCapacity(strGuid, 80, 0)
		
		DllCall("ole32\StringFromGUID2"
		, "Ptr",  ptrGuid
		, "Ptr", &strGuid
		, "Int",  40)      ; Size of buffer in WChars
		
		Return StrGet(&strGuid, "UTF-16")
	}
	
	
	; Converts GUID-string to 16-bytes binary GUID.
	; Argument 'ptrGuid' can be either a variable or a pointer to write into.
	
	_StringToGuid( strGuid, ByRef ptrGuid ) {
		If (IsByRef(ptrGuid))
			VarSetCapacity(ptrGuid, 16, 0)
		
		DllCall("ole32\CLSIDFromString"
		, "WStr",  strGuid
		, "Ptr" , (IsByRef(ptrGuid)  ?  &ptrGuid  :  ptrGuid))
	}
	
	
	; Copies data from variable or memory to new IStream.
	; Argument 'varBuffer' can be either a variable or a pointer to read from.
	; If 'dataSize' argument is zero, creates empty IStream ('varBuffer' is ignored).
	; Returns pointer to created IStream.
	
	_MemToStream( ByRef varBuffer, dataSize ) {
		Local streamPtr  := 0
		Local hGlobalPtr := 0
		
		If (dataSize > 0) {
			hGlobalPtr := DllCall("GlobalAlloc"
			, "UInt", 0x02      ; 0x02: uFlags = GMEM_MOVABLE
			, "UPtr", dataSize
			, "Ptr")
			
			Local lockedDataPtr := DllCall("kernel32\GlobalLock", "Ptr", hGlobalPtr, "Ptr")
			
			DllCall("kernel32\RtlMoveMemory"
			, "Ptr" ,  lockedDataPtr
			, "Ptr" , (IsByRef(varBuffer)  ?  &varBuffer  :  varBuffer)
			, "UPtr",  dataSize)
			
			DllCall("kernel32\GlobalUnlock", "Ptr", hGlobalPtr)
		}
		
		DllCall("ole32\CreateStreamOnHGlobal"
		, "Ptr" , hGlobalPtr
		, "Int" , True
		, "Ptr*", streamPtr)
		
		Return streamPtr
	}
	
	
	; Copies data from IStream to variable. Optionally releases IStream.
	; Argument 'varBuffer' must be a variable to write to.
	; Returns size of written data.
	
	_StreamToMem( streamPtr, ByRef varBuffer, releaseStream := True ) {
		Local
		
		hGlobalPtr := 0
		
		DllCall("ole32\GetHGlobalFromStream"
		, "Ptr" , streamPtr
		, "Ptr*", hGlobalPtr)
		
		If (hGlobalPtr == 0)
			Return 0
		
		dataSize   := DllCall("kernel32\GlobalSize", "Ptr", hGlobalPtr, "UPtr")
		hLockedPtr := DllCall("kernel32\GlobalLock", "Ptr", hGlobalPtr, "Ptr")
		
		VarSetCapacity(varBuffer, dataSize, 0)
		
		DllCall("kernel32\RtlMoveMemory"
		, "Ptr" , &varBuffer
		, "Ptr" ,  hLockedPtr
		, "UPtr",  dataSize)
		
		DllCall("kernel32\GlobalUnlock", "Ptr", hGlobalPtr)
		
		If (releaseStream == True) {
			ObjRelease(streamPtr)
			DllCall("kernel32\GlobalFree", "Ptr", hGlobalPtr)
		}
		
		Return dataSize
	}
	
	
	; Creates stream from file.
	; Returns pointer to created IStream.
	
	_FileToStream( filename, access := "rw" ) {
		Local
		access := (0
		|  ((access ~= "[rR]")  ?  0x80000000  :  0)
		|  ((access ~= "[wW]")  ?  0x40000000  :  0) )
		
		DllCall("GdiPlus\GdipCreateStreamOnFile"
		, "WStr", filename
		, "UInt", access
		, "Ptr*", streamPtr)
		
		Return streamPtr
	}
	
	
	; Converts binary data to Base64-string.
	; Omit argument 'strBase64' to get Base64-string as a return value.
	
	_BinaryToBase64( dataPtr, dataSize, ByRef strBase64 := "" ) {
		Local
		
		If !(DllCall("crypt32\CryptBinaryToString"
		, "Ptr"  , dataPtr         ; Pointer to the binary data to be converted
		, "UInt" , dataSize        ; Size of the binary data
		, "UInt" , 0x40000001      ; dwFlags = CRYPT_STRING_NOCRLF | CRYPT_STRING_BASE64
		, "Ptr"  , 0               ; String buffer to write
		, "UInt*", strSize := 0))  ; Size of resulting string buffer in TChars
			Return -1
		
		VarSetCapacity(strBase64, strSize * (A_IsUnicode ? 2 : 1), 0)
		
		If !(DllCall("crypt32\CryptBinaryToString"
		, "Ptr"  , dataPtr
		, "UInt" , dataSize
		, "UInt" , 0x40000001
		, "Str"  , strBase64
		, "UInt*", strSize))
			Return -2
		
		If (IsByRef(strBase64) == False)
			Return strBase64
	}
	
	
	; Converts Base64-string to binary buffer.
	; Returns size of binary data on success.
	
	_Base64ToBinary( ByRef strBase64, ByRef varBuffer ) {
		Local
		
		If (IsByRef(varBuffer) == False)
			Return 0
		
		; Determine the size of binary data
		If !(DllCall("crypt32\CryptStringToBinary"
		, "Str"  , strBase64      ; String to be converted
		, "UInt" , 0              ; String length if not zero-terminated
		, "UInt" , 0x01           ; String format: CRYPT_STRING_BASE64
		, "Ptr"  , 0              ; Buffer to receive data (NULL to calculate size)
		, "UInt*", dataSize := 0  ; Size of the buffer
		, "Ptr"  , 0              ; Int* to get number of skipped chars (optional)
		, "Ptr"  , 0))            ; Int* to get actual format used (optional)
			Return -1
		
		VarSetCapacity(varBuffer, dataSize, 0)
		
		; Decode string to binary data
		If !(DllCall("crypt32\CryptStringToBinary"
		, "Str"  , strBase64
		, "UInt" , 0
		, "UInt" , 0x01
		, "Ptr"  , &varBuffer
		, "UInt*", dataSize
		, "Ptr"  , 0
		, "Ptr"  , 0))
			Return -2
		
		Return dataSize
	}
	
	
	; Creates binary array from given array with given datatype and offset.
	; Used widely across the script to pass data to DllCalls.
	
	_CreateBinArray( srcArray, ByRef binArray, elemType := "UInt", offset := 0 ) {
		Local
		
		Static elemSizes := { "Int64" : 8
		, "Char"  : 1   , "UChar"  : 1
		, "Short" : 2   , "UShort" : 2
		, "Int"   : 4   , "UInt"   : 4
		, "Float" : 4   , "Double" : 8
		, "Ptr"   : A_PtrSize
		, "UPtr"  : A_PtrSize }
		
		If (elemSizes.HasKey(elemType)) {
			elemSize := elemSizes[elemType]
		} Else {
			elemType := "UInt"
			elemSize := 4
		}
		
		VarSetCapacity(binArray, (offset + srcArray.Length()*elemSize), 0)
		elemPos := offset
		
		Loop % srcArray.Length() {
			NumPut( srcArray[A_Index], binArray, elemPos, elemType )
			elemPos += elemSize
		}
	}
	
	
	; Creates flat copy of given array, unpacking any nested arrays.
	; Non-numeric keys are skipped.
	
	_FlattenArray( srcArray, dstArray := "" ) {
		Local
		Global OGdip
		
		flatArray := IsObject(dstArray)  ?  dstArray  :  []
		
		Loop % srcArray.Length() {
			item := srcArray[A_Index]
			
			If (IsObject(item) && (item.Length() != 0)) {
				OGdip._FlattenArray(item, flatArray)
			} Else {
				flatArray.Push(item)
			}
		}
		
		Return flatArray
	}
		
	
	
	; Color functions
	; ===============
	
	; Creates color UInt from given RGB[a] values.
	
	RGB( R, G, B, A := 0xFF ) {
		Return (0
		| ((A & 0xFF) << 24)
		| ((R & 0xFF) << 16)
		| ((G & 0xFF) <<  8)
		| ((B & 0xFF) <<  0) )
	}
	
	
	; Creates color UInt from given HSL[a] values.
	; Algorithm taken from wikipedia:
	; https://en.wikipedia.org/wiki/HSL_and_HSV#HSL_to_RGB
	
	HSL( H, S, L, A := 0xFF) {
		Local
		
		Hi := Mod(H, 360) / 60
		S  := S / 100
		L  := L / 100
		
		C := (1 - Abs(2*L - 1)) * S        ; Chroma
		X := C * (1 - Abs(Mod(Hi,2) - 1))  ; Second largest component
		M := L - C/2
		
		MC := 255*(C+M)
		MX := 255*(X+M)
		M  := M*255
		
		rgba := (Hi < 1) ? [MC, MX,  M, a]
		:       (Hi < 2) ? [MX, MC,  M, a]
		:       (Hi < 3) ? [M , MC, MX, a]
		:       (Hi < 4) ? [M , MX, MC, a]
		:       (Hi < 5) ? [MX,  M, MC, a]
		:       (Hi < 6) ? [MC,  M, MX, a]  :  [MC, MX, M, a]
		
		Return this.RGB(rgba*)
	}
	
	
	; Converts color UInt to an array of HSLA values.
	
	ToHSL( argb ) {
		Local
		
		A := (argb & 0xFF000000) >> 24
		R := (argb & 0x00FF0000) >> 16
		G := (argb & 0x0000FF00) >>  8
		B := (argb & 0x000000FF) >>  0
		
		V := Max(Max(R,G),B)  ; Max component - Value
		M := Min(Min(R,G),B)  ; Min component
		C := V - M            ; Chroma
		L := (V + M) / 2      ; Lightness
		
		H := (C == 0)  ?  0
		:  (V == R)  ?  (60 * (0 + (G-B) / C))
		:  (V == G)  ?  (60 * (2 + (B-R) / C))
		:  (V == B)  ?  (60 * (4 + (R-G) / C)) : 0
		
		S := (V - L) / Min(L, 1-L)
		
		Return [ H, S, L, A ]
	}
	
	
	; Mix two ARGB colors.
	
	MixRGB( argb1, argb2, t := 0.5 ) {
		a1 := (argb1 & 0xFF000000) >> 24
		r1 := (argb1 & 0x00FF0000) >> 16
		g1 := (argb1 & 0x0000FF00) >>  8
		b1 := (argb1 & 0x000000FF) >>  0
		
		a2 := (argb2 & 0xFF000000) >> 24
		r2 := (argb2 & 0x00FF0000) >> 16
		g2 := (argb2 & 0x0000FF00) >>  8
		b2 := (argb2 & 0x000000FF) >>  0
		
		rm := Min(Max(r1 + (r2-r1) * t,  0), 255)
		gm := Min(Max(g1 + (g2-g1) * t,  0), 255)
		bm := Min(Max(b1 + (b2-b1) * t,  0), 255)
		
		am := Min(Max(a1 + (a2-a1) * t,  0), 255)
		
		Return (0
		|  (am << 24)
		|  (rm << 16)
		|  (gm <<  8)
		|  (bm <<  0))
	}
	
	
	; Converts color from BGR format (ex. COLORREF) to ARGB
	
	BGRtoRGB( abgr ) {
		Return (abgr & 0xFF000000)
		|  ((abgr & 0xFF0000) >> 16)
		|  ((abgr & 0x00FF00) >> 0)
		|  ((abgr & 0x0000FF) << 16)
	}
	
	; Getting color by short name.
	; Argument 'key' can be:
	;   • CSS-like three-hex string;
	;   • name of one primary color (see CNames below)
	;     with optional modifier "L" or "D";
	;   • "Rnd" for random color.
	; Returned color always have full alpha.
	; 
	; Examples:
	;   > OGdip.GetColor("48F")     ==  0xFF4488FF
	;   > OGdip.GetColor("Yellow")  ==  0xFFFFFF00 
	;   > OGdip.GetColor("DGray")   ==  0xFF404040
	; 
	; To get colors even quicker, you can add this hack to your code:
	;   CC := {Base:{__Get:OGdip.GetColor}}
	;   MsgBox % Format("{:X}`n{:X}`n{:X}",  CC.48F,  CC.LBlue,  CC.Rnd)
	
	GetColor( key ) {
		Static CHex := {0:0x00, 1:0x11, 2:0x22, 3:0x33, 4:0x44, 5:0x55, 6:0x66, 7:0x77
		,               8:0x88, 9:0x99, A:0xAA, B:0xBB, C:0xCC, D:0xDD, E:0xEE, F:0xFF}
		
		If (key ~= "^[0-9A-Fa-f]{3}$") {
			key := StrSplit(key, "")
			
			Return OGdip.RGB( CHex[key[1]], CHex[key[2]], CHex[key[3]] )
		}
		
		Static CNames := {0:0
		,  Red   : 0xFF0000  , Cyan   : 0x00FFFF  , Black: 0x000000
		,  Green : 0x00FF00  , Magenta: 0xFF00FF  , White: 0xFFFFFF
		,  Blue  : 0x0000FF  , Yellow : 0xFFFF00  , Gray : 0x808080}
		
		If (CNames.HasKey(key))
			Return (0xFF000000 | CNames[key])
		
		; Lighter or Darker color
		If (key ~= "i)^[LD]") && (CNames.HasKey(SubStr(key, 2))) {
			retColor := CNames[SubStr(key, 2)]
			invColor := ((~retColor) >> 1) & 0x7F7F7F
			
			retColor := (key ~= "i)^L")      ;  Red := 0xFF0000
			?   (retColor |  invColor)       ; LRed := 0xFF7F7F
			:  ((retColor >> 1) & 0x7F7F7F)  ; DRed := 0x7F0000
			
			Return (0xFF000000 | retColor)
		}
		
		If (key = "Rnd") {
			Random, retColor, 0, 0xFFFFFF
			Return (0xFF000000 | retColor)
		}
		
		Return 0
	}
	
	
	; Opens color selection dialog and returns selected color.
	; If user cancels the dialog, returns empty string.
	; Returned color have no alpha set.
	
	ChooseColor(initColor := "") {
		Local
		Static customColors := False
		
		If (customColors == False) {
			VarSetCapacity(customColors, 16*4, 0)
			Loop 16 {
				NumPut(0x00FFFFFF, customColors, (A_Index-1)*4, "UInt")
			}
		}
		
		; ChooseColor does not like alpha values in colors.
		rgbInitColor := (initColor == "")  ?  0  :  this.BGRtoRGB(initColor & 0xFFFFFF)
		
		VarSetCapacity(structChooseColor, A_PtrSize*9, 0)
		
		NumPut( A_PtrSize*9  , structChooseColor, 0*A_PtrSize, "UInt" )  ; lStructSize
		NumPut( 0            , structChooseColor, 1*A_PtrSize, "Ptr"  )  ; hwndOwner
		NumPut( rgbInitColor , structChooseColor, 3*A_PtrSize, "UInt" )  ; rgbResult
		NumPut( &customColors, structChooseColor, 4*A_PtrSize, "Ptr"  )  ; customColors
		NumPut( 0x01 | 0x02  , structChooseColor, 5*A_PtrSize, "UInt" )  ; flags = CC_RGBINIT | CC_FULLOPEN
		
		reply := DllCall("comdlg32\ChooseColorW", "Ptr", &structChooseColor)
		
		If (reply == 0)
			Return ""
		
		Return this.BGRtoRGB(NumGet(structChooseColor, 3*A_PtrSize, "UInt"))
	}
	
	
	; Capture screen or window. Returns instance of Bitmap.
	;   > bmp := OGdip.Screenshot()              ; Capture primary monitor
	;   > bmp := OGdip.Screenshot( 2 )           ; Capture second monitor
	;   > bmp := OGdip.Screenshot( "*" )         ; Capture all monitors
	;   > bmp := OGdip.Screenshot( x, y, w, h )  ; Capture area of virtual screen.
	;   > bmp := OGdip.Screenshot( winTitle [, clientOnly] )  ; Capture window by title or HWND
	
	; Parts of the code are taken from related functions of <Gdip_All> library.
	; Special thanks to GeekDude and Marius Șucan.
	
	Screenshot( source := "", args* ) {
		Local
		Global OGdip
		
		If ( ((source ~= "^\*|\d$") == 0)
		&&   (args.Length() == 0) )
		&& ( (winHwnd := WinExist(source))
		||   (winHwnd := WinExist("ahk_id " source)) )
		{
			; See <Gdip_All> GetWindowRect function.
			VarSetCapacity(binRect, 16, 0)
			clientOnly := args.HasKey(1)  &&  !!args[1]
			
			If (clientOnly) {
				DllCall("GetClientRect"
				, "UPtr" , winHwnd
				, "UPtr" , &binRect)
				
				winW := NumGet(binRect,  8, "Int")
				winH := NumGet(binRect, 12, "Int")
				
			} Else {
				err := DllCall("dwmapi\DwmGetWindowAttribute"
				, "UPtr",  winHwnd  ; HWND  hwnd
				, "UInt",  9        ; DWORD dwAttribute (DWMWA_EXTENDED_FRAME_BOUNDS)
				, "UPtr", &binRect  ; PVOID pvAttribute
				, "UInt",  16       ; DWORD cbAttribute
				, "UInt")           ; HRESULT
				
				If (err) {
					DllCall("GetWindowRect"
					, "UPtr",  winHwnd
					, "UPtr", &binRect)
				}
				
				winW := Abs(NumGet(binRect,  8, "Int") - NumGet(binRect, 0, "Int"))
				winH := Abs(NumGet(binRect, 12, "Int") - NumGet(binRect, 4, "Int"))
			}
			
			bmpCapture := new OGdip.Bitmap( winW, winH )
			bmpCapture.GetGraphics()
			bmpGDC := bmpCapture.G.GetDC()
			
			DllCall("PrintWindow"
			, "UPtr",  winHwnd
			, "UPtr",  bmpGDC
			, "UInt",  clientOnly)
			
			bmpCapture.G.ReleaseDC(bmpGDC)
			Return bmpCapture
		}
		
		; See <Gdip_All> Gdip_BitmapFromScreen function.
		If (source == "*") {
			scrX := DllCall("GetSystemMetrics", "Int", 76)  ; SM_XVIRTUALSCREEN
			scrY := DllCall("GetSystemMetrics", "Int", 77)  ; SM_YVIRTUALSCREEN
			scrW := DllCall("GetSystemMetrics", "Int", 78)  ; SM_CXVIRTUALSCREEN
			scrH := DllCall("GetSystemMetrics", "Int", 79)  ; SM_CYVIRTUALSCREEN
			
		} Else
		If (args.Length() == 3) {
			scrX := source
			scrY := args[1]
			scrW := args[2]
			scrH := args[3]
			
		} Else {
			SysGet, monitorBounds, Monitor, % source
			If (monitorBoundsLeft == "")
				Return
			
			scrX := monitorBoundsLeft
			scrY := monitorBoundsTop
			scrW := monitorBoundsRight  - monitorBoundsLeft
			scrH := monitorBoundsBottom - monitorBoundsTop
		}
		
		bmpCapture := new OGdip.Bitmap( scrW, scrH )
		bmpCapture.GetGraphics()
		bmpGDC := bmpCapture.G.GetDC()
		
		screenDC := DllCall("GetDC", "UPtr", 0)
		
		DllCall("gdi32\BitBlt"
		, "UPtr", bmpGDC
		, "Int" , 0
		, "Int" , 0
		, "Int" , scrW
		, "Int" , scrH
		, "UPtr", screenDC
		, "Int" , scrX
		, "Int" , scrY
		, "UInt", 0x00CC0020)  ; ROP = SRCCOPY
		
		bmpCapture.G.ReleaseDC(bmpGDC)
		Return bmpCapture
	}
	
	
	
	; Enum class
	; ==========
	; Service class, used to get enumeration values by name or id.
	; Most useful to parse arguments that can be given either by name or numeric id.
	;   > myUnit := OGdip.Enum.Get("unit", "pixel")
	
	Class Enum {
		; Used in Region.Combine and Graphics.SetClip
		Static CombineMode := { _minId: 0, _maxId: 5
			, "=": 0   , "Set": 0   , "Replace"    : 0
			, "&": 1   , "And": 1   , "Intersect"  : 1
			, "+": 2   , "Add": 2   , "Union"      : 2
			, "X": 3   , "Xor": 3   , "ExclusiveOr": 3
			, "-": 4   , "Sub": 4   , "Subtract"   : 4
			, "!": 5   , "Cut": 5   , "Complement" : 5 }
		
		Static CoordSpace := { _minId: 0, _maxId: 2
			, "World"  : 0
			, "Page"   : 1
			, "Device" : 2 }
		
		Static HatchStyle := { _minId: 0, _maxId: 52
			, "H":  0  , "\":  2  , "Grid" :  4
			, "V":  1  , "/":  3  , "XGrid":  5
			
			, "5%" :  6  , "10%":  7  , "20%":  8
			, "25%":  9  , "30%": 10  , "40%": 11
			, "50%": 12  , "60%": 13  , "70%": 14
			, "75%": 15  , "80%": 16  , "90%": 17
			
			, "\\" : 18  , "\\2": 20  , "\3" : 22
			, "//" : 19  , "//2": 21  , "/3" : 23
			
			, "VV" : 24  , "VVV": 26  , "VV2": 28
			, "HH" : 25  , "HHH": 27  , "HH2": 29
			
			, "D\" : 30  , "DH" : 32
			, "D/" : 31  , "DV" : 33
			
			, "Confetti": 34   , "Confetti2": 35
			, "Zigzag"  : 36   , "Wave"     : 37
			, "/Brick"  : 38   , "Brick"    : 39
			, "Weave"   : 40   , "Plaid"    : 41  , "Divot" : 42
			, "GridDot" : 43   , "XGridDot" : 44
			, "Shingle" : 45   , "Trellis"  : 46  , "Sphere": 47
			
			, "GridSmall": 48  , "XGridNA"  : 51
			, "Checkers" : 49  , "XCheckers": 52
			, "Checkers2": 50 }
		
		Static Unit := { _minId: 0, _maxId: 7
			, "World"      : 0
			, "Display"    : 1
			, "Pixel"      : 2
			, "Point"      : 3
			, "Inch"       : 4
			, "Document"   : 5
			, "Millimeter" : 6
			, "MetafileGDI": 7 }
		
		Static WrapMode := { _minId: 0, _maxId: 4
			, "None"  : 0
			, "X"     : 1
			, "Y"     : 2
			, "XY"    : 3
			, "Clamp" : 4 }
		
		
		Get( enumName, enumKey, defaultValue := 0 ) {
			Local
			
			If (enumKey == "")
				Return defaultValue
			
			enumList := False ? ""
			:  IsObject(enumName)    ?  enumName
			:  this.HasKey(enumName) ?  this[enumName]  :  0
			
			If (IsObject(enumList) == False)
				Return defaultValue
			
			If (enumList.HasKey(enumKey))
				Return enumList[enumKey]
			
			If (enumKey >= enumList._minId)
			&& (enumKey <= enumList._maxId)
				Return enumKey
			
			Return defaultValue
		}
		
		
		GetName( enumName, enumValue, defaultValue := 0 ) {
			Local
			
			If (enumValue == "")
			|| (this.HasKey(enumName) == False)
				Return defaultValue
			
			enumList := this[enumName]
			
			For key, value In enumList {
				If (enumValue == value)
					Return key
			}
			
			Return defaultValue
		}
	}
	
	
	
	; Image class
	; ===========
	; 
	; Image class is a base for Bitmap and Metafile classes.
	; Most useful for reading and writing various metadata.
	; 
	; Constructors:
	;   > img := new OGdip.Image( filename [, useICM] )              ; Create from file
	;   > img := new OGdip.Image( "*", streamPtr [, useICM] )        ; Create from stream
	;   > img := new OGdip.Image( "*BASE64", strBase64 [, useICM] )  ; Create from base64-string
	;   > img := new OGdip.Image( oImage )                           ; Clone existing image
	;   > img := new OGdip.Image( oImage, width, height )            ; Create thumbnail
	;   > img := OGdip.Image.FromBase64( strBase64 [, useICM] )      ; Create from base64-string
	; 
	; Properties:
	;   • Width
	;   • Height
	;   • Attributes
	; 
	; Methods:
	;   .Save( output [, saveParams] )
	;   .SaveAdd( [dimension, oImageFrame] )
	;   .SetAttribute( attributeName, args* )
	;   .GetGraphics()
	;   .Rotate( flipType )
	;   .GetBounds()
	;   .GetPhysicalSize()
	;   .GetResolution()
	;   .GetPixelFormat( [formatAsText] )
	;   .GetInfo()
	;   .GetPalette( [rawData] )
	;   .SetPalette( palette )
	;   .GetFrameCount( [extended] )
	;   .SelectFrame( frame [, dimension] )
	;   .GetProperty( propId )
	;   .GetAllProperties()
	;   .RemoveProperty( propId )
	;   .SetProperty( propId, propType, propValue [, length] )
	; 
	; Internal Methods:
	;   ._GetEncoder( [format] )
	;   ._GetPixelFormatByName( format [, nameByFormat] )
	;   ._GetMultiframeDimensions( &guidList )
	;   ._PropertyID( propId [, getName] )
	;   ._PropertyTypeMeta( propType )
	;   ._ApproximateFraction( n [, precision] )
	; 
	; Subclasses:
	;   • Bitmap
	;   • Metafile
	
	Class Image {
		
		__New( source, args* ) {
			Local
			Global OGdip
			
			pImage := 0
			
			If (IsObject(source))
			&& ((source.Base == OGdip.Image)
			||  (source.Base == OGdip.Bitmap)
			||  (source.Base == OGdip.Metafile))
			{
				If (args.Length() == 2) {
					DllCall("GdiPlus\GdipGetImageThumbnail"
					, "Ptr" , source._pImage
					, "UInt", args[1]  ;  width
					, "UInt", args[2]  ;  height
					, "Ptr*", pImage   ; &thumbImage
					, "Ptr" , 0        ;  callback
					, "Ptr" , 0)       ;  callbackData
					
				} Else {
					DllCall("GdiPlus\GdipCloneImage"
					, "Ptr" , source._pImage
					, "Ptr*", pImage)
				}
				
			} Else
			If (source = "*") {
				streamPtr :=  args[1]
				useICM    :=  args.HasKey(2)  ?  args[2]  :  False
				
				DllCall("GdiPlus\GdipLoadImageFromStream" . (useICM ? "ICM" : "")
				, "Ptr" , streamPtr
				, "Ptr*", pImage)
				
			} Else
			If (source == "*BASE64") {
				; This constructor wasn't finished and have not created Image instance,
				; so it does not need to call __Delete afterwards.
				this.Base := False
				Return OGdip.Image.FromBase64( args* )
				
			} Else {
				useICM := args.HasKey(1)  ?  args[1]  :  False
				
				DllCall("GdiPlus\GdipLoadImageFromFile" . (useICM ? "ICM" : "")
				, "WStr", source
				, "Ptr*", pImage)
			}
			
			
			If (pImage == 0) {
				this.Base := False  ; Avoid calling __Delete
				Return False
			}
			
			this._pImage := pImage
			
			If (OGdip.autoGraphics == True)
				this.GetGraphics()
		}
		
		
		FromBase64( ByRef strBase64, useICM := False ) {
			Local
			Global OGdip
			
			dataSize  := OGdip._Base64ToBinary( strBase64, binBuffer := "" )
			streamPtr := OGdip._MemToStream( binBuffer, dataSize )
			
			DllCall("GdiPlus\GdipLoadImageFromStream" . (useICM ? "ICM" : "")
			, "Ptr" , streamPtr
			, "Ptr*", pImage := 0)
			
			ObjRelease(streamPtr)
			
			
			If (pImage == 0)
				Return False
			
			resultImage := { Base: OGdip.Image, _pImage: pImage }
			
			If (OGdip.autoGraphics == True)
				resultImage.GetGraphics()
			
			Return resultImage
		}
		
		
		__Delete() {
			DllCall("GdiPlus\GdipDisposeImage"
			, "Ptr", this._pImage)
		}
		
		
		; Width and Height properties
		; Getters cache values on first call (assuming Image can't change size).
		; Setters can be used to reset cache and get uncached value:
		;   > w := (img.Width := 0)
		
		Width {
			Get {
				Local
				
				If (ObjRawGet(this, "_cacheWidth"))
					Return this._cacheWidth
				
				DllCall("GdiPlus\GdipGetImageWidth"
				, "Ptr"   , this._pImage
				, "UInt*" , pxWidth := 0)
				
				Return (this._cacheWidth := pxWidth)
			}
			Set {
				this.Delete("_cacheWidth")
				Return this.Width
			}
		}
		
		
		Height {
			Get {
				Local
				
				If (ObjRawGet(this, "_cacheHeight"))
					Return this._cacheHeight
				
				DllCall("GdiPlus\GdipGetImageHeight"
				, "Ptr"   , this._pImage
				, "UInt*" , pxHeight := 0)
				
				Return (this._cacheHeight := pxHeight)
			}
			Set {
				this.Delete("_cacheHeight")
				Return this.Height
			}
		}
		
		
		; Attributes property
		; Getter returns ImageAttributes object or empty string.
		; Setter takes ImageAttributes object or an object that can init ImageAttributes.
		; See also: Image.SetAttribute method, ImageAttributes class
		
		Attributes {
			Get {
				Return this._Attributes
			}
			Set {
				If (value == "") {
					Return (this._Attributes := "")
				}
				
				If (IsObject(value) == True) {
					If (value.Base == OGdip.ImageAttributes) {
						Return (this._Attributes := value)
						
					} Else {
						Return (this._Attributes := new OGdip.ImageAttributes(value))
					}
				}
				
				Return value
			}
		}
		
		
		; Sets single image attribute by given name.
		; Creates ImageAttributes if needed.
		
		SetAttribute( attributeName, args* ) {
			If (this.Attributes == "")
				this.Attributes := new OGdip.ImageAttributes()
			
			this.Attributes.SetAttribute( attributeName, args* )
		}
		
		
		; Get encoders information.
		;   > codecJpg := OGdip.Image._GetEncoder("jpg")
		;   > codecAll := OGdip.Image._GetEncoder()
		; For internal use with .Save method.
		
		_GetEncoder( format := "" ) {
			Local
			Global OGdip
			
			Static encoders := ""
			
			If (IsObject(encoders)) {
				If (format == "")
					Return encoders
				
				If (format != "")
				&& (encoders.HasKey(format))
					Return encoders[format]
				
				Return -1
			}
			
			encoders := {}
			
			; Get list of available encoders
			
			DllCall("GdiPlus\GdipGetImageEncodersSize"
			, "UInt*", codecCount := 0
			, "UInt*", codecListSize := 0)
			
			VarSetCapacity(codecList, codecListSize, 0)
			
			DllCall("GdiPlus\GdipGetImageEncoders"
			, "UInt",  codecCount
			, "UInt",  codecListSize
			, "Ptr" , &codecList)
			
			; See ImageCodecInfo in GdiPlusImaging.h
			codecInfoSize  := 2*16 + 5*A_PtrSize + 4*4 + 2*A_PtrSize
			
			Loop % codecCount {
				codecOffset := &codecList + (A_Index-1) * codecInfoSize
				
				; Only elements important for saving are retrieved.
				; DllName, Description, MimeType, Flags, Version and Signature are skipped.
				
				codecInfo := {}
				codecInfo.codecClsid  := OGdip._GuidToString(codecOffset)
				codecInfo.formatGuid  := OGdip._GuidToString(codecOffset + 16)
				
				codecInfo.codecName   := StrGet( NumGet(codecOffset + 2*16 + 0*A_PtrSize, "Ptr"),  "UTF-16" )
				codecInfo.extensions  := StrGet( NumGet(codecOffset + 2*16 + 3*A_PtrSize, "Ptr"),  "UTF-16" )
				
				; Get list of available EncoderParameters
				
				DllCall("GdiPlus\GdipGetEncoderParameterListSize"
				, "Ptr"  , this._pImage
				, "Ptr"  , codecOffset
				, "UInt*", paramListSize := 0)
				
				VarSetCapacity(paramList, paramListSize, 0)
				
				DllCall("GdiPlus\GdipGetEncoderParameterList"
				, "Ptr" ,  this._pImage
				, "Ptr" ,  codecOffset
				, "UInt",  paramListSize
				, "Ptr" , &paramList)
				
				paramInfoSize := 16 + 2*4 + A_PtrSize  ; See EncoderParameter in GdiPlusImaging.h
				paramCount    := NumGet(paramList, 0, "UInt")
				
				codecInfo.parameters := {}
				
				Loop % paramCount {
					paramOffset := A_PtrSize + (A_Index-1)*paramInfoSize
					paramGuid   := OGdip._GuidToString(&paramList + paramOffset)
					
					; Since some parameters are not used or implemented in current GDI+,
					; I decided to hard-code its values to reduce complexity of the script.
					; Consult MSDN, GdiPlusImaging.h and GdiPlusEnums.h if needed.
					
					paramName := False ? 0
					: (paramGuid = "{1D5BE4B5-FA4A-452D-9CDD-5DB35105E7EB}")  ?  "quality"     ; JPEG
					: (paramGuid = "{8D0EB2D1-A58E-4EA8-AA14-108074B7B6F9}")  ?  "transform"   ; JPEG
					: (paramGuid = "{292266FC-AC40-47BF-8CFC-A85B89A655DE}")  ?  "multiframe"  ; TIFF/GIF
					: (paramGuid = "{E09D739D-CCD4-44EE-8EBA-3FBF8BE4FC58}")  ?  "compression" ; TIFF
					: (paramGuid = "{66087055-AD66-4C7C-9A18-38A2310B8337}")  ?  "colorDepth"  ; TIFF
					: (paramGuid = "{A219BBC9-0A9D-4005-A3EE-3A421B8BB06C}")  ?  "saveAsCmyk"  ; TIFF
					: (paramGuid = "{EDB33BCE-0266-4A77-B904-27216099E717}")  ?  "lumaTable"   ; JPEG
					: (paramGuid = "{F2E455DC-09B3-4316-8260-676ADA32481C}")  ?  "chromaTable"  :  ""
					
					If (paramName != "")
						codecInfo.parameters[paramName] := paramGuid
				}
				
				For index, extension In StrSplit(codecInfo.extensions, ";") {
					extension := Trim(extension, "*. ")
					encoders[extension] := codecInfo
				}
			}
			
			; Restart function with newly created 'encoders' and return result.
			Return OGdip.Image._GetEncoder(format)
		}
		
		
		; Save Image to file, stream or base64-string.
		; File format is determined by given extension, even when saving to stream or base64.
		; Formats supported by GDI+ : BMP, JPG, PNG, TIF, GIF
		;   > img.Save( "mypicture.bmp" )  ; Save as file and return status (0 = Ok)
		;   > img.Save( "*.jpg" )          ; Save as stream and return IStream pointer
		;   > img.Save( "*BASE64.png" )    ; Save and return as base64-string
		;   > img.Save( "unknown.bin" )    ; Unknown format, will return -1
		; 
		; You can pass an object with following fields as a second argument 'saveParams':
		;   • transform    - JPEG lossless transform (90|180|-90|"X"|"Y");
		;   • quality      - JPEG encoding quality (0..100, bigger is better quality, but larger filesize);
		;   • multiframe   - Start multiframe GIF/TIFF-file; add more frames with .SaveAdd method;
		;   • compression  - TIFF compression algorithm (LZW|RLE|CCITT3|CCITT4|None);
		;   • colorDepth   - TIFF bit depth (1|4|8|24|32);
		;   • saveAsCmyk   - Save TIFF file with CMYK color space;
		;   • lumaTable    - Array of 8*8 short values for JPEG luminance table
		;   • chromaTable  - Array of 8*8 short values for JPEG chrominance table
		; 
		; Examples:
		;   > img.Save("example.jpg", {quality: 95})
		;   > img.Save("example.jpg", {transform: "X"})
		;   > img.Save("example.tif", {compression: "lzw", saveAsCmyk: 1})
		
		Static EnumJpegTransform := { _minId: 13, _maxId: 17
			,  "CW": 13  ,  90: 13  , -270: 13
			,  "XY": 14  , 180: 14  , -180: 14
			, "CCW": 15  , 270: 15  ,  -90: 15
			,   "X": 16
			,   "Y": 17 }
		
		Static EnumTiffCompression := { _minId: 2, _maxId: 6
			, "LZW"    : 2
			, "CCITT3" : 3
			, "CCITT4" : 4
			, "RLE"    : 5
			, "None"   : 6 }
		
		Save( output, saveParams := "" ) {
			Local
			Global OGdip
			
			RegexMatch(output, "(?<=\.)[^\.]+$", format)
			
			encoderInfo := this._GetEncoder(format)
			
			If (IsObject(encoderInfo) == False)
				Return -1
			
			OGdip._StringToGuid(encoderInfo.codecClsid, encoderClsid := "")
			encoderParamsPtr := 0
			
			If (IsObject(saveParams))
			&& (saveParams.Count() > 0)
			{
				paramsToUse := []
				paramsValuesSize := 0
				
				For paramName, paramGuid In encoderInfo.parameters {
					If (saveParams.HasKey(paramName)) {
						paramsToUse.Push(paramName)
						paramsValuesSize += ((paramName = "lumaTable") || (paramName = "chromaTable"))
						?  (64*2)  ; Quantization tables are 8*8 of Short values
						:   4      ; All other parameters are Long or LongRange
					}
				}
				
				; Create EncoderParameters structure with values buffer
				paramInfoSize := 16 + 2*4 + A_PtrSize
				VarSetCapacity(saveParamsList, A_PtrSize + paramsToUse.Length() * paramInfoSize, 0)
				NumPut(paramsToUse.Length(), saveParamsList, 0, "UInt")
				
				VarSetCapacity(saveValuesList, paramsValuesSize, 0)
				valueOffset := 0
				
				For index, paramName In paramsToUse {
					paramGuid  := encoderInfo.parameters[paramName]
					paramValue := saveParams[paramName]
					
					valuesNum := 1
					valueType := 4  ; Most parameters use 'Long' type
					
					paramPtr := &saveParamsList + A_PtrSize + (index-1)*paramInfoSize
					valuePtr := &saveValuesList + valueOffset
					
					If (paramName = "lumaTable")
					|| (paramName = "chromaTable")
					{
						valuesNum := 64  ; 
						valueType := 3   ; Short
						
						Loop % Min(64, paramValue.Length()) {
							NumPut(paramValue[A_Index], saveValuesList, (valueOffset + (A_Index-1)*2), "Short")
						}
						
						valueOffset += 64*2
						
					} Else {
						If (paramName = "compression") {
							rawValue := OGdip.Enum.Get(this.EnumTiffCompression, paramValue, 6)
							
						} Else
						If (paramName = "transform") {
							rawValue := OGdip.Enum.Get(this.EnumJpegTransform, paramValue, 13)
							
						} Else
						If (paramName = "quality") {
							rawValue := Min(Max(paramValue, 0), 100)
							
						} Else
						If (paramName = "multiframe") {
							rawValue := 18  ; EncoderValueMultiFrame
							
						} Else
						If (paramName = "saveAsCmyk") {
							rawValue := 1
							
						} Else {
							rawValue := paramValue
						}
						
						NumPut(rawValue, saveValuesList, valueOffset, "UInt")
						valueOffset += 4
					}
					
					; Write EncoderParameter
					OGdip._StringToGuid( paramGuid, 0+paramPtr )
					NumPut(valuesNum , 0+paramPtr, 16, "UInt")
					NumPut(valueType , 0+paramPtr, 20, "UInt")
					NumPut(valuePtr  , 0+paramPtr, 24, "Ptr")
				}
				
				encoderParamsPtr := &saveParamsList
			}
			
			
			If (InStr(output, "*") == 0) {
				; Save to regular file
				Return DllCall("GdiPlus\GdipSaveImageToFile"
				, "Ptr" ,  this._pImage
				, "WStr",  output
				, "Ptr" , &encoderClsid
				, "Ptr" ,  encoderParamsPtr)
				
			} Else {
				streamPtr := OGdip._MemToStream(0, 0)  ; Create empty stream
				
				DllCall("GdiPlus\GdipSaveImageToStream"
				, "Ptr" ,  this._pImage
				, "Ptr" ,  streamPtr
				, "Ptr" , &encoderClsid
				, "Ptr" ,  encoderParamsPtr)
				
				If (InStr(output, "*BASE64")) {
					dataSize  := OGdip._StreamToMem( streamPtr, varBuffer := "" )
					OGdip._BinaryToBase64( &varBuffer, dataSize, strBase64 := "")
					
					Return strBase64
				}
				
				Return streamPtr
			}
		}
		
		
		; Save additional frames to previously saved multiframe image.
		; Dimension should be "time" for GIF, "page" for TIF.
		;   > multiimg.SaveAdd( "page", img1 )  ; add another image as a new frame
		;   > multiimg.SaveAdd( "page" )        ; add selected frame from 'multiimg' as a new frame
		;   > multiimg.SaveAdd()                ; flush and close saved multiframe image
		
		SaveAdd( dimension := "", oImageFrame := "" ) {
			Local
			Global OGdip
			
			; Create single-item EncoderParameters structure
			codecInfoSize := 16 + 4 + 4 + A_PtrSize
			
			VarSetCapacity(encoderParams, A_PtrSize + codecInfoSize + 4, 0)
			NumPut(1, encoderParams, 0, "UInt")
			
			dimensionValue := False ? 0
			:  (dimension = "time")       ?  21
			:  (dimension = "resolution") ?  22
			:  (dimension = "page")       ?  23  :  20  ; EncoderValueFlush
			
			valuePtr := &encoderParams + A_PtrSize + codecInfoSize
			NumPut(dimensionValue, 0+valuePtr, "UInt")
			
			; Write 'multiframe' EncoderParameter
			OGdip._StringToGuid("{292266FC-AC40-47BF-8CFC-A85B89A655DE}", &encoderParams + A_PtrSize)
			NumPut(1        , encoderParams, A_PtrSize+16, "UInt")  ; NumberOfValues : 1
			NumPut(4        , encoderParams, A_PtrSize+20, "UInt")  ; ValueType : LONG
			NumPut(valuePtr , encoderParams, A_PtrSize+24, "Ptr")
			
			; Choose function to call
			If (IsObject(oImageFrame) == True)
			&& ((oImageFrame.Base == OGdip.Image)
			||  (oImageFrame.Base.Base == OGdip.Image))
			{
				Return DllCall("GdiPlus\GdipSaveAddImage"
				, "Ptr" ,  this._pImage
				, "Ptr" ,  oImageFrame._pImage
				, "Ptr" , &encoderParams)
				
			} Else {
				DllCall("GdiPlus\GdipSaveAdd"
				, "Ptr" ,  this._pImage
				, "Ptr" , &encoderParams)
			}
			
			Return this
		}
		
		
		; Creates Graphics object from Image.
		; Returns created Graphics object, also sets it to properties .G and .Graphics
		; If OGdip.autoGraphics is True, these properties are created in each new instance.
		
		GetGraphics() {
			If (this.Graphics)
				Return this.Graphics
			
			this.G := this.Graphics := new OGdip.Graphics(this)
			Return this.Graphics
		}
		
		
		; Rotates or flips image.
		;   > img.Rotate(90)  ; Rotate image 90° clockwise.
		
		Static EnumRotateFlipType := { _minId: 0, _maxId: 7
			,  "CW": 1  ,  90: 1  , -270: 1
			,  "XY": 2  , 180: 2  , -180: 2
			, "CCW": 3  , 270: 3  ,  -90: 3
			,   "X": 4
			,   "Y": 6 }
		
		Rotate( flipType ) {
			DllCall("GdiPlus\GdipImageRotateFlip"
			, "Ptr" , this._pImage
			, "UInt", OGdip.Enum.Get(this.EnumRotateFlipType, flipType, 0))
			
			Return this
		}
		
		
		; Get image bounds.
		; Metafile images can have left-top corner other than [0, 0],
		; getting bounds is generally more reliable way than just Width/Height.
		
		GetBounds() {
			Local
			
			VarSetCapacity(srcRectF, 4*4, 0)
			
			DllCall("GdiPlus\GdipGetImageBounds"
			, "Ptr"  ,  this._pImage
			, "Ptr"  , &srcRectF
			, "UInt*",  unit := 0)
			
			x := NumGet(srcRectF, 4*0, "Float")
			y := NumGet(srcRectF, 4*1, "Float")
			w := NumGet(srcRectF, 4*2, "Float")
			h := NumGet(srcRectF, 4*3, "Float")
			
			Return [ x, y, w, h, unit ]
		}
		
		
		; Get physical size of the image.
		; In most cases returns same values as regular Width/Height.
		; For some metafiles, however, these values are in different units.
		
		GetPhysicalSize() {
			Local
			
			DllCall("GdiPlus\GdipGetImageDimension"
			, "Ptr"   , this._pImage
			, "Float*", phWidth  := 0
			, "Float*", phHeight := 0)
			
			Return [ phWidth, phHeight ]
		}
		
		
		; Get resolution in dots per inch of the image.
		; Note that some images may have several places to store DPI.
		
		GetResolution() {
			Local
			
			DllCall("GdiPlus\GdipGetImageHorizontalResolution"
			, "Ptr"   , this._pImage
			, "Float*", hDPI := 0)
			
			DllCall("GdiPlus\GdipGetImageVerticalResolution"
			, "Ptr"   , this._pImage
			, "Float*", vDPI := 0)
			
			Return [ hDPI, vDPI ]
		}
		
		
		; Returns pixel format numeric id for given name (or vice versa).
		; For internal use with Image.GetPixelFormat and Bitmap.ConvertFormat.
		
		_GetPixelFormatByName( formatName, nameByFormat := False ) {
			Local
			Static formats := ""
			Static names   := ""
			
			If (formats == "") {
				PF_INDEXED   := 0x010000  ; Indexes into a palette
				PF_GDI       := 0x020000  ; Is a GDI-supported format
				PF_ALPHA     := 0x040000  ; Has an alpha component
				PF_PALPHA    := 0x080000  ; Pre-multiplied alpha
				PF_EXTENDED  := 0x100000  ; Extended color 16 bits/channel
				PF_CANONICAL := 0x200000
				
				formats := {}
				formats["I1"]       :=   1 | ( 1 << 8) | PF_GDI | PF_INDEXED
				formats["I4"]       :=   2 | ( 4 << 8) | PF_GDI | PF_INDEXED
				formats["I8"]       :=   3 | ( 8 << 8) | PF_GDI | PF_INDEXED
				formats["I16"]      :=   4 | (16 << 8) | PF_EXTENDED
				formats["RGB555"]   :=   5 | (16 << 8) | PF_GDI
				formats["RGB565"]   :=   6 | (16 << 8) | PF_GDI
				formats["ARGB1555"] :=   7 | (16 << 8) | PF_GDI | PF_ALPHA
				formats["RGB24"]    :=   8 | (24 << 8) | PF_GDI
				formats["RGB32"]    :=   9 | (32 << 8) | PF_GDI
				formats["ARGB32"]   :=  10 | (32 << 8) | PF_GDI | PF_ALPHA | PF_CANONICAL
				formats["PARGB32"]  :=  11 | (32 << 8) | PF_GDI | PF_ALPHA | PF_PALPHA
				formats["RGB48"]    :=  12 | (48 << 8) | PF_EXTENDED
				formats["ARGB64"]   :=  13 | (64 << 8) | PF_ALPHA | PF_CANONICAL | PF_EXTENDED
				formats["PARGB64"]  :=  14 | (64 << 8) | PF_ALPHA | PF_PALPHA | PF_EXTENDED
				formats["CMYK32"]   :=  15 | (32 << 8)
				
				names := {}
				For key, value In formats
					names[value] := key
			}
			
			If (nameByFormat == True)
				Return names[formatName]
			
			If (formats.HasKey(formatName))
				Return formats[formatName]
			
			If (Floor(formatName) > 0)
				Return Floor(formatName)
			
			Return formats["ARGB32"]
		}
		
		
		; Get image pixel format.
		;   > img.GetPixelFormat()     =>  2498570   ; 'ARGB32' format (0x26200A)
		;   > img.GetPixelFormat(True) =>  "ARGB32"
		
		GetPixelFormat( formatAsText := False ) {
			DllCall("GdiPlus\GdipGetImagePixelFormat"
			, "Ptr"  , this._pImage
			, "UInt*", pixelFormat := 0)
			
			Return (formatAsText
			?  this._GetPixelFormatByName(pixelFormat, True)
			:  pixelFormat)
		}
		
		
		; Get object with specific information bits about the image.
		;   > imgInfo := myImg.GetInfo()
		; 
		; Following fields may be present in returned object:
		;   .type          - 'bitmap' | 'metafile' | 'unknown'
		;   .rawFormat     - 'membmp' | 'bmp' | 'emf' | 'wmf' | 'jpg' | 'png' | 'gif' | 'tif' | 'exif' | 'undefined'
		;   .scalable      - 1 - image can be scaled, >1 - image can be scaled with limitations
		;   .hasAlpha      - 1 - image has transparent pixels, >1 - image has semi-transparent pixels
		;   .hasDPI        - DPI information is stored in the image
		;   .hasPixelSize  - Pixel size is stored in the image
		;   .readOnly      - Pixel data is read-only
		;   .caching       - Pixel data can be cached
		;   .colorSpace    - 'RGB' | 'CMYK' | 'Gray' | 'YCbCr' | 'YCCK'
		
		GetInfo() {
			Local
			imageInfo := {}
			
			
			DllCall("GdiPlus\GdipGetImageType"
			, "Ptr"  , this._pImage
			, "UInt*", imageType := 0)
			
			imageInfo.type := False ? ""
			: (imageType == 1) ? "bitmap"
			: (imageType == 2) ? "metafile"  :  "unknown"
			
			
			VarSetCapacity(imageGuid, 16, 0)
			
			DllCall("GdiPlus\GdipGetImageRawFormat"
			, "Ptr"  , this._pImage
			, "Ptr"  , &imageGuid)
			
			guidInt := NumGet(imageGuid, 0, "UInt")  ; Image format GUIDs differ only in the first INT,
			imageInfo.rawFormat := False ? ""        ; ex: {b96b3caa-0728-11d3-9d7b-0000f81ef32e} is a MemoryBMP
			:  (guidInt == 0xb96b3caa) ? "membmp"
			:  (guidInt == 0xb96b3cab) ? "bmp"
			:  (guidInt == 0xb96b3cac) ? "emf"
			:  (guidInt == 0xb96b3cad) ? "wmf"
			:  (guidInt == 0xb96b3cae) ? "jpg"
			:  (guidInt == 0xb96b3caf) ? "png"
			:  (guidInt == 0xb96b3cb0) ? "gif"
			:  (guidInt == 0xb96b3cb1) ? "tif"
			:  (guidInt == 0xb96b3cb2) ? "exif"
			:  (guidInt == 0xb96b3cb5) ? "ico"  : "undefined"
			
			
			DllCall("GdiPlus\GdipGetImageFlags"
			, "Ptr"  , this._pImage
			, "UInt*", imageFlags := 0)
			
			imageInfo.scalable     := !!(imageFlags & 0x00001) + (!!(imageFlags & 0x00008) << 1)
			imageInfo.hasAlpha     := !!(imageFlags & 0x00002) + (!!(imageFlags & 0x00004) << 1)
			imageInfo.hasDPI       := !!(imageFlags & 0x01000)
			imageInfo.hasPixelSize := !!(imageFlags & 0x02000)
			imageInfo.readOnly     := !!(imageFlags & 0x10000)
			imageInfo.caching      := !!(imageFlags & 0x20000)
			
			imageInfo.colorSpace := Trim(""
			. ((imageFlags & 0x00010) ? "RGB "   :  "")
			. ((imageFlags & 0x00020) ? "CMYK "  :  "")
			. ((imageFlags & 0x00040) ? "Gray "  :  "")
			. ((imageFlags & 0x00080) ? "YCbCr " :  "")
			. ((imageFlags & 0x00100) ? "YCCK "  :  ""))
			
			Return imageInfo
		}
		
		
		; Gets image palette either as an array/object or raw binary data.
		;   > palette := img.GetPalette()      ; array/object - see additional fields below
		;   > img.GetPalette( varBinPalette )  ; put palette binary data to a variable
		; Note: for animated GIFs you may need to use .GetProperty("GlobalPalette")
		
		GetPalette( ByRef rawData := 0 ) {
			Local
			
			DllCall("GdiPlus\GdipGetImagePaletteSize"
			, "Ptr" ,  this._pImage
			, "Int*",  paletteSize := 0)
			
			VarSetCapacity(rawData, paletteSize, 0)
			
			success := DllCall("GdiPlus\GdipGetImagePalette"
			, "Ptr" ,  this._pImage
			, "Ptr" , &rawData
			, "Int" ,  paletteSize)
			
			If (IsByRef(rawData))
			|| (success != 0)
				Return success
			
			palette := {}
			paletteFlags := NumGet(rawData, 0, "UInt")
			paletteCount := NumGet(rawData, 4, "UInt")
			
			palette.hasAlpha  := !!(paletteFlags & 0x01)
			palette.grayscale := !!(paletteFlags & 0x02)
			palette.halftone  := !!(paletteFlags & 0x04)
			palette.entries   := paletteCount
			
			Loop % paletteCount {
				palette[A_Index] := NumGet(rawData, 4 + A_Index * 4, "UInt")
			}
			
			Return palette
		}
		
		
		; Sets image palette either from array or ARGB entries or pointer to binary data.
		;   > img.SetPalette([0xFF000000, 0xFFFF0000])  ; Set two-color palette (black and red)
		;   > img.SetPalette( &varBinaryPalette )       ; Set palette from binary data
		; If argument is an array, palette flags will be deduced automatically.
		
		SetPalette( palette ) {
			Local
			
			If (IsObject(palette) == False) {
				palettePtr := palette
				
			} Else {
				paletteEntries := palette.MaxIndex()
				VarSetCapacity(paletteBinData, 4*(2 + paletteEntries), 0)
				
				hasAlpha  := 0  ; These flags will be autodetected.
				grayscale := 1  ; Halftone flag will always be reset.
				
				Loop % paletteEntries {
					argb := palette[A_Index]
					
					If (hasAlpha == 0)
						hasAlpha := ((argb & 0xFF000000) != 0xFF000000)
					
					If (grayscale == 1) {
						r := (argb & 0xFF0000) >> 16
						g := (argb & 0x00FF00) >> 8
						b := (argb & 0x0000FF) >> 0
						grayscale := (r == g) && (g == b)
					}
					
					NumPut(palette[A_Index], paletteBinData, 4*(A_Index+1), "UInt")
				}
				
				paletteFlags := (hasAlpha << 0) | (grayscale << 1)
				
				NumPut(paletteFlags   , paletteBinData, 0, "UInt")
				NumPut(paletteEntries , paletteBinData, 4, "UInt")
				
				palettePtr := &paletteBinData
			}
			
			Return DllCall("GdiPlus\GdipSetImagePalette"
			, "Ptr", this._pImage
			, "Ptr", palettePtr)
		}
		
		
		; Gets binary list of dimension GUIDs for multiframe images.
		; Returns number of dimensions.
		; For internal use in .GetFrameCount and .SelectActiveFrame
		
		_GetMultiframeDimensions( ByRef guidList ) {
			Local
			
			DllCall("GdiPlus\GdipImageGetFrameDimensionsCount"
			, "Ptr"  , this._pImage
			, "UInt*", dimensionsCount := 0)
			
			If (dimensionsCount == 0)
				Return 0
			
			VarSetCapacity(guidList, 16*dimensionsCount, 0)
			
			DllCall("GdiPlus\GdipImageGetFrameDimensionsList"
			, "Ptr"  , this._pImage
			, "Ptr"  , &guidList
			, "UInt" , dimensionsCount)
			
			Return dimensionsCount
		}
		
		
		; Get frame count for multiframe images (GIF/TIF).
		; Return value depends on argument 'extended':
		;   • False (default)  - returns frame count only from the first dimension
		;   • True             - returns object with all frame counts from all dimensions
		; Most images have only one dimension, so default behavior is usually sufficient.
		
		GetFrameCount( extended := False ) {
			Local
			
			dimensionsCount := this._GetMultiframeDimensions( guidList := "" )
			frameCountInfo  := {}
			
			Loop % dimensionsCount {
				; Determine dimension by first UInt
				dimensionId := NumGet(guidList, (A_Index-1)*16, "UInt")
				dimensionName := False ? ""
				:  (dimensionId == 0x6aedbd6d)  ?  "time"
				:  (dimensionId == 0x7462dc86)  ?  "page"
				:  (dimensionId == 0x84236f7b)  ?  "resolution"  :  "unknown"
				
				DllCall("GdiPlus\GdipImageGetFrameCount"
				, "Ptr"  ,  this._pImage
				, "Ptr"  , &guidList + (A_Index-1)*16
				, "UInt*",  frameCount := 0)
				
				If (extended == False)
					Return frameCount
				
				frameCountInfo[A_Index] := dimensionName
				frameCountInfo[dimensionName] := frameCount
			}
			
			Return frameCountInfo
		}
		
		
		; Selects active frame in multiframe image.
		;   • frame      - frame number to select (starting from 1)
		;   • dimension  - index of dimension (starting from 1)
		; Note: When you change active frame, all changes made to current frame will be lost.
		
		SelectFrame( frame, dimension := 1 ) {
			Local
			
			dimensionsCount := this._GetMultiframeDimensions( guidList := "" )
			
			If (dimension > dimensionsCount)
			|| (dimension < 1)
				Return -1
			
			Return DllCall("GdiPlus\GdipImageSelectActiveFrame"
			, "Ptr" ,  this._pImage
			, "Ptr" , &guidList + (dimension-1)*16
			, "UInt", (frame-1))
		}
		
		
		; Returns metadata property numeric ID by name (or vice versa)
		; For internal use in property-related methods below.
		; Pass "*" as first argument to get list of all known properties.
		; Argument 'getName' specifies the return type:
		;   •  0  - returns property numeric id;
		;   •  1  - returns property name;
		;   • -1  - toggle name to id and vice versa.
		
		_PropertyID( propId, getName := -1 ) {
			Local
			Static propertyById   := ""
			Static propertyByName := ""
			
			If (propertyById == "") {
				propertyById   := {}
				propertyByName := {}
				
				FileRead, propertyList, % A_LineFile "\..\OGdip_Properties.txt"
				
				propertyLines := StrSplit(propertyList, "`n", "`r")
				
				For index, propertyLine In propertyLines {
					If (propertyLine ~= "^\s*;")  ; Comment line
					|| (propertyLine ~= "^\s*$")  ; Empty line
						Continue
					
					If (0 != RegexMatch(propertyLine, "O)^(0x\w\w\w\w)\s+(\S+)\s+(\S+)\s+(\w+)", lineItems)) {
						propItemId   := Floor(lineItems[1])
						propItemName := lineItems[4]
						
						propertyById[propItemId] := propItemName
						propertyByName[propItemName] := propItemId
					}
				}
			}
			
			If (propId == "*")
				Return propertyById.Clone()
			
			If (propertyById.HasKey(propId))
				Return ((getName == 0)  ?  propId  :  propertyById[propId])
			
			If (propertyByName.HasKey(propId))
				Return ((getName == 1)  ?  propId  :  propertyByName[propId])
			
			Return  ; Not found
		}
		
		
		; Returns type-related metadata for given type name or numeric ID.
		; For internal use in property-related methods below.
		
		_PropertyTypeMeta( propType ) {
			Static typeMeta := ""
			
			If (typeMeta == "") {
				typeMeta := {}
				typeMeta[ 1] := typeMeta["Byte"]      := { typeId: 1,  tagType: "Byte"     ,  binType: "UChar",  binSize: 1}
				typeMeta[ 2] := typeMeta["ASCII"]     := { typeId: 2,  tagType: "ASCII"    ,  binType: "AStr" ,  binSize: 1}
				typeMeta[ 3] := typeMeta["Short"]     := { typeId: 3,  tagType: "Short"    ,  binType: "Short",  binSize: 2}
				typeMeta[ 4] := typeMeta["Long"]      := { typeId: 4,  tagType: "Long"     ,  binType: "UInt" ,  binSize: 4}
				typeMeta[ 5] := typeMeta["Rational"]  := { typeId: 5,  tagType: "Rational" ,  binType: "UInt" ,  binSize: 4}
				typeMeta[ 7] := typeMeta["Undefined"] := { typeId: 7,  tagType: "Undefined",  binType: "UChar",  binSize: 1}
				typeMeta[ 9] := typeMeta["SLONG"]     := { typeId: 9,  tagType: "SLONG"    ,  binType: "Int"  ,  binSize: 4}
				typeMeta[10] := typeMeta["SRational"] := { typeId:10,  tagType: "SRational",  binType: "Int"  ,  binSize: 4}
			}
			
			If (typeMeta.HasKey(propType) == True)
				Return typeMeta[propType]
			
			Return typeMeta["Undefined"]
		}
		
		
		; Farey sequence algorithm for fraction approximation.
		; Used in .SetProperty for Rational/SRational tag types.
		; Returns array of two numbers: numerator and denominator.
		; Precision sets maximum level of error:
		;   > _ApproximateFraction(-0.75)         =>  [-3, 4]
		;   > _ApproximateFraction(25)            =>  [25, 1]
		;   > _ApproximateFraction(3.1415926, 3)  =>  [22, 7]
		;   > _ApproximateFraction(3.1415926, 5)  =>  [355, 113]
		;   > _ApproximateFraction(3.1415926, 10) =>  [173551, 55243]
		
		_ApproximateFraction( n, precision := 10 ) {
			Local
			
			sign       := (n > 0) ? 1 : -1
			intPart    := Floor(Abs(n))
			fracPart   := Abs(n) - intPart
			denomLimit := 0xFFFFFF / (intPart+1)
			
			If (fracPart == 0)
			|| (fracPart == 1)
				Return [n, 1]
			
			An := 0, Ad := 1, Bn := 1, Bd := 1, maxDiff := 10**-precision
			Loop {
				Cn := (An + Bn), Cd := (Ad + Bd)
				Cv := Cn / Cd
				
				If (Cd > denomLimit)
				|| (Abs(fracPart - Cv) < maxDiff)
					Break
				
				If (fracPart < (Cn/Cd)) {
					Bn := Cn, Bd := Cd
				} Else {
					An := Cn, Ad := Cd
				}
			}
			
			Return [ sign * (intPart * Cd + Cn), Cd ]
		}
		
		
		; Get single metadata property item.
		; Returns an object with the following fields:
		;   .propId    - property numeric id
		;   .propName  - property name
		;   .value     - string or number, if property contains single item
		;   .binary    - raw binary data
		;   .length    - length in bytes of raw binary data
		;   .typeId    - data type numeric id
		;   .tagType   - data type name (as defined in GdiPlusImaging.h)
		;   .binType   - DllCall-compatible type
		;   .binSize   - size of binType
		; 
		; If .value contains empty string, this means property data contains multiple values,
		; and you need to read them from .binary field:
		;   > myFile.RawWrite( propInfo.GetAddress("binary"), propInfo.length )
		
		GetProperty( propId ) {
			Local
			
			propId := this._PropertyID(propId, 0)  ; Convert propId to numeric index
			
			success := DllCall("GdiPlus\GdipGetPropertyItemSize"
			, "Ptr"  , this._pImage
			, "UInt" , propId
			, "UInt*", propSize := 0)
			
			If (success != 0)
			|| (propSize == 0)
				Return success
			
			VarSetCapacity(propertyItem, propSize, 0)
			
			success := DllCall("GdiPlus\GdipGetPropertyItem"
			, "Ptr" ,  this._pImage
			, "UInt",  propId
			, "UInt",  propSize
			, "Ptr" , &propertyItem)
			
			If (success != 0)
				Return success
			
			itemPropId  := NumGet(propertyItem, 0           , "UInt")
			itemLength  := NumGet(propertyItem, 4           , "UInt")
			itemType    := NumGet(propertyItem, 8           , "Short")
			itemDataPtr := NumGet(propertyItem, 8+A_PtrSize , "Ptr")
			
			retItem := this._PropertyTypeMeta(itemType).Clone()
			retItem.propId   := itemPropId
			retItem.propName := this._PropertyID(itemPropId, 1)
			
			If (itemType == 2) {  ; ASCII
				retItem.value := StrGet(itemDataPtr, itemLength, "CP0")
				
			} Else {
				If ((itemType == 5) || (itemType == 10))  ; Rational: (Int1/Int2)
				&& (itemLength == 2*retItem.binSize)
				{
					numerator   := NumGet(0+itemDataPtr, 0              , retItem.binType)
					denominator := NumGet(0+itemDataPtr, retItem.binSize, retItem.binType)
					retItem.value := numerator / denominator
					
				} Else
				If (itemLength == retItem.binSize) {
					retItem.value := NumGet(0+itemDataPtr, 0, retItem.binType)
					
				} Else {
					retItem.value := ""
				}
			}	
			
			; Copy binary data
			retItem.length := itemLength
			retItem.binary := ""
			retItem.SetCapacity("binary", itemLength)
			
			DllCall("kernel32\RtlMoveMemory"
			, "Ptr" , retItem.GetAddress("binary")
			, "Ptr" , itemDataPtr
			, "UPtr", itemLength)
			
			Return retItem
		}
		
		
		; Gets all metadata properties.
		; Returns an object, where keys = property names, values = objects as in .GetProperty.
		
		GetAllProperties() {
			Local
			
			DllCall("GdiPlus\GdipGetPropertyCount"
			, "Ptr"  , this._pImage
			, "UInt*", propCount := 0)
			
			VarSetCapacity(propIdList, 4*propCount, 0)
			
			DllCall("GdiPlus\GdipGetPropertyIdList"
			, "Ptr"  ,  this._pImage
			, "UInt" ,  propCount
			, "Ptr"  , &propIdList)
			
			resultProps := {}
			
			Loop % propCount {
				propId   := NumGet(propIdList, (A_Index-1)*4, "UInt")
				propName := this._PropertyID(propId, 1)  ; Convert propId to name string
				propItem := this.GetProperty(propId)
				
				If (IsObject(propItem))
					resultProps[propName] := propItem
			}
			
			Return resultProps
		}
		
		
		; Removes given metadata property from the image.
		
		RemoveProperty( propId ) {
			DllCall("GdiPlus\GdipRemovePropertyItem"
			, "Ptr" , this._pImage
			, "UInt", this._PropertyID(propId, 0))
		}
		
		
		; Sets metadata property item.
		; PropId can be either numeric index or name of the property.
		; If 'length' property is omitted or zero, 'propValue' is treated as a single value.
		; To set binary data, pass variable to 'propValue' and specify 'length' in bytes.
		; Single-value Rational types are approximated to the nearest fraction.
		;   > img.SetProperty("Orientation", "Short", 3)  ; Rotate image 180°
		;   > img.SetProperty(0x5100, 4, varBinData, 64)  ; Set FrameDelay for animated GIF
		; 
		; Consult MSDN for types and other info, because some properties are far from obvious.
		; For example, 'Gamma' property requires specific fraction with numerator of 100000.
		; https://docs.microsoft.com/en-us/windows/win32/gdiplus/-gdiplus-constant-property-item-descriptions
		
		SetProperty( propId, propType, ByRef propValue, length := 0 ) {
			Local
			
			propId   := this._PropertyID(propId, 0)
			propMeta := this._PropertyTypeMeta(propType)
			propType := propMeta.typeId
			
			If (length == 0) {
				If (propType == 2) {  ; ASCII
					propSize := StrPut(propValue, "CP0")
					
					VarSetCapacity(binString, propSize, 0)
					
					StrPut(propValue, &binString, propSize, "CP0")
					propData := &binString
					
				} Else
				If (propType == 5)   ; Rational
				|| (propType == 10)  ; SRational
				{
					fraction := (propId == 0x0301)
					?  [ 100000, 100000 / propValue ]
					:  this._ApproximateFraction(propValue)
					
					VarSetCapacity(binFraction, 2*4, 0)
					NumPut(fraction[1], binFraction, 0, propMeta.binType)
					NumPut(fraction[2], binFraction, 4, propMeta.binType)
					
					propData := &binFraction
					propSize := 2*4
					
				} Else {
					VarSetCapacity(binValue, propMeta.binSize, 0)
					NumPut(propValue, binValue, 0, propMeta.binSize)
					
					propData := &binValue
					propSize := propMeta.binSize
				}
				
			} Else {  ; Binary data
				propSize := length
				propData := &propValue
			}
			
			VarSetCapacity(propItem, (8 + 2*A_PtrSize), 0)
			
			NumPut(propId  , propItem, 0, "UInt")
			NumPut(propSize, propItem, 4, "UInt")
			NumPut(propType, propItem, 8, "Short")
			NumPut(propData, propItem, 8+A_PtrSize, "Ptr")
			
			Return DllCall("GdiPlus\GdipSetPropertyItem"
			, "Ptr",  this._pImage
			, "Ptr", &propItem)
		}
	}
	
	
	
	; Bitmap class
	; ============
	; 
	; Constructors:
	;   Create bitmap from file:
	;     > bmp := new OGdip.Bitmap( filename [, useICM] )
	;   
	;   Create empty bitmap or bitmap from memory data:
	;     > bmp := new OGdip.Bitmap( w, h [, scan0ptr, pxFormat, stride] )
	;   
	;   Clone existing Bitmap or specified area of it:
	;     > bmp := new OGdip.Bitmap( oBitmap [, x, y, w, h, pxFormat] )
	;   
	;   Create empty bitmap with properties specified by Graphics object:
	;     > bmp := new OGdip.Bitmap( oGraphics, w, h )
	;   
	;   Create bitmap from Base64-string (second method is more efficient):
	;     > bmp := new OGdip.Bitmap( "*BASE64", strBase64 )
	;     > bmp := OGdip.Bitmap.FromBase64( strBase64 )
	;   
	;   Other constructors:
	;     > bmp := new OGdip.Bitmap( "*DDS", iDDSurfacePtr )                 ; From IDirectDrawSurface
	;     > bmp := new OGdip.Bitmap( "*DIB", bitmapinfoPtr, bmpDataPtr )     ; From GDI BITMAPINFO
	;     > bmp := new OGdip.Bitmap( "*HBITMAP", hBitmapPtr [, hPalette] )   ; From GDI HBITMAP
	;     > bmp := new OGdip.Bitmap( "*HICON", hIconPtr )                    ; From GDI HICON
	;     > bmp := new OGdip.Bitmap( "*RESOURCE", hInstance, resourceName )  ; From resource
	;     > bmp := new OGdip.Bitmap( "*STREAM", streamPtr [, useICM] )       ; From IStream
	;     > bmp := new OGdip.Bitmap( "*CLIPBOARD" )                          ; From Clipboard
	; 
	; Some methods and properties are inherited from Image class.
	; 
	; Methods:
	;   .Resize( width, height [, ipoMode, keepAspectRatio] )
	;   .GetHBITMAP( [bgColor] )
	;   .GetHICON()
	;   .GetPixel( px, py )
	;   .SetPixel( px, py, argb )
	;   .LockBits( [x, y, w, h, pxFormat] )
	;   .UnlockBits( objBitmapData)
	;   .SetResolution( xDPI, yDPI )
	;   .ConvertFormat( pxFormat [, paletteKey, dither, alphaLimit] )
	;   .GetHistogram( [channels, normalize, multiplier] )
	;   .ApplyEffect( effectName, effectArgs* )
	;   .FromClipboard()
	;   .ToClipboard()
	; 
	; Methods for internal use:
	;   ._GetStride( pxFormat, width )
	;   ._CreatePalette( paletteKey, ByRef paletteData, ByRef paletteType )
	
	Class Bitmap  Extends  OGdip.Image {
		
		; Calculates stride in bytes.
		; Used in scan0-constructor and .LockBits method.
		
		_GetStride( pxFormat, width ) {
			Local bitsPerPixel  := (pxFormat >> 8) & 0xFF
			Local bytesPerPixel := Ceil(bitsPerPixel / 8)
			
			Return (4 * Ceil(width * bytesPerPixel / 4))
		}
		
		
		__New( source, args* ) {
			Local
			Global OGdip
			
			pBitmap := 0
			
			If (IsObject(source) == True) {
				If ((source.Base == OGdip.Bitmap)
				||  (source.Base == OGdip.Metafile)
				||  (source.Base == OGdip.Image))
				{
					; New( oImage, x, y, w, h [, pxFormat] )
					If (args.Length() >= 4) {
						pxFormat := (args.Length() < 5)
						?  source.GetPixelFormat()
						:  this._GetPixelFormatByName( args[5] )
						
						DllCall("GdiPlus\GdipCloneBitmapAreaI"
						, "UInt", args[1]  ; x
						, "UInt", args[2]  ; y
						, "UInt", args[3]  ; w
						, "UInt", args[4]  ; h
						, "UInt", pxFormat
						, "Ptr" , source._pImage
						, "Ptr*", pBitmap)
						
					} Else {
						DllCall("GdiPlus\GdipCloneImage"
						, "Ptr" , source._pImage
						, "Ptr*", pBitmap)
					}
					
				} Else
				If (source.Base == OGdip.Graphics)
				&& (args.Length() == 2)
				{
					DllCall("GdiPlus\GdipCreateBitmapFromGraphics"
					, "Int" , args[1]  ; width
					, "Int" , args[2]  ; height
					, "Ptr" , OGdip.Graphics._pGraphics
					, "Ptr*", pBitmap)
				}
				
			} Else
			If (source == "*BASE64") {
				; This constructor wasn't finished and have not created Bitmap instance,
				; so it does not need to call __Delete afterwards.
				this.Base := False
				Return OGdip.Bitmap.FromBase64( args* )
				
			} Else
			If (source == "*DDS") {
				DllCall("GdiPlus\GdipCreateBitmapFromDirectDrawSurface"
				, "Ptr" , args[1]  ; IDirectDrawSurface7*
				, "Ptr*", pBitmap)
				
			} Else
			If (source == "*DIB") {
				DllCall("GdiPlus\GdipCreateBitmapFromGdiDib"
				, "Ptr" , args[1]  ; BITMAPINFO
				, "Ptr" , args[2]  ; Pixel data
				, "Ptr*", pBitmap)
				
			} Else
			If (source == "*HBITMAP") {
				DllCall("GdiPlus\GdipCreateBitmapFromHBITMAP"
				, "Ptr" , args[1]                ; HBITMAP
				, "Ptr" , args[2] ? args[2] : 0  ; HPALETTE
				, "Ptr*", pBitmap)
				
			} Else
			If (source == "*HICON") {
				DllCall("GdiPlus\GdipCreateBitmapFromHICON"
				, "Ptr" , args[1]  ; HICON
				, "Ptr*", pBitmap)
				
			} Else
			If (source == "*RESOURCE") {
				; Alternatively, parameter #2 can consist of the resource identifier
				; in the low-order word and zero in the high-order word.
				; Note that GDI+ can load only resources in BMP format.
				DllCall("GdiPlus\GdipCreateBitmapFromResource"
				, "Ptr" , args[1]  ; HINSTANCE
				, "WStr", args[2]  ; Bitmap name
				, "Ptr*", pBitmap)
				
			} Else
			If (source == "*STREAM") {
				useICM := args.HasKey(2)  ?  args[2]  :  False
				
				DllCall("GdiPlus\GdipCreateBitmapFromStream" . (useICM ? "ICM" : "")
				, "Ptr" , args[1]  ; IStream*
				, "Ptr*", pBitmap)
				
			} Else
			If (source == "*CLIPBOARD") {
				this.Base := False
				Return OGdip.Bitmap.FromClipboard()
				
			} Else
			If (args.Length() >= 1)
			&& (source ~= "^\d+$")
			{
				width  := source
				height := args[1]
				scan0  := args.HasKey(2)  ?  args[2]  :  0
				format := args.HasKey(3)  ?  args[3]  :  "ARGB32"
				format := this._GetPixelFormatByName(format)
				stride := args.HasKey(4)  ?  args[4]  :  this._GetStride(format, width)
				
				DllCall("GdiPlus\GdipCreateBitmapFromScan0"
				, "Int" , width
				, "Int" , height
				, "Int" , stride
				, "UInt", format
				, "Ptr" , scan0
				, "Ptr*", pBitmap)
				
			} Else {
				useICM := args.HasKey(1)  ?  args[1]  :  False
				
				DllCall("GdiPlus\GdipCreateBitmapFromFile" . (useICM ? "ICM" : "")
				, "WStr", source
				, "Ptr*", pBitmap)
			}
			
			
			If (pBitmap == 0) {
				this.Base := False  ; Avoid calling __Delete
				Return False
			}
			
			this._pImage := pBitmap
			
			If (OGdip.autoGraphics == True)
				this.GetGraphics()
		}
		
		
		FromBase64( ByRef strBase64, useICM := False ) {
			Local
			Global OGdip
			
			pBitmap   := 0
			dataSize  := OGdip._Base64ToBinary( strBase64, binBuffer := "" )
			streamPtr := OGdip._MemToStream( binBuffer, dataSize )
			
			DllCall("GdiPlus\GdipCreateBitmapFromStream" . (useICM ? "ICM" : "")
			, "Ptr" , streamPtr  ; IStream*
			, "Ptr*", pBitmap)
			
			ObjRelease(streamPtr)
			
			If (pBitmap == 0)
				Return False
			
			Return { Base: OGdip.Bitmap, _pImage: pBitmap }
		}
		
		
		; Put bitmap image to GUI control (picture or button).
		; Corresponding style will be set for picture control (0x0E for picture).
		; Set style 0x80 (BS_BITMAP) for a button to show only image without text.
		; 
		; If argument 'scale' is set, image would be scaled:
		;   • Numeric bit-flags - see in the code below;
		;   • Named preset value - see in the code below;
		;   • Text in format "W:H" to set exact width and height.
		
		SetToControl( hwndCtrl, scale := "", bgColor := 0xFFFFFFFF ) {
			Local
			
			If (Not DllCall("IsWindow", "Ptr", hwndCtrl))
				ControlGet, hwndCtrl, HWND,, % hwndCtrl, A
			
			If (hwndCtrl == "")
				Return "Control not found"
			
			WinGetClass, ctrlClass, % ("ahk_id " . hwndCtrl)
			ControlGet,  ctrlStyle, Style,,, % ("ahk_id " . hwndCtrl)
			
			If (ctrlClass = "Button") {
				; Control, Style, +0x80,, % ("ahk_id" . hwndCtrl)  ; 0x80 - BS_BITMAP
				msgId := 0x00F7  ; BM_SETIMAGE
				
			} Else
			If (ctrlClass = "Static") {
				Control, Style, +0x0E,, % ("ahk_id" . hwndCtrl)  ; 0x0E - SS_BITMAP
				msgId := 0x0172  ; STM_SETIMAGE
				
			} Else {
				Return "Unsupported control type"
			}
			
			
			hBitmap := this.GetHBITMAP(bgColor)
			
			If (hBitmap == 0)
				Return "Can't create HBITMAP"
			
			; Resize the bitmap if needed
			flags := (scale == "") ?  0
			:  (scale = "Fit")     ?  0x1A  ; Keep aspect ratio, best fit full image;
			:  (scale = "FitDown") ?  0x15  ; Keep aspect ratio, best fit full image (only scale down);
			:  (scale = "W")       ?  0x13  ; Keep aspect ratio, best fit by width
			:  (scale = "H")       ?  0x1C  ; Keep aspect ratio, best fit by height
			:  (scale = "Cover")   ?  0x2A  ; Keep aspect ratio, cover all control area;
			:  (scale = "Stretch") ?  0x0F  ; Do not keep aspect ratio, stretch to all control area;
			:   scale
			
			If (flags != 0) {
				ControlGetPos,,, ctlW, ctlH,, % ("ahk_id " . hwndCtrl)
				bmpW := this.Width,  bmpH := this.Height
				
				If (flags ~= ":") {
					flags := StrSplit(flags, ":")
					resultW := 0+flags[1]
					resultH := 0+flags[2]
					
				} Else {
					factorW := ctlW / bmpW                       ; 0x00 - Do not scale width
					factorW := ((flags & 3) == 3)  ?  factorW    ; 0x01 - Scale width down
					:  (flags & 2)  ?  Max(1, factorW)           ; 0x02 - Scale width up
					:  (flags & 1)  ?  Min(1, factorW)  :  1     ; 0x03 - Always scale width
					
					factorH := ctlH / bmpH                       ; 0x00 - Do not scale height
					factorH := ((flags & 12) == 12)  ?  factorH  ; 0x04 - Scale height down
					:  (flags & 8)  ?  Max(1, factorH)           ; 0x08 - Scale height up
					:  (flags & 4)  ?  Min(1, factorH)  :  1     ; 0x0C - Always scale height
					
					factorR := False ? 0                               ; 0x00 - Do not keep aspect ratio
					:  (flags & 0x10)  ?  Min(factorW, factorH)        ; 0x10 - Keep ratio, choose minimum size
					:  (flags & 0x20)  ?  Max(factorW, factorH)  :  0  ; 0x20 - Keep ratio, choose maximum size
					
					resultW := bmpW * ((factorR == 0)  ?  factorW  :  factorR)
					resultH := bmpH * ((factorR == 0)  ?  factorH  :  factorR)
				}
				
				hResizedBitmap := DllCall("CopyImage"
				, "Ptr" , hBitmap
				, "UInt", 0
				, "Int" , resultW
				, "Int" , resultH
				, "UInt", 0x0C     ; flags = LR_COPYDELETEORG | LR_COPYRETURNORG
				, "Ptr")
				
				If (hResizedBitmap != 0)
					hBitmap := hResizedBitmap
			}
			
			
			hPrevBitmap := DllCall("SendMessage"
			, "Ptr" , hwndCtrl
			, "UInt", msgId
			, "UInt", 0
			, "Ptr" , hBitmap)
			
			DllCall("DeleteObject", "Ptr", hPrevBitmap)
			
			; Assuming no one will use GDI+ on systems earlier than XP
			If (A_OSType != "WIN_XP")
				DllCall("DeleteObject", "Ptr", hBitmap)
			
			Return hBitmap
		}
		
		
		GetHBITMAP( bgColor := 0x0 ) {
			Local
			
			DllCall("GdiPlus\GdipCreateHBITMAPFromBitmap"
			, "Ptr" , this._pImage
			, "Ptr*", hBitmap := 0
			, "UInt", bgColor)
			
			Return hBitmap
		}
		
		
		GetHICON() {
			Local
			
			DllCall("GdiPlus\GdipCreateHICONFromBitmap"
			, "Ptr" , this._pImage
			, "Ptr*", hIcon := 0)
			
			Return hIcon
		}
		
		
		; GetPixel / SetPixel
		; Returned value of GetPixel may depend on pixelformat of the Bitmap.
		; To read/write pixel values in bulk, consider using .LockBits method.
		
		GetPixel( px, py ) {
			Local
			
			DllCall("GdiPlus\GdipBitmapGetPixel"
			, "Ptr"  , this._pImage
			, "Int"  , px
			, "Int"  , py
			, "UInt*", argb := 0)
			
			Return argb
		}
		
		SetPixel( px, py, argb ) {
			DllCall("GdiPlus\GdipBitmapSetPixel"
			, "Ptr" , this._pImage
			, "Int" , px
			, "Int" , py
			, "UInt", argb)
		}
		
		
		; Locks rectangular area of bitmap to a temporary buffer.
		; Locked area can then be read and written directly.
		; Requires method .UnlockBits to be called afterwards.
		; Returns object with the fields of BitmapData.
		; Specify all zeroes for x,y,w,h to lock entire bitmap.
		
		LockBits(x := 0, y := 0, w := 0, h := 0, pxFormat := 0) {
			Local
			Global OGdip
			
			pxFormat := (pxFormat == 0)
			?  this.GetPixelFormat()
			:  this._GetPixelFormatByName(pxFormat)
			
			If ((w == 0) || (h == 0)) {
				w := (w != 0)  ?  w  :  (this.Width  - x)
				h := (h != 0)  ?  h  :  (this.Height - y)
			}
			
			OGdip._CreateBinArray( [x, y, w, h],  lockRect := "",  "Int" )
			
			objBitmapData := { _binBData: "" }
			objBitmapData.SetCapacity("_binBData", 16 + 2*A_PtrSize)
			binBDataPtr := objBitmapData.GetAddress("_binBData")
			
			DllCall("GdiPlus\GdipBitmapLockBits"
			, "Ptr"  ,  this._pImage
			, "Ptr"  , &lockRect
			, "UInt" ,  0x03          ; ImageLockMode : 1:Read | 2:Write
			, "UInt" ,  pxFormat
			, "Ptr"  ,  binBDataPtr)
			
			objBitmapData.width  := NumGet(binBDataPtr+0,  0, "UInt")
			objBitmapData.height := NumGet(binBDataPtr+0,  4, "UInt")
			objBitmapData.stride := NumGet(binBDataPtr+0,  8, "UInt")
			objBitmapData.format := NumGet(binBDataPtr+0, 12, "UInt")
			objBitmapData.scan0  := NumGet(binBDataPtr+0, 16, "Ptr")
			
			Return objBitmapData
		}
		
		
		; Unlocks area previously locked by .LockBits.
		; Pass the object you received from .LockBits as an argument.
		
		UnlockBits( objBitmapData ) {
			DllCall("GdiPlus\GdipBitmapUnlockBits"
			, "Ptr", this._pImage
			, "Ptr", objBitmapData.GetAddress("_binBData"))
		}
		
		
		SetResolution( xDPI, yDPI ) {
			DllCall("GdiPlus\GdipBitmapSetResolution"
			, "Ptr"  , this._pImage
			, "Float", xDPI
			, "Float", yDPI)
		}
		
		
		; Return scaled version of the bitmap.
		; See Graphics.SetOptions for 'ipoMode'.
		; Note: scaling up with 'Nearest' mode can produce edge artifacts.
		
		Resize( width, height, ipoMode := "", keepAspectRatio := True ) {
			Local
			Global OGdip
			
			scaleFactor := Min( (width / this.Width), (height / this.Height) )
			
			newWidth  := keepAspectRatio  ?  Floor(this.Width  * scaleFactor)  :  width
			newHeight := keepAspectRatio  ?  Floor(this.Height * scaleFactor)  :  height
			
			sizedCopy := new OGdip.Bitmap(newWidth, newHeight)
			sizedCopy.GetGraphics()
			sizedCopy.G.SetOptions( {interpolate: ipoMode} )
			sizedCopy.G.DrawImage(this, 0, 0, newWidth, newHeight)
			
			Return sizedCopy
		}
		
		
		; Creates palette by given key.
		; Resulting binary palette and its type will be written in ByRef arguments.
		;   > bmp._CreatePalette( [argb*], pd, pt )  ; Custom palette from array of ARGB colors
		;   > bmp._CreatePalette(  128   , pd, pt )  ; Optimal palette with given number of colors
		;   > bmp._CreatePalette( "BW"   , pd, pt )  ; Fixed, system predefined palette
		
		_CreatePalette(paletteKey, ByRef paletteData, ByRef paletteType) {
			Local
			Global OGdip
			Static sysPalettes := ""
			
			If (sysPalettes == "") {
				sysPalettes := {}
				sysPalettes["BW"]        := {paletteType: 2, colors:  2, useTransparent: 0}
				sysPalettes["Halftone2"] := {paletteType: 3, colors: 16, useTransparent: 0}
				sysPalettes["Halftone3"] := {paletteType: 4, colors: 35, useTransparent: 1}
				sysPalettes["Halftone4"] := {paletteType: 5, colors: 72, useTransparent: 1}
				sysPalettes["Halftone5"] := {paletteType: 6, colors:133, useTransparent: 1}
				sysPalettes["Halftone6"] := {paletteType: 7, colors:224, useTransparent: 1}
				sysPalettes["RGB-676"]   := {paletteType: 8, colors:252, useTransparent: 1}
				sysPalettes["RGB-884"]   := {paletteType: 9, colors:256, useTransparent: 0}
				
				sysPalettes["System"] := sysPalettes["Halftone2"]
				sysPalettes["Web"]    := sysPalettes["Halftone6"]
			}
			
			useTransparent := 0  ; Whether to include transparent color into palette.
			optimalColors  := 0  ; Number of optimal colors with Optimal palette.
			bitmapPtr      := 0  ; Source bitmap for creating Optimal palette.
			
			If (IsObject(paletteKey) == True) {
				paletteType := 0  ; PaletteTypeCustom
				colorsCount := paletteKey.Length()
				
				paletteData := ""
				OGdip._CreateBinArray(paletteKey, paletteData, "UInt", 8)
				
			} Else
			If (sysPalettes.HasKey(paletteKey) == True) {
				sysPalette := sysPalettes[paletteKey]
				
				paletteType    := sysPalette.paletteType
				useTransparent := sysPalette.useTransparent
				colorsCount    := sysPalette.colors + useTransparent
				
			} Else {
				paletteType    := 1  ; PaletteTypeOptimal
				useTransparent := (paletteKey < 256)
				colorsCount    :=  paletteKey + useTransparent
				optimalColors  :=  colorsCount
				bitmapPtr      :=  this._pImage
			}
			
			If (paletteType != 0)
				VarSetCapacity(paletteData, (4 + 4 + colorsCount*4), 0)
			
			NumPut(colorsCount, paletteData, 4, "UInt")
			
			DllCall("GdiPlus\GdipInitializePalette"
			, "Ptr" , &paletteData
			, "UInt",  paletteType
			, "Int" ,  optimalColors
			, "Int" ,  useTransparent
			, "Ptr" ,  bitmapPtr)
		}
		
		
		; Convert bitmap pixel format. Creates palette if necessary.
		;   • format      - Target format, see ._GetPixelFormatByName method.
		;   • paletteKey  - Palette key for indexed formats, see ._CreatePalette method.
		;   • dither      - 1 for diffusion dither, 0 for no dither, or preset name, see below.
		;   • alphaLimit  - Threshold of alpha value (0..255), pixels below it will be transparent.
		; 
		;   > bmp.ConvertFormat("ARGB32")
		;   > bmp.ConvertFormat("I1", "BW", True)
		;   > bmp.ConvertFormat("I8", "Halftone4", "4x4", 255)
		
		ConvertFormat( format, paletteKey := 256, dither := True, alphaLimit := 128 ) {
			Local
			
			oldFormat := this.GetPixelFormat()
			newFormat := this._GetPixelFormatByName(format)
			
			paletteType := 0
			palettePtr  := 0
			
			If (newFormat & 0x010000) {  ; New format is indexed
				paletteData := ""
				this._CreatePalette(paletteKey, paletteData, paletteType)
				
				palettePtr := &paletteData
			}
			
			oldBitDepth := (oldFormat >> 8) & 0xFF
			newBitDepth := (newFormat >> 8) & 0xFF
			
			If (newBitDepth >= oldBitDepth) {
				dither := 0  ; DitherType: None
				
			} Else
			If (newBitDepth == 16)
			&& (dither == "4x4")
			{
				dither := 2  ; Ordered4x4, special case for 16-bpp format
				
			} Else
			If (paletteType >= 2) {
				dither := False ? ""
				:  (dither = "4x4")   ?  2        ; Ordered4x4
				:  (dither = "8x8")   ?  3        ; Ordered8x8
				:  (dither = "16x16") ?  4        ; Ordered16x16
				:  (dither = "S4")    ?  5        ; Spiral4x4
				:  (dither = "S8")    ?  6        ; Spiral8x8
				:  (dither = "DS4")   ?  7        ; DualSpiral4x4
				:  (dither = "DS8")   ?  8        ; DualSpiral8x8
				:  (dither = True)    ?  9  :  1  ; Diffusion : Solid
				
			} Else {
				dither := (dither == True) ? 9 : 1
			}
			
			DllCall("GdiPlus\GdipBitmapConvertFormat"
			, "Ptr"  ,  this._pImage
			, "UInt" ,  newFormat
			, "UInt" ,  dither
			, "UInt" ,  paletteType
			, "Ptr"  ,  palettePtr
			, "Float", (alphaLimit * 100 / 255))
		}
		
		
		; Get histogram of selected channels of bitmap.
		; Argument 'normalize' acts as follows:
		;   • "Sum"     - total sum of each channel will be equal to 1
		;   • "Max"     - maximum value of each channel will be equal to 1
		;   • "MaxAll"  - maximum value of all channels will be equal to 1
		; After normalization, each value will be multiplied by 'multiplier'.
		; 
		; Returns object with following fields:
		;   • channels - array of channel names (ex. ["R", "G", "B"])
		;   • entries  - number of entries in each channel (usually 256)
		;   • <N>      - channel data by numeric index N
		;   • <S>      - channel data by name S
		; Each channel data is zero-based (!) array of values, plus 'max' field.
		; 
		;   > hist := bmp.GetHistogram()
		;   > hist.channels  =>  ["A", "R", "G", "B"]
		;   > Format( "There are {} pixels where Red value is 0", hist.R[0] )
		;   > Format( "Maximum value of Blue channel is {}"     , hist[4].max )
		;   
		;   > hist := bmp.GetHistogram("RGB", "MaxAll", 255)
		;   > Format( "Max: R={1:d}, G={2:d}, B={3:d}", hist.R.max, hist.B.max, hist.G.max )
		
		GetHistogram( channels := "ARGB", normalize := "", multiplier := 1 ) {
			Local
			
			params := False ? ""
			:  (channels = "PARGB") ? {histType: 1, channelNames: ["A", "R", "G", "B"]}
			:  (channels = "RGB"  ) ? {histType: 2, channelNames: ["R", "G", "B"]}
			:  (channels = "Gray" ) ? {histType: 3, channelNames: ["Gray"]}
			:  (channels = "B"    ) ? {histType: 4, channelNames: ["B"]}
			:  (channels = "G"    ) ? {histType: 5, channelNames: ["G"]}
			:  (channels = "R"    ) ? {histType: 6, channelNames: ["R"]}
			:  (channels = "A"    ) ? {histType: 7, channelNames: ["A"]}
			:                         {histType: 0, channelNames: ["A", "R", "G", "B"]}
			
			DllCall("GdiPlus\GdipBitmapGetHistogramSize"
			, "UInt" , params.histType
			, "UInt*", entriesNum := 0)
			
			channelsNum  := params.channelNames.Length()
			channelBytes := entriesNum * 4
			VarSetCapacity(histogramData, channelsNum * channelBytes, 0)
			
			DllCall("GdiPlus\GdipBitmapGetHistogram"
			, "Ptr" , this._pImage
			, "UInt", params.histType
			, "UInt", entriesNum
			, "Ptr" , ((channelsNum < 1)  ?  0  :  (&histogramData + 0 * channelBytes))
			, "Ptr" , ((channelsNum < 2)  ?  0  :  (&histogramData + 1 * channelBytes))
			, "Ptr" , ((channelsNum < 3)  ?  0  :  (&histogramData + 2 * channelBytes))
			, "Ptr" , ((channelsNum < 4)  ?  0  :  (&histogramData + 3 * channelBytes)) )
			
			; Parse data
			histogram := {}
			histogram.channels := params.channelNames.Clone()
			histogram.entries  := entriesNum
			
			channelMaxAll := 0
			
			Loop % channelsNum {
				channelMax := 0
				
				channelName := params.channelNames[A_Index]
				
				channelArray := []
				histogram[A_Index]     := channelArray
				histogram[channelName] := channelArray
				
				channelByteOffset := (A_Index-1) * channelBytes
				
				Loop % entriesNum {
					value := NumGet(histogramData, channelByteOffset + (A_Index-1) * 4, "UInt")
					channelArray[A_Index-1] := value
					
					channelMax := Max(channelMax, value)
				}
				
				channelArray.maxValue := channelMax
				channelMaxAll := Max(channelMaxAll, channelMax)
			}
			
			If (normalize == "")
				Return histogram
			
			
			pixelCount := this.Width * this.Height
			
			; Normalize data
			Loop % channelsNum {
				channelArray := histogram[A_Index]
				
				normFactor := False ? ""
				: (normalize = "Max")    ? (channelArray.maxValue)
				: (normalize = "MaxAll") ?  channelMaxAll
				:                           pixelCount
				
				normFactor := multiplier / normFactor
				
				Loop % entriesNum {
					channelArray[A_Index-1] *= normFactor
				}
				
				channelArray.maxValue *= normFactor
			}
			
			Return histogram
		}
		
		
		; Applies effect of given name with given arguments.
		;   > bmp.ApplyEffect("Blur", 5)       ; Blur image with radius 5
		;   > bmp.ApplyEffect("Tint", 0, 100)  ; Tint red
		;   > bmp.ApplyEffect("HSL",, -100)    ; Desaturate - note omitted 1st and 3rd arguments
		; 
		; To avoid unnecessary creating/destroying objects,
		; to use effect more than once or with several bitmaps,
		; to have more control (ex. applying effect only to selected area),
		; consider creating instance of OGdip.Effect.<Name> instead of this shortcut.
		
		ApplyEffect( effectName, effectArgs* ) {
			Local
			Global OGdip
			
			oEffect := new OGdip.Effect( effectName, effectArgs* )
			oEffect.ApplyToBitmap(this)
		}
		
		
		; Gets Bitmap from clipboard. Used in constructor. Does not support alpha.
		
		FromClipboard() {
			Local
			Global OGdip
			
			cbBMP := DllCall("IsClipboardFormatAvailable", "UInt", 0x2)  ; 0x2 - CF_BITMAP
			
			If (cbBMP == 0)
				Return 0
			
			If Not DllCall("OpenClipboard", "UPtr", A_ScriptHwnd)
				Return -1
			
			
			hCBData := DllCall("GetClipboardData", "UInt", 0x2,  "UPtr")
			hBitmap := DllCall("CopyImage"
			, "Ptr" , hCBData
			, "UInt", 0        ; type = IMAGE_BITMAP
			, "Int" , 0        ; width
			, "Int" , 0        ; height
			, "UInt", 0x2004   ; flags = LR_CREATEDIBSECTION | LR_COPYRETURNORG
			, "Ptr")
			
			DllCall("CloseClipboard")
			
			
			newBitmap := new OGdip.Bitmap("*HBITMAP", hBitmap)
			DllCall("DeleteObject", hBitmap)
			
			Return newBitmap
		}
		
		
		; Puts Bitmap to clipboard. Does not support alpha.
		
		ToClipboard() {
			Local
			
			If Not (hBitmap := this.GetHBITMAP())
				Return -1
			
			If Not (hClip := DllCall("OpenClipboard", "Ptr", A_ScriptHwnd))
				Return -2
			
			If Not (DllCall("EmptyClipboard")) {
				DllCall("CloseClipboard")
				Return -3
			}
			
			gdiHBitmap := DllCall("CopyImage"
			, "Ptr" , hBitmap
			, "UInt", 0        ; type = IMAGE_BITMAP
			, "Int" , 0        ; width
			, "Int" , 0        ; height
			, "UInt", 0x0C     ; flags = LR_COPYDELETEORG | LR_COPYRETURNORG
			, "Ptr")
			
			success := DllCall("SetClipboardData"
			, "UInt", 0x02         ; CF_BITMAP
			, "Ptr" , gdiHBitmap)
			
			If (Not success) {
				DllCall("CloseClipboard")
				Return -4
			}
			
			DllCall("CloseClipboard")
			Return 0
		}
	}
	
	
	; Cached bitmap class
	; ===================
	; 
	; Cached bitmap stores data in a format optimized for certain context.
	; This increases performance, but reduces flexibility:
	; for example, you cannot transform bitmap when drawing.
	;   > bmpCache := new OGdip.CachedBitmap( bmpSource, dstGraphics )
	;   > dstGraphics.DrawImage( bmpCache, 100, 100 )
	
	Class CachedBitmap {
		
		__New( oBitmap, oGraphics := -1 ) {
			If (oGraphics == -1)
				oGraphics := oBitmap.Graphics
			
			DllCall("GdiPlus\GdipCreateCachedBitmap"
			, "Ptr" , oBitmap._pImage
			, "Ptr" , oGraphics._pGraphics
			, "Ptr*", pCachedBitmap := 0)
			
			
			If (pCachedBitmap == 0) {
				this.Base := False  ; Avoid calling __Delete
				Return False
			}
			
			this._pCachedBitmap := pCachedBitmap
		}
		
		__Delete() {
			DllCall("GdiPlus\GdipDeleteCachedBitmap"
			, "Ptr", this._pCachedBitmap)
		}
	}
	
	
	
	; Effect class
	; ============
	;
	; Super-class for all available bitmap effects.
	; Effects API available only in GDI+ v1.1 or higher.
	; 
	; Constructors:
	;   > oEffect := new OGdip.Effect.Blur( 5 )     ; Create Blur effect with 5px radius.
	;   > oEffect := new OGdip.Effect( "Blur", 5 )  ; Same, but creates effect by name.
	; 
	; Methods:
	;   .SetParameters( args* )
	;   .ApplyToBitmap( oBitmap [, x, y, w, h] )
	;   .GetRawEffectParameters( paramsData, paramsSize )
	; 
	; Effects:
	;   .Blur( radius, expandEdge )
	;   .BrightnessContrast( brightness, contrast )
	;   .ColorBalance( cyanRed, magentaGreen, yellowBlue )
	;   .ColorCurve( adjustment, value, channel )
	;   .ColorLUT( lutR, lutG, lutB, lutA )
	;   .ColorMatrix( matrix )
	;   .HSL( hue, saturation, lightness )
	;   .Levels( highlight, midtone, shadow )
	;   .RedEyeCorrection( rectArray [, rectArrays...] )
	;   .Sharpen( radius, amount )
	;   .Tint( hue, amount )
	; 
	; Methods for internal use:
	;   ._SetEffectParameters( paramsPtr, paramsSize )
	;   ._CreateColorMatrix( matrix, &pMatrix )
	
	Class Effect {
		
		__New( args* ) {
			Local
			Global OGdip
			
			If (this.Base == OGdip.Effect) {    ; > new OGdip.Effect(...)  was called,
				; This constructor acts as a proxy and does not create Effect object by itself,
				; so it does not need to call __Delete method when it goes out of scope.
				this.Base := False
				
				effectName := args.RemoveAt(1)  ; creating effect by subclass name.
				
				If (OGdip.Effect.HasKey(effectName) == True)        ; Element is present
				&& (IsFunc(OGdip.Effect[effectName]) == False)      ; Element is not a func/method
				&& (OGdip.Effect[effectName].Base == OGdip.Effect)  ; Element is a subclass
				{
					effectSubclass := OGdip.Effect[effectName]
					Return new effectSubclass(args*)
					
				} Else {
					Return False
				}
			}
			
			; All subclasses share one constructor - this one.
			; It uses Static properties from subclasses to instantiate.
			
			If (this._effectGuid == "")
				Return False
			
			OGdip._StringToGuid(this._effectGuid, guidBinary := "")
			pEffect := 0
			
			; In 32-bit GdipCreateEffect requires four UInts, in 64-bit - pointer to GUID.
			; Discovered thanks to  Gdip_All.ahk  and  AutoIt GdiPlus UDF library.
			; Special thanks to @robodesign and @LarsJ
			; https://www.autoitscript.com/forum/topic/159683-t/?tab=comments#comment-1158796
			
			If (A_PtrSize == 4) {
				DllCall("GdiPlus\GdipCreateEffect"
				, "UInt", NumGet(guidBinary,  0, "UInt")
				, "UInt", NumGet(guidBinary,  4, "UInt")
				, "UInt", NumGet(guidBinary,  8, "UInt")
				, "UInt", NumGet(guidBinary, 12, "UInt")
				, "Ptr*", pEffect)
				
			} Else {
				DllCall("GdiPlus\GdipCreateEffect"
				, "Ptr" , &guidBinary
				, "Ptr*",  pEffect)
			}
			
			
			If (pEffect == 0) {
				this.Base := False  ; Avoid calling __Delete
				Return False
			}
			
			this._pEffect := pEffect
			this._params := this._defaultParams.Clone()
			this.SetParameters(args*)
		}
		
		
		__Delete() {
			DllCall("GdiPlus\GdipDeleteEffect"
			, "Ptr", this._pEffect)
		}
		
		
		_SetEffectParameters( paramsPtr, paramsSize ) {
			DllCall("GdiPlus\GdipSetEffectParameters"
			, "Ptr" , this._pEffect
			, "Ptr" , paramsPtr
			, "UInt", paramsSize)
		}
		
		
		; Applies effect to bitmap.
		;   > eff.ApplyToBitmap( bmp )             ; Applies effect to the whole bitmap
		;   > eff.ApplyToBitmap( bmp,  x,y,w,h )   ; Applies effect to the given area of a bitmap
		;   > eff.ApplyToBitmap( bmp, [x,y,w,h] )  ; Same, but with an array as a single argument
		
		ApplyToBitmap( oBitmap, args* ) {
			Local
			Global OGdip
			
			roiRectPtr := 0
			
			If (args.Length() > 0) {
				args := OGdip._FlattenArray(args)
				
				If (args.Length() >= 4) {
					; Argument for the function is pair of points, not an actual RECT:
					x1 := args[1]
					y1 := args[2]
					x2 := args[1] + args[3]
					y2 := args[2] + args[4]
					
					; Arrange coordinates in proper order, in case width/height was negative.
					; Good to know that ROI argument works fine with out-of-bounds values.
					roi := [ Min(x1,x2), Min(y1,y2), Max(x1,x2), Max(y1,y2) ]
					
					OGdip._CreateBinArray(roi, roiRect := "", "UInt")
					roiRectPtr := &roiRect
				}
			}
			
			DllCall("GdiPlus\GdipBitmapApplyEffect"
			, "Ptr" , oBitmap._pImage
			, "Ptr" , this._pEffect
			, "Ptr" , roiRectPtr
			, "UInt", 0   ; UseAuxData
			, "Ptr" , 0   ; Effect.auxData
			, "UInt", 0)  ; Effect.auxDataSize
		}
		
		
		; Returns binary data and size of Effect parameters.
		
		GetRawEffectParameters( ByRef paramsData, ByRef paramsSize ) {
			Local
			
			DllCall("GdiPlus\GdipGetEffectParametersSize"
			, "Ptr"  , this._pEffect
			, "UInt*", paramsSize := 0)
			
			VarSetCapacity(paramsData, paramsSize, 0)
			
			DllCall("GdiPlus\GdipGetEffectParameters"
			, "Ptr"  , this._pEffect
			, "UInt*", paramsSize
			, "Ptr"  , &paramsData)
		}
		
		
		; Creates 5*5 ColorMatrix.
		; Used in effect ColorMatrix  and  image attribute ColorMatrix.
		; 
		; Argument 'matrix' should be an array of up to four color vectors [VR, VG, VB, VA].
		; Each vector is an array of up to five values [mR, mG, mB, mA, offV].
		; Omitted vectors and values will be set to identity values.
		; 
		; Resulting value for a color channel = N*mR + N*mG + N*mB + N*mA + offV*255.
		; For example:
		;   Source image pixel color is RGBA  = (180, 140, 100, 255)
		;   Matrix VR (red channel) vector    = [ 0.5, 1, -0.25, 0, 0.1 ]
		;   Resulting pixel red channel value = 180*0.5 + 140*1 - 0.25*100 + 0.1*255  =  230
		; 
		; Examples (note omitted channels and values):
		;   • [ [1,0,0], [1,0,0], [1,0,0] ]  - extracts red channel
		;   • [ [-1,0,0,0,1] ]               - inverts red channel
		;   • [ [0,0,1], "", [1,0,0] ]       - swaps red and blue channels.
		;   • [ "", "", "", [0,0,0,0,1] ]    - makes bitmap opaque (sets alpha=255)
		;   • [ [.2,.7,.1], [.2,.7,.1], [.2,.7,.1] ]  - converts image to grayscale
		;   • [ [,,,,0.5], [,,,,0.5], [,,,,0.5] ]     - increase brightness by half
		
		_CreateColorMatrix( matrix, ByRef binMatrix ) {
			Local
			
			VarSetCapacity(binMatrix, 5*5*4, 0)  ; FLOAT[5][5] ColorMatrix
			
			; Set matrix to identity. Zeroes are set by VarSetCapacity.
			Loop 5 {
				NumPut(1, binMatrix, (A_Index-1)*(5 + 1) * 4, "Float")
			}
			
			If (IsObject(matrix) == False)
				Return
			
			Loop % Min(4, matrix.Length()) {
				column := A_Index-1
				vector := matrix[A_Index]
				
				If (IsObject(vector) == False)
					Continue
				
				Loop % Min(5, vector.Length()) {
					row := A_Index-1
					
					If (vector.HasKey(A_Index))
						NumPut( vector[A_Index], binMatrix, (row*5 + column)*4, "Float" )
				}
			}
		}
		
		
		; Effect subclasses
		; -----------------
		
		; Blur
		;   • radius      -  0 .. 255    - size of gaussian kernel in pixels.
		;   • expandEdge  -  True|False  - resize bitmap to fit blurred edges.
		
		Class Blur  Extends  OGdip.Effect {
			Static _effectGuid    := "{633C80A4-1843-482B-9EF2-BE2834C5FDD4}"
			Static _defaultParams := { radius: 0, expandEdge: False }
			
			SetParameters( args* ) {
				Local
				(!args.HasKey(1)) ? "" : (this._params.radius     := Min(Max(args[1], 0), 255))
				(!args.HasKey(2)) ? "" : (this._params.expandEdge := !!(args[2]))
				
				VarSetCapacity(paramsData, (paramsSize := 4+4), 0)
				NumPut(this._params.radius    , paramsData, 0, "Float")
				NumPut(this._params.expandEdge, paramsData, 4, "UInt")
				
				this._SetEffectParameters( &paramsData, paramsSize )
			}
		}
		
		
		; BrightnessContrast
		;   • brightness  -  -255 .. 255  - value to add to each pixel
		;   • contrast    -  -100 .. 100  - scale factor relative to gray center
		
		Class BrightnessContrast  Extends  OGdip.Effect {
			Static _effectGuid    := "{D3A1DBE1-8EC4-4C17-9F4C-EA97AD1C343D}"
			Static _defaultParams := { brightness: 0, contrast: 0 }
			
			SetParameters( args* ) {
				Local
				(!args.HasKey(1)) ? "" : (this._params.brightness := Min(Max(args[1], -255), 255))
				(!args.HasKey(2)) ? "" : (this._params.contrast   := Min(Max(args[2], -100), 100))
				
				VarSetCapacity(paramsData, (paramsSize := 4+4), 0)
				NumPut(this._params.brightness, paramsData, 0, "Int")
				NumPut(this._params.contrast  , paramsData, 4, "Int")
				
				this._SetEffectParameters( &paramsData, paramsSize )
			}
		}
		
		
		; ColorBalance
		;   • cyanRed       -  -100 .. 100  - Multiplies value of each given channel
		;   • magentaGreen  -  -100 .. 100  | by a factor of 0..2 corresponding to value.
		;   • yellowBlue    -  -100 .. 100  | For example, -50 halves, +100 doubles all pixel values.
		
		Class ColorBalance  Extends  OGdip.Effect {
			Static _effectGuid    := "{537E597D-251E-48DA-9664-29CA496B70F8}"
			Static _defaultParams := { cyanRed: 0, magentaGreen: 0, yellowBlue: 0 }
			
			SetParameters( args* ) {
				Local
				(!args.HasKey(1)) ? "" : (this._params.cyanRed      := Min(Max(args[1], -100), 100))
				(!args.HasKey(2)) ? "" : (this._params.magentaGreen := Min(Max(args[2], -100), 100))
				(!args.HasKey(3)) ? "" : (this._params.yellowBlue   := Min(Max(args[3], -100), 100))
				
				VarSetCapacity(paramsData, (paramsSize := 4+4+4), 0)
				NumPut(this._params.cyanRed     , paramsData, 0, "Int")
				NumPut(this._params.magentaGreen, paramsData, 4, "Int")
				NumPut(this._params.yellowBlue  , paramsData, 8, "Int")
				
				this._SetEffectParameters( &paramsData, paramsSize )
			}
		}
		
		
		; ColorCurve
		;   • adjustment  - Name of the adjustment type, one letter will suffice (eg. E = Exp = Exposure)
		;   • value       - Amount of adjustment. See limits in the code.
		;   • channel     - Color channel to operate on: 'R'|'G'|'B', default is 'All'.
		; 
		; NB: the order of arguments for this effect is different from GDI+ API.
		; 
		; Adjustment types:
		;   • Exposure        - acts as 'brightness' in BrightnessContrast
		;   • Density         - acts as 'brightness' in BrightnessContrast
		;   • Contrast        - acts as 'contrast'   in BrightnessContrast
		;   • Highlight       - adjusts highlight (pixels lighter than half the intensity)
		;   • Shadow          - adjusts shadow    (pixels darker  than half the intensity)
		;   • Midtone         - adjusts midtone (similar to gamma, -50 ≈ γ=0.5, +50 ≈ γ=2.0) 
		;   • WhiteSaturation - sets white point of the image
		;   • BlackSaturation - sets black point of the image
		
		Class ColorCurve  Extends  OGdip.Effect {
			Static _effectGuid    := "{DD6A0022-58E4-4A67-9D9B-D48EB881A53D}"
			Static _defaultParams := { adjustment: "E", channel: 0, value: 0 }
			
			SetParameters( args* ) {
				Local
				Static adjustmentTypes := ""
				
				If (adjustmentTypes == "") {
					adjustmentTypes := {}
					adjustmentTypes["E"] := {typeCode: 0, vMin: -255, vMax: 255}  ; Exposure
					adjustmentTypes["D"] := {typeCode: 1, vMin: -255, vMax: 255}  ; Density
					adjustmentTypes["C"] := {typeCode: 2, vMin: -100, vMax: 100}  ; Contrast
					adjustmentTypes["H"] := {typeCode: 3, vMin: -100, vMax: 100}  ; Highlight
					adjustmentTypes["S"] := {typeCode: 4, vMin: -100, vMax: 100}  ; Shadow
					adjustmentTypes["M"] := {typeCode: 5, vMin: -100, vMax: 100}  ; Midtone
					adjustmentTypes["W"] := {typeCode: 6, vMin:    0, vMax: 255}  ; WhiteSaturation
					adjustmentTypes["B"] := {typeCode: 7, vMin:    0, vMax: 255}  ; BlackSaturation
				}
				
				If (args.HasKey(1)) {
					keyLetter := SubStr(args[1], 1, 1)
					
					If (adjustmentTypes.HasKey(keyLetter) == True)
						this._params.adjustment := keyLetter
				}
				
				adjustMeta := adjustmentTypes[ this._params.adjustment ]
				
				If (args.HasKey(3)) {
					this._params.channel := False ? ""
					:  (args[3] = "R")  ?  1
					:  (args[3] = "G")  ?  2
					:  (args[3] = "B")  ?  3  :  0
				}
				
				If (args.HasKey(2)) {
					this._params.value := Min(Max(value, adjustMeta.vMin), adjustMeta.vMax)
				}
				
				VarSetCapacity(paramsData, (paramsSize := 4+4+4), 0)
				NumPut(adjustMeta.typeCode  , paramsData, 0, "UInt")
				NumPut(this._params.channel , paramsData, 4, "UInt")
				NumPut(this._params.value   , paramsData, 8, "Int")
				
				this._SetEffectParameters( &paramsData, paramsSize )
			}
		}
		
		
		; ColorLUT
		;   • lutR  -  Each LUT (look-up table) is an array of values to be remapped.
		;   • lutG  |  For example, array of 256 values [255, 254, ..., 1, 0] will invert given channel.
		;   • lutB  |  There is no need to specify all values, only those that need to be remapped.
		;   • lutA  |  For example, object {1:255, 256:0} invert only lowest and highest values.
		
		Class ColorLUT Extends OGdip.Effect {
			Static _effectGuid    := "{A7CE72A9-0F7F-40D7-B3CC-D0C02D5C3212}"
			Static _defaultParams := { lutR: 0, lutG: 0, lutB: 0, lutA: 0 }
			
			SetParameters( args* ) {
				Local
				
				VarSetCapacity(paramsData, (paramsSize := 256*4), 0)
				
				Loop 4 {
					lutOffset := (A_Index-1) * 256
					
					; Arguments are [R,G,B,A] while in memory they need to be [B,G,R,A]
					argIndex := ([3, 2, 1, 4])[A_Index]
					
					lutArray := (args.HasKey(argIndex) && IsObject(args[argIndex]))
					?  args[argIndex]
					:  []
					
					Loop 256 {
						lutElem := lutArray.HasKey(A_Index)
						?  lutArray[A_Index]
						:  (A_Index-1)
						
						NumPut(lutElem, paramsData, lutOffset + (A_Index-1), "UChar")
					}
				}
				
				this._SetEffectParameters( &paramsData, paramsSize )
			}
		}
		
		
		; ColorMatrix
		;   • matrix  - See _CreateColorMatrix method for explanation.
		
		Class ColorMatrix Extends OGdip.Effect {
			Static _effectGuid    := "{718F2615-7933-40E3-A511-5F68FE14DD74}"
			Static _defaultParams := { matrix: 0 }
			
			SetParameters( args* ) {
				Local
				Global OGdip
				
				OGdip.Effect._CreateColorMatrix( args[1], paramsData := "" )
				
				this._SetEffectParameters( &paramsData, 5*5*4 )
			}
		}
		
		
		; HSL
		;   • hue  -  -180 .. 180  -  Hue shift. Values out of range will be wrapped around.
		;   • sat  -  -100 .. 100  -  Saturation change, 0 - no change
		;   • lit  -  -100 .. 100  -  Lightness change , 0 - no change
		
		Class HSL Extends OGdip.Effect {
			Static _effectGuid    := "{8B2DD6C3-EB07-4D87-A5F0-7108E26A9C5F}"
			Static _defaultParams := { hue: 0, sat: 0, lit: 0 }
			
			SetParameters( args* ) {
				Local
				(!args.HasKey(1)) ? "" : (this._params.hue := Mod(args[1] + 180, 360) - 180)
				(!args.HasKey(2)) ? "" : (this._params.sat := Min(Max(args[2], -100), 100))
				(!args.HasKey(3)) ? "" : (this._params.lit := Min(Max(args[3], -100), 100))
				
				VarSetCapacity(paramsData, (paramsSize := 4+4+4), 0)
				NumPut(this._params.hue , paramsData, 0, "Int")
				NumPut(this._params.sat , paramsData, 4, "Int")
				NumPut(this._params.lit , paramsData, 8, "Int")
				
				this._SetEffectParameters( &paramsData, paramsSize )
			}
		}
		
		
		; Levels
		;   • highlight  -     0 .. 100  - Sets white point   (100 - no change)
		;   • midtone    -  -100 .. 100  - Sets midtone point ( 0  - no change)
		;   • shadow     -     0 .. 100  - Sets black point   ( 0  - no change)
		
		Class Levels Extends OGdip.Effect {
			Static _effectGuid    := "{99C354EC-2A31-4f3a-8C34-17A803B33A25}"
			Static _defaultParams := { highlight: 100, midtone: 0, shadow: 0 }
			
			SetParameters( args* ) {
				Local
				(!args.HasKey(1)) ? "" : (this._params.highlight := Min(Max(args[1],    0), 100))
				(!args.HasKey(2)) ? "" : (this._params.midtone   := Min(Max(args[2], -100), 100))
				(!args.HasKey(3)) ? "" : (this._params.shadow    := Min(Max(args[3],    0), 100))
				
				VarSetCapacity(paramsData, (paramsSize := 4+4+4), 0)
				NumPut(this._params.highlight, paramsData, 0, "Int")
				NumPut(this._params.midtone  , paramsData, 4, "Int")
				NumPut(this._params.shadow   , paramsData, 8, "Int")
				
				this._SetEffectParameters( &paramsData, paramsSize )
			}
		}
		
		
		; RedEyeCorrection
		;   • rect1  - Array of [x,y,w,h] that specifies a rectangular area of the effect
		;   • rectN  - Multiple areas can be used in one effect
		
		Class RedEyeCorrection Extends OGdip.Effect {
			Static _effectGuid    := "{74D29D05-69A4-4266-9549-3CC52836B632}"
			Static _defaultParams := { areas: 0 }
			
			SetParameters( args* ) {
				Local
				Global OGdip
				
				rects := []
				
				Loop % args.Length() {
					If (IsObject(args[A_Index]) == True)
					&& (args[A_Index].Length() == 4)
						rects.Push(args[A_Index])
				}
				
				flatRects := OGdip._FlattenArray(rects)
				OGdip._CreateBinArray( flatRects, paramsData := "", "Int", 4 )
				NumPut(rects.Length(), paramsData, 0, "UInt")
				
				paramsSize := 4 + rects.Length() * 4*4
				
				this._SetEffectParameters( &paramsData, paramsSize )
			}
		}
		
		
		; Sharpen
		;   • radius  -  0 .. 255  - size of convolution kernel in pixels
		;   • amount  -  0 .. 100  - strength of the effect
		
		Class Sharpen Extends OGdip.Effect {
			Static _effectGuid    := "{63CBF3EE-C526-402c-8F71-62C540BF5142}"
			Static _defaultParams := { radius: 0, amount: 0 }
			
			SetParameters( args* ) {
				Local
				
				(!args.HasKey(1)) ? "" : (this._params.radius := Min(Max(args[1], 0), 255))
				(!args.HasKey(2)) ? "" : (this._params.amount := Min(Max(args[2], 0), 100))
				
				VarSetCapacity(paramsData, (paramsSize := 4+4), 0)
				NumPut(this._params.radius, paramsData, 0, "Float")
				NumPut(this._params.amount, paramsData, 4, "Float")
				
				this._SetEffectParameters( &paramsData, paramsSize )
			}
		}
		
		
		; Tint
		;   • hue     -  -180 .. 180
		;   • amount  -  -100 .. 100
		
		Class Tint Extends OGdip.Effect {
			Static _effectGuid    := "{1077AF00-2848-4441-9489-44AD4C2D7A2C}"
			Static _defaultParams := { hue: 0, amount: 0 }
			
			SetParameters( args* ) {
				Local
				
				(!args.HasKey(1)) ? "" : (this._params.hue    := Mod(args[1] + 180, 360) - 180)
				(!args.HasKey(2)) ? "" : (this._params.amount := Min(Max(args[2], -100), 100))
				
				VarSetCapacity(paramsData, (paramsSize := 4+4), 0)
				NumPut(this._params.hue   , paramsData, 0, "Int")
				NumPut(this._params.amount, paramsData, 4, "Int")
				
				this._SetEffectParameters( &paramsData, paramsSize )
			}
		}
	}
	
	
	
	; Metafile class
	; ==============
	; 
	; Metafile stores records of commands and settings used to draw vector image.
	; Metafiles can be created either for playing (drawing) or recording (creating).
	; In most cases to draw metafile it is easier to create Image object instead of Metafile.
	; For selective drawing, use Graphics.EnumerateMetafile and play only required records from the callback.
	; 
	; Constructors:
	;   For playing:
	;     > mf := new OGdip.Metafile( filename )                     ; Create from file
	;     > mf := new OGdip.Metafile( "*IStream", streamPtr )        ; Create from IStream
	;     > mf := new OGdip.Metafile( wmfFilename, wmfPFHeaderPtr )  ; Create from WMF file with placeable header
	;     > mf := new OGdip.Metafile( "*HMETAFILE", hMetafile, wmfPFHeaderPtr, deleteWmf )  ; From GDI handle
	;     > mf := new OGdip.Metafile( "*HENHMETAFILE", hEnhMetafile, deleteEmf )            ; From GDI handle
	;   
	;   For recording:
	;     > mf := OGdip.Metafile.RecordTo( hDC, filename [, emfType, frameRect, emfUnit, description] )
	;     > mf := OGdip.Metafile.RecordTo( hDC, "*STREAM", streamPtr [, emfType, frameRect, emfUnit, description] )
	; 
	; Properties:
	;   .RasterizationDPI
	; 
	; Methods:
	;   .PlayRecord( pImage, recordType, flags, dataSize, dataPtr )
	;   .GetHeaderPtr( [source, handle] )
	;   .GetHENHMETAFILE()
	;   .ConvertToWmf( filename [, mapType, flags] )
	;   .ConvertToEmfPlus( oGraphics, filename [, emfType, description] )
	
	Class Metafile  Extends  OGdip.Image {
		
		__New( source, handle := "", args* ) {
			pImage := 0
			
			If (source = "*ISTREAM") {
				DllCall("GdiPlus\GdipCreateMetafileFromStream"
				, "Ptr" , handle   ; IStream pointer
				, "Ptr*", pImage)
				
			} Else
			If (source = "*HENHMETAFILE") {
				; Whether to delete HENHMETAFILE with this object
				deleteEmf := args.HasKey(1)  ?  args[1]  :  0
				
				DllCall("GdiPlus\GdipCreateMetafileFromEmf"
				, "Ptr" , handle   ; HENHMETAFILE
				, "UInt", deleteEmf
				, "Ptr*", pImage)
				
			} Else
			If (source = "*HMETAFILE")
			&& (args.Length() >= 1)
			{
				deleteWmf := args.HasKey(2)  ?  args[2]  :  0
				
				DllCall("GdiPlus\GdipCreateMetafileFromWmf"
				, "Ptr" , handle   ; HMETAFILE
				, "UInt", deleteWmf
				, "Ptr" , args[1]  ; Pointer to WmfPlaceableFileHeader
				, "Ptr*", pImage)
				
			} Else {
				If (handle == "") {
					DllCall("GdiPlus\GdipCreateMetafileFromFile"
					, "WStr", source
					, "Ptr*", pImage)
					
				} Else {
					DllCall("GdiPlus\GdipCreateMetafileFromWmfFile"
					, "WStr", source
					, "Ptr" , handle  ; WmfPlaceableFileHeader
					, "Ptr*", pImage)
				}
			}
			
			If (pImage == 0) {
				this.Base := False  ; Avoid calling __Delete
				Return False
			}
			
			this._pImage := pImage
			
			If (OGdip.autoGraphics)
				this.GetGraphics()
		}
		
		
		Static EnumEmfType := { _minId: 3, _maxId: 5
			, "Emf"    : 3  , "EmfOnly"    : 3
			, "Emf+"   : 4  , "EmfPlus"    : 4
			, "EmfDual": 5  , "EmfPlusDual": 5 }
		
		RecordTo( hDC, source, args* ) {
			Local
			Global OGdip
			
			pImage     := 0
			pStreamPtr := 0
			pFrameRect := 0
			tempHDC    := False
			
			If (hDC == 0) {
				hDC := DllCall("CreateCompatibleDC", "Ptr", 0, "Ptr")
				tempHDC := True
			}
			
			If (source = "*STREAM") {
				pStreamPtr := args.RemoveAt(1)
			}
			
			emfType := args.HasKey(1)  ?  args[1]  :  "EmfPlusDual"
			emfType := OGdip.Enum.Get(this.EnumEmfType, emfType, 5)
			
			If (IsObject(args[2])) {
				OGdip._CreateBinArray( args[2], binFrameRect := "", "Float" )
				pFrameRect := &binFrameRect
			}
			
			emfUnit := args.HasKey(3)  ?  args[3]  :  "MetafileGDI"
			emfUnit := OGdip.Enum.Get("Unit", emfUnit, 7)
			
			description := args.HasKey(4)  ?  args[4]  :  ""
			dscType := "WStr"
			
			If (description == "") {
				dscType := "Ptr"
				description := 0
			}
			
			If (source == "") {
				DllCall("GdiPlus\GdipRecordMetafile"
				, "Ptr" , hDC
				, "UInt", emfType
				, "Ptr" , pFrameRect
				, "UInt", emfUnit
				, "WStr", description
				, "Ptr*", pImage)
				
			} Else
			If (source = "*STREAM") {
				DllCall("GdiPlus\GdipRecordMetafileStream"
				, "Ptr" , pStreamPtr
				, "Ptr" , hDC
				, "UInt", emfType
				, "Ptr" , pFrameRect
				, "UInt", emfUnit
				, "WStr", description
				, "Ptr*", pImage)
				
			} Else {
				DllCall("GdiPlus\GdipRecordMetafileFileName"
				, "WStr", source
				, "Ptr" , hDC
				, "UInt", emfType
				, "Ptr" , pFrameRect
				, "UInt", emfUnit
				, "WStr", description
				, "Ptr*", pImage)
			}
			
			If (tempHDC == True) {
				DllCall("DeleteDC", "Ptr", hDC)
			}
			
			If (pImage == 0)
				Return False
			
			recMetafile := { Base: OGdip.Metafile, _pImage: pImage }
			
			If (OGdip.autoGraphics)
				recMetafile.GetGraphics()
			
			Return recMetafile
		}
		
		
		; Gets binary metafile header.
		;   > pHeader := mf.GetHeaderPtr()
		;   > pHeader := OGdip.Metafile.GetHeaderPtr( filename )
		;   > pHeader := OGdip.Metafile.GetHeaderPtr( "*STREAM", streamPtr )
		;   > pHeader := OGdip.Metafile.GetHeaderPtr( "*HENHMETAFILE", hEnhMetafile )
		
		GetHeaderPtr( source := "", handle := "" ) {
			Local pHeader := 0
			
			If (source = "") {
				DllCall("GdiPlus\GdipGetMetafileHeaderFromMetafile"
				, "Ptr" , this._pImage
				, "Ptr*", pHeader)
				
			} Else
			If (source = "*HENHMETAFILE") {
				DllCall("GdiPlus\GdipGetMetafileHeaderFromEmf"
				, "Ptr" , handle  ; HENHMETAFILE
				, "Ptr*", pHeader)
				
			} Else
			If (source = "*STREAM") {
				DllCall("GdiPlus\GdipGetMetafileHeaderFromStream"
				, "Ptr" , handle  ; Pointer to IStream
				, "Ptr*", pHeader)
				
			} Else {
				DllCall("GdiPlus\GdipGetMetafileHeaderFromFile"
				, "WStr", source  ; Filename
				, "Ptr*", pHeader)
			}
			
			Return pHeader
		}
		
		
		; This method must only be called from EnumerateMetafile callback.
		; It is not recommended to call this method on instance of Metafile object.
		;   >  EnumerateMetafileCallback( ... ) {
		;   >     OGdip.Metafile.PlayRecord( ... )
		;   >  }
		
		PlayRecord( pImage, recordType, flags, dataSize, dataPtr ) {
			DllCall("GdiPlus\GdipPlayMetafileRecord"
			, "Ptr" , pImage
			, "UInt", recordType
			, "UInt", flags
			, "UInt", dataSize
			, "Ptr" , dataPtr)
		}
		
		
		; Gets/sets resolution of bitmaps (including some elements that will be stored as bitmaps,
		; ex. some gradients and texture-based brushes). Default value is 96 dpi.
		; Set to zero to match the resolution of device context used in constructor.
		
		RasterizationDPI {
			Get {
				Local
				DllCall("GdiPlus\GdipGetMetafileDownLevelRasterizationLimit"
				, "Ptr" , this._pImage
				, "UInt*", result := 0)
				
				Return result
			}
			Set {
				DllCall("GdiPlus\GdipSetMetafileDownLevelRasterizationLimit"
				, "Ptr" , this._pImage,
				, "UInt", value)
				
				Return value
			}
		}
		
		
		; Gets HENHMETAFILE handle
		; Important: This method sets the metafile object to an invalid state.
		; Don't forget to call DeleteEnhMetafile to delete this handle.
		
		GetHENHMETAFILE() {
			Local
			
			DllCall("GdiPlus\GdipGetHemfFromMetafile"
			, "Ptr" , this._pImage
			, "Ptr*", HENHMETAFILE := 0)
			
			Return HENHMETAFILE
		}
		
		
		; Types logical units will be mapped to.
		
		Static EnumWmfMapType := { _minId: 1, _maxId: 8
			, "Pixel"       : 1    ; Pixels
			, "Metric"      : 2    ; 0.1 mm
			, "MetricHi"    : 3    ; 0.01 mm
			, "Imperial"    : 4    ; 0.01 inch
			, "ImperialHi"  : 5    ; 0.001 inch
			, "Twips"       : 6    ; 1/1440 inch
			, "Isotropic"   : 7    ; Arbitrary units with equally scaled axes.
			, "Anisotropic" : 8 }  ; Arbitrary units with arbitrarily scaled axes.
		
		; Converts metafile to WMF and saves it to a file.
		; Important: this method uses .GetHENHMETAFILE, read its description.
		; Metafile object may become unusable after conversion.
		
		ConvertToWmf( filename, mapType := 8, flags := 0 ) {
			Local
			
			hEnhMetafile := this.GetHENHMETAFILE()
			
			bufferSize := DllCall("GdiPlus\GdipEmfToWmfBits"
			, "Ptr" , hEnhMetafile
			, "UInt", 0
			, "Ptr" , 0
			, "Int" , mapMode
			, "Int" , flags)
			
			If (bufferSize == 0)
				Return False
			
			VarSetCapacity(dataBuffer, bufferSize, 0)
			
			resultSize := DllCall("GdiPlus\GdipEmfToWmfBits"
			, "Ptr" ,  hEnhMetafile
			, "UInt",  bufferSize
			, "Ptr" , &dataBuffer
			, "Int" ,  mapMode
			, "Int" ,  flags)
			
			hMetafile := DllCall("gdi32\SetMetaFileBitsEx"
			, "UInt",  resultSize
			, "Ptr" , &dataBuffer)
			
			DllCall("gdi32\CopyMetaFile"
			, "Ptr" , hMetafile
			, "Str" , filename)
			
			DllCall("gdi32\DeleteMetaFile"   , "Ptr", hMetafile)
			DllCall("gdi32\DeleteEnhMetaFile", "Ptr", hEnhMetafile)
		}
		
		
		; Converts metafile to EMF+ format.
		;   > mf.ConvertToEmfPlus( oGraphics, ["", emfType, description] )
		;   > mf.ConvertToEmfPlus( oGraphics, filename [, emfType, description] )
		;   > mf.ConvertToEmfPlus( oGraphics, "*STREAM", streamPtr [, emfType, description] )
		; 
		; If conversion was successful, Metafile's internal image handle is updated.
		; Return bitset of various grades of success.
		
		ConvertToEmfPlus( oGraphics, output := "", args* ) {
			Local
			Global OGdip
			
			pConverted  := 0
			failureFlag := 0
			streamPtr   := 0
			
			If (output = "*STREAM") {
				streamPtr := args.RemoveAt(1)
			}
			
			emfType := args.HasKey(1)  ?  args[1]  :  "EmfPlusDual"
			emfType := OGdip.Enum.Get( this.EnumEmfType, emfType, 5 )
			
			description := args.HasKey(2)  ?  args[2]  :  ""
			dscType := "WStr"
			
			If (description == "") {
				dscType := "Ptr"
				description := 0
			}
			
			If (output == "") {
				success := DllCall("GdiPlus\GdipConvertToEmfPlus"
				, "Ptr"  , oGraphics._pGraphics
				, "Ptr"  , this._pImage
				, "UInt*", failureFlag
				, "UInt" , emfType
				, dscType, description
				, "Ptr*" , pConverted)
				
			} Else
			If (output = "*STREAM") {
				success := DllCall("GdiPlus\GdipConvertToEmfPlusToStream"
				, "Ptr"  , oGraphics._pGraphics
				, "Ptr"  , this._pImage
				, "UInt*", failureFlag
				, "Ptr"  , streamPtr
				, "UInt" , emfType
				, dscType, description
				, "Ptr*" , pConverted)
				
			} Else {
				success := DllCall("GdiPlus\GdipConvertToEmfPlusToFile"
				, "Ptr"  , oGraphics._pGraphics
				, "Ptr"  , this._pImage
				, "UInt*", failureFlag
				, "WStr" , output
				, "UInt" , emfType
				, dscType, description
				, "Ptr*" , pConverted)
				
			}
			
			If (pConverted != 0) {
				DllCall("GdiPlus\GdipDisposeImage", "Ptr", this._pImage)
				this._pImage := (success == 0)  ?  pConverted  :  0
			}
			
			Return (0
			|  ((this._pImage != 0) << 0)
			|  ((pConverted != 0)   << 1)
			|  ((failureFlag == 0)  << 2) )
		}
	}
	
	
	
	; ImageAttributes class
	; =====================
	; 
	; ImageAttributes object allows to process image data during rendering,
	; keeping original image intact. Each attribute allows to specify
	; category of adjustment: for example, you can have certain attribute
	; to affect only pen drawings and another attribute - for brush fills.
	; 
	; Each attribute has a way to clear its value, but note this:
	; if attribute was previously set for a certain category, default
	; attributes will no longer affect this category even if you clear it.
	; 
	; Constructors:
	;   > ia := new OGdip.ImageAttributes( [initAttrs] )  ; Create and optionally initialize IA
	;   > ia := new OGdip.ImageAttributes( oAttributes )  ; Clone existing IA
	; 
	; Methods:
	;   .Reset( [adjustType] )
	;   .SetAttribute( attributeName, args* )
	;   .SetColorKey( argbLow [, argbHigh, adjustType] )
	;   .SetColorMatrix( colorMatrix [, grayMatrix, alterMode, adjustType] )
	;   .SetGamma( gammaValue [, adjustType] )
	;   .SetNoOp( [setOrClear, adjustType] )
	;   .SetOutputChannel( cmykChannel [, adjustType] )
	;   .SetRemapTable( remapTable [, adjustType] )
	;   .SetThreshold( threshold [, adjustType] )
	;   .SetWrapMode( wrapMode [, adjustType] )
	;   .SetToIdentity( [adjustType] )
	;   .SetColorProfile( filename [, adjustType] )
	;   .GetAdjustedPalette( palette [, adjustType] )
	
	Class ImageAttributes {
		
		Static EnumAdjustType := { _minId: 0, _maxId: 4
			, "Default" : 0
			, "Bitmap"  : 1
			, "Brush"   : 2
			, "Pen"     : 3
			, "Text"    : 4 }
		
		
		__New( initAttrs := "" ) {
			Local
			Global OGdip
			
			pAttributes := 0
			
			If (IsObject(initAttrs) == True)
			&& (initAttrs.Base == OGdip.ImageAttributes)
			{
				DllCall("GdiPlus\GdipCloneImageAttributes"
				, "Ptr" , initAttrs._pAttributes
				, "Ptr*", pAttributes)
				
			} Else {
				DllCall("GdiPlus\GdipCreateImageAttributes"
				, "Ptr*", pAttributes)
			}
			
			
			If (pAttributes == 0) {
				this.Base := False  ; Avoid calling __Delete
				Return False
			}
			
			this._pAttributes := pAttributes
			
			If (IsObject(initAttrs) == True)
			&& (initAttrs.Base != OGdip.ImageAttributes)
			{
				For key, value In initAttrs {
					this.SetAttribute(key, value)
				}
			}
		}
		
		
		__Delete() {
			DllCall("GdiPlus\GdipDisposeImageAttributes"
			, "Ptr", this._pAttributes)
		}
		
		
		; Removes all adjustments for a given category.
		
		Reset( adjustType := "" ) {
			Local
			Global OGdip
			
			adjustType := OGdip.Enum.Get(this.EnumAdjustType, adjustType, 0)
			
			DllCall("GdiPlus\GdipResetImageAttributes"
			, "Ptr" , this._pAttributes
			, "UInt", adjustType)
			
			Return this
		}
		
		
		; Sets attribute parameters by given name.
		; Used by constructor and Image.SetAttribute method.
		
		SetAttribute( attributeName, args* ) {
			Return (False ? ""
			:  (attributeName = "ColorKey")      ?  this.SetColorKey( args* )
			:  (attributeName = "ColorMatrix")   ?  this.SetColorMatrix( args* )
			:  (attributeName = "Gamma")         ?  this.SetGamma( args* )
			:  (attributeName = "NoOp")          ?  this.SetNoOp( args* )
			:  (attributeName = "OutputChannel") ?  this.SetOutputChannel( args* )
			:  (attributeName = "ColorProfile")  ?  this.SetColorProfile( args* )
			:  (attributeName = "RemapTable")    ?  this.SetRemapTable( args* )
			:  (attributeName = "Threshold")     ?  this.SetThreshold( args* )
			:  (attributeName = "WrapMode")      ?  this.SetWrapMode( args* )
			:  this)
		}
		
		
		; Sets color key range.
		; Any color with channel values between those of argbLow and argbHigh,
		; will be made transparent.
		; 
		; Pass empty string as a first argument to clear this attribute.
		
		SetColorKey( argbLow, argbHigh := "", adjustType := "" ) {
			Local
			Global OGdip
			
			adjustType := OGdip.Enum.Get(this.EnumAdjustType, adjustType, 0)
			setOrClear := (argbLow != "")
			
			If (argbLow == "")
				argbLow := 0
			
			If (argbHigh == "")
				argbHigh := argbLow
			
			DllCall("GdiPlus\GdipSetImageAttributesColorKeys"
			, "Ptr" , this._pAttributes
			, "UInt", adjustType
			, "UInt", setOrClear
			, "UInt", argbLow
			, "UInt", argbHigh)
			
			Return this
		}
		
		
		; Sets color matrices for color and grayscale.
		; See Effect._CreateColorMatrix for details about color matrices.
		; 
		; Pass empty string as a first argument to clear this attribute.
		
		Static EnumAlterMode := { _minId: 0, _maxId: 2
			, "Default"  : 0                   ; All colors are adjusted
			, "SkipGray" : 1  , "Color" : 1    ; Gray shades are not adjusted
			, "AltGray"  : 2  , "Gray"  : 2 }  ; Only gray shades are adjusted
		
		SetColorMatrix( colorMatrix, grayMatrix := "", alterMode := "", adjustType := "" ) {
			Local
			Global OGdip
			
			setOrClear := IsObject(colorMatrix)
			
			adjustType := OGdip.Enum.Get(this.EnumAdjustType, adjustType, 0)
			alterMode  := OGdip.Enum.Get(this.EnumAlterMode , alterMode , 0) * setOrClear
			
			pColorMatrix := 0
			pGrayMatrix  := 0
			
			If (setOrClear && IsObject(colorMatrix)) {
				OGdip._CreateColorMatrix(colorMatrix, binColorMatrix := "")
				pColorMatrix := &binColorMatrix
			}
			
			If (setOrClear && IsObject(grayMatrix)) {
				OGdip._CreateColorMatrix(grayMatrix, binGrayMatrix := "")
				pGrayMatrix := &binGrayMatrix
			}
			
			DllCall("GdiPlus\GdipSetImageAttributesColorMatrix"
			, "Ptr" , this._pAttributes
			, "UInt", adjustType
			, "UInt", setOrClear
			, "Ptr" , pColorMatrix
			, "Ptr" , pGrayMatrix
			, "UInt", alterMode)
			
			Return this
		}
		
		
		; Sets gamma value.
		; Pass empty string as a first argument to clear this attribute.
		
		SetGamma( gammaValue, adjustType := "" ) {
			Local
			Global OGdip
			
			adjustType := OGdip.Enum.Get(this.EnumAdjustType, adjustType, 0)
			setOrClear := (gammaValue != "")
			
			If (gammaValue == "")
				gammaValue := 0
			
			DllCall("GdiPlus\GdipSetImageAttributesGamma"
			, "Ptr"  , this._pAttributes
			, "UInt" , adjustType
			, "UInt" , setOrClear
			, "Float", gammaValue)
			
			Return this
		}
		
		
		; Disables color adjustment for a certain category.
		; Pass any falsy value (ex. empty string) as a first argument to clear this attribute.
		
		SetNoOp( setOrClear := True, adjustType := "" ) {
			Local
			Global OGdip
			
			adjustType := OGdip.Enum.Get(this.EnumAdjustType, adjustType, 0)
			
			DllCall("GdiPlus\GdipSetImageAttributesNoOp"
			, "Ptr" , this._pAttributes
			, "UInt", adjustType
			, "UInt", !!setOrClear)
			
			Return this
		}
		
		
		; Converts an image to CMYK color space and extracts specified channel.
		; Pass empty string as a first argument to clear this attribute.
		
		Static EnumCmykChannel := { _minId:0, _maxId:3
			, 0:0,  "C":0,  "Cyan"   : 0
			, 1:1,  "M":1,  "Magenta": 1
			, 2:2,  "Y":2,  "Yellow" : 2
			, 3:3,  "K":3,  "Black"  : 3 }
		
		SetOutputChannel( cmykChannel, adjustType := "" ) {
			Local
			Global OGdip
			
			adjustType  := OGdip.Enum.Get(this.EnumAdjustType , adjustType , 0)
			cmykChannel := OGdip.Enum.Get(this.EnumCmykChannel, cmykChannel, 4)
			setOrClear  := (cmykChannel != 4)
			
			DllCall("GdiPlus\GdipSetImageAttributesOutputChannel"
			, "Ptr" , this._pAttributes
			, "UInt", adjustType
			, "UInt", setOrClear
			, "UInt", cmykChannel)
		}
		
		
		; Sets color remap table.
		; Argument 'remapTable' should be array of pairs [oldColor, newColor, ...].
		; Pass any non-object value as a first argument to clear this attribute.
		
		SetRemapTable( remapTable, adjustType := "" ) {
			Local
			Global OGdip
			
			adjustType := OGdip.Enum.Get(this.EnumAdjustType, adjustType, 0)
			setOrClear := IsObject(remapTable)
			
			If (setOrClear) {
				OGdip._CreateBinArray(remapTable, binRemapTable := "", "UInt")
				
				pRemapTable := &binRemapTable
				remapTableSize := remapTable.Length() // 2
				
			} Else {
				pRemapTable := 0
				remapTableSize := 0
			}
			
			DllCall("GdiPlus\GdipSetImageAttributesRemapTable"
			, "Ptr" , this._pAttributes
			, "UInt", adjustType
			, "UInt", setOrClear
			, "UInt", remapTableSize
			, "Ptr" , pRemapTable)
			
			Return this
		}
		
		
		; Sets threshold value (0..255) to cutoff channel values.
		; If channel value of color is less than threshold value,
		; it will be set to zero, otherwise it will be set to 255.
		; Threshold doesn't affect alpha channel.
		; 
		; Pass empty string as a first argument to clear this attribute.
		
		SetThreshold( threshold, adjustType := "" ) {
			Local
			Global OGdip
			
			adjustType := OGdip.Enum.Get(this.EnumAdjustType, adjustType, 0)
			setOrClear := (threshold != "")
			
			If (threshold == "")
				threshold := 0
			
			threshold := Min(Max(threshold, 0), 255) / 255
			
			DllCall("GdiPlus\GdipSetImageAttributesThreshold"
			, "Ptr"  , this._pAttributes
			, "UInt" , adjustType
			, "UInt" , setOrClear
			, "Float", threshold)
			
			Return this
		}
		
		
		; Sets wrap mode - specifies how image will tile an area.
		; Argument 'argbOutside' specifies color outside of the rendered image.
		
		SetWrapMode( wrapMode, argbOutside := 0x0 ) {
			wrapMode := OGdip.Enum.Get(OGdip.Enum.WrapMode, wrapMode)
			
			DllCall("GdiPlus\GdipSetImageAttributesWrapMode"
			, "Ptr" , this._pAttributes
			, "UInt", wrapMode
			, "UInt", argbOutside
			, "UInt", False)
			
			Return this
		}
		
		
		; Sets color adjustment matrix for specified category to identity matrix.
		
		SetToIdentity( adjustType := "" ) {
			Local
			Global OGdip
			
			adjustType := OGdip.Enum.Get(this.EnumAdjustType, adjustType, 0)
			
			DllCall("GdiPlus\GdipSetImageAttributesToIdentity"
			, "Ptr" , this._pAttributes
			, "UInt", adjustType)
			
			Return this
		}
		
		
		; Use in conjunction with .SetOutputChannel.
		; Pass filename of the color profile to use.
		; Color profiles directory: %SystemRoot%\System32\Spool\Drivers\Color
		; Pass empty string as a first argument to clear this attribute.
		
		SetColorProfile( filename, adjustType := "" ) {
			Local
			Global OGdip
			
			adjustType := OGdip.Enum.Get(this.EnumAdjustType, adjustType, 0)
			setOrClear := (filename != "")
			
			lastArg := setOrClear  ?  ["WStr", filename]  :  ["Ptr", 0]
			
			DllCall("GdiPlus\GdipSetImageAttributesOutputChannelColorProfile"
			, "Ptr" , this._pAttributes
			, "UInt", adjustType
			, "UInt", setOrClear
			, lastArg*)
			
			Return this
		}
		
		
		; Modifies palette according to the adjustments of specified category.
		; Argument palette can be either a pointer to binary palette data,
		; or an array of ARGB values.
		
		GetAdjustedPalette( palette, adjustType := "" ) {
			Local
			Global OGdip
			
			adjustType := OGdip.Enum.Get(this.EnumAdjustType, adjustType, 0)
			palettePtr := 0
			
			If (IsObject(palette) == True) {
				OGdip._CreateBinArray( palette, binPalette := "", "UInt", 8 )
				NumPut(palette.Length(), binPalette, 4, "UInt")
				
				palettePtr := &binPalette
				
			} Else {
				palettePtr := palette
			}
			
			DllCall("GdiPlus\GdipGetImageAttributesAdjustedPalette"
			, "Ptr" , this._pAttributes
			, "Ptr" , palettePtr
			, "UInt", adjustType)
			
			If (IsObject(palette) == True) {
				palEntries := NumGet(palettePtr+0, 4, "UInt")
				
				Loop % palEntries {
					palette[A_Index] := NumGet(palettePtr+0, (A_Index+1)*4, "UInt")
				}
			}
			
			Return palette
		}
	}
	
	
	
	; Font class
	; ==========
	; 
	; Constructors:
	;   Create from font family name or FontFamily object:
	;     > fnt := new OGdip.Font( fontFamily [, size, style, unit] )
	;   
	;   Create from object (all fields except 'family' are optional):
	;     > fnt := new OGdip.Font( { family:fontFamily, size:16, style:"BI", unit:"Pixel" } )
	;   
	;   Clone existing Font:
	;     > fnt := new OGdip.Font( oFont )
	;   
	;   Other constructors:
	;     > fnt := new OGdip.Font( "*HDC", hDC )
	;     > fnt := new OGdip.Font( "*LOGFONTA", hDC, logfontA )
	;     > fnt := new OGdip.Font( "*LOGFONTW", hDC, logfontW )
	; 
	; Examples:
	;   > fnt := new OGdip.Font("Arial", 16, "BoldItalic")
	;   > fnt := new OGdip.Font("Alice.ttf", 32)
	; 
	; Methods:
	;   .GetFamily()
	;   .GetSize()
	;   .GetStyle()
	;   .GetUnit()
	;   .GetHeight( oGraphics | dpi )
	;   .GetLOGFONT( &logfont, oGraphics [, ansi] )
	;   .SetSize()
	;   .SetStyle()
	;   
	; Internal methods:
	;   ._GetFontStyle( strStyle )
	
	Class Font {
		
		__New( source, args* ) {
			Local
			Global OGdip
			
			pFont := 0
			srcFontFamily := ""
			gpStatus := 0
			
			If (source == "*HDC") {
				gpStatus := DllCall("GdiPlus\GdipCreateFontFromDC"
				, "Ptr" , args[1]  ; HDC
				, "Ptr*", pFont)
				
			} Else
			If (source == "*LOGFONTA") {
				gpStatus := DllCall("GdiPlus\GdipCreateFontFromLogfontA"
				, "Ptr" , args[1]  ; HDC
				, "Ptr" , args[2]  ; LOGFONTA
				, "Ptr*", pFont)
				
			} Else
			If (source == "*LOGFONTW") {
				gpStatus := DllCall("GdiPlus\GdipCreateFontFromLogfontW"
				, "Ptr" , args[1]  ; HDC
				, "Ptr" , args[2]  ; LOGFONTW
				, "Ptr*", pFont)
				
			} Else
			If (IsObject(source) == True)
			&& (source.Base == OGdip.Font)
			{
				DllCall("GdiPlus\GdipCloneFont"
				, "Ptr" , source._pFont
				, "Ptr*", pFont)
				
			} Else {
				; Defaults, may be overwritten below
				fontSize  := args.HasKey(1)  ?  args[1]  :  12
				fontStyle := args.HasKey(2)  ?  args[2]  :  0
				fontUnit  := args.HasKey(3)  ?  args[3]  :  0
				
				If (IsObject(source) == True)
				&& (source.Base == OGdip.FontFamily)
				{
					srcFontFamily := source
					
				} Else
				If (IsObject(source) == True)
				&& (source.HasKey("family"))
				{
					srcFontFamily := new OGdip.FontFamily(source.family)
					fontSize  := source.HasKey("size")  ?  source["size"]  :  fontSize
					fontStyle := source.HasKey("style") ?  source["style"] :  fontStyle
					fontUnit  := source.HasKey("unit")  ?  source["unit"]  :  fontUnit
					
				} Else {
					srcFontFamily := new OGdip.FontFamily(source)
				}
				
				pFamily   := srcFontFamily._pFontFamily
				fontStyle := OGdip.Font._GetFontStyle(fontStyle)
				fontUnit  := OGdip.Enum.Get("Unit", fontUnit)
				
				DllCall("GdiPlus\GdipCreateFont"
				, "Ptr"  , pFamily
				, "Float", fontSize
				, "Int"  , fontStyle
				, "UInt" , fontUnit
				, "Ptr*" , pFont)
			}
			
			
			If (pFont == 0) {
				this.Base := False  ; Avoid calling __Delete
				Return gpStatus
			}
			
			this._pFont := pFont
			
			; Keep FontFamily loaded in case it's used by several fonts.
			If (srcFontFamily == "") {
				DllCall("GdiPlus\GdipGetFamily"
				, "Ptr" , this._pFont
				, "Ptr*", pFontFamily := 0)
				
				srcFontFamily := {Base: OGdip.FontFamily, _pFontFamily: pFontFamily}
			}
			
			this._fontFamily := srcFontFamily
		}
		
		
		__Delete() {
			DllCall("GdiPlus\GdipDeleteFont"
			, "Ptr", this._pFont)
		}
		
		
		; Converts style string to numeric font style.
		; Allowed string variants:
		;   • "BoldUnderline", "BU", "B+U"        - style determined by uppercase letters;
		;   • "italic strikeout", "bold; italic"  - style determined by first letters;
		;   •  5,  0x03                           - numeric font style, returned as is.
		; Used in constructor.
		
		_GetFontStyle( strStyle ) {
			If (strStyle ~= "^\d+$")
				Return strStyle
			
			Return (0
			+  ((strStyle ~= "(\bb|B)")  ?  0x01  :  0)    ; Bold
			+  ((strStyle ~= "(\bi|I)")  ?  0x02  :  0)    ; Italic
			+  ((strStyle ~= "(\bu|U)")  ?  0x04  :  0)    ; Underline
			+  ((strStyle ~= "(\bs|S)")  ?  0x08  :  0) )  ; Strikeout
		}
		
		
		; Returns copy of FontFamily object this font uses.
		
		GetFamily() {
			Local
			Global OGdip
			
			DllCall("GdiPlus\GdipGetFamily"
			, "Ptr" , this._pFont
			, "Ptr*", pFontFamily := 0)
			
			DllCall("GdiPlus\GdipCloneFontFamily"
			, "Ptr" , pFontFamily
			, "Ptr*", pCloneFontFamily := 0)
			
			Return { Base: OGdip.FontFamily, _pFontFamily: pCloneFontFamily }
		}
		
		
		; Returns font size (em size) in units of the font.
		
		GetSize() {
			Local
			
			DllCall("GdiPlus\GdipGetFontSize"
			, "Ptr"   , this._pFont
			, "Float*", fontSize := 0)
			
			Return fontSize
		}
		
		
		; Returns numeric style value.
		; See ._GetFontStyle method for bits meaning.
		
		GetStyle() {
			Local
			
			DllCall("GdiPlus\GdipGetFontStyle"
			, "Ptr" , this._pFont
			, "Int*", fontStyle := 0)
			
			Return fontStyle
		}
		
		
		GetUnit() {
			Local
			
			DllCall("GdiPlus\GdipGetFontUnit"
			, "Ptr"  , this._pFont
			, "UInt*", fontUnit := 0)
			
			Return fontUnit
		}
		
		
		; Returns line spacing for the font based on its size and unit.
		; Argument 'arg' can be:
		;   • Graphics object whose unit and resolution are used in the height calculation.
		;   • Numeric DPI value, returned value is in pixels.
		
		GetHeight( arg := "" ) {
			Local
			
			If (IsObject(arg) == True)
			&& (arg.Base == OGdip.Graphics)
			{
				DllCall("GdiPlus\GdipGetFontHeight"
				, "Ptr"   , this._pFont
				, "Ptr"   , arg._pGraphics
				, "Float*", fontHeight := 0)
				
			} Else {
				DllCall("GdiPlus\GdipGetFontHeightGivenDPI"
				, "Ptr"   , this._pFont
				, "Float" , ((arg == "")  ?  A_ScreenDPI  :  arg)
				, "Float*", fontHeight := 0)
			}
			
			Return fontHeight
		}
		
		
		GetLOGFONT( ByRef LOGFONT, oGraphics := 0, ansi := False ) {
			Local
			Global OGdip
			
			If (IsObject(oGraphics))
			&& (oGraphics.Base == OGdip.Graphics) {
				pGraphics := oGraphics._pGraphics
				
			} Else {
				; Create temporary graphics
				tempHdc := DllCall("CreateCompatibleDC", "Ptr", 0, "Ptr")
				tempGr  := new OGdip.Graphics("*HDC", tempHdc)
				DllCall("DeleteDC", "Ptr", tempHdc)
				
				pGraphics := tempGr._pGraphics
			}
			
			VarSetCapacity(LOGFONT, 28 + 32*(ansi ? 1 : 2))
			
			DllCall("GdiPlus\GdipGetLogFont" . (ansi ? "A" : "W")
			, "Ptr" ,  this._pFont
			, "Ptr" ,  pGraphics
			, "Ptr" , &LOGFONT)
		}
		
		
		; Change style/size by re-creating Font object and stealing its pointer.
		
		SetStyle( fontStyle ) {
			Local
			Global OGdip
			
			newFont := new OGdip.Font( this._fontFamily,  this.GetSize(),  fontStyle,  this.GetUnit() )
			
			DllCall("GdiPlus\GdipDeleteFont"
			, "Ptr", this._pFont)
			
			this._pFont := newFont._pFont
			
			newFont.Base := False
			newFont := ""
			
			Return this
		}
		
		
		SetSize( fontSize ) {
			Local
			Global OGdip
			
			newFont := new OGdip.Font( this.GetFamily(),  fontSize,  this.GetStyle(),  this.GetUnit() )
			
			DllCall("GdiPlus\GdipDeleteFont"
			, "Ptr", this._pFont)
			
			this._pFont := newFont._pFont
			
			newFont.Base := False
			newFont := ""
			
			Return this
		}
	}
	
	
	
	; FontFamily class
	; ================
	; 
	; Constructors:
	;   > ffam := new OGdip.FontFamily( familyName )   ; From installed font family name (ex. "Arial")
	;   > ffam := new OGdip.FontFamily( filename )     ; From file (.ttf and some .otf) 
	;   > ffam := new OGdip.FontFamily( "*MONO" )      ; Generic monospace family
	;   > ffam := new OGdip.FontFamily( "*SANS" )      ; Generic sans-serif family
	;   > ffam := new OGdip.FontFamily( "*SERIF" )     ; Generic serif family
	;   > ffam := new OGdip.FontFamily( oFontFamily )  ; Clone another FontFamily object
	; 
	; Methods:
	;   .IsStyleAvailable( fontStyle )
	;   .GetName()
	;   .GetMetrics( [fontStyle] )
	
	Class FontFamily {
		
		__New( source ) {
			Local
			Global OGdip
			
			pFontFamily := 0
			
			If (IsObject(source) == True)
			&& (source.Base == OGdip.FontFamily)
			{
				DllCall("GdiPlus\GdipCloneFontFamily"
				, "Ptr" , source._pFontFamily
				, "Ptr*", pFontFamily)
				
			} Else
			If (source = "*SANS") {
				DllCall("GdiPlus\GdipGetGenericFontFamilySansSerif"
				, "Ptr*", pFontFamily)
				
			} Else
			If (source = "*SERIF") {
				DllCall("GdiPlus\GdipGetGenericFontFamilySerif"
				, "Ptr*", pFontFamily)
				
			} Else
			If (source = "*MONO") {
				DllCall("GdiPlus\GdipGetGenericFontFamilyMonospace"
				, "Ptr*", pFontFamily)
				
			} Else
			If (source ~= "\.(ttf|otf)$")
			|| (IsObject(source) == True)
			{
				DllCall("GdiPlus\GdipNewPrivateFontCollection"
				, "Ptr*", pFontCollection := 0)
				
				If (IsObject(source) == True) {
					DllCall("GdiPlus\GdipPrivateAddMemoryFont"
					, "Ptr" , pFontCollection
					, "Ptr" , source.Ptr
					, "Int" , source.Size)
					
				} Else {
					DllCall("GdiPlus\GdipPrivateAddFontFile"
					, "Ptr" , pFontCollection
					, "WStr", source)
				}
				
				DllCall("GdiPlus\GdipGetFontCollectionFamilyCount"
				, "Ptr" , pFontCollection
				, "Int*", familyCount := 0)
				
				If (familyCount != 0) {
					VarSetCapacity(familyList, 2*A_PtrSize * familyCount, 0)
					
					DllCall("GdiPlus\GdipGetFontCollectionFamilyList"
					, "Ptr" ,  pFontCollection
					, "Int" ,  familyCount
					, "Ptr" , &familyList
					, "Int*",  familyCount)
					
					pTempFontFamily := NumGet(familyList, 0, "Ptr")
					
					DllCall("GdiPlus\GdipCloneFontFamily"
					, "Ptr" , pTempFontFamily
					, "Ptr*", pFontFamily)
					
					DllCall("GdiPlus\GdipDeletePrivateFontCollection"
					, "Ptr", pFontCollection)
				}
				
			} Else {
				DllCall("GdiPlus\GdipCreateFontFamilyFromName"
				, "WStr", source
				, "Ptr" , 0  ; FontCollection
				, "Ptr*", pFontFamily)
			}
			
			
			If (pFontFamily == 0) {
				this.Base := False  ; Avoid calling __Delete
				Return False
			}
			
			this._pFontFamily := pFontFamily
		}
		
		
		__Delete() {
			DllCall("GdiPlus\GdipDeleteFontFamily"
			, "Ptr", this._pFontFamily)
		}
		
		
		; Returns True if given font style is available in the FontFamily.
		; See OGdip.Font._GetFontStyle method for possible values of 'fontStyle'.
		
		IsStyleAvailable( fontStyle ) {
			Local
			
			DllCall("GdiPlus\GdipIsStyleAvailable"
			, "Ptr"  , this._pFontFamily
			, "Int"  , OGdip.Font._GetFontStyle(fontStyle)
			, "UInt*", result := 0)
			
			Return result
		}
		
		
		; Returns FontFamily name.
		
		GetName( langId := 0 ) {
			Local
			
			VarSetCapacity(familyName, 32*2, 0)  ; LF_FACESIZE = 32 WChars
			
			DllCall("GdiPlus\GdipGetFamilyName"
			, "Ptr"   , this._pFontFamily
			, "WStr"  , familyName
			, "UShort", langId)
			
			Return familyName
		}
		
		
		; Returns various measurements of the font family for the given style.
		; All measurements are in design units, independent of any context units.
		; See OGdip.Font._GetFontStyle for possible values of 'fontStyle'.
		; Returned value is an object with following fields:
		;   • cellAscent
		;   • cellDescent
		;   • emHeight
		;   • lineHeight
		
		GetMetrics( fontStyle := 0 ) {
			Local
			
			fontStyle := OGdip.Font._GetFontStyle(fontStyle)
			
			DllCall("GdiPlus\GdipGetCellAscent"
			, "Ptr"    , this._pFontFamily
			, "Int"    , fontStyle
			, "UShort*", fmAscent := 0)
			
			DllCall("GdiPlus\GdipGetCellDescent"
			, "Ptr"    , this._pFontFamily
			, "Int"    , fontStyle
			, "UShort*", fmDescent := 0)
			
			DllCall("GdiPlus\GdipGetEmHeight"
			, "Ptr"    , this._pFontFamily
			, "Int"    , fontStyle
			, "UShort*", fmEmHeight := 0)
			
			DllCall("GdiPlus\GdipGetLineSpacing"
			, "Ptr"    , this._pFontFamily
			, "Int"    , fontStyle
			, "UShort*", fmLineHeight := 0)
			
			result := {}
			result.emHeight   := fmEmHeight
			result.ascent     := fmAscent
			result.descent    := fmDescent
			result.lineHeight := fmLineHeight
			
			Return result
		}
	}
	
	
	ChooseFont( initFont := "" ) {
		Local
		Global OGdip
		
		tagLFSize := 28 + 32*2     ; Size of LOGFONTW struct
		tagCFSize := 13*A_PtrSize  ; Size of CHOOSEFONTW struct
		VarSetCapacity(tagLogFont   , tagLFSize, 0)
		VarSetCapacity(tagChooseFont, tagCFSize, 0)
		
		; Create input LOGFONT
		If (IsObject(initFont))
		&& (initFont.Base == OGdip.Font)
		{
			initFont.GetLOGFONT(tagLogFont, 0)
			
		} Else {
			NumPut(400, tagLogFont, 16)
			NumPut( 16, tagLogFont,  0)
			StrPut("Arial", &tagLogFont+28, "UTF-16")
		}
		
		; Create CHOOSEFONTW
		NumPut(  tagCFSize, tagChooseFont, 0*A_PtrSize+0, "UInt")
		NumPut(&tagLogFont, tagChooseFont, 3*A_PtrSize+0, "Ptr")
		NumPut(    0x40041, tagChooseFont, 4*A_PtrSize+4, "UInt")  ; Flags = CF_TTONLY | CF_INITTOLOGFONTSTRUCT | CF_SCREENFONTS
		
		isSelected := DllCall("comdlg32\ChooseFontW", "Ptr", &tagChooseFont)
		If (isSelected == 0)
			Return False
		
		retLogFont := NumGet(tagChooseFont, 3*A_PtrSize+0, "Ptr")
		If (retLogFont == 0)
			Return -1
		
		; Create Font from LOGFONTW
		hdc := DllCall("CreateCompatibleDC", "Ptr", 0, "Ptr")
		newFont := new OGdip.Font("*LOGFONTW", hdc, retLogFont)
		DllCall("DeleteDC", "Ptr", hdc)
		
		Return newFont
	}
	
	
	; Returns array with names of installed font families.
	;   > allFamilies   := OGdip.GetInstalledFontFamilies()
	;   > arialFamilies := OGdip.GetInstalledFontFamilies("Arial")
	
	GetInstalledFontFamilies( nameRegex := "" ) {
		Local
		Static pFontCollection := 0
		
		If (pFontCollection == 0) {
			DllCall("GdiPlus\GdipNewInstalledFontCollection"
			, "Ptr*", pFontCollection := 0)
		}
		
		DllCall("GdiPlus\GdipGetFontCollectionFamilyCount"
		, "Ptr" , pFontCollection
		, "Int*", familyCount := 0)
		
		VarSetCapacity(familyList, 2*A_PtrSize*familyCount, 0)
		
		DllCall("GdiPlus\GdipGetFontCollectionFamilyList"
		, "Ptr" ,  pFontCollection
		, "Int" ,  familyCount
		, "Ptr" , &familyList
		, "Int*",  familyCount)
		
		langId := 0
		families := []
		
		Loop % familyCount {
			familyPtr := NumGet(familyList, (A_Index-1)*A_PtrSize, "Ptr")
			
			VarSetCapacity(familyName, 32*2, 0)  ; LF_FACESIZE = 32 WChars
			
			DllCall("GdiPlus\GdipGetFamilyName"
			, "Ptr"   , familyPtr
			, "WStr"  , familyName
			, "UShort", langId)
			
			If (familyName ~= nameRegex) {
				families.Push(familyName)
			}
		}
		
		Return families
	}
	
	
	
	; StringFormat class
	; ==================
	; 
	; Constructors:
	;   > sfmt := new OGdip.StringFormat( oStringFormat )  ; Clone existing StringFormat
	;   > sfmt := new OGdip.StringFormat( 0 )              ; Create generic StringFormat
	;   > sfmt := new OGdip.StringFormat( 1 )              ; Create typographic StringFormat
	;   > sfmt := new OGdip.StringFormat( options )        ; Create StringFormat from object
	; 
	; Properties:           Meaning:
	;   .Align                Text alignment inside layout: left, center or right;
	;   .LineAlign            Line alignment inside layout: top, middle or bottom;
	;   .Trimming             Trimming method for too large text;
	;   .HotkeyPrefix         How hotkey prefix (ampersand) is processed;
	;   .DigitSubstitution    Whether to replace Western European digits with local ones;
	;   .TabStops             Array of tab stop offsets;
	;   .RightToLeft          Flag: Reading order is right-to-left; affects alignment;
	;   .Vertical             Flag: Text lines are drawn vertically.
	;   .Overhang             Flag: Character parts overhanging layout rect will not be clipped.
	;   .ShowControl          Flag: Display control characters;
	;   .NoFontFallback       Flag: Use fallback font for missing characters;
	;   .MeasureTrails        Flag: Include trailing spaces to the measurements;
	;   .NoWrap               Flag: Disables text wrapping to the next line;
	;   .LineLimit            Flag: Allows to draw only entire lines, not partially fitting;
	;   .NoClip               Flag: Disables clipping; affects MeasureTrails.
	;   .RawFlags             Raw numeric value of StringFormatFlags.
	; 
	; Methods:
	;   .SetMeasurableCharacterRanges( ranges )
	;   .SetOptions( options )
	
	
	Class StringFormat {
		
		__New( options := 1 ) {
			Local
			Global OGdip
			
			pStringFormat := 0
			
			If (IsObject(options))
			&& (options.Base == OGdip.StringFormat)
			{
				DllCall("GdiPlus\GdipCloneStringFormat"
				, "Ptr" , options._pStringFormat
				, "Ptr*", pStringFormat)
				
			} Else
			If (options == 0)
			|| (options =  "Default")
			{
				DllCall("GdiPlus\GdipStringFormatGetGenericDefault"
				, "Ptr*", pStringFormat)
				
			} Else
			If (options == 1)
			|| (options =  "Typographic")
			{
				DllCall("GdiPlus\GdipStringFormatGetGenericTypographic"
				, "Ptr*", pStringFormat)
				
			} Else {
				DllCall("GdiPlus\GdipCreateStringFormat"
				, "Int" , 0  ; Flags
				, "UInt", 0  ; LANDID = LANG_NEUTRAL
				, "Ptr*", pStringFormat)
			}
			
			
			If (pStringFormat == 0) {
				this.Base := False  ; Avoid calling __Delete
				Return False
			}
			
			this._pStringFormat := pStringFormat
			this._flagsCache := this.RawFlags
			
			If (IsObject(options) == True)
			&& (options.Base != OGdip.StringFormat)
			{
				this.SetOptions(options)
			}
		}
		
		
		__Delete() {
			DllCall("GdiPlus\GdipDeleteStringFormat"
			, "Ptr", this._pStringFormat)
		}
		
		
		Static EnumSFAlignment := { _minId: 0, _maxId: 2
			, "Near"   : 0   , "Left"   : 0
			, "Center" : 1   , "Middle" : 1
			, "Far"    : 2   , "Right"  : 2 }
		
		Static EnumSFLineAlignment := { _minId: 0, _maxId: 2
			, "Near"   : 0   , "Top"    : 0
			, "Center" : 1   , "Middle" : 1
			, "Far"    : 2   , "Bottom" : 2 }
		
		Static EnumSFTrimming := { _minId: 0, _maxId: 5
			, "None"  : 0
			, "Char"  : 1
			, "Word"  : 2
			, "EChar" : 3
			, "EWord" : 4
			, "EMid"  : 5 }
		
		Static EnumSFHotkeyPrefix := { _minId: 0, _maxId: 2
			, "None" : 0
			, "Show" : 1
			, "Hide" : 2 }
		
		Static EnumSFDigitSubstitute := { _minId: 0, _maxId: 3
			, "User"        : 0
			, "None"        : 1
			, "National"    : 2
			, "Traditional" : 3 }
		
		
		Align {
			Get {
				Local
				DllCall("GdiPlus\GdipGetStringFormatAlign"
				, "Ptr"  , this._pStringFormat
				, "UInt*", value := 0)
				
				Return value
			}
			Set {
				DllCall("GdiPlus\GdipSetStringFormatAlign"
				, "Ptr" , this._pStringFormat
				, "UInt", OGdip.Enum.Get(this.EnumSFAlignment, value, 0))
				
				Return value
			}
		}
		
		
		LineAlign {
			Get {
				Local
				DllCall("GdiPlus\GdipGetStringFormatLineAlign"
				, "Ptr"  , this._pStringFormat
				, "UInt*", value := 0)
				
				Return value
			}
			Set {
				DllCall("GdiPlus\GdipSetStringFormatLineAlign"
				, "Ptr" , this._pStringFormat
				, "UInt", OGdip.Enum.Get(this.EnumSFLineAlignment, value, 0))
				
				Return value
			}
		}
		
		
		Trimming {
			Get {
				Local
				DllCall("GdiPlus\GdipGetStringFormatTrimming"
				, "Ptr"  , this._pStringFormat
				, "UInt*", value := 0)
				
				Return value
			}
			Set {
				DllCall("GdiPlus\GdipSetStringFormatTrimming"
				, "Ptr" , this._pStringFormat
				, "UInt", OGdip.Enum.Get(this.EnumSFTrimming, value, 0))
				
				Return value
			}
		}
		
		
		HotkeyPrefix {
			Get {
				Local
				DllCall("GdiPlus\GdipGetStringFormatHotkeyPrefix"
				, "Ptr"  , this._pStringFormat
				, "UInt*", value := 0)
				
				Return value
			}
			Set {
				DllCall("GdiPlus\GdipSetStringFormatHotkeyPrefix"
				, "Ptr" , this._pStringFormat
				, "UInt", OGdip.Enum.Get(this.EnumSFHotkeyPrefix, value, 0))
				
				Return value
			}
		}
		
		
		DigitSubstitution {
			Get {
				Local
				DllCall("GdiPlus\GdipGetStringFormatDigitSubstitution"
				, "Ptr"    , this._pStringFormat
				, "UShort*", langId := 0
				, "UInt*"  , sfdsValue := 0)
				
				Return [ sfdsValue, langId ]
			}
			Set {
				Local
				Global OGdip
				
				If (IsObject(value) == True) {
					sfdsValue := OGdip.Enum.Get(this.EnumSFDigitSubstitute, value[1], 0)
					langId := value[2]
					
				} Else {
					sfdsValue := OGdip.Enum.Get(this.EnumSFDigitSubstitute, value, 0)
					langId := 0
				}
				
				DllCall("GdiPlus\GdipSetStringFormatDigitSubstitution"
				, "Ptr"   , this._pStringFormat
				, "UShort", langId
				, "UInt"  , sfdsValue)
				
				Return value
			}
		}
		
		
		RawFlags {
			Get {
				Local
				DllCall("GdiPlus\GdipGetStringFormatFlags"
				, "Ptr" , this._pStringFormat
				, "Int*", value := 0)
				
				Return value
			}
			Set {
				DllCall("GdiPlus\GdipSetStringFormatFlags"
				, "Ptr" , this._pStringFormat
				, "Int" , value)
				
				this._flagsCache := value
				Return value
			}
		}
		
		
		TabStops {
			Get {
				Local
				
				DllCall("GdiPlus\GdipGetStringFormatTabStopCount"
				, "Ptr" , this._pStringFormat
				, "Int*", tabStopsCount := 0)
				
				VarSetCapacity(binTabStops, tabStopsCount * 4, 0)
				
				DllCall("GdiPlus\GdipGetStringFormatTabStops"
				, "Ptr" , this._pStringFormat
				, "Int" , tabStopsCount
				, "Ptr" , 0  ; OUT firstTabOffset
				, "Ptr" , &binTabStops)
				
				tabStopsArray := []
				
				Loop % tabStopsCount {
					tabStopsArray[A_Index] := NumGet(binTabStops, (A_Index-1)*4, "Float")
				}
				
				Return tabStopsArray
			}
			Set {
				Local
				Global OGdip
				
				If (IsObject(value) == False)
					Return value
				
				OGdip._CreateBinArray(value, binTabStops := "", "Float")
				
				DllCall("GdiPlus\GdipSetStringFormatTabStops"
				, "Ptr"  ,  this._pStringFormat
				, "Float",  0  ; firstTabOffset
				, "Int"  ,  value.Length()
				, "Ptr"  , &binTabStops)
				
				Return value
			}
		}
		
		
		RightToLeft {
			Get {
				Return (!!(this._flagsCache & 0x0001))
			}
			Set {
				Return this.RawFlags := this._flagsCache := (value
				?  (this._flagsCache |  0x0001)
				:  (this._flagsCache & ~0x0001))
			}
		}
		
		Vertical {
			Get {
				Return (!!(this._flagsCache & 0x0002))
			}
			Set {
				Return this.RawFlags := this._flagsCache := (value
				?  (this._flagsCache |  0x0002)
				:  (this._flagsCache & ~0x0002))
			}
		}
		
		Overhang {
			Get {
				Return (!!(this._flagsCache & 0x0004))
			}
			Set {
				Return this.RawFlags := this._flagsCache := (value
				?  (this._flagsCache |  0x0004)
				:  (this._flagsCache & ~0x0004))
			}
		}
		
		ShowControl {
			Get {
				Return (!!(this._flagsCache & 0x0020))
			}
			Set {
				Return this.RawFlags := this._flagsCache := (value
				?  (this._flagsCache |  0x0020)
				:  (this._flagsCache & ~0x0020))
			}
		}
		
		NoFontFallback {
			Get {
				Return (!!(this._flagsCache & 0x0400))
			}
			Set {
				Return this.RawFlags := this._flagsCache := (value
				?  (this._flagsCache |  0x0400)
				:  (this._flagsCache & ~0x0400))
			}
		}
		
		MeasureTrails {
			Get {
				Return (!!(this._flagsCache & 0x0800))
			}
			Set {
				Return this.RawFlags := this._flagsCache := (value
				?  (this._flagsCache |  0x0800)
				:  (this._flagsCache & ~0x0800))
			}
		}
		
		NoWrap {
			Get {
				Return (!!(this._flagsCache & 0x1000))
			}
			Set {
				Return this.RawFlags := this._flagsCache := (value
				?  (this._flagsCache |  0x1000)
				:  (this._flagsCache & ~0x1000))
			}
		}
		
		LineLimit {
			Get {
				Return (!!(this._flagsCache & 0x2000))
			}
			Set {
				Return this.RawFlags := this._flagsCache := (value
				?  (this._flagsCache |  0x2000)
				:  (this._flagsCache & ~0x2000))
			}
		}
		
		NoClip {  ; SPISPOPD
			Get {
				Return (!!(this._flagsCache & 0x4000))
			}
			Set {
				Return this.RawFlags := this._flagsCache := (value
				?  (this._flagsCache |  0x4000)
				:  (this._flagsCache & ~0x4000))
			}
		}
		
		
		; Sets character ranges to measure. Used in Graphics.MeasureString.
		; Note: maximum measurable range count in GDI+ is limited to 32.
		
		SetMeasurableCharacterRanges( ranges ) {
			Local
			Global OGdip
			
			rangesFlatArray := OGdip._FlattenArray(ranges)
			OGdip._CreateBinArray(rangesFlatArray, rangesBinArray := 0, "Int")
			
			DllCall("GdiPlus\GdipSetStringFormatMeasurableCharacterRanges"
			, "Ptr" ,  this._pStringFormat
			, "Int" ,  rangesFlatArray.Length() // 2
			, "Ptr" , &rangesBinArray)
		}
		
		
		; Sets various properties and parameters in bulk using single object.
		; From the code below you can deduce what key corresponds to what property.
		
		SetOptions( opts ) {
			If (IsObject(opts) == False)
				Return this
			
			(!opts.HasKey("align"))       ? "" :  (this.Align        := opts["align"])
			(!opts.HasKey("lineAlign"))   ? "" :  (this.LineAlign    := opts["lineAlign"])
			(!opts.HasKey("trimming"))    ? "" :  (this.Trimming     := opts["trimming"])
			(!opts.HasKey("tabStops"))    ? "" :  (this.TabStops     := opts["tabStops"])
			(!opts.HasKey("hotkey"))      ? "" :  (this.HotkeyPrefix := opts["hotkey"])
			
			(!opts.HasKey("ranges"))      ? "" :  (this.SetMeasurableCharacterRanges(opts["ranges"]))
			
			(!opts.HasKey("rtl"))         ? "" :  (this.RightToLeft    := opts["rtl"])
			(!opts.HasKey("vertical"))    ? "" :  (this.Vertical       := opts["vertical"])
			(!opts.HasKey("overhang"))    ? "" :  (this.Overhang       := opts["overhang"])
			(!opts.HasKey("showCtrl"))    ? "" :  (this.ShowControl    := opts["showCtrl"])
			(!opts.HasKey("fallback"))    ? "" :  (this.NoFontFallback := opts["fallback"])
			(!opts.HasKey("countTrails")) ? "" :  (this.MeasureTrails  := opts["countTrails"])
			(!opts.HasKey("noWrap"))      ? "" :  (this.NoWrap         := opts["noWrap"])
			(!opts.HasKey("lineClip"))    ? "" :  (this.LineLimit      := opts["lineClip"])
			(!opts.HasKey("noClip"))      ? "" :  (this.NoClip         := opts["noClip"])
			
			Return this
		}
	}
	
	
	
	; Graphics class
	; ==============
	; 
	; Graphics is used to draw figures and images.
	; 
	; Constructors:
	;   > gr := new OGdip.Graphics( oImage )
	;   > gr := new OGdip.Graphics( "*HDC", hDC )
	;   > gr := new OGdip.Graphics( "*HWND", hWnd [, useICM] )
	; 
	; Properties:
	;   .Pen
	;   .Brush
	;   .PageScale
	;   .PageUnit
	;   .DPI
	; 
	; Methods:
	;   .SetPen( args* )
	;   .SetBrush( args* )
	;   .GetDC()
	;   .ReleaseDC( pHDC )
	;   .GetNearestColor( argb )
	;   .SetOptions( opts )
	;   .GetOptions()
	;   .Flush( [flushSync] )
	;   .Clear( [argb] )
	; 
	; Drawing methods:
	;   .DrawLine( points* )
	;   .DrawBezier( points* )
	;   .DrawCurve( points* [, options] )
	;   .DrawPolygon( points* [, fillMode] )
	;   .DrawClosedCurve( points* [, options] )
	;   .DrawArc( x, y, w, h, startAngle, sweepAngle )
	;   .DrawArcC( cx, cy, rx, ry, startAngle, sweepAngle )
	;   .DrawPie( x, y, w, h, startAngle, sweepAngle )
	;   .DrawPieC( cx, cy, rx, ry, startAngle, sweepAngle )
	;   .DrawEllipse( x, y, w [, h] )
	;   .DrawEllipseC( cx, cy, rx [, ry] )
	;   .DrawRectangle( x, y, w [, h] )
	;   .DrawRectangleC( cx, cy, rx [, ry] )
	;   .DrawRoundedRectangle( x, y, w, h, rx [, ry] )
	;   .DrawPath( oPath )
	;   .DrawRegion( oRegion )
	;   .DrawImage( image, <destination> [, <source>, oAttributes] )
	;   .DrawImageC( image, x, y [, angle, scaleX, scaleY, oAttributes] )
	;   
	; Note: most drawing methods return Graphics object itself, which allows chaining:
	;   > gr.SetPen(redPen).SetBrush().DrawRectangle(0,0,100,50).SetPen(mainPen).SetBrush(mainBrush)
	; 
	; Text methods:
	;   .DrawString( text, font, x, y [, w, h][, format] )
	;   .DrawDriverString( text, font, positions [, oMatrix, flags] )
	;   .MeasureString( text, font, x, y [, w, h][, strFormat, ranges] )
	;   .MeasureDriverString( text, font, positions [, oMatrix, flags] )
	; 
	; Transform methods (world space):
	;   .TransformReset()
	;   .TransformMove( dx, dy [, mxOrder] )
	;   .TransformScale( sx, sy [, mxOrder] )
	;   .TransformRotate( angle [, mxOrder] )
	;   .TransformRotateAt( cx, cy, angle [, mxOrder] )
	;   .TransformMatrix( oMatrix [, mxOrder] )
	;   .SetTransformMatrix( oMatrix )
	;   .GetTransformMatrix()
	;   .TransformPoints( fromSpace, toSpace, points* )
	; 
	; Clipping:
	;   .ResetClip()
	;   .SetClip( object [, combineMode] )
	;   .MoveClip( moveX, moveY )
	;   .GetClip()
	;   .GetClipBounds( [onlyVisible] )
	;   .IsClipEmpty()
	;   .IsVisible( x, y [, w, h]
	; 
	; State and containers:
	;   .SaveState()
	;   .RestoreState( stateId )
	;   .BeginContainer( [srcRect, dstRect, unit] )
	;   .EndContainer( containerId )
	
	Class Graphics {
		
		__New( source, handle := 0, useICM := False ) {
			Local
			Global OGdip
			
			pGraphics := 0
			
			If (IsObject(source) == True)
			&& ((source.Base == OGdip.Image)
			||  (source.Base == OGdip.Bitmap)
			||  (source.Base == OGdip.Metafile))
			{
				DllCall("GdiPlus\GdipGetImageGraphicsContext"
				, "Ptr" , source._pImage
				, "Ptr*", pGraphics)
				
			} Else
			If (source == "*HDC") {
				DllCall("GdiPlus\GdipCreateFromHDC"
				, "Ptr" , handle
				, "Ptr*", pGraphics)
				
			} Else
			If (source == "*HWND") {
				DllCall("GdiPlus\GdipCreateFromHWND" . (useICM ? "ICM" : "")
				, "Ptr" , handle
				, "Ptr*", pGraphics)
			}
			
			
			If (pGraphics == 0) {
				this.Base := False  ; Avoid calling __Delete
				Return False
			}
			
			this._pGraphics := pGraphics
			this._Pen   := ""
			this._Brush := ""
		}
		
		
		__Delete() {
			DllCall("GdiPlus\GdipDeleteGraphics"
			, "Ptr", this._pGraphics)
		}
		
		
		; Pen/Brush properties
		; Setting empty string will remove current pen/brush.
		; Setting Pen/Brush object will set it as a current pen/brush.
		; Anything else will be used to initialize new pen/brush.
		; See also .SetPen/.SetBrush methods below.
		
		Pen {
			Get {
				Return this._Pen
			}
			Set {
				If (value == "")
					Return (this._Pen := "")
				
				If (IsObject(value) == True)
				&& (value.Base == OGdip.Pen)
					Return (this._Pen := value)
				
				Return (this._Pen := new OGdip.Pen(value))
			}
		}
		
		Brush {
			Get {
				Return this._Brush
			}
			Set {
				If (value == "")
					Return (this._Brush := "")
				
				If (IsObject(value) == True)
				&& (value.Base.Base == OGdip.Brush)
					Return (this._Brush := value)
				
				Return (this._Brush := new OGdip.Brush(value))
			}
		}
		
		
		; Gets/sets page scale.
		; Page is a different coordinate system than world transform.
		
		PageScale {
			Get {
				Local
				
				DllCall("GdiPlus\GdipGetPageScale"
				, "Ptr"   , this._pGraphics
				, "Float*", gpScale := -1)
				
				Return gpScale
			}
			Set {
				DllCall("GdiPlus\GdipSetPageScale"
				, "Ptr"  , this._pGraphics
				, "Float", value)
				
				Return value
			}
		}
		
		
		; Gets/sets page unit.
		; Note: unit is returned as a number,
		; use OGdip.Enum.GetName("Unit", value) to get name.
		
		PageUnit {
			Get {
				Local
				
				DllCall("GdiPlus\GdipGetPageUnit"
				, "Ptr"  , this._pGraphics
				, "UInt*", gpUnit := -1)
				
				Return gpUnit
			}
			Set {
				DllCall("GdiPlus\GdipSetPageUnit"
				, "Ptr"  , this._pGraphics
				, "UInt" , OGdip.Enum.Get("Unit", value, 0))
				
				Return value
			}
		}
		
		
		; Gets resolution as an array of two elements. Read-only.
		
		DPI {
			Get {
				Local
				
				DllCall("GdiPlus\GdipGetDpiX"
				, "Ptr"   , this._pGraphics
				, "Float*", dpiX := 0)
				
				DllCall("GdiPlus\GdipGetDpiY"
				, "Ptr"   , this._pGraphics
				, "Float*", dpiY := 0)
				
				Return [ dpiX, dpiY ]
			}
			Set {
				Return value
			}
		}
		
		
		; Set current Pen/Brush. Support method chaining.
		
		SetPen( args* ) {
			this.Pen := (args.Length() == 1)
			?  args[1]
			:  new OGdip.Pen(args*)
			
			Return this
		}
		
		SetBrush( args* ) {
			this.Brush := (args.Length() == 1)
			?  args[1]
			:  new OGdip.Brush(args*)
			
			Return this
		}
		
		
		; Get device context associated with Graphics object.
		; Do not call any Graphics methods between .GetDC and .ReleaseDC calls.
		
		GetDC() {
			Local
			
			DllCall("GdiPlus\GdipGetDC"
			, "Ptr" , this._pGraphics
			, "Ptr*", pHDC := 0)
			
			Return pHDC
		}
		
		ReleaseDC( pHDC ) {
			DllCall("GdiPlus\GdipReleaseDC"
			, "Ptr" , this._pGraphics
			, "Ptr" , pHDC)
		}
		
		
		; Returns nearest color for devices with 8-bpp or lower.
		
		GetNearestColor( argb ) {
			Local
			
			DllCall("GdiPlus\GdipGetNearestColor"
			, "Ptr"  , this._pGraphics
			, "UInt*", argb := 0)
			
			Return argb
		}
		
		
		; Sets various options. Supports chaining.
		; Takes one argument: either strings 'High' or 'Low', or an object with following fields:
		;   • composeOver
		;     • True  - semi-transparent drawings will blend with background.
		;     • False - semi-transparent drawings will replace background and its alpha values.
		;   
		;   • gammaBlend - Try enabling this if blend colors looks dark and muddy.
		;     • True  - perform gamma-corrected color blending (convert to linear, blend, convert to sRGB).
		;     • False - perform simple color blending
		;   
		;   • halfPixel  - Try enabling this if lines with integer coordinates looks blurry.
		;     • True  - pixel grid is shifted by half-pixel.
		;     • False - pixel grid starts at 0:0
		;   
		;   • renderOrigin  - Object {x:N, y:N} with origin for ordered dithering and hatch brushes.
		;   
		;   • interpolate   - Interpolation algorithm for scaled and rotated bitmaps.
		;     • 0 = "Nearest"
		;     • 1 = "Bilinear"
		;     • 2 = "Bicubic"
		;     • 3 = "HQBilinear"
		;     • 4 = "HQBicubic"
		;   
		;   • smooth  - Antialiasing algorithm for drawing lines and filled figures.
		;     • 0 = "None"
		;     • 1 = "8x4"
		;     • 2 = "8x8"
		;     
		;   • textHint  - Antialiasing algorithm for drawing text.
		;     • 0 = "System"        - System default mode
		;     • 1 = "Bitmap"        - Aliased bitmap, not hinted
		;     • 2 = "BitmapHint"    - Aliased bitmap, hinted
		;     • 3 = "Antialias"     - Antialiased, not hinted
		;     • 4 = "AntialiasHint" - Antialiased, hinted
		;     • 5 = "ClearType"     - Subpixel antialiasing, hinted
		
		SetOptions( opts ) {
			If (opts = "High")
			|| (opts == 1)
			{
				opts := { 0:0
				, gammaBlend  : True
				, halfPixel   : True
				, interpolate : "HQBicubic"
				, smooth      : "8x8"
				, textHint    : "AntialiasHint" }
				
			} Else
			If (opts = "Low")
			|| (opts == 0)
			{
				opts := { 0:0
				, gammaBlend  : False
				, halfPixel   : False
				, interpolate : "Nearest"
				, smooth      : "None"
				, textHint    : "BitmapHint" }
			}
			
			If (opts.HasKey("composeOver")) {
				DllCall("GdiPlus\GdipSetCompositingMode"
				, "Ptr" , this._pGraphics
				, "UInt", (opts.composeOver ? 0 : 1))  ; SourceOver = 0, SourceCopy = 1
			}
			
			If (opts.HasKey("gammaBlend")) {
				DllCall("GdiPlus\GdipSetCompositingQuality"
				, "Ptr" , this._pGraphics
				, "UInt", (opts.gammaBlend ? 2 : 1))   ; HighQuality = 2, HighSpeed = 1
			}
			
			If (opts.HasKey("halfPixel")) {
				DllCall("GdiPlus\GdipSetPixelOffsetMode"
				, "Ptr" , this._pGraphics
				, "UInt", (opts.halfPixel ? 2 : 1))    ; HighQuality = 2, HighSpeed = 1
			}
			
			If (opts.HasKey("renderOrigin")) {
				DllCall("GdiPlus\GdipSetRenderingOrigin"
				, "Ptr" , this._pGraphics
				, "Int" , opts.renderOrigin.x
				, "Int" , opts.renderOrigin.y)
			}
			
			If (opts.HasKey("textContrast")) {
				DllCall("GdiPlus\GdipSetTextContrast"
				, "Ptr" , this._pGraphics
				, "UInt", opts.textContrast)
			}
			
			If (opts.HasKey("interpolate")) {
				DllCall("GdiPlus\GdipSetInterpolationMode"
				, "Ptr" , this._pGraphics
				, "UInt", (False ? 0
				:   ((opts.interpolate == 0) || (opts.interpolate = "Nearest"))    ?  5
				:   ((opts.interpolate == 1) || (opts.interpolate = "Bilinear"))   ?  3
				:   ((opts.interpolate == 2) || (opts.interpolate = "Bicubic"))    ?  4
				:   ((opts.interpolate == 3) || (opts.interpolate = "HQBilinear")) ?  6
				:   ((opts.interpolate == 4) || (opts.interpolate = "HQBicubic"))  ?  7  :  3))
			}
			
			If (opts.HasKey("smooth")) {
				DllCall("GdiPlus\GdipSetSmoothingMode"
				, "Ptr" , this._pGraphics
				, "UInt", (False ? 0
				:   ((opts.smooth == 0) || (opts.smooth = "None")) ?  3
				:   ((opts.smooth == 1) || (opts.smooth = "8x4"))  ?  4
				:   ((opts.smooth == 2) || (opts.smooth = "8x8"))  ?  5  :  4))
			}
			
			If (opts.HasKey("textHint")) {
				DllCall("GdiPlus\GdipSetTextRenderingHint"
				, "Ptr" , this._pGraphics
				, "UInt", (False ? 0
				:   ((opts.textHint == 0) || (opts.textHint = "System"))        ?  0
				:   ((opts.textHint == 1) || (opts.textHint = "Bitmap"))        ?  2
				:   ((opts.textHint == 2) || (opts.textHint = "BitmapHint"))    ?  1
				:   ((opts.textHint == 3) || (opts.textHint = "Antialias"))     ?  4
				:   ((opts.textHint == 4) || (opts.textHint = "AntialiasHint")) ?  3
				:   ((opts.textHint == 5) || (opts.textHint = "ClearType"))     ?  5  :  0))
			}
			
			Return this
		}
		
		
		; Gets various options. Returns an object with the fields described in .SetOptions.
		
		GetOptions() {
			Local
			
			DllCall("GdiPlus\GdipGetCompositingMode"   , "Ptr", this._pGraphics, "UInt*", compositingMode    := 0)
			DllCall("GdiPlus\GdipGetCompositingQuality", "Ptr", this._pGraphics, "UInt*", compositingQuality := 0)
			DllCall("GdiPlus\GdipGetInterpolationMode" , "Ptr", this._pGraphics, "UInt*", interpolationMode  := 0)
			DllCall("GdiPlus\GdipGetPixelOffsetMode"   , "Ptr", this._pGraphics, "UInt*", pixelOffsetMode    := 0)
			DllCall("GdiPlus\GdipGetSmoothingMode"     , "Ptr", this._pGraphics, "UInt*", smoothingMode      := 0)
			DllCall("GdiPlus\GdipGetTextRenderingHint" , "Ptr", this._pGraphics, "UInt*", textRenderingHint  := 0)
			
			DllCall("GdiPlus\GdipGetRenderingOrigin"   , "Ptr", this._pGraphics, "Int*" , originX := 0, "Int*", originY := 0)
			DllCall("GdiPlus\GdipGetTextContrast"      , "Ptr", this._pGraphics, "UInt*", textContrast  := 0)
			
			retOptions := {}
			
			; See GdiPlusEnums.h and MSDN documentation for clarification
			retOptions.composeOver := !compositingMode
			retOptions.gammaBlend  := (compositingQuality == 2) || (compositingQuality == 3)
			retOptions.halfPixel   := (pixelOffsetMode == 2) || (pixelOffsetMode == 4)
			
			retOptions.renderOrigin := {x: originX, y: originY}
			retOptions.textContrast := textContrast
			
			retOptions.interpolate := False ? ""
			:  (interpolationMode == 3)  ?  "Bilinear"
			:  (interpolationMode == 4)  ?  "Bicubic"
			:  (interpolationMode == 5)  ?  "Nearest"
			:  (interpolationMode == 6)  ?  "HQBilinear"
			:  (interpolationMode == 7)  ?  "HQBicubic"  : "Default"
			
			retOptions.smooth := False ? ""
			:  (smoothingMode == 2)  ?  "8x4"
			:  (smoothingMode == 4)  ?  "8x4"
			:  (smoothingMode == 5)  ?  "8x8"  :  "None"
			
			retOptions.textHint := False ? ""
			:  (textRenderingHint == 1)  ?  "BitmapHint"
			:  (textRenderingHint == 2)  ?  "Bitmap"
			:  (textRenderingHint == 3)  ?  "AntialiasHint"
			:  (textRenderingHint == 4)  ?  "Antialias"
			:  (textRenderingHint == 5)  ?  "ClearType"  :  "System"
			
			Return retOptions
		}
		
		
		; Flushes all pending graphics operations.
		; I have no idea what this means.
		
		Flush( flushSync := True ) {
			DllCall("GdiPlus\GdipFlush"
			, "Ptr" , this._pGraphics
			, "UInt", flushSync)
		}
		
		
		; Clears all graphics to a specified color. Supports chaining.
		
		Clear( argb := 0x0 ) {
			DllCall("GdiPlus\GdipGraphicsClear"
			, "Ptr" , this._pGraphics
			, "UInt", argb)
			
			Return this
		}
		
		
		; == Drawing ==
		; All drawing methods support chaining, unless otherwise specified.
		
		; -- Open lines and curves --
		; Each function takes multiple pairs of arguments, one coord pair per point.
		; Arrays of point coords can be passed as well, mixed arguments are supported.
		;   > gr.DrawLine(  x1,y1, x2,y2, ...  )
		;   > gr.DrawLine( [x1,y1, x2,y2, ...] )
		
		
		; Draws a sequence of connected straight lines.
		; End point for one line is the start point for the next one.
		; See also .DrawPolygon to draw and fill closed figure of straight lines.
		
		DrawLine( points* ) {
			Local
			Global OGdip
			
			If (this._Pen == "")
				Return this
			
			points := OGdip._FlattenArray(points)
			
			OGdip._CreateBinArray(points, binPoints := "", "Float")
			
			DllCall("GdiPlus\GdipDrawLines"
			, "Ptr" ,  this._pGraphics
			, "Ptr" ,  this._Pen._pPen
			, "Ptr" , &binPoints
			, "Int" , (points.Length() // 2))
			
			Return this
		}
		
		
		; Draws a sequence of connected cubic bezier splines.
		; End point for one spline is the start point for the next one.
		; Points argument sequence is PX,PY, [CX,CY, CX,CY, PX,PY]*N
		; where PX,PY is the start/end point, and CX,CY are control points.
		
		DrawBezier( points* ) {
			Local
			Global OGdip
			
			If (this._Pen == "")
				Return this
			
			points := OGdip._FlattenArray(points)
			
			OGdip._CreateBinArray(points, binPoints := "", "Float")
			
			DllCall("GdiPlus\GdipDrawBeziers"
			, "Ptr" ,  this._pGraphics
			, "Ptr" ,  this._Pen._pPen
			, "Ptr" , &binPoints
			, "Int" , (points.Length() // 2))
			
			Return this
		}
		
		
		; Draws a cardinal spline that passes through given points.
		;   > gr.DrawCurve( x1,y1, x2,y2, ... [, options] )
		;   > gr.DrawCurve( [x1,y1, x2,y2], ... [, options] )
		;   > gr.DrawCurve( ... [, options] )
		; 
		; Optional last argument should be an object and can contain following fields:
		;   • tension    - How tightly the curve bends through the points, default=0.5
		;   • startPoint - Index of point to start drawing from, default=1
		;   • endPoint   - Index of point to end drawing. Have priority over .segments.
		;   • segments   - Number of segments between startPoint and endPoint.
		; Alternatively, last argument may be a single number that specifies tension only.
		; 
		; See also .DrawClosedCurve to draw and fill closed cardinal spline.
		
		DrawCurve( points* ) {
			Local
			Global OGdip
			
			If (this._Pen == "")
				Return this
			
			options := 0
			lastArg := points[ points.Length() ]
			
			If (IsObject(lastArg) == True)  ; Last argument is an object
			&& (lastArg.Length() == 0)      ; but is not a coords array.
			{
				options := points.Pop()
			}
			
			points := OGdip._FlattenArray(points)
			pointsCount := points.Length() // 2
			
			; Default options
			tension    := 0.5
			startPoint := 0
			segments   := pointsCount-1
			
			If (points.Length() & 1 == 1) {
				tension := points.Pop()
			}
			
			; Parse options
			If (options != 0) {
				If (options.HasKey("tension"))
					tension := options.tension
				
				If (options.HasKey("startPoint"))
					startPoint := Min( pointsCount-1, options.startPoint-1 )
					
				If (options.HasKey("endPoint")) {
					segments := Min((pointsCount-startPoint-1), (options.endPoint-1 - startPoint))
					
				} Else
				If (options.HasKey("segments")) {
					segments := Min((pointsCount-startPoint-1), options.segments)
				}
			}
			
			OGdip._CreateBinArray(points, binPoints := "", "Float")
			
			DllCall("GdiPlus\GdipDrawCurve3"
			, "Ptr"  ,  this._pGraphics
			, "Ptr"  ,  this._Pen._pPen
			, "Ptr"  , &binPoints
			, "Int"  ,  pointsCount
			, "Int"  ,  startPoint
			, "Int"  ,  segments
			, "Float",  tension)
			
			Return this
		}
		
		
		; -- Closed polygons and curves --
		
		; Draws and fills closed polygon with straight lines.
		; Optional argument 'fillMode' specifies fill behavior
		; with self-intersecting paths: 0 - alternate; 1 - winding.
		;   > gr.DrawPolygon(  x1,y1, x2,y2, ...  [, fillMode] )
		;   > gr.DrawPolygon( [x1,y1, x2,y2, ...] [, fillMode] )
		
		DrawPolygon( points* ) {
			Local
			Global OGdip
			
			points := OGdip._FlattenArray(points)
			
			fillMode := 0
			
			If ((points.Length() & 1) == 1) {
				fillMode := !!(points.Pop())
			}
			
			pointsCount := points.Length() // 2
			OGdip._CreateBinArray(points, binPoints := "", "Float")
			
			If (this._Brush != "") {
				DllCall("GdiPlus\GdipFillPolygon"
				, "Ptr" ,  this._pGraphics
				, "Ptr" ,  this._Brush._pBrush
				, "Ptr" , &binPoints
				, "Int" ,  pointsCount
				, "UInt",  fillMode)
			}
			
			If (this._Pen != "") {
				DllCall("GdiPlus\GdipDrawPolygon"
				, "Ptr" ,  this._pGraphics
				, "Ptr" ,  this._Pen._pPen
				, "Ptr" , &binPoints
				, "Int" ,  pointsCount)
			}
			
			Return this
		}
		
		
		; Draws and fills closed cardinal spline.
		; Last argument is optional and can be either a number (tension) or an object (see below).
		;   > gr.DrawClosedCurve( x1,y1, x2,y2, ... [, tension] )
		;   > gr.DrawClosedCurve( pointsArray [, tension] )
		;   > gr.DrawClosedCurve( ... [, options] )
		; 
		; Object 'options' can contain following fields:
		;   • tension
		;   • fillMode
		
		DrawClosedCurve( points* ) {
			Local
			Global OGdip
			
			options := 0
			lastArg := points[ points.Length() ]
			
			If (IsObject(lastArg) == True)
			&& (lastArg.Length() == 0)
			{
				options := points.Pop()
			}
			
			points := OGdip._FlattenArray(points)
			
			tension  := 0.5
			fillMode := 0
			
			If (points.Length() & 1 == 1) {
				tension := points.Pop()
			}
			
			If (IsObject(options) == True) {
				If (options.HasKey("tension"))
					tension := options.tension
				
				If (options.HasKey("fillMode"))
					fillMode := options.fillMode
			}
			
			pointsCount := points.Length() // 2
			OGdip._CreateBinArray(points, pointsArray := "", "Float")
			
			If (this._Brush != "") {
				DllCall("GdiPlus\GdipFillClosedCurve2"
				, "Ptr"  ,  this._pGraphics
				, "Ptr"  ,  this._Brush._pBrush
				, "Ptr"  , &pointsArray
				, "Int"  ,  pointsCount
				, "Float",  tension
				, "UInt" , (fillMode ? 1 : 0))
			}
			
			If (this._Pen != "") {
				DllCall("GdiPlus\GdipDrawClosedCurve2"
				, "Ptr"  ,  this._pGraphics
				, "Ptr"  ,  this._Pen._pPen
				, "Ptr"  , &pointsArray
				, "Int"  ,  pointsCount
				, "Float",  tension)
			}
			
			Return this
		}
		
		
		; -- Elliptic figures --
		; Arguments x,y,w,h specify a rectangle that bounds the main ellipse.
		; C-functions specify main ellipse by center point and two radii.
		; Angles are in degrees, clockwise (!) and relative to the world, not ellipse.
		
		; Draws an arc.
		
		DrawArc( x, y, w, h, startAngle, sweepAngle ) {
			If (this._Pen == "")
				Return this
			
			DllCall("GdiPlus\GdipDrawArc"
			, "Ptr"  , this._pGraphics
			, "Ptr"  , this._Pen._pPen
			, "Float", x
			, "Float", y
			, "Float", w
			, "Float", h
			, "Float", startAngle
			, "Float", sweepAngle)
			
			Return this
		}
		
		DrawArcC( cx, cy, rx, ry, startAngle, sweepAngle ) {
			Return this.DrawArc( cx-rx, cy-ry, rx*2, ry*2, startAngle, sweepAngle )
		}
		
		
		; Draws and fills a pie.
		
		DrawPie( x, y, w, h, startAngle, sweepAngle ) {
			Local
			
			args := []
			args.Push("Float", x
			,         "Float", y
			,         "Float", w
			,         "Float", h
			,         "Float", startAngle
			,         "Float", sweepAngle)
			
			If (this._Brush != "") {
				DllCall("GdiPlus\GdipFillPie"
				, "Ptr" , this._pGraphics
				, "Ptr" , this._Brush._pBrush
				, args*)
			}
			
			If (this._Pen != "") {
				DllCall("GdiPlus\GdipDrawPie"
				, "Ptr" , this._pGraphics
				, "Ptr" , this._Pen._pPen
				, args*)
			}
			
			Return this
		}
		
		DrawPieC( cx, cy, rx, ry, startAngle, sweepAngle ) {
			Return this.DrawPie( cx-rx, cy-ry, rx*2, ry*2, startAngle, sweepAngle )
		}
		
		
		; Draws and fills an ellipse or (if last argument is omitted) a circle.
		
		DrawEllipse( x, y, w, h := "" ) {
			If (h == "")
				h := w
			
			args := []
			args.Push("Float", x
			,         "Float", y
			,         "Float", w
			,         "Float", h)
			
			If (this._Brush != "") {
				DllCall("GdiPlus\GdipFillEllipse"
				, "Ptr" , this._pGraphics
				, "Ptr" , this._Brush._pBrush
				, args*)
			}
			
			If (this._Pen != "") {
				DllCall("GdiPlus\GdipDrawEllipse"
				, "Ptr" , this._pGraphics
				, "Ptr" , this._Pen._pPen
				, args*)
			}
			
			Return this
		}
		
		DrawEllipseC( cx, cy, rx, ry := "" ) {
			If (ry == "")
				ry := rx
			
			Return this.DrawEllipse( cx-rx, cy-ry, rx*2, ry*2 )
		}
		
		
		; Draws and fills rectangle or (if last argument is omitted) a square.
		
		DrawRectangle( x, y, w, h := "" ) {
			If (h == "")
				h := w
			
			args := []
			args.Push("Float", x
			,         "Float", y
			,         "Float", w
			,         "Float", h)
			
			If (this._Brush != "") {
				DllCall("GdiPlus\GdipFillRectangle"
				, "Ptr" , this._pGraphics
				, "Ptr" , this._Brush._pBrush
				, args*)
			}
			
			If (this._Pen != "") {
				DllCall("GdiPlus\GdipDrawRectangle"
				, "Ptr" , this._pGraphics
				, "Ptr" , this._Pen._pPen
				, args*)
			}
			
			Return this
		}
		
		DrawRectangleC( cx, cy, rx, ry := "" ) {
			If (ry == "")
				ry := rx
			
			Return this.DrawRectangle( cx-rx, cy-ry, rx*2, ry*2 )
		}
		
		
		; Draws and fills rounded rectangle.
		
		DrawRoundedRectangle( x, y, w, h, rx, ry := "" ) {
			Local
			Global OGdip
			
			rrPath := new OGdip.Path()
			rrPath.AddRoundedRectangle(x, y, w, h, rx, ry)
			this.FillPath(rrPath)
			this.DrawPath(rrPath)
			
			Return this
		}
		
		
		; Draws and fills Path (see Path class).
		
		DrawPath( oPath ) {
			If (this._Brush != "") {
				DllCall("GdiPlus\GdipFillPath"
				, "Ptr" , this._pGraphics
				, "Ptr" , this._Brush._pBrush
				, "Ptr" , oPath._pPath)
			}
			
			If (this._Pen != "") {
				DllCall("GdiPlus\GdipDrawPath"
				, "Ptr" , this._pGraphics
				, "Ptr" , this._Pen._pPen
				, "Ptr" , oPath._pPath)
			}
			
			Return this
		}
		
		
		; Fills Region (see Region class).
		
		FillRegion( oRegion ) {
			If (this._Brush == "")
				Return this
			
			DllCall("GdiPlus\GdipFillRegion"
			, "Ptr" , this._pGraphics
			, "Ptr" , this._Brush._pBrush
			, "Ptr" , oRegion._pRegion)
			
			Return this
		}
		
		
		; Draw an image or selected area of it with given transformation.
		;   > gr.DrawImage( oImage, <Destination> [, <SourceArea>, ImageAttributes] )
		;   
		; Destination argset can be:
		;   • Two numbers or a single array of two numbers: DX, DY
		;     Image will be drawn at position DX,DY with original size.
		;     You can't specify SourceArea in this case.
		;     If image is CachedBitmap, only these arguments will be used.
		;   
		;   • Four numbers or a single array of four numbers: DX, DY, DW, DH
		;     Image will be drawn at position DX,DY with size DW,DH.
		;   
		;   • Six numbers or a single array of six numbers: X1,Y1, X2,Y2, X3,Y3
		;     Specifies coordinates of top-left, top-right and bottom-left points
		;     of a parallelogram to fit image into.
		;   
		;   • Instance of OGdip.Matrix
		;     A matrix that defines affine transformation of the drawn image.
		; 
		; SourceArea argset can be:
		;   • Four numbers or a single array of four numbers: SX, SY, SW, SH
		;     Specifies area of the image to be drawn.
		; 
		;     If <SourceArea> is omitted, whole image will be drawn.
		; 
		; ImageAttributes argument:
		;   • If set, it will take precedence over built-in attributes.
		;   • If omitted, built-in attributes will be used (if present).
		
		DrawImage( oImage, args* ) {
			Local
			Global OGdip
			
			; Simplest case: CachedBitmap
			If (oImage.Base == OGdip.CachedBitmap) {
				DllCall("GdiPlus\GdipDrawCachedBitmap"
				, "Ptr" , this._pGraphics
				, "Ptr" , oImage._pCachedBitmap
				, "Int" , args[1]
				, "Int" , args[2])
				
				Return this
			}
			
			; Is last argument an ImageAttributes?
			attributesPtr := 0
			lastArg := args[ args.Length() ]
			
			If (IsObject(lastArg) == True)
			&& (lastArg.Base == OGdip.ImageAttributes)
			{
				attributesPtr := (args.Pop())._pAttributes
				
			} Else
			If (IsObject(oImage.Attributes))
			&& (oImage.Attributes.Base == OGdip.ImageAttributes)
			{
				attributesPtr := oImage.Attributes._pAttributes
			}
			
			srcTransform := ""
			dstTransform := ""
			
			; Destination
			If (IsObject(args[1])) {
				dstTransform := args.RemoveAt(1)  ; DSTRECT*, DST3PT*, MATRIX*
				
			} Else {
				If (args.Length() == 4)   ; DX,DY,DW,DH
				|| (args.Length() == 5)   ; DX,DY,DW,DH, SRCRECT*
				|| (args.Length() == 8)   ; DX,DY,DW,DH, SX,SY,SW,SH
				{
					dstTransform := [ args[1], args[2], args[3], args[4] ]
					args.RemoveAt(1, 4)
					
				} Else
				If (args.Length() == 6)   ; PX1,PY1,PX2,PY2,PX3,PY3
				|| (args.Length() == 7)   ; PX1,PY1,PX2,PY2,PX3,PY3, SRCRECT*
				|| (args.Length() == 10)  ; PX1,PY1,PX2,PY2,PX3,PY3, SX,SY,SW,SH
				{
					dstTransform := [ args[1], args[2], args[3], args[4], args[5], args[6] ]
					args.RemoveAt(1, 6)
					
				} Else {                  ; DX,DY
					dstTransform := [ args[1], args[2] ]
					args.RemoveAt(1, 2)
				}
			}
			
			; Source
			If (IsObject(args[1]))                ; SRCRECT*
			&& (args[1].Length() == 4)
			{
				srcTransform := args.RemoveAt(1)
				
			} Else
			If (args.Length() == 4) {             ; SX,SY,SW,SH
				srcTransform := [ args[1], args[2], args[3], args[4] ]
				
			} Else {
				; Width/Height properties is unreliable in some cases.
				; Different frames in multiframe images can have different sizes.
				; Some metafiles' upper-left corner may not be (0,0).
				srcTransform := oImage.GetBounds()
			}
			
			; Update destination if only X/Y were given
			If (dstTransform.Length() == 2) {
				dstTransform.Push( srcTransform[3], srcTransform[4] )
			}
			
			; Clip source area to image bounds
			imageBounds := oImage.GetBounds()
			srcTransform[1] := Max(srcTransform[1], imageBounds[1])
			srcTransform[2] := Max(srcTransform[2], imageBounds[2])
			srcTransform[3] := Min(srcTransform[3], imageBounds[3] - (srcTransform[1] - imageBounds[1]))
			srcTransform[4] := Min(srcTransform[4], imageBounds[4] - (srcTransform[2] - imageBounds[2]))
			
			
			; Choose method to draw
			If (dstTransform.Base == OGdip.Matrix) {
				OGdip._CreateBinArray(srcTransform, srcRectArray := "", "Float")
				DllCall("GdiPlus\GdipDrawImageFX"
				, "Ptr" , this._pGraphics
				, "Ptr" , oImage._pImage
				, "Ptr" , &srcRectArray
				, "Ptr" , dstTransform._pMatrix
				, "Ptr" , 0   ; Effect is ignored - function is already too complex
				, "Ptr" , attributesPtr
				, "UInt", 2)  ; Unit - Pixel
				
			} Else
			If (dstTransform.Length() == 6) {
				OGdip._CreateBinArray(dstTransform, dstPointsArray := "", "Float")
				DllCall("GdiPlus\GdipDrawImagePointsRect"
				, "Ptr"  , this._pGraphics
				, "Ptr"  , oImage._pImage
				, "Ptr"  , &dstPointsArray
				, "Int"  , 3
				, "Float", srcTransform[1]
				, "Float", srcTransform[2]
				, "Float", srcTransform[3]
				, "Float", srcTransform[4]
				, "UInt" , 2  ; Unit
				, "Ptr"  , attributesPtr
				, "Ptr"  , 0
				, "Ptr"  , 0)
				
			} Else {
				DllCall("GdiPlus\GdipDrawImageRectRect"
				, "Ptr"  , this._pGraphics
				, "Ptr"  , oImage._pImage
				, "Float", dstTransform[1]
				, "Float", dstTransform[2]
				, "Float", dstTransform[3]
				, "Float", dstTransform[4]
				, "Float", srcTransform[1]
				, "Float", srcTransform[2]
				, "Float", srcTransform[3]
				, "Float", srcTransform[4]
				, "UInt" , 2  ; Unit
				, "Ptr"  , attributesPtr
				, "Ptr"  , 0
				, "Ptr"  , 0)
			}
			
			Return this
		}
		
		
		; Draw image by center point with given angle and scale.
		; Angle is clockwise and in degrees.
		
		DrawImageC( oImage, x, y, angle := 0, scaleX := 1, scaleY := "", oAttributes := "" ) {
			Local
			Global OGdip
			
			If (scaleY == "")
				scaleY := scaleX
			
			sdx := scaleX * oImage.Width / 2
			sdy := scaleY * oImage.Height / 2
			
			oMatrix := new OGdip.Matrix()
			oMatrix.Rotate(angle)
			
			dstPoints := [-sdx, -sdy, sdx, -sdy, -sdx, sdy]
			dstPoints := oMatrix.TransformPoints(dstPoints)
			
			Loop 3 {
				dstPoints[A_Index*2-1] := dstPoints[A_Index*2-1] + x
				dstPoints[A_Index*2-0] := dstPoints[A_Index*2-0] + y
			}
			
			this.DrawImage(oImage, dstPoints, oAttributes)
		}
		
		
		; -- Text methods --
		
		; Draws regular string using current brush.
		;   > gr.DrawString( strText, font, x, y [, format] )        ; Text at given point
		;   > gr.DrawString( strText, font, x, y, w, h [, format] )  ; Text at given bounding box
		;   > gr.DrawString( strText, font, layoutRect [, format] )  ; Same, bounding box as array
		; 
		; Argument 'font' can be either an instance of Font object
		;  or Font initialization object (see Font class).
		; Argument 'format' can either be an instance of StringFormat object
		;  or StringFormat initialization object (see StringFormat class).
		
		DrawString( strText, strFont, args* ) {
			Local
			Global OGdip
			
			If (this._Brush == "")
				Return this
			
			If (IsObject(strFont) == False)
			|| (strFont.Base != OGdip.Font)
				strFont := new OGdip.Font(strFont)
			
			; Extract or create StringFormat
			lastArg := args[ args.Length() ]
			
			If (IsObject(lastArg) == False)
			|| (args.Length() == 1)
			{
				oFormat := new OGdip.StringFormat(1)
				
			} Else
			If (lastArg.Base == OGdip.StringFormat) {
				oFormat := args.Pop()
				
			} Else {
				oFormat := new OGdip.StringFormat( args.Pop() )
			}
			
			; Normalize layout
			layoutRect := OGdip._FlattenArray(args)
			
			Loop % (4 - layoutRect.Length())
				layoutRect.Push(0)
			
			OGdip._CreateBinArray( layoutRect, binLayout := "", "Float")
			
			DllCall("GdiPlus\GdipDrawString"
			, "Ptr" ,  this._pGraphics
			, "WStr",  strText
			, "Int" ,  StrLen(strText)
			, "Ptr" ,  strFont._pFont
			, "Ptr" , &binLayout
			, "Ptr" ,  oFormat._pStringFormat
			, "Ptr" ,  this._Brush._pBrush)
			
			Return this
		}
		
		
		; Draws driver string using current brush.
		;   > gr.DrawString( strText, strFont, positions [, oMatrix, flags] )
		; 
		; Argument 'strFont' can be either an instance of Font object
		;  or Font initialization object (see Font class).
		; 
		; Argument 'positions' should be an array with positions of each glyph of 'strText'.
		; Alternatively it can be array [x, y] - position of the first glyph.
		; 
		; Argument 'oMatrix' should be an instance of Matrix object
		;  that specifies transformations applied to each glyph of 'strText'.
		; 
		; Argument 'flags' can contain following bit-fields (see GdiPlusEnums.h):
		;   • 0 - 'strText' contains 16-bit indices of font glyphs.
		;   • 1 - 'strText' contains Unicode characters (that is, regular WStr).
		;   • 2 - Text should be drawn vertically.
		;   • 4 - Glyph positions are calculated from position of the first glyph.
		;   • 8 - Reduces memory footprint by lowering quality
		
		DrawDriverString( strText, strFont, positions, oMatrix := "", flags := 1 ) {
			Local
			Global OGdip
			
			If (this._Brush == "")
				Return this
			
			If (IsObject(strFont) == False)
			|| (strFont.Base != OGdip.Font)
				strFont := new OGdip.Font(strFont)
			
			pMatrix := 0
			
			If (IsObject(strMatrix))
			&& (strMatrix.Base == OGdip.Matrix)
			{
				pMatrix := oMatrix._pMatrix
			}
			
			positions := OGdip._FlattenArray(positions)
			
			If (positions.Length() < 2)
				positions := [0, 0]
				
			If (positions.Length() == 2) {
				flags |= 4  ; DriverStringOptionsRealizedAdvance
				
			} Else {
				While (positions.Length() < (StrLen(strText) * 2)) {
					positions.Push(0, 0)
				}
			}
			
			OGdip._CreateBinArray(positions, binPositions := "", "Float")
			
			DllCall("GdiPlus\GdipDrawDriverString"
			, "Ptr" , this._pGraphics
			, "WStr", strText
			, "Int" , StrLen(strText)
			, "Ptr" , strFont._pFont
			, "Ptr" , this._Brush._pBrush
			, "Ptr" , &binPositions
			, "Int" , flags
			, "Ptr" , pMatrix)
			
			Return this
		}
		
		
		; Measures string or its parts for specified font, layout and stringformat.
		;   > ret := gr.MeasureString( text, font, x, y [, w, h][, strFormat, ranges] )
		;   > ret := gr.MeasureString( text, font, layoutRect [, strFormat, ranges] )
		; 
		; Argument 'ranges' is identified by first letter and can be:
		;   • "A" - All - returned value is a bounding box of the whole string.
		;   • "L" - Lines
		;   • "W" - Words
		;   • "C" - Chars
		;   • Array of pairs [start, length]
		; All modes except "All" return an array of regions bounding given ranges.
		; Note: maximum number of ranges is limited to 32, because higher range count
		; causes GDI+ to return ValueOverflow error.
		
		MeasureString(strText, strFont := "", args* ) {
			Local
			Global OGdip
			
			If (IsObject(args[1]) == True) {  ; layoutRect is an array
				layoutRect := args[1]
				format := args.HasKey(2)  ?  args[2]  :  1
				ranges := args.HasKey(3)  ?  args[3]  :  "All"
				
			} Else
			If (args.Length() > 4) {  ; layoutRect is x,y,w,h  and at least stringformat is present
				layoutRect := [ args[1], args[2], args[3], args[4] ]
				format := args.HasKey(5)  ?  args[5]  :  1
				ranges := args.HasKey(6)  ?  args[6]  :  "All"
				
			} Else
			If (args.Length() == 3) {  ; X,Y,SF
				layoutRect := [ args[1], args[2], 0, 0 ]
				format := args[3]
				ranges := "All"
				
			} Else {  ; Ambiguous arguments: either X,Y,SF,RNG  or X,Y,W,H with no extra arguments
				lastArg := args[ args.Length() ]
				
				If (IsObject(lastArg) == True)
				|| (lastArg ~= "i)[ALWC]")
				{
					layoutRect := [ args[1], args[2], 0, 0 ]
					format := args[3]
					ranges := args[4]
					
				} Else {
					layoutRect := [ args[1], args[2], args[3], args[4] ]
					format := 1
					ranges := "All"
				}
			}
			
			; Normalizing values
			OGdip._CreateBinArray(layoutRect, binLayout := "", "Float")
			format := new OGdip.StringFormat(format)
			
			rangesFirstLetter := SubStr(ranges, 1, 1)
			
			If (rangesFirstLetter = "A") {
				VarSetCapacity(outBboxRect, 4*4, 0)
				
				DllCall("GdiPlus\GdipMeasureString"
				, "Ptr" ,  this._pGraphics
				, "WStr",  strText
				, "Int" ,  StrLen(strText)
				, "Ptr" ,  strFont._pFont
				, "Ptr" , &binLayout
				, "Ptr" ,  format._pStringFormat
				, "Ptr" , &outBboxRect
				, "Int*",  outCodePoints := 0
				, "Int*",  outLinesFilled := 0)
				
				retBBox := { chars: outCodePoints, lines: outLinesFilled }
				Loop 4 {
					retBBox[A_Index] := NumGet(outBboxRect, (A_Index-1)*4, "Float")
				}
				
				Return retBBox
			}
			
			; Measure character ranges
			rangesList := []
			
			If (IsObject(ranges) == True) {  ; Convert one-based positions to zero-based
				Loop % ranges.Length() {
					rangesList[A_Index] := (A_Index & 1)  ?  (ranges[A_Index]-1)  :  ranges[A_Index]
				}
				
			} Else {
				matchRegex := False ? ""
				:  (rangesFirstLetter = "L")  ?  "P)([^\r\n]+)"
				:  (rangesFirstLetter = "W")  ?  "P)([\p{L}\d]+)"
				:  (rangesFirstLetter = "C")  ?  "P)(\S)"  :  "How did you get here?"
				
				strCursor := 1
				
				Loop {
					matchFound := RegexMatch(strText, matchRegex, rxMatch, strCursor)
					If (matchFound == 0)
						Break
					
					rangesList.Push(rxMatchPos1-1, rxMatchLen1)
					
					If (rangesList.Length() >= 32*2)
						Break
					
					strCursor := rxMatchPos1 + rxMatchLen1
				}
			}
			
			format.SetMeasurableCharacterRanges(rangesList)
			rangeCount := rangesList.Length() // 2
			
			regionsList := []
			
			VarSetCapacity(binRegions, rangeCount * A_PtrSize, 0)
			
			Loop % rangeCount {
				nRegion := new OGdip.Region()
				regionsList.Push(nRegion)
				NumPut(nRegion._pRegion,  binRegions, (A_Index-1)*A_PtrSize,  "Ptr")
			}
			
			DllCall("GdiPlus\GdipMeasureCharacterRanges"
			, "Ptr" ,  this._pGraphics
			, "WStr",  strText
			, "Int" ,  StrLen(strText)
			, "Ptr" ,  strFont._pFont
			, "Ptr" , &binLayout
			, "Ptr" ,  format._pStringFormat
			, "Int" ,  rangeCount
			, "Ptr" , &binRegions)
			
			Return regionsList
		}
		
		
		; Measures and returns bounding box of a driver string.
		; See .DrawDriverString method for information about arguments.
		
		MeasureDriverString( strText, strFont, positions, oMatrix := "", flags := 1 ) {
			Local
			Global OGdip
			
			If (IsObject(strFont) == False)
			|| (strFont.Base != OGdip.Font)
				strFont := new OGdip.Font(strFont)
			
			pMatrix := 0
			
			If (IsObject(oMatrix))
			&& (oMatrix.Base == OGdip.Matrix)
			{
				pMatrix := oMatrix._pMatrix
			}
			
			positions := OGdip._FlattenArray(positions)
			
			If (positions.Length() < 2) {
				positions := [0, 0]
				flags |= 4  ; DriverStringOptionsRealizedAdvance
				
			} Else
			If (positions.Length() == 2) {
				flags |= 4  ; DriverStringOptionsRealizedAdvance
				
			} Else {
				While (positions.Length() < (StrLen(strText) * 2)) {
					positions.Push(0, 0)
				}
			}
			
			OGdip._CreateBinArray(positions, binPositions := "", "Float")
			
			DllCall("GdiPlus\GdipMeasureDriverString"
			, "Ptr" ,  this._pGraphics
			, "WStr",  strText
			, "Int" ,  StrLen(strText)
			, "Ptr" ,  strFont._pFont
			, "Ptr" , &binPositions
			, "Int" ,  flags
			, "Ptr" ,  pMatrix
			, "Ptr" , &outBBoxRect)
			
			retBBox := []
			
			Loop 4 {
				retBBox[A_Index] := NumGet(outBBoxRect, (A_Index-1)*4, "Float")
			}
			
			Return retBBox
		}
		
		
		; == Transformations ==
		; All methods except .GetTransformMatrix and .TransformPoints support chaining.
		; Most methods use optional 'mxOrder' argument that specifies
		; order of matrix multiplication - somewhat like putting
		; transformation on top or bottom of the transformation stack.
		
		TransformReset() {
			DllCall("GdiPlus\GdipResetWorldTransform"
			, "Ptr", this._pGraphics)
			
			Return this
		}
		
		TransformMove( dx, dy, mxOrder := 0 ) {
			DllCall("GdiPlus\GdipTranslateWorldTransform"
			, "Ptr"  , this._pGraphics
			, "Float", dx
			, "Float", dy
			, "UInt" , mxOrder)
			
			Return this
		}
		
		TransformScale( sx, sy, mxOrder := 0 ) {
			DllCall("GdiPlus\GdipScaleWorldTransform"
			, "Ptr"  , this._pGraphics
			, "Float", sx
			, "Float", sy
			, "UInt" , mxOrder)
			
			Return this
		}
		
		TransformRotate( angle, mxOrder := 0 ) {
			DllCall("GdiPlus\GdipRotateWorldTransform"
			, "Ptr"  , this._pGraphics
			, "Float", angle
			, "UInt" , mxOrder)
			
			Return this
		}
		
		TransformRotateAt( cx, cy, angle, mxOrder := 0 ) {
			this.TransformMove(cx, cy)
			this.TransformRotate(angle)
			this.TransformMove(-cx, -cy)
			
			Return this
		}
		
		TransformMatrix( oMatrix, mxOrder := 0 ) {
			DllCall("GdiPlus\GdipMultiplyWorldTransform"
			, "Ptr" , this._pGraphics
			, "Ptr" , oMatrix._pMatrix
			, "UInt", mxOrder)
			
			Return this
		}
		
		SetTransformMatrix( oMatrix ) {
			DllCall("GdiPlus\GdipSetWorldTransform"
			, "Ptr" , this._pGraphics
			, "Ptr" , oMatrix._pMatrix)
			
			Return this
		}
		
		GetTransformMatrix() {
			Local worldMatrix := new OGdip.Matrix()
			
			DllCall("GdiPlus\GdipGetWorldTransform"
			, "Ptr", this._pGraphics
			, "Ptr", worldMatrix._pMatrix)
			
			Return worldMatrix
		}
		
		
		; Converts points from one coordinate space to another.
		; See MSDN article about coordinate systems if you'll ever need it:
		; https://docs.microsoft.com/en-us/windows/win32/gdiplus/-gdiplus-types-of-coordinate-systems-about
		
		TransformPoints( fromSpace, toSpace, points* ) {
			Local
			Global OGdip
			
			Static coordSpace := {0:0, 1:1, 2:2, "World":0, "Page":1, "Device":2}
			
			fromSpace := coordSpace[fromSpace]
			toSpace   := coordSpace[toSpace]
			
			points := OGdip._FlattenArray(points)
			pointsCount := points.Length() // 2
			
			OGdip._CreateBinArray(points, binPoints := "", "Float")
			
			DllCall("GdiPlus\GdipTransformPoints"
			, "Ptr" ,  this._pGraphics
			, "UInt",  toSpace
			, "UInt",  fromSpace
			, "Ptr" , &binPoints
			, "Int" ,  pointsCount)
			
			retArray := []
			
			Loop % pointsCount * 2 {
				retArray[A_Index] := NumGet(binPoints, (A_Index-1)*4, "Float")
			}
			
			Return retArray
		}
		
		
		; == Clipping ==
		; Clipping restricts drawing to a certain area.
		
		
		; Sets clipping region to infinite, removing any drawing restrictions.
		; Supports chaining.
		
		ResetClip() {
			DllCall("GdiPlus\GdipResetClip"
			, "Ptr", this._pGraphics)
			
			Return this
		}
		
		
		; Sets or combines current clipping region with given rectangular area or object.
		; Supports chaining.
		;   > gr.SetClip( oGraphics [, combineMode] )
		;   > gr.SetClip( oPath [, combineMode] )
		;   > gr.SetClip( oRegion [, combineMode] )
		;   > gr.SetClip( "*HRGN", hRgn [, combineMode] )
		;   > gr.SetClip(  x, y, w, h  [, combineMode] )
		;   > gr.SetClip( [x, y, w, h] [, combineMode] )
		; See OGdip.Enum.CombineMode for possible 'combineMode' argument.
		; Default 'combineMode' is 'Replace'.
		
		SetClip( source, args* ) {
			Local
			Global OGdip
			
			combineMode := 0
			
			If  (args.Length() == 4)
			|| ((args.Length() == 1)  &&  (IsObject(source) == True))
			|| ((args.Length() == 2)  &&  (source == "*HRGN"))
			{
				combineMode := OGdip.Enum.Get("CombineMode", args.Pop(), 2)
			}
			
			
			If (IsObject(source) == True)
			&& (source.Base == OGdip.Graphics)
			{
				DllCall("GdiPlus\GdipSetClipGraphics"
				, "Ptr" , this._pGraphics
				, "Ptr" , source._pGraphics
				, "UInt", combineMode)
				
			} Else
			If (IsObject(source) == True)
			&& (source.Base == OGdip.Path)
			{
				DllCall("GdiPlus\GdipSetClipPath"
				, "Ptr" , this._pGraphics
				, "Ptr" , source._pPath
				, "UInt", combineMode)
				
			} Else
			If (IsObject(source) == True)
			&& (source.Base == OGdip.Region)
			{
				DllCall("GdiPlus\GdipSetClipRegion"
				, "Ptr" , this._pGraphics
				, "Ptr" , source._pRegion
				, "UInt", combineMode)
				
			} Else
			If (source == "*HRGN") {
				DllCall("GdiPlus\GdipSetClipHrgn"
				, "Ptr" , this._pGraphics
				, "Ptr" , args[1]  ; HRGN handle
				, "UInt", combineMode)
				
			} Else {
				rect := IsObject(source)  ?  source  :  [source, args*]
				
				DllCall("GdiPlus\GdipSetClipRect"
				, "Ptr"  , this._pGraphics
				, "Float", rect[1]
				, "Float", rect[2]
				, "Float", rect[3]
				, "Float", rect[4]
				, "UInt" , combineMode)
			}
			
			Return this
		}
		
		
		; Moves clipping region. Supports chaining.
		
		MoveClip( moveX, moveY ) {
			DllCall("GdiPlus\GdipTranslateClip"
			, "Ptr"  , this._pGraphics
			, "Float", moveX
			, "Float", moveY)
			
			Return this
		}
		
		
		; Returns clipping Region object (see Region class).
		
		GetClip() {
			Local
			Global OGdip
			
			clipRegion := new OGdip.Region()
			
			DllCall("GdiPlus\GdipGetClip"
			, "Ptr" , this._pGraphics
			, "Ptr*", clipRegion._pRegion)
			
			Return clipRegion
		}
		
		
		; Gets bounding box for the whole clipping region or the visible part of it.
		
		GetClipBounds( onlyVisible := False ) {
			VarSetCapacity(outRect := "", 4*4, 0)
			
			DllCall( (onlyVisible
			?  "GdiPlus\GdipGetClipBounds"
			:  "GdiPlus\GdipGetVisibleClipBounds")
			, "Ptr", this._pGraphics
			, "Ptr", &outRect)
			
			retRect := []
			
			Loop 4 {
				retRect.Push( NumGet(outRect, (A_Index-1)*4, "Float") )
			}
			
			Return retRect
		}
		
		
		; Returns True if clipping region is empty.
		
		IsClipEmpty() {
			DllCall("GdiPlus\GdipIsClipEmpty"
			, "Ptr"  , this._pGraphics
			, "UInt*", result := 0)
			
			Return result
		}
		
		
		; Checks if given point or rectangular area is inside the visible clipping region.
		;   > gr.IsVisible( x, y [, w, h] )
		
		IsVisible( args* ) {
			Local
			
			If (IsObject(args[1]) == True) {
				args := args[1]
			}
			
			If (args.Length() == 4) {
				DllCall("GdiPlus\GdipIsVisibleRect"
				, "Ptr"  , this._pGraphics
				, "Float", args[1]
				, "Float", args[2]
				, "Float", args[3]
				, "Float", args[4]
				, "UInt*", result := 0)
				
			} Else {
				DllCall("GdiPlus\GdipIsVisiblePoint"
				, "Ptr"  , this._pGraphics
				, "Float", args[1]
				, "Float", args[2]
				, "UInt*", result := 0)
			}
			
			Return result
		}
		
		
		; == State and containers ==
		; Both .SaveState and .BeginContainer methods save current Graphics state,
		; such as transformations, clipping region, and quality settings.
		; Both .RestoreState and .EndContainer methods restore saved Graphics state.
		; Additionally, .BeginContainer allows to specify transformation to be applied
		; to the container in the form of source and destination rectangles.
		; States saved by both methods use the same stack, so restoring from state 'N'
		; will also remove all states that were placed to that stack after 'N'.
		
		SaveState() {
			Local
			
			DllCall("GdiPlus\GdipSaveGraphics"
			, "Ptr"  , this._pGraphics
			, "UInt*", stateId := 0)
			
			Return stateId
		}
		
		RestoreState( stateId ) {
			DllCall("GdiPlus\GdipRestoreGraphics"
			, "Ptr" , this._pGraphics
			, "UInt", stateId)
			
			Return this
		}
		
		BeginContainer( srcRect := "", dstRect := "", unit := "" ) {
			Local
			Global OGdip
			
			If (IsObject(srcRect) == False) || (srcRect.Length() < 4)
			|| (IsObject(dstRect) == False) || (dstRect.Length() < 4)
			{
				DllCall("GdiPlus\GdipBeginContainer2"
				, "Ptr"  , this._pGraphics
				, "UInt*", containerId := 0)
				
			} Else {
				unit := OGdip.Enum.Get("Unit", unit, this.PageUnit)
				
				OGdip._CreateBinArray(srcRect, binSrcRect := "", "Float")
				OGdip._CreateBinArray(dstRect, binDstRect := "", "Float")
				
				DllCall("GdiPlus\GdipBeginContainer"
				, "Ptr"  , this._pGraphics
				, "Ptr"  , &binDstRect
				, "Ptr"  , &binSrcRect
				, "UInt" , unit
				, "UInt*", containerId := 0)
			}
			
			Return containerId
		}
		
		EndContainer( containerId ) {
			DllCall("GdiPlus\GdipEndContainer"
			, "Ptr" , this._pGraphics
			, "UInt", containerId)
		}
		
		
		; Enumerate metafile records with provided callback.
		; Callback function can filter records or alter records data,
		; and use Metafile.PlayRecord method to play these records.
		; 
		; Callback function should be registered with RegisterCallback and take following arguments:
		;   • FnCallback(UINT recordType, UINT flags, UINT dataSize, PTR dataPtr, PTR callbackData)
		; If callback function returns False, enumeration process is aborted.
		; Last argument 'callbackData' will receive Metafile's internal image pointer (pImage).
		; 
		;   > gr.EnumerateMetafile( oMetafile, cbAddress, <Destination> [, sourceRect, unit][, oAttributes] )
		; 
		; Destination argset can be:
		;   • Two numbers or a single array of two numbers: DX, DY
		;   • Array of four numbers: DX, DY, DW, DH
		;   • Array of six numbers: X1,Y1, X2,Y2, X3,Y3
		; See comments on .DrawImage's destination argset.
		; 
		; Argument 'sourceRect' must be an array of four numbers [SX, SY, SW, SH]
		; that specifies rectangular portion of the displayed metafile.
		; Argument 'unit' specifies the unit of measure for the 'sourceRect'.
		
		EnumerateMetafile( oMetafile, cbAddress, args* ) {
			Local
			Global OGdip
			
			
			; Destination argset
			If (IsObject(args[1])) {
				destination := args.RemoveAt(1)
				
			} Else {
				destination := []
				
				Loop 3 {
					If (args.HasKey(1) == False)  ||  IsObject(args[1])
					|| (args.HasKey(2) == False)  ||  IsObject(args[1])
						Break
					
					destination.Push( args[1], args[2] )
					args.RemoveAt(1, 2)
				}
			}
			
			OGdip._CreateBinArray(destination, binDestination := "", "Float")
			
			
			; ImageAttributes
			pAttributes := 0
			lastArg := (args.Length() == 0)  ?  ""  :  args[ args.Length() ]
			
			If (IsObject(lastArg))
			&& (lastArg.Base == OGdip.ImageAttributes)
			{
				oAttributes := args.Pop()
				pAttributes := oAttributes._pAttributes
				
			} Else
			If (oMetafile.Attributes != "") {
				pAttributes := oMetafile.Attributes._pAttributes
			}
			
			
			; SrcRect and unit
			pSrcRect := 0
			
			If (IsObject(args[1])) {
				OGdip._CreateBinArray(args[1], binSrcRect := "", "Float")
				pSrcRect := &binSrcRect
			}
			
			srcUnit := args.HasKey(2)  ?  args[2]  :  this.PageUnit
			srcUnit := OGdip.Enum.Get("Unit", srcUnit, this.PageUnit)
			
			
			; Construct function name and argument list
			gdipFuncName := "GdipEnumerateMetafile"
			.  ((pSrcRect == 0)  ?  ""  :  "SrcRect")
			
			gdipFuncArgs := []
			gdipFuncArgs.Push("Ptr",  this._pGraphics)
			gdipFuncArgs.Push("Ptr",  oMetafile._pMetafile)
			gdipFuncArgs.Push("Ptr", &binDestination)
			
			If (destination.Length() >= 6) {
				gdipFuncName .= "DestPoints"
				gdipFuncArgs.Push("Int", 3)
				
			} Else
			If (destination.Length() >= 4) {
				gdipFuncName .= "DestRect"
				
			} Else {
				gdipFuncName .= "DestPoint"
			}
			
			If (pSrcRect != 0) {
				gdipFuncArgs.Push("Ptr" , pSrcRect)
				gdipFuncArgs.Push("UInt", srcUnit)
			}
			
			gdipFuncArgs.Push("Ptr", cbAddress)
			gdipFuncArgs.Push("Ptr", oMetafile._pImage)
			gdipFuncArgs.Push("Ptr", pAttributes)
			
			
			; Calling the function
			DllCall(gdipFuncName, gdipFuncArgs*)
		}
	}
	
	
	
	; Path class
	; ==========
	; 
	; Path object keeps a sequence of points, lines, curves and figures.
	; You can then draw and fill the whole path multiple times.
	; 
	; Constructors:
	;   > figure := new OGdip.Path( [fillMode] )
	;   > figure := new OGdip.Path( oPath )
	;   > figure := new OGdip.Path( points, types )
	; 
	; Properties:
	;   .FillMode
	; 
	; Methods:
	;   .AddLine( points* )
	;   .AddBezier( points* )
	;   .AddCurve( points* [, tension | options] )
	;   .AddPolygon( points* )
	;   .AddClosedCurve( points* [, tension] )
	;   .AddArc( x, y, w, h, startAngle, sweepAngle )
	;   .AddArcC( cx, cy, rx, ry, startAngle, sweepAngle )
	;   .AddPie( x, y, w, h, startAngle, sweepAngle )
	;   .AddPieC( cx, cy, rx, ry, startAngle, sweepAngle )
	;   .AddEllipse( x, y, w [, h] )
	;   .AddEllipseC( cx, cy, rx [, ry] )
	;   .AddRectangle( x, y, w [, h] )
	;   .AddRectangleC( cx, cy, rx [, ry] )
	;   .AddRoundedRectangle( x, y, w, h, rx [, ry] )
	;   .AddPath( oPath [, connectPaths] )
	;   .AddString( strText, strFont, <layout> [, format] )
	;   .SetMarker()
	;   .ClearMarkers()
	;   .StartFigure( [closePrevious] )
	;   .CloseFigure( [closeAll] )
	;   .Reset()
	;   .Reverse()
	;   .Flatten( [flatness, oMatrix] )
	;   .Outline( [flatness, oMatrix] )
	;   .StrokeToFill( oPen [, flatness, oMatrix] )
	;   .Warp( srcRect, dstPoints [, warpMode, flatness, oMatrix] )
	;   .GetSubpaths( [getIndices] )
	;   .GetMarkedSubpaths( [getIndices] )
	;   .TransformMatrix( oMatrix )
	;   .GetPointsRaw( &binPoints, &binTypes )
	;   .GetPoints( &typesArray )
	;   .GetLastPoint()
	;   .GetBounds( [oPen, oMatrix] )
	;   .IsVisible( x, y [, oGraphics, oPen] )
	
	Class Path {
		
		__New( args* ) {
			Local
			Global OGdip
			
			pPath := 0
			
			If (args.Length() == 1)
			&& (args[1].Base == OGdip.Path)
			{
				DllCall("GdiPlus\GdipClonePath"
				, "Ptr" , args[1]._pPath
				, "Ptr*", pPath)
				
			} Else
			If (args.Length() >= 2)
			&& (IsObject(args[1]) == True)
			&& (IsObject(args[2]) == True)
			{
				pointCount := Min( args[1].Length(), args[2].Length() )
				
				OGdip._CreateBinArray(args[1], binPoints := "", "Float")
				OGdip._CreateBinArray(args[2], binTypes  := "", "UChar")
				
				fillMode := args.HasKey(3)  ?  (!!args[3])  :  0
				
				DllCall("GdiPlus\GdipCreatePath2"
				, "Ptr" , &binPoints
				, "Ptr" , &binTypes
				, "Int" ,  pointCount
				, "UInt",  fillMode
				, "Ptr*",  pPath)
				
			} Else {
				fillMode := args.HasKey(1)  ?  (!!args[1])  :  0
				
				DllCall("GdiPlus\GdipCreatePath"
				, "UInt", fillMode
				, "Ptr*", pPath)
			}
			
			
			If (pPath == 0) {
				this.Base := False  ; Avoid calling __Delete
				Return False
			}
			
			this._pPath := pPath
		}
		
		
		__Delete() {
			DllCall("GdiPlus\GdipDeletePath"
			, "Ptr", this._pPath)
		}
		
		
		; FillMode specifies how path with self-intersections will be filled:
		;   •  0  - Alternate fill mode
		;   •  1  - Winding fill mode (may depend on path/subpath direction)
		
		FillMode {
			Get {
				Local
				DllCall("GdiPlus\GdipGetPathFillMode"
				, "Ptr"  , this._pPath
				, "UInt*", result := 0)
				
				Return result
			}
			Set {
				DllCall("GdiPlus\GdipSetPathFillMode"
				, "Ptr" , this._pPath
				, "UInt", value)
				
				Return value
			}
		}
		
		
		; == Drawing ==
		; Methods below are generally similar to Graphics.Draw* methods,
		; but instead of drawing they just add elements to the path.
		; For details see corresponding Graphics.Draw* method.
		
		; Adds a sequence of connected straigt lines to the path.
		
		AddLine( points* ) {
			Local
			Global OGdip
			
			points := OGdip._FlattenArray(points)
			
			OGdip._CreateBinArray(points, binPoints := "", "Float")
			
			DllCall("GdiPlus\GdipAddPathLine2"
			, "Ptr",  this._pPath
			, "Ptr", &binPoints
			, "Int", (points.Length() // 2))
			
			Return this
		}
		
		
		; Adds a sequence of connected cubic bezier splines to the path.
		
		AddBezier( points* ) {
			Local
			Global OGdip
			
			points := OGdip._FlattenArray(points)
			
			OGdip._CreateBinArray(points, binPoints := "", "Float")
			
			DllCall("GdiPlus\GdipAddPathBeziers"
			, "Ptr",  this._pPath
			, "Ptr", &binPoints
			, "Int", (points.Length() // 2))
			
			Return this
		}
		
		
		; Adds a cardinal spline that passes through given points to the path.
		
		AddCurve( points* ) {
			Local
			Global OGdip
			
			options := 0
			lastArg := points[ points.Length() ]
			
			If (IsObject(lastArg) == True)  ; Last argument is an object
			&& (lastArg.Length() == 0)      ; but is not a coords array.
			{
				options := points.Pop()
			}
			
			points := OGdip._FlattenArray(points)
			pointsCount := points.Length() // 2
			
			; Default options
			tension    := 0.5
			startPoint := 0
			segments   := pointsCount-1
			
			If (points.Length() & 1 == 1) {
				tension := points.Pop()
			}
			
			; Parse options
			If (options != 0) {
				If (options.HasKey("tension"))
					tension := options.tension
				
				If (options.HasKey("startPoint"))
					startPoint := Min( pointsCount-1, options.startPoint-1 )
					
				If (options.HasKey("endPoint")) {
					segments := Min((pointsCount-startPoint-1), (options.endPoint-1 - startPoint))
					
				} Else
				If (options.HasKey("segments")) {
					segments := Min((pointsCount-startPoint-1), options.segments)
				}
			}
			
			OGdip._CreateBinArray(points, binPoints := "", "Float")
			
			DllCall("GdiPlus\GdipAddPathCurve3"
			, "Ptr"  ,  this._pPath
			, "Ptr"  , &binPoints
			, "Int"  ,  pointsCount
			, "Int"  ,  offset
			, "Int"  ,  segments
			, "Float",  tension)
			
			Return this
		}
		
		
		; Adds closed polygon with straight lines.
		
		AddPolygon( points* ) {
			Local
			Global OGdip
			
			points := OGdip._FlattenArray(points)
			
			OGdip._CreateBinArray(points, binPoints := "", "Float")
			
			DllCall("GdiPlus\GdipAddPathPolygon"
			, "Ptr",  this._pPath
			, "Ptr", &binPoints
			, "Int", (points.Length() // 2))
			
			Return this
		}
		
		
		; Adds a closed cardinal spline to the path.
		
		AddClosedCurve( points* ) {
			Local
			Global OGdip
			
			points := OGdip._FlattenArray(points)
			
			tension := 0.5
			
			If (points.Length() & 1 == 1) {
				tension := points.Pop()
			}
			
			OGdip._CreateBinArray(points, binPoints := "", "Float")
			
			DllCall("GdiPlus\GdipAddPathClosedCurve2"
			, "Ptr"  ,  this._pPath
			, "Ptr"  , &binPoints
			, "Int"  , (points.Length() // 2)
			, "Float",  tension)
			
			Return this
		}
		
		
		; Adds an arc to the path.
		
		AddArc( x, y, w, h, startAngle, sweepAngle ) {
			DllCall("GdiPlus\GdipAddPathArc"
			, "Ptr"  , this._pPath
			, "Float", x
			, "Float", y
			, "Float", w
			, "Float", h
			, "Float", startAngle
			, "Float", sweepAngle)
			
			Return this
		}
		
		AddArcC( cx, cy, rx, ry, startAngle, sweepAngle ) {
			Return this.AddArc( cx-rx, cy-ry, rx*2, ry*2, startAngle, sweepAngle )
		}
		
		
		; Adds a pie to the path
		
		AddPie( x, y, w, h, startAngle, sweepAngle ) {
			DllCall("GdiPlus\GdipAddPathPie"
			, "Ptr"  , this._pPath
			, "Float", x
			, "Float", y
			, "Float", w
			, "Float", h
			, "Float", startAngle
			, "Float", sweepAngle)
			
			Return this
		}
		
		AddPieC( cx, cy, rx, ry, startAngle, sweepAngle ) {
			Return this.AddPie( cx-rx, cy-ry, rx*2, ry*2, startAngle, sweepAngle )
		}
		
		
		; Adds an ellipse or (if last argument is omitted) a circle to the path.
		
		AddEllipse( x, y, w, h := "" ) {
			If (h == "")
				h := w
			
			DllCall("GdiPlus\GdipAddPathEllipse"
			, "Ptr", this._pPath
			, "Float", x
			, "Float", y
			, "Float", w
			, "Float", h)
			
			Return this
		}
		
		AddEllipseC( cx, cy, rx, ry := "" ) {
			If (ry == "")
				ry := rx
			
			Return this.AddEllipse( cx-rx, cy-ry, rx*2, ry*2 )
		}
		
		
		; Adds a rectangle or (if last argument is omitted) a square to the path.
		
		AddRectangle( x, y, w, h := "" ) {
			If (h == "")
				h := w
			
			DllCall("GdiPlus\GdipAddPathRectangle"
			, "Ptr", this._pPath
			, "Float", x
			, "Float", y
			, "Float", w
			, "Float", h)
			
			Return this
		}
		
		AddRectangleC( cx, cy, rx, ry := "" ) {
			If (ry == "")
				ry := rx
			
			Return this.AddRectangle( cx-rx, cy-ry, rx*2, ry*2 )
		}
		
		
		; Adds a rounded rectangle to the path.
		
		AddRoundedRectangle( x, y, w, h, rx, ry := "" ) {
			Local
			
			If (ry == "")
				ry := rx
			
			rx := Min(rx, w/2),  bx := rx * 0.55
			ry := Min(ry, h/2),  by := ry * 0.55
			x1 := x,  x2 := x+rx,  x3 := x+w-rx,  x4 := x+w
			y1 := y,  y2 := y+ry,  y3 := y+h-ry,  y4 := y+h
			
			this.StartFigure()
			
			; Adding only corners, lines will be added automatically.
			; Using Bezier produces cleaner path points than Arc.
			this.AddBezier( x3, y1,  x3+bx, y1,  x4, y2-by,  x4, y2 )
			this.AddBezier( x4, y3,  x4, y3+by,  x3+bx, y4,  x3, y4 )
			this.AddBezier( x2, y4,  x2-bx, y4,  x1, y3+by,  x1, y3 )
			this.AddBezier( x1, y2,  x1, y2-by,  x2-bx, y1,  x2, y1 )
			
			this.CloseFigure()
			
			Return this
		}
		
		
		; Adds a Path object to the current path.
		; If 'connectPaths' is True, first figure of 'oPath' will be added
		; to the last figure of current path.
		
		AddPath( oPath, connectPaths := False ) {
			DllCall("GdiPlus\GdipAddPathPath"
			, "Ptr" , this._pPath
			, "Ptr" , oPath._pPath
			, "UInt", connectPaths)
			
			Return this
		}
		
		
		; Adds string outline to the path.
		
		AddString( strText, strFont, args* ) {
			Local
			Global OGdip
			
			If (IsObject(strFont) == False)
			|| (strFont.Base != OGdip.Font)
				strFont := new OGdip.Font(strFont)
			
			oFontFamily := strFont.GetFamily()
			
			; Extract or create StringFormat
			lastArg := args[ args.Length() ]
			
			If (IsObject(lastArg) == False)
			|| (args.Length() == 1)
			{
				oFormat := new OGdip.StringFormat(1)
				
			} Else
			If (lastArg.Base == OGdip.StringFormat) {
				oFormat := args.Pop()
				
			} Else {
				oFormat := new OGdip.StringFormat( args.Pop() )
			}
			
			; Normalize layout
			layoutRect := OGdip._FlattenArray(args)
			
			Loop % (4 - layoutRect.Length())
				layoutRect.Push(0)
			
			OGdip._CreateBinArray( layoutRect, binLayout := "", "Float")
			
			DllCall("GdiPlus\GdipAddPathString"
			, "Ptr"  ,  this._pPath
			, "WStr" ,  strText
			, "Int"  ,  StrLen(strText)
			, "Ptr"  ,  oFontFamily._pFontFamily
			, "Int"  ,  strFont.GetStyle()
			, "Float",  strFont.GetSize()
			, "Ptr"  , &binLayout
			, "Ptr"  ,  oFormat._pStringFormat)
		}
		
		
		; Marks last point in the path as a marker.
		; You can then split path into subpaths with .SplitByMarkers method.
		
		SetMarker() {
			DllCall("GdiPlus\GdipSetPathMarker"
			, "Ptr", this._pPath)
			
			Return this
		}
		
		
		; Clears all markers from the path.
		
		ClearMarkers() {
			DllCall("GdiPlus\GdipClearPathMarkers"
			, "Ptr", this._pPath)
			
			Return this
		}
		
		
		; Start new figure in the path, optionally closing previous one.
		
		StartFigure( closePrevious := False) {
			If (closePrevious)
				this.CloseFigure()
			
			DllCall("GdiPlus\GdipStartPathFigure"
			, "Ptr", this._pPath)
			
			Return this
		}
		
		
		; Close last or all figures in the path.
		
		CloseFigure( closeAll := False) {
			If (closeAll) {
				DllCall("GdiPlus\GdipClosePathFigures"
				, "Ptr", this._pPath)
				
			} Else {
				DllCall("GdiPlus\GdipClosePathFigure"
				, "Ptr", this._pPath)
			}
			
			Return this
		}
		
		
		; Empties the path and set FillMode to 0 (Alternate).
		
		Reset() {
			DllCall("GdiPlus\GdipResetPath"
			, "Ptr", this._pPath)
			
			Return this
		}
		
		
		; Reverses direction of the path.
		; This may affect drawing the path (changes position of pen caps),
		; or filling the path with FillMode = 1 (Winding).
		
		Reverse() {
			DllCall("GdiPlus\GdipReversePath"
			, "Ptr", this._pPath)
			
			Return this
		}
		
		
		; Converts all curves in the path to the sequences of connected straight lines.
		; Optional Matrix transformation may be applied before conversion.
		; Argument 'flatness' specifies maximum error between flattened
		; and original paths. Lower values result in higher number of segments.
		
		Flatten( flatness := 0.25, oMatrix := 0 ) {
			Local pMatrix := 0
			
			If (IsObject(oMatrix))
			&& (oMatrix.Base == OGdip.Matrix)
				pMatrix := oMatrix._pMatrix
			
			DllCall("GdiPlus\GdipFlattenPath"
			, "Ptr"  , this._pPath
			, "Ptr"  , pMatrix
			, "Float", flatness)
			
			Return this
		}
		
		
		; Similar to .Flatten method, but converted path
		; will contain only outlines of the original path.
		
		Outline( flatness := 0.25, oMatrix := 0 ) {
			Local pMatrix := 0
			
			If (IsObject(oMatrix))
			&& (oMatrix.Base == OGdip.Matrix)
				pMatrix := oMatrix._pMatrix
			
			DllCall("GdiPlus\GdipWindingModeOutline"
			, "Ptr"  , this._pPath
			, "Ptr"  , pMatrix
			, "Float", flatness)
			
			Return this
		}
		
		
		; Converts path to enclose the area that will be filled
		; if the original path was drawn with given pen.
		; Flattens the path.
		
		StrokeToFill( oPen, flatness := 0.25, oMatrix := "" ) {
			Local pMatrix := 0
			
			If (IsObject(oMatrix) == True)
			&& (oMatrix.Base == OGdip.Matrix)
			{
				pMatrix := oMatrix._pMatrix
			}
			
			DllCall("GdiPlus\GdipWidenPath"
			, "Ptr"  , this._pPath
			, "Ptr"  , oPen._pPen
			, "Ptr"  , pMatrix
			, "Float", flatness)
			
			Return this
		}
		
		
		; Warp transforms the path so that the source rect matches destination:
		;   > path.Warp( srcRect, dstPoints [, warpMode, oMatrix, flatness] )
		; 
		; 'dstPoints' should contain either 3 or 4 point coordinates.
		; For 3-points warp, srcRect will be warped to a parallelogram.
		; For 4-points warp, srcRect will be warped to a trapezoid.
		; 
		; NB! Bilinear warping have severe issues with subpaths and flatness:
		; https://www.codeguru.com/cpp/g-m/gdi/gdi/article.php/c3679/Weird-Warps.htm
		
		Warp( srcRect, dstPoints, warpMode := 0, flatness := 0.25, oMatrix := "" ) {
			pMatrix := 0
			
			If (IsObject(oMatrix) == True)
			&& (oMatrix.Base == OGdip.Matrix)
			{
				pMatrix := oMatrix._pMatrix
			}
			
			OGdip._CreateBinArray(dstPoints, binDstPoints := "", "Float")
			
			DllCall("GdiPlus\GdipWarpPath"
			, "Ptr"  ,  this._pPath
			, "Ptr"  ,  pMatrix
			, "Ptr"  , &binDstPoints
			, "Int"  ,  dstPoints.Length() // 2
			, "Float",  srcRect[1]
			, "Float",  srcRect[2]
			, "Float",  srcRect[3]
			, "Float",  srcRect[4]
			, "UInt" ,  warpMode
			, "Float",  flatness)
			
			Return this
		}
		
		
		; Returns current path subpaths or only indices of their
		; start/end points in the path's data (see .GetPoints).
		;   > myPath.GetSubpaths()      =>  [ oPath1, oPath2, ... ]
		;   > myPath.GetSubpaths(True)  =>  [ [nStart, nEnd, nPoints, isClosed], ... ]
		
		GetSubpaths( getIndices := False ) {
			Local
			Global OGdip
			
			DllCall("GdiPlus\GdipCreatePathIter"
			, "Ptr*", pPathIterator
			, "Ptr" , this._pPath)
			
			; Following two DllCalls aren't actually needed.
			DllCall("GdiPlus\GdipPathIterGetSubpathCount"
			, "Ptr" , pPathIterator
			, "Int*", subpathCount)
			
			DllCall("GdiPlus\GdipPathIterRewind"
			, "Ptr" , pPathIterator)
			
			subpathList := []
			
			Loop % subpathCount {
				If (getIndices) {
					DllCall("GdiPlus\GdipPathIterNextSubpath"
					, "Ptr"  , pPathIterator
					, "Int*" , pointCount := -1
					, "Int*" , startIndex := -1
					, "Int*" , endIndex   := -1
					, "UInt*", isClosed   := -1)
					
					If (pointCount <= 0)
						Break
					
					subpathList.Push( [startIndex, endIndex, pointCount, isClosed] )
					
				} Else {
					DllCall("GdiPlus\GdipPathIterNextSubpathPath"
					, "Ptr"  , pPathIterator
					, "Int*" , pointCount := -1
					, "Ptr*" , pSubpath   := -1
					, "UInt*", isClosed   := -1)
					
					If (pointCount <= 0)
						Break
					
					subpathList.Push( {Base: OGdip.Path, _pPath: pSubpath} )
				}
			}
			
			DllCall("GdiPlus\GdipDeletePathIter"
			, "Ptr", pPathIterator)
			
			Return subpathList
		}
		
		
		; Returns current path subfigures or indices of their start/end points.
		; Similar to .GetSubpaths method, but separates by markers (see .SetMarker method).
		;   > mypath.GetMarkedSubpaths()      =>  [ oPath1, oPath2, ... ]
		;   > mypath.GetMarkedSubpaths(True)  =>  [ [nStart, nEnd, nPoints], ... ]
		
		GetMarkedSubpaths( getIndices := False ) {
			Local
			Global OGdip
			
			DllCall("GdiPlus\GdipCreatePathIter"
			, "Ptr*", pPathIterator
			, "Ptr" , this._pPath)
			
			DllCall("GdiPlus\GdipPathIterRewind"
			, "Ptr" , pPathIterator)
			
			subpathList := []
			
			Loop % subpathCount {
				If (getIndices) {
					DllCall("GdiPlus\GdipPathIterNextMarker"
					, "Ptr"  , pPathIterator
					, "Int*" , pointCount := -1
					, "Int*" , startIndex := -1
					, "Int*" , endIndex   := -1)
					
					If (pointCount <= 0)
						Break
					
					subpathList.Push( [startIndex, endIndex, pointCount] )
					
				} Else {
					DllCall("GdiPlus\GdipPathIterNextMarkerPath"
					, "Ptr"  , pPathIterator
					, "Int*" , pointCount := -1
					, "Ptr*" , pSubpath   := -1)
					
					If (pointCount <= 0)
						Break
					
					subpathList.Push( {Base: OGdip.Path, _pPath: pSubpath} )
				}
			}
			
			DllCall("GdiPlus\GdipDeletePathIter"
			, "Ptr", pPathIterator)
			
			Return subpathList
		}
		
		
		; Transforms path with given Matrix.
		
		TransformMatrix( oMatrix ) {
			DllCall("GdiPlus\GdipTransformPath"
			, "Ptr", this._pPath
			, "Ptr", oMatrix._pMatrix)
			
			Return this
		}
		
		
		; Writes raw path data in two provided variables:
		;   • binPoints  - binary array of 2*N Floats, coordinate pairs of points.
		;   • binTypes   - binary array of N bytes, each byte encodes type of point.
		; Returns number of points in the path.
		
		; Point types:
		;   0x00 - Start of a figure;
		;   0x01 - Start/end of a straight line;
		;   0x03 - Bezier control/end point; usually in groups of 3 (C, C, E);
		;   0x10 - DashMode; undocumented and probably not implemented;
		;   0x20 - Marker;
		;   0x80 - Close subpath.
		
		GetPointsRaw( ByRef binPoints, ByRef binTypes ) {
			Local
			
			DllCall("GdiPlus\GdipGetPointCount"
			, "Ptr" , this._pPath
			, "Int*", pointCount := 0)
			
			VarSetCapacity(binPoints, pointCount*2*4, 0)
			VarSetCapacity(binTypes , pointCount    , 0)
			
			DllCall("GdiPlus\GdipGetPathPoints"
			, "Ptr",  this._pPath
			, "Ptr", &binPoints
			, "Int",  pointCount)
			
			DllCall("GdiPlus\GdipGetPathTypes"
			, "Ptr",  this._pPath
			, "Ptr", &binTypes
			, "Int",  pointCount)
			
			Return pointCount
		}
		
		
		; Returns regular array with coordinates of each point in the path.
		; Pass a variable as a 'typeList' argument to store regular array of point types.
		
		GetPoints( ByRef typesArray := "" ) {
			Local
			
			pointCount := this.GetPointsRaw( binPoints := "", binTypes := "" )
			
			pointsArray := []
			typesArray  := []
			
			Loop % pointCount {
				pointsArray.Push( NumGet(binPoints, (A_Index-1)*8  , "Float") )
				pointsArray.Push( NumGet(binPoints, (A_Index-1)*8+4, "Float") )
				
				typesArray.Push(  NumGet(binTypes , (A_Index-1)    , "UChar") )
			}
			
			Return pointsArray
		}
		
		
		; Returns coordinates of the last point in the path as a regular array[2].
		
		GetLastPoint() {
			Local
			
			VarSetCapacity(binPoint := "", 2*4, 0)
			
			DllCall("GdiPlus\GdipGetPathLastPoint"
			, "Ptr", this._pPath
			, "Ptr", &binPoint)
			
			Return [ NumGet(binPoint, 0, "Float"), NumGet(binPoint, 4, "Float") ]
		}
		
		
		; Gets a bounding rectangle for the path.
		;   • oMatrix  -  optional Matrix transformation to be applied beforehand.
		;   • oPen     -  optional Pen that affects calculation of the bounding box.
		
		GetBounds( oPen := "", oMatrix := "" ) {
			Local
			Global OGdip
			
			pPen := 0
			pMatrix := 0
			
			If (IsObject(oMatrix) == True)
			&& (oMatrix.Base == OGdip.Matrix)
			{
				pMatrix := oMatrix._pMatrix
			}
			
			If (IsObject(oPen) == True)
			&& (oPen.Base == OGdip.Pen)
			{
				pPen := oPen._pPen
			}
			
			VarSetCapacity(binOutRect := "", 4*2*4, 0)
			
			DllCall("GdiPlus\GdipGetPathWorldBounds"
			, "Ptr",  this._pPath
			, "Ptr", &binOutRect
			, "Ptr",  pMatrix
			, "Ptr",  pPen)
			
			outRect := []
			
			Loop % 4*2 {
				outRect.Push( NumGet(binOutRect, (A_Index-1)*4, "Float") )
			}
			
			Return outRect
		}
		
		
		; Checks if point is in the fill/stroke area of the path.
		; 
		; Argument 'oGraphics' can be Graphics object that specifies
		; world-to-device transformation, and check is done in device coordinates.
		; If omitted, check is done in world coordinates.
		; 
		; Argument 'oPen' can be instance of Pen object.
		; If present, checks if point touches the outline of the path drawn with given Pen.
		; Otherwise, checks if point touches fill area of the path.
		
		IsVisible( x, y, oGraphics := "", oPen := "" ) {
			Local
			Global OGdip
			
			pGraphics := 0
			
			If (IsObject(oGraphics) == True)
			&& (oGraphics.Base == OGdip.Graphics)
			{
				pGraphics := oGraphics._pGraphics
			}
			
			If (IsObject(oPen) == True)
			&& (oPen.Base == OGdip.Pen)
			{
				DllCall("GdiPlus\GdipIsOutlineVisiblePathPoint"
				, "Ptr", this._pPath
				, "Float", x
				, "Float", y
				, "Ptr"  , oPen._pPen
				, "Ptr"  , pGraphics
				, "UInt*", result)
				
			} Else {
				DllCall("GdiPlus\GdipIsVisiblePathPoint"
				, "Ptr", this._pPath
				, "Float", x
				, "Float", y
				, "Ptr"  , pGraphics
				, "UInt*", result)
			}
			
			Return result
		}
	}
	
	
	
	; Pen class
	; =========
	; 
	; Constructors:
	;   > myPen := new OGdip.Pen( [argb, width, unit] )
	;   > myPen := new OGdip.Pen( oPen )
	;   > myPen := new OGdip.Pen( oBrush )
	; 
	; Properties:
	;   .Color
	;   .Width
	;   .Unit
	; 
	; Methods:
	;   .SetStroke( strokeType )
	;   .SetLineJoin( [lineJoin, miterLimit] )
	;   .SetDash( [dashStyle, dashOffset, dashCap] )
	;   .SetCaps( [startCap, dashCap, endCap] )
	;   .GetInfo()
	; 
	; Transform methods:
	;   .TransformReset()
	;   .TransformMove( dx, dy [, mxOrder] )
	;   .TransformScale( sx, sy [, mxOrder] )
	;   .TransformRotate( angle [, mxOrder] )
	;   .TransformRotateAt( cx, cy, angle [, mxOrder] )
	;   .TransformMatrix( oMatrix [, mxOrder] )
	;   .SetTransformMatrix( oMatrix )
	;   .GetTransformMatrix()
	; 
	; Internal methods:
	;   ._IdentifyCap( cap [, dashCap] )
	; 
	; Classes:
	;   Pen.CustomCap
	;   Pen.ArrowCap
	
	Class Pen {
		
		__New( source := 0x0, width := 1, unit := 0 ) {
			Local
			Global OGdip
			
			pPen := 0
			
			If (IsObject(source) == True)
			&& (source.Base == OGdip.Pen)
			{
				DllCall("GdiPlus\GdipClonePen"
				, "Ptr" , source._pPen
				, "Ptr*", pPen)
				
				this._brushSource := source._brushSource
				
			} Else
			If (IsObject(source) == True)
			&& (source.Base.Base == OGdip.Brush)
			{
				DllCall("GdiPlus\GdipCreatePen2"
				, "Ptr"  , source._pBrush
				, "Float", width
				, "UInt" , unit
				, "Ptr*" , pPen)
				
				this._brushSource := source
				
			} Else {
				DllCall("GdiPlus\GdipCreatePen1"
				, "UInt" , source
				, "Float", width
				, "UInt" , unit
				, "Ptr*" , pPen)
				
				this._brushSource := 0
			}
			
			
			If (pPen == 0) {
				this.Base := False  ; Avoid calling __Delete
				Return False
			}
			
			this._pPen := pPen
		}
		
		
		__Delete() {
			DllCall("GdiPlus\GdipDeletePen"
			, "Ptr", this._pPen)
		}
		
		
		; Gets/sets pen color or brush that pen is based on.
		
		Color {
			Get {
				Local
				If (IsObject(this._brushSource) == True) {
					Return this._brushSource
					
				} Else {
					DllCall("GdiPlus\GdipGetPenColor"
					, "Ptr"   , this._pPen
					, "UInt*", argb := 0)
					
					Return argb
				}
			}
			Set {
				If (IsObject(this._brushSource) == True) {
					If (IsObject(value) == True)
					&& (value.Base.Base == OGdip.Brush)
					{
						DllCall("GdiPlus\GdipSetPenBrushFill"
						, "Ptr", this._pPen
						, "Ptr", value._pBrush)
						
						this._brushSource := value
					}
					
					Return this._brushSource
					
				} Else {
					DllCall("GdiPlus\GdipSetPenColor"
					, "Ptr"  , this._pPen
					, "UInt", value)
				}
				
				Return value
			}
		}
		
		
		Width {
			Get {
				DllCall("GdiPlus\GdipGetPenWidth"
				, "Ptr"   , this._pPen
				, "Float*", width := 0)
				
				Return width
			}
			Set {
				If (value == "")
					Return
				
				DllCall("GdiPlus\GdipSetPenWidth"
				, "Ptr"  , this._pPen
				, "Float", value)
				
				Return value
			}
		}
		
		
		; Gets/sets pen unit.
		; Note: getting it will return unit as a numeric index.
		; Use OGdip.Enum.Get("Unit", unit) to get name from it.
		
		Unit {
			Get {
				DllCall("GdiPlus\GdipGetPenUnit"
				, "Ptr"  , this._pPen
				, "UInt*", penUnit := 0)
				
				Return penUnit
			}
			Set {
				DllCall("GdiPlus\GdipSetPenUnit"
				, "Ptr" , this._pPen
				, "UInt", OGdip.Enum.Set("Unit", value))
				
				Return value
			}
		}
		
		
		; Sets pen alignment or compound array.
		;   > pen1.SetStroke( "Center" )    ; Pen stroke is centered.
		;   > pen1.SetStroke( "Inset" )     ; For closed figures stroke will be inset.
		;   > pen1.SetStroke( [0.0, 1.0] )  ; Set compound array.
		; Compound array contains numbers that specify fills and gaps across the stroke.
		; For example, array [0.0, 0.2, 0.5, 1.0] will create two parallel strokes:
		; 20%-width stroke to the left, then 30%-width gap and half-width stroke to the right.
		; There are four predefined compound arrays: Double, Triple, Left and Right.
		; Note: after you use compound array, you cannot revert to 'Inset' mode.
		
		SetStroke( strokeShape ) {
			Local
			Global OGdip
			
			If (strokeShape = "Center") || (strokeShape == 0)
			|| (strokeShape = "Inset")  || (strokeShape == 1)
			{
				penAlignment := (strokeShape = "Inset") || (strokeShape == 1)
				
				DllCall("GdiPlus\GdipSetPenMode"
				, "Ptr" , this._pPen
				, "UInt", penAlignment)
				
				Return this
			}
			
			compoundArray := IsObject(strokeShape)  ?  strokeShape
			:  (strokeShape = "Double")  ?  [0.0, 0.333,  0.666, 1.0]
			:  (strokeShape = "Triple")  ?  [0.0, 0.2,  0.4, 0.6,  0.8, 1.0]
			:  (strokeShape = "Left")    ?  [0.0, 0.5]
			:  (strokeShape = "Right")   ?  [0.5, 1.0]
			:  [0.0, 1.0]
			
			OGdip._CreateBinArray(compoundArray, binCompound := "", "Float")
			
			; Revert to 'Center', compound arrays don't work with 'Inset'.
			DllCall("GdiPlus\GdipSetPenMode"
			, "Ptr" , this._pPen
			, "UInt", 0)
			
			DllCall("GdiPlus\GdipSetPenCompoundArray"
			, "Ptr" ,  this._pPen
			, "Ptr" , &binCompound
			, "Int" ,  compoundArray.Length())
			
			Return this
		}
		
		
		; Sets type of line joins on the corners and miter limit.
		; Miter limit sets the ratio of a size of a corner tip to the width of the pen stroke.
				
		Static EnumLineJoin := { _minId: 0, _maxId: 3
			, "M": 0  , "Miter": 0
			, "B": 1  , "Bevel": 1
			, "R": 2  , "Round": 2
			, "C": 3  , "MClip": 3  , "MiterClip": 3 }

		SetLineJoin( joinType := "", miterLimit := "" ) {
			Local
			Global OGdip
			
			If (joinType != "") {
				joinType := OGdip.Enum.Get(this.EnumLineJoin, joinType, 0)
				
				DllCall("GdiPlus\GdipSetPenLineJoin"
				, "Ptr" , this._pPen
				, "UInt", joinType)
			}
			
			If (miterLimit != "") {
				DllCall("GdiPlus\GdipSetPenMiterLimit"
				, "Ptr"  , this._pPen
				, "Float", miterLimit)
			}
			
			Return this
		}
		
		
		; Sets dash style, offset, and optionally dash cap.
		; Argument 'dashStyle' can be either enumeration or an array
		; of lengths (relative to pen width) of dashes and gaps.
		
		Static EnumDashStyle := { _minId: 0, _maxId: 4
			, "Solid"      : 0
			, "Dash"       : 1
			, "Dot"        : 2
			, "DashDot"    : 3
			, "DashDotDot" : 4 }

		SetDash( dashStyle := "", dashOffset := "", dashCap := "" ) {
			Local
			Global OGdip
			
			If (dashStyle != "") {
				If (IsObject(dashStyle)) {
					OGdip._CreateBinArray(dashStyle, binDashPattern := "", "Float")
					
					DllCall("GdiPlus\GdipSetPenDashArray"
					, "Ptr",  this._pPen
					, "Ptr", &binDashPattern
					, "Int",  dashStyle.Length())
					
				} Else {
					dashStyle := OGdip.Enum.Get(this.EnumDashStyle, dashStyle, 0)
					
					DllCall("GdiPlus\GdipSetPenDashStyle"
					, "Ptr" , this._pPen
					, "UInt", dashStyle)
				}
			}
			
			If (dashOffset != "") {
				DllCall("GdiPlus\GdipSetPenDashOffset"
				, "Ptr"  , this._pPen
				, "Float", dashOffset)
			}
			
			If (dashCap != "")
				this.SetCaps("", dashCap, "")
			
			Return this
		}
		
		
		; Return numeric identificator of the cap given as a string.
		; See comments in the code below, form of brackets mimics the form of a cap.
		; For internal use in .SetCaps method.
		
		_IdentifyCap( cap, dashCap := False ) {
			Local
			
			If (cap == "")
				Return
			
			If (IsObject(cap))     ; Assuming CustomCap
			&& (dashCap == False)
				Return cap
			
			capType := False ? ""
			:  (cap ~= "[\|FN]")   ?  0   ;  |  F  N  Flat  None
			:  (cap ~= "[\[\]S]")  ?  1   ;  [  ]  S  Square
			:  (cap ~= "[\(\)R]")  ?  2   ;  (  )  R  Round
			:  (cap ~= "[\<\>T]")  ?  3   ;  <  >  T  Triangle
			:  (cap ~= "^\d+$")    ?  Floor(cap)
			:  0
			
			If (dashCap == True)  ; Dash-cap can only be flat, round or triangle
				Return ((capType == 1) ? 0 : capType)
			
			If (cap ~= "[\+\*\!]")           ;  +  *  !  Make anchor (big cap)
				capType += 0x10
			
			If (cap ~= "A")                  ;  A  Arrow
				capType := 0x14
			
			Return capType
		}
		
		
		; Sets cap style for start/end of the stroke and start/end of dashes.
		; Each argument can be omitted to keep that cap style unchanged.
		; Each argument can be a string (see ._IdentifyCap), numeric id,
		; or (for startCap/endCap) an instance of CustomCap object.
		
		SetCaps( startCap := "", dashCap := "", endCap := "" ) {
			Local
			
			If (startCap != "") {
				If (IsObject(startCap) == False) {
					DllCall("GdiPlus\GdipSetPenStartCap"
					, "Ptr" , this._pPen
					, "UInt", this._IdentifyCap(startCap))
					
				} Else {
					this._startCap := startCap
					
					DllCall("GdiPlus\GdipSetPenCustomStartCap"
					, "Ptr" , this._pPen
					, "Ptr" , startCap._pCap)
				}
			}
			
			If (endCap != "") {
				If (IsObject(endCap) == False) {
					DllCall("GdiPlus\GdipSetPenEndCap"
					, "Ptr" , this._pPen
					, "UInt", this._IdentifyCap(endCap))
					
				} Else {
					this._endCap := endCap
					
					DllCall("GdiPlus\GdipSetPenCustomEndCap"
					, "Ptr" , this._pPen
					, "Ptr" , endCap._pCap)
				}
			}
			
			If (dashCap != "") {
				DllCall("GdiPlus\GdipSetPenDashCap197819"
				, "Ptr" , this._pPen
				, "UInt", this._IdentifyCap(dashCap, True))
			}
			
			Return this
		}
		
		
		; -- Transformation methods --
		
		TransformReset() {
			DllCall("GdiPlus\GdipResetPenTransform"
			, "Ptr", this._pPen)
			
			Return this
		}
		
		TransformMove( dx, dy, mxOrder := 0 ) {
			DllCall("GdiPlus\GdipTranslatePenTransform"
			, "Ptr"  , this._pPen
			, "Float", dx
			, "Float", dy
			, "UInt" , mxOrder)
			
			Return this
		}
		
		TransformScale( sx, sy, mxOrder := 0 ) {
			DllCall("GdiPlus\GdipScalePenTransform"
			, "Ptr"  , this._pPen
			, "Float", sx
			, "Float", sy
			, "UInt" , mxOrder)
			
			Return this
		}
		
		TransformRotate( angle, mxOrder := 0 ) {
			DllCall("GdiPlus\GdipRotatePenTransform"
			, "Ptr"  , this._pPen
			, "Float", angle
			, "UInt" , mxOrder)
			
			Return this
		}
		
		TransformRotateAt( cx, cy, angle, mxOrder := 0 ) {
			this.TransformMove(cx, cy)
			this.TransformRotate(angle)
			this.TransformMove(-cx, -cy)
			
			Return this
		}
		
		TransformMatrix( oMatrix, mxOrder := 0 ) {
			DllCall("GdiPlus\GdipMultiplyPenTransform"
			, "Ptr" , this._pPen
			, "Ptr" , oMatrix._pMatrix
			, "UInt", mxOrder)
			
			Return this
		}
		
		SetTransformMatrix( oMatrix ) {
			DllCall("GdiPlus\GdipSetPenTransform"
			, "Ptr" , this._pPen
			, "Ptr" , oMatrix._pMatrix)
			
			Return this
		}
		
		GetTransformMatrix() {
			Local oMatrix
			oMatrix := new OGdip.Matrix()
			
			DllCall("GdiPlus\GdipGetPenTransform"
			, "Ptr", this._pPen
			, "Ptr", oMatrix._pMatrix)
			
			Return oMatrix
		}
		
		
		; Returns object with various info about the pen.
		; See object structure at the bottom of this method.
		
		GetInfo() {
			Local
			
			DllCall("GdiPlus\GdipGetPenStartCap"
			, "Ptr"   , this._pPen
			, "UInt*" , penStartCapType := -1)
			
			DllCall("GdiPlus\GdipGetPenEndCap"
			, "Ptr"   , this._pPen
			, "UInt*" , penEndCapType := -1)
			
			DllCall("GdiPlus\GdipGetPenDashCap197819"
			, "Ptr"   , this._pPen
			, "UInt*" , penDashCapType := -1)
			
			DllCall("GdiPlus\GdipGetPenLineJoin"
			, "Ptr"   , this._pPen
			, "UInt*" , penLineJoinType := -1)
			
			DllCall("GdiPlus\GdipGetPenMiterLimit"
			, "Ptr"   , this._pPen
			, "Float*", penMiterLimit := -1)
			
			DllCall("GdiPlus\GdipGetPenMode"
			, "Ptr"   , this._pPen
			, "UInt*" , penAlignment := -1)
			
			DllCall("GdiPlus\GdipGetPenFillType"
			, "Ptr"   , this._pPen
			, "UInt*" , penFillType := -1)
			
			DllCall("GdiPlus\GdipGetPenDashStyle"
			, "Ptr"   , this._pPen
			, "UInt*" , penDashStyle := -1)
			
			DllCall("GdiPlus\GdipGetPenDashOffset"
			, "Ptr"   , this._pPen
			, "Float*", penDashOffset := -1)
			
			
			DllCall("GdiPlus\GdipGetPenDashCount"
			, "Ptr"   , this._pPen
			, "Int*"  , penDashArrayCount := 0)
			
			VarSetCapacity(binPenDashArray, penDashArrayCount * 4, 0)
			
			DllCall("GdiPlus\GdipGetPenDashArray"
			, "Ptr"   ,  this._pPen
			, "Ptr"   , &binPenDashArray
			, "Int"   ,  penDashArrayCount)
			
			penDashArray := []
			
			Loop % penDashArrayCount {
				penDashArray.Push( NumGet(binPenDashArray, (A_Index-1)*4, "Float") )
			}
			
			
			DllCall("GdiPlus\GdipGetPenCompoundCount"
			, "Ptr"   , this._pPen
			, "Int*"  , penCompoundArrayCount := 0)
			
			VarSetCapacity(binPenCompoundArray, penCompoundArrayCount * 4, 0)
			
			DllCall("GdiPlus\GdipGetPenCompoundArray"
			, "Ptr"   ,  this._pPen
			, "Ptr"   , &binPenCompoundArray
			, "Int"   ,  penCompoundArrayCount)
			
			penCompoundArray := []
			
			Loop % penCompoundArrayCount {
				penCompoundArray.Push( NumGet(binPenCompoundArray, (A_Index-1)*4, "Float") )
			}
			
			result := {}
			result.startCap      := penStartCapType
			result.endCap        := penEndCapType
			result.dashCap       := penDashCapType
			result.lineJoin      := penLineJoinType
			result.miterLimit    := penMiterLimit
			result.alignment     := penAlignment
			result.fillType      := penFillType
			result.dashStyle     := penDashStyle
			result.dashOffset    := penDashOffset
			result.dashArray     := penDashArray
			result.compoundArray := penCompoundArray
			
			Return result
		}
		
		
		; CustomCap class
		; ---------------
		; Creates non-standard pen cap from a given path.
		; 
		; Constructors:
		;   > myCap := new OGdip.Pen.CustomCap( oPath [, pathIsFill, inset, baseCap] )
		;   > myCap := new OGdip.Pen.CustomCap( oCustomCap )
		; Note: Path must intersect negative Y-axis for CustomCap to work properly.
		; Note: CustomCap always uses winding fill mode for its path.
		; 
		; Methods:
		;   .SetCaps( [baseCap, startCap, endCap] )
		;   .SetLineJoin( joinType )
		;   .SetBaseInset( inset )
		;   .SetWidthScale( wScale )
		;   .GetInfo()
		
		Class CustomCap {
			
			__New( source, pathIsFill := True, inset := 0, baseCap := 0 ) {
				Local
				Global OGdip
				
				pCap := 0
				
				If (IsObject(source) == False)
					Return False
				
				If (source.Base == OGdip.Pen.CustomCap) {
					DllCall("GdiPlus\GdipCloneCustomLineCap"
					, "Ptr" , source._pCap
					, "Ptr*", pCap)
					
				} Else
				If (source.Base == OGdip.Path) {
					DllCall("GdiPlus\GdipCreateCustomLineCap"
					, "Ptr"  , (pathIsFill ? source._pPath : 0)
					, "Ptr"  , (pathIsFill ? 0 : source._pPath)
					, "UInt" ,  OGdip.Pen._IdentifyCap(baseCap)
					, "Float",  inset
					, "Ptr*" ,  pCap)
				}
				
				
				If (pCap == 0) {
					this.Base := False  ; Avoid calling __Delete
					Return False
				}
				
				this._pCap := pCap
			}
			
			
			__Delete() {
				DllCall("GdiPlus\GdipDeleteCustomLineCap"
				, "Ptr", this._pCap)
			}
			
			
			; Sets base cap and caps for cap's path stroke.
			; Base cap is a regular cap that is used as a part of CustomCap.
			; See OGdip.Pen._IdentifyCap method for cap styles.
			
			SetCaps( baseCap := "", startCap := "", endCap := "" ) {
				Local
				Global OGdip
				
				If (baseCap != "") {
					DllCall("GdiPlus\GdipSetCustomLineCapBaseCap"
					, "Ptr" , this._pCap
					, "UInt", OGdip.Pen._IdentifyCap(baseCap))
				}
				
				If (startCap == "")
				&& (endCap   == "")
					Return this
				
				DllCall("GdiPlus\GdipGetCustomLineCapStrokeCaps"
				, "Ptr"  , this._pCap
				, "UInt*", prevStartCap := 0
				, "UInt*", prevEndCap   := 0)
				
				newStartCap := (startCap == "") ? prevStartCap : OGdip.Pen._IdentifyCap(startCap)
				newEndCap   := (endCap   == "") ? prevEndCap   : OGdip.Pen._IdentifyCap(endCap)
				
				DllCall("GdiPlus\GdipSetCustomLineCapStrokeCaps"
				, "Ptr" , this._pCap
				, "UInt", newStartCap
				, "UInt", newEndCap)
				
				Return this
			}
			
			
			; Sets line join type for cap's path stroke.
			
			SetLineJoin( joinType ) {
				joinType := OGdip.Enum.Get(OGdip.Pen.EnumLineJoin, joinType, 0)
				
				DllCall("GdiPlus\GdipSetCustomLineCapStrokeJoin"
				, "Ptr" , this._pCap
				, "UInt", joinType)
				
				Return this
			}
			
			
			; Sets the distance between the end of a pen stroke and the base cap.
			
			SetBaseInset( inset ) {
				DllCall("GdiPlus\GdipSetCustomLineCapBaseInset"
				, "Ptr"  , this._pCap
				, "Float", inset)
				
				Return this
			}
			
			
			; Sets the scale of the cap relative to pen's width (default is 1.0).
			
			SetWidthScale( wScale ) {
				DllCall("GdiPlus\GdipSetCustomLineCapWidthScale"
				, "Ptr"  , this._pCap
				, "Float", wScale)
				
				Return this
			}
			
			
			; Returns object with various information about CustomCap.
			; See object structure at the end of this method.
			
			GetInfo() {
				Local
				
				DllCall("GdiPlus\GdipGetCustomLineCapStrokeCaps"
				, "Ptr"  , this._pCap
				, "UInt*", startCap := 0
				, "UInt*", endCap   := 0)
				
				DllCall("GdiPlus\GdipGetCustomLineCapStrokeJoin"
				, "Ptr"  , this._pCap
				, "UInt*", joinType := 0)
				
				DllCall("GdiPlus\GdipGetCustomLineCapBaseCap"
				, "Ptr"  , this._pCap
				, "UInt*", baseCap := 0)
				
				DllCall("GdiPlus\GdipGetCustomLineCapBaseInset"
				, "Ptr"   , this._pCap
				, "Float*", baseInset := 0)
				
				DllCall("GdiPlus\GdipGetCustomLineCapWidthScale"
				, "Ptr"   , this._pCap
				, "Float*", widthScale := 0)
				
				result := {}
				result.startCap   := startCap
				result.endCap     := endCap
				result.baseCap    := baseCap
				result.joinType   := joinType
				result.baseInset  := baseInset
				result.widthScale := widthScale
				
				Return result
			}
		}
		
		
		; ArrowCap class
		; --------------
		; Creates arrow cap with adjustable parameters.
		; 
		; Constructors:
		;   > myCap := new OGdip.Pen.ArrowCap( [height, width, isFilled] )
		;   > myCap := new OGdip.Pen.ArrowCap( oArrowCap )
		; 
		; Methods:
		;   .SetHeight( arrowHeight )
		;   .SetWidth( width )
		;   .SetInset( inset )
		;   .SetFill( fillState )
		;   .GetInfo()
		
		Class ArrowCap {
			
			__New( height := 3, width := 3, isFilled := 0 ) {
				pCap := 0
				
				If (IsObject(height) == False) {
					DllCall("GdiPlus\GdipCreateAdjustableArrowCap"
					, "Float", height
					, "Float", width
					, "UInt" , isFilled
					, "Ptr*" , pCap)
					
				} Else
				If (height.Base == OGdip.Pen.ArrowCap) {
					DllCall("GdiPlus\GdipCloneCustomLineCap"
					, "Ptr" , height._pCap
					, "Ptr*", pCap)
				}
				
				
				If (pCap == 0) {
					this.Base := False  ; Avoid calling __Delete
					Return False
				}
				
				this._pCap := pCap
			}
			
			
			__Delete() {
				DllCall("GdiPlus\GdipDeleteCustomLineCap"
				, "Ptr", this._pCap)
			}
			
			
			; Sets height (length) of the arrow relative to pen's width.
			
			SetHeight( height ) {
				DllCall("GdiPlus\GdipSetAdjustableArrowCapHeight"
				, "Ptr"  , this._pCap
				, "Float", height)
				
				Return this
			}
			
			
			; Sets width of the arrow relative to pen's width.
			
			SetWidth( width ) {
				DllCall("GdiPlus\GdipSetAdjustableArrowCapWidth"
				, "Ptr"  , this._pCap
				, "Float", width)
				
				Return this
			}
			
			
			; Sets base midpoint offset:
			;   •  0   - flat base  , arrow have a triangular form;
			;   •  >0  - inset base , arrow have V-shaped form;
			;   •  <0  - outset base, arrow have diamond-shaped form.
			
			SetInset( arrowInset ) {
				DllCall("GdiPlus\GdipSetAdjustableArrowCapMiddleInset"
				, "Ptr"  , this._pCap
				, "Float", arrowInset)
				
				Return this
			}
			
			
			; Sets arrow filled state:
			;   •  1  -  arrow is filled
			;   •  0  -  arrow have only outline and no fill
			
			SetFill( fillState ) {
				DllCall("GdiPlus\GdipSetAdjustableArrowCapFillState"
				, "Ptr"  , this._pCap
				, "UInt" , fillState)
				
				Return this
			}
			
			
			; Returns object with various information about ArrowCap.
			; See object structure at the end of this method.
			
			GetInfo() {
				Local
				
				DllCall("GdiPlus\GdipGetAdjustableArrowCapHeight"
				, "Ptr"   , this._pCap
				, "Float*", height := 0)
				
				DllCall("GdiPlus\GdipGetAdjustableArrowCapWidth"
				, "Ptr"   , this._pCap
				, "Float*", width := 0)
				
				DllCall("GdiPlus\GdipGetAdjustableArrowCapMiddleInset"
				, "Ptr"   , this._pCap
				, "Float*", inset := 0)
				
				DllCall("GdiPlus\GdipGetAdjustableArrowCapFillState"
				, "Ptr"   , this._pCap
				, "UInt*" , fillState := 0)
				
				result := {}
				result.height := height
				result.width  := width
				result.inset  := inset
				result.fill   := fillState
				
				Return result
			}
		}
	}
	
	
	
	; Brush class
	; ===========
	; 
	; Super-class for all brush types.
	; Can be used to create instance of required subclass.
	; Individual subclass constructors, however, provide more flexibility.
	; 
	; Constructors:
	;   > br := new OGdip.Brush( oBrush )                          ; Clone brush
	;   > br := new OGdip.Brush( argb )                            ; SolidBrush
	;   > br := new OGdip.Brush( style, argb1, argb2 )             ; HatchBrush
	;   > br := new OGdip.Brush( oImage [, x,y,w,h, attributes] )  ; TextureBrush
	;   > br := new OGdip.Brush( points [, argb1, argb2, wrap] )   ; LinearBrush
	;   > br := new OGdip.Brush( oPath [, colors, centerColor] )   ; PathBrush
	; 
	; Methods:
	;   .GetType( [asText] )
	;   ._CreatePlacesList( source, itemCount )
	; 
	; Subclasses:
	;   • SolidBrush
	;   • HatchBrush
	;   • TextureBrush
	;   • LinearBrush
	;   • PathBrush
	
	Class Brush {
		
		__New( source := "", args* ) {
			Local
			Global OGdip
			
			; This constructor acts as a proxy and does not create a Brush instance by itself,
			; so it does not need to call __Delete afterwards.
			this.Base := False
			
			If (IsObject(source) == True) {
				If (source.Base == OGdip.Image)
				|| (source.Base == OGdip.Bitmap)
				|| (source.Base == OGdip.Metafile)
				{
					Return new OGdip.Brush.TextureBrush( source, args* )
				}
				
				If (source.Base == OGdip.Path) {
					Return new OGdip.Brush.PathBrush( source, args* )
				}
				
				If (source.Base.Base == OGdip.Brush) {
					brushType := source.GetType()
					
					brushBase := False ? ""
					:  (brushType == 0)  ?  OGdip.Brush.SolidBrush
					:  (brushType == 1)  ?  OGdip.Brush.HatchBrush
					:  (brushType == 2)  ?  OGdip.Brush.TextureBrush
					:  (brushType == 3)  ?  OGdip.Brush.PathBrush
					:  (brushType == 4)  ?  OGdip.Brush.LinearBrush
					:  OGdip.Brush.SolidBrush
					
					DllCall("GdiPlus\GdipCloneBrush"
					, "Ptr" , source._pBrush
					, "Ptr*", pCloneBrush := 0)
					
					If (pCloneBrush == 0)
						Return False
					
					Return { Base: brushBase, _pBrush: pCloneBrush }
				}
				
				; Assuming 'source' is array of two points
				Return new OGdip.Brush.LinearBrush( source, args* )
			}
			
			If (args.Length() > 2) {
				Return new OGdip.Brush.LinearBrush( source, args* )
			}
			
			If (args.Length() == 2) {
				Return new OGdip.Brush.HatchBrush( source, args* )
			}
			
			Return new OGdip.Brush.SolidBrush( source )
		}
		
		
		__Delete() {
			DllCall("GdiPlus\GdipDeleteBrush"
			, "Ptr", this._pBrush)
		}
		
		
		GetType( asText := False ) {
			Local
			
			DllCall("GdiPlus\GdipGetBrushType"
			, "Ptr"  , this._pBrush
			, "UInt*", brushType := 0)
			
			Return ((asText == False) ? brushType
			:  (brushType == 0)  ?  "Solid"
			:  (brushType == 1)  ?  "Hatch"
			:  (brushType == 2)  ?  "Texture"
			:  (brushType == 3)  ?  "Path"
			:  (brushType == 4)  ?  "Linear"  :  brushType)
		}
		
		
		; Normalizes array of positions to be used with multiple colors.
		; If 'source' is not an array, creates an array with evenly distributed values.
		; For internal use in LinearBrush and PathBrush.
		
		_CreatePlacesList( source, itemCount ) {
			Local
			
			If (IsObject(source) == True)
			&& (source.Length() >= itemCount)
			{
				placesList := source.Clone()
				
				If (placesList[1] != 0)
					placesList[1] := 0
				
				If (placesList[itemCount] != 0)
					placesList[itemCount] := 0
				
				Loop % placesList.Length() {
					placesList[A_Index] := False ? 0
					:  (A_Index == 1)         ?  0  ; First elem is always zero
					:  (A_Index == itemCount) ?  1  ; Last elem is always 1
					:   Min(Max( placesList[A_Index], 0 ), 1)
				}
				
			} Else {
				placesList := []
				
				Loop % itemCount {
					placesList[A_Index] := (A_Index-1) / (itemCount-1)
				}
			}
			
			Return placesList
		}
		
		
		
		; SolidBrush class
		; ----------------
		; Solid brush uses single color.
		; 
		; Constructors:
		;   > br := new OGdip.Brush.SolidBrush( [argb] )
		; 
		; Properties:
		;   > Color
		
		Class SolidBrush  Extends  OGdip.Brush {
			
			__New( argb := 0xFFFFFFFF ) {
				DllCall("GdiPlus\GdipCreateSolidFill"
				, "UInt", argb
				, "Ptr*", pBrush := 0)
				
				If (pBrush == 0) {
					this.Base := False  ; Avoid calling __Delete
					Return False
				}
				
				this._pBrush := pBrush
			}
			
			
			Color {
				Get {
					Local
					
					DllCall("GdiPlus\GdipGetSolidFillColor"
					, "Ptr"  , this._pBrush
					, "UInt*", argb := 0)
					
					Return argb
				}
				Set {
					DllCall("GdiPlus\GdipSetSolidFillColor"
					, "Ptr" , this._pBrush
					, "UInt", value)
					
					Return value
				}
			}
		}
		
		
		
		; HatchBrush class
		; ----------------
		; Hatch brush uses predefined two-color pattern.
		; 
		; Constructors:
		;   > br := new OGdip.Brush.HatchBrush( hatchStyle [, fgColor, bgColor] )
		; See OGdip.Enum.HatchStyle for 'hatchStyle' named aliases.
		; 
		; Methods:
		;   .GetHatchStyle()
		;   .GetForegroundColor()
		;   .GetBackgroundColor()
		
		Class HatchBrush  Extends  OGdip.Brush {
			
			__New( hatchStyle, fgColor := 0xFFFFFFFF, bgColor := 0xFF000000 ) {
				Local pBrush := 0
				
				hatchStyle := OGdip.Enum.Get("HatchStyle", hatchStyle, 12)
				
				DllCall("GdiPlus\GdipCreateHatchBrush"
				, "UInt", hatchStyle
				, "UInt", fgColor
				, "UInt", bgColor
				, "Ptr*", pBrush)
				
				If (pBrush == 0) {
					this.Base := False  ; Avoid calling __Delete
					Return False
				}
				
				this._pBrush := pBrush
			}
			
			
			GetHatchStyle() {
				Local
				
				DllCall("GdiPlus\GdipGetHatchStyle"
				, "Ptr"  , this._pGraphics
				, "UInt*", hatchStyle := 0)
				
				Return hatchStyle
			}
			
			GetForegroundColor() {
				Local
				
				DllCall("GdiPlus\GdipGetHatchForegroundColor"
				, "Ptr"  , this._pGraphics
				, "UInt*", argb := 0)
				
				Return argb
			}
			
			GetBackgroundColor() {
				Local
				
				DllCall("GdiPlus\GdipGetHatchBackgroundColor"
				, "Ptr"  , this._pGraphics
				, "UInt*", argb := 0)
				
				Return argb
			}
		}
		
		
		
		; TextureBrush class
		; ------------------
		; Texture brush uses image (bitmap or metafile).
		; 
		; Constructors:
		;   > br := new OGdip.Brush.TextureBrush( oImage [, x, y, w, h][, oAttributes] )
		; Arguments [x, y, w, h] specify area of bitmap that will be used as a texture.
		; For a metafile, whole image will be used and scaled to fit given texture size [w, h].
		; 
		; Properties:
		;   .WrapMode
		; 
		; Methods:
		;   .GetImage()
		; 
		; Transform methods:
		;   .TransformReset()
		;   .TransformMove( dx, dy [, mxOrder] )
		;   .TransformScale( sx, sy, [, mxOrder] )
		;   .TransformRotate( angle [, mxOrder] )
		;   .TransformRotateAt( cx, cy, angle [, mxOrder] )
		;   .TransformMatrix( oMatrix [, mxOrder] )
		;   .SetTransformMatrix( oMatrix )
		;   .GetTransformMatrix()
		
		Class TextureBrush  Extends  OGdip.Brush {
			
			__New( oImage, args* ) {
				Local
				Global OGdip
				
				pBrush := 0
				pAttributes := 0
				
				; Extract ImageAttributes argument (if present).
				If (args.Length() > 0) {
					lastArg := args[args.MaxIndex()]
					
					If (IsObject(lastArg) == True)
					&& (lastArg.Base == OGdip.ImageAttributes)
					{
						pAttributes := lastArg._pAttributes
						args.Pop()
					}
				}
				
				; Extract XYWH arguments.
				If (args.Length() == 4) {
					rect := [ args[1], args[2], args[3], args[4] ]
					
				} Else
				If (IsObject(args[1]) == True) {
					rect := args[1]
					
				} Else {
					rect := oImage.GetBounds()
				}
				
				; Clip rect to image bounds
				imgBounds := oImage.GetBounds()
				
				rect[1] := Max(rect[1], imgBounds[1])
				rect[2] := Max(rect[2], imgBounds[2])
				rect[3] := Min(rect[3], imgBounds[3] - (rect[1] - imgBounds[1]))
				rect[4] := Min(rect[4], imgBounds[4] - (rect[2] - imgBounds[2]))
				
				DllCall("GdiPlus\GdipCreateTextureIA"
				, "Ptr"  , oImage._pImage
				, "Ptr"  , pAttributes
				, "Float", rect[1]
				, "Float", rect[2]
				, "Float", rect[3]
				, "Float", rect[4]
				, "Ptr*" , pBrush)
				
				If (pBrush == 0) {
					this.Base := False  ; Avoid calling __Delete
					Return False
				}
				
				this._pBrush := pBrush
			}
			
			
			WrapMode {
				Get {
					Local
					DllCall("GdiPlus\GdipGetTextureWrapMode"
					, "Ptr"  , this._pBrush
					, "UInt*", result := 0)
					
					Return result
				}
				Set {
					DllCall("GdiPlus\GdipSetTextureWrapMode"
					, "Ptr" , this._pBrush
					, "UInt", OGdip.Enum.Get("WrapMode", value, 0))
					
					Return value
				}
			}
			
			
			GetImage() {
				DllCall("GdiPlus\GdipGetTextureImage"
				, "Ptr" , this._pBrush
				, "Ptr*", pImage := 0)
				
				Return ((pImage == 0)  ?  0  :  {Base: OGdip.Image, _pImage: pImage})
			}
			
			
			TransformReset() {
				DllCall("GdiPlus\GdipResetTextureTransform"
				, "Ptr" , this._pBrush)
				
				Return this
			}
			
			TransformMove( dx, dy, mxOrder := 0 ) {
				DllCall("GdiPlus\GdipTranslateTextureTransform"
				, "Ptr"  , this._pBrush
				, "Float", dx
				, "Float", dy
				, "UInt" , mxOrder)
				
				Return this
			}
			
			TransformScale( sx, sy, mxOrder := 0 ) {
				DllCall("GdiPlus\GdipScaleTextureTransform"
				, "Ptr" , this._pBrush
				, "Float", sx
				, "Float", sy
				, "UInt" , mxOrder)
				
				Return this
			}
			
			TransformRotate( angle, mxOrder := 0 ) {
				DllCall("GdiPlus\GdipRotateTextureTransform"
				, "Ptr"  , this._pBrush
				, "Float", angle
				, "UInt" , mxOrder)
				
				Return this
			}
			
			TransformRotateAt( cx, cy, angle, mxOrder := 0 ) {
				this.TransformMove(cx, cy)
				this.TransformRotate(angle)
				this.TransformMove(-cx, -cy)
				
				Return this
			}
			
			TransformMatrix( oMatrix, mxOrder := 0 ) {
				DllCall("GdiPlus\GdipMultiplyTextureTransform"
				, "Ptr" , this._pBrush
				, "Ptr" , oMatrix._pMatrix
				, "UInt", mxOrder)
				
				Return this
			}
			
			SetTransformMatrix( oMatrix ) {
				DllCall("GdiPlus\GdipSetTextureTransform"
				, "Ptr" , this._pBrush
				, "Ptr" , oMatrix._pMatrix)
				
				Return this
			}
			
			GetTransformMatrix() {
				oMatrix := new OGdip.Matrix()
				
				DllCall("GdiPlus\GdipMultiplyTextureTransform"
				, "Ptr" , this._pBrush
				, "Ptr" , oMatrix._pMatrix
				, "UInt", mxOrder)
				
				Return oMatrix
			}
		}

		
		
		; LinearBrush class
		; -----------------
		; Linear gradient brush uses two or more colors
		; that interpolate between given points.
		; 
		; Constructors:
		;   > br := new OGdip.Brush.LinearBrush( x1,y1,x2,y2 [, argb1, argb2, wrapMode] )
		;   > br := new OGdip.Brush.LinearBrush( points [, argb1, argb2, wrapMode] )
		; Because gradient is linear, only actually useful wrapMode is 1:"X".
		; 
		; Properties:
		;   .GradientMode [Read-only]
		;   .WrapMode
		;   .UseGamma
		; 
		; Methods:
		;   .GetColors( [&placesList, &factorsList] )
		;   .SetColors( color1, color2 )
		;   .SetMode( lgMode [, arg1, arg2] )
		; 
		; Transform methods:
		;   .TransformReset()
		;   .TransformMove( dx, dy [, mxOrder] )
		;   .TransformScale( sx, sy, [, mxOrder] )
		;   .TransformRotate( angle [, mxOrder] )
		;   .TransformRotateAt( cx, cy, angle [, mxOrder] )
		;   .TransformMatrix( oMatrix [, mxOrder] )
		;   .SetTransformMatrix( oMatrix )
		;   .GetTransformMatrix()
		
		Class LinearBrush  Extends  OGdip.Brush {
			
			__New( args* ) {
				Local
				Global OGdip
				
				; Two points 
				If (IsObject(args[1]) == True) {
					lgPoints := OGdip._FlattenArray( args.RemoveAt(1) )
					
				} Else {
					lgPoints := [ args[1], args[2], args[3], args[4] ]
					args.RemoveAt(1, 4)
				}
				
				OGdip._CreateBinArray(lgPoints, binPoints := "", "Float")
				
				color1   := args.HasKey(1)  ?  args[1]  :  0xFF000000
				color2   := args.HasKey(2)  ?  args[2]  :  0xFFFFFFFF
				wrapMode := args.HasKey(3)  ?  args[3]  :  0
				
				DllCall("GdiPlus\GdipCreateLineBrush"
				, "Ptr" , &binPoints
				, "Ptr" , &binPoints + 2*4
				, "UInt",  color1
				, "UInt",  color2
				, "UInt",  wrapMode
				, "Ptr*",  pBrush := 0)
				
				If (pBrush == 0) {
					this.Base := False  ; Avoid calling __Delete
					Return False
				}
				
				this._pBrush := pBrush
				this._lgMode := "Linear"
			}
			
			
			; Internal value of current gradient mode. Read-only.
			; Can return following values (see .SetMode):
			;   • Linear
			;   • Smooth
			;   • Custom
			;   • Multi
			
			GradientMode {
				Get {
					Return this._lgMode
				}
				Set {
					Return value
				}
			}
			
			
			WrapMode {
				Get {
					Local
					DllCall("GdiPlus\GdipGetLineWrapMode"
					, "Ptr"  , this._pBrush
					, "UInt*", result := -1)
					
					Return result
				}
				Set {
					DllCall("GdiPlus\GdipSetLineWrapMode"
					, "Ptr" , this._pBrush
					, "UInt", value)
					
					Return value
				}
			}
			
			
			; Gamma correction for interpolated colors.
			; By default, colors are blended in the sRGB space, so the average of two colors
			; may be perceived by human eye much darker than any of those colors.
			; With UseGamma = 1 colors will be blended in linear space, then converted back to sRGB.
			; This reduces contrast difference and often is perceived as more 'proper' blend.
			
			UseGamma {
				Get {
					Local
					DllCall("GdiPlus\GdipGetLineGammaCorrection"
					, "Ptr"  , this._pBrush
					, "UInt*", result := -1)
					
					Return result
				}
				Set {
					DllCall("GdiPlus\GdipSetLineGammaCorrection"
					, "Ptr" , this._pBrush
					, "UInt", !!value)
					
					Return value
				}
			}
			
			
			; Returns an array of used colors.
			; For 'Linear', 'Smooth' and 'Custom' mode only two colors are used.
			; You can pass variables to get arrays of positions (places) and weights (factors)
			; for a 'Custom'/'Multi' mode.
			
			GetColors( ByRef placesList := "", ByRef factorsList := "" ) {
				Local
				
				If (this._lgMode == "Multi") {
					DllCall("GdiPlus\GdipGetLinePresetBlendCount"
					, "Ptr" , this._pBrush
					, "Int*", itemsCount)
					
					VarSetCapacity(binColors := "", itemsCount*4, 0)
					VarSetCapacity(binPlaces := "", itemsCount*4, 0)
					
					DllCall("GdiPlus\GdipGetLinePresetBlend"
					, "Ptr",  this._pBrush
					, "Ptr", &binColors
					, "Ptr", &binPlaces
					, "Int",  itemsCount)
					
					colorsList := []
					placesList := []
					
					Loop % itemsCount {
						colorsList.Push( NumGet(binColors, (A_Index-1)*4, "UInt") )
						placesList.Push( NumGet(binPlaces, (A_Index-1)*4, "Float") )
					}
					
					Return colorsList
				}
				
				If (this._lgMode == "Custom")
				&& ( (IsByRef(factorsList) == True)
				||   (IsByRef(placesList)  == True) )
				{
					DllCall("GdiPlus\GdipGetLineBlendCount"
					, "Ptr" , this._pBrush
					, "Int*", itemsCount)
					
					VarSetCapacity(binFactors := "", itemsCount*4, 0)
					VarSetCapacity(binPlaces  := "", itemsCount*4, 0)
					
					DllCall("GdiPlus\GdipGetLineBlend"
					, "Ptr",  this._pBrush
					, "Ptr", &binFactors
					, "Ptr", &binPlaces
					, "Int",  itemsCount)
					
					factorsList := []
					placesList  := []
					
					Loop % itemsCount {
						factorsList.Push( NumGet(binFactors, (A_Index-1)*4, "Float") )
						placesList.Push(  NumGet(binPlaces , (A_Index-1)*4, "Float") )
					}
				}
				
				VarSetCapacity(binBaseColors := "", 4*2, 0)
				
				DllCall("GdiPlus\GdipGetLineColors"
				, "Ptr" ,  this._pBrush
				, "Ptr" , &binBaseColors)
				
				color1 := NumGet(binBaseColors, 0, "UInt")
				color2 := NumGet(binBaseColors, 4, "UInt")
				
				Return [ color1, color2 ]
			}
			
			
			; Sets start and end colors of the gradient.
			; To set multiple colors for 'Multi' mode, use .SetMode method.
			
			SetColors( color1, color2 ) {
				If (this._lgMode == "Multi") {
					this.SetMode("Multi", [color1, color2])
					
				} Else {
					DllCall("GdiPlus\GdipSetLineColors"
					, "Ptr", this._pBrush
					, "UInt", color1
					, "UInt", color2)
				}
				
				Return this
			}
			
			
			; Sets interpolation mode of linear gradient:
			;   > br.SetMode( "Linear" [, focus, scale] )
			;   > br.SetMode( "Smooth" [, focus, scale] )
			;   > br.SetMode( "Custom", factors [, positions] )
			;   > br.SetMode( "Multi" , colors  [, positions] )
			; 
			; 'Linear' mode uses linear interpolation between two base colors.
			; 'Smooth' mode uses sigmoid interpolation between two base colors.
			; 
			; For both 'Linear' and 'Smooth' modes you can specify two arguments:
			;   • focus  - position of the tip of the triangle or the bell-shape.
			;     For example, focus = 0.75 will create ramp-up for 3/4 of the gradient,
			;     then ramp-down for the last quarter of the gradient.
			;     Default is 1, which means only ramp-up for the entire gradient
			;     from the start color to the end color.
			;   
			;   • scale  - influence of the end color on the gradient tip.
			;     For example, scale = 0.5 will blend from start color
			;     only to the average of start and end colors.
			;     Default is 1, which means end color will be fully present in the gradient.
			; 
			; 'Custom' mode also uses two base colors, but interpolates between them
			; using provided arrays of factors and positions. For example, this call:
			;   > br.SetMode( "Custom", [1, 0, 0.5, 0, 1], [0, 0.4, 0.5, 0.6, 1.0] )
			; will create gradient W-shaped gradient - start color at the beginning and the end,
			; ramping full down close to the center, with a peak of average color right in the middle.
			; 
			; 'Multi' mode allows multiple colors to be used, but limited to linear interpolation only.
			; In both 'Custom' and 'Multi' modes if 'positions' argument is omitted,
			; factors/colors will be distributed evenly across the gradient. For example:
			;   > br.SetMode( "Multi", [0xFFFF0000, 0xFF00FF00, 0xFF0000FF] )
			; will create ugly (though mathematically correct) transition between red, green and blue.
			
			SetMode( lgMode, arg1 := 1, arg2 := 1 ) {
				Local
				Global OGdip
				
				If (IsObject(arg1) == True)
				&& (arg1.Length() >= 2)
				&& ( (lgMode = "Multi")
				||   (lgMode = "Custom") )
				{
					; For both "Multi" and "Custom" modes second argument is
					; an array of positions, so we'll deal with it first.
					itemsCount := arg1.Length()
					placesList := this._CreatePlacesList(arg2, itemsCount)
					
					OGdip._CreateBinArray(placesList, binPlaces := "", "Float")
					
					If (lgMode = "Custom") {
						OGdip._CreateBinArray(arg1, binFactors := "", "Float")
						
						DllCall("GdiPlus\GdipSetLineBlend"
						, "Ptr",  this._pBrush
						, "Ptr", &binFactors
						, "Ptr", &binPlaces
						, "Int",  itemsCount)
						
						this._lgMode := "Custom"
						
					} Else {  ; lgMode = "Multi"
						OGdip._CreateBinArray(arg1, binColors := "", "UInt")
						
						DllCall("GdiPlus\GdipSetLinePresetBlend"
						, "Ptr",  this._pBrush
						, "Ptr", &binColors
						, "Ptr", &binPlaces
						, "Int",  itemsCount)
						
						this._lgMode := "Multi"
					}
					
				} Else
				If (lgMode = "Smooth") {
					DllCall("GdiPlus\GdipSetLineSigmaBlend"
					, "Ptr"  , this._pBrush
					, "Float", arg1
					, "Float", arg2)
						
					this._lgMode := "Smooth"
					
				} Else {  ; Fallback to "Linear" mode
					DllCall("GdiPlus\GdipSetLineLinearBlend"
					, "Ptr"  , this._pBrush
					, "Float", arg1
					, "Float", arg2)
						
					this._lgMode := "Linear"
				}
				
				Return this
			}
			
			
			; Transform methods
			
			TransformReset() {
				DllCall("GdiPlus\GdipResetLineTransform"
				, "Ptr", this._pBrush)
				
				Return this
			}
			
			TransformMove( dx, dy, mxOrder := 0 ) {
				DllCall("GdiPlus\GdipTranslateLineTransform"
				, "Ptr"  , this._pBrush
				, "Float", dx
				, "Float", dy
				, "UInt" , mxOrder)
				
				Return this
			}
			
			TransformScale( sx, sy, mxOrder := 0 ) {
				DllCall("GdiPlus\GdipScaleLineTransform"
				, "Ptr"  , this._pBrush
				, "Float", sx
				, "Float", sy
				, "UInt" , mxOrder)
				
				Return this
			}
			
			TransformRotate( angle, mxOrder := 0 ) {
				DllCall("GdiPlus\GdipRotateLineTransform"
				, "Ptr"  , this._pBrush
				, "Float", angle
				, "UInt" , mxOrder)
				
				Return this
			}
			
			TransformRotateAt( cx, cy, angle, mxOrder := 0 ) {
				this.TransformMove(cx, cy)
				this.TransformRotate(angle)
				this.TransformMove(-cx, -cy)
				
				Return this
			}
			
			TransformMatrix( oMatrix, mxOrder := 0 ) {
				DllCall("GdiPlus\GdipMultiplyLineTransform"
				, "Ptr" , this._pBrush
				, "Ptr" , oMatrix._pMatrix
				, "UInt", mxOrder)
				
				Return this
			}
			
			SetTransformMatrix( oMatrix ) {
				DllCall("GdiPlus\GdipSetLineTransform"
				, "Ptr", this._pBrush
				, "Ptr", oMatrix._pMatrix)
				
				Return this
			}
			
			GetTransformMatrix() {
				Local lgMatrix := new OGdip.Matrix()
				
				DllCall("GdiPlus\GdipGetLineTransform"
				, "Ptr", this._pBrush
				, "Ptr", lgMatrix._pMatrix)
				
				Return lgMatrix
			}
		}
		
		
		
		; PathBrush
		; ---------
		; Path gradient brush uses interior area and outline of the Path object
		; to create more complex gradients that LinearBrush.
		; 
		; Constructors:
		;   > br := new OGdip.Brush.PathBrush( oPath [, colors, centerColor] )
		;   > br := new OGdip.Brush.PathBrush( points [, colors, wrapMode] )
		; 
		; Properties:
		;   .GradientMode [Read-only]
		;   .WrapMode
		;   .UseGamma
		; 
		; Methods:
		;   .GetBoundRect()
		;   .GetPointCount()
		;   .GetFocusScales()
		;   .SetFocusScales( fx, fy )
		;   .GetCenterPoint()
		;   .SetCenterPoint( x, y )
		;   .GetCenterColor()
		;   .SetCenterColor( argb )
		;   .GetSurroundColors()
		;   .GetInwardColors( [&placesList] )
		;   .GetColors()
		;   .GetCustomFactors( &factorsList, &placesList )
		;   .SetSurroundColors( colors* )
		;   .SetColors()
		;   .SetMode( pgMode [, arg1, arg2] )
		; 
		; Transform methods:
		;   .TransformReset()
		;   .TransformMove( dx, dy [, mxOrder] )
		;   .TransformScale( sx, sy, [, mxOrder] )
		;   .TransformRotate( angle [, mxOrder] )
		;   .TransformRotateAt( cx, cy, angle [, mxOrder] )
		;   .TransformMatrix( oMatrix [, mxOrder] )
		;   .SetTransformMatrix( oMatrix )
		;   .GetTransformMatrix()
		
		Class PathBrush  Extends  OGdip.Brush {
			
			__New( source, args* ) {
				Local
				Global OGdip
				
				pBrush  := 0
				sColors := [0xFFFFFFFF]
				cColor  :=  0xFF000000
				
				If (IsObject(source) == True)
				&& (source.Base == OGdip.Path)
				{
					DllCall("GdiPlus\GdipCreatePathGradientFromPath"
					, "Ptr" , source._pPath
					, "Ptr*", pBrush)
					
					flatArgs := OGdip._FlattenArray(args)
					
					If (flatArgs.Length() >= 2) {
						cColor  := flatArgs.Pop()
						sColors := flatArgs
					}
					
				} Else
				If (IsObject(source) == True) {
					points := OGdip._FlattenArray(source)
					wrapMode := 0
					
					If (args.Length() > 0)
					&& (IsObject(args[1]) == True)
					{
						flatArg := OGdip._FlattenArray( args.RemoveAt(1) )
						cColor  := flatArg.Pop()
						sColors := flatArg
					}
					
					If (args.Length() > 0) {
						wrapMode := OGdip.Enum.Get("WrapMode", args[1], 0)
					}
					
					OGdip._CreateBinArray(points, binPoints := "", "Float")
					
					DllCall("GdiPlus\GdipCreatePathGradient"
					, "Ptr" , &binPoints
					, "Int" , (points.Length() // 2)
					, "UInt",  wrapMode
					, "Ptr*",  pBrush)
					
				}
				
				If (pBrush == 0) {
					this.Base := False  ; Avoid calling __Delete
					Return False
				}
				
				this._pBrush := pBrush
				this._pgMode := "Linear"
				
				this.SetCenterColor(cColor)
				this.SetColors(sColors)
			}
			
			
			; Internal value of current gradient mode. Read-only.
			; Can return following values (see .SetMode):
			;   • Linear
			;   • Smooth
			;   • Custom
			;   • Inward
			
			GradientMode {
				Get {
					Return this._pgMode
				}
				Set {
					Return value
				}
			}
			
			
			WrapMode {
				Get {
					Local
					DllCall("GdiPlus\GdipGetPathGradientWrapMode"
					, "Ptr"  , this._pBrush
					, "UInt*", result := -1)
					
					Return result
				}
				Set {
					DllCall("GdiPlus\GdipSetPathGradientWrapMode"
					, "Ptr" , this._pBrush
					, "UInt", value)
					
					Return value
				}
			}
			
			
			; See LinearBrush.UseGamma
			
			UseGamma {
				Get {
					Local
					DllCall("GdiPlus\GdipGetPathGradientGammaCorrection"
					, "Ptr"  , this._pBrush
					, "UInt*", result := -1)
					
					Return result
				}
				Set {
					DllCall("GdiPlus\GdipSetPathGradientGammaCorrection"
					, "Ptr" , this._pBrush
					, "UInt", !!value)
					
					Return value
				}
			}
			
			
			; Gets/sets Path object used by PathBrush.
			; Note: GDI+ returns 'NotImplemented' error.
			
			; Path {
			; 	Get {
			; 		DllCall("GdiPlus\GdipGetPathGradientPath", "Ptr", this._pBrush, "Ptr", pPath := 0)
			; 		Return pPath
			; 	}
			; 	Set {
			; 		DllCall("GdiPlus\GdipSetPathGradientPath", "Ptr", this._pBrush, "Ptr", value._pPath)
			; 		Return value
			; 	}
			; }
			
			
			; Gets smallest rectangle that encloses boundary of path used by PathBrush.
			
			GetBoundRect() {
				Local
				
				VarSetCapacity(boundRect := "", 4*4, 0)
				
				DllCall("GdiPlus\GdipGetPathGradientRect"
				, "Ptr",  this._pBrush
				, "Ptr", &boundRect)
				
				boundRect := []
				
				Loop 4 {
					boundRect[A_Index] := NumGet(boundRect, (A_Index-1)*4, "Float")
				}
				
				Return boundRect
			}
			
			
			; Gets number of points in a path used by PathBrush.
			
			GetPointCount() {
				Local
				
				DllCall("GdiPlus\GdipGetPathGradientPointCount"
				, "Ptr" , this._pBrush
				, "Int*", pointCount := -1)
				
				Return pointCount
			}
			
			
			; Gets/sets focus scales.
			; Note: this is not the same as [focus, scale] arguments in .SetMode.
			; Focus scale is a number from that sets the size (relative to path size)
			; of the center color area in certain direction. For example, focus scales [0.25, 1.0]
			; with the circular path will produce "cat's eye" gradient, with center color area
			; being 25% of the width and 100% of the height.
			; Note: focus scales have no effect for multiple surround colors.
			
			GetFocusScales() {
				Local
				
				DllCall("GdiPlus\GdipGetPathGradientFocusScales"
				, "Ptr"   , this._pBrush
				, "Float*", fx := -1
				, "Float*", fy := -1)
				
				Return [ fx, fy ]
			}
			
			SetFocusScales( fx, fy) {
				DllCall("GdiPlus\GdipSetPathGradientFocusScales"
				, "Ptr"  , this._pBrush
				, "Float", fx
				, "Float", fy)
				
				Return this
			}
				
			
			; Gets/sets coordinates of the center point of the path gradient.
			; By default, center point is at the centroid of the path.
			
			GetCenterPoint() {
				Local
				
				VarSetCapacity(binPoint := "", 2*4, 0)
				
				DllCall("GdiPlus\GdipGetPathGradientCenterPoint"
				, "Ptr",  this._pBrush
				, "Ptr", &binPoint)
				
				Return [ NumGet(binPoint, 0, "Float"),  NumGet(binPoint, 4, "Float") ]
			}
			
			SetCenterPoint( x, y ) {
				OGdip._CreateBinArray( [x, y], binPoint := "", "Float" )
				
				DllCall("GdiPlus\GdipSetPathGradientCenterPoint"
				, "Ptr", this._pBrush
				, "Ptr", &binPoint)
				
				Return this
			}
			
			
			; Gets/sets center color of the path gradient.
			; Note: center color have no effect for 'Inward' ('Preset') gradient mode.
			
			GetCenterColor() {
				Local
				
				DllCall("GdiPlus\GdipGetPathGradientCenterColor"
				, "Ptr"  , this._pBrush
				, "UInt*", argb := -1)
				
				Return argb
			}
			
			SetCenterColor( argb ) {
				DllCall("GdiPlus\GdipSetPathGradientCenterColor"
				, "Ptr" , this._pBrush
				, "UInt", argb)
				
				Return this
			}
			
			
			; Gets array of surround or inward colors used by path gradient.
			; For .GetInwardColors you can additionally retrieve array of positions.
			; Using .GetColors() retrieves colors for current mode and usually more convenient.
			
			GetSurroundColors() {
				Local
				
				DllCall("GdiPlus\GdipGetPathGradientSurroundColorCount"
				, "Ptr" , this._pBrush
				, "Int*", colorCount := 0)
				
				VarSetCapacity(binColors := "", colorCount*4, 0)
				
				DllCall("GdiPlus\GdipGetPathGradientSurroundColorsWithCount"
				, "Ptr" ,  this._pBrush
				, "Ptr" , &binColors
				, "Int*",  colorCount)
				
				colorsList := []
				
				Loop % colorCount {
					colorsList[A_Index] := NumGet(binColors, (A_Index-1)*4, "UInt")
				}
				
				Return colorsList
			}
			
			
			GetInwardColors( ByRef placesList := "" ) {
				Local
				
				DllCall("GdiPlus\GdipGetPathGradientPresetBlendCount"
				, "Ptr" , this._pBrush
				, "Int*", colorCount := 0)
				
				VarSetCapacity(binColors := "", colorCount*4, 0)
				VarSetCapacity(binPlaces := "", colorCount*4, 0)
				
				DllCall("GdiPlus\GdipGetPathGradientPresetBlend"
				, "Ptr" ,  this._pBrush
				, "Ptr" , &binColors
				, "Ptr" , &binPlaces
				, "Int*",  colorCount)
				
				colorsList := []
				placesList := []
				
				Loop % colorCount {
					colorsList[A_Index] := NumGet(binColors, (A_Index-1)*4, "UInt")
					placesList[A_Index] := NumGet(binPlaces, (A_Index-1)*4, "Float")
				}
				
				Return colorsList
			}
			
			
			GetColors() {
				Return ((this._pgMode = "Inward")
				?  this.GetInwardColors()
				:  this.GetSurroundColors())
			}
			
			
			; Returns weights (factors) and positions (places) of the gradient.
			; This method applies only to 'Custom' gradient mode.
			; To get positions of colors for 'Inward' gradient mode, use .GetInwardColors method.
			
			GetCustomFactors( ByRef factorsList, ByRef placesList ) {
				Local
				
				DllCall("GdiPlus\GdipGetPathGradientBlendCount"
				, "Ptr" , this._pBrush
				, "Int*", itemCount := 0)
				
				VarSetCapacity(binFactors := "", 4*itemCount, 0)
				VarSetCapacity(binPlaces  := "", 4*itemCount, 0)
				
				DllCall("GdiPlus\GdipGetPathGradientBlend"
				, "Ptr" ,  this._pBrush
				, "Ptr" , &binFactors
				, "Ptr" , &binPlaces
				, "Int" ,  itemCount)
				
				factorsList := []
				placesList  := []
				
				Loop % itemCount {
					factorsList[A_Index] := NumGet(binFactors, (A_Index-1)*4, "Float")
					placesList[A_Index]  := NumGet(binPlaces , (A_Index-1)*4, "Float")
				}
			}
			
			
			; Sets an array of colors for surrounding points of the path gradient.
			; For example, if path is a rectangle, you can pass four colors - one for each corner.
			; If there are more points in the path than provided colors,
			; last color will be used for the rest of the points.
			; For curved or elliptical paths using more than one color may result in rough edges.
			
			SetSurroundColors( colors* ) {
				Local
				Global OGdip
				
				colors := OGdip._FlattenArray(colors)
				
				OGdip._CreateBinArray(colors, binColors := "", "UInt")
				
				DllCall("GdiPlus\GdipSetPathGradientSurroundColorsWithCount"
				, "Ptr" ,  this._pBrush
				, "Ptr" , &binColors
				, "Int*",  colors.Length())
				
				Return this
			}
			
			
			; Sets an array of colors for current gradient mode.
			; Preserves positions for 'Inward' gradient mode.
			
			SetColors( colorsList* ) {
				Local
				Global OGdip
				
				colorsList := OGdip._FlattenArray(colorsList)
				
				If (this._pgMode = "Inward") {
					this.GetInwardColors(placesList := "")
					this.SetMode("Inward", colorsList, placesList)
					
				} Else {
					this.SetSurroundColors(colorsList)
				}
				
				Return this
			}
			
			
			; Sets one of four modes of the path gradient.
			;   > br.SetMode( "Linear" [, focus, scale] )
			;   > br.SetMode( "Smooth" [, focus, scale] )
			;   > br.SetMode( "Custom" , factors [, positions] )
			;   > br.SetMode( "Inward" , colors  [, positions] )
			; See LinearBrush.SetMode for description of the first three modes.
			; 
			; Last mode, 'Inward', is similar to both LinearBrush's 'Multi' mode
			; and 'Custom' path gradient mode. Instead of colors being assigned
			; to the outline points of the path, they are interpolated
			; from path's outline to the center point.
			; 
			; When converting from the 'Inward' mode to any of the first three,
			; colors used in 'Inward' mode will be transferred to the new mode:
			; last of used colors will become the color of the center,
			; rest of used colors will become surround colors.
			
			SetMode( pgMode, arg1 := 1, arg2 := 1 ) {
				Local
				Global OGdip
				
				If (this._pgMode = "Inward")
				&& (Not (pgMode = "Inward"))
				{
					prevColorsList := this.GetInwardColors()
					
					this.SetCenterColor(prevColorsList.Pop())
					this.SetSurroundColors(prevColorsList)
				}
				
				If (pgMode = "Inward") {
					If (IsObject(arg1) == True)
					&& (IsObject(arg2) == True)
					{
						itemCount  := arg1.Length()
						colorsList := arg1
						placesList := this._CreatePlacesList(arg2, itemCount)
						
					} Else {
						If (this._pgMode = "Inward") {
							; Keep positions of colors
							colorsList := this.GetInwardColors( placesList := "" )
							
						} Else {
							colorsList := this.GetSurroundColors()
							colorsList.Push( this.GetCenterColor() )
							placesList := ""
						}
						
						itemCount  := colorsList.Length()
						
						placesList := (IsObject(arg1) == True)
						?  this._CreatePlacesList(arg1, itemCount)
						:  this._CreatePlacesList(placesList, itemCount)
					}
					
					OGdip._CreateBinArray(colorsList, binColors := "", "UInt")
					OGdip._CreateBinArray(placesList, binPlaces := "", "Float")
					
					DllCall("GdiPlus\GdipSetPathGradientPresetBlend"
					, "Ptr",  this._pBrush
					, "Ptr", &binColors
					, "Ptr", &binPlaces
					, "Int",  itemCount)
					
					this._pgMode := "Inward"
					
				} Else
				If (pgMode = "Custom") {
					If (IsObject(arg1) == True)
					&& (IsObject(arg2) == True)
					{
						factorsList := arg1
						placesList  := arg2
						
					} Else {

						this.GetCustomFactors( factorsList := "", placesList := "" )
						
						If (IsObject(arg1) == True)
							factorsList := arg1
					}
					
					itemCount  := factorsList.Length()
					placesList := this._CreatePlacesList(placesList, itemCount)
					
					OGdip._CreateBinArray(factorsList, binFactors := "", "Float")
					OGdip._CreateBinArray(placesList , binPlaces  := "", "Float")
					
					DllCall("GdiPlus\GdipSetPathGradientBlend"
					, "Ptr", this._pBrush
					, "Ptr", binFactors
					, "Ptr", binPlaces
					, "Int", itemCount)
					
					this._pgMode := "Custom"
				
				} Else
				If (pgMode = "Smooth") {
					DllCall("GdiPlus\GdipSetPathGradientSigmaBlend"
					, "Ptr"  , this._pBrush
					, "Float", arg1
					, "Float", arg2)
					
					this._pgMode := "Smooth"
					
				} Else {
					DllCall("GdiPlus\GdipSetPathGradientLinearBlend"
					, "Ptr"  , this._pBrush
					, "Float", arg1
					, "Float", arg2)
					
					this._pgMode := "Linear"
				}
				
				Return this
			}
			
			
			; Transform methods
			
			TransformReset() {
				DllCall("GdiPlus\GdipResetPathGradientTransform"
				, "Ptr", this._pBrush)
				
				Return this
			}
			
			TransformMove( dx, dy, mxOrder := 0 ) {
				DllCall("GdiPlus\GdipTranslatePathGradientTransform"
				, "Ptr"  , this._pBrush
				, "Float", dx
				, "Float", dy
				, "UInt" , mxOrder)
				
				Return this
			}
			
			TransformScale( sx, sy, mxOrder := 0 ) {
				DllCall("GdiPlus\GdipScalePathGradientTransform"
				, "Ptr"  , this._pBrush
				, "Float", sx
				, "Float", sy
				, "UInt" , mxOrder)
				
				Return this
			}
			
			TransformRotate( angle, mxOrder := 0 ) {
				DllCall("GdiPlus\GdipRotatePathGradientTransform"
				, "Ptr"  , this._pBrush
				, "Float", angle
				, "UInt" , mxOrder)
				
				Return this
			}
			
			TransformRotateAt( angle, cx, cy, mxOrder := 0 ) {
				this.TransformMove(cx, cy)
				this.TransformRotate(angle)
				this.TransformMove(-cx, -cy)
				
				Return this
			}
			
			TransformMatrix( oMatrix, mxOrder := 0 ) {
				DllCall("GdiPlus\GdipMultiplyPathGradientTransform"
				, "Ptr" , this._pBrush
				, "Ptr" , oMatrix._pMatrix
				, "UInt", mxOrder)
				
				Return this
			}
			
			SetTransformMatrix( oMatrix ) {
				DllCall("GdiPlus\GdipSetPathGradientTransform"
				, "Ptr", this._pBrush
				, "Ptr", oMatrix._pMatrix)
				
				Return this
			}
			
			GetTransformMatrix() {
				Local pgMatrix := new OGdip.Matrix()
				
				DllCall("GdiPlus\GdipGetPathGradientTransform"
				, "Ptr", this._pBrush
				, "Ptr", pgMatrix._pMatrix)
				
				Return pgMatrix
			}
		}
	}
	
	
	
	; Region class
	; ============
	; 
	; Region is a custom shaped area of the display surface.
	; Regions are used to clipping and hit-testing.
	; 
	; Constructors:
	;   > rgn := new OGdip.Region()                                 ; Create infinite region
	;   > rgn := new OGdip.Region( oRegion )                        ; Clone existing Region object
	;   > rgn := new OGdip.Region( oPath )                          ; Create region from Path object
	;   > rgn := new OGdip.Region( x, y, w, h )                     ; Create rectangular region
	;   > rgn := new OGdip.Region( "*HRGN", hRegion )               ; Create region from GDI HRGN
	;   > rgn := new OGdip.Region( "*RGNDATA", dataPtr, dataSize )  ; Create region from byte data
	; 
	; Methods:
	;   .GetHRGN( oGraphics )
	;   .GetData( &rgnData, &rgnDataSize )
	;   .GetBounds( oGraphics )
	;   .GetScans( oMatrix )
	;   .Move( dx, dy )
	;   .Transform( oMatrix )
	;   .Combine( target [, combineMode] )
	;   .SetInfinite()
	;   .SetEmpty()
	;   .IsInfinite( oGraphics )
	;   .IsEmpty( oGraphics )
	;   .IsEqual( oRegion, oGraphics )
	;   .IsVisible( x, y [, w, h][, oGraphics] )
	
	
	Class Region {
		
		__New( source := "", args* ) {
			Local
			Global OGdip
			
			pRegion := 0
			
			If (source == "") {
				DllCall("GdiPlus\GdipCreateRegion"
				, "Ptr*", pRegion)
				
			} Else
			If (IsObject(source) == True)
			&& (source.Base == OGdip.Region)
			{
				DllCall("GdiPlus\GdipCloneRegion"
				, "Ptr" , source._pRegion
				, "Ptr*", pRegion)
				
			} Else
			If (IsObject(source) == True)
			&& (source.Base == OGdip.Path) {
				DllCall("GdiPlus\GdipCreateRegionPath"
				, "Ptr" , source._pPath
				, "Ptr*", pRegion)
				
			} Else
			If (source == "*HRGN") {
				DllCall("GdiPlus\GdipCreateRegionHrgn"
				, "Ptr" , args[1]  ; HRGN handle
				, "Ptr*", pRegion)
				
			} Else
			If (source == "*RGNDATA") {
				DllCall("GdiPlus\GdipCreateRegionRgnData"
				, "Ptr" , args[1]  ; BYTE* regionData
				, "Int" , args[2]  ; INT   size
				, "Ptr*", pRegion)
				
			} Else {
				srcRect := OGdip._FlattenArray( [source, args*] )
				
				If (srcRect.Length() < 4) {
					this.Base := False  ; Avoid calling __Delete
					Return False
				}
				
				OGdip._CreateBinArray(srcRect, binRect := "", "Float")
				
				DllCall("GdiPlus\GdipCreateRegionRect"
				, "Ptr" , &binRect
				, "Ptr*",  pRegion)
			}
				
			If (pRegion == 0) {
				this.Base := False  ; Avoid calling __Delete
				Return False
			}
			
			this._pRegion := pRegion
		}
		
		
		__Delete() {
			DllCall("GdiPlus\GdipDeleteRegion"
			, "Ptr", this._pRegion)
		}
		
		
		; Creates GDI HRGN handle to the region.
		; Pass Graphics object that contains world and page transformations
		; required to calculate the device coordinates of this region.
		
		GetHRGN( oGraphics ) {
			Local
			
			DllCall("GdiPlus\GdipGetRegionHRgn"
			, "Ptr" , this._pRegion
			, "Ptr" , oGraphics._pGraphics
			, "Ptr*", pHRGN := 0)
			
			Return pHRGN
		}
		
		
		; Gets binary data that describes this region.
		
		GetData( ByRef rgnData, ByRef rgnDataSize ) {
			Local
			
			DllCall("GdiPlus\GdipGetRegionDataSize"
			, "Ptr"  , this._pRegion
			, "UInt*", rgnBufferSize := 0)
			
			VarSetCapacity(rgnData, rgnBufferSize, 0)
			
			DllCall("GdiPlus\GdipGetRegionData"
			, "Ptr"  ,  this._pRegion
			, "Ptr"  , &rgnData
			, "UInt" ,  rgnBufferSize
			, "UInt*",  rgnDataSize)
		}
		
		
		; Gets a rectangle that encloses this region.
		; Pass Graphics object that contains world and page transformations
		; required to calculate the device coordinates of this region.
		; Note: returned rectangle isn't always the smallest possible rectangle.
		
		GetBounds( oGraphics ) {
			Local
			
			VarSetCapacity(outRect := "", 4*4, 0)
			
			DllCall("GdiPlus\GdipGetRegionBounds"
			, "Ptr" ,  this._pRegion
			, "Ptr" ,  oGraphics._pGraphics
			, "Ptr" , &outRect)
			
			rectResult := []
			
			Loop 4 {
				rectResult.Push( NumGet(outRect, (A_Index-1)*4, "Float") )
			}
		}
		
		
		; Returns an array of rectangles that approximate this region.
		; Optional Matrix transformation may be applied beforehand.
		
		GetScans( oMatrix := 0 ) {
			Local
			Global OGdip
			
			If (IsObject(oMatrix) == False)
			|| (oMatrix.Base != OGdip.Matrix)
			{
				oMatrix := new OGdip.Matrix()
			}
			
			pMatrix := oMatrix._pMatrix
			
			DllCall("GdiPlus\GdipGetRegionScansCount"
			, "Ptr"  , this._pRegion
			, "UInt*", scansCount := 0
			, "Ptr"  , pMatrix)
			
			VarSetCapacity(rectArray := "", (scansCount * 4 * 4), 0)
			
			DllCall("GdiPlus\GdipGetRegionScans"
			, "Ptr" ,  this._pRegion
			, "Ptr" , &rectArray
			, "Int*",  scansCount
			, "Ptr" ,  pMatrix)
			
			rectList := []
			offset := 0
			
			Loop % scansCount {
				rectItem := []
				
				Loop 4 {
					rectItem.Push( NumGet(rectArray, offset, "Float") )
					offset += 4
				}
				
				rectList.Push(rectItem)
			}
			
			Return rectList
		}
		
		
		; Translates region by given amount of units.
		
		Move( dx, dy ) {
			DllCall("GdiPlus\GdipTranslateRegion"
			, "Ptr"  , this._pRegion
			, "Float", dx
			, "Float", dy)
			
			Return this
		}
		
		
		; Transforms region with given Matrix object.
		
		Transform( oMatrix ) {
			DllCall("GdiPlus\GdipTransformRegion"
			, "Ptr", this._pRegion
			, "Ptr", oMatrix._pMatrix)
			
			Return this
		}
		
		
		; Combines region with given target.
		;   > rgn.Combine(  x, y, w, h , mode )
		;   > rgn.Combine( [x, y, w, h], mode )
		;   > rgn.Combine( oPath, mode )
		;   > rgn.Combine( oRegion, mode )
		; See OGdip.Enum.CombineMode for 'mode' argument.
		; Default combine mode is union (add).
		
		Combine( args* ) {
			Local
			Global OGdip
			
			combineMode := 2
			
			If (args.Length() == 5)           ; Case (x,y,w,h, mode)
			|| ( (IsObject(args[1]) == True)  ; Case (rect|path|region, mode)
			||   (args.Length() == 2) )
			{
				combineMode := OGdip.Enum.Get("CombineMode", args.Pop(), 2)
			}
			
			firstArg := args[1]
			
			If (IsObject(firstArg) == True)
			&& (firstArg.Base == OGdip.Region)
			{
				DllCall("GdiPlus\GdipCombineRegionRegion"
				, "Ptr" , this._pRegion
				, "Ptr" , firstArg._pRegion
				, "UInt", combineMode)
				
			} Else
			If (IsObject(firstArg) == True)
			&& (firstArg.Base == OGdip.Path)
			{
				DllCall("GdiPlus\GdipCombineRegionPath"
				, "Ptr" , this._pRegion
				, "Ptr" , firstArg._pPath
				, "UInt", combineMode)
				
			} Else {
				srcRect := IsObject(firstArg)  ?  firstArg  :  args
				
				OGdip._CreateBinArray(srcRect, binRect := "", "Float")
				
				DllCall("GdiPlus\GdipCombineRegionRect"
				, "Ptr" ,  this._pRegion
				, "Ptr" , &binRect
				, "UInt",  combineMode)
			}
			
			Return this
		}
		
		
		; Sets region to infinite/empty.
		; Checks if region is infinite/empty.
		
		SetInfinite() {
			DllCall("GdiPlus\GdipSetInfinite"
			, "Ptr", this._pRegion)
			
			Return this
		}
		
		
		SetEmpty() {
			DllCall("GdiPlus\GdipSetEmpty"
			, "Ptr", this._pRegion)
			
			Return this
		}
		
		; I have no idea why we need a Graphics here.
		; Is there, like, another type of infinity I'm not aware of?
		
		IsInfinite( oGraphics ) {
			Local
			
			DllCall("GdiPlus\GdipIsInfiniteRegion"
			, "Ptr"  , this._pRegion
			, "Ptr"  , oGraphics._pGraphics
			, "UInt*", result := 0)
			
			Return result
		}
		
		
		IsEmpty( oGraphics ) {
			Local
			
			DllCall("GdiPlus\GdipIsEmptyRegion"
			, "Ptr"  , this._pRegion
			, "Ptr"  , oGraphics._pGraphics
			, "UInt*", result := 0)
			
			Return result
		}
		
		
		; Checks if this region equals another region.
		
		IsEqual( oRegion, oGraphics ) {
			Local
			
			DllCall("GdiPlus\GdipIsEqualRegion"
			, "Ptr"  , this._pRegion
			, "Ptr"  , oRegion._pRegion
			, "Ptr"  , oGraphics._pGraphics
			, "UInt*", result := 0)
			
			Return result
		}
		
		
		; Checks if point or rectangle is inside the region.
		;   > rgn.IsVisible( x, y [, w, h][, oGraphics] )
		
		IsVisible( args* ) {
			Local
			Global OGdip
			
			pGraphics := 0
			
			If (args.Length() == 3)
			|| (args.Length() == 5)
			{
				oGraphics := args.Pop()
				
				If (IsObject(oGraphics) == True)
				&& (oGraphics.Base == OGdip.Graphics)
				{
					pGraphics := oGraphics._pGraphics
				}
			}
			
			If (args.Length() == 2) {
				DllCall("GdiPlus\GdipIsVisibleRegionPoint"
				, "Ptr"  , this._pRegion
				, "Float", args[1]  ; x
				, "Float", args[2]  ; y
				, "Ptr"  , pGraphics
				, "UInt*", result := 0)
				
			} Else {
				rect := IsObject(args[1])  ?  args[1]  :  args
				
				DllCall("GdiPlus\GdipIsVisibleRegionRect"
				, "Ptr"  , this._pRegion
				, "Float", rect[1]  ; x
				, "Float", rect[2]  ; y
				, "Float", rect[3]  ; w
				, "Float", rect[4]  ; h
				, "Ptr"  , pGraphics
				, "UInt*", result := 0)
			}
			
			Return result
		}
	}
	
	
	; Matrix class
	; ============
	; 
	; Constructors:
	;   > mx := new OGdip.Matrix()                         ; Create identity matrix
	;   > mx := new OGdip.Matrix( m11,m12,m21,m22,dx,dy )  ; Create matrix from given values
	;   > mx := new OGdip.Matrix( matrixValues[6] )        ; Create matrix from an array of values
	;   > mx := new OGdip.Matrix( oMatrix )                ; Clone existing matrix
	; 
	; GDI+ stores matrix elements in row order, as you see in the second constructor.
	; However, some people (me) prefer column order over row order: m11,m21,dx, m12,m22,dy.
	; If you prefer this notation too, set OGdip.Matrix.useColumns := True. If you don't - don't.
	; This option affects order of the elements when creating, setting and getting these elements.
	; 
	; If you are going to use this class, I assume you already know what you're doing.
	; Therefore only some methods have descriptive comments.
	; 
	; Methods:
	;   .SetElements( m11,m12,m21,m22,dx,dy )
	;   .GetElements()
	;   .Multiply( oMatrix [, mxOrder] )
	;   .Translate( dx, dy [, mxOrder] )
	;   .Scale( sx, sy [, mxOrder] )
	;   .Rotate( angle [, mxOrder] )
	;   .RotateAt( cx, cy, angle [, mxOrder] )
	;   .Shear( hx, hy [, mxOrder] )
	;   .Invert()
	;   .IsInvertible()
	;   .IsIdentity()
	;   .IsEqual( oMatrix )
	;   .TransformPoints( points* )
	;   .TransformVectors( vectors* )
	
	Class Matrix {
		Static useColumns := False
		
		__New( args* ) {
			Local
			Global OGdip
			
			pMatrix  := 0
			firstArg := args[1]
			
			If (IsObject(firstArg) == True)
			&& (firstArg.Base == OGdip.Matrix)
			{
				DllCall("GdiPlus\GdipCloneMatrix"
				, "Ptr" , firstArg._pMatrix
				, "Ptr*", pMatrix)
				
			} Else {
				mxElems := IsObject(firstArg) ? firstArg : args
				
				If (mxElems.Length() == 6) {
					DllCall("GdiPlus\GdipCreateMatrix2"
					, "Float", mxElems[ this.useColumns ? 1 : 1 ]
					, "Float", mxElems[ this.useColumns ? 3 : 2 ]
					, "Float", mxElems[ this.useColumns ? 5 : 3 ]
					, "Float", mxElems[ this.useColumns ? 2 : 4 ]
					, "Float", mxElems[ this.useColumns ? 4 : 5 ]
					, "Float", mxElems[ this.useColumns ? 6 : 6 ]
					, "Ptr*" , pMatrix)
					
				} Else {
					DllCall("GdiPlus\GdipCreateMatrix"
					, "Ptr*" , pMatrix)
				}
			}
				
			If (pMatrix == 0) {
				this.Base := False  ; Avoid calling __Delete
				Return False
			}
			
			this._pMatrix := pMatrix
		}
		
		
		__Delete() {
			DllCall("GdiPlus\GdipDeleteMatrix"
			, "Ptr", this._pMatrix)
		}
		
		
		SetElements( args* ) {
			Local mxElems := OGdip._FlattenArray(args)
			
			If (mxElems.Length() != 6)
				Return this
			
			DllCall("GdiPlus\GdipSetMatrixElements"
			, "Ptr", this._pMatrix
			, "Float", mxElems[ this.useColumns ? 1 : 1 ]
			, "Float", mxElems[ this.useColumns ? 3 : 2 ]
			, "Float", mxElems[ this.useColumns ? 5 : 3 ]
			, "Float", mxElems[ this.useColumns ? 2 : 4 ]
			, "Float", mxElems[ this.useColumns ? 4 : 5 ]
			, "Float", mxElems[ this.useColumns ? 6 : 6 ])
			
			Return this
		}
		
		
		GetElements() {
			Local
			
			VarSetCapacity(binMxElems := "", 6*4, 0)
			
			DllCall("GdiPlus\GdipGetMatrixElements"
			, "Ptr",  this._pMatrix
			, "Ptr", &binMxElems)
			
			elemArray := []
			elemIndex := this.useColumns ? [1,4,2,5,3,6] : [1,2,3,4,5,6]
			
			Loop 6 {
				elemArray[ elemIndex[A_Index] ] := NumGet(binMxElems, (A_Index-1)*4, "Float")
			}
			
			Return elemArray
		}
		
		
		Multiply( oMatrix, mxOrder := 0 ) {
			If (IsObject(oMatrix) == False)
				Return this
			
			If (oMatrix.Base != OGdip.Matrix) {
				oMatrix := new OGdip.Matrix(oMatrix)
			}
			
			DllCall("GdiPlus\GdipMultiplyMatrix"
			, "Ptr" , this._pMatrix
			, "Ptr" , oMatrix._pMatrix
			, "UInt", mxOrder)
			
			Return this
		}
		
		Translate( dx, dy, mxOrder := 0 ) {
			DllCall("GdiPlus\GdipTranslateMatrix"
			, "Ptr"  , this._pMatrix
			, "Float", dx
			, "Float", dy
			, "UInt" , mxOrder)
			
			Return this
		}
		
		Scale( sx, sy, mxOrder := 0 ) {
			DllCall("GdiPlus\GdipScaleMatrix"
			, "Ptr"  , this._pMatrix
			, "Float", sx
			, "Float", sy
			, "UInt" , mxOrder)
			
			Return this
		}
		
		Rotate( angle, mxOrder := 0 ) {
			DllCall("GdiPlus\GdipRotateMatrix"
			, "Ptr"  , this._pMatrix
			, "Float", angle
			, "UInt" , mxOrder)
			
			Return this
		}
		
		RotateAt( cx, cy, angle, mxOrder := 0 ) {
			this.Translate(cx, cy, mxOrder)
			this.Rotate(angle, mxOrder)
			this.Translate(-cx, -cy, mxOrder)
			
			Return this
		}
		
		Shear( hx, hy, mxOrder := 0 ) {
			DllCall("GdiPlus\GdipShearMatrix"
			, "Ptr"  , this._pMatrix
			, "Float", hx
			, "Float", hy
			, "UInt" , mxOrder)
			
			Return this
		}
		
		Invert() {
			DllCall("GdiPlus\GdipInvertMatrix"
			, "Ptr" , this._pMatrix)
			
			Return this
		}
		
		
		IsInvertible() {
			Local
			
			DllCall("GdiPlus\GdipIsMatrixInvertible"
			, "Ptr"  , this._pMatrix
			, "UInt*", result := 0)
			
			Return result
		}
		
		IsIdentity() {
			Local
			
			DllCall("GdiPlus\GdipIsMatrixIdentity"
			, "Ptr"  , this._pMatrix
			, "UInt*", result := 0)
			
			Return result
		}
		
		IsEqual( oMatrix ) {
			Local result := 0
			
			If (IsObject(oMatrix) == False)
			|| (oMatrix.Base != OGdip.Matrix)
			{
				Return False
			}
			
			DllCall("GdiPlus\GdipIsMatrixEqual"
			, "Ptr"  , this._pMatrix
			, "Ptr"  , oMatrix._pMatrix
			, "UInt*", result)
			
			Return result
		}
		
		
		; Applies matrix transformation to the given points.
		; Returns an array of coordinate pairs of transformed points.
		; Arguments can be any mix of coordinate pairs and arrays of coordinate pairs.
		
		TransformPoints( points* ) {
			Local
			Global OGdip
			
			points := OGdip._FlattenArray(points)
			pointsCount := points.Length() // 2
			
			OGdip._CreateBinArray(points, binPoints := "", "Float")
			
			DllCall("GdiPlus\GdipTransformMatrixPoints"
			, "Ptr" ,  this._pMatrix
			, "Ptr" , &binPoints
			, "Int" ,  pointsCount)
			
			retPoints := []
			
			Loop % pointsCount * 2 {
				retPoints.Push(NumGet(binPoints, (A_Index-1)*4, "Float"))
			}
			
			Return retPoints
		}
		
		
		; Same as .TransformPoints method, but points are treated as vectors.
		; This means that given coordinates may be scaled and rotated but not translated.
		
		TransformVectors( vectors* ) {
			vectors := OGdip._FlattenArray(vectors)
			vectorsCount := vectors.Length() // 2
			
			OGdip._CreateBinArray(vectors, binVectors := "", "Float")
			
			DllCall("GdiPlus\GdipVectorTransformMatrixPoints"
			, "Ptr" ,  this._pMatrix
			, "Ptr" , &binVectors
			, "Int" ,  vectorsCount)
			
			retVectors := []
			
			Loop % vectorsCount * 2 {
				retVectors.Push(NumGet(binVectors, (A_Index-1)*4, "Float"))
			}
			
			Return retVectors
		}
	}
}