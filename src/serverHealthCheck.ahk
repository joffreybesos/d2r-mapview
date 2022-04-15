
checkServer(ByRef settings) {
    errormsg3 := localizedStrings["errormsg3"]
    errormsg13 := localizedStrings["errormsg13"]
    errormsg14 := localizedStrings["errormsg14"]
    errormsg15 := localizedStrings["errormsg15"]
    errormsg16 := localizedStrings["errormsg16"]
    ;health check
    baseUrl := settings["baseUrl"]
    testUrl := baseUrl "/health"
    
    try {
        healthCheck(testUrl)
    } catch e {
        if (FileExist("d2-mapserver.exe")) {
            startMapServer("d2-mapserver.exe", settings)
        } else {
            emsg := e.message
            emsg := StrReplace(emsg, "`nSource:`t`tWinHttp.WinHttpRequest`nDescription:`t", "")
            emsg := StrReplace(emsg, "`r`n`nHelpFile:`t`t(null)`nHelpContext:`t0", "")
            WriteLog(emsg)
            Msgbox, 48, d2r-mapview %version%, %errormsg13% %baseUrl%`n`n%errormsg14%`n%errormsg15%`n%errormsg16%`n%emsg%`n`n%errormsg3%
            ExitApp
        }
    }
}
startMapServer(serverExe, ByRef settings) {
    errormsg3 := localizedStrings["errormsg3"]
    errormsg13 := localizedStrings["errormsg13"]
    errormsg14 := localizedStrings["errormsg14"]
    errormsg15 := localizedStrings["errormsg15"]
    errormsg16 := localizedStrings["errormsg16"]
    errormsg17 := localizedStrings["errormsg17"]
    errormsg18 := localizedStrings["errormsg18"]
    errormsg19 := localizedStrings["errormsg19"]
    errormsg20 := localizedStrings["errormsg20"]
    WriteLog("Attempting to start map server...")
    Runwait, taskkill /im %serverExe% /f
    Runwait, taskkill /im node.exe /f

    ServerLog := A_ScriptDir . "\serverlog.txt"
    FileDelete, %ServerLog%
    Run,%ComSpec% /c %serverExe% >> %ServerLog%,,Hide

    ; wait until 'running on hostname' appears in logs
    start_time := A_TickCount
    time_to_run := 60000
    end_time := start_time + time_to_run
    serverStarted := false
    while (A_tickcount < end_time)
    {
        FileRead,Output,%ServerLog%
        if (InStr(Output, "Running on http://") > 0)
        {
            WriteLog("SUCCESS: Map server started!")
            serverStarted := true
            end_time := 0
        }
    }

    if (!serverStarted) {
        WriteLog("ERROR: Map server failed to start, check serverlog.txt")
        Msgbox, 48, d2r-mapview %version%, %errormsg17%`n%errormsg18%`n%errormsg19%`n`n%errormsg3%
        ExitApp
    }

    ; do health check on new server instance
    RegExMatch(Output, "Running on (http:\/\/.*?:\d+)", newBaseUrl)
    newTestUrl := newBaseUrl1 "/health"
    try {
        healthCheck(newTestUrl)
    } catch e {
        emsg := e.message
        Msgbox, 48, d2r-mapview %version%, %errormsg13% %newBaseUrl1%`n`n%errormsg14%`n%errormsg20%`n`n%emsg%`n`n%errormsg3%
        ExitApp
    }
    WriteLog("Started and using server on " newBaseUrl1)
    settings["baseUrl"] := newBaseUrl1
}

healthCheck(testUrl) {
    whr := ComObjCreate("WinHttp.WinHttpRequest.5.1")
    WinHttpReq.SetTimeouts("10", "10", "10", "10")
    whr.Open("GET", testUrl, true)
    whr.Send()
    whr.WaitForResponse()
    ;healthCheck := whr.ResponseText
}