class automap {

}
		checkAutomapVisibility(d2rprocess, settings, levelNo) {
		    uiOffset:= settings["uiOffset"]
		    alwaysShowMap:= settings["alwaysShowMap"]
		    hideTown:= settings["hideTown"]
		    ;WriteLogDebug("Checking visibility, hideTown: " hideTown " alwaysShowMap: " alwaysShowMap)
		    if ((levelNo == 1 or levelNo == 40 or levelNo == 75 or levelNo == 103 or levelNo == 109) and hideTown) {
		        if (isMapShowing) {
		            WriteLogDebug("Hiding town " levelNo " since hideTown is set to true")
		        }
		        hideMap(false)
		    } else if not WinActive(gameWindowId) {
		        if (isMapShowing) {
		            WriteLogDebug("D2R is not active window, hiding map")
		        }
		        hideMap(false)
		    } else if (!isAutomapShown(d2rprocess, uiOffset) and !alwaysShowMap) {
		        ; hidemap
		        hideMap(alwaysShowMap)
		    } else {
		        unHideMap()
		    } 
		    return
		}

		hideMap(alwaysShowMap) {
		    if (alwaysShowMap == false) {
		        Gui, Map: Hide
		        Gui, Units: Hide
		        if (isMapShowing) {
		            WriteLogDebug("Map hidden")
		        }
		        isMapShowing:= 0
		    }
		}

		unHideMap() {
		    ;showmap
		    if (!isMapShowing) {
		        WriteLogDebug("Map shown")
		    }
		    isMapShowing:= 1
		    Gui, Map: Show, NA
		    Gui, Units: Show, NA
		}