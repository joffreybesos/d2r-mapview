#SingleInstance, Force
SendMode Input
SetWorkingDir, %A_ScriptDir%
#Include %A_ScriptDir%\include\logging.ahk

downloadMapImage(baseUrl, gameMemoryData, ByRef mapData) {
    imageUrl := baseUrl . "/v1/map/" . gameMemoryData["mapSeed"] . "/" . gameMemoryData["difficulty"] . "/" . gameMemoryData["levelNo"] . "/image?flat=true"

    sFile := A_Temp . "\" . gameMemoryData["mapSeed"] . "_" . gameMemoryData["difficulty"] . "_" . gameMemoryData["levelNo"] . ".png"
    FileDelete, %sFile%

    try {
        whr := ComObjCreate("WinHttp.WinHttpRequest.5.1")
        WinHttpReq.SetTimeouts("60000", "60000", "60000", "60000")
        whr.Open("GET", imageUrl, true)
        whr.Send()
        whr.WaitForResponse()
        
        fileContents := whr.ResponseBody
        respHeaders := whr.GetAllResponseHeaders
        leftTrimmed := whr.getResponseHeader("lefttrimmed")
        topTrimmed := whr.getResponseHeader("toptrimmed")
        mapOffsetX := whr.getResponseHeader("offsetx")
        mapOffsety := whr.getResponseHeader("offsety")
        mapwidth := whr.getResponseHeader("mapwidth")
        mapheight := whr.getResponseHeader("mapheight")
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
        WriteLog(respHeaders)
        WriteLog(e.message)
        WriteLog("ERROR: Error downloading image from " imageUrl)
    }
    WriteLog("Downloaded " imageUrl " to " sFile)
    mapData := { "sFile": sFile, "leftTrimmed" : leftTrimmed, "topTrimmed" : topTrimmed, "mapOffsetX" : mapOffsetX, "mapOffsety" : mapOffsety, "mapwidth" : mapwidth, "mapheight" : mapheight }
}  