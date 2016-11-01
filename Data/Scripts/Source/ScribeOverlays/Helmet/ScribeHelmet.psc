ScriptName ScribeHelmet Extends ScribeOverlay_ViewBase

; View Implementation
;---------------------------------------------------------------------------------------------------

; @implements
Event OnViewReload()
	ScribeOverlay.Log("OnViewReload()", self)
	Camera.OnAliasReload()
	Gear.OnAliasReload()
	Motion.OnAliasReload()
	Lighting.OnAliasReload()
	Menu.OnAliasReload()
	RegisterForModEvent(EventArtError, "OnArtError") 	;@AS2
	RegisterForModEvent(EventArtLoaded, "OnArtLoaded") 	;@AS2
	RegisterForModEvent(Camera.EventCameraChanged, "OnCameraChanged")
	RegisterForModEvent(Gear.EventGearChanged, "OnGearChange")
	RegisterForModEvent(Motion.EventMotionChanged, "OnMotionChanged")
	RegisterForModEvent(Lighting.EventLightChanged, "OnLightChanged")
EndEvent


; @implements
Event OnViewReady()
	ScribeOverlay.Log("OnViewReady()", self)
	If(GetState() != "ACTIVESTATE")
		GoToState("ACTIVESTATE")
	EndIf
	Camera.OnAliasReady()
	Gear.OnAliasReady()
	Motion.OnAliasReady()
	Lighting.OnAliasReady()
	Menu.OnAliasReady()
EndEvent


; @implements
string Function GetViewSource()
	return "overlays/HelmetView.swf"
EndFunction


;@implements
string Function GetViewType()
	return "ScribeHelmet"
EndFunction


;@implements
string[] Function GetHudModes()
	string[] array = new string[8]
	array[0] = "All"
	array[1] = "StealthMode"
	array[2] = "Favor"
	array[3] = "Swimming"
	array[4] = "HorseMode"
	array[5] = "WarHorseMode"
	array[6] = "DialogueMode"
	array[7] = "VATSPlayback"
	return array
EndFunction



; Storage
;---------------------------------------------------------------------------------------------------

Function SaveOptions(string asPathKey, float afSize, float afAlpha, float afInterval, float afDuration, int aiStrength)
	ScribeOverlay.Log("SaveOptions() :: asPathKey="+asPathKey, self)
	string json = StorageDirectory + asPathKey + ".json"
	JsonUtil.SetFloatValue(json, "GearSize", afSize)
	JsonUtil.SetFloatValue(json, "GearAlpha", afAlpha)
	JsonUtil.SetFloatValue(json, "LightInterval", afInterval)
	JsonUtil.SetFloatValue(json, "LightDuration", afDuration)
	JsonUtil.SetFloatValue(json, "LightStrength", aiStrength)
	JsonUtil.Save(json)
EndFunction

; this is just bad
Function SendEvent_RequestOptions(string asPathKey)
	float fArtSize
	float fArtAlpha
	float fLightInterval
	float fLightDuration
	int iLightStrength

	string json = StorageDirectory + asPathKey + ".json"
	If(JsonUtil.Load(json))
		ScribeOverlay.Log("SendEvent_UpdateOptions() :: Sending json options, FilePath="+json, self)
		fArtSize = JsonUtil.GetFloatValue(json, "GearSize")
		fArtAlpha = JsonUtil.GetFloatValue(json, "GearAlpha")
		fLightInterval = JsonUtil.GetFloatValue(json, "LightInterval")
		fLightDuration = JsonUtil.GetFloatValue(json, "LightDuration")
		iLightStrength = JsonUtil.GetFloatValue(json, "LightStrength") as int
	Else
		ScribeOverlay.Log("SendEvent_UpdateOptions() :: Sending common options.", self)
		fArtSize = Gear.Size
		fArtAlpha = Gear.Alpha
		fLightInterval = Lighting.Interval
		fLightDuration = Lighting.Duration
		iLightStrength = Lighting.Strength
	EndIf

	; send results
	int ihandle = ModEvent.Create(EventRequestOptions)
	If(ihandle)
		ModEvent.PushString(ihandle, asPathKey)
		ModEvent.PushFloat(ihandle, fArtSize)
		ModEvent.PushFloat(ihandle, fArtAlpha)
		ModEvent.PushFloat(ihandle, fLightInterval)
		ModEvent.PushFloat(ihandle, fLightDuration)
		ModEvent.PushInt(ihandle, iLightStrength)
		ModEvent.Send(ihandle)
	EndIf
