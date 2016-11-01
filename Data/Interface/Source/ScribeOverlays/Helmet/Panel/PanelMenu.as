
import Shared.GlobalFunc;
import gfx.managers.FocusHandler;
import gfx.io.GameDelegate;
import gfx.ui.InputDetails;
import gfx.ui.NavigationCode;
import skyui.defines.Input;
import skyui.util.DialogManager;
import skyui.util.GlobalFunctions;
import skyui.util.Translator;
import skyui.util.Tween;
import Components.CrossPlatformButtons;


class Helmet.Panel.PanelMenu extends MovieClip
{

// TODO: Arrow keys or D-Pad to change option focus and select

// Private Variables
//..............................................
	private var requestDataId_: Number;


// Option Dialog
//..............................................
	private var _platform: Number;
	private var _isDialogOpen: Boolean;
	private var	_dialogTitleText: String = "";


// Menu Buttons
//..............................................
	private var ButtonPanelLeft: MovieClip;
	private var ButtonPanelRight: MovieClip;

	private var _acceptControls: Object;
	private var _defaultControls: Object;
	private var _cancelControls: Object;


// Stage Elements
//..............................................
	private var MessageTextField: TextField;
	private var BackgroundClip: MovieClip;

	private var NameTextField: TextField;
	private var KeyTextField: TextField;

	private var SizeValue: Number;
	private var SizeButton: CrossPlatformButtons;
	private var SizeTextField: TextField;

	private var AlphaValue: Number;
	private var AlphaButton: CrossPlatformButtons;
	private var AlphaTextField: TextField;

	private var IntervalValue: Number;
	private var IntervalButton: CrossPlatformButtons;
	private var IntervalTextField: TextField;

	private var DurationValue: Number;
	private var DurationButton: CrossPlatformButtons;
	private var DurationTextField: TextField;

	private var StrengthValue: Number;
	private var StrengthButton: CrossPlatformButtons;
	private var StrengthTextField: TextField;


// Initialization
//--------------------------------------------------------------------------------------------------

	public function PanelMenu()
	{
		super();
		_isDialogOpen = false;
		_visible = false;
	}


	public function onLoad()
	{
		super.onLoad();
		Mouse.addListener(this);
		Key.addListener(this);
		FocusHandler.instance.setFocus(this, 0);
		requestDataId_ = setInterval(this, "send_OpenMenu", 1);
		_visible = true;
	}



// Setup
//--------------------------------------------------------------------------------------------------

	public function handleInput(details, pathToFocus): Boolean
	{
		var bHandledInput: Boolean = false;
		if (GlobalFunc.IsKeyPressed(details))
		{
			if(_isDialogOpen == false)
			{
				if(details.navEquivalent == NavigationCode.TAB)
				{
					OnCancelPress();
					bHandledInput = true;
				}
				else if (details.navEquivalent == NavigationCode.ENTER)
				{
					OnAcceptPress();
					bHandledInput = true;
				}
				else if (details.control == _defaultControls.name)
				{
					OnDefaultPress();
					bHandledInput = true;
				}
			}
		}
		if(bHandledInput)
		{
			return bHandledInput;
		}
		else
		{
			var nextClip = pathToFocus.shift();
			if (nextClip.handleInput(details, pathToFocus))
			{
				return true;
			}
		}

		return false;
	}


