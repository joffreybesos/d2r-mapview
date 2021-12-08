#SingleInstance, Force
SendMode Input
SetWorkingDir, %A_ScriptDir%

WriteLog(text) {
	FormatTime, vDate,, yyyy-MM-dd HH-mm-ss ;24-hour
	FileAppend, % vDate ": " text "`n", log.txt ; can provide a full path to write to another directory
}

WriteLogDebug(text) {
	if (debug == "true") {
		FormatTime, vDate,, yyyy-MM-dd HH-mm-ss ;24-hour
		FileAppend, % vDate ": DEBUG: " text "`n", log.txt ; can provide a full path to write to another directory
	}
}

WriteTimedLog() {
	if (gameStartTime > 0) {
		SetFormat Integer, D
		gameStartTime += 0
		ElapsedSeconds := (A_TickCount - gameStartTime)/1000.0
		FormatTime, vDate,, yyyy-MM-dd HH-mm-ss ;24-hour
		WriteLog("STOPWATCH: Game session duration: " ElapsedSeconds)
	}
}