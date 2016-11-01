ScriptName ScribeSample_View Extends ScribeOverlay_ViewBase


; Initialize
;---------------------------------------------------------------------------------------------------

; @implements
Event OnViewReload()
	ScribeOverlay.Log("OnViewReload()", self)
EndEvent


; @implements
Event OnViewReady()
	ScribeOverlay.Log("OnViewReady()", self)
EndEvent


; @implements
string Function GetViewSource()
	return "overlays/SampleView.swf"
EndFunction


; @implements
string Function GetViewType()
 return "ScribeSample_View"
EndFunction


;@implements
string[] Function GetHudModes()
	string[] array = new string[6]
	array[0] = "All"
	array[1] = "StealthMode"
	array[2] = "Favor"
	array[3] = "Swimming"
	array[4] = "HorseMode"
	array[5] = "WarHorseMode"
	return array
EndFunction
