
checkServer(ByRef settings) {
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
            Msgbox, 48, d2r-mapview, Could not connect to %baseUrl%`n`nMake sure the server is running`nCould also not find d2-mapserver.exe to launch server`nYou need to place d2r-map.exe in the same folder as your d2-mapserver.exe`n%emsg%`n`nExiting...
            ExitApp
        }
    }
}
startMapServer(serverExe, ByRef settings) {
    WriteLog("Starting map server...")
    Runwait, taskkill /im %serverExe% /f
    Runwait, taskkill /im node.exe /f

    ServerLog := A_ScriptDir . "\serverlog.txt"
    FileDelete, %ServerLog%
    Run,%ComSpec% /c %serverExe% >> %ServerLog%,,Hide

    ; wait until 'running on hostname' appears in logs
    start_time := A_TickCount
    time_to_run := 30000
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
        Msgbox, 48, d2r-mapview, Could not start d2-mapserver.exe!`nTry running serversetup.bat and try again`nAlso check serverlog.txt for errors`n`nExiting...
        ExitApp
    }

    ; do health check on new server instance
    RegExMatch(Output, "Running on (http:\/\/.*?:\d+)", newBaseUrl)
    newTestUrl := newBaseUrl1 "/health"
    try {
        healthCheck(newTestUrl)
    } catch e {
        emsg := e.message
        Msgbox, 48, d2r-mapview, Could not connect to %newBaseUrl1%`n`nMake sure the server is running`nDouble check your baseUrl in settings.ini`n`n%emsg%`n`nExiting...
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