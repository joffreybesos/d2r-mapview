#SingleInstance, Force
SendMode Input
SetWorkingDir, %A_ScriptDir%



prefetchMaps(settings, gameMemoryData) {
    
    baseUrl:= settings["baseUrl"]
    t := settings["wallThickness"] + 0.0
    if (t > 5)
        t := 5
    if (t < 1)
        t := 1

    prefetchUrl := baseUrl . "/v1/map/prefetch"
 
    mapIds := calculateLevel(gameMemoryData["levelNo"])

    requestBody := "{""seed"": """ gameMemoryData["mapSeed"] ""","
    requestBody := requestBody """difficulty"": """ gameMemoryData["difficulty"] ""","
    requestBody := requestBody """mapIds"": [" mapIds "],"
    requestBody := requestBody """wallthickness"": """ t ""","

    requestBody := requestBody """centerServerScale"": """ settings["serverScale"] ""","
    requestBody := requestBody """serverScale"": ""2"","
        edges := "false"
    if (settings["edges"])
        edges := "true"
    requestBody := requestBody """edge"": """ edges """}"

    
    try {
        whr := ComObjCreate("WinHttp.WinHttpRequest.5.1")
        WinHttpReq.SetTimeouts("1", "1", "1", "1")
        whr.Open("POST", prefetchUrl, false)
        whr.SetRequestHeader("Content-Type", "application/json")
        whr.Send(requestBody)
        whr.WaitForResponse()
    } catch e {
        ; fail silently
    }

    WriteLog("Prefetching map images: " requestBody)

}


calculateLevel(currentLevel) {
    allWPs := "1,3,5,6,27,28,29,32,35,40,42,43,45,46,48,74,75,78,79,80,81,83,101,103,105,107,109,111,112,113,115,118,121,123,129"
    switch (currentLevel) {
        case 1: return "1,2,4,83,39"
        case 2: return "3,8"
        case 3: return "4,2,17"
        case 4: return "38,5,3"
        case 5: return "6,4"
        case 6: return "7,5,20,21"
        case 7: return "8,6"
        case 8: return ""
        case 9: return "14"
        case 10: return "14"
        case 11: return "15"
        case 12: return "16"
        case 13: return ""
        case 14: return ""
        case 15: return ""
        case 16: return ""
        case 17: return "18,19"
        case 18: return ""
        case 19: return ""
        case 20: return "21"
        case 21: return "22"
        case 22: return "23"
        case 23: return "24"
        case 24: return "25"
        case 25: return ""
        case 26: return "27,7"
        case 27: return "28"
        case 28: return "29"
        case 29: return "30"
        case 30: return "31"
        case 31: return "32"
        case 33: return "34"
        case 34: return "35"
        case 35: return "36"
        case 36: return "37"
        case 37: return ""
        case 38: return ""
        case 39: return ""
        case 40: return "1,75,103,109,48,75"
        case 41: return "42"
        case 42: return "43"
        case 43: return "44"
        case 44: return "45"
        case 45: return "58"
        case 46: return ""
        case 47: return "48"
        case 48: return "49"
        case 49: return ""
        case 50: return "51"
        case 51: return "52"
        case 52: return "53"
        case 53: return "54"
        case 54: return "74"
        case 55: return "59"
        case 56: return "57"
        case 57: return ""
        case 58: return "61"
        case 59: return ""
        case 60: return ""
        case 61: return ""
        case 62: return "63"
        case 63: return "64"
        case 64: return ""
        case 65: return ""
        case 66: return ""
        case 67: return ""
        case 68: return ""
        case 69: return ""
        case 70: return ""
        case 71: return ""
        case 72: return ""
        case 73: return ""
        case 74: return "46"
        case 75: return "83,76"
        case 76: return "77,78"
        case 77: return "78"
        case 78: return "79"
        case 79: return "80"
        case 80: return "81"
        case 81: return "82"
        case 82: return "83"
        case 83: return "100"
        
        

    }
    return ""
}
