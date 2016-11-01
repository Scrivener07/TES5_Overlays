Scriptname ScribeHelmet_MCM extends SKI_ConfigBase

ScribeHelmet Helmet

string PAGE_SETTINGS
string PAGE_ABOUT
string OPTION_OPENMENU_KEYMAPSTATE
string OPTION_ARTALPHA_SLIDERSTATE
string OPTION_ARTSIZE_SLIDERSTATE
string OPTION_LIGHTINGENABLED_TOGGLESTATE
string OPTION_LIGHTINGSTRENGTH_SLIDERSTATE
string OPTION_LIGHTINGDURATION_SLIDERSTATE
string OPTION_LIGHTINGINTERVAL_SLIDERSTATE
string CONTENT_SPLASH


; MCM Implementation
;---------------------------------------------------------------------------------------------------

;@implements
Event OnConfigInit()
	ScribeOverlay.Log("OnConfigInit()", self)
	PAGE_SETTINGS = "Settings"
	OPTION_OPENMENU_KEYMAPSTATE = "OPTION_OPENMENU_KEYMAPSTATE"
	OPTION_ARTALPHA_SLIDERSTATE = "OPTION_ARTALPHA_SLIDERSTATE"
	OPTION_ARTSIZE_SLIDERSTATE = "OPTION_ARTSIZE_SLIDERSTATE"
	OPTION_LIGHTINGENABLED_TOGGLESTATE = "OPTION_LIGHTINGENABLED_TOGGLESTATE"
	OPTION_LIGHTINGSTRENGTH_SLIDERSTATE = "OPTION_LIGHTINGSTRENGTH_SLIDERSTATE"
	OPTION_LIGHTINGDURATION_SLIDERSTATE = "OPTION_LIGHTINGDURATION_SLIDERSTATE"
	OPTION_LIGHTINGINTERVAL_SLIDERSTATE = "OPTION_LIGHTINGINTERVAL_SLIDERSTATE"
	CONTENT_SPLASH = "scribeoverlays/splash.dds"
	ModName = ScribeOverlay.GetName()
	Pages = new string[1]
	Pages[0] = PAGE_SETTINGS
	Pages[1] = PAGE_ABOUT
	Helmet = ScribeOverlay.GetHelmet()
EndEvent


;@implements
Event OnConfigClose()
	ScribeOverlay.Log("OnConfigClose()", self)
EndEvent


;@implements
Event OnPageReset(string page)
	If (!page)
		LoadCustomContent(CONTENT_SPLASH, 0, 0)
		return
	Else
		UnloadCustomContent()
	EndIf

	If (page == PAGE_SETTINGS)
		SetCursorFillMode(TOP_TO_BOTTOM)
		SetCursorPosition(0)

		AddKeyMapOptionST(OPTION_OPENMENU_KEYMAPSTATE, "Open Menu", Helmet.Menu.OpenKey)

		AddHeaderOption("Art", OPTION_FLAG_NONE)
		AddSliderOptionST(OPTION_ARTALPHA_SLIDERSTATE, "Alpha", Helmet.Gear.Alpha, "{0}%")
		AddSliderOptionST(OPTION_ARTSIZE_SLIDERSTATE, "Size", Helmet.Gear.Size, "{0}")

		AddHeaderOption("Lighting", OPTION_FLAG_NONE)
		AddToggleOptionST(OPTION_LIGHTINGENABLED_TOGGLESTATE, "Enable", Helmet.Lighting.IsActive)
		AddSliderOptionST(OPTION_LIGHTINGINTERVAL_SLIDERSTATE, "Interval", Helmet.Lighting.Interval, "{2}")
		AddSliderOptionST(OPTION_LIGHTINGDURATION_SLIDERSTATE, "Duration", Helmet.Lighting.Duration, "{2}")
		AddSliderOptionST(OPTION_LIGHTINGSTRENGTH_SLIDERSTATE, "Strength", Helmet.Lighting.Strength, "{0}")
	EndIf
EndEvent


string Function GetCustomControl(int keyCode)
	If(keyCode == Helmet.Menu.OpenKey)
		return "Open Menu"
	EndIF
	return ""
EndFunction


bool Function PromptKeyConflict(string a_conflictControl, string a_conflictName)
	bool continue = true
	if (a_conflictControl != "")
		string msg
		if (a_conflictName != "")
			msg = "This key is already mapped to:\n\"" + a_conflictControl + "\"\n(" + a_conflictName + ")\n\nAre you sure you want to continue?"
		else
			msg = "This key is already mapped to:\n\"" + a_conflictControl + "\"\n\nAre you sure you want to continue?"
		endIf
		continue = ShowMessage(msg, true, "$Yes", "$No")
	endIf
	return continue
EndFunction


; Options
;---------------------------------------------------------------------------------------------------

State OPTION_OPENMENU_KEYMAPSTATE
	Event OnKeyMapChangeST(int a_keyCode, string a_conflictControl, string a_conflictName)
		if(PromptKeyConflict(a_conflictControl, a_conflictName))
			Helmet.Menu.OpenKey = a_keyCode
			SetKeyMapOptionValueST(a_keyCode, false, OPTION_OPENMENU_KEYMAPSTATE)
		endIf
	EndEvent

	Event OnDefaultST()
		SetKeyMapOptionValueST(Helmet.Menu.OpenKeyDefault, false, OPTION_OPENMENU_KEYMAPSTATE)
	EndEvent

	Event OnHighlightST()
		SetInfoText("Press this hotkey to customize your equipped helmet.")
	EndEvent