	private function setPlatform(platform:Number): Void
	{
		_platform = platform;

		if (platform == 0) {
			_acceptControls = Input.Enter;
			_defaultControls = Input.ReadyWeapon;
			_cancelControls = Input.Tab;
		} else {
			_acceptControls = Input.Accept;
			_defaultControls = Input.YButton;
			_cancelControls = Input.Cancel;
		}


		ButtonPanelLeft.setPlatform(platform, false);
		ButtonPanelLeft.clearButtons();
			var defaultButton = ButtonPanelLeft.addButton({text: "$Default", controls: _defaultControls});
			defaultButton.addEventListener("press", this, "OnDefaultPress");
			defaultButton.addEventListener("rollOver", this, "OnDefaultRollOver");
		ButtonPanelLeft.updateButtons();


		ButtonPanelRight.setPlatform(platform, false);
		ButtonPanelRight.clearButtons();
			var cancelButton = ButtonPanelRight.addButton({text: "$Cancel", controls: _cancelControls});
			cancelButton.addEventListener("press", this, "OnCancelPress");
			cancelButton.addEventListener("rollOver", this, "OnCancelRollOver");

			var acceptButton = ButtonPanelRight.addButton({text: "$Save", controls: _acceptControls});
			acceptButton.addEventListener("press", this, "OnAcceptPress");
			acceptButton.addEventListener("rollOver", this, "OnAcceptRollOver");
		ButtonPanelRight.updateButtons();


		SizeButton.SetPlatform(platform, false);
		SizeButton.addEventListener("press", this, "OnSizeButtonClick");
		SizeButton.addEventListener("rollOver", this, "OnSizeButtonRollOver");

		AlphaButton.SetPlatform(platform, false);
		AlphaButton.addEventListener("press", this, "OnAlphaButtonClick");
		AlphaButton.addEventListener("rollOver", this, "OnAlphaButtonRollOver");

		IntervalButton.SetPlatform(platform, false);
		IntervalButton.addEventListener("press", this, "OnIntervalButtonClick");
		IntervalButton.addEventListener("rollOver", this, "OnIntervalButtonRollOver");

		DurationButton.SetPlatform(platform, false);
		DurationButton.addEventListener("press", this, "OnDurationButtonClick");
		DurationButton.addEventListener("rollOver", this, "OnDurationButtonRollOver");

		StrengthButton.SetPlatform(platform, false);
		StrengthButton.addEventListener("press", this, "OnStrengthButtonClick");
		StrengthButton.addEventListener("rollOver", this, "OnStrengthButtonRollOver");
	}






// Menu
//--------------------------------------------------------------------------------------------------


	private function send_OpenMenu(): Void
	{
		skse.Log("PanelMenu.as: send_OpenMenu()");
		clearInterval(requestDataId_);
		skse.SendModEvent("ScribeHelmet_MenuOpen");
	}


	private function send_CloseMenu(): Void
	{
		skse.Log("PanelMenu.as: send_CloseMenu()");
		skse.SendModEvent("ScribeHelmet_MenuClose", null, 0); // SEND THE RESOLVED STRING KEY AS WELL, float is used as bool for DoAppyUpdate
		skse.CloseMenu("CustomMenu"); // match name in papyrus
	}


	public function SetupMenu(platform:Number, a_Equipment:String, a_PathKey:String): Void
	{
		setPlatform(platform);
		NameTextField.text = a_Equipment;
		KeyTextField.text = a_PathKey;
	}



	public function SetupOptions(a_size:Number, a_alpha:Number, a_interval:Number, a_duration:Number, a_strength:Number): Void
	{
		skse.Log("PanelMenu.as: SetupOptions()");

		SizeValue = a_size;
		SizeTextField.text = a_size.toString();

		AlphaValue = a_alpha;
		AlphaTextField.text = a_alpha.toString();

		IntervalValue = a_interval;
		IntervalTextField.text = a_interval.toString();

		DurationValue = a_duration;
		DurationTextField.text = a_duration.toString();

		StrengthValue = a_strength;
		StrengthTextField.text = a_strength.toString();
	}


	// enable SELF
	private function dimIn(): Void
	{
		GameDelegate.call("PlaySound",["UIMenuBladeCloseSD"]);
		Tween.LinearTween(BackgroundClip, "_alpha", 30, 100, 0.5, null);
	}


	// disable SELF
	private function dimOut(): Void
	{
		GameDelegate.call("PlaySound",["UIMenuBladeOpenSD"]);
		Tween.LinearTween(BackgroundClip, "_alpha", 100, 30, 0.5, null);
	}





// Slider Dialog
//--------------------------------------------------------------------------------------------------

	private function ShowSliderDialog(a_eventID:String, a_title:String, a_format:String, a_value:Number, a_default:Number, a_min:Number, a_max:Number, a_interval:Number): Void
	{
		if(_isDialogOpen) { return; }
		_isDialogOpen = true;

		var initObj = {
			_x: 700, _y: 550,
			platform: _platform,
			eventID: a_eventID,
			titleText: a_title,
			sliderValue: a_value,
			sliderDefault: a_default,
			sliderMax: a_max,
			sliderMin: a_min,
			sliderInterval: a_interval,
			sliderFormatString: a_format
		};

		dimOut();

		var dialog = DialogManager.open(this, "OptionSliderDialog", initObj);
		dialog.addEventListener("valueChanged", this, "OnSliderValueChanged");
		dialog.addEventListener("dialogClosing", this, "OnSliderDialogClosing");
		dialog.addEventListener("dialogClosed", this, "OnSliderDialogClosed");
	}



