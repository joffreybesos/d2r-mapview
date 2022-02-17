
LoadLocalization(ByRef localizedStrings, ByRef settings) {
    FileInstall, localization.ini, localization.ini, 0
    locale := GetLocale()
    settings["locale"] := locale
    IniRead, OutputVarSection, localization.ini, %locale%
    Loop, Parse, OutputVarSection , `n
    {
        valArr := StrSplit(A_LoopField,"=")
        localizedStrings[valArr[1]] := valArr[2]
    }
}


GetLocale() {
    locale := Format("{:04X}", GetDefaultLCID())
    switch (locale) {
        case "0404": ; chinese taiwan zhTW
            localeName := "zhTW"  ; Chinese Taiwan
        case "0407","0807","0c07","1007","1407":
            localeName := "deDE"  ; German
        case "040a","0c0a":
            localeName := "esES"  ; Spanish
        case "040c","080c","0c0c","100c","140c","180c":
            localeName := "frFR"  ; French
        case "0410","0810":
            localeName := "itIT"  ; Italian
        case "0412":
            localeName := "koKR"  ; Korean
        case "0415":
            localeName := "plPL"  ; Polish
        case "080a","100a","140a","180a","1c0a","200a","240a","280a", "2c0a", "300a", "340a", "380a", "3c0a", "400a", "440a", "480a", "4c0a", "500a":
            localeName := "esMX"  ; Mexican spanish
        case "0411":
            localeName := "jaJP"  ; Japanese
        case "0416", "0816":
            localeName := "ptBR"  ; Portuguese 
        case "0419":
            localeName := "ruRU"
        case "0804","0c04","1004","1404":
            localeName := "zhCN"  ; Chinese
        default:
            localeName := "enUS"
    }
    return localeName
}



GetDefaultLCID(LCID := 0x0400) {
   ; msdn.microsoft.com/en-us/library/windows/desktop/dd317768(v=vs.85).aspx
   ; LOCALE_INVARIANT = 0x007F, LOCALE_SYSTEM_DEFAULT = 0x0800, LOCALE_USER_DEFAULT = 0x0400
   ; LOCALE_CUSTOM_DEFAULT = 0x0C00, LOCALE_CUSTOM_UI_DEFAULT = 0x1400, LOCALE_CUSTOM_UNSPECIFIED = 0x1000 <<< Win Vista+
   Return DllCall("ConvertDefaultLocale", "UInt", LCID, "UInt")
}

