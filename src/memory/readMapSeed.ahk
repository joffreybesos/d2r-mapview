
calculateMapSeed(InitSeedHash1, InitSeedHash2, EndSeedHash1) {
	WriteLog("Calculating new map seed from " InitSeedHash1 " " InitSeedHash2 " " EndSeedHash1)
	mapSeed := DllCall("SeedGenerator.dll\GetSeed", "UInt", InitSeedHash1, "UInt", InitSeedHash2, "UInt", EndSeedHash1, "UInt", "0", "UInt")
	WriteLog("Found mapSeed " mapSeed)
	return mapSeed
}
