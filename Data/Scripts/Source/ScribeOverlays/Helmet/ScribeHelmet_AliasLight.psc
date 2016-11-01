ScriptName ScribeHelmet_AliasLight Extends ScribeHelmet_Alias


; Fields
;..................................................
int LastLight = -1


; Alias Implementation
;---------------------------------------------------------------------------------------------------

;@implement
Event OnGameReload()
	ScribeOverlay.Log("OnGameReload()", self)
EndEvent


;@implement
Event OnAliasReload()
	ScribeOverlay.Log("OnAliasReload()", self)
	RegisterForModEvent(Helmet.EventLightFinished, "OnLightFinished") 	;@AS2
EndEvent


;@implement
Event OnAliasReady()
	ScribeOverlay.Log("OnAliasReady()", self)
	SetActive()

	UnregisterForUpdate()
	RegisterForSingleUpdate(1.0)
EndEvent




; Active State
;---------------------------------------------------------------------------------------------------

State ACTIVESTATE
	Event OnUpdate()
		int iLight = Math.Floor(Player.GetLightLevel())
		If(iLight != LastLight)
			LastLight = iLight
			SendEvent_LightChanged(iLight)
		EndIf
	EndEvent


	Event OnLightFinished(string asEventName, string asString, float afNumber, form akSender)
		ScribeOverlay.Log("OnLightFinished()", self)
		RegisterForSingleUpdate(UpdateInterval)
	EndEvent


	Event OnEndState()
		ScribeOverlay.Log("OnEndState()", self)
		UnregisterForUpdate()
		LastLight = -1
	EndEvent
EndState


; Empty State
;---------------------------------------------------------------------------------------------------

Event OnLightFinished(string asEventName, string asString, float afNumber, form akSender)
	{Empty State}
EndEvent


; Events
;---------------------------------------------------------------------------------------------------

Function SendEvent_LightChanged(int aiLightLevel)
	ScribeOverlay.Log("SendEvent_LightChanged(aiLightLevel="+aiLightLevel+")", self)
	int ihandle = ModEvent.Create(EventLightChanged)
	If(ihandle)
		ModEvent.PushInt(ihandle, aiLightLevel)
		ModEvent.Send(ihandle)
	EndIf
EndFunction



; Properties
;---------------------------------------------------------------------------------------------------

string Property EventLightChanged Hidden
	string Function Get()
		return "ScribeHelmet_EventLightChanged"
	EndFunction
EndProperty



float Property UpdateInterval Hidden
	float Function Get()
		return Interval + Duration
	EndFunction
EndProperty


GlobalVariable Property ScribeHelmet_OptionLightInterval Auto
float Property LightIntervalDefault = 1.0 AutoReadOnly
float Property Interval Hidden
	float Function Get()
		return ScribeHelmet_OptionLightInterval.GetValue()
	EndFunction
	Function Set(float aValue)
		ScribeHelmet_OptionLightInterval.SetValue(aValue)
	EndFunction
EndProperty


GlobalVariable Property ScribeHelmet_OptionLightDuration Auto
float Property DurationDefault = 1.0 AutoReadOnly
float Property Duration Hidden
	float Function Get()
		return ScribeHelmet_OptionLightDuration.GetValue()
	EndFunction
	Function Set(float aValue)
		ScribeHelmet_OptionLightDuration.SetValue(aValue)
	EndFunction
EndProperty


GlobalVariable Property ScribeHelmet_OptionLightStrength Auto
int Property StrengthDefault = 25 AutoReadOnly
int Property Strength Hidden
	int Function Get()
		return ScribeHelmet_OptionLightStrength.GetValueInt()
	EndFunction
	Function Set(int aValue)
		If(aValue < 0)
			aValue = 0
		ElseIf(aValue > 255)
			aValue = 255
		EndIf
		ScribeHelmet_OptionLightStrength.SetValueInt(aValue)
	EndFunction
EndProperty