EndFunction



; Active State
;---------------------------------------------------------------------------------------------------

State ACTIVESTATE
	Event OnCameraChanged(bool abFirstPerson)
		ScribeOverlay.Log("OnCameraChanged(abFirstPerson="+abFirstPerson+")", self)
		Armor kEquipped = Gear.GetEquipped()
		If(kEquipped)
			Visible = abFirstPerson
		EndIf
	EndEvent


	Event OnGearChange(Form akForm, string asPathKeyA, string asPathKeyB)
		ScribeOverlay.Log("OnGearChange(asPathKeyA="+asPathKeyA+", asPathKeyB="+asPathKeyB+")", self)
		If(Ready)
			If(akForm)
				Int iHandle = UICallback.Create(HUD_MENU, ViewInstance + ".LoadArt")
				If(iHandle)
					UICallback.PushString(iHandle, asPathKeyA)
					UICallback.PushString(iHandle, asPathKeyB)
					UICallback.Send(iHandle)
				EndIf
				Visible = Camera.IsFirstPerson
			Else
				Visible = false
			EndIf
		EndIf
	EndEvent


	Event OnArtError(string asEventName, string asPathKey, float afNumber, form akSender)
		ScribeOverlay.Log("OnArtError(asArgString="+asPathKey+")", self)
	EndEvent


	Event OnArtLoaded(string asEventName, string asPathKey, float afNumber, form akSender)
		ScribeOverlay.Log("OnArtLoaded() :: asPathKey="+asPathKey, self)

		RegisterForModEvent(EventRequestOptions, "OnRequestOptions")
		SendEvent_RequestOptions(asPathKey)
	EndEvent


	Event OnRequestOptions(string asPathKey, float afArtSize, float afArtAlpha, float afLightInterval, float afLightDuration, int aiLightStrength)
		UnregisterForModEvent(EventRequestOptions)

		Int iHandle = UICallback.Create(HUD_MENU, ViewInstance + ".ApplySettings")
		If(iHandle)
			ScribeOverlay.Log("SendCallback_ApplySettings() :: Sending UICallback ApplySettings", self)
			UICallback.PushString(iHandle, asPathKey)
			UICallback.PushFloat(iHandle, afArtSize)
			UICallback.PushFloat(iHandle, afArtAlpha)
			UICallback.PushFloat(iHandle, afLightDuration)
			UICallback.PushInt(iHandle, aiLightStrength)
			UICallback.Send(iHandle)
		EndIf
	EndEvent


	Event OnMotionChanged(string asFrameLabel)
		ScribeOverlay.Log("OnHelmetMotion("+asFrameLabel+")", self)
		If(Visible && Ready)
			UI.InvokeString(HUD_MENU, ViewInstance + ".ChangeMotion", asFrameLabel)
		EndIf
	EndEvent


	Event OnLightChanged(int aiLightLevel)
		ScribeOverlay.Log("OnLightChanged(aiLightLevel="+aiLightLevel+")", self)
		If(Visible && Ready)
			UI.InvokeFloat(HUD_MENU, ViewInstance + ".ChangeLight", aiLightLevel)
		EndIf
	EndEvent

EndState




; Empty State
;---------------------------------------------------------------------------------------------------

