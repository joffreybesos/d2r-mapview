

class MapImage {
    mapSeed := ""
    difficulty := ""
    levelNo := ""
    imageUrl := ""
    imageHeaders :=

    leftTrimmed := ""
    topTrimmed := ""
    levelxmargin := ""
    levelymargin := ""
    mapOffsetX := ""
    mapOffsety := ""
    mapwidth := ""
    mapheight := ""
    exits := ""
    waypoint := ""
    bosses := ""
    quests := ""
    prerotated := ""
    originalwidth := ""
    originalheight := ""

    __new(ByRef settings, ByRef mapSeed, ByRef difficulty, ByRef levelNo, pathStart := 0, pathEnd := 0) {
        this.mapSeed := mapSeed
        this.difficulty := difficulty
        this.levelNo := levelNo
        baseUrl:= settings["baseUrl"]
        thickness := settings["wallThickness"] + 0.0
        if (thickness > 5)
            thickness := 5
        if (thickness < 1)
            thickness := 1

        imageUrl := baseUrl . "/v1/map/" . mapSeed . "/" . difficulty . "/" . levelNo . "/image?wallthickness=" . thickness
        imageUrl := imageUrl . "&rotate=true&showTextLabels=false"
        imageUrl := imageUrl . "&padding=0"  ; . settings["padding"]
        imageUrl := imageUrl . "&noStitch=true"  ; . settings["padding"]
        imageUrl := imageUrl . "&edge=true"
        if (settings["showPathFinding"]) {
            if (pathStart && pathEnd) {
                imageUrl := imageUrl . "&pathFinding=true"
                imageUrl := imageUrl . "&pathStart=" . pathStart
                imageUrl := imageUrl . "&pathEnd=" . pathEnd
                imageUrl := imageUrl . "&pathColour=" . settings["pathFindingColour"]
            }
        }
        imageUrl := imageUrl . "&serverScale=" . settings["serverScale"]

        this.imageUrl := imageUrl
        this.downloadImage(imageUrl)
        WriteLog("Downloading image " imageUrl)

    } 

    getFileName() {
        return A_Temp "/" this.mapSeed "_" this.difficulty "_" this.levelNo ".png"
    }

    downloadImage(Byref imageUrl) {
        tries := 0
        Loop, 5
        {
            tries++
            try {
                whr := ComObjCreate("WinHttp.WinHttpRequest.5.1")
                whr.SetTimeouts("45000", "45000", "45000", "45000")
                whr.Open("GET", imageUrl, true)
                whr.Send()
                whr.WaitForResponse()
                vStream := whr.ResponseStream
                sFile := this.getFileName()
                if (ComObjType(vStream) = 0xD) { ;VT_UNKNOWN = 0xD

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
                this.sFile := sFile
                this.parseHeaders(whr.GetAllResponseHeaders)

                if (whr.GetAllResponseHeaders)
                    break ; don't retry if headers found
            } catch e {
                errMsg := e.message
                errMsg := StrReplace(errMsg, "`nSource:`t`tWinHttp.WinHttpRequest`nDescription:`t", "")
                errMsg := StrReplace(errMsg, "`r`n`nHelpFile:`t`t(null)`nHelpContext:`t0", "")
                WriteLog("ERROR: " errMsg)
                Loop, Parse, respHeaders, `n
                {
                    WriteLog("Response Header: " A_LoopField)
                }
                if (Instr(errMsg, "The operation timed out")) {
                    WriteLog("ERROR: Timeout downloading image from " imageUrl)
                    WriteLog("The mapserver likely isn't running for some reason")
                }
                if (A_Index == 5) {
                    WriteLog("ERROR: Could not load map even after retrying 5 times " errMsg)
                    Msgbox, 48, d2r-mapview %version%, %errormsg4% %baseUrl%.`n%errormsg5%`n%errormsg6%`n`n%errMsg%`n%errormsg3%
                }
            }
            if (tries > 1) {
                WriteLog("Downloaded image after " tries " attempts")
            }
        }
    }

