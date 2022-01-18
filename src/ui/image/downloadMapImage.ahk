#SingleInstance, Force
SendMode Input
SetWorkingDir, %A_ScriptDir%
#Include %A_ScriptDir%\include\logging.ahk

downloadMapImage(settings, gameMemoryData, ByRef mapData) {
    baseUrl:= settings["baseUrl"]
    t := settings["wallThickness"] + 0.0
    if (t > 5)
        t := 5
    if (t < 1)
        t := 1
    
    imageUrl := baseUrl . "/v1/map/" . gameMemoryData["mapSeed"] . "/" . gameMemoryData["difficulty"] . "/" . gameMemoryData["levelNo"] . "/image?wallthickness=" . t
    sFile := A_Temp . "\" . gameMemoryData["mapSeed"] . "_" . gameMemoryData["difficulty"] . "_" . gameMemoryData["levelNo"]
    sFileTxt := A_Temp . "\" . gameMemoryData["mapSeed"] . "_" . gameMemoryData["difficulty"] . "_" . gameMemoryData["levelNo"]

    if (settings["edges"]) {
        imageUrl := imageUrl . "&edge=true"
    }
    if (settings["centerMode"]) {
        imageUrl := imageUrl . "&serverScale=" . settings["serverScale"]
        sFile .= "_Center"
        sFileTxt .= "_Center"
    }
    
    sFile .= ".png"
    sFileTxt .= ".txt"

    levelNo := gameMemoryData["levelNo"]
    IniRead, levelScale, mapconfig.ini, %levelNo%, scale, 1.0
    IniRead, levelxmargin, mapconfig.ini, %levelNo%, x, 0
    IniRead, levelymargin, mapconfig.ini, %levelNo%, y, 0
    ;WriteLog("Read levelScale " levelScale " " levelxmargin " " levelymargin " from file")

    if (not FileExist(sFile) or not FileExist(sFileTxt)) {
        ; if either file is missing, do a fresh download
        FileDelete, %sFile%
        FileDelete, %sFileTxt%

        try {
            whr := ComObjCreate("WinHttp.WinHttpRequest.5.1")
            WinHttpReq.SetTimeouts("60000", "60000", "60000", "60000")
            whr.Open("GET", imageUrl, true)
            whr.Send()
            whr.WaitForResponse()
            
            fileContents := whr.ResponseBody
            respHeaders := whr.GetAllResponseHeaders
            vStream := whr.ResponseStream
            
            if (ComObjType(vStream) = 0xD) {      ;VT_UNKNOWN = 0xD
                pIStream := ComObjQuery(vStream, "{0000000c-0000-0000-C000-000000000046}")	;defined in ObjIdl.h

                oFile := FileOpen( sFile, "w")
                Loop {	
                    VarSetCapacity(Buffer, 8192)
                    hResult := DllCall(NumGet(NumGet(pIStream + 0) + 3 * A_PtrSize)	; IStream::Read 
                        , "ptr", pIStream	
                        , "ptr", &Buffer			;pv [out] A pointer to the buffer which the stream data is read into.
                        , "uint", 8192			;cb [in] The number of bytes of data to read from the stream object.
                        , "ptr*", cbRead)		;pcbRead [out] A pointer to a ULONG variable that receives the actual number of bytes read from the stream object. 
                    oFile.RawWrite(&Buffer, cbRead)
                } Until (cbRead = 0)
                ObjRelease(pIStream)
                oFile.Close()
            }
        } catch e {
            errMsg := e.message
            if (Instr(errMsg, "The operation timed out")) {
                WriteLog("ERROR: Timeout downloading image from " imageUrl)
                WriteLog("You can try opening the above URL in your browser to test connectivity")
                Msgbox, 48, d2r-mapview, Timed out reading map from map server`nCheck baseUrl in settings.ini`n`nExiting....
            } else if (Instr(errMsg, "The requested header was not found")) {
                Loop, Parse, respHeaders, `n
                {
                    WriteLog("Response Header: " A_LoopField)
                }
                WriteLog("ERROR: Did not find an expected header " imageUrl)
                WriteLog("If it didn't find the correct headers, you likely need to update your server docker image")
                Msgbox, 48, d2r-mapview, Error downloading map image.`nEnsure you are using latest version of map server`n`nExiting....
            } else {
                WriteLog(errMsg)
                Loop, Parse, respHeaders, `n
                {
                    WriteLog("Response Header: " A_LoopField)
                }
                WriteLog("ERROR: Error downloading image from " imageUrl)
                if (FileExist(sFile)) {
                    WriteLog("Downloaded image to file, but something else went wrong " sFile)
                }
                If InStr(baseUrl, "map.d2r-mapview.xyz")
                    Msgbox, 48, d2r-mapview, Error downloading map image.`nCheck map server baseUrl in settings.ini or errors in log.txt`n`nConsider running your own map server, it's easy to setup now and much faster`n`nExiting....
                Else
                    Msgbox, 48, d2r-mapview, Error downloading map image.`nCheck map server baseUrl in settings.ini or errors in log.txt`n`nExiting....
            }
        }
        FileAppend, %respHeaders%, %sFileTxt%
    }
    if (FileExist(sFileTxt)) {
        FileRead, respHeaders, %sFileTxt%
    }
    if (FileExist(sFile)) {
        WriteLog("Downloaded " imageUrl " to " sFile)
        foundFields := 0
        Loop, Parse, respHeaders, `r`n
        {  
            ;WriteLogDebug("Response Header: " A_LoopField)
            
            field := StrSplit(A_LoopField, ":")
            switch (field[1]) {
                case "lefttrimmed": leftTrimmed := Trim(field[2]), foundFields++
                case "toptrimmed": topTrimmed := Trim(field[2]), foundFields++
                case "offsetx": mapOffsetX := Trim(field[2]), foundFields++
                case "offsety": mapOffsety := Trim(field[2]), foundFields++
                case "mapwidth": mapwidth := Trim(field[2]), foundFields++
                case "mapheight": mapheight := Trim(field[2]), foundFields++
                case "exits": exits := Trim(field[2]), foundFields++
                case "waypoint": waypoint := Trim(field[2]), foundFields++
                case "bosses": bosses := Trim(field[2]), foundFields++
                case "quests": quests := Trim(field[2]), foundFields++
            }
        }
        if (foundFields < 9) {
            WriteLog("ERROR: Did not find all expected response headers, turn on debug mode to view. Unexpected behaviour may occur")
        }
    }
    ;WriteLog("sFile: " sFile ", leftTrimmed: " leftTrimmed ", topTrimmed: " topTrimmed ", levelScale: " levelScale ", levelxmargin: " levelxmargin ", levelymargin: " levelymargin ", mapOffsetX: " mapOffsetX ", mapOffsety: " mapOffsety ", mapwidth: " mapwidth ", mapheight: " mapheight ", exits: " exits  ", waypoint: " waypoint  ", bosses: " bosses)
    mapData := { "sFile": sFile, "leftTrimmed" : leftTrimmed, "topTrimmed" : topTrimmed, "levelScale": levelScale, "levelxmargin": levelxmargin, "levelymargin": levelymargin, "mapOffsetX" : mapOffsetX, "mapOffsety" : mapOffsety, "mapwidth" : mapwidth, "mapheight" : mapheight, "exits": exits, "waypoint": waypoint, "bosses": bosses, "quests": quests }
} 