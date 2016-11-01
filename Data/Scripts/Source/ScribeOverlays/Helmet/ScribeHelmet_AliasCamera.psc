ScriptName ScribeHelmet_AliasCamera Extends ScribeHelmet_Alias


; Fields
;..................................................
bool FirstPerson = false
int FIRSTPERSON_CAM = 0
int THIRDPERSON2_CAM = 9
int HORSE_CAM = 10
string IFPV_ENTERINGVIEW_EVENT
string IFPV_LEAVINGVIEW_EVENT


; Alias Implementation
;---------------------------------------------------------------------------------------------------

;@implement
Event OnGameReload()
	ScribeOverlay.Log("OnGameReload()", self)
	IFPV_ENTERINGVIEW_EVENT = "IFPV_EnteringView"
	IFPV_LEAVINGVIEW_EVENT = "IFPV_LeavingView"
EndEvent


;@implement
Event OnAliasReload()
	ScribeOverlay.Log("OnAliasReload()", self)

	UnregisterForModEvent(IFPV_ENTERINGVIEW_EVENT)
	UnregisterForModEvent(IFPV_LEAVINGVIEW_EVENT)
	UnregisterForCameraState()
	UnregisterForControl(TogglePOV)

	If(HasEnhancedCamera)
		RegisterforCameraState()
		RegisterForControl(TogglePOV)
	ElseIf(HasIFPV)
		RegisterForModEvent(IFPV_ENTERINGVIEW_EVENT, "OnIFPV")
		RegisterForModEvent(IFPV_LEAVINGVIEW_EVENT, "OnIFPV")
		IFPV.SetBoolValue("bSendModEvents", true)
	Else
		RegisterforCameraState()
	EndIf
EndEvent


;@implement
Event OnAliasReady()
	ScribeOverlay.Log("OnAliasReady()", self)
	SetActive()
EndEvent






; Active State
;---------------------------------------------------------------------------------------------------

State ACTIVESTATE
	Event OnPlayerCameraState(int oldState, int newState)
		ScribeOverlay.Log("OnPlayerCameraState(oldState="+oldState+", newState="+newState+")", self)
		If(newState == FIRSTPERSON_CAM)
			FirstPerson = true
			SendEvent_CameraChanged(FirstPerson)
			return
		ElseIf(newState == THIRDPERSON2_CAM)
			FirstPerson = false
			SendEvent_CameraChanged(FirstPerson)
			return
		EndIf

		If(newState == HORSE_CAM && oldState == FIRSTPERSON_CAM)
			If(HasEnhancedCamera)
				FirstPerson = true
				SendEvent_CameraChanged(FirstPerson)
			Else
				FirstPerson = false
				SendEvent_CameraChanged(FirstPerson)
			EndIf
		EndIf
	EndEvent


	Event OnControlUp(string asControl, float afHoldTime)
		ScribeOverlay.Log("OnControlUp() :: asControl="+asControl, self, true)
		If(AllowInput)
			If(HasEnhancedCamera && Game.GetCameraState() == HORSE_CAM)
				FirstPerson = !FirstPerson
				SendEvent_CameraChanged(FirstPerson)
			EndIf
		EndIf
	EndEvent


	Event OnIFPV(String eventName, String strArg, Float numArg, Form sender)
		ScribeOverlay.Log("OnIFPV(eventName="+eventName+")", self)
		If(eventName == IFPV_ENTERINGVIEW_EVENT)
			FirstPerson = true
			SendEvent_CameraChanged(FirstPerson)
			return
		ElseIf(eventName == IFPV_LEAVINGVIEW_EVENT)
			FirstPerson = false
			SendEvent_CameraChanged(FirstPerson)
			return
		EndIf
	EndEvent


	Event OnEndState()
		ScribeOverlay.Log("OnEndState()", self)
		UnregisterForCameraState()
		UnregisterForAllControls()
		UnregisterForModEvent(IFPV_ENTERINGVIEW_EVENT)
		UnregisterForModEvent(IFPV_LEAVINGVIEW_EVENT)
	EndEvent
EndState



; Empty State
;---------------------------------------------------------------------------------------------------

Event OnIFPV(String eventName, String strArg, Float numArg, Form sender)
	{Empty State}
EndEvent



; Methods
;---------------------------------------------------------------------------------------------------

Function SendEvent_CameraChanged(bool abFirstPerson)
	ScribeOverlay.Log("SendEvent_CameraChanged(abFirstPerson="+abFirstPerson+")", self)
	int ihandle = ModEvent.Create(EventCameraChanged)
	If(ihandle)
		ModEvent.PushBool(ihandle, abFirstPerson)
		ModEvent.Send(ihandle)
	EndIf
EndFunction


; Properties
;---------------------------------------------------------------------------------------------------

string Property EventCameraChanged Hidden
	string Function Get()
		return "ScribeHelmet_EventCameraChanged"
	EndFunction
EndProperty

bool Property IsFirstPerson
	bool Function Get()
		return  FirstPerson || Game.GetCameraState() == FIRSTPERSON_CAM
	EndFunction
EndProperty


string Property TogglePOV
	string Function Get()
		return "Toggle POV"
	EndFunction
EndProperty


bool Property HasIFPV
	bool Function Get()
		return SKSE.GetPluginVersion("firstperson plugin") != -1 && IFPV.GetVersion()
	EndFunction
EndProperty


bool Property HasEnhancedCamera
	bool Function Get()
		return SKSE.GetPluginVersion("EnhancedCamera") != -1
	EndFunction
EndProperty