    parseHeaders(ByRef respHeaders) {
        foundFields := 0
        Loop, Parse, respHeaders, `r`n
        { 
            ; WriteLogDebug("Response Header: " A_LoopField)

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
                case "prerotated": prerotated := convertToBool(field[2]), foundFields++
                case "originalwidth": originalwidth := Trim(field[2]), foundFields++
                case "originalheight": originalheight := Trim(field[2]), foundFields++
                case "version": mapServerVersion := Trim(field[2])
            }
        }
        if (foundFields < 9) {
            WriteLog("ERROR: Did not find all expected response headers, turn on debug mode to view. Unexpected behaviour may occur")
            Loop, Parse, respHeaders, `n
            {
                WriteLog("Response Header: " A_LoopField)
            }
        }
        ; if prerotated returns true at least once then it will be for every other request
        ; this should stop any weird rotation issues
        if (prerotated) {
            serverisv10 := true
        }
        if (serverisv10) {
            prerotated := true
        }
        if (mapServerVersion < 14) {
            if (!settings["alertedMapServerVersion"]) {
                settings["alertedMapServerVersion"] := true
                IniWrite, % 1, settings.ini, Settings, alertedMapServerVersion
                errormsg27 := localizedStrings["errormsg27"]
                Msgbox, 48, d2r-mapview %version%, %errormsg27%
            }
        }
        this.leftTrimmed := leftTrimmed
        this.topTrimmed := topTrimmed
        this.topTrimmed := topTrimmed
        this.levelxmargin := levelxmargin
        this.levelymargin := levelymargin
        this.mapOffsetX := mapOffsetX
        this.mapOffsety := mapOffsety
        this.mapwidth := mapwidth
        this.mapheight := mapheight
        this.exits := exits
        this.waypoint := waypoint
        this.bosses := bosses
        this.quests := quests
        this.prerotated := prerotated
        this.originalwidth := originalwidth
        this.originalheight := originalheight
    }

}

; yes AHK really needs this
convertToBool(field) {
    if (Trim(field) == "true")
        return 1
    return 0
}

GetPathEnd(levelNo, ByRef pathStart, ByRef pathEnd) {
    switch levelNo
    {
        ;case "2": return "8" ; den of evil
        case "3": pathStart := 2, pathEnd := 4
        case "4": pathStart := 3, pathEnd := 10
        case "5": pathStart := 10, pathEnd := 6
        case "6": pathStart := 5, pathEnd := 7
        ;case "7": return "12"
        ;case "8": return "2"
        case "9": pathStart := 3, pathEnd := 13
        case "10": pathStart := 4, pathEnd := 5
        case "11": pathStart := 6, pathEnd := 15
        case "12": pathStart := 7, pathEnd := 16
        case "21": pathStart := 20, pathEnd := 22
        case "22": pathStart := 21, pathEnd := 23
        case "23": pathStart := 22, pathEnd := 24
        case "24": pathStart := 23, pathEnd := 25
        case "28": pathStart := 27, pathEnd := 29
        case "29": pathStart := 28, pathEnd := 29
        case "30": pathStart := 29, pathEnd := 31
        case "31": pathStart := 30, pathEnd := 32
        ;case "33": return "34"
        case "34": pathStart := 33, pathEnd := 35
        case "35": pathStart := 34, pathEnd := 36
        case "36": pathStart := 35, pathEnd := 37
        ;case "41": return "55"
        ;case "42": return "56"
        ;case "43": return "62"
        ;case "44": return "65"
        ; case "45": return "58"
        case "47": pathStart := 40, pathEnd := 48
        case "48": pathStart := 47, pathEnd := 49
        ;case "50": pathStart := 40, pathEnd := 51
        case "51": pathStart := 50, pathEnd := 52
        case "52": pathStart := 51, pathEnd := 53
        case "53": pathStart := 52, pathEnd := 54
        case "54": pathStart := 53, pathEnd := 298
        case "55": pathStart := 41, pathEnd := 59
        case "56": pathStart := 42, pathEnd := 57
        case "57": pathStart := 56, pathEnd := 60
        case "58": pathStart := 48, pathEnd := 61
        case "62": pathStart := 61, pathEnd := 63
        case "63": pathStart := 62, pathEnd := 64
        case "64": pathStart := 63, pathEnd := 749

        case "66": pathStart := 46, pathEnd := 152
        case "67": pathStart := 46, pathEnd := 152
        case "68": pathStart := 46, pathEnd := 152
        case "69": pathStart := 46, pathEnd := 152
        case "70": pathStart := 46, pathEnd := 152
        case "71": pathStart := 46, pathEnd := 152
        case "72": pathStart := 46, pathEnd := 152

        case "84": pathStart := 76, pathEnd := 397
        case "85": pathStart := 76, pathEnd := 407

        case "86": pathStart := 78, pathEnd := 87
        case "87": pathStart := 86, pathEnd := 90
        case "88": pathStart := 78, pathEnd := 89
        case "89": pathStart := 88, pathEnd := 91
        case "91": pathStart := 89, pathEnd := 406
        
        case "92": pathStart := 81, pathEnd := 93
        case "100": pathStart := 83, pathEnd := 101
        case "101": pathStart := 100, pathEnd := 102

        case "104": pathStart := 103, pathEnd := 105
        case "105": pathStart := 104, pathEnd := 106
        case "106": pathStart := 105, pathEnd := 107
        case "107": pathStart := 106, pathEnd := 108
        
        case "113": pathStart := 112, pathEnd := 114
        case "115": pathStart := 113, pathEnd := 117
        case "118": pathStart := 117, pathEnd := 120
        case "122": pathStart := 121, pathEnd := 123
        case "123": pathStart := 122, pathEnd := 124
        case "128": pathStart := 120, pathEnd := 129
        case "129": pathStart := 128, pathEnd := 130
        case "130": pathStart := 129, pathEnd := 131
    }
    return
}