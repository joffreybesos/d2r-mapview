#MaxMem 256

; create JSON data for a single map maps for a given seed/difficulty
generateMapData(ByRef seed, ByRef difficulty, ByRef mapId) {
    cmd := exePath " """ d2path """ --seed " seed " --difficulty " difficulty " --map " mapId
    response := StdOutToVar(cmd)
    levelData := 
    Loop, parse, response, `n, `r
    {
        if (SubStr(A_LoopField, 1, 7) == "{""type""") {
            levelData := A_LoopField
        }
    }
    return levelData
}

; ; create all JSON data for all maps for a given seed/difficulty
; generateAllMapData(ByRef seed, ByRef difficulty) {
;     cmd := exePath " """ d2path """ --seed " seed " --difficulty " difficulty
;     response := StdOutToVar(cmd)
; 	levels := []
;     Loop, parse, response, `n, `r
;     {
;         if (SubStr(A_LoopField, 1, 7) == "{""type""") {
;             levels.push(A_LoopField)
;         }
;     }
;     return levels
; }

; create all JSON data for all maps for a given seed/difficulty
generateAllMapData(ByRef seed, ByRef difficulty) {
	Loop, 136
	{
		filename := seed "_" difficulty "_" A_Index ".json"
		cmd := exePath " """ d2path """ --seed " seed " --difficulty " difficulty " --map " A_Index " > " A_Temp "\" filename
		Run, %comspec% /c %cmd%,,hide
	}
}

; runs a command and captures stdout without flashing a cmd window
StdOutToVar(cmd) {
	DllCall("CreatePipe", "PtrP", hReadPipe, "PtrP", hWritePipe, "Ptr", 0, "UInt", 0)
	DllCall("SetHandleInformation", "Ptr", hWritePipe, "UInt", 1, "UInt", 1)

	VarSetCapacity(PROCESS_INFORMATION, (A_PtrSize == 4 ? 16 : 24), 0)    ; http://goo.gl/dymEhJ
	cbSize := VarSetCapacity(STARTUPINFO, (A_PtrSize == 4 ? 68 : 104), 0) ; http://goo.gl/QiHqq9le
	NumPut(cbSize, STARTUPINFO, 0, "UInt")                                ; cbSize
	NumPut(0x100, STARTUPINFO, (A_PtrSize == 4 ? 44 : 60), "UInt")        ; dwFlags
	NumPut(hWritePipe, STARTUPINFO, (A_PtrSize == 4 ? 60 : 88), "Ptr")    ; hStdOutput
	NumPut(hWritePipe, STARTUPINFO, (A_PtrSize == 4 ? 64 : 96), "Ptr")    ; hStdError
	
	if !DllCall(
	(Join Q C
		"CreateProcess",             ; http://goo.gl/9y0gw
		"Ptr",  0,                   ; lpApplicationName
		"Ptr",  &cmd,                ; lpCommandLine
		"Ptr",  0,                   ; lpProcessAttributes
		"Ptr",  0,                   ; lpThreadAttributes
		"UInt", true,                ; bInheritHandles
		"UInt", 0x08000000,          ; dwCreationFlags
		"Ptr",  0,                   ; lpEnvironment
		"Ptr",  0,                   ; lpCurrentDirectory
		"Ptr",  &STARTUPINFO,        ; lpStartupInfo
		"Ptr",  &PROCESS_INFORMATION ; lpProcessInformation
	)) {
		DllCall("CloseHandle", "Ptr", hWritePipe)
		DllCall("CloseHandle", "Ptr", hReadPipe)
		return ""
	}

	DllCall("CloseHandle", "Ptr", hWritePipe)
	VarSetCapacity(buffer, 4096, 0)
	while DllCall("ReadFile", "Ptr", hReadPipe, "Ptr", &buffer, "UInt", 4096, "UIntP", dwRead, "Ptr", 0)
		sOutput .= StrGet(&buffer, dwRead, "CP0")

	DllCall("CloseHandle", "Ptr", NumGet(PROCESS_INFORMATION, 0))         ; hProcess
	DllCall("CloseHandle", "Ptr", NumGet(PROCESS_INFORMATION, A_PtrSize)) ; hThread
	DllCall("CloseHandle", "Ptr", hReadPipe)
	return sOutput
}