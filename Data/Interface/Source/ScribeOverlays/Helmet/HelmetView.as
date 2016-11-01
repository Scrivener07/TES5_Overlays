import flash.geom.ColorTransform;
import flash.geom.Transform;

import mx.utils.Delegate;
import mx.transitions.Tween;
import mx.transitions.easing.*;

import Views.ViewBase;
import Scribe.ScribeFunctions;

class Helmet.HelmetView extends ViewBase
{

// Art
//--------------------------------------------------
	private var Art:MovieClip;
	private var ClipLoader:MovieClipLoader;
	private var AttemptIdx:Number = -1;
	private var PriorityExtension:String = "dds";

// Properties
//--------------------------------------------------
	public function get ModEvent_ArtError():String { return "ScribeHelmet_EventArtError"; }
	public function get ModEvent_ArtLoaded():String { return "ScribeHelmet_EventArtLoaded"; }
	public function get ModEvent_LightFinished():String { return "ScribeHelmet_EventLightFinished"; }


	private var pathkey:String = undefined;
	private var pathkeyFallback:String = undefined;
	private var useFallback:Boolean = false;
	public function get PathKey():String { if(useFallback) { return pathkeyFallback; } return pathkey; }


	private var filePath:String = "";
	public function get FilePath():String { return filePath; }
	public function set FilePath(a_value:String):Void { filePath = a_value; }

	public function get HeightMin():Number { return Stage.height + 50; }


// Options
//--------------------------------------------------

	private var artSize:Number = 0;
	public function set ArtSize(a_value:Number):Void
	{
		if(artSize != a_value)
		{
			artSize = a_value;
			var newHeight = HeightMin + a_value;
			if(newHeight < HeightMin) { newHeight = HeightMin; }
			ScribeFunctions.scaleToHeight(this, newHeight);
		}
	}


	public function get ArtAlpha():Number { return this._alpha; }
	public function set ArtAlpha(a_value:Number):Void { this._alpha = a_value; }


	private var lightDuration:Number = 1;
	public function get LightDuration():Number { return lightDuration; }
	public function set LightDuration(a_value:Number):Void { lightDuration = a_value; }


	private var lightStrength:Number = 25;
	public function get LightStrength():Number { return lightStrength; }
	public function set LightStrength(a_value:Number):Void { lightStrength = a_value; }



// Initialize
//--------------------------------------------------------------------------------------------------

	public function HelmetView()
	{
		super();
		ClipLoader = new MovieClipLoader();
		ClipLoader.addListener(this);
	}


	public function onLoad()
	{
		skse.Log("HelmetView.as: onLoad()");
	}


// Papyrus
//--------------------------------------------------------------------------------------------------

	// @papyrus ScribeHelmet_View.psc
	public function LoadArt(a_PathKeyA:String, a_PathKeyB:String):Void
	{
		skse.Log("HelmetView.as: LoadArt(a_PathKeyA="+a_PathKeyA + ", a_PathKeyB="+a_PathKeyB +")");
		pathkey = a_PathKeyA;
		pathkeyFallback = a_PathKeyB;
		useFallback = false;
		Attempt();
	}


	// @papyrus ScribeHelmet_View.psc
	public function ApplySettings(a_ArtPath:String, a_ArtSize:Number, a_ArtAlpha:Number, a_LightDuration:Number, a_LightStrength:Number):Void
	{
		skse.Log("HelmetView.as: ApplySettings(a_ArtPath="+a_ArtPath+ ", a_ArtSize="+a_ArtSize+ ", a_ArtAlpha="+a_ArtAlpha+ ", a_LightDuration="+a_LightDuration+ ", a_LightStrength="+a_LightStrength +")");
		FilePath = a_ArtPath;
		ArtSize = a_ArtSize;
		ArtAlpha = a_ArtAlpha;
		LightDuration = a_LightDuration;
		LightStrength = a_LightStrength;
	}


	// @papyrus ScribeHelmet_View.psc
	public function ChangeMotion(a_FrameLabel:String):Void
	{
		skse.Log("HelmetView.as: ChangeMotion(a_FrameLabel="+a_FrameLabel+")");
		gotoAndPlay(a_FrameLabel);
	}


	// @papyrus ScribeHelmet_View.psc
	public function ChangeLight(a_LightLevel:Number):Void
	{
		skse.Log("HelmetView.as: ChangeLight(a_LightLevel="+a_LightLevel+")");

		var _ColorChannel:Number = ToColorChannel(a_LightLevel);
 		var c:ColorTransform = this.transform.colorTransform;

		var redTween:Tween = new Tween(c, "redOffset", Strong.easeIn, c.redOffset, _ColorChannel, LightDuration, true);
		var greenTween:Tween = new Tween(c, "greenOffset", Strong.easeIn, c.greenOffset, _ColorChannel, LightDuration, true);
		var blueTween:Tween = new Tween(c, "blueOffset", Strong.easeIn, c.blueOffset, _ColorChannel, LightDuration, true);


		redTween.onMotionChanged = Delegate.create(this, function ():Void
		{
			this.transform.colorTransform = c;
		});

		redTween.onMotionFinished = Delegate.create(this, function ():Void
		{
			skse.SendModEvent(ModEvent_LightFinished);
		});
	}



// Functions
//--------------------------------------------------------------------------------------------------

	private function Attempt():Void
	{
		AttemptIdx = -1;
		loadResource("overlays/" + PathKey + "." + PriorityExtension);
	}


	private function loadResource(asFilePath:String):Void
	{
		skse.Log("HelmetView.as: loadResource(asFilePath="+asFilePath +") :: RootPath="+RootPath);
		FilePath = asFilePath;
		ClipLoader.unloadClip();
		ClipLoader.loadClip(asFilePath, Art);
	}



	private function onLoadInit(a_MovieClip:MovieClip)
	{
		skse.Log("HelmetView.as: onLoadInit(a_MovieClip="+a_MovieClip._name+")");
		ScribeFunctions.scaleToHeight(this, HeightMin);
		skse.SendModEvent(ModEvent_ArtLoaded, PathKey);
	}



	private function onLoadError(a_MovieClip:MovieClip, errorCode:String)
	{
		skse.Log("HelmetView.as: onLoadError(a_MovieClip="+a_MovieClip._name+", errorcode="+errorCode+")");

		if(errorCode == "URLNotFound")
		{
			if(AttemptIdx == 4 && useFallback == false)
			{
				useFallback = true;
				Attempt();
				return;
			}
			AttemptIdx += 1;
			if(AttemptIdx == 0 || AttemptIdx == 1 || AttemptIdx == 2 || AttemptIdx == 3 || AttemptIdx == 4)
			{
				var extensions:Array = new Array(5);
				extensions[0] = "swf";
				extensions[1] = "dds";
				extensions[2] = "png";
				extensions[3] = "jpg"; // jpeg
				extensions[4] = "gif";
				var nextFile:String = ConvertFileExtension(FilePath, extensions[AttemptIdx]);
				loadResource(nextFile);
			}
			else
			{
				AttemptIdx = -1;
				FilePath = ConvertFileExtension(FilePath, PriorityExtension);
				skse.SendModEvent(ModEvent_ArtError, PathKey);
			}
		}
	}


	private function ConvertFileExtension(asFilePath:String, asExtension:String):String
	{
		return asFilePath.substr(0, asFilePath.length - 3) + asExtension;
	}



	private function ToColorChannel(a_LightLevel:Number):Number
	{
		if(a_LightLevel > 90 || LightStrength > 255)
		{
			return 0;
		}
		else
		{
			var _lightPercent:Number = a_LightLevel / 150; 					// percent of a_LightLevel (0 to 150)
			var _colorModifier:Number = _lightPercent * LightStrength;		// convert _lightPercent of LightStrength into _colorModifier amount
			var _colorTransform:Number = _colorModifier - LightStrength;	// invert the _colorModifier amount with minus LightStrength
			if(_colorTransform > 0)											// cap _colorTransform to 0 for normal color (no white)
			{
				return 0;
			}
			else
			{
				return Math.floor(_colorTransform);
			}
		}
	}



}
