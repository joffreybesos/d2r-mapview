
; Valid locales
; enUS
; zhTW
; deDE
; esES
; frFR
; itIT
; koKR
; plPL
; esMX
; jaJP
; ptBR
; ruRU
; zhCN

LoadLocalization(ByRef settings) {
    FileInstall, localization.ini, localization.ini, 1
    
    if (settings["locale"] == "") {
        locale := GetLocale()
        settings["locale"] := locale
        writeIniVar("locale")
    } else {
        locale := settings["locale"]
    }
    WriteLog("Locale selected is " locale)

    ;have to split these up due to ahk limitations
    localizedStringsNPCS := ReadSection(locale, "NPCS")
    localizedStringsShrines := ReadSection(locale, "Shrines")
    localizedStringsAreas := ReadSection(locale, "Areas")
    localizedStringsItems := ReadSection(locale, "Items")
    localizedStringsMonsters := ReadSection(locale, "Monsters")
    localizedStringsRunes := ReadSection(locale, "Runes")
    localizedStringsBuffs := ReadSection(locale, "Buffs")
    localizedStringsUI := ReadSection(locale, "UI")
    localizedStringsQuality := ReadSection(locale, "Quality")
    localizedStringsSockets := ReadSection(locale, "Sockets")
    localizedStringsErrors := ReadSection(locale, "Errors")
    localizedStrings := []
    for k, v in localizedStringsNPCS
        localizedStrings[k]:=v
    for k, v in localizedStringsShrines
        localizedStrings[k]:=v
    for k, v in localizedStringsAreas
        localizedStrings[k]:=v
    for k, v in localizedStringsItems
        localizedStrings[k]:=v
    for k, v in localizedStringsMonsters
        localizedStrings[k]:=v
    for k, v in localizedStringsRunes
        localizedStrings[k]:=v
    for k, v in localizedStringsBuffs
        localizedStrings[k]:=v
    for k, v in localizedStringsUI
        localizedStrings[k]:=v
    for k, v in localizedStringsQuality
        localizedStrings[k]:=v
    for k, v in localizedStringsSockets
        localizedStrings[k]:=v
    for k, v in localizedStringsErrors
        localizedStrings[k]:=v
    return localizedStrings
}

ReadSection(locale, section) {
    IniRead, OutputVarSection, localization.ini, %locale%-%section%
    localizedStrings := []

    Loop, Parse, OutputVarSection , `n
    {
        valArr := StrSplit(A_LoopField,"=")
        valArr[1] := StrReplace(valArr[1], """", "")
        valArr[2] := StrReplace(valArr[2], """", "")
        ; msgbox % valArr[1] " " valArr[2]
        
        localizedStrings[valArr[1]] := valArr[2]
    }
    return localizedStrings
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


;~    This works only with single Lined Edit Controls
GetUnicodeText(ByRef wString, hWnd)
{
   static EM_GETLINELENGTH := 0xC1, EM_GETLINE := 0xC4
   length := DllCall("SendMessageW", "UInt",hWnd, "UInt",EM_GETLINELENGTH, "UInt",0, "Uint",0)
   VarSetCapacity(wString,length*2+1,0)
   NumPut(length,wString,"Uint")
   result := DllCall("SendMessageW", "UInt",hWnd, "UInt",EM_GETLINE, "UInt",0,"Uint",&wString)
}

SetUnicodetext(ByRef ptrUnicodeText,hWnd)
{
   static WM_SETTEXT := 0x0C
   DllCall("SendMessageW", "UInt",hWnd, "UInt",WM_SETTEXT, "UInt",0, "Uint",&ptrUnicodeText)
}

Unicode2UTF8(ByRef wString)
{
   nSize := DllCall("WideCharToMultiByte","Uint",65001,"Uint",0,"Uint"
      ,&wString,"int",-1,"Uint",0,"int",0,"Uint",0,"Uint",0)
   VarSetCapacity(sString, nSize)
   DllCall("WideCharToMultiByte","Uint",65001,"Uint",0,"Uint"
      ,&wString,"int",-1,"str",sString,"int",nSize,"Uint",0,"Uint",0)
   Return sString
}