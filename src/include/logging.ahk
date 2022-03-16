global timestamps := []
global perfdata := []

WriteLog(text) {
	FormatTime, vDate,, yyyy-MM-dd HH-mm-ss ;24-hour
	FileAppend, % vDate ": " text "`n", log.txt ; can provide a full path to write to another directory
}

WriteLogDebug(text) {
	if (debug == "true" or debug == 1) {
		FormatTime, vDate,, yyyy-MM-dd HH-mm-ss ;24-hour
		FileAppend, % vDate ": DEBUG: " text "`n", log.txt ; can provide a full path to write to another directory
	}
}


timeStamp(name) {
	DllCall("QueryPerformanceCounter", "Int64P", timestamp)
	if (timestamps[name]) {
		duration := timestamp - timestamps[name]
		;OutputDebug, % name "," duration "`n"
		perfdata.push({"name": name, "duration": duration})
		
		timestamps[name] := 0
	} else {
		timestamps[name] := timestamp
	}
}	