import gfx.managers.FocusHandler;
import gfx.ui.InputDetails;
import gfx.ui.NavigationCode;
import Shared.GlobalFunc;
import skyui.components.list.BasicEnumeration;
import skyui.components.list.ScrollingList;
import skyui.components.ButtonPanel;
import skyui.defines.Input;
import skyui.util.GlobalFunctions;
import skyui.util.Translator;

class Shared.ResourceLoader extends MovieClip
{
	private var ClipLoader:MovieClipLoader; // helm
	private var Target:MovieClip; // helm
 	private var Status:MovieClip; // not implemented
	private var imagefile:String; // helm



// Initialization
//--------------------------------------------------------------------------------------------------

	public function ResourceLoader()
	{
		super();
		_lockroot = true;
		ClipLoader = new MovieClipLoader();
		ClipLoader.addListener(this);
		Status._visible = false;
	}


	public function onLoad()
	{
		super.onLoad();
		_visible = true; // Initially hidden
	}



// Events
//--------------------------------------------------------------------------------------------------


	function onLoadError(target_mc:MovieClip, errorCode:String)
	{
		if(errorCode == "URLNotFound")
		{
			ShowLoading(true, "URLNotFound"); // helm
		}
	}


	function onLoadInit(target_mc:MovieClip)
	{
		scaleToHeight(Target, 210);
		ShowLoading(false, ""); // helm
	}




// Image
//--------------------------------------------------------------------------------------------------


	private function loadImage(a_File:String):Void
	{
		a_File = "../../exported/overlays/" + a_File
		imagefile = a_File;
	//	setFilePath("Loading:" + a_File);
		ShowLoading(true, ""); // helm
		ClipLoader.loadClip(a_File, Target);
	}


	private function scaleToHeight(target_mc:MovieClip, a_height:Number):Void
	{
		target_mc._height = a_height;
		target_mc._xscale = target_mc._yscale;
	}




// Functions
//--------------------------------------------------------------------------------------------------

	private function ShowLoading(showLoading:Boolean, errorCode:String):Void
	{
		Status._visible = showLoading; // helm

		if(showLoading == false)
		{
			Status.gotoAndPlay("Stop"); // helm
			return;

		}
		else
		{
			if(errorCode == "URLNotFound")
			{
				Status.gotoAndStop("Error"); // helm
				return;
			}
			else
			{
				Status.gotoAndPlay("Start"); // helm
				return;
			}
		}
	}


}
