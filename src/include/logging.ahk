#SingleInstance, Force
SendMode Input
SetWorkingDir, %A_ScriptDir%
WriteLog(text) {
	FileAppend, % A_NowUTC ": " text "`n", log.txt ; can provide a full path to write to another directory
}