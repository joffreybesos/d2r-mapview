

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

    __new(ByRef settings, ByRef mapSeed, ByRef difficulty, ByRef levelNo, ByRef mapImageList) {
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
        imageUrl := imageUrl . "&padding=" . settings["padding"]
        imageUrl := imageUrl . "&edge=true"
        if (settings["centerMode"]) {
            imageUrl := imageUrl . "&serverScale=" . settings["serverScale"]
        }

        this.imageUrl := imageUrl
        this.downloadImage(imageUrl)
        
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
                this.sFile := sFile
                this.parseHeaders(whr.GetAllResponseHeaders)
                
                if (whr.GetAllResponseHeaders)
                    break   ; don't retry if headers found
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

    refreshMapMargins() {
        levelNo := this.levelNo
        IniRead, levelScale, mapconfig.ini, %levelNo%, scale, 1.0
        IniRead, levelxmargin, mapconfig.ini, %levelNo%, x, 0
        IniRead, levelymargin, mapconfig.ini, %levelNo%, y, 0
        this.levelScale := levelScale
        this.levelxmargin := levelxmargin
        this.levelymargin := levelymargin
    }
    
}

; yes AHK really needs this
convertToBool(field) {
    if (Trim(field) == "true")
        return 1
    return 0
}

