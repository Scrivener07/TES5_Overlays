import skyui.util.GlobalFunctions;
import Scribe.ScribeFunctions;
import Scribe.Debug;

class Views.ViewLoader extends MovieClip
{
	#include "../version.as"

	private var _rootPath:String = "";
	private var _mcLoader:MovieClipLoader;
	private var ViewContainer:MovieClip;
	public function get VIEW_CONTAINER():String { return "ViewContainer"; }


// Initialize
//--------------------------------------------------------------------------------------------------

	public function ViewLoader()
	{
		super();
		_lockroot = true;
		GlobalFunctions.addArrayFunctions();
		_mcLoader = new MovieClipLoader();
		_mcLoader.addListener(this);
		skse.Log("ViewLoader.as: Constructor() :: Version=" + OVERLAY_VERSION_STRING);
	}


	public function onLoad(): Void
	{
		Prepare();
	}


	private function Prepare():Void
	{
		skse.Log("ViewLoader.as: Prepare()");
		// NOTE: Get instance with object.object, not at depth
		// 'HUD_MENU.__OnEnterFrameBeacon' 	From Depth= 9876  to Depth=9876
		// 'HUD_MENU._gsAnimation12_1_3' 	From Depth= 999   to Depth= 999
		// 'HUD_MENU.HUDMovieBaseInstance' 	From Depth=-16383 to Depth= 100
		// 'HUD_MENU.widgetLoaderContainer' From Depth=-1000  to Depth=-500
		// 'HUD_MENU.WidgetContainer' 		From Depth=-16384 to Depth=-510
		// 'HUD_MENU.ViewLoader' 			From Depth= ????? to Depth=-600  "_root.ViewLoader.Instance.ViewContainer.#.view"
		ScribeFunctions.swapDepthFor(_root, "HUDMovieBaseInstance", -16383, 100);
		ScribeFunctions.swapDepthFor(_root, "widgetLoaderContainer", -1000, -500);
		ScribeFunctions.swapDepthFor(_root, "WidgetContainer", -16384, -510);
		ScribeFunctions.swapDepthFor(_root, "ViewLoader", _parent.getDepth(), -600);
	}




// Papyrus Interface
//--------------------------------------------------------------------------------------------------

	// @papyrus ScribeOverlay_ViewManager
	public function setPath(a_path:String):Void
	{
		skse.Log("ViewLoader.as: setPath(a_path="+a_path+") :: Set root resource path.");
		_rootPath = a_path;
	}


	// @papyrus ScribeOverlay_ViewManager
	public function loadViews(/* viewSources (128) */):Void
	{
		skse.Log("ViewLoader.as: loadViews(*) :: Loading already registered views.");

		if(ViewContainer != undefined) // clean up
		{
			for(var s:String in ViewContainer)
			{
				var view = ViewContainer[s];
				if(view != null && view instanceof MovieClip)
				{
					_mcLoader.unloadClip(view);

					var index = _root.HUDMovieBaseInstance.HudElements.indexOf(view);
					if(index != undefined)
					{
						_root.HUDMovieBaseInstance.HudElements.splice(index, 1);
					}
				}
			}
		}

		for(var i: Number = 0; i < arguments.length; i++) // load args
		{
			if(arguments[i] != undefined && arguments[i] != "")
			{
				loadView(String(i), arguments[i]);
			}
		}
	}



// Client Loader
//--------------------------------------------------------------------------------------------------

	// @papyrus ScribeOverlay_ViewManager
	public function loadView(a_viewID:String, a_viewSource:String):Void
	{
		if(ViewContainer == undefined) // create ViewContainer if not already
		{
			ViewContainer = this.createEmptyMovieClip(VIEW_CONTAINER, -16384);
			ViewContainer.Lock("TL");
			ViewContainer._x = 0;
			ViewContainer._y = 0;
			skse.Log("ViewLoader.as: loadView() :: Created ViewContainer="+ViewContainer+"");
		}
		var sFilePath:String = _rootPath + a_viewSource;
		var newViewID:MovieClip = ViewContainer.createEmptyMovieClip(a_viewID, ViewContainer.getNextHighestDepth());
		_mcLoader.loadClip(sFilePath, newViewID);
		skse.Log("ViewLoader.as: loadView(a_viewID="+a_viewID+", a_viewSource="+ a_viewSource+") :: sFilePath=" + sFilePath);
	}



	public function onLoadError(a_ViewIDClip:MovieClip, a_errorCode:String):Void
	{
		skse.Log("ViewLoader.as: onLoadError(a_ViewIDClip="+a_ViewIDClip._name+", a_errorCode="+ a_errorCode+")");
		sendError(a_ViewIDClip, "ViewLoadFailure");
	}



	public function onLoadInit(a_ViewIDClip:MovieClip):Void
	{
		skse.Log("ViewLoader.as: onLoadInit(a_ViewIDClip="+a_ViewIDClip._name+")");

		if(a_ViewIDClip.view == undefined)
		{
			sendError(a_ViewIDClip, "ViewUndefined");
			return;
		}

		a_ViewIDClip.onModeChange = function(a_hudMode:String):Void
		{
			var viewHolder:MovieClip = this;
			if(viewHolder.view.onModeChange != undefined)
			{
				viewHolder.view.onModeChange(a_hudMode);
				skse.Log("ViewLoader.as: a_ViewIDClip.onModeChange() :: a_hudMode="+a_hudMode);
			}
		}

		a_ViewIDClip.view.setRootPath(_rootPath);
		sendLoaded(a_ViewIDClip);
	}




// Functions
//--------------------------------------------------------------------------------------------------

	private function sendLoaded(a_ViewIDClip:MovieClip):Void
	{
		var sEventName:String = "ScribeOverlay_EventViewLoaded";
		var sViewID:String = a_ViewIDClip._name;
		skse.SendModEvent(sEventName, sViewID);
		skse.Log("ViewLoader.as: sendLoaded(a_ViewIDClip="+a_ViewIDClip+") :: sEventName="+sEventName+", sViewID="+sViewID);
		Debug.walkMovie(ViewContainer);
	}


	private function sendError(a_ViewIDClip:MovieClip, a_ErrorName:String):Void
	{
		var sEventName:String = "ScribeOverlay_EventViewError";
		var nViewID:Number = Number(a_ViewIDClip._name);
		skse.SendModEvent(sEventName, a_ErrorName, nViewID);
		skse.Log("ViewLoader.as: sendError(a_ErrorName="+a_ErrorName+", nViewID="+nViewID+") :: sEventName="+sEventName);
		Debug.walkMovie(ViewContainer);
	}


}
