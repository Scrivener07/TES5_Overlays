ScriptName ScribeMagic_View Extends ScribeOverlay_ViewBase


; Initialize
;---------------------------------------------------------------------------------------------------

event OnViewReload()
	ScribeOverlay.Log("OnViewReload()", self)
endEvent


event OnViewReady()
	ScribeOverlay.Log("OnViewReady()", self)
endEvent


string function GetViewSource()
	return "overlays/MagicView.swf"
endFunction


string function GetViewType()
	return "ScribeMagic_View"
endFunction

