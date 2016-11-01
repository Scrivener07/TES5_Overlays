import skyui.util.DialogManager;
import skyui.util.GlobalFunctions;
import skyui.util.Translator;
import gfx.managers.FocusHandler;
import gfx.ui.NavigationCode;
import Shared.GlobalFunc;

import skyui.defines.Input;


class Helmet.Panel.SliderDialog extends OptionDialog
{

	// Stage Elements
	//..............................................
	public var sliderPanel: MovieClip;


	// Slider Event
	//..............................................
	public var eventID: String = "";
	public var sliderValue: Number;
	public var onDialogValueChanged: Function;


	// Slider Values
	//..............................................
	public var sliderDefault: Number;
	public var sliderMax: Number;
	public var sliderMin: Number;
	public var sliderInterval: Number;
	public var sliderFormatString: String;



	// Input Controls
	//..............................................
	private var _acceptControls: Object;
	private var _defaultControls: Object;
	private var _cancelControls: Object;





// Initialization
//--------------------------------------------------------------------------------------------------

	public function SliderDialog()
	{
		super();
	}



	// @override OptionDialog
	public function initButtons(): Void
	{
		skse.Log("SliderDialog.as: initButtons()");

		if (platform == 0) {
			_acceptControls = Input.Enter;
			_defaultControls = Input.ReadyWeapon;
			_cancelControls = Input.Tab;
		} else {
			_acceptControls = Input.Accept;
			_defaultControls = Input.YButton;
			_cancelControls = Input.Cancel;
		}


		leftButtonPanel.clearButtons();
		var defaultButton = leftButtonPanel.addButton({text: "$Default", controls: _defaultControls});
		defaultButton.addEventListener("press", this, "onDefaultPress");
		leftButtonPanel.updateButtons();

		rightButtonPanel.clearButtons();
		var cancelButton = rightButtonPanel.addButton({text: "$Cancel", controls: _cancelControls});
		cancelButton.addEventListener("press", this, "onCancelPress");

		var acceptButton = rightButtonPanel.addButton({text: "$Accept", controls: _acceptControls});
		acceptButton.addEventListener("press", this, "onAcceptPress");
		rightButtonPanel.updateButtons();
	}


	// @override OptionDialog
	public function initContent(): Void
	{
		skse.Log("SliderDialog.as: initContent()");
		sliderPanel.slider.maximum = sliderMax;
		sliderPanel.slider.minimum = sliderMin;
		sliderPanel.slider.liveDragging = true;
		sliderPanel.slider.snapInterval = sliderInterval;
		sliderPanel.slider.snapping = true;
		sliderPanel.slider.value = sliderValue;

		sliderFormatString = Translator.translate(sliderFormatString);
		updateValueText();

		//TODO: TESTING new slider value change event
		sliderPanel.slider.addEventListener("change", this, "onValueChange");

		FocusHandler.instance.setFocus(sliderPanel.slider, 0);
	}





// Buttons
//--------------------------------------------------------------------------------------------------

	// @GFx
	public function handleInput(details, pathToFocus): Boolean
	{
		skse.Log("SliderDialog.as: handleInput() :: details=" + details);
		var nextClip = pathToFocus.shift();
		if (nextClip.handleInput(details, pathToFocus))
			return true;

		if (GlobalFunc.IsKeyPressed(details, false)) {
			if (details.navEquivalent == NavigationCode.TAB) {
				onCancelPress();
				return true;
			} else if (details.navEquivalent == NavigationCode.ENTER) {
				onAcceptPress();
				return true;
			} else if (details.control == _defaultControls.name) {
				onDefaultPress();
				return true;
			}
		}

		return true; // Don't forward to higher level
	}


	private function onCancelPress(): Void
	{
		skse.Log("SliderDialog.as: onCancelPress()");
		skse.SendModEvent("ScribeHelmet_EventDialogCanceled", eventID);
		DialogManager.close();
	}


	private function onAcceptPress(): Void
	{
		skse.Log("SliderDialog.as: onAcceptPress()");
		skse.SendModEvent("ScribeHelmet_EventDialogAccepted", eventID, sliderValue);
		DialogManager.close();
	}


	private function onDefaultPress(): Void
	{
		skse.Log("SliderDialog.as: onDefaultPress()");
		sliderValue = sliderPanel.slider.value = sliderDefault;
		updateValueText();
	}





// Slider
//--------------------------------------------------------------------------------------------------

	private function onValueChange(event: Object): Void
	{
		skse.Log("SliderDialog.as: onValueChange()");

		sliderValue = event.target.value;
		updateValueText();

		if (onDialogValueChanged)
		{
			onDialogValueChanged();
		}

		dispatchEvent({type:"valueChanged", eventID:eventID, sliderValue:sliderValue});
	}



	private function updateValueText(): Void
	{
		var t = sliderFormatString	? GlobalFunctions.formatString(sliderFormatString, sliderValue)
									: Math.round(sliderValue * 100) / 100;
		sliderPanel.valueTextField.SetText(t);
		skse.Log("SliderDialog.as: updateValueText() :: t=" + t);
	}


}