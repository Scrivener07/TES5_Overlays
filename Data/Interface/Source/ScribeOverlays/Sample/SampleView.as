import Views.ViewBase;

class Sample.SampleView extends ViewBase
{


// Initialize
//--------------------------------------------------------------------------------------------------

	public function SampleView()
	{
		super();
		skse.Log("SampleView.as: Constructor()");
	}

	public function onLoad()
	{
		skse.Log("SampleView.as: onLoad()");
	}

}
