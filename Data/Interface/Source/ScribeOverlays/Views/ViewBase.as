import skyui.util.Tween;
import Shared.GlobalFunc;

class Views.ViewBase extends MovieClip
{
// "_root.ViewLoader.Instance.ViewContainer.#.view"

	private var _viewHolder:MovieClip;
	public function get ViewID():String { return _viewHolder._name; }

	private var _rootPath:String = "";
	public function get RootPath():String { return _rootPath; }

	private var _clientInfo: Object;
	public function get ScriptName():String { return _clientInfo["scriptName"]; }
	public function get FormName():String { return _clientInfo["formName"]; }
	public function get FormID():String { return _clientInfo["formID"]; }

	public function get Url():String { return _url; }
	public function get InstancePath():String { return this.toString(); }

	public function get Visible():Boolean { return _visible; }
	public function set Visible(a_value:Boolean):Void { _visible = a_value; }

	public function get Alpha():Number { return _alpha; }
	public function set Alpha(a_value:Number):Void { _alpha = a_value; }

	public function get Width():Number { return _width; }
	public function set Width(a_value:Number):Void { _width = a_value; }

	public function get Height():Number { return _height; }
	public function set Height(a_value:Number):Void { _height = a_value; }
	public function get HeightMin():Number { return Stage.height; }

	public function get X():Number { return _x; }
	public function set X(a_value:Number):Void { _x = a_value; }

	public function get Y():Number { return _y; }
	public function set Y(a_value:Number):Void { _y = a_value; }

	public function get XScale():Number { return _xscale; }
	public function set XScale(a_value:Number):Void { _xscale = a_value; }

	public function get YScale():Number { return _yscale; }
	public function set YScale(a_value:Number):Void { _yscale = a_value; }

	private static var MODES:Array = ["All", "Favor", "MovementDisabled", "Swimming", "WarHorseMode", "HorseMode", "InventoryMode", "BookMode", "DialogueMode", "StealthMode", "SleepWaitMode", "BarterMode", "TweenMode", "WorldMapMode", "JournalMode", "CartMode", "VATSPlayback"];
	private static var MODEMAP:Object = {all: "All", favor: "Favor", movementdisabled: "MovementDisabled", swimming: "Swimming", warhorsemode: "WarHorseMode", horsemode: "HorseMode", inventorymode: "InventoryMode", bookmode: "BookMode", dialoguemode: "DialogueMode", stealthmode: "StealthMode", sleepwaitmode: "SleepWaitMode", bartermode: "BarterMode", tweenmode: "TweenMode", worldmapmode: "WorldMapMode", journalmode: "JournalMode", cartmode: "CartMode", vatsplayback: "VATSPlayback"};


// Initialize
//--------------------------------------------------------------------------------------------------

	public function ViewBase()
	{
		_clientInfo = {};
		_viewHolder = _parent;

		if (_global.gfxPlayer)
			_global.gfxExtensions = true;
		else
			_viewHolder._visible = false;
	}


	// @ ViewLoader.as
	public function setRootPath(a_path:String): Void
	{
		_rootPath = a_path;
		skse.Log("ViewBase.as: setRootPath(a_path="+a_path+")");
	}



// Papyrus
//--------------------------------------------------------------------------------------------------

	// @papyrus ScribeOverlay_ViewBase
	public function setClientInfo(a_clientString:String): Void
	{
		skse.Log("ViewBase.as: setClientInfo(a_clientString="+a_clientString+")");
		// [ScriptName <formName (formID)>]
		var view = this;
		var clientInfo: Object = new Object();
		var lBrackIdx: Number = 0;
		var lInequIdx: Number = a_clientString.indexOf("<");
		var lParenIdx: Number = a_clientString.indexOf("(");
		var rParenIdx: Number = a_clientString.indexOf(")");

		clientInfo["scriptName"] = a_clientString.slice(lBrackIdx + 1, lInequIdx - 1);
		clientInfo["formName"] = a_clientString.slice(lInequIdx + 1, lParenIdx - 1);
		clientInfo["formID"] = a_clientString.slice(lParenIdx + 1, rParenIdx);
		view._clientInfo = clientInfo;
	}


	// @papyrus ScribeOverlay_ViewBase
	public function setModes(/* a_visibleMode0:String, a_visibleMode1:String, ... */): Void
	{
		var numValidModes:Number = 0;
		// Clear all modes
		for (var i=0; i<MODES.length; i++)
		{
			delete(_viewHolder[MODES[i]]);
		}
		for (var i=0; i<arguments.length; i++)
		{
			var m = MODEMAP[arguments[i].toLowerCase()];
			if (m != undefined)
			{
				_viewHolder[m] = true;
				numValidModes++;
			}
		}
		if(numValidModes == 0)
		{
			sendError("NoValidModes", Number(ViewID));
		}
		var hudMode:String = _root.HUDMovieBaseInstance.HUDModes[_root.HUDMovieBaseInstance.HUDModes.length - 1];
		_viewHolder._visible = _viewHolder.hasOwnProperty(hudMode);
		_root.HUDMovieBaseInstance.HudElements.push(_viewHolder);
		skse.Log("ViewBase.as: setModes()");
	}



// Functions
//--------------------------------------------------------------------------------------------------

	public function fadeTo(a_alpha:Number, a_duration:Number): Void
	{
		var duration:Number = Math.max(0, a_duration || 0);
		Tween.LinearTween(this, "_alpha", this._alpha, a_alpha, duration, null);
		skse.Log("ViewBase.as: fadeTo(a_alpha="+a_alpha+", a_duration="+a_duration+")");
	}


	private function sendError(a_ErrorName:String, a_ViewID:Number):Void
	{
		var sEventName:String = "ScribeOverlay_EventViewError";
		skse.SendModEvent(sEventName, a_ErrorName, a_ViewID);
		skse.Log("ViewBase.as: sendError(a_ErrorName="+a_ErrorName+", a_ViewID="+a_ViewID+") :: sEventName="+sEventName);
	}


}
