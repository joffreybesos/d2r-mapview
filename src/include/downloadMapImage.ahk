#SingleInstance, Force
SendMode Input
SetWorkingDir, %A_ScriptDir%
#Include %A_ScriptDir%\include\Gdip_All.ahk
#Include %A_ScriptDir%\include\showText.ahk
#Include %A_ScriptDir%\include\logging.ahk

downloadMapImage(sMapUrl, ByRef mapData) {
    ; Gui, 1: Destroy
    
    ; ShowText(1000, 50, 50, "Loading map data...`nPlease wait", "22")
    
    sFile=%A_Temp%\currentmap.png
    FileDelete, %sFile%

    ; download file
    try {
        
        whr := ComObjCreate("WinHttp.WinHttpRequest.5.1")
        whr.Open("GET", sMapUrl, true)
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
        WriteLog(e.message)
        WriteLog("ERROR: Failed to download image from " imageUrl)
    }
    ;WriteLog("Downloaded " sMapUrl " to " sFile)
    mapData := { "sFile": sFile, "leftTrimmed" : leftTrimmed, "topTrimmed" : topTrimmed, "mapOffsetX" : mapOffsetX, "mapOffsety" : mapOffsety, "mapwidth" : mapwidth, "mapheight" : mapheight }
}  