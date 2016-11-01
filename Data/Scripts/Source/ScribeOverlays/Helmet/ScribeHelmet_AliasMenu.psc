ScriptName ScribeHelmet_AliasMenu Extends ScribeHelmet_Alias

; Fields
;..................................................
bool Ready = false
Bool IsOpen = false

string currentKey
float userArtSize
float userArtAlpha
float userLightInterval
float userLightDuration
int userLightStrength

string MENUINSTANCE
string MENUFILE

string JOURNAL_MENU
string CUSTOM_MENU

string EVENT_MENUOPEN
string EVENT_MENUCLOSE
string EVENT_SLIDERACCEPTED
string EVENT_SLIDERCANCELED


; Alias Implementation
;---------------------------------------------------------------------------------------------------

;@implement
Event OnGameReload()
	ScribeOverlay.Log("OnGameReload()", self)
	JOURNAL_MENU = "Journal Menu"
	CUSTOM_MENU = "CustomMenu"
	MENUFILE = "scribeoverlays/PanelMenu"
	MENUINSTANCE = "_root.Instance"
	EVENT_MENUOPEN = "ScribeHelmet_MenuOpen"
	EVENT_MENUCLOSE = "ScribeHelmet_MenuClose"
	EVENT_SLIDERACCEPTED = "ScribeHelmet_EventDialogAccepted"
	EVENT_SLIDERCANCELED = "ScribeHelmet_EventDialogCanceled"
EndEvent


;@implement
Event OnAliasReload()
	ScribeOverlay.Log("OnAliasReload()", self)
	UnregisterForAllKeys()
	RegisterForKey(OpenKey)
	RegisterForMenu(JOURNAL_MENU)
EndEvent


;@implement
Event OnAliasReady()
	ScribeOverlay.Log("OnAliasReady()", self)
	SetActive()
	currentKey = ""
	userArtSize = -1.0
	userArtAlpha = -1.0
	userLightInterval = -1.0
	userLightDuration = -1.0
	userLightStrength = -1
	Ready = true
EndEvent


; Active State
;---------------------------------------------------------------------------------------------------

