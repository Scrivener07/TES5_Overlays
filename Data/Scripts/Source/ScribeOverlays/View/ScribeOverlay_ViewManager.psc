ScriptName ScribeOverlay_ViewManager Extends ScribeOverlay_Quest

; Client Path "_root.ViewLoader.Instance.ViewContainer.#.view"

ScribeOverlay_ViewBase[] _clients

string[] _viewsources
int _curViewID	= 0
int _viewCount	= 0


; Constants
;..................................................
string Property HUD_MENU 		= "HUD Menu" AutoReadOnly
string Property LOADER_NAME 	= "ViewLoader" AutoReadOnly
string Property VIEW_CONTAINER 	= "ViewContainer" AutoReadOnly

string Property LOADER_FILE
	string Function Get()
		return "overlays/" + LOADER_NAME + ".swf"
	EndFunction
EndProperty

string Property LOADER_INSTANCE
	string Function Get()
		return "_root." + LOADER_NAME + ".Instance"
	EndFunction
EndProperty


; Initialize
;---------------------------------------------------------------------------------------------------

Event OnInit()
	_clients = new ScribeOverlay_ViewBase[128]
	_viewsources = new string[128]
	Utility.Wait(3.0) 						; Wait until all views have registered their callbacks
	OnGameReload()
EndEvent


Event OnGameReload()
	RegisterForModEvent("ScribeOverlay_EventViewError", "OnViewError")
	RegisterForModEvent("ScribeOverlay_EventViewLoaded", "OnViewLoaded")
	CleanUp()
	If(UI.IsMenuOpen(HUD_MENU))
		Initialize()
	Else
		RegisterForMenu(HUD_MENU)
	EndIf
EndEvent


Event OnMenuOpen(string asMenuName)
	If(asMenuName == HUD_MENU)
		UnregisterForMenu(HUD_MENU)
		Initialize()
	EndIf
EndEvent


Function Initialize()
	If(IsLoaded() == false) ; not injected yet
		ScribeOverlay.Log("Initialize() :: Creating new empty movieclip '"+LOADER_NAME+"'' on Hud Menu '_root'.", self)
		string[] sArray = new string[2] 	; movieclip container on HudMenu root
		sArray[0] = LOADER_NAME 			; movieclip name
		sArray[1] = "0" 					; movieclip depth
		UI.InvokeStringA(HUD_MENU, "_root.createEmptyMovieClip", sArray) ; create loader on hud menu root
		If(TryLoad() == false)
			If(TryLoad("exported/") == false)
				ScribeOverlay.Log("Initialize() :: Failed to inject the view loader on " + HUD_MENU, self, true, true)
				return ; failed
			EndIf
		EndIf
	EndIf

	UI.InvokeStringA(HUD_MENU, LOADER_INSTANCE + ".loadViews", _viewsources) ; Load already registered views
	SendModEvent("ScribeOverlay_EventManagerReady") ; send ready event to views
EndFunction


bool Function TryLoad(string asMovieRoot = "") ; "Data/Interface/exported/" 'overlays/ViewLoader.swf'
	string sMovie = asMovieRoot + LOADER_FILE
	string sInvoke = "_root." + LOADER_NAME + ".loadMovie"
	UI.InvokeString(HUD_MENU, sInvoke, sMovie)

	Utility.Wait(0.5)

	bool success = IsLoaded()
	If(success)
		UI.InvokeString(HUD_MENU, LOADER_INSTANCE + ".setPath", asMovieRoot)
	EndIf

	ScribeOverlay.Log("TryLoad(asMovieRoot="+asMovieRoot+") :: success="+success+", sInvoke="+sInvoke+", sMovie="+sMovie, self)
	return success
EndFunction


bool Function IsLoaded()
	{using an included property in version.as as a test to check injection success. True if the integer is non-zero}
	return UI.GetInt(HUD_MENU, "_global.Views."+LOADER_NAME+".OVERLAY_RELEASE_IDX") as bool
EndFunction




; Views
;---------------------------------------------------------------------------------------------------

Event OnViewError(string asEventName, string asErrorName, float afViewID, form a_sender)
	ScribeOverlay.Log("OnViewError(asEventName="+asEventName+", asErrorName="+asErrorName+", afViewID="+afViewID+")", self)
	int viewID = afViewID as int
	string viewName = _clients[viewID] as string
	Debug.MessageBox(asErrorName + " " + viewName)
EndEvent


Event OnViewLoaded(string asEventName, string a_strArg, float a_numArg, form a_sender)
	int viewID = a_strArg as int
	ScribeOverlay_ViewBase client = _clients[viewID]

	If(client != none)
		ScribeOverlay.Log("Loading client " + client as string, self)
		client.OnViewBase()
	EndIf
EndEvent



; @ api
int Function RequestViewID(ScribeOverlay_ViewBase akClient)
	If (_viewCount >= 128)
		return -1
	EndIf

	int viewID = NextViewID()
	_clients[viewID] = akClient
	_viewCount += 1

	return viewID
EndFunction



; @ api
string Function CreateView(int aiViewID, string asViewSource)
	_viewsources[aiViewID] = asViewSource
	string[] sArray = new string[2]
	sArray[0] = aiViewID as string
	sArray[1] = asViewSource

	string sInvoke = LOADER_INSTANCE + ".loadView"
	string sViewInstance = GetInstanceForView(aiViewID)
	UI.InvokeStringA(HUD_MENU, sInvoke, sArray)
	ScribeOverlay.Log("CreateView(aiViewID="+aiViewID+", asViewSource="+asViewSource+") :: sInvoke="+sInvoke, self)
	return sViewInstance
EndFunction


; @ api
string Function GetInstanceForView(int aiViewID)
	string sPath = LOADER_INSTANCE +"." + VIEW_CONTAINER + "." + aiViewID + ".view"
	ScribeOverlay.Log("GetInstanceForView(aiViewID="+aiViewID+") :: sPath="+sPath, self)
	return sPath
EndFunction



int Function NextViewID()
	int startIdx = _curViewID
	While (_clients[_curViewID] != none)
		_curViewID += 1
		If (_curViewID >= 128)
			_curViewID = 0
		EndIf
		If (_curViewID == startIdx)
			return -1
		EndIf
	EndWhile
	return _curViewID
EndFunction


Function CleanUp()
	_viewCount = 0
	int i = 0
	While (i < _clients.length)
		If (_clients[i] == none || _clients[i].GetFormID() == 0)
			_clients[i] = none
			_viewsources[i] = ""
		Else
			_viewCount += 1
		EndIf
		i += 1
	EndWhile
EndFunction


; un-used
ScribeOverlay_ViewBase[] Function GetViews()
	ScribeOverlay_ViewBase[] viewsCopy = new ScribeOverlay_ViewBase[128]
	int i = 0
	While (i < _clients.length)
		viewsCopy[i] = _clients[i]
		i += 1
	EndWhile
	return viewsCopy
EndFunction
