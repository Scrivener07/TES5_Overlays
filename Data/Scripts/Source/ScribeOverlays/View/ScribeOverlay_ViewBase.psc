ScriptName ScribeOverlay_ViewBase Extends ScribeOverlay_Quest Hidden

ScribeOverlay_ViewManager ViewManager

bool				_initialized		= false
bool				_ready				= false
int					_viewID				= -1
string				_viewInstance		= ""
bool 				_visible 			= true
float				_alpha				= 100.0
float				_width				= 1280.0
float				_height				= 720.0
float				_x					= 0.0
float				_y					= 0.0
string[]			_modes


; Constants
;..................................................
string Property	HUD_MENU = "HUD Menu" AutoReadOnly


; Initialize
;---------------------------------------------------------------------------------------------------

Event OnInit()
	OnGameReload()
EndEvent


; @implements
Event OnGameReload()
	_ready = false
	RegisterForModEvent("ScribeOverlay_EventManagerReady", "OnManagerReady")
	If(!IsExtending() && RequireExtend)
		Debug.MessageBox("WARNING!\n" + self as string + " must extend a base script type.")
		ScribeOverlay.Log("WARNING! Must extend a base script type.", self)
	EndIf
	If(!_initialized)
		_initialized = true
		If(!_modes)
			_modes = GetHudModes()
		EndIf
		OnViewReload()
	EndIf
EndEvent


; @ScribeOverlay_ViewManager.psc
Event OnManagerReady(string a_eventName, string a_strArg, float a_numArg, Form akViewManager)
	{Register this}
	ScribeOverlay_ViewManager newManager = akViewManager as ScribeOverlay_ViewManager

	If(ViewManager == newManager)
		return ; Already registered
	EndIf

	ViewManager = newManager
	_viewID = ViewManager.RequestViewID(self)

	If(_viewID != -1)
		_viewInstance = ViewManager.CreateView(_viewID, GetViewSource())
	else
		ScribeOverlay.Log("Warning: could not be loaded, too many hud views. Max is 128", self)
		return
	EndIf

	ScribeOverlay.Log("OnManagerReady() :: _viewInstance="+_viewInstance, self)
EndEvent


; @ScribeOverlay_ViewManager.psc
Event OnViewBase()
	{Called after each game reload by ViewManager.}
	UI.InvokeString(HUD_MENU, ViewInstance + ".setClientInfo", self as string)
	_ready = true
	; view properties
	Visible = _visible
 	Alpha = _alpha
 	Width = _width
 	Height = _height
 	X = _x
	Y = _y
	Modes = _modes ; LAST, Reset base properties except modes to prevent view from being drawn too early.
	ScribeOverlay.Log("OnClientReady() :: ViewInstance=" + ViewInstance, self)
	OnViewReady() ; kick api
EndEvent




; Interface
;---------------------------------------------------------------------------------------------------

; @interface
Event OnViewReload()
	{Implement event to handle any custom view initialization}
EndEvent


; @interface
Event OnViewReady()
	{Implement event to handle view ready}
EndEvent


; @interface
string Function GetViewSource()
	{Implement and set to be the same as swf name}
	return ""
EndFunction


; @interface
string Function GetViewType()
	{Implement and set to be the same as scriptname}
	return ""
EndFunction


; @interface
string[] Function GetHudModes()
	{Implement and set to change default hud modes.}
	_modes = new string[6]
	_modes[0] = "All"
	_modes[1] = "StealthMode"
	_modes[2] = "Favor"
	_modes[3] = "Swimming"
	_modes[4] = "HorseMode"
	_modes[5] = "WarHorseMode"
	return _modes
EndFunction



; Methods
;---------------------------------------------------------------------------------------------------

float[] Function GetDimensions()
	{Return the dimensions of the view (width,height).}
	float[] dim = new float[2]
	dim[0] = Width
	dim[1] = Height
	return dim
EndFunction


bool Function IsExtending()
	string s = self as string
	string sn = GetViewType() + " "
	s = StringUtil.Substring(s, 1, StringUtil.GetLength(sn))
	If (s == sn)
		return false
	EndIf
	return true
EndFunction


Function FadeTo(float a_alpha, float a_duration)
	{Fades the view to a new alpha over time}
	float[] args = new float[2]
	args[0] = a_alpha
	args[1] = a_duration
	UI.InvokeFloatA(HUD_MENU, ViewInstance + ".fadeTo", args)
EndFunction




; Properties
;---------------------------------------------------------------------------------------------------

; @required
string Property ViewName = "I-forgot-to-set-the-view name" auto
{Name of the view. Used to identify it in the user interface.}


; @required
bool Property RequireExtend	= true	auto
{Require extending the view type instead of using it directly.}


bool Property Ready
	{True once the view has registered. ReadOnly}
	bool Function get()
		return _ready
	EndFunction
EndProperty


int Property ViewID
	{Unique ID of the view. ReadOnly}
	int Function get()
		return _viewID
	EndFunction
EndProperty


string Property ViewInstance
	{Path to the root of the view from _root of HudMenu. ReadOnly}
	string Function get()
		return _viewInstance
	EndFunction
EndProperty


string[] Property Modes Hidden
	{HUDModes in which the view is visible, see readme for available modes}
	string[] Function get()
		return _modes
	EndFunction
	Function set(string[] value)
		_modes = value
		If(Ready)
			UI.InvokeStringA(HUD_MENU, ViewInstance + ".setModes", value)
		EndIf
	EndFunction
EndProperty


bool Property Visible Hidden
	{whether or not the view is visible or not. Default: true}
	bool Function get()
		return _visible
	EndFunction
	Function set(bool value)
		_visible = value
		If(Ready)
			UI.SetBool(HUD_MENU, ViewInstance + ".Visible", value)
		EndIf
	EndFunction
EndProperty


float Property Alpha Hidden
	{Opacity of the view [0.0, 100.0]. Default: 100.0}
	float Function get()
		return _alpha
	EndFunction
	Function set(float value)
		_alpha = value
		If(Ready)
			UI.SetFloat(HUD_MENU, ViewInstance + ".Alpha", value)
		EndIf
	EndFunction
EndProperty


float Property X Hidden
	{Horizontal position of the view in pixels at a resolution of 1280x720 [0.0, 1280.0]. Default: 0.0}
	float Function get()
		return _x
	EndFunction
	Function set(float value)
		_x = value
		If(Ready)
			UI.SetFloat(HUD_MENU, ViewInstance + ".X", value)
		EndIf
	EndFunction
EndProperty


float Property Y Hidden
	{Vertical position of the view in pixels at a resolution of 1280x720 [0.0, 720.0]. Default: 0.0}
	float Function get()
		return _y
	EndFunction
	Function set(float value)
		_y = value
		If(Ready)
			UI.SetFloat(HUD_MENU, ViewInstance + ".Y", value)
		EndIf
	EndFunction
EndProperty


float Property Width Hidden
	{Horizontal position of the view in pixels at a resolution of 1280x720 [0.0, 1280.0]. Default: 0.0}
	float Function get()
		return _width
	EndFunction
	Function set(float value)
		_width = value
		If(Ready)
			UI.SetFloat(HUD_MENU, ViewInstance + ".Width", value)
		EndIf
	EndFunction
EndProperty


float Property Height Hidden
	{Vertical position of the view in pixels at a resolution of 1280x720 [0.0, 720.0]. Default: 0.0}
	float Function get()
		return _height
	EndFunction
	Function set(float value)
		_height = value
		If(Ready)
			UI.SetFloat(HUD_MENU, ViewInstance + ".Height", value)
		EndIf
	EndFunction
EndProperty
