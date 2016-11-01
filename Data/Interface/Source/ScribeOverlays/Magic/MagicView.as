import Views.ViewBase;

class Magic.MagicView extends ViewBase
{
	var myTextField:TextField;


// Initialize
//--------------------------------------------------------------------------------------------------

	public function MagicView()
	{
		super();
		skse.Log("MagicView.as: Constructor");
	}


	public function onLoad()
	{
		myTextField.text = "test magic view 123";
		skse.Log("MagicView.as: onLoad()");
	}

}