EndState


State OPTION_ARTALPHA_SLIDERSTATE ; SLIDER
	Event OnSliderOpenST()
		SetSliderDialogStartValue(Helmet.Gear.Alpha)
		SetSliderDialogDefaultValue(Helmet.Gear.AlphaDefault)
		SetSliderDialogRange(1.0, 100.0)
		SetSliderDialogInterval(1.0)
	Endevent
	Event OnSliderAcceptST(float value)
		Helmet.Gear.Alpha = value
		SetSliderOptionValueST(Helmet.Gear.Alpha, "{0}%")
	Endevent
	Event OnDefaultST()
		Helmet.Gear.Alpha = Helmet.Gear.AlphaDefault
		SetSliderOptionValueST(Helmet.Gear.Alpha, "{0}%")
	Endevent
	Event OnHighlightST()
		SetInfoText("Change the art transparency to an amount.")
	Endevent
EndState


State OPTION_ARTSIZE_SLIDERSTATE ; SLIDER
	Event OnSliderOpenST()
		SetSliderDialogStartValue(Helmet.Gear.Size)
		SetSliderDialogDefaultValue(Helmet.Gear.SizeDefault)
		SetSliderDialogRange(0, 5000)
		SetSliderDialogInterval(1.0)
	Endevent
	Event OnSliderAcceptST(float value)
		Helmet.Gear.Size = value
		SetSliderOptionValueST(Helmet.Gear.Size, "{0}")
	Endevent
	Event OnDefaultST()
		Helmet.Gear.Size = Helmet.Gear.SizeDefault
		SetSliderOptionValueST(Helmet.Gear.Size, "{0}")
	Endevent
	Event OnHighlightST()
		SetInfoText("Modify the art size by an amount.")
	Endevent
EndState


State OPTION_LIGHTINGENABLED_TOGGLESTATE ; TOGGLE
	Event OnSelectST()
		Helmet.Lighting.SetActive(!Helmet.Lighting.IsActive)
		SetToggleOptionValueST(Helmet.Lighting.IsActive)
		ForcePageReset()
	EndEvent
	Event OnHighlightST()
		SetInfoText("Enables reactive lighting on overlay art.")
	EndEvent
EndState


State OPTION_LIGHTINGINTERVAL_SLIDERSTATE ; SLIDER
	Event OnSliderOpenST()
		SetSliderDialogStartValue(Helmet.Lighting.Interval)
		SetSliderDialogDefaultValue(Helmet.Lighting.LightIntervalDefault)
		SetSliderDialogRange(0.1, 10.0)
		SetSliderDialogInterval(0.1)
	Endevent
	Event OnSliderAcceptST(float value)
		Helmet.Lighting.Interval = value
		SetSliderOptionValueST(Helmet.Lighting.Interval, "{2}")
	Endevent
	Event OnDefaultST()
		Helmet.Lighting.Interval = Helmet.Lighting.LightIntervalDefault
		SetSliderOptionValueST(Helmet.Lighting.Interval, "{2}")
	Endevent
	Event OnHighlightST()
		SetInfoText("Changes how often the lighting will attempt to update.\nContributes ["+Helmet.Lighting.Interval+"] to the update interval ["+UpdateInterval+"].")
	Endevent
EndState


State OPTION_LIGHTINGDURATION_SLIDERSTATE ; SLIDER
	Event OnSliderOpenST()
		SetSliderDialogStartValue(Helmet.Lighting.Duration)
		SetSliderDialogDefaultValue(Helmet.Lighting.DurationDefault)
		SetSliderDialogRange(0.1, 10.0)
		SetSliderDialogInterval(0.1)
	Endevent
	Event OnSliderAcceptST(float value)
		Helmet.Lighting.Duration = value
		SetSliderOptionValueST(Helmet.Lighting.Duration, "{2}")
	Endevent
	Event OnDefaultST()
		Helmet.Lighting.Duration = Helmet.Lighting.DurationDefault
		SetSliderOptionValueST(Helmet.Lighting.Duration, "{2}")
	Endevent
	Event OnHighlightST()
		SetInfoText("The amount of time it takes to tween from one light level to another.\nContributes ["+Helmet.Lighting.Duration+"] to the update interval ["+UpdateInterval+"].")
	Endevent
EndState


State OPTION_LIGHTINGSTRENGTH_SLIDERSTATE ; SLIDER
	Event OnSliderOpenST()
		SetSliderDialogStartValue(Helmet.Lighting.Strength)
		SetSliderDialogDefaultValue(Helmet.Lighting.StrengthDefault)
		SetSliderDialogRange(0, 150)
		SetSliderDialogInterval(1.0)
	Endevent
	Event OnSliderAcceptST(float value)
		Helmet.Lighting.Strength = value as int
		SetSliderOptionValueST(Helmet.Lighting.Strength, "{0}")
	Endevent
	Event OnDefaultST()
		Helmet.Lighting.Strength = Helmet.Lighting.StrengthDefault
		SetSliderOptionValueST(Helmet.Lighting.Strength, "{0}")
	Endevent
	Event OnHighlightST()
		SetInfoText("Adjust the strength of the overlay darkness.")
	Endevent
EndState

; Properties
;---------------------------------------------------------------------------------------------------

float Property UpdateInterval
	float Function Get()
		return Helmet.Lighting.Interval + Helmet.Lighting.Duration
	EndFunction
EndProperty
