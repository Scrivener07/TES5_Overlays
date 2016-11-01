ScriptName ScribeHelmet_AliasMotion Extends ScribeHelmet_Alias

; Fields
;..................................................
string JUMPUP_ANIMA
string SPRINT_ANIMA
string SPRINTEND_ANIMA
string HORSEDISMOUNT_ANIMA
string HORSEIDLE_ANIMA
string HORSELOCO_ANIMA
string HORSESPRINT_ANIMA
string HORSEJUMP_ANIMA
string STRAFELEFT_CONTROL
string STRAFERIGHT_CONTROL



; Alias Implementation
;---------------------------------------------------------------------------------------------------

;@implement
Event OnGameReload()
	ScribeOverlay.Log("OnGameReload()", self)
	JUMPUP_ANIMA = "JumpUp"
	SPRINT_ANIMA = "tailSprint"
	SPRINTEND_ANIMA = "EndAnimatedCameraDelta"
	HORSEDISMOUNT_ANIMA = "tailHorseDismount"
	HORSEIDLE_ANIMA = "HorseIdle"
	HORSELOCO_ANIMA = "HorseLocomotion"
	HORSESPRINT_ANIMA = "HorseSprint"
	HORSEJUMP_ANIMA = "JumpBegin"
	STRAFELEFT_CONTROL = "Strafe Left"
	STRAFERIGHT_CONTROL = "Strafe Right"
EndEvent


;@implement
Event OnAliasReload()
	ScribeOverlay.Log("OnAliasReload()", self)
	RegisterForControl(STRAFELEFT_CONTROL)
	RegisterForControl(STRAFERIGHT_CONTROL)
	RegisterForAnimationEvent(Player, JUMPUP_ANIMA)
	RegisterForAnimationEvent(Player, SPRINT_ANIMA)
	RegisterForAnimationEvent(Player, SPRINTEND_ANIMA)
	RegisterForAnimationEvent(Player, HORSEIDLE_ANIMA)
	RegisterForAnimationEvent(Player, HORSESPRINT_ANIMA)
	RegisterForAnimationEvent(Player, HORSELOCO_ANIMA)
	RegisterForAnimationEvent(Player, HORSEJUMP_ANIMA)
	RegisterForAnimationEvent(Player, HORSEDISMOUNT_ANIMA)
EndEvent


;@implement
Event OnAliasReady()
	ScribeOverlay.Log("OnAliasReady()", self)
	SetActive()
EndEvent


; Active State
;---------------------------------------------------------------------------------------------------

State ACTIVESTATE
	Event OnAnimationEventUnregistered(ObjectReference akSource, string asEventName)
		ScribeOverlay.Log("OnAnimationEventUnregistered() :: Re-registering " + asEventName, self)
		RegisterForAnimationEvent(Player, asEventName)
	EndEvent


	Event OnAnimationEvent(ObjectReference akSource, string asEventName)
		ScribeOverlay.Log("OnAnimationEvent() :: asEventName="+asEventName, self)
		If(asEventName == SPRINTEND_ANIMA || asEventName == HORSEIDLE_ANIMA || asEventName == HORSEDISMOUNT_ANIMA)
			SendEvent_MotionChanged("Idle")
		ElseIf(asEventName == JUMPUP_ANIMA || asEventName == HORSEJUMP_ANIMA)
			SendEvent_MotionChanged("Jump")
		ElseIf(asEventName == SPRINT_ANIMA)
			SendEvent_MotionChanged("Sprint")
		ElseIf(asEventName == HORSELOCO_ANIMA)
			SendEvent_MotionChanged("HorseMove")
		ElseIf(asEventName == HORSESPRINT_ANIMA)
			SendEvent_MotionChanged("HorseSprint")
		EndIf
	EndEvent


	Event OnControlDown(string asControl)
		If(AllowInput)
			ScribeOverlay.Log("OnControlDown() :: asControl="+asControl, self)
			If(asControl == STRAFELEFT_CONTROL)
				SendEvent_MotionChanged("MoveLeft")
			ElseIf(asControl == STRAFERIGHT_CONTROL)
				SendEvent_MotionChanged("MoveRight")
			EndIf

			If(Player.IsOnMount())
				Utility.Wait(1.0)
				Actor horse = Game.GetPlayersLastRiddenHorse()
				If(horse.IsSprinting())
					SendEvent_MotionChanged("HorseSprint")
				ElseIf(horse.IsRunning())
					SendEvent_MotionChanged("HorseMove")
				Else
					SendEvent_MotionChanged("Idle")
				EndIf
			EndIf
		EndIf
	EndEvent


	Event OnEndState()
		ScribeOverlay.Log("OnEndState()", self)
		UnregisterForAllControls()
		UnregisterForAnimationEvent(Player, JUMPUP_ANIMA)
		UnregisterForAnimationEvent(Player, SPRINT_ANIMA)
		UnregisterForAnimationEvent(Player, SPRINTEND_ANIMA)
		UnregisterForAnimationEvent(Player, HORSEIDLE_ANIMA)
		UnregisterForAnimationEvent(Player, HORSELOCO_ANIMA)
		UnregisterForAnimationEvent(Player, HORSESPRINT_ANIMA)
		UnregisterForAnimationEvent(Player, HORSEJUMP_ANIMA)
		UnregisterForAnimationEvent(Player, HORSEDISMOUNT_ANIMA)
	EndEvent
EndState




; Methods
;---------------------------------------------------------------------------------------------------

Function SendEvent_MotionChanged(string asFrameLabel)
	ScribeOverlay.Log("SendEvent_MotionChanged(asFrameLabel="+asFrameLabel+")", self)
	int ihandle = ModEvent.Create(EventMotionChanged)
	If(ihandle)
		ModEvent.PushString(ihandle, asFrameLabel)
		ModEvent.Send(ihandle)
	EndIf
EndFunction



; Properties
;---------------------------------------------------------------------------------------------------

string Property EventMotionChanged Hidden
	string Function Get()
		return "ScribeHelmet_EventMotionChanged"
	EndFunction
EndProperty
