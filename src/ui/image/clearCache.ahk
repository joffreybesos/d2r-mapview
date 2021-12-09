#SingleInstance, Force
SendMode Input
SetWorkingDir, %A_ScriptDir%

ClearCache(folder) {
    files := 0
    Loop Files, %folder%\*.png
    {
        if (RegExMatch(A_LoopFileName, "i)\d+_\d+_\d+\.png")) {
            files++
            FileDelete, %A_LoopFileFullPath%
        }
    }
    Loop Files, %folder%\*.txt
    {
        if (RegExMatch(A_LoopFileName, "i)\d+_\d+_\d+\.txt")) {
            files++
            FileDelete, %A_LoopFileFullPath%

        }
    }
    WriteLog("Deleted " files " files from cache")
}