State ACTIVESTATE
	Event OnMenuClose(string menuName)
		ScribeOverlay.Log("OnMenuClose() :: menuName="+menuName, self)
		UnregisterForAllKeys()
		RegisterForKey(OpenKey)
	EndEvent


	Event OnKeyUp(int keyCode, float holdTime)
		ScribeOverlay.Log("OnKeyUp() :: Ready="+Ready+" IsOpen="+IsOpen, self)

		If(Ready && IsOpen == false)
			IsOpen = true
			RegisterForModEvent(EVENT_MENUOPEN, "OnPanelOpened")
			RegisterForModEvent(EVENT_MENUCLOSE, "OnPanelClosed")
			RegisterForModEvent(EVENT_SLIDERACCEPTED, "OnSliderAccepted")
			RegisterForModEvent(EVENT_SLIDERCANCELED, "OnSliderCanceled")

			UI.OpenCustomMenu(MENUFILE)

			While(IsOpen)
				Utility.WaitMenuMode(0.1)
			EndWhile

			UnregisterForModEvent(EVENT_MENUOPEN)
			UnregisterForModEvent(EVENT_MENUCLOSE)
			UnregisterForModEvent(EVENT_SLIDERACCEPTED)
			UnregisterForModEvent(EVENT_SLIDERCANCELED)
		EndIf
	EndEvent



	Event OnPanelOpened(String asEventName, String asStringArg, Float afNumArg, Form akSender)
		ScribeOverlay.Log("OnPanelOpened()", self)

		currentKey = Helmet.Gear.CurrentKey
		RegisterForModEvent(Helmet.EventRequestOptions, "OnRequestOptions") ; @Helmet
		Helmet.SendEvent_RequestOptions(currentKey)
	EndEvent



	Event OnRequestOptions(string asPathKey, float afArtSize, float afArtAlpha, float afLightInterval, float afLightDuration, int aiLightStrength)
		ScribeOverlay.Log("OnRequestOptions() :: asPathKey="+asPathKey, self)

		UnregisterForModEvent(Helmet.EventRequestOptions)

		If(IsOpen)
			Int iSetupMenu = UICallback.Create(CUSTOM_MENU, MENUINSTANCE + ".SetupMenu")
			If(iSetupMenu)
				UICallback.PushInt(iSetupMenu, (Game.UsingGamepad() as Int))
				UICallback.PushString(iSetupMenu, Helmet.Gear.GetEquipped().GetName())
				UICallback.PushString(iSetupMenu, asPathKey)
				UICallback.Send(iSetupMenu)
			EndIf

			Int iSetupOptions = UICallback.Create(CUSTOM_MENU, MENUINSTANCE + ".SetupOptions")
			If(iSetupOptions)
				userArtSize = afArtSize
				userArtAlpha = afArtAlpha
				userLightInterval = afLightInterval
				userLightDuration = afLightDuration
				userLightStrength = aiLightStrength

				UICallback.PushFloat(iSetupOptions, afArtSize)
				UICallback.PushFloat(iSetupOptions, afArtAlpha)
				UICallback.PushFloat(iSetupOptions, afLightInterval)
				UICallback.PushFloat(iSetupOptions, afLightDuration)
				UICallback.PushFloat(iSetupOptions, aiLightStrength)
				UICallback.Send(iSetupOptions)
			EndIf
		EndIf
	EndEvent



	Event OnSliderCanceled(String asEventName, String asOptionID, Float afNumber, Form akSender)
		ScribeOverlay.Log("OnSliderCanceled(asEventName="+asEventName+", asOptionID="+asOptionID+")", self, false)
	EndEvent



	Event OnSliderAccepted(String asEventName, String asOptionID, Float afSliderValue, Form akSender)
		ScribeOverlay.Log("OnSliderAccepted() :: asOptionID="+asOptionID, self)

		If(asOptionID == "GearSize")
			userArtSize = afSliderValue							; update local
			Helmet.Gear.Size = userArtSize						; update alias
			Helmet.SetArtSize(userArtSize) 						; update view
			ScribeOverlay.Log("OnSliderAccepted(asEventName="+asEventName+", asOptionID="+asOptionID+", userArtSize="+userArtSize+") ", self, false)

		ElseIf(asOptionID == "GearAlpha")
			userArtAlpha = afSliderValue						; update local
			Helmet.Gear.Alpha = userArtAlpha					; update alias
			Helmet.SetArtAlpha(userArtAlpha)					; update view
			ScribeOverlay.Log("OnSliderAccepted(asEventName="+asEventName+", asOptionID="+asOptionID+", userArtAlpha="+userArtAlpha+") ", self, false)

		ElseIf(asOptionID == "LightInterval")
			userLightInterval = afSliderValue 					; update local
			Helmet.Lighting.Interval = userLightInterval		; update alias
			ScribeOverlay.Log("OnSliderAccepted(asEventName="+asEventName+", asOptionID="+asOptionID+", userLightInterval="+userLightInterval+") ", self, false)

		ElseIf(asOptionID == "LightDuration")
			userLightDuration = afSliderValue					; update local
			Helmet.SetLightDuration(userLightDuration)			; update view
			ScribeOverlay.Log("OnSliderAccepted(asEventName="+asEventName+", asOptionID="+asOptionID+", userLightDuration="+userLightDuration+") ", self, false)

		ElseIf(asOptionID == "LightStrength")
			userLightStrength = afSliderValue as int 			; update local
			Helmet.SetLightStrength(userLightStrength) 			; update view ; TODO: this will TRUNACATE the value!
			ScribeOverlay.Log("OnSliderAccepted(asEventName="+asEventName+", asOptionID="+asOptionID+", userLightStrength="+userLightStrength+") ", self, false)

		EndIf
	EndEvent



	Event OnPanelClosed(String asEventName, String asPathKey, Float afHasChanged, Form akSender)
		ScribeOverlay.Log("OnSliderAccepted() :: asPathKey="+asPathKey, self)

		If(asEventName == EVENT_MENUCLOSE)
			; Panel closed will save a file no matter what
			; Save user options to overlay config file for current key
			Helmet.SaveOptions(Helmet.Gear.CurrentKey, userArtSize, userArtAlpha, userLightInterval, userLightDuration, userLightStrength)

			; clear this values
			currentKey = ""
			userArtSize = -1.0
			userArtAlpha = -1.0
			userLightInterval = -1.0
			userLightDuration = -1.0
			userLightStrength = -1

			IsOpen = false ; unlock input key for new panel menu
		EndIf
	EndEvent


	Event OnEndState()
		ScribeOverlay.Log("OnEndState()", self)
		Ready = false
		UnregisterForAllMenus()
		UnregisterForAllKeys()
		UI.CloseCustomMenu()
	EndEvent
EndState




; Empty State
;---------------------------------------------------------------------------------------------------

Event OnRequestOptions(string asPathKey, float afArtSize, float afArtAlpha, float afLightInterval, float afLightDuration, int aiLightStrength)
	{Empty State}
EndEvent

Event OnPanelOpened(String asEventName, String asString, Float afNumber, Form akSender)
	{empty state}
EndEvent

Event OnPanelClosed(String asEventName, String asString, Float afNumber, Form akSender)
	{empty state}
EndEvent

Event OnSliderAccepted(String asEventName, String asOptionID, Float afSliderValue, Form akSender)
	{empty state}
EndEvent

Event OnSliderCanceled(String asEventName, String asOptionID, Float afNumber, Form akSender)
	{empty state}
EndEvent


; Properties
;---------------------------------------------------------------------------------------------------

GlobalVariable Property ScribeHelmet_MenuOpenKey Auto
int Property OpenKeyDefault = 211 AutoReadOnly ; del
int Property OpenKey Hidden
	int Function Get()
		return ScribeHelmet_MenuOpenKey.GetValueInt()
	EndFunction
	Function Set(int aValue)
		ScribeHelmet_MenuOpenKey.SetValueInt(aValue)
	EndFunction
EndProperty

