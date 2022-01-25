#Include Yaml.ahk

;FileRead, textContents, "itemfilter.yaml"

yamlObj:=Yaml("itemfilter.yaml",isfile:=1) ;isfile is set to 1 by default

;MsgBox % yamlObj.Dump() ;count sequence items in Foreword



; MsgBox % yamlObj.enabledAlerts.(8) ;count sequence items in Foreword



;msgbox % yamlObj.enabledAlerts.()


;Msgbox % yamlObj.Alerts.Dump(1)

numAlerts := yamlObj.enabledAlerts.()

Loop, %numAlerts%
{
    thisAlert := yamlObj.Alerts[yamlObj.enabledAlerts.(A_Index)]
    numQualities := thisAlert.quality.()
    items := thisAlert.item.Dump(3)
    
    msgbox % items
}