	private function OnSliderValueChanged(event:Object, eventID:String, sliderValue:Number): Void
	{
		MessageTextField.text = "Type:" + event.type.toString() + ", EventID:" + event.eventID + ", SliderValue:" + event.sliderValue.toString();
		skse.Log("PanelMenu.as: SetupOptions() :: " + MessageTextField.text);

		if(event.eventID == "GearSize")
		{
			SizeValue = event.sliderValue;
			SizeTextField.text = event.sliderValue.toString();
		}
		else if(event.eventID == "GearAlpha")
		{
			AlphaValue = event.sliderValue;
			AlphaTextField.text = event.sliderValue.toString();
		}
		else if(event.eventID == "LightInterval")
		{
			IntervalValue = event.sliderValue;
			IntervalTextField.text = event.sliderValue.toString();
		}
		else if(event.eventID == "LightDuration")
		{
			DurationValue = event.sliderValue;
			DurationTextField.text = event.sliderValue.toString();
		}
		else if(event.eventID == "LightStrength")
		{
			StrengthValue = event.sliderValue;
			StrengthTextField.text = event.sliderValue.toString();
		}


	//	skse.SendModEvent("ScribeHelmet_EventDialogAccepted", eventID, sliderValue);
	}



	private function OnSliderDialogClosing(event:Object): Void
	{
		dimIn();
	}

	private function OnSliderDialogClosed(event:Object): Void
	{
		dimIn();
		_isDialogOpen = false;
	}



// Buttons
//--------------------------------------------------------------------------------------------------

	private function OnDefaultRollOver(): Void { MessageTextField.text = "$DefaultTip"; }
	private function OnDefaultPress(): Void
	{
		MessageTextField.text = "OnDefaultPress";

	}



	private function OnCancelRollOver(): Void { MessageTextField.text = "$CancelTip"; }
	private function OnCancelPress(): Void
	{
		MessageTextField.text = "OnCancelPress";
		send_CloseMenu();
	}



	private function OnAcceptRollOver(): Void { MessageTextField.text = "$SaveTip"; }
	private function OnAcceptPress(): Void
	{
		MessageTextField.text = "OnAcceptPress";
		MessageTextField.textColor = 0x36BD00; // dummy thing
		send_CloseMenu();
	}



	private function OnSizeButtonRollOver(): Void { MessageTextField.text = "$OptionSizeTip"; }
	private function OnSizeButtonClick(): Void
	{
		skse.Log("PanelMenu.as: OnSizeButtonClick()");
		ShowSliderDialog("GearSize", "$OptionSize", "", SizeValue, 0, 0, 1000, 1);
	}


	private function OnAlphaButtonRollOver(): Void { MessageTextField.text = "$OptionAlphaTip"; }
	private function OnAlphaButtonClick(): Void
	{
		skse.Log("PanelMenu.as: OnAlphaButtonClick()");
		ShowSliderDialog("GearAlpha", "$OptionAlpha", "", AlphaValue, 0, 0, 100, 1);
	}


	private function OnIntervalButtonRollOver(): Void { MessageTextField.text = "$OptionIntervalTip"; }
	private function OnIntervalButtonClick(): Void
	{
		skse.Log("PanelMenu.as: OnIntervalButtonClick()");
		ShowSliderDialog("LightInterval", "$OptionInterval", "", IntervalValue, 1.0, 0.1, 60.0, 0.1);
	}


	private function OnDurationButtonRollOver(): Void { MessageTextField.text = "$OptionDurationTip"; }
	private function OnDurationButtonClick(): Void
	{
		skse.Log("PanelMenu.as: OnDurationButtonClick()");
		ShowSliderDialog("LightDuration", "$OptionDuration", "", DurationValue, 1.0, 0.1, 30, 0.1);
	}


	private function OnStrengthButtonRollOver(): Void { MessageTextField.text = "$OptionStrengthTip"; }
	private function OnStrengthButtonClick(): Void
	{
		skse.Log("PanelMenu.as: OnStrengthButtonClick()");
		ShowSliderDialog("LightStrength", "$OptionStrength", "", StrengthValue, 0, 0, 100, 1);
	}




}
