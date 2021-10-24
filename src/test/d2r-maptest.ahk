#Include %A_ScriptDir%\classMemory.ahk

if (_ClassMemory.__Class != "_ClassMemory")
{
	msgbox class memory not correctly installed. Or the (global class) variable "_ClassMemory" has been overwritten
	ExitApp
}

d2r := new _ClassMemory("ahk_exe D2R.exe", "", hProcessCopy) 

if !isObject(d2r) 
{
	ExitApp
}

; change the offset here to test a new read()

startingAddress := d2r.BaseAddress + 0x2027a50
playerUnit := d2r.read(startingAddress, "Int64")

; get the map seed
pAct := playerUnit + 0x20
actAddress := d2r.read(pAct, "Int64")
mapSeedAddress := actAddress + 0x14
mapSeed := d2r.read(mapSeedAddress, "UInt")

; get the level number
pPathAddress := playerUnit + 0x38
pPath := d2r.read(pPathAddress, "Int64")
pRoom1 := pPath + 0x20
pRoom1Address := d2r.read(pRoom1, "Int64")
pRoom2 := pRoom1Address + 0x18
pRoom2Address := d2r.read(pRoom2, "Int64")
pLevel := pRoom2Address + 0x90
pLevelAddress := d2r.read(pLevel, "Int64")
dwLevelNo := pLevelAddress + 0x1F8
levelNo := d2r.read(dwLevelNo, "UInt")

; TODO: get difficulty

SetFormat Integer, H
mapSeed += 0
msg := "MapSeed: " . mapSeed
SetFormat Integer, D
mapSeed += 0
msg := msg . " (" . mapSeed . ")`n" . "Level No: " . levelNo
msgbox % msg