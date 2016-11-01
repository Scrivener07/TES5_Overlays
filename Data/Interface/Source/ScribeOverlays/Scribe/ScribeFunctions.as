class Scribe.ScribeFunctions
{
	public static function fitToScreen(a_MovieClip:MovieClip):Void
	{
		skse.Log("ScribeFunctions.as: fitToScreen(a_MovieClip="+a_MovieClip+ ") :: Stage.height="+Stage.height);
		scaleToHeight(a_MovieClip, Stage.height);
	}


	public static function scaleToHeight(a_MovieClip:MovieClip, a_Height:Number):Void
	{
		skse.Log("ScribeFunctions.as: scaleToHeight(a_MovieClip="+a_MovieClip+ " , a_Height="+a_Height+")");
		a_MovieClip._height = a_Height;
		a_MovieClip._xscale = a_MovieClip._yscale;
		centerOnStage(a_MovieClip);
	}


	public static function centerOnStage(a_MovieClip:MovieClip):Void
	{
		a_MovieClip._x = (Stage.width - a_MovieClip._width) / 2;
		a_MovieClip._y = (Stage.height - a_MovieClip._height) / 2;
		skse.Log("ScribeFunctions.as: centerOnStage(a_MovieClip="+a_MovieClip+") :: a_MovieClip._x="+a_MovieClip._x+", a_MovieClip._y="+a_MovieClip._y);
	}


	public static function swapDepthFor(a_MovieClip:MovieClip, a_TargetName:String, a_AtDepth:Number, a_ToDepth:Number):Void
	{
		var targetMovie:MovieClip = a_MovieClip.getInstanceAtDepth(a_AtDepth);
		if (targetMovie._name == a_TargetName)
		{
			targetMovie.swapDepths(a_ToDepth);
		}
		skse.Log("ScribeFunctions.as: swapDepthFor(a_MovieClip="+a_MovieClip+", a_TargetName="+a_TargetName+", a_AtDepth="+a_AtDepth+", a_ToDepth="+a_ToDepth+") :: targetMovie="+targetMovie);
	}


}
