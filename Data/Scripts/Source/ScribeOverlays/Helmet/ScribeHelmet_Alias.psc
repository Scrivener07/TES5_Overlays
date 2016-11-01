ScriptName ScribeHelmet_Alias Extends ReferenceAlias Hidden


; Initialize
;---------------------------------------------------------------------------------------------------

Event OnInit()
	OnPlayerLoadGame()
EndEvent

Event OnPlayerLoadGame()
	Player = Game.GetPlayer()
	Helmet = GetOwningQuest() as ScribeHelmet
	OnGameReload()
EndEvent


; Implement
;---------------------------------------------------------------------------------------------------

Event OnGameReload()
	{override me}
EndEvent

Event OnAliasReload()
	{override me}
EndEvent

Event OnAliasReady()
	{override me}
EndEvent





; Functions and Properties
;---------------------------------------------------------------------------------------------------

ScribeHelmet Property Helmet Auto Hidden
Actor Property Player Auto Hidden

string Property StateEmpty
	string Function Get()
		return ""
	EndFunction
EndProperty

string Property StateActive
	string Function Get()
		return "ACTIVESTATE"
	EndFunction
EndProperty


bool Property IsActive Hidden
	bool Function Get()
		return GetState() == StateActive
	EndFunction
EndProperty


Function SetActive(bool aValue = true)
	If(aValue)
		If(GetState() != StateActive)
			GoToState(StateActive)
		EndIf
	Else
		If(GetState() != StateEmpty)
			GoToState(StateEmpty)
		EndIf
	EndIf
EndFunction


bool Property AllowInput
	bool Function Get()
		return !Utility.IsInMenuMode() && !UI.IsTextInputEnabled()
	EndFunction
EndProperty