Event OnRequestOptions(string asPathKey, float afArtSize, float afArtAlpha, float afLightInterval, float afLightDuration, int aiLightStrength)
	{Empty State}
EndEvent

Event OnCameraChanged(bool abFirstPerson)
	{Empty State}
EndEvent

Event OnGearChange(Form akForm, string asPathKeyA, string asPathKeyB)
	{Empty State}
EndEvent

Event OnArtError(string asEventName, string asPathKey, float afNumber, form akSender)
	{Empty State}
EndEvent

Event OnArtLoaded(string asEventName, string asPathKey, float afNumber, form akSender)
	{Empty State}
EndEvent

Event OnMotionChanged(string asFrameLabel)
	{Empty State}
EndEvent

Event OnLightChanged(int aiColorChannel)
	{Empty State}
EndEvent



; Property Setters
;---------------------------------------------------------------------------------------------------

Function SetArtSize(float aValue)
	If(Ready)
		ScribeOverlay.Log("SetArtSize() :: aValue="+aValue, self)
		UI.SetFloat(HUD_MENU, ViewInstance + ".ArtSize", aValue)
	EndIf
EndFunction


Function SetArtAlpha(float aValue)
	If(Ready)
		ScribeOverlay.Log("SetArtAlpha() :: aValue="+aValue, self)
		UI.SetFloat(HUD_MENU, ViewInstance + ".ArtAlpha", aValue)
	EndIf
EndFunction


Function SetLightDuration(float aValue)
	If(Ready)
		ScribeOverlay.Log("SetLightDuration() :: aValue="+aValue, self)
		UI.SetFloat(HUD_MENU, ViewInstance + ".LightDuration", aValue)
	EndIf
EndFunction


Function SetLightStrength(int aValue)
	If(Ready)
		ScribeOverlay.Log("SetLightStrength() :: aValue="+aValue, self)
		UI.SetInt(HUD_MENU, ViewInstance + ".LightStrength", aValue)
	EndIf
EndFunction


; Properties
;---------------------------------------------------------------------------------------------------

string Property EventArtError Hidden
	string Function Get()
		return "ScribeHelmet_EventArtError"
	EndFunction
EndProperty


string Property EventArtLoaded Hidden
	string Function Get()
		return "ScribeHelmet_EventArtLoaded"
	EndFunction
EndProperty


string Property EventLightFinished Hidden
	string Function Get()
		return "ScribeHelmet_EventLightFinished"
	EndFunction
EndProperty


string Property EventRequestOptions Hidden
	string Function Get()
		return "ScribeHelmet_EventRequestOptions"
	EndFunction
EndProperty


string Property StorageDirectory Hidden
	string Function Get()
		return "../../../Interface/exported/overlays/"
	EndFunction
EndProperty


ScribeHelmet_AliasGear Property Gear Hidden
	ScribeHelmet_AliasGear Function Get()
		return self.GetAliasByName("Gear") as ScribeHelmet_AliasGear
	EndFunction
EndProperty


ScribeHelmet_AliasCamera Property Camera Hidden
	ScribeHelmet_AliasCamera Function Get()
		return self.GetAliasByName("Camera") as ScribeHelmet_AliasCamera
	EndFunction
EndProperty


ScribeHelmet_AliasMenu Property Menu Hidden
	ScribeHelmet_AliasMenu Function Get()
		return self.GetAliasByName("Menu") as ScribeHelmet_AliasMenu
	EndFunction
EndProperty


ScribeHelmet_AliasMotion Property Motion Hidden
	ScribeHelmet_AliasMotion Function Get()
		return self.GetAliasByName("Motion") as ScribeHelmet_AliasMotion
	EndFunction
EndProperty


ScribeHelmet_AliasLight Property Lighting Hidden
	ScribeHelmet_AliasLight Function Get()
		return self.GetAliasByName("Lighting") as ScribeHelmet_AliasLight
	EndFunction
EndProperty
