class Scribe.Debug
{


// Diagnostic
//--------------------------------------------------------------------------------------------------

	public static function walkMovie(a_Movieclip:MovieClip):Void
	{
		skse.Log("Debug.as: walkMovie(a_Movieclip="+a_Movieclip._name+")");

		for (var sElement:String in a_Movieclip) // this will eval each movie in the root timeline from top to bottom
		{
			var kObject:Object = a_Movieclip[sElement];
			if (kObject instanceof MovieClip)
			{
				skse.Log("Debug.as: walkMovie :: kObject=" + kObject._name);
			}
		}
	}

}
