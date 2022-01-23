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
    centerRequestBody := requestBody """serverScale"": """ settings["serverScale"] ""","
    requestBody := requestBody """serverScale"": ""2"","
    
    edges := "false"
    if (settings["edges"])
        edges := "true"
    requestBody := requestBody """edge"": """ edges """}"
    
    try {
        whr := ComObjCreate("WinHttp.WinHttpRequest.5.1")
        ;WinHttpReq.SetTimeouts("1", "1", "1", "1")
        whr.Open("POST", prefetchUrl, false)
        whr.SetRequestHeader("Content-Type", "application/json")
        whr.Send(requestBody)
        whr.WaitForResponse()
    } catch e {
        ; fail silently
    }
    ; prefetch center maps
    try {
        whr := ComObjCreate("WinHttp.WinHttpRequest.5.1")
        ;WinHttpReq.SetTimeouts("1", "1", "1", "1")
        whr.Open("POST", prefetchUrl, false)
        whr.SetRequestHeader("Content-Type", "application/json")
        whr.Send(centerRequestBody)
        whr.WaitForResponse()
    } catch e {
        ; fail silently
    }
}


calculateLevel(currentLevel) {
    allWPs := "1,3,5,6,27,28,29,32,35,40,42,43,45,46,48,74,75,78,79,80,81,83,101,103,105,107,109,111,112,113,115,118,121,123,129"
    switch (currentLevel) {
        ;case 1: return "1,2,3,4,5"
        ;case 2: return "1,2,3,4,5"
    }
    return allWPs
}

    ; try {
    ;     whr := ComObjCreate("WinHttp.WinHttpRequest.5.1")
    ;     WinHttpReq.SetTimeouts("60000", "60000", "60000", "60000")
    ;     whr.Open("GET", imageUrl, true)
    ;     whr.Send()
    ;     whr.WaitForResponse()
        
    ;     fileContents := whr.ResponseBody
    ;     respHeaders := whr.GetAllResponseHeaders
    ;     vStream := whr.ResponseStream
        
    ;     if (ComObjType(vStream) = 0xD) {      ;VT_UNKNOWN = 0xD
    ;         pIStream := ComObjQuery(vStream, "{0000000c-0000-0000-C000-000000000046}")	;defined in ObjIdl.h

    ;         oFile := FileOpen( sFile, "w")
    ;         Loop {	
    ;             VarSetCapacity(Buffer, 8192)
    ;             hResult := DllCall(NumGet(NumGet(pIStream + 0) + 3 * A_PtrSize)	; IStream::Read 
    ;                 , "ptr", pIStream	
    ;                 , "ptr", &Buffer			;pv [out] A pointer to the buffer which the stream data is read into.
    ;                 , "uint", 8192			;cb [in] The number of bytes of data to read from the stream object.
    ;                 , "ptr*", cbRead)		;pcbRead [out] A pointer to a ULONG variable that receives the actual number of bytes read from the stream object. 
    ;             oFile.RawWrite(&Buffer, cbRead)
    ;         } Until (cbRead = 0)
    ;         ObjRelease(pIStream)
    ;         oFile.Close()
    ;     }
    ; } catch e {
    ;     errMsg := e.message
    ;     if (Instr(errMsg, "The operation timed out")) {
    ;         WriteLog("ERROR: Timeout downloading image from " imageUrl)
    ;         WriteLog("You can try opening the above URL in your browser to test connectivity")
    ;         Msgbox, 48, d2r-mapview, Timed out reading map from map server`nCheck baseUrl in settings.ini`n`nExiting....
    ;     } else if (Instr(errMsg, "The requested header was not found")) {
    ;         Loop, Parse, respHeaders, `n
    ;         {
    ;             WriteLog("Response Header: " A_LoopField)
    ;         }
    ;         WriteLog("ERROR: Did not find an expected header " imageUrl)
    ;         WriteLog("If it didn't find the correct headers, you likely need to update your server docker image")
    ;         Msgbox, 48, d2r-mapview, Error downloading map image.`nEnsure you are using latest version of map server`n`nExiting....
    ;     } else {
    ;         WriteLog(errMsg)
    ;         Loop, Parse, respHeaders, `n
    ;         {
    ;             WriteLog("Response Header: " A_LoopField)
    ;         }
    ;         WriteLog("ERROR: Error downloading image from " imageUrl)
    ;         if (FileExist(sFile)) {
    ;             WriteLog("Downloaded image to file, but something else went wrong " sFile)
    ;         }
    ;         If InStr(baseUrl, "map.d2r-mapview.xyz")
    ;             Msgbox, 48, d2r-mapview, Error downloading map image.`nPublic map server may be down`nConsider running your own map server, it's easy to setup now and much faster`n`nCheck map server baseUrl in settings.ini or errors in log.txt`n`nExiting....
    ;         Else
    ;             Msgbox, 48, d2r-mapview, Error downloading map image from %baseUrl%.`nCheck that map server is running`nCheck baseUrl in settings.ini or errors in log.txt`n`nExiting....
    ;     }
    ; }